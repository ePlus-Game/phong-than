[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ServerRoot,
    [Parameter(Mandatory=$true)][string]$ItemDir,
    [Parameter(Mandatory=$true)][string]$PakTool
)
$ErrorActionPreference = 'Stop'
# Resolve before Push-Location; otherwise relative arguments change meaning.
$ServerRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ServerRoot)
$ItemDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ItemDir)
$PakTool = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($PakTool)
$tables = @('meleeweapon','rangeweapon','armor','ring','amulet','boot','belt',
            'helm','cuff','pendant','horse','ibitem','magicscript','material','questkey')
$looseRoot = Join-Path $ServerRoot 'settings\item\001'
$package = Join-Path $ServerRoot 'package.ini'
$toolAvailable = Test-Path -LiteralPath $PakTool -PathType Leaf
$verified = $toolAvailable
$verifiedTables = 0
$source = if ($toolAvailable) { 'PAK' } else { 'LOOSE_FALLBACK' }
$issues = New-Object Collections.Generic.List[string]
New-Item -ItemType Directory -Force -Path $ItemDir | Out-Null

# Verify that every fallback exists before any attempt to populate the catalog.
if (-not $toolAvailable) {
    foreach ($t in $tables) {
        $loose = Join-Path $looseRoot "$t.txt"
        if (-not (Test-Path -LiteralPath $loose -PathType Leaf) -or
            (Get-Item -LiteralPath $loose).Length -eq 0) {
            throw "Thieu PakEntryExtract.exe VA bang du phong: $loose. Can build bang PhongThanSource\Build\Build-PakEntryExtract.ps1 (yeu cau VC6 + Engine.lib)."
        }
    }
    $issues.Add("Thieu PakEntryExtract.exe tai $PakTool. Chay AdminWeb\Install-Pak-Extractor.cmd, sau do khoi dong lai Web Admin.")
    Write-Warning $issues[0]
}
$enc = [Text.Encoding]::GetEncoding(1252)
$pathFile = Join-Path $ItemDir '_path.txt'
foreach ($t in $tables) {
    $destination = Join-Path $ItemDir "$t.txt"
    $extracted = $false
    $tmp = Join-Path $ItemDir ("$t." + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        if ($toolAvailable) {
            $virtualPath = "\settings\item\001\$t.txt"
            [IO.File]::WriteAllBytes($pathFile, $enc.GetBytes($virtualPath))
            Push-Location $ServerRoot
            try {
                $nativeOutput = @(& $PakTool $package "@$pathFile" $tmp 2>&1 | ForEach-Object { "$_" })
                $exit = $LASTEXITCODE
                if ($exit -ne 0) { $issues.Add("$t.txt : exit=$exit; $((@($nativeOutput) | Select-Object -Last 2) -join ' | ')") }
            } catch {
                $exit = -1
                $issues.Add("$t.txt : $($_.Exception.Message)")
            } finally {
                Pop-Location
            }
            if ($exit -eq 0 -and (Test-Path -LiteralPath $tmp -PathType Leaf) -and
                (Get-Item -LiteralPath $tmp).Length -gt 0) {
                # The native reader emits these only after a complete PAK-only
                # read and output write. Exit 0/nonempty output alone is insufficient.
                $entry = @($nativeOutput | Where-Object { $_ -eq "PAK_ENTRY=$virtualPath" })
                $index = @($nativeOutput | Where-Object { $_ -match '^PAK_INDEX=\d+$' })
                $size = @($nativeOutput | Where-Object { $_ -eq ('BYTES=' + (Get-Item -LiteralPath $tmp).Length) })
                if ($entry.Count -eq 1 -and $index.Count -eq 1 -and $size.Count -eq 1) {
                    Move-Item -LiteralPath $tmp -Destination $destination -Force
                    $extracted = $true
                    $verifiedTables++
                } else {
                    $issues.Add("$t.txt : missing or inconsistent PAK_ENTRY/PAK_INDEX/BYTES receipt from reader.")
                }
            }
        }
        if (-not $extracted) {
            $loose = Join-Path $looseRoot "$t.txt"
            if (-not (Test-Path -LiteralPath $loose -PathType Leaf) -or
                (Get-Item -LiteralPath $loose).Length -eq 0) {
                throw "Khong trich duoc $t.txt tu PAK va khong co bang loose: $loose"
            }
            Copy-Item -LiteralPath $loose -Destination $destination -Force
            $verified = $false
            $source = 'LOOSE_FALLBACK'
            if ($toolAvailable) {
                if (-not @($issues | Where-Object { $_.StartsWith("$t.txt :") }).Count) { $issues.Add("$t.txt : extractor failed without diagnostic or empty output.") }
                Write-Warning "PAK extract $t.txt that bai; dung bang loose. Khoa phat vat pham de tranh sai item ID."
            }
        }
    } finally {
        if (Test-Path -LiteralPath $tmp -PathType Leaf) {
            Remove-Item -LiteralPath $tmp -Force
        }
    }
}
[pscustomobject]@{ Source=$source; PakVerified=[bool]($verified -and $verifiedTables -eq $tables.Count); Tables=$tables.Count; VerifiedTables=$verifiedTables; ToolAvailable=[bool]$toolAvailable; Issues=@($issues.ToArray()) }
