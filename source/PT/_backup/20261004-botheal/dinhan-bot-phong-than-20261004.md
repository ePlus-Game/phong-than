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

## Phần 5: Bot dùng chiêu 9x (bot9x, 2026-10-04)

Yêu cầu: "Bot tổ đội đánh chiêu 9x nhé". AI 11 chỉ dùng ô 4, nên ô 4 của mọi bot tổ đội được đặt thành chiêu cấp 90 của phái.

### 5.1 Chiêu 9x theo phái

Nguồn: `vng00.pak \settings\item\001\skillbook.txt` (sách "Sách kỹ năng <phái> cấp 90"), dữ liệu kỹ năng `settings\skills.txt` (ptfix), script cấp `script\skill\<phái>\*.lua` (serverlist.pak).

| Phái (mẫu bot) | Chiêu cấp 90 | Dạng khi NPC dùng | Ô 4 mới | Cấp đặt |
|---|---|---|---|---|
| Giáp Sĩ (2703–2708) | 42 Khuynh Thành Nhất Kích | IsPhysical, `physicsenhance_p = 40 + 4·lv`; AtFirer, missile 124 (Stand, DmgRange 10 ô) + start 147 (6 missile 133). Đánh lan mọi quái quanh bot, AttackRadius 120. | **42** (thay 41) | 10 → 20 |
| Đạo Sĩ (2709–2714) | 26 Tam Muội Chân Hỏa | `firedamage_v = 300+30·lv … 400+40·lv`; Wall đặt tại mục tiêu, missile 51 (DmgRange 15), TimePerCast 40 (bằng 18 cũ). | **26** (thay 18) | 10 → 20 |
| Dị Nhân (2715–2720) | 51 Vạn Cốt Toàn Khô | Chỉ có `fatallystrike_p`, AddBaseDamage 0, IsUseAR 0. `KNpc::CalcDamage` thoát khi min + max = 0, và `bIsFS` chỉ dùng cho sát thương phản đòn. Ngoài ra đây là dạng Line + missile Stand sinh tại người tung (bản vá skillself không áp vì TargetOnly 0). **Không gây sát thương.** | giữ **44** Thôi Thân Chú | 10 → 20 |

- Ngũ hành không tách chiêu: trong Phong Thần, `GetSeries()` của người chơi là phái (0 Giáp Sĩ, 1 Đạo Sĩ, 2 Dị Nhân; xem các script tân thủ). Series trong `Npcs.txt` của bot chỉ là ngũ hành NPC, và không kỹ năng nào có cột Series. Vì vậy mỗi phái có đúng 1 chiêu cấp 90, không phụ thuộc Series của mẫu bot.
- Bốn chiêu "Ma pháp tối cao" của Đạo Sĩ là 23 Lôi Động Cửu Thiên (cấp 78), 24 Huyền Nữ Bổ Thiên (82), 25 Băng Phong Vạn Lý (86) và 26 Tam Muội Chân Hỏa (90). Chỉ 26 là chiêu cấp 90. 23 có TimePerCast 125: bot chỉ có ô 4 nên sẽ đứng yên khoảng 6 giây giữa hai lần ra chiêu.
- Không chiêu nào được chọn là dạng Line + Stand nổ tại người tung. 42 là AtFirer theo thiết kế: vùng sát thương 10 ô quanh bot, rộng hơn tầm đánh 120.
- Dị Nhân không có chiêu 9x đánh được: 458 Phong Quyển Tàn Vân (cấp 85) là chiêu gọi đệ, phần này đã có đệ tử bot lo.

### 5.2 Cấp kỹ năng

- Bot cấp dưới 90: cấp 10, bằng cấp mẫu và MaxLevel 10.
- Từ cấp 90: cứ 3 cấp nhân vật thêm 1, tối đa 20 (bot cấp 120). Engine nạp được mọi cấp < 64 từ script cấp: `KSkillManager::InstanceSkill` quét lại bảng một lần rồi cache.
- Cấp bot lấy bằng `GetNpcLevel(bot)`; nếu engine không có hàm này thì lấy cấp người chơi.

### 5.3 Lua (`party.lua`, nguồn `scratchpad\botparty\src\party.lua`)

- Thêm bảng `PTBP_SK` (mẫu → chiêu), `PTBP_SkLevel(lv)` và `PTBP_SkTick(bot, lv)`. `PTBP_Player` gọi `PTBP_SkTick` cho mọi bot ngay trong tick sinh bot, trước `PTBP_DnTick`.
- `SetNpcSkill(bot, chiêu, cấp, 4)` chỉ ghi ô 4; ô 1–3 giữ chiêu của mẫu. Riêng Dị Nhân vẫn đặt ô 1 = 49 như dinhanbot.
- Chỉ đặt một lần: NpcParam 3 = 2. Bot do bản dinhanbot sinh ra (NpcParam 3 = 1) được nâng ở tick kế tiếp, nên bot đang sống cũng đổi chiêu sau khi nạp nóng.
- `PTBP_DnTick` không còn tự đổi kỹ năng, chỉ lo đệ tử. Toàn bộ phần đệ tử (dinhanbot) và map, phe (vtcc) giữ nguyên.
- Không cần C++ mới: `SetNpcSkill` và `GetNpcLevel` đã có trong engine hiện tại.

### 5.4 Kiểm tra

- `scratchpad\qtest\sim_bot9x.lua` (sinh từ `sim_dinhanbot.lua` bằng `scratchpad\bot9x\make_sim.py`, thêm mục 15): pass 82 / fail 14 ở cả `-Stack 100` lẫn emu. 14 FAIL trùng y hệt `out_dinhanbot.txt` (kỳ vọng cũ "thành không có bot"). Không có ERR hay FLAG. Headroom tick 37 khung, bằng bản dinhanbot.
- 16 kiểm tra mới đều đạt: công thức cấp; 18/18 mẫu nhận đúng chiêu; quái và mẫu 2721 không bị đụng; 7 bot đủ 3 phái có ô 4 = 42/26/44, cấp 10, cờ 2; ô 1–3 không đổi; đệ Dị Nhân vẫn có; tick ổn định không gọi lại `SetNpcSkill`; người chơi cấp 110 → chiêu cấp 16/17 theo cấp bot; bot cũ (cờ 0/1) được nâng; không có `GetNpcLevel` thì lấy cấp người chơi (120 → 20); không có `SetNpcSkill` thì bot vẫn ra, không lỗi; đổi map thì bot mới có chiêu ngay trong tick sinh.
- `sim_vtcc_bp.lua` (thường và emu): FAILS=0, kết quả giống hệt trước khi sửa.

### 5.5 Triển khai

- [ ] Coordinator: chép `scratchpad\botparty\out\party.lua` (22073 byte, gồm cả dinhanbot và vtcc) vào `Server\script\phongthan\bots\party.lua`. Bản `scratchpad\dinhanbot\out\party.lua` đã cũ, đừng dùng. servertimer nạp lại ở tick sau, bot đang sống đổi chiêu trong 1 phút.
- Không cần ptfix, không cần C++, không cần khởi động lại.
- Kiểm tra trong game: bot Giáp Sĩ ra Khuynh Thành Nhất Kích (đánh lan quanh bot), bot Đạo Sĩ ra Tam Muội Chân Hỏa, bot Dị Nhân vẫn ra Thôi Thân Chú và quái mất máu.
- Backup: `_backup\20261004-bot9x\` (src/out party.lua, sim_dinhanbot.lua, CHANGELOG, tài liệu này).

### 5.6 Vòng 2: Đạo Sĩ đánh luân phiên 3 chiêu, đệ Dị Nhân là Phong Quyển Tàn Vân

Bảng chiêu mới (cấp chiêu vẫn theo công thức 5.2):

| Phái | Ô 1 | Ô 2 | Ô 3 | Ô 4 |
|---|---|---|---|---|
| Giáp Sĩ 2703–2708 | 42 | 42 | 42 | 42 Khuynh Thành Nhất Kích |
| Đạo Sĩ 2709–2714 | 26 | 23 Lôi Động Cửu Thiên | 25 Băng Phong Vạn Lý | 26 Tam Muội Chân Hỏa |
| Dị Nhân 2715–2720 | 44 | 44 | 44 | 44 Thôi Thân Chú (bỏ 49) |

- 23 Lôi Động Cửu Thiên: AtTarget, 8 missile 18 (Stand tại vùng mục tiêu, DmgRange 4), `lightingdamage_v = 1 … 200+20·lv`, TimePerCast 125.
- 25 Băng Phong Vạn Lý ("Băng Hồng Vạn Lý"): AtTarget, missile 1 rồi vòng 117 (32 missile), `colddamage_v = 120+15·lv … 200+25·lv`, TimePerCast 20.
- Cả hai gây sát thương thật, AddBaseDamage 1. Không chiêu nào là dạng Line + Stand.

**C++ (`KNpcAI.cpp`, marker `bot9x`, build CoreServer 17:16, chưa triển khai):**
- `ProcessAIType11` không còn gọi `SetActiveSkill(4)` cố định. Thay vào đó gọi `PhongThanAi11PickSkill`, hàm này lấy các ô 1–4 thỏa đủ ba điều kiện:
  - id và cấp > 0;
  - chiêu thuộc style Missles, Melee hoặc PhongThanAttack;
  - đã hết TimePerCast (`KSkillList::CanCast`, đúng phép thử của `KNpc::DoSkill`).
- Trong các ô đó chọn ngẫu nhiên một ô. Nhờ vậy chiêu đang hồi (ví dụ 23) bị bỏ qua, bot không đứng yên.
- Không ô nào sẵn sàng thì dùng ô 4, như cũ.
- NPC chỉ có ô 4 và đệ triệu hồi (cùng một id ở cả 4 ô) có hành vi không đổi.
- Engine cũ (chưa có bản này): bot chỉ dùng ô 4, tức Đạo Sĩ ra 26, Giáp Sĩ ra 42, Dị Nhân ra 44.

**Đệ của bot Dị Nhân:**
- Luôn là Phong Quyển Tàn Vân: kỹ năng 458 → mẫu 407 (bảng summon `vng00.pak`, PTTH_LIST hàng 9, cấp học 85).
- Cấp đệ theo pet10: `(cấp người chơi − 85) / 5 + 1`, giới hạn 1–10. Cấp NPC = `85 + 5·(cấp đệ − 1)`, không vượt cấp người chơi.
- Cả 4 ô đặt chiêu 145 (tên VNG "arrow thổ 3": mũi tên vật lý bắn tỏa, `physicsenhance_p`) ở cấp đệ.
- Lý do đặt cả 4 ô: `AddNpcPet` chỉ nâng ô 4, mà engine ra chiêu theo cấp của ô đầu tiên có cùng id (`KSkillList::FindSame`), nên đệ thực tế chỉ đánh cấp 1.
- Đệ mẫu khác do bản dinhanbot sinh ra bị xóa và gọi lại ở tick sau.

**Kiểm tra:**
- `sim_bot9x.lua` (round 2): 86 pass / 14 fail ở cả `-Stack 100` lẫn emu. 14 fail trùng y hệt bản gốc. Headroom tick 37 khung, không có FLAG.
- Các kiểm tra mới đều đạt:
  - 18/18 mẫu nhận đủ 4 ô;
  - 7 bot đủ 3 phái, cờ 3;
  - đệ là 407 với chiêu 145 ở cấp đệ (người chơi cấp 110 thì đệ cấp 6);
  - đệ mẫu cũ bị thay, không sót NPC;
  - bot cờ 0/1/2 được nâng;
  - không có `GetNpcLevel` hoặc `SetNpcSkill` thì không lỗi.
- `sim_vtcc_bp` FAILS=0, giống hệt trước.
- Bộ chọn chiêu C++ không chạy được trong mô phỏng Lua; mới kiểm bằng build và đọc code.

**Triển khai:** chép `scratchpad\botparty\out\party.lua` vào runtime; `CoreServer.dll` (Modern\Win32ServerRelease) trong đợt C++ tới. Không cần ptfix, client không đổi.
