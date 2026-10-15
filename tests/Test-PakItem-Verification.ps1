# Windows PowerShell 5.1: verify catalog gate using synthetic fixtures only.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
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
    $fakeText='@echo off'+$nl+'echo PACKAGED_ITEM> "%~3"'+$nl+'exit /b 0'+$nl
    [IO.File]::WriteAllText($fake,$fakeText,[Text.Encoding]::ASCII)
    $success= & $Script -ServerRoot $server -ItemDir (Join-Path $root 'success') -PakTool $fake
    if (-not $success.PakVerified -or $success.Source -ne 'PAK' -or
        $success.Tables -ne 15 -or @($success.Issues).Count -ne 0) {
        throw '15 successful tool exits must pass catalog verification protocol'
    }
    $fail=Join-Path $root 'failed-reader.cmd'
    $failText='@echo off'+$nl+'echo missing entry 1>&2'+$nl+'exit /b 4'+$nl
    [IO.File]::WriteAllText($fail,$failText,[Text.Encoding]::ASCII)
    $broken= & $Script -ServerRoot $server -ItemDir (Join-Path $root 'failed') -PakTool $fail 3>$null
    if ($broken.PakVerified -or $broken.Source -ne 'LOOSE_FALLBACK' -or
        @($broken.Issues).Count -lt 15) {
        throw 'Failed PAK lookups must keep item grants locked with diagnostics'
    }
    Write-Host 'PASS: missing tool, success protocol, failed PAK lookup all follow safe gate.'
    Write-Host 'Synthetic test does not verify real game PAK data.'
    # Clear the deliberate exit 4 from the fake broken extractor so that
    # the invoking Windows PowerShell GitHub Actions step exits successfully.
    $global:LASTEXITCODE=0
} finally {
    if (Test-Path -LiteralPath $root -PathType Container) {
        Remove-Item -LiteralPath $root -Force -Recurse
    }
}
