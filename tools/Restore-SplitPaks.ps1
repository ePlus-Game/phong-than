# Restore split PAK archives using built-in Windows PowerShell 5.1 (no Python).
# Source of truth: archive/PT_EXACT_ZIP_MANIFEST.csv.
[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$VerifyExisting
)
$ErrorActionPreference = 'Stop'
$RepoRoot = [IO.Path]::GetFullPath($RepoRoot)
$manifest = Join-Path $RepoRoot 'archive\PT_EXACT_ZIP_MANIFEST.csv'
if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
    throw "Missing PAK manifest: $manifest"
}

$rows = @(Import-Csv -LiteralPath $manifest -Encoding UTF8 |
    Where-Object { $_.storage -eq 'split-git-parts' })
if ($rows.Count -eq 0) { throw "No split-git-parts entries in $manifest" }

$restored = 0
$skipped = 0
foreach ($row in $rows) {
    $oldPath = [string]$row.git_or_archive_path
    if (-not $oldPath.StartsWith('source/PT/', [StringComparison]::Ordinal)) {
        throw "Unexpected manifest path: $oldPath"
    }
    $relative = $oldPath.Substring('source/PT/'.Length)
    $segments = @($relative.Split('/'))
    if ($segments.Count -eq 0 -or @($segments | Where-Object {
        $_ -eq '' -or $_ -eq '.' -or $_ -eq '..' -or $_.Contains(':') -or $_.Contains('\')
    }).Count -gt 0) {
        throw "Unsafe manifest path: $oldPath"
    }
    if ($segments[0] -eq 'docs') {
        $relative = 'docs/original-pt/' + $relative.Substring('docs/'.Length)
    }
    $target = Join-Path $RepoRoot ($relative.Replace('/', '\'))
    $expectedSize = [long]::Parse([string]$row.uncompressed_bytes,
        [Globalization.CultureInfo]::InvariantCulture)
    $expectedHash = ([string]$row.sha256).ToLowerInvariant()
    if ($expectedSize -le 0 -or $expectedHash -notmatch '^[0-9a-f]{64}$') {
        throw "Invalid PAK manifest metadata: $oldPath"
    }

    if (Test-Path -LiteralPath $target -PathType Leaf) {
        if ((Get-Item -LiteralPath $target).Length -ne $expectedSize) {
            throw "Existing PAK size mismatch; refusing overwrite: $target"
        }
        if ($VerifyExisting) {
            $actualHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($actualHash -ne $expectedHash) {
                throw "Existing PAK checksum mismatch; refusing overwrite: $target"
            }
        }
        $skipped++
        continue
    }

    $partsDir = "$target.parts"
    if (-not (Test-Path -LiteralPath $partsDir -PathType Container)) {
        throw "Missing PAK and split parts: $target (expected $partsDir)"
    }
    $parts = @(Get-ChildItem -LiteralPath $partsDir -Filter 'part-*.bin' -File | Sort-Object Name)
    if ($parts.Count -eq 0) { throw "No PAK chunks in $partsDir" }
    $index = 0
    foreach ($part in $parts) {
        if ($part.Name -cne ('part-{0:D4}.bin' -f $index) -or
            ($part.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Missing, out-of-order or linked PAK chunk: $partsDir (index $index)"
        }
        $index++
    }

    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $temp = "$target.restore-$([guid]::NewGuid().ToString('N')).tmp"
    $digest = [Security.Cryptography.SHA256]::Create()
    $total = [long]0
    try {
        $dest = [IO.File]::Open($temp, [IO.FileMode]::CreateNew,
            [IO.FileAccess]::Write, [IO.FileShare]::None)
        try {
            $buffer = New-Object byte[] (1024 * 1024)
            foreach ($part in $parts) {
                $source = [IO.File]::OpenRead($part.FullName)
                try {
                    while (($n = $source.Read($buffer, 0, $buffer.Length)) -gt 0) {
                        $dest.Write($buffer, 0, $n)
                        [void]$digest.TransformBlock($buffer, 0, $n, $buffer, 0)
                        $total += $n
                    }
                } finally { $source.Dispose() }
            }
        } finally { $dest.Dispose() }
        [void]$digest.TransformFinalBlock([byte[]]@(), 0, 0)
        $actualHash = [BitConverter]::ToString($digest.Hash).Replace('-', '').ToLowerInvariant()
        if ($total -ne $expectedSize -or $actualHash -ne $expectedHash) {
            throw "Restored PAK checksum/size mismatch: $target"
        }
        [IO.File]::Move($temp, $target)
        $restored++
        Write-Host "RESTORED: $relative"
    } finally {
        $digest.Dispose()
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
}
Write-Host "PAK restore complete: restored=$restored, already-present=$skipped"
