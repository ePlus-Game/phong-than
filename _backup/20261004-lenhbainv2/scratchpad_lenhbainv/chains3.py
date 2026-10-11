# -*- coding: utf-8 -*-
# lenhbainv2 (2026-10-04): "bai quai" (farm) of every fight step and every step whose quest items drop from monsters
# while that step is open (mob_drop.lua PTDROP_MAT / PTDrop_Special conditions, nb2 counters, daily2/3 spots).
# Exec'd at the end of chains.py after chains2.py (same globals). Farm keys: farms.json (farm.py) via dests3.py.
import json as _json
FARMS = _json.load(open(os.path.join(H, 'farms.json'), encoding='utf-8'))


def _find(c, var, v, extra=None):
    for i, r in enumerate(ROWS):
        if r["c"] == c and r["var"] == var and r["lo"] <= v <= r["hi"] and (extra is None or extra(r)):
            return i
    raise KeyError((c, var, v))


def SETF(c, var, v, farm, extra=None, **kw):
    i = _find(c, var, v, extra)
    ROWS[i]["farm"] = farm
    ROWS[i].update(kw)


def SPLIT(c, var, v, newrows, extra=None):
    """replace the matching row by rows built with R() (collected, then spliced in at its position)"""
    i = _find(c, var, v, extra)
    keep = ROWS[:]
    del ROWS[:]
    for args, kw in newrows:
        R(*args, **kw)
    new = ROWS[:]
    ROWS[:] = keep[:i] + new + keep[i + 1:]


# ---------------- newbie 2004: material drops (mob_drop PTDROP_MAT: task value = the hand-in step)
SETF(3, 21, 3, "f_kiemnhan")
SETF(4, 23, 1, "f_xathan")
SETF(5, 26, 10, "f_kiemnhan")
SETF(5, 26, 11, "f_xathan")
SETF(6, 25, 1, "f_kiemnhantq", txt="lấy 3 mảnh bảo đao từ Kiếm Nhân Tướng Quân ở Yến Sơn, mang tới Triệu Điền")
SETF(7, 24, 2, "f_phanquan")
SETF(9, 11, 2, "f_tuyetquai")
SETF(11, 14, 1, "f_ngoccot")
SETF(12, 13, 1, "f_ngoccot")
SETF(13, 16, 9, "f_ngoccot")
SETF(13, 16, 13, "f_tuyetquai")
SETF(15, 31, 5, "f_hoadien")
SETF(16, 35, 3, "f_thaotien")
SETF(18, 33, 1, "f_cuongdieu")
SETF(19, 36, 8, "f_cuongdieu")
SETF(19, 36, 12, "f_hoadien")
# Thien Thu "tuoi nuoc": the 6 materials drop while task 321 = their detail (PTDROP_MAT {321, j})
for j, f in ((8, "f_cuongdieu"), (9, "f_ngoccot"), (10, "f_kiemnhan"), (11, "f_xathan"), (12, "f_hoadien"), (13, "f_tuyetquai")):
    SETF(21, 321, j, f)

# ---------------- world quests: Con Lon kinh (EV40) drops from Thi Thu (Bich Du 2) while task 50 = 5
SETF(31, 50, 5, "f_thithu")

# ---------------- daily: the game scripts spawn the targets around the player at these fixed points
SD = [k for k in FARMS if k.startswith("sd")]
TCH = sorted(int(k[3:]) for k in FARMS if k.startswith("tch"))
SPLIT(41, 2144, 1, [((41, 2144, (1, 2), "angiao", "tự hạ 5 Ảnh Tử rồi Tinh ở bản đồ được giao"),
                     dict(kill=1, farm="tch%d" % m, v2=2145, lo2=m, hi2=m, m2=10000)) for m in TCH] +
      [((41, 2144, (1, 2), "angiao", "tự hạ Ảnh Tử và Tinh (Ân Giao đưa tới bản đồ)"), dict(kill=1))])
SPLIT(42, 2148, 1, [((42, 2148, 1, "anhong", "siêu độ 3 + 3 oan hồn ở Chiêu Hồn Trận"),
                     dict(kill=1, farm="sd%d" % i, v2=2149, lo2=i, hi2=i)) for i in range(1, len(SD) + 1)] +
      [((42, 2148, 1, "anhong", "siêu độ oan hồn (Ân Hồng đưa tới chỗ)"), dict(kill=1))])
SPLIT(45, 2312, 1, [((45, 2312, 1, "anhong", "siêu độ 3 + 3 oan linh ở Chiêu Hồn Trận"),
                     dict(kill=1, farm="sd%d" % i, v2=2313, lo2=i, hi2=i)) for i in range(1, len(SD) + 1)] +
      [((45, 2312, 1, "anhong", "siêu độ oan linh (Ân Hồng đưa tới chỗ)"), dict(kill=1))])
SPLIT(43, 2152, 1, [((43, 2152, 1, "thuyenphu%d" % (1054 + k), "hút 6 hồn ở đảo được giao"),
                     dict(kill=1, farm="hh%d" % k, v2=2153, lo2=k, hi2=k, m2=10)) for k in (1, 2)] +
      [((43, 2152, 1, "thuyenphu1055", "hút 6 hồn ở đảo (Thuyền Phu)"), dict(kill=1))])
SPLIT(47, 2321, 1, [((47, 2321, 1, "luclam", "phá xe lương ở Tam Sơn"),
                     dict(kill=1, farm="ll%d" % k, v2=2326, lo2=k, hi2=k)) for k in (1, 2, 3)] +
      [((47, 2321, 1, "luclam", "phá xe lương ở Tam Sơn"), dict(kill=1, farm="ll1"))])
# Tru Yeu: target template = task 897 - 1
TYN = {13: "Ngưu Sát", 16: "Dạ Xoa", 17: "Thiên Hao", 18: "Sa Hồn", 20: "Lục Quỷ", 23: "Lão Hồ Lô", 28: "Băng Linh",
       30: "Anh Chiêu Thần"}
for cp in (0, 1, 2):
    vs = "vosu%d" % (1002 + cp)
    SPLIT(51, 898, 1, [((51, 898, (1, 999), vs, "tự hạ %s (giữ hiệu ứng sư môn)" % nm),
                        dict(camp=cp, v2=897, lo2=v, hi2=v, kill=1, farm="f_ty%d" % v)) for v, nm in sorted(TYN.items())] +
          [((51, 898, (1, 999), vs, "tự hạ quái theo yêu cầu của Võ Sư (giữ hiệu ứng sư môn)"),
            dict(camp=cp, v2=897, lo2=1, hi2=999, kill=1))], extra=lambda r, cp=cp: r["camp"] == cp)

# ---------------- Tien Ma 38: 30 monsters of Nguc Phap Son
SETF(60, 2283, 38, "f_tm1075")

# ---------------- Dong Di
SPLIT(53, 597, 2, [((53, 597, 2, "dangthienngoc", "gặp Đặng Thiền Ngọc ở Tam Sơn"), {})])
SPLIT(53, 597, 3, [((53, 597, 3, "dangthienngoc", "về gặp Đặng Thiền Ngọc"), dict(v2=598, lo2=100, hi2=100)),
                   ((53, 597, 3, "dangthienngoc", "hạ Lam Cốt ở Bích Du cho Đặng Thiền Ngọc"), dict(kill=1, farm="dd_f_lamcot"))])
SETF(53, 597, 7, "dd_f_lamcot", txt="nhờ Bá Giám làm Hộ thân phù (Lam Cốt rơi Ngọc Hư phù, Hồng bảo thạch; 10.000 lượng)")
SETF(53, 597, 13, "dd_f_phitho", txt="hạ 10 Phi Thố ở Khai Minh đảo (về bằng Thuyền Phu trên đảo)")
SETF(53, 597, 300, "dd_f_phitho", txt="giao Quả nhân sâm cho Thiếu Nữ Di Tộc (Phi Thố ở Khai Minh đảo rơi)")
SETF(53, 597, 30, "dd_f_phapkhi", txt="mang 7 Mảnh pháp khí tới Yển Bá Ích (Chúc Thần, Thiết Tinh ở Thánh Địa rơi)")
SETF(54, 589, 2, "dd_f_thietcot")
SETF(55, 590, 2, "dd_f_huyetyeu")
SETF(56, 591, 2, "dd_f_thiettinh")
