# Tứ Linh (Linh Tê) và Thử Thách Huyền Vũ: dựng lại bằng Lua

> Ngày: 2026-10-02 · Người thực hiện: agent `tutuong_b` · Phạm vi: Giai đoạn 2 (Tứ Linh) và Giai đoạn 4 (Thử Thách Huyền Vũ) trong báo cáo Tứ Tượng.
> Không sửa C++, không sửa `Npcs.txt`. Đã kiểm thử trên simulator Lua 4 và build thử ptfix. **Chưa kiểm thử trong game.**

## Phần 1: Tổng quan

- **Tứ Linh chạy lại ở Thầy tướng số** (Triều Ca và Tây Kỳ). Menu cũ của NPC vẫn còn; có thêm dòng "Tứ Linh".
  - Mỗi ngày 4 lượt; mỗi Chìa khóa Linh Tê (8/329) cho thêm 1 lượt.
  - Một lượt gồm 6 vòng. Mỗi vòng, Linh Tê môn đưa người chơi vào một mê cung ngẫu nhiên: Hoang mạc, Hiên Viên, Băng Xuyên hoặc Đông Hải.
  - Người chơi phải diệt đủ lâu la trước khi buff Linh Tê hết giờ.
  - Mỗi vòng nhận kinh nghiệm và ngân lượng. Xong 6 vòng, quay về nhận thưởng lớn: 1 Tinh Phách ngẫu nhiên và 30% cơ hội có Lâm Tiên Lộ.
- **Quái được đếm qua hook trong `\script\npcdeath\normal.lua`.** Đây là script chết chung của 1.282 mẫu quái thường. Hook chạy trước, có bảo vệ lỗi, rồi mới chạy nguyên `OnDeath` gốc của VNG, nên các nhiệm vụ Trừ Yêu, Lính đánh thuê, Hoa cỏ không đổi.
- **Thử Thách Huyền Vũ được thiết kế lại để chơi một mình được**, trên map 86, tức runtime 1086 "Huyền Vũ Thần Vực".
  - Thí Luyện Thần Sứ đứng ở Triều Ca và trong Thần Vực.
  - Lịch: đăng ký từ 18:50, bắt đầu 19:20 hằng ngày. Ngoài ra có thể "Vào ngay" bất kỳ lúc nào để chơi một mình.
  - Gồm 8 đợt trong 15 phút: 4 Vật Tổ, rồi Huyền Vũ qua 6 cấp hồn, cuối cùng là Huyền Vũ Thần Hồn.
  - Thắng thì có Bảo Rương. Rời đi thì về lại chỗ cũ, nếu không xác định được thì về Triều Ca.
- **Không dùng Mission API**, dù các hàm đã được đăng ký. Mission gắn cố định với `\script\missions\missionNN.lua` và chỉ có một phiên cho cả bản đồ, nên không hợp với nhiều người chơi riêng lẻ cùng lúc. Thay vào đó dùng biến task, tham số NPC và tick mỗi phút (xem 2.4).
- **Cần coordinator làm 2 việc:**
  1. Thêm hook `PTAdm_TtTick` vào `servertimer.lua`.
  2. Đưa `extra_tutuong_b.py` vào bản build ptfix thật.
  Sau đó người dùng khởi động lại server.

## Phần 2: Chi tiết

### 2.1 Tứ Linh: luật chơi

| Mục | Giá trị |
|---|---|
| NPC | Thầy tướng số Triều Ca `\script\朝歌\算命先生.lua` (ptfix f1532fee) và Tây Kỳ `\script\西岐\算命先生.lua` (ptfix 1536a76f): thêm dòng `{"Tứ Linh","PTTL_Menu";show=1}` ngay trước `SayTask` |
| Cấp tối thiểu | 65 (theo chuỗi 11940 và bảng thăng cấp VNG) |
| Lượt/ngày | 4, cộng tối đa 4 lượt từ Chìa khóa Linh Tê. Hủy nhiệm vụ vẫn bị tính lượt |
| Vòng | 6. Tầng mê cung theo vòng: 1, 2, 3, 4, 5, 5 (tầng 5 là bản đồ của ma vương) |
| Số quái cần diệt | 10 / 12 / 15 / 18 / 20 / 25 |
| Thời gian (buff Linh Tê) | Bậc 1 = 600 giây (vòng 1–2), bậc 2 = 480 giây (vòng 3–4), bậc 3 = 360 giây (vòng 5–6), đúng thời hạn của item 8/326–328, 342–350 |
| Thưởng mỗi vòng | Kinh nghiệm = cấp × 1.500 × số vòng; ngân lượng = 1.000 × số vòng |
| Thưởng cuối (vòng 6) | Kinh nghiệm = cấp × 20.000; 20.000 lượng; 1 Tinh Phách ngẫu nhiên 3/200–203; 30% Lâm Tiên Lộ 8/330 |
| Tổ đội | Mọi thành viên đang ở đúng bản đồ mục tiêu đều được tính quái |

**Bốn mê cung.** Mỗi mê cung gồm 5 bản đồ. Tọa độ vào là điểm dịch chuyển lấy từ script đi lại của VNG trong PAK. Cả 20 bản đồ đều nạp được (`core_map_load_diag.log`).

| Mê cung | Ma vương | Buff | Bản đồ (tầng 1 → 5) |
|---|---|---|---|
| Hoang mạc | Thiết Bố | 326/327/328 | 1022 Hoang mạc, 1023 Thổ Thành, 1024 Phong Than, 1025 Lục Châu, 1026 Sa Mạc chết |
| Hiên Viên | Côn Bối | 342/343/344 | 1027–1031 Hiên Viên tầng 1–5 |
| Băng Xuyên | Lam Bá | 345/346/347 | 1032 Ngọc Tuyền, 1033 Tuyết Cốc, 1034 Đại Phong, 1035 Đại Thạch, 1036 Băng Xuyên Cực |
| Đông Hải | Kim Trại | 348/349/350 | 1037 Thủy Vực, 1038 Long Cung, 1039 Hải Câu, 1040 Long Vực, 1041 Long Uyên |

**Luồng chơi:**
1. Người chơi nhận nhiệm vụ ở Thầy tướng số. Mê cung đầu tiên được chọn ngẫu nhiên, NPC cấp buff Linh Tê, rồi hỏi "Đưa ta đến mê cung". Chọn thì được `NewWorld` tới điểm vào.
2. Mỗi quái chết trên đúng bản đồ mục tiêu được +1 và có thông báo "đã diệt k/N".
3. Khi đủ số quái: nhận thưởng vòng, mê cung kế tiếp được chọn ngẫu nhiên (khác mê cung vừa xong), và hiện hộp thoại "Đi qua Linh Tê môn".
4. Xong vòng 6, nhiệm vụ chuyển sang trạng thái 7. Người chơi về một trong hai Thầy tướng số để "Phục mệnh". Thưởng được trao qua `QuestExchange(2043, 7, 0, …)`, nên nếu hành trang đầy thì không mất gì.
5. Nếu hết giờ, nhiệm vụ chuyển sang trạng thái 8. Hết giờ được phát hiện khi giết quái, khi mở hộp thoại hoặc ở tick mỗi phút. Người chơi về NPC "Trả nhiệm vụ"; thưởng các vòng đã xong thì đã nhận rồi.

**Chìa khóa Linh Tê 8/329:** ptfix đổi cột script của dòng này trong `ibitem.txt` từ `NONE` sang `\script\phongthan\tutuong\tl_chiakhoa.lua`. Click phải dùng: +1 lượt hôm nay và tiêu hao chìa qua `PTCompat_UseCharge`.

**Không làm buff bậc 4** (8/331, 351–353; +20% kháng). Lý do: item script `pt_ibitem.lua` chưa hỗ trợ tên "Linh Tê_X 4", và `AddIBBuff` với các mã này chỉ tạo buff đánh dấu, không có thuộc tính.

### 2.2 Hook đếm quái trong `normal.lua`

- Bản có hiệu lực là bản trong ptfix (id 510083b1). Plug-in `extra_tutuong_b.py` sửa ở mức byte trên bản đã có dòng Include `pt_compat` do build thêm vào:
  1. thêm `Include("\\script\\phongthan\\tutuong\\tl_lib.lua")`;
  2. đổi tên `OnDeath` thành `PTTL_OrigOnDeath`;
  3. thêm `OnDeath` mới: `call(PTTL_OnKill, {npcindex}, "x", PTTL_KillErr)`, trả lại `PlayerIndex`, rồi gọi `PTTL_OrigOnDeath(npcindex)`.
- Bản file rời `Server\script\npcdeath\normal.lua` cũng được sửa y hệt cho nhất quán (đã sao lưu). Engine đọc PAK trước, nên bản rời chỉ là dự phòng.
- `PTTL_OnKill` chỉ đọc và ghi biến task 2040–2048 của người giết và tổ đội. Nếu người chơi không có Tứ Linh đang chạy, hàm thoát ngay.

### 2.3 Thử Thách Huyền Vũ: thiết kế mới

| Mục | Giá trị |
|---|---|
| Bản đồ | 1086 `xuan_wu_shen_yu` (đã nạp). Điểm vào (1217, 2964), tức region (76, 92). Region này không có file vật cản `_S`; đây là khoảng trống trên bản đồ nhỏ |
| NPC vào cửa | Thí Luyện Thần Sứ (tpl 2064, dòng 2066). Tick đặt ở Triều Ca (1723, 3121), cạnh Thầy tướng số, và trong Thần Vực (1211, 2954). Script `hv_npc.lua` |
| Lịch | 18:50–19:19 đăng ký (buff 8/8691 đến 19:20); 19:20–19:30 tick đưa người đã đăng ký và đang trực tuyến vào; thông báo toàn server lúc 18:50 và 19:20 |
| Vào ngay | `PTHV_ANYTIME = 1`: chơi một mình bất kỳ giờ nào |
| Lượt/ngày | 2, tính chung cho lượt theo lịch và lượt vào ngay. Cấp tối thiểu 70 |
| Thời gian | 900 giây cho cả 8 đợt (buff 8/8692). Hết giờ thì thất bại và về thành |
| Đợt 1 | 4 Vật Tổ Huyền Vũ (tpl 2065–2068), sinh lực = cấp × 300 |
| Đợt 2–7 | Huyền Vũ Sơ/Trung/Cao/Vương/Hoàng/Thần Hồn (tpl 2085–2090), sinh lực = cấp × (600 + 300 × (đợt − 2)) |
| Đợt 8 | Huyền Vũ (tpl 2124, kind 0), đổi tên thành "Huyền Vũ Thần Hồn", sinh lực = cấp × 3.000 |
| Thưởng mỗi đợt | Kinh nghiệm = cấp × 800 × số đợt |
| Bảo Rương | NPC tpl 1759 "Huyền Vũ Bảo Rương". Chỉ chủ nhân mở được; tự mở sau 300 giây hoặc khi người chơi rời map. Thưởng: cấp × 20.000 kinh nghiệm, 30.000 lượng, 2 Tứ Tượng Tinh Hoa 3/115, 5 nguyên liệu ngẫu nhiên 3/22–25 (`QuestExchange(2051, 3, 0, …)`); sau đó buff 8/8716 trong 300 giây |
| Rời đi | Qua NPC trong Thần Vực, khi chết hoặc thoát game (`SetLogoutRV(1)`; tick thấy người chơi không còn ở 1086 thì đóng lượt), hoặc khi hết giờ. Về điểm đã lưu lúc vào, mặc định Triều Ca |

**Vì sao chọn các mẫu NPC này:**
- Huyền Vũ Thần Hồn dòng 2071 có `Kind = 8`, nằm ngoài enum `NPCKIND` (0..5), nên không an toàn để dùng. Boss cuối dùng dòng 2126 (kind 0).
- Sinh lực gốc của các cấp hồn là 10–70 triệu. Script ghi đè bằng `SetNpcLife` theo cấp người chơi để một người cũng đánh được. Các hệ số nằm ở `PTHV_Life` trong `hv_lib.lua`.

**Nhận biết quái chết.** Mọi NPC sinh ra đều được gắn:
- `SetNpcParam` 0 = PlayerIndex chủ nhân, 1 = serial của lượt (`SystemTime()` lúc bắt đầu), 2 = số đợt;
- `SetNpcScript(hv_mob.lua)`;
- `SetNpcTimeout` để dọn NPC bị bỏ lại.

Cách engine gọi script khi quái chết khác nhau theo mẫu:
- Vật Tổ không có DeathScript, nên engine gọi `DeathSelf` của action script (`KNpc::DoDeath`).
- Các cấp hồn dùng DeathScript sẵn có trong `Npcs.txt` (`\script\npcdeath\xuanwu_lv1..6.lua`). VNG đã mất các file này; nay viết lại.
- Boss cuối dùng `\script\npcdeath\xuan_wu.lua`.

Mọi đường trên đều gọi `PTHV_MobDeath`. Hàm này cộng cho chủ nhân, bất kể ai đánh, rồi `DelNpc`. Bản sao NPC đặt sẵn bởi region (không có tham số) bị bỏ qua và vẫn hồi sinh như trước.

### 2.4 Quyết định về Mission API

- **Đã kiểm tra trong `ScriptFuns.cpp`:** các hàm sau đều được đăng ký: `OpenMission` (LuaInitMission, dòng 7752), `StartMissionTimer` (7954), `AddMSPlayer` (8037), `SetMissionV`, `GetMissionV`, `RunMission`, `CloseMission`.
- **Lý do không dùng:**
  - `OpenMission` gọi `InitMission` trong `\script\missions\mission%02d.lua` (`KTaskFuns.h`), và timer gọi `\script\timertask\task%02d.lua`. Mỗi mission chỉ có một phiên cho cả subworld 1086. Nhiều người "vào ngay" cùng lúc sẽ dùng chung một trạng thái.
  - Muốn dùng thì phải cấp mã mission/timer mới và đăng ký script mới; số `missionNN` đã có file `mission01.lua` của VNG.
- **Cách đã làm:**
  - Trạng thái của từng người nằm ở biến task 2049–2068.
  - NPC tự mang thông tin chủ nhân trong tham số NPC.
  - Tick mỗi phút lo lịch 19:20, đồng hồ và trường hợp người chơi rời map.
  - Hạn giờ còn được kiểm tra ngay khi giết quái hoặc mở hộp thoại, nên độ trễ tối đa của đồng hồ là 1 phút.

### 2.5 Biến task (dải 2040–2069 của tutuong_b)

| Biến | Ý nghĩa |
|---|---|
| 2040 / 2041 / 2042 | Tứ Linh: ngày (yyyymmdd) / số lượt đã dùng / số lượt thêm từ chìa |
| 2043 | Vòng: 0 rảnh, 1–6 đang chạy, 7 chờ phục mệnh, 8 hết giờ |
| 2044 / 2045 / 2046 / 2047 / 2048 | Mê cung / bản đồ mục tiêu / số quái đã diệt / số quái cần / hạn giờ (`SystemTime`) |
| 2049 / 2050 | Huyền Vũ: ngày / số lượt hôm nay |
| 2051 | Trạng thái: 0 không, 1 đã đăng ký 19:20, 2 đang thử thách, 3 chờ mở rương |
| 2052 / 2053 / 2054 / 2055 | Đợt / số NPC còn lại / hạn giờ / serial của lượt |
| 2056 / 2057 / 2059 | Bản đồ, x, y để quay về |
| 2060 / 2066 / 2067 / 2068 | Chỉ số NPC của đợt hiện tại (rương dùng ô 2060) |

Bỏ qua 2058, 2061–2065, 2069 vì các script VNG mới (`script\common\newserver.luax`, gói quà máy chủ mới, thẻ Bạch Hổ) đang dùng. Không dùng 54/55 (nhiệm vụ Tứ Tượng ở Thủ khố).

### 2.6 File

| File | Loại |
|---|---|
| `Server\script\phongthan\tutuong\tt_common.lua` | Mới: hằng số và helper (ngày, giờ, Say, trao ibitem, thành viên tổ đội) |
| `Server\script\phongthan\tutuong\tl_lib.lua` | Mới: logic Tứ Linh (menu, vòng, đếm quái, thưởng, tick) |
| `Server\script\phongthan\tutuong\tl_chiakhoa.lua` | Mới: item script Chìa khóa Linh Tê |
| `Server\script\phongthan\tutuong\hv_lib.lua` | Mới: logic Thử Thách Huyền Vũ |
| `Server\script\phongthan\tutuong\hv_npc.lua`, `hv_mob.lua`, `hv_chest.lua` | Mới: hộp thoại Thí Luyện Thần Sứ, action script của quái, Bảo Rương |
| `Server\script\phongthan\tutuong\tt_tick.lua` | Mới: `PTTT_Tick()` cho servertimer |
| `Server\script\npcdeath\xuanwu_lv1..6.lua`, `xuan_wu.lua` | Mới: DeathScript các cấp hồn và boss (thay file VNG đã mất) |
| `Server\script\npcdeath\normal.lua` | Sửa ở mức byte (hook Tứ Linh); sao lưu ở `_backup\20261002-tutuong_b\PhongThanRuntime-Staging\Server\script\npcdeath\normal.lua` |
| `scratchpad\ptfix\extra_tutuong_b.py` | Mới: plug-in ptfix (2 Thầy tướng số, `normal.lua`, dòng ibitem 8/329) |

Mã nguồn UTF-8 nằm ở `scratchpad\tutuong_b\src\`. Lệnh `python mk.py` chuyển sang TCVN3 và triển khai, có sao lưu.

## Phần 3: Hành động (checklist kiểm thử trong game)

**Chuẩn bị (coordinator):**
- [ ] Thêm vào `servertimer.lua`, đặt trước `PTAdm_Tick`:
  ```lua
  function PTAdm_TtTick()
  	if not PTTT_Tick then dofile("script\\phongthan\\tutuong\\tt_tick.lua") end
  	if PTTT_Tick then PTTT_Tick() end
  end
  ```
- [ ] Trong `PTAdm_Tick()`, gọi `PTAdm_TtTick()`, chẳng hạn sau `PTAdm_NbTick()`.
- [ ] Build ptfix thật có `extra_tutuong_b.py` rồi để người dùng khởi động lại server. Lần tick đầu tiên tự `ReLoadScript` các script rời.

**Tứ Linh (nhân vật cấp ≥ 65):**
- [ ] Thầy tướng số Triều Ca có dòng "Tứ Linh"; menu cũ vẫn còn (nhân vật Dị Nhân vẫn thấy "gọi Thú Biến Thân"). Kiểm tra tương tự ở Tây Kỳ.
- [ ] "Mở Linh Tê môn" → có buff Linh Tê → "Đưa ta đến mê cung" → tới đúng bản đồ, đứng được, không kẹt vật cản.
- [ ] Giết quái ở bản đồ khác: không được tính. Giết quái ở đúng bản đồ: hiện "đã diệt k/N".
- [ ] Đủ quái → nhận kinh nghiệm và lượng, hiện hộp thoại "Đi qua Linh Tê môn" tới mê cung mới.
- [ ] Xong 6 vòng → về Thầy tướng số → "Phục mệnh" → nhận Tinh Phách (thử cả lúc hành trang đầy: không nhận được và không mất trạng thái).
- [ ] Để hết giờ → thông báo vòng thất bại → "Trả nhiệm vụ".
- [ ] Lượt thứ 5 trong ngày bị từ chối → dùng Chìa khóa Linh Tê → nhận được lượt mới, chìa mất.
- [ ] Đi tổ đội 2 người cùng bản đồ: cả hai cùng được tính quái.
- [ ] Nhiệm vụ Trừ Yêu, Lính đánh thuê, Hoa cỏ vẫn đếm quái bình thường.

**Thử Thách Huyền Vũ (nhân vật cấp ≥ 70):**
- [ ] Sau 1–2 phút, Thí Luyện Thần Sứ xuất hiện ở Triều Ca, cạnh Thầy tướng số.
- [ ] "Vào thử thách ngay" → vào map 1086, đứng được → thấy 4 Vật Tổ.
- [ ] Phá đủ 4 Vật Tổ → Sơ Hồn xuất hiện cạnh người chơi → lần lượt qua 8 đợt → Bảo Rương → mở → nhận thưởng và về Triều Ca.
- [ ] Thử độ khó: một người cấp 80 có đánh kịp trong 15 phút không. Nếu quá dễ hoặc quá khó, chỉnh `PTHV_Life` và `PTHV_TIME`.
- [ ] Bỏ cuộc qua NPC trong Thần Vực: quái bị xóa, người chơi về chỗ cũ.
- [ ] Chết hoặc thoát game giữa chừng: trong vòng 1 phút lượt bị đóng và quái bị xóa.
- [ ] 18:50–19:19 "Đăng ký 19:20" → có buff 8691 → 19:20 tự được đưa vào Thần Vực.
- [ ] Lượt thứ 3 trong ngày bị từ chối.

## Phần 4: Tài liệu tham khảo

- Báo cáo nghiên cứu: `scratchpad\tutuong\tutuong_report.md`, mục 2.4 (Tứ Linh) và 2.6 (Huyền Vũ).
- Engine: `ScriptFuns.cpp`:
  - `LuaAddIBBuffCompat` (buff theo giây, mã = skill id; không có skill thì là buff đánh dấu);
  - `LuaSetNpcActionScript`, `LuaSetNpcTimeout`, `LuaSetNpcLife`;
  - `LuaInitMission`, `LuaStartMissionTimer`, `LuaAddMissionPlayer`.
- `KNpc.cpp`:
  - `DoDeath`: `LastDamage` với `kind_normal`, DeathScript `OnDeath`, `DeathSelf` khi không có DeathScript;
  - `DoRevive`: NPC sinh bằng `AddNpc` sẽ hồi sinh nếu không bị `DelNpc`.
- `KPlayer::DialogNpc`: `main(npcIndex)`.
- `PhongThanQuestExchange.inl`: giao dịch nguyên tử.
- Simulator: `scratchpad\qtest\sim_tutuong_b.lua` → `out_tutuong_b.txt`; bản đã giải mã: `out_tutuong_b.u8.txt`.
- Liên quan:
  - `bao-thuong-can-khon-tu-tuong-thu-kho-phong-than-20261002.md` (tutuong_a: Thủ khố, item Tứ Tượng);
  - `boss-the-gioi-lenh-bai-phong-than-20260930.md` (4 ma vương).
- Bước tiếp theo nên làm:
  - Đổi thưởng Thất Tinh Huyền Vũ (bit 2028) tại Thí Luyện Thần Sứ.
  - Buff bậc 4 của Linh Tê.
  - Bảng xếp hạng thời gian hoàn thành Huyền Vũ.
