# Generates script\phongthan\ext\matdo.lua (ASCII) = header + data (from Npcs.txt) + matdo_body.lua.
# Run: python gen_matdo.py  -> out\matdo.lua
import os
HERE = os.path.dirname(os.path.abspath(__file__))
SRV = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server"
CUR = os.path.join(SRV, r"settings\phongthan\Npcs.txt")
ORIG = r"E:\VL\Phong than\PT\_backup\20261003-respawn\Server\Npcs.txt"   # before the 2026-10-03 halving

def load(p):
    lines = open(p, 'rb').read().split(b'\r\n')
    hdr = [h.strip().decode('latin-1') for h in lines[0].split(b'\t')]
    return hdr, [l.split(b'\t') for l in lines[1:]]

h, R = load(CUR)
hb, RB = load(ORIG)
ci = {c: i for i, c in enumerate(h)}
rf, ki, ai, ca, nm = ci['ReviveFrame'], ci['Kind'], ci['AIMode'], ci['Camp'], ci['Name']

# normal monsters = the selection rule of the 2026-10-03 respawn change (Kind 0, AIMode not 0/6) with the
# original ReviveFrame <= 1080 (bosses revive slower); value = current Npcs.txt ReviveFrame (what Load gives)
RFT = {}
RW = {}
for tid, (a, b) in enumerate(zip(R, RB)):
    if len(b) <= max(rf, ki, ai, ca, nm) or len(a) <= rf: continue
    if b[ki].strip() not in (b'0', b''): continue
    aim = b[ai].strip()
    if aim in (b'', b'0', b'6'): continue
    v = b[rf].strip(); c = a[rf].strip()
    if not v.isdigit() or not c.isdigit(): continue
    if int(v) > 1080: continue
    RFT[tid] = int(c)
    name = a[nm]
    # region seed whitelist: plain field monsters (camp 5, AI 1-5, no colour tag, no quest copy, no bot rows)
    if a[ca].strip() == b'5' and aim in (b'1', b'2', b'3', b'4', b'5') and b'<' not in name \
            and '\u4efb\u52a1'.encode('gbk') not in name and tid < 2700:
        RW[tid] = 1

for t in (10, 11, 12, 15, 18):
    assert t in RW, t

SPAWN_MAPS = [1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1015, 1017, 1018, 1019, 1065,
              1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036,
              1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051,
              1053, 1054, 1055, 1056, 1072, 1077, 1078]
MAPS = [1014, 1016] + SPAWN_MAPS + [1073, 1074, 1075, 1076]
assert len(MAPS) == 57 and len(set(MAPS)) == 57

head = open(os.path.join(HERE, 'matdo_head.lua'), encoding='ascii').read()
body = open(os.path.join(HERE, 'matdo_body.lua'), encoding='ascii').read()
out = [head.rstrip('\n'), '',
       '-- ------------------------------------------------------------------ data (gen_matdo.py)',
       '-- monster maps (= PTBP_MAPS fields of bots\\party.lua): 1014/1016 VNG Region_S, the rest spawn_main.lua',
       'PTMD_MAPS = {}']
for i, m in enumerate(MAPS):
    out.append('PTMD_MAPS[%d] = %d' % (i + 1, m))
out.append('PTMD_REGION = {}')
out.append('PTMD_REGION[1014] = 1')
out.append('PTMD_REGION[1016] = 1')
out.append('-- template (Npcs.txt data row) -> ReviveFrame of the normal monsters (Kind 0, AIMode not 0/6, <= 1080 frames)')
out.append('PTMD_RF = {}')
for t in sorted(RFT):
    out.append('PTMD_RF[%d] = %d' % (t, RFT[t]))
out.append('-- region seed whitelist (camp 5, AI 1-5, no colour tag / quest copy)')
out.append('PTMD_RW = {}')
for t in sorted(RW):
    out.append('PTMD_RW[%d] = 1' % t)
text = '\n'.join(out) + '\n' + body
text.encode('ascii')
os.makedirs(os.path.join(HERE, 'out'), exist_ok=True)
open(os.path.join(HERE, 'out', 'matdo.lua'), 'w', encoding='ascii', newline='\n').write(text)
print('maps', len(MAPS), 'rf', len(RFT), 'rw', len(RW), 'bytes', len(text))
