# Đối chiếu cẩm nang với source — 14/10/2026

> **Bằng chứng theo đường dẫn source, không đồng nhất với gameplay đã nghiệm thu.** Phân loại: **CODE** (đọc hàm/bảng trực tiếp), **PROJECT-DOC** (tài liệu kỹ thuật dự án, chưa thực thi lại), **VNG-ONLY** (web/cẩm nang bản gốc), **UNVERIFIED** (chưa khẳng định được từ code), **RISK** (đường đi có khả năng lỗi). Mọi dữ liệu gốc và binary/PAK vẫn giữ nguyên.

## Ma trận kiểm tra

| Khẳng định trong cẩm nang | Kết quả | Bằng chứng/hướng xử lý |
| --- | --- | --- |
| Ba hệ phái Giáp Sĩ, Đạo Sĩ, Dị Nhân | **VNG-ONLY**; chưa đối chiếu class ID/client selection | [Cẩm nang VNG](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-giap-si.html) và [cẩm nang hệ phái](PLAYER_HANDBOOK.md); cần source class definitions/character creator |
| Giới hạn nhân vật 150 hay 200 | **UNVERIFIED** | Chưa có dòng code/bảng EXP chứng minh; tài liệu VNG về chuyển sinh không đủ xác nhận bản phục dựng |
| Danh sách kỹ năng và build 3 hệ phái | **UNVERIFIED** | Tài liệu dự án nêu đã nạp 104 sách kỹ năng, nhưng chưa trích ID/tên/cấp học/công thức từng nghề |
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

1. Không ghi cấp 150/200 là cấp tối đa nhân vật nếu chưa trích đúng bảng EXP và code server.
2. Không gọi trang bị Lục/Cam/VNG là trang bị cuối game của bản phục dựng khi chưa tra item ID và drop/công thức.
3. Phân biệt thú cưỡi, đệ tử của Dị Nhân và 8 Linh Thú custom — ba hệ thống khác nhau.
4. Không nhầm giới hạn 40 của Linh Thú với cấp nhân vật.
5. Nhiệm vụ bản VNG phải giữ nhãn **tham khảo**, không tuyên bố đã hoàn thành hay rơi đúng phần thưởng ở server hiện tại.

## Kiểm kê các bảng mã hóa cũ

Bảng cấp EXP, item, kỹ năng ở thư mục settings có thể dùng mã hóa GBK/CP936, khiến trình đọc UTF-8 thông thường không hiển thị được. Đã bổ sung [tools/gameplay_code_audit.py](../tools/gameplay_code_audit.py) và workflow [gameplay-code-audit.yml](../.github/workflows/gameplay-code-audit.yml) để quét tĩnh từ GitHub Actions bằng sparse checkout và giải mã GB18030; xuất đường dẫn, số dòng, đối tượng nghi vấn về class/EXP/skill/item/quest. **Kết quả quét chỉ là ứng viên**, phải tự đối chiếu logic thực thi trước khi điền con số hoặc hướng dẫn build.

### Chưa có bằng chứng để kết luận

- Class IDs của Giáp Sĩ / Đạo Sĩ / Dị Nhân trong code và UI chọn nghề.
- Mức cấp tối đa nhân vật trên server (khác level pet, level kỹ năng sinh hoạt).
- Danh sách skill ID/cấp học/tác dụng, phân bổ Sức mạnh/Thể lực/Trí lực theo PvE/PvP.
- Tên, ID, thuộc tính và thứ hạng của toàn bộ trang bị trong bản phục dựng.
- Quy trình chơi được từ cấp 1 đến cuối game, quái/boss và tỷ lệ rơi đồ.
- Tính tương thích giữa Lua runtime, PAK đóng gói, bảng settings client/server.

**Nguyên tắc nghiệm thu:** SOURCE → cấu hình thực sự được nạp → unit/integration test → gameplay client/server → cẩm nang khẳng định.
