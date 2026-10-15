# Synthetic fixtures only. Never starts/stops game or touches SQL/PAKs.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$tool = Join-Path $RepoRoot 'tools\Diagnose-WorldRegistration.ps1'
$tokens=$null;$errors=$null
[void][Management.Automation.Language.Parser]::ParseFile($tool,[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw "Diagnostic script syntax failed: $($errors[0].Message)" }
$folder = Join-Path ([IO.Path]::GetTempPath()) ('pt-world-diag-' + [guid]::NewGuid().ToString('N'))
$server = Join-Path $folder 'Server'
$enc = [Text.Encoding]::ASCII
function Put([string]$File,[string]$Value) {
    [IO.File]::WriteAllText((Join-Path $server $File),$Value,$enc)
}
function Assert-Case([string]$Expected) {
    $result = & $tool -RuntimeRoot $folder -ExpectedMapCount 102 | Where-Object { $_ -is [pscustomobject] }
    if ($result.classification -ne $Expected) {
        throw "Expected $Expected, got $($result.classification)"
    }
    if ($result.game_processes_modified -or $result.database_modified -or
        $result.status -ne 'DIAGNOSTIC_ONLY_NOT_WORLD_READY_PROOF') {
        throw 'Diagnostic script is incorrectly claiming state mutation or readiness'
    }
    return $result
}
try {
    New-Item -ItemType Directory -Path $server -Force | Out-Null
    $literalOld = 'world_slot=0 configured_id=1001\nworld_slot=21 configured_id=1022\n'
    Put 'core_map_load_diag.log' $literalOld
    $r = Assert-Case 'MAP_PROGRESS_PARTIAL_OR_STALE'
    if ($r.last_observed_map_slot -ne 21 -or $r.map_events_in_tail -ne 2) {
        throw 'Legacy literal escaped newline was not parsed'
    }

    Put 'gameserver_login_diag.log' 'world_map_count_invalid count=0 limit=255'
    [void](Assert-Case 'GAMESERVER_REGISTRATION_FAILED')
    Put 'gameserver_login_diag.log' ''
    Put 'bishop_world_diag.log' 'phase=registry_rejected service=0 value=0'
    [void](Assert-Case 'BISHOP_REJECTED_HANDSHAKE_OR_MAPS')
    Put 'bishop_world_diag.log' 'phase=registry_accepted service=1001 value=102'
    [void](Assert-Case 'REGISTRY_ACCEPTED_BUT_NO_MARKER')
    Put 'bishop_world_diag.log' ''
    Put 'core_map_load_diag.log' ''
    Put 'native_world_ready.log' 'WORLD_READY bishop_pid=123 service=1001 maps=102'
    [void](Assert-Case 'HISTORICAL_WORLD_READY_MARKER_PRESENT')

    $out = Join-Path ([IO.Path]::GetTempPath()) ('pt-world-diagnostic-'+[guid]::NewGuid().ToString('N')+'.json')
    try {
        $result = & $tool -RuntimeRoot $folder -ExpectedMapCount 102 -ReportPath $out |
            Where-Object { $_ -is [pscustomobject] }
        $json = Get-Content -LiteralPath $out -Raw | ConvertFrom-Json
        if ($json.classification -ne $result.classification -or $json.game_processes_modified) {
            throw 'Safe JSON report inconsistent'
        }
        $raw=[IO.File]::ReadAllText($out)
        if ($raw -match '127\.0\.0\.1|password=|DataBase\.ini=') {
            throw 'Potential secret or address leaked to JSON'
        }
    } finally {
        if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }
    }
    Write-Host 'PASS: diagnosis classifies stale map logs, GameServer failure, Bishop rejection, missing marker and old marker without accepting readiness.'
} finally {
    if (Test-Path -LiteralPath $folder -PathType Container) {
        Remove-Item -LiteralPath $folder -Force -Recurse
    }
}
