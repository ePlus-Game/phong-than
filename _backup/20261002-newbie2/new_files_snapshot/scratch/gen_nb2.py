# -*- coding: utf-8 -*-
# newbie2 (2026-10-03): generates Server\script\phongthan\newbie2\nb2_data.lua (ASCII file, TCVN3/GBK as \ddd escapes)
# from the quest spec below (taskinfo 894-925, 999-1010, 3003-3005; texts follow taskinfo.ini).
# usage: python gen_nb2.py [outfile]
import os, sys, unicodedata
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low as _low

OUT = sys.argv[1] if len(sys.argv) > 1 else r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan\newbie2\nb2_data.lua"


def tcvn(s):
    o = bytearray()
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128: o.append(ord(ch))
        elif ch in _low: o.append(_low[ch])
        elif ch.lower() in _low: o.append(_low[ch.lower()])
        else: raise ValueError(repr(ch) + " in " + s)
    return bytes(o)


def esc(b):
    r = []
    for c in b:
        if c == 34: r.append('\\"')
        elif c == 92: r.append("\\\\")
        elif c < 32 or c >= 127: r.append("\\%d" % c)
        else: r.append(chr(c))
    return '"' + "".join(r) + '"'


def V(s):   # Vietnamese text shown to players (TCVN3)
    return ("raw", esc(tcvn(s)))


def G(s):   # GBK server name of a map NPC
    return ("raw", esc(s.encode("gbk")))


def lua(v, ind=""):
    if isinstance(v, tuple) and v[0] == "raw": return v[1]
    if v is None: return "nil"
    if isinstance(v, bool): return "1" if v else "nil"
    if isinstance(v, int): return str(v)
    if isinstance(v, str): return esc(v.encode("ascii"))
    if isinstance(v, list): return "{ " + ", ".join(lua(x, ind) for x in v) + " }"
    if isinstance(v, dict):
        parts = []
        for k, x in v.items():
            if x is None: continue
            key = ("[%d]" % k) if isinstance(k, int) else k
            parts.append("%s = %s" % (key, lua(x, ind)))
        return "{ " + ", ".join(parts) + " }"
    raise TypeError(v)

# ------------------------------------------------------------------ NPCs (map, GBK or TCVN3 names)
N = {
    "taphoa": G("杂货商"), "thukho": G("仓库管理员"), "toho": G("苏护"), "lohung": G("鲁雄"),
    "trieudien": G("晁田"), "sul": G("崇应鸾"), "tuhang": G("慈航道人"), "thodong": G("铜匠"),
    "xichtinh": G("赤精子"), "vantrung": G("云中子"), "nhiendang": G("燃灯道人"), "namcuc": G("南极仙翁"),
    "thieuhao": G("少昊图腾"), "hautho": G("后土图腾"), "chucdung": G("祝融图腾"), "congcong": G("共工图腾"),
    "phongba": G("风伯图腾"), "yisheng": G("医生"), "nhamdaica": G("任大哥"),
    "shs1002": G("生活技能老师（大营）"), "shs1003": G("生活技能老师（玉虚）"), "shs1004": G("生活技能老师（蚩尤墓）"),
    "dpts": V("Đại phu Tam Sơn"), "dpdq": V("Đại phu Đồng Quan"),
}
VILLAGE = {0: 1002, 1: 1003, 2: 1004}
FIELD = [1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019]
HP = [1, 0, 1, 1, 0, 0]
MP = [1, 3, 1, 1, 0, 0]


def it(t, n): return t + [n]


def go(m, names, n, **kw):
    d = {"go": [m, [N[x] for x in names]], "n": n}
    d.update(kw); return d


def RW(exp, money, items=None): return {"exp": exp, "money": money, "items": items or []}


def SC(p): return [6, 1, p, 1, 0, 0, 1]

# ------------------------------------------------------------------ chain quests
Q = {}
# ---------------- Giap Si (Sung Thanh doanh 1002)
Q[909] = dict(lv=1, intro=V("Thông báo cho Tạp hóa Thương biết sắp có giông bão, nên che chắn hàng hoá cho tốt! Tạp hóa Thương ở ngay trong doanh trại."),
    s=[go(1002, ["taphoa"], 0, msg=V("Tạp hóa Thương: Đa tạ đã báo tin! Phiền ngươi đến gặp Thủ khố, nhắc y cất kỹ quân lương.")),
       go(1002, ["thukho"], 1, msg=V("Thủ khố: Ta biết rồi, kho lương sẽ được che chắn cẩn thận. Ngươi làm tốt lắm, tân binh!"))],
    rw=RW(300, 500, [it(HP, 3), it(MP, 3)]))
Q[907] = dict(lv=1, intro=V("Lỗ Hùng bận huấn luyện tân binh, nhờ ngươi ra ngoài rừng (Sùng Thành dã ngoại) tiêu diệt 8 Kiếm Nhân, xong về phục mệnh Tạp hóa Thương."),
    s=[{"kill": {"tids": [0], "need": 8, "lab": V("Kiếm Nhân")}, "n0": 0, "a0": "Nk", "n": 1, "a": "Nck"},
       go(1002, ["taphoa"], 2, ti=1, msg=V("Tạp hóa Thương: Giỏi lắm! Lỗ Hùng sẽ vui khi nghe tin này."))],
    rw=RW(800, 1000, [it(HP, 3)]))
Q[906] = dict(lv=3, intro=V("Tô Hộ có một bình Tuyết Lộ đang ở trong tay Lỗ Hùng. Hãy đến lấy rồi đưa về cho Tô Hộ."),
    s=[go(1002, ["lohung"], 0, msg=V("Lỗ Hùng: Đây là Tuyết Lộ của Tô Hộ, cẩn thận đừng làm vỡ!")),
       go(1002, ["toho"], 1, msg=V("Tô Hộ: Tuyết Lộ đây rồi, đa tạ ngươi đã cẩn thận mang về."))],
    rw=RW(1000, 1000, [it(MP, 3)]))
Q[904] = dict(lv=6, intro=V("Tô Hộ thích nghiên cứu võ công, nhờ ngươi mua 1 quyển Tế Huyết Trảm (bí kíp hệ phái, có bán ở Quân Sư hoặc Võ sư) rồi đưa cho Tô Hộ xem thử."),
    s=[go(1002, ["toho"], 0, book=[27, 62027], msg=V("Tô Hộ: Quả là bí kíp hay, ngươi hãy giữ lấy mà luyện tập. Đây là chút lộ phí."))],
    rw=RW(1500, 2000))
Q[905] = dict(lv=6, intro=V("Sau cấp 10, hãy đến Sùng Thành doanh bái kiến Triều Điền, y có việc quan trọng giao cho ngươi."),
    s=[go(1002, ["trieudien"], 0, lv=10, msg=V("Triều Điền: Ngươi đến rồi! Quân trang của ta đang gặp chuyện chẳng lành..."))],
    rw=RW(3000, 2000))
Q[903] = dict(lv=10, intro=V("Quân lính của Triều Điền vận chuyển quân trang đã bị yêu ma nhập hồn vào các rương hàng. Ra ngoài thành (bản đồ dã ngoại), mở rương thả 4 Yêu Ma rồi siêu độ chúng."),
    s=[{"chest": 4, "n0": 0, "n": 1, "a": "ck"},
       go(1002, ["trieudien"], 2, ti=1, msg=V("Triều Điền: Yêu ma đã bị siêu độ, quân trang an toàn rồi. Mật tịch này tặng ngươi."))],
    rw=RW(6000, 3000, [it(HP, 5), SC(304)]))
Q[902] = dict(lv=14, intro=V("Sùng Ứng Loan xem Thư tạo phản xong rất tức giận. Hãy đến Yến Sơn tiêu diệt 12 Hoàn Cẩu để dụ Hoàn Cẩu Vương xuất hiện, rồi theo Lệnh bài tìm Hoàn Cẩu Soái và Hoàn Cẩu Tinh."),
    s=[{"king": {"tid": 7, "maps": [1007, 1015], "every": 12, "boss902": 1}, "n0": 0, "n": 1, "a": "NdK"},
       go(1002, ["sul"], 2, ti=1, msg=V("Sùng Ứng Loan: Phản quân Hoàn Cẩu đã tan rã, công lao của ngươi không nhỏ!"))],
    rw=RW(12000, 5000, [it(HP, 5), it(MP, 5), SC(351)]))
# ---------------- Dao Si (Ngoc Hu cung 1003)
Q[897] = dict(lv=1, intro=V("Hoan nghênh bạn đến với thế giới Phong Thần. Hãy đi bái kiến Từ Hàng Đạo Nhân trong Ngọc Hư Cung."),
    s=[go(1003, ["tuhang"], 0, msg=V("Từ Hàng Đạo Nhân: Tốt lắm. Hãy đi làm quen với Tạp hóa Thương và Thủ khố, sau này sẽ cần đến họ.")),
       {"go2": [[1003, [N["taphoa"]]], [1003, [N["thukho"]]]], "n": 1, "n2a": 2, "n2b": 3},
       go(1003, ["tuhang"], 4, msg=V("Từ Hàng Đạo Nhân: Ngươi đã quen đường trong Ngọc Hư Cung rồi đấy."))],
    rw=RW(300, 500, [it(HP, 3), it(MP, 3)]))
Q[896] = dict(lv=1, intro=V("Ra ngoài rừng (Chân núi Côn Lôn) tiêu diệt 8 Tuyết Quái chứng tỏ thực lực, xong tìm Thợ đồng ở Ngọc Hư Cung trả nhiệm vụ."),
    s=[{"kill": {"tids": [1], "need": 8, "lab": V("Tuyết Quái")}, "n0": 0, "a0": "Nk", "n": 1, "a": "Nck"},
       go(1003, ["thodong"], 2, ti=1, msg=V("Thợ đồng: Thân thủ không tệ, đây là phần thưởng cho ngươi."))],
    rw=RW(800, 1000, [it(HP, 3)]))
Q[895] = dict(lv=3, intro=V("Xích Tinh Tử có đề thi của chúng tiên, nhờ ngươi đem đến giao cho Vân Trung Tử."),
    s=[go(1003, ["xichtinh"], 0, msg=V("Xích Tinh Tử: Đây là đề thi, mang đến cho Vân Trung Tử ngay.")),
       go(1003, ["vantrung"], 0, msg=V("Vân Trung Tử: Đề thi đây rồi, ngươi làm việc rất chu đáo."))],
    rw=RW(1000, 1000, [it(MP, 3)]))
Q[910] = dict(lv=3, intro=V("Vân Trung Tử rất am hiểu võ học, nhờ ngươi mua 1 quyển Chưởng Tâm Lôi (bí kíp hệ phái, có bán ở Quân Sư hoặc Võ sư) về cho ông xem thử."),
    s=[go(1003, ["vantrung"], 0, book=[3, 62003], msg=V("Vân Trung Tử: Chưởng Tâm Lôi quả là tuyệt học, ngươi hãy chăm chỉ tu luyện."))],
    rw=RW(1500, 2000))
Q[911] = dict(lv=3, intro=V("Vân Trung Tử rất vui vì ngươi đã vượt qua thử thách, nhắn ngươi sau cấp 10 đến phía Bắc Ngọc Hư Cung tìm Nhiên Đăng."),
    s=[go(1003, ["nhiendang"], 0, lv=10, msg=V("Nhiên Đăng Đạo Nhân: Ngươi đến đúng lúc, Ngọc Hư Cung đang gặp tai họa..."))],
    rw=RW(3000, 2000))
Q[912] = dict(lv=10, intro=V("Yêu ma thừa cơ nhập vào rương pháp bảo của Ngọc Hư Cung. Cầm Trấn rương phù ra ngoài thành (bản đồ dã ngoại), mở rương thả 4 Yêu Ma rồi siêu độ chúng."),
    s=[{"chest": 4, "n0": 0, "n": 1, "a": "ck"},
       go(1003, ["nhiendang"], 2, ti=1, msg=V("Nhiên Đăng Đạo Nhân: Rương pháp bảo đã sạch yêu khí. Mật tịch này tặng ngươi."))],
    rw=RW(6000, 3000, [it(HP, 5), SC(308)]))
Q[913] = dict(lv=14, intro=V("Băng Lang ở Côn Lôn hấp thu được linh khí. Mỗi lần giáo huấn 12 Băng Lang sẽ dụ 1 Băng Lang Vương xuất hiện, hàng phục 3 Băng Lang Vương rồi về gặp Nam Cực Tiên Ông."),
    s=[{"king": {"tid": 4, "every": 12, "ktpl": 606, "kname": V("Băng Lang Vương"), "need": 3}, "n0": 0, "n": 1, "a": "dK"},
       go(1003, ["namcuc"], 2, ti=1, msg=V("Nam Cực Tiên Ông: Băng Lang Vương đã quy phục, Côn Lôn yên ổn rồi."))],
    rw=RW(12000, 5000, [it(HP, 5), it(MP, 5), SC(306)]))
# ---------------- Di Nhan (Xi Vuu mo 1004)
Q[1000] = dict(lv=1, intro=V("Chào mừng đến với Phong Thần! Thiếu Hạo đang tìm ngươi đấy."),
    s=[go(1004, ["thieuhao"], 0, msg=V("Thiếu Hạo: Ngươi là Dị nhân mới đến à? Hãy đi chào Tạp hóa Thương trước.")),
       go(1004, ["taphoa"], 1, msg=V("Tạp hóa Thương: Có gì cần cứ ghé chỗ ta. Giờ hãy qua gặp Thủ khố.")),
       go(1004, ["thukho"], 2, msg=V("Thủ khố: Đồ đạc gửi ở chỗ ta là an toàn nhất. Về báo với Thiếu Hạo đi.")),
       go(1004, ["thieuhao"], 3, msg=V("Thiếu Hạo: Tốt lắm, ngươi đã quen với Xi Vưu Mộ rồi."))],
    rw=RW(300, 500, [it(HP, 3), it(MP, 3)]))
Q[1001] = dict(lv=1, intro=V("Ra ngoài thôn (Cự Lộc) tiêu diệt 8 Hỏa Diện để chứng minh năng lực, xong tìm Thợ đồng ở Xi Vưu Mộ trả nhiệm vụ."),
    s=[{"kill": {"tids": [2], "need": 8, "lab": V("Hỏa Diện")}, "n0": 0, "n": 1, "a": "Nck"},
       go(1004, ["thodong"], 2, ti=1, msg=V("Thợ đồng: Không tồi, đây là phần thưởng cho ngươi."))],
    rw=RW(800, 1000, [it(HP, 3)]))
Q[999] = dict(lv=3, intro=V("Hậu Thổ cho biết Chúc Dung và Cộng Công luôn bất đồng, nhờ ngươi đến hỏi chuyện cả hai để tìm hiểu nguyên nhân."),
    s=[{"go2": [[1004, [N["chucdung"]]], [1004, [N["congcong"]]]], "n": 0, "n2a": 0, "n2b": 0,
        "msg": V("Thì ra Cộng Công làm rách cuốn Kim Cang Chú của Chúc Dung nên hai người mới giận nhau.")}],
    rw=RW(1000, 1000))
Q[1002] = dict(lv=3, intro=V("Giúp Chúc Dung và Cộng Công hòa giải: đánh Hỏa Diện lấy 5 trang sách rách, đánh Cuồng Điêu lấy 1 Tuyến quyển, giao cho Cộng Công."),
    s=[{"coll": [{"lab": V("Trang sách rách"), "need": 5, "tids": [2], "chance": 60, "n": 1},
                 {"lab": V("Tuyến quyển"), "need": 1, "tids": [6], "chance": 50, "n": 2}], "n0": 0, "n": 1, "a": "c"},
       go(1004, ["congcong"], 1, a="c", msg=V("Cộng Công: Ta đã đóng lại cuốn Kim Cang Chú. Phiền ngươi mang trả cho Chúc Dung.")),
       go(1004, ["chucdung"], 3, msg=V("Chúc Dung: Kim Cang Chú đã lành lại! Ta và Cộng Công từ nay không còn hiềm khích."))],
    rw=RW(2000, 2000, [it(HP, 3), it(MP, 3)]))
Q[1003] = dict(lv=4, intro=V("Thiếu Hạo nhờ ngươi mua 1 quyển Lực Sĩ Tế (bí kíp hệ phái, có bán ở Quân Sư hoặc Võ sư) để ông xem thử."),
    s=[go(1004, ["thieuhao"], 0, book=[450, 62450], msg=V("Thiếu Hạo: Lực Sĩ Tế là đệ tử đầu tiên của Dị nhân, ngươi hãy học lấy."))],
    rw=RW(1500, 2000))
Q[1006] = dict(lv=4, intro=V("Chúc Dung nói con đường trưởng thành của Dị nhân đầy chông gai. Hãy ra ngoài luyện tập, sau cấp 10 đi tìm Phong Bá."),
    s=[go(1004, ["phongba"], 0, lv=10, nlv=2, msg=V("Phong Bá: Ngươi đã cứng cáp hơn nhiều rồi, ta đang cần người giúp sức."))],
    rw=RW(3000, 2000))
Q[1004] = dict(lv=10, intro=V("Bảo rương cần đưa đến tộc lân cận đã bị ma quái chiếm. Ra ngoài thành (bản đồ dã ngoại), mở rương thả 4 Yêu Ma rồi siêu độ chúng."),
    s=[{"chest": 4, "n0": 0, "n": 1, "a": "ck"},
       go(1004, ["phongba"], 2, ti=1, msg=V("Phong Bá: Bảo rương đã an toàn. Mật tịch này tặng ngươi."))],
    rw=RW(6000, 3000, [it(HP, 5), SC(306)]))
Q[1007] = dict(lv=14, intro=V("Lục Quái không ngừng tấn công người vận chuyển của tộc ta. Đánh bại 12 Lục Quái sẽ xuất hiện 1 Lục Quái Vương, hàng phục 3 Lục Quái Vương lấy 3 lệnh bài rồi về gặp Phong Bá."),
    s=[{"king": {"tid": 5, "every": 12, "ktpl": 607, "kname": V("Lục Quái Vương"), "need": 3}, "n0": 0, "n": 1, "a": "dK"},
       go(1004, ["phongba"], 2, ti=1, msg=V("Phong Bá: 3 Lục Quái Lệnh đây rồi, đường vận chuyển đã thông."))],
    rw=RW(12000, 5000, [it(HP, 5), it(MP, 5), SC(350)]))
# ---------------- common tail (taskinfo playertype 0)
Q[898] = dict(lv=20, intro=V("Có thể đến Tân thủ thôn tìm Tạp hóa Thương, rồi gặp Sinh Hoạt Sư tìm hiểu Kỹ năng sống."),
    s=[go(1002, ["taphoa"], 0, p=0), go(1003, ["taphoa"], 1, p=1), go(1004, ["taphoa"], 2, p=2),
       go(1002, ["shs1002"], 3, p=0, msg=V("Sinh Hoạt Sư: Kỹ năng sống giúp ngươi tự làm ra vật phẩm, hãy thường xuyên ghé ta.")),
       go(1003, ["shs1003"], 4, p=1, msg=V("Sinh Hoạt Sư: Kỹ năng sống giúp ngươi tự làm ra vật phẩm, hãy thường xuyên ghé ta.")),
       go(1004, ["shs1004"], 5, p=2, msg=V("Sinh Hoạt Sư: Kỹ năng sống giúp ngươi tự làm ra vật phẩm, hãy thường xuyên ghé ta."))],
    rw=RW(2000, 2000))
Q[901] = dict(lv=21, intro=V("Đại phu là đội ngũ cứu viện quan trọng. Hãy đến Mạnh Tân tìm Đại phu xem ông gặp khó khăn gì."),
    s=[go(1015, ["yisheng"], 0, msg=V("Đại phu Mạnh Tân: Ngươi đến thật đúng lúc, quân nhu đang thiếu dược liệu trầm trọng."))],
    rw=RW(8000, 3000))
Q[1005] = dict(lv=21, intro=V("Đại phu là đội ngũ cứu viện quan trọng của Xi Vưu Mộ. Phong Bá nhờ ngươi đến Mạnh Tân hỏi Đại phu gặp phải vấn đề gì."),
    s=[go(1015, ["yisheng"], 0, msg=V("Đại phu Mạnh Tân: Ngươi đến thật đúng lúc, quân nhu đang thiếu dược liệu trầm trọng."))],
    rw=RW(8000, 3000))
Q[900] = dict(lv=21, intro=V("Đại phu Mạnh Tân cần 5 Hạp Đằng: đánh Hoàn Cẩu ở Mạnh Tân để nhận Hoàn Cẩu Ấn Ký, ở trạng thái ấn ký tiêu diệt Giáp Cốt sẽ nhận được Hạp Đằng."),
    s=[{"mark": {"tids": [7], "maps": [1015], "msg": V("Nhận được Hoàn Cẩu Ấn Ký, giờ hãy tiêu diệt Giáp Cốt để lấy Hạp Đằng.")},
        "coll": [{"lab": V("Hạp Đằng"), "need": 5, "tids": [13], "maps": [1015], "chance": 50, "mark": 1, "n": 1}], "n0": 0, "n": 1, "a": "c"},
       go(1015, ["yisheng"], 2, ti=1, rw=RW(8000, 3000), msg=V("Đại phu Mạnh Tân: Đủ Hạp Đằng rồi! Đại phu ở ải Tam Sơn cũng đang cần giúp, ngươi qua đó xem sao.")),
       go(1016, ["dpts"], 4, msg=V("Đại phu Tam Sơn: Dưới chân núi Tam Sơn có Nguyên Sâm, đánh yêu thú ở đó sẽ tìm được. Ta cần 10 củ.")),
       {"coll": [{"lab": V("Nguyên Sâm"), "need": 10, "maps": [1016], "chance": 50, "n": 6}], "n0": 6, "n": 6},
       go(1016, ["dpts"], 7, rw=RW(10000, 3000), msg=V("Đại phu Tam Sơn: Đa tạ! Đại phu ở Đồng Quan đang gặp nạn, ngươi giúp ông ấy với.")),
       go(1014, ["dpdq"], 9, msg=V("Đại phu Đồng Quan: Sơn Xuyên Liễu bị yêu khí nhiễm độc. Đánh Ngưu Sát lấy Tĩnh hóa phù để tịnh hóa 5 Sơn Xuyên Liễu.")),
       {"coll": [{"lab": V("Sơn Xuyên Liễu đã tịnh hóa"), "need": 5, "tids": [12], "maps": [1014], "chance": 50, "n": 11}], "n0": 11, "n": 11},
       go(1014, ["dpdq"], 12, ti=1, msg=V("Đại phu Đồng Quan: Sơn Xuyên Liễu đã sạch độc, quân y ba nơi đều nhờ ơn ngươi."))],
    rw=RW(15000, 5000, [it(HP, 10), it(MP, 10)]))
Q[1008] = dict(lv=22, intro=V("Chiến loạn liên miên, các thương gia ráo riết gom hàng. Tạp thương Xi Vưu Mộ nhờ ngươi đến ải Du Hồn thu thập 20 Trúc, 10 Thụ, 4 Trầm (đánh yêu thú ở Du Hồn)."),
    s=[{"coll": [{"lab": V("Trúc"), "need": 20, "maps": [1011], "chance": 60},
                 {"lab": V("Thụ"), "need": 10, "maps": [1011], "chance": 60},
                 {"lab": V("Trầm"), "need": 4, "maps": [1011], "chance": 60}], "n0": 0, "n": 0},
       go(1004, ["taphoa"], 1, ti=1, msg=V("Tạp thương Xi Vưu Mộ: Hàng đủ cả rồi! Tạp thương Triều Ca cũng đang cần người giúp."))],
    rw=RW(8000, 3000))
Q[899] = dict(lv=22, intro=V("Chiến loạn liên miên, các thương gia ráo riết gom hàng. Tạp hóa Sùng Thành nhờ ngươi đến Tam Sơn thu thập 20 Lý, 10 Trầm, 5 Nham (đánh yêu thú ở Tam Sơn)."),
    s=[{"coll": [{"lab": V("Lý"), "need": 20, "maps": [1016], "chance": 60},
                 {"lab": V("Trầm"), "need": 10, "maps": [1016], "chance": 60},
                 {"lab": V("Nham"), "need": 5, "maps": [1016], "chance": 60}], "n0": 0, "n": 0},
       go(1002, ["taphoa"], 1, ti=1, rw=RW(8000, 3000), msg=V("Tạp hóa Sùng Thành: Hàng tốt lắm! Tạp hóa Triều Ca cũng đang cần người giúp.")),
       go(1021, ["taphoa"], 2, msg=V("Tạp hóa Triều Ca: Ta cần 20 Châu, 10 Khúc, 5 Cầm ở Mạnh Tân (đánh yêu thú ở Mạnh Tân).")),
       {"coll": [{"lab": V("Châu"), "need": 20, "maps": [1015], "chance": 60},
                 {"lab": V("Khúc"), "need": 10, "maps": [1015], "chance": 60},
                 {"lab": V("Cầm"), "need": 5, "maps": [1015], "chance": 60}], "n0": 3, "n": 3},
       go(1021, ["taphoa"], 4, rw=RW(10000, 3000), msg=V("Tạp hóa Triều Ca: Đủ hàng rồi! Sau cấp 24 ngươi hãy đến giúp Tạp thương Tây Kỳ.")),
       go(1020, ["taphoa"], 5, lv=24, msg=V("Tạp thương Tây Kỳ: Ta cần 20 Tảo, 10 Quế, 5 Cổ, ở Kỳ Sơn gần Tây Kỳ có nhiều.")),
       {"coll": [{"lab": V("Tảo"), "need": 20, "maps": [1017], "chance": 60},
                 {"lab": V("Quế"), "need": 10, "maps": [1017], "chance": 60},
                 {"lab": V("Cổ"), "need": 5, "maps": [1017], "chance": 60}], "n0": 7, "n": 7},
       go(1020, ["taphoa"], 6, rw=RW(12000, 4000), msg=V("Tạp thương Tây Kỳ: Tốt lắm! Tạp thương Trương ở Ngọc Hư Cung cần 5 Xa, 10 Hồng, 20 Thạch ở Thủ Dương sơn.")),
       {"coll": [{"lab": V("Xa"), "need": 5, "maps": [1010], "chance": 60},
                 {"lab": V("Hồng"), "need": 10, "maps": [1010], "chance": 60},
                 {"lab": V("Thạch"), "need": 20, "maps": [1010], "chance": 60}], "n0": 8, "n": 8},
       go(1003, ["taphoa"], 9, ti=1, msg=V("Tạp thương Trương: Vật tư dự bị đã đủ, ngươi là thương nhân giỏi nhất vùng này!"))],
    rw=RW(15000, 5000, [it(HP, 10), it(MP, 10)]))

CHAIN = {
    0: [909, 907, 906, 904, 905, 903, 902, 898, 901, 900, 899],
    1: [897, 896, 895, 910, 911, 912, 913, 898, 901, 900, 899],
    2: [1000, 1001, 999, 1002, 1003, 1006, 1004, 1007, 898, 1005, 900, 1008, [899, 3]],
}

# ------------------------------------------------------------------ mat tich / lenh (item 6/1/x)
# particular: (task, template 0-based, need, mob level, name)
SCROLL = [
    (303, 918, 0, 20, 3, "Kiếm Nhân"), (304, 914, 7, 30, 12, "Hoàn Cẩu"), (305, 1009, 2, 20, 3, "Hỏa Diện"),
    (306, 1010, 9, 30, 13, "Thảo Tiên"), (307, 915, 1, 20, 3, "Tuyết Quái"), (308, 916, 8, 30, 11, "Yểm Hỏa"),
    (309, 917, -1, 2, 5, "Thu thập"),
    (350, 925, 10, 30, 15, "Cổ Điêu"), (351, 919, 11, 30, 15, "Cốt Tinh"), (352, 921, 12, 30, 20, "Ngưu Sát"),
    (353, 920, 13, 30, 20, "Giáp Cốt"), (354, 922, 18, 30, 20, "Hắc Phong"), (355, 924, 15, 30, 25, "Dạ Xoa"),
    (356, 923, 24, 30, 25, "Giang Quy"),
]
# 917 per profession: (VNG step, item A detail, item B detail, template sources)
COLLECT917 = {0: (0, 11, 10, "Mảnh Giáp", "Đoản Kiếm"), 1: (2, 9, 13, "Ngọc Cốt", "Băng Cơ"), 2: (4, 12, 8, "Mặt Quỷ", "Hỏa Vũ")}
# material drops of the 917 scroll (template -> genre 3 detail), like npc_fix\mob_drop.lua
MAT917 = {0: 10, 3: 11, 4: 9, 8: 9, 1: 13, 2: 12, 6: 8}

TXT = {
    "qs_name": "Quân Sư (Tân thủ)",
    "qs_hello": "Quân Sư (Tân thủ): Ta phụ trách chuỗi nhiệm vụ tân thủ mới (Mao Lư, Thí luyện, Trừ yêu...). Chuỗi này chạy song song với nhiệm vụ tân thủ cũ của các NPC trong thôn, làm cả hai đều được.",
    "opt_start": "Nhận nhiệm vụ Mao Lư (chuỗi tân thủ mới)",
    "opt_status": "Xem nhiệm vụ đang làm",
    "opt_report": "Báo cáo hoàn thành nhiệm vụ",
    "opt_scroll": "Trả nhiệm vụ Mật tịch / Lệnh",
    "opt_book": "Mua bí kíp hệ phái",
    "opt_info": "Giới thiệu chuỗi tân thủ mới",
    "opt_exit": "Kết thúc đối thoại",
    "info": "Nhận Mao Lư ở chỗ ta, sau đó làm theo sổ nhiệm vụ (F11). Gặp NPC: chỉ cần đến sát NPC đó (hoặc bấm vào NPC), tiến độ tự cập nhật sau vài giây. Đánh quái: tự đếm. Nhiệm vụ trả ở NPC khác cũng có thể báo cáo tại ta. Mật tịch / Lệnh rơi khi đánh quái tương ứng: bấm chuột phải để nhận, đủ số lượng thì về gặp Tạp hóa Thương hoặc ta.",
    "done_all": "Ngươi đã hoàn thành toàn bộ chuỗi nhiệm vụ tân thủ mới. Hãy tiếp tục con đường Phong Thần!",
    "wait_lv": "Nhiệm vụ kế tiếp cần đạt cấp ",
    "not_started": "Ngươi chưa nhận chuỗi nhiệm vụ tân thủ mới.",
    "accepted": "Nhận nhiệm vụ: ",
    "completed": "Hoàn thành nhiệm vụ: ",
    "bag_full": "Hành trang không đủ chỗ trống, hãy sắp xếp lại rồi quay lại.",
    "no_report": "Nhiệm vụ hiện tại chưa thể báo cáo ở chỗ ta. Hãy xem sổ nhiệm vụ (F11).",
    "need_book": "Ngươi chưa có bí kíp cần thiết (mua ở Quân Sư - mục Mua bí kíp hệ phái).",
    "got_exp": "Nhận được kinh nghiệm: ",
    "got_money": " lượng",
    "kill_prog": "Tiến độ: ",
    "chest_open": "Rương chứa đồ bật mở, 4 Yêu Ma lao ra! Hãy siêu độ chúng.",
    "chest_town": "Hãy ra ngoài thành (bản đồ dã ngoại) để mở rương thả Yêu Ma.",
    "yeuma": "Yêu Ma",
    "hc_vuong": "Hoàn Cẩu Vương", "hc_soai": "Hoàn Cẩu Soái", "hc_tinh": "Hoàn Cẩu Tinh",
    "king_appear": " xuất hiện! Hãy hàng phục nó.",
    "lenhbai": "Nhận được Lệnh bài Hoàn Cẩu Vương: Hoàn Cẩu Soái và Hoàn Cẩu Tinh đã lộ diện gần đây!",
    "not_owner": "Đây không phải mục tiêu nhiệm vụ của ngươi.",
    "sc_ask": "Ngươi được Hạnh Vận Tinh phù hộ! Nhận nhiệm vụ ",
    "sc_ask2": " chứ? Hoàn thành xong về gặp Tạp hóa Thương (hoặc Quân Sư tân thủ) nhận thưởng.",
    "sc_yes": "Đồng ý", "sc_no": "Để sau",
    "sc_busy": "Ngươi đang làm nhiệm vụ này rồi, không thể dùng thêm mật tịch.",
    "sc_noitem": "Trong túi không có mật tịch! Không thể nhận nhiệm vụ!",
    "sc_got": "Nhận nhiệm vụ ",
    "sc_done": "Đã đủ số lượng, hãy về gặp Tạp hóa Thương (hoặc Quân Sư tân thủ) giao nhiệm vụ.",
    "sc_none": "Ngươi không có nhiệm vụ Mật tịch / Lệnh nào đã hoàn thành.",
    "sc_reward": "Giao nhiệm vụ thành công: ",
    "sc_drop": "Ngươi được Hạnh Vận Tinh phù hộ, nhặt được ",
    "sc_need917": "Cần 2 vật phẩm: ",
    "orw": " hoặc ",
    "got": "Nhận được ",
    "dp_hello": ": Thời loạn thương binh nhiều, ta ở đây chữa trị cho quân sĩ.",
    "dp_heal": "Trị thương",
    "dp_healed": "Sinh lực và nội lực của bạn đã hoàn toàn hồi phục.",
    "status_none": "Nhiệm vụ: ",
    "near": "Đã gặp ",
}


def gen():
    L = []
    L.append("-- Phong Than 2026-10-03 (newbie2): DATA of the new-era newbie chain (taskinfo 894-925, 999-1010, 3003-3005).")
    L.append("-- GENERATED by scratchpad\\newbie2\\gen_nb2.py, do not edit by hand. ASCII file: TCVN3 texts and GBK NPC names")
    L.append("-- are \\ddd escapes. Logic: nb2_lib.lua. Doc: docs\\features\\tan-thu-moi-phong-than-20261003.md")
    L.append("PTNB2_Q = {}")
    for qid, q in Q.items():
        d = {"id": qid, "lv": q["lv"], "intro": q["intro"], "rw": q["rw"], "s": q["s"]}
        L.append("PTNB2_Q[%d] = %s" % (qid, lua(d)))
    L.append("PTNB2_CHAIN = {}")
    for p, ch in CHAIN.items():
        L.append("PTNB2_CHAIN[%d] = %s" % (p, lua([x if isinstance(x, list) else [x, 1] for x in ch])))
    L.append("PTNB2_SCROLL = {}   -- [i] = { item particular, taskinfo id, template (0-based, -1 collect), need, mob level, name }")
    for i, (p, tid, tpl, need, mlv, nm) in enumerate(SCROLL):
        L.append("PTNB2_SCROLL[%d] = %s" % (i + 1, lua([p, tid, tpl, need, mlv, V(nm)])))
    L.append("PTNB2_C917 = {}   -- [profession] = { VNG step, material A detail, material B detail, name A, name B }")
    for p, (st, a, b, na, nb) in COLLECT917.items():
        L.append("PTNB2_C917[%d] = %s" % (p, lua([st, a, b, V(na), V(nb)])))
    L.append("PTNB2_MAT917 = %s" % lua({k: v for k, v in MAT917.items()}))
    L.append("PTNB2_TXT = {}")
    for k, v in TXT.items():
        L.append("PTNB2_TXT.%s = %s" % (k, lua(V(v))))
    L.append("PTNB2_N_TAPHOA = %s" % lua(N["taphoa"]))
    L.append("PTNB2_N_DPTS = %s" % lua(N["dpts"]))
    L.append("PTNB2_N_DPDQ = %s" % lua(N["dpdq"]))
    L.append("PTNB2_FIELD = %s" % lua({m: 1 for m in FIELD}))
    data = ("\r\n".join(L) + "\r\n").encode("ascii")
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, "wb").write(data)
    print("wrote", OUT, len(data), "bytes,", len(Q), "quests,", len(SCROLL), "scrolls")


if __name__ == "__main__":
    gen()
