# Windows PowerShell 5.1 locale regression. Keep this script ASCII-only.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
$mod = Join-Path $RepoRoot 'AdminWeb\Ui-Localization.ps1'
$locale = Join-Path $RepoRoot 'AdminWeb\locales\vi-VN.json'
foreach($file in @($mod,(Join-Path $RepoRoot 'AdminWeb\PhongThan-Admin.ps1'))) {
    $tokens=$null;$errors=$null
    [void][Management.Automation.Language.Parser]::ParseFile($file,[ref]$tokens,[ref]$errors)
    if ($errors.Count -gt 0) { throw "PowerShell 5.1 syntax error: $file" }
}
. $mod
Import-PtAdminLocale $locale
if ($script:PtLocaleLookup.Count -lt 50) { throw 'Vietnamese catalog is incomplete' }
$accountKey='Khong tim thay tai khoan.'
$accountText=ConvertTo-PtVietnamese $accountKey
if ($accountText -cne $script:PtLocaleLookup[$accountKey] -or $accountText -notmatch '[^\x00-\x7F]') {
    throw 'UTF-8 accented account response failed'
}
$missingItem=ConvertTo-PtVietnamese 'Khong tim thay vat pham MagicScript|5624'
if ($missingItem -match '^Khong tim' -or -not $missingItem.EndsWith('MagicScript|5624') -or
    $missingItem -notmatch '[^\x00-\x7F]') { throw 'Parameterized accented response failed' }
$descKey='Cho server xu ly (toi da ~60 giay)'
if ((ConvertTo-PtVietnamese $descKey) -cne $script:PtLocaleLookup[$descKey]) {
    throw 'Queue history message is not accented'
}
if ((ConvertTo-PtVietnamese 'Da xep lenh c12: Tat het bot') -match 'Tat het bot') {
    throw 'Nested parameter translation failed'
}
foreach($item in @('role_61.pthc','Bishop.exe','MagicScript|5624')) {
    if ((ConvertTo-PtVietnamese $item) -cne $item) { throw "Game identifier was changed: $item" }
}
$source='{"ok":true,"message":"Khong tim thay tai khoan.","status":{"itemCatalogIssues":["Thieu PakEntryExtract.exe tai C:\\Game\\AdminWeb\\bin\\PakEntryExtract.exe. Chay AdminWeb\\Install-Pak-Extractor.cmd, sau do khoi dong lai Web Admin."]},"history":[{"desc":"Cho server xu ly (toi da ~60 giay)","detail":"Khong tim thay vat pham MagicScript|5624","status":"PENDING","name":"role_61.pthc"}]}'
$output=ConvertTo-PtLocalizedJson $source | ConvertFrom-Json
if ($output.message -cne $accountText) { throw 'Server API message was not localized' }
if ($output.history[0].desc -cne $script:PtLocaleLookup[$descKey]) {
    throw 'Server history description was not localized'
}
if ($output.history[0].detail -cne $missingItem) {
    throw 'Server history detail was not localized'
}
if ($output.history[0].status -cne 'PENDING' -or $output.history[0].name -cne 'role_61.pthc') {
    throw 'API status or game identifiers were changed'
}
$issue=$output.status.itemCatalogIssues[0]
if ($issue -notmatch '[^\x00-\x7F]' -or -not $issue.Contains('AdminWeb\Install-Pak-Extractor.cmd')) {
    throw 'Catalog diagnostic lost accents or a Windows file path'
}
$jsLocale = $script:PtLocaleJsonForPage | ConvertFrom-Json
if ($jsLocale.locale -ne 'vi-VN' -or $jsLocale.messages.$accountKey -cne $accountText) {
    throw 'Browser locale data lost UTF-8 text'
}
$raw=[IO.File]::ReadAllText($locale,(New-Object Text.UTF8Encoding($false,$true)))
if ($raw.Contains('__PT_TOKEN__')) { throw 'Unexpected token placeholder in localization file' }
Write-Host 'PASS: explicit UTF-8 locale, PowerShell 5.1 parsing and accented API without changing identifiers.'
