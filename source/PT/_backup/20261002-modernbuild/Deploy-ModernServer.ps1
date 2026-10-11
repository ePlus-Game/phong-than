# Deploy the VS2022 (MSVC v143) server build: GameServer.exe, CoreServer.dll, Engine.dll, LuaLibDll.dll, Bishop.exe.
# Copies them into Runtime\Server and Output\Server (launcher requires runtime == Output == receipt),
# updates NATIVE_DEPLOYMENT.json, and keeps a full backup for Rollback-ModernServer.ps1.
# Bishop.exe imports Engine.dll, so it is rebuilt and deployed together with the rest of the stack.
$ErrorActionPreference = 'Stop'
$root = 'E:\VL\Phong than\PT'
$src = "$root\PhongThanSource\OutputModern\Server"
$dsts = @("$root\PhongThanRuntime-Staging\Server", "$root\PhongThanSource\Output\Server")
$receipt = "$root\PhongThanRuntime-Staging\NATIVE_DEPLOYMENT.json"
$files = 'GameServer.exe', 'CoreServer.dll', 'Engine.dll', 'LuaLibDll.dll', 'Bishop.exe'
$running = @(Get-Process GameServer, Bishop -ErrorAction SilentlyContinue)
if ($running.Count) { throw ('Dang chay: ' + (($running | ForEach-Object { $_.Name }) -join ', ') + '. Tat toan bo server truoc.') }
foreach ($f in $files) { if (-not (Test-Path -LiteralPath "$src\$f")) { throw "Thieu $src\$f" } }

# The first backup (pure VC6) stays the rollback target; later runs only add files it does not have yet.
$latestFile = "$root\_backup\server-vc6-LATEST.txt"
$baseline = $null
if (Test-Path -LiteralPath $latestFile) { $baseline = (Get-Content -LiteralPath $latestFile -Raw).Trim() }
$bak = Join-Path $root ('_backup\server-deploy-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $bak | Out-Null
Copy-Item -LiteralPath $receipt -Destination $bak
if (-not $baseline) { $baseline = $bak }
foreach ($d in $dsts) {
    $tag = Split-Path (Split-Path $d -Parent) -Leaf
    New-Item -ItemType Directory -Force -Path "$bak\$tag", "$baseline\$tag" | Out-Null
    foreach ($f in $files) {
        $t = Join-Path $d $f
        if (Test-Path -LiteralPath $t) {
            Copy-Item -LiteralPath $t -Destination "$bak\$tag\$f"
            if (-not (Test-Path -LiteralPath "$baseline\$tag\$f")) { Copy-Item -LiteralPath $t -Destination "$baseline\$tag\$f" }
        }
    }
}
foreach ($d in $dsts) {
    foreach ($f in $files) {
        Copy-Item -LiteralPath "$src\$f" -Destination (Join-Path $d $f) -Force
        $pdb = [IO.Path]::ChangeExtension("$src\$f", '.pdb')
        if (Test-Path -LiteralPath $pdb) { Copy-Item -LiteralPath $pdb -Destination $d -Force }
    }
}
$r = Get-Content -LiteralPath $receipt -Raw | ConvertFrom-Json
foreach ($a in $r.Artifacts) {
    if ($a.Role -eq 'Server' -and ($files -contains $a.Name)) { $a.Sha256 = (Get-FileHash -LiteralPath (Join-Path $dsts[0] $a.Name)).Hash }
}
($r | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $receipt -Encoding UTF8
Set-Content -LiteralPath $latestFile -Value $baseline -Encoding ASCII
foreach ($f in $files) {
    $h = @($dsts | ForEach-Object { (Get-FileHash -LiteralPath (Join-Path $_ $f)).Hash } | Sort-Object -Unique)
    $rh = ($r.Artifacts | Where-Object { $_.Role -eq 'Server' -and $_.Name -eq $f }).Sha256
    Write-Host ('{0,-15} {1}' -f $f, $(if ($h.Count -eq 1 -and $h[0] -eq $rh) { 'khop' } else { 'LECH' }))
}
Write-Host "Da trien khai ban build moi. Backup lan nay: $bak ; ban VC6 goc: $baseline"
