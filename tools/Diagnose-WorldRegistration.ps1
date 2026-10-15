# Read-only WORLD_READY diagnostics; never starts game, touches SQL or edits PAKs.
[CmdletBinding()]
param(
    [string]$RuntimeRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'PhongThanRuntime-Staging'),
    [ValidateRange(1,255)][int]$ExpectedMapCount = 102,
    [string]$ReportPath
)
$ErrorActionPreference = 'Stop'
$RuntimeRoot = [IO.Path]::GetFullPath($RuntimeRoot)
$server = Join-Path $RuntimeRoot 'Server'
if (-not (Test-Path -LiteralPath $server -PathType Container)) {
    throw "Missing runtime Server directory: $server"
}
$names = @('core_map_load_diag.log','gameserver_login_diag.log','bishop_world_diag.log','native_world_ready.log')
$logs = @{}
$metadata = @()
foreach ($name in $names) {
    $path = Join-Path $server $name
    $exists = Test-Path -LiteralPath $path -PathType Leaf
    $content = ''
    $modified = $null
    if ($exists) {
        $item = Get-Item -LiteralPath $path
        $modified = $item.LastWriteTimeUtc.ToString('o')
        # Never export raw logs which may contain network/player details.
        $content = (@(Get-Content -LiteralPath $path -Tail 256 -ErrorAction Stop) -join [Environment]::NewLine)
        # Old map diagnostics used literal backslash + n instead of newline.
        if ($name -eq 'core_map_load_diag.log') {
            $content = $content.Replace('\n', [Environment]::NewLine)
        }
    }
    $logs[$name] = $content
    $metadata += [pscustomobject]@{ name=$name; exists=[bool]$exists; modified_utc=$modified }
}
$mapEntries = @([regex]::Matches($logs['core_map_load_diag.log'], 'world_slot=(\d+)\s+configured_id=(\d+)'))
$lastSlot = $null
$lastId = $null
if ($mapEntries.Count -gt 0) {
    $last = $mapEntries[$mapEntries.Count-1]
    $lastSlot = [int]$last.Groups[1].Value
    $lastId = [int]$last.Groups[2].Value
}
$serverStages = @([regex]::Matches($logs['gameserver_login_diag.log'],
    'world_(?:register_blocked|hello_send_failed|map_count_invalid|registry_send_failed|registry_sent|service_registration_failed)'))
$lastServerStage = if ($serverStages.Count) { $serverStages[$serverStages.Count-1].Value } else { $null }
$bishopStages = @([regex]::Matches($logs['bishop_world_diag.log'],
    'phase=(world_hello_rejected|world_hello_accepted|registry_rejected|map_id_rejected|registry_accepted|ready_log_open_failed)\s+service=(\d+)\s+value=(\d+)'))
$lastBishopStage = if ($bishopStages.Count) {
    $m = $bishopStages[$bishopStages.Count-1]
    [pscustomobject]@{ phase=$m.Groups[1].Value; service=[int]$m.Groups[2].Value; value=[int]$m.Groups[3].Value }
} else { $null }
$readyEntries = @([regex]::Matches($logs['native_world_ready.log'],
    'WORLD_READY bishop_pid=(\d+) service=(\d+) maps=(\d+)'))
# An old marker with a recycled PID is NOT live readiness proof.
$markerSeen = $readyEntries.Count -gt 0
$classification = 'INSUFFICIENT_LOG_EVIDENCE'
$nextAction = 'Run Read-WindowsRuntimeEvidence.ps1 for fresh process and port evidence.'
if ($lastBishopStage -and $lastBishopStage.phase -eq 'ready_log_open_failed') {
    $classification = 'BISHOP_CANNOT_WRITE_READY_MARKER'
    $nextAction = 'Check permission to write Server/native_world_ready.log; do not restart services blindly.'
} elseif ($lastBishopStage -and $lastBishopStage.phase -in @('registry_rejected','map_id_rejected','world_hello_rejected')) {
    $classification = 'BISHOP_REJECTED_HANDSHAKE_OR_MAPS'
    $nextAction = 'Inspect relay ID, registry payload and map IDs in a separate test runtime.'
} elseif ($lastServerStage -in @('world_register_blocked','world_hello_send_failed','world_map_count_invalid','world_registry_send_failed','world_service_registration_failed')) {
    $classification = 'GAMESERVER_REGISTRATION_FAILED'
    $nextAction = 'Inspect GameServer relay state, gateway connection and loaded-map count.'
} elseif ($null -ne $lastSlot -and ($lastSlot+1) -lt $ExpectedMapCount) {
    $classification = 'MAP_PROGRESS_PARTIAL_OR_STALE'
    $nextAction = 'Check map load errors and whether log events came from the current process.'
} elseif ($lastBishopStage -and $lastBishopStage.phase -eq 'registry_accepted' -and -not $markerSeen) {
    $classification = 'REGISTRY_ACCEPTED_BUT_NO_MARKER'
    $nextAction = 'Check Bishop marker file creation in Server working directory.'
} elseif ($markerSeen) {
    $classification = 'HISTORICAL_WORLD_READY_MARKER_PRESENT'
    $nextAction = 'Verify PID, ServiceId and freshness with Read-WindowsRuntimeEvidence.ps1 before login.'
} elseif ($null -ne $lastSlot -and ($lastSlot+1) -ge $ExpectedMapCount) {
    $classification = 'MAPS_OBSERVED_WAITING_FOR_REGISTRATION'
    $nextAction = 'Check world hello/map registry handshake; map loading alone is not WORLD_READY.'
}
$result = [pscustomobject]@{
    status='DIAGNOSTIC_ONLY_NOT_WORLD_READY_PROOF'
    expected_maps=$ExpectedMapCount
    last_observed_map_slot=$lastSlot
    last_observed_map_id=$lastId
    map_events_in_tail=$mapEntries.Count
    latest_gameserver_stage=$lastServerStage
    latest_bishop_stage=$lastBishopStage
    historical_world_ready_marker_seen=[bool]$markerSeen
    classification=$classification
    next_action=$nextAction
    log_files=$metadata
    game_processes_modified=$false
    database_modified=$false
}
if ($ReportPath) {
    $destination = [IO.Path]::GetFullPath($ReportPath)
    if ($destination.StartsWith($RuntimeRoot.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)) {
        throw 'Report must be saved outside game runtime'
    }
    $parent = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        throw "Report directory does not exist: $parent"
    }
    $json = ConvertTo-Json -InputObject $result -Depth 6
    [IO.File]::WriteAllText($destination,$json+[Environment]::NewLine,[Text.UTF8Encoding]::new($false))
    Write-Host "Saved safe summary: $destination"
}
Write-Host "World diagnosis: $classification"
Write-Host "Next: $nextAction"
Write-Output $result
