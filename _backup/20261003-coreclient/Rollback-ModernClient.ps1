# Restore the VC6 client binaries saved by Deploy-ModernClient.ps1 (the original VC6 backup by default),
# The restored VC6 CoreClient/Represent2 are the already byte-patched copies, so
# PhongThan-ClientPatch.ps1 reports "Da va" for them again.
# By default only the Client artifact hashes in NATIVE_DEPLOYMENT.json are recomputed (PakChain and server
# entries changed since stay valid); -FullReceipt copies back the whole receipt saved in the backup.
param([string]$Backup, [switch]$FullReceipt)
$ErrorActionPreference = 'Stop'
$root = 'E:\VL\Phong than\PT'
if (-not $Backup) { $Backup = (Get-Content -LiteralPath "$root\_backup\client-vc6-LATEST.txt" -Raw).Trim() }
if (-not (Test-Path -LiteralPath $Backup)) { throw "Khong thay backup: $Backup" }
$running = @(Get-Process Game -ErrorAction SilentlyContinue)
if ($running.Count) { throw 'Game.exe dang chay. Thoat toan bo client truoc.' }
$receipt = "$root\PhongThanRuntime-Staging\NATIVE_DEPLOYMENT.json"
$map = @{ 'PhongThanRuntime-Staging' = "$root\PhongThanRuntime-Staging\Client"; 'Output' = "$root\PhongThanSource\Output\Client" }
foreach ($tag in $map.Keys) {
    $dir = Join-Path $Backup $tag
    if (Test-Path -LiteralPath $dir) { Get-ChildItem -LiteralPath $dir -File | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $map[$tag] $_.Name) -Force } }
}
if (-not $FullReceipt) {
    # Only rewrite the Client artifact hashes from the restored runtime files.
    $r = Get-Content -LiteralPath $receipt -Raw | ConvertFrom-Json
    foreach ($a in $r.Artifacts) {
        $f = Join-Path $map['PhongThanRuntime-Staging'] $a.Name
        if ($a.Role -eq 'Client' -and (Test-Path -LiteralPath $f)) { $a.Sha256 = (Get-FileHash -LiteralPath $f).Hash }
    }
    ($r | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $receipt -Encoding UTF8
} else {
    Copy-Item -LiteralPath (Join-Path $Backup 'NATIVE_DEPLOYMENT.json') -Destination $receipt -Force
}
Write-Host "Da khoi phuc client VC6 tu $Backup"

