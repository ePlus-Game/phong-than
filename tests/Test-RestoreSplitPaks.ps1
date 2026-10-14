# Self-contained tests: no game binaries, network, SQL, or Python required.
$ErrorActionPreference = 'Stop'
$restore = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools\Restore-SplitPaks.ps1'
$root = Join-Path $env:TEMP ('pt-pak-restore-test-' + [guid]::NewGuid().ToString('N'))
try {
    $archive = Join-Path $root 'archive'
    $partsDir = Join-Path $root 'PhongThanRuntime-Staging\Client\data\vng00.pak.parts'
    New-Item -ItemType Directory -Path $archive, $partsDir -Force | Out-Null
    $bytes = [Text.Encoding]::ASCII.GetBytes('PhongThan-synthetic-PAK-fixture')
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $expectedHash = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '').ToLowerInvariant()
    } finally { $sha.Dispose() }
    @([pscustomobject]@{
        storage = 'split-git-parts'
        git_or_archive_path = 'source/PT/PhongThanRuntime-Staging/Client/data/vng00.pak'
        uncompressed_bytes = $bytes.Length
        sha256 = $expectedHash
    }) | ConvertTo-Csv -NoTypeInformation |
        Set-Content -LiteralPath (Join-Path $archive 'PT_EXACT_ZIP_MANIFEST.csv') -Encoding UTF8

    $a = New-Object byte[] 10
    $b = New-Object byte[] ($bytes.Length - 10)
    [Array]::Copy($bytes, 0, $a, 0, $a.Length)
    [Array]::Copy($bytes, 10, $b, 0, $b.Length)
    [IO.File]::WriteAllBytes((Join-Path $partsDir 'part-0000.bin'), $a)
    [IO.File]::WriteAllBytes((Join-Path $partsDir 'part-0001.bin'), $b)

    & $restore -RepoRoot $root | Out-Null
    $pak = Join-Path $root 'PhongThanRuntime-Staging\Client\data\vng00.pak'
    if ((Get-FileHash -LiteralPath $pak -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedHash) {
        throw 'Restore produced incorrect content'
    }
    & $restore -RepoRoot $root -VerifyExisting | Out-Null

    Remove-Item -LiteralPath $pak -Force
    [IO.File]::WriteAllBytes((Join-Path $partsDir 'part-0001.bin'),
        [Text.Encoding]::ASCII.GetBytes('bad'))
    $failed = $false
    try { & $restore -RepoRoot $root | Out-Null } catch { $failed = $true }
    if (-not $failed -or (Test-Path -LiteralPath $pak)) {
        throw 'Corrupt PAK chunks were not rejected'
    }
    Write-Host 'PASS: restore, idempotency, and corrupt-chunk rejection'
} finally {
    if (Test-Path -LiteralPath $root) {
        Remove-Item -LiteralPath $root -Recurse -Force
    }
}
