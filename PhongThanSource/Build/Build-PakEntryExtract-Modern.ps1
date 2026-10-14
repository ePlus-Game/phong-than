# Build an isolated PAK extractor using a freshly-built MSVC x86 Engine DLL.
# Do not replace Engine.dll in Client/Server runtime.
[CmdletBinding()]
param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($ProjectRoot)
$out = Join-Path $root 'OutputModern\Tools'
$src = Join-Path $root 'Tests\Native\PakEntryExtract.cpp'
$engineLib = Join-Path $root 'OutputModern\lib\Engine.lib'
$engineDll = Join-Path $root 'OutputModern\Server\Engine.dll'
$luaDll = Join-Path $root 'OutputModern\Server\LuaLibDll.dll'
$luaCopy = Join-Path $out 'LuaLibDll.dll'
$engineHeaders = Join-Path $root 'Sources\Engine\Src'
$engineInc = Join-Path $root 'Sources\Engine\Include'
$dxInc = Join-Path $root 'ThirdParty\dx9csdk\Include'
$gdiInc = Join-Path $root 'ThirdParty\WindowsSDK\GDIPlus\Include'
# Keep Windows SDK ahead of old DirectX SDK: old basetsd.h breaks winnt.h PVOID64.
$env:INCLUDE = "$gdiInc;$($env:INCLUDE);$dxInc"
foreach ($p in @($src,$engineLib,$engineDll,$luaDll,(Join-Path $engineHeaders 'KPakList.h'))) {
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) {
        throw "Missing fresh source dependency: $p"
    }
}
$programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
$vswhere = Join-Path $programFilesX86 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $vswhere -PathType Leaf)) { throw 'MSVC vswhere.exe not found' }
$vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vs) { throw 'MSVC x86 C++ compiler is missing' }
$vcvarsall = Join-Path $vs 'VC\Auxiliary\Build\vcvarsall.bat'
$env:PATH = (Split-Path -Parent $vswhere) + ';' + $env:PATH
$lines = & cmd.exe /c ('"' + $vcvarsall + '" x86 >nul && set')
foreach ($line in $lines) {
    $i = $line.IndexOf('=')
    if ($i -gt 0) { [Environment]::SetEnvironmentVariable($line.Substring(0,$i),$line.Substring($i+1),'Process') }
}
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) { throw 'MSVC cl.exe unavailable after vcvarsall' }
New-Item -ItemType Directory -Path $out -Force | Out-Null
$exe = Join-Path $out 'PakEntryExtract.exe'
$engineCopy = Join-Path $out 'Engine.dll'
$argv = @(
    '/nologo','/MD','/O2','/EHsc','/W3','/Zc:strictStrings-','/Zc:wchar_t-',
    '/DWIN32','/DNDEBUG','/D_CRT_SECURE_NO_WARNINGS','/D_CRT_NONSTDC_NO_DEPRECATE',
    '/D_USE_32BIT_TIME_T','/DHMONITOR_DECLARED',
    "/I$engineHeaders","/I$engineInc",
    "/Fe$exe",$src,$engineLib,
    '/link','/MACHINE:X86','/SUBSYSTEM:CONSOLE','/INCREMENTAL:NO',
    '/NODEFAULTLIB:libc.lib','/NODEFAULTLIB:libcd.lib',
    'legacy_stdio_definitions.lib','legacy_stdio_wide_specifiers.lib'
)
$oldPreference=$ErrorActionPreference
try {
    $ErrorActionPreference='Continue'
    $messages = @(& cl.exe @argv 2>&1 | ForEach-Object { "$_" })
    $status=$LASTEXITCODE
} finally { $ErrorActionPreference=$oldPreference }
$messages | ForEach-Object { Write-Host $_ }
if ($status -ne 0 -or -not (Test-Path -LiteralPath $exe -PathType Leaf)) {
    throw "MSVC PakEntryExtract build failed: exit=$status"
}
Copy-Item -LiteralPath $engineDll -Destination $engineCopy -Force
Copy-Item -LiteralPath $luaDll -Destination $luaCopy -Force
Write-Host '=== PAK EXE IMPORTS ==='
& dumpbin.exe /dependents $exe | ForEach-Object { Write-Host $_ }
Write-Host '=== ENGINE DLL IMPORTS ==='
& dumpbin.exe /dependents $engineCopy | ForEach-Object { Write-Host $_ }
[pscustomobject]@{
    Status='BUILT_NOT_RUNTIME_VERIFIED'
    Executable=$exe
    EngineDll=$engineCopy
    LuaLibDll=$luaCopy
    ExeSha256=(Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
    EngineSha256=(Get-FileHash -LiteralPath $engineCopy -Algorithm SHA256).Hash
    LuaSha256=(Get-FileHash -LiteralPath $luaCopy -Algorithm SHA256).Hash
}
