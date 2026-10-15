# Windows PowerShell 5.1: verify catalog gate using synthetic fixtures only.
[CmdletBinding()]
param([string]$RepoRoot)
$ErrorActionPreference='Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
$Admin = Join-Path $RepoRoot 'AdminWeb'
$Script = Join-Path $Admin 'Initialize-ItemTables.ps1'
$Installer = Join-Path $Admin 'Install-Pak-Extractor.ps1'
foreach($file in @($Script,$Installer,(Join-Path $Admin 'PhongThan-Admin.ps1'))) {
    $tokens=$null;$errors=$null
    [void][Management.Automation.Language.Parser]::ParseFile($file,[ref]$tokens,[ref]$errors)
    if ($errors.Count) { throw "PowerShell 5.1 parser failed ($file): $($errors[0].Message)" }
}
$root=Join-Path ([IO.Path]::GetTempPath()) ('pt-pak-contract-'+[guid]::NewGuid().ToString('N'))
$server=Join-Path $root 'Server'
$loose=Join-Path $server 'settings\item\001'
$tables=@('meleeweapon','rangeweapon','armor','ring','amulet','boot','belt','helm','cuff','pendant','horse','ibitem','magicscript','material','questkey')
try {
    New-Item -ItemType Directory -Path $loose -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $server 'package.ini'), '[Package]', [Text.Encoding]::ASCII)
    foreach($t in $tables) {
        [IO.File]::WriteAllText((Join-Path $loose ($t+'.txt')), "LOOSE_"+$t, [Text.Encoding]::ASCII)
    }
    $missing= & $Script -ServerRoot $server -ItemDir (Join-Path $root 'missing') -PakTool (Join-Path $root 'no-tool.exe') 3>$null
    if ($missing.PakVerified -or $missing.Source -ne 'LOOSE_FALLBACK' -or
        $missing.Tables -ne 15 -or @($missing.Issues).Count -lt 1) {
        throw 'Missing reader must lock grants and explain reason'
    }
    # Fake cmd only simulates extractor CLI; it is NOT actual PAK validation.
    $fake=Join-Path $root 'fake-reader.cmd'
    $nl=[Environment]::NewLine
    # argv[2] is @pathfile; remove the @ before opening it.
    $fakeText='@echo off'+$nl+'echo PACKAGED_ITEM> "%~3"'+$nl+
        'set "PATHARG=%~2"'+$nl+'set /p VIRTUAL=<"%PATHARG:~1%"'+$nl+
        'echo PAK_ENTRY=%VIRTUAL%'+$nl+'echo PAK_INDEX=0'+$nl+'echo BYTES=15'+$nl+'exit /b 0'+$nl
    [IO.File]::WriteAllText($fake,$fakeText,[Text.Encoding]::ASCII)
    $success= & $Script -ServerRoot $server -ItemDir (Join-Path $root 'success') -PakTool $fake
    if (-not $success.PakVerified -or $success.Source -ne 'PAK' -or
        $success.Tables -ne 15 -or $success.VerifiedTables -ne 15 -or @($success.Issues).Count -ne 0) {
        throw '15 successful tool exits must pass catalog verification protocol'
    }
    foreach($mode in @('exit','empty','absent','receipt','path','size','index')) {
        $bad = switch($mode) {
            'exit' { 'exit /b 4' }
            'empty' { 'type nul > "%~3"' }
            'absent' { 'del "%~3"' }
            'receipt' { 'rem no receipt' }
            'path' { 'echo PAK_ENTRY=\wrong.txt' }
            'size' { 'echo PAK_ENTRY=%VIRTUAL%'+$nl+'echo PAK_INDEX=0'+$nl+'echo BYTES=999' }
            'index' { 'echo PAK_ENTRY=%VIRTUAL%'+$nl+'echo PAK_INDEX=-1'+$nl+'echo BYTES=15' }
        }
        # Only armor is invalid: the other 14 succeed. Reuse the verified cache.
        $oneBad=$fakeText.Replace('echo PAK_ENTRY=%VIRTUAL%',
            'if "%VIRTUAL%"=="\settings\item\001\armor.txt" ('+$nl+$bad+$nl+'exit /b 0'+$nl+')'+$nl+'echo PAK_ENTRY=%VIRTUAL%')
        [IO.File]::WriteAllText($fake,$oneBad,[Text.Encoding]::ASCII)
        $partial= & $Script -ServerRoot $server -ItemDir (Join-Path $root 'success') -PakTool $fake 3>$null
        if($partial.PakVerified -or $partial.VerifiedTables -ne 14 -or
            $partial.Source -ne 'LOOSE_FALLBACK' -or @($partial.Issues).Count -lt 1) {
            throw "One invalid table must lock all grants: $mode"
        }
        if([IO.File]::ReadAllText((Join-Path $root 'success\armor.txt')) -ne 'LOOSE_armor') {
            throw "Stale verified cache retained: $mode"
        }
    }
    [IO.File]::WriteAllText($fake,$fakeText,[Text.Encoding]::ASCII)
    Push-Location $root
    try {
        $relative= & $Script -ServerRoot 'Server' -ItemDir 'relative-cache' -PakTool '.\fake-reader.cmd'
        if(-not $relative.PakVerified){throw 'Relative arguments must resolve before changing location'}
    } finally {Pop-Location}
    $fail=Join-Path $root 'failed-reader.cmd'
    $failText='@echo off'+$nl+'echo missing entry 1>&2'+$nl+'exit /b 4'+$nl
    [IO.File]::WriteAllText($fail,$failText,[Text.Encoding]::ASCII)
    $broken= & $Script -ServerRoot $server -ItemDir (Join-Path $root 'failed') -PakTool $fail 3>$null
    if ($broken.PakVerified -or $broken.Source -ne 'LOOSE_FALLBACK' -or
        @($broken.Issues).Count -lt 15) {
        throw 'Failed PAK lookups must keep item grants locked with diagnostics'
    }
    # Installer must not replace existing tool files after a partial/failed audit.
    # A fixture verifier avoids executing synthetic PE headers as native code.
    $installRoot=Join-Path $root 'install-repo'
    $installAdmin=Join-Path $installRoot 'AdminWeb'
    $installBin=Join-Path $installAdmin 'bin'
    $installServer=Join-Path $installRoot 'PhongThanRuntime-Staging\Server'
    $bundle=Join-Path $root 'bundle'
    New-Item -ItemType Directory -Force $installBin,$installServer,$bundle | Out-Null
    [IO.File]::WriteAllText((Join-Path $installServer 'package.ini'),'[Package]')
    $names=@('PakEntryExtract.exe','Engine.dll','LuaLibDll.dll')
    foreach($name in $names) {
        $pe=New-Object byte[] 1024
        $pe[0]=77;$pe[1]=90;$pe[60]=128;$pe[128]=80;$pe[129]=69;$pe[132]=76;$pe[133]=1
        [IO.File]::WriteAllBytes((Join-Path $bundle $name),$pe)
        [IO.File]::WriteAllText((Join-Path $installBin $name),'original')
    }
    $zip=Join-Path $root 'reader.zip'
    Compress-Archive -Path (Join-Path $bundle '*') -DestinationPath $zip
    # Exercise the real -File entry point without -RepoRoot, from an unrelated
    # working directory. Stop at the fixture verifier, before installing tools.
    $fixtureInstaller=Join-Path $installAdmin 'Install-Pak-Extractor.ps1'
    Copy-Item -LiteralPath $Installer -Destination $fixtureInstaller
    [IO.File]::WriteAllText((Join-Path $installAdmin 'Initialize-ItemTables.ps1'),
        'throw "DEFAULT_ROOT_VERIFIER_REACHED"')
    Push-Location $bundle
    $savedPreference=$ErrorActionPreference
    try {
        # The marker is an intentional child-process error, captured for assertion.
        $ErrorActionPreference='Continue'
        $log=@(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureInstaller -ZipPath $zip 2>&1 | ForEach-Object { "$_" })
        $childExit=$LASTEXITCODE
    } finally {$ErrorActionPreference=$savedPreference;Pop-Location}
    if($childExit -eq 0 -or ($log -join "`n") -notmatch 'DEFAULT_ROOT_VERIFIER_REACHED') {
        throw "Default RepoRoot did not reach the verifier: $($log -join ' | ')"
    }
    # Bundled reader must reach the same verifier without ZIP, gh or download.
    foreach($name in $names) {Copy-Item -LiteralPath (Join-Path $bundle $name) -Destination (Join-Path $installBin $name) -Force}
    $savedPreference=$ErrorActionPreference
    try {
        $ErrorActionPreference='Continue'
        $log=@(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fixtureInstaller 2>&1 | ForEach-Object { "$_" })
        $childExit=$LASTEXITCODE
    } finally {$ErrorActionPreference=$savedPreference}
    if($childExit -eq 0 -or ($log -join "`n") -notmatch 'DEFAULT_ROOT_VERIFIER_REACHED' -or
        ($log -join "`n") -notmatch 'Use official reader bundled with source') {
        throw "Bundled reader must verify PAK without downloading: $($log -join ' | ')"
    }
    foreach($name in $names) {[IO.File]::WriteAllText((Join-Path $installBin $name),'original')}
    foreach($audit in @(
        '[pscustomobject]@{PakVerified=$false;Tables=15;VerifiedTables=14;Issues=@("fixture failure")}',
        '[pscustomobject]@{PakVerified=$true;Tables=15;VerifiedTables=14;Issues=@("inconsistent count")}'
    )) {
        [IO.File]::WriteAllText((Join-Path $installAdmin 'Initialize-ItemTables.ps1'),$audit)
        $rejected=$false
        try { & $Installer -RepoRoot $installRoot -ZipPath $zip | Out-Null }
        catch {$rejected=$true}
        if(-not $rejected){throw 'Installer accepted an incomplete audit'}
        foreach($name in $names) {
            if([IO.File]::ReadAllText((Join-Path $installBin $name)) -ne 'original') {
                throw "Installer overwrote tool despite failed audit: $name"
            }
        }
    }
    Write-Host 'PASS: 15/15 receipt protocol; every single-table failure locks; stale cache and relative paths; installer refuses partial audits without replacing tools.'
    Write-Host 'Synthetic test does not verify real game PAK data.'
    # Clear the deliberate exit 4 from the fake broken extractor so that
    # the invoking Windows PowerShell GitHub Actions step exits successfully.
    $global:LASTEXITCODE=0
} finally {
    if (Test-Path -LiteralPath $root -PathType Container) {
        Remove-Item -LiteralPath $root -Force -Recurse
    }
}
