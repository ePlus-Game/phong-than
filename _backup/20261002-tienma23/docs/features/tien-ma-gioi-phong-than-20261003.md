# Tiên Ma giới: bản đồ nội dung và giai đoạn 1 (đường vào, chủ tuyến bước 0–7, 3 nhiệm vụ phụ, 1 nhiệm vụ ngày)

> Dự án: Phong Thần (bản local) · Ngày: 2026-10-03 · Agent `tienma`
> Trạng thái: **Đã viết và mô phỏng xong, CHƯA triển khai lên runtime.** Lệnh chép file vào `Server\script\` bị chặn quyền trong phiên này; file nằm sẵn ở `scratchpad\tienma\out\`, chạy `python mk_tienma.py --deploy` để chép (xem Phần 3).
> Mô phỏng Lua 4: 40/40 kiểm tra đạt (`qtest\sim_tienma.lua` → `out_tienma.txt`). Scratch build ptfix đạt (`scratchpad\tienma\ptfix_test.pak`, 463 mục, `tienma stubs added: 15/15`).

## Phần 1: Tổng quan

### Insight chính
1. **Map Tiên Ma giới không lệch tên.** Kết luận "placeholder 1073–1075 lệch một map" của báo cáo kiểm toán là sai:
   - `taskinfo.ini` dùng số map VNG: 73 = Bất Chu Thiên Quan, 74 = Bất Chu Sơn, 75 = Ngục Pháp Sơn, 76 = Thánh Địa (ví dụ Task 1021 Xích Tinh Tử `(73,1992,3776)`, Task 109 Yển Bá Ích `(75,1889,3431)`).
   - Tên chữ Hán trong `WorldSet.ini` chỉ là **thư mục địa hình** mà VNG dùng lại: 1073 địa hình 佳梦关, 1074 địa hình 狱法山, 1075 địa hình 夷方部落, 1076 阪泉圣地.
   - Vì vậy tên placeholder (Tu Hành Sư, Đắc Kỷ, Liên Đăng Hộ Sứ trên 1073; Yển Thúc Di, Yển Bá Ích trên 1075) là **đúng** cho Tiên Ma.
   - Đông Di (`\script\东夷\*`, Bá Giám đưa tới `NewWorld(73,1615,3888)`) cũng nằm trên 1073, nhưng ở **túi đất phía tây nam không nối với khu chính** (kiểm tra lưới đi lại).
2. **Engine đã quy ước "cấp Tiên Ma = cấp nhân vật".** `GetPlayerExtLevel()` trả về cấp nhân vật, `AddOwnExtendExp()` cộng kinh nghiệm thường (`ScriptFuns.cpp` 11382, 11679). Giai đoạn 1 theo đúng quy ước này. Hệ quả: mọi mốc "cấp Tiên Ma 15/30/45…" đều mở ngay với nhân vật cấp 85+, nên **chơi một mình được**, chỉ bị chặn bởi thứ tự nhiệm vụ.
3. **Thiếu toàn bộ script NPC**, nhưng dữ liệu còn đủ để dựng lại:
   - `Npcs.txt` có đủ template (Tu Hành Sư 765, Linh Xà thụ 775, Linh Xà 806, Phi Thố 739, Ưu Trùng 808, Trạnh/Nanh 740/741, Phong Thú Sơn Hồn 750/751, Ly Châu 744/745…);
   - `taskinfo.ini` có chữ từng bước;
   - vài script vật phẩm VNG còn (叶子哨, 解咒符, 捕捉戾的葫芦, 25级仙魔品牌武器礼包) cho biết biến nhiệm vụ, vật phẩm và tọa độ.
4. **Dải biến 2220–2259 được giao bị VNG dùng một phần** (hệ linh thú `common_beast.luax`, `属性灵宠.luax`, `common.luax`, hộp quà). Giai đoạn 1 chỉ dùng 9 biến không ai dùng: 2222, 2223, 2242, 2245, 2252, 2254, 2256, 2258, 2259.

### Giai đoạn 1 đã làm (chơi một mình được)
| Nội dung | NPC | Kết quả |
|---|---|---|
| Đường vào Tiên Ma giới (cấp ≥ 75), chọn phe Tiên/Ma, đi/về | Tiếp Dẫn Đạo Nhân ở Tây Kỳ, Triều Ca, 2 doanh trại 1073 | Dịch chuyển tới doanh Tiên (1984/3800) hoặc doanh Ma (1622/3221) |
| Chủ tuyến 86/87/88 bước 0–7 (cấp ≥ 85) | Tiếp Dẫn → Tu Hành Sư → Đắc Kỷ → Tu Hành Sư → Linh Xà thụ → Linh Xà → Đắc Kỷ | Vũ khí Tiên Ma (84/85, 86, 87), thú cưỡi cấp 8 theo phái, 12 vạn tu luyện |
| 1024 Ưu Trùng Phụ Thể | Huyền Đô Đại Pháp Sư | 1 Phi Thố → 20 Ưu Trùng; 200.000 kinh nghiệm + 20.000 lượng |
| 1025 Phi Thố Cốt | Huyền Đô Đại Pháp Sư | 20 Phi Thố; 300.000 + 30.000 |
| 89 Phong Thú Sơn Hồn | Bạch Hạc Đạo Trưởng (Tiên) / Linh Nha Kiếm Tiên (Ma) | Trạnh Nanh → Tỏa Tinh Bàn → boss triệu hồi; 500.000 + 50.000 |
| 93/94 Nam Minh Ly Hỏa (ngày, 9 vòng) | Mộc Tra | Mỗi vòng 1 Ly Châu; cấp × 2.000 kinh nghiệm |

## Phần 2: Chi tiết

### 2.1 Bản đồ nội dung Tiên Ma giới (từ taskinfo + dữ liệu còn lại)
| Map (runtime / VNG) | Chủ tuyến 86–88 | Nhiệm vụ phụ / ngày | NPC chính (template) | Quái (template) |
|---|---|---|---|---|
| **1073 Bất Chu Thiên Quan** (73) | Bước 0–19: Linh Xà, Liên Hoa Thần Đăng (Tiên 8–14, Ma 15–19) | 89, 92 Trư Lung Thảo, 93/94, 95 Thiên Nhạc Diêm La (tổ đội 5), 96 Bất Diệt Đăng, 97 Bát Quái Luân Hồi, 98 Hoàng Kim Tàng Bảo Đồ (19–23h), 1021/1022 Chiến Kỳ (PK), 1023/1028 hoa, 1024, 1025, 1026 Hô Tiên Hoán Ma, 1027 Thiên Kiếp, 1030 Linh Quang, 1042, 1043 | Tu Hành Sư 765, Đắc Kỷ 164, Xích Tinh Tử 764, Cao Giác 774, Mộc Tra 763, Ma Lễ Thọ 773, Huyền Đô 779, Nữ Oa 780, Chúc Dung 781, Cửu Thiên Huyền Nữ 837, Liên Đăng Hộ Sứ 822, Bạch Hạc 761, Linh Nha 771 | Phi Thố 739, Trạnh/Nanh 740/741, Ưu Trùng 808, Khâm Nguyên 743/783, Ly Châu 744/745, Phong Thú Sơn Hồn 750/751, Liên Đăng sứ giả, Nguyên Thần 823–836 |
| **1074 Bất Chu Sơn** (74) | Bước 20–27: Hỏa thần/Thủy thần, Thiên Niên Đại Thạch → Thạch Quái | 99/100 Ngũ Sắc Hồn, 102 Thông lộ Ngục Pháp Sơn (Kỳ Bá, tổ đội), 103 Thiên Yết, 1031, 1032, 1033/1034, 1036, 1037, 1040/1041 | Hỏa thần 856, Thủy thần 857, Lộc Thần, Vô Ương Tử 842, Hồng Lư Đơn Khách 850, Nam Minh Tử 843, Ly Cấu Tôn Giả 849, Sơn Thần Hồng Bác 860 | Sói (噬狼 746/885), Phong Yêu 748/749, Thạch Quái 877, Thiên Yết |
| **1075 Ngục Pháp Sơn** (75) | Bước 28–46: Tứ Bất Tướng, La Bàn (Giải chú phù 6/1/518, biến 1465/1466), Cự Thú, Khương Tử Nha lúc nhỏ, hậu nhân Phục Hy | 104–113, 118, 119, 1077, 1078, 1080 Ngục Pháp Phong Yên, 1082–1085 | Yển Thúc Di 1009, Yển Bá Ích 1008, Mật thám Tiên/Ma 1013/1014, Tứ Bất Tướng | Cự Thú 1046, quái Ngục Pháp |
| **1076 Thánh Địa** (76) | Bước 47–50: Thiên Niên Ninh Vương, Lang Vương, Ngọc Bội | 115/116, 1086–1089, 1097/1098 | Tu Hành Sư, Dược Sư Tiên/Ma, Khương Ngu Tích, Cơ Huyền Phong | Ninh Vương, Lang Vương |
| Thành và map cũ | — | 90 Tu Tiên đạo (Xích Tinh Tử, Khổn Tiên Cung), 91 Nhập Ma (Cao Minh, Xi Vưu Mộ), 101, 117 | — | — |

- Các id 1029, 1035, 1038, 1039, 1044–1053, 1053–1058, 1059–1061, 1070–1076, 1081, 1090–1096 nằm trong dải 1021–1098 nhưng **không thuộc Tiên Ma**: lễ hội, Hoàng Thiên Hóa, Tinh Quan, Giang Sơn Y Cựu. Để cho các nhóm tương ứng.
- Script thiếu theo nametab: `不周天关` 62, `不周山` 47, `狱法山` 53, `阪泉圣地` 48, `祭渊谷` 9, cộng death script `npcdeath\仙魔\*` và `ontimer\*`. Trap nối map **có đủ**: 佳梦关↔狱法山↔夷方部落↔阪泉圣地↔流波山.

### 2.2 Thiết kế giai đoạn 1
- **Biến nhiệm vụ** (không đụng biến chính tuyến 1/2/3):

| Biến | Ý nghĩa |
|---|---|
| 2222 | Chủ tuyến: 0 chưa nhận, 1 = bước 0 … 7 = bước 7 (hết giai đoạn 1) |
| 2223 | 1024: 1 đánh Phi Thố, 2 diệt 20 Ưu Trùng, 3 phục mệnh, 4 xong |
| 2258 | 1025: 1 bắt 20 Phi Thố, 2 phục mệnh, 3 xong |
| 2242 | 89: 1 diệt Trạnh Nanh, 2 mang Tỏa Tinh Bàn, 3 đánh boss, 4 phục mệnh, 5 xong |
| 2245 | Ngày 93/94: ngày(6 số)×100 + vòng×10 + trạng thái |
| 2252 | Phe: 1 Tiên, 2 Ma |
| 2254 / 2256 | Đếm Ưu Trùng (1024) / Phi Thố (1025) |
| 2259 | Chỉ số NPC triệu hồi đang sống (Linh Xà / Phong Thú Sơn Hồn) |

- **NPC** (do `ext\tienma.lua` đặt và giữ sống mỗi phút):
  - **Tiếp nhận 3 placeholder trên 1073** đúng template và ô: Tu Hành Sư Tiên (765, 1996/3784), Tu Hành Sư Ma (765, 1612/3208), Đắc Kỷ (164, 1956/3304). Chỉ đổi tên hiển thị và script, không xóa gì. Không tìm thấy thì tự đặt NPC mới tại đúng ô đó.
  - **Đặt mới 9 NPC:** Tiếp Dẫn ×4 (1020 1476/3060, 1021 1776/3047, 1073 1970/3830 và 1630/3214), Linh Xà Thụ (1776/3600), Huyền Đô Đại Pháp Sư (1792/3612), Bạch Hạc (1964/3752), Linh Nha Kiếm Tiên (1603/3226), Mộc Tra (1980/3820). Mọi ô đều đi được và nối với doanh Tiên (`positions.py`).
  - **Không đụng:** Cửu Thiên Huyền Nữ, Liên Đăng Hộ Sứ, Tào Bảo, Huyền Đô placeholder ở túi tây nam, toàn bộ placeholder 1074–1076, mọi NPC Đông Di.
- **Quái nhiệm vụ:** 32 con trên 1073, tự hồi sinh tại chỗ, gắn `mob_kill.lua`, đánh dấu `GetNpcParam(npc,1) = 7701`.

| Đàn | Template, cấp | Vị trí |
|---|---|---|
| Phi Thố | 739, 72 | quanh 1720/3780 |
| Ưu Trùng | 808, 70 | quanh 1760/3700 |
| Trạnh / Nanh | 740 / 741, 74 | quanh 1865/3505 |
| Ly Châu | 745 / 744, 74 | quanh 1900/3655 |

- **Đếm quái:** dùng `LastDamage` của script gắn qua `SetNpcScript` (`KNpc.cpp:1718`, PlayerIndex là người được kinh nghiệm). Người giết và đồng đội cùng map đều được tính.
  - Boss/Linh Xà triệu hồi tự xóa qua `Timeout` 1 giây sau khi chết (không `DelNpc` trong hàm chết), hoặc sau 5 phút nếu bỏ đó. Chết/biến mất thì có thể gọi lại.
- **ptfix (`extra_tienma.py`)** thêm 15 mục còn thiếu ở mọi PAK, không thay mục nào đã có:
  - 9 stub đường dẫn VNG `\script\不周天关\{接引道人, 修行师, 修行师仙, 妲己, 灵蛇树, 玄都大法师, 白鹤道长, 灵牙剑仙, 木吒}.lua`, mỗi stub `Include` script rời tương ứng;
  - 6 death script trong `Npcs.txt` `\script\npcdeath\{戾, 优虫, 狰, 狞, 仙·离朱, 魔·离朱}.lua`: quái sinh tự động ở 1074/1075 cũng được tính cho nhiệm vụ. Quái đàn/triệu hồi (7701–7703) bỏ qua để không đếm hai lần.
  - Thứ tự plug-in không quan trọng (chỉ thêm mục mới).
- **Sổ F11:** `TaskNote(86+phái, bước)`, `TaskNote(1024/1025/89/93/94, …)` hiển thị chữ taskinfo qua `lib\vng_tasknote.lua`. Mô phỏng xác nhận chữ đúng từng bước.

### 2.3 Mô phỏng (`qtest\sim_tienma.lua`, PowerShell 32-bit) — 40 đạt / 0 lỗi
- **Tick:**
  - nhận 3 placeholder, không đụng placeholder khác;
  - đặt 12 NPC thoại và 32 quái;
  - tick lần 2 không đặt thêm; quái mất được đặt lại.
- **Đường vào:** cấp 70 bị từ chối; cấp 86 chọn phe Tiên → 1073; nhận vũ khí 86 một lần.
- **Chủ tuyến 1→7:**
  - Linh Xà hết giờ thì gọi lại được; giết xong được bước 6, NPC bị xóa;
  - hết ô trống thì chờ; bước 7 nhận thú cưỡi `0,10,1` cấp 8 và 120.000.
- **Nhiệm vụ phụ:**
  - 1024: 1 Phi Thố → 19 Ưu Trùng chưa đủ → 20 thì xong, thưởng 200.000;
  - 1025: 20 Phi Thố;
  - 89: boss 750; Phong Thú Sơn Hồn sinh tự động (không đánh dấu) không được tính; phục mệnh.
- **Ngày:** 9 vòng, vòng 10 bị từ chối.
- **Phe Ma, Giáp Sĩ:** về doanh Ma; chọn vũ khí dài 85; boss 751; về Triều Ca.
- **Stub death script** lấy từ `ptfix_test.pak`: Phi Thố sinh tự động trên 1075 được đếm; Phi Thố của đàn bị bỏ qua.
- **Hồi quy** `sim_questfix`, `sim_questaudit`, `sim_tta`, `sim_tutuong_b`, `t_st`: chạy xong, không FAIL, không lỗi nạp hoặc lỗi chạy. Chênh lệch so với base đến từ thay đổi runtime của agent khác; giai đoạn 1 chưa triển khai nên không ảnh hưởng.

## Phần 3: Hành động

### Triển khai (người dùng / coordinator)
1. Chép file (tạo mới, không ghi đè file nào; có sẵn backup vào `_backup\20261002-tienma\` nếu trùng):
   ```
   cd C:\Users\LICHNT~1.OFF\AppData\Local\Temp\claude\D--Project-Email-Send\d0824b0a-6cac-412d-8946-ef7c47e9c425\scratchpad\tienma
   python mk_tienma.py --deploy
   ```
   Tạo: `Server\script\phongthan\tienma\{tm_lib, mob_kill, npc_tiepdan, npc_tuhanhsu, npc_dacky, npc_linhxathu, npc_huyendo, npc_bachhac, npc_moctra}.lua` và `Server\script\phongthan\ext\tienma.lua`.
2. `servertimer.lua` **không cần sửa**: `PTAdm_ExtOne("tienma")` tự nạp `ext\tienma.lua` và gọi `PTEXT_tienma_Tick()` mỗi phút.
3. ptfix: `extra_tienma.py` đã nằm trong `scratchpad\ptfix\`. Lần build chính thức kế tiếp sẽ tự gộp. Phần chính chạy được cả khi chưa có ptfix mới.
4. Khởi động lại server theo cách thường lệ (người dùng tự làm).

### Checklist kiểm thử trong game
- [ ] Tây Kỳ (≈184/191) hoặc Triều Ca (≈222/190) có **Tiếp Dẫn Đạo Nhân**. Cấp < 75 bị từ chối; cấp ≥ 75 chọn phe rồi tới Bất Chu Thiên Quan.
- [ ] Cấp ≥ 85: "Nhận nhiệm vụ chủ tuyến Tiên Ma" → nhận vũ khí đúng phái, F11 hiện "Nhận được một vũ khí Tiên Ma giới…".
- [ ] Tu Hành Sư ở doanh Tiên (249/236) hoặc doanh Ma (201/200) có hội thoại mới (không còn "Vai tro va huong dan").
- [ ] Đắc Kỷ (244/206) → Tu Hành Sư → Linh Xà Thụ (222/225) "Thổi Diệp Tử Tiêu" → **Linh Xà** xuất hiện cạnh mình → giết → Đắc Kỷ → nhận thú cưỡi + kinh nghiệm.
- [ ] Huyền Đô Đại Pháp Sư (224/225): 1024 rồi 1025. Đàn Phi Thố ở ≈215/236, Ưu Trùng ≈220/231.
- [ ] Bạch Hạc Đạo Trưởng (245/234) hoặc Linh Nha Kiếm Tiên (200/201): Trạnh Nanh ở ≈233/219 → mở pháp trận → giết Phong Thú Sơn Hồn → phục mệnh.
- [ ] Mộc Tra (247/238): nhận vòng, giết Ly Châu (≈237/228), giao, lặp tới 9/9.
- [ ] Đi cùng tổ đội: đồng đội cùng map cũng được tính quái.
- [ ] Báo lại nếu NPC hoặc quái đứng vào chỗ không tới được, hay Linh Xà/boss không biến mất sau khi chết.

### Các giai đoạn sau (việc còn lại)
| Giai đoạn | Nội dung | Phụ thuộc / ghi chú |
|---|---|---|
| **2** (1073, phần còn lại) | Chủ tuyến bước 8–19 Liên Hoa Thần Đăng (6 đăng Tiên/Ma, Liên Đăng Sứ giả 821, đèn 874/875/819); 96 Bất Diệt Đăng; 97 Bát Quái (8 quẻ `item\卦卷\*` có sẵn); 1023/1028 hoa (792–795); 1026 Hô Tiên Hoán Ma (tháp 790/791, Nữ Oa); 1027 Thiên Kiếp (vật tổ 838/839, Nguyên Thần 823–836, Cửu Thiên Huyền Nữ); 1030, 1042, 1043; 92 Trư Lung Thảo (18 lượt nói chuyện, trận 811/812) | Đặt Xích Tinh Tử, Cao Giác, Chúc Dung, Nữ Oa, Ma Lễ Thọ (tránh trùng NPC 东夷\魔礼寿 của Đông Di), Thợ Đồng, Người hái thuốc |
| **3** (1074 Bất Chu Sơn) | Bước 20–27 (Hỏa thần 856/Thủy thần 857, Thiên Niên Đại Thạch 876 → Thạch Quái 877); 99/100, 103, 1031, 1032, 1033/1034, 1036, 1037, 1040/1041 | Thay 6 placeholder 1074; xác nhận trap 佳梦关→狱法山 nối 1073–1074 |
| **4** (1075 Ngục Pháp Sơn) | Bước 28–46 (Tứ Bất Tướng, 4 Pháp trụ, La Bàn, Giải chú phù 6/1/518 có script `item\解咒符.lua` dùng biến 1465/1466 và global 205–207, Cự Thú 1046, Khương Tử Nha lúc nhỏ); 104–113, 118, 119, 1077, 1078, 1082–1085 | **Phối hợp Đông Di:** 偃* của Ngục Pháp Sơn là `\script\狱法山\偃*.lua` (khác `\script\东夷\偃*.lua`); 104 nhắc "Bộ lạc Đông Di" |
| **5** (1076 Thánh Địa) | Bước 47–50; 115/116, 1086–1089, 1097/1098 | Thay 7 placeholder 1076 |
| **6** | 95 Thiên Nhạc Diêm La, 102 Thông lộ (tổ đội 5 người), 1021/1022 Chiến Kỳ, 1033/1034 (PK phe), 98 Minh Di 19–23h, 1080 Ngục Pháp Phong Yên | Cần cờ phe PK và lịch giờ; cân nhắc nới điều kiện tổ đội cho người chơi một mình |
| Ngoài phạm vi | 90/91 (Khổn Tiên Cung), quái sinh tự động 750/751 trên 1073 (374 con Phong Thú Sơn Hồn đáng ra là boss riêng), cấp Tiên Ma thật (tách khỏi cấp nhân vật) | Quái là dữ liệu của coordinator (`spawn_1073.lua`); cấp Tiên Ma riêng cần C++ |

## Phần 4: Tài liệu tham khảo
- **Mã nguồn sinh** (scratchpad `tienma\`):
  - `lua_src.py` (nội dung Lua tiếng Việt), `mk_tienma.py` (đổi sang TCVN3 và triển khai), `positions.py` → `positions.json` (ô đi được);
  - `taskinfo_tm.txt` (taskinfo 86–119, 1021–1098 đã giải mã), `nametab_tm.txt` (script Tiên Ma có/thiếu), `regnpc.py` (placeholder 1073–1076: template, ô, tên).
- **Plug-in:** `scratchpad\ptfix\extra_tienma.py`; scratch build `scratchpad\tienma\ptfix_test.pak`.
- **Mô phỏng:** `scratchpad\qtest\sim_tienma.lua` → `out_tienma.txt`; `tm_stub_death.lua` (stub lấy từ PAK thử).
- **Engine:**
  - `KNpc.cpp` 1696–1720 (LastDamage cho người giết), 1866–1885 (DeathScript/DeathSelf/hồi sinh), 842 (Timeout);
  - `ScriptFuns.cpp` 11382 (`GetPlayerExtLevel` = cấp), 11679 (`AddOwnExtendExp`), 4056 (`AddNpc` 6 tham số).
- **Liên quan:**
  - `scratchpad\questaudit\quest_audit.md` mục 2.4, 2.12;
  - `kiem-toan-nhiem-vu-phong-than-20261002.md`, `nhiem-vu-chinh-tuyen-phong-than-20260928.md`, `quai-cac-ban-do-phong-than-20260928.md`;
  - tài liệu Đông Di của agent `sudo_dongdi` (`su-do-dong-di-phong-than-20261003.md`, chưa có lúc viết).
