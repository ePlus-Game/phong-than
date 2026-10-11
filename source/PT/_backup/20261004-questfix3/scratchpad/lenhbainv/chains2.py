# -*- coding: utf-8 -*-
# lenhbainv: second part of the quest-step table (exec'd at the end of chains.py, same globals).

# ====================================================================== 8. world quests 2004 + city quests
EVN.update({33: "Định Hải bảo châu", 34: "Chúc Ngư huyết", 35: "Thố Ngư huyết", 36: "Thể Ngư huyết", 37: "Mảnh Lưu tinh",
            38: "Huyền thảo", 39: "Liễu mộc", 40: "Côn Lôn kính", 41: "Đèn thần", 42: "Bạch Linh Phướn",
            43: "Bạch Linh phướn", 44: "Thiên Cương chân khí", 106: "Binh phù", 107: "Thông hành lệnh",
            108: "Hộ thân phù", 109: "Thư của Yển Bá Ích", 110: "Thư của Đặng Cửu Công", 111: "Tiên Thảo lộ",
            112: "Hoàn Linh Đơn", 113: "Di Tiên Tán", 114: "Mảnh pháp khí"})
C(30, "Minh Châu")
R(30, 41, 1, "chucamdo", "nhận Định Hải bảo châu ở Chủ Cầm Đồ")
R(30, 41, 2, "dothuquan", "mang bảo châu tới Đồ Thư Quán", [E(33)])
R(30, 41, 3, "culuuton", "mang bảo châu tới Cù Lưu Tôn", [E(33)])
for v in range(20, 27):
    b = v - 20
    have = [E(33)] + [E(n) for bit, n in ((1, 34), (2, 36), (4, 35)) if b & bit]
    dest = bits_first_missing(20, v, [(1, "mob_chucngu"), (2, "mob_thengu"), (4, "mob_thongu")])
    R(30, 41, v, dest, "hạ 3 loại cá ở Thủy Vực lấy huyết", have, kill=1)
R(30, 41, 27, "culuuton", "giao bảo châu và 3 huyết cá cho Cù Lưu Tôn", [E(33), E(34), E(35), E(36)])
R(30, 41, 10, "chucamdo", "nhận lại bảo châu ở Chủ Cầm Đồ")
R(30, 41, 11, "culuuton", "mang bảo châu tới Cù Lưu Tôn", [E(33)])
C(31, "Vi Lao")
R(31, 50, 1, "nguoihaithuoc", "gặp Người Hái Thuốc")
R(31, 50, 2, "mob_duoclau", "hạ Dược Lâu Tử ở Thủ Dương sơn", kill=1)
R(31, 50, 3, "vocat", "giao Huyền thảo cho Võ Cát", [E(38)])
R(31, 50, 4, "xichtinh", "gặp Xích Tinh Tử")
R(31, 50, 5, "xichtinh", "mang Liễu mộc, Côn Lôn kính, 2 Đèn thần tới Xích Tinh Tử", [E(39), E(40), E(41, 2)])
R(31, 50, 6, "vocat", "giao Liễu mộc, Côn Lôn kính, 2 Đèn thần cho Võ Cát", [E(39), E(40), E(41, 2)])
R(31, 50, 7, "xichtinh", "nhận thưởng ở Xích Tinh Tử")
R(31, 50, 8, "vocat", "gặp lại Võ Cát")
C(32, "Phi Tiên")
R(32, 51, 1, "thaytuongso1020", "gặp Thầy Tướng Số Tây Kỳ (mang 1.000 lượng)")
R(32, 51, 2, "caominh", "gặp Cao Minh")
R(32, 51, 3, "mob_hoatru", "hạ Hoa Trư ở Hoang Mạc", kill=1)
R(32, 51, 4, "nguoitayvuc", "giao Mảnh Lưu tinh cho Người Tây Vực", [E(37)])
R(32, 51, 5, "nguoitayvuc", "ghép thú cưỡi ở Người Tây Vực (cần thú cưỡi, Ba Lạc Nhẫn, 10 danh vọng)")
C(33, "Quy Tinh")            # custom PTNV_X33 (task 53 = state byte 1 + step byte 2)
C(34, "Phu Thê")
BTP = NI(6, 1, 11, 1, 1, "Biến thân phù", -1)
R(34, 92, 1, "duongtien_qt", "nhận Biến thân phù ở Dương Tiễn")
R(34, 92, (2, 4), "nhamdaica", "biến thân rồi gặp Nhậm Đại Ca", [BTP])
R(34, 92, 5, "nhamdaitau", "biến thân rồi gặp Nhậm Đại Tẩu", [BTP])
C(35, "Yên Phúc")
R(35, 91, 1, "thaytuongso1021", "gặp Thầy Tướng Số Triều Ca")
R(35, 91, 2, "tongdinhan", "về gặp Tống Dị Nhân")
R(35, 91, 3, "thaytuongso1021", "mang tâm phù tới Thầy Tướng Số", [NI(6, 1, 12, 0, 1, "Tâm phù", -1)])
C(36, "Thám Quân")          # custom PTNV_X36 (task 314 = map of the field doctor, 100 = report)
C(37, "Thu thập (Tân Miễn)")
R(37, 310, 1, "tanmien", "nộp 5 nguyên liệu cho Tân Miễn (kèm lượng bạc)", [NI(3, 6, 0, 0, 5, "")])
for v in range(2, 8):
    R(37, 310, v, "tanmien", "nộp 10 nguyên liệu cho Tân Miễn (kèm lượng bạc)", [NI(3, v + 6, 0, 0, 10, "")])
R(37, 310, (8, 13), "tanmien", "nộp 1 pháp bảo cho Tân Miễn (tự chuẩn bị)")
for v in range(14, 18):
    R(37, 310, v, "tanmien", "nộp 5 nguyên liệu cho Tân Miễn (kèm lượng bạc)", [NI(3, v + 8, 0, 0, 5, "")])
R(37, 310, (18, 21), "tanmien", "nộp 1 pháp bảo cho Tân Miễn (tự chuẩn bị)")
R(37, 310, 38, "tanmien", "nộp Liễu mộc cho Tân Miễn", [E(39)])
C(38, "Tứ Tượng")
for v in range(22, 26):
    R(38, 55, v, "thukho1020", "nộp 10 nguyên liệu cho Thủ Khố Tây Kỳ (cần 1 ô 2x2 trống)", [NI(3, v, 0, 0, 10, "")])

# ====================================================================== 9. su do (Tru Yeu, 4 trials) + Dong Di
C(51, "Trừ Yêu (sư môn)")
for cp in (0, 1, 2):
    R(51, 898, (1, 999), "vosu%d" % (1002 + cp), "tự hạ quái theo yêu cầu của Võ Sư (giữ hiệu ứng sư môn)", camp=cp,
      v2=897, lo2=1, hi2=999, kill=1)
    R(51, 898, 0, "vosu%d" % (1002 + cp), "về trả nhiệm vụ ở Võ Sư", camp=cp, v2=897, lo2=1, hi2=999)
C(52, "Thí luyện (sư đồ)")   # custom PTNV_X52: 899..902 values 1..5 -> maze doctor on the map of the step
C(53, "Đông Di")
R(53, 597, 0, "tontuvu", "nhận ở Tôn Tử Vũ", lv=70, st=1, lvmax=0)      # lvmax 0: never listed as "chua nhan"
R(53, 597, 1, "dangcuucong_dd", "trả lời câu hỏi của Đặng Cửu Công")
R(53, 597, 2, "dangcuucong_dd", "gặp Đặng Thiền Ngọc ở Tam Sơn")
R(53, 597, 3, "dangcuucong_dd", "hạ Lam Cốt rồi về Đặng Thiền Ngọc", kill=1)
R(53, 597, 4, "hoangphiho_sd", "mang Binh phù tới Hoàng Phi Hổ", [E(106)])
R(53, 597, 5, "lytinh", "trả lời Lý Tĩnh, giao Thông hành lệnh", [E(107)])
R(53, 597, 6, "bagiam", "gặp Bá Giám")
R(53, 597, 7, "bagiam", "nhờ Bá Giám làm Hộ thân phù (Ngọc Hư phù tự chuẩn bị, 10.000 lượng)",
  [NI(3, 79, 0, 0, 1, "")])
R(53, 597, 8, "bagiam", "giao Hộ thân phù cho Bá Giám", [E(108)])
R(53, 597, (9, 10), "dongdi1073", "gặp Ma Lễ Thọ và 3 anh em Ma Lễ")
R(53, 597, 11, "dangcuucong_dd", "về gặp Đặng Cửu Công")
R(53, 597, 12, "dongdi1073", "gặp Ma Lễ Thọ")
R(53, 597, 13, "dongdi1073", "hạ Phi Thố ở Khai Minh đảo (Thuyền Phu Trần Đường)", kill=1)
R(53, 597, 14, "dd_thieunu", "gặp Thiếu Nữ Di Tộc")
R(53, 597, 300, "dd_thieunu", "giao Quả nhân sâm cho Thiếu Nữ Di Tộc", [NI(3, 81, 0, 0, 1, "")])
R(53, 597, 15, "dd_bachdi", "gặp Bạch Di")
R(53, 597, 16, "dd_yenbaich", "gặp Yển Bá Ích")
R(53, 597, 299, "dd_yenthucdi", "gặp Yển Thúc Di")
LIEU = [NI(3, 73, 0, 0, 1, ""), NI(3, 74, 0, 0, 1, ""), NI(3, 75, 0, 0, 1, ""), NI(3, 76, 0, 0, 1, "")]
YP = [NI(1, 2, 0, 1, 3, ""), NI(1, 5, 0, 1, 3, "")]
R(53, 597, 17, "dd_lieunhan", "giúp Liễu Nhân và Yển Phong", LIEU + YP)
R(53, 597, 18, "dd_yenphong", "giao thuốc cho Yển Phong", YP)
R(53, 597, 20, "dd_lieunhan", "giao Mai, Lan, Trúc, Cúc cho Liễu Nhân", LIEU)
R(53, 597, 21, "dd_yenthucdi", "giao Tiên Thảo lộ, Hoàn Linh Đơn, 400 nguyên liệu cho Yển Thúc Di",
  [E(111), E(112), NI(3, 22, 0, 0, 100, ""), NI(3, 23, 0, 0, 100, ""), NI(3, 24, 0, 0, 100, ""), NI(3, 25, 0, 0, 100, "")])
R(53, 597, 22, "dd_yenthucdi", "xong việc Yển Long, Yển Hổ, Yển Lang rồi về Yển Thúc Di", kill=1)
R(53, 597, 23, "dd_yenbaich", "gặp Yển Bá Ích")
R(53, 597, 24, "dangcuucong_dd", "mang thư Yển Bá Ích tới Đặng Cửu Công", [E(109)])
R(53, 597, 25, "vovuong", "mang thư Đặng Cửu Công tới Trụ Vương và Võ Vương", [E(110)])
R(53, 597, 26, "dangcuucong_dd", "về gặp Đặng Cửu Công")
R(53, 597, 27, "vovuong", "gặp Võ Vương")
R(53, 597, 28, "khuongtunha", "gặp Khương Tử Nha")
R(53, 597, 29, "dd_yenbaich", "gặp Yển Bá Ích")
R(53, 597, 30, "dd_yenbaich", "mang 7 Mảnh pháp khí tới Yển Bá Ích", [E(114, 7)])
R(53, 597, 31, "khuongtunha", "giao 7 Mảnh pháp khí cho Khương Tử Nha", [E(114, 7)])
C(54, "Đông Di - Yển Long")
R(54, 589, 1, "dd_yenlong", "giao Di Tiên Tán cho Yển Long", [E(113)])
R(54, 589, (2, 21), "dd_yenlong", "hạ 20 Thiết Cốt ở Giai Mộng Quan", kill=1)
R(54, 589, 30, "dd_yenlong", "về gặp Yển Long")
C(55, "Đông Di - Yển Hổ")
R(55, 590, 1, "dd_yenho", "giao Di Tiên Tán cho Yển Hổ", [E(113)])
R(55, 590, (2, 21), "dd_yenho", "hạ 20 Huyết Yêu ở Giai Mộng Quan", kill=1)
R(55, 590, 30, "dd_yenho", "về gặp Yển Hổ")
C(56, "Đông Di - Yển Lang")
R(56, 591, 1, "dd_yenlang", "giao Di Tiên Tán cho Yển Lang", [E(113)])
R(56, 591, (2, 21), "dd_yenlang", "hạ 20 Thiết Tinh ở Thánh Địa", kill=1)
R(56, 591, 30, "dd_yenlang", "về gặp Yển Lang")
