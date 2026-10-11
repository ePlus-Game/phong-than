# Công thành / Lãnh địa: chế độ "lãnh địa cá nhân" cho người chơi solo

> Ngày: 2026-10-03 · Agent `congthanh`
> Phạm vi: nhiệm vụ lãnh địa (30, 31, 34, 69, 78, 79), lính đánh thuê và sát thủ (850–874), tân thủ đời mới 894 (Khảo nghiệm điện Phong Thần) và 908 (Phương pháp mới).
> Nguồn gốc: kiểm toán nhiệm vụ mục 14 (`S\questaudit\quest_audit.md`) và `tan-thu-moi-phong-than-20261003.md` (894/908 để lại).
> Trạng thái:
> - Lua đã nằm trong runtime nhưng **chưa bật**. Cần coordinator thêm tên ext `congthanh` và deploy ptfix mới.
> - Bản vá C++ là **tùy chọn**, chưa áp dụng.

## Phần 1: Tổng quan

### Insight chính

1. **Hệ thống bang hội của server này chết từ gốc, không phải thiếu script.**
   - GameServer không bao giờ nối tới máy chủ bang hội: `m_pTongClient = NULL` ở `KSOServer.cpp:438` và không được gán lại ở đâu.
   - Relay đang chạy (`PhongThanRelay.exe`) không có mã bang hội.
   - Hệ quả: lệnh tạo bang bị bỏ qua và không ai có bang. Mọi hàm Lua dạng "bang/thành" trả 0.
   - Không có map công thành nào: `MapList.ini` / `WorldSet.ini` không có 夏日/秋风/红叶/黄沙/黑暗之城.
   - Dù relay có chạy, `citywar.ini` vẫn đòi 60 thành viên và bang cấp 18. Đây là thiết kế cho nhóm, không thể chơi solo.
2. **Phần lõi nhiệm vụ lãnh địa VNG vẫn còn đủ trong PAK, chỉ thiếu "chủ thành".**
   - 4 script công trình chứa toàn bộ nhiệm vụ: `即时国战\神殿` (Điện Phong Thần: 894, 34), `兵营` (Trại lính: 850–874), `炼丹炉` (Phòng luyện thuốc: 908, 30), `靶场` (Thao trường: 31).
   - Chúng chỉ hỏi vài câu: "người này có sở hữu thành không" (`IsOwnerCity`), "công trình đã xây chưa" (`GetBuildingState`), "biến thành thị" (`GetCityTask`/`SetCityTask`), "cống hiến" (`GetTongContri`), "cấp thành" (`GetCityInfo`).
   - Phần đếm quái cho 894 và lính đánh thuê **đã chạy sẵn** trong `npc_quests\normal.lua`.
3. **Giải pháp: "lãnh địa cá nhân", Lua-only.**
   - Người chơi tự lập lãnh địa ở *Lãnh địa quan* (Tây Kỳ). Trạng thái lãnh địa nằm trong task riêng của nhân vật (2430–2479).
   - Một lớp API Lua (`ct_api.lua`) được nối vào cuối 4 script VNG qua ptfix. Lớp này trả lời các câu hỏi trên từ task của người chơi.
   - Kết quả: **script VNG chạy nguyên bản**: cùng bước, cùng phần thưởng, cùng chữ taskinfo trong F11.
4. **69, 78, 79 không có mã VNG** (script công trình là stub hoặc thiếu hẳn). Ba nhiệm vụ này được viết mới theo chữ taskinfo, bản solo.
5. **C++ không bắt buộc.** Bản vá đã soạn chỉ thêm native "chế độ bang hội" cho 8 hàm còn thiếu. Nó trơ (trả 0) khi không có bang, và Lua tự nhận biết có hay chưa có bản vá.

### Nhận định quan trọng

- 894/908 nay làm được: 894 đi hết 5 bước trong mô phỏng; 908 cần hạ boss thế giới **Cửu Anh** (bước 1, theo VNG).
- Nhiệm vụ lính đánh thuê đi đủ 3 loại × 4 cấp (Truy sát, Thu thập, Đưa tin). Riêng nhiệm vụ PK của VNG cũng chỉ là khung rỗng.
- Tỷ lệ solo đã chỉnh (xem 2.4). Mốc gốc của VNG (1.000–20.000 lượt lính đánh thuê cho cả bang) đổi thành 20–150 lượt cho một người.

## Phần 2: Chi tiết

### 2.1 Hệ thống VNG cần gì

| Công trình (NPC) | Script VNG (PAK) | Nhiệm vụ | Hàm "lãnh địa" script gọi |
|---|---|---|---|
| Điện Phong Thần | `\script\即时国战\神殿.lua` d2683bb5 | 894 Khảo nghiệm (5 bước, cấp 30), 34 Hoa thần bí (ngày, 5 + 15 lượt) | IsOwnerCity, GetBuildingState, BuildingOperator, IsHaveTongRight, AddCityIndexRes(1), AddTongContri, Msg2TongMember, DestroyBuilding |
| Trại lính đánh thuê | `\script\即时国战\兵营.lua` ad7f1d51 | 852–874 Sát thủ / Thu thập / Đưa tin C.1–4 | + GetCityInfo (cấp thành), GetCityTask/SetCityTask (biến 21–38) |
| Phòng luyện thuốc | `\script\即时国战\炼丹炉.lua` 17c5b8e1 | 908 Phương pháp mới (cấp 40, cống hiến ≥ 100), 30 Luyện tiên đơn | + GetTongContri, AddCityIndexRes(2) |
| Thao trường | `\script\即时国战\靶场.lua` 8448eaa4 | 31 Thao trường thí luyện (cần Đại phu dã ngoại báo gián điệp) | + AddTongAttr(0,1) |
| Sân luyện thú | `怪物牧场.lua` (stub) | 69 Trừ ma | không có mã nhiệm vụ |
| Phòng chiến xa | `兵工厂.lua` (stub) | 78 Thu thập Xích Đồng Thảo | không có mã nhiệm vụ |
| Hý viện | `戏院.lua` **thiếu** | 79 Điệp báo (thâm nhập thành bang khác) | — |
| Mở khóa công trình | `OnBuild` (script 4fb5f518) | cần số lượt lính đánh thuê theo loại (biến thành thị 21–36) | GetCityTask |
| Hoa thần Cửu Di (15 map) | `\script\神秘花卉任务\任务-<map>.lua` | 34: tìm hoa | VNG di chuyển hoa bằng `DelNpc(DialogNpcIdx)` + `AddNpc` 5 tham số, nên lỗi |

**Lịch công thành VNG:**
- `systemtimetask` (engine không đọc).
- Sự kiện "quái công thành cấp 4": script thiếu.
- `IsInMonsterAttackDay` (C++ Wave 8) trả thứ Tư / thứ Bảy.

Không có phần nào chạy được khi không có bang.

### 2.2 Hàm Lua: đã có và còn thiếu

| Hàm | Trạng thái trước | Sau thay đổi |
|---|---|---|
| IsOwnerCity, GetCityInfo, Msg2TongMember, AddTongAttr | C++ (Wave 8, Carriage), trả 0 khi không có bang | Lua ghi đè trong 4 script công trình; native vẫn là đường dự phòng |
| GetCityTask, SetCityTask, AddCityIndexRes, GetOwnCityLevel, GetTongContri | **Thiếu** (script dừng lỗi) | Lua; native trong bản vá C++ (tùy chọn) |
| IsHaveTongRight, AddTongContri, GetBuildingState, BuildingOperator | Stub `pt_compat` (0 / không làm gì) | Lua; IsHaveTongRight / AddTongContri cũng có native trong bản vá |
| DestroyBuilding | Thiếu | Lua (lãnh địa cá nhân không phá công trình) |
| SetByte/GetByte/GetBit/SetBit, HaveNormalItem, DelNormalItem, GetItemLevel2, DelItem2, HaveIBBuff, RemoveIBBuff, FindAValidIBItem, CostIBItem, MsgBox, Say, SayTask | C++ có | — |

**Lỗi engine phát hiện thêm:** `LuaSelectUI` cắt "nhãn/hàm" ở dấu `/` **đầu tiên**.
- Nhãn VNG như "N/v lính đánh thuê" sẽ gọi một hàm tên "v lính đánh thuê…", nên menu chết.
- `ct_api.lua` đổi `/` trong nhãn thành `.` (Say, SayTask, BuildingOperator), chỉ trong 4 script công trình.
- Các script VNG khác có nhãn chứa `/` cũng bị lỗi này. Ngoài phạm vi, đề xuất xử lý chung trong `pt_compat.lua`.

### 2.3 Bang hội có dùng được không?

Không. Chi tiết:
- **Tạo bang:** `KPlayerTong::CheckCreateCondition` cho phép tạo một mình (cấp 60, 2.000 vạn lượng, vật phẩm 195, danh vọng 300, phúc duyên 500). Nhưng gói tin gửi qua `m_pTongClient`, mà biến này luôn NULL, nên bị vứt.
- **Dữ liệu bang:** BerkeleyDB `TongDB` của S3Relay cũ không còn được ghi từ 2026-09-04.
- **Sở hữu thành:** chỉ có qua Lua `LoadTongMap`. `danhsachthanhthi.lua` gắn map 1 cho bang "Tuyệt Kiếm" (một phát hiện phụ: người không cùng bang phải chịu thuế +15% ở cửa hàng).
- **Client:** có giao diện bang (UiTongManager…), không có giao diện thành/công thành.

### 2.4 Thiết kế lãnh địa cá nhân

**Task (đã kiểm tra trống trong script rời và script PAK; engine giữ 4800+):**

| Task | Ý nghĩa |
|---|---|
| 2430 | 1 = đã lập lãnh địa |
| 2431 | Cấp thành thị 1–4 |
| 2432–2435 | Tài nguyên: Hương liệu (từ Hoa thần bí), Gỗ (Luyện tiên đơn), Xích đồng (78), Lương thảo (69) |
| 2436 | Cống hiến cá nhân (`GetTongContri` / `AddTongContri`) |
| 2437 / 2438 | Hưng thịnh (`AddTongAttr` loại 0) / các loại khác |
| 2439 | Ngày thu thuế |
| 2440–2446 | Công trình 1–7 đã xây |
| 2447 | Ngày lập lãnh địa |
| 2448 / 2449 | Ngày và số điểm quyên góp |
| 2450–2467 | Biến thành thị VNG 21–38: 21–36 số lượt lính đánh thuê theo loại, 37 ngày reset, 38 seed ngày |
| 2468–2470 | 69 (vật phẩm/số lượng, ngày, số lượt) |
| 2471–2473 | 78 (đang làm/số bụi, ngày, số lượt) |
| 2474–2476 | 79 (bước, ngày, số lượt) |
| 2477 / 2478 | Trạm dịch đưa thư: ngày, số thư |
| 2479 | Thời điểm thao tác bụi cỏ gần nhất (chống spam) |

**Lập lãnh địa:** cấp ≥ 20, nộp 100.000 lượng, tặng 20 cống hiến.

**Công trình** (xây ở Lãnh địa quan, trả bằng ngân lượng):

| # | Công trình | Mở ở cấp | Giá (lượng) | Nhiệm vụ |
|---|---|---|---|---|
| 1 | Điện Phong Thần | 1 | 50.000 | 894, 34 |
| 2 | Trại lính đánh thuê | 1 | 50.000 | 850–874 |
| 3 | Sân luyện thú | 1 | 30.000 | 69 |
| 4 | Phòng chiến xa | 1 | 30.000 | 78 |
| 5 | Phòng luyện thuốc | 2 | 100.000 | 908, 30 |
| 6 | Thao trường | 3 | 150.000 | 31 |
| 7 | Hý viện | 4 | 200.000 | 79 |

**Nâng cấp thành thị** (cống hiến và số lượt lính đánh thuê chỉ cần đạt; tài nguyên và ngân lượng bị trừ):

| Lên cấp | Cấp nhân vật | Cống hiến | Lượt lính đánh thuê | Hương liệu | Gỗ | Ngân lượng |
|---|---|---|---|---|---|---|
| 2 | 40 | 50 | 20 | 5 | 0 | 300.000 |
| 3 | 50 | 150 | 60 | 15 | 5 | 600.000 |
| 4 | 60 | 300 | 150 | 30 | 15 | 1.000.000 |

Cấp thành thị quyết định cấp nhiệm vụ sát thủ được mở: Sát thủ C.k cần thành cấp ≥ k (giữ luật VNG trong `show_buttons`), cùng với cấp nhân vật 20 / 40 / 60 / 70.

**Nguồn cống hiến:**
- Mỗi nhiệm vụ lính đánh thuê: +1 (VNG).
- Hoa thần bí: +1 mỗi 5 lượt (VNG).
- Luyện đơn: +1 mỗi 10 lượt (VNG).
- 69 và 79: +1 mỗi lượt.
- Quyên góp: 10.000 lượng = 1 điểm, tối đa 30 điểm/ngày.

**Thuế ngày:** 10.000 × cấp thành thị + 500 × hưng thịnh (tối đa tính 100 điểm hưng thịnh).

**Trạm dịch:** đưa thư "Đưa tin" thay người chơi, 5.000 lượng/thư, tối đa 10 thư/ngày.
- Lý do: các NPC nhận thư VNG (Đại phu, Tạp hóa, Võ sư, Thợ đồng ở 7 thành) phần lớn không đứng trên map.
- Vật phẩm phải mang về vẫn phải tự tìm.

**Giảm theo solo:** bước 5 của 894 cần 40 thay vì 200 mỗi loại nguyên liệu (`PTCT_SHENDIAN_ITEM_DIV = 5`).

### 2.5 Từng nhiệm vụ làm thế nào

| Nhiệm vụ | Đường đi |
|---|---|
| **894** Khảo nghiệm điện Phong Thần | Điện Phong Thần (cấp ≥ 30): hạ Ngưu Sát/Giáp Cốt/Hắc Phong ×50 → Dạ Xoa/Giang Quy ×50 → Thiên Hạo ×50 → Sa Hồn ×50 → nộp 6 nguyên liệu ×40 (Hỏa vũ, Ngọc cốt, Đoản Kiếm, Mảnh Giáp, Mặt Quỷ, Băng cơ). Đếm quái bằng `normal.lua` có sẵn. |
| **34** Hoa thần bí | Sau 894: nộp 50.000 lượng (lượt 6–20 cần thêm Thiên Tiên Thủy). Đi map được chỉ định, tìm **Hoa thần Cửu Di** (15 map, ext đặt), về Điện. Mỗi 5 lượt được +1 Hương liệu và +1 cống hiến. |
| **850–874** Lính đánh thuê | Trại lính: Truy sát (hạ 2 loại quái ×50), Thu thập (2 loại nguyên liệu ×50, hoặc 1 đầu boss ở cấp 3–4), Đưa tin (2 NPC + mang vật phẩm về, có thể nhờ trạm dịch). 5 điểm hành động/ngày, tối đa 2 lần mỗi loại. |
| **908** Phương pháp mới | Thành cấp 2, nhân vật cấp ≥ 40, cống hiến ≥ 100: hạ **Cửu Anh** (boss thế giới, slot 101) → nộp Toàn Tâm đinh, Lạc Hồn chung, Hồng Hồ Lô, Ngọc Hư Phù, Lam Bảo Thạch, Hồng Bảo Thạch → quay Càn Khôn Luân lấy Bạch Hổ hoặc Đại Hao Tinh Quân → 25 vạn kinh nghiệm. |
| **30** Luyện tiên đơn | Sau 908: mỗi ngày 10 lượt (lượt 11–30 cần Lò luyện đơn). Mỗi 10 lượt được +1 Gỗ. |
| **31** Thao trường thí luyện | Thành cấp 3: nhận tin gián điệp → **Đại phu dã ngoại** báo (đặt task 304 = 100) → phục mệnh; lượt 10 được +1 Hưng thịnh. |
| **69** Trừ ma | Sân luyện thú: mang về 20 chứng vật quái theo cấp; 2 lượt/ngày; thưởng kinh nghiệm, 50.000 lượng, +1 cống hiến, +1 Lương thảo. |
| **78** Xích Đồng Thảo | Phòng chiến xa: hái 5 bụi ở bãi tây nam Tây Kỳ; 20 lượt/ngày; thưởng kinh nghiệm, +1 Xích đồng, 30% được +1 Hưng thịnh. |
| **79** Điệp báo | Hý viện (cấp 4): gặp **Vệ quân** ở Triều Ca → phá hoại Xích Đồng Thảo → phục mệnh; 5 lượt/ngày; thưởng kinh nghiệm, +1 cống hiến, +1 tài nguyên ngẫu nhiên. |

### 2.6 NPC (ext `congthanh`)

| NPC | Map | Ô (x, y) | Template | Script |
|---|---|---|---|---|
| Lãnh địa quan | Tây Kỳ 1020 | 1535, 3026 | 768 | `congthanh\ct_steward.lua` |
| Điện Phong Thần* | 1020 | 1530, 3026 | 1130 | VNG 神殿 |
| Trại lính đánh thuê* | 1020 | 1525, 3026 | 211 | VNG 兵营 |
| Phòng luyện thuốc* | 1020 | 1520, 3026 | 149 | VNG 炼丹炉 |
| Thao trường* | 1020 | 1557, 3026 | 158 | VNG 靶场 |
| Sân luyện thú | 1020 | 1562, 3026 | 151 | `ct_muchang.lua` |
| Phòng chiến xa | 1020 | 1567, 3026 | 157 | `ct_chienxa.lua` |
| Hý viện | 1020 | 1562, 3036 | 2081 | `ct_hyvien.lua` |
| Xích Đồng Thảo ×3 | 1020 | (1520, 3044), (1525, 3048), (1520, 3052) | 151 | `ct_herb.lua` |
| Vệ quân | Triều Ca 1021 | 1622, 2944 | 211 | `ct_vequan.lua` |
| Hoa thần Cửu Di* ×15 | 1001–1065 | ô đầu bảng `pos` của từng script VNG | 255 | VNG `神秘花卉任务\任务-<map>.lua` |

- Hàng NPC ở Tây Kỳ nằm 10 ô phía nam dãy cửa hàng. Đã kiểm ô trống 5×5 trên lưới server (Region_S) và lưới client (Region_C trong maps.pak), và ô nối liền khu cửa hàng.
- Hoa: kiểm ô trống 3×3 cả hai lưới.
- Template đều là kind 3 (đối thoại). Template "building" kind 9 của VNG (372/374/379/381) **không dùng**, vì engine chỉ có kind 0–5.
- (*) Chỉ đặt khi ptfix mới đã deploy. Ext dò file đánh dấu `\script\phongthan\congthanh\ct_pakmark.lua`, file này chỉ có trong ptfix: dò ở tick 1, sau đó cứ 30 phút một lần.

### 2.7 File và cổng an toàn

| File | Vai trò |
|---|---|
| `Server\script\phongthan\congthanh\ct_lib.lua` | Hằng số, task, bảng công trình / cấp, helper |
| `…\ct_api.lua` | Lớp API cho 4 script VNG, sửa nhãn có `/`, giảm số nguyên liệu 894 |
| `…\ct_steward.lua` | Lãnh địa quan |
| `…\ct_muchang.lua`, `ct_chienxa.lua`, `ct_herb.lua`, `ct_hyvien.lua`, `ct_vequan.lua` | 69, 78, 79 |
| `Server\script\phongthan\ext\congthanh.lua` | `PTEXT_congthanh_Tick`: ReLoadScript, đặt và giữ NPC |
| `S\ptfix\extra_congthanh.py` | Nối `ct_api` vào 4 script VNG, tắt bước di chuyển hoa ở 15 script hoa, thêm file đánh dấu |
| `S\congthanh\src\*.lua` + `gen.py` | Mã nguồn UTF-8; `gen.py` sinh Lua ASCII (TCVN3 dạng `\ddd`) |
| `S\congthanh\cpp_patch.md`, `apply_patch.py`, `PhongThanLuaCongThanh.h` | Bản vá C++ tùy chọn và trình áp dụng |

**Cổng:**
1. Chưa có tên ext `congthanh` trong `PTADM_EXT_NAMES`: không NPC nào xuất hiện, tính năng tắt hoàn toàn.
2. Có ext nhưng ptfix cũ: chỉ đặt Lãnh địa quan, 69, 78, 79 và Vệ quân. 4 công trình VNG và 15 hoa chờ file đánh dấu.
3. Bản vá C++: `ct_api` bắt native lúc nạp. Có lãnh địa cá nhân thì luôn dùng task; không có thì gọi native nếu có, không thì trả 0.

### 2.8 Kiểm thử mô phỏng

- **Bản build ptfix nháp:** Client `S\congthanh\ptfix_test_client.pak` rồi Server `S\congthanh\ptfix_test.pak`, cả hai thành công. Log Server ghi `congthanh: shendian d2683bb5, bingying ad7f1d51, liandan 17c5b8e1, bachang 8448eaa4, flowers 15/15, pakmark`. Áp plug-in lần 2 không đổi byte nào (idempotent).
- **`qtest\sim_congthanh.lua`:** 143 kiểm tra, **0 lỗi**, trên bản runtime ở cả hai chế độ:
  - `-Stack 100`;
  - `-Stack 0 -Args1 EMU` (mỗi lối vào được đệm xuống đúng khoảng trống stack của engine: 47 khung cho NPC, 40 cho ext). Khoảng trống nhỏ nhất ghi được: 34 khung (lời gọi lồng `liandan_open`), ext 37.
  - Phạm vi: lập lãnh địa → xây → 894 đủ 5 bước (đếm quái thật qua `normal.lua`) → 34 ×5 (dùng script hoa VNG đã vá) → Sát thủ / Thu thập / Đưa tin C.1 (có trạm dịch) → lên cấp 2 → 908 → 30 → cấp 3 → 31 → 69 / 78 / 79 → cấp 4, mở Sát thủ C.4 → quyên góp / thuế / sang ngày. Thêm chế độ bang hội với stub C++ (`qtest\ct_cpp_stubs.lua`), ext tick (idempotent, đặt lại khi mất, cổng đánh dấu), và kiểm tra chỉ ghi task 2430–2479.
- **Hồi quy:** `sim_questfix`, `sim_questaudit`, `sim_tta`, `sim_tutuong_b`, `t_st` đều chạy (TOTAL FAILS = 0).

### 2.9 Các giai đoạn

| Giai đoạn | Nội dung | Trạng thái |
|---|---|---|
| 1 | Lãnh địa cá nhân, 7 công trình, 894/908/30/31/34/69/78/79, lính đánh thuê, hoa, trạm dịch, thuế | **Xong** (mô phỏng). Chờ bật ext và deploy ptfix |
| 1b | Bản vá C++ native chế độ bang hội (8 hàm) + sửa tràn `KGameData` (tùy chọn) | Đã soạn và thử applier trên bản sao; chờ coreclient |
| 2 | **Thủ thành theo lịch**: tối thứ Tư / thứ Bảy (`IsInMonsterAttackDay`), quái "mê cung" tấn công hàng công trình ở Tây Kỳ; người có lãnh địa giữ thành được thưởng tài nguyên / hưng thịnh. Dùng mẫu NPC-script + `LastDamage` (questfix) để đếm quái, không sửa `normal.lua` | Thiết kế |
| 2b | Nâng cấp từng công trình (cấp 1–3, `GetBuildingState` trả cấp); bước 1 của 908 có lựa chọn solo (Cửu Anh "bóng" riêng) nếu boss thế giới quá khó | Thiết kế |
| 3 | Bang hội thật (khi có relay xử lý bang): `LoadTongMap` đặt chủ thành, bản vá C++ đã có sẵn đường | Phụ thuộc relay |

## Phần 3: Hành động

### Coordinator

- [ ] Thêm `"congthanh"` vào `PTADM_EXT_NAMES` trong `Server\script\servertimer.lua`. Tick mỗi phút, đã chạy trong `call` có bảo vệ. File `script\phongthan\ext\congthanh.lua` đã có sẵn.
- [ ] Build ptfix thật với plug-in `S\ptfix\extra_congthanh.py` (Client trước, Server sau). Plug-in chạy sau `cankhon2`/`clientcrash`, trước `daily2`; không plug-in nào khác đụng 4 script công trình hay 15 script hoa.
- [ ] (Tùy chọn) Sau khi coreclient xong: `python S\congthanh\apply_patch.py --check`, rồi `python S\congthanh\apply_patch.py [--with-gamedata-fix]`, rồi build lại Core.
- [ ] Dán dòng CHANGELOG và README trong báo cáo agent.

### Người dùng thử trong game (sau khi khởi động lại)

- [ ] Tây Kỳ, khoảng 10 ô phía nam dãy cửa hàng: thấy **Lãnh địa quan**, Sân luyện thú, Phòng chiến xa, Hý viện, 3 bụi Xích Đồng Thảo.
- [ ] Nếu ptfix mới đã deploy, có thêm Điện Phong Thần, Trại lính, Phòng luyện thuốc, Thao trường.
- [ ] Lãnh địa quan → **Lập lãnh địa riêng** (cấp ≥ 20, 10 vạn lượng) → **Xây dựng công trình** cấp 1.
- [ ] Điện Phong Thần → **Khảo nghiệm** (cấp ≥ 30) → kiểm tra F11 hiện "Khảo nghiệm điện Phong Thần" kèm số quái.
- [ ] Trại lính → N.v lính đánh thuê → Truy sát → Sát thủ C.1. Hạ quái và xem thông báo "(x/50)". Đưa tin: dùng **Nhờ trạm dịch đưa thư** ở Lãnh địa quan.
- [ ] Sau 894, nhận Hoa thần bí → đến map được chỉ định tìm **Hoa thần Cửu Di**.
- [ ] Báo lại: NPC đứng sai chỗ hoặc bị kẹt, menu không phản hồi khi bấm (đặc biệt các dòng có "N.v"), F11 hiện "Task N - step S".

## Phần 4: Tài liệu tham khảo

- Kiểm toán: `S\questaudit\quest_audit.md` mục 14 và 2.13; `docs\features\tan-thu-moi-phong-than-20261003.md`.
- Script VNG đã trích: `S\congthanh\vng\*.u8.txt` (đọc được) / `*.raw`; công cụ `S\congthanh\dump.py`, `apis.py`, `grid2.py`, `flowers.py`, `pakx.py`.
- Engine: `PhongThanLuaWave8.h` (IsOwnerCity, GetCityInfo, PersistentGroup), `PhongThanLuaCarriage.h` (AddTongAttr), `ScriptFuns.cpp` (`LuaSelectUI` cắt ở dấu "/" đầu tiên), `KSOServer.cpp:438`, `KSubWorld.cpp:547` (LoadTong).
- Mẫu ext / NPC: `script\phongthan\ext\cankhon2.lua`, `newbie2.lua`.
- Skill / agent liên quan: `questfix2` (mẫu đếm quái bằng NPC-script, dùng cho giai đoạn 2), `vantieu` (AddTongAttr), `newbie2` (894/908 chuyển sang đây).
