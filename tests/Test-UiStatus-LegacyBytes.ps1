# Regression: read UiStatus as raw one-byte legacy data, not PowerShell UTF-8 text.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$file=Join-Path $RepoRoot 'PhongThanRuntime-Staging\Client\Ui\ui3\UiStatus.ini'
$font=Join-Path $RepoRoot 'PhongThanRuntime-Staging\Client\font\14.fnt'
$raw=[IO.File]::ReadAllBytes($file)
$latin1=[Text.Encoding]::GetEncoding(28591)
$lines=$latin1.GetString($raw) -split "\r?\n"
if ($lines.Count -ne 2605) { throw "Unexpected UI layout: $($lines.Count) lines" }
$expected=@{
    248 = '56-F2-20-6B-68-DD'
    258 = '4D-61-20-70-68-B8-70'
    268 = '54-CB-70-20-74-72-75-6E-67'
    278 = '4C-AB-69-20-73-B8-74'
    288 = '42-A8-6E-67-20-73-B8-74'
    298 = '54-68-E6-20-73-B8-74'
    308 = '48-E1-61-20-73-B8-74'
}
foreach($number in @($expected.Keys)) {
    $line=$lines[$number-1]
    if ($line -notmatch '^Text=(.*)$') { throw "Missing Text at line $number" }
    $hex=[BitConverter]::ToString($latin1.GetBytes($Matches[1]))
    if ($hex -cne $expected[$number]) { throw "Wrong TCVN3 bitmap code at line ${number}: $hex" }
}
$fbytes=[IO.File]::ReadAllBytes($font)
if ($fbytes.Length -lt 1040) { throw 'Font 14 is missing/incomplete' }
$mapped=New-Object 'bool[]' 256
for($i=0;$i -lt 256;$i++) { $mapped[$i]=[BitConverter]::ToUInt32($fbytes,16+4*$i) -gt 0 }
$restored=0
for($number=248;$number -le 448;$number++) {
    $line=$lines[$number-1]
    if ($line -notmatch '^\s*(Text|Tip)\s*=(.*)$') { continue }
    $value=$Matches[2]
    $chars=$latin1.GetBytes($value)
    $hasHigh=$false
    foreach($byte in $chars) {
        if ($byte -ge 128) {
            $hasHigh=$true
            if (-not $mapped[$byte]) { throw "Missing font glyph at line $number, byte $byte" }
        }
    }
    if ($hasHigh) { ++$restored }
}
if ($restored -ne 27) { throw "Expected 27 single-byte UI labels, found $restored" }
Write-Host "PASS: 27 restored UiStatus labels use mapped one-byte VNG font glyphs; all other UI lines untouched by this test."
