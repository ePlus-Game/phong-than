# Vạn Tiên trận chơi được trên máy chủ Phong Thần local

> Ngày: 2026-10-02 · Người thực hiện: agent `vantien` · Loại: tính năng mới, chỉ dùng Lua và dữ liệu, không sửa C++, không sửa `npcs.txt`, không cần ptfix.
> Nhãn: **[VERIFIED]** = đã kiểm tra trên mã nguồn, dữ liệu bản đồ hoặc trình mô phỏng. **[INFERRED]** = suy luận, cần thử trong game.

## Phần 1: Tổng quan

### Insight chính
- Vạn Tiên trận giờ là **phó bản PvE có giờ, vào được một mình**. Người chơi nói chuyện với **Thiên Hùng ở Tây Kỳ (1020)**. Nếu trận đang đóng, Thiên Hùng **mở trận ngay**: chuẩn bị 20 giây rồi đánh 30 phút. Ngoài ra trận vẫn tự mở theo giờ VNG.
- Có 4 trận, dùng 4 bản đồ **Huyễn**:

| Trận | Mission | Bản đồ | Cấp vào | Mở khóa sớm |
|---|---|---|---|---|
| Thổ | 1 | 1079 | 30+ | — |
| Thủy | 2 | 1080 | 51+ | đã phá trận Thổ |
| Hỏa | 3 | 1081 | 71+ | đã phá trận Thủy |
| Phong | 4 | 1082 | 91+ | đã phá trận Hỏa |

- **Luồng chơi**:
  1. Vào trận.
  2. Hạ 4 tiên (Ô Vân, Cầu Thủ, Linh Nha, Kim Quang). Mỗi người trong trận nhận 1 lệnh (Thanh long, Chu tước, Huyền võ, Bạch hổ).
  3. Khi đủ 4 tiên, Thông Thiên Giáo Chủ xuất hiện ở **Thần Bí Trận Điểm**. Vào đó bằng trận nhãn VNG (cần đủ 4 lệnh) hoặc nhờ Đại phu đưa vào.
  4. Hạ Thông Thiên thì nhận thưởng phá trận, và 4 **Bảo rương Thông Thiên** xuất hiện.
  5. Đại phu cho **tiến thẳng sang trận kế tiếp**. Người chơi có thể đi liền từ trận 1 đến trận 4.
- **Thân thiện khi chơi một mình hoặc với bot**: mọi người đứng trong trận đều nhận lệnh và thưởng, kể cả khi đòn cuối do bot hoặc người ngoài trận đánh.
- Sáu lớp chặn trong báo cáo nghiên cứu đều đã gỡ bằng Lua (bảng ở 2.1).

### Nhận định quan trọng
- **Không có mẫu NPC riêng cho "Thiên Hùng"** trong `npcs.txt` (đã tìm `天雄`, không có). Vì vậy dùng mẫu **247 `passerby099`**, chính là NPC cổng Vạn Tiên trận của VNG (`review.lua`), rồi đặt tên "Thiên Hùng" bằng `SetNpcName`. Không sửa `npcs.txt`.
- Vị trí 4 tiên, Thông Thiên và rương là **[INFERRED]**, vì dữ liệu đặt NPC gốc đã mất. Mọi ô đã được kiểm tra trên Region_S của bản đồ Huyễn **[VERIFIED]**:
  - không có vật cản;
  - tiên và quái nằm trong vùng đi bộ chính, thông với điểm vào;
  - Thông Thiên và rương nằm trong vùng kín "Thần Bí Trận Điểm", đúng nơi trận nhãn VNG dịch chuyển tới.
- Chưa chuyển chuỗi **nhiệm vụ ngày VNG của Thiên Hùng** (script `b5deef29`, cấp Vạn Tiên, set đồ). Phần thưởng hiện nằm ở trận và rương.

## Phần 2: Chi tiết

### 2.1 Gỡ từng lớp chặn
| Lớp chặn trong báo cáo | Cách gỡ |
|---|---|
| (a) Engine không đọc `missions.txt`/`timertask.txt`, chỉ gọi `mission%02d.lua` và `task%02d.lua:OnMissionTimer` | Viết `script\missions\mission01..04.lua` và `script\timertask\task02..09.lua` mới. Các file này mỏng, gọi `vt_lib.lua`. `mission01.lua` và `task01.lua` cũ (VLTK) đã được backup rồi thay. |
| (b) Mã map cũ 67–70 làm `SubWorldID2Idx` trả về -1 | Dùng thẳng 1079–1082 cho `SubWorldID2Idx`, `NewWorld` và `AddNpc`. |
| (c) Map 1067/1069/1070 không có Region_S | Dùng 4 map Huyễn: đã nạp, đủ Region_S, có trap VNG. |
| (d) Thiếu API `GetNextPlayer`, `LockCamp`, `KillNpcByIdx`, `SendGlobalMessage`, `DelHandItem` | Thay bằng vòng `GetMSPlayerCount`/`MSDIdx2PIdx`/`GetPMParam` và `AddGlobalNews`. Các API còn lại không còn cần. |
| (e) `SetMissionV` 2 tham số và `AddNpc` 5 tham số không có tác dụng | Trạng thái lưu ở GlobalValue 400–419. `AddNpc` luôn gọi đủ 6 tham số. |
| (f) Không có lịch mở | Tick `PTVT_Tick` chạy mỗi phút, mở trận theo giờ VNG. Ngoài ra Thiên Hùng mở trận theo yêu cầu. |
| Death script của NPC sinh bằng script không chạy | Gắn ActionScript bằng `SetNpcScript`. Engine gọi `LastDamage(npc)` với `PlayerIndex` là người hưởng kill (`KNpc::DoDeath`) [VERIFIED mã nguồn]. Boss và rương được đặt `SetNpcRevTime` 24 giờ để không hồi sinh. |
| 8 script trap VNG chỉ có trong PAK, chưa đăng ký | Tick lần đầu chạy `ReLoadScript` cho 8 đường dẫn GBK, nên không cần ptfix. Id trap trong Region_S trùng hash các script này [VERIFIED]. |
| Rương VNG không có thưởng | `vt_chest.lua` phát thưởng (2.4). |

### 2.2 Luồng mission (giống nhau cho cả 4 trận)
1. **Mở**: Thiên Hùng (theo yêu cầu, chuẩn bị 20 giây) hoặc tick (theo giờ, chuẩn bị 5 phút) gọi `OpenMission(n)`. Hàm `InitMission` của mission:
   - sinh 4 tiên (mẫu Huyễn 1904–1923), 12 quái 强化 (mẫu 53–60) và 2–3 Đại phu (mẫu 766);
   - gắn mọi NPC vào mission bằng `AddMSNpc`;
   - đặt GV trạng thái = 1 và tạo khóa lượt;
   - bật timer bắt đầu (`task06..09`).
2. **Bắt đầu**: timer bắt đầu gọi `RunMission`. Trạng thái = 2, người trong trận được `SetFightState(1)`, và timer kết thúc 30 phút (`task02..05`) bắt đầu chạy.
3. **Đánh**:
   - Mỗi tiên chết cho mọi người trong trận 1 lệnh (3,66..69).
   - Đủ 4 tiên thì Thông Thiên xuất hiện.
   - Thông Thiên chết: trạng thái = 3 (đã phá), sinh 4 rương, phát thưởng phá trận, ghi tiến độ mở khóa.
4. **Rời trận**: Đại phu "Rời trận" hoặc đổi map đều gọi `OnLeave`. `OnLeave` tắt trạng thái chiến đấu, xóa lệnh và đánh dấu slot mission không còn hiệu lực.
5. **Kết thúc**: timer kết thúc gọi `CloseMission`. `EndMission` đưa mọi người đang đứng trên map về Tây Kỳ, rồi engine xóa toàn bộ NPC của mission.
6. **Mở lại**: trận đã phá mà không còn ai bên trong thì lần vào sau tạo lượt mới. Trận đang chạy thì người vào sau nhập chung lượt, giữ nguyên tiến độ (ví dụ khi chết rồi quay lại).

### 2.3 Đại phu trong trận
Có 1 Đại phu ở điểm vào, 1 trong vùng Thông Thiên, và 1 trong vùng trap thứ hai nếu vùng đó kín (trận Thổ, Thủy, Phong), nên không ai bị kẹt. Menu gồm:
- Tình hình trận: số tiên đã hạ, thời gian còn lại.
- Đưa đến Thần Bí Trận Điểm: chỉ hiện khi đã hạ đủ 4 tiên.
- Tiến vào trận kế tiếp: sau khi phá trận.
- Mua thuốc (`Sale(1)`, như Đại phu Tây Kỳ).
- Về điểm vào.
- Rời trận về Tây Kỳ.

### 2.4 Phần thưởng (cân cho chơi một mình)
Phần thưởng dùng vật phẩm có sẵn trong `material.txt` [VERIFIED].

| Nguồn | Thổ | Thủy | Hỏa | Phong |
|---|---|---|---|---|
| Hạ Thông Thiên: EXP | 600 × cấp | 800 × cấp | 1000 × cấp | 1200 × cấp |
| Hạ Thông Thiên: ngân lượng | 10.000 | 20.000 | 30.000 | 50.000 |
| Hạ Thông Thiên: nguyên liệu | 1 Địa Tâm (3,110) | 1 Thủy Hồn (3,112) | 1 Hỏa Linh (3,113) | 1 Phong Lệ (3,111) |
| Mỗi rương (×4): EXP | 300 × cấp | 400 × cấp | 500 × cấp | 600 × cấp |
| Mỗi rương: ngân lượng | 3.000 | 6.000 | 10.000 | 15.000 |

- Mỗi rương có thêm một lần quay vật phẩm:
  - 45%: nguyên liệu nguyên tố của trận;
  - 20%: Mảnh Hồng thủy tinh (3,77);
  - 20%: Mảnh Lam thủy tinh (3,78);
  - 10%: Hoàn Nguyên Thạch (3,136);
  - 5%: không có gì.
- Ví dụ cấp 45, trận Thổ: khoảng 81.000 EXP, 22.000 lượng và 3–5 nguyên liệu mỗi lần phá. Mức này gần một lượt nhiệm vụ ngày Vạn Tiên của VNG.
- **Giới hạn**: mỗi trận nhận thưởng tối đa **2 lần mỗi ngày** cho mỗi nhân vật (`PTVT_DAILY_CAP`). Rương chỉ thưởng cho người đã nhận thưởng Thông Thiên trong lượt đó (task 2004 = khóa lượt).
- Mọi con số nằm trong `vt_data.lua`. Muốn chỉnh thì sửa `scratchpad\vantien\impl\build.py` rồi build lại.

### 2.5 Biến dùng
- **GlobalValue 400–419**, 5 giá trị cho mỗi trận: trạng thái, mặt nạ kill, khóa lượt, số giây chuẩn bị, số rương đã mở. Chỉ script Vạn Tiên VNG (không chạy) dùng dải này [VERIFIED: grep loose và quét toàn bộ PAK].
- **Task 2000–2005**: 2000 tiến độ (bit n = đã phá trận n), 2001 ngày, 2002 số lần thưởng trong ngày, 2003 khóa lượt đã vào, 2004 khóa lượt được mở rương, 2005 map đang ở. Dải 2000–2019 được giao cho agent `vantien`, chưa ai dùng [VERIFIED].
- **Mission timer**: id 2–5 (kết thúc) và 6–9 (bắt đầu), khớp `timertask.txt` của VNG.

### 2.6 Vị trí [VERIFIED trên Region_S, INFERRED về thiết kế]
- **Thiên Hùng**: Tây Kỳ 1020, mps (50464, 96896) = ô (1577, 3028), cạnh Bảo Thương (ô 1580, 3024). Ô này trống trong Region_S loose vùng (98, 94). Về thành tại ô (1580, 3030).
- **Điểm vào** (VNG):
  - Thổ (1325, 3280);
  - Thủy (1752, 3567);
  - Hỏa (1647, 3397): điểm VNG (1650, 3400) không có Region_S nên dời sang ô trống gần nhất;
  - Phong (1671, 3035).
- **Thông Thiên**: cách điểm đến của trận nhãn khoảng 5–6 ô, trong vùng kín. Riêng trận Hỏa dùng điểm đến của trap 2 (1708, 3181), vì trap 1 rơi vào vùng chính.
- Toàn bộ bảng tọa độ nằm trong `script\phongthan\vantien\vt_data.lua`.

## Phần 3: Hành động

### 3.1 Việc của coordinator (agent không được sửa các file này)
- [ ] Thêm hook vào `Server\script\servertimer.lua`, ngay sau `PTAdm_WbTick`:
  ```lua
  -- 2026-10-02 Van Tien tran (4 tran tren map Huyen 1079..1082, Thien Hung o Tay Ky).
  -- Logic in script\phongthan\vantien\vt_timer.lua (GV 400..419, task 2000..2005).
  function PTAdm_VtTick()
  	if not PTVT_Tick then dofile("script\\phongthan\\vantien\\vt_timer.lua") end
  	if PTVT_Tick then PTVT_Tick() end
  end
  ```
  rồi thêm dòng `PTAdm_VtTick()` vào `PTAdm_Tick()`, sau `PTAdm_WbTick()`. Hook chạy mỗi phút.
- [ ] Ghi `CHANGELOG.md` và `docs\features\README.md`.
- [ ] (Tùy chọn) Nút "Mở Vạn Tiên trận n" trên web admin: ghi `PTVT_AdminOpen(n)` vào `pending.lua`. Hàm này có sẵn trong state servertimer sau tick đầu.

### 3.2 Checklist thử trong game (người dùng tự khởi động lại server)
- [ ] Khởi động lại GameServer. Sau tối đa 1 phút, **Thiên Hùng** xuất hiện ở Tây Kỳ, cạnh Bảo Thương.
- [ ] Nhân vật dưới cấp 30 bị từ chối. Nhân vật cấp 30–50 chỉ vào được trận Thổ.
- [ ] Chọn "Vạn Tiên trận (Thổ)": được đưa vào map 1079, thấy Đại phu, 4 tiên và quái. Sau 20 giây có thông báo "Trận chiến bắt đầu".
- [ ] Hạ từng tiên: mỗi lần nhận 1 lệnh và có thông báo "(k/4)". Thử để bot đánh đòn cuối, vẫn phải nhận lệnh.
- [ ] Đủ 4 tiên: Thông Thiên xuất hiện. Thử bước vào trận nhãn (cần 4 lệnh), hoặc nhờ Đại phu đưa đến Thần Bí Trận Điểm.
- [ ] Hạ Thông Thiên: nhận EXP, lượng và nguyên liệu, thấy 4 Bảo rương. Đập rương nhận thêm thưởng.
- [ ] Đại phu → "Tiến vào Vạn Tiên trận (Thủy)": vào được dù chưa đủ cấp 51. Lặp lại đến trận Phong.
- [ ] "Rời trận": về Tây Kỳ, mất trạng thái chiến đấu, lệnh bị xóa.
- [ ] Phá cùng một trận lần thứ 3 trong ngày: báo đã đủ lượt, rương không có thưởng.
- [ ] Thoát game trong trận rồi vào lại: về điểm hồi sinh (thường là thành). Nếu vẫn đứng trong trận đang mở, tick sẽ đăng ký lại; nếu trận đã đóng, tick đưa về Tây Kỳ.
- [ ] Đợi hết 30 phút: mọi người bị đưa về Tây Kỳ, NPC trong trận biến mất.
- [ ] Theo dõi `result.log` và log server: không có lỗi script `vt_*.lua`, `mission0x.lua`, `task0x.lua`.

### 3.3 Rủi ro cần để ý [INFERRED]
- **Sức mạnh boss**: cấp tiên và Thông Thiên lần lượt là 45/50, 65/70, 85/90, 100/105. Nếu quá khó khi chơi một mình, giảm `lv_tien`, `lv_tt`, `lv_mob` trong `build.py`.
- **Chạm trận nhãn khi chưa đủ 4 tiên**: nếu người chơi còn lệnh từ trước, trap VNG vẫn dịch chuyển vào vùng kín. Đại phu trong vùng đó có lựa chọn "Về điểm vào trận".
- **Mẫu 247 hiển thị như cổng** (passerby099) chứ không phải hình người. Nếu muốn hình người, đổi `PTVT_TH[4]` sang mẫu passerby khác.

## Phần 4: Tài liệu tham khảo
- **Mã nguồn đã đọc**:
  - `Core\Src\ScriptFuns.cpp`: InitMission, RunMission, CloseMission, timer, `AddMSPlayer`, `SetNpcRevTime`, `NewWorld`, `AddNpc`, `AddNormalItem`;
  - `KMission.cpp/.h`: `OnLeave` qua `RemovePlayer`, `StopMission` xóa NPC mission;
  - `KTaskFuns.cpp`: `task%02d.lua:OnMissionTimer`, khung hình 18 FPS;
  - `KNpc.cpp`: `LastDamage`, `DoRevive`;
  - `KSortScript.cpp`: quét `\script` lúc khởi động, `ReLoadScript`;
  - `KRegion.cpp`, `SceneDataDef.h`: Region_S gồm obstacle và trap.
- **File runtime mới**: `Server\script\phongthan\vantien\vt_data.lua`, `vt_lib.lua`, `vt_timer.lua`, `vt_thienhung.lua`, `vt_daiphu.lua`, `vt_boss.lua`, `vt_chest.lua`; `script\missions\mission01..04.lua`; `script\timertask\task01..09.lua`.
- **Backup**: `E:\VL\Phong than\PT\_backup\20261002-vantien\Server\script\missions\mission01.lua`, `...\timertask\task01.lua` (bản VLTK). Không tự khôi phục; chỉ khôi phục khi người dùng đồng ý.
- **Nguồn build và kiểm thử**:
  - `scratchpad\vantien\impl\src\` (UTF-8), `build.py`, `mapgrid.py`;
  - trình mô phỏng `scratchpad\qtest\sim_vantien.lua`. Kết quả: `out_vantien.txt` (bản build) và `out_vantien_runtime.txt` (bản đã triển khai), **80/80 ok, 0 flag**.
- **Tài liệu liên quan**: `scratchpad\vantien\vantien_report.md` (nghiên cứu), `boss-the-gioi-lenh-bai-phong-than-20260930.md` (mẫu tick), `loi-ra-ban-do-cong-dich-chuyen-phong-than-20260928.md` (đăng ký script trap).
- **Việc tiếp theo có thể làm**:
  - chuyển chuỗi nhiệm vụ ngày VNG của Thiên Hùng (`b5deef29`) với task 405–409 và set đồ cấp Vạn Tiên;
  - mở lại dòng menu Vạn Tiên của Sùng Hắc Hổ, Từ Hàng, Thiếu Hạo để trỏ sang `PTVT_EnterRequest`.
