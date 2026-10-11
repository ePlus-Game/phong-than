# -*- coding: utf-8 -*-
# lenhbainv2 (2026-10-04): "bai quai" destinations for every fight / monster-drop step of Lenh Bai Nhiem Vu.
# Monster positions: script\phongthan\spawn\spawn_<map>.lua (PT_SPAWN_DATA + PT_SPAWN_SPECIAL rows
# {template (Npcs.txt row, 0-based), level, mpsX, mpsY}; servertimer spawns both) + the live dump (npcs_live.txt:
# region monsters of 1014 / 1016, PTADM_MOB_SPAWN). Centre = monster of the wanted templates with the most monsters of
# those templates within 20 cells (lowest level band first when several maps are allowed); arrival cell 3-7 cells
# from that monster, walkable with its 8 neighbours (cells.py). Fixed points (daily2/3 spots chosen by the game
# scripts themselves) are checked with radius 0-4.  Output: farms.json (read by dests3.py).
import os, re, sys, json, collections
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
import cells
R = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan"

MOBS = collections.defaultdict(list)       # map -> [(tpl, lv, cx, cy)]
for fn in os.listdir(os.path.join(R, "spawn")):
    m = re.match(r"spawn_(\d{4})\.lua$", fn)
    if not m:
        continue
    mid = int(m.group(1))
    t = open(os.path.join(R, "spawn", fn), "rb").read().decode("latin-1")
    for a, l, x, y in re.findall(r"\{(\d+),(\d+),(\d+),(\d+)\}", t):
        MOBS[mid].append((int(a), int(l), int(x) // 32, int(y) // 32))
for l in open(os.path.join(H, "npcs_live.txt"), "rb").read().split(b"\n"):
    c = l.rstrip(b"\r").split(b"\t")
    if len(c) < 7:
        continue
    t, mid, x, y, lv = int(c[1]), int(c[2]), int(c[3]), int(c[4]), int(c[5])
    if lv > 1 and t >= 0:
        MOBS[mid].append((t, lv, x, y))

ALLNPC = collections.defaultdict(list)
for l in open(os.path.join(H, "npcs_live.txt"), "rb").read().split(b"\n"):
    c = l.rstrip(b"\r").split(b"\t")
    if len(c) >= 7:
        ALLNPC[int(c[2])].append((int(c[3]), int(c[4])))


def best_center(tpls, maps, maxlv=999):
    best = None
    for mid in maps:
        pts = [(x, y, lv) for (t, lv, x, y) in MOBS.get(mid, []) if (tpls is None or t in tpls) and lv <= maxlv]
        for (x, y, lv) in pts:
            n = sum(1 for (a, b, _) in pts if (a - x) ** 2 + (b - y) ** 2 <= 400)
            key = (n, -lv)
            if best is None or key > best[0]:
                best = (key, mid, x, y, n, lv)
    return best


def farm(tpls, maps, maxlv=999):
    b = best_center(tpls, maps, maxlv)
    if not b:
        return None
    _, mid, x, y, n, lv = b
    occ = [(p[2], p[3]) for p in MOBS[mid]] + ALLNPC[mid]
    r = cells.pick(mid, x, y, occ, rmin=3, rmax=7, prefer=4)
    if not r:
        return None
    return dict(map=mid, nx=x, ny=y, x=r[0], y=r[1], dist=r[2], tier=r[4], cluster=n, mlv=lv,
                tpls=sorted(tpls) if tpls else None)


def fixed(mid, x, y):
    r = cells.pick(mid, x, y, ALLNPC[mid], rmin=0, rmax=4, prefer=0)
    if not r:
        return None
    return dict(map=mid, nx=x, ny=y, x=r[0], y=r[1], dist=r[2], tier=r[4], cluster=0, mlv=0, tpls=None)


# key: (label, level, templates or None = any monster of the map, maps, maxlv)
SPEC = [
    ("f_kiemnhan", "Bãi Kiếm Nhân (Sùng Thành dã ngoại)", 1, [0], [1005], 999),
    ("f_xathan", "Bãi Xà Thần (Bắc Hải)", 5, [3], [1006], 999),
    ("f_tuyetquai", "Bãi Tuyết Quái (Chân núi Côn Lôn)", 1, [1], [1008], 999),
    ("f_hoadien", "Bãi Hỏa Diện (Cự Lộc)", 1, [2], [1013], 999),
    ("f_banglang", "Bãi Băng Lang", 7, [4], [1008, 1009, 1010], 999),
    ("f_ngoccot", "Bãi Băng Lang, Yểm Hỏa", 7, [4, 8], [1008, 1009, 1010], 999),
    ("f_cuongdieu", "Bãi Cuồng Điêu (Du Hồn)", 7, [6], [1011], 999),
    ("f_lucquai", "Bãi Lục Quái", 8, [5], [1013, 1011], 999),
    ("f_hoancau1007", "Bãi Hoàn Cẩu (Yến Sơn)", 12, [7], [1007], 999),
    ("f_kiemnhantq", "Kiếm Nhân Tướng Quân (Yến Sơn)", 7, [102], [1007], 999),
    ("f_phanquan", "Phản Quân Đội Trưởng (Yến Sơn)", 12, [101], [1007], 999),
    ("f_thaotien", "Thảo Tiên Bà Bà (Miêu Cương)", 7, [105], [1012], 999),
    ("f_giapcot", "Bãi Giáp Cốt, Hoàn Cẩu (Mạnh Tân)", 21, [13], [1015], 999),
    ("f_tamson", "Bãi quái Tam Sơn", 22, None, [1016], 40),
    ("f_nguusat1014", "Bãi Ngưu Sát (Đồng Quan)", 21, [12], [1014], 999),
    ("f_duhon", "Bãi quái Du Hồn", 22, None, [1011], 40),
    ("f_manhtan", "Bãi quái Mạnh Tân", 22, None, [1015], 40),
    ("f_kyson", "Bãi quái Kỳ Sơn", 24, None, [1017], 40),
    ("f_thuduong", "Bãi quái Thủ Dương sơn", 22, None, [1010], 40),
    ("f_thithu", "Thi Thú (Bích Du tầng 2)", 57, [114], [1043], 999),
    ("f_tm1075", "Bãi quái Ngục Pháp Sơn", 85, None, [1075], 999),
    ("dd_f_lamcot", "Bãi Lam Cốt (Bích Du)", 70, [44], [1044, 1045, 1047], 999),
    ("dd_f_phitho", "Bãi Phi Thố (Khai Minh đảo)", 70, [421, 422, 423], [1072], 999),
    ("dd_f_thietcot", "Bãi Thiết Cốt (Giai Mộng Quan)", 70, [750, 751], [1073], 999),
    ("dd_f_huyetyeu", "Bãi Huyết Yêu (Giai Mộng Quan)", 70, [747], [1073], 999),
    ("dd_f_thiettinh", "Bãi Thiết Tinh (Thánh Địa)", 70, [930], [1076], 999),
    ("dd_f_phapkhi", "Bãi Chúc Thần, Thiết Tinh (Thánh Địa)", 70, [934, 930], [1076], 999),
]
# Tru Yeu (task 897 = template + 1): field maps 1005-1051 + 1065
TY = {13: "Ngưu Sát", 16: "Dạ Xoa", 17: "Thiên Hao", 18: "Sa Hồn", 20: "Lục Quỷ", 23: "Lão Hồ Lô", 28: "Băng Linh",
      30: "Anh Chiêu Thần"}
FIELD = list(range(1005, 1052)) + [1065]
for v, nm in TY.items():
    SPEC.append(("f_ty%d" % v, "Trừ Yêu - bãi %s" % nm, 20, [v - 1], FIELD, 999))

out = {}
bad = 0
for key, label, lv, tpls, maps, maxlv in SPEC:
    r = farm(set(tpls) if tpls else None, maps, maxlv)
    if not r:
        print("NO FARM", key)
        bad += 1
        continue
    r.update(key=key, label=label, lv=lv, src="spawn_%d.lua%s" % (r["map"], " tpl " + ",".join(map(str, r["tpls"])) if r["tpls"] else " (mọi quái)"))
    out[key] = r
    print("%-16s %d (%d,%d) -> (%d,%d) d%d t%d cluster20=%d lv%d" % (key, r["map"], r["nx"], r["ny"], r["x"], r["y"], r["dist"], r["tier"], r["cluster"], r["mlv"]))

# fixed points chosen by the quest scripts (they spawn the targets around the player there)
d2 = open(os.path.join(R, "daily2", "d2_data.lua"), "rb").read().decode("latin-1")
sd = re.search(r"PTD2_SD_SPOTS = \{(.*?)\n\}", d2, re.S).group(1)
SD = [tuple(map(int, r)) for r in re.findall(r"\{ (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), (\d+) \}", sd)]
for i, s in enumerate(SD, 1):
    r = fixed(s[0], s[3], s[4])
    if not r:
        print("NO SD", i); bad += 1; continue
    r.update(key="sd%d" % i, label="Chiêu Hồn Trận (Siêu Độ, Mã Đế)", lv=20, src="daily2\\d2_data.lua PTD2_SD_SPOTS[%d]" % i)
    out[r["key"]] = r
tch = re.search(r"PTD2_TCH_POS = \{(.*?)\}\s*\n", d2).group(1)
for m, x, y in re.findall(r"\[(\d+)\] = \{ (\d+), (\d+) \}", tch):
    r = fixed(int(m), int(x), int(y))
    if not r:
        print("NO TCH", m); bad += 1; continue
    r.update(key="tch%s" % m, label="Bãi Ảnh Tử (Thiên Cương Hồn)", lv=60, src="daily2\\d2_data.lua PTD2_TCH_POS[%s]" % m)
    out[r["key"]] = r
for i, (m, x, y) in enumerate(((1055, 1720, 3043), (1056, 1577, 3038)), 1):
    r = fixed(m, x, y)
    r.update(key="hh%d" % i, label="Đảo hút hồn (Hấp Hồn)", lv=80, src="daily2\\d2_core.lua PTD2_HH_ISLANDS[%d]" % i)
    out[r["key"]] = r
for i, (x, y) in enumerate(((1401, 3448), (1373, 3495), (1396, 3438)), 1):
    r = fixed(1016, x, y)
    r.update(key="ll%d" % i, label="Chỗ xe lương (Lục Lâm)", lv=20, src="daily3\\d3_core.lua PTD3_LL_SPOTS[%d]" % i)
    out[r["key"]] = r
json.dump(out, open(os.path.join(H, "farms.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=0)
print(len(out), "farm points,", bad, "problems")
