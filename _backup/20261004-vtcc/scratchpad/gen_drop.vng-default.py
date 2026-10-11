# vtcc (2026-10-04): VNG drop tables of the Van Tien tran bosses / chests as Lua (vt_drop.lua).
# The rebuilt engine never reads the DropRateFile columns of Npcs.txt (only ExecuteScript(m_DropScriptID,"DropRate")),
# so the tien, Thong Thien and Bao ruong of Van Tien tran dropped nothing. This reads, for every template used by
# vt_data.lua (PTVT_D), the VNG pairs (Treasure, DropRateFile) and (Treasure1, DropRateFile1) of
# settings\phongthan\Npcs.txt, parses the VNG ini (\settings\item\droprate\*.ini, server PAK), keeps only the entries
# that can really be created on BOTH sides (server + client tables incl. ptfix) and writes
#   out\script\phongthan\vantien\vt_drop.lua  (ASCII, one statement per record: engine Lua stack 120 slots)
# plus out\drop_report.txt (every entry, kept / skipped and why).
import os, re, sys, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, r"C:\Users\LICHNT~1.OFF\AppData\Local\Temp\claude\D--Project-Email-Send\d0824b0a-6cac-412d-8946-ef7c47e9c425\scratchpad\lenhbainv")
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from pakread import Side
from tcvn import dec

RT = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server"
SIDES = {"Server": Side("Server"), "Client": Side("Client")}
EQUIP_FILE = {0: "MeleeWeapon", 1: "RangeWeapon", 2: "Armor", 3: "Ring", 4: "Amulet", 5: "Boot", 6: "Belt", 7: "Helm",
              8: "Cuff", 9: "Pendant", 10: "Horse"}

# ---------------------------------------------------------------- item tables of both sides
_tab = {}
def table(side, name):
    k = (side, name)
    if k not in _tab:
        b, n = SIDES[side].get("\\settings\\item\\001\\%s.txt" % name)
        rows = []
        if b:
            for l in b.split(b"\r\n")[1:]:
                c = l.split(b"\t")
                if len(c) > 3:
                    rows.append(c)
        _tab[k] = rows
    return _tab[k]

def num(x):
    try: return int(x)
    except Exception: return None

def item_name(g, d, p, lv):
    """name if (g,d,p,lv) exists on both sides, else None (+ reason)."""
    names = []
    for side in SIDES:
        if g == 0:
            rows = [c for c in table(side, EQUIP_FILE.get(d, "?")) if num(c[3]) == p and len(c) > 11 and num(c[11]) == lv]
        elif g == 1:
            rows = [c for c in table(side, "potion") if num(c[2]) == d and (len(c) > 11 and num(c[11]) == lv)]
        elif g == 3:
            rows = [c for c in table(side, "material") if num(c[2]) == d]
        elif g == 6:
            rows = [c for c in table(side, "magicscript") if num(c[2]) == d and num(c[3]) == p]
        elif g == 7:
            rows = [c for c in table(side, "skillbook") if num(c[2]) == d and num(c[3]) == p]
        else:
            rows = []
        if not rows:
            return None, "missing on " + side
        names.append(dec(rows[0][0]).lstrip("#"))
    return names[0], ""

# project bi kip (usable, right click = learn): magicscript 6/1/(62000 + skill), extra_bikip.py
def bikip_row(skill):
    n, why = item_name(6, 1, 62000 + skill, 1)
    return n

# ---------------------------------------------------------------- VNG drop ini
def ini(path):
    b, n = SIDES["Server"].get(path)
    if b is None:
        return None, None
    t = b.decode("latin-1")
    main = dict(re.findall(r"(?m)^(\w+)=(\-?\d+)", t.split("[1]")[0]))
    ents = []
    for s, g, d, p, r in re.findall(r"\[(\d+)\]\s*Genre=(\d+)\s*Detail=(\d+)\s*Particular=(\d+)\s*RandRate=(\d+)", t):
        ents.append((int(s), int(g), int(d), int(p), int(r)))
    return {k: int(v) for k, v in main.items()}, ents

# ---------------------------------------------------------------- templates of PTVT_D
vd = open(os.path.join(RT, "script", "phongthan", "vantien", "vt_data.lua"), encoding="latin-1").read()
tien = sorted({int(x) for blk in re.findall(r"tpl_tien = \{([^}]*)\}", vd) for x in blk.split(",")})
tts = sorted({int(x) for x in re.findall(r"tpl_tt = (\d+)", vd)})
chest = int(re.search(r"PTVT_TPL_CHEST = (\d+)", vd).group(1))
tpls = tien + tts + [chest]
npcs = open(os.path.join(RT, "settings", "phongthan", "Npcs.txt"), "rb").read().split(b"\r\n")
rep = []
files = {}
npc_rows = []
for t in tpls:
    c = npcs[t + 1].split(b"\t")
    tr0, tr1 = num(c[4]) or 0, num(c[5]) or 0
    f0, f1 = c[95].decode("gbk"), c[96].decode("gbk")
    npc_rows.append((t, c[0].decode("gbk"), tr0, f0, tr1, f1))
    for f in (f0, f1):
        if f and f not in files:
            files[f] = None

out_tables = {}
for f in files:
    m, ents = ini(f)
    if m is None:
        rep.append("FILE MISSING %s" % f)
        continue
    rr = m.get("RandRange", 1000000)
    lo, hi = m.get("MinItemLevel", 1), m.get("MaxItemLevel", 1)
    slo, shi = m.get("MinItemLevelScale", 1), m.get("MaxItemLevelScale", 1)
    keep = []
    for s, g, d, p, r in ents:
        if r <= 0:
            rep.append("%s [%d] %d/%d/%d rate 0: never drops (VNG)" % (f, s, g, d, p))
            continue
        if g == 0 or g == 1:
            lvls = []
            for L in range(lo, hi + 1):
                w = slo if hi == lo else int(round(slo + (shi - slo) * (L - lo) / float(hi - lo)))
                if w < 1: w = 1
                n, why = item_name(g, d, p, L)
                if n: lvls.append((L, w, n))
            if not lvls:
                rep.append("%s [%d] %d/%d/%d rate %d SKIPPED: no level %d..%d on both sides" % (f, s, g, d, p, r, lo, hi))
                continue
            keep.append(dict(g=g, d=d, p=p, r=r, lv=[(L, w) for L, w, n in lvls], name=lvls[-1][2]))
            rep.append("%s [%d] %d/%d/%d rate %d levels %s %s" % (f, s, g, d, p, r, [L for L, w, n in lvls], lvls[-1][2]))
        elif g == 7:
            bk = bikip_row(p)
            n7, why = item_name(7, d, p, 1)
            if bk:
                keep.append(dict(g=6, d=1, p=62000 + p, r=r, lv=[(1, 1)], name=bk))
                rep.append("%s [%d] 7/%d/%d (skill %d) rate %d -> usable bi kip 6/1/%d %s" % (f, s, d, p, p, r, 62000 + p, bk))
            elif n7:
                keep.append(dict(g=7, d=d, p=p, r=r, lv=[(1, 1)], name=n7))
                rep.append("%s [%d] 7/%d/%d rate %d VNG skill book kept as is %s" % (f, s, d, p, r, n7))
            else:
                rep.append("%s [%d] 7/%d/%d rate %d SKIPPED: %s" % (f, s, d, p, r, why))
        else:
            n, why = item_name(g, d, p, 1)
            if not n:
                rep.append("%s [%d] %d/%d/%d rate %d SKIPPED: %s" % (f, s, g, d, p, r, why))
                continue
            keep.append(dict(g=g, d=d, p=p, r=r, lv=[(1, 1)], name=n))
            rep.append("%s [%d] %d/%d/%d rate %d %s" % (f, s, g, d, p, r, n))
    out_tables[f] = (rr, keep, sum(e["r"] for e in keep))

# ---------------------------------------------------------------- Lua
def esc(s):
    from tcvn import low
    o = []
    import unicodedata
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128:
            o.append("\\\\" if ch == "\\" else ("\\\"" if ch == '"' else ch))
        elif ch in low: o.append("\\%d" % low[ch])
        elif ch.lower() in low: o.append("\\%d" % low[ch.lower()])
        else: o.append("?")
    return "".join(o)

fid = {}
L = []
w = L.append
w("-- Phong Than 2026-10-04 (agent vtcc): VNG drops of the Van Tien tran tien, Thong Thien and Bao ruong.")
w("-- Generated by scratchpad\\vtcc\\gen_drop.py from settings\\phongthan\\Npcs.txt (Treasure / DropRateFile pairs) and")
w("-- the VNG \\settings\\item\\droprate\\*.ini; only entries that exist on server AND client are kept (drop_report.txt).")
w("-- The engine does not read DropRateFile, so the ActionScripts vt_boss.lua / vt_chest.lua call PTVD_Drop(npc):")
w("-- n rolls per table (n = Treasure for DropRateFile, Treasure1 for DropRateFile1), each roll random(1, RandRange)")
w("-- against the cumulative RandRate; equipment / potion level weighted between MinItemLevel(Scale) and")
w("-- MaxItemLevel(Scale). Items go into the killer's bag (AddNormalItemPile: stacks, nothing on the ground); the")
w("-- special table (DropRateFile1) is given first, a full bag stops the rest. Genre-7 VNG skill books are given as")
w("-- the project's usable bi kip 6/1/(62000 + skill) when that row exists. Do not edit: run the generator.")
w("-- 0 = VNG (the tien roll their special table DropRateFile1 = jiuying.ini Treasure1 = 0 times: no bi kip).")
w("-- n > 0 = non-VNG option: the tien roll that table n times (bi kip he phai, do luc 0/2/3-5, 0/9/3-5, Minh Uyen).")
w("PTVD_FORCE1 = 0")
w("PTVD_T = {}")
w("PTVD_N = {}")
w("")
w("function PTVD_Tab(k, range)")
w("\tlocal t = {}")
w("\tt.range = range")
w("\tt.n = 0")
w("\tPTVD_T[k] = t")
w("end")
w("")
w("-- one entry: genre, detail, particular, rate, name; levels added by PTVD_Lv")
w("function PTVD_Ent(k, g, d, p, r, nm)")
w("\tlocal t = PTVD_T[k]")
w("\tlocal e = {}")
w("\te.g = g")
w("\te.d = d")
w("\te.p = p")
w("\te.r = r")
w("\te.nm = nm")
w("\te.lv = {}")
w("\te.lw = 0")
w("\te.pri = 0")
w("\tif g == 0 and d ~= 4 and p <= 3 then e.pri = 1 end   -- plain white gear of the generic boss table: given last")
w("\tt.n = t.n + 1")
w("\tt[t.n] = e")
w("end")
w("")
w("function PTVD_Lv(k, lv, wt)")
w("\tlocal t = PTVD_T[k]")
w("\tlocal e = t[t.n]")
w("\ttinsert(e.lv, { lv, wt })")
w("\te.lw = e.lw + wt")
w("end")
w("")
w("-- template: rolls of the main table, its key, rolls of the special table, its key")
w("function PTVD_Npc(tpl, n0, k0, n1, k1)")
w("\tlocal o = {}")
w("\to.n0 = n0")
w("\to.k0 = k0")
w("\to.n1 = n1")
w("\to.k1 = k1")
w("\tPTVD_N[tpl] = o")
w("end")
w("")
k = 0
for f, (rr, keep, tot) in out_tables.items():
    k += 1
    fid[f] = k
    w("-- %s: RandRange %d, kept rate sum %d (%.1f%% per roll)" % (f.split("\\")[-1], rr, tot, 100.0 * tot / rr))
    w("PTVD_Tab(%d, %d)" % (k, rr))
    for e in keep:
        w("PTVD_Ent(%d, %d, %d, %d, %d, \"%s\")" % (k, e["g"], e["d"], e["p"], e["r"], esc(e["name"])))
        for lv, wt in e["lv"]:
            w("PTVD_Lv(%d, %d, %d)" % (k, lv, wt))
for t, nm, tr0, f0, tr1, f1 in npc_rows:
    w("PTVD_Npc(%d, %d, %d, %d, %d)   -- %s: %s x%d, %s x%d" % (t, tr0 if f0 in fid else 0, fid.get(f0, 0), tr1 if f1 in fid else 0,
                                                         fid.get(f1, 0), "tpl", f0.split("\\")[-1], tr0, f1.split("\\")[-1], tr1))
w("")
w(r'''-- level of entry e (weighted)
function PTVD_PickLv(e)
	local n = getn(e.lv)
	if n <= 1 then return e.lv[1][1] end
	local r = random(1, e.lw)
	local i = 1
	while i <= n do
		r = r - e.lv[i][2]
		if r <= 0 then return e.lv[i][1] end
		i = i + 1
	end
	return e.lv[n][1]
end

-- n rolls of table k: picked entries appended to out
function PTVD_Roll(k, n, out)
	local t = PTVD_T[k]
	if not t or n <= 0 then return end
	local j = 1
	while j <= n do
		local r = random(1, t.range)
		local i = 1
		while i <= t.n do
			r = r - t[i].r
			if r <= 0 then
				tinsert(out, t[i])
				i = t.n
			end
			i = i + 1
		end
		j = j + 1
	end
end

-- create one item in the current player's bag; 1 = given, 0 = no room (nothing is dropped on the ground)
function PTVD_GiveOne(e)
	local lv = PTVD_PickLv(e)
	local se = 0
	if e.g == 0 then se = random(0, 4) end
	local r = AddNormalItemPile(e.g, e.d, e.p, lv, se, 0)
	if r and r > 0 then return 1 end
	return 0
end

-- VNG drop of NPC ni for the current player (the killer); returns given, lost
function PTVD_Drop(ni)
	local o = PTVD_N[GetNpcTemplateID(ni)]
	if not o or not AddNormalItemPile then return 0, 0 end
	local list = {}
	local n1 = o.n1
	if n1 == 0 and PTVD_FORCE1 > 0 and o.k1 > 0 then n1 = PTVD_FORCE1 end
	PTVD_Roll(o.k1, n1, list)
	PTVD_Roll(o.k0, o.n0, list)
	local got = 0
	local lost = 0
	local names = ""
	local pass = 0
	while pass <= 1 do
		local i = 1
		while list[i] do
			if list[i].pri == pass then
				if lost == 0 and PTVD_GiveOne(list[i]) == 1 then
					got = got + 1
					if got <= 6 then names = names .. ", " .. list[i].nm end
				else
					lost = lost + 1
				end
			end
			i = i + 1
		end
		pass = pass + 1
	end
	if got > 0 then
		local s = "%(GOT1)s" .. got .. "%(GOT2)s" .. strsub(names, 3)
		if got > 6 then s = s .. "..." end
		Msg2Player(s .. ".")
	end
	if lost > 0 then Msg2Player("%(LOST1)s" .. lost .. "%(LOST2)s") end
	return got, lost
end
''' % dict(GOT1=esc("Vật phẩm rơi (bảng VNG): nhận "), GOT2=esc(" món: "),
           LOST1=esc("Hành trang đầy: "), LOST2=esc(" vật phẩm rơi không nhận được. Hãy dọn bớt hành trang.")))
od = os.path.join(HERE, "out", "script", "phongthan", "vantien")
os.makedirs(od, exist_ok=True)
data = "\r\n".join(L).replace("\r\n", "\n").replace("\n", "\r\n").encode("ascii")
open(os.path.join(od, "vt_drop.lua"), "wb").write(data)
open(os.path.join(HERE, "out", "drop_report.txt"), "w", encoding="utf-8").write(
    "\n".join(["%d %s Treasure %d %s / Treasure1 %d %s" % r for r in npc_rows] + [""] + rep) + "\n")
print("vt_drop.lua", len(data), "tables", len(out_tables), "templates", len(npc_rows))
for f, (rr, keep, tot) in out_tables.items():
    print(f, len(keep), "entries, %.1f%% per roll" % (100.0 * tot / rr))
