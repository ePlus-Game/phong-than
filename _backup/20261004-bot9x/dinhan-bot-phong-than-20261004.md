---
title: Bot tổ đội Dị Nhân không đánh + đệ tử của bot Dị Nhân
slug: dinhan-bot
date: 2026-10-04
status: Lua xong (chờ cài runtime), C++ đã build (chờ triển khai CoreServer)
tags: [bot-to-doi, di-nhan, de-tu, ai11, cpp, lua]
summary: >
  Bot tổ đội Dị Nhân (mẫu 2715–2720) chỉ dùng kỹ năng ô 4 là 49 Trảm Tâm Chú. Đây là chú nguyền giảm lực tấn
  công của địch, không có thuộc tính sát thương, nên bot "đánh" mà quái không mất máu. Cách sửa: party.lua đổi ô 4
  sang 44 Thôi Thân Chú. Ngoài ra bot Dị Nhân giờ gọi 1 đệ tử theo cấp người chơi; đệ đi theo bot và đánh quái.
  Phần đệ tử cần C++ mới (AddNpcPet, GetNpcPetIdx, chuỗi chủ trong CalcDamage).
---

# Bot tổ đội Dị Nhân không đánh + đệ tử của bot Dị Nhân

## Phần 1: Tổng quan

- **Nguyên nhân là dữ liệu, không phải engine.** AI 11 của bot (`KNpcAI::ProcessAIType11`, `KNpcAI.cpp` dòng 1828) luôn gọi `SetActiveSkill(4)`. Bot Dị Nhân có ô 4 là **49 Trảm Tâm Chú**. Chiêu này là chú nguyền (debuff): chỉ gắn trạng thái giảm lực tấn công lên địch, không gây sát thương. Bot vẫn niệm chú, nhưng quái không mất máu.
- Giáp Sĩ (ô 4 = 41 Thiên Quân Trảm) và Đạo Sĩ (ô 4 = 18 Thập Phương Liệt Hỏa) có ô 4 là chiêu sát thương, nên đánh bình thường.
- **Người chơi Dị Nhân không bị lỗi engine.** 47 Phá Giáp Chú và 49 Trảm Tâm Chú là chú nguyền theo thiết kế VNG: người chơi dùng cũng không ra sát thương. Chiêu đánh của Dị Nhân là 44 Thôi Thân Chú; chiêu này dùng MisslesForm 6 (AtTarget) với missile 128 đứng yên tại mục tiêu, giống hệt cách Giáp Sĩ 41 dùng missile 123. Lỗi nổ về bản thân của Chưởng Tâm Lôi / Băng Tuyết Đạn / Tích Lịch Hỏa (dạng Line) đã được bản vá skillself sửa; lỗi này không liên quan.
- **Đệ tử của bot Dị Nhân:** trước đây bot không có đệ. Giờ mỗi bot Dị Nhân gọi 1 đệ. Mẫu đệ chọn theo cấp người chơi, cùng bảng `PTTH_LIST` của Lệnh Bài Triệu Hồi; cấp đệ 1–10 theo công thức pet10. Chủ của đệ là chính bot NPC. Kinh nghiệm, đồ rơi và LastDamage từ đòn đánh của đệ được tính cho người chơi.

## Phần 2: Chi tiết

### 2.1 Bằng chứng dữ liệu

| Kỹ năng | Dữ liệu (`settings\skills.txt`, ptfix) | Script cấp (`script\skill\yiren\*.lua`) | Kết luận |
|---|---|---|---|
| 49 Trảm Tâm Chú (ô 4 của bot) | StateSpecialId 14, LvlSetting1 `addphysicsdamage_v`, child 127 (MoveKind 0, DmgRange 10) | `addphysicsdamage_v = -(20 + 5·lv)` trong `72 + 18·lv` khung | Chỉ trừ lực tấn công, **0 sát thương** |
| 47 Phá Giáp Chú | StateSpecialId 12, `addexdefense_v`, `allres_p`, child 131 | `-(30 + 2·lv)` phòng thủ, `-(15 + lv)`% kháng | Chú nguyền, 0 sát thương |
| 44 Thôi Thân Chú | IsPhysical 1, `physicsenhance_p`, MisslesForm 6, child 128 (Stand, CollidRange 1) | `physicsenhance_p = 16 + 4·lv` | **Chiêu đánh** (giống 41 của Giáp Sĩ) |
| 45 Bổ Tâm Chú | TargetAlly / TargetSelf, `lifepotion_v` | — | Hồi máu đồng minh |

Dòng dữ liệu bot trong `settings\phongthan\Npcs.txt` (file rời, server và client giống nhau): dòng file 2716–2721, tức mẫu 2715–2720, có Skill1..4 = 44 / 45 / 47 / 49, Level `10|0`. Cách đọc `10|0` không có lỗi: Giáp Sĩ và Đạo Sĩ ghi cùng dạng và đánh bình thường.

Những nghi phạm khác đã loại trừ:
- Missile 127 / 128 / 131: không phải lỗi va chạm. 128 có cùng dạng với 123 của Giáp Sĩ (Stand, CollidRange 1).
- `CastMissles` với `SKILL_MF_AtTarget` (`KSkills.cpp` 1185): không phân biệt NPC hay người chơi.
- Mana / vũ khí: NPC không bị trừ cost (`m_Kind != kind_player || Cost(...)`).

### 2.2 Sửa kỹ năng (chỉ Lua)

`script\phongthan\bots\party.lua` (nguồn `scratchpad\botparty\src\party.lua`, sinh bằng `gen.py`), hàm `PTBP_DnTick`:
- Với mọi bot tổ đội mẫu 2715–2720, gọi `SetNpcSkill(bot, 44, 10, 4)` và `SetNpcSkill(bot, 49, 10, 1)` (đổi chỗ ô 1 và ô 4). Mỗi bot chỉ làm 1 lần, đánh dấu bằng NpcParam 3 = 1.
- Không sửa `Npcs.txt` vì file rời này nhiều tính năng dùng chung. Nếu đưa vào ptfix thì các lần sửa file rời sau này sẽ bị ptfix che mất.
- Engine hiện tại đã có `SetNpcSkill`, nên phần này có hiệu lực ngay khi cài party.lua, không cần khởi động lại.

### 2.3 Đệ tử của bot Dị Nhân

**Lua (`party.lua`):**
- `PTBP_PetPick(lv)` chọn hàng cao nhất của `PTBP_PET` (= `PTTH_LIST`: 359/5 … 2032/120) có cấp học ≤ cấp người chơi. Cấp đệ = `(lv - cấp học) / 5 + 1`, giới hạn 1–10. Cấp NPC = `cấp học + 5·(cấp đệ - 1)`, không vượt cấp người chơi. Ví dụ người chơi cấp 50 được 403 Hỏa Lôi tế, NPC cấp 50, đệ cấp 2.
- Mỗi phút (`PTBP_Player`), nếu bot Dị Nhân chưa có đệ thì gọi `AddNpcPet(bot, mẫu, cấp NPC, cấp đệ)` và đặt tên `"[Đệ tử] <tên bot>"`. Mỗi tick, phe hiện tại của đệ được đồng bộ theo bot (chiến trường Thương Chu: phe 1/2).
- `PTBP_DelBot` xóa đệ cùng bot (bot chết hoặc lạc, giảm số bot, tắt tổ đội, `PTBP_DismissAll`).
- Giới hạn toàn server `PTBP_PET_MAX_TOTAL = 60` đệ (lấy số của tick trước và tick đang chạy).
- Nếu engine chưa có `AddNpcPet` / `GetNpcPetIdx` (C++ cũ) thì không gọi đệ, chỉ sửa kỹ năng. Không báo lỗi.

**C++ (build, chưa triển khai):**

| File | Thay đổi |
|---|---|
| `PhongThanBotPet.h` (mới) | `AddNpcPet(owner, tpl, npclevel, petlevel)`: chủ phải là NPC sống, không phải người chơi. Đệ có AiMode 11; `m_nOwnerIdx` = bot; `Owner[]` = tên bot; `bot.m_nPetIdx` = đệ (mỗi bot 1 đệ, đệ cũ bị xóa). Phe, hệ và tốc độ lấy theo bot. Máu và sát thương gốc nhân `(100 + 50·(lv-1))%`, ô 4 = kỹ năng của mẫu ở cấp đệ, giống pet10. `GetNpcPetIdx(owner)` trả về đệ đang sống hoặc 0. |
| `ScriptFuns.cpp` | `#include "PhongThanBotPet.h"` sau `PhongThanPartyBot.h`; đăng ký `AddNpcPet`, `GetNpcPetIdx`. |
| `KNpc.cpp` (`CalcDamage`) | Trước đây chỉ 1 bước `nAttacker = owner`, nên đòn của đệ bị tính cho bot (một NPC): không ai nhận kinh nghiệm, phần kinh nghiệm của người chơi bị hụt đúng bằng sát thương của đệ, đồ rơi và LastDamage rơi vào bot. Giờ engine đi theo chuỗi chủ tối đa 3 bước (đệ → bot → người chơi). |
| `KNpcAI.cpp` (`ProcessAIType11`) | Xóa đệ khi slot của chủ đã trống (`m_dwID == 0`). Lý do: `KNpc::Init` để SubWorld 0 và máu 100, nên đệ ở subworld 0 cứ đi theo một slot rỗng. Với chủ là NPC, xóa đệ cả khi slot đó đã có NPC khác (so tên `Owner` với tên chủ). |

Các trường hợp xóa đệ, không để sót NPC:
- Bot chết, bị xóa, đổi map hoặc ẩn: AI 11 của đệ tự xóa đệ.
- Đệ chết: đoạn botparty:P3 trong `KNpc.cpp` xóa đệ và xóa `m_nPetIdx` của bot.
- Lua xóa bot: `PTBP_DelBot` xóa đệ trước.

Cách cũ là cho bot dùng kỹ năng gọi đệ 450–461 qua `NpcCastSkill`. Không dùng cách này vì: (1) cấp đệ lấy theo kỹ năng đang chọn của bot (luôn là 10); (2) gói SKILL_CAST `DirectEffect` gửi xuống client khiến client chạy cả nhánh `SKILL_SS_CreateNpc`; (3) Lua không lấy được chỉ số đệ để dọn.

### 2.4 Những gì cần triển khai

| Phần | Cần? | Ghi chú |
|---|---|---|
| Lua `party.lua` | Có | `scratchpad\botparty\out\party.lua` (đã sinh, khớp `scratchpad\dinhanbot\out\party.lua`), chép vào `Server\script\phongthan\bots\party.lua`. Lệnh chép đã bị hệ thống quyền từ chối, coordinator chép giúp. servertimer nạp lại ở tick sau. |
| ptfix | Không | Không đổi dữ liệu PAK. |
| C++ server | Có (cho đệ tử và kinh nghiệm của đệ) | `CoreServer.dll` (Modern\Win32ServerRelease, 16:22). |
| C++ client | Không | Mọi thay đổi nằm trong phần `_SERVER` hoặc chỉ chạy ở server. CoreClient và Game.exe được build lại cho chắc, hành vi không đổi. |

## Phần 3: Kiểm tra

- Build `Build-Modern.ps1 -Targets CoreServer,CoreClient,GameClient`: cả 3 OK (16:22). `CoreServer.dll` có chuỗi `AddNpcPet` / `GetNpcPetIdx`. Các bản vá cũ giữ nguyên (chỉ thay đúng 4 đoạn có nhãn `dinhanbot`).
- Mô phỏng `scratchpad\qtest\sim_dinhanbot.lua` (dựng từ `sim_botparty_orig.lua`, giả lập engine: AI 11 chủ là NPC, xóa đệ chết, `SetNpcSkill`, `AddNpcPet`, `GetNpcPetIdx`):
  - `-Stack 100`: pass 66 / fail 14. `-Args1 emu`: pass 66 / fail 14, không tràn stack, không có FLAG `ORPHAN_PET`.
  - 14 FAIL **trùng y hệt** bản gốc `out_botparty_orig.txt`. Đó là kỳ vọng cũ "thành không có bot", sai từ khi có partytown. Không phải lỗi mới.
  - 29 kiểm tra mới đều đạt: bảng đệ = PTTH_LIST; chọn mẫu và cấp theo cấp 3 / 50 / 64 / 200; bot Dị Nhân ô 4 = 44 cấp 10, ô 1 = 49, bot hệ khác không bị đổi; mỗi bot Dị Nhân có đúng 1 đệ (AI 11, chủ = bot, đúng tên, phe, map); không gọi đệ lại khi đệ còn sống; đệ chết thì có đệ mới; bot chết hoặc lạc thì bot và đệ cùng mất; DismissAll; đổi map; phe Thương Chu = 2; giới hạn server 1 rồi 60; engine cũ (không có `AddNpcPet`) chỉ sửa kỹ năng, không lỗi; người chơi cấp 3 được đệ 359 cấp 3.
- Không kiểm tra trực tiếp trong game: việc cài runtime bị từ chối quyền, và C++ chưa triển khai.

## Phần 4: Hành động và tham khảo

- [ ] Coordinator: chép `scratchpad\botparty\out\party.lua` vào `Server\script\phongthan\bots\party.lua` (bot Dị Nhân đánh ngay ở tick sau).
- [ ] Đợt triển khai C++ tiếp theo: `CoreServer.dll` (gồm dinhanbot cùng các bản vá đang chờ). Sau khi triển khai, bot Dị Nhân tự gọi đệ ở tick kế tiếp.
- [ ] Kiểm tra trong game: lập tổ đội bot có bot Dị Nhân, xem bot ra chiêu Thôi Thân Chú và quái mất máu; xem đệ "[Đệ tử] …" đi theo bot và đánh; quái do đệ hạ phải cộng kinh nghiệm cho người chơi.
- Backup: `_backup\20261004-dinhanbot\` (KNpc.cpp, KNpcAI.cpp, ScriptFuns.cpp, party.lua src/out/runtime, CHANGELOG, README).
- Script làm việc: `scratchpad\dinhanbot\` (`patch_cpp.py`, `make_sim.py`, `dump_*.py`, `pakread.py`).
- Liên quan: `to-doi-bot-phong-than-20261003.md`, `petfight-tokenmenu-phong-than-20261003.md`, `pet-exp-phong-than-20261003.md`, `skill-self-target-phong-than-20261004.md`.
