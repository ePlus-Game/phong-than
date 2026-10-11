# Coordinator 2026-10-03: map NPCs restored from VNG regions keep their GBK names, which the
# TCVN3 client font renders as garbage ("Ã‰Ã™ÃªÂ»ÃÂ¼ÃŒÃš"), so players cannot find quest NPCs such as the
# Xi Vuu newbie totems. Generate ext\npcnames.lua: renames every PTADM_NPC_FIX NPC whose name is
# the GBK one to a Vietnamese (TCVN3) name and binds its script (PTAdm_FixNpcScripts matches the
# GBK name or the ASCII label, so after a rename it no longer finds the NPC: we bind it ourselves).
import re, sys, os, unicodedata
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low as _low

def tcvn(s):
    o = bytearray()
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128: o.append(ord(ch))
        elif ch in _low: o.append(_low[ch])
        elif ch.lower() in _low: o.append(_low[ch.lower()])
        else: raise ValueError(ch)
    return bytes(o)

import json
VN = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "vn_names.json"), encoding="utf-8"))

st = open(r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\servertimer.lua", "rb").read().decode("latin-1")
rows = re.findall(r'\{ *(\d{4}), *"([^"]*)", *"([^"]*)", *"([^"]*)" *\}', st)
def lua_unesc(s):
    return re.sub(r'\\(\d{1,3})', lambda m: chr(int(m.group(1))), s).replace('\\\\', '\\')
def esc(b):
    return "".join(chr(c) if 32 <= c < 127 and chr(c) not in '"\\' else "\\%d" % c for c in b)
# names that other features use to track their own NPCs (alive checks by name) must not change
import glob
others = ""
for fp in glob.glob(r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan\**\*.lua", recursive=True):
    if fp.lower().endswith("npcnames.lua") or "\\newbie2\\" in fp.lower() or fp.lower().endswith("pt_npcalias.lua"): continue
    others += open(fp, "rb").read().decode("latin-1")
skipped = []
# names spawned and alive-checked by servertimer PTADM_NPC_SPAWN / PTADM_MOB_SPAWN (EnsureNpcs compares GetNpcName)
spawnnames = set(re.findall(r'\{ *\d{4}, *\d+, *\d+, *\d+, *\d+, *"([^"]*)"', st))
# content 2026-10-04 (D6): Sung Thanh (1002) region NPCs that still showed GBK names.
#  FORCE: (map, gbk) FIX rows renamed although the GBK name occurs in another feature's file - audited: the Thu Kho
#         GBK name only appears inside script PATHS there (ext\tienma.lua PTTM_P(...)), never in a name test.
#  EXTRA: region NPCs without a PTADM_NPC_FIX row (map, gbk, label, script or ""): renamed only, the script they
#         already run is kept (the tick binds a script only when the row has one).
#         Tap Hoa 1002: keeps its VNG region script (Sale 5). Sinh hoat teacher (Dai Doanh) 1002 ran the ASCII
#         placeholder npc_restore\1002_18.lua: bound to sinhhoat\sh_master.lua (what the ptfix forwarder of its VNG
#         path intended). Its label differs from the sinhhoat "Sinh Hoat Su" so PTAdm_FixNpcScripts / sinhhoat never mix
#         them up. D5: Nhi Lang Than (1052, VNG region NPC tpl 223, already placed - no spawn) -> npc_fix\1052_nhi_lang_than.lua
#         (the VNG script tested GetItemCount(39) = genre 39, always 0).
#  The camel (PTADM_NPC_SPAWN, alive-checked by name) is NOT renamed here: ext\noidung.lua renames it together with
#  its in-memory spawn row, so PTAdm_EnsureNpcs never sees a missing NPC (no duplicate).
FORCE = {("1002", "\\178\\214\\191\\226\\185\\220\\192\\237\\212\\177")}
EXTRA = [
    ("1002", "\\212\\211\\187\\245\\201\\204", "Tap Hoa Thuong Nhan", ""),
    ("1002", "\\201\\250\\187\\238\\188\\188\\196\\220\\192\\207\\202\\166\\163\\168\\180\\243\\211\\170\\163\\169", "Sinh Hoat Su Dai Doanh", "\\\\script\\\\phongthan\\\\sinhhoat\\\\sh_master.lua"),
    ("1052", "\\182\\254\\192\\201\\201\\241", "Nhi Lang Than", "\\\\script\\\\phongthan\\\\npc_fix\\\\1052_nhi_lang_than.lua"),
]
rows = rows + EXTRA
alias = []
out = []
for mp, gbk, label, script in rows:
    g = lua_unesc(gbk)
    if all(ord(c) < 128 for c in g):
        continue                      # ASCII names (gates) already readable
    if (gbk in others or gbk in spawnnames) and (mp, gbk) not in FORCE and (mp, gbk, label, script) not in EXTRA:
        skipped.append(label); continue
    if label in VN:
        name = tcvn(VN[label])
    elif any(ord(c) >= 128 for c in lua_unesc(label)):
        name = lua_unesc(label).encode("latin-1")   # label is already TCVN3
    else:
        name = label.encode("ascii")
    if script:
        out.append('{ %s, "%s", "%s", "%s" },' % (mp, gbk, esc(name), script))
    else:
        out.append('{ %s, "%s", "%s" },' % (mp, gbk, esc(name)))   # content D6: rename only, keep the NPC's script
    alias.append('PTNN_ALIAS["%s"] = "%s"' % (esc(name), gbk))

# taphoa 2026-10-03: the alias must cover EVERY Vietnamese name an NPC of PTADM_NPC_FIX can carry, not only
# the rows renamed above. mk_spawnnames.py gives the PTADM_NPC_SPAWN rows (Thu Kho, Tho Dong, Dai Phu, Tap Hoa,
# Bao Thuong...) a TCVN3 name and puts the same name in f[3] of the FIX row; those GBK names are skipped above
# ("others" / spawn names), so they had no alias and newbie2 (PTNB2_ScanNpcs, GBK names in nb2_data.lua) lost
# Thu Kho / Tho Dong of 1003/1004 (quests 896, 897, 1000, 1001). Add every FIX row whose label is TCVN3.
amap = {}
order = []
conflicts = []
for line in alias:
    k, v = re.match(r'PTNN_ALIAS\["([^"]*)"\] = "([^"]*)"', line).groups()
    if k not in amap:
        amap[k] = v; order.append(k)
    elif amap[k] != v:
        conflicts.append((k, amap[k], v))
for mp, gbk, label, script in rows:
    g = lua_unesc(gbk)
    l = lua_unesc(label)
    if all(ord(c) < 128 for c in g) or all(ord(c) < 128 for c in l) or l == g:
        continue                      # gates (ASCII GBK field) / ASCII labels: no NPC carries them as a TCVN3 name
    k = esc(l.encode("latin-1"))
    if k not in amap:
        amap[k] = gbk; order.append(k)
    elif amap[k] != gbk:
        conflicts.append((k, amap[k], gbk))
alias = ['PTNN_ALIAS["%s"] = "%s"' % (k, amap[k]) for k in order]
if conflicts:
    print("ALIAS CONFLICTS (first GBK kept):", conflicts)

lua = [
 "-- Generated by scratchpad\\npcnames\\gen_npcnames.py (coordinator 2026-10-03).",
 "-- Renames PTADM_NPC_FIX NPCs that still carry GBK names (unreadable in the TCVN3 client) and binds",
 "-- their script, since PTAdm_FixNpcScripts no longer matches them by name afterwards.",
 "PTNN_ROWS = {",
] + ["\t" + r for r in out] + [
 "}",
 "",
 "function PTEXT_npcnames_Tick()",
 "\tlocal maxn = PTADM_MAX_NPC or 48000",
 "\tlocal i = 1",
 "\twhile i < maxn do",
 "\t\tlocal nm = GetNpcName(i)",
 "\t\tif nm and nm ~= \"\" then",
 "\t\t\tlocal k = 1",
 "\t\t\twhile PTNN_ROWS[k] do",
 "\t\t\t\tlocal r = PTNN_ROWS[k]",
 "\t\t\t\tif nm == r[2] then",
 "\t\t\t\t\tlocal w = GetNpcPos(i)",
 "\t\t\t\t\tif w == r[1] then",
 "\t\t\t\t\t\tif r[4] then SetNpcScript(i, r[4]) end",
 "\t\t\t\t\t\tSetNpcName(i, r[3])",
 "\t\t\t\t\tend",
 "\t\t\t\tend",
 "\t\t\t\tk = k + 1",
 "\t\t\tend",
 "\t\tend",
 "\t\ti = i + 1",
 "\tend",
 "end",
 "",
]
# content 2026-10-04: NPCNAMES_OUT=<dir> writes ext\npcnames.lua / lib\pt_npcalias.lua there (dry run, diff first)
_out = os.environ.get("NPCNAMES_OUT")
_base = _out if _out else r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan"
if _out:
    os.makedirs(os.path.join(_out, "ext"), exist_ok=True); os.makedirs(os.path.join(_out, "lib"), exist_ok=True)
dst = os.path.join(_base, "ext", "npcnames.lua")
open(dst, "wb").write(("\r\n".join(lua)).encode("latin-1"))
al = os.path.join(_base, "lib", "pt_npcalias.lua")
open(al, "wb").write(("\r\n".join(["-- Generated by scratchpad\\npcnames\\gen_npcnames.py: Vietnamese (TCVN3) NPC name -> original GBK name.", "-- Covers the rows renamed by ext\\npcnames.lua and every PTADM_NPC_FIX label that is TCVN3 (servertimer spawns", "-- those NPCs with that name). Used by newbie2\\nb2_lib.lua PTNB2_ScanNpcs (quest targets are GBK names).", "PTNN_ALIAS = {}"] + alias) + "\r\n").encode("latin-1"))
print("rows", len(out), "->", dst); print("skipped (used by other features):", skipped)
print("alias", len(alias), "->", al)

