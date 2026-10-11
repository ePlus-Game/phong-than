# Coordinator 2026-10-03: servertimer PTADM_NPC_SPAWN rows keep GBK names (garbled in the TCVN3 client) and
# EnsureNpcs checks GetNpcName == that name, so ext\npcnames.lua must not rename them. Fix at the source:
# give those spawn rows the Vietnamese (TCVN3) name, and put the same name as label (f[3]) in the matching
# PTADM_NPC_FIX row so PTAdm_FixNpcScripts still binds the script. Also writes a hot-patch for the running
# server (pending.lua) that updates the in-memory tables and the live NPC names.
import re, os, json, sys, unicodedata, shutil
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low as _low
HERE = os.path.dirname(os.path.abspath(__file__))
VN = json.load(open(os.path.join(HERE, "vn_names.json"), encoding="utf-8"))
def tcvn(s):
    o = bytearray()
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128: o.append(ord(ch))
        elif ch in _low: o.append(_low[ch])
        elif ch.lower() in _low: o.append(_low[ch.lower()])
        else: raise ValueError(ch)
    return bytes(o)
def esc(b):
    return "".join(chr(c) if 32 <= c < 127 and chr(c) not in '"\\' else "\\%d" % c for c in b)

ST = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\servertimer.lua"
raw = open(ST, "rb").read().decode("latin-1")
fix = re.findall(r'\{ *(\d{4}), *"([^"]*)", *"([^"]*)", *"([^"]*)" *\}', raw)
label = {}
for m, g, l, sc in fix:
    label.setdefault((m, g), l)
spawn_re = re.compile(r'(\{ *(\d{4}), *(\d+), *(\d+), *(\d+), *(\d+), *")([^"]*)(")')
changes = []
def sub_spawn(mo):
    m, g = mo.group(2), mo.group(7)
    l = label.get((m, g))
    if l and l in VN:
        n = esc(tcvn(VN[l]))
        changes.append((m, g, n, l))
        return mo.group(1) + n + mo.group(8)
    return mo.group(0)
new = spawn_re.sub(sub_spawn, raw)
done = set((m, g) for m, g, n, l in changes)
def sub_fix(mo):
    m, g, l = mo.group(2), mo.group(3), mo.group(4)
    if (m, g) in done and l in VN:
        return mo.group(1) + esc(tcvn(VN[l])) + mo.group(5)
    return mo.group(0)
new = re.sub(r'(\{ *(\d{4}), *"([^"]*)", *")([^"]*)(", *"[^"]*" *\})', sub_fix, new)
if new != raw:
    bk = r"E:\VL\Phong than\PT\_backup\20261003-npcnames"
    shutil.copy2(ST, os.path.join(bk, "servertimer_before_spawnnames.lua"))
    open(ST, "wb").write(new.encode("latin-1"))
uniq = sorted(set(changes))
print("spawn rows renamed:", len(changes), sorted(set(l for m, g, n, l in changes)))

lua = ['-- coordinator 2026-10-03: hot-apply Vietnamese names to servertimer-spawned NPCs',
       'PTSNFIX = {'] + ['\t{ %s, "%s", "%s" },' % (m, g, n) for m, g, n, l in uniq] + ['}',
       'local nrow = 0',
       'local k = 1',
       'while PTADM_NPC_SPAWN[k] do',
       '\tlocal s = PTADM_NPC_SPAWN[k]',
       '\tlocal j = 1',
       '\twhile PTSNFIX[j] do',
       '\t\tlocal f = PTSNFIX[j]',
       '\t\tif s[1] == f[1] and s[6] == f[2] then',
       '\t\t\ts[6] = f[3]',
       '\t\t\tlocal ni = PTADM_SPAWNED and PTADM_SPAWNED[k]',
       '\t\t\tif ni and ni > 0 and GetNpcName(ni) == f[2] then SetNpcName(ni, f[3]) end',
       '\t\t\tnrow = nrow + 1',
       '\t\tend',
       '\t\tj = j + 1',
       '\tend',
       '\tk = k + 1',
       'end',
       'k = 1',
       'while PTADM_NPC_FIX[k] do',
       '\tlocal r = PTADM_NPC_FIX[k]',
       '\tlocal j = 1',
       '\twhile PTSNFIX[j] do',
       '\t\tif r[1] == PTSNFIX[j][1] and r[2] == PTSNFIX[j][2] then r[3] = PTSNFIX[j][3] end',
       '\t\tj = j + 1',
       '\tend',
       '\tk = k + 1',
       'end',
       'PTNN_ROWS = nil',
       'dofile("script\\\\phongthan\\\\ext\\\\npcnames.lua")',
       'dofile("script\\\\phongthan\\\\lib\\\\pt_npcalias.lua")',
       'PTAdm_Log("spawnnames_fix", "OK", "spawn rows=" .. nrow)']
open(os.path.join(HERE, "hot_spawnnames.lua"), "wb").write("\r\n".join(lua).encode("latin-1"))
