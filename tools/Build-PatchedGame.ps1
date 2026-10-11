# Build fixed Phong Than code from a separate copy, preserving original game source bytes.
[CmdletBinding()]
param(
    [ValidateSet('Modern','VC6')][string]$Toolchain = 'Modern',
    [ValidateSet('Release','Debug')][string]$Configuration = 'Release',
    [string]$SourceRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'PhongThanSource'),
    [Parameter(Mandatory=$true)][string]$WorkRoot,
    [switch]$PreflightOnly,
    [switch]$KeepGoing
)
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd('\')
$source = [IO.Path]::GetFullPath($SourceRoot).TrimEnd('\')
$work = [IO.Path]::GetFullPath($WorkRoot).TrimEnd('\')
if ($Toolchain -eq 'Modern' -and $Configuration -ne 'Release') {
    throw 'Modern build supports Release only. For Debug use -Toolchain VC6.'
}
if ($work -ieq $repo -or $work.StartsWith($repo + '\',[StringComparison]::OrdinalIgnoreCase)) {
    throw 'WorkRoot MUST be outside the Git checkout.'
}
if ($work -ieq $source -or $work.StartsWith($source + '\',[StringComparison]::OrdinalIgnoreCase) -or
    $source.StartsWith($work + '\',[StringComparison]::OrdinalIgnoreCase)) {
    throw 'WorkRoot MUST be separate from SourceRoot.'
}
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { throw 'Install Python 3.10+ before building.' }
$preflight = @((Join-Path $repo 'tools/release_preflight.py'), '--source-root', $source,
               '--workspace', $work, '--toolchain', $Toolchain)
if (-not $PreflightOnly) { $preflight += '--check-sdk' }
Push-Location $repo
try {
    & $python.Source @preflight
    if ($LASTEXITCODE -ne 0) { throw 'Build preflight failed.' }
    if ($PreflightOnly) {
        Write-Host 'PREFLIGHT PASSED — no game binaries built' -ForegroundColor Green
        return
    }
    if (Test-Path -LiteralPath $work) { throw "Refusing to overwrite existing workspace: $work" }
    $parent = Split-Path -Parent $work
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $work -Recurse -ErrorAction Stop

    & $python.Source (Join-Path $repo 'tools/legacy_hardening.py') '--target' $work '--apply'
    if ($LASTEXITCODE -ne 0) { throw 'Failed to apply security/build fixes.' }

    if ($Toolchain -eq 'Modern') {
        $build = Join-Path $work 'Build/Build-Modern.ps1'
    } else {
        $build = Join-Path $work 'Build/Build-PhongThan.ps1'
    }
    $arguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$build)
    if ($Toolchain -eq 'VC6') { $arguments += @('-Configuration',$Configuration) }
    if ($Toolchain -eq 'Modern' -and $KeepGoing) { $arguments += '-KeepGoing' }
    $powershell = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $powershell)) {
        $powershell = (Get-Command powershell.exe -ErrorAction Stop).Source
    }
    & $powershell @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Compilation failed. Check build logs inside $work"
    }
    Write-Host "Compiler finished successfully. NOT a validated playable game: $work" -ForegroundColor Green
} finally {
    Pop-Location
}
