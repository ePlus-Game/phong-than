---
tính năng: Bot giả người chơi (20–30 NPC mang hình người chơi)
ngày: 2026-10-02
trạng thái: Đã viết và chạy thử trong simulator, chờ khởi động lại server + client và gắn hook servertimer
phạm vi: Npcs.txt (Server + Client), script\phongthan\bots\bots.lua, không sửa C++
---

# Bot giả người chơi cho Phong Thần

## Phần 1: Tổng quan

- **Mục tiêu:** người chơi một mình vẫn thấy thế giới có người. Server luôn giữ 26 bot (chỉnh được trong khoảng 20–30). Bot có thân, giáp, mũ, vũ khí, ngựa của người chơi và mang tên kiểu người chơi Việt (ThiênLong, TiểuYến, ĐộcCôKiếm, KhóiSương…).
- **Bot làm được 4 việc:**
  1. Đứng và đi lại quanh trung tâm 5 thành: Sùng Thành doanh, Ngọc Hư cung, Xi Vưu Mộ, Tây Kỳ, Triều Ca.
  2. Đánh quái ở 20 bãi luyện công (cấp quái 3–45), dùng kỹ năng của phái mình.
  3. Nói chuyện. Bong bóng chat hiện trên đầu bot, bot chào người chơi đi ngang qua bằng tên, và thỉnh thoảng có một dòng "[Thế giới] Tên bot: …" gửi cho cả server.
  4. Tụ tập ở khu sự kiện. Trước giờ boss thế giới 10 phút đến sau giờ đó 15 phút, 4 bot sự kiện đứng quanh chỗ boss xuất hiện. Ngoài giờ boss, các bot này đứng ở Phong Thần đài (map 1001).
- **Cách làm:** chỉ dùng dữ liệu và Lua, không đụng C++.
  - Thêm 18 template mới (id 2703–2720) vào `Npcs.txt`. Template dùng thân người chơi (`男甲士/女甲士`, `男术士/女术士`, `男异人/女异人`), camp 0, AIMode 1, kỹ năng ghi bằng id số.
  - Một script `bots.lua` lo việc spawn, giữ đủ số lượng, đổi chỗ đứng và chat.
- **Phải khởi động lại cả server lẫn client.** Engine đọc `Npcs.txt` một lần lúc khởi động. File `Npcs.txt` của **client** cũng đã đổi: client cũ không có template 2703–2720 nên sẽ không vẽ được bot.
- **Bot an toàn với người chơi:** camp 0 là đồng minh với mọi phe trừ quái (camp 5), nên bot không đánh người chơi và người chơi cũng không đánh được bot.

## Phần 2: Chi tiết

### 2.1 Engine đọc Npcs.txt bản nào

| Phía | Đường dẫn engine đọc | Có trong PAK? | Bản có hiệu lực |
|---|---|---|---|
| Server | `\settings\phongthan\Npcs.txt` (`CoreUseNameDef.h:93`, `KCore.cpp:297`) | Không. `core_server_pak_diag.log` hôm nay ghi `found=0`; đã quét cả 23 PAK, kể cả `ptfix.pak` | File loose `Server\settings\phongthan\Npcs.txt` |
| Client | Cùng đường dẫn (KCore dùng chung) | Không. Đã quét 23 PAK của client | File loose `Client\settings\phongthan\Npcs.txt` |

PAK chỉ chứa bản cũ `\settings\npcs.txt` (vng00/serverlist/settings.pak), mà engine này không đọc bản đó. Vì vậy **không cần plug-in ptfix**. Hai file loose vẫn giống hệt nhau sau khi sửa (SHA-256 `05D92DEA…AA50F88`).

### 2.2 Template 2703–2720

Các dòng được nối vào cuối file ở mức byte:
- giữ 122 cột, CRLF, mã GBK;
- tên viết bằng TCVN3;
- phần đầu file giữ nguyên từng byte so với bản backup.

| Id | Thân | Tên template (dự phòng) | Giáp/Mũ | Vũ khí | Ngựa / cưỡi | Kỹ năng (id) |
|---|---|---|---|---|---|---|
| 2703–2705 | 男甲士 (Giáp Sĩ nam) | Thiết Hán, Cuồng Đao, Bá Vương | 3/4/5 | 25/27/29 | 3 đi bộ, 4 và 5 cưỡi | 29 Khai Sơn, 31 Điện Quang, 38 Liên Hoàn, 41 Thiên Quân |
| 2706–2708 | 女甲士 (Giáp Sĩ nữ) | Hồng Đao, Nữ Hiệp, Kim Phượng | 3/4/5 | 26/28/30 | như trên | như trên |
| 2709–2711 | 男术士 (Thuật Sĩ nam) | Đạo Trưởng, Lôi Pháp, Hỏa Vân | 3/4/5 | 5/7/9 | 3 đi bộ, 4 và 5 cưỡi | 5 Băng Tuyết Đạn, 6 Tích Lịch Hỏa, 15 Phong Vân Lôi Động, 18 Thập Phương Liệt Hỏa |
| 2712–2714 | 女术士 (Thuật Sĩ nữ) | Băng Nhi, Tiên Cô, Thủy Tiên | 3/4/5 | 6/8/10 | như trên | như trên |
| 2715–2717 | 男异人 (Dị Nhân nam) | Quỷ Kiến, Âm Phong, Huyết Chú | 3/4/5 | 5/7/9 | như trên | 44 Thôi Thân, 45 Bổ Tâm, 47 Phá Giáp, 49 Trảm Tâm Chú |
| 2718–2720 | 女异人 (Dị Nhân nữ) | Yêu Nữ, Linh Hồ, Dạ Lan | 3/4/5 | 6/8/10 | như trên | như trên |

Các bộ giáp, mũ, vũ khí và ngựa đều lấy từ những dòng VNG đang dùng cùng thân (靶场, 心魔…). Như vậy client chắc chắn có sẵn hình.

Các cột chung của 18 template:

| Nhóm cột | Giá trị |
|---|---|
| `Kind`, `Camp` | 0, 0 |
| Kỹ năng | `Level1..4` = `10\|0` (cấp kỹ năng 10) |
| AI | `AIMode` 1. `AIParam` = 40, 25, 25, 25, 25, 0, 0. `VisionRadius` 450, `ActiveRadius` 700, `AIMaxTime` 10 |
| Chỉ số theo cấp (`standard.lua`: giá trị = P1 + P2 × cấp) | Máu 800 + 120 × cấp. AR 150 + 6 × cấp. Né 60 + 3 × cấp. Thủ 30 + 3 × cấp. Sát thương 20 + 3 × cấp đến 40 + 5 × cấp. Kinh nghiệm 0 |
| Hồi sinh | `ReviveFrame` 540 (30 giây). Không có `DeathScript` |
| Hẹn giờ | `TimerScript` = `\script\phongthan\bots\bots.lua`, `TimerValue` 30 (bong bóng chat) |

Cấp của bot được truyền lúc `AddNpc`:
- ở thành: cấp 40–90;
- ở bãi quái: cấp quái + 8 đến 15;
- ở chỗ boss: bằng cấp boss.

### 2.3 Script `Server\script\phongthan\bots\bots.lua`

File được sinh ra từ `scratchpad\bots\gen_bots.py` cùng với `bots_template.lua`. File thuần ASCII; chuỗi TCVN3 viết dạng `\ddd`.

| Hàm | Việc làm |
|---|---|
| `PTBOT_Tick()` | servertimer gọi mỗi phút. Lần đầu chạy `PTBot_Init`. Sau đó, với từng bot: nếu bot mất thì spawn lại; nếu hết thời gian đứng một chỗ (8–20 phút) thì đổi chỗ (mỗi phút tối đa 4 bot). Bot sự kiện đổi chỗ ngay khi cửa sổ boss mở hoặc đóng. Cuối tick là chào người chơi và gửi chat thế giới |
| `PTBot_Init()` | Gọi `ReLoadScript` cho chính file này để `OnTimer` chạy được. Xoá các bot "mồ côi" còn sót khi state của servertimer bị nạp lại: duyệt 48 000 NPC, `GetNpcID ≠ 0` và template nằm trong 2703–2720 |
| `PTBot_Place(b)` | Chọn chỗ theo vai trò của bot, kiểm tra map đã nạp (`SubWorldID2Idx`), lệch ngẫu nhiên ±6 ô, rồi `AddNpc` (thử 9 điểm lệch có kiểm tra vật cản, cuối cùng đặt không kiểm tra). Sau đó `SetNpcName`, `SetNpcParam(1 = loại chỗ, 2 = số thứ tự bot)` và `SetNpcTimer` |
| `PTBot_BossWindow()` | Đọc `PTWB_LIST` (`boss\wb_data.lua`). Chọn boss có giờ ra nằm trong khoảng −10/+15 phút, ưu tiên boss cấp cao. Map của boss phải đã nạp |
| `PTBot_Greet()` | Với người chơi online đứng cách bot ≤ 20 ô (cùng map): bot nói "Chào <tên>!" hoặc một câu tương tự. Mỗi phút tối đa 3 câu; mỗi người chơi được chào lại sau ít nhất 10 phút |
| `PTBot_WorldChat()` | Cứ 2–5 phút gửi một dòng `Msg2SubWorld("<color=yellow>[Thế giới] Tên<color>: …")` |
| `OnTimer(npcIndex)` | Chạy trong state đã đăng ký. 45% khả năng nói một câu `NpcChat` hợp ngữ cảnh (thành / bãi quái / sự kiện), sau đó hẹn lần kế tiếp sau 25–75 giây |

Phân bổ 26 bot:
- 11 bot ở thành, 11 bot ở bãi quái, 4 bot sự kiện.
- Mỗi lần đổi chỗ, bot thành có 30% khả năng đi luyện công. Ngược lại, bot luyện công có 30% khả năng về thành.

Các biến cấu hình đầu file:
- `PTBOT_COUNT` = 26
- `PTBOT_MOVE_PER_TICK` = 4
- `PTBOT_STAY_MIN/MAX` = 8/20
- `PTBOT_WORLD_CHAT` = 1
- `PTBOT_GREET_CD` = 10
- `PTBOT_ARENA_DUEL` = nil

Tất cả hàm Lua dùng trong script đều có trong bảng đăng ký của `ScriptFuns.cpp`: `AddNpc`, `DelNpc`, `SetNpcName`, `GetNpcName`, `GetNpcID`, `GetNpcTemplateID`, `GetNpcPos`, `SetNpcParam`, `GetNpcParam`, `SetNpcTimer`, `SetNpcCamp`, `SetNpcCurCamp`, `NpcChat`, `Msg2SubWorld`, `SubWorldID2Idx`, `ReLoadScript`, `GetName`, `GetWorldPos`. Không dùng biến task nào.

### 2.4 Giới hạn của cách chỉ dùng Lua (không sửa C++)

| Giới hạn | Nguyên nhân trong engine | Cách xử lý |
|---|---|---|
| Không ra lệnh "đi bộ tới X" được | Lua không có walk-to. `SetNpcPos` dịch chuyển tức thời và không đổi điểm gốc AI | Đi lại tại chỗ dựa vào AIMode 1 (tuần tra quanh điểm gốc trong bán kính 700, đuổi quái trong tầm 450). Muốn đổi chỗ thì `DelNpc` rồi `AddNpc` nơi mới, nên người chơi sẽ thấy bot biến mất ở chỗ cũ và xuất hiện ở chỗ mới |
| Ngoại hình cố định theo template | Không có hàm Lua nào đổi giáp hay thân của NPC | 18 bộ ngoại hình xoay vòng cho 30 tên |
| Chat thế giới chỉ là dòng hệ thống | Client bỏ tên người gửi ở kênh −1 | Ghi tên bot vào đầu nội dung |
| Bấm vào bot thì thấy là NPC, không có bang hội, danh hiệu hay tổ đội | Bot là `kind_normal` | Không dùng `kind_player`: đường `AddBot` có hơn 100 chỗ truy cập `Player[0]` (xem `scratchpad\bots\bots_report.md`) |
| AIParam có thể "dính" từ NPC cũ | `KNpc::LoadDataFromTemplate` chỉ chép `m_AiParam` (gồm cả bán kính đánh) lần đầu tiên một ô NPC được dùng (`m_AiSkillRadiusLoadFlag`) | Khi đổi chỗ, `DelNpc` + `AddNpc` dùng lại đúng ô vừa trả (danh sách ô trống kiểu LIFO), nên bot thường giữ AIParam của bot. Nếu một bot nhận ô cũ của quái thì có thể đánh hơi khác, nhưng tự hết ở lần đổi chỗ sau |
| Quái do bot giết chạy death script mà không có người chơi | `m_nDeathScriptPlayerIdx = 0`. Engine đã chặn `DropRate` và `LastDamage` khi `nPlayer = 0` (`KNpc.cpp:1712-1718`) | Không rơi đồ, không cộng nhiệm vụ cho ai. Bot sẽ "giành quái" với người chơi như người thật |
| Bot ở khu boss có thể tranh đòn kết liễu boss | Bot đánh mọi kẻ địch trong tầm 450 | Bot sự kiện đứng cách chỗ boss 18–26 ô, ngoài tầm nhìn của boss. Bot chỉ vào đánh nếu boss đi lại gần |
| PK giữa bot | Bot camp 1 gặp bot camp 2 là địch, nhưng bot camp 1/2 cũng đánh người chơi thuộc camp khác 0 | Tắt mặc định (`PTBOT_ARENA_DUEL = nil`). Bật lên thì bot ở Phong Thần đài chia hai phe và đánh nhau |

## Phần 3: Hành động

### 3.1 Việc của người điều phối (agent bots không tự sửa các file dùng chung)

- [ ] Thêm hook vào `Server\script\servertimer.lua`, **đặt sau `PTAdm_WbTick()`** (bot cần `PTWB_LIST`):
  ```lua
  -- 2026-10-02 bot gia nguoi choi (20-30 NPC hinh nguoi choi o thanh, bai quai, khu boss/PK, chat).
  -- Logic trong script\phongthan\bots\bots.lua (template 2703-2720 trong settings\phongthan\Npcs.txt).
  function PTAdm_BotTick()
  	if not PTBOT_Tick then dofile("script\\phongthan\\bots\\bots.lua") end
  	if PTBOT_Tick then PTBOT_Tick() end
  end
  ```
  Sau đó gọi `PTAdm_BotTick()` trong `PTAdm_Tick()`, ngay sau dòng `PTAdm_WbTick()`. Tần suất: mỗi phút (theo nhịp servertimer).
- [ ] Ghi `CHANGELOG.md` và `docs\features\README.md`.

### 3.2 Người dùng kiểm tra trong game

1. [ ] **Khởi động lại server**, vì `Npcs.txt` chỉ được nạp lúc khởi động và `bots.lua` được đăng ký lúc quét script.
2. [ ] **Khởi động lại client** (thoát hẳn rồi mở lại), vì `Client\settings\phongthan\Npcs.txt` đã đổi.
3. [ ] Đợi 1–2 phút sau khi server lên. Về Sùng Thành doanh (1002) hoặc Tây Kỳ (1020): thấy vài bot mang tên người chơi, có thân, giáp, vũ khí, một số cưỡi ngựa, đi lại quanh khu NPC bán hàng.
4. [ ] Đứng gần bot khoảng 1 phút: bot chào "Chào <tên bạn>!" hoặc một câu tương tự; thỉnh thoảng có bong bóng chat trên đầu bot.
5. [ ] Trong khung hệ thống, cứ vài phút có một dòng "[Thế giới] <tên bot>: …".
6. [ ] Ra bãi quái, ví dụ Sùng Thành ngoài thành (1005), Mạnh Tân (1015) hoặc Hoang Mạc (1022): bot dùng kỹ năng phái đánh quái, quái hồi sinh thì bot đánh tiếp.
7. [ ] Bật chế độ chiến đấu rồi thử đánh bot: không đánh được. Bot cũng không đánh bạn.
8. [ ] Khoảng phút 50–59 mỗi giờ (Cửu Linh ra lúc :59 ở Tam Sơn 1016): thấy 4 bot đứng cách chỗ boss khoảng 20 ô.
9. [ ] Đứng nhìn một con bot 10–20 phút: nó biến mất và xuất hiện ở chỗ khác. Đây là cách đổi chỗ có chủ ý.
10. [ ] Nếu không thấy bot nào: mở `Server` log tìm `[AddNpc] invalid template` (nghĩa là server chưa nạp `Npcs.txt` mới), và kiểm tra hook servertimer đã được thêm chưa.

### 3.3 Hoàn tác

- Bản gốc nằm ở `E:\VL\Phong than\PT\_backup\20261002-bots\{Server,Client}\settings\phongthan\Npcs.txt`. Theo CLAUDE.md, **chỉ khôi phục khi người dùng đồng ý**.
- Cách tắt bot nhanh mà không phải khôi phục: bỏ dòng `PTAdm_BotTick()` khỏi servertimer, hoặc đặt `PTBOT_COUNT = 0` (lần tick sau sẽ xoá hết bot).

## Phần 4: Tài liệu tham khảo

- Nghiên cứu gốc: `scratchpad\bots\bots_report.md`.
- Bộ sinh dữ liệu: `scratchpad\bots\gen_bots.py` (`rows` | `lua`) và `scratchpad\bots\bots_template.lua`.
- Test simulator: `scratchpad\qtest\sim_bots.lua`, kết quả ở `out_bots.txt`. Kết quả:
  - 26/26 bot sống ở mọi tick;
  - 3 bot bị xoá từ bên ngoài được spawn lại ở tick sau;
  - bot mồ côi bị dọn; ô NPC đã trả với template cũ không bị `DelNpc` lần hai;
  - bot sự kiện chuyển tới Bàn Cổ (1051) lúc 17:55;
  - `PTBOT_COUNT = 20` thì 6 bot thừa bị xoá;
  - bật duel thì 3 bot ở 1001 nhận camp đấu;
  - không có lỗi runtime.
- Mã engine:
  - spawn: `ScriptFuns.cpp:4056` (`AddNpc`), `4095` (`DelNpc`), `4669` (`SetNpcTimer`), `9490` (`NpcChat`), `2477` (`Msg2SubWorld`);
  - hồi sinh: `KNpc.cpp:1817-1906`, `2309-2370`, `7995-8020`;
  - AI: `KNpcAI.cpp:1172-1427`;
  - phe: `KNpcSet.cpp:158-195`;
  - template: `KNpcTemplate.cpp`, `KNpc.cpp:265-360`, `7655-7786`.
- Liên quan: `boss\wb_data.lua` (lịch boss thế giới), `spawn\spawn_<map>.lua` (toạ độ bãi quái), `revivepos.ini` (toạ độ Phong Thần đài).

## Bổ sung 2026-10-02 (lần 2): bot đi theo người chơi
- **Yêu cầu:** đi đến đâu cũng có khoảng 30–50 bot chơi cùng.
- **Trước đây:** 26 bot rải cố định ở 5 thành và 20 bãi luyện công, nên người chơi hiếm khi gặp.
- **Nay (PTBOT_FOLLOW = 1):**
  - Có **40 bot** (PTBOT_COUNT). Danh sách tên tăng lên 46.
  - Mỗi phút, mỗi bot được gán cho một người chơi đang online. Bot nào cách mọi người chơi hơn 45 ô sẽ được đưa tới quanh người chơi đó, cách 6–28 ô, tối đa 50 bot mỗi phút. Vì vậy dịch chuyển sang bản đồ khác thì khoảng 1 phút sau bot sẽ có mặt.
  - Cấp của bot bằng cấp người chơi ±5, nên bot đánh được quái quanh đó (quái đã có kỹ năng thật).
  - Ở thành, bot nói câu kiểu "thành"; ở bãi quái, bot nói câu kiểu "luyện công".
  - Khi không ai online, bot quay về cách cũ (thành, bãi quái, boss).
- **Chỉnh nhanh** (đầu file ots.lua):
  - PTBOT_COUNT: tối đa 46;
  - PTBOT_NEAR;
  - PTBOT_RING_MIN / PTBOT_RING_MAX.
- **Lưu ý:** bản runtime script\phongthan\bots\bots.lua giờ là bản gốc. Đừng chạy lại gen_bots.py, vì nó sẽ ghi đè phần đi theo người chơi.
- Backup _backup\20261002-botfollow\. Mô phỏng: 40/40 bot sống ở mọi tick, chia đều quanh 2 người chơi.
- **Cần khởi động lại server.**