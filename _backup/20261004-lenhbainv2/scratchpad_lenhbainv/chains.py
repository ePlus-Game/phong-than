# -*- coding: utf-8 -*-
# lenhbainv: quest-step table of "Lenh Bai Nhiem Vu" (Nhiem vu dang lam) and "Lenh Bai Tiep Te" (items).
# Every row comes from the hand-in scripts (npc_fix\*.lua, newbie2 data, daily2/3, vanluong, tienma/tienma45,
# vienco gs_data, vantien) read on 2026-10-04 - see docs\features\lenh-bai-nhiem-vu-phong-than-20261004.md.
# Row: R(chain, taskvar, values, dest key or None, text, items, **opts)
#   values: int | (lo, hi) | [list]   camp: -1 all / 0 Giap Si / 1 Dao Si / 2 Di Nhan (GetPlayerType)
#   st=1: "chua nhan" row (value 0) shown only for lv <= player level <= lvmax
#   v2, lo2, hi2: second task condition; cond: 1 Van Tien day valid, 3 task 2283 == 0
#   kill=1: the step is a fight / action counted by the engine or a task counter: no item can replace it
# Items: EV(n, count, name) event item (QuestExchange {4,n,0,0,0,0,c}); NI(g, d, p, lv, count, name) VNG tuple;
#   BK(skill, particular, name) skill book (satisfied when the skill is learnt); cvar/cbit: only when that bit is set
import os, sys, runpy
H = os.path.dirname(os.path.abspath(__file__))
S = os.path.dirname(H)

CH = []          # (id, title)
ROWS = []


def C(cid, title):
    CH.append((cid, title))


def R(c, var, vals, dest, txt, items=None, camp=-1, lv=0, st=0, lvmax=200, v2=0, lo2=0, hi2=0, cond=0, kill=0,
      farm=None, m2=0):
    """farm: "bai quai" destination of the step (lenhbainv2): the target of a kill step, or where the quest items
    of the step drop (used while items are missing). m2 > 0: the second task value is taken modulo m2."""
    if isinstance(vals, int):
        rng = [(vals, vals)]
    elif isinstance(vals, tuple):
        rng = [vals]
    else:
        vs = sorted(vals)
        rng = []
        for v in vs:
            if rng and rng[-1][1] == v - 1:
                rng[-1] = (rng[-1][0], v)
            else:
                rng.append((v, v))
    for lo, hi in rng:
        ROWS.append(dict(c=c, var=var, lo=lo, hi=hi, dest=dest, txt=txt, items=items or [], camp=camp, lv=lv, st=st,
                         lvmax=lvmax, v2=v2, lo2=lo2, hi2=hi2, cond=cond, kill=kill, farm=farm, m2=m2))


def EV(n, cnt, name, cvar=0, cbit=0):
    return ("EV", 1, n, 0, 0, 0, cnt, cvar, cbit, name, -1)


def NI(g, d, p, lv, cnt, name, cl=None):
    """lv = level created, cl = level counted (-1 any; default = lv, like QuestExchange)"""
    return ("NI", 2, g, d, p, lv, cnt, 0, 0, name, lv if cl is None else cl)


def BK(skill, part, name):
    return ("BK", 3, 6, 1, part, skill, 1, 0, 0, name, -1)


def bits_first_missing(base, v, order):
    """bit-mask steps: v = base + sum(bits); first NPC of `order` [(bit, dest)] whose bit is missing"""
    b = v - base
    for bit, dest in order:
        if not (b & bit):
            return dest
    return None


# names of event items (questkey.txt) and genre-3 materials, Vietnamese
EVN = {0: "Thư tiến cử", 1: "Thần Oanh", 2: "Thần Mộc", 3: "An Cư Đồ", 4: "Thần Dư Kinh", 6: "Huyền Nữ binh pháp",
       7: "Huỳnh Đế nội kinh", 8: "Luyện Kim thuật", 9: "Phong Thần bảng", 10: "Trúc giản", 11: "Huyết thư",
       12: "Ấn tín Võ Thành Vương", 13: "Râu Thần Long", 15: "Thiệp mời", 16: "Cạnh tinh rượu", 17: "Phục Thù phù",
       18: "Kim Hà quan", 19: "Ma huyết", 20: "Hỏa thạch", 21: "Lưỡi đao", 22: "Thân đao", 23: "Cán đao",
       24: "Dũng đao", 25: "Cuốc", 26: "Hộp gấm", 27: "Thần Khí", 28: "Mảnh Thần Khí", 29: "Mật thư Thiên Lý Nhãn",
       30: "Thức ăn của Dị nhân", 45: "Gỗ trầm hương", 49: "Mầm cây thần bí", 106: "Mật hàm Đông Di"}


def E(n, cnt=1, cvar=0, cbit=0):
    return EV(n, cnt, EVN.get(n, "Vật phẩm nhiệm vụ %d" % n), cvar, cbit)


MAT = {0: "Thủy tinh", 1: "Lưu huỳnh", 2: "Linh chi", 3: "Đồng thau", 4: "Tơ lụa", 5: "Bì cách", 8: "Hỏa Vũ",
       9: "Ngọc Cốt", 10: "Đoản Kiếm", 11: "Mảnh Giáp", 12: "Mặt Quỷ", 13: "Băng Cơ", 22: "Địa tâm", 23: "Phong lộ",
       24: "Thủy hàn", 25: "Hỏa linh", 29: "Ba Lạc Nhẫn cấp 1", 30: "Ba Lạc Nhẫn cấp 2", 31: "Ba Lạc Nhẫn cấp 3",
       32: "Ba Lạc Nhẫn cấp 4", 33: "Ba Lạc Nhẫn cấp 5", 82: "San thạch", 116: "Đại Địa Nhẫn", 117: "Hoàn Quân Nhẫn",
       118: "Liệt Diễm Nhẫn", 119: "Phong Bạo Nhẫn"}


def M(d, cnt):
    return NI(3, d, 0, 0, cnt, MAT[d])


# ====================================================================== 1. newbie2 (Quan Su), tasks 2180 / 2184
C(1, "Tân thủ mới")
_nb2 = runpy.run_path(os.path.join(S, "newbie2", "gen_nb2.py"), run_name="lenhbainv_import")
NB2Q, NB2CH = _nb2["Q"], _nb2["CHAIN"]
_rawname = {v[1]: k for k, v in _nb2["N"].items()}     # escaped lua literal -> key
NB2DEST = {("taphoa", 1002): "taphoa1002", ("taphoa", 1003): "taphoa1003", ("taphoa", 1004): "taphoa1004",
           ("taphoa", 1020): "taphoa1020", ("taphoa", 1021): "taphoa1021", ("thukho", 1002): "thukho1002",
           ("thukho", 1003): "thukho1003", ("thukho", 1004): "thukho1004", ("toho", 1002): "toho",
           ("lohung", 1002): "lohung", ("trieudien", 1002): "trieudien", ("sul", 1002): "sungungloan",
           ("tuhang", 1003): "tuhang", ("thodong", 1003): "thodong1003", ("thodong", 1004): "thodong1004",
           ("xichtinh", 1003): "xichtinh", ("vantrung", 1003): "vantrung", ("nhiendang", 1003): "nhiendang",
           ("namcuc", 1003): "namcuc", ("thieuhao", 1004): "thieuhao", ("hautho", 1004): "hautho",
           ("chucdung", 1004): "chucdung", ("congcong", 1004): "congcong", ("phongba", 1004): "phongba",
           ("yisheng", 1015): "dpmanhtan", ("shs1002", 1002): "shs1002", ("shs1003", 1003): "shs1003",
           ("shs1004", 1004): "shs1004", ("dpts", 1016): "dptamson", ("dpdq", 1014): "dpdongquan"}
BOOKN = {27: "Tế Huyết Trảm", 3: "Chưởng Tâm Lôi", 450: "Lực Sĩ Tế"}


# lenhbainv2: "bai quai" of the newbie2 fight steps (tids = Npcs.txt rows 0-based, maps from nb2_data / F11)
NB2LAB = {0: "Kiếm Nhân", 1: "Tuyết Quái", 2: "Hỏa Diện", 4: "Băng Lang", 5: "Lục Quái", 7: "Hoàn Cẩu"}
NB2FARM = {(907, 1): "f_kiemnhan", (896, 1): "f_tuyetquai", (1001, 1): "f_hoadien", (902, 1): "f_hoancau1007",
           (913, 1): "f_banglang", (1007, 1): "f_lucquai", (1002, 1): "f_hoadien", (900, 1): "f_giapcot",
           (900, 4): "f_tamson", (900, 7): "f_nguusat1014", (1008, 1): "f_duhon", (899, 1): "f_tamson",
           (899, 4): "f_manhtan", (899, 7): "f_kyson", (899, 9): "f_thuduong"}
NB2CHEST = {0: "f_kiemnhan", 1: "f_tuyetquai", 2: "f_hoadien"}   # chest steps: field map next to the village


def _nb2_go(m, names):
    key = _rawname[names[0][1]]
    return NB2DEST[(key, m)]


for prof, chain in NB2CH.items():
    R(1, 2180, 0, "qs%d" % (1002 + prof), "nhận chuỗi tân thủ mới ở Quân Sư", camp=prof, lv=1, st=1, lvmax=30)
    for i, ent in enumerate(chain, 1):
        qid = ent[0] if isinstance(ent, list) else ent
        q = NB2Q[qid]
        R(1, 2184, 0, "qs%d" % (1002 + prof), "chờ đủ cấp %d để nhận nhiệm vụ kế tiếp" % q["lv"], camp=prof,
          lv=q["lv"], v2=2180, lo2=i, hi2=i)
        for s, st in enumerate(q["s"], 1):
            if st.get("p") is not None and st["p"] != prof:
                continue
            items = []
            kill = 0
            dest = None
            if "go" in st:
                dest = _nb2_go(st["go"][0], st["go"][1])
                txt = "gặp NPC"
                if st.get("book"):
                    sk, part = st["book"]
                    items = [BK(sk, part, "Bí kíp " + BOOKN.get(sk, str(sk)))]
                    txt = "mang bí kíp (đã học) tới NPC"
                if st.get("lv"):
                    txt += " (cần cấp %d)" % st["lv"]
            elif "go2" in st:
                dest = _nb2_go(st["go2"][0][0], st["go2"][0][1])
                txt = "gặp 2 NPC"
            elif "kill" in st:
                kill, txt = 1, "tự đánh %d %s (đếm tự động)" % (st["kill"]["need"], NB2LAB.get(st["kill"]["tids"][0], "quái"))
            elif "chest" in st:
                kill, txt = 1, "ra ngoài thành mở rương, siêu độ 4 Yêu Ma"
            elif "king" in st:
                kill, txt = 1, "đánh %s gọi vương rồi hàng phục" % NB2LAB.get(st["king"]["tid"], "quái")
            elif "coll" in st or "mark" in st:
                kill, txt = 1, "đánh quái thu thập (đếm tự động, không phải vật phẩm)"
            else:
                txt = "làm theo sổ F11"
            farm = NB2FARM.get((qid, s))
            if farm is None and "chest" in st:
                farm = NB2CHEST[prof]
            R(1, 2184, s, dest, txt, items, camp=prof, v2=2180, lo2=i, hi2=i, kill=kill, farm=farm)

# ====================================================================== 2. newbie 2004 (npc_fix 1002/1003/1004)
C(2, "Hộp Gấm")
R(2, 20, 0, "toho", "nhận ở Tô Hộ", camp=0, lv=1, st=1, lvmax=20)
R(2, 20, 1, "thukho1002", "báo Thủ Khố", camp=0)
for v in range(10, 17):
    R(2, 20, v, bits_first_missing(10, v, [(1, "sungungloan"), (2, "trieuloi"), (4, "trieudien")]),
      "báo tin cho Sùng Ứng Loan, Triệu Lôi, Triệu Điền", camp=0)
R(2, 20, 17, "thukho1002", "nhận Hộp gấm ở Thủ Khố", camp=0)
R(2, 20, 18, "toho", "giao Hộp gấm cho Tô Hộ", [E(26)], camp=0)
C(3, "Tân Thức (Sùng Thành)")
R(3, 21, 0, "lohung", "nhận ở Lỗ Hùng", camp=0, lv=3, st=1, lvmax=25)
R(3, 21, 1, "authienhoa", "gặp Âu Thiên Hóa", camp=0)
R(3, 21, 2, "sungungbuu", "gặp Sùng Ứng Bưu", camp=0)
R(3, 21, 3, "authienhoa", "giao 10 Đoản Kiếm (Kiếm Nhân rơi)", [M(10, 10)], camp=0)
R(3, 21, 4, "sunghauho", "gặp Sùng Hầu Hổ", camp=0)
R(3, 21, 5, "lohung", "gặp Lỗ Hùng", camp=0)
R(3, 21, 6, "sunghacho", "gặp Sùng Hắc Hổ", camp=0)
R(3, 21, 7, "authienhoa", "gặp Âu Thiên Hóa", camp=0)
R(3, 21, 8, "lohung", "trả nhiệm vụ ở Lỗ Hùng", camp=0)
C(4, "Mở rương (Sùng Thành)")
R(4, 23, 1, "thukho1002", "giao 5 Mảnh Giáp (Xà Thần rơi)", [M(11, 5)], camp=0)
C(5, "Thu thập Thủ Khố (Sùng Thành)")
R(5, 26, 10, "thukho1002", "giao 10 Đoản Kiếm", [M(10, 10)], camp=0)
R(5, 26, 11, "thukho1002", "giao 10 Mảnh Giáp", [M(11, 10)], camp=0)
C(6, "Dũng Đao")
R(6, 25, 0, "trieudien", "nhận ở Triệu Điền", camp=0, lv=7, st=1, lvmax=25)
R(6, 25, 1, "trieudien", "mang 3 mảnh bảo đao (Kiếm Nhân tướng quân, Yến Sơn)", [E(21), E(22), E(23)], camp=0)
R(6, 25, 2, "authienhoa", "nhờ Âu Thiên Hóa ghép bảo đao", [E(21), E(22), E(23)], camp=0)
R(6, 25, 3, "trieudien", "giao Dũng đao cho Triệu Điền", [E(24)], camp=0)
C(7, "Kiêm Ái")
R(7, 24, 0, "sungungloan", "nhận ở Sùng Ứng Loan", camp=0, lv=12, st=1, lvmax=30)
R(7, 24, 1, "authienhoa", "gặp Âu Thiên Hóa", camp=0)
R(7, 24, 2, None, "tự hạ Phản quân đội trưởng ở Yến Sơn (nhận Cuốc)", camp=0, kill=1)
R(7, 24, 3, "sungungloan", "giao Cuốc cho Sùng Ứng Loan", [E(25)], camp=0)
C(8, "Bách Lý")
R(8, 10, 0, "tuhang", "nhận ở Từ Hàng", camp=1, lv=1, st=1, lvmax=20)
for v in range(1, 15):
    if v % 2 == 1:
        R(8, 10, v, bits_first_missing(1, v, [(2, "linhbao"), (4, "namcuc"), (8, "xichtinh")]),
          "thỉnh giáo Linh Bảo, Nam Cực, Xích Tinh Tử", camp=1)
R(8, 10, 15, "tuhang", "về gặp Từ Hàng", camp=1)
C(9, "Ngũ Thất")
R(9, 11, 0, "namcuc", "nhận ở Nam Cực Tiên Ông", camp=1, lv=3, st=1, lvmax=25)
R(9, 11, 1, "hoanglong_t", "gặp Hoàng Long Chân Nhân", camp=1)
R(9, 11, 2, "namcuc", "giao 10 Băng Cơ (Tuyết Quái rơi)", [M(13, 10)], camp=1)
R(9, 11, 3, "nhiendang", "nhận lửa ở Nhiên Đăng", camp=1)
R(9, 11, 4, "namcuc", "giao Hỏa thạch", [E(20)], camp=1)
C(10, "Khảo nghiệm")
R(10, 15, 0, "vantrung", "nhận ở Vân Trung Tử", camp=1, lv=7, st=1, lvmax=25)
R(10, 15, 1, "linhbao", "trả lời 3 câu đố của Linh Bảo", camp=1)
R(10, 15, 2, "vantrung", "về gặp Vân Trung Tử", camp=1)
R(10, 15, 5, "mob_yemhoa", "hạ Yểm Hỏa ở Thủ Dương Sơn (hoặc Tuyết Nguyên Cự Thú ở Tây Côn Lôn)", camp=1, kill=1)
R(10, 15, 6, "vantrung", "phục mệnh Vân Trung Tử", camp=1)
C(11, "Linh lực")
R(11, 14, 0, "nhiendang", "nhận ở Nhiên Đăng", camp=1, lv=12, st=1, lvmax=30)
R(11, 14, 1, "nhiendang", "giao 10 Ngọc Cốt (Băng Lang, Yểm Hỏa rơi)", [M(9, 10)], camp=1)
C(12, "Mở rương (Ngọc Hư)")
R(12, 13, 1, "thukho1003", "giao 5 Ngọc Cốt", [M(9, 5)], camp=1)
C(13, "Thu thập Thủ Khố (Ngọc Hư)")
R(13, 16, 9, "thukho1003", "giao 10 Ngọc Cốt", [M(9, 10)], camp=1)
R(13, 16, 13, "thukho1003", "giao 10 Băng Cơ", [M(13, 10)], camp=1)
C(14, "Khai Trí")
R(14, 30, 0, "thieuhao", "nhận ở Thiếu Hạo", camp=2, lv=1, st=1, lvmax=20)
for v in range(1, 15):
    if v % 2 == 1:
        R(14, 30, v, bits_first_missing(1, v, [(2, "phongba"), (4, "khoaphu"), (8, "chucdung")]),
          "tìm Phong Bá, Khoa Phụ, Chúc Dung", camp=2)
R(14, 30, 15, "thieuhao", "về gặp Thiếu Hạo", camp=2)
C(15, "Tân Thức (Xi Vưu)")
R(15, 31, 0, "hautho", "nhận ở Hậu Thổ", camp=2, lv=3, st=1, lvmax=25)
R(15, 31, 1, "caogiac", "gặp Cao Giác", camp=2)
R(15, 31, 2, "caominh", "nhận thư ở Cao Minh", camp=2)
R(15, 31, 3, "hinhthien_t", "đưa thư cho Hình Thiên", [E(29)], camp=2)
R(15, 31, 4, "caominh", "về gặp Cao Minh", camp=2)
R(15, 31, 5, "hautho", "giao 10 Mặt Quỷ (Hỏa Diện rơi)", [M(12, 10)], camp=2)
C(16, "Thần Khí")
R(16, 35, 0, "chucdung", "nhận ở Chúc Dung", camp=2, lv=7, st=1, lvmax=25)
R(16, 35, 1, "congcong", "gặp Cộng Công", camp=2)
R(16, 35, 2, "caominh", "gặp Cao Minh", camp=2)
R(16, 35, (3, 5), None, "hạ Thảo Tiên ba ba ở Miêu Cương (mỗi con 1 Mảnh Thần Khí)", camp=2, kill=1)
R(16, 35, 6, "congcong", "giao 3 Mảnh Thần Khí", [E(28, 3)], camp=2)
R(16, 35, 7, "chucdung", "giao Thần Khí cho Chúc Dung", [E(27)], camp=2)
C(17, "Cứu Tế")
R(17, 34, 0, "phongba", "nhận ở Phong Bá", camp=2, lv=12, st=1, lvmax=30)
R(17, 34, 1, "hinhthien_t", "gặp Hình Thiên", camp=2)
# questfix3: steps 2 / 4 at the VNG NPC "Thu linh toc nhan bi mat tich" (Cu Loc [239,192], ext\questfix3.lua)
R(17, 34, 2, "toclinh1013", "gặp Thủ lĩnh tộc nhân mất tích ở Cự Lộc", camp=2)
R(17, 34, 3, "mob_docluc", "hạ Độc Lục quái ở Cự Lộc lấy lại lương thực", camp=2, kill=1)
R(17, 34, 4, "toclinh1013", "mang Thức ăn về cho Thủ lĩnh tộc nhân ở Cự Lộc", [E(30)], camp=2)
R(17, 34, 5, "hinhthien_t", "giao Thức ăn cho Hình Thiên", [E(30)], camp=2)
R(17, 34, 6, "phongba", "về gặp Phong Bá", camp=2)
C(18, "Mở rương (Xi Vưu)")
R(18, 33, 1, "thukho1004", "giao 5 Hỏa Vũ (Cuồng Điêu rơi)", [M(8, 5)], camp=2)
C(19, "Thu thập Thủ Khố (Xi Vưu)")
R(19, 36, 8, "thukho1004", "giao 10 Hỏa Vũ", [M(8, 10)], camp=2)
R(19, 36, 12, "thukho1004", "giao 10 Mặt Quỷ", [M(12, 10)], camp=2)

# ====================================================================== 3. main story (tasks 3 / 1 / 2)
C(20, "Chính tuyến")
G, D, N = 0, 1, 2
VAR = {G: 3, D: 1, N: 2}
R(20, 3, 0, "sunghauho", "nhận chính tuyến ở Sùng Hầu Hổ", camp=G, lv=25, st=1)
R(20, 3, 1, "trinhluan", "gặp Trịnh Luân", camp=G)
R(20, 3, 2, "sunghauho", "giao Huyết thư", [E(11)], camp=G)
R(20, 3, 10, "sunghacho", "gặp Sùng Hắc Hổ", camp=G, lv=35)
R(20, 3, 11, "hoangphiho", "giao Gỗ trầm hương cho Hoàng Phi Hổ", [E(45)], camp=G, lv=35)
R(20, 3, 20, "hoangphiho", "gặp Hoàng Phi Hổ", camp=G, lv=45)
R(20, 3, 21, "lytinh", "báo tin Lý Tĩnh và Đặng Cửu Công", camp=G)
R(20, 3, 22, "dangcuucong", "báo tin Đặng Cửu Công", camp=G)
R(20, 3, 23, "lytinh", "báo tin Lý Tĩnh", camp=G)
R(20, 3, 24, "hoangphiho", "về gặp Hoàng Phi Hổ", camp=G, lv=45)
R(20, 3, 25, "mob_trandien", "hạ Trấn Điện Tướng Quân ở Mục Dã", camp=G, kill=1)
R(20, 3, 26, "hoangphiho", "giao Ấn tín cho Hoàng Phi Hổ", [E(12)], camp=G)
R(20, 3, 27, "khuongtunha", "gặp Khương Tử Nha", camp=G)
R(20, 3, 30, "duongtien", "gặp Dương Tiễn", camp=G, lv=55)
R(20, 3, 31, "mob_donghai", "hạ Đông Hải Thần Long ở Long Cung", camp=G, kill=1)
R(20, 3, 32, "hohymi", "mang Râu Thần Long tới Hồ Hỷ Mị", [E(13)], camp=G, lv=55)
R(20, 1, 0, "hoanglong", "nhận chính tuyến ở Hoàng Long Chân Nhân", camp=D, lv=25, st=1)
R(20, 1, 1, "khuongtunha", "đưa Thư tiến cử cho Khương Tử Nha", [E(0)], camp=D)
R(20, 1, 2, "loichantu", "gặp Lôi Chấn Tử", camp=D, lv=35)
for v in range(10, 17):
    R(20, 1, v, bits_first_missing(10, v, [(1, "hoangphiho"), (2, "lytinh"), (4, "dangcuucong")]),
      "thuyết phục Hoàng Phi Hổ, Lý Tĩnh, Đặng Cửu Công", camp=D)
R(20, 1, 17, "loichantu", "về gặp Lôi Chấn Tử", camp=D)
R(20, 1, 20, "khuongtunha", "gặp Khương Tử Nha", camp=D, lv=45)
R(20, 1, 21, "hoangthienhoa", "gặp Hoàng Thiên Hóa", camp=D, lv=45)
R(20, 1, 22, "mob_bachai", "hạ Bắc Hải Thần Oanh ở Bắc Hải", camp=D, kill=1)
R(20, 1, 23, "thohanhton", "giao Thần Oanh cho Thổ Hành Tôn", [E(1)], camp=D)
R(20, 1, 24, "hoangthienhoa", "về gặp Hoàng Thiên Hóa", camp=D, lv=45)
R(20, 1, 30, "thohanhton", "gặp Thổ Hành Tôn", camp=D, lv=55)
R(20, 1, 31, "hohymi", "gặp Hồ Hỷ Mị", camp=D, lv=55)
R(20, 1, 32, "mob_battu", "hạ Bất Tử Thần Mộc ở Phong Than", camp=D, kill=1)
R(20, 1, 33, "hohymi", "mang Thần Mộc tới Hồ Hỷ Mị", [E(2)], camp=D, lv=55)
R(20, 2, 0, "hinhthien", "nhận chính tuyến ở Hình Thiên", camp=N, lv=25, st=1)
R(20, 2, 1, "hohymi", "gặp Hồ Hỷ Mị", camp=N, lv=25)
R(20, 2, 2, "hinhthien", "giao Thiệp mời cho Hình Thiên", [E(15)], camp=N)
R(20, 2, 10, "phonglam", "gặp Phong Lâm", camp=N, lv=35)
R(20, 2, 11, "ngolong", "gặp Ngô Long", camp=N)
R(20, 2, 12, "chutuudiem", "lấy Cạnh tinh rượu ở Chủ Tửu Điếm (NPC tự phát)", camp=N, lv=35)
R(20, 2, 13, "ngolong", "giao Cạnh tinh rượu cho Ngô Long", [E(16)], camp=N, lv=35)
R(20, 2, 20, "thuonghao", "gặp Thương Hạo", camp=N, lv=45)
R(20, 2, 21, "mob_thuongquan", "hạ Thương Quân Hiệu Úy ở Mạnh Tân", camp=N, kill=1)
R(20, 2, 22, "thuonghao", "về gặp Thương Hạo", camp=N, lv=45)
R(20, 2, 30, "vanthaisu", "giao Phục Thù phù cho Văn Thái Sư", [E(17)], camp=N, lv=55)
R(20, 2, 31, "mob_kimha", "hạ Kim Hà Thú ở Tam Sơn", camp=N, kill=1)
R(20, 2, 32, "dabao", "giao Kim Hà quan cho Đa Bảo Đạo Nhân", [E(18)], camp=N)
R(20, 2, 33, "vanthaisu", "mang Ma huyết tới Văn Thái Sư", [E(19)], camp=N)
R(20, 2, 34, "hohymi", "mang Ma huyết tới Hồ Hỷ Mị", [E(19)], camp=N, lv=55)
KEEP = {G: 13, D: 2, N: 19}
VC1064 = {G: "thannong", D: "hienvien", N: "xivuu"}
for cp in (G, D, N):
    t = VAR[cp]
    R(20, t, 40, "dacky", "gặp Đắc Kỷ", camp=cp, lv=65)
    R(20, t, 41, "tayvuongmau", "gặp Tây Vương Mẫu", camp=cp, lv=65)
    R(20, t, 42, "mob_ancu", "hạ An Cư Thú ở Bích Du tầng 4", camp=cp, kill=1)
    R(20, t, 43, "tayvuongmau", "giao An Cư Đồ cho Tây Vương Mẫu", [E(3)], camp=cp, lv=65)
    R(20, t, 50, VC1064[cp], "đến Viễn Cổ gặp thủ lĩnh", camp=cp, lv=70 if cp == N else 55)
    R(20, t, 51, "mob_tranhnanh", "hạ Tranh Nanh ở Khốn Tiên tầng 1", camp=cp, kill=1)
    R(20, t, 52, VC1064[cp], "mang Thần Dư Kinh về Viễn Cổ", [E(4)], camp=cp, lv=70 if cp == N else 55)
    R(20, t, 60, "dacky", "mang %s tới Đắc Kỷ" % EVN[KEEP[cp]], [E(KEEP[cp])], camp=cp, lv=75)
    R(20, t, 61, "khuongtunha", "gặp Khương Tử Nha", camp=cp)
    R(20, t, 62, "vovuong", "giao Thần Dư Kinh cho Võ Vương", [E(4)], camp=cp)
    # 63: 3 books from the Tien The kills; task 42 bits 1 Can Tuong (EV8), 2 Ton Vu (EV6), 4 Bien Thuoc (EV7)
    books = [E(8, 1, 42, 1), E(6, 1, 42, 2), E(7, 1, 42, 4)]
    for b42 in range(0, 8):
        if b42 == 7:
            R(20, t, 63, "vovuong", "giao 3 bộ sách cho Võ Vương", books, camp=cp, v2=42, lo2=7, hi2=7)
        else:
            dest = bits_first_missing(0, b42, [(1, "mob_cantuong"), (2, "mob_tonvu"), (4, "mob_bienthuoc")])
            R(20, t, 63, dest, "hạ 3 Tiền Thế ở Khốn Tiên tầng 2-4 lấy sách", books, camp=cp, v2=42, lo2=b42,
              hi2=b42, kill=1)
    R(20, t, 70, "tayvuongmau", "gặp Tây Vương Mẫu", camp=cp, lv=80)
    R(20, t, 71, "dacky1063", "gặp Đắc Kỷ ở Triều Ca 10 năm sau", camp=cp, lv=80)
    R(20, t, 72, "nguyenthuy", "gặp Nguyên Thủy Thiên Tôn", camp=cp, lv=80)
    R(20, t, 73, "mob_doitruong", "hạ Đội Trưởng Lục Soát", camp=cp, kill=1)
    R(20, t, 74, "nguyenthuy", "giao Trúc giản cho Nguyên Thủy Thiên Tôn", [E(10)], camp=cp, lv=80)
    R(20, t, 80, "dackyluc", "giao Phong Thần bảng cho Đắc Kỷ lúc nhỏ", [E(9)], camp=cp, lv=85)

# ====================================================================== 4. Thien Thu (seed EV49 must be carried)
C(21, "Thiên Thụ - tưới nước")
for j in range(8, 14):
    R(21, 321, j, "linhbao", "giao 10 %s cho Linh Bảo" % MAT[j], [E(49), M(j, 10)])
C(22, "Thiên Thụ - bón phân")
for j in range(22, 26):
    R(22, 322, j, "caogiac", "giao 10 %s cho Cao Giác" % MAT[j], [E(49), M(j, 10)])
C(23, "Thiên Thụ - bắt sâu")
R(23, 323, (1, 6), "sungungbuu", "mang 1 pháp bảo tới Sùng Ứng Bưu (pháp bảo tự chuẩn bị)", [E(49)])
# questfix3: seed held (804 = 1 Mam cay 4/49, 2 Mam dac biet 4/164), no care step open (cond 4: 321 = 322 = 323 = 0).
# 320 counts the care visits (request + hand-in = 2); at 20 the three NPCs refuse and Ba Giam (VNG PAK script
# \script\feng_shen_tai\bai_jian.lua, "Lay duoc qua") pays by the growth task 327. No item: the seed is already held.
C(24, "Thiên Thụ - chăm sóc, thu hoạch")
R(24, 804, (1, 2), "bagiam", "mang Mầm cây tới Bá Giám thu hoạch (đã đủ 10 lần chăm sóc, thưởng theo độ trưởng thành)",
  v2=320, lo2=20, hi2=999, cond=4)
R(24, 804, (1, 2), "linhbao", "chăm sóc Mầm cây: Linh Bảo tưới nước, Cao Giác bón phân, Sùng Ứng Bưu bắt sâu (đủ 10 lần thì tới Bá Giám)",
  v2=320, lo2=0, hi2=19, cond=4)

# ====================================================================== 5. daily / repeatable
C(40, "Thiên Cống")
TC = {1: 116, 2: 117, 3: 118, 4: 119}
for k, d in TC.items():
    R(40, 2142, k, "tinhquan1020", "nộp %s cho Tinh Quan" % MAT[d], [M(d, 1)])
R(40, 2142, 5, "tinhquan1020", "nộp 3 San thạch cho Tinh Quan", [M(82, 3)])
R(40, 2142, 6, "tinhquan1020", "nộp 50 Đồng thau cho Tinh Quan", [M(3, 50)])
C(41, "Thiên Cương Hồn")
R(41, 2144, (1, 2), "angiao", "tự hạ Ảnh Tử và Tinh (Ân Giao đưa tới bản đồ)", kill=1)
R(41, 2144, 3, "angiao", "về gặp Ân Giao")
C(42, "Siêu Độ")
R(42, 2148, 1, "anhong", "siêu độ oan hồn (Ân Hồng đưa tới chỗ)", kill=1)
R(42, 2148, 2, "anhong", "về gặp Ân Hồng")
C(43, "Hấp Hồn")
R(43, 2152, 1, "thuyenphu1055", "hút 6 hồn ở đảo (Thuyền Phu)", kill=1)
R(43, 2152, 2, "thuyenphu1055", "về gặp Thuyền Phu")
C(44, "Vận chuyển")          # custom: PTNV_X44 (destination city + goods + count in task 2169)
C(45, "Mã Đế")
R(45, 2312, 1, "anhong", "siêu độ oan linh (Ân Hồng đưa tới chỗ)", kill=1)
R(45, 2312, 2, "anhong", "về gặp Ân Hồng")
C(46, "Phúc Kim")
for k in range(1, 6):
    R(46, 2316, k, "chiemtinh1020", "nộp %s cho Nhà Chiêm Tinh" % MAT[28 + k], [M(28 + k, 1)])
C(47, "Lục Lâm")
R(47, 2321, 1, "luclam", "phá xe lương ở Tam Sơn", kill=1)
R(47, 2318, (1, 2), "luclam", "nhận thưởng ở Lục Lâm Hảo Hán")
C(48, "Vận Lương")
R(48, 2121, 1, "luongthao", "hộ tống xe lương tới Lương Thảo Quan", kill=1)
C(49, "Vận Tiêu")
R(49, 2130, (1, 99999999), "tongtieudau", "hộ tống xe tiêu tới Tổng Tiêu Đầu", kill=1)
C(50, "Vạn Tiên trận")
R(50, 2009, (1, 99999), "thienhung1020", "làm nhiệm vụ trong trận rồi về Thiên Hùng", cond=1, kill=1)
R(50, 2009, 100000, "thienhung1020", "nhận thưởng ở Thiên Hùng", cond=1)

# ====================================================================== 6. Tien Ma gioi (2222 / 2283, faction 2252)
C(60, "Tiên Ma giới")


def TM(var, vals, tien, ma, txt, items=None, kill=0, cond=0):
    if ma is None:
        R(60, var, vals, tien, txt, items, kill=kill, cond=cond)
    else:
        R(60, var, vals, tien, txt, items, v2=2252, lo2=1, hi2=1, kill=kill, cond=cond)
        R(60, var, vals, ma, txt, items, v2=2252, lo2=2, hi2=2, kill=kill, cond=cond)


R(60, 2222, 0, "tiepdan1020", "nhận chủ tuyến ở Tiếp Dẫn Đạo Nhân", lv=85, st=1)
TM(2222, 1, "tm1073_tu_t", "tm1073_tu_m", "nhận thư ở Tu Hành Sư")
TM(2222, 2, "tm1073_dacky", None, "điều tra ở Đắc Kỷ")
TM(2222, 3, "tm1073_tu_t", "tm1073_tu_m", "về Tu Hành Sư")
TM(2222, 4, "tm1073_linhxa", None, "gọi rắn ở Linh Xà Thụ")
TM(2222, 5, "tm1073_linhxa", None, "hạ Linh Xà", kill=1)
TM(2222, (6, 7), "tm1073_dacky", None, "gặp Đắc Kỷ")
TM(2222, 8, "tm1073_ld_t", None, "nhận việc ở Liên Đăng Hộ Sứ")
TM(2222, [9, 11], "tm1073_ld_t", None, "thắp 6 đèn rồi gọi Sứ Giả", kill=1)
TM(2222, 10, "tm1073_ld_t", None, "hàng phục Sứ Giả", kill=1)
TM(2222, 12, "tm1073_ld_t", None, "báo Liên Đăng Hộ Sứ")
TM(2222, 15, "tm1073_ld_m", None, "nhận việc ở Liên Đăng Hộ Sứ")
TM(2222, [16, 18], "tm1073_ld_m", None, "thắp 6 đèn rồi gọi Sứ Giả", kill=1)
TM(2222, 17, "tm1073_ld_m", None, "hàng phục Sứ Giả", kill=1)
TM(2222, 19, "tm1073_ld_m", None, "báo Liên Đăng Hộ Sứ")
TM(2222, 13, "tm1073_dacky", None, "báo Đắc Kỷ")
TM(2222, 14, "tm1074_tu_t", "tm1074_tu_m", "đến Bất Chu Sơn tìm thần")
TM(2222, 20, "tm1074_hoa", None, "nhận sức mạnh Hỏa Thần và Thủy Thần")
TM(2222, 21, "tm1074_thach", None, "trao sức mạnh cho Thiên Niên Đại Thạch")
TM(2222, 22, "tm1074_thach", None, "hàng phục Thạch Quái", kill=1)
TM(2222, [23, 25], "tm1074_hoa", None, "báo Hỏa Thần")
TM(2222, 24, "tm1074_thuy", None, "báo Thủy Thần")
TM(2222, 27, "tm1075_tu_t", "tm1075_tu_m", "đến Ngục Pháp Sơn gặp Tu Hành Sư", cond=3)
GCP, HDO, DTC = NI(6, 1, 518, 1, 1, "Giải Chú Phù"), NI(6, 1, 529, 1, 1, "Hà Đồ Lạc Thư"), NI(6, 1, 575, 1, 1, "Dẫn Tuyền Châm")
TM(2283, 28, "tm1075_tbt", None, "nhận Giải Chú Phù ở Tứ Bất Tướng")
TM(2283, 29, "tm1075_laban", None, "dùng Giải Chú Phù trong vòng La Bàn", [GCP])
TM(2283, 30, "tm1075_tbt", None, "hỏi lại Tứ Bất Tướng")
TM(2283, [31, 32, 37], "tm1075_phaptru", None, "hỏi mật mã 4 Pháp trụ")
TM(2283, 33, "tm1075_laban", None, "xoay La Bàn theo mật mã")
TM(2283, 34, "tm1075_laban", None, "dùng Giải Chú Phù gọi Cự Thú", [GCP])
TM(2283, 35, "tm1075_laban", None, "hàng phục Cự Thú", [GCP], kill=1)
TM(2283, 36, "tm1075_tbt", None, "báo Tứ Bất Tướng")
TM(2283, 38, "tm1075_tbt", None, "hạ 30 quái ở Ngục Pháp Sơn", kill=1)
TM(2283, (39, 40), "tm1075_cong", None, "qua Cổng thời gian gặp Khương Tử Nha lúc nhỏ")
TM(2283, 41, "tm1075_laban", None, "dùng Hà Đồ Lạc Thư trong vòng La Bàn", [HDO])
TM(2283, 43, "tm1075_phaptru", None, "sửa 4 Pháp trụ (Bắc, Đông, Nam, Tây)", [HDO], kill=1)
TM(2283, 44, "tm1075_tbt", None, "gọi và hàng phục Phục Hy", [HDO], kill=1)
TM(2283, 45, "tm1075_tu_t", "tm1075_tu_m", "từ biệt Tu Hành Sư")
TM(2283, 46, "tm1076_tu_t", "tm1076_tu_m", "đến Thánh Địa gặp Tu Hành Sư")
TM(2283, 47, "tm1076_king", None, "hạ 2 vương rồi dùng Dẫn Tuyền Châm, hạ Vạn Trảo Thú", [DTC], kill=1)
TM(2283, (48, 49), "tm1076_tu_t", "tm1076_tu_m", "về gặp Tu Hành Sư")

# ====================================================================== 7. Giang Son Y Cuu (custom PTNV_X70), kill spots
C(70, "Giang Sơn Y Cựu")
GS = {1: (1022, 1513, 3543), 2: (1022, 1513, 3543), 3: (1022, 1496, 2976), 4: (1037, 1609, 3351), 5: (1037, 1570, 3357),
      6: (1037, 1570, 3357), 7: (1026, 1480, 3136), 8: (1041, 1608, 3392), 9: (1026, 1493, 3367), 10: (1033, 1840, 3278),
      11: (1029, 1452, 2749), 12: (1031, 1577, 2630), 13: (1031, 1600, 2601), 14: (1032, 2000, 2845),
      15: (1036, 1585, 3765), 16: (1036, 1296, 3392), 17: (1047, 1786, 3100), 18: (1051, 1636, 2991), 19: (1051, 1592, 3120)}

exec(compile(open(os.path.join(H, 'chains2.py'), encoding='utf-8').read(), 'chains2.py', 'exec'))

exec(compile(open(os.path.join(H, 'chains3.py'), encoding='utf-8').read(), 'chains3.py', 'exec'))

