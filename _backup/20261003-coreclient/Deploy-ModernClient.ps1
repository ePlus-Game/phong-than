# Deploy the VS2022 (MSVC v143) client stack: Game.exe, CoreClient.dll, Engine.dll, LuaLibDll.dll, Represent2.dll.
# These five modules call each other through C++ classes and new/delete, so they must all come from the same
# toolchain (one CRT: ucrtbase/vcruntime140). Never mix them with the VC6 copies (msvcrt/msvcp60).
# Represent3.dll (only used with config.ini Represent=3), Heaven/Rainbow/ExpandPackage/FilterText stay VC6:
# they are loaded through plain C/COM-style interfaces (same as the modern server stack).
# Copies into Runtime\Client and Output\Client (launcher requires runtime == Output == receipt),
# updates NATIVE_DEPLOYMENT.json and keeps a full backup for Rollback-ModernClient.ps1.
# After this, AdminWeb\PhongThan-ClientPatch.ps1 skips every CoreClient/Represent2 byte patch
# ("Bo qua (khac phien ban)"): it checks the PE TimeStamp (0x6aaa74c1 / 0x6aa134b5) before any byte.
# Needs the Visual C++ 2015-2022 x86 redistributable (vcruntime140.dll / msvcp140.dll in SysWOW64).
param([switch]$WhatIf)
$ErrorActionPreference = 'Stop'
$root = 'E:\VL\Phong than\PT'
$src = "$root\PhongThanSource\OutputModern\Client"
$dsts = @("$root\PhongThanRuntime-Staging\Client", "$root\PhongThanSource\Output\Client")
$receipt = "$root\PhongThanRuntime-Staging\NATIVE_DEPLOYMENT.json"
$files = 'Game.exe', 'CoreClient.dll', 'Engine.dll', 'LuaLibDll.dll', 'Represent2.dll'

$running = @(Get-Process Game -ErrorAction SilentlyContinue)
if ($running.Count) { throw 'Game.exe dang chay. Thoat toan bo client truoc khi trien khai.' }
foreach ($f in $files) { if (-not (Test-Path -LiteralPath "$src\$f")) { throw "Thieu $src\$f (chay Build-Modern.ps1 -Targets CoreClient,Represent2,GameClient)" } }
foreach ($dll in 'vcruntime140.dll', 'msvcp140.dll') {
    if (-not (Test-Path -LiteralPath "$env:WINDIR\SysWOW64\$dll")) { throw "Thieu $dll x86 (cai Visual C++ 2015-2022 Redistributable x86)." }
}
# Every destination file must be writable (a running/locked client would leave a half-deployed stack).
foreach ($d in $dsts) {
    foreach ($f in $files) {
        $t = Join-Path $d $f
        if (Test-Path -LiteralPath $t) {
            try { $fs = [IO.File]::Open($t, 'Open', 'ReadWrite', 'None'); $fs.Close() } catch { throw "File dang bi khoa: $t" }
        }
    }
}
if ($WhatIf) { Write-Host 'Kiem tra truoc khi trien khai: OK (chua sao chep gi).'; return }

# The first backup (pure VC6, with the byte patches) stays the rollback target; later runs only add
# files it does not have yet.
$latestFile = "$root\_backup\client-vc6-LATEST.txt"
$baseline = $null
if (Test-Path -LiteralPath $latestFile) { $baseline = (Get-Content -LiteralPath $latestFile -Raw).Trim() }
$bak = Join-Path $root ('_backup\client-deploy-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $bak | Out-Null
Copy-Item -LiteralPath $receipt -Destination $bak
if (-not $baseline) { $baseline = $bak }
$extra = @('CoreClient.map', 'CoreClient.pdb', 'Represent2.map', 'Represent2.pdb', 'Game.pdb', 'Game.map', 'Engine.pdb', 'LuaLibDll.pdb')
foreach ($d in $dsts) {
    $tag = Split-Path (Split-Path $d -Parent) -Leaf
    New-Item -ItemType Directory -Force -Path "$bak\$tag", "$baseline\$tag" | Out-Null
    foreach ($f in $files + $extra) {
        $t = Join-Path $d $f
        if (Test-Path -LiteralPath $t) {
            $name = (Get-Item -LiteralPath $t).Name   # keep the on-disk spelling (Output has engine.dll)
            Copy-Item -LiteralPath $t -Destination "$bak\$tag\$name"
            if (-not (Test-Path -LiteralPath "$baseline\$tag\$name")) { Copy-Item -LiteralPath $t -Destination "$baseline\$tag\$name" }
        }
    }
}
if (-not (Test-Path -LiteralPath "$baseline\NATIVE_DEPLOYMENT.json")) { Copy-Item -LiteralPath $receipt -Destination $baseline }

foreach ($d in $dsts) {
    $isOutput = $d -like '*\PhongThanSource\Output\*'
    foreach ($f in $files) {
        Copy-Item -LiteralPath "$src\$f" -Destination (Join-Path $d $f) -Force
        $pdb = [IO.Path]::ChangeExtension("$src\$f", '.pdb')
        if (Test-Path -LiteralPath $pdb) { Copy-Item -LiteralPath $pdb -Destination $d -Force }
        # Output keeps the .map next to the binary (crash-offset lookups)
        $map = [IO.Path]::ChangeExtension("$src\$f", '.map')
        if ($isOutput -and (Test-Path -LiteralPath $map)) { Copy-Item -LiteralPath $map -Destination $d -Force }
    }
}
$r = Get-Content -LiteralPath $receipt -Raw | ConvertFrom-Json
foreach ($a in $r.Artifacts) {
    if ($a.Role -eq 'Client' -and ($files -contains $a.Name)) { $a.Sha256 = (Get-FileHash -LiteralPath (Join-Path $dsts[0] $a.Name)).Hash }
}
($r | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $receipt -Encoding UTF8
Set-Content -LiteralPath $latestFile -Value $baseline -Encoding ASCII
$bad = 0
foreach ($f in $files) {
    $h = @($dsts | ForEach-Object { (Get-FileHash -LiteralPath (Join-Path $_ $f)).Hash } | Sort-Object -Unique)
    $rh = ($r.Artifacts | Where-Object { $_.Role -eq 'Client' -and $_.Name -eq $f }).Sha256
    $ok = ($h.Count -eq 1 -and $h[0] -eq $rh -and $h[0] -eq (Get-FileHash -LiteralPath "$src\$f").Hash)
    if (-not $ok) { $bad++ }
    Write-Host ('{0,-15} {1}' -f $f, $(if ($ok) { 'khop' } else { 'LECH' }))
}
# The byte patcher must now skip CoreClient/Represent2 (different PE TimeStamp).
foreach ($p in @(@('CoreClient.dll', 0x6aaa74c1), @('Represent2.dll', 0x6aa134b5))) {
    $b = [IO.File]::ReadAllBytes((Join-Path $dsts[0] $p[0]))
    $ts = [BitConverter]::ToUInt32($b, [BitConverter]::ToInt32($b, 0x3c) + 8)
    Write-Host ('{0,-15} TimeStamp 0x{1:x8} -> va byte {2}' -f $p[0], $ts, $(if ($ts -ne [uint32]$p[1]) { 'se bi bo qua (dung)' } else { 'VAN AP DUNG (sai)' }))
}
Write-Host "Da trien khai client ban build moi. Backup lan nay: $bak ; ban VC6 goc: $baseline"
if ($bad) { exit 1 }
