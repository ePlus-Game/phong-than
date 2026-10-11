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
            $Skills.Add([pscustomobject]@{ id = $id; prof = $p; name = (ConvertFrom-Tcvn $Enc1252.GetBytes($c[0])).TrimStart('#'); style = [int]("0$($c[4])" -replace '\D', ''); max = $max })
        }
    }
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
            $ids = @($a.skills | ForEach-Object { [int]$_ } | Where-Object { $_ -ge $ProfRanges[$prof][0] -and $_ -le $ProfRanges[$prof][1] } | Select-Object -Unique)
            if (-not $ids.Count) { throw 'Chua chon ky nang nao cua phai nay.' }
            $check = if ($a.checkProf -eq $false) { -1 } else { $prof }
            $profName = @('Giap Si', 'Dao Si', 'Di Nhan')[$prof]
            Add-BridgeCommand 'Bi kip / ky nang' "$name <- $($ids.Count) ky nang $profName cap $lv" ("PTAdm_SetSkills({ID}, $(ConvertTo-LuaString $name), $check, $lv, {" + ($ids -join ', ') + "})")
        }
        'level' {
            # KPlayer::SetLevel rolls every skill back to 0 (refunding points) and
            # refunds attribute points; skills 1..60 are captured and restored.
            $name = Assert-Name $a.player; $v = Clamp $a.level 1 200; $ln = ConvertTo-LuaString $name
            $msg = ConvertTo-LuaString ("Admin: level " + $v)
            Add-BridgeCommand 'Tang level' "$name -> level $v" ("local pi = PTAdm_FindPlayer($ln) if pi then local sk = {} local s = 1 while s <= 60 do local l = GetMagicLevel(s) if l and l > 0 then sk[s] = l end s = s + 1 end SetLevel($v) s = 1 while s <= 60 do if sk[s] then SetSkillLevel(s, sk[s]) AddMagic(s, sk[s]) end s = s + 1 end Msg2Player($msg) PTAdm_Log({ID}, `"OK`", $ln .. `" level=`" .. GetLevel()) else PTAdm_Log({ID}, `"FAIL`", `"offline `" .. $ln) end")
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
        default { Send-Json $ctx @{ error = 'Not found' } 404 }
    }
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
