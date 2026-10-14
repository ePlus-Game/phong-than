[CmdletBinding()]
param([string]$ProjectRoot=(Split-Path -Parent $PSScriptRoot),[string]$RuntimeRoot=(Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'PhongThanRuntime-Staging'),[int]$TimeoutSeconds=60,[int]$WorldReadyTimeoutSeconds=900)
$ErrorActionPreference='Stop'
function Read-NativeWorldReadyMarker {
    param([string]$Path,[long]$AfterOffset,[int]$BishopPid,[int]$ServiceId,[int]$ExpectedMapCount)
    if(-not (Test-Path -LiteralPath $Path -PathType Leaf)){return $null}
    $stream=[IO.File]::Open($Path,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite)
    try{
        if($AfterOffset -lt 0 -or $stream.Length -le $AfterOffset){return $null}
        [void]$stream.Seek($AfterOffset,[IO.SeekOrigin]::Begin)
        $reader=[IO.StreamReader]::new($stream,[Text.Encoding]::ASCII)
        try{$text=$reader.ReadToEnd()}finally{$reader.Dispose()}
    }finally{$stream.Dispose()}
    # Require a complete new line, the current Bishop PID and configured world.
    $pattern='(?m)^WORLD_READY bishop_pid=(\d+) service=(\d+) maps=(\d+)\r?\n'
    foreach($match in [regex]::Matches($text,$pattern)){
        if([int]$match.Groups[1].Value -eq $BishopPid -and
           [int]$match.Groups[2].Value -eq $ServiceId -and
           [int]$match.Groups[3].Value -eq $ExpectedMapCount){
            return [pscustomobject]@{BishopPid=$BishopPid;ServiceId=$ServiceId;MapCount=$ExpectedMapCount}
        }
    }
    return $null
}
& (Join-Path $ProjectRoot 'Tests\Test-NativeRuntime.ps1') -ProjectRoot $ProjectRoot -RuntimeRoot $RuntimeRoot | Out-Null
. (Join-Path $PSScriptRoot 'AccountDatabase.ps1')
$serverRoot=Join-Path $RuntimeRoot 'Server'
# No database setup or client changes are permitted if a runtime is already active.
# Check before LocalDB setup/restore, which can change data and locks.
$existing=@(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object {
    $_.ExecutablePath -and $_.ExecutablePath.StartsWith($serverRoot+'\',[StringComparison]::OrdinalIgnoreCase)
})
if($existing){throw "Server already running: $($existing.Name -join ', ')"}
$manifest=Get-Content (Join-Path $PSScriptRoot 'RUNTIME_CONTENT_MANIFEST.json') -Raw | ConvertFrom-Json
$pipe=Start-AccountLocalDb $manifest.RuntimeSettings.AccountLocalDbInstance
$db=Set-AccountDatabaseIni (Join-Path $serverRoot 'DataBase.ini') $pipe
# LocalDB can come back without [account] registered: re-attach it from
# PhongThanRuntime-State\sql, or restore Server\database\account.bak on a new machine.
$ptSetup=Join-Path (Split-Path -Parent $ProjectRoot) 'AdminWeb\PhongThan-Setup.ps1'
if (Test-Path -LiteralPath $ptSetup) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ptSetup -Step database | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Account database setup failed; refusing to start services.' }
}
Test-AccountDatabase32 $db 'account'
$expectedMapCount=[int]$manifest.DataRegistries.Gameplay.Map.ExpectedActiveMapCount
if($expectedMapCount -le 0){throw 'Missing ExpectedActiveMapCount in runtime content manifest.'}
$serverConfig=Get-Content -LiteralPath (Join-Path $serverRoot 'ServerCfg.ini') -Raw
$relaySection=[regex]::Match($serverConfig,'(?ims)^\[Relay\]\s*\r?\n(.*?)(?=^\[|\z)')
$serviceMatch=[regex]::Match($relaySection.Groups[1].Value,'(?im)^\s*ServiceId\s*=\s*(\d+)\s*$')
if(-not $serviceMatch.Success){throw 'Missing Relay.ServiceId in ServerCfg.ini.'}
$expectedServiceId=[int]$serviceMatch.Groups[1].Value
$readyLog=Join-Path $serverRoot 'native_world_ready.log'
$readyOffset=if(Test-Path -LiteralPath $readyLog -PathType Leaf){(Get-Item -LiteralPath $readyLog).Length}else{0L}
$services=@(
    @{Name='Goddess.exe';Ports=@(5001)},
    @{Name='PhongThanAccountServer.exe';Ports=@(5002)},
    @{Name='PhongThanRelay.exe';Ports=@(5003)},
    @{Name='Bishop.exe';Ports=@(5622,5632)},
    @{Name='GameServer.exe';Ports=@(6666)}
)
$started=[Collections.Generic.List[object]]::new()
$gameSocketStarted=$false
$bishopProcess=$null
$gameProcess=$null
try{
    foreach($service in $services){
        $process=Start-Process -FilePath (Join-Path $serverRoot $service.Name) -WorkingDirectory $serverRoot -WindowStyle Hidden -PassThru
        $started.Add($process)
        if($service.Name -eq 'Bishop.exe'){$bishopProcess=$process}
        if($service.Name -eq 'GameServer.exe'){$gameProcess=$process}
        $until=[DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
        do{
            $process.Refresh()
            if($process.HasExited){throw "$($service.Name) exited code=$($process.ExitCode)"}
            $owned=@(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object OwningProcess -eq $process.Id | Select-Object -ExpandProperty LocalPort)
            $missing=@($service.Ports | Where-Object {$_ -notin $owned})
            if(-not $missing.Count){
                if($service.Name -eq 'GameServer.exe'){$gameSocketStarted=$true}
                break
            }
            Start-Sleep -Milliseconds 250
        }while([DateTime]::UtcNow -lt $until)
        if($missing.Count){throw "$($service.Name) missing ports: $($missing -join ', ')"}
        [pscustomobject]@{Service=$service.Name;Pid=$process.Id;Ports=$owned;Status='LISTENING'}
    }
}catch{
    if(-not $gameSocketStarted){
        foreach($process in $started){$process.Refresh();if(-not $process.HasExited){Stop-Process -Id $process.Id -Force}}
    }else{
        Write-Warning 'Game socket is live; services were left running to preserve possible player saves.'
    }
    throw
}
# Deliberately outside the force-cleanup block: a readiness timeout must not
# kill a live game process that may already own a character session.
$readyDeadline=[DateTime]::UtcNow.AddSeconds($WorldReadyTimeoutSeconds)
$nextProgress=[DateTime]::UtcNow
$ready=$null
do{
    $bishopProcess.Refresh()
    $gameProcess.Refresh()
    if($bishopProcess.HasExited -or $gameProcess.HasExited){
        throw 'Gateway/GameServer exited before map readiness. Other services remain running; inspect their logs.'
    }
    $ready=Read-NativeWorldReadyMarker -Path $readyLog -AfterOffset $readyOffset -BishopPid $bishopProcess.Id -ServiceId $expectedServiceId -ExpectedMapCount $expectedMapCount
    if($ready){break}
    if([DateTime]::UtcNow -ge $nextProgress){
        $mapLog=Join-Path $serverRoot 'core_map_load_diag.log'
        $tail=if(Test-Path -LiteralPath $mapLog){(Get-Content -LiteralPath $mapLog -Tail 16) -join "`n"}else{''}
        $slots=[regex]::Matches($tail,'world_slot=(\d+) configured_id=(\d+)')
        if($slots.Count){
            $last=$slots[$slots.Count-1]
            Write-Host "Dang nap map: $([int]$last.Groups[1].Value+1)/$expectedMapCount (map $($last.Groups[2].Value)). Cho Bishop xac nhan WORLD_READY..."
        }else{Write-Host 'Dang nap the gioi. Cho Bishop xac nhan WORLD_READY...'}
        $nextProgress=[DateTime]::UtcNow.AddSeconds(15)
    }
    Start-Sleep -Milliseconds 1000
}while([DateTime]::UtcNow -lt $readyDeadline)
if(-not $ready){
    throw "Game socket is listening, but Bishop has not confirmed all $expectedMapCount maps. Services remain running; do not log in until world registration completes. Check $readyLog."
}
[pscustomobject]@{Service='PhongThan world';Pid=$gameProcess.Id;BishopPid=$bishopProcess.Id;MapCount=$ready.MapCount;Status='READY_FOR_LOGIN'}
