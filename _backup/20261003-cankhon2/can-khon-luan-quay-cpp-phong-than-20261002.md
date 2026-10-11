# Càn Khôn Luân: vòng quay phía server (C++) cho Thái Tuế Sư

## Phần 1: Tổng quan

- **Trước đây:** engine không có hàm `Roulette`. Script Thái Tuế Sư (`npc_fix\1020_thai_tue.lua`) rơi vào hàm dự phòng, gọi `Finished()` ngay nên người chơi nhận thưởng tức thì, không có cảm giác "quay".
- **Bây giờ (phương án B1, chỉ C++ server):**
  - `CoreServer.dll` có hàm Lua `Roulette(k[, "tên0|tên1|..."])` và `RouletteBusy()`.
  - Khi quay, server gửi dòng chữ giữa màn hình (TopMessage) với tên ô đang được chiếu sáng. Các ô đổi nhanh lúc đầu rồi chậm dần, khoảng 5–6 giây.
  - Vòng quay dừng đúng ô `k`, nghỉ 1 giây, rồi engine gọi `Finished()` của script để phát thưởng.
- **Không cần build lại client.** Hiệu ứng chỉ là chữ, không có hình bánh xe (giới hạn của B1).
- **An toàn:**
  - mỗi nhân vật chỉ có một vòng quay tại một thời điểm;
  - nếu vòng quay bị gián đoạn (thoát game, mất kết nối, chết, đổi bản đồ) thì xóa trạng thái và **không** phát thưởng.
- **Tương thích ngược:** script vẫn giữ hàm dự phòng. Server cũ (chưa có `Roulette`) vẫn phát thưởng ngay như trước.

## Phần 2: Chi tiết

### 2.1 Luồng xử lý mới

1. Người chơi chọn "Xoay Càn Khôn Luân" → `yes_2` → `MsgBox` → `yes_3`.
   - Nếu đang quay (`RouletteBusy()==1`), cả `yes_2` lẫn `yes_3` dừng lại, báo "Càn Khôn Luân đang quay, hãy chờ kết quả!" và không trừ lượt hay vật phẩm.
2. `rolling()` bốc `k`, ghi task 72/73/764 như bản gốc, rồi gọi `Roulette(k, PT_CKL_NAMES)`.
   - Nếu engine từ chối (trả về nil), script gọi `Finished()` ngay để người chơi không mất lượt.
3. `LuaRoulette` lấy script đang chạy từ `Npc[player].m_ActionScriptID`. `ExecuteScript` gán giá trị này trước mỗi lần gọi Lua, kể cả callback của dialog. Nếu bằng 0 thì dùng `m_dwTaskExcuteScriptId`. Sau đó hàm gọi `KPlayer::PhongThanRouletteStart`.
4. `KPlayer::Active()` (server, mỗi khung, 18 FPS) gọi `PhongThanRouletteActive()`:
   - **20 bước.** Mỗi bước tiến 1 ô, bước cuối rơi đúng ô `k`.
   - **Thời gian giữa hai bước:** `2 + step²/40` khung, tức khoảng 0,1 giây lúc đầu và 0,6 giây ở cuối, tổng khoảng 5,5 giây.
   - **Bước cuối:** hiện "Càn Khôn Luân dừng tại: <màu vàng>tên ô", nghỉ 18 khung (1 giây).
   - **Kết thúc:** xóa trạng thái **trước**, rồi mới gọi `ExecuteScript(id, "Finished", k)`. Nhờ vậy, khi `Finished` mở lượt quay lại (ô Ngũ Quỷ → `MsgBox(...,"rolling")`), lượt mới vẫn bắt đầu được.
5. **Hủy vòng quay (không thưởng):**

| Tình huống | Nơi phát hiện | Báo người chơi |
|---|---|---|
| Mất kết nối / thoát game / chuyển server | nhánh `m_nNetConnectIdx == -1 \|\| m_bExchangeServer` đầu `Active()` | Không (đã offline) |
| Nhân vật bị giải phóng hoặc tái sử dụng slot | `KPlayer::Release()` gọi `PhongThanRouletteClear()` | Không |
| Chết / đang hồi sinh / máu ≤ 0 | `PhongThanRouletteActive()` | "Càn Khôn Luân bị gián đoạn, lượt quay này không có phần thưởng." |
| Đổi bản đồ (subworld khác lúc bắt đầu) | `PhongThanRouletteActive()` | Như trên |

### 2.2 Tên 12 ô

- Script truyền chuỗi `PT_CKL_NAMES` (TCVN3) theo đúng thứ tự `Finished()` (task 72 = k): Ngũ Quỷ, Đại Hao, Bạch Hổ, Thiên Cẩu, Bách Việt, Tử Vi, Thiên Đức, Thái Âm, Thái Dương, Thái Tuế, Tiểu Hao, Dịch Mã.
- C++ tách chuỗi theo dấu `|`, tối đa 16 ô, mỗi tên tối đa 31 byte.
- Nếu không có tham số thứ hai, hoặc chuỗi có dưới 2 tên, C++ dùng 12 tên mặc định giống hệt (hằng TCVN3 dạng `\x..` trong `KPlayer.cpp`). Như vậy bản VNG `\script\彩票\太岁.lua` trong ptfix, vốn gọi `Roulette(k)` một tham số, cũng chạy được.

### 2.3 Thay đổi mã nguồn (tóm tắt diff chính xác)

Thư mục gốc: `E:\VL\Phong than\PT\PhongThanSource\Sources\Core\Src`. Các file đều là UTF-8 hợp lệ (không phải GBK). Kết thúc dòng gốc (LF, một số dòng CRLF) đã được giữ nguyên. Toàn bộ code mới là ASCII.

| File | Vị trí | Thay đổi |
|---|---|---|
| `KPlayer.h` | sau `BOOL m_PlayerDBLoad;` trong khối `#ifdef _SERVER` (dòng 140) | +17 dòng: `enum { PT_ROULETTE_MAX_SECTORS = 16, PT_ROULETTE_NAME_LEN = 32 }`, các biến `m_nRouletteK` (-1 = rảnh), `m_nRouletteCount`, `m_nRouletteStep`, `m_nRouletteSubWorld`, `m_dwRouletteNextFrame`, `m_dwRouletteScriptId`, `m_szRouletteNames[16][32]`; khai báo `PhongThanRouletteStart/Abort/Active/Clear/Send` |
| `KPlayer.cpp` | `Release()`, sau `m_ImagePlayer = 0;` (khối `_SERVER`) | +1 dòng `PhongThanRouletteClear();` |
| `KPlayer.cpp` | `Active()`, nhánh return sớm | `return;` → `{ PhongThanRouletteAbort("offline", FALSE); return; }` |
| `KPlayer.cpp` | `Active()`, sau `SendCurNormalSyncData();` | +1 dòng `PhongThanRouletteActive();` |
| `KPlayer.cpp` | ngay sau hàm `KPlayer::Active()` | +~170 dòng `#ifdef _SERVER`: `PT_ROULETTE_STEPS 20`, `PT_ROULETTE_FINAL_PAUSE GAME_FPS`, bảng tên mặc định TCVN3, 3 chuỗi thông báo TCVN3, thân 5 hàm. `PhongThanRouletteSend` dựng `KPhongThanScriptAction{PHONGTHAN_SCRIPT_SHOW, UI_TOPMESSAGE, ServerOwned=1}` → `DoScriptAction`, cùng đường với Lua `TopMessage` |
| `ScriptFuns.cpp` | trước `#ifndef _SERVER` / `LuaPlaySound` (ngay trên bảng `GameScriptFuns`) | +42 dòng `#ifdef _SERVER`: `LuaRoulette` (trả 1 khi bắt đầu, nil khi bận / thiếu script / thiếu player) và `LuaRouletteBusy` (1/0) |
| `ScriptFuns.cpp` | bảng `GameScriptFuns`, sau `{"ChatRoom_AddTime", ...}` (nhánh `_SERVER`) | +3 dòng: `{"Roulette", LuaRoulette}`, `{"RouletteBusy", LuaRouletteBusy}` |

Không đụng tới các bản sửa khác trong ngày (shop, `RepairAllEquip`, CRT handler trong `KCore.cpp`, `PhongThanUpdateSetAura`...). Diff so với bản sao lưu chỉ gồm các khối "insert" ở trên.

### 2.4 Thay đổi Lua

File: `PhongThanRuntime-Staging\Server\script\phongthan\npc_fix\1020_thai_tue.lua`. File chứa TCVN3/GBK nên được sửa ở mức byte bằng Python, giữ CRLF.

- Cập nhật chú thích đầu file.
- Thêm `PT_CKL_NAMES` (12 tên TCVN3).
- Hàm dự phòng `Roulette` thêm `return 1`, để `rolling()` không gọi `Finished()` hai lần.
- Thêm `PT_CKL_Busy()`.
- Dòng đầu `yes_2()` và `yes_3()`: `if PT_CKL_Busy() then return end`.
- `rolling()`: `Roulette(k)` → `if not Roulette(k, PT_CKL_NAMES) then Finished() end`.
- Phần phát thưởng trong `Finished()` giữ nguyên.

### 2.5 Kiểm chứng

- **Build:** `CoreServer` OK, 0 lỗi. Không có warning mới trong `KPlayer.cpp` / `ScriptFuns.cpp` (chỉ còn các warning có sẵn C5208/C4005).
  - Kết quả: `PhongThanSource\OutputModern\Server\CoreServer.dll` (10/2/2026 6:23 PM, 10.017.280 byte).
  - Trong DLL có chuỗi `Roulette`, `RouletteBusy` và các tên ô TCVN3.
- **Simulator** (`qtest\sim_ckl.lua`), tất cả đạt:
  - engine cũ: thưởng ngay, đúng 1 lần;
  - engine mới: không thưởng trước khi gọi `Finished`. Bấm lại khi đang quay bị chặn, không trừ lượt. Sau `Finished` nhận thưởng 1 lần;
  - engine từ chối: thưởng ngay 1 lần;
  - đếm được đủ 12 tên.

## Phần 3: Hành động (checklist test trong game)

Điều kiện: coordinator đã deploy `CoreServer.dll` mới khi server dừng, người dùng tự bật lại server.

- [ ] Nhân vật cấp ≥ 40 đến Thái Tuế Sư (map 1020) → "Xoay Càn Khôn Luân" → đồng ý. Kỳ vọng: dialog đóng, giữa màn hình hiện "Càn Khôn Luân đang quay: <tên ô>", đổi nhanh rồi chậm dần trong khoảng 5–6 giây.
- [ ] Vòng quay dừng ở "Càn Khôn Luân dừng tại: <tên ô màu vàng>". Khoảng 1 giây sau hiện Talk phát thưởng **đúng ô đó**, kèm EXP (cấp × 100).
- [ ] Trong lúc quay, bấm lại NPC → "Xoay Càn Khôn Luân". Kỳ vọng: thông báo "đang quay, hãy chờ kết quả", không trừ lượt hay Cây/Hình thế thân.
- [ ] Quay trúng Ngũ Quỷ → MsgBox "quay lại một lần" → đồng ý. Kỳ vọng: vòng quay mới chạy bình thường.
- [ ] Đang quay thì dùng Thổ Địa Phù hoặc đổi map. Kỳ vọng: "Càn Khôn Luân bị gián đoạn...", không có thưởng.
- [ ] Đang quay thì thoát game, đăng nhập lại. Kỳ vọng: không có thưởng, không lỗi, quay lại được.
- [ ] Kiểm tra log server có `[Roulette] start ...` / `finished ...` / `abort ... reason=...`.
- [ ] (Tùy chọn) Nếu TopMessage của client chồng nhiều dòng thay vì thay thế: báo lại để chuyển sang kênh hiển thị khác.

## Phần 4: Tài liệu tham khảo

- Chẩn đoán: `scratchpad\features3\features3_report.md`, mục 2.2 (B. Càn Khôn Luân), phương án B1.
- **Bản sao lưu:** `E:\VL\Phong than\PT\_backup\20261002-cankhon\`
  - `KPlayer.cpp`, `KPlayer.h`, `ScriptFuns.cpp`;
  - `1020_thai_tue.lua`.
- Simulator: `scratchpad\qtest\sim_ckl.lua` → `out_ckl.txt`.
- Liên quan:
  - đường hiển thị `LuaTopMessage` → `LuaSendPhongThanPlayerText(UI_TOPMESSAGE)` (`ScriptFuns.cpp`);
  - `KPlayer::DoScriptAction` (`PhongThanPlayerDialog.inl`).
- **Bước tiếp theo:**
  - Nếu muốn có hình bánh xe thật, xem phương án B2 (thanh tiến trình có sẵn + ini) hoặc B3 (UI client) trong báo cáo chẩn đoán.
