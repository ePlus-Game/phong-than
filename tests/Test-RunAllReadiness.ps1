$ErrorActionPreference = 'Stop'
$path = Join-Path $PSScriptRoot '..\AdminWeb\PhongThan-RunAll.ps1'
$source = Get-Content -LiteralPath $path -Raw
$tokens = $null
$errors = $null
[void][Management.Automation.Language.Parser]::ParseInput($source, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw "Launcher syntax error: $($errors[0])" }
function Assert([bool]$condition, [string]$reason) {
    if (-not $condition) { throw "FAIL: $reason" }
}
$guard = $source.IndexOf('Assert-ExistingServerReady', $source.IndexOf('# Reject stale/unready clusters'))
$setup = $source.IndexOf('-Step all')
$clientPatch = $source.IndexOf('PhongThan-ClientPatch.ps1')
$admin = $source.IndexOf("Step '3/3 Mo web admin'")
Assert ($guard -ge 0 -and $guard -lt $setup -and $guard -lt $clientPatch) 'existing service readiness before side effects'
Assert ($source.Contains("Read-WindowsRuntimeEvidence.ps1")) 'must invoke read-only live observer'
Assert ($source.Contains("-ExpectedMapCount 102")) 'must require 102 maps'
Assert ($source.Contains("READY_FOR_LOGIN_CHECK")) 'must require observer success'
Assert ($source.Contains("report.world_ready")) 'must require fresh world marker'
Assert ($source.Contains('$code -ne 0')) 'must propagate observer failures'
Assert ($source.Contains("Assert-ExistingServerReady`n        Write-Host 'Da tim thay 5")) 'must recheck existing services before admin'
Assert ($admin -gt $source.LastIndexOf('Assert-ExistingServerReady')) 'no admin before readiness'
Assert ($source.Contains("PhongThan-Admin-Console.ps1")) 'must launch dedicated admin console'
Assert ($source.Contains("'-NoExit'")) 'admin console must stay open after error'
$adminPath = Join-Path $PSScriptRoot '..\AdminWeb\PhongThan-Admin-Console.ps1'
$admin = Get-Content -LiteralPath $adminPath -Raw
[void][Management.Automation.Language.Parser]::ParseInput($admin, [ref]$tokens, [ref]$errors)
Assert ($errors.Count -eq 0) 'admin console must parse on Windows PowerShell'
Assert ($admin.Contains('Start-Transcript')) 'must persist admin startup log'
Assert ($admin.Contains('Stop-Transcript')) 'must finish transcript'
Assert ($admin.Contains('PhongThan-Admin.ps1')) 'must invoke original admin script'
Assert ($admin.Contains('ADMIN STARTUP FAILED:')) 'must expose fatal startup error'
Write-Host 'PASS: WORLD_READY guard and persistent Admin startup diagnostics'
