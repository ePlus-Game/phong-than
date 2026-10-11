# Restore the VC6 server binaries saved by Deploy-ModernServer.ps1 (the original VC6 backup by default).
param([string]$Backup)
$ErrorActionPreference = 'Stop'
$root = 'E:\VL\Phong than\PT'
if (-not $Backup) { $Backup = (Get-Content -LiteralPath "$root\_backup\server-vc6-LATEST.txt" -Raw).Trim() }
$running = @(Get-Process GameServer, Bishop -ErrorAction SilentlyContinue)
if ($running.Count) { throw ('Dang chay: ' + (($running | ForEach-Object { $_.Name }) -join ', ') + '. Tat toan bo server truoc.') }
$map = @{ 'PhongThanRuntime-Staging' = "$root\PhongThanRuntime-Staging\Server"; 'Output' = "$root\PhongThanSource\Output\Server" }
foreach ($tag in $map.Keys) {
    $dir = Join-Path $Backup $tag
    if (Test-Path -LiteralPath $dir) { Get-ChildItem -LiteralPath $dir -File | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $map[$tag] $_.Name) -Force } }
}
Copy-Item -LiteralPath (Join-Path $Backup 'NATIVE_DEPLOYMENT.json') -Destination "$root\PhongThanRuntime-Staging\NATIVE_DEPLOYMENT.json" -Force
Write-Host "Da khoi phuc ban VC6 tu $Backup"
