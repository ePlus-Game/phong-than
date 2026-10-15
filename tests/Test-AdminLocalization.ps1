# Read-only Windows PowerShell 5.1 locale regression; no game processes or SQL.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
$mod = Join-Path $RepoRoot 'AdminWeb\Ui-Localization.ps1'
$locale = Join-Path $RepoRoot 'AdminWeb\locales\vi-VN.json'
foreach($file in @($mod,(Join-Path $RepoRoot 'AdminWeb\PhongThan-Admin.ps1'))) {
    $tokens=$null;$errors=$null
    [void][Management.Automation.Language.Parser]::ParseFile($file,[ref]$tokens,[ref]$errors)
    if ($errors.Count -gt 0) { throw "PowerShell 5.1 syntax error in $file : $($errors[0].Message)" }
}
. $mod
Import-PtAdminLocale $locale
if ($script:PtLocaleLookup.Count -lt 50) { throw 'Vietnamese locale is unexpectedly incomplete' }
function Assert-Text([string]$Original, [string]$Expected) {
    $actual = ConvertTo-PtVietnamese $Original
    if ($actual -cne $Expected) {
        throw "Localized text does not match for: $Original"
    }
}
Assert-Text 'Khong tim thay tai khoan.' 'Không tìm thấy tài khoản.'
Assert-Text 'Khong tim thay vat pham MagicScript|5624' 'Không tìm thấy vật phẩm MagicScript|5624'
Assert-Text 'Cho server xu ly (toi da ~60 giay)' 'Chờ server xử lý (tối đa khoảng 60 giây).'
Assert-Text 'Da xep lenh c12: Tat het bot' 'Đã xếp lệnh c12: Tắt toàn bộ bot.'
Assert-Text 'role_61.pthc' 'role_61.pthc'
Assert-Text 'Bishop.exe' 'Bishop.exe'
Assert-Text 'Đạo Sĩ' 'Đạo Sĩ'
# Test a JSON-cloned API response with nested history and verification detail.
$source='{"ok":true,"message":"Khong tim thay tai khoan.","status":{"itemCatalogIssues":["Thieu PakEntryExtract.exe tai C:\\Game\\AdminWeb\\bin\\PakEntryExtract.exe. Chay AdminWeb\\Install-Pak-Extractor.cmd, sau do khoi dong lai Web Admin."]},"history":[{"desc":"Cho server xu ly (toi da ~60 giay)","detail":"Khong tim thay vat pham MagicScript|5624","status":"PENDING","name":"role_61.pthc"}]}'
$output=ConvertTo-PtLocalizedJson $source | ConvertFrom-Json
if ($output.message -cne 'Không tìm thấy tài khoản.') { throw 'API message was not localized' }
if ($output.history[0].desc -cne 'Chờ server xử lý (tối đa khoảng 60 giây).') { throw 'History desc not localized' }
if ($output.history[0].detail -cne 'Không tìm thấy vật phẩm MagicScript|5624') { throw 'History detail not localized' }
if ($output.history[0].status -cne 'PENDING' -or $output.history[0].name -cne 'role_61.pthc') {
    throw 'Protocol state or original identifiers were changed'
}
if (-not $output.status.itemCatalogIssues[0].StartsWith('Thiếu PakEntryExtract.exe')) {
    throw 'Nested item catalog error not localized'
}
$jsLocale = $script:PtLocaleJsonForPage | ConvertFrom-Json
if ($jsLocale.locale -ne 'vi-VN') { throw 'Browser locale injection lost UTF-8 text' }
$original=[IO.File]::ReadAllText($locale,(New-Object Text.UTF8Encoding($false,$true)))
if ($original.Contains('__PT_TOKEN__')) { throw 'Locale must not contain token placeholder' }
Write-Host 'PASS: real UTF-8 Vietnamese source, PS 5.1 parser, localized nested API and unchanged game identifiers.'
