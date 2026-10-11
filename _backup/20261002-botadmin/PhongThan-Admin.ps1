# Phong Than local admin web (PowerShell 5.1, built-in only).
# Serves http://localhost:<Port>/ for this machine only. Game actions are queued
# as Lua calls into Server\admin_bridge\pending.lua; script\servertimer.lua runs
# the queue once per minute (see its header). Accounts use the LocalDB directly.
[CmdletBinding()]
param([int]$Port = 8765, [switch]$NoBrowser)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Runtime = Join-Path $Root 'PhongThanRuntime-Staging'
$ServerRoot = Join-Path $Runtime 'Server'
$Bridge = Join-Path $ServerRoot 'admin_bridge'
$DataDir = Join-Path $PSScriptRoot 'data'
# GameServer reads package files before loose files (KCore.cpp g_SetPakFileMode(1)),
# so item codes must come from the PAK copies of the tables, extracted at startup.
$ItemDir = Join-Path $DataDir 'pak_item_tables'
$Enc1252 = [Text.Encoding]::GetEncoding(1252)
$EncGbk = [Text.Encoding]::GetEncoding(936)
$Utf8 = New-Object Text.UTF8Encoding($false)
$Token = [guid]::NewGuid().ToString('N')
New-Item -ItemType Directory -Force $Bridge, $DataDir | Out-Null

# ---------------------------------------------------------------- TCVN3 text
$tcvnFrom = @(0xB5,0xB8,0xB6,0xB7,0xB9,0xA8,0xBB,0xBE,0xBC,0xBD,0xC6,0xA9,0xC7,0xCA,0xC8,0xC9,0xCB,0xAE,0xCC,0xD0,0xCE,0xCF,0xD1,0xAA,0xD2,0xD5,0xD3,0xD4,0xD6,0xD7,0xDD,0xD8,0xDC,0xDE,0xDF,0xE3,0xE1,0xE2,0xE4,0xAB,0xE5,0xE8,0xE6,0xE7,0xE9,0xAC,0xEA,0xED,0xEB,0xEC,0xEE,0xEF,0xF3,0xF1,0xF2,0xF4,0xAD,0xF5,0xF8,0xF6,0xF7,0xF9,0xFA,0xFD,0xFB,0xFC,0xFE,0xA1,0xA2,0xA7,0xA3,0xA4,0xA5,0xA6)
$tcvnTo = @(0xE0,0xE1,0x1EA3,0xE3,0x1EA1,0x103,0x1EB1,0x1EAF,0x1EB3,0x1EB5,0x1EB7,0xE2,0x1EA7,0x1EA5,0x1EA9,0x1EAB,0x1EAD,0x111,0xE8,0xE9,0x1EBB,0x1EBD,0x1EB9,0xEA,0x1EC1,0x1EBF,0x1EC3,0x1EC5,0x1EC7,0xEC,0xED,0x1EC9,0x129,0x1ECB,0xF2,0xF3,0x1ECF,0xF5,0x1ECD,0xF4,0x1ED3,0x1ED1,0x1ED5,0x1ED7,0x1ED9,0x1A1,0x1EDD,0x1EDB,0x1EDF,0x1EE1,0x1EE3,0xF9,0xFA,0x1EE7,0x169,0x1EE5,0x1B0,0x1EEB,0x1EE9,0x1EED,0x1EEF,0x1EF1,0x1EF3,0xFD,0x1EF7,0x1EF9,0x1EF5,0x102,0xC2,0x110,0xCA,0xD4,0x1A0,0x1AF)
$TcvnToUni = @{}; $UniToTcvn = @{}
for ($i = 0; $i -lt $tcvnFrom.Count; $i++) { $TcvnToUni[[int]$tcvnFrom[$i]] = [char]$tcvnTo[$i]; $UniToTcvn[[int]$tcvnTo[$i]] = [byte]$tcvnFrom[$i] }

function ConvertFrom-Tcvn([byte[]]$Bytes) {
    $sb = New-Object Text.StringBuilder
    foreach ($b in $Bytes) { if ($TcvnToUni.ContainsKey([int]$b)) { [void]$sb.Append($TcvnToUni[[int]$b]) } else { [void]$sb.Append([char]$b) } }
    $sb.ToString()
}
function ConvertTo-Tcvn([string]$Text) {
    $out = New-Object Collections.Generic.List[byte]
    foreach ($ch in $Text.ToCharArray()) {
        $c = [int]$ch
        if ($c -lt 128) { $out.Add([byte]$c); continue }
        if ($UniToTcvn.ContainsKey($c)) { $out.Add($UniToTcvn[$c]); continue }
        $lower = [int][char]::ToLowerInvariant($ch)
        if ($UniToTcvn.ContainsKey($lower)) { $out.Add($UniToTcvn[$lower]); continue }
        $base = ([string]$ch).Normalize([Text.NormalizationForm]::FormD)[0]
        if ([int]$base -lt 128) { $out.Add([byte][int]$base) } else { $out.Add([byte][int][char]'?') }
    }
    , $out.ToArray()
}
# Lua 4 string literal of TCVN3 bytes; only printable ASCII is emitted raw.
function ConvertTo-LuaString([string]$Text) {
    $sb = New-Object Text.StringBuilder('"')
    foreach ($b in (ConvertTo-Tcvn $Text)) {
        if ($b -ge 32 -and $b -le 126 -and $b -ne 34 -and $b -ne 92) { [void]$sb.Append([char]$b) } else { [void]$sb.Append('\' + ([int]$b).ToString('000')) }
    }
    [void]$sb.Append('"'); $sb.ToString()
}
function Get-Plain([string]$Text) {
    $d = $Text.ToLowerInvariant().Replace([string][char]0x111, 'd').Normalize([Text.NormalizationForm]::FormD)
    [regex]::Replace($d, '\p{Mn}', '')
}

# ---------------------------------------------------------------- catalogs
Write-Host 'Dang trich bang vat pham tu PAK...'
New-Item -ItemType Directory -Force $ItemDir | Out-Null
$pakTool = Join-Path $Root 'PhongThanSource\Output\Tools\PakEntryExtract.exe'
$pathFile = Join-Path $ItemDir '_path.txt'
Push-Location $ServerRoot
try {
    foreach ($t in 'meleeweapon', 'rangeweapon', 'armor', 'ring', 'amulet', 'boot', 'belt', 'helm', 'cuff', 'pendant', 'horse', 'ibitem', 'magicscript', 'material', 'questkey') {
        [IO.File]::WriteAllBytes($pathFile, $Enc1252.GetBytes("\settings\item\001\$t.txt"))
        & $pakTool (Join-Path $ServerRoot 'package.ini') "@$pathFile" (Join-Path $ItemDir "$t.txt") | Out-Null
        if (-not (Test-Path -LiteralPath (Join-Path $ItemDir "$t.txt"))) { Copy-Item -LiteralPath (Join-Path $ServerRoot "settings\item\001\$t.txt") (Join-Path $ItemDir "$t.txt") }
    }
} finally { Pop-Location }
Write-Host 'Dang nap danh muc vat pham...'
$Items = New-Object Collections.Generic.List[object]
$lookup = Join-Path $Root 'Tra-cuu-vat-pham.txt'
if (Test-Path -LiteralPath $lookup) {
    foreach ($line in [IO.File]::ReadAllLines($lookup, [Text.Encoding]::UTF8)) {
        $c = $line -split "`t"
        if ($c.Count -lt 6 -or $c[1] -notmatch '^\d+$') { continue }
        $Items.Add([pscustomobject]@{ key = "$($c[0])|$($c[1])"; group = $c[0]; code = [int]$c[1]; name = $c[3]; table = $c[4]; line = [int]$c[5]; plain = (Get-Plain $c[3]) })
    }
}
$ItemByKey = @{}; foreach ($it in $Items) { $ItemByKey[$it.key] = $it }

# Set gear (do luc): armor/helm/boot/belt/pendant rows with set id (col 69).
# Armor rows fix particular -> (profession, variant); boot/belt have no profession
# requirement and reuse the same particular numbering. Tier = armor level req (type 36).
$GearTables = [ordered]@{ armor = 'Giap'; helm = 'Mu'; boot = 'Giay'; belt = 'That lung'; pendant = 'Boi' }
$GearPieces = New-Object Collections.Generic.List[object]
$gearRows = @{}
foreach ($t in $GearTables.Keys) {
    $lines = [IO.File]::ReadAllLines((Join-Path $ItemDir "$t.txt"), $Enc1252)
    $rows = New-Object Collections.Generic.List[object]
    for ($r = 1; $r -lt $lines.Count; $r++) {
        $c = $lines[$r] -split "`t"
        if ($c.Count -lt 70 -or $c[69] -notmatch '^[1-9]\d*$') { continue }
        $prof = -1; $req = 0
        for ($k = 44; $k -le 54; $k += 2) {
            if ($c[$k] -eq '37' -and $c[$k + 1] -match '^\d+$') { $prof = [int]$c[$k + 1] }
            if ($c[$k] -eq '36' -and $c[$k + 1] -match '^\d+$') { $req = [int]$c[$k + 1] }
        }
        $rows.Add([pscustomobject]@{ set = [int]$c[69]; part = [int]("0$($c[3])" -replace '\D', ''); ilv = [int]("0$($c[11])" -replace '\D', ''); prof = $prof; req = $req; line = $r + 1; name = (ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])).TrimStart('#') })
    }
    $gearRows[$t] = $rows
}
$partMap = @{}; $setTier = @{}; $setName = @{}
foreach ($g in ($gearRows['armor'] | Group-Object set)) {
    foreach ($pg in ($g.Group | Where-Object { $_.prof -ge 0 } | Group-Object prof)) {
        $parts = @($pg.Group | ForEach-Object part | Sort-Object -Unique)
        for ($i = 0; $i -lt $parts.Count; $i++) { $partMap["$($g.Name)|$($parts[$i])"] = @([int]$pg.Name, ($i + 1)) }
    }
    $setTier[[int]$g.Name] = ($g.Group | Measure-Object req -Maximum).Maximum
}
foreach ($t in $GearTables.Keys) {
    foreach ($row in $gearRows[$t]) {
        $pm = $partMap["$($row.set)|$($row.part)"]
        if (-not $pm) { continue }
        if ($row.prof -ge 0 -and $row.prof -ne $pm[0]) { continue }
        $key = "$($GearTables[$t])|$($row.line - 1)"
        if (-not $ItemByKey.ContainsKey($key)) { continue }
        $GearPieces.Add([pscustomobject]@{ set = $row.set; tier = $setTier[$row.set]; prof = $pm[0]; variant = $pm[1]; piece = $GearTables[$t]; ilv = $row.ilv; req = $row.req; key = $key; name = $row.name })
        if ($t -eq 'armor' -and -not $setName["$($row.set)|$($pm[0])|$($pm[1])"]) { $setName["$($row.set)|$($pm[0])|$($pm[1])"] = $row.name }
    }
}

# Tier weapons (vu khi luc): melee/range rows with profession requirement (type 37)
# and a level requirement (type 36) >= 10; quest copies "(N.v)"/"nhiem vu" skipped.
$Weapons = New-Object Collections.Generic.List[object]
foreach ($wt in @(@('meleeweapon', 'Vu khi gan'), @('rangeweapon', 'Vu khi xa'))) {
    $lines = [IO.File]::ReadAllLines((Join-Path $ItemDir "$($wt[0]).txt"), $Enc1252)
    $seenW = @{}
    for ($r = 1; $r -lt $lines.Count; $r++) {
        $c = $lines[$r] -split "`t"
        if ($c.Count -lt 56) { continue }
        $prof = -1; $req = 0
        for ($k = 44; $k -le 54; $k += 2) {
            if ($c[$k] -eq '37' -and $c[$k + 1] -match '^\d+$') { $prof = [int]$c[$k + 1] }
            if ($c[$k] -eq '36' -and $c[$k + 1] -match '^\d+$') { $req = [int]$c[$k + 1] }
        }
        if ($prof -lt 0 -or $req -lt 10) { continue }
        $name = ((ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])).TrimStart('#') -replace '<[^>]*>', '').Trim()
        if ((Get-Plain $name) -match 'nhiem vu|\(n\.v\)') { continue }
        $key = "$($wt[1])|$r"
        if (-not $ItemByKey.ContainsKey($key)) { continue }
        $sig = "$name|$req|$($c[11])|$($c[9])"; if ($seenW[$sig]) { continue }; $seenW[$sig] = $true
        # Series column 1000 marks the green (luc) rows that carry magic slots 6..10.
        $Weapons.Add([pscustomobject]@{ key = $key; name = $name; prof = $prof; req = $req; ilv = [int]("0$($c[11])" -replace '\D', ''); green = ($c[9] -eq '1000'); kind = $(if ($wt[0] -eq 'rangeweapon') { 'Tam xa' } else { 'Can chien' }) })
    }
}

# Max presets: rows whose attributes are fixed (min = max) in the VNG tables, the
# only reliable "max option" the unmodified engine can produce. (+12) rows carry
# the upgrade stat bonus in the template but no upgrade stars (nUpgradeLvl = 0).
$GroupByTable = @{ meleeweapon = 'Vu khi gan'; amulet = 'Day chuyen'; horse = 'Thu cuoi'; pendant = 'Boi' }
$tableCache2 = @{}
function Find-PresetRow([string]$Table, [int]$Part, [int]$Level) {
    if (-not $tableCache2.ContainsKey($Table)) { $tableCache2[$Table] = [IO.File]::ReadAllLines((Join-Path $ItemDir "$Table.txt"), $Enc1252) }
    $lines = $tableCache2[$Table]
    for ($r = 1; $r -lt $lines.Count; $r++) {
        $c = $lines[$r] -split "`t"
        if ($c[3] -eq "$Part" -and $c[11] -eq "$Level") {
            $prof = -1; $req = 0
            for ($k = 44; $k -le 54; $k += 2) {
                if ($c[$k] -eq '37' -and $c[$k + 1] -match '^\d+$') { $prof = [int]$c[$k + 1] }
                if ($c[$k] -eq '36' -and $c[$k + 1] -match '^\d+$') { $req = [int]$c[$k + 1] }
            }
            $key = "$($GroupByTable[$Table])|$r"
            if (-not $ItemByKey.ContainsKey($key)) { return $null }
            return [pscustomobject]@{ key = $key; name = ((ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])).TrimStart('#') -replace '<[^>]*>', '').Trim(); prof = $prof; req = $req; part = $Part; level = $Level }
        }
    }
    $null
}
$Presets = New-Object Collections.Generic.List[object]
$presetDefs = @(
    @('Vu khi max - Tinh Quan Cap 10', 'meleeweapon', @(244, 245, 246, 247), 10),
    @('Vu khi Tinh Quan (+12) - chi so cuong hoa co san, khong co sao', 'meleeweapon', @(132, 133, 134, 135), 10),
    @('Thu cuoi max - Tinh Quan Cap 10', 'horse', @(60, 61, 62), 10),
    @('Thu cuoi max - Nghich (cap 10)', 'horse', @(24, 25, 26), 10),
    @('Thu cuoi - Bach Kim Nghich Thien', 'horse', @(27, 28, 29), 10),
    @('Thu cuoi - Phi Tuyet', 'horse', @(42, 43, 44), 10),
    @('Phap bao max cap 120 (o Ngoc boi)', 'amulet', @(89, 90, 91, 92, 143), 10),
    @('Phap bao That Bao Kim Lien (o Ngoc boi)', 'amulet', @(72, 73, 74), 10)
)
foreach ($pd in $presetDefs) {
    foreach ($pp in $pd[2]) {
        $row = Find-PresetRow $pd[1] $pp $pd[3]
        if ($row) { $Presets.Add([pscustomobject]@{ group = $pd[0]; key = $row.key; name = $row.name; prof = $row.prof; req = $row.req }) }
    }
}
# Phap bao list (amulet, worn in the JadePendant slot), one row per particular at level 10.
$Talismans = New-Object Collections.Generic.List[object]
$amuletLines = [IO.File]::ReadAllLines((Join-Path $ItemDir 'amulet.txt'), $Enc1252)
$seenA = @{}
for ($r = 1; $r -lt $amuletLines.Count; $r++) {
    $c = $amuletLines[$r] -split "`t"
    if ($c.Count -lt 56 -or $c[11] -ne '10') { continue }
    $key = "Day chuyen|$r"; if (-not $ItemByKey.ContainsKey($key)) { continue }
    $prof = -1; $req = 0
    for ($k = 44; $k -le 54; $k += 2) {
        if ($c[$k] -eq '37' -and $c[$k + 1] -match '^\d+$') { $prof = [int]$c[$k + 1] }
        if ($c[$k] -eq '36' -and $c[$k + 1] -match '^\d+$') { $req = [int]$c[$k + 1] }
    }
    $name = ((ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])).TrimStart('#') -replace '<[^>]*>', '').Trim()
    if ($seenA["$name|$prof"]) { continue }; $seenA["$name|$prof"] = $true
    $Talismans.Add([pscustomobject]@{ key = $key; name = $name; prof = $prof; req = $req; part = $c[3] })
}
# Phap khi (VNG instrument.txt 0/11) and An (signet.txt 0/13): the engine cannot load those
# tables, so ptfix.pak appends them to amulet.txt as phap bao (particular 200+ / 250+), worn in
# the Ngoc + 2 Talisman slots. Rows are not in Tra-cuu-vat-pham.txt: register them here.
$Instruments = New-Object Collections.Generic.List[object]
$Signets = New-Object Collections.Generic.List[object]
$seenIS = @{}
for ($r = 1; $r -lt $amuletLines.Count; $r++) {
    $c = $amuletLines[$r] -split "`t"
    if ($c.Count -lt 56 -or $c[3] -notmatch '^\d+$' -or [int]$c[3] -lt 200) { continue }
    $name = ((ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])).TrimStart('#') -replace '<[^>]*>', '').Trim()
    $ilv = [int]("0$($c[11])" -replace '\D', '')
    if ($seenIS["$($c[3])|$ilv"]) { continue }; $seenIS["$($c[3])|$ilv"] = $true
    $key = "Day chuyen|$r"
    if (-not $ItemByKey.ContainsKey($key)) {
        $it = [pscustomobject]@{ key = $key; group = 'Day chuyen'; code = $r; name = $name; table = 'amulet.txt'; line = $r + 1; plain = (Get-Plain $name) }
        $Items.Add($it); $ItemByKey[$key] = $it
    }
    $req = 0
    for ($k = 44; $k -le 54; $k += 2) { if ($c[$k] -eq '36' -and $c[$k + 1] -match '^\d+$') { $req = [int]$c[$k + 1] } }
    $o = [pscustomobject]@{ key = $key; name = $name; req = $req; ilv = $ilv; part = [int]$c[3] }
    if ([int]$c[3] -ge 250) { $Signets.Add($o) } else { $Instruments.Add($o) }
}

# Mounts: horse.txt requirement pairs (cols 44..55); type 37 = profession (0 Giap Si,
# 1 Dao Si, 2 Di Nhan), type 36 = character level. No type 37 = usable by everyone.
$Mounts = New-Object Collections.Generic.List[object]
$horseLines = [IO.File]::ReadAllLines((Join-Path $ItemDir 'horse.txt'), $Enc1252)
foreach ($it in $Items) {
    if ($it.group -ne 'Thu cuoi' -or $it.line -gt $horseLines.Count) { continue }
    $c = $horseLines[$it.line - 1] -split "`t"
    $prof = -1; $req = 0
    for ($k = 44; $k -le 54; $k += 2) {
        if ($c[$k] -eq '37' -and $c[$k + 1] -match '^\d+$') { $prof = [int]$c[$k + 1] }
        if ($c[$k] -eq '36' -and $c[$k + 1] -match '^\d+$') { $req = [int]$c[$k + 1] }
    }
    $Mounts.Add([pscustomobject]@{ key = $it.key; name = $it.name; prof = $prof; req = $req; plain = $it.plain })
}
$TableCache = @{}
function Get-ItemCode([string]$Key) {
    # Project starter bag (Sources\Core\Src\PhongThanStarterBag.h): reusable item picker.
    if ($Key -eq 'StarterBag') { return @{ g = 6; d = 61000; p = 0; lv = 1; se = 0; name = 'Tui tan thu' } }
    # World-boss token (ptfix.pak magicscript row 61001, script\phongthan\item\boss_lenhbai.lua).
    if ($Key -eq 'BossToken') { return @{ g = 6; d = 61001; p = 0; lv = 1; se = 0; name = 'Lenh Bai Boss The Gioi' } }
    # Remote sell token (ptfix.pak magicscript row 61002, script\phongthan\item\huydo_lenhbai.lua).
    if ($Key -eq 'SellToken') { return @{ g = 6; d = 61002; p = 0; lv = 1; se = 0; name = 'Lenh Bai Huy Do' } }
    # Di Nhan summon token (ptfix.pak magicscript row 61003, script\phongthan\item\trieuhoi_lenhbai.lua).
    if ($Key -eq 'SummonToken') { return @{ g = 6; d = 61003; p = 0; lv = 1; se = 0; name = 'Lenh Bai Trieu Hoi' } }
    # Rebirth skill books (ptfix.pak magicscript rows 61011..61019 = skill 1481..1489, sach_kn_<id>.lua).
    if ($Key -match '^SkillBook(\d{4})$') {
        $sid = [int]$Matches[1]
        if ($sid -lt 1481 -or $sid -gt 1489) { throw "Sach ky nang $sid khong ton tai" }
        return @{ g = 6; d = 61011 + $sid - 1481; p = 0; lv = 1; se = 0; name = "Sach Ky Nang $sid" }
    }
    $it = $ItemByKey[$Key]; if (-not $it) { throw "Khong tim thay vat pham $Key" }
    switch ($it.group) {
        'MagicScript' { return @{ g = 6; d = $it.code; p = 0; lv = 1; se = 0; name = $it.name } }
        'Nguyen lieu' { return @{ g = 3; d = $it.code; p = 0; lv = 1; se = 0; name = $it.name } }
        'Nhiem vu'    { return @{ g = 4; d = $it.code; p = 0; lv = 1; se = 0; name = $it.name } }
    }
    if (-not $TableCache.ContainsKey($it.table)) { $TableCache[$it.table] = [IO.File]::ReadAllLines((Join-Path $ItemDir $it.table), $Enc1252) }
    $row = $TableCache[$it.table][$it.line - 1] -split "`t"
    $num = { param($v, $def) if ("$v" -match '^-?\d+$') { [int]$v } else { $def } }
    if ($it.group -eq 'Ky tran cac') { return @{ g = (& $num $row[1] 8); d = (& $num $row[2] 0); p = (& $num $row[3] 0); lv = 1; se = 0; name = $it.name } }
    @{ g = (& $num $row[1] 0); d = (& $num $row[2] 0); p = (& $num $row[3] 0); lv = (& $num $row[11] 1); se = (& $num $row[9] 0); name = $it.name }
}

Write-Host 'Dang nap danh sach NPC va ban do...'
$Npcs = New-Object Collections.Generic.List[object]
$npcLines = [IO.File]::ReadAllLines((Join-Path $ServerRoot 'settings\phongthan\Npcs.txt'), $Enc1252)
for ($i = 1; $i -lt $npcLines.Count; $i++) {
    $c = $npcLines[$i] -split "`t", 3
    if (-not $c[0]) { continue }
    $raw = $Enc1252.GetBytes($c[0])
    $name = if (($raw | Where-Object { $_ -ge 128 }).Count) { $EncGbk.GetString($raw) } else { $c[0] }
    $name = $name -replace '<[^>]*>', ''
    $Npcs.Add([pscustomobject]@{ id = $i - 1; name = $name; kind = [int]("0$($c[1])" -replace '\D', ''); plain = (Get-Plain $name) })
}
# Profession skills (Sources\Core\Src\KPhongThanProfessionSkills.h):
# 0 Giap Si 27-42, 1 Dao Si 3-26, 2 Di Nhan 43-51. Skills.txt: 0 name, 2 id, 4 style, 49 max level.
$ProfRanges = @{ 0 = @(27, 42); 1 = @(3, 26); 2 = @(43, 51) }
$Skills = New-Object Collections.Generic.List[object]
$seenSkill = @{}
foreach ($line in [IO.File]::ReadAllLines((Join-Path $ServerRoot 'settings\Skills.txt'), $Enc1252)) {
    $c = $line -split "`t"
    if ($c.Count -lt 50 -or $c[2] -notmatch '^\d+$') { continue }
    $id = [int]$c[2]
    if ($seenSkill[$id]) { continue }
    foreach ($p in $ProfRanges.Keys) {
        if ($id -ge $ProfRanges[$p][0] -and $id -le $ProfRanges[$p][1]) {
            $seenSkill[$id] = $true
            $max = if ($c[49] -match '^\d+$') { [Math]::Min(10, [int]$c[49]) } else { 10 }
            $Skills.Add([pscustomobject]@{ id = $id; prof = $p; name = (ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])).TrimStart('#'); style = [int]("0$($c[4])" -replace '\D', ''); max = $max; tier = 0 })
        }
    }
}
# VNG rebirth skills Lv.60/120/180 (2026-10-01, level scripts + skills.txt rows in ptfix.pak v9).
# Outside the 3-51 profession ranges, so they are listed and allowed separately.
$RebirthSkills = @(
    @(1481, 0, 60, 3, 'Huy\u1ebft Chi\u1ebfn Sa Tr\u01b0\u1eddng'), @(1482, 0, 120, 3, 'D\u0129 Chi\u1ebfn D\u01b0\u1ee1ng Chi\u1ebfn'), @(1483, 0, 180, 3, 'B\u00e1ch Chi\u1ebfn D\u01b0 Sinh'),
    @(1484, 1, 60, 3, 'Nghi\u1ec7p H\u1ecfa Ph\u1ea7n T\u00e2m'), @(1485, 1, 120, 3, 'H\u1ea1o Nhi\u00ean Ch\u00ednh Kh\u00ed'), @(1486, 1, 180, 3, 'D\u1eabn H\u1ecfa Thi\u00eau Th\u00e2n'),
    @(1487, 2, 60, 3, '\u0110\u1ed9c H\u00e0nh Thi\u00ean H\u1ea1'), @(1488, 2, 120, 2, 'C\u1ed5 Ho\u1eb7c Ch\u00fang Sinh'), @(1489, 2, 180, 2, 'V\u1ea1n \u0110\u1ed9c H\u1ed9 Th\u00e2n'))
$RebirthByProf = @{ 0 = @(); 1 = @(); 2 = @() }
foreach ($r in $RebirthSkills) {
    $Skills.Add([pscustomobject]@{ id = $r[0]; prof = $r[1]; name = [regex]::Unescape($r[4]); style = $r[3]; max = 10; tier = $r[2] })
    $RebirthByProf[$r[1]] += $r[0]
}
# Di Nhan summon skills "Ky nang de tu (trieu hoi)" (2026-10-02, ptfix plug-in extra_petskill.py:
# skills.txt rows 450-461, SkillStyle 4). id, required level, name. Allowed for prof 2 via $RebirthByProf.
$PetSkills = @(
    @(450, 5, 'L\u1ef1c S\u0129 t\u1ebf'), @(451, 15, 'Tr\u01b0\u1eddng Cung t\u1ebf'), @(452, 25, 'Thi\u00ean V\u0169 t\u1ebf'), @(453, 35, 'Li\u00ean N\u1ed7 t\u1ebf'),
    @(454, 45, 'H\u1ecfa L\u00f4i t\u1ebf'), @(455, 55, 'To\u00e1i C\u1ed1t t\u1ebf'), @(456, 65, 'L\u01b0u Tinh t\u1ebf'), @(457, 75, 'Truy H\u1ed3n t\u1ebf'),
    @(458, 85, 'Phong Quy\u1ec3n T\u00e0n V\u00e2n'), @(459, 95, 'Cu\u1ed3ng \u0110\u00e0o t\u1ebf'), @(460, 105, 'Ng\u1ef1 S\u1eadu B\u1ea1o Phong'), @(461, 120, 'Huy\u1ec1n \u1ea2nh T\u00e1n Hoa'))
foreach ($r in $PetSkills) {
    $Skills.Add([pscustomobject]@{ id = $r[0]; prof = 2; name = [regex]::Unescape($r[2]); style = 4; max = 10; tier = 0; pet = 1; req = $r[1] })
    $RebirthByProf[2] += $r[0]
}
$Maps = New-Object Collections.Generic.List[object]
$mapNames = @{}
foreach ($line in [IO.File]::ReadAllLines((Join-Path $ServerRoot 'settings\MapList.ini'), $Enc1252)) {
    if ($line -match '^(\d+)_name=\$?(.*)$') { $mapNames[1000 + [int]$Matches[1]] = ConvertFrom-Tcvn ($Enc1252.GetBytes($Matches[2].Trim())) }
}
foreach ($line in [IO.File]::ReadAllLines((Join-Path $ServerRoot 'maps\WorldSet.ini'))) {
    if ($line -match '^World\d+=(\d+)') { $id = [int]$Matches[1]; $Maps.Add([pscustomobject]@{ id = $id; name = $(if ($mapNames[$id]) { $mapNames[$id] } else { "Ban do $id" }) }) }
}

# ---------------------------------------------------------------- state
$HistoryPath = Join-Path $DataDir 'history.json'
$EventsPath = Join-Path $DataDir 'events.json'
function Read-JsonList([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return , (New-Object Collections.ArrayList) }
    $list = New-Object Collections.ArrayList
    $data = [IO.File]::ReadAllText($Path, $Utf8) | ConvertFrom-Json
    foreach ($x in @($data)) { if ($x) { [void]$list.Add($x) } }
    , $list
}
function Save-Json([string]$Path, $Value) { [IO.File]::WriteAllText($Path, (ConvertTo-Json -InputObject ([object[]]$Value.ToArray()) -Depth 8), $Utf8) }
$History = Read-JsonList $HistoryPath
$Events = Read-JsonList $EventsPath
$script:ResultOffset = 0L
$script:Seq = 0

# ---------------------------------------------------------------- bridge
function Add-BridgeCommand([string]$Type, [string]$Description, [string]$LuaTemplate) {
    $script:Seq++
    $id = 'c' + (Get-Date -Format 'MMddHHmmss') + $script:Seq
    $lua = $LuaTemplate.Replace('{ID}', "`"$id`"") + "`n"
    $bytes = $Enc1252.GetBytes($lua)
    $pending = Join-Path $Bridge 'pending.lua'
    $tmp = Join-Path $Bridge ('write_' + $id + '.tmp')
    for ($try = 0; $try -lt 5; $try++) {
        try {
            if (Test-Path -LiteralPath $pending) {
                $old = [IO.File]::ReadAllBytes($pending)
                [IO.File]::WriteAllBytes($tmp, [byte[]]($old + $bytes))
                try { [IO.File]::Replace($tmp, $pending, [NullString]::Value); break }
                catch [IO.FileNotFoundException] { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
            }
            [IO.File]::WriteAllBytes($tmp, $bytes)
            [IO.File]::Move($tmp, $pending); break
        } catch { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 100; if ($try -eq 4) { throw } }
    }
    $entry = [pscustomobject]@{ id = $id; time = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); type = $Type; desc = $Description; status = 'PENDING'; detail = 'Cho server xu ly (toi da ~60 giay)' }
    [void]$History.Insert(0, $entry)
    while ($History.Count -gt 300) { $History.RemoveAt($History.Count - 1) }
    Save-Json $HistoryPath $History
    $entry
}
function Update-Results {
    $log = Join-Path $Bridge 'result.log'
    if (-not (Test-Path -LiteralPath $log)) { return }
    $fs = [IO.File]::Open($log, 'Open', 'Read', 'ReadWrite')
    try {
        if ($fs.Length -lt $script:ResultOffset) { $script:ResultOffset = 0 }
        [void]$fs.Seek($script:ResultOffset, 'Begin')
        $buf = New-Object byte[] ($fs.Length - $script:ResultOffset)
        $n = $fs.Read($buf, 0, $buf.Length); $script:ResultOffset += $n
    } finally { $fs.Dispose() }
    if (-not $n) { return }
    $changed = $false
    foreach ($line in ($Enc1252.GetString($buf, 0, $n) -split "`r?`n")) {
        $c = $line -split "`t"; if ($c.Count -lt 3) { continue }
        foreach ($h in $History) { if ($h.id -eq $c[1]) { $h.status = $c[2]; $h.detail = "$($c[0]) $($c[3])"; $changed = $true } }
    }
    if ($changed) { Save-Json $HistoryPath $History }
}
function Get-Online {
    $path = Join-Path $Bridge 'online.txt'
    $list = @(); $stamp = $null
    if (Test-Path -LiteralPath $path) {
        $lines = [IO.File]::ReadAllLines($path, $Enc1252)
        if ($lines.Count) { $stamp = $lines[0] }
        foreach ($l in ($lines | Select-Object -Skip 1)) {
            $c = $l -split "`t"; if ($c.Count -lt 6) { continue }
            $map = [int]$c[3]
            $list += [pscustomobject]@{ name = (ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])); account = $c[1]; level = $c[2]; map = $map; mapName = $(if ($mapNames[$map]) { $mapNames[$map] } else { "$map" }); x = $c[4]; y = $c[5]; prof = $(if ($c.Count -ge 7 -and $c[6] -match '^-?\d+$') { [int]$c[6] } else { -1 }) }
        }
    }
    [pscustomobject]@{ stamp = $stamp; players = $list }
}
function Get-Status {
    $hb = Join-Path $Bridge 'heartbeat.txt'
    $procs = @(Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($ServerRoot + '\', [StringComparison]::OrdinalIgnoreCase) } | ForEach-Object { $_.Name })
    [pscustomobject]@{
        heartbeat = $(if (Test-Path -LiteralPath $hb) { [IO.File]::ReadAllText($hb) } else { $null })
        heartbeatAgeSec = $(if (Test-Path -LiteralPath $hb) { [int]((Get-Date) - (Get-Item -LiteralPath $hb).LastWriteTime).TotalSeconds } else { -1 })
        pendingQueued = (Test-Path -LiteralPath (Join-Path $Bridge 'pending.lua'))
        services = $procs
        now = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }
}
# World bosses (VNG \script\boss<refresh>\*.lua): static table data\worldboss.json + live state
# written every minute by script\phongthan\boss\wb_lib.lua into admin_bridge\worldboss.txt
# (key, state 1 alive / -1 killed / 0 not spawned, spawn hhmm, death hhmm, next hhmm, killer).
$WorldBossPath = Join-Path $DataDir 'worldboss.json'
$WorldBoss = if (Test-Path -LiteralPath $WorldBossPath) { @([IO.File]::ReadAllText($WorldBossPath, $Utf8) | ConvertFrom-Json) } else { @() }
function Format-HHMM([string]$v) { if ($v -notmatch '^\d+$' -or [int]$v -le 0) { return '' }; $n = [int]$v; '{0:00}:{1:00}' -f [Math]::Floor($n / 100), ($n % 100) }
function Get-WorldBoss {
    $path = Join-Path $Bridge 'worldboss.txt'
    $live = @{}; $stamp = $null
    if (Test-Path -LiteralPath $path) {
        $lines = [IO.File]::ReadAllLines($path, $Enc1252)
        if ($lines.Count) { $stamp = $lines[0] }
        foreach ($l in ($lines | Select-Object -Skip 1)) { $c = $l -split "`t"; if ($c.Count -ge 5) { $live[$c[0]] = $c } }
    }
    $list = foreach ($b in $WorldBoss) {
        $c = $live[$b.key]
        $st = if ($c) { [int]$c[1] } else { 0 }
        $death = if ($c) { Format-HHMM $c[3] } else { '' }
        [pscustomobject]@{
            key = $b.key; name = $b.name; map = $b.map; mapName = $b.mapName; level = $b.level; dx = $b.dx; dy = $b.dy; schedule = $b.schedule
            state = $(if ($st -eq 1) { 'alive' } elseif ($st -eq -1 -and $death) { 'killed' } else { 'waiting' })
            spawn = $(if ($c) { Format-HHMM $c[2] } else { '' }); death = $death
            next = $(if ($c) { Format-HHMM $c[4] } else { '' })
            killer = $(if ($c -and $c.Count -ge 6 -and $c[5]) { ConvertFrom-Tcvn $Enc1252.GetBytes($c[5]) } else { '' })
        }
    }
    [pscustomobject]@{ stamp = $stamp; bosses = @($list) }
}
# Van Tien tran (2026-10-02): live state written every minute (and after an admin open) by
# script\phongthan\vantien\vt_timer.lua PTVT_WriteStatus into admin_bridge\vantien.txt:
# line 1 time, then n, state (0 closed / 1 preparation / 2 fighting / 3 cleared), kill mask, players inside, seconds left, key.
function Get-VanTien {
    $path = Join-Path $Bridge 'vantien.txt'
    $live = @{}; $stamp = $null
    if (Test-Path -LiteralPath $path) {
        $lines = [IO.File]::ReadAllLines($path, $Enc1252)
        if ($lines.Count) { $stamp = $lines[0] }
        foreach ($l in ($lines | Select-Object -Skip 1)) { $c = $l -split "`t"; if ($c.Count -ge 5 -and $c[0] -match '^\d$') { $live[[int]$c[0]] = $c } }
    }
    $names = @('', 'Tho', 'Thuy', 'Hoa', 'Phong'); $minLv = @(0, 30, 51, 71, 91); $maps = @(0, 1079, 1080, 1081, 1082)
    $list = foreach ($n in 1..4) {
        $c = $live[$n]
        $st = if ($c) { [int]$c[1] } else { 0 }
        $mask = if ($c) { [int]$c[2] } else { 0 }
        $tien = 0; foreach ($b in 1, 2, 4, 8) { if ($mask -band $b) { $tien++ } }
        [pscustomobject]@{
            tran = $n; name = $names[$n]; minLevel = $minLv[$n]; map = $maps[$n]; state = $st
            tien = $(if ($st -gt 0) { $tien } else { 0 }); thongThien = [bool]($st -gt 0 -and ($mask -band 16))
            inside = $(if ($c) { [int]$c[3] } else { 0 }); restSec = $(if ($c) { [int]$c[4] } else { 0 })
        }
    }
    [pscustomobject]@{ stamp = $stamp; trans = @($list) }
}
# Client resolution (PhongThanClient.cpp KMyApp::GameInit reads \config.ini [Client] FullScreen,
# ScreenWidth, ScreenHeight once at startup; the in-game VNG resolution combo has no code behind it).
$ClientCfgPath = Join-Path $Root 'PhongThanRuntime-Staging\Client\config.ini'
function Get-ClientCfg {
    $w = 1024; $h = 768; $f = 0
    if (Test-Path -LiteralPath $ClientCfgPath) {
        foreach ($l in [IO.File]::ReadAllLines($ClientCfgPath, $Enc1252)) {
            if ($l -match '^\s*ScreenWidth\s*=\s*(\d+)') { $w = [int]$Matches[1] }
            elseif ($l -match '^\s*ScreenHeight\s*=\s*(\d+)') { $h = [int]$Matches[1] }
            elseif ($l -match '^\s*FullScreen\s*=\s*(\d+)') { $f = [int]$Matches[1] }
        }
    }
    [pscustomobject]@{ width = $w; height = $h; fullScreen = ($f -ne 0); gameRunning = [bool](Get-Process Game -ErrorAction SilentlyContinue) }
}
function Set-ClientCfg($a) {
    $w = [int]$a.width; $h = [int]$a.height; $f = if ([int]$a.fullScreen) { 1 } else { 0 }
    if (-not (($w -eq 800 -and $h -eq 600) -or ($w -eq 1024 -and $h -eq 768))) { throw 'Chi ho tro 800x600 hoac 1024x768.' }
    if (-not (Test-Path -LiteralPath $ClientCfgPath)) { throw 'Khong tim thay Client\config.ini.' }
    $bak = Join-Path $Root ('_backup\client-config\config.ini.' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $bak) | Out-Null
    Copy-Item -LiteralPath $ClientCfgPath -Destination $bak
    $lines = [Collections.Generic.List[string]]([IO.File]::ReadAllLines($ClientCfgPath, $Enc1252))
    $sec = ''; $seen = @{}; $clientEnd = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $l = $lines[$i]
        if ($l -match '^\s*\[(.+)\]') { if ($sec -eq 'Client') { $clientEnd = $i }; $sec = $Matches[1]; continue }
        if ($sec -ne 'Client') { continue }
        if ($l -match '^\s*ScreenWidth\s*=') { $lines[$i] = "ScreenWidth=$w"; $seen.w = 1 }
        elseif ($l -match '^\s*ScreenHeight\s*=') { $lines[$i] = "ScreenHeight=$h"; $seen.h = 1 }
        elseif ($l -match '^\s*FullScreen\s*=') { $lines[$i] = "FullScreen=$f"; $seen.f = 1 }
    }
    if ($clientEnd -lt 0) { $clientEnd = $lines.Count }
    if (-not $seen.f) { $lines.Insert($clientEnd, "FullScreen=$f") }
    if (-not $seen.h) { $lines.Insert($clientEnd, "ScreenHeight=$h") }
    if (-not $seen.w) { $lines.Insert($clientEnd, "ScreenWidth=$w") }
    [IO.File]::WriteAllLines($ClientCfgPath, $lines.ToArray(), $Enc1252)
    $run = if (Get-Process Game -ErrorAction SilentlyContinue) { ' Game dang mo: thoat game va mo lai de ap dung.' } else { ' Ap dung o lan mo game tiep theo.' }
    "Da luu ${w}x${h}, " + $(if ($f) { 'toan man hinh' } else { 'cua so' }) + '.' + $run
}
# Client sound volume (2026-10-02, agent sound): KUiOptions keeps music/effect volume (0..100, <=3 = mute)
# in Client\UserData\UiCommon.ini [Options] MusicValue / SoundValue and applies them at startup
# (UiInit.cpp:56 -> KUiOptions::LoadSetting -> KOption::SetMusicVolume / SetSndVolume). config.ini has no
# sound keys. The running game rewrites UiCommon.ini from memory, so saving is refused while Game.exe runs.
$ClientUiCommonPath = Join-Path $Root 'PhongThanRuntime-Staging\Client\UserData\UiCommon.ini'
function Get-ClientSound {
    $m = 100; $s = 100
    if (Test-Path -LiteralPath $ClientUiCommonPath) {
        $sec = ''
        foreach ($l in [IO.File]::ReadAllLines($ClientUiCommonPath, $Enc1252)) {
            if ($l -match '^\s*\[(.+)\]') { $sec = $Matches[1]; continue }
            if ($sec -ne 'Options') { continue }
            if ($l -match '^\s*MusicValue\s*=\s*(-?\d+)') { $m = [int]$Matches[1] }
            elseif ($l -match '^\s*SoundValue\s*=\s*(-?\d+)') { $s = [int]$Matches[1] }
        }
    }
    $m = [Math]::Max(0, [Math]::Min(100, $m)); $s = [Math]::Max(0, [Math]::Min(100, $s))
    [pscustomobject]@{ music = $m; sound = $s; gameRunning = [bool](Get-Process Game -ErrorAction SilentlyContinue) }
}
function Set-ClientSound($a) {
    $m = [int]$a.music; $s = [int]$a.sound
    if ($m -lt 0 -or $m -gt 100 -or $s -lt 0 -or $s -gt 100) { throw 'Am luong phai tu 0 den 100.' }
    if (Get-Process Game -ErrorAction SilentlyContinue) { throw 'Game dang mo: thoat game truoc (game ghi de UiCommon.ini khi thoat), roi luu lai.' }
    $lines = New-Object Collections.Generic.List[string]
    if (Test-Path -LiteralPath $ClientUiCommonPath) {
        $bak = Join-Path $Root ('_backup\client-config\UiCommon.ini.' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $bak) | Out-Null
        Copy-Item -LiteralPath $ClientUiCommonPath -Destination $bak
        foreach ($l in [IO.File]::ReadAllLines($ClientUiCommonPath, $Enc1252)) { $lines.Add($l) }
    } else {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ClientUiCommonPath) | Out-Null
    }
    $sec = ''; $seen = @{}; $optStart = -1; $optEnd = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $l = $lines[$i]
        if ($l -match '^\s*\[(.+)\]') { if ($sec -eq 'Options' -and $optEnd -lt 0) { $optEnd = $i }; $sec = $Matches[1]; if ($sec -eq 'Options') { $optStart = $i }; continue }
        if ($sec -ne 'Options') { continue }
        if ($l -match '^\s*MusicValue\s*=') { $lines[$i] = "MusicValue=$m"; $seen.m = 1 }
        elseif ($l -match '^\s*SoundValue\s*=') { $lines[$i] = "SoundValue=$s"; $seen.s = 1 }
    }
    if ($optStart -lt 0) {
        if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -ne '') { $lines.Add('') }
        $lines.Add('[Options]'); $optEnd = $lines.Count
    } elseif ($optEnd -lt 0) { $optEnd = $lines.Count }
    while ($optEnd -gt $optStart + 1 -and $optStart -ge 0 -and $lines[$optEnd - 1].Trim() -eq '') { $optEnd-- }
    if (-not $seen.s) { $lines.Insert($optEnd, "SoundValue=$s") }
    if (-not $seen.m) { $lines.Insert($optEnd, "MusicValue=$m") }
    [IO.File]::WriteAllLines($ClientUiCommonPath, $lines.ToArray(), $Enc1252)
    "Da luu am luong: nhac nen $m, hieu ung $s" + $(if ($m -le 3 -and $s -le 3) { ' (tat tieng)' } else { '' }) + '. Ap dung o lan mo game tiep theo.'
}
function Get-Characters {
    $dir = Join-Path $ServerRoot 'CharacterStore'
    @(Get-ChildItem -LiteralPath $dir -Filter 'role_*.pthc' -ErrorAction SilentlyContinue | ForEach-Object {
        $hex = $_.BaseName.Substring(5)
        if ($hex -match '^([0-9A-Fa-f]{2})+$') {
            $bytes = [byte[]]@(for ($i = 0; $i -lt $hex.Length; $i += 2) { [Convert]::ToByte($hex.Substring($i, 2), 16) })
            [pscustomobject]@{ name = (ConvertFrom-Tcvn $bytes); saved = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm') }
        }
    })
}

# ---------------------------------------------------------------- actions
function Assert-Name([string]$Name) { if (-not $Name -or $Name.Length -gt 32) { throw 'Ten nhan vat khong hop le.' }; $Name }
function Clamp([object]$v, [int]$min, [int]$max) { $n = [int]$v; if ($n -lt $min) { $min } elseif ($n -gt $max) { $max } else { $n } }
function Invoke-Action($a) {
    switch ($a.type) {
        'give' {
            $code = Get-ItemCode $a.itemKey; $n = Clamp $a.count 1 50; $name = Assert-Name $a.player
            Add-BridgeCommand 'Phat do' "$name <- $($code.name) x$n" ("PTAdm_Give({ID}, $(ConvertTo-LuaString $name), $($code.g), $($code.d), $($code.p), $($code.lv), $($code.se), $n, $(ConvertTo-LuaString $code.name))")
        }
        'giveall' {
            $code = Get-ItemCode $a.itemKey; $n = Clamp $a.count 1 50
            Add-BridgeCommand 'Phat do toan server' "Tat ca <- $($code.name) x$n" ("PTAdm_GiveAll({ID}, $($code.g), $($code.d), $($code.p), $($code.lv), $($code.se), $n, $(ConvertTo-LuaString $code.name))")
        }
        'money' { $name = Assert-Name $a.player; $v = Clamp $a.amount 1 2000000000; Add-BridgeCommand 'Tang tien' "$name +$v luong" "PTAdm_Money({ID}, $(ConvertTo-LuaString $name), $v)" }
        'coin' {
            # Tien dong = account ExtPoint (Ky Tran Cac currency). Inline Lua so the
            # running servertimer.lua needs no reload; AddExtPoint marks it changed.
            $name = Assert-Name $a.player; $v = Clamp $a.amount 1 1000000; $ln = ConvertTo-LuaString $name
            Add-BridgeCommand 'Tang tien dong' "$name +$v tien dong" ("local pi = PTAdm_FindPlayer($ln) if pi then AddExtPoint($v) Msg2Player(" + (ConvertTo-LuaString ("Admin t" + [char]0x1EB7 + "ng $v ti" + [char]0x1EC1 + "n " + [char]0x111 + [char]0x1ED3 + "ng")) + ") PTAdm_Log({ID}, `"OK`", $ln .. `" coin+$v now=`" .. GetExtPoint()) else PTAdm_Log({ID}, `"FAIL`", `"offline `" .. $ln) end")
        }
        'skills' {
            $name = Assert-Name $a.player; $prof = [int]$a.prof
            if (-not $ProfRanges.ContainsKey($prof)) { throw 'Phai khong hop le.' }
            $lv = Clamp $a.level 1 10
            $ids = @($a.skills | ForEach-Object { [int]$_ } | Where-Object { ($_ -ge $ProfRanges[$prof][0] -and $_ -le $ProfRanges[$prof][1]) -or ($RebirthByProf[$prof] -contains $_) } | Select-Object -Unique)
            if (-not $ids.Count) { throw 'Chua chon ky nang nao cua phai nay.' }
            $check = if ($a.checkProf -eq $false) { -1 } else { $prof }
            $profName = @('Giap Si', 'Dao Si', 'Di Nhan')[$prof]
            Add-BridgeCommand 'Bi kip / ky nang' "$name <- $($ids.Count) ky nang $profName cap $lv" ("PTAdm_SetSkills({ID}, $(ConvertTo-LuaString $name), $check, $lv, {" + ($ids -join ', ') + "})")
        }
        'level' {
            # KPlayer::SetLevel rolls every skill back to 0 (refunding points) and
            # refunds attribute points; skills 1..60, the summon skills 450..461 and the rebirth skills 1478..1489 are captured and restored.
            $name = Assert-Name $a.player; $v = Clamp $a.level 1 200; $ln = ConvertTo-LuaString $name
            $msg = ConvertTo-LuaString ("Admin: level " + $v)
            Add-BridgeCommand 'Tang level' "$name -> level $v" ("local pi = PTAdm_FindPlayer($ln) if pi then local sk = {} local s = 1 while s <= 1489 do if s <= 60 or s >= 1478 or (s >= 450 and s <= 461) then local l = GetMagicLevel(s) if l and l > 0 then sk[s] = l end end s = s + 1 end SetLevel($v) s = 1 while s <= 1489 do if sk[s] then SetSkillLevel(s, sk[s]) AddMagic(s, sk[s]) end s = s + 1 end Msg2Player($msg) PTAdm_Log({ID}, `"OK`", $ln .. `" level=`" .. GetLevel()) else PTAdm_Log({ID}, `"FAIL`", `"offline `" .. $ln) end")
        }
        'attr' {
            # Attribute points (2026-10-02). AddStrg/AddDex/AddVit/AddEng add to the base value and subtract
            # the same amount from the free points (ScriptFuns.cpp LuaSetPlayer*), so AddProp(total) first
            # keeps the player's own free points. ResetProp refunds every spent point.
            $name = Assert-Name $a.player; $ln = ConvertTo-LuaString $name
            $show = "`" str=`" .. GetStrg(1) .. `" dex=`" .. GetDex(1) .. `" vit=`" .. GetVit(1) .. `" eng=`" .. GetEng(1) .. `" free=`" .. GetProp() .. `" AR=`" .. (GetDex(1) * 4 - 28)"
            if ($a.info) {
                Add-BridgeCommand 'Diem thuoc tinh' "$name xem chi so" ("local pi = PTAdm_FindPlayer($ln) if pi then PTAdm_Log({ID}, `"OK`", $ln .. $show) else PTAdm_Log({ID}, `"FAIL`", `"offline `" .. $ln) end")
            } elseif ($a.reset) {
                Add-BridgeCommand 'Diem thuoc tinh' "$name tay diem" ("local pi = PTAdm_FindPlayer($ln) if pi then ResetProp() Msg2Player(`"Admin: da tay diem thuoc tinh, hay cong lai o F3`") PTAdm_Log({ID}, `"OK`", $ln .. `" reset`" .. $show) else PTAdm_Log({ID}, `"FAIL`", `"offline `" .. $ln) end")
            } else {
                $s = Clamp $a.str 0 5000; $dx = Clamp $a.dex 0 5000; $v = Clamp $a.vit 0 5000; $e = Clamp $a.eng 0 5000; $p = Clamp $a.prop 0 10000
                $tot = $s + $dx + $v + $e
                if (($tot + $p) -le 0) { throw 'Hay nhap so diem can cong.' }
                $lua = "local pi = PTAdm_FindPlayer($ln) if pi then "
                if ($tot -gt 0) { $lua += "AddProp($tot) " }
                if ($s -gt 0) { $lua += "AddStrg($s) " }; if ($dx -gt 0) { $lua += "AddDex($dx) " }
                if ($v -gt 0) { $lua += "AddVit($v) " }; if ($e -gt 0) { $lua += "AddEng($e) " }
                if ($p -gt 0) { $lua += "AddProp($p) " }
                $lua += "Msg2Player(`"Admin: cong diem thuoc tinh`") PTAdm_Log({ID}, `"OK`", $ln .. $show) else PTAdm_Log({ID}, `"FAIL`", `"offline `" .. $ln) end"
                Add-BridgeCommand 'Diem thuoc tinh' "$name +suc manh $s, than phap $dx, sinh khi $v, noi cong $e, tiem nang $p" $lua
            }
        }
        'exp' { $name = Assert-Name $a.player; $v = Clamp $a.amount 1 2000000000; Add-BridgeCommand 'Tang kinh nghiem' "$name +$v exp" "PTAdm_Exp({ID}, $(ConvertTo-LuaString $name), $v)" }
        'news' { $t = "$($a.text)".Trim(); if (-not $t -or $t.Length -gt 250) { throw 'Noi dung thong bao 1-250 ky tu.' }; Add-BridgeCommand 'Thong bao' $t "PTAdm_News({ID}, $(ConvertTo-LuaString $t))" }
        'spawn' {
            $npc = Clamp $a.npc 0 ($Npcs.Count - 1); $lv = Clamp $a.level 1 200; $n = Clamp $a.count 1 30
            $label = "$($Npcs[$npc].name) (#$npc) lv$lv x$n"
            if ($a.mode -eq 'player') { $name = Assert-Name $a.player; Add-BridgeCommand 'Tao boss/NPC' "$label canh $name" "PTAdm_SpawnNear({ID}, $npc, $lv, $(ConvertTo-LuaString $name), $n)" }
            else { $m = [int]$a.map; $x = Clamp $a.x 0 100000; $y = Clamp $a.y 0 100000; Add-BridgeCommand 'Tao boss/NPC' "$label tai $m ($x,$y)" "PTAdm_SpawnAt({ID}, $npc, $lv, $m, $x, $y, $n)" }
        }
        'clear' { Add-BridgeCommand 'Xoa boss/NPC' 'Xoa tat ca NPC tao tu web' 'PTAdm_ClearSpawned({ID})' }
        'wbspawn' {
            $b = @($WorldBoss | Where-Object { $_.key -eq "$($a.key)" })[0]; if (-not $b) { throw 'Khong tim thay boss the gioi.' }
            Add-BridgeCommand 'Boss the gioi' "Goi $($b.key) ngay" ("if not PTWB_SpawnKey then dofile(`"script\\phongthan\\boss\\wb_lib.lua`") end local r = PTWB_SpawnKey(`"$($b.key)`") if r > 0 then PTAdm_Log({ID}, `"OK`", `"npc=`" .. r) elseif r == 0 then PTAdm_Log({ID}, `"OK`", `"dang song`") else PTAdm_Log({ID}, `"FAIL`", `"ket qua `" .. r) end")
        }
        'vtopen' {
            # 2026-10-02 Van Tien tran: open tran n (1 Tho, 2 Thuy, 3 Hoa, 4 Phong) now, 5 min preparation.
            # PTVT_AdminOpen (script\phongthan\vantien\vt_timer.lua): 1 opened, 2 already open, 0 map not loaded.
            $n = [int]$a.tran; if ($n -lt 1 -or $n -gt 4) { throw 'Tran Van Tien phai la 1..4.' }
            $tn = @('', 'Tho', 'Thuy', 'Hoa', 'Phong')[$n]
            Add-BridgeCommand 'Van Tien tran' "Mo Van Tien tran $n ($tn)" ("if not PTVT_AdminOpen then dofile(`"script\\phongthan\\vantien\\vt_timer.lua`") end local r = PTVT_AdminOpen($n) if r == 1 then PTAdm_Log({ID}, `"OK`", `"da mo tran $n ($tn), 5 phut chuan bi`") elseif r == 2 then PTAdm_Log({ID}, `"OK`", `"tran $n ($tn) dang mo san`") else PTAdm_Log({ID}, `"FAIL`", `"khong mo duoc tran $n, ket qua `" .. tostring(r)) end")
        }
        default { throw "Hanh dong khong ho tro: $($a.type)" }
    }
}

# ---------------------------------------------------------------- accounts
. (Join-Path $Root 'PhongThanSource\Deploy\AccountRegistration.ps1')
function Invoke-Sql([string]$Sql, [hashtable]$Params, [switch]$Query) {
    $cn = New-Object Data.SqlClient.SqlConnection 'Server=(localdb)\MSSQLLocalDB;Integrated Security=true;Database=account;Connect Timeout=10'
    $cn.Open()
    try {
        $cmd = $cn.CreateCommand(); $cmd.CommandText = $Sql
        if ($Params) { foreach ($k in $Params.Keys) { [void]$cmd.Parameters.AddWithValue($k, $Params[$k]) } }
        if (-not $Query) { return $cmd.ExecuteNonQuery() }
        $r = $cmd.ExecuteReader(); $rows = @()
        while ($r.Read()) { $o = [ordered]@{}; for ($i = 0; $i -lt $r.FieldCount; $i++) { $o[$r.GetName($i)] = $(if ($r.IsDBNull($i)) { $null } else { "$($r.GetValue($i))" }) }; $rows += [pscustomobject]$o }
        $r.Close(); , $rows
    } finally { $cn.Close() }
}
function Get-Md5Upper([string]$Plain) {
    if ($Plain -cnotmatch '\A[\x21-\x7E]{6,16}\z') { throw 'Mat khau 6-16 ky tu ASCII, khong dau, khong khoang trang.' }
    $md5 = [Security.Cryptography.MD5]::Create()
    try { [BitConverter]::ToString($md5.ComputeHash([Text.Encoding]::ASCII.GetBytes($Plain))).Replace('-', '') } finally { $md5.Dispose() }
}
function Invoke-AccountAction($b) {
    switch ($b.op) {
        'create' {
            $pw = ConvertTo-SecureString $b.password -AsPlainText -Force; $pw2 = ConvertTo-SecureString $b.password -AsPlainText -Force
            New-PhongThanAccount -RuntimeRoot $Runtime -AccountName $b.account -Password $pw -ConfirmPassword $pw2 | Out-Null
            "Da tao tai khoan $($b.account)."
        }
        'password' {
            Assert-PhongThanAccountName $b.account
            $h = Get-Md5Upper $b.password
            $sql = if ($b.alsoSecond) { 'UPDATE Account_Info SET cPassWord=@p, cSecPassword=@p WHERE cAccName=@a' } else { 'UPDATE Account_Info SET cPassWord=@p WHERE cAccName=@a' }
            if ((Invoke-Sql $sql @{ '@p' = $h; '@a' = $b.account }) -ne 1) { throw 'Khong tim thay tai khoan.' }
            "Da doi mat khau $($b.account)."
        }
        'extpoint' {
            Assert-PhongThanAccountName $b.account
            $v = Clamp $b.value 0 2000000000
            if ((Invoke-Sql 'UPDATE Account_Habitus SET nExtPoint=@v WHERE cAccName=@a' @{ '@v' = $v; '@a' = $b.account }) -ne 1) { throw 'Khong tim thay tai khoan.' }
            "Da dat xu = $v cho $($b.account) (co hieu luc khi dang nhap lai)."
        }
        default { throw 'Thao tac tai khoan khong hop le.' }
    }
}

# ---------------------------------------------------------------- scheduler
function Invoke-Event($ev, [string]$Reason) {
    $ids = @()
    foreach ($a in @($ev.actions)) { try { $ids += (Invoke-Action $a).id } catch { Write-Host "Su kien $($ev.name): $($_.Exception.Message)" } }
    $ev.lastRun = (Get-Date -Format 'yyyy-MM-dd HH:mm')
    Save-Json $EventsPath $Events
    "Su kien '$($ev.name)' ($Reason): da xep $($ids.Count) lenh."
}
function Invoke-Scheduler {
    $now = Get-Date; $today = $now.ToString('yyyy-MM-dd'); $dow = [int]$now.DayOfWeek
    foreach ($ev in $Events) {
        if (-not $ev.enabled -or "$($ev.time)" -notmatch '^(\d{1,2}):(\d{2})$') { continue }
        $at = $now.Date.AddHours([int]$Matches[1]).AddMinutes([int]$Matches[2])
        $days = @($ev.days | Where-Object { "$_" -ne '' })
        if ($days.Count -and ($days -notcontains $dow) -and ($days -notcontains "$dow")) { continue }
        if ($now -ge $at -and $now -lt $at.AddMinutes(10) -and "$($ev.lastRun)" -notlike "$today*") { Write-Host (Invoke-Event $ev 'theo lich') }
    }
}

# ---------------------------------------------------------------- http
function Send-Json($ctx, $obj, [int]$Code = 200) {
    $bytes = $Utf8.GetBytes((ConvertTo-Json -InputObject $obj -Depth 8 -Compress))
    $ctx.Response.StatusCode = $Code; $ctx.Response.ContentType = 'application/json; charset=utf-8'
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length); $ctx.Response.Close()
}
function Read-Body($ctx) { $sr = New-Object IO.StreamReader($ctx.Request.InputStream, $Utf8); try { $t = $sr.ReadToEnd() } finally { $sr.Dispose() }; if ($t) { $t | ConvertFrom-Json } else { $null } }
function Find-Items([string]$q, [string]$group) {
    $p = Get-Plain $q; $res = @()
    foreach ($it in $Items) {
        if ($group -and $it.group -ne $group) { continue }
        if ($p -and -not ($it.plain.Contains($p) -or "$($it.code)" -eq $q)) { continue }
        $res += [pscustomobject]@{ key = $it.key; group = $it.group; code = $it.code; name = $it.name }
        if ($res.Count -ge 80) { break }
    }
    , $res
}
function Find-Npcs([string]$q, [string]$kind) {
    $p = Get-Plain $q; $res = @()
    foreach ($n in $Npcs) {
        if ($kind -ne '' -and "$($n.kind)" -ne $kind) { continue }
        if ($p -and -not ($n.plain.Contains($p) -or "$($n.id)" -eq $q)) { continue }
        $res += [pscustomobject]@{ id = $n.id; name = $n.name; kind = $n.kind }
        if ($res.Count -ge 100) { break }
    }
    , $res
}
function Invoke-Route($ctx) {
    $req = $ctx.Request; $path = $req.Url.AbsolutePath; $qs = $req.QueryString
    if ($path -eq '/' -or $path -eq '/index.html') {
        $html = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'index.html'), $Utf8).Replace('__PT_TOKEN__', $Token)
        $bytes = $Utf8.GetBytes($html); $ctx.Response.ContentType = 'text/html; charset=utf-8'
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length); $ctx.Response.Close(); return
    }
    if (-not $path.StartsWith('/api/')) { Send-Json $ctx @{ error = 'Not found' } 404; return }
    # Custom header blocks cross-site requests from other pages in the browser.
    if ($req.Headers['X-PT-Token'] -ne $Token) { Send-Json $ctx @{ error = 'Sai token. Tai lai trang.' } 403; return }
    Update-Results
    switch ("$($req.HttpMethod) $path") {
        'GET /api/status' { Send-Json $ctx @{ status = (Get-Status); online = (Get-Online) } }
        'GET /api/items' { Send-Json $ctx @{ items = (Find-Items $qs['q'] $qs['group']) } }
        'GET /api/groups' { Send-Json $ctx @{ groups = @($Items | ForEach-Object group | Select-Object -Unique) } }
        'GET /api/npcs' { Send-Json $ctx @{ npcs = (Find-Npcs $qs['q'] "$($qs['kind'])") } }
        'GET /api/presets' { Send-Json $ctx @{ presets = $Presets.ToArray(); talismans = @($Talismans | Sort-Object req, name); instruments = @($Instruments | Sort-Object part, ilv); signets = @($Signets | Sort-Object part, ilv) } }
        'GET /api/weapons' {
            $prof = "$($qs['prof'])"; $tier = "$($qs['tier'])"; $greenOnly = "$($qs['green'])" -ne '0'
            $res = @($Weapons | Where-Object { ($prof -eq '' -or "$($_.prof)" -eq $prof) -and ($tier -eq '' -or "$($_.req)" -eq $tier) -and (-not $greenOnly -or $_.green) } | Sort-Object req, name, ilv | Select-Object -First 300)
            $tiers = @($Weapons | Where-Object { $prof -eq '' -or "$($_.prof)" -eq $prof } | ForEach-Object req | Sort-Object -Unique)
            Send-Json $ctx @{ weapons = $res; tiers = $tiers }
        }
        'GET /api/gearsets' {
            $prof = [int]"0$($qs['prof'])"; $out = New-Object Collections.Generic.List[object]
            foreach ($g in ($GearPieces | Where-Object prof -eq $prof | Group-Object set, variant, ilv | Sort-Object { $_.Group[0].tier }, { $_.Group[0].set }, { $_.Group[0].variant }, { $_.Group[0].ilv })) {
                $f = $g.Group[0]
                $pieces = @($g.Group | Group-Object piece | ForEach-Object { $_.Group[0] } | ForEach-Object { [pscustomobject]@{ piece = $_.piece; key = $_.key; name = $_.name; req = $_.req } })
                $out.Add([pscustomobject]@{ set = $f.set; tier = $f.tier; variant = $f.variant; ilv = $f.ilv; title = $setName["$($f.set)|$prof|$($f.variant)"]; pieces = $pieces })
            }
            Send-Json $ctx @{ sets = $out.ToArray() }
        }
        'POST /api/giveset' {
            $b = Read-Body $ctx; $name = Assert-Name $b.player; $n = 0
            foreach ($k in @($b.keys)) { if ($GearPieces | Where-Object key -eq "$k") { [void](Invoke-Action ([pscustomobject]@{ type = 'give'; itemKey = "$k"; player = $name; count = 1 })); $n++ } }
            if (-not $n) { throw 'Khong co mon hop le trong bo.' }
            Send-Json $ctx @{ ok = $true; message = "Da xep lenh phat $n mon do luc cho $name." }
        }
        'GET /api/mounts' {
            $prof = "$($qs['prof'])"; $p = Get-Plain "$($qs['q'])"; $res = New-Object Collections.Generic.List[object]; $seen = @{}
            foreach ($m in $Mounts) {
                if ($prof -ne '' -and $m.prof -ne -1 -and "$($m.prof)" -ne $prof) { continue }
                if ($p -and -not $m.plain.Contains($p)) { continue }
                $sig = "$($m.name)|$($m.prof)|$($m.req)"; if ($seen[$sig]) { continue }; $seen[$sig] = $true
                $res.Add([pscustomobject]@{ key = $m.key; name = $m.name; prof = $m.prof; req = $m.req })
                if ($res.Count -ge 150) { break }
            }
            Send-Json $ctx @{ mounts = $res.ToArray(); total = $Mounts.Count }
        }
        'GET /api/skills' { Send-Json $ctx @{ skills = $Skills.ToArray() } }
        'GET /api/maps' { Send-Json $ctx @{ maps = $Maps.ToArray() } }
        'GET /api/worldboss' { Send-Json $ctx (Get-WorldBoss) }
        'GET /api/vantien' { Send-Json $ctx (Get-VanTien) }
        'GET /api/clientcfg' { Send-Json $ctx (Get-ClientCfg) }
        'POST /api/clientcfg' { Send-Json $ctx @{ ok = $true; message = (Set-ClientCfg (Read-Body $ctx)) } }
        'GET /api/clientsound' { Send-Json $ctx (Get-ClientSound) }
        'POST /api/clientsound' { Send-Json $ctx @{ ok = $true; message = (Set-ClientSound (Read-Body $ctx)) } }
        'GET /api/characters' { Send-Json $ctx @{ characters = (Get-Characters) } }
        'GET /api/history' { Send-Json $ctx @{ history = $History.ToArray() } }
        'POST /api/action' { $r = Invoke-Action (Read-Body $ctx); Send-Json $ctx @{ ok = $true; message = "Da xep lenh $($r.id): $($r.desc)"; entry = $r } }
        'GET /api/accounts' { Send-Json $ctx @{ accounts = (Invoke-Sql 'SELECT i.cAccName AS account, CONVERT(varchar(16), i.dRegDate, 120) AS registered, CONVERT(varchar(16), i.dLoginDate, 120) AS lastLogin, h.nExtPoint AS extPoint FROM Account_Info i LEFT JOIN Account_Habitus h ON h.cAccName = i.cAccName ORDER BY i.cAccName' -Query) } }
        'POST /api/account' { Send-Json $ctx @{ ok = $true; message = (Invoke-AccountAction (Read-Body $ctx)) } }
        'GET /api/events' { Send-Json $ctx @{ events = $Events.ToArray() } }
        'POST /api/events' {
            $b = Read-Body $ctx
            if (-not $b.name -or "$($b.time)" -notmatch '^\d{1,2}:\d{2}$') { throw 'Can ten su kien va gio dang HH:mm.' }
            $existing = $null; foreach ($e in $Events) { if ($e.id -eq $b.id) { $existing = $e } }
            if ($existing) { [void]$Events.Remove($existing) }
            $ev = [pscustomobject]@{ id = $(if ($b.id) { $b.id } else { 'e' + (Get-Date -Format 'yyyyMMddHHmmss') }); name = "$($b.name)"; enabled = [bool]$b.enabled; time = "$($b.time)"; days = @($b.days); lastRun = $(if ($existing) { $existing.lastRun } else { '' }); actions = @($b.actions) }
            [void]$Events.Add($ev); Save-Json $EventsPath $Events
            Send-Json $ctx @{ ok = $true; message = "Da luu su kien '$($ev.name)'." }
        }
        'POST /api/events/delete' { $b = Read-Body $ctx; $del = @($Events | Where-Object { $_.id -eq $b.id }); foreach ($d in $del) { [void]$Events.Remove($d) }; Save-Json $EventsPath $Events; Send-Json $ctx @{ ok = $true; message = 'Da xoa su kien.' } }
        'POST /api/events/run' { $b = Read-Body $ctx; $ev = @($Events | Where-Object { $_.id -eq $b.id })[0]; if (-not $ev) { throw 'Khong tim thay su kien.' }; Send-Json $ctx @{ ok = $true; message = (Invoke-Event $ev 'chay ngay') } }
        'GET /api/setup/status' { Send-Json $ctx (Get-SetupState) }
        'POST /api/setup/run' {
            $b = Read-Body $ctx; $step = "$($b.step)"
            if (@('all', 'localdb', 'database', 'backup') -notcontains $step) { throw 'Buoc cai dat khong hop le.' }
            if ($script:SetupProc -and -not $script:SetupProc.HasExited) { throw 'Dang co mot buoc cai dat chay, hay doi.' }
            $script:SetupLog = Join-Path $DataDir 'setup.log'
            Set-Content -LiteralPath $script:SetupLog -Value "== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') buoc: $step" -Encoding UTF8
            $script:SetupProc = Start-Process -FilePath 'powershell.exe' -PassThru -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$SetupScript`"", '-Step', $step, '-LogPath', "`"$($script:SetupLog)`"")
            Send-Json $ctx @{ ok = $true; message = "Da bat dau buoc '$step'. Xem nhat ky ben duoi." }
        }
        default { Send-Json $ctx @{ error = 'Not found' } 404 }
    }
}

# ---------------------------------------------------------------- server setup (LocalDB + account DB)
$SetupScript = Join-Path $PSScriptRoot 'PhongThan-Setup.ps1'
$script:SetupProc = $null
$script:SetupLog = Join-Path $DataDir 'setup.log'
function Get-SetupState {
    $running = [bool]($script:SetupProc -and -not $script:SetupProc.HasExited)
    $st = $null
    if (-not $running) {
        $raw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $SetupScript -Step check -Json 2>$null
        $line = @($raw | Where-Object { "$_".StartsWith('{') })[-1]
        if ($line) { $st = $line | ConvertFrom-Json }
    }
    $log = @()
    if (Test-Path -LiteralPath $script:SetupLog) { $log = @(Get-Content -LiteralPath $script:SetupLog -Encoding UTF8 -Tail 40) }
    $exit = $null
    if ($script:SetupProc -and $script:SetupProc.HasExited) { $exit = $script:SetupProc.ExitCode }
    @{ running = $running; status = $st; log = $log; exitCode = $exit }
}

$listener = New-Object Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
$url = "http://localhost:$Port/"
Write-Host "Phong Than Admin dang chay: $url  (dong cua so nay de tat)"
Write-Host "Vat pham: $($Items.Count) | NPC: $($Npcs.Count) | Ban do: $($Maps.Count)"
if (-not $NoBrowser) { Start-Process $url }
try {
    while ($listener.IsListening) {
        $task = $listener.GetContextAsync()
        while (-not $task.Wait(2000)) { try { Invoke-Scheduler } catch { Write-Host "Scheduler: $($_.Exception.Message)" } }
        $ctx = $task.Result
        try { Invoke-Route $ctx }
        catch { try { Send-Json $ctx @{ error = $_.Exception.Message } 400 } catch {} }
    }
} finally { $listener.Stop(); $listener.Close() }
