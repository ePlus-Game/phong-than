[CmdletBinding()]
param([string]$RepoRoot)
$ErrorActionPreference='Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }
$vswhere=Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs=& $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if(-not $vs){throw 'MSVC x86 tools required'}
$vcvars=Join-Path $vs 'VC\Auxiliary\Build\vcvarsall.bat'
$lines=& cmd.exe /c ('"'+$vcvars+'" x86 >nul && set')
foreach($line in $lines) {
    $i=$line.IndexOf('=')
    if($i -gt 0){[Environment]::SetEnvironmentVariable($line.Substring(0,$i),$line.Substring($i+1),'Process')}
}
$out=Join-Path $RepoRoot 'PhongThanSource\Output\TownPortalTests'
New-Item -ItemType Directory -Force $out | Out-Null
$exe=Join-Path $out 'TownPortalTests.exe'
& cl.exe /nologo /EHsc /MT (Join-Path $RepoRoot 'PhongThanSource\Tests\Native\TownPortalTests.cpp') "/Fe$exe" "/Fo$out\TownPortalTests.obj"
if($LASTEXITCODE -ne 0){throw 'Town portal test build failed'}
& $exe (Join-Path $RepoRoot 'AdminWeb\bin\LuaLibDll.dll') (Join-Path $RepoRoot 'PhongThanRuntime-Staging\Server\script\phongthan\npc_fix\exit_truyen_tong.lua') (Join-Path $RepoRoot 'tests\town_portal.lua')
if($LASTEXITCODE -ne 0){throw "Town portal tests failed: $LASTEXITCODE"}
