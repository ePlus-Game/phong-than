[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RuntimeRoot,
    [Parameter(Mandatory=$true)][string]$ManifestPath,
    [int]$ExpectedMapCount = 102,
    [switch]$CheckClient,
    [string]$ReportPath
)

# Pure read-only live process and port observation. No start/stop, DB or patches.
$ErrorActionPreference = 'Stop'

function Test-WorldReadyRecord {
    param([string]$Content, [int]$BishopPid, [int]$ServiceId, [int]$ExpectedMapCount)
    if ($BishopPid -le 0 -or $ServiceId -le 0 -or $ExpectedMapCount -le 0) { return $false }
    $pattern = '(?m)^WORLD_READY bishop_pid=(\d+) service=(\d+) maps=(\d+)\r?\n'
    foreach ($m in [regex]::Matches($Content, $pattern)) {
        if ([int]$m.Groups[1].Value -eq $BishopPid -and
            [int]$m.Groups[2].Value -eq $ServiceId -and
            [int]$m.Groups[3].Value -eq $ExpectedMapCount) { return $true }
    }
    return $false
}

function Test-PortCoverage {
    param([int[]]$ObservedPorts, [int[]]$RequiredPorts)
    if (-not $RequiredPorts -or $RequiredPorts.Count -eq 0) { return $false }
    foreach ($p in $RequiredPorts) {
        if ($p -le 0 -or $p -notin $ObservedPorts) { return $false }
    }
    return $true
}

$issues = [Collections.Generic.List[string]]::new()
$results = [Collections.Generic.List[object]]::new()
$root = [IO.Path]::GetFullPath($RuntimeRoot).TrimEnd('\')
$serverRoot = Join-Path $root 'Server'
$serverPrefix = [IO.Path]::GetFullPath($serverRoot).TrimEnd('\') + '\'
$clientPrefix = [IO.Path]::GetFullPath((Join-Path $root 'Client')).TrimEnd('\') + '\'
$names = @('Goddess.exe', 'PhongThanAccountServer.exe', 'PhongThanRelay.exe',
           'Bishop.exe', 'GameServer.exe')
$ports = $null
$serviceId = 0
$mapCount = $null
$worldReady = $false
$freshLog = $false

try {
    $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    $ports = $manifest.RuntimeSettings.ExpectedListeningPorts
    foreach ($name in $names) {
        if (-not $ports.PSObject.Properties[$name]) { $issues.Add("manifest missing $name") }
    }
    if ($ports.PSObject.Properties['S3Relay.exe']) {
        $issues.Add('manifest still references S3Relay.exe')
    }
} catch { $issues.Add('cannot read service port manifest') }

try {
    $ini = [IO.File]::ReadAllText((Join-Path $serverRoot 'ServerCfg.ini'))
    $section = [regex]::Match($ini, '(?ims)^\[Relay\][ \t]*\r?\n(.*?)(?=^\[|\z)')
    $m = [regex]::Match($section.Groups[1].Value, '(?im)^[ \t]*ServiceId[ \t]*=[ \t]*(\d+)[ \t]*$')
    if ($m.Success) { $serviceId = [int]$m.Groups[1].Value }
    else { $issues.Add('Relay.ServiceId missing from config') }
} catch { $issues.Add('ServerCfg.ini not readable') }

try {
    $mapText = [IO.File]::ReadAllText((Join-Path $serverRoot 'maps\WorldSet.ini'))
    $matches = [regex]::Matches($mapText, '(?m)^[ \t]*Count[ \t]*=[ \t]*(\d+)[ \t]*\r?$')
    if ($matches.Count -eq 1) { $mapCount = [int]$matches[0].Groups[1].Value }
    if ($mapCount -ne $ExpectedMapCount) { $issues.Add('wrong or ambiguous map count') }
} catch { $issues.Add('WorldSet.ini not readable') }

$listeners = @()
try { $listeners = @(Get-NetTCPConnection -State Listen -ErrorAction Stop) }
catch { $issues.Add('cannot inspect TCP listener ownership') }

$processes = @{}
foreach ($name in $names) {
    $candidates = @()
    try {
        $candidates = @(Get-CimInstance Win32_Process -Filter "Name='$name'" -ErrorAction Stop |
            Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith(
                $serverPrefix, [StringComparison]::OrdinalIgnoreCase) })
    } catch { $issues.Add("cannot inspect $name") }
    $required = @()
    if ($null -ne $ports -and $ports.PSObject.Properties[$name]) {
        $required = @($ports.$name | ForEach-Object { [int]$_ })
    }
    $row = [ordered]@{ name=$name; pid=$null; required_ports=$required;
                       listening_ports=@(); status='BLOCKED' }
    if ($candidates.Count -ne 1) {
        $issues.Add("expected one running $name in runtime Server")
    } else {
        $proc = $candidates[0]
        $processes[$name] = $proc
        $row.pid = [int]$proc.ProcessId
        $observed = @($listeners | Where-Object { $_.OwningProcess -eq $proc.ProcessId } |
            Select-Object -ExpandProperty LocalPort -Unique)
        $row.listening_ports = @($observed | Sort-Object)
        if (Test-PortCoverage -ObservedPorts $observed -RequiredPorts $required) {
            $row.status = 'LISTENING'
        } else { $issues.Add("missing port listener for $name") }
    }
    $results.Add([pscustomobject]$row)
}

if ($processes.ContainsKey('Bishop.exe') -and $serviceId -gt 0) {
    try {
        $bishop = $processes['Bishop.exe']
        $log = Get-Item -LiteralPath (Join-Path $serverRoot 'native_world_ready.log')
        $start = ([datetime]$bishop.CreationDate).ToUniversalTime()
        $freshLog = $log.LastWriteTimeUtc -ge $start.AddSeconds(-1)
        $args = @{ Content=[IO.File]::ReadAllText($log.FullName)
                   BishopPid=[int]$bishop.ProcessId
                   ServiceId=$serviceId
                   ExpectedMapCount=$ExpectedMapCount }
        $worldReady = $freshLog -and (Test-WorldReadyRecord @args)
    } catch { $issues.Add('world readiness marker unreadable') }
}
if (-not $worldReady) { $issues.Add('fresh matching WORLD_READY marker missing') }

$client = 'NOT_CHECKED'
if ($CheckClient) {
    try {
        $candidates = @(Get-CimInstance Win32_Process -Filter "Name='Game.exe'" |
            Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith(
                $clientPrefix, [StringComparison]::OrdinalIgnoreCase) })
        $client = if ($candidates.Count -eq 1) { 'RUNNING_NOT_LOGIN_VERIFIED' } else { 'NOT_RUNNING' }
    } catch { $client = 'UNKNOWN' }
}

$report = [ordered]@{
    status = if ($issues.Count -eq 0) { 'READY_FOR_LOGIN_CHECK' } else { 'BLOCKED' }
    scope = 'read_only_live_process_observation'
    map_count = $mapCount
    world_ready = [bool]$worldReady
    world_log_fresh = [bool]$freshLog
    services = @($results.ToArray())
    client = $client
    blockers = @($issues.ToArray() | Select-Object -Unique)
    process_started = $false
    database_modified = $false
    login_verified = $false
    save_relogin_verified = $false
    gameplay_verified = $false
}
$json = ConvertTo-Json -InputObject $report -Depth 7
if ($ReportPath) {
    $destination = [IO.Path]::GetFullPath($ReportPath)
    if ($destination.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Refusing to write report into game runtime'
    }
    $parent = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $parent)) { throw 'Report output directory does not exist' }
    [IO.File]::WriteAllText($destination, $json + [Environment]::NewLine, [Text.Encoding]::UTF8)
}
Write-Output $json
if ($issues.Count -gt 0) { exit 2 }
