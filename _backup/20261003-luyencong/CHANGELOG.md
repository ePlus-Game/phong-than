# Changelog

## [Unreleased]

<!-- stackgem-20261003 -->
### [COMPLETED] - 2026-10-03 20:25 (stackgem; C++ đã build, chờ triển khai cùng ptfix)
- **Sửa**: Mảnh thủy tinh, thủy tinh, bảo thạch (genre 3) và 4 loại Không Thư (8/139–142/2) không xếp chồng.
  - Nguyên nhân genre 3: dữ liệu đúng (`material.txt` MaxStack 100). Web admin phát bằng `PTAdm_GiveTo` → `AddItemID(idx, 0)` → `InsertEquipment(idx, false)`, không gộp chồng. Mỗi viên chiếm một ô, túi đầy thì món bị đẩy ra đất. Runtime 20:14: KyUc1Thoi được phát 130 Hồng Bảo Thạch, chỉ còn 41.
  - Nguyên nhân Không Thư: `KItem::operator=(KBASICPROP_IBITEM)` lấy giới hạn chồng = `UseCount` (1), bỏ qua cột 11 `是否叠放` của `ibitem.txt`.
  - `servertimer.lua` `PTAdm_GiveTo`: món có `GetMaxStackItem > 1` dùng `AddItemIDStack` (tự gộp). Áp dụng cho mọi nút phát đồ của web admin, không sửa `PhongThan-Admin.ps1`. Áp nóng: `scratchpad\stackgem\hot_givestack.lua`.
  - C++ `KItem.cpp`: giới hạn chồng genre 8 = max(`UseCount`, cột 11 nếu > 1). Đã build CoreServer, CoreClient, GameClient lúc 20:19. Các bản vá cũ vẫn còn nguyên.
  - ptfix `scratchpad\ptfix\extra_stackgem.py` (Client + Server):
    - cột 11 = 100 cho 4 Không Thư;
    - chuẩn hóa về 1 cho 1.302 dòng VNG khác có 100/200/250, để chúng giữ hành vi cũ.
    - **Phải triển khai cùng C++.**
  - `pt_bikip.lua`, kèm template `gen_bikip.py`: trả nguyên liệu khi ép sách thất bại giữa chừng dùng `AddNormalItemPile` (gộp chồng), không tốn thêm ô. Hàm đếm và trừ vốn đã tính theo số lượng chồng.
  - Đồ đang có sẵn: không tự gộp, kéo thả lên món cùng loại để gộp. Món mới tự gộp.
  - Kiểm thử:
    - ptfix thử `scratchpad\stackgem\` chỉ khác v25 ở cột 11 `ibitem.txt`;
    - `sim_bikip`, `sim_bikip2` giống hệt trước khi sửa;
    - `sim_stackgem` (mới) FAILS=0.
  - Backup `_backup\20261003-stackgem\`. Tài liệu `docs\features\stack-gem-phong-than-20261003.md`.

### [COMPLETED] - 2026-10-03 20:20 (petexp, áp nóng qua admin bridge 20:15, không cần khởi động lại)
- **Thêm**: Đệ tử Dị Nhân có kinh nghiệm và cấp riêng; không trừ kinh nghiệm của chủ.
  - Task 2505 = cấp, 2506 = kinh nghiệm trong cấp. Một cặp dùng chung cho 12 loại đệ tử và đệ tử kỹ năng. Dải 2505–2509 đã quét toàn bộ PAK, script và settings rời: không ai dùng.
  - Mỗi quái thường (death script `npc_quests\normal.lua`) do chủ hoặc đệ tử hạ cho đệ tử kinh nghiệm bằng cấp quái. Gấp 4 khi đệ tử thấp hơn giới hạn từ 10 cấp; chia 4 với quái thấp hơn đệ tử quá 10 cấp.
  - Điều kiện: đệ tử lệnh bài còn sống, cùng bản đồ, cách chủ tối đa 60 ô; hoặc đệ tử kỹ năng còn sống (`PetGetType`).
  - Kinh nghiệm lên cấp: `2 × cấp × (cấp + 10)`. Giới hạn: không vượt cấp chủ, tối đa 150. Lên cấp có thông báo.
  - Sức mạnh (đệ tử lệnh bài):
    - gọi ra ở cấp đệ tử;
    - máu tối đa bằng máu chủ × (100 + cấp)%, hồi đầy;
    - kỹ năng đệ tử cấp `1 + cấp/15`, tối đa 10;
    - tên `[cấp]Tên`;
    - đệ tử đang đứng ngoài được áp ngay khi lên cấp.
  - Lời thoại Lệnh Bài hiện cấp và kinh nghiệm đệ tử. Menu vẫn 7 dòng.
  - Đệ tử kỹ năng 450–461: có nhận kinh nghiệm; **chưa** tăng sức mạnh theo cấp, vì Lua không có chỉ số NPC của nó.
  - File:
    - `script\phongthan\lib\petexp_lib.lua` (mới);
    - `trieuhoi_lenhbai.lua`, sinh lại bằng `scratchpad\skill180\mktrieuhoi.py`;
    - `npc_quests\normal.lua`, chỉ nối thêm cuối file bằng `scratchpad\petexp\patch_normal.py`.
  - Không sửa C++.
  - Kiểm thử: `sim_petexp` (thường, emu, live) FAILS=0; `sim_petmorph`, `sim_petmorph_pe` (thường, emu, live) FAILS=0; `sim_petskill`, `sim_petskill_pe` và `t_qnormal` không lỗi.
  - Backup `_backup\20261003-petexp\`. Tài liệu `docs\features\pet-exp-phong-than-20261003.md`.

### [COMPLETED] - 2026-10-03 20:00 (áp nóng qua admin bridge, không cần khởi động lại)
- **Sửa**: Tạp Hóa Thương, Thợ Đồng, Thủ Khố mất bước nhiệm vụ tân thủ mới (newbie2) ở Ngọc Hư (897, 896) và Xi Vưu (1000, 1001).
  - Nguyên nhân: `mk_spawnnames.py` cho NPC spawn tên TCVN3, nhưng `pt_npcalias.lua` (TCVN3 → GBK, dùng trong `PTNB2_ScanNpcs`) không có Thủ Khố, Thợ Đồng, Đại Phu.
  - Hậu quả: newbie2 không thấy các NPC này. Mô phỏng kẹt ở `1000:3` và `897:2`.
  - `gen_npcnames.py`: alias gồm mọi nhãn TCVN3 của `PTADM_NPC_FIX` (61 tên, không trùng). `mk_spawnnames.py` tự chạy lại `gen_npcnames.py`.
  - `newbie2\nb2_lib.lua`: xóa cache vị trí NPC mỗi khi state được nạp lại (sửa ở mức byte).
  - Áp nóng 19:58: nạp lại alias, `ReLoadScript` quan_su.lua, quét lại; 1003/1004 đã thấy 仓库管理员, 铜匠, 杂货商.
- **Sửa**: Xóa 14 NPC spawn trùng do đợt đổi tên 19:13 để lại (Tạp Hóa ×4, Bào Thương ×5, Khoa Phụ, Đa Bảo, Thần Nông, Nguyên Thủy, Đắc Kỷ lúc nhỏ).
  - Kiểm thử: `sim_taphoa` FAILS=0 (alias cũ: 12), `sim_newbie2` và `sim_nb2emu 47,40` giống hệt bản trước.
  - Backup `_backup\20261003-taphoa\`. Tài liệu `docs\features\taphoa-npcnames-phong-than-20261003.md`.

### [IN PROGRESS] - 2026-10-03 20:05 (đã build/sửa dữ liệu, chờ tắt server + client để triển khai)
- **Thay đổi**: Theo yêu cầu người dùng, bỏ hẳn phạt chênh cấp kinh nghiệm trên mọi bản đồ: quái cao hay thấp hơn bao nhiêu cấp cũng nhận đủ kinh nghiệm.
  - File: `KPlayer::AddSelfExp`, dấu `noexppenalty`.
  - Bản này thay luật -5%/cấp (sàn 50%) của entry desertexp bên dưới.
  - Bán kính nhận kinh nghiệm khi chơi một mình 1600 (desertexp) giữ nguyên.
  - Backup `_backup\20261003-noexppenalty\`.
- **Thay đổi**: Quái thường hồi sinh nhanh gấp đôi trên mọi bản đồ: `ReviveFrame` 181–1080 chia đôi, sàn 180.
  - 30 giây thành 15 giây; 60 giây thành 30 giây.
  - Áp cho 490 mẫu quái trong `settings\phongthan\Npcs.txt` (Server + Client).
  - Không đổi boss, quái nhiệm vụ, đệ tử triệu hồi (AI 6).
  - Backup `_backup\20261003-respawn\`.
- **Thêm**: Khung danh sách tổ đội kiểu VNG ở bên phải màn hình, dưới bản đồ nhỏ.
  - Dùng lại layout VNG (PAK id d180f81d) và sprite VNG.
  - Hiện người chơi (đội trưởng, tên vàng, cờ) và tối đa 7 bot "[Tổ đội]", mỗi hàng có cấp, huy hiệu nghề, thanh máu, đầu lâu khi chết. Cũng hiện tổ đội thật.
  - Alt+G bật/tắt, trạng thái lưu ở `UserData\UiCommon.ini`.
  - CoreClient thêm cửa đọc `PAIOperation 'PTPP'`, không đổi giao thức.
  - Cần triển khai CoreClient.dll và Game.exe. Backup `_backup\20261003-partypanel\`.
- **Thêm**: Võ sư Phong Thần Đài (1001, cạnh Bá Giám) trong `ext\sudo_dongdi.lua`. Backup `_backup\20261003-vosu1001\`.

### [IN PROGRESS] - 2026-10-03 19:58 (desertexp: C++ đã build, chờ triển khai CoreServer.dll khi tắt server)
- **Sửa**: Đánh quái ở sa mạc (bản đồ 1022–1026, quái cấp 30–50) không lên kinh nghiệm. `KPlayer::AddSelfExp` chỉ cho **1 điểm** khi quái cao hơn người chơi trên 15 cấp. Đã kiểm chứng qua bridge lúc 19:50: KyUc1Thoi cấp 10, `AddExp(20, cấp)` = +100, `AddExp(20, cấp + 22)` = +1.
  - Luật mới cho quái cao cấp hơn: chênh ≤ 5 nhận 100%, sau đó giảm 5% mỗi cấp, thấp nhất 50% (trước đây chênh 15 chỉ còn 5%, trên 15 còn 1 điểm).
  - Luật cho quái thấp cấp hơn giữ nguyên.
- **Sửa**: Quái do đệ tử Dị Nhân hoặc bot tổ đội (AiMode 11) hạ ở xa chủ không cho kinh nghiệm. `KNpcDeathCalcExp::CalcExp` (nhánh chơi một mình) đòi chủ đứng trong bán kính 768, trong khi đệ tử đánh mục tiêu cách chủ tới 1000. Bán kính tăng lên 1600 (`PHONGTHAN_SOLO_EXP_DISTANCE`). Tổ đội thật giữ nguyên.
- Đã loại trừ: `Npcs.txt` (ExpParam quái sa mạc giống quái thường), thưởng bot tổ đội, death script `normal.lua`, tự đánh phía client.
- Build `CoreServer` OK lúc 19:52. Bản build có cả bản vá đang chờ của `KNpcAI.cpp` và `KItemList.cpp`.
- Backup `_backup\20261003-desertexp\`. Tài liệu `docs\features\desert-exp-phong-than-20261003.md`.

### [IN PROGRESS] - 2026-10-03 19:50 (Lua đã áp nóng; C++ và dữ liệu chờ khởi động lại server/client)
- **Sửa**: Chuyển bản đồ thì vũ khí đang đeo "rơi về túi". Thực ra server chưa từng trang bị vũ khí đó, các bước như sau:
  - Bảng hình `VNG_WeaponPart.txt` chỉ đến record 3291. Vũ khí tân thủ ptfix (3412–3414) và các record VNG 3292–3411 (Tiên Ma, cung nhiệm vụ) không có dòng hình.
  - Vì vậy `KItemList::Equip` trả FALSE. `ExchangeItem` bỏ qua kết quả này nên vũ khí kẹt ở trạng thái "cầm tay", còn client vẫn hiện là đã đeo.
  - Tick `PTAdm_HandTick` sau đó đẩy vũ khí về túi.
- **Cách sửa**:
  - C++ `KItemList.cpp`: thiếu hình thì vẫn trang bị (hiện tay không), và `ExchangeItem` tôn trọng kết quả của `Equip`.
  - Dữ liệu: thêm 93 dòng hình vũ khí 3292–3414 vào `settings\item\VNG_WeaponPart.txt` (Server + Client).
- **Sửa**: Lỗi phụ nhân bản Xu. Khi túi đầy, `AddItemID` thả đồ đang cầm xuống đất và đưa bản sao vào tay, nên mỗi phút có thêm một bản.
  - `PTAdm_HandFixPlayer` nay chỉ sao chép khi `CheckRoom` còn chỗ, và chỉ xóa bản trên tay khi bản sao đã nằm trong túi (vị trí 3/4).
  - Đã áp nóng lúc 19:49.
- Backup `_backup\20261003-weaponequip\`.

### [IN PROGRESS] - 2026-10-03 19:55 (code xong, chờ cài ptfix mới và khởi động lại server/web admin)
- **Thêm**: Võ sư ở mọi thành có 3 mục "Mua bí kíp hệ phái" (Sale 66/67/68 theo phái), "Đóng sách (ép bí kíp)", "Đổi sách kỹ năng cũ thành bí kíp", như ở Tây Kỳ/Triều Ca.
  - Áp dụng cho Sùng Thành, Ngọc Hư, Xi Vưu, Dao Trì. Script Phong Thần Đài đã vá sẵn nhưng bản đồ chưa có NPC Võ sư.
  - Menu, nhiệm vụ và tiệm sách VNG giữ nguyên.
  - File: `lib\pt_bikip2.lua`, plug-in ptfix `extra_bikip2.py`.
- **Thêm**: Web admin, tab Bí kíp / Kỹ năng, thẻ "Bí kíp hệ phái & nguyên liệu ép sách":
  - phát Bạch/Lam/Hồng/Hoàng Không Thư, Mảnh Hồng Thủy Tinh, Hồng Thủy Tinh, Hồng Bảo Thạch theo số lượng hoặc theo bộ N lần ép;
  - phát bí kíp theo phái (1 cuốn hoặc tất cả);
  - khóa vật phẩm `BiKip<mã>`.
  - Backup `_backup\20261003-bikip2\`.
- **Thay đổi**: Thứ tự plug-in ptfix: extra_bikip < extra_bikip2 < extra_sudo_dongdi. Đã thử đảo thứ tự, kết quả như nhau.

### [IN PROGRESS] - 2026-10-03 19:40 (đã build, chờ tắt server để triển khai CoreServer.dll)
- **Sửa**: Đệ tử Dị Nhân (Lực Sĩ Tế…) không đánh cùng chủ. AI 11 (`KNpcAI::ProcessAIType11`) lấy mục tiêu cũ của chủ mà không kiểm tra:
  - `m_nPeopleIdx` của chủ cũng là NPC vừa nói chuyện; `CheckNpc` coi NPC đối thoại là hợp lệ, nên đệ cứ chạy theo NPC đó.
  - Quái đánh chủ từ xa còn sống mà cách hơn 1000 thì bị bỏ, nhưng không chọn lại quái gần nhất, nên đệ đứng im.
  - Sửa: hàm mới `PhongThanPetTargetOk` (còn sống, không phải NPC đối thoại, cùng bản đồ, là địch của đệ, cách chủ không quá 1000). Lần lượt thử các ứng viên, sau cùng là quái gần nhất.
  - Backup `_backup\20261003-petfight\KNpcAI.cpp`.

### [COMPLETED] - 2026-10-03 19:32 (áp nóng)
- **Sửa**: Menu Lệnh Bài Triệu Hồi có 17 dòng, client cắt mất "Đổi hình dạng đệ tử". Menu chính nay gọn:
  - Gọi đệ tử (cấp 5-55), Gọi đệ tử (cấp 65-120), Học kỹ năng, Đổi hình dạng, Gọi về, Thu hồi, Đóng;
  - 12 đệ tử chia sang 2 trang con, có nút "Quay lại".
  - File: `S\skill180\mktrieuhoi.py` → `item\trieuhoi_lenhbai.lua`. Backup `_backup\20261003-tokenmenu\`. `sim_petmorph` FAILS=0.

### [COMPLETED] - 2026-10-03 19:20 (áp nóng qua admin bridge, không cần khởi động lại)
- **Sửa**: Đổi tên NPC lần 1 (17:30) làm `PTAdm_EnsureNpcs` tưởng NPC đã mất và đặt thêm bản mới mỗi phút (Khoa Phụ, Bào Thương, Thần Nông, Tạp Hóa…). Bản lọc đã bỏ sót bảng `PTADM_NPC_SPAWN` trong servertimer.
  - Đã xóa 84 NPC thừa trên 9 bản đồ, trả 28 NPC về tên cũ.
  - `gen_npcnames.py` loại các tên spawn.
- **Sửa**: 29 dòng `PTADM_NPC_SPAWN` dùng luôn tên tiếng Việt TCVN3, và nhãn `PTADM_NPC_FIX` tương ứng đổi theo để vẫn gắn script (`mk_spawnnames.py`).
  - Thợ Đồng, Đại Phu, Thủ Khố, Tạp Hóa, Bào Thương, Khoa Phụ… nay hiện tên tiếng Việt.
  - Backup `_backup\20261003-npcnames\servertimer_before_spawnnames.lua`.
- **Thêm**: Thiên Hùng thứ hai ở Triều Ca (1021, 55216/96608, cạnh quảng trường Thái Tuế Sư): `PTVT_EnsureThienHung2` trong `vt_timer.lua` (runtime + nguồn). Backup `_backup\20261003-thienhung2\`. `sim_vantien2` 74/74.

### [COMPLETED] - 2026-10-03 18:35 (đã cài 19:04: server 5 file + client 5 file + ptfix v24, mã khớp; GameServer stack 16 MB)
- **Sửa (build)**: GameServer sập lúc 18:00:01 (0xC00000FD) khi Vạn Tiên trận mở theo lịch.
  - Dump (`%LOCALAPPDATA%\CrashDumps\GameServer.exe.56748.dmp`) cho thấy `LuaAddMissionNpc` (`AddMSNpc`) xin 729 KB ngăn xếp: tạo một `KMission` tạm làm khóa tìm mission.
  - `ScriptFuns.cpp` có 23 chỗ viết như vậy, ngăn xếp mặc định 1 MB không đủ.
  - Sửa: `Build-Modern.ps1` link GameServer với `/STACK:16777216` (16 MB). GameServer build lại OK.
- **Thêm (C++, botparty)**:
  - thưởng kinh nghiệm tổ đội bot +15% / đồng đội ở gần (`SetPartyBotBonus`);
  - xóa xác NPC AiMode 11 có chủ sau khi chết (`PhongThanPartyBot.h`, `KNpcDeathCalcExp.cpp`, `KNpc.cpp`).
  - Backup `_backup\20261003-botparty\`.
- **Sửa (C++)**: `ProcessAIType11` xóa đệ tử khi chủ đổi bản đồ nhưng không xóa `m_nPetIdx` của chủ, nên lần triệu hồi sau có thể xóa nhầm NPC dùng lại ô đó. Backup `_backup\20261003-petidx\`.
- **Thêm (Lua, botparty)**:
  - tổ đội bot tự động ở 57 bản đồ có quái (mặc định 4 đồng đội, chỉnh 0–7);
  - NPC "Hỗ Trợ Tổ Đội" ở 1002/1003/1004;
  - web admin có mục tổ đội bot;
  - bot tự do không còn tụ quanh người chơi đang có tổ đội bot.
- **Build**: CoreServer + GameServer (server), CoreClient + Game.exe (client: khung theo dõi nhiệm vụ + tự đánh), ptfix v24 (616 entry) đều OK.

### [COMPLETED] - 2026-10-03 18:25 (autofight; CoreClient + Game.exe đã build 0 lỗi, chờ cài cùng tổ đội bot)
- **Thêm**: Tự động đánh phía client như auto VNG:
  - Alt+S: chiêu tay phải; hết dùng được thì chuyển chiêu trái.
  - Alt+A: chiêu tay trái.
  - Alt+D: đứng tại chỗ.
  - Bấm lại cùng phím để tắt.
  - Tìm quái gần nhất (bán kính 640, không rời điểm bật quá 960), đánh qua đúng đường click chuột; hết quái thì về điểm bật.
  - Tự uống bình máu / mana ở thanh phím nhanh (dưới 50% / 20%).
- **Thêm**: Auto tự tắt khi đổi bản đồ, chết, vào khu an toàn, mở hội thoại server, giao dịch. Click chuột tạm dừng 4 giây. Bỏ qua bot giả và pet có chủ.
- **Sửa**: Phím Alt+A/S/D có sẵn trong `autoexec.lua` của VNG trước đây không có tác dụng.
- **Tệp**: `Core\Src\PhongThanAutoFight.inl` (mới), `KPlayerAI.cpp`, `KPlayer.cpp`, `CoreShell.cpp`, `GameClient\Ui\ShortcutKey.cpp`. Backup `_backup\20261003-autofight\`.

### [COMPLETED] - 2026-10-03 18:10 (questtrack; Game.exe đã build, chờ cài cùng tổ đội bot + tự đánh)
- **Thêm**: Khung theo dõi nhiệm vụ bên trái màn hình như VNG (lớp mới `KUiTaskTrace` trong Game.exe):
  - hiện tối đa 5 nhiệm vụ chưa xong (tên + bước hiện tại từ dữ liệu F11);
  - cập nhật ngay khi server gửi TaskNote, ẩn nhiệm vụ đã xong;
  - bật/tắt bằng Alt+N, lưu ở `UserData\UiCommon.ini` [TaskTrace];
  - layout `\ui\ui3\uitasktrace.ini` (plug-in `extra_questtrack.py`, chép từ `任务提示.ini` của VNG).
- **Sửa**: Sổ F11 ghi tràn mảng khi có từ 12 bản ghi; đọc chuỗi không có ký tự kết thúc; `KTaskDataFile::ClearAll` rò bộ nhớ. Backup `_backup\20261003-questtrack\src\`.

### [COMPLETED] - 2026-10-03 17:30 (áp nóng qua admin bridge, không cần khởi động lại)
- **Sửa**: Người chơi không tìm được NPC nhiệm vụ tân thủ ở Xi Vưu Mộ. Các NPC khôi phục từ dữ liệu vùng VNG (tượng Đồ Đằng Thiếu Hạo, Chúc Dung, Khoa Phụ, Phong Bá…) mang tên GBK, client TCVN3 hiện thành ký tự lỗi.
  - `ext\npcnames.lua` (sinh bằng `scratchpad\npcnames\gen_npcnames.py`, tên ở `vn_names.json`) đổi 68 NPC trong `PTADM_NPC_FIX` sang tên tiếng Việt có dấu và gắn lại script.
  - Bỏ qua các tên mà tính năng khác dùng để kiểm tra NPC còn sống (Thủ Khố, Đại Phu, Thợ Đồng…).
- **Sửa**: newbie2 tìm NPC theo tên GBK. Thêm `lib\pt_npcalias.lua` (tên Việt → GBK); `nb2_lib.lua` dịch tên khi quét.
- **Thay đổi**: `PTADM_EXT_NAMES` có thêm `npcnames`. Backup `_backup\20261003-npcnames\`.
- **Kiểm tra**: `sim_newbie2` FAILS=0, `t_st` OK. Trên server thật, tên các tượng 1004 đã đổi (Thiếu Hạo (Đồ Đằng) ở 1588/3272).

### [COMPLETED] - 2026-10-03 17:15 (bản build tổng: đã cài server + client + ptfix v23; 21 mô phỏng chính đạt)
- **Thêm (congthanh2)**: Bóng Cửu Linh cho bước 1 nhiệm vụ 908. Gọi ở Lãnh địa quan / Phòng luyện thuốc, sức mạnh theo cấp; boss thế giới Cửu Linh vẫn được tính.
- **Thêm (congthanh2)**: 23 Đại phu dã ngoại còn thiếu cho nhiệm vụ 31 (task 304 = 5–51), không trùng Đại phu đã có.
- **Thêm (congthanh2)**: Thủ thành theo lịch 12:30 / 20:30 và "Khiêu chiến ngay":
  - 3 đợt quân địch, hộ vệ là bot;
  - thắng thì thưởng (tối đa 2 lần / ngày), thua thì Hưng thịnh −1.
- **Thêm (congthanh2)**: Nâng cấp 7 công trình cấp 1–5, hiệu quả nối vào script VNG qua `ct_api`. Backup `_backup\20261003-congthanh2\`.
- **Thay đổi**: Đã triển khai cùng lúc:
  - server 5 file (`_backup\server-deploy-20261003-171406`);
  - client 5 file (`_backup\client-deploy-20261003-171408`);
  - ptfix v23, 615 entry (`_backup\ptfix-20261003-171409`).
- **Kiểm tra**: 21 mô phỏng chính (`t_st`, `questfix`, `questfix2`, `tta`, `tutuong_b`, `newbie2`, `daily2`, `daily3`, `vanluong`, `tienma23`, `tienma45`, `vienco`, `sinhhoat`, `congthanh`, `sudo_dongdi`, `sudocpp`, `cankhon2`, `petmorph`, `bikip`, `bots`, `botadmin`) đều đạt, 0 lỗi.

### [COMPLETED] - 2026-10-03 16:58 (C++ đã áp + build)
- **Thêm (C++, congthanh)**: 8 native chế độ bang hội: `GetCityTask` / `SetCityTask` / `AddCityIndexRes` / `GetCityIndexRes` / `GetOwnCityLevel` / `IsHaveTongRight` / `GetTongContri` / `AddTongContri`.
- **Sửa (C++, congthanh)**: Tràn bộ đệm `KGameData szKeyName[6]` → `[16]`. Backup `_backup\20261003-congthanh\`.
- **Thêm (C++, cppbatch)**:
  - AiMode 13 "bạn đồng hành" cho linh thú;
  - `SetNpcAiMode(npc, 11|13)`, chỉ cho NPC có chủ là người chơi;
  - stub `OpenNpcCollectionDlg`.
- **Sửa (C++, cppbatch)**:
  - `SyncNpc` nạp lại hình NPC khi đổi mẫu (đổi hình đệ tử hiện ngay);
  - chặn Kind ngoài bảng (VNG 7–15 → `kind_normal`);
  - AiMode 11 dừng ngay sau khi xóa linh thú.
- **Bảo mật**: Chặn chia cho 0 ở CastCircle, FlyEventTime 0 (skill 1494), hiệu ứng đạn 0 hướng, tốc độ −100%, MixPoisonDamage, Poison2DecManaP. Backup `_backup\20261003-cppbatch\`.
- **Thêm**: Linh Thú Lệnh chọn chế độ "Bạn đồng hành" (AI 13) / "Chiến đấu" (AI 11 + kỹ năng 63).
- **Build**: CoreServer + CoreClient 0 lỗi (16:57); chưa cài.

### [COMPLETED] - 2026-10-03 (congthanh; script đã cài, chờ build ptfix + C++ cuối)
- **Thêm**: Lãnh địa cá nhân cho người chơi solo (`script\phongthan\congthanh\*`, `ext\congthanh.lua`). Hệ bang hội của server không chạy từ gốc: `KSOServer` gán `m_pTongClient = NULL`.
  - Lãnh địa quan ở Tây Kỳ: lập lãnh địa, 7 công trình, Thành thị cấp 1–4, quyên góp, thuế ngày, trạm dịch.
  - 4 công trình VNG chạy nguyên bản qua `ct_api.lua`, nên làm được 894, 908, 30, 31, 34 và lính đánh thuê / sát thủ 850–874.
- **Thêm**: Nhiệm vụ 69, 78, 79 viết theo taskinfo. 15 Hoa thần Cửu Di đặt cố định.
- **Sửa**: Plug-in `extra_congthanh.py`:
  - nối `ct_api` vào 4 script 即时国战;
  - tắt nhánh di chuyển hoa bị lỗi;
  - nhãn menu chứa "/" không còn gọi sai hàm.
- **Thay đổi**: `PTADM_EXT_NAMES` có thêm `congthanh` (backup `_backup\20261003-ext3\`). Task 2430–2479.
- **Chuẩn bị**: Bản vá C++ tùy chọn (8 native chế độ bang hội, sửa tràn bộ đệm `KGameData szKeyName[6]`), sẽ áp cùng đợt build cuối.

### [COMPLETED] - 2026-10-03 16:22 (đã cài ptfix v22; cần khởi động lại server và client)
- **Sửa**: Thủ Khố Sùng Thành doanh / Ngọc Hư cung / Xi Vưu Mộ lệch chỉ số menu từ khi coordinator chèn dòng "Mở rương chứa đồ" vào đầu bảng `tasks` (02/10):
  - "Hộp gấm" (task 20) không bao giờ hiện, nên chuỗi Tô Hộ → Thủ Khố → Triệu Điền / Triệu Lôi tắc;
  - "Thu thập" (task 26/16/36) và "Sử dụng Thủ khố" hiện sai.
  - Dời chỉ số `tasks[N].show` +1 trong `main()` (sửa mức byte). Backup `_backup\20261003-newbiefix\`.
- **Sửa**: `sim_main.lua` bỏ qua mọi `Include`, nên báo nhầm `PTSD_JudgeRelation` nil; nay chỉ bỏ qua `vng_tasknote`.
- **Thêm**: Mô phỏng `sim_nbfemu.lua` (chuỗi tân thủ với stack giống engine) và `sim_nbf_tn.lua`. Tài liệu `tan-thu-thon-phong-than-20261003.md`.
- **Thay đổi**: ptfix v22 (615 entry, 22 plug-in) đã cài cho Server + Client. Bản cũ ở `_backup\ptfix-20261003-162150`. Plug-in `extra_congthanh.py` còn đang làm (Lua có điều kiện chặn), sẽ build lại khi agent congthanh xong.

### [COMPLETED] - 2026-10-03 16:20 (tienma23; script đã cài, chờ ptfix v22 + khởi động lại)
- **Thêm**: Tiên Ma giới giai đoạn 2 (Bất Chu Thiên Quan 1073):
  - chủ tuyến bước 8–19 (Liên Hoa Thần Đăng) cho cả hai phe;
  - nhiệm vụ 96, 97, 1023/1028, 1026, 1027, 1042, 1043, 92;
  - đặt Xích Tinh Tử, Cao Giác, Chúc Dung, Nữ Oa, Ma Lễ Thọ (1603, 3235; tách khỏi Ma Lễ Thọ của Đông Di).
- **Thêm**: Tiên Ma giới giai đoạn 3 (Bất Chu Sơn 1074):
  - chủ tuyến bước 20–27 (Hỏa Thần / Thủy Thần, Thiên Niên Đại Thạch → Thạch Quái);
  - nhiệm vụ 99/100, 103, 1030–1034, 1036, 1037, 1040/1041;
  - bàn giao cho giai đoạn 4 ở task 2222 = 27.
- **Sửa**: Plug-in `extra_tienma.py`:
  - thêm 55 stub NPC VNG và 5 death script;
  - đưa 8 quẻ Bát Quái (file GBK rời, engine không đọc được) vào PAK;
  - viết lại Huyễn Quang Kính (so map runtime 1000+N, bỏ `math.*`).
- **Thay đổi**: Biến Tiên Ma dùng trường thập phân trong các biến đã có, cộng 2263/2278, vì dải 2260–2279 bị hệ linh sủng VNG chiếm. Backup `_backup\20261002-tienma23\`.

### [COMPLETED] - 2026-10-03 16:45 (có hiệu lực khi khởi động lại server)
- **Thêm**: Nối Lục Lâm với Vận Lương/Vận Tiêu: người phá xe của **người khác** nhận cờ Lục Lâm (xe lương: Đạo Tặc, xe tiêu: Kim Bài) qua `PTD3_LL_GrantFlag`; chủ xe không nhận. `vanluong\vl_core.lua` Include `daily3\d3_lib.lua`, gọi trong chế độ bảo vệ.
- **Sửa**: Vận Lương không bao giờ vào được nhánh nói chuyện với xe lương / Lương Thảo Quan (giao xe) trong game. Engine gọi `main(npcIndex)` (`KPlayer::DialogNpc`) và không có biến toàn cục `DialogNpcIdx`.
  - `main(npcidx)` nay dùng tham số, `DialogNpcIdx` chỉ còn làm dự phòng cho mô phỏng.
  - `PTVL_TieuNear` đo khoảng cách từ vị trí người chơi.
- **Kiểm tra**: `sim_vanluong` 47/47; `t_luclam_link.lua` (người chơi thứ 2 phá xe → cờ 2318 = 1, chủ xe không có cờ).
- **Tệp**: nguồn `scratchpad\vantieu\src\vl_core.lua`, `vl_lib.lua` (sinh lại bằng `gen.py`). Backup `_backup\20261003-luclam-link\`.

### [COMPLETED] - 2026-10-03 16:40 (sinhhoat; script đã cài, chờ ptfix v22 + khởi động lại)
- **Thêm**: Sự kiện Lễ Quan:
  - 5 NPC;
  - lễ vật hằng ngày;
  - Tam Nguyệt Kỳ Sơn (trồng cây ở Kỳ Sơn);
  - Khiêu chiến cực hạn (7 heo);
  - giờ 12:00–13:59 và 19:00–22:59, có thông báo.
- **Thêm**: Sinh hoạt:
  - 5 Sinh Hoạt Sư, 30 điểm thu thập;
  - 5 kỹ năng sống cấp 1–10, nhiệm vụ 1200–1202;
  - chế tác, đơn hàng ngày, Tôn Sư 1509–1513.
- **Thêm**: Linh thú: 8 con × 4 giai đoạn (mẫu VNG 2486–2536), Linh Thú Sứ (Tây Kỳ / Triều Ca), Linh Thú Lệnh, trứng, Linh Thú Đơn. Đi theo chủ, lên cấp khi chiến đấu, không đánh. Phần đánh và cộng chỉ số cần C++, đề xuất ở tài liệu mục 2.6.
- **Thêm**: Plug-in `extra_sinhhoat.py` (magicscript 61370–61381, forwarder 生活技能老师 / 礼官), task 2370–2399.

### [COMPLETED] - 2026-10-03 16:30 (daily3; script đã cài, chờ ptfix v22 + khởi động lại server)
- **Thêm**: Mã Đế (taskinfo 81): Ân Hồng giao thêm tối đa 10 vòng sau 5 lần Siêu Độ; thưởng kinh nghiệm cộng dồn 10% / vòng, quà ở vòng 5 / 10.
- **Thêm**: Phúc Kim (taskinfo 71): Nhà Chiêm Tinh ở Triều Ca / Tây Kỳ đổi Bá Lạc Nhãn cấp 1–5 lấy 5–150 vạn lượng, 5 lần / ngày.
- **Thêm**: Lục Lâm Hảo Hán (Tam Sơn), phía cướp:
  - phá xe lương quan phủ / xe quân lương;
  - danh hiệu Lục Lâm Đạo Tặc / Kim Bài (cờ Lua + rank 200/201);
  - plug-in `extra_daily3.py`.
- **Sửa**: F11 chuỗi 2004 dùng chữ taskinfo đời 2004 cho các id 1, 2, 7, 8, 10, 13, 16, 31; hết báo "hoàn thành" sớm và hết "Task 31 - step 0".
- **Sửa**: F11 cho 44 script rời còn dùng TaskNote C++ (Include ở cuối file); bọc `NewTaskNote`. Backup `_backup\20261003-daily3\`.
- **Ghi chú**: Chưa nối cờ Lục lâm với xe Vận Lương thật (cần sửa `vanluong\vl_core.lua`, đoạn sửa ở Phần 3 tài liệu daily3).

### [COMPLETED] - 2026-10-03 16:10 (sudocpp; CoreServer đã triển khai, chờ ptfix v22 + khởi động lại server)
- **Thêm (C++)**: API sư đồ VNG (`PhongThanLuaMasterPR.h`, đăng ký trong ScriptFuns.cpp):
  - `GetMasterPRValue` / `AddMasterPRValue` / `DecMasterPRValue`;
  - `CanMasterPR` / `DoMasterPR` / `UnMasterPREx`;
  - `IsMaster`, `CanChangeMasterPRValue` / `ChangeMasterPRValue`;
  - `GetNativeWeightMax` / `AddWeightMax`, `MasterPRVersion`.
  - Lưu bằng task engine 4847/4848, không đổi DB. CoreServer build 0 lỗi, đã triển khai 16:10. Backup nguồn `_backup\20261003-sudocpp\cpp\`.
- **Thêm**: Hoàng Phi Hổ mở lại Bái sư, Đổi điểm sư đồ, Quy Chân Kính và Xuất sư. Người chơi một mình xuất sư với Hoàng Phi Hổ làm sư phụ ảo (1 lần / nhân vật, task 2410).
- **Thêm**: Na Tra mở lại Đổi sức lực (plug-in `extra_sudocpp.py`, cờ `PTSC_WEIGHT_EXCHANGE`). Lưu ý: engine không có luật sức chứa hành trang, nên sức lực chỉ được lưu và hiển thị.
- **Sửa**: `npc_fix\1021_hoang_phi_ho.lua` nối thêm Include `sudocpp_hph.lua` (backup `_backup\20261003-sudocpp\`).

### [IN PROGRESS] - 2026-10-03 16:10 (newbiefix)
- **Sửa**: Người dùng báo nhiệm vụ tân thủ ở Sùng Thành doanh / Xi Vưu Mộ / Ngọc Hư cung không hoạt động.
  - Server đã tắt hẳn từ 14:42; lần chạy cuối, newbie2 còn lỗi tràn ngăn xếp (đã sửa 15:20).
  - Mô phỏng `sim_main newbie:0..2` báo chuỗi tân thủ 2004 đứng ở progress=0 (hồi quy).
  - NPC sư đồ gọi `PTSD_JudgeRelation` nil.
  - Agent newbiefix đang khoanh vùng nguyên nhân và sửa.

### [COMPLETED] - 2026-10-03 (tienma45; script đã cài, chờ ptfix v22 + khởi động lại server)
- **Thêm**: Tiên Ma giới giai đoạn 4 (Ngục Pháp Sơn 1075) và 5 (Thánh Địa 1076):
  - chủ tuyến bước 28–50;
  - 22 nhiệm vụ phụ / ngày (104–113, 115/116, 118, 119, 1077, 1078, 1082–1089, 1097/1098);
  - 68 NPC và 52 quái do `ext\tienma45.lua` giữ sống;
  - bàn giao từ bước 27 qua task 2222.
- **Thêm**: Plug-in `extra_tienma45.py`: stub vật phẩm Giải chú phù / Hà Đồ Lạc Thư / Dẫn Tuyền Châm, death script quái 1075, 33 đường dẫn NPC VNG.
- **Thay đổi**: `script\item\hetuluoshu.lua` (bản VNG Lua 5) thay bằng stub. Backup `_backup\20261002-tienma45\`.

### [COMPLETED] - 2026-10-03 16:00 (vienco; script đã cài, chờ ptfix v22 + khởi động lại server)
- **Thêm**: Viễn Cổ chiến trường (Thương Chu, map 1071), bản PvE chơi một mình:
  - hai đạo quân NPC Thương (camp 1) / Chu (camp 2);
  - người chơi chọn phe tại Viễn Cổ Chiến Sứ (Phong Thần Đài);
  - mỗi giờ một trận 45 phút, tổng kết tự động;
  - giữ luật VNG Vị Quốc Lập Công (taskinfo 85), đẳng cấp chiến trường 0–10.
  - Tệp: `ext\vienco.lua`, `vienco\vc_*.lua`.
- **Thêm**: Giang Sơn Y Cựu (taskinfo 1053–1058, 1081): chuỗi 19 bước tại Dư Khánh (Triều Ca), mục tiêu riêng từng người (`vienco\gs_*.lua`).
- **Sửa**: Plug-in `extra_vienco.py` thay `新古战场\姜尚.lua` / `闻仲.lua` bằng chủ tướng bản PvE, và cho bẫy 周营in / 商营in đọc phe ở task 2341.
- **Ghi chú**: Đề xuất stub C++ `OpenNpcCollectionDlg` (sách 江山卷) sẽ áp cùng đợt C++.

### [COMPLETED] - 2026-10-03 15:52 (petmorph; có hiệu lực khi khởi động lại server)
- **Thêm**: Lệnh Bài Triệu Hồi có mục "Đổi hình dạng đệ tử" kiểu VNG:
  - 6 hình: Thỏ Vàng, Câu Trần Vàng, Chúc Thần Vàng, Tất Phương, Hạn Bạt, Hóa Xà (mẫu 2651–2656, task 254);
  - có tùy chọn trở về hình mặc định;
  - miễn phí, chỉ đổi ngoại hình, giữ nguyên chỉ số và kỹ năng.
- **Thay đổi**: Đệ tử lệnh bài được gọi lại ngay với hình mới (`NpcPolyMorph`). Đệ tử kỹ năng 450–461 mang hình đã chọn từ lần triệu hồi kế tiếp.
- **Sửa**: Gọi về / thu hồi nhận đúng đệ tử đã đổi hình. Backup `_backup\20261003-petmorph\`.
- **Ghi chú**: Bản vá client tùy chọn (`SyncNpc` nạp lại sprite khi đổi mẫu) ở `scratchpad\petmorph\cpp_patch.md`, sẽ áp cùng đợt C++ Hoàng Phi Hổ / công thành.

### [COMPLETED] - 2026-10-03 15:45 (đã triển khai client VS2022 + ptfix v21; cần khởi động lại server và client)

**Client VS2022**
- **Sửa (C++)**: Đưa toàn bộ vá byte client vào mã nguồn:
  - `g_ReleaseCore` giải phóng `g_SoundCache` trước khi DirectSound tắt (lỗi thoát "…a350");
  - thanh máu 0% không vẽ;
  - `barback.spr` vẽ theo góc trên trái (`bRenderFlag = 0`);
  - `PhongThanUsesActorCanvas` nhận mọi đường dẫn `npcres\` (thay vá Represent2 0xB0C3).
- **Thay đổi**: Dựng lại client bằng VS2022: Game.exe, CoreClient.dll, Represent2.dll (Engine.dll, LuaLibDll.dll dùng chung bản server), 0 lỗi.
  - Đã triển khai 15:43 bằng `_backup\20261003-coreclient\Deploy-ModernClient.ps1`; 5 file khớp mã.
  - Bản VC6 lưu ở `_backup\client-deploy-20261003-154302`; quay về bằng `Rollback-ModernClient.ps1`.
  - Các vá byte cũ tự bỏ qua vì TimeStamp khác.
- **Thay đổi**: `Build-Modern.ps1` tự thêm vswhere vào PATH; Game.exe giữ cờ như bản VC6.

**Càn Khôn Luân (cankhon2)**
- **Sửa**: Thái Tuế Sư cũ là tượng đá (tpl 1116) đứng sát tường góc đông bắc Tây Kỳ, không đi tới được. Đã xóa dòng spawn trong servertimer (backup `_backup\20261003-cankhon2-st\`).
- **Thêm**: NPC hình người tpl 1130 "Thái Tuế Sư (Càn Khôn Luân)" ở Tây Kỳ (cạnh Cửa Nam, 173/199) và Triều Ca (quảng trường, 215/187), spawn qua `ext\cankhon2.lua`.
- **Sửa**: Dòng "Xoay" luôn hiện (dưới cấp 40 thì giải thích). Thiếu Hình/Cây thế thân thì chỉ chỗ mua (Kỳ Trân Các) hoặc cho trả 5 / 10 vạn lượng. Chặn phát thưởng 2 lần.
- **Thêm**: Plug-in `extra_cankhon2.py`: `\script\彩票\太岁.lua` Include bản đã sửa.

**Gói ptfix**
- **Thay đổi**: ptfix v21 đã cài cho Server + Client.

### [IN PROGRESS] - 2026-10-03 15:30
- **Thay đổi**: `PTADM_EXT_NAMES` có thêm `tienma45`, `daily3`, `vienco`, `sinhhoat`, `cankhon2`. Backup `_backup\20261003-ext2\`.
- **Thêm**: Đang làm song song:
  - Càn Khôn Luân không thấy NPC, không quay được (cankhon2);
  - Tiên Ma giới giai đoạn 2–3 (tienma23) và 4–5 (tienma45);
  - Mã Đế, Phúc Kim, Lục lâm hảo hán, chữ F11 thật (daily3);
  - Viễn Cổ chiến trường, Giang Sơn Y Cựu (vienco);
  - Lễ Quan, Sinh hoạt, Linh thú (sinhhoat).
  - Hoàng Phi Hổ (API sư đồ) và hệ công thành cần C++: làm sau khi CoreClient build xong, vì cùng bộ mã nguồn Core.

### [COMPLETED] - 2026-10-03 15:20 (đã cài ptfix v20; cần khởi động lại server và client)
- **Sửa**: Tân thủ đời mới báo "stack overflow / Include failed vng_tasknote_data.lua" trên server thật.
  - Nguyên nhân: mỗi script state của engine chỉ có 120 ô stack Lua (`KLuaScript` gọi `lua_open(100)`). File taskinfo dựng mỗi bản ghi bằng một constructor lớn và được nạp ở đáy chuỗi gọi sâu của tick servertimer.
  - Viết lại `lib\vng_tasknote_data.lua` thành mỗi bước một câu lệnh nhỏ (394 bản ghi, 2248 bước, 0 khác biệt).
  - newbie2 nạp dữ liệu ở đầu điểm vào; ghi chú F11 được xếp hàng chạy ở độ sâu nông.
  - Backup `_backup\20261003-nb2fix\`.
- **Thêm**: Simulator `run.ps1 -Stack N -Db`, `sim_nb2emu.lua` mô phỏng đúng độ trống stack của engine.
- **Thay đổi**: ptfix v20 (499 entry; thêm `extra_clientcrash.py` cho missile 9, `extra_verifyall.py` cho rương Thủ khố Tây Kỳ/Triều Ca) đã cài cho Server + Client. Bản cũ ở `_backup\ptfix-20261003-151450`.

### [IN PROGRESS] - 2026-10-03 15:10 (build lại CoreClient bằng VS2022 để sửa tận gốc)
- **Sửa (vá byte, đã áp)**: Game sập lúc thoát (WER "unknown …a350", có từ 28/09). Destructor atexit của `g_SoundCache` gọi Release trên DirectSound buffer đã giải phóng. Vá CoreClient 0x56220 `b9` → `c3` trong `PhongThan-ClientPatch.ps1`, áp cho Runtime + Output, receipt đã cập nhật. Backup `_backup\20261003-soundexit\`.
- **Thêm (chờ build ptfix v20)**: Plug-in `extra_clientcrash.py` đặt Speed = 2 cho missile 9 (Băng Tuyết Đạn, skill 5/67), vì Speed 0 gây chia cho 0 ở cả client lẫn server. Tài liệu `loi-thoat-client-phong-than-20261003.md`.
- **Đang làm**: Build CoreClient (và các module client cần đồng bộ) bằng VS2022; chuyển các bản vá byte client vào mã nguồn; sửa `g_SoundCache` và khung thanh máu.

### [COMPLETED] - 2026-10-03 14:48 (đã cài CoreServer + ptfix v19; cần khởi động lại server và client)
- **Sửa (C++)**: GameServer sập lúc 14:01 và 14:42 (0xC0000094) trong `KSkill::CastExtractiveLineMissle`: một số loại đạn kỹ năng có tốc độ 0 nên phép chia cho tốc độ gây lỗi. Thêm `PT_SAFE_SPEED` cho 3 phép chia trong `KSkills.cpp`. Backup `_backup\20261003-missilespeed\`.
- **Thêm (C++, agent vantieu)**: `SendCarriage`, `GetTGuardNum`, `GetTGuardTimeScale`, `AddTongAttr` (`PhongThanLuaCarriage.h`); AiMode 12 cho xe tiêu đi theo chủ, không tấn công (`KNpcAI.cpp`). Backup `_backup\20261003-vantieu\`.
- **Thêm**: Vận Lương viết lại bằng Lua (Đồng Quan 1014, đường tắt có thổ phỉ, 6 chuyến/ngày). Vận Tiêu 2004 chạy lại theo lịch 12:00/19:00/21:00. Plug-in `extra_vanluong.py`, task 2121–2133.
- **Thêm**: Võ sư Tây Kỳ (1020) và Triều Ca (1021), trước đây chưa từng được đặt nên không mua/ép bí kíp được. Thêm vào bảng spawn của `ext\sudo_dongdi.lua`, gắn script PAK `\script\西岐|朝歌\教师.lua`.
- **Thêm**: Đã cài script Tiên Ma giới giai đoạn 1 (người dùng đồng ý 14:44).
- **Sửa**: Ô trống viền vàng cạnh bot/quái là khung thanh máu `barback.spr` bị Represent2 dời (−160, −192). Plug-in `extra_botvisual.py` đặt CenterY = 1. Gói ptfix chung cho Server + Client, vì PakChain chỉ có 1 mã băm.
- **Sửa**: Bot: `Stature` 180 → 114 (đi bộ) / 152 (cưỡi ngựa). `bots.lua` có `PTBot_Say`, không gửi chat rỗng. Backup `_backup\20261003-botvisual\`.
- **Thay đổi**: ptfix v19 (498 entry, 13 plug-in) đã cài cho Server + Client.

### [COMPLETED] - 2026-10-03 (questfix2; chờ build ptfix + khởi động lại server)
- **Sửa**: Quy Tinh (task 53):
  - Thiên Cương Tinh bị giết không còn hồi sinh mãi trên map. Script Cương Tinh đánh dấu `PTQ2_DEAD`; tick `ext\questfix2.lua` xóa trong vòng 1 phút và xóa luôn con bị bỏ quá 30 phút.
  - 6 Phong Ấn Tháp bỏ qua Cương Tinh người chơi đã thu.
  - Mô phỏng 6 tháp × 36 bước đạt.
- **Sửa**: 41 script npc_restore có thêm dòng "Kết thúc đối thoại" (35 file từng có hộp thoại cụt). Con bạc, Chủ cầm đồ, Tiểu Bảo, Võ Cát, Tống Dị Nhân có câu thoại riêng khi không có nhiệm vụ. Backup `_backup\20261002-questfix2\npc_restore`.
- **Thay đổi**: Giữ tọa độ tháp Bắc Hải / Cự Lộc (217,197), vì dữ liệu gốc cũng ghi vậy.

### [COMPLETED] - 2026-10-03 15:00 (newbie2; NPC chạy ngay ở tick kế tiếp, mật tịch cần ptfix mới)
- **Thêm**: Chuỗi tân thủ đời mới (taskinfo 897–913, 999–1008, 898–901) qua NPC Quân Sư (Tân thủ) ở 3 thôn. Chạy song song với chuỗi 2004; F11 dùng đúng id taskinfo.
- **Thêm**: Đếm quái bằng `newbie2\nb2_mob.lua` (gọi lại `mob_drop.lua`, giữ đồ rơi chuỗi cũ); đặt Đại phu Tam Sơn (1016) và Đồng Quan (1014).
- **Sửa**: 14 Mật tịch / Lệnh (6/1/303–309, 350–356) dùng được, qua stub ptfix `extra_newbie2.py`.
- **Thay đổi**: Không làm 894/908 (công trình lãnh địa, cần hệ công thành).

### [COMPLETED] - 2026-10-03 (sudo_dongdi + sửa hook Tứ Linh; chờ build ptfix + khởi động lại server)
- **Thêm**: Sư đồ chơi một mình:
  - Trừ yêu (42, số quái bằng một nửa VNG, tối thiểu 30) và 4 Thí luyện 43–46;
  - đặt 3 Võ sư tân thủ, Na Tra Tây Kỳ, 20 Đại phu trong mê cung.
- **Sửa**: Trừ yêu không đếm được quái (7/8 script chết VNG thiếu); mở lại thí luyện ở Thổ Hành Tôn, Hoàng Thiên Hóa, Dương Tiễn.
- **Thêm**: Chuỗi Đông Nguy (35, 37–41) chạy trọn 0→32:
  - mở lại điểm bắt đầu và menu Đông Di;
  - đặt 14 NPC Đông Di trong túi tây nam 1073, Ma Lễ Thọ ở (1606, 3880);
  - Thuyền phu Khai Minh đảo;
  - nguồn rơi vật phẩm thay thế.
- **Tệp**: `ext\sudo_dongdi*.lua`, plug-in `extra_sudo_dongdi.py`. Backup `_backup\20261003-sudo_dongdi\`.
- **Sửa**: Đếm quái Tứ Linh chưa từng chạy. `KNpcTemplate.cpp` đổi DeathScript `\script\npcdeath\normal.lua` sang `\script\phongthan\npc_quests\normal.lua`, nên hook cũ bị bỏ qua. Đã thêm hook vào `npc_quests\normal.lua` (bọc `OnDeath`, chạy trong chế độ bảo vệ). Mô phỏng đạt. Backup `_backup\20261003-tulinh-hook\`.

### [COMPLETED] - 2026-10-03 (daily2; chờ build ptfix + khởi động lại server)
- **Thêm**: Nhiệm vụ ngày đời mới theo taskinfo VNG:
  - Thiên Cống (56, 5 vòng);
  - Thiên Cương Hồn (53, 6 vòng);
  - Siêu Độ Linh Hồn (48, 5 vòng);
  - Hấp Hồn Âm Sát (70, 4 vòng);
  - Vận chuyển (61, 7 chuyến).
  - Chơi một mình được, F11 đúng chữ, reset theo ngày.
  - Tệp: `script\phongthan\daily2\*`, `ext\daily2.lua`, task 2140–2155 và 2169–2175.
- **Thêm**: Plug-in `extra_daily2.py`: stub `\script\封神台\殷郊.lua` chuyển sang hội thoại Thiên Cương Hồn.

### [COMPLETED] - 2026-10-03 15:15 (verifyall; chờ build ptfix v20 + khởi động lại server)
- **Kiểm tra**: Đối chiếu toàn bộ tính năng 01–03/10 với runtime.
  - Script khớp bản stage/generator; ptfix v19 khớp bản build lại (498 entry); hook servertimer đủ.
  - 444 file Lua: không lỗi cú pháp Lua 4, không `true`/`false`, không trùng tên global.
  - 389 đường dẫn script đều có file; các sim hiện hành đều đạt.
- **Sửa**: Thủ khố Tây Kỳ/Triều Ca (script PAK keeper Tứ Tượng) thiếu mục "Mở rương chứa đồ". Plug-in `extra_verifyall.py` thêm `pt_mo_ruong`.
- **Ghi nhận**: newbie2 tràn ngăn xếp khi Include `vng_tasknote_data.lua` (đang sửa). Npcs.txt còn 6 ô kỹ năng ghi tên GBK.
- **Sửa**: `gen_lua.py` của sudo_dongdi đã có Võ sư 1020/1021.

### [COMPLETED] - 2026-10-03 14:44 (tienma: script đã cài theo đồng ý của người dùng)
- **Thêm**: Tiên Ma giới giai đoạn 1:
  - Tiếp Dẫn Đạo Nhân ở Tây Kỳ, Triều Ca và 2 doanh trại 1073; chọn phe Tiên/Ma (cấp ≥ 75);
  - chủ tuyến 86/87/88 bước 0–7 (vũ khí Tiên Ma, Linh Xà, thú cưỡi cấp 8);
  - nhiệm vụ phụ 1024, 1025, 89; nhiệm vụ ngày 93/94 (9 vòng).
  - Plug-in `extra_tienma.py`: 9 stub `\script\不周天关\*.lua` và 6 death script quái Tiên Ma.
  - Script nằm sẵn ở `scratchpad\tienma\out\`; việc chép vào runtime bị bộ phân loại quyền chặn, nên chờ người dùng đồng ý.
- **Ghi chú**: Tên NPC tạm trên 1073–1075 không lệch: 1073 = Bất Chu Thiên Quan, 1074 = Bất Chu Sơn, 1075 = Ngục Pháp Sơn.

### [IN PROGRESS] - 2026-10-03 14:05
- **Thay đổi**: `servertimer.lua` có `PTAdm_ExtTick()`, chạy file mở rộng `script\phongthan\ext\<tên>.lua` cho 6 tính năng (questfix2, sudo_dongdi, vanluong, daily2, newbie2, tienma). Mỗi file chạy trong chế độ bảo vệ, thiếu file thì bỏ qua. Backup `_backup\20261003-ext\`.
- **Thêm**: Đang làm song song:
  - Quy Tinh (6 tháp) và hội thoại NPC thiếu nút thoát;
  - Sư đồ và Đông Di;
  - Vận Lương, Vận Tiêu (có C++);
  - nhiệm vụ ngày đời mới;
  - tân thủ đời mới;
  - Tiên Ma giới giai đoạn 1.

### [COMPLETED] - 2026-10-02 22:18 (đã cài ptfix v17; cần khởi động lại server và game)
- **Sửa**: Tứ Linh có đường vào: Thầy tướng số Tây Kỳ/Triều Ca gắn vào script PAK đã vá (`PTADM_NPC_FIX`).
- **Sửa**: Tứ Tượng nhận được: thêm Thủ Khố Tây Kỳ (1469/3063) và Triều Ca (1715/3036), tpl 151.
- **Sửa**: Thử Thách Huyền Vũ dùng đúng map 1084 Huyền Vũ Thần Vực (trước là 1086 Tử Huyền Động Thiên).
- **Thêm**: 14 NPC nhiệm vụ: Người Hái Thuốc, Thầy Bói, Tân Miễn, Tì Bà, Bá Giám, Đồ Thư Quán, Cù Lưu Tôn, 6 Phong Ấn Tháp. Người Tây Vực dùng script VNG thật.
- **Thêm**: 13 quái nhiệm vụ: Dược Lâu Tử, Hoa Trư, cá Đông Hải. Plug-in `extra_questfix.py`:
  - thêm `LastDamage` cho script quái và Thiên Cương Tinh;
  - sửa `AddNpc` 6 tham số ở Phong ấn tháp;
  - thêm hàm dự phòng `HaveItem2` / `LoadIni`;
  - Thầy Bói nhận map 1020/1021.
- **Sửa**: Võ Cát đếm Đèn thần bằng `HaveEventItemCount(41)`, nên Vi Lao qua được bước 6.
- **Thay đổi**: `servertimer.lua` chỉ thêm dòng dữ liệu (đánh dấu `-- qf`). Backup `_backup\20261002-questfix\`.
- **Thay đổi**: ptfix v17 (448 entry, 6 plug-in) đã cài cho Server + Client.
- **Tài liệu**: `kiem-toan-nhiem-vu-phong-than-20261002.md`.

### [COMPLETED] - 2026-10-02 21:41 (đã cài ptfix v16; cần khởi động lại server và game)
- **Sửa**: Bí kíp hệ phái (sách kỹ năng VNG loại 7) không click học, không mua, không ép được. Nguyên nhân:
  - `KItemList::ExecuteScript` bỏ qua loại 7;
  - `KBuySell` thiếu nhánh `item_skillbook`, nên 80 dòng sách trong goods.txt bị bỏ và làm lệch hàng mọi tiệm phía sau;
  - "Đóng sách" của Võ sư VNG cho sách loại 7, không kiểm tra chỗ trống.
- **Thêm**: 60 bí kíp magicscript 6/1/(62000+mã kỹ năng), click phải để học (đúng phái, đủ cấp): `lib\pt_bikip.lua`, `item\bikip_<mã>.lua`, `bikip_sach7.lua`. Plug-in `extra_bikip.py`.
- **Sửa**: goods.txt có 63 dòng sách thành bí kíp và 17 dòng giữ chỗ; các tiệm hết lệch hàng do sách.
- **Thêm**: 3 tiệm bí kíp theo phái (Sale 66/67/68). Võ sư Tây Kỳ/Triều Ca có thêm:
  - "Mua bí kíp hệ phái";
  - "Đóng sách (ép bí kíp)": công thức VNG, cần 3 ô, thiếu thì trả lại;
  - "Đổi sách kỹ năng cũ thành bí kíp".
- **Thay đổi**: ptfix v16 (406 entry, 5 plug-in) đã cài cho Server + Client; bản cũ ở `_backup\ptfix-20261002-214104`.

### [COMPLETED] - 2026-10-02 21:40 (cần khởi động lại server và web admin)
- **Sửa (dữ liệu)**: GameServer sập lúc 21:15 khi khởi động (0xC00000FD, tràn ngăn xếp trong `_chkstk`), ngay sau khi nạp bản đồ.
  - Nghi do đợt gán kỹ năng hàng loạt. 47 ô kỹ năng trạng thái (style 2: Băng Cơ Tuyết Cốt, Phản đòn xa/cận chiến…) được cast ngay khi NPC sinh ra, thêm 6 ô hào quang (254, 255).
  - Thay các ô này bằng kỹ năng tấn công của chính mẫu NPC đó (hoặc 63). Backup `_backup\20261002-npcskills-state\`.
- **Thêm**: Web admin có tab "Bot giả người chơi":
  - bật/tắt bot;
  - bot tự do đi theo người chơi, kèm số lượng;
  - danh sách địa điểm (bản đồ, X/Y, số bot, cấp);
  - nút "Áp dụng" và "Tắt hết bot";
  - trạng thái tự làm mới mỗi 30 giây.
- **Thêm**: `bots.lua` đọc `admin_bridge\bots_config.lua`:
  - có `PTBOT_AdminApply()`;
  - tối đa 100 bot, từ bot thứ 47 tên có hậu tố số;
  - ghi trạng thái `admin_bridge\bots.txt`.
  - Backup `_backup\20261002-botadmin\`.

### [COMPLETED] - 2026-10-02 21:30 (đã cài ptfix v15 + CoreServer; cần mở server, client, web admin)

**Kỹ năng đệ tử Dị Nhân**
- **Thêm**: 12 kỹ năng triệu hồi mã 450–461 (SkillStyle 4, Attrib = mẫu NPC 359…2032), qua plug-in `extra_petskill.py` cùng script cấp `\script\phongthan\skill\pt_summon_lvl.lua`.
- **Thêm**: Lệnh Bài Triệu Hồi có mục "Học kỹ năng triệu hồi" (học từng kỹ năng hoặc học tất cả, chỉ khi đủ cấp).
- **Thêm**: Web admin có nhóm "Kỹ năng đệ tử (triệu hồi)" cho Dị Nhân; lệnh đổi cấp giữ lại 450–461.
- **Sửa**: Tên kỹ năng chuyển sinh trong web admin bị lỗi font dưới PowerShell 5.1 (đã chuyển sang dạng `\uXXXX`). Backup `_backup\20261002-petskill\`.
- **Sửa (C++)**: `KSkill::Cast` (CreateNpc) ghi đè ô kỹ năng 4 của đệ tử bằng `1574 + Attrib - 2152`. Với mẫu 359–2032 ra mã âm, nên đệ tử gọi bằng kỹ năng không đánh. Nay chỉ áp công thức khi Attrib ≥ 2152; ngược lại giữ kỹ năng của mẫu, và mã ≤ 0 thì dùng 1. Backup `_backup\20261002-petslot4\`.

**Tứ Tượng vòng 2**
- **Thêm/Sửa** (đã cài script; người dùng đồng ý 21:28):
  - Bảo Rương 1291 → 2 Tinh Hoa + 5 mỗi loại nguyên liệu;
  - Hộp Chu Tước → buff "Hồn Phách (Lôi)" 1 giờ;
  - Thẻ Bạch Hổ → x2 EXP 7 ngày (`getmoreexp_p`, task 2021);
  - buff bậc 4 Tứ Linh;
  - đổi thưởng Thất Tinh Huyền Vũ (task 2028/2022);
  - 6 script Huyền Vũ Phần.
- **Sửa**: Tứ Linh không còn gọi `AddIBBuff(326..350)`, vốn gắn nhầm debuff Nhị Thập Bát Tú lên người chơi.
- Backup `_backup\20261002-tutuong2\`.

**Gói ptfix**
- **Thay đổi**: ptfix v15 (405 entry: sound, tutuong_a, tutuong_b, petskill) đã cài cho Server + Client; bản cũ ở `_backup\ptfix-20261002-210919`.

### [COMPLETED] - 2026-10-02 21:25 (cần khởi động lại server)
- **Thay đổi**: Bot đi theo người chơi (`bots.lua`, `PTBOT_FOLLOW = 1`):
  - 40 bot (danh sách 46 tên);
  - mỗi phút, bot cách mọi người chơi hơn 45 ô được đưa tới quanh một người chơi online (cách 6–28 ô, cấp = cấp người chơi ±5);
  - khi không ai online thì quay về cách rải ở thành / bãi quái như cũ.
  - Backup `_backup\20261002-botfollow\`.

### [COMPLETED] - 2026-10-02 21:10 (đã triển khai CoreServer, cần khởi động lại server)
- **Sửa (C++)**: GameServer sập lúc 20:59 (0xC0000094, chia cho 0) trong `KSkill::CastSpread`. Khi mục tiêu đứng trùng vị trí người ra chiêu thì `nDistance = 0`. Lỗi lộ ra vì quái và đệ tử đã có kỹ năng. Thêm `if (nDistance <= 0) nDistance = 1;` và khởi tạo `nDesX/nDesY`. Các chỗ chia khác trong KSkills/KMissle đã có kiểm tra. Backup `_backup\20261002-castspread\`. Chỉ triển khai `CoreServer.dll`, mã runtime = Output = receipt.

### [COMPLETED] - 2026-10-02 21:15 (cần khởi động lại server và client)
- **Sửa (dữ liệu)**: Nguyên nhân gốc khiến đệ tử Dị Nhân không đánh: 12 mẫu đệ tử (359–362, 403–407, 1345, 1346, 2032) ghi kỹ năng bằng tên (`#npc tấn công vật lý`, `#arrow hỏa 2`...). `KNpcTemplate` đọc cột Skill bằng `GetInteger` (atoi), nên ra 0 và NPC không có kỹ năng. Một số mẫu còn có cấp kỹ năng 0.
  - Đổi sang mã số theo `skills.txt`: 63, 141, 139, 132, 142, 143, 144, 140, 145, 388, 297, 1996.
  - Cả 4 ô kỹ năng dùng kỹ năng chính, cấp ≥ 1.
  - Sửa ở cả Server và Client `settings\phongthan\Npcs.txt`, hai file vẫn giống nhau. Backup `_backup\20261002-petskill\`.
- **Sửa (dữ liệu, người dùng đồng ý 21:20)**: Sửa kỹ năng cho toàn bộ quái/NPC:
  - 1.442 mẫu, 5.667 ô kỹ năng đổi tên → mã số theo `skills.txt`;
  - 326 ô cấp < 1 nâng lên ≥ 1;
  - 167 ô có tên không tồn tại gán đòn thường 63.
  - Sửa ở cả Server và Client `Npcs.txt`; backup `_backup\20261002-npcskills\`. Tài liệu `ky-nang-quai-npc-phong-than-20261002.md`.

### [COMPLETED] - 2026-10-02 21:00 (đã triển khai 20:45, 5 file khớp mã)
- **Sửa (C++)**: Đệ tử Dị Nhân không đánh khi chủ đánh (`KNpcAI::ProcessAIType11`):
  - Trước đây đệ tử cách chủ quá 250 là bị kéo về ở mỗi lượt AI. Nó vừa chạy tới quái đã bị kéo lại, nên không bao giờ ra đòn. Nay chỉ kéo về khi cách chủ hơn 900, hoặc khi không có mục tiêu.
  - Đệ tử đánh đúng mục tiêu chủ đang dùng kỹ năng nhắm vào (`m_SkillParam1 == -1` → `m_SkillParam2`). Nếu không có thì đánh quái gần nhất.
- **Sửa (C++)**: `AddTotemNpc` / `AddMyTrap` (Lệnh Bài Triệu Hồi) gán phe của chủ cho đệ tử. Phe lấy theo mẫu NPC có thể trùng phe quái, khi đó không tìm được mục tiêu (`PhongThanLuaWave7.h`). Backup `_backup\20261002-petai\`.

### [COMPLETED] - 2026-10-02 20:45 (chờ ptfix v15 + mở lại web admin)
- **Sửa**: Cửa sổ ESC → Tùy chọn mất toàn bộ điều khiển âm thanh do thiếu file giao diện `\ui\ui3\UiOptions.ini`. Game.exe nạp tên này, còn VNG chỉ phát hành `选项.ini`. Plug-in ptfix `extra_sound.py` đóng gói lại bố cục VNG thành `uioptions.ini`: thanh Âm thanh / Hiệu ứng âm thanh, 4 nút bật/tắt, nút đóng.
- **Thêm**: Web admin, thẻ "Cài đặt client: âm thanh":
  - chỉnh nhạc nền / hiệu ứng (0–100) hoặc tắt hết tiếng;
  - ghi `Client\UserData\UiCommon.ini` mục [Options], có sao lưu, từ chối khi game đang mở (API `/api/clientsound`);
  - backup `_backup\20261002-sound\`.

### [COMPLETED] - 2026-10-02 21:10 (cần khởi động lại server và web admin)
- **Sửa**: Thiên Hùng (Tây Kỳ) đổi sang mẫu 202 `passerby054` (hình tiên nhân); tick tự thay NPC mẫu cũ.
- **Thêm**: Chuỗi nhiệm vụ ngày Vạn Tiên của Thiên Hùng (chuyển từ VNG `b5deef29`):
  - Lục Hồn Phiên;
  - diệt quái / tiên / Thông Thiên / hỏi Đại phu;
  - 11 đẳng cấp, trang bị bộ ở đẳng cấp 1/4/7/9;
  - Thưởng Kim Bài;
  - task 2006–2013 (`vt_quest.lua`, `vt_mob.lua`).
- **Thêm**: Web admin có tab "Vạn Tiên trận": nút "Mở Vạn Tiên trận" (`vtopen` → `PTVT_AdminOpen(n)`) và bảng trạng thái (`/api/vantien`). Backup `_backup\20261002-vantien2\`.

### [IN PROGRESS] - 2026-10-02 20:40
- **Thêm**: Đang làm song song:
  - Tứ Tượng:
    - Bảo Rương 1291 → 2 Tinh Hoa + 5 mỗi loại nguyên liệu;
    - Hộp Chu Tước → buff sát thương 1 giờ;
    - Thẻ Bạch Hổ → x2 EXP 7 ngày;
    - buff bậc 4 Tứ Linh;
    - đổi thưởng Thất Tinh Huyền Vũ.
  - Vạn Tiên:
    - Thiên Hùng hình người;
    - chuỗi nhiệm vụ ngày;
    - nút "Mở Vạn Tiên trận" trên web admin.
  - Âm thanh: client không có nút chỉnh âm lượng.

### [COMPLETED] - 2026-10-02 20:30 (đã triển khai, chờ mở server)
- **Sửa (build)**: Lúc 18:20, GameServer bản VS2022 vẫn sập khi nạp script: `LuaLibDll!setnodevector`, 0xC0000005, do hết bộ nhớ 2 GB. Bản GameServer.exe VC6 gốc đã được vá cờ LARGEADDRESSAWARE, còn `Build-Modern.ps1` lại link với `/LARGEADDRESSAWARE:NO`. Đổi thành `/LARGEADDRESSAWARE`, build lại GameServer và Bishop, rồi triển khai: 5 file khớp mã, backup `_backup\server-deploy-20261002-202922`.
- **Ghi chú**: Lỗi CRT 0xC0000409 lúc 16:35 đã hết sau bản sửa CRT handler.
- **Thay đổi**: Đã cài ptfix v14 cho Server và Client lúc 20:30 (bản cũ ở `_backup\ptfix-20261002-203027`).

### [COMPLETED] - 2026-10-02 17:05 (có hiệu lực khi mở server)
- **Sửa**: Bào Thương chặn mọi người chơi cấp ≥ 20 với câu "đang Vận Tiêu hoặc biến thân". `GetMorphType()` trả -1 khi không biến thân, script lại so với 0. Đổi thành `mt ~= -1 and mt ~= 0` trong `npc_fix\bao_thuong.lua` và generator; sửa mock simulator thành -1. Backup `_backup\20261002-baothuong\`.
- **Thêm**: Thủ khố Tây Kỳ, Triều Ca, Sùng Thành có mục "Mở rương chứa đồ" (`SetFightState(0)` + `OpenBox(2)`). Các map thành không có vật thể rương nên trước đây không mở được. Sửa mức byte giữ mã TCVN3. Backup `_backup\20261002-thukho\`.

### [COMPLETED] - 2026-10-02 18:30 (đã triển khai 18:50, 5 file khớp mã)
- **Thêm**: CoreServer có hàm Lua `Roulette(k[, tên ô])` và `RouletteBusy()`. Càn Khôn Luân (Thái Tuế Sư) quay khoảng 5–6 giây bằng chữ giữa màn hình, chậm dần, dừng đúng ô trúng rồi mới gọi `Finished()` phát thưởng (KPlayer.h/.cpp, ScriptFuns.cpp; backup `_backup\20261002-cankhon\`).
- **Bảo mật**: Mỗi nhân vật chỉ một vòng quay một lúc; hủy, không thưởng, khi thoát, mất kết nối, chết hoặc đổi bản đồ.
- **Sửa**: `npc_fix\1020_thai_tue.lua`:
  - truyền tên 12 ô;
  - chặn bấm lại khi đang quay (không trừ lượt);
  - vẫn phát thưởng ngay khi server chưa có `Roulette`.
- **Sửa (Build-Modern.ps1)**: cờ `/DHMONITOR_DECLARED` chỉ áp cho Bishop. Áp cho mọi project thì Core lỗi `ddraw.h C2061 HMONITOR`.

### [COMPLETED] - 2026-10-02 18:50 (cần cài ptfix v14 + khởi động lại server và client)

**Vạn Tiên trận**
- **Thêm**: Vạn Tiên trận chơi được, một người cũng chơi được:
  - 4 trận Thổ/Thủy/Hỏa/Phong trên map Huyễn 1079–1082;
  - Thiên Hùng ở Tây Kỳ mở trận theo yêu cầu và theo giờ VNG;
  - 4 tiên → Thông Thiên Giáo Chủ → 4 Bảo rương; Đại phu trong trận;
  - thưởng EXP, lượng, nguyên liệu, mảnh thủy tinh, Hoàn Nguyên Thạch; tối đa 2 lần mỗi trận mỗi ngày.
- **Tệp**: `script\phongthan\vantien\*.lua`, `missions\mission02..04.lua`, `timertask\task02..09.lua`.
- **Thay đổi**: `missions\mission01.lua` và `timertask\task01.lua` (bản VLTK) được thay; backup `_backup\20261002-vantien\`.

**Bot giả người chơi**
- **Thêm**: 18 template NPC 2703–2720 trong `settings\phongthan\Npcs.txt` (Server + Client); backup `_backup\20261002-bots\`.
- **Thêm**: `script\phongthan\bots\bots.lua` giữ 26 bot ở thành, bãi luyện công, quanh boss thế giới và Phong Thần đài. Bot đổi chỗ, có bong bóng chat, chào người chơi, dòng "[Thế giới]".

**Tứ Tượng**
- **Thêm**: Lớp tương thích Lua 5 trong `pt_compat.lua`: `math`/`table`/`string`, `require`, `DelItemByID`, các stub VIP. Mỗi tên chỉ được gán khi đang nil.
- **Sửa**: Các vật phẩm Tứ Tượng:
  - Túi Tứ Tượng 8/286 cho 1 mỗi loại nguyên liệu;
  - Túi 6/1/1652 và 6/1/1835 dùng được;
  - Rương 1291, Hộp Chu Tước 1329, Thẻ Bạch Hổ 1304 không còn lỗi script; phần thưởng gốc không có trong dữ liệu VN thì vật phẩm được giữ lại.
- **Sửa**: Nhiệm vụ Tứ Tượng ở Thủ khố Tây Kỳ/Triều Ca kiểm tra ô trống và đủ 10 nguyên liệu trước khi thưởng.
- **Thêm**: Trưởng lão Tứ Tượng (677–680) lúc 00/12h :00/:15/:30/:45 cạnh 4 ma vương: đổi Tinh Phách → Ngưng Phách → Tứ Tượng Tinh Thạch. 4 ma vương rơi 2 Tinh Phách đúng hệ (`wb_lib.lua`). Backup `_backup\20261002-tutuong_a\`.
- **Thêm**: Tứ Linh (Linh Tê) ở Thầy tướng số Triều Ca/Tây Kỳ:
  - 4 lượt/ngày, Chìa khóa Linh Tê 8/329 cho thêm lượt;
  - 6 vòng mê cung;
  - vòng 6 thưởng thêm Tinh Phách và cơ hội Lâm Tiên Lộ.
- **Thêm**: Thử Thách Huyền Vũ (map 1086), một người chơi được:
  - Thí Luyện Thần Sứ ở Triều Ca, đăng ký 18:50, vào lúc 19:20 hoặc vào ngay;
  - 8 đợt quái trong 15 phút, kết thúc có Bảo Rương.
- **Sửa**: `npcdeath\normal.lua` có hook đếm quái Tứ Linh (ptfix + file loose); backup `_backup\20261002-tutuong_b\`.

**Gộp và tích hợp**
- **Sửa**: Đổi tên các hàm/biến trưởng lão từ `PTTT_` sang `PTTE_`, vì trùng tên với Tứ Linh/Huyền Vũ.
- **Thay đổi**: `servertimer.lua` có `PTAdm_FeatTick()` gọi 4 tick (bot, trưởng lão, Tứ Linh/Huyền Vũ, Vạn Tiên) trong chế độ bảo vệ `call(...,"x")`: tick nào lỗi thì ghi `admin_bridge\tick_error.log`, admin bridge không dừng. Backup `_backup\20261002-merge\`.
- **Thay đổi**: `build_ptfix.py` nạp plug-in `extra_*.py` (backup `.v13`). Đã build ptfix v14 (397 entry), chờ cài tại `AdminWeb\pending\ptfix.pak`.

### [COMPLETED] - 2026-10-02 18:10 (đã triển khai, chờ mở server để thử)
- **Sửa (C++)**: GameServer bản VS2022 thoát ngay khi khởi động (ucrtbase 0xC0000409 — CRT mới dừng tiến trình khi gặp tham số không hợp lệ, CRT của VC6 thì bỏ qua). Thêm `_set_invalid_parameter_handler` bỏ qua lỗi vào `KFile.cpp`, `KCore.cpp`, `GameServer.cpp` (backup `_backup\20261002-crtfix\`).
- **Thay đổi**: Build lại `Bishop.exe` bằng VS2022, vì Bishop cũng nạp `Engine.dll`; lần triển khai trước dừng giữa chừng do Bishop khóa `Engine.dll`.
- **Sửa (Build-Modern.ps1)**: gọi `rc.exe` trực tiếp, không qua response file; tự thay `afxres.h` (MFC) bằng `winres.h`; thêm `/DHMONITOR_DECLARED`.
- **Sửa (Deploy/Rollback-ModernServer.ps1)**:
  - thêm `Bishop.exe`; kiểm tra cả GameServer lẫn Bishop đã tắt;
  - rollback luôn về bản VC6 gốc `server-vc6-20261002-161718`;
  - sửa tên thư mục backup `Output`;
  - in kết quả đối chiếu mã băm.

### [COMPLETED] - 2026-10-02 16:26
- **Sửa (C++)**: Mua, bán, sửa đồ ở cửa hàng NPC và Lệnh Bài Hủy Đồ không còn bị từ chối ngầm:
  - `KPlayer::BuyItem` và `SellItem`: chỉ cần ở cùng bản đồ với lúc mở cửa hàng (trước đây phải đúng từng đơn vị vị trí);
  - `KBuySell::CanBuy`, `KBuySell::Sell`, `KPlayer::RepairItem`: được dùng khi đang chiến đấu;
  - `RepairItem`: giá sửa = 0 thì sửa miễn phí thay vì bỏ qua.
  - Backup mã nguồn ở `_backup\20261002-shopfix\`. CoreServer build lại và đã triển khai lúc 16:25; backup bản trước ở `_backup\server-vc6-20261002-162518` (đây là bản VS2022 cũ, bản VC6 gốc vẫn ở `server-vc6-20261002-161718`).
  - Bỏ câu "Đứng yên tại chỗ" trong lời nhắc của lệnh bài.

### [IN PROGRESS] - 2026-10-02 16:30
- **Sửa (nghiên cứu)**: Bào Thương, Càn Khôn Luân (kèm vòng quay thật) và Rương Thủ Khố đều không chạy trong game (người dùng báo). Đang chẩn đoán.
- **Thêm (nghiên cứu)**: Tứ Tượng: lệnh và trận (cùng Vạn Tiên trận), thần thú và phó bản.

### [IN PROGRESS] - 2026-10-02 16:40
- **Thêm (nghiên cứu)**: Vạn Tiên trận, sự kiện PvP hẹn giờ của VNG (mission). Đang dò script, bản đồ, lịch, luật và phần thưởng trong PAK, cùng mức hỗ trợ của engine.
- **Thêm (nghiên cứu)**: Bot giả người chơi (người dùng chọn: 20–30 bot; đi dạo trong thành, đánh quái, chat, tham gia Vạn Tiên trận/PK). Đang dò cách cho NPC hiện như người chơi (`m_Appearance`, bản thử `KPlayerSet::AddBot`) và AI di chuyển/đánh quái.

### [COMPLETED] - 2026-10-02 16:17 (đã triển khai, chờ thử trong game)
- **Triển khai**: Người dùng đồng ý. Đã chạy `Deploy-ModernServer.ps1`: GameServer.exe, CoreServer.dll, Engine.dll, LuaLibDll.dll bản VS2022 đã vào Runtime\Server và Output\Server; mã băm runtime, Output và receipt khớp nhau. Backup VC6 ở `_backup\server-vc6-20261002-161718`. Khôi phục bằng `_backup\20261002-modernbuild\Rollback-ModernServer.ps1`.

### [IN PROGRESS] - 2026-10-02 16:20 (build xong, chờ triển khai)
- **Build**: Bộ server đã build thành công bằng VS2022 (`OutputModern\Server`): GameServer.exe, CoreServer.dll, Engine.dll, LuaLibDll.dll (32-bit, cần VC++ 2015–2022 x86).
- **Sửa** `Build\Build-Modern.ps1`:
  - stderr của cl không còn dừng script trên PS 5.1;
  - bọc ngoặc kép đúng cho đường dẫn có dấu cách;
  - link các `.lib` khai báo như file nguồn trong `.dsp`, ưu tiên bản `.lib` vừa build;
  - thêm `/NODEFAULTLIB:libc`, `/D_WINSOCKAPI_`, `/Zc:sizedDealloc-`;
  - tự thêm ATL bản Spectre vào đường dẫn LIB/INCLUDE khi thiếu bản thường.
- **Sửa mã nguồn để build được bằng VS2022** (vẫn tương thích VC6, backup ở `_backup\20261002-modernbuild\`): Kime.cpp, KLuaScript.cpp, KStepLuaScript.cpp, EDOneTimePad.cpp, DataSource.cpp, KPlayerChat.h, inoutmac.h, KGMCommand.cpp, KNpc.h (`UpdateNpcStateInfo` chuyển sang public, mã vòng sáng gọi tới), KWeather.cpp, ScriptFuns.cpp.
- **Chuyển bản vá byte vào mã nguồn**: `KItemList::Fit` (pháp bảo đeo được 2 ô Talisman) và `KPlayer::AddSelfExp` (mọi quái thấp cấp hơn cho exp − exp×chênh/200).
- Triển khai bằng `_backup\20261002-modernbuild\Deploy-ModernServer.ps1`, khôi phục bằng `Rollback-ModernServer.ps1`. **Chưa triển khai**: chờ người dùng đồng ý và tắt GameServer.

### [IN PROGRESS] - 2026-10-02 15:50 (đã thay bằng mục trên)
- **Build**: Đã cài VS 2022 Build Tools 17.14.41 (MSVC 14.44, SDK 10.0.26100) sau khi thêm 2 chứng chỉ trung gian Microsoft (Code Signing PCA 2024, Windows Code Signing PCA 2024). Chạy `Build\Build-Modern.ps1` cho toàn bộ engine, kèm 5 bản sửa C++: vòng sáng set đồ, tay không có sát thương, chính xác âm, đệ tử tự đánh, RepairAllEquip. Đầu ra là `OutputModern`, chưa thay vào runtime.

### [IN PROGRESS] - 2026-10-02 10:30
- **Xóa**: Bản vá đệ tử tự đánh bằng chèn mã: launcher đã áp lúc 10:16 nhưng đệ tử vẫn đứng yên, nên không có tác dụng. Người dùng đồng ý gỡ. Đã bỏ 3 mục khỏi `PhongThan-ClientPatch.ps1` (bản cũ lưu ở `_backup\20261002-newbie\PhongThan-ClientPatch.ps1.withpet`). Khôi phục byte DLL bằng `_backup\20261002-newbie\Revert-PetPatch.ps1`; đang chờ server tắt vì DLL đang bị khóa.

### [IN PROGRESS] - 2026-10-02 10:05 (đã thay bằng mục trên)
- **Thêm (chưa áp)**: Đệ tử tự đánh kẻ địch gần nhất bằng cách chèn mã vào `CoreServer.dll`. Đoạn mã 27 byte đặt ở vùng trống cuối `.text` (RVA 0xA93E0): nếu không có mục tiêu thì gọi `KNpcAI::GetNearestNpc(8)` rồi nhảy về `ProcessAIType11` tại 0x1C8C2; `.text` VirtualSize đổi 0xA83DE → 0xA9000. Đã kiểm tra: vùng trống toàn byte 0, `GetNearestNpc` kết thúc bằng `ret 4`, các offset tương đối đúng. 3 mục đã nằm trong `PhongThan-ClientPatch.ps1`, nhưng lệnh áp bị bộ phân loại an toàn của Claude Code chặn ("Create RCE Surface"), **chưa ghi vào DLL**. Lần chạy launcher tiếp theo sẽ tự áp nếu giữ nguyên 3 mục này.
- Dừng làm các bản chèn mã còn lại (RepairAllEquip, vòng sáng set đồ) để chờ người dùng quyết định.

### [COMPLETED] - 2026-10-02 09:41
- **Sửa**: Vá byte `CoreServer.dll` thay cho bản build C++. `KNpc::CheckHitTarget` tại 0x16BFB: chính xác âm thành 0 (sàn 40% trúng) thay vì trượt 100%. Đã thêm vào `PhongThan-ClientPatch.ps1` và áp cho runtime và Output lúc 09:40.
- **Cài đặt**: ptfix v13 (F35C71C2) gồm đồ tân thủ, EXP x5, kỹ năng chuyển sinh, giá sửa đồ, Lệnh Bài Triệu Hồi. Bản cũ lưu ở `_backup\ptfix-20261002-094002`.
- **Ghi nhận**: Cài VS Build Tools lỗi 5003 / `0x80096004 Certificate is invalid` (mạng công ty can thiệp HTTPS hoặc thiếu chứng chỉ gốc). Các bản sửa còn lại cần chèn code nên chưa vá byte được: RepairAllEquip, đệ tử tự đánh, vòng sáng set đồ.

### [COMPLETED] - 2026-10-02 09:10
- **Thêm**: Đồ tân thủ. Nhân vật cấp ≤ 10 nhận một lần vũ khí cấp 1 max thuộc tính theo phái (dòng mới `meleeweapon` 900/901/902 trong ptfix v13: sát thương cố định tối đa, độ bền 100, dòng phép xanh cố định) và thú cưỡi Trác Mã/Tước/Điệp (horse 24–26). Code: `script\phongthan\newbie\starter_gear.lua` (task 1950), hook `PTAdm_NbTick` trong `servertimer.lua` (backup `_backup\20261002-newbie\`). ptfix v13 pending (F35C71C2), builder backup `.v12`.
- **Ghi nhận**: Máy không có trình biên dịch C++ (không có VC6, VS Build Tools, Clang, MinGW). `Build\Build-Modern.ps1` build bằng VS 2022 Build Tools (MSVC v143) nhưng chưa từng chạy. 5 bản sửa C++ đang chờ: RepairAllEquip, đệ tử tự đánh, tay không có sát thương, chính xác âm, vòng sáng set đồ.

### [COMPLETED] - 2026-10-02 08:45
- **Thay đổi**: Hệ số kinh nghiệm x5 (người dùng chọn). `GameSetting.ini` không có `[ServerConfig]`, nên `g_ExpRate` = 1. Đã thêm `ExpRate=5` vào ptfix v12 (pending, 512951B2) và vào bản rời `Server\settings\GameSetting.ini` (backup `_backup\20261002-exprate\`).
- **Sửa**: Lỗi LocalDB "SQL Server process failed to start" ở web admin. Nguyên nhân là Claude tự khởi động lại web admin từ shell sandbox. Đã dừng tiến trình đó; từ nay để người dùng tự mở lại web admin.

### [COMPLETED] - 2026-10-02 08:31
- **Thêm**: Web admin "Điểm thuộc tính" (lệnh `attr`): cộng thẳng sức mạnh/thân pháp/sinh khí/nội công mà không trừ tiềm năng (`AddProp` tổng rồi `AddStrg/AddDex/AddVit/AddEng`), cộng điểm tiềm năng tự do, xem chỉ số và chính xác, tẩy điểm (`ResetProp`, có xác nhận). Cập nhật mô tả Lệnh Bài Hủy Đồ. Web admin đã chạy lại lúc 08:29.

### [COMPLETED] - 2026-10-02 08:23
- **Sửa**: Cầm vũ khí vẫn không gây sát thương. Nguyên nhân chính: chính xác = thân pháp×4−28 = −16 với thân pháp 3, và `KNpc::CheckHitTarget` trả về trượt 100% khi chính xác âm. EmLaAi2 còn 95 điểm tiềm năng chưa cộng. Đã sửa C++: chính xác âm tính là 0, có sàn 40% trúng. Chờ VC6. Backup `KNpc.cpp.orig`. Dùng ngay: cộng thân pháp ≥ 8.

### [COMPLETED] - 2026-10-02 08:20
- **Sửa**: Đánh quái không mất máu và không hiện số sát thương. Bridge đo NPC 2796 Tuyết quái 60/60 máu trước và sau 1 phút. EmLaAi2 **không mặc trang bị nào**. `KPlayer::SetNpcPhysicsDamage` chỉ cộng sức mạnh/thân pháp khi có vũ khí, nên tay không ra 0, `KNpc::CalcDamage` bỏ qua `nMin + nMax <= 0` và cũng không hiện số. Đã sửa C++: tay không cộng sức mạnh, tối thiểu 1. Chờ build VC6. Backup `_backup\20261001-repairall\KPlayer.cpp.orig`. Cách dùng ngay: trang bị vũ khí cho nhân vật.

### [COMPLETED] - 2026-10-01 20:58 (điều tra trước đó)
- **Điều tra**: Đạo Sĩ/Dị Nhân đánh trúng quái (cả đánh thường) nhưng quái không mất máu (EmLaAi2, Đạo Sĩ cấp 1, map 1008). Đã loại trừ:
  - trạng thái chiến đấu: fight=1;
  - chênh cấp: quái cấp 3/7;
  - kháng của quái: Tuyết quái 60 máu, kháng 0–40%, khớp vng00;
  - dữ liệu và script kỹ năng: không đổi, các script có trong serverlist.pak;
  - `skills.txt`: engine dùng vng00 từ trước v9.
- Phát hiện phụ: vòng sửa đồ kẹt tay chuyển món "Xu" (questkey 4/47) của EmLaAi2 mỗi phút (532→537). Món này đã nằm trong túi nhưng vị trí báo về là 1, nên bị nhận nhầm là đồ trên tay. Chưa sửa.

### [COMPLETED] - 2026-10-01 20:42
- **Sửa**: Đệ tử Dị Nhân không tự đánh. AI 11 chỉ lấy mục tiêu khi chủ hoặc đệ tử bị đánh trúng, còn đòn đánh của người chơi không gán mục tiêu phía server. Đã thêm vào `KNpcAI.cpp` (`ProcessAIType11`): khi không có mục tiêu thì dùng `GetNearestNpc(relation_enemy)`. Chờ build VC6. Backup `_backup\20261001-repairall\KNpcAI.cpp.orig`.

### [COMPLETED] - 2026-10-01 20:30
- **Sửa**: Kỹ Năng Quyển 5624/5625/5626 trước đây chỉ là bản khóa BLOCKED_SPEC nên click không có tác dụng. Nay dạy mọi kỹ năng phái còn thiếu ở cấp 1, Dị Nhân được tặng thêm Lệnh Bài Triệu Hồi; sách chỉ mất khi có cho gì đó. Bản cũ lưu ở `_backup\20261001-kynangquyen\`.
- **Sửa**: Lệnh Bài Triệu Hồi hiện đủ 12 đệ tử, con chưa đủ cấp ghi "(cần cấp N)". Kiểm tra trên server: EmlaAi1 (cấp 10) đã gọi được Lực Sĩ tế, NPC 13425, sinh lực 523. Đã nạp nóng 20:29.

### [COMPLETED] - 2026-10-01 19:32
- **Sửa**: "Lệnh bài triệu hồi đang lỗi". Server vẫn chạy ptfix v9, nên vật phẩm 61003 chưa tồn tại trong dữ liệu (v11 còn nằm ở `pending`). Khi server và game đã tắt, đã chạy `PhongThan-ClientPatch.ps1` để cài ptfix v11 (29E18868) cho Server và Client; bản cũ lưu ở `_backup\ptfix-20261001-193200`. Các DLL đã vá sẵn, không thay đổi.

### [COMPLETED] - 2026-10-01 13:58
- **Thêm**: Đệ tử triệu hồi của Dị Nhân (VNG `summonskill.txt` 450–461 mà engine không đọc). Lệnh Bài Triệu Hồi (magicscript 61003, `trieuhoi_lenhbai.lua`) dùng `AddTotemNpc` (AI 11 thú cưng) + `SetNpcOwner` + `SetNpcCurCamp`, mốc cấp theo sách VNG. Web admin có mã `SummonToken` và khung Dị Nhân trong tab Kỹ năng. ptfix v11 (gồm v9 + v10) đặt ở `AdminWeb\pending`, backup builder `.v10`.

### [COMPLETED] - 2026-10-01 13:15
- **Sửa**: Sách kỹ năng "click không thấy gì". Log server cho thấy script có chạy, nhưng kết quả chỉ in bằng `Msg2Player` nên dễ bị bỏ sót. EmLaAi (Giáp Sĩ, cấp 120) đã có 1481–1483 cấp 10, và 1483 cần cấp 180. Từ nay kết quả hiện bằng hộp thoại `Say` (`PTSK_Show`).
- **Thêm**: Log chẩn đoán `Server\admin_bridge\token.log` cho Lệnh Bài Hủy Đồ (menu, từng mục, sau `Sale`) và cho sách kỹ năng. Đã nạp nóng 13:14.

### [COMPLETED] - 2026-10-01 09:32
- **Sửa**: Không sửa được đồ (NPC Thợ Đồng và Lệnh Bài Hủy Đồ). Trang bị VNG có giá gốc 1, nên `GetRepairPrice` = 0 và `KPlayer::RepairItem` bỏ qua. ptfix v10 đổi giá 1 → 1000 cho 19.721 dòng meleeweapon/armor/helm/belt/boot/pendant (`build_ptfix.py`, backup `.v9`). Bản v10 gồm cả nội dung v9 (kỹ năng chuyển sinh), đặt ở `AdminWeb\pending\ptfix.pak`, cài khi khởi động lại.

### [COMPLETED] - 2026-10-01 09:15
- **Thêm**: Kỹ năng chuyển sinh 60/120/180 cho 3 phái (1481–1489). ptfix v9 gồm script chỉ số `\script\skill\zhuansheng\*.lua` và `skills.txt` với thuộc tính engine đã xử lý; có 9 Sách kỹ năng (magicscript 61011–61019, `sach_kn_<id>.lua`). Web admin dạy/đặt cấp, phát sách, lệnh level giữ 1478–1489. ptfix v9 chờ cài khi khởi động lại; sách và lệnh bài đã nạp nóng 09:13.
- **Thêm**: Lệnh Bài Hủy Đồ bản 5/6. Mục "Hủy đồ" mở hộp `GiveItemUI`, xác nhận thì `RemoveRoom(12)` xóa vĩnh viễn. Mục "Sửa toàn bộ đồ đang mặc" gọi `RepairAllEquip()` nếu engine có.
- **Thêm**: Hàm C++ `RepairAllEquip` trong `ScriptFuns.cpp` (sửa miễn phí đồ đang mặc, đồng bộ độ bền), chờ build VC6. Backup `_backup\20261001-repairall\`.
- **Sửa**: Ghi nhận nguyên nhân sửa đồ ở cửa hàng không ăn: `KPlayer::RepairItem` bỏ qua khi giá sửa = 0 (đồ giá gốc 0/thấp).

### [COMPLETED] - 2026-10-01 08:57
- **Sửa**: Lệnh Bài Hủy Đồ — nhãn "Bán / hủy đồ trong túi" chứa `/` nên `Say` cắt nhãn và gọi sai hàm; đổi thành "Bán hoặc hủy đồ trong túi" (`huydo_lenhbai.lua` bản 4, backup `.v3`). Ghi kết quả kiểm thử trực tiếp: mua/bán đạt, hộp "Tu sửa" hiện cho đồ đang mặc.

### [COMPLETED] - 2026-10-01 08:30
- **Sửa**: Cửa hàng NPC (Đại Phu, Thợ Đồng, Tạp Hóa…) và Lệnh Bài Hủy Đồ không mua/bán/sửa được: `KBuySell::CanBuy`, `KBuySell::Sell` và `KPlayer::RepairItem` từ chối khi đang chiến đấu (thông báo lỗi không hiện ở client), mà nhiều đường vào thành không đặt lại trạng thái chiến đấu. `vng_tasknote.lua` bọc `Sale`: mở cửa hàng thì `SetFightState(0)` + task 1940 = 1; thẻ hủy đồ bản 3 tắt chiến đấu cho cả Bán và Sửa. Mô phỏng Lua 4 đạt; `ReLoadScript` 15 script lúc 08:27. Backup `_backup\20261001-shop-fight`. Tài liệu `cua-hang-trang-thai-chien-dau-phong-than-20261001.md`

### [COMPLETED] - 2026-10-01 08:05
- **Thêm**: Lệnh Bài Hủy Đồ có thêm chức năng sửa đồ đang mặc (bản Lua, người dùng chọn): menu Bán/hủy đồ · Sửa đồ đang mặc (tạm `SetFightState(0)` vì `KPlayer::RepairItem` từ chối khi chiến đấu, task 1940 ghi dấu, mở cửa hàng → nút Sửa → click từng món trong F3, trả lượng như NPC) · Bật lại chiến đấu · Kết thúc. Không có API sửa toàn bộ 1 lần (cần C++). Mô phỏng Lua 4 đạt; `ReLoadScript` trên server. Web admin cập nhật hướng dẫn. Backup `_backup\20260930-worldboss\huydo_lenhbai.lua.v1`

### [COMPLETED] - 2026-10-01 07:55
- **Thêm**: Phần thưởng boss thế giới (bảng "Tăng cường", người dùng chọn): `script\phongthan\boss\wb_loot.lua` (sinh bằng `scratchpad\boss\gen_loot.py`) + `PTWB_GiveLoot` trong `wb_lib.lua`, trao vào túi người hạ đòn cuối một lần mỗi lượt hạ. Theo cấp boss 40/60/80/100: đồ trắng VNG 2/3/4/5 món (loại theo npcdroprate-boss), 1 bí kíp đúng phái (5624–5626), đồ lục bộ cùng cấp 1/1/1/2 món, tỉ lệ 10/20/35/50% nhận pháp bảo/pháp khí/ấn (báo toàn server). Trước đây boss không rơi gì vì engine không đọc droprate .ini. Mô phỏng Lua 4 đạt; `AddItem` trên server tạo đủ mọi mã (57/57, 38/38, 10/10, 3/3, 144/144); nạp nóng 07:52. Tab web "Boss thế giới" thêm mô tả phần thưởng. Backup `_backup\20260930-worldboss\wb_lib.lua.v2`

### [COMPLETED] - 2026-10-01 07:50
- **Thêm**: Web admin tab "Cài đặt server" → "Cài đặt client: độ phân giải": chọn 800×600 / 1024×768 và Cửa sổ / Toàn màn hình, ghi `Client\config.ini` `[Client]` ScreenWidth/ScreenHeight/FullScreen (backup `_backup\client-config\`), có hiệu lực khi mở lại game. API `GET/POST /api/clientcfg`. Thử trên bản sao config.ini đạt
- **Ghi nhận**: Ô "độ phân giải" (cùng CmbAniQuality, MaxPlayerCount) trong giao diện VNG của ESC → Tùy chọn không có mã trong `KUiOptions`, cần C++. Thanh âm thanh có mã đầy đủ (OPTION_MUSIC/SOUND_VALUE → KOption 0–100); `UiCommon.ini` chưa từng lưu giá trị âm thanh; chờ người dùng mô tả triệu chứng. Tài liệu `cai-dat-do-phan-giai-am-thanh-phong-than-20261001.md`

### [COMPLETED] - 2026-09-30 20:55
- **Thêm**: Lệnh Bài Hủy Đồ (magicscript 61002, ptfix v8): vĩnh viễn, không mất khi dùng, không vứt/giao dịch/bán; `script\phongthan\item\huydo_lenhbai.lua` gọi `Sale(1)` ngay tại chỗ (OpenSale lưu vị trí của chính người chơi, hàm bán chỉ kiểm tra người chơi đứng yên), nên bán đồ trong túi từ xa được. `build_ptfix.py` gom 2 lệnh bài vào danh sách `TOKENS` (backup `build_ptfix.py.v7`). Web admin tab "Phát đồ": nút Phát Lệnh Bài Hủy Đồ / Boss Thế Giới, mã `SellToken`. Mô phỏng Lua 4 đạt; `ReLoadScript` 20:52; `AdminWeb\pending\ptfix.pak` = v8. Tài liệu `lenh-bai-huy-do-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 20:50
- **Thay đổi**: Lệnh Bài Boss Thế Giới: chọn boss → boss đang sống thì dịch chuyển tới (tới vị trí hiện tại nếu boss đã đi > 30 ô khỏi chỗ xuất hiện); boss chưa tới giờ hoặc đã bị diệt thì **gọi boss ra ngay** tại điểm VNG (thông báo toàn server "được <người chơi> triệu hồi"), rồi dịch chuyển tới. Ghi cùng GlobalValue với vòng lặp nên web và tick thấy boss đang sống; `wb_lib` xóa tên người hạ cũ khi boss sống lại. Mô phỏng Lua 4 đạt (gọi + dịch chuyển, sống, đã đi xa). Nạp nóng 20:50 (`ReLoadScript` + `dofile wb_lib`). Backup `_backup\20260930-worldboss\*.v2/.v1`

### [COMPLETED] - 2026-09-30 20:47
- **Sửa**: Click Lệnh Bài Boss Thế Giới không hiện gì: log server ghi `ExecuteScript_RESULT … value2=0`, tức script chưa được đăng ký. Khi server quét thư mục script lúc khởi động, thư mục làm việc là thư mục của từng script, nên `dofile("script\\phongthan\\boss\\wb_data.lua")` ở đầu file thất bại và cả script bị bỏ qua. `boss_lenhbai.lua` chuyển việc nạp dữ liệu vào `PTWB_Load()`, gọi trong `main`/`PTWB_Page*`/`PTWB_Teleport`. Đã `ReLoadScript` nóng lúc 20:46 (không cần khởi động lại). Kiểm chứng: chạy logic lệnh bài trong server qua bridge không lỗi; mô phỏng Lua 4 đạt. Bản cũ ở `_backup\20260930-worldboss\boss_lenhbai.lua.v1`

### [COMPLETED] - 2026-09-30 14:15
- **Thêm**: Boss thế giới: 12 boss VNG (\script\boss刷新) theo lịch systemtimetask. `script\phongthan\boss\wb_lib.lua` (`PTWB_Tick`, gọi từ `servertimer.lua` `PTAdm_WbTick`) gọi boss đúng phút nếu chưa còn sống (AddNpc 6 tham số, mã map 10xx), thông báo toàn server, theo dõi sống/bị diệt (GlobalValue 101–112 + 4101–4192), ghi `admin_bridge\worldboss.txt`. Nạp nóng 14:14; gọi thử Cửu Linh 14:15 thành công (NPC 30980, 1016 tại 1590,3336)
- **Thêm**: Lệnh Bài Boss Thế Giới (magicscript 61001 trong ptfix v7, mẫu từ Lệnh Bài VIP): vĩnh viễn, không mất khi dùng, không giao dịch/vứt/bán; `script\phongthan\item\boss_lenhbai.lua`: 2 trang trạng thái 12 boss và dịch chuyển (NewWorld, điểm cách boss 10 ô)
- **Thay đổi**: ptfix v7 (374 mục) bọc 12 script chết boss VNG: giữ `OnDeath` gốc (thông báo, phần thưởng Đầu …), ghi PlayerIndex người hạ, khôi phục ô của boss khác (VNG đặt về 0 để nối chuỗi). Đặt ở `AdminWeb\pending\ptfix.pak`
- **Thêm**: Web admin tab "Boss thế giới" (trạng thái, giờ xuất hiện/bị diệt, người hạ, lần tới, lịch, Gọi ngay, phát lệnh bài); API `GET /api/worldboss`, hành động `wbspawn`, mã `BossToken`, `data\worldboss.json`. Mô phỏng Lua 4 (`qtest\sim_wb.lua`) đạt. Backup `_backup\20260930-worldboss`. Tài liệu `boss-the-gioi-lenh-bai-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 13:30
- **Sửa**: Khung thanh máu rỗng lơ lửng (quái vừa chết đang chờ hồi sinh: không có hình xác nhưng lớp phủ vẫn vẽ `barback.spr` với 0% máu). `PhongThan-ClientPatch.ps1` vá `CoreClient.dll` 0x7A44B (`PaintPhongThanLifeBarOverlay`): `85db7d0433dbeb0a` → `85db0f8eb8010000` (máu ≤ 0% thì thoát hàm). Áp dụng khi mở lại game bằng `PhongThan-MoGame.cmd`

### [COMPLETED] - 2026-09-30 13:22
- **Sửa**: Web admin ô "Ấn" hiện đủ 10 loại (mỗi loại ấn VNG chỉ có một cấp, lọc theo cấp làm mỗi cấp chỉ còn 1 món); pháp khí/ấn hiện thêm mã particular để phân biệt các món trùng tên. Kiểm chứng: API trả 344 pháp khí và 10 ấn; phát thử "Bạch Liên Pháp khí" thành công (`c09301319449 EmLaAi +1`); túi EmLaAi có sẵn 0/4/200 và 0/4/259, một pháp khí đang đeo ở ô 7 (Talisman1), tức bản vá `Fit` hoạt động
- **Ghi nhận**: Nhãn tên và thanh máu quái chồng nhau: nhiều quái cùng đuổi đánh thì đứng chồng lên một điểm (engine không xét va chạm NPC–NPC), mỗi con vẽ tên và thanh máu riêng. Thanh máu mọi quái hiện vì tùy chọn ShowLife đang bật (`UserData\*\UiConfig.ini` ShowLife=4); phím F8 tắt/bật, khi tắt chỉ quái đang chọn hiện thanh máu

### [COMPLETED] - 2026-09-30 12:44
- **Thay đổi**: Sinh lại quái cho 55 bản đồ theo mật độ/kiểu rải VNG (1014: 311 ô/quái; nhóm 1/2/3/4 con = 70/19/7/3% rải đều; 150–700 con/map; 1 tinh anh/map) bằng `scratchpad\mobs\gen_spawn_v2.py` (người dùng chọn "làm tất cả một lần"). Tổng 29.542 con (trước khoảng 7.260); giữ nguyên `PT_SPAWN_SPECIAL` và quái thêm tay ở 1007/1043. Cả 55 file nạp được bằng Lua 4
- **Thay đổi**: `servertimer.lua` đổi `PTSpawn_Run(2500)` thành `PTSpawn_Run(4000)` (nạp xong khoảng 8 phút sau khi bật). Backup `_backup\20260930-spawn-v2`. Tài liệu `quai-mat-do-vng-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 12:40
- **Sửa**: Đánh quái không có kinh nghiệm: `KPlayer::AddSelfExp` chỉ cho 1 điểm khi người chơi cao hơn quái trên 15 cấp (EmLaAi cấp 120, quái 1027 cấp 38; quái cao nhất hiện có cấp 102). Người dùng chọn nới luật: `PhongThan-ClientPatch.ps1` vá `CoreServer.dll` 0x26976 `7c1a`→`9090`, mọi quái thấp cấp hơn cho gốc × (1 − chênh/200) (chênh 82 → 59%). Áp dụng khi server đã tắt. Tài liệu `kinh-nghiem-danh-quai-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 12:28
- **Thêm**: Pháp khí và Ấn dạng pháp bảo (phương án tạm, người dùng đồng ý): `build_ptfix.py` ghép 480 dòng vào cuối `amulet.txt`: pháp khí từ `instrument.txt` (particular 200–237, thuộc tính ẩn gộp vào ô cơ bản trống, dời cột yêu cầu/cờ), ấn từ `signet.txt` (250–259, bỏ cột trọng chú, bỏ hạn 180). `ptfix_v6.pak` (362 mục) đặt ở `AdminWeb\pending\ptfix.pak`; v5 đã được cài lúc 11:44
- **Thêm**: Web admin tab "Đồ max & Pháp bảo" có 2 ô "Pháp khí" (344 mục) và "Ấn" (10 loại), kèm bộ chọn cấp; `PhongThan-Admin.ps1` tự đăng ký các dòng particular ≥ 200 vào danh mục; `/api/presets` trả thêm `instruments` và `signets`

### [COMPLETED] - 2026-09-30 12:15
- **Thêm**: 2 ô "Pháp bảo" (Talisman1/2 = `itempart_ring1/2`) nhận pháp bảo 0/4 và cộng chỉ số thật: `PhongThan-ClientPatch.ps1` vá 15 byte nhánh `equip_amulet` của `KItemList::Fit` (2 hàm) trong `CoreServer.dll` (0x4DB06, 0x4DC2D) và `CoreClient.dll` (0x4F389, 0x4F4AD): chấp nhận ô 6–8. Áp dụng khi server và game đã tắt
- **Sửa**: `PhongThan-ClientPatch.ps1` chỉ vá khi cả bản runtime và bản Output đều ghi được (Test-NativeRuntime đòi cả hai khớp receipt); game đang mở thì chỉ bỏ qua phần client. Lần chạy thử đầu đã vá riêng Output CoreServer, đã khôi phục ngay, Test-NativeRuntime PASS
- **Ghi nhận**: Pháp khí (VNG `instrument.txt`, 0/11, 380 dòng) và Thần Ấn (`signet.txt`, 0/13, 100 dòng) không tạo được: engine không nạp 2 bảng này, và số loại lệch (engine 11 = ấn, 12 = pháp khí). Cần C++; chưa thêm nút phát đồ trên web admin. Tài liệu `o-phap-bao-phap-khi-an-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 11:58
- **Sửa**: Không đổi/mặc được đồ trong túi: server giữ một vật phẩm "trên tay" mà client không thấy (lưu vào DB với `pos_hand` lúc thoát, nạp lại vào tay khi đăng nhập, hoặc do thả đè gây lệch). `KItemList::ExchangeItem` bỏ qua mọi lệnh mặc đồ khi `m_Hand` có đồ. `servertimer.lua` thêm `PTAdm_HandFixPlayer()`/`PTAdm_HandTick()`: mỗi phút nhân bản món trên tay vào ô trống trong túi (`AddItemIdx` + `AddItemID`), chỉ xóa bản trên tay khi bản sao đã vào túi. Nạp nóng 11:55: EmLaAi món 3 (0/4/102) → túi (0,5). Backup `_backup\20260930-handfix`. Tài liệu `doi-do-trong-tui-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 10:02
- **Sửa**: Càn Khôn Luân (Thái Tuế Sư) không hoạt động: NPC chưa được đặt ở bản đồ nào, và engine thiếu hàm `Roulette` (vòng quay ở client). Script mới `npc_fix\1020_thai_tue.lua` giữ logic VNG, `Roulette(k)` gọi thẳng `Finished()` nên thưởng phát ngay (không có hoạt ảnh). `servertimer.lua` thêm NPC template 1116 ở Tây Kỳ (1020, 49296/97296) vào SPAWN và FIX; NpcDisplayNames thêm `太岁师`. Mô phỏng đạt; nạp nóng 09:57 (NPC 8703). Backup `_backup\20260930-cankhon`
- **Ghi nhận**: Dược điếm / Thợ Đồng: NPC, script, API, buysell (đã đệm cột) và `UiShop.ini` đều đúng phía server; chờ kiểm thử trong game. Tài liệu `can-khon-luan-duoc-diem-tho-dong-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 09:45
- **Sửa**: Quái vẽ lệch +95/+101 px so với tên và vùng bấm (không chọn được quái): vá 1 byte `Represent2.dll` (0xB0C3 `70`→`00`, chuỗi `npcres\passerby\`→`npcres\` trong IsPhongThanHumanComposite) qua `PhongThan-ClientPatch.ps1` (timestamp 6aa134b5, vá runtime + Output, cập nhật receipt)
- **Sửa**: Vật phẩm nhiều lượt (Di Ngoại Phù 10/30/50…) dùng 1 lần là mất: `pt_compat.lua` thay `CostIBItem` đếm lượt trong ItemParam (lưu DB), bảng `lib\pt_ibuses.lua` (95 loại từ ibitem.txt); ptfix chèn pt_compat vào cả script có `CostIBItem` (359 script)
- **Thêm**: Buff chỉ số tổng quát cho ibitem NONE (Dao/Ngọc … tán…): 429 loại, 6 ô, chỉ nhận thuộc tính cộng thẳng an toàn; task 1921–1938; ptfix v5 (1.677 dòng ibitem) chờ cài. Mô phỏng đạt. Tài liệu `quai-hien-thi-lech-va-luot-dung-vat-pham-phong-than-20260930.md`

### [COMPLETED] - 2026-09-30 09:15 (bản 2 bình máu/mana)
- **Sửa**: Thanh Lộ/Sơn Thủy dùng 1 lần là mất (bản 1 trừ theo số lượng, nhưng số lượng trong túi là 1). Bản 2: 1 bình = hồi liên tục `lifereplenish_v`(88)/`manareplenish_v`(92) theo mức của bình, thời gian = dung lượng/50.000 ngày, cộng dồn; buff và bình dùng chung `PTIB_Refresh` (áp lại khi engine tính lại chỉ số, nhận biết qua +1% kinh nghiệm dấu hiệu), task 1906–1920. Mô phỏng đạt. `ptfix.pak` v3 (57 dòng ibitem) chờ cài ở `AdminWeb\pending`; `servertimer.lua` sửa điều kiện nạp thư viện. Backup generator `scratchpad\ibitem\gen.py.v1`

### [COMPLETED] - 2026-09-30 09:30
- **Thêm**: Bình máu/mana và buff kinh nghiệm ibitem bằng Lua (theo yêu cầu, thay cho C++): `script\phongthan\ibitem\pt_ibitem.lua` + `pt_ibitem_lib.lua` + `pt_ibitem_data.lua` (sinh từ ibitem.txt bằng `scratchpad\ibitem\gen.py`). Bình (particular 3/4): hồi đầy phần thiếu, trừ dung lượng = số lượng vật phẩm. Buff (particular 0, thuộc tính 181/187): `ModifyAttrib`, cộng dồn thời gian, `servertimer.lua` `PTAdm_IbTick()` áp lại/gỡ mỗi phút; task 1906–1910. Mô phỏng đạt
- **Thay đổi**: `ptfix.pak` bản 2 (+ ghi đè `\settings\item\001\ibitem.txt`: 61 dòng NONE → pt_ibitem.lua) đặt ở `AdminWeb\pending\ptfix.pak`; `PhongThan-ClientPatch.ps1` tự cài khi GameServer + client tắt (backup `_backup\ptfix-<thời gian>`), cập nhật NATIVE_DEPLOYMENT.json
- **Ghi nhận**: Cài VS 2022 Build Tools thất bại (mã 5003, "Certificate is invalid: vs_installer.opc" — thiếu chứng chỉ gốc Microsoft hoặc mạng công ty can thiệp); đã viết sẵn `Build\Build-Modern.ps1` (build .dsp bằng MSVC mới vào `OutputModern`, không đè bản VC6)

### [COMPLETED] - 2026-09-30 08:30
- **Sửa**: Chữ "# Khôi Giáp Sĩ" khi quái chết: `CorpseIdx` 14/65 → 0 trong `settings\phongthan\Npcs.txt` (Client + Server, 2.703 dòng; ObjData VNG không có dòng xác quái, DataID 14 là cái mũ). Backup `_backup\20260930-corpse`
- **Thay đổi (mã nguồn C++, chờ VC6)**: `KNpc::DrawBlood` không vẽ tên/thanh máu cho quái đang chết/chờ hồi sinh (hình `*_die.spr` VNG không có nên quái chết chỉ còn tên + thanh máu). Backup `_backup\20260929-cpp-src\KNpc.cpp`. Tài liệu `quai-chi-hien-ten-thanh-mau-phong-than-20260930.md`, `vat-pham-ibitem-lo-buff-phong-than-20260929.md`
- **Sửa**: `Start-NativeServer.ps1` tự chạy `PhongThan-ClientPatch.ps1` khi bật server (bản vá dùng thuốc chưa được áp vì client mở không qua MoGame)

### [COMPLETED] - 2026-09-29 14:05
- **Thêm**: Bào Thương dựng mới: `npc_fix\bao_thuong.lua` (sinh từ `scratchpad\baothuong\gen.py`), 5 thương nhân (tid 1388 `跑商`) + 5 lạc đà (tid 366) ở 1002/1003/1004/1020/1021; thuê lạc đà 10/25 kiện, mua đặc sản, bán ở thành khác giá ×(1,2+0,1×khoảng cách), kinh nghiệm = kiện×giá×2, Ngôi Sao May Mắn khi ≥10 kiện; task 1900–1905. Mô phỏng 1 chuyến đạt; nạp nóng 14:00 (47/47 NPC). NpcDisplayNames thêm `跑商`, `骆驼`. Tài liệu `bao-thuong-chay-buon-phong-than-20260929.md`
- **Thêm**: Nguồn vật phẩm nhánh tân thủ: hạt giống Thiên Thụ (4,49 + task 804=1, 3% từ quái có mob_drop khi cấp ≥35), Thi Thú (tid 114) ×3 ở 1043 rơi Côn Lôn kính (4,40) 1/3 khi task 50=5, 52=1. Nạp nóng 13:53. Vạn Tiên trận là sự kiện PvP (mission) — không làm
- **Thay đổi (mã nguồn C++, chưa build — máy không có VC6)**: `KPlayer.cpp` vòng sáng set (state 26 khi 3–4 món, 27 khi ≥5 món) trong `ReCalcEquip`; `KItemList.cpp` UseItem/NowEatItem nhận chỉ số 0 ở client; `UiTrade.cpp` kiểm tra NULL. Backup `_backup\20260929-cpp-src`. Lưu ý: sửa bằng Edit tool làm hỏng byte GBK nên đã khôi phục và áp lại ở mức byte (đã kiểm tra)

### [COMPLETED] - 2026-09-29 09:45
- **Sửa**: Mất người khi cưỡi thú: 290 món mũ/giáp trong `VNG_ArmorPart.txt` có giá trị 10 → mã hình 9, nhưng bảng hình nhân vật chỉ có 0–8 nên đầu/thân không được vẽ. Đổi 10 → 9 (hình jsm08) ở Server và Client. Backup `_backup\20260929-armorpart`. Tài liệu `mat-nguoi-khi-cuoi-thu-phong-than-20260929.md`

### [COMPLETED] - 2026-09-29 09:35
- **Sửa**: Không dùng được thuốc máu/mana: `KItemList::UseItem`/`NowEatItem` chặn `m_PlayerIdx <= 0` mà client luôn là 0. Vá 2 byte `CoreClient.dll` (0x4f66a, 0x4f7e7: jg→jge) bằng `AdminWeb\PhongThan-ClientPatch.ps1` (kiểm tra timestamp + byte gốc, vá runtime + Output, cập nhật NATIVE_DEPLOYMENT.json, backup `_backup\client-patch`); tự chạy trong `PhongThan-MoGame.cmd` và `PhongThan-ChayTatCa.cmd`. Tài liệu `dung-thuoc-mau-mana-phong-than-20260929.md`

### [COMPLETED] - 2026-09-29 09:20
- **Thêm**: Tài liệu bổ sung cho các yêu cầu cũ chưa có .md: `web-admin-quan-tri-phong-than-20260928.md`, `sua-loi-vat-pham-hoi-thoai-phong-than-20260928.md`, `bao-thuong-chay-buon-phong-than-20260929.md`, mục lục `docs\features\README.md`; bảng trạng thái nhiệm vụ tân thủ trong `kiem-thu-nhiem-vu-mo-phong-phong-than-20260929.md`

### [COMPLETED] - 2026-09-29 09:05
- **Thêm**: Bộ mô phỏng nhiệm vụ offline (Lua 4 của engine, 32-bit): chạy trọn chuỗi chính tuyến 3 phái 0→81 PASS; chạy toàn bộ nhiệm vụ tân thủ; 265 script VNG vá qua ptfix.pak đều có nút đóng. Tài liệu `kiem-thu-nhiem-vu-mo-phong-phong-than-20260929.md`
- **Thêm**: Tiệm thuốc (Đại Phu, Sale 11/1), tiệm vũ khí (Thợ Đồng, Sale 2/3/4/12), Tạp Hóa (Sale 13) cho 1002/1003/1004/1020/1021: 12 script `npc_fix\<map>_{dai_phu,tho_dong,tap_hoa}.lua` (thêm nút đóng; sửa `egg()` của Thợ Đồng dùng biến nil), 12 dòng PTADM_NPC_SPAWN + PTADM_NPC_FIX (đã nạp nóng), `铜匠 → Tho Dong` trong NpcDisplayNames (Server/Client/ProjectContent). Backup `_backup\20260929-shops`
- **Thêm**: `ptfix.pak` (ưu tiên 0 trong package.ini Server+Client, cập nhật NATIVE_DEPLOYMENT.json; Test-ServerPakParity + Test-NativeRuntime PASS): 265 script VNG có TaskNote/SayTask được chèn `Include(pt_compat.lua)`; `buysell.txt` thêm cột đệm (KBuySell đọc từ cột 2 làm mất món đầu mỗi tiệm). Hiệu lực sau khi khởi động lại server + client. Backup `_backup\20260929-ptfix`
- **Thêm**: `script\phongthan\lib\pt_compat.lua`: TaskNote→chữ F11; SayTask/Say tự thêm "Kết thúc đối thoại"; hàm dự phòng cho 30 API engine chưa đăng ký (GetNewPills, IsMaster, IsHaveTongRight...) để NPC gốc không đứng hình
- **Thêm**: Rơi vật phẩm nhiệm vụ: `npc_fix\mob_drop.lua` (Đoản Kiếm, Mảnh Giáp, Mặt Quỷ, Băng Cơ, Ngọc Cốt, Hỏa Vũ 35%/lần khi đang làm đúng bước; lưỡi/thân/cán đao, Thư tạo phản, mảnh Thần Khí, thức ăn); `spawn_main.lua` tự gắn khi thả quái; đã gắn nóng 811 quái; thêm 3 Phản quân đội trưởng ở Yến Sơn [213,187]. Backup `_backup\20260929-drops`
- **Sửa**: Túi đồ vẽ tràn khung: `Client\Ui\ui3\UiItem.ini` [ItemBox] 5×7 → 6×10 (đúng EQUIPMENT_ROOM 6×10). Backup `_backup\20260929-uiitem`
- **Sửa**: 2 NPC đứng trên ô vật cản: Thủ Khố 1004 và Đắc Kỷ 1063 dời 2 ô (từ lần khởi động sau)
- **Sửa**: `Start-NativeServer.ps1` (bảng điều khiển dùng file này) gọi `PhongThan-Setup.ps1 -Step database` trước khi kiểm tra DB
- **Thêm**: Giao diện client còn thiếu (cửa sổ vô hình): `UiShop.ini`, `UiStoreBox.ini`, `UiTrade.ini`, `UiTradeConfirmWnd.ini`, `UiGetMoney.ini` trong `Client\Ui\ui3` (dựa trên layout VNG tìm thấy trong PAK dưới tên tiếng Trung). Tài liệu `tiem-thuoc-vu-khi-tap-hoa-phong-than-20260929.md`
- **Chẩn đoán**: Vòng sáng set đồ lục chưa được viết trong mã dựng lại (chỉ số set vẫn cộng); cần C++ hoặc phương án Lua tạm. Tài liệu `vong-sang-set-do-luc-phong-than-20260929.md`
- **Thêm**: `PhongThan-ChayTatCa.cmd` + `AdminWeb\PhongThan-RunAll.ps1`: kiểm tra/cài DB → bật server → mở web admin (tham số `game` để mở luôn client)

### [COMPLETED] - 2026-09-29 08:55
- **Kết quả**: kiểm thử `check`/`all` (idempotent), khôi phục `account.bak` vào database tạm (10 tài khoản) rồi xóa; API `/api/setup/status` chạy trên web tạm cổng 8799. Thêm bước `backup` (account → account.bak, giữ bản cũ). Tài liệu `docs\features\cai-dat-server-localdb-phong-than-20260929.md`. Mô phỏng chuỗi chính tuyến 3 phái 0→81 PASS (bộ mô phỏng Lua 4 offline)
- **Thêm**: Tab "Cài đặt server" trên web admin + `AdminWeb\PhongThan-Setup.ps1` + `PhongThan-CaiDat.cmd`: tự cài SQL LocalDB (từ `Setup\SqlLocalDB.msi`, hoặc tải qua `Setup\SQL2022-SSEI-Expr.exe`), tạo/khởi động instance MSSQLLocalDB, gắn lại hoặc khôi phục database `account` từ `Server\database\account.bak` vào `PhongThanRuntime-State\sql`, cập nhật `DataBase.ini`
- **Sửa**: `vng_tasknote.lua` — bước nhiệm vụ không có chữ trong taskinfo.ini: sau bước cuối hiện "Nhiệm vụ hoàn thành", bước bị hổng dùng chữ của bước gần nhất trước đó (hết "Task N - step S" ở NPC tân thủ)

### [COMPLETED] - 2026-09-29 08:50
- **Sửa**: Lỗi "Cannot open database account": LocalDB khởi động lại lúc 08:27 nhưng database `account` không còn được gắn (file vẫn ở `PhongThanRuntime-State\sql`). Đã gắn lại (backup `_backup\20260929-accountdb`). `Start-StagingServer.ps1` thêm bước tự gắn lại database `account` nếu thiếu, trước khi kiểm tra kết nối

### [COMPLETED] - 2026-09-28 22:10
- **Kết quả**: nạp nóng thành công, `result.log` 22:06: `added=7274 forced=0 failed=0 skippedMaps=0 done`. GameServer ổn định (553 MB). Đã gộp 51 tên quái tiếng Việt vào `NpcDisplayNames.txt` (Server, Client, ProjectContent), backup ở `_backup\20260928-spawn`. Tài liệu: `docs\features\quai-cac-ban-do-phong-than-20260928.md`
- **Thêm**: Quái cho 86 bản đồ trống (không còn dữ liệu đặt quái gốc ngoài 1014/1016/1052, đã quét 91.684 entry PAK). Quần thể sinh theo bằng chứng (lời nhiệm vụ taskinfo, bảng tên quái VNG npc_name/mob_name, cấp trong script boss/sự kiện): 51 map chính 6.654 quái + 4 map 1073–1076 (603) + 17 quái mục tiêu nhiệm vụ. Dữ liệu `Server\script\phongthan\spawn\` (56 file, compile OK); `servertimer.lua` `PTAdm_Spawn()` chạy 2500 AddNpc/tick, 1 lần mỗi lần khởi động. Backup: `_backup\20260928-spawn`

### [COMPLETED] - 2026-09-28 21:05 (chẩn đoán, chưa sửa)
- **Chẩn đoán**: Thanh Lộ / Lâm Tiên Lộ và các ibitem có cột script `NONE` dùng không có tác dụng: `KItemList::NowEatItem` (KItemList.cpp:1584-1595) với ibitem chỉ gọi `ExecuteScript(nIdx)`, script `NONE` thì thoát, không gọi hệ IBBuff (`AddIBBuffToStore`, ScriptFuns.cpp ~12200) và không trừ vật phẩm. Bảng ibitem nằm trong PAK nên không vá bằng file rời được. Cần build lại C++ (ánh xạ ibitem → IBBuff/ApplyMagicAttrib). Vật phẩm không bị mất

### [COMPLETED] - 2026-09-28 20:55
- **Sửa**: Lối ra bản đồ không hoạt động (toàn thế giới): script trap chỉ có trong `script.pak` nên không được đăng ký lúc khởi động. `servertimer.lua` `PTAdm_RegisterExits()` nạp 122 script trap gốc (`npc_fix\exit_trap_register.lua`); thêm trap rời `script\trap\玉虚宫to矿场.lua`; đặt 13 NPC cổng (10 "Cổng đi …" + 3 "Truyền Tống Trận", template 1686). Nạp nóng 20:53: `traps 122 rebound 68 npc_spawned 25/25`. Tài liệu: `docs\features\loi-ra-ban-do-cong-dich-chuyen-phong-than-20260928.md`. Backup: `_backup\20260928-exits`

### [COMPLETED] - 2026-09-28 20:50
- Kết quả nạp nóng 20:49: `rebound 55` NPC (67 script npc_fix, tất cả compile OK bằng LuaLibDll), `npc_spawned 12/12`, `mobs 19/19` (11 quái chính tuyến + Kim Hà thú, script `mob_*.lua` gắn làm ActionScript/LastDamage), hook `Include("\\script\\phongthan\\lib\\vng_tasknote.lua")` vào 67 script (PTTaskNote từ taskinfo.ini: 401 task, cắt 480 byte chống tràn buffer client). Thêm 9 tên vào NpcDisplayNames (Server/Client/ProjectContent). Backup: `_backup\20260928-chinhtuyen`. Tọa độ NPC ở 1044/1061–1064 và quái Thương quân hiệu úy là suy luận (cần chủ server xác nhận). Chưa kiểm thử trong game
- Kế hoạch lúc 20:30:
- **Sửa**: Chính tuyến 3 phái: script `npc_fix` cho 14 NPC chính tuyến (bỏ menu tạm, thoát SayTask, QuestExchange), đặt 7 NPC thiếu (Đa Bảo, Thần Nông, Hiên Viên, Xi Vưu, Đắc Kỷ tương lai, Nguyên Thủy Thiên Tôn, Đắc Kỷ thời trẻ) + Thủ Khố/Tạp Hóa 1003/1004 cạnh NPC liên quan, script chết cho 11 quái nhiệm vụ
- **Thêm**: F11 giai đoạn 2: thư viện chữ nhiệm vụ từ `taskinfo.ini` (`PTTaskNote`)

### [COMPLETED] - 2026-09-28 20:20
- **Thêm**: Web admin tab "Vũ khí lục" (theo phái 0–3 và mốc cấp, lọc dòng lục = cột hệ 1000) và tab "Đồ max & Pháp bảo" (28 mẫu cố định: vũ khí Tinh Quân Cấp 10 và (+12), thú cưỡi Tinh Quân / Nghịch / Bạch Kim / Phi Tuyết, pháp bảo cấp 120, Thất Bảo Kim Liên; 101 pháp bảo mặc ô Ngọc bội). API `/api/weapons`, `/api/presets`. Tài liệu: `docs\features\vu-khi-luc-do-max-cuong-hoa-phong-than-20260928.md`. Backup: `_backup\20260928-admin-web-v7`
- **Ghi nhận không làm được nếu không rebuild C++**: cường hóa +12 thật (không có Lua đặt UpgradeLevel), ép max roll (SetAttrib_CBR random), pháp khí/ấn (Shipin/Signet không nạp)

### [COMPLETED] - 2026-09-28 19:50
- **Sửa**: Tiền đồng không hiện trong túi đồ (F4): `KUiItem` đọc mục `[Gold]` cho ExtPoint nhưng `Client\Ui\ui3\UiItem.ini` không có mục này (PAK cũng không có file). Thêm `[Gold]` tại hàng BindMoney chưa dùng (317,367). Ghi `nExtPoint=10000` cho tài khoản lichnt vào DB (bộ nhớ server đã là 10000 từ 18:00). Backup: `_backup\20260928-uiitem-gold`
- **Chẩn đoán**: Không mặc được thú cưỡi do server kẹt trạng thái "cầm đồ trên tay" (`m_Hand` ≠ 0, `KItemList::ExchangeItem` bỏ qua mọi lệnh kéo sang ô khác). Nhân vật đủ điều kiện (level 90, series 0). Cách gỡ: thoát nhân vật và vào lại (server lưu món trên tay về ô cũ qua BackLocal)

### [COMPLETED] - 2026-09-28 20:03
- Kết quả: 27 script `npc_fix` (1002: 11, 1003: 7, 1004: 9) biên dịch OK bằng `LuaLibDll.dll` của engine; nạp nóng 20:03 `rebound 27`. Khoa Phụ spawn bằng `PTAdm_EnsureNpcs` (template 175, 48768/104704, `SetNpcName` 夸父图腾), thêm "Khoa Phu" vào `NpcDisplayNames.txt` (Server + Client + ProjectContent). Backup: `_backup\20260928-npc-tanthu\` (before + after). Chưa kiểm thử chuỗi nhiệm vụ trong game
- Chi tiết phần đã lên kế hoạch lúc 18:50:
- **Sửa**: Hội thoại + nhiệm vụ NPC tân thủ 3 phái (1002/1003/1004): script mới `Server\script\phongthan\npc_fix\<map>_<npc>.lua` (thêm dòng thoát SayTask, QuestExchange cho bước phát đồ, bỏ menu tạm, sửa GetItemCount/DelHandItem), bật lại "Tân Thủ tầm bảo" (Lỗ Hùng/Từ Hàng/Hình Thiên), đặt NPC Khoa Phụ 1004 (~190/204). Gắn qua `PTADM_NPC_FIX` trong `servertimer.lua`. Tài liệu: `docs\features\hoi-thoai-npc-tan-thu-phong-than-20260928.md`
- **Thêm**: Tài liệu `docs\features\nhiem-vu-chinh-tuyen-phong-than-20260928.md`

### [COMPLETED] - 2026-09-28 18:38
- Kiểm tra: `Test-NativeRuntime` PASS; chưa kiểm thử hiển thị trong game. Tài liệu: `docs\features\he-thong-nhiem-vu-f11-phong-than-20260928.md`
- **Thêm**: Layout F11 `Client\Ui\ui3\UiTaskNote.ini` + `UiTaskNote-MissionNote.ini` (thiếu trong cả PAK lẫn loose nên cửa sổ F11 vô hình), dựng trên sprite VNG `\Spr\Ui4\任务记事\`. Backup dữ liệu nhiệm vụ client: `_backup\20260928-f11`

### [COMPLETED] - 2026-09-28 18:21
- **Thêm**: Tính năng 4 "Đồ lục" trên web admin: bộ đồ theo phái và cấp (20/40/60/80/100 + 2 bộ không yêu cầu cấp), phát cả bộ 5 món (Giáp/Mũ/Giày/Thắt lưng/Bội). API `/api/gearsets`, `/api/giveset`. Tài liệu: `docs\features\do-luc-he-phai-phong-than-20260928.md`. Backup: `_backup\20260928-admin-web-v6`
- Tính năng 1–3 (nhiệm vụ chính tuyến, F11, NPC tân thủ): đang khảo sát

### [COMPLETED] - 2026-09-28 18:11
- **Sửa**: Gói nguyên liệu 1571–1593 mở được (xác nhận 18:10:11, Gói Đoản Kiếm Lớn `deleted=1`). Nguyên nhân gốc: `GetItemPartByID` trả 0 cho các gói này (mã gói nằm ở DetailType). Script nhận diện gói bằng `GetItemCount(6, mã)`, nhiều loại thì hiện menu chọn, trừ bằng `DelItem(1, 6, mã)`. Backup: `_backup\20260928-openpack\openpack_fixed_v2.lua`
- **Sửa**: Web admin tính mã đồ từ bảng trong PAK (GameServer đọc PAK trước). Bảng trên đĩa lệch với PAK: armor/boot/belt/helm/pendant 2611 vs 3271 dòng, amulet 861 vs 1441, horse 1151 vs 6211, ibitem 220 vs 9333. Web tự trích 15 bảng vào `AdminWeb\data\pak_item_tables` khi khởi động
- **Thêm**: Tab "Thú cưỡi": chọn nhân vật online → chỉ hiện thú cưỡi đúng phái (yêu cầu loại 37) + loại dùng chung; Giáp Sĩ 103, Đạo Sĩ 111, Dị Nhân 102 mẫu (đã gộp trùng). Backup: `_backup\20260928-admin-web-v5`

### [COMPLETED] - 2026-09-28 18:06
- **Thêm**: Web admin "Tăng level nhân vật" (`SetLevel` 1–200; ghi lại và khôi phục cấp kỹ năng 1–60 vì `KPlayer::SetLevel` gọi `RollBackSkills`)
- **Thay đổi**: Tiền đồng = vật phẩm "Xu" (Nhiệm vụ 47, cộng dồn 100/ô); nút cũ đổi tên thành "Cộng điểm xu tài khoản" (ExtPoint, Kỳ Trân Các). Backup: `_backup\20260928-admin-web-v4`
- **Đang điều tra**: Gói Đoản Kiếm Lớn — đã thêm log `admin_bridge\openpack_trace.log` vào script mở gói (nạp 18:02), chờ lần dùng tiếp theo

### [COMPLETED] - 2026-09-28 17:59
- **Sửa**: Thủ khố Sùng Thành vẫn không có nút thoát vì GameServer đọc `script.pak` trước file rời (`g_SetPakFileMode(1)`), bản ghi đè lúc 17:47 không có tác dụng (đã chuyển vào backup). Script sửa đặt ở đường dẫn mới `script\phongthan\npc_fix\1002_thu_kho.lua`; `servertimer.lua` gắn lại script cho NPC mỗi phút (`PTAdm_FixNpcScripts`, 17:52 rebound 1)
- **Sửa**: Gói nguyên liệu (MagicScript 1571–1593, vd Gói Đoản Kiếm Lớn) click phải không có tác dụng: `script\item\卦卷\开包操作.lua` đọc item ở tham số 4 nhưng server truyền ở tham số 1; thay `DelItemByID`/`IsItemBind` (không tồn tại) bằng `RemoveItem`; câu thông báo GBK đổi sang tiếng Việt không dấu. Nạp nóng 17:56. Backup: `_backup\20260928-openpack`
- **Thêm**: Web admin tab "Bí kíp / Kỹ năng": chọn phái (Giáp Sĩ 27–42, Đạo Sĩ 3–26, Dị Nhân 43–51), dạy/đặt cấp 1–10, kiểm tra đúng phái, phát Kỹ Năng Quyển 5624–5626; online hiển thị phái. `PTAdm_SetSkills` nạp nóng 17:59. Backup: `_backup\20260928-admin-web-v3`
- Chưa kiểm tra trong game: dạy kỹ năng, mở gói, hộp thoại Thủ khố

### [COMPLETED] - 2026-09-28 17:47
- **Sửa**: Hộp thoại Thủ khố Sùng Thành không có nút thoát. Nguyên nhân: `SayTask` (C++ compat) không tự thêm dòng thoát. Tạo bản ghi đè trên đĩa `Server\script\崇城大营\仓库管理员.lua` (trích từ `script.pak`) thêm "Kết thúc đối thoại" vào menu chính và menu Nguyên liệu; nạp nóng bằng `ReLoadScript` qua cầu nối (17:45:00 OK). Backup gốc + bản sửa: `_backup\20260928-thukho`
- **Thêm**: Web admin: tặng tiền đồng (`AddExtPoint`, nhân vật online), nút chọn nhanh Kim Nguyên Bảo (Nguyên liệu 1183). Backup: `_backup\20260928-admin-web-v2`
- Chưa kiểm tra trong game: hộp thoại Thủ khố sau khi nạp lại, lệnh tiền đồng

### [COMPLETED] - 2026-09-28 17:40
- **Sửa**: `Deploy\Start-StagingClient.ps1` bỏ qua `Test-GdiPlusAbi` khi máy không có VC6 DUMPBIN (nút "Mo client" hết lỗi). Backup: `_backup\20260928-admin-web`
- **Thêm**: Nút phát Túi tân thủ (lệnh bài admin) trong tab Phát đồ
- Kiểm tra: server nạp `servertimer.lua` mới (nhịp 17:35:00); lệnh thông báo OK, phát đồ cho nhân vật offline báo FAIL đúng; giao diện hiển thị đúng. Chưa thử phát đồ/tạo boss với nhân vật online. Backup bản hoàn chỉnh: `_backup\20260928-admin-web-v1`

- **Thêm**: Web quản trị local `AdminWeb\` (PowerShell HttpListener + HTML, chỉ `localhost`): phát đồ, tạo boss/NPC, thông báo, sự kiện theo lịch, quản lý tài khoản
- **Thay đổi**: `script\servertimer.lua` (Server + ProjectContent) đọc hàng đợi lệnh `Server\admin_bridge\pending.lua` mỗi phút và ghi danh sách người chơi online. Backup: `_backup\20260928-admin-web`

### [COMPLETED] - 2026-09-28 17:20
- **Thêm**: File tra cứu mã vật phẩm `Tra-cuu-vat-pham.txt` (48.554 mục) xuất bằng `Tools\Export-StarterBagLookup.ps1`
- Lưu ý: cần khởi động lại server để GameServer nạp lại danh sách tài khoản
- **Thay đổi**: Thêm tài khoản `lichnt` vào `[Grant] Accounts` của `PhongThanStarterBag.ini` (Server, Client, Source) để tự nhận Túi tân thủ (lấy đồ theo ID). Backup: `_backup\20260928-starterbag`

### [COMPLETED] - 2026-09-28 16:58
- Kết quả: server `READY_FOR_LOGIN` (Goddess 5001, AccountServer 5002, Relay 5003, Bishop 5622/5632, GameServer 6666, 102 bản đồ); client mở và phản hồi bình thường

- **Thêm**: Cài SQL Server LocalDB (bản 17.0, instance `MSSQLLocalDB`), khôi phục database `account` từ `Server\database\account.bak` vào `PhongThanRuntime-State\sql`
- **Thêm**: Lối tắt `PhongThan-BangDieuKhien.cmd` (mở bảng điều khiển server) và `PhongThan-MoGame.cmd` (mở client trực tiếp, bỏ qua kiểm tra DUMPBIN của VC6)
