# Tân thủ đời mới: Quân Sư, Mao Lư, Thí luyện, Trừ yêu và Mật tịch

> Dự án: Phong Thần (bản local) · Ngày: 2026-10-03 · Người làm: agent newbie2
> Trạng thái: **Đã viết xong, mô phỏng đạt 161/161.** Phần NPC/quái chạy qua ext tick (`script\phongthan\ext\newbie2.lua`), servertimer tự nạp ở phút kế tiếp. Riêng 14 mật tịch cần bản ptfix mới (plug-in `extra_newbie2.py`, bản build thử đạt) rồi khởi động lại server.

## Phần 1: Tổng quan

- **Vấn đề:** chuỗi tân thủ đời mới của VNG (taskinfo 894–925, 999–1010, 3003–3005) chỉ còn chữ trong `taskinfo.ini`.
  - Không có script NPC nào gọi các nhiệm vụ này.
  - 14 mật tịch / lệnh (vật phẩm 6/1/303–309, 350–356) trỏ tới file tên tiếng Trung để rời trên đĩa. Engine không mở được loại file này, nên bấm chuột phải không có tác dụng.
  - Kể cả khi nhận được, cũng không có chỗ nào đếm quái hay trả thưởng.
- **Cách làm (chỉ Lua và ptfix, không sửa C++):**
  - Đặt NPC **Quân Sư (Tân thủ)** ở 3 thôn, đúng tọa độ taskinfo 3003–3005. Đây là nơi nhận chuỗi nhiệm vụ.
  - Các bước "đi gặp NPC" tự hoàn thành khi người chơi **đứng sát NPC đó** (trong khoảng 5 ô). Không cần sửa script của NPC cũ.
  - Quái mục tiêu được gắn script đếm riêng `nb2_mob.lua`. Script này **gọi lại `mob_drop.lua` trước**, nên đồ rơi của chuỗi 2004 vẫn giữ nguyên.
  - Mật tịch có script mới, nằm trong ptfix tại đúng đường dẫn tiếng Trung.
  - Sổ nhiệm vụ F11 dùng đúng id taskinfo, hiện chữ thật qua `PTTaskNote`.
- **Hai chuỗi cùng tồn tại (đã chọn): chạy song song, độc lập.**
  - Chuỗi 2004 (task 1–50, NPC `npc_fix`) và quà tân thủ `starter_gear.lua` (task 1950) **không bị đụng tới**.
  - Chuỗi mới là **lựa chọn thêm**: người chơi tự đến Quân Sư nhận Mao Lư, làm cả hai chuỗi cùng lúc cũng được.
  - Chuỗi mới chỉ ghi task 2180–2219.
  - Một con quái có thể tính cho cả hai chuỗi (ví dụ Kiếm Nhân vừa rơi Đoản Kiếm cho task 21, vừa đếm cho 907).
- **Không làm:** 894 (Khảo nghiệm điện Phong Thần) và 908 (Phương pháp mới) là nhiệm vụ công trình lãnh địa (type=2). Hai nhiệm vụ này cần bang hội có thành; hệ thống công thành chưa dựng (kiểm toán mục 14).

## Phần 2: Chi tiết

### 2.1 Chuỗi theo phái (thứ tự tự động; nhiệm vụ kế tiếp tự nhận khi đủ cấp)

| Phái | Chuỗi taskinfo |
|---|---|
| Giáp Sĩ (1002) | 909 Mao Lư → 907 Thí luyện (8 Kiếm Nhân) → 906 Cẩn thận (cấp 3) → 904 Cần Mẫn (cấp 6, bí kíp Tế Huyết Trảm) → 905 Mưu Lược (gặp Triều Điền khi cấp 10) → 903 Trừ yêu (cấp 10) → 902 Phản quân kế (cấp 14) |
| Đạo Sĩ (1003) | 897 Mao Lư → 896 Thí luyện (8 Tuyết Quái) → 895 Khảo nghiệm mới (cấp 3) → 910 Cần Mẫn (Chưởng Tâm Lôi) → 911 Tịnh tâm (gặp Nhiên Đăng khi cấp 10) → 912 Trừ yêu (cấp 10) → 913 Băng Lang (cấp 14) |
| Dị Nhân (1004) | 1000 Mao Lư → 1001 Thí luyện (8 Hỏa Diện) → 999 Hóa giải (cấp 3) → 1002 Hòa thuận → 1003 Cần Mẫn (cấp 4, Lực Sĩ Tế) → 1006 Gian khổ (gặp Phong Bá khi cấp 10) → 1004 Trừ yêu (cấp 10) → 1007 Lục Quái (cấp 14) |
| Chung (taskinfo playertype 0) | 898 Sinh Hoạt Sư (cấp 20) → 901 Giải nguy (Dị Nhân: 1005, cấp 21) → 900 Trừ họa (cấp 21) → 899 Trữ hàng (cấp 22; Dị Nhân làm 1008 trước, sau đó nối vào 899 từ bước Triều Ca) |

### 2.2 Cơ chế từng loại bước

| Loại bước | Ví dụ | Cách chạy |
|---|---|---|
| Gặp NPC | Mao Lư, Cẩn thận, Khảo nghiệm, Giải nguy | Đứng sát NPC (\|dx\| ≤ 5, \|dy\| ≤ 10 ô). Quân Sư kiểm tra 3 giây một lần, ext tick kiểm tra 1 phút một lần |
| Gặp NPC + cấp | Mưu Lược, Tịnh tâm, Gian khổ | Như trên, nhưng chỉ tính khi đủ cấp 10. Gian khổ đổi dòng F11 sang bước 2 khi vừa đủ cấp |
| Bí kíp | Cần Mẫn 904/910/1003 | Có bí kíp trong túi (6/1/62027, 62003, 62450) hoặc đã học kỹ năng. Mua ở Quân Sư → "Mua bí kíp hệ phái" (Sale 66/67/68) |
| Đánh quái | Thí luyện | Đếm khi người chơi giết quái đúng template (bất kỳ bản đồ) |
| Trừ yêu | 903/912/1004 | Ra bản đồ dã ngoại (1005–1019): rương mở, 4 Yêu Ma (template 573) hiện quanh người chơi. Chỉ chủ nhân giết mới tính. Sau 10 phút không giết thì Yêu Ma biến mất và được thả lại |
| Vương | 913 Băng Lang, 1007 Lục Quái | Cứ 12 con thường thì hiện 1 Vương (606 / 607). Hàng phục 3 Vương |
| Phản quân kế | 902 | 12 Hoàn Cẩu (Yến Sơn hoặc Mạnh Tân) → Hoàn Cẩu Vương (575). Giết Vương nhận Lệnh bài, hiện Hoàn Cẩu Soái (577) và Hoàn Cẩu Tinh (576). Giết cả hai thì xong |
| Thu thập (vật phẩm ảo) | 1002 Sách rách / Tuyến quyển, 900 Hạp Đằng / Nguyên Sâm / Sơn Xuyên Liễu, 899/1008 hàng hóa | Đánh quái ở bản đồ ghi trong taskinfo, rơi theo tỉ lệ 50–60%. Số lượng giữ trong biến nhiệm vụ, không chiếm ô túi |
| Trả nhiệm vụ | Bước "phục mệnh" sau đánh quái | Đứng sát NPC trả trong taskinfo, **hoặc** bấm Quân Sư → "Báo cáo hoàn thành nhiệm vụ" |

- Phần thưởng: kinh nghiệm, bạc, bình máu/nội lực nhỏ (1,0,1 / 1,3,1). Trừ yêu và nhiệm vụ cấp 14 tặng thêm 1 mật tịch.
  - Thưởng được phát bằng `QuestExchange` trên biến bước. Túi đầy thì không mất gì; nhiệm vụ chờ tới lần kiểm tra sau.
- NPC thiếu trên bản đồ đã được đặt thêm:
  - Đại phu Tam Sơn (1016, ô 1511/3122);
  - Đại phu Đồng Quan (1014, ô 1368/3106).
  - Cả hai ô đều đi được theo Region_S, cạnh cổng vào. NPC có menu "Trị thương".

### 2.3 Mật tịch / Lệnh (914–925, 1009, 1010)

| Vật phẩm | Taskinfo | Quái (template) | Số lượng |
|---|---|---|---|
| 6/1/303 Kiếm Nhân | 918 | 0 | 20 |
| 6/1/304 Hoàn Cẩu | 914 | 7 | 30 |
| 6/1/305 Hỏa Diện | 1009 | 2 | 20 |
| 6/1/306 Thảo Tiên | 1010 | 9 | 30 |
| 6/1/307 Tuyết Quái | 915 | 1 | 20 |
| 6/1/308 Yểm Hỏa | 916 | 8 | 30 |
| 6/1/309 Thu thập | 917 | Nộp 2 nguyên liệu theo phái (Mảnh Giáp/Đoản Kiếm, Ngọc Cốt/Băng Cơ, Mặt Quỷ/Hỏa Vũ) | 2 |
| 6/1/350 Cổ Điêu | 925 | 10 (Đồng Quan) | 30 |
| 6/1/351 Cốt Tinh | 919 | 11 | 30 |
| 6/1/352 Ngưu Sát | 921 | 12 (Đồng Quan) | 30 |
| 6/1/353 Giáp Cốt | 920 | 13 | 30 |
| 6/1/354 Hắc Phong | 922 | 18 (Tam Sơn) | 30 |
| 6/1/355 Dạ Xoa | 924 | 15 | 30 |
| 6/1/356 Giang Quy | 923 | 24 | 30 |

- **Nguồn mật tịch:**
  - Rơi 1% mỗi lần giết đúng quái, khi chưa có trong túi và người chơi không quá cấp quái + 15.
  - Thưởng của chuỗi chính.
- **Dùng:** bấm chuột phải → "Đồng ý" thì vật phẩm mất và bắt đầu đếm. Mỗi mật tịch chỉ chạy một lần tại một thời điểm; các loại khác nhau chạy song song được.
- **Trả:** đứng sát Tạp hóa Thương (1002/1003/1004/1020/1021), hoặc bấm Quân Sư → "Trả nhiệm vụ Mật tịch / Lệnh".
  - Thưởng: kinh nghiệm = số lượng × cấp quái × 80; bạc = số lượng × cấp quái × 15; thêm 2 bình máu.
- Khi "Thu thập" đang chạy, quái nguyên liệu rơi thêm nguyên liệu với tỉ lệ 35%, tối đa đủ 2 cái.

### 2.4 Biến nhiệm vụ (dải newbie2 2180–2219)
- Đã quét script rời và mọi script trong PAK. Các id 2181–2183, 2186–2190, 2193, 2196–2200, 2203, 2206, 2209, 2212–2219 có trong các script VNG tên tiếng Trung (lễ bao, thú cưng…). Những file này không chạy được, nhưng vẫn **tránh dùng** các id đó.

| Task | Ý nghĩa |
|---|---|
| 2180 | Vị trí trong chuỗi của phái (0 = chưa nhận, n+1 = xong cả chuỗi) |
| 2184 | Bước của nhiệm vụ hiện tại (0 = chờ đủ cấp) |
| 2185 / 2191 / 2192 | Bộ đếm của bước hiện tại |
| 2194 | Cờ (bit 1 = đã hiện gợi ý 3003–3005 trong F11) |
| 2205 | Thời điểm (frame) thả Yêu Ma / Vương gần nhất |
| 2195, 2201, 2202, 2204 | 14 mật tịch, mỗi cái 1 byte (0 = không có, 1 + số quái = đang làm) |

### 2.5 Gắn script đếm cho quái
- Template được gắn: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 18, 24.
- Phạm vi gắn:
  - quái của `spawn_main.lua` (danh sách `PT_SPAWN_NPCS`);
  - quái gốc VNG ở Đồng Quan 1014 (Cổ Điêu, Ngưu Sát) và Tam Sơn 1016 (Hắc Phong, Dạ Xoa, Cốt Tinh).
- Quái nhiệm vụ của `PTADM_MOB_SPAWN` (template ≥ 100) và NPC của agent khác **không bị đổi script**.
- Đã soát `ext\sudo_dongdi.lua` (chỉ gắn template 44/421–423 ở 1044–1072) và `ext\daily2.lua` (chỉ gắn quái tự đặt): không trùng.
- Gắn lần đầu ngay khi `PT_SPAWN_DONE`, sau đó quét lại 30 phút một lần.

### 2.6 Tệp
| Tệp | Vai trò |
|---|---|
| `Server\script\phongthan\ext\newbie2.lua` | `PTEXT_newbie2_Tick`: ReLoadScript, đặt 3 Quân Sư + 2 Đại phu, gắn quái, kiểm tra người chơi mỗi phút |
| `Server\script\phongthan\newbie2\nb2_lib.lua` | Toàn bộ logic: nhận, bước, thưởng, gần NPC, quái tạm, mật tịch |
| `Server\script\phongthan\newbie2\nb2_data.lua` | Dữ liệu nhiệm vụ, chữ TCVN3 (sinh bằng `scratchpad\newbie2\gen_nb2.py`, không sửa tay) |
| `Server\script\phongthan\newbie2\quan_su.lua` | Hội thoại Quân Sư + `OnTimer` (kiểm tra 3 giây/lần) |
| `Server\script\phongthan\newbie2\nb2_dp.lua` | Đại phu Tam Sơn / Đồng Quan |
| `Server\script\phongthan\newbie2\nb2_mob.lua` | Script của quái: đếm, gọi `mob_drop.lua`, xóa quái tạm |
| `Server\script\phongthan\newbie2\nb2_scroll.lua` | Dùng mật tịch |
| `scratchpad\ptfix\extra_newbie2.py` | 14 stub tại đường dẫn tiếng Trung của mật tịch |
| `scratchpad\qtest\sim_newbie2.lua` (+ `sim_nb2_npcs.lua`) | Mô phỏng |

## Phần 3: Hành động

### Cài đặt (chủ server / điều phối)
- [ ] Build ptfix chính thức có `extra_newbie2.py` (bản thử: `scratchpad\newbie2\ptfix_test.pak`, 491 mục, 14/14 stub), cài vào `Server\data`, khởi động lại server.
- [ ] Phần NPC/quái không cần build: servertimer tự nạp `ext\newbie2.lua` ở phút kế tiếp.
- [ ] Mật tịch Cần Mẫn cần tiệm bí kíp (ptfix v16 của agent bikip) đã cài.

### Kiểm thử trong game
1. [ ] Tạo nhân vật Giáp Sĩ mới. Trong vòng 1 phút, F11 có dòng "Nhiệm Vụ Tân Thủ: Đến … Quân Sư (Tân thủ) …". Gặp Quân Sư ở Sùng Thành [204,200] → "Nhận nhiệm vụ Mao Lư".
2. [ ] Đứng cạnh Tạp hóa Thương [207,198]: trong vài giây có thông báo, F11 chuyển sang "đến gặp Thủ khố". Đứng cạnh Thủ khố: Mao Lư hoàn thành, nhận 300 kinh nghiệm, 500 lượng, 3+3 bình. Thí luyện tự nhận.
3. [ ] Ra Sùng Thành dã ngoại giết 8 Kiếm Nhân: F11 hiện "Tiến độ hiện tại: Kiếm Nhân (n/8)". Về Tạp hóa Thương (hoặc Quân Sư → Báo cáo) để trả.
4. [ ] Kiểm tra chuỗi cũ: nhận Tân Thức ở Lỗ Hùng, giết Kiếm Nhân vẫn nhặt được Đoản Kiếm.
5. [ ] Lên cấp 10, làm Trừ yêu: ra bản đồ dã ngoại, trong 3 giây có 4 "Yêu Ma" quanh nhân vật. Giết hết rồi về Triều Điền.
6. [ ] Cấp 14, Phản quân kế: ở Yến Sơn giết 12 Hoàn Cẩu → Hoàn Cẩu Vương xuất hiện → giết → Soái và Tinh xuất hiện → giết cả hai.
7. [ ] Đạo Sĩ: Băng Lang (12 con ra 1 Vương, cần 3 Vương). Dị Nhân: Hòa thuận (Sách rách, Tuyến quyển), Lục Quái.
8. [ ] Mật tịch: dùng lệnh admin tặng 6/1/304, bấm chuột phải → Đồng ý → giết 30 Hoàn Cẩu → đứng cạnh Tạp hóa Thương: nhận thưởng, F11 hiện "Nhiệm vụ hoàn thành".
9. [ ] Cấp 21–24: Trừ họa đi Mạnh Tân → Tam Sơn → Đồng Quan (Đại phu mới đặt). Trữ hàng đi Sùng Thành → Triều Ca → Tây Kỳ → Ngọc Hư.
10. [ ] Nếu bước "gặp NPC" không tự qua: xem `Server\admin_bridge\newbie2_error.log` và `result.log` (dòng `newbie2 OK bound N monsters`).

### Giới hạn đã biết
- Bộ hẹn giờ 3 giây chạy trên NPC Quân Sư. Nếu engine không xử lý NPC ở vùng không có người chơi, việc kiểm tra rơi về ext tick, nên chậm tối đa 1 phút.
- Người khác giết Yêu Ma / Vương của mình thì không tính. Phải chờ 10 phút để quái được thả lại.
- Vật phẩm thu thập của 1002/899/900/1008 là vật phẩm ảo (đếm trong biến). Bản này không có vật phẩm VNG tương ứng và không có bụi cỏ hái được.
- Bước "gặp NPC" tính theo vị trí, không theo lần bấm vào NPC. NPC cũ vẫn mở hội thoại cũ của chúng.

## Phần 4: Tài liệu tham khảo
- Taskinfo: `\ui\ui3\taskinfo.ini` (bản dump `scratchpad\newbie2\ti_full.txt`); F11: `he-thong-nhiem-vu-f11-phong-than-20260928.md`.
- Chuỗi 2004: `hoi-thoai-npc-tan-thu-phong-than-20260928.md`, `nhiem-vu-chinh-tuyen-phong-than-20260928.md`, `roi-vat-pham-nhiem-vu-phong-than-20260929.md` (`mob_drop.lua`).
- Kiểm toán: `kiem-toan-nhiem-vu-phong-than-20261002.md`, `scratchpad\questaudit\quest_audit.md` mục 2.2.
- Bí kíp: `bi-kip-he-phai-phong-than-20261002.md` (Sale 66/67/68, vật phẩm 6/1/62000+kỹ năng).
- Engine: `KNpc.cpp` (LastDamage, Timeout, OnTimer), `ScriptFuns.cpp` (SetNpcTimer, SetNpcParam), `PhongThanQuestExchange.inl`.
