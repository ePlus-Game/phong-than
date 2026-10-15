# Web Admin display localization for Windows PowerShell 5.1.
# This source is ASCII-only. Real Vietnamese text is stored in UTF-8 JSON.
# No game TCVN3/PAK/Lua text is converted by these functions.

function Import-PtAdminLocale([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing Web Admin locale file: $Path"
    }
    $strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
    $raw = [IO.File]::ReadAllText($Path, $strictUtf8)
    $obj = $raw | ConvertFrom-Json
    if ($null -eq $obj -or $obj.locale -ne 'vi-VN' -or $null -eq $obj.messages -or $null -eq $obj.patterns) {
        throw "Invalid Web Admin locale schema: $Path"
    }
    $script:PtLocaleLookup = @{}
    foreach ($p in $obj.messages.PSObject.Properties) {
        if ($p.Value -isnot [string] -or -not $p.Name) {
            throw "Invalid Vietnamese message key: $($p.Name)"
        }
        $script:PtLocaleLookup[$p.Name] = [string]$p.Value
    }
    $script:PtLocalePatterns = @(
        foreach ($rule in $obj.patterns) {
            if ($rule.regex -isnot [string] -or $rule.template -isnot [string]) {
                throw 'Invalid pattern in Vietnamese locale file.'
            }
            [pscustomobject]@{
                Regex = New-Object System.Text.RegularExpressions.Regex($rule.regex)
                Template = [string]$rule.template
            }
        }
    )
    # JSON comes only from a tracked project file, not requests.
    # Escape HTML/script separators before inlining as JavaScript data.
    $script:PtLocaleJsonForPage = $raw.Replace('<', '\u003c').Replace('>', '\u003e').Replace('&', '\u0026')
    $script:PtLocaleJsonForPage = $script:PtLocaleJsonForPage.Replace([string][char]0x2028, '\u2028').Replace([string][char]0x2029, '\u2029')
}

function ConvertTo-PtVietnamese([string]$Value, [int]$Depth = 0) {
    if ([string]::IsNullOrEmpty($Value)) { return $Value }
    if ($script:PtLocaleLookup.ContainsKey($Value)) { return [string]$script:PtLocaleLookup[$Value] }
    if ($Depth -gt 2) { return $Value }
    foreach ($rule in $script:PtLocalePatterns) {
        $m = $rule.Regex.Match($Value)
        if (-not $m.Success) { continue }
        $out = [string]$rule.Template
        for ($i = 1; $i -lt $m.Groups.Count; $i++) {
            $part = $m.Groups[$i].Value
            if ($Depth -lt 2) { $part = ConvertTo-PtVietnamese $part ($Depth + 1) }
            $out = $out.Replace(('{' + ($i - 1) + '}'), $part)
        }
        return $out
    }
    return $Value
}

function ConvertTo-PtApiResponseText($Object) {
    # Only a small, explicit set of presentation fields can be translated.
    # This function operates on a temporary JSON clone, never on live game data.
    if ($null -eq $Object) { return }
    if ($Object -is [array]) {
        foreach ($member in $Object) { ConvertTo-PtApiResponseText $member }
        return
    }
    if ($Object -is [pscustomobject]) {
        foreach ($p in $Object.PSObject.Properties) {
            if ($p.Name -in @('error', 'message', 'desc', 'detail', 'text')) {
                if ($p.Value -is [string]) { $p.Value = ConvertTo-PtVietnamese $p.Value }
            } elseif ($p.Name -eq 'itemCatalogIssues' -and $p.Value -is [array]) {
                for ($i = 0; $i -lt $p.Value.Count; $i++) {
                    if ($p.Value[$i] -is [string]) { $p.Value[$i] = ConvertTo-PtVietnamese $p.Value[$i] }
                }
            } elseif ($p.Value -is [array] -or $p.Value -is [pscustomobject]) {
                ConvertTo-PtApiResponseText $p.Value
            }
        }
    }
}

function ConvertTo-PtLocalizedJson([string]$Json) {
    if ([string]::IsNullOrEmpty($Json)) { return $Json }
    $payload = ConvertFrom-Json -InputObject $Json
    ConvertTo-PtApiResponseText $payload
    return (ConvertTo-Json -InputObject $payload -Depth 8 -Compress)
}
