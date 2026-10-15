# Isolated Windows PowerShell 5.1 units. Never dot-source the HTTP server.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$tokens=$null; $errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $RepoRoot 'AdminWeb\PhongThan-Admin.ps1'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw 'Backend parse failure' }
$names=@('Assert-EventTime','Get-EvNext','Get-EvWarn','Clamp','Get-Md5Upper','New-AdminOpsCode','Confirm-AdminOpsCode','Invoke-Route','Invoke-Scheduler')
foreach($name in $names) {
    $node=@($ast.FindAll({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name},$true))
    if ($node.Count -ne 1) { throw "Expected one production function: $name" }
    . ([scriptblock]::Create($node[0].Extent.Text))
}
$script:checks=0
function Check($ok,[string]$label) { if (-not $ok) { throw "FAIL: $label" }; $script:checks++ }
function Reject([scriptblock]$body,[string]$label) { $threw=$false; try { & $body | Out-Null } catch { $threw=$true }; Check $threw $label }
Check ((Assert-EventTime '0:00') -eq '00:00') 'normalize single-digit hour'
Check ((Assert-EventTime '23:59') -eq '23:59') 'last valid minute'
foreach($value in @('24:00','99:99','12:60','-1:00','1:2','20:00x',"20:00`n",'')) { Reject { Assert-EventTime $value } "reject time $value" }
Check ((Clamp -1 0 10) -eq 0) 'clamp lower bound'
Check ((Clamp 11 0 10) -eq 10) 'clamp upper bound'
Check ((Clamp 5 0 10) -eq 5) 'keep valid quantity'
Check ((Get-Md5Upper 'abcdef') -ceq 'E80B5017098950FC58AAD83C8C14978E') 'legacy account digest'
foreach($pw in @('abc','abc def','abcdefghijklmnopq')) { Reject { Get-Md5Upper $pw } 'reject invalid password' }
$now=[datetime]'2026-10-15T20:00:00'
$row=[pscustomobject]@{days='4';hh=20;mm=0}
Check ((Get-EvNext $row $now) -eq $now) 'event start is included'
Check ((Get-EvNext $row $now.AddMinutes(2)) -eq $now) 'retain firing window'
Check ((Get-EvNext $row $now.AddMinutes(3)) -eq $now.AddDays(7)) 'window end rolls one week'
$EvVngVt=@('20:00')
Check (@(Get-EvWarn ([pscustomobject]@{kind='thuongchu';hh=20;mm=44})).Count -eq 1) 'warn overlapping Thuong Chu'
Check (@(Get-EvWarn ([pscustomobject]@{kind='thuongchu';hh=20;mm=45})).Count -eq 0) 'accept Thuong Chu minute 45'
$script:AdminOpsCodes=@{}
$code=New-AdminOpsCode 'rollback' 'fixture'
Confirm-AdminOpsCode 'rollback' 'fixture' $code
Reject { Confirm-AdminOpsCode 'rollback' 'fixture' $code } 'confirmation is single-use'
$code=New-AdminOpsCode 'rollback' 'fixture'
Reject { Confirm-AdminOpsCode 'rollback' 'other' $code } 'confirmation bound to resource'
$code=New-AdminOpsCode 'rollback' 'fixture'
$script:AdminOpsCodes.rollback.until=(Get-Date).AddMinutes(-1)
Reject { Confirm-AdminOpsCode 'rollback' 'fixture' $code } 'expired confirmation'
# Route boundaries are mocks: no HTTP listener, SQL, bridge files or game process.
$Token='unit-token';$script:updates=0;$script:saves=0;$script:reply=$null
function Update-Results { $script:updates++ }
function Send-Json($ctx,$obj,[int]$Code=200) { $script:reply=@{body=$obj;code=$Code} }
function Read-Body($ctx) { $script:body }
function Save-Json($path,$value) { $script:saves++ }
function Context([string]$path,[string]$method,[string]$token) { [pscustomobject]@{Request=[pscustomobject]@{Url=[uri]('http://localhost'+$path);QueryString=@{};Headers=@{'X-PT-Token'=$token};HttpMethod=$method}} }
Invoke-Route (Context '/api/events' 'POST' 'bad-token')
Check ($script:reply.code -eq 403 -and $script:updates -eq 0 -and $script:saves -eq 0) 'auth fails before business logic'
$Events=New-Object Collections.ArrayList;$EventsPath='unused'
$script:body=[pscustomobject]@{name='fixture';time='99:99';enabled=$true;days=@();actions=@()}
Reject { Invoke-Route (Context '/api/events' 'POST' $Token) } 'invalid event rejected before save'
Check ($Events.Count -eq 0 -and $script:saves -eq 0) 'invalid event has no side effects'
$script:body.time='9:05'
Invoke-Route (Context '/api/events' 'POST' $Token)
Invoke-Route (Context '/api/events' 'POST' $Token)
Check ($Events.Count -eq 2 -and $Events[0].id -ne $Events[1].id) 'rapid event creates have unique IDs'
Check ($Events[0].time -eq '09:05') 'route stores canonical time'
# Previously saved invalid times must never roll into another date.
$Events=New-Object Collections.ArrayList
[void]$Events.Add([pscustomobject]@{enabled=$true;time='99:99';days=@();lastRun=''})
$script:fired=0
function Invoke-AdminOpsTick {}
function Invoke-Event($event,$reason) { $script:fired++ }
Invoke-Scheduler
Check ($script:fired -eq 0) 'scheduler ignores invalid legacy rows'
Write-Host "PASS: $script:checks isolated backend assertions; no game or database accessed."
