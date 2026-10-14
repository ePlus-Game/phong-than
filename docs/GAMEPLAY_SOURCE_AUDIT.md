# Đối chiếu cẩm nang với source — 14/10/2026

> **Trạng thái sau [PR #70](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/70): lỗi EXP/int32 đã được sửa trong code và qua native test/build Windows, nhưng gameplay tại cấp 200 chưa nghiệm thu. Theo dõi runtime tại [Issue #71](https://github.com/ePlus-Game/phong-than-truyen-ky/issues/71) và [test matrix](RUNTIME_GAMEPLAY_ACCEPTANCE.md).**
>
> **Bằng chứng theo đường dẫn source, không đồng nhất với gameplay đã nghiệm thu.** Phân loại: **CODE** (đọc hàm/bảng trực tiếp), **PROJECT-DOC** (tài liệu kỹ thuật dự án, chưa thực thi lại), **VNG-ONLY** (web/cẩm nang bản gốc), **UNVERIFIED** (chưa khẳng định được từ code), **RISK** (đường đi có khả năng lỗi). Mọi dữ liệu gốc và binary/PAK vẫn giữ nguyên.

## Ma trận kiểm tra

| Khẳng định trong cẩm nang | Kết quả | Bằng chứng/hướng xử lý |
| --- | --- | --- |
| Ba hệ phái Giáp Sĩ, Đạo Sĩ, Dị Nhân | **CODE**: 3 ID `0=Giáp Sĩ`, `1=Đạo Sĩ`, `2=Dị Nhân`; chưa test UI tạo nhân vật | [`KProfession.cpp`](../PhongThanSource/Sources/Core/Src/KProfession.cpp) dòng 6–29 khai báo `giapsi`, `daosi`, `dinhan` và ánh xạ ID theo thứ tự; [`KProfession.h`](../PhongThanSource/Sources/Core/Src/KProfession.h) dòng 6–19 xác nhận registry riêng |
| Giới hạn nhân vật | **CODE + FIXED:** MAX_LEVEL=200; EXP 131+ đã xử lý tương thích int32; runtime chưa nghiệm thu | `GameDataDef.h:74`; [PR #70](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/70) sửa loader và cộng EXP; [test C++ #38564658247](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38564658247) PASS |
| Danh sách kỹ năng và build 3 hệ phái | **CODE + UNVERIFIED**: đã tìm bảng skill, chưa chứng minh build/cấp học theo nghề | `PhongThanRuntime-Staging/Server/settings/Skills.txt`: 99 cột, 2.703 dòng dữ liệu, có `SkillId`, `SkillName`, `CharClass`, `ReqLevel`, `MaxLevel`; `KPlayer.cpp` dòng 4708 giới hạn tăng skill theo cấp nhân vật và cấp yêu cầu |
| Chín nhóm trang bị, tên bộ và món mạnh nhất | **UNVERIFIED** với bản phục dựng | Nguồn VNG phân biệt Lục/Cam/Hoàng Kim/Tiên Ma, nhưng chưa đối chiếu item table và slot/server gating |
| Nhiệm vụ Hộp Gấm của Tô Hộ | **PROJECT-DOC** có code nhiệm vụ và test Lua 4 | [NPC_QUEST_FOUNDATION_HANDOFF.md](../PhongThanSource/Docs/NPC_QUEST_FOUNDATION_HANDOFF.md) nêu QuestExchange và kiểm thử 5 chuỗi / 24 ca / 1.112 assertions; chưa test client/server E2E |
| 126 NPC phục dựng | **PROJECT-DOC** | [NPC_AUTHORED_126_RESULT.md](../PhongThanSource/Docs/NPC_AUTHORED_126_RESULT.md): 125/126 đặt được; 84 NPC mới chỉ hướng dẫn, 42 có nhánh Lua gốc; không gọi 126 nhiệm vụ đã hoàn thành |
| Hệ thống Linh Thú: 8 loại, 4 giai đoạn, cấp 40 | **CODE** | Server/script/phongthan/sinhhoat/sh_lib.lua: dòng 311–320, 334–385; lt_npc.lua: dòng 1–11, 124–175 |
| Linh Thú đầu tiên miễn phí | **CODE** | lt_npc.lua: dòng 69–81, có PTLT_FirstMenu/PTLT_First |
| Đổi trứng Linh Thú | **CODE** | sh_lib.lua: dòng 330–332 và lt_npc.lua: dòng 84–109; 20 Linh Thú Đơn + 100.000 lượng |
| Nâng Linh Thú giai đoạn 1→2→3→4 | **CODE** | lt_npc.lua: dòng 9–11, 117–175, phí 50.000 / 200.000 / 500.000 lượng |
| Hệ kỹ năng sinh hoạt | **CODE** | sh_lib.lua: dòng 9–10, 46–50, 249–276; Hái thuốc/Khai khoáng/Câu cá/Luyện đan/Hóa trù; cấp thường 9, mở 10 sau Tôn Sư |
| 7 ngày đăng nhập nhận quà | **CODE** (cấu hình mặc định) | content/dg_lib.lua: dòng 1–36; mặc định 20.000 lượng/ngày, thưởng chu kỳ 7 ngày 200.000; admin config có thể ghi đè |
| Chế tạo/hợp thành cơ bản | **CODE + PROJECT-DOC** | Sources/Core/Src/PhongThanComposeRecipe.h: bảng 19 cột và điều kiện công thức cơ bản nhóm 1/loại 6/xác suất 100%; tài liệu nền ghi 30 công thức, nhưng chưa kiểm thử tương tác với người chơi |

## Phát hiện về cấp nhân vật [CODE + RISK]

- `PhongThanSource/Sources/Core/Src/GameDataDef.h:74`: `#define MAX_LEVEL 200`.
- `KPlayer.cpp:2994,3063,3084`: tăng cấp kiểm tra `m_Level < MAX_LEVEL` và chặn ở trần 200; `KPlayer.cpp:4513` cũng không chấp nhận đặt cấp vượt 200.
- `CoreUseNameDef.h:65`: đường dẫn bảng EXP `\\settings\\npc\\player\\level_exp.txt`. Bản Server/Client có cùng Git blob SHA `e513c4ff0d65fe3246365143be89642bcc986b20`, chứa **200 dòng**, level 1 đến 200.
- Dòng **131–200** có mức EXP `5300556000` mỗi dòng; cấp 130 là `496166400`. Con số **5.300.556.000 > 2.147.483.647**.
- **Trước PR #70**, `KPlayerSet.cpp` đọc EXP qua `KTabFile::GetInteger`/`atoi` vào mảng `int` và có rủi ro tràn. **Sau PR #70**, loader dùng `PhongThanParseBaseLevelExp` xử lý riêng placeholder vượt int32 và kiểm tra EXP chuyển sinh, `KPlayer.cpp` dùng số 64-bit trung gian trước khi lưu int32. Cả hai file dữ liệu EXP gốc không đổi. [Issue #68](https://github.com/ePlus-Game/phong-than-truyen-ky/issues/68) **closed / code fixed**; nghiệm thu thực tế tại [#71](https://github.com/ePlus-Game/phong-than-truyen-ky/issues/71).

Cần tránh nhầm `MAX_SERIES = 5` (ngũ hành Kim/Mộc/Thủy/Hỏa/Thổ, `level_add.txt`) với **ba hệ phái** (Giáp Sĩ/Đạo Sĩ/Dị Nhân): bảng ngũ hành không phải mapping class.


## Đối chiếu sâu mã nghề, giới hạn cấp và skill table

**Hệ phái từ C++ [CODE]:** `PhongThanSource/Sources/Core/Src/KProfession.cpp:8–23` khai báo mảng nghề theo thứ tự `giapsi`, `daosi`, `dinhan`; ID gán bằng chỉ số mảng `i`. Tức **0 = Giáp Sĩ, 1 = Đạo Sĩ, 2 = Dị Nhân**. `KProfession.h` ghi rõ registry code-owned, không phụ thuộc `faction.ini`.

**Giới hạn nhân vật [CODE]:** `PhongThanSource/Sources/Core/Src/GameDataDef.h:74` đặt `#define MAX_LEVEL 200`. `KPlayer.cpp:3081–3087` chặn `LevelUp()` tại `>= MAX_LEVEL`; `KPlayer.cpp:4513` từ chối `SetLevel` vượt quá 200. Cấp 200 là **cap khai báo trong source**, chưa chứng minh đạt được khi chạy game.

**EXP [SOURCE + FIXED / RUNTIME OPEN]:** Bản dữ liệu gốc Server/Client vẫn có 200 dòng và placeholder `5.300.556.000` tại cấp 131–200. [PR #70](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/70) đã bổ sung `PhongThanExpCompat.h` và sửa `KPlayerSet.cpp`, `KPlayer.cpp` để đọc an toàn trong miền int32; tại runtime, cấp 131 dùng `530.055.600` EXP, cấp 200 dùng `2.030.805.600` EXP. Các mốc cấp 1–130 giữ nguyên; đây là chính sách tương thích của dự án, **không phải EXP chính thức VNG**. Đã PASS native test trên 200 hàng dữ liệu hai bên và build Windows x86; chưa test cấp 131/200 bằng nhân vật thật trong VM (xem [#71](https://github.com/ePlus-Game/phong-than-truyen-ky/issues/71)).

**Điểm cấp [CODE]:** `KPlayer.cpp:71–73` khai báo tăng **5 điểm thuộc tính** và **1 điểm kỹ năng** mỗi lần lên cấp; `LevelUp()` cập nhật các điểm này. Không đồng nghĩa có thể khuyên tỷ lệ cộng điểm cụ thể từng nghề.

**Skill table [CODE]:** `PhongThanRuntime-Staging/Server/settings/Skills.txt` có 99 cột và 2.703 hàng; trong đó cột `SkillId`, `SkillName`, `CharClass`, `ReqLevel`, `MaxLevel`. `CharClass` xuất hiện giá trị 0/1/3 nhưng **chưa xác nhận cách giải nghĩa field này**, không được lấy trực tiếp làm ID nghề Giáp Sĩ/Đạo Sĩ/Dị Nhân. Bảng có thể chứa kỹ năng cũ, phụ trợ hoặc không khả dụng, nên 2.703 hàng **không phải 2.703 kỹ năng đang dùng được**.

## Bảng kỹ năng gốc trong code [CODE, chưa nghiệm thu gameplay]

- `PhongThanRuntime-Staging/Server/settings/Skills.txt` và bản Client: cùng SHA `fbb351d766baf9772afe6721821828d26e27b11c`.
- Có **2.703 dòng với SkillId số hợp lệ** trên **99 cột**. Các cột gồm `SkillName`, `SkillId`, `Attrib`, `SkillStyle`, `CharClass`, `SkillCostType`, `CostValue`, `TimePerCast`, v.v.
- Các giá trị `CharClass`: **0 (2.618), 1 (14), 3 (71)**. **KHÔNG tự gán CharClass thành Giáp Sĩ/Đạo Sĩ/Dị Nhân** nếu chưa đọc rõ logic ánh xạ. Bảng còn có kỹ năng NPC, biến thể và kỹ năng theo level.
- Tên gốc chứa văn bản mã hóa legacy; muốn làm cẩm nang phải giải mã đúng TCVN3/GB18030, loại bỏ kỹ năng NPC, xác nhận cấp học, sở hữu và hiệu lực của skill.
- Các kỹ năng sinh hoạt trong `sh_lib.lua` (5 nghề, cap 9/10) **khác** hệ thống kỹ năng chiến đấu `Skills.txt` và giới hạn cấp nhân vật.

## GitHub Actions audit thực thi

- PR [#67](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/67), [run #38557516369](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38557516369): **PASS**.
- Đã quét tĩnh **3.116 file** từ source và settings (865 file GB18030, 1.927 UTF-8, 315 CP1252, 9 file thay ký tự lỗi).
- Tự động xác nhận: `MAX_LEVEL=200`, bảng EXP **200 dòng**, **server/client giống nhau**, **giá trị vượt int32 bắt đầu ở cấp 131**.
- Đây là kết quả đối chiếu code/data, **không phải kiểm thử gameplay hoặc toàn bộ source**.

## Bảng Linh Thú từ Lua

| Linh Thú | NPC template theo 4 giai đoạn |
| --- | --- |
| Hồ Hỷ Mị | 2486, 2487, 2488, 2489 |
| Na Tra | 2490, 2491, 2492, 2493 |
| Lôi Chấn Tử | 2510, 2511, 2512, 2513 |
| Thạch Cơ | 2515, 2516, 2517, 2518 |
| Thái Ất | 2520, 2521, 2522, 2523 |
| Đắc Kỷ | 2525, 2526, 2527, 2528 |
| Thân Công Báo | 2529, 2530, 2531, 2532 |
| Hoàng Phi Hổ | 2533, 2534, 2535, 2536 |

Mỗi loài có bốn mốc tối đa cấp 10/20/30/40; kinh nghiệm Linh Thú dùng hàm PTLT_Need(lv) = 10 + 2*lv (không phải bảng EXP nhân vật). Cho ăn một Linh Thú Đơn +30 EXP. Tất cả là luật Lua, chưa có bằng chứng client test hiện tại.

### Nguyên liệu tiến hóa theo Lua

| Bước | Điều kiện cấp | Mỗi nhóm nguyên liệu | Vật liệu đặc biệt | Lượng |
| --- | --- | --- | --- | ---: |
| Giai đoạn 1→2 | 10 | 10 tinh hoa thảo dược + 10 thịt cá cấp 1–3 | Không | 50.000 |
| Giai đoạn 2→3 | 20 | 10 tinh hoa + 10 thịt cá cấp 4–6 | 1 Mảnh Hoàng thủy tinh (item genre/detail/part 3/88/0) | 200.000 |
| Giai đoạn 3→4 | 30 | 10 tinh hoa + 10 thịt cá cấp 7–10 | 1 Hoàng thủy tinh (item 3/89/0) | 500.000 |

**RISK:** lt_npc.lua: dòng 74–81 thay đổi trạng thái sở hữu trước khi chắc chắn đã cấp Linh Thú Lệnh; dòng 104–109 thu tiền rồi cấp trứng nhưng không kiểm tra kết quả PTSH_Give. Cơ chế bù vật liệu có thể thất bại khi túi đồ không đủ chỗ. Không khuyến khích dùng vật phẩm giá trị trên server thật. Xem [REWARDS_AND_PETS.md](REWARDS_AND_PETS.md).

## Những chỗ cần sửa trong tài liệu tân thủ

1. **Cap được khai báo trong code là 200**; bảng gốc có placeholder vượt int32 từ cấp 131, nhưng PR #70 đã sửa ở runtime loader. Còn cần nghiệm thu EXP, chuyển sinh và relogin trên Windows VM.
2. Không gọi trang bị Lục/Cam/VNG là trang bị cuối game của bản phục dựng khi chưa tra item ID và drop/công thức.
3. Phân biệt thú cưỡi, đệ tử của Dị Nhân và 8 Linh Thú custom — ba hệ thống khác nhau.
4. Không nhầm giới hạn 40 của Linh Thú với cấp nhân vật.
5. Nhiệm vụ bản VNG phải giữ nhãn **tham khảo**, không tuyên bố đã hoàn thành hay rơi đúng phần thưởng ở server hiện tại.

## Kiểm kê các bảng mã hóa cũ

Bảng cấp EXP, item, kỹ năng ở thư mục settings có thể dùng mã hóa GBK/CP936, khiến trình đọc UTF-8 thông thường không hiển thị được. Đã bổ sung [tools/gameplay_code_audit.py](../tools/gameplay_code_audit.py) và workflow [gameplay-code-audit.yml](../.github/workflows/gameplay-code-audit.yml) để quét tĩnh từ GitHub Actions bằng sparse checkout và giải mã GB18030; xuất đường dẫn, số dòng, đối tượng nghi vấn về class/EXP/skill/item/quest. **Kết quả quét chỉ là ứng viên**, phải tự đối chiếu logic thực thi trước khi điền con số hoặc hướng dẫn build.

### Chưa có bằng chứng để kết luận

- **Đã tìm được** ID `0/1/2` của ba hệ phái từ `KProfession.cpp`; còn phải kiểm tra màn hình chọn nhân vật và luồng nhận ID qua server.
- Khả năng **đạt cấp 200 thực tế** sau bản vá EXP int32 và độ an toàn khi chuyển sinh, save/load/relogin trên Windows VM.
- Danh sách skill ID/cấp học/tác dụng, phân bổ Sức mạnh/Thể lực/Trí lực theo PvE/PvP.
- Tên, ID, thuộc tính và thứ hạng của toàn bộ trang bị trong bản phục dựng.
- Quy trình chơi được từ cấp 1 đến cuối game, quái/boss và tỷ lệ rơi đồ.
- Tính tương thích giữa Lua runtime, PAK đóng gói, bảng settings client/server.

**Nguyên tắc nghiệm thu:** SOURCE → cấu hình thực sự được nạp → unit/integration test → gameplay client/server → cẩm nang khẳng định.
