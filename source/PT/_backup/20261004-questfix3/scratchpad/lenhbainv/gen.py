# -*- coding: utf-8 -*-
# lenhbainv (2026-10-04): generate the Lua of "Lenh Bai Nhiem Vu" (magicscript 61430) and "Lenh Bai Tiep Te Nhiem Vu"
# (magicscript 61431). Output (ASCII files, TCVN3 as \ddd escapes) to scratchpad\lenhbainv\out\script\phongthan\item\:
#   nhiemvu_data.lua     shared library + data (destinations, groups, quest-step rows, item sets); no main()
#   nhiemvu_lenhbai.lua  item script 61430: menus + teleport
#   tiepte_lenhbai.lua   item script 61431: items still missing for the current steps
#   nhiemvu_give.lua     auto-give of both tokens for the minute tick (no main(): dofile'd into the servertimer state)
# Inputs: dests_final.json (pick_all.py: live NPC positions + arrival cells), chains.py/chains2.py (quest steps),
# item names from the effective (PAK-first) settings\item\001\{questkey,material,magicscript,potion}.txt.
import os, sys, json, unicodedata, math
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low as _low
import chains
from pakread import Side

ITEM_NV, ITEM_TT, TASK_NV, TASK_TT = 61430, 61431, 2611, 2612
NL = "\r\n"


def tcvn(s):
    o = bytearray()
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128: o.append(ord(ch))
        elif ch in _low: o.append(_low[ch])
        elif ch.lower() in _low: o.append(_low[ch.lower()])
        else: raise ValueError(repr(ch) + " in " + s)
    return bytes(o)


def LB(b):
    out = []
    for c in b:
        if c >= 128 or c < 32: out.append("\\%03d" % c)
        elif c in (34, 92): out.append("\\" + chr(c))
        else: out.append(chr(c))
    return '"' + "".join(out) + '"'


def L(s):
    return LB(tcvn(s))


def asc(s):
    return unicodedata.normalize("NFD", s).replace("đ", "d").replace("Đ", "D").encode("ascii", "ignore").decode()


# ------------------------------------------------------------------ item names (TCVN3 bytes from the item tables)
_srv = Side("Server")
NAMES = {}


def _table(path, key):
    b, _ = _srv.get(path)
    if not b:
        return
    for l in b.split(b"\r\n")[1:]:
        c = l.split(b"\t")
        if len(c) < 4 or not c[0]:
            continue
        try:
            k = key(c)
        except ValueError:
            continue
        nm = c[0].lstrip(b"#")
        while b"<c" in nm:          # strip <c=...> tags
            a = nm.find(b"<c")
            e = nm.find(b">", a)
            if e < 0: break
            nm = nm[:a] + nm[e + 1:]
        if k not in NAMES and nm.strip():
            NAMES[k] = nm.strip()


_table("\\settings\\item\\001\\questkey.txt", lambda c: (4, int(c[2]), 0))
_table("\\settings\\item\\001\\material.txt", lambda c: (int(c[1]), int(c[2]), 0))
_table("\\settings\\item\\001\\magicscript.txt", lambda c: (6, 1, int(c[3])))
_table("\\settings\\item\\001\\potion.txt", lambda c: (int(c[1]), int(c[2]), 0))


def item_name(it):
    tag, k, g, d, p, lv, cnt, cv, cb, name, cl = it
    if k == 1:
        return NAMES.get((4, g, 0)) or tcvn(name)
    if k == 3:
        return tcvn(name)
    return NAMES.get((g, d, p)) or (tcvn(name) if name else b"(%d,%d,%d)" % (g, d, p))


# ------------------------------------------------------------------ destinations, gates, groups
DF = json.load(open(os.path.join(H, "dests_final.json"), encoding="utf-8"))
TOWNS = {1001, 1002, 1003, 1004, 1020, 1021, 1052}
GROUPS = [
    (2, "Tân thủ (cấp 1-24)", "qs1002 qs1003 qs1004 toho lohung authienhoa sungungbuu trieudien trieuloi sungungloan "
     "thukho1002 taphoa1002 tuhang namcuc linhbao xichtinh hoanglong_t vantrung nhiendang thukho1003 taphoa1003 "
     "thieuhao hautho chucdung phongba congcong khoaphu caogiac caominh hinhthien_t thukho1004 taphoa1004 "
     "thodong1003 thodong1004 shs1002 shs1003 shs1004 dpmanhtan dptamson dpdongquan"),
    (3, "Chính tuyến (cấp 25-85)", "sunghauho trinhluan sunghacho hoanglong loichantu hinhthien phonglam ngolong "
     "chutuudiem thuonghao vanthaisu dabao hoangphiho lytinh dangcuucong khuongtunha duongtien hohymi hoangthienhoa "
     "thohanhton dacky tayvuongmau vovuong tiepdan1020 tiepdan1021"),
    (4, "Thế giới, thành thị (cấp 23-70)", "tongdinhan thaytuongso1021 nhamdaitau hoangthienhoa_tq thukho1020 thukho1021 "
     "tiba bagiam nguoitayvuc conbac chucamdo dothuquan culuuton thayboi tanmien tieubao vocat nguoihaithuoc "
     "duongtien_qt tontuvu dangcuucong_dd hoangphiho_sd"),
    (5, "Hàng ngày, lặp lại", "vosu1002 vosu1003 vosu1004 thohanhton_tl natra hoangthienhoa_tl duongtien_tl taphoa_vc "
     "anhong bt1020 luclam tieusudq luongthao chiemtinh1020 chiemtinh1021 tongtieudau tinhquan1020 tinhquan1021 "
     "thaitue1020 angiao thaytuongso1020 thuyenphu1055 thuyenphu1056"),
    (6, "Sự kiện, hoạt động", "thienhung1020 dukhanh lanhdia vienco thiluyen tiepdan1021 lequan1020 shs1020 linhthu1021"),
]
used = set()
for r in chains.ROWS:
    if r["dest"]:
        used.add(r["dest"])
for g in GROUPS:
    used.update(g[2].split())
CUSTOM_KEYS = [k for k in DF if k.startswith(("dp", "gs", "tower", "tt"))] + ["hoangthienhoa", "thohanhton_tl", "natra",
                                                                              "hoangthienhoa_tl", "duongtien_tl", "dukhanh",
                                                                              "duongtien_qt", "taphoa_vc"]
used.update(k for k in CUSTOM_KEYS if k in DF)
KEYS = sorted(used, key=lambda k: (DF[k]["map"], DF[k]["lv"], k))
IDX = {k: i + 1 for i, k in enumerate(KEYS)}


def gate_of(k):
    m = DF[k]["map"]
    if m == 1073:
        return 9 if (k.startswith("dd_") or k == "dongdi1073") else 1
    return {1074: 2, 1075: 3, 1076: 4, 1064: 5, 1063: 6, 1062: 7, 1061: 8}.get(m, 0)


# ------------------------------------------------------------------ item sets
SETS = {}


def set_id(items):
    if not items:
        return 0
    key = tuple(items)
    if key not in SETS:
        SETS[key] = len(SETS) + 1
    return SETS[key]


for r in chains.ROWS:
    r["set"] = set_id(r["items"])

CHT = dict(chains.CH)
CUSTOM = {33: "PTNV_X33", 36: "PTNV_X36", 44: "PTNV_X44", 52: "PTNV_X52", 70: "PTNV_X70"}
ORDER = [c for c, _ in chains.CH]

# ================================================================== nhiemvu_data.lua
o = []
w = o.append
w("-- Phong Than \"Lenh Bai Nhiem Vu\" (61430) + \"Lenh Bai Tiep Te Nhiem Vu\" (61431): shared library and data.")
w("-- 2026-10-04, agent lenhbainv. GENERATED by scratchpad\\lenhbainv\\gen.py - edit the generator, not this file.")
w("-- Doc: docs\\features\\lenh-bai-nhiem-vu-phong-than-20261004.md. No main(): loaded at call time by both item scripts")
w("-- (PTNV_Load in nhiemvu_lenhbai.lua / tiepte_lenhbai.lua). Lua 4: one small statement per record (stack 120 slots).")
w("-- Destinations: live NPC positions dumped from the running server (admin bridge, 2026-10-04 15:16); arrival cell")
w("-- 1-3 cells from the NPC (monsters: 3-7), walkable with its 8 neighbours on the client and server grids, no trap.")
w("")
w("PTNV_DS = {}")
w("PTNV_GR = {}")
w("PTNV_CH = {}")
w("PTNV_CO = {}")
w("PTNV_NCO = 0")
w("PTNV_IS = {}")
w("PTNV_DP = {}")
w("PTNV_GS = {}")
w("PTNV_TW = {}")
w("PTNV_TT = {}")
w("")
w("function PTNV_D(i, m, x, y, lv, camp, gate, fight, nm)")
w("\tlocal d = {}")
w("\td.map = m")
w("\td.x = x")
w("\td.y = y")
w("\td.lv = lv")
w("\td.camp = camp")
w("\td.gate = gate")
w("\td.fight = fight")
w("\td.nm = nm")
w("\tPTNV_DS[i] = d")
w("end")
w("")
w("function PTNV_GN(g, title)")
w("\tlocal t = {}")
w("\tt.n = 0")
w("\tt.title = title")
w("\tPTNV_GR[g] = t")
w("end")
w("")
w("function PTNV_M(g, i)")
w("\tlocal t = PTNV_GR[g]")
w("\tt.n = t.n + 1")
w("\tt[t.n] = i")
w("end")
w("")
w("function PTNV_C(c, title, fn)")
w("\tlocal t = {}")
w("\tt.title = title")
w("\tt.fn = fn")
w("\tt.n = 0")
w("\tt.r = {}")
w("\tPTNV_CH[c] = t")
w("\tPTNV_NCO = PTNV_NCO + 1")
w("\tPTNV_CO[PTNV_NCO] = c")
w("end")
w("")
w("-- quest-step row: chain, task var, value lo..hi, camp (-1 all), level, start-row flag + max level, destination,")
w("-- text, item set, second task var lo2..hi2, extra condition, kill (fight / counter step: no item can replace it)")
w("function PTNV_R(c, var, lo, hi, camp, lv, st, lvmax, dest, txt, set, v2, lo2, hi2, cond, kill)")
w("\tlocal r = {}")
w("\tr.var = var")
w("\tr.lo = lo")
w("\tr.hi = hi")
w("\tr.camp = camp")
w("\tr.lv = lv")
w("\tr.st = st")
w("\tr.lvmax = lvmax")
w("\tr.dest = dest")
w("\tr.txt = txt")
w("\tr.set = set")
w("\tr.v2 = v2")
w("\tr.lo2 = lo2")
w("\tr.hi2 = hi2")
w("\tr.cond = cond")
w("\tr.kill = kill")
w("\tlocal t = PTNV_CH[c]")
w("\tt.n = t.n + 1")
w("\tt.r[t.n] = r")
w("end")
w("")
w("-- item: kind 1 event item (detail g), 2 VNG tuple g,d,p created at level lv, counted at level cl (-1 any),")
w("-- 3 skill book (skill lv, book 6,1,p); n = count; cv/cb = only when bit cb of task cv is set")
w("function PTNV_It(k, g, d, p, lv, n, cl, cv, cb, nm)")
w("\tlocal it = {}")
w("\tit.k = k")
w("\tit.g = g")
w("\tit.d = d")
w("\tit.p = p")
w("\tit.lv = lv")
w("\tit.n = n")
w("\tit.cl = cl")
w("\tit.cv = cv")
w("\tit.cb = cb")
w("\tit.nm = nm")
w("\treturn it")
w("end")
w("")
w("function PTNV_I(s, k, g, d, p, lv, n, cl, cv, cb, nm)")
w("\tlocal t = PTNV_IS[s]")
w("\tif not t then")
w("\t\tt = {}")
w("\t\tt.n = 0")
w("\t\tPTNV_IS[s] = t")
w("\tend")
w("\tt.n = t.n + 1")
w("\tt[t.n] = PTNV_It(k, g, d, p, lv, n, cl, cv, cb, nm)")
w("end")
w("")
w("-- runtime row for the custom chains")
w("function PTNV_Row(dest, txt, items, kill, lv)")
w("\tlocal r = {}")
w("\tr.dest = dest")
w("\tr.txt = txt")
w("\tr.items = items")
w("\tr.set = 0")
w("\tr.kill = kill")
w("\tr.lv = lv")
w("\treturn r")
w("end")
w("")
T = {
    "close": "Đóng", "back": "Quay lại", "next": "Trang sau",
    "blocked": "<color=yellow>Lệnh bài<color>: không dùng được ở bản đồ này (sự kiện, phó bản, chiến trường, Thiên Lao). Hãy ra bản đồ ngoài hoặc về thành trước.",
    "gate": "<color=yellow>Lệnh Bài Nhiệm Vụ<color>: chưa tới bước nhiệm vụ ở bản đồ này (cần làm theo chuỗi, NPC sẽ đưa bạn tới). Lệnh bài chỉ đưa tới đây khi bạn đã đi tới bước đó.",
    "nomap": " chưa được mở trên máy chủ.", "nogo": "Không dịch chuyển được tới ",
    "arrive": "Đã tới cạnh ", "lvneed": " (cần cấp ", "lv": "cấp ",
}
for k, v in T.items():
    w("PTNV_T_%s = %s" % (k.upper(), L(v)))
w("")
w("function PTNV_Camp()")
w("\tlocal c = nil")
w("\tif GetPlayerType then c = GetPlayerType() end")
w("\tif c == nil or c < 0 or c > 2 then c = GetProfession() end")
w("\tif c == nil or c < 0 or c > 2 then c = 0 end")
w("\treturn c")
w("end")
w("")
w("-- main-story task of the camp: Giap Si 3, Dao Si 1, Di Nhan 2")
w("function PTNV_MainVar()")
w("\tlocal c = PTNV_Camp()")
w("\tif c == 0 then return 3 end")
w("\treturn c")
w("end")
w("")
w("function PTNV_Bit(v, b)")
w("\treturn mod(floor(v / b), 2) == 1")
w("end")
w("")
w("function PTNV_Say(title, o)")
w("\tlocal n = getn(o)")
w("\tlocal t = { title, n }")
w("\tlocal k = 1")
w("\twhile k <= n do t[k + 2] = o[k] k = k + 1 end")
w("\tcall(Say, t)")
w("end")
w("")
w("-- maps where the tokens work: field maps and cities 1001-1057, quest maps 1061-1065, Tien Ma / Luu Ba / Khong Tang")
w("-- 1073-1078. Never from Thien Lao (1060), Truc Lung (1066), Van Tien (1067-1070, 1079-1082), battlefield (1071),")
w("-- Khai Minh dao (1072), Huyen Vu and the instances 1083+.")
w("function PTNV_SrcOk()")
w("\tlocal m = GetWorldPos()")
w("\tif not m then return nil end")
w("\tif m >= 1001 and m <= 1057 then return m end")
w("\tif m >= 1061 and m <= 1065 then return m end")
w("\tif m >= 1073 and m <= 1078 then return m end")
w("\treturn nil")
w("end")
w("")
w("function PTNV_Blocked()")
w("\tSay(PTNV_T_BLOCKED, 1, PTNV_T_CLOSE .. \"/\" .. PTNV_NOFN)")
w("end")
w("")
w("-- quest-progress gates of the maps the chains reach through NPC teleports (same tests as those NPCs)")
w("function PTNV_Gate(code)")
w("\tif code == 1 then return GetLevel() >= 75 and GetTask(2252) > 0 end")
w("\tif code == 2 then local t = GetTask(2222) return t == 14 or t >= 20 end")
w("\tif code == 3 then return GetTask(2222) >= 27 end")
w("\tif code == 4 then return GetTask(2283) >= 46 end")
w("\tif code == 5 then return GetTask(PTNV_MainVar()) >= 50 end")
w("\tif code == 6 then return GetTask(PTNV_MainVar()) >= 71 end")
w("\tif code == 7 then return GetTask(PTNV_MainVar()) >= 72 end")
w("\tif code == 8 then return GetTask(PTNV_MainVar()) >= 80 end")
w("\tif code == 9 then return GetTask(597) >= 9 end")
w("\treturn 1")
w("end")
w("")
w("function PTNV_Go(i)")
w("\tlocal d = PTNV_DS[i]")
w("\tif not d then return end")
w("\tif not PTNV_SrcOk() then PTNV_Blocked() return end")
w("\tif d.gate > 0 and not PTNV_Gate(d.gate) then")
w("\t\tSay(PTNV_T_GATE, 1, PTNV_T_CLOSE .. \"/\" .. PTNV_NOFN)")
w("\t\treturn")
w("\tend")
w("\tlocal sw = SubWorldID2Idx(d.map)")
w("\tif not sw or sw < 0 then")
w("\t\tMsg2Player(d.nm .. PTNV_T_NOMAP)")
w("\t\treturn")
w("\tend")
w("\tif NewWorld(d.map, d.x, d.y) == 0 then")
w("\t\tMsg2Player(PTNV_T_NOGO .. d.nm .. \".\")")
w("\t\treturn")
w("\tend")
w("\tSetFightState(d.fight)")
w("\tMsg2Player(PTNV_T_ARRIVE .. d.nm .. \" [\" .. floor(d.x / 8) .. \",\" .. floor(d.y / 16) .. \"].\")")
w("end")
w("")
w("-- destinations of a group visible to the camp of the player")
w("function PTNV_List(g)")
w("\tlocal camp = PTNV_Camp()")
w("\tlocal t = PTNV_GR[g]")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\tlocal k = 1")
w("\twhile k <= t.n do")
w("\t\tlocal d = PTNV_DS[t[k]]")
w("\t\tif d.camp < 0 or d.camp == camp then")
w("\t\t\tn = n + 1")
w("\t\t\to[n] = t[k]")
w("\t\tend")
w("\t\tk = k + 1")
w("\tend")
w("\to.n = n")
w("\treturn o")
w("end")
w("")
w("-- page p of n entries: 4 per page + next, or the last <= 5 entries; returns first, last, has-next")
w("function PTNV_Span(n, p)")
w("\tlocal first = (p - 1) * 4 + 1")
w("\tif n - first + 1 <= 5 then return first, n, nil end")
w("\treturn first, first + 3, 1")
w("end")
w("")
w("function PTNV_Page(g, p)")
w("\tlocal t = PTNV_List(g)")
w("\tlocal first, last, more = PTNV_Span(t.n, p)")
w("\tlocal lv = GetLevel()")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\tlocal i = first")
w("\twhile i <= last do")
w("\t\tlocal d = PTNV_DS[t[i]]")
w("\t\tlocal s = d.nm .. \" (\" .. PTNV_T_LV .. d.lv .. \")\"")
w("\t\tif lv < d.lv then s = s .. \" *\" end")
w("\t\tn = n + 1")
w("\t\to[n] = s .. \"/PTNV_G\" .. t[i]")
w("\t\ti = i + 1")
w("\tend")
w("\tif more then n = n + 1 o[n] = PTNV_T_NEXT .. \"/PTNV_P\" .. g .. \"_\" .. (p + 1) end")
w("\tif p > 1 then n = n + 1 o[n] = PTNV_T_BACK .. \"/PTNV_P\" .. g .. \"_\" .. (p - 1)")
w("\telse n = n + 1 o[n] = PTNV_T_BACK .. \"/main\" end")
w("\tn = n + 1 o[n] = PTNV_T_CLOSE .. \"/PTNV_No\"")
w("\tPTNV_Say(\"<color=yellow>\" .. PTNV_GR[g].title .. \"<color>: \" .. PTNV_T_PAGEHINT .. lv .. \".\", o)")
w("end")
w("")
w("function PTNV_Cond(code)")
w("\tif code == 1 then")
w("\t\tif date then return tonumber(date(\"%Y%m%d\")) == GetTask(2010) end")
w("\t\treturn 1")
w("\tend")
w("\tif code == 3 then return GetTask(2283) == 0 end")
w("\treturn 1")
w("end")
w("")
w("function PTNV_Match(q, camp, lv)")
w("\tif q.camp >= 0 and q.camp ~= camp then return nil end")
w("\tlocal v = GetTask(q.var)")
w("\tif v < q.lo or v > q.hi then return nil end")
w("\tif q.v2 > 0 then")
w("\t\tlocal v2 = GetTask(q.v2)")
w("\t\tif v2 < q.lo2 or v2 > q.hi2 then return nil end")
w("\tend")
w("\tif q.st == 1 and (lv < q.lv or lv > q.lvmax) then return nil end")
w("\tif q.cond > 0 and not PTNV_Cond(q.cond) then return nil end")
w("\treturn 1")
w("end")
w("")
w("-- every chain with a step in progress (first matching row per chain): o[i] = { c = chain, r = row }")
w("function PTNV_Active()")
w("\tlocal camp = PTNV_Camp()")
w("\tlocal lv = GetLevel()")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\tlocal k = 1")
w("\twhile k <= PTNV_NCO do")
w("\t\tlocal c = PTNV_CO[k]")
w("\t\tlocal ch = PTNV_CH[c]")
w("\t\tlocal r = nil")
w("\t\tif ch.fn then")
w("\t\t\tlocal f = getglobal(ch.fn)")
w("\t\t\tr = f(camp, lv)")
w("\t\telse")
w("\t\t\tlocal j = 1")
w("\t\t\twhile j <= ch.n and not r do")
w("\t\t\t\tif PTNV_Match(ch.r[j], camp, lv) then r = ch.r[j] end")
w("\t\t\t\tj = j + 1")
w("\t\t\tend")
w("\t\tend")
w("\t\tif r then")
w("\t\t\tlocal e = {}")
w("\t\t\te.c = c")
w("\t\t\te.r = r")
w("\t\t\tn = n + 1")
w("\t\t\to[n] = e")
w("\t\tend")
w("\t\tk = k + 1")
w("\tend")
w("\to.n = n")
w("\treturn o")
w("end")
w("")
w("function PTNV_Clip(s, n)")
w("\tif strlen(s) > n then return strsub(s, 1, n - 2) .. \"..\" end")
w("\treturn s")
w("end")
w("")
w("-- one line describing the step of an active entry")
w("function PTNV_StepText(e)")
w("\tlocal r = e.r")
w("\tlocal s = \"<color=yellow>\" .. PTNV_CH[e.c].title .. \"<color>: \" .. r.txt")
w("\tif r.lv and r.lv > GetLevel() then s = s .. PTNV_T_LVNEED .. r.lv .. \")\" end")
w("\tif r.dest and r.dest > 0 then s = s .. \". \" .. PTNV_T_NPC .. PTNV_DS[r.dest].nm .. \".\" end")
w("\tif r.kill == 1 then s = s .. \" \" .. PTNV_T_KILL end")
w("\treturn s")
w("end")
w("")
w("-- items of a row still required now: o[i] = { it, have, miss }, o.tot = pieces missing, o.kinds = kinds missing")
w("function PTNV_Have(it)")
w("\tif it.k == 1 then return HaveEventItemCount(it.g) or 0 end")
w("\tif it.k == 3 then")
w("\t\tlocal ml = HaveMagic(it.lv)")
w("\t\tif ml and ml > 0 then return 1 end")
w("\t\treturn HaveNormalItem(6, 1, it.p, -1) or 0")
w("\tend")
w("\treturn HaveNormalItem(it.g, it.d, it.p, it.cl) or 0")
w("end")
w("")
w("function PTNV_Need(r)")
w("\tlocal L = r.items")
w("\tif not L and r.set > 0 then L = PTNV_IS[r.set] end")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\to.tot = 0")
w("\to.kinds = 0")
w("\tif L then")
w("\t\tlocal k = 1")
w("\t\twhile k <= L.n do")
w("\t\t\tlocal it = L[k]")
w("\t\t\tif it.cv == 0 or PTNV_Bit(GetTask(it.cv), it.cb) then")
w("\t\t\t\tlocal e = {}")
w("\t\t\t\te.it = it")
w("\t\t\t\te.have = PTNV_Have(it)")
w("\t\t\t\te.miss = it.n - e.have")
w("\t\t\t\tif e.miss < 0 then e.miss = 0 end")
w("\t\t\t\tif e.miss > 0 then o.kinds = o.kinds + 1 end")
w("\t\t\t\to.tot = o.tot + e.miss")
w("\t\t\t\tn = n + 1")
w("\t\t\t\to[n] = e")
w("\t\t\tend")
w("\t\t\tk = k + 1")
w("\t\tend")
w("\tend")
w("\to.n = n")
w("\treturn o")
w("end")
w("")
w("-- create one piece in the bag; 0 if it does not fit (nothing is dropped on the ground)")
w("function PTNV_GiveOne(it)")
w("\tif it.k == 1 then return AddEventItem(it.g) or 0 end")
w("\tlocal g, d, p, lv = it.g, it.d, it.p, it.lv")
w("\tif it.k == 3 then g, d, p, lv = 6, 1, it.p, 1 end")
w("\tif AddNormalItemPile then return AddNormalItemPile(g, d, p, lv, 0, 0) or 0 end")
w("\t-- fallback (engine without AddNormalItemPile): like PTAdm_GiveTo, only with a free bag cell")
w("\tif CalcFreeItemCellCount() < 1 then return 0 end")
w("\tlocal idx = AddItem(g, d, p, lv, 0, 0)")
w("\tif not idx or idx <= 0 then return 0 end")
w("\tlocal mx = GetMaxStackItem(idx)")
w("\tif mx and mx > 1 then AddItemIDStack(idx) else AddItemID(idx, 0) end")
w("\treturn idx")
w("end")
w("")
# ---------------- custom chains
w("-- ---------------- custom chains (state packed in task variables)")
w("-- Quy Tinh (task 53: GetByte 1 = state, 2 = step 0..35; tower map = floor(step / 6))")
w("function PTNV_X33(camp, lv)")
w("\tlocal v = GetTask(53)")
w("\tif v == 0 then return nil end")
w("\tlocal st = GetByte(v, 1)")
w("\tlocal sp = GetByte(v, 2)")
w("\tlocal tw = PTNV_TW[floor(sp / 6) + 1]")
w("\tif st == 1 then return PTNV_Row(tw, %s, PTNV_X33I(42), 0, 59) end" % L("mang Bạch Linh Phướn tới Phong Ấn Tháp"))
w("\tif st == 2 then return PTNV_Row(tw, %s, PTNV_X33I(43), 1, 59) end" % L("hạ Thiên Cương Tinh cạnh Phong Ấn Tháp"))
w("\tif st == 3 then return PTNV_Row(%d, %s, PTNV_X33I(44), 0, 59) end" % (IDX["duongtien_qt"], L("giao Thiên Cương chân khí cho Dương Tiễn")))
w("\tif st == 0 and sp > 0 and sp < 36 then return PTNV_Row(%d, %s, nil, 0, 59) end" % (IDX["duongtien_qt"], L("nhận lượt Quy Tinh tiếp ở Dương Tiễn")))
w("\treturn nil")
w("end")
w("")
w("function PTNV_X33I(ev)")
w("\tlocal t = {}")
w("\tt.n = 1")
w("\tt[1] = PTNV_It(1, ev, 0, 0, 0, 1, -1, 0, 0, PTNV_EVN[ev])")
w("\treturn t")
w("end")
w("")
w("-- Tham Quan (task 314: 5..51 = field doctor on map 1000 + v, 100 = report to Hoang Thien Hoa)")
w("function PTNV_X36(camp, lv)")
w("\tlocal v = GetTask(314)")
w("\tif v >= 5 and v <= 51 then return PTNV_Row(PTNV_DP[1000 + v], %s, nil, 0, 30) end" % L("tìm Đại Phu dã ngoại ở bản đồ được giao"))
w("\tif v == 100 then return PTNV_Row(%d, %s, nil, 0, 30) end" % (IDX["hoangthienhoa"], L("về báo Hoàng Thiên Hóa (kèm lượng bạc)")))
w("\treturn nil")
w("end")
w("")
w("-- Van chuyen (task 2169 = dest city * 100000 + goods * 1000 + count)")
w("function PTNV_X44(camp, lv)")
w("\tlocal v = GetTask(2169)")
w("\tif v <= 0 then return nil end")
w("\tlocal city = floor(v / 100000)")
w("\tlocal gd = floor(mod(v, 100000) / 1000)")
w("\tlocal cnt = mod(v, 1000)")
w("\tlocal g = PTNV_VCG[gd]")
w("\tlocal t = nil")
w("\tif g and cnt > 0 then")
w("\t\tt = {}")
w("\t\tt.n = 1")
w("\t\tt[1] = PTNV_It(2, 3, g, 0, 0, cnt, 0, 0, 0, PTNV_VCN[gd])")
w("\tend")
w("\treturn PTNV_Row(PTNV_TT[city], %s, t, 0, 10)" % L("giao hàng cho Tạp Thương thành đích"))
w("end")
w("")
w("-- Thi luyen su do (899 Hoang mac, 900 Dong Hai, 901 Hien Vien, 902 Bang Xuyen: 1..5 maze doctor, 6 giver)")
w("function PTNV_X52(camp, lv)")
w("\tlocal k = 1")
w("\twhile k <= 4 do")
w("\t\tlocal v = GetTask(898 + k)")
w("\t\tif v >= 1 and v <= 5 then return PTNV_Row(PTNV_DP[PTNV_TLB[k] + v], %s, nil, 0, 20) end" % L("gặp Đại Phu tầng mê cung (giữ hiệu ứng thí luyện)"))
w("\t\tif v == 6 then return PTNV_Row(PTNV_TLG[k], %s, nil, 0, 20) end" % L("về trả thí luyện"))
w("\t\tk = k + 1")
w("\tend")
w("\treturn nil")
w("end")
w("")
w("-- Giang Son Y Cuu (2355 step, 2356 state 0 accept / 1 fight / 2 report, 2360 = 1 finished)")
w("function PTNV_X70(camp, lv)")
w("\tif GetTask(2360) == 1 then return nil end")
w("\tlocal s = GetTask(2355)")
w("\tlocal st = GetTask(2356)")
w("\tif s < 1 or s > 19 then return nil end")
w("\tif st == 1 then return PTNV_Row(PTNV_GS[s], %s .. s .. %s, nil, 1, 30) end" % (L("bước "), L(": tự hạ quái ở bãi được giao")))
w("\tif st == 2 then return PTNV_Row(%d, %s .. s, nil, 0, 30) end" % (IDX["dukhanh"], L("báo Dư Khánh bước ")))
w("\treturn PTNV_Row(%d, %s .. s, nil, 0, 30)" % (IDX["dukhanh"], L("nhận ở Dư Khánh bước ")))
w("end")
w("")
T2 ={"pagehint": "chọn NPC để dịch chuyển tới ngay cạnh (dấu * = chưa đủ cấp). Cấp hiện tại ",
      "npc": "NPC: ", "kill": "(Bước này cần tự đánh hoặc tự làm.)"}
for k, v in T2.items():
    w("PTNV_T_%s = %s" % (k.upper(), L(v)))
w("")
# ---------------- data
w("function PTNV_Data()")
for k in KEYS:
    d = DF[k]
    lab = d["label"]
    w("\tPTNV_D(%d, %d, %d, %d, %d, %d, %d, %d, %s)   -- %s npc [%d,%d] tier %d" % (
        IDX[k], d["map"], d["x"], d["y"], d["lv"], d["camp"], gate_of(k), 0 if d["map"] in TOWNS else 1, L(lab), k,
        d["nx"], d["ny"], d["tier"]))
for gid, title, keys in GROUPS:
    w("\tPTNV_GN(%d, %s)" % (gid, L(title)))
    ks = sorted(keys.split(), key=lambda k: (DF[k]["lv"], asc(DF[k]["label"])))
    for k in ks:
        w("\tPTNV_M(%d, %d)" % (gid, IDX[k]))
for c in ORDER:
    fn = CUSTOM.get(c)
    w("\tPTNV_C(%d, %s, %s)" % (c, L(CHT[c]), ('"%s"' % fn) if fn else "nil"))
for r in chains.ROWS:
    w("\tPTNV_R(%d, %d, %d, %d, %d, %d, %d, %d, %s, %s, %d, %d, %d, %d, %d, %d)" % (
        r["c"], r["var"], r["lo"], r["hi"], r["camp"], r["lv"], r["st"], r["lvmax"],
        str(IDX[r["dest"]]) if r["dest"] else "nil", L(r["txt"]), r["set"], r["v2"], r["lo2"], r["hi2"], r["cond"],
        r["kill"]))
for items, sid in sorted(SETS.items(), key=lambda x: x[1]):
    for it in items:
        tag, k, g, d, p, lv, cnt, cv, cb, name, cl = it
        w("\tPTNV_I(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %s)" % (sid, k, g, d, p, lv, cnt, cl, cv, cb, LB(item_name(it))))
w("\tPTNV_EVN = {}")
for ev in (42, 43, 44):
    w("\tPTNV_EVN[%d] = %s" % (ev, LB(NAMES.get((4, ev, 0)) or tcvn(chains.EVN[ev]))))
w("\tPTNV_VCG = {}")
w("\tPTNV_VCN = {}")
for gd, mat in ((1, 4), (2, 2), (3, 1), (4, 5), (5, 0)):
    w("\tPTNV_VCG[%d] = %d" % (gd, mat))
    w("\tPTNV_VCN[%d] = %s" % (gd, LB(NAMES.get((3, mat, 0)) or tcvn(chains.MAT[mat]))))
for ci, key in ((1, "tt1002"), (2, "tt1003"), (3, "tt1004"), (4, "taphoa_vc"), (5, "tt1021")):
    w("\tPTNV_TT[%d] = %d" % (ci, IDX[key]))
for i, m in enumerate((1006, 1007, 1012, 1013, 1010, 1009), 1):
    w("\tPTNV_TW[%d] = %d" % (i, IDX["tower%d" % m]))
for k in KEYS:
    if k.startswith("dp") and k[2:].isdigit():
        w("\tPTNV_DP[%s] = %d" % (k[2:], IDX[k]))
for s in range(1, 20):
    w("\tPTNV_GS[%d] = %d" % (s, IDX["gs%d" % s]))
w("\tPTNV_TLB = { 1021, 1036, 1026, 1031 }")
w("\tPTNV_TLG = { %d, %d, %d, %d }" % (IDX["thohanhton_tl"], IDX["natra"], IDX["hoangthienhoa_tl"], IDX["duongtien_tl"]))
w("end")
w("")
data = NL.join(o) + NL

# ================================================================== nhiemvu_lenhbai.lua (61430)
MAXP = {}
for gid, title, keys in GROUPS:
    n = len(keys.split())
    p, first = 1, 1
    while n - first + 1 > 5:
        p += 1
        first += 4
    MAXP[gid] = p
MAXA = 40
o = []
w = o.append
w("-- Phong Than \"Lenh Bai Nhiem Vu\" (magicscript %d, 2026-10-04, agent lenhbainv). Permanent, never consumed." % ITEM_NV)
w("-- GENERATED by scratchpad\\lenhbainv\\gen.py - edit the generator. Doc: docs\\features\\lenh-bai-nhiem-vu-phong-than-20261004.md")
w("-- Right click: \"Nhiem vu dang lam\" (chains whose task variables show a step in progress, with the NPC of that step)")
w("-- and 5 groups of quest NPCs (newbie, main story, world, daily, events); choosing one = NewWorld next to the NPC.")
w("-- Data + logic: nhiemvu_data.lua (dofile at call time, cwd = Server; no top-level dofile). Menus <= 7 rows.")
w("")
w("PTNV_NOFN = \"PTNV_No\"")
w("")
w("function PTNV_Load()")
w("\tif PTNV_LOADED then return end")
w("\tdofile(\"script\\\\phongthan\\\\item\\\\nhiemvu_data.lua\")")
w("\tif PTNV_Data then")
w("\t\tPTNV_Data()")
w("\t\tPTNV_LOADED = 1")
w("\tend")
w("end")
w("")
w("function PTNV_No()")
w("end")
w("")
TM = {"title": "<color=yellow>Lệnh Bài Nhiệm Vụ<color>: chọn nhóm nhiệm vụ rồi chọn NPC, lệnh bài đưa bạn tới ngay cạnh NPC đó. Cấp hiện tại ",
      "cur": "Nhiệm vụ đang làm", "none": "<color=yellow>Lệnh Bài Nhiệm Vụ<color>: chưa thấy nhiệm vụ nào đang làm (hoặc đã xong hết các bước có thể nhận biết). Hãy nhận nhiệm vụ ở các NPC trong menu nhóm.",
      "curtitle": "<color=yellow>Nhiệm vụ đang làm<color>: chọn để xem bước hiện tại và dịch chuyển tới NPC cần gặp.",
      "goto": "Dịch chuyển tới ", "nonpc": "Bước này không có NPC cố định để dịch chuyển."}
for k, v in TM.items():
    w("PTNV_TM_%s = %s" % (k.upper(), L(v)))
w("")
w("function PTNV_Main()")
w("\tPTNV_Load()")
w("\tlocal a = PTNV_Active()")
w("\tlocal o = {}")
w("\to[1] = PTNV_TM_CUR .. \" (\" .. a.n .. \")/PTNV_AP1\"")
k = 2
for gid, title, keys in GROUPS:
    w("\to[%d] = PTNV_GR[%d].title .. \"/PTNV_P%d_1\"" % (k, gid, gid))
    k += 1
w("\to[%d] = PTNV_T_CLOSE .. \"/PTNV_No\"" % k)
w("\tPTNV_Say(PTNV_TM_TITLE .. GetLevel() .. \".\", o)")
w("end")
w("")
w("function PTNV_ActPage(p)")
w("\tPTNV_Load()")
w("\tlocal a = PTNV_Active()")
w("\tif a.n == 0 then")
w("\t\tSay(PTNV_TM_NONE, 2, PTNV_T_BACK .. \"/main\", PTNV_T_CLOSE .. \"/PTNV_No\")")
w("\t\treturn")
w("\tend")
w("\tlocal first, last, more = PTNV_Span(a.n, p)")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\tlocal i = first")
w("\twhile i <= last do")
w("\t\tlocal e = a[i]")
w("\t\tlocal s = PTNV_CH[e.c].title .. \": \"")
w("\t\tif e.r.dest and e.r.dest > 0 then s = s .. PTNV_DS[e.r.dest].nm else s = s .. e.r.txt end")
w("\t\tn = n + 1")
w("\t\to[n] = PTNV_Clip(s, 58) .. \"/PTNV_A\" .. i")
w("\t\ti = i + 1")
w("\tend")
w("\tif more then n = n + 1 o[n] = PTNV_T_NEXT .. \"/PTNV_AP\" .. (p + 1) end")
w("\tif p > 1 then n = n + 1 o[n] = PTNV_T_BACK .. \"/PTNV_AP\" .. (p - 1)")
w("\telse n = n + 1 o[n] = PTNV_T_BACK .. \"/main\" end")
w("\tn = n + 1 o[n] = PTNV_T_CLOSE .. \"/PTNV_No\"")
w("\tPTNV_Say(PTNV_TM_CURTITLE, o)")
w("end")
w("")
w("function PTNV_Act(i)")
w("\tPTNV_Load()")
w("\tlocal a = PTNV_Active()")
w("\tlocal e = a[i]")
w("\tif not e then PTNV_ActPage(1) return end")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\tlocal s = PTNV_StepText(e)")
w("\tif e.r.dest and e.r.dest > 0 then")
w("\t\tn = n + 1")
w("\t\to[n] = PTNV_Clip(PTNV_TM_GOTO .. PTNV_DS[e.r.dest].nm, 58) .. \"/PTNV_AG\" .. i")
w("\telse")
w("\t\ts = s .. \" \" .. PTNV_TM_NONPC")
w("\tend")
w("\tn = n + 1 o[n] = PTNV_T_BACK .. \"/PTNV_AP\" .. (floor((i - 1) / 4) + 1)")
w("\tn = n + 1 o[n] = PTNV_T_CLOSE .. \"/PTNV_No\"")
w("\tPTNV_Say(PTNV_Clip(s, 500), o)")
w("end")
w("")
w("function PTNV_ActGo(i)")
w("\tPTNV_Load()")
w("\tlocal a = PTNV_Active()")
w("\tlocal e = a[i]")
w("\tif e and e.r.dest and e.r.dest > 0 then PTNV_Go(e.r.dest) end")
w("end")
w("")
for gid, title, keys in GROUPS:
    for p in range(1, MAXP[gid] + 1):
        w("function PTNV_P%d_%d() PTNV_Load() PTNV_Page(%d, %d) end" % (gid, p, gid, p))
for p in range(1, MAXA // 4 + 2):
    w("function PTNV_AP%d() PTNV_ActPage(%d) end" % (p, p))
for i in range(1, MAXA + 1):
    w("function PTNV_A%d() PTNV_Act(%d) end" % (i, i))
    w("function PTNV_AG%d() PTNV_ActGo(%d) end" % (i, i))
for k in KEYS:
    w("function PTNV_G%d() PTNV_Load() PTNV_Go(%d) end" % (IDX[k], IDX[k]))
w("")
w("function main(nItemIdx)")
w("\tPTNV_Main()")
w("\treturn 0")
w("end")
w("")
nv = NL.join(o) + NL

# ================================================================== tiepte_lenhbai.lua (61431)
o = []
w = o.append
w("-- Phong Than \"Lenh Bai Tiep Te Nhiem Vu\" (magicscript %d, 2026-10-04, agent lenhbainv). Permanent, never consumed." % ITEM_TT)
w("-- GENERATED by scratchpad\\lenhbainv\\gen.py. Doc: docs\\features\\lenh-bai-nhiem-vu-phong-than-20261004.md")
w("-- Right click: the chains in progress (same detection as Lenh Bai Nhiem Vu); choosing one lists the quest items the")
w("-- hand-in script of the current step checks (HaveEventItem / HaveNormalItem / QuestExchange tuples) with the count")
w("-- still missing, and \"Xac nhan\" creates exactly the missing pieces (stacked; nothing dropped on the ground; no money,")
w("-- no rewards). Fight / counter steps cannot be replaced: the token says so and never sets task counters.")
w("")
w("PTNV_NOFN = \"PTTT_No\"")
w("")
w("function PTNV_Load()")
w("\tif PTNV_LOADED then return end")
w("\tdofile(\"script\\\\phongthan\\\\item\\\\nhiemvu_data.lua\")")
w("\tif PTNV_Data then")
w("\t\tPTNV_Data()")
w("\t\tPTNV_LOADED = 1")
w("\tend")
w("end")
w("")
w("function PTTT_No()")
w("end")
w("")
TT = {"title": "<color=yellow>Lệnh Bài Tiếp Tế<color>: chọn nhiệm vụ đang làm để nhận đủ vật phẩm nhiệm vụ còn thiếu của bước hiện tại.",
      "none": "<color=yellow>Lệnh Bài Tiếp Tế<color>: chưa thấy nhiệm vụ nào đang làm. Hãy nhận nhiệm vụ trước (Lệnh Bài Nhiệm Vụ đưa bạn tới NPC).",
      "miss": "thiếu ", "items": " món", "ok": "đủ đồ", "fight": "tự đánh", "noitem": "không cần đồ",
      "have": ": có ", "need": "/cần ", "lack": ", thiếu ",
      "confirm": "Xác nhận nhận đồ còn thiếu", "nothing": "Bước này không cần vật phẩm nhiệm vụ.",
      "allok": "Bạn đã có đủ vật phẩm cho bước này.",
      "room1": "Hành trang cần ít nhất ", "room2": " ô trống (mỗi loại vật phẩm 1 ô), hiện còn ",
      "room3": ". Hãy sắp xếp lại rồi dùng lệnh bài.",
      "got": "Lệnh Bài Tiếp Tế: nhận ", "full": "Hành trang đầy, chưa nhận được ",
      "fail": "Không tạo được vật phẩm ", "done": "Đã phát xong vật phẩm còn thiếu.",
      "killnote": "Bước này cần tự đánh hoặc tự làm (quái, đèn, hộ tống...): lệnh bài không thay được và không đặt biến đếm."}
for k, v in TT.items():
    w("PTTT_T_%s = %s" % (k.upper(), L(v)))
w("")
w("function PTTT_Label(e)")
w("\tlocal s = PTNV_CH[e.c].title .. \": \"")
w("\tlocal nd = PTNV_Need(e.r)")
w("\tif nd.tot > 0 then s = s .. PTTT_T_MISS .. nd.tot .. PTTT_T_ITEMS")
w("\telseif e.r.kill == 1 then s = s .. PTTT_T_FIGHT")
w("\telseif nd.n > 0 then s = s .. PTTT_T_OK")
w("\telse s = s .. PTTT_T_NOITEM end")
w("\treturn s")
w("end")
w("")
w("function PTTT_Page(p)")
w("\tPTNV_Load()")
w("\tlocal a = PTNV_Active()")
w("\tif a.n == 0 then")
w("\t\tSay(PTTT_T_NONE, 1, PTNV_T_CLOSE .. \"/PTTT_No\")")
w("\t\treturn")
w("\tend")
w("\tlocal first, last, more = PTNV_Span(a.n, p)")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\tlocal i = first")
w("\twhile i <= last do")
w("\t\tn = n + 1")
w("\t\to[n] = PTNV_Clip(PTTT_Label(a[i]), 58) .. \"/PTTT_A\" .. i")
w("\t\ti = i + 1")
w("\tend")
w("\tif more then n = n + 1 o[n] = PTNV_T_NEXT .. \"/PTTT_P\" .. (p + 1) end")
w("\tif p > 1 then n = n + 1 o[n] = PTNV_T_BACK .. \"/PTTT_P\" .. (p - 1) end")
w("\tn = n + 1 o[n] = PTNV_T_CLOSE .. \"/PTTT_No\"")
w("\tPTNV_Say(PTTT_T_TITLE, o)")
w("end")
w("")
w("function PTTT_Detail(i)")
w("\tPTNV_Load()")
w("\tlocal a = PTNV_Active()")
w("\tlocal e = a[i]")
w("\tif not e then PTTT_Page(1) return end")
w("\tlocal nd = PTNV_Need(e.r)")
w("\tlocal s = PTNV_StepText(e)")
w("\tlocal k = 1")
w("\twhile k <= nd.n do")
w("\t\tlocal x = nd[k]")
w("\t\ts = s .. \"<enter>- \" .. x.it.nm .. PTTT_T_HAVE .. x.have .. PTTT_T_NEED .. x.it.n")
w("\t\tif x.miss > 0 then s = s .. PTTT_T_LACK .. x.miss end")
w("\t\tk = k + 1")
w("\tend")
w("\tif nd.n == 0 then s = s .. \"<enter>\" .. PTTT_T_NOTHING")
w("\telseif nd.tot == 0 then s = s .. \"<enter>\" .. PTTT_T_ALLOK end")
w("\tlocal o = {}")
w("\tlocal n = 0")
w("\tif nd.tot > 0 then n = n + 1 o[n] = PTTT_T_CONFIRM .. \"/PTTT_OK\" .. i end")
w("\tn = n + 1 o[n] = PTNV_T_BACK .. \"/PTTT_P\" .. (floor((i - 1) / 4) + 1)")
w("\tn = n + 1 o[n] = PTNV_T_CLOSE .. \"/PTTT_No\"")
w("\tPTNV_Say(PTNV_Clip(s, 500), o)")
w("end")
w("")
w("function PTTT_Give(i)")
w("\tPTNV_Load()")
w("\tlocal a = PTNV_Active()")
w("\tlocal e = a[i]")
w("\tif not e then return end")
w("\tlocal nd = PTNV_Need(e.r)")
w("\tif nd.tot == 0 then Msg2Player(PTTT_T_ALLOK) return end")
w("\tlocal free = CalcFreeItemCellCount()")
w("\tif free < nd.kinds then")
w("\t\tSay(PTTT_T_ROOM1 .. nd.kinds .. PTTT_T_ROOM2 .. free .. PTTT_T_ROOM3, 1, PTNV_T_CLOSE .. \"/PTTT_No\")")
w("\t\treturn")
w("\tend")
w("\tlocal k = 1")
w("\tlocal stop = nil")
w("\twhile k <= nd.n and not stop do")
w("\t\tlocal x = nd[k]")
w("\t\tlocal got = 0")
w("\t\twhile got < x.miss and not stop do")
w("\t\t\tif PTNV_GiveOne(x.it) > 0 then got = got + 1 else stop = 1 end")
w("\t\tend")
w("\t\tif got > 0 then Msg2Player(PTTT_T_GOT .. x.it.nm .. \" x\" .. got) end")
w("\t\tif stop then")
w("\t\t\tif CalcFreeItemCellCount() < 1 then Msg2Player(PTTT_T_FULL .. x.it.nm .. \" x\" .. (x.miss - got))")
w("\t\t\telse Msg2Player(PTTT_T_FAIL .. x.it.nm) end")
w("\t\tend")
w("\t\tk = k + 1")
w("\tend")
w("\tif not stop then Msg2Player(PTTT_T_DONE) end")
w("\tif e.r.kill == 1 then Msg2Player(PTTT_T_KILLNOTE) end")
w("end")
w("")
for p in range(1, MAXA // 4 + 2):
    w("function PTTT_P%d() PTTT_Page(%d) end" % (p, p))
for i in range(1, MAXA + 1):
    w("function PTTT_A%d() PTTT_Detail(%d) end" % (i, i))
    w("function PTTT_OK%d() PTTT_Give(%d) end" % (i, i))
w("")
w("function main(nItemIdx)")
w("\tPTTT_Page(1)")
w("\treturn 0")
w("end")
w("")
tt = NL.join(o) + NL

# ================================================================== nhiemvu_give.lua
o = []
w = o.append
w("-- Phong Than 2026-10-04 (agent lenhbainv): give every character one \"Lenh Bai Nhiem Vu\" (magicscript %d, task %d)" % (ITEM_NV, TASK_NV))
w("-- and one \"Lenh Bai Tiep Te Nhiem Vu\" (magicscript %d, task %d). Called once a minute from" % (ITEM_TT, TASK_TT))
w("-- script\\phongthan\\newbie\\starter_gear.lua (PTNB_NvTick, protected by PTAdm_Safe). No main(): dofile'd into the")
w("-- servertimer state. Generated by scratchpad\\lenhbainv\\gen.py. The task is set only once the token exists (given")
w("-- here, or already in bag / box, e.g. from the web admin), so the gift waits for the ptfix row and a free bag cell.")
w("PTNV_GIVE = { { %d, %d }, { %d, %d } }" % (ITEM_NV, TASK_NV, ITEM_TT, TASK_TT))
w("PTNV_GIVE_MSG = { %s, %s }" % (
    L("Bạn nhận được Lệnh Bài Nhiệm Vụ: nhấp phải để chọn nhiệm vụ và dịch chuyển tới ngay cạnh NPC nhận/trả nhiệm vụ. Dùng vĩnh viễn, không mất."),
    L("Bạn nhận được Lệnh Bài Tiếp Tế Nhiệm Vụ: nhấp phải để nhận đủ vật phẩm nhiệm vụ còn thiếu của bước đang làm. Dùng vĩnh viễn, không mất.")))
w("")
w("-- current PlayerIndex: number of tokens given now")
w("function PTNV_GiveOneToken(k)")
w("\tlocal it = PTNV_GIVE[k][1]")
w("\tlocal tk = PTNV_GIVE[k][2]")
w("\tif GetTask(tk) ~= 0 then return 0 end")
w("\tlocal have = HaveNormalItem(6, 1, it, -1)")
w("\tif have and have > 0 then")
w("\t\tSetTask(tk, 1)")
w("\t\treturn 0")
w("\tend")
w("\tlocal r = AddNormalItem(6, 1, it, 1, 0, 0)")
w("\tif r and r > 0 then")
w("\t\tSetTask(tk, 1)")
w("\t\tMsg2Player(PTNV_GIVE_MSG[k])")
w("\t\treturn 1")
w("\tend")
w("\treturn 0")
w("end")
w("")
w("function PTNV_GiveTick()")
w("\tlocal i = 1")
w("\tlocal max = PTADM_MAX_PLAYER or 0")
w("\twhile i <= max do")
w("\t\tPlayerIndex = i")
w("\t\tlocal nm = GetName()")
w("\t\tif nm and nm ~= \"\" then")
w("\t\t\tlocal n = PTNV_GiveOneToken(1) + PTNV_GiveOneToken(2)")
w("\t\t\tif n > 0 and PTAdm_Log then PTAdm_Log(\"lenhbainv\", \"OK\", nm .. \" +\" .. n .. \" Lenh Bai Nhiem Vu/Tiep Te\") end")
w("\t\tend")
w("\t\ti = i + 1")
w("\tend")
w("\tPlayerIndex = nil")
w("end")
w("")
give = NL.join(o) + NL

od = os.path.join(H, "out", "script", "phongthan", "item")
os.makedirs(od, exist_ok=True)
for name, txt in (("nhiemvu_data.lua", data), ("nhiemvu_lenhbai.lua", nv), ("tiepte_lenhbai.lua", tt), ("nhiemvu_give.lua", give)):
    b = txt.encode("ascii")
    open(os.path.join(od, name), "wb").write(b)
    print(name, len(b))
print("dests", len(KEYS), "rows", len(chains.ROWS), "sets", len(SETS), "chains", len(ORDER), "pages", MAXP)
# report table for the doc
rep = []
for gid, title, keys in GROUPS:
    for k in sorted(keys.split(), key=lambda k: (DF[k]["lv"], asc(DF[k]["label"]))):
        d = DF[k]
        rep.append(dict(group=title, key=k, label=d["label"], lv=d["lv"], camp=d["camp"], map=d["map"], nx=d["nx"],
                        ny=d["ny"], x=d["x"], y=d["y"], src=d["src"], tier=d["tier"]))
json.dump(rep, open(os.path.join(H, "menu_table.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=0)
json.dump({k: dict(DF[k], idx=IDX[k], gate=gate_of(k)) for k in KEYS}, open(os.path.join(H, "dest_index.json"), "w",
          encoding="utf-8"), ensure_ascii=False, indent=0)
