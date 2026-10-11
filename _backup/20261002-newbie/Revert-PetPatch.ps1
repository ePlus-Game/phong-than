# Revert the 2026-10-02 pet-AI code cave in CoreServer.dll (runtime + Output), keeping every other patch.
# Restores: .text VirtualSize (0x1F8), cave bytes (0xA93E0, 27 bytes -> 00), jump site (0x1C8BB).
# Only writes when the current bytes are exactly the patched ones; backs the files up first.
$ErrorActionPreference = 'Stop'
$root = 'E:\VL\Phong than\PT'
$files = @("$root\PhongThanRuntime-Staging\Server\CoreServer.dll", "$root\PhongThanSource\Output\Server\Coreserver.dll")
$edits = @(
    @{ Off = 0x1f8;   Cur = '00900a00'; Orig = 'de830a00' },
    @{ Off = 0xa93e0; Cur = '85db7f0b6a088bcee8b31af7ff8bd88b066a048d0c40e9c734f7ff'; Orig = ('00' * 27) },
    @{ Off = 0x1c8bb; Cur = 'e920cb08009090'; Orig = '8b066a048d0c40' }
)
function Hex([byte[]]$b, [int]$o, [int]$n) { -join ($b[$o..($o + $n - 1)] | ForEach-Object { $_.ToString('x2') }) }
if (@(Get-Process GameServer -ErrorAction SilentlyContinue).Count) { throw 'GameServer dang chay: tat server truoc.' }
$bak = Join-Path $root ('_backup\revert-pet-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $bak | Out-Null
foreach ($f in $files) {
    $b = [IO.File]::ReadAllBytes($f)
    $state = @($edits | ForEach-Object { $h = Hex $b $_.Off ($_.Cur.Length / 2); if ($h -eq $_.Cur) { 'patched' } elseif ($h -eq $_.Orig) { 'orig' } else { "unknown:$h" } })
    if ($state -match '^unknown') { throw "Byte khong khop o $f : $($state -join ', ')" }
    if (-not ($state -contains 'patched')) { Write-Host "Da o trang thai goc: $f"; continue }
    Copy-Item -LiteralPath $f -Destination (Join-Path $bak ((Split-Path (Split-Path $f -Parent) -Leaf) + '_CoreServer.dll'))
    foreach ($e in $edits) {
        for ($i = 0; $i -lt $e.Orig.Length / 2; $i++) { $b[$e.Off + $i] = [Convert]::ToByte($e.Orig.Substring($i * 2, 2), 16) }
    }
    [IO.File]::WriteAllBytes($f, $b)
    Write-Host "Da khoi phuc: $f"
}
$receipt = "$root\PhongThanRuntime-Staging\NATIVE_DEPLOYMENT.json"
if (Test-Path -LiteralPath $receipt) {
    Copy-Item -LiteralPath $receipt -Destination $bak
    $r = Get-Content -LiteralPath $receipt -Raw | ConvertFrom-Json
    $hash = (Get-FileHash -LiteralPath $files[0]).Hash
    foreach ($a in $r.Artifacts) { if ($a.Role -eq 'Server' -and $a.Name -eq 'CoreServer.dll') { $a.Sha256 = $hash } }
    ($r | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $receipt -Encoding UTF8
    Write-Host "Da cap nhat NATIVE_DEPLOYMENT.json ($hash)"
}
Write-Host "Backup: $bak"
