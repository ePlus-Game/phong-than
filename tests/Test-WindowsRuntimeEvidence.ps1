$ErrorActionPreference = 'Stop'
$path = Join-Path $PSScriptRoot '..\tools\Read-WindowsRuntimeEvidence.ps1'
$source = Get-Content -LiteralPath $path -Raw
$tokens = $null; $parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseInput(
    $source, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw "PowerShell parse failed: $($parseErrors[0])" }
$functions = @($ast.FindAll({
    param($node)
    $node -is [Management.Automation.Language.FunctionDefinitionAst] -and
    $node.Name -in @('Test-WorldReadyRecord', 'Test-PortCoverage')
}, $true))
if ($functions.Count -ne 2) { throw 'Missing pure test helpers' }
foreach ($function in $functions) { Invoke-Expression $function.Extent.Text }
function Assert([bool]$actual, [string]$message) {
    if (-not $actual) { throw "FAIL: $message" }
}
$valid = "WORLD_READY bishop_pid=1234 service=1001 maps=102" + [char]10
Assert (Test-WorldReadyRecord -Content $valid -BishopPid 1234 -ServiceId 1001 -ExpectedMapCount 102) 'complete marker'
Assert (-not (Test-WorldReadyRecord -Content $valid -BishopPid 55 -ServiceId 1001 -ExpectedMapCount 102)) 'wrong PID'
Assert (-not (Test-WorldReadyRecord -Content $valid -BishopPid 1234 -ServiceId 1002 -ExpectedMapCount 102)) 'wrong service'
Assert (-not (Test-WorldReadyRecord -Content $valid -BishopPid 1234 -ServiceId 1001 -ExpectedMapCount 100)) 'wrong maps'
Assert (-not (Test-WorldReadyRecord -Content ($valid.TrimEnd()) -BishopPid 1234 -ServiceId 1001 -ExpectedMapCount 102)) 'partial line'
Assert (Test-WorldReadyRecord -Content ($valid + "WORLD_READY bishop_pid=1234 service=1001 maps=102" + [char]13 + [char]10) -BishopPid 1234 -ServiceId 1001 -ExpectedMapCount 102) 'CRLF accepted'
Assert (-not (Test-WorldReadyRecord -Content ("x" + $valid) -BishopPid 1234 -ServiceId 1001 -ExpectedMapCount 102)) 'marker anchored'
Assert (Test-PortCoverage -ObservedPorts @(5001, 5002) -RequiredPorts @(5001)) 'one port'
Assert (Test-PortCoverage -ObservedPorts @(5622, 5632, 9999) -RequiredPorts @(5622, 5632)) 'bishop ports'
Assert (-not (Test-PortCoverage -ObservedPorts @(5622) -RequiredPorts @(5622, 5632))) 'missing listener'
Assert (-not (Test-PortCoverage -ObservedPorts @(5001) -RequiredPorts @())) 'empty requirements'
Assert (-not (Test-PortCoverage -ObservedPorts @(5001) -RequiredPorts @(0))) 'invalid requirement'
foreach ($unsafe in @('Start-Process', 'Stop-Process', 'Invoke-Sqlcmd', 'sqlcmd.exe',
                      'Invoke-WebRequest', 'Get-Credential', 'ConvertFrom-SecureString')) {
    Assert (-not $source.Contains($unsafe)) "read-only source must not call $unsafe"
}
foreach ($flag in @('login_verified = $false', 'save_relogin_verified = $false',
                     'gameplay_verified = $false', 'database_modified = $false')) {
    Assert ($source.Contains($flag)) "must keep $flag false"
}
Write-Host 'PASS: Windows readiness parser and read-only boundaries'
