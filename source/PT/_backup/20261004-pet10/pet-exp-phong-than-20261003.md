# Đệ tử Dị Nhân có kinh nghiệm và cấp riêng (petexp)

Ngày: 2026-10-03. Yêu cầu: "Quái chết đệ tử chưa tăng kinh nghiệm và lên level". Người dùng chọn phương án **đệ tử có kinh nghiệm riêng**, không trừ kinh nghiệm của chủ.

## Phần 1: Tổng quan

- Mỗi quái thường chết do chủ hoặc đệ tử hạ, nếu đệ tử đang được gọi ra và ở gần, thì đệ tử nhận kinh nghiệm riêng. Kinh nghiệm của chủ giữ nguyên.
- Kinh nghiệm và cấp của đệ tử lưu theo nhân vật: **task 2505 = cấp**, **task 2506 = kinh nghiệm trong cấp hiện tại**. Đăng xuất hay khởi động lại máy chủ vẫn giữ.
- Một cặp task dùng chung cho cả 12 loại đệ tử. Lý do:
  - Người chơi nuôi một đệ tử; lệnh bài chỉ chọn hình thái để gọi ra.
  - Nếu tách riêng thì tốn 24 task, và đổi loại đệ tử là mất công nuôi lại từ đầu.
  - Đệ tử gọi bằng kỹ năng 450–461 cũng góp chung vào cặp task này.
- Đủ kinh nghiệm thì đệ tử lên cấp, có thông báo. Đệ tử lệnh bài đang đứng ngoài được áp cấp mới ngay: hồi đầy máu, máu tối đa và cấp kỹ năng tăng.
- Toàn bộ làm bằng Lua, áp nóng được, không cần sửa C++. `KNpcDeathCalcExp.cpp` không bị đụng tới.

## Phần 2: Chi tiết

### 2.1 Công thức

| Mục | Giá trị |
|---|---|
| Cấp ban đầu | 1 (task 2505 = 0 được đọc là cấp 1) |
| Kinh nghiệm cần để lên cấp kế | `2 × cấp × (cấp + 10)`: cấp 1 cần 22, cấp 10 cần 400, cấp 50 cần 6.000, cấp 100 cần 22.000, cấp 149 cần 47.382 |
| Kinh nghiệm mỗi quái | Bằng cấp quái (tối thiểu 1) |
| Đuổi cấp | Gấp 4 khi đệ tử thấp hơn giới hạn cấp từ 10 cấp trở lên |
| Quái xám | Chia 4 (tối thiểu 1) khi quái thấp hơn đệ tử quá 10 cấp |
| Giới hạn cấp | Không vượt cấp chủ, tối đa 150 (giống VNG: thú nuôi không vượt chủ). Khi đã bằng cấp chủ, thanh kinh nghiệm dừng ở mức đầy; chủ lên cấp thì quái kế tiếp đẩy đệ tử lên tiếp |
| Nhiều cấp một lần | Có, phần dư được chuyển sang cấp sau |

Ví dụ: chủ cấp 60, đệ tử cấp 30 đánh quái cấp 50 thì mỗi con được 200 kinh nghiệm (50 × 4).

### 2.2 Đệ tử mạnh lên theo cấp (đệ tử lệnh bài)

`SetNpcOwner(idx, tên, 0)` trong C++ (`ScriptFuns.cpp` `LuaSetNpcOwner`) sao chép từ chủ sang đệ tử: sát thương vật lý và nguyên tố, chính xác, phòng thủ, tốc độ, `m_CurrentLifeMax`, `m_CurrentManaMax`. Nó không đặt máu hiện tại, nên trước đây đệ tử ra đời với máu theo mẫu NPC chứ không đầy.

Cấp NPC truyền vào `AddTotemNpc` chỉ ảnh hưởng chỉ số mẫu (bị `SetNpcOwner` ghi đè), cấp hiển thị, và cấp kỹ năng tính từ cột `Level1..4` của mẫu. Cột này của cả 12 mẫu đều là `1`, nên kỹ năng đệ tử luôn ở cấp 1. Vì vậy cấp đệ tử phải tác động trực tiếp qua native có sẵn:

| Cách áp | Native | Công thức |
|---|---|---|
| Cấp NPC khi gọi | `AddTotemNpc(tpl, cấp đệ tử, ...)` | Thay cho `GetLevel()` của chủ |
| Máu tối đa (và hồi đầy) | `GetNpcLife(npc chủ)`, `SetNpcLife(idx, v, 1)` | Máu tối đa của chủ × (100 + cấp) %. Cấp 50 là 150%, cấp 150 là 250% |
| Cấp kỹ năng đệ tử | `SetNpcSkill(idx, kỹ năng, cấp, ô 1..4)` | `1 + cấp/15`, tối đa 10 (`MaxLevel` trong skills.txt). Kỹ năng cung của đệ tử có `physicsenhance_p = 20 + 5 × cấp`, tức từ 25% lên 70% |
| Tên | `SetNpcName` | `[cấp]Tên`, giống cách VNG đặt tên đệ tử kỹ năng `[%d]%s` |

Kỹ năng theo mẫu (Npcs.txt): 360→141, 361→139, 362→132, 403→142, 404→143, 405→144, 406→140, 407→145, 1345→388, 1346→297, 2032→1996. Mẫu 359 Lực Sĩ tế dùng 63 (đánh thường, `MaxLevel` 0) nên không đổi cấp kỹ năng, chỉ tăng máu.

Không có native đọc hay đặt sát thương nguyên tố, phòng thủ riêng cho NPC theo %, nên phần sát thương vẫn sao chép từ chủ và tăng nhờ cấp kỹ năng.

### 2.3 Khi nào được tính kinh nghiệm

- Death script quái thường: `KNpcTemplate` chuyển `\script\npcdeath\normal.lua` sang `\script\phongthan\npc_quests\normal.lua`. Trong `Npcs.txt` có 399 mẫu quái thường (Kind 0) dùng file này. 157 mẫu không có death script; trong đó 58 có kinh nghiệm, toàn là rương, boss sự kiện, totem và mẫu biến hình. Boss có death script riêng **không** cho đệ tử kinh nghiệm.
- `PlayerIndex` trong `OnDeath` là người `KNpcDeathCalcExp::CalcExp` chọn. Sát thương của đệ tử được ghi cho chủ, nên khi đệ tử hạ quái thì vẫn là chủ.
- Đệ tử lệnh bài (task 1941/1942) được tính khi: chủ đúng tên, mẫu đúng (kể cả hình 2651–2656), NPC còn sống, cùng bản đồ với chủ và cách chủ không quá 60 ô theo mỗi trục.
- Đệ tử kỹ năng 450–461: Lua không có native lấy `m_nPetIdx`. Dùng `PetGetType()`: hàm này trả mẫu NPC của đệ tử kỹ năng khi nó còn sống. Có thì được tính kinh nghiệm, nhưng không kiểm tra được khoảng cách.
- Chỉ phái Dị Nhân (`GetProfession() == 2`).

### 2.4 Lệnh bài

- Lời thoại menu chính thêm một đoạn màu xanh lá: "Đệ tử cấp N, kinh nghiệm E/Cần". Khi bằng cấp chủ có thêm "(đã bằng cấp chủ)"; ở cấp 150 là "(cấp tối đa)".
- Menu vẫn 7 dòng, không thêm dòng.
- Gọi đệ tử: "Đã gọi đệ tử: Tên (cấp N)".

### 2.5 Đệ tử từ kỹ năng 450–461

- **Kinh nghiệm: đã áp dụng.** Giết quái khi đệ tử kỹ năng còn sống thì được tính vào cùng cặp task 2505/2506.
- **Sức mạnh theo cấp: chưa áp dụng.** Lua không lấy được chỉ số NPC của đệ tử kỹ năng. Đệ tử này vẫn theo luật VNG trong C++ (`KSkills.cpp` `SKILL_SS_CreateNpc`): cộng chỉ số của chủ, cấp kỹ năng ô 4 bằng cấp kỹ năng triệu hồi (tối đa 10).
- Muốn áp dụng thì cần thêm một native C++ nhỏ (ví dụ `GetSummonPetIdx()` trả `Npc[người chơi].m_nPetIdx`), rồi gọi lại `PTPE_Apply`. Lần này không làm, vì có agent khác đang sửa và build Core.

### 2.6 File và cách sinh

| File | Vai trò |
|---|---|
| `scratchpad\skill180\mktrieuhoi.py` | Generator. Sinh cả lệnh bài lẫn thư viện; không sửa tay file runtime |
| `Server\script\phongthan\lib\petexp_lib.lua` (mới) | Thư viện `PTPE_*`: cấp, công thức, kiểm tra đệ tử, áp sức mạnh, hook giết quái, dòng thông tin |
| `Server\script\phongthan\item\trieuhoi_lenhbai.lua` | Include thư viện (có bảo vệ); gọi đệ tử theo cấp đệ tử; thông tin trong lời thoại |
| `Server\script\phongthan\npc_quests\normal.lua` | Nối thêm cuối file: Include thư viện và bọc `OnDeath` gọi `PTPE_OnKill` trong `call(..., "x", ...)`. Phần trên giữ nguyên từng byte |
| `scratchpad\petexp\patch_normal.py` | Bản vá ở mức byte cho `normal.lua`, chạy lại nhiều lần không trùng (có dấu `-- 2026-10-03 petexp:`) |

An toàn khi lỗi:

- Include trong lệnh bài và trong `normal.lua` đều được bọc `call`. Nếu thiếu thư viện thì lệnh bài chạy như cũ (cấp chủ, tên thường).
- Lỗi trong hook đệ tử không làm dừng `OnDeath` gốc và hook Tứ Linh.
- Hàm nào dùng native mới cũng kiểm tra native đó có tồn tại trước khi gọi.

### 2.7 Chọn số task

- Đã quét bằng `scratchpad\petexp\taskscan.py`, bản mở rộng từ `daily3\taskscan.py`. Phạm vi quét: mọi entry văn bản của mọi PAK, `script.pak`, `ptfix.pak` đang chạy, toàn bộ `Server\script` rời, toàn bộ `Server\settings` rời và `admin_bridge`.
- Dải 2505–2509 không có `GetTask` hay `SetTask` nào. Các số 2500–2502 chỉ xuất hiện dưới dạng hằng (tỉ lệ rơi, khoảng cách, tọa độ).
- Engine giữ riêng 4800–4999, nên không dùng dải đó. Dải 1943–1950 gần task đệ tử cũ thì đã bị script liên server của VNG dùng.

## Phần 3: Hành động

### 3.1 Kiểm thử đã chạy (Lua 4, `scratchpad\qtest`)

| Mô phỏng | Kết quả |
|---|---|
| `sim_petexp.lua -Stack 100` (bản nháp và bản đã triển khai `-Args1 live`) | FAILS=0, 43 kiểm tra |
| `sim_petexp.lua -Stack 0 -Args1 emu` / `emu,live` (khoảng trống stack như engine, 47 khung) | FAILS=0, khoảng trống nhỏ nhất 46 khung, không tràn stack |
| `sim_petmorph.lua` thường và `emu` (bản gốc) | FAILS=0 |
| `sim_petskill.lua` (bản gốc) | Không có lỗi |
| `sim_petmorph_pe.lua` thường, `emu`, `live`, `emu,live` (chạy nguyên sim_petmorph trên lệnh bài mới có thư viện; chỉ đổi kiểm tra menu 17 dòng thành 7 dòng theo menu của coordinator) | FAILS=0 |
| `sim_petskill_pe.lua` (sim_petskill trên lệnh bài mới) | Không có lỗi; khác bản cũ đúng ở menu 7 dòng và "AddTotemNpc lv1 / (cấp 1)" |
| `t_qnormal.lua` (normal.lua đã triển khai) | wrapper=1 hits=1, sau lỗi vẫn chạy |

`sim_petexp` kiểm tra:

- menu 7 dòng có dòng cấp đệ tử;
- gọi ở cấp 1 và cấp 30: cấp NPC, tên, máu 101% và 130%, kỹ năng 143 cấp 3 ở 4 ô;
- hook giết quái: `OnDeath` gốc và hook Tứ Linh vẫn chạy;
- được +200 khi đuổi cấp; không được khi đệ tử xa 61 ô, khác bản đồ, hoặc ô 1941 là NPC của người khác;
- đệ tử kỹ năng (kể cả hình VNG) được tính; không có đệ tử thì không được;
- lên cấp áp ngay cho đệ tử đang đứng ngoài; lên nhiều cấp một lần; quái xám chia 4;
- giới hạn bằng cấp chủ: dừng ở mức đầy, chủ lên cấp thì đệ tử lên theo; cấp 150 có thông báo tối đa;
- khác phái hoặc `PlayerIndex` = 0: không tính;
- lỗi trong hook không làm dừng `OnDeath`;
- thiếu thư viện: lệnh bài vẫn chạy kiểu cũ;
- luồng đổi hình (Thỏ Vàng), gọi về, thu hồi, học kỹ năng, trang 2 vẫn đúng.

### 3.2 Áp nóng

- Đã ghi `admin_bridge\pending.lua`, chỉ ghi khi file chưa có. Nội dung: `ReLoadScript` cho `petexp_lib.lua`, `trieuhoi_lenhbai.lua`, `npc_quests\normal.lua`, rồi `PTAdm_Log("petexp", ...)` kèm kiểm tra native.
- Kết quả, `result.log` lúc 20:15:00:
  - dòng `petexp OK`;
  - `SetNpcSkill`, `SetNpcLife`, `GetNpcLife`, `PetGetType`, `SetNpcName` đều có;
  - `ReLoadScript` trả `nil`. Đây là bình thường: `LuaReLoadScript` không trả giá trị.
- Không cần khởi động lại máy chủ.

### 3.3 Người dùng cần làm

- [ ] Vào game bằng nhân vật Dị Nhân, dùng Lệnh Bài Triệu Hồi. Lời thoại phải có "Đệ tử cấp 1, kinh nghiệm 0/22".
- [ ] Gọi một đệ tử. Tên hiện `[1]Tên`, thông báo "(cấp 1)".
- [ ] Đánh vài quái cùng đệ tử. Có thông báo "Đệ tử lên cấp N! ...". Mở lại lệnh bài thì kinh nghiệm tăng.
- [ ] Đệ tử đang đứng ngoài đổi tên `[N]` ngay trên máy chủ. Máy khách có thể chỉ hiện tên mới sau khi gọi lại đệ tử.
- [ ] Nếu đã gọi đệ tử trước lúc áp nóng: thu hồi rồi gọi lại để đệ tử nhận cấp đệ tử.

## Phần 4: Tài liệu tham khảo

- Tài liệu liên quan: `de-tu-trieu-hoi-di-nhan-phong-than-20261001.md`, `ky-nang-de-tu-di-nhan-phong-than-20261002.md`, `doi-hinh-dang-de-tu-phong-than-20261003.md`, `petfight-tokenmenu-phong-than-20261003.md`, `desert-exp-phong-than-20261003.md`.
- Mã C++ đã đọc (không sửa):
  - `ScriptFuns.cpp`: `LuaSetNpcOwner`, `LuaSetNpcLife`, `LuaSetNpcSkill`, `LuaPetGetTypeCompat`;
  - `PhongThanLuaWave7.h`: `LuaAddTotemNpcCompat`;
  - `KNpc.cpp`: `DoDeath`, `ApplyPhongThanNpcLevelData`;
  - `KNpcDeathCalcExp.cpp` `CalcExp`;
  - `KSkills.cpp` `SKILL_SS_CreateNpc`;
  - `KSkillManager.cpp` `InstanceSkill`.
- Backup: `_backup\20261003-petexp\` (trieuhoi_lenhbai.lua, normal.lua, mktrieuhoi.py, CHANGELOG.md, README.md).
- Bước tiếp theo, nếu muốn:
  - thêm native C++ `GetSummonPetIdx` để đệ tử kỹ năng 450–461 cũng mạnh lên theo cấp;
  - thêm bảng kinh nghiệm riêng cho boss.
