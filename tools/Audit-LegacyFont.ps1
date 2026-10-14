# Read-only inspection of legacy bitmap-font coverage and UI text encodings.
# No source, PAK, or player file is rewritten.
[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$ReportPath
)
$ErrorActionPreference = 'Stop'
$RepoRoot = [IO.Path]::GetFullPath($RepoRoot)
$FontRoot = Join-Path $RepoRoot 'PhongThanRuntime-Staging\Client\font'
$UiRoot = Join-Path $RepoRoot 'PhongThanRuntime-Staging\Client\Ui'
if (-not $ReportPath) { $ReportPath = Join-Path $env:TEMP 'phongthan-font-coverage.json' }

function Read-U32([byte[]]$Bytes,[int]$Offset) {
    return [BitConverter]::ToUInt32($Bytes,$Offset)
}
function Inspect-AsfFont([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing ASF font: $Path" }
    [byte[]]$bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 16 -or
        $bytes[0] -ne 65 -or $bytes[1] -ne 83 -or $bytes[2] -ne 70 -or $bytes[3] -ne 0) {
        throw "Invalid ASF signature: $Path"
    }
    [uint32]$dataSize = Read-U32 $bytes 4
    [uint32]$count = Read-U32 $bytes 8
    if ($count -ne 256 -or (16L + 4L*$count + $dataSize) -ne $bytes.Length) {
        throw "Invalid ASF size/count: $Path"
    }
    $loaded = New-Object 'bool[]' 256
    $missing = New-Object 'System.Collections.Generic.List[int]'
    $available = 0
    for ($i=0; $i -lt 256; ++$i) {
        [uint32]$offset = Read-U32 $bytes (16 + $i*4)
        if ($offset -ge $dataSize) { throw "Glyph offset out of range: $Path code=$i" }
        $loaded[$i] = ($offset -gt 0)
        if ($loaded[$i]) { ++$available }
        else { $missing.Add($i) }
    }
    return [pscustomobject]@{
        Name = [IO.Path]::GetFileName($Path)
        Width = [BitConverter]::ToUInt16($bytes,12)
        Height = [BitConverter]::ToUInt16($bytes,14)
        SlotCount = [int]$count
        GlyphCount = $available
        MissingCodes = @($missing.ToArray())
        LoadedMap = $loaded
    }
}

$fonts = @('14.fnt','16.fnt','18.fnt') | ForEach-Object {
    Inspect-AsfFont (Join-Path $FontRoot $_)
}
# A byte must exist in all three sizes before claiming every UI font can render it.
$covered = New-Object 'bool[]' 256
for ($i=0;$i -lt 256;$i++) {
    $covered[$i] = [bool]($fonts[0].LoadedMap[$i] -and $fonts[1].LoadedMap[$i] -and $fonts[2].LoadedMap[$i])
}
if (-not (Test-Path -LiteralPath $UiRoot -PathType Container)) { throw "Missing UI directory: $UiRoot" }
$findings = New-Object 'System.Collections.Generic.List[object]'
$filesScanned = 0
$valuesScanned = 0
$latin1 = [Text.Encoding]::GetEncoding(28591)
$strictUtf8 = New-Object System.Text.UTF8Encoding($false,$true)
foreach ($file in @(Get-ChildItem -LiteralPath $UiRoot -Recurse -File -Filter '*.ini')) {
    ++$filesScanned
    # Latin1 here is a byte-preserving transport, NOT a source-encoding guess.
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    $lines = $latin1.GetString($bytes) -split "\r?\n"
    for ($lineNo=0; $lineNo -lt $lines.Count; ++$lineNo) {
        $line = $lines[$lineNo]
        if ($line -match '^\s*[;#]') { continue }
        if ($line -notmatch '^\s*(Text|Caption|Title|Tooltip|ToolTip|Tip|Message|Label|Description|Desc|Prompt|Content|Hint)\s*=(.*)$') { continue }
        ++$valuesScanned
        $value = $Matches[2]
        if (-not $value) { continue }
        [byte[]]$raw = $latin1.GetBytes($value)
        $nonAscii = @($raw | Where-Object { $_ -ge 128 }).Count
        if (-not $nonAscii) { continue }
        $missingCodes = New-Object 'System.Collections.Generic.List[int]'
        foreach ($byte in $raw) {
            if ($byte -lt 32 -or $byte -eq 127 -or $byte -eq 32) { continue }
            if (-not $covered[$byte] -and -not $missingCodes.Contains([int]$byte)) {
                $missingCodes.Add([int]$byte)
            }
        }
        $utf8Possible = $false
        try { $null = $strictUtf8.GetString($raw); $utf8Possible = $true } catch {}
        if ($missingCodes.Count -eq 0 -and -not $utf8Possible) { continue }
        $relative = $file.FullName.Substring($RepoRoot.TrimEnd('\').Length + 1).Replace('\','/')
        $findings.Add([pscustomobject]@{
            File=$relative; Line=$lineNo+1
            Utf8Candidate=[bool]$utf8Possible
            MissingGlyphBytes=@($missingCodes.ToArray())
            # Hex preview avoids incorrectly rendering legacy bytes in the console.
            ValueHexPreview=([BitConverter]::ToString($raw,0,[Math]::Min(48,$raw.Length)))
        })
    }
}
$report=[pscustomobject]@{
    Status = 'AUDIT_ONLY_NOT_ENCODING_PROOF'
    Fonts = @($fonts | ForEach-Object {
        [pscustomobject]@{
            Name=$_.Name; Width=$_.Width; Height=$_.Height
            SlotCount=$_.SlotCount; GlyphCount=$_.GlyphCount
            MissingCodes=$_.MissingCodes
        }
    })
    FilesScanned = $filesScanned
    TextValuesScanned = $valuesScanned
    FindingsCount = $findings.Count
    Findings = @($findings.ToArray())
}
$parent = Split-Path -Parent $ReportPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
}
[IO.File]::WriteAllText($ReportPath,($report | ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
Write-Host "Font audit (READ ONLY): $($fonts.Count) bitmap fonts; $filesScanned UI files; $valuesScanned text fields; $($findings.Count) candidate issues."
Write-Host "Report: $ReportPath"
$report
