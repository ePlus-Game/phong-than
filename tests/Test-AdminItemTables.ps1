$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$helper = Join-Path $root 'AdminWeb\Initialize-ItemTables.ps1'
$admin = Join-Path $root 'AdminWeb\PhongThan-Admin.ps1'
foreach ($file in @($helper, $admin)) {
    $tokens = $null; $errors = $null
    [void][Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) { throw "PowerShell parse failed: $file : $($errors[0])" }
}
$source = Get-Content -LiteralPath $admin -Raw
if (-not $source.Contains('Initialize-ItemTables.ps1') -or
    -not $source.Contains('if (-not $script:PakItemCatalogVerified)')) {
    throw 'Admin must use helper and block unverified item codes'
}
$work = Join-Path $env:TEMP ('pt-admin-item-test-' + [guid]::NewGuid().ToString('N'))
$server = Join-Path $work 'Server'
$loose = Join-Path $server 'settings\item\001'
$cache = Join-Path $work 'cache'
$missing = Join-Path $work 'missing-PakEntryExtract.exe'
try {
    New-Item -ItemType Directory -Force -Path $loose | Out-Null
    $tables = @('meleeweapon','rangeweapon','armor','ring','amulet','boot','belt',
                'helm','cuff','pendant','horse','ibitem','magicscript','material','questkey')
    foreach ($table in $tables) {
        Set-Content -LiteralPath (Join-Path $loose "$table.txt") -Value "test-$table" -Encoding Ascii
    }
    $result = & $helper -ServerRoot $server -ItemDir $cache -PakTool $missing
    if ($result.PakVerified -or $result.Source -ne 'LOOSE_FALLBACK' -or $result.Tables -ne 15) {
        throw 'Missing extractor must use unverified loose fallback'
    }
    foreach ($table in $tables) {
        $file = Join-Path $cache "$table.txt"
        if (-not (Test-Path -LiteralPath $file) -or
            -not ((Get-Content -LiteralPath $file -Raw).Contains("test-$table"))) {
            throw "Missing fallback table: $table"
        }
    }
    Remove-Item -LiteralPath (Join-Path $loose 'armor.txt')
    $failed = $false
    try { & $helper -ServerRoot $server -ItemDir $cache -PakTool $missing | Out-Null }
    catch { $failed = $true }
    if (-not $failed) { throw 'Missing extractor and loose table must fail closed' }
    Write-Host 'PASS: Admin starts without extractor using loose tables; unsafe item codes are blocked'
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
