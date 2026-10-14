# Cẩm nang tổng hợp Phong Thần Truyền Kỳ

> **Cập nhật 14/10/2026 — bản nghiên cứu dành cho tân thủ và nhóm phục dựng.** Tài liệu gốc VNG là nguồn tham khảo về thiết kế game, **không** chứng minh tính năng có thể chơi trên bản phục dựng hiện tại. Đọc nhãn nguồn trước khi làm theo hướng dẫn.

> **Đối chiếu code (14/10/2026):** [Bảng xác minh gameplay từ Lua/C++ và các mục chưa chứng minh](GAMEPLAY_SOURCE_AUDIT.md).

## Mục lục

1. [Bắt đầu](#1-bắt-đầu)
2. [Ba hệ phái và lối chơi](#2-ba-hệ-phái-và-lối-chơi)
3. [Kỹ năng và cách cộng điểm](#3-kỹ-năng-và-cách-cộng-điểm)
4. [Nhiệm vụ và lộ trình theo cấp](#4-nhiệm-vụ-và-lộ-trình-theo-cấp)
5. [Trang bị: Lục, Cam, Hoàng Kim, Thần Binh, Tiên Ma](#5-trang-bị-lục-cam-hoàng-kim-thần-binh-tiên-ma)
6. [Thú cưỡi, Đệ tử Dị Nhân, Linh Thú](#6-thú-cưỡi-đệ-tử-dị-nhân-linh-thú)
7. [Hoạt động, boss và kinh tế](#7-hoạt-động-boss-và-kinh-tế)
8. [Cấp tối đa, chuyển sinh và những câu hỏi lớn](#8-cấp-tối-đa-chuyển-sinh-và-những-câu-hỏi-lớn)
9. [Ma trận nguồn chứng cứ và kiểm thử](#9-ma-trận-nguồn-chứng-cứ-và-kiểm-thử)

**Nhãn:** **[VNG]** = cẩm nang VNG; **[SOURCE]** = đã tìm thấy logic/bảng trong repo; **[TESTED]** = đã nghiệm thu gameplay trong client/server của dự án (hiện **không có**); **[OPEN]** = còn cần kiểm tra.

## 1. Bắt đầu

Phong Thần Truyền Kỳ là dự án phục dựng client/server Windows x86. Nhiều thành phần đã build thành công nhưng full release và gameplay E2E chưa nghiệm thu. Không coi [hướng dẫn tải game VNG](https://phongthan.vinagame.com.vn/cam-nang/huong-dan/huong-dan-tai-game.html) là cách tải/cài đặt client của dự án này.

**Checklist người chơi mới:** chọn hệ phái phù hợp → làm nhiệm vụ cấp 1 → theo chuỗi nhiệm vụ lớp → tìm NPC nhập môn ở cấp 12 → tìm hiểu kỹ năng và yêu cầu trang bị → giữ lại vật phẩm hiếm đến khi cơ chế nâng cấp đã xác minh. Đối với bản thử nghiệm, cần tạo nhân vật thử, ghi nhận tên NPC, map, phần thưởng và lỗi trước/sau đăng xuất.

## 2. Ba hệ phái và lối chơi

| Hệ phái | Nhận diện | Cách chiến đấu theo cẩm nang VNG | Lưu ý |
| --- | --- | --- | --- |
| **Giáp Sĩ** | Chiến binh cận chiến | Vũ khí sắc bén, sức mạnh/thể lực, giáp phòng ngự, cưỡi thú | Đánh trực diện; cần đối chiếu build vũ khí và chỉ số từ source |
| **Đạo Sĩ** | Pháp sư | Âm dương, ngũ hành, địa/thủy/phong/hỏa; dùng thần điểu di chuyển | Chưa xác định hệ phép hay tỷ lệ thuộc tính tối ưu của server hiện tại |
| **Dị Nhân** | Triệu hồi & bùa chú | Gọi lực sĩ, tinh quân, thiên quân, thần thú; bùa chú tiêu hao; có cánh bay | Cần phân biệt triệu hồi kỹ năng với đệ tử pet/linh thú custom |

**Không phải hệ phái:** Côn Lôn, Thiên Sơn, Tiêu Dao từng được ghi sai trong tài liệu cũ. Ba lớp nhân vật cần dùng xuyên suốt tài liệu là Giáp Sĩ, Đạo Sĩ, Dị Nhân.

Nguồn: [Giáp Sĩ](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-giap-si.html), [Đạo Sĩ](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-dao-si.html), [Dị Nhân](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-di-nhan.html). **[VNG]**

## 3. Kỹ năng và cách cộng điểm

Các trang giới thiệu VNG có mục kỹ năng theo hệ phái; song **chưa lập được bảng ánh xạ skill ID ↔ tên ↔ cấp học ↔ hiệu ứng ↔ chi phí ↔ công thức tính** của runtime dự án. Vì thế các định hướng dưới đây không phải “build tối ưu đã test”.

| Hệ phái | Cần tra cứu trước | Định hướng ban đầu, không phải công thức cộng điểm |
| --- | --- | --- |
| Giáp Sĩ | Đòn cận chiến, loại vũ khí, yêu cầu Sức mạnh/Thể lực, phòng ngự | Ưu tiên đạt điều kiện dùng vũ khí, kiểm tra sống sót trong PvE rồi mới phân bổ phần dư |
| Đạo Sĩ | Các nhóm phép, sát thương ma pháp/ngũ hành, tiêu hao nội lực và hồi phục | Chọn một lộ trình phép phù hợp với quái/boss; chưa có tỷ lệ điểm chỉ số chuẩn |
| Dị Nhân | Triệu hồi, cấp pet/trợ thủ, bùa chú, thời gian duy trì, hồi chiêu | Kiểm tra kỹ năng triệu hồi thực sự hoạt động trước khi dồn điểm |

**Không tự đưa ra** tỷ lệ 3:1, 4:1 hay cộng tối đa kỹ năng cụ thể khi chưa có công thức và thử nghiệm. Lộ trình xác minh: xuất dữ liệu kỹ năng từ client/PAK → map sang server → thử học, reset điểm, tăng cấp, đánh quái và PvP → công bố build cho farm/boss/PvP riêng.

## 4. Nhiệm vụ và lộ trình theo cấp

**Trang chi tiết có NPC/tọa độ và chuỗi nhiệm vụ:** [BEGINNER_QUESTS.md](BEGINNER_QUESTS.md).

| Mốc | Giáp Sĩ | Đạo Sĩ | Dị Nhân | Tình trạng |
| --- | --- | --- | --- | --- |
| **1** | **Hộp Gấm** — Tô Hộ (200,204), Sùng Thành Đại Doanh | **Bách Lý** — Từ Hàng Đạo Nhân (206,196) | **Khai Trí** — Thiếu Hạo (198,204) | [VNG], chưa test |
| **12** | Sùng Ứng Loan (212,198), Sùng Thành Đại Doanh | Nhiên Đăng Đạo Nhân (206,192), Ngọc Hư Cung | Phong Bá (195,204), Xi Vưu Mộ | [VNG], chưa test |
| **14** | Theo nhiệm vụ lớp | Theo nhiệm vụ lớp | **Cứu Tế** — Phong Bá → Hình Thiên → Cự Lộc | [VNG], chưa test |
| **25** | Chưa đối chiếu | **Chinh Đồ** — Hoàng Long Chân Nhân → Khương Tử Nha | Chưa đối chiếu | [VNG], chưa test |
| **55** | Chưa đối chiếu | **Thần Mộc** — Thổ Hành Tôn → Hồ Hỷ Mị → Bất Tử Thần Mộc | Chưa đối chiếu | [VNG], chưa test |
| **65** | **Bình An** được ghi trong cẩm nang, phạm vi lớp cần đối chiếu | Như bên trái | Như bên trái | [VNG], chưa test |
| **70** | **Thần Dụ Kính** (đối chiếu các nhánh) | Như bên trái | Như bên trái | [VNG], chưa test |
| **111+** | Thập Tuyệt Trận — Nhân Tự Trận | Như bên trái | Như bên trái | [VNG], chưa xác nhận có ở runtime |
| **131+** | Thập Tuyệt Trận — Hồng Sa Trận | Như bên trái | Như bên trái | [VNG], chưa xác nhận có ở runtime |

**Chuỗi tân thủ theo nội dung VNG:**
- Giáp Sĩ: Hộp Gấm → Tân Thức → Dũng Đao → Kiếm Ái → Trừ Họa → Giáo Huấn.
- Đạo Sĩ: Bách Lý → Ngũ Thất → Khảo Nghiệm → Linh Lực → Băng Lang → Trừ Họa → Giáo Huấn.
- Dị Nhân: Khai Trí → Tân Thức → Thần Khí → Cứu Tế → Trừ Họa → Giáo Huấn.

Trình tự trên phản ánh cách trình bày trong hướng dẫn VNG, **chưa xác minh dependency thật trong server**. Nhiệm vụ cấp 12 và tọa độ tham khảo tại [FAQ chính thức](https://phongthan.vinagame.com.vn/cam-nang/huong-dan/hoi-va-dap.html).

**Thực trạng dự án [SOURCE]:** nền tảng quest Lua 4/NPC/task journal tồn tại; 5 chuỗi task 20/11/31/23/26 có bộ test, 24 tình huống/1.112 assertion và 68 assertion diệt quái. Trong 126 NPC đã kiểm kê, **84 script mới hướng dẫn**, 42 script còn lại có nhánh Lua gốc nhưng chưa nghiệm thu tất cả nhánh. Xem [QUEST_SYSTEM_STATUS.md](QUEST_SYSTEM_STATUS.md). Không đồng nhất unit test với nhiệm vụ chơi được.

## 5. Trang bị: Lục, Cam, Hoàng Kim, Thần Binh, Tiên Ma

### 5.1. Phân loại và mốc đã công bố

| Dòng trang bị | Phân cấp/điều kiện từ VNG | Cách nhận phổ biến ghi trong VNG |
| --- | --- | --- |
| **Lục** | Cấp 20, 40, 60, 80, 100; **Lục 120** chỉ có ở một số cụm máy chủ | Luyện quái, Boss Hoàng Kim, Vạn Tiên Trận, nhiệm vụ, đổi danh vọng; Lục 120 có đường ghép |
| **Cam Trấn Nguyên** | Các dòng Nghĩa Khí, Phục Ma, Hào Kiệt, Thiên Tứ, Phá Quân; khác theo phiên bản | Học đồ phổ, có điều kiện danh vọng, nguyên liệu, chế tạo |
| **Cam Sự Kiện / Cam Thánh** | Phụ thuộc cụm máy chủ và sự kiện | Sự kiện, đấu giá, đua top, giải đấu |
| **Vũ khí Hoàng Kim** | Có các mức theo bản phát hành, ví dụ **10x** trong danh sách nguồn thưởng VNG | Boss, tính năng và các hoạt động công bố |
| **Thần Binh** | Dòng riêng | Cần xác minh từng phiên bản và công thức |
| **Tinh Quân / Quần Anh Hội** | Một số dòng chỉ ở cụm 2017 | Cần kiểm tra điều kiện cụm |
| **Tiên Ma** | Mốc 30, 50, 70 trong bảng VNG | Tính năng/sự kiện tương ứng |

Nguồn chính thức: [Hệ thống các trang bị Phong Thần (2020)](https://phongthan.vinagame.com.vn/tin-tuc/can-biet/he-thong-cac-trang-bi-phong-than.html). **Không có một dòng “cao cấp nhất” áp dụng mọi máy chủ**.

### 5.2. Các nhóm trang bị cần tra trong game

Vũ khí, giáp, mũ, hộ uyển, hộ phù, ngọc bội, dây chuyền, nhẫn, giày — danh sách ghi nhận từ nghiên cứu trước; cần đối chiếu slot/ID và điều kiện của từng item trong source.

**Trang bị Lục theo mốc VNG:**
- **Lục 20:** luyện quái và một số hoạt động/nhiệm vụ.
- **Lục 40/60:** luyện quái, Boss Hoàng Kim tương ứng, Vạn Tiên Trận và các hoạt động.
- **Lục 80:** boss cấp 80/100, Thiên Cương Hồn, nhiệm vụ 85.
- **Lục 100:** Boss Hoàng Kim 100, boss đặc biệt, nhiệm vụ 92, đổi danh vọng tại Vân Tiêu.
- **Lục 120:** chỉ có một số cụm 2008/2013/2017, có đường săn boss và ghép tại Võ Vương.

### 5.3. Chế tạo đồ Cam

Theo [hướng dẫn chế tạo](https://phongthan.vinagame.com.vn/tin-tuc/can-biet/huong-dan-cach-thuc-che-tao-trang-bi-cam.html), người chơi cần học đồ phổ; chế tạo cấp cao cần đủ danh vọng Trấn Nguyên, nguyên liệu/tư cách tương ứng. VNG nêu **Dị Nhân có thể học chế tạo trang bị của Giáp Sĩ và Đạo Sĩ** — không đồng nghĩa mọi món trang bị đều mặc được hoặc bản phục dựng cho phép.

Theo [phân loại nguyên liệu](https://phongthan.vinagame.com.vn/tin-tuc/can-biet/phan-loai-cac-nguyen-lieu-hop-thanh-trang-bi-cam.html), ví dụ công thức **20 Đoản Kiếm + 20 Mảnh Giáp + 20 Mặt Quỷ + 20 Hỏa Vũ + 20 Băng Cơ + 20 Tuyết Cốt = 1 Thu Thập** được công bố xác suất 100% trong bản VNG liên quan. **Không thực hiện trên bản phục dựng trước khi xác minh recipe.**

### 5.4. Một số tên trang bị Tiên Ma có nguồn

VNG liệt kê các món **Huyền Khung Khôi, Minh Quang Quán, Thiên Lộc Trụ, Huyền Khung Chiến Ngoa, Minh Quang Lý, Thiên Lộc Ngoa, Thần Phục Huyền Khung Giáp, Minh Quang Đạo Bào, Thiên Lộc Hộ Giáp**, cùng vũ khí **Cữu Tích Đao, Câu Trần Phủ, Thái Linh Kiếm, Vĩnh Dạ Phủ** trong [Càn Khôn Tiên Ma](https://phongthan.vinagame.com.vn/cam-nang/tinh-nang/can-khon-tien-ma.html). Đây là **ví dụ tên thật từ tài liệu VNG**, không phải kết luận trang bị cuối game hay item đã có trong source.

### 5.5. Bảng cấp cuối game theo hệ phái (cần item IDs)

| Hệ phái | Nguồn item cần đối chiếu | Trạng thái |
| --- | --- | --- |
| Giáp Sĩ | Trang bị/vũ khí dùng được, sát thương/phòng ngự, set bonus, cách nhận | [OPEN] |
| Đạo Sĩ | Vũ khí phép, thuộc tính ma pháp, trang bị nghề/set bonus, cách nhận | [OPEN] |
| Dị Nhân | Trang bị hỗ trợ triệu hồi/bùa chú, set bonus, cách nhận | [OPEN] |

Chưa có chứng cứ đủ để chọn duy nhất “bộ đồ mạnh nhất”. **Không được tự gán item Tiên Ma hoặc bộ Cam của VNG cho bản phục dựng**.

## 6. Thú cưỡi, Đệ tử Dị Nhân, Linh Thú

| Hệ thống | Dữ liệu đã có trong repo | Giới hạn cần biết |
| --- | --- | --- |
| **Thú cưỡi** | Bảng `horse.txt`; chức năng hiển thị/cấp thú | Chưa xác nhận quy trình ép, cộng cấp hoặc nguồn nhận đầy đủ |
| **Đệ tử Dị Nhân** | `PhongThanBotPet.h`, `petexp_lib.lua`, `nuoithu_lib.lua` | Có tăng kinh nghiệm và cấp **1–10**; khác kỹ năng triệu hồi/pháp thuật |
| **Linh Thú custom** | `sinhhoat/sh_lib.lua`, `lt_npc.lua`, `lt_lenh.lua` | **8 Linh Thú, 4 giai đoạn tiến hóa**, đổi trứng, cho ăn, triệu hồi; chưa nghiệm thu gameplay |

**Nguy cơ giao dịch:** lệnh phát quà/đổi trứng/tiến hóa có nhánh lỗi có thể hoàn tiền, hoàn nguyên liệu thiếu hoặc gây cấp trùng khi retry; chưa bảo đảm atomic transaction. Không dùng tài khoản thật hoặc vật phẩm quý để thử. Chi tiết [REWARDS_AND_PETS.md](REWARDS_AND_PETS.md).

## 7. Hoạt động, boss và kinh tế

Tài liệu VNG nhắc đến Boss Hoàng Kim, Vạn Tiên Trận, Thập Tuyệt Trận, Tứ Tượng, Hộ Hoa Sứ Giả, Tống Tửu, Thương Chu, Giang Sơn Y Cựu; **đây là danh mục ứng viên để kiểm thử**, không chứng minh các hoạt động đã mở trên server phục dựng.

Đối với người mới: ưu tiên hoàn thành nhiệm vụ của hệ phái trước khi săn boss/nâng đồ; kiểm tra túi còn chỗ trống khi nhận thưởng; không làm đi làm lại hành động nhận quà nếu có lỗi mạng hoặc thông báo PARTIAL; ghi log và báo GM thay vì tự retry.

Nguồn [Hệ thống trang bị](https://phongthan.vinagame.com.vn/tin-tuc/can-biet/he-thong-cac-trang-bi-phong-than.html), [Động Sát Mộc Thần](https://phongthan.vinagame.com.vn/cam-nang/chinh-phuc/dong-sat-moc-than.html).

## 8. Cấp tối đa, chuyển sinh và những câu hỏi lớn

- **Cấp tối đa bản phục dựng:** **chưa xác minh**. Phát biểu “150” trước đây thiếu chứng cứ trong source; [cẩm nang chuyển sinh VNG](https://phongthan.vinagame.com.vn/cam-nang/tinh-nang/chuyen-sinh.html) còn đề cập cấp 200. Không suy ra server này là cấp 150 hay 200.
- **Chuyển sinh:** có tài liệu VNG, **chưa xác minh script/điều kiện/tác động save** của bản phục dựng.
- **Trang bị mạnh nhất:** phụ thuộc content/version/server; cần trích đủ bảng item, set, nâng cấp và kỹ năng liên quan.
- **Điểm cộng tối ưu:** chưa có build benchmark; không phát tán bảng cộng điểm đoán.
- **Có thể chơi chưa:** các gate build Windows module/client/server PASS nhưng full release và kiểm thử login→nhiệm vụ→lưu→đăng nhập lại chưa được nghiệm thu. Xem [MASTER_ROADMAP.md](MASTER_ROADMAP.md).

## 9. Ma trận nguồn chứng cứ và kiểm thử

| Chủ đề | Có nguồn VNG | Có chứng cứ source dự án | Đã test gameplay | Việc cần thực hiện |
| --- | --- | --- | --- | --- |
| 3 hệ phái | Có | Chưa đối chiếu đầy đủ mapping | Không | Mapping class IDs, UI tạo nhân vật, kỹ năng |
| Nhiệm vụ đầu game | Có | Quest foundation, kiểm kê NPC | Không | Thử từng bước và phần thưởng |
| Level cap | Nguồn khác phiên bản, có mốc 200 | Chưa chỉ ra cấu hình cap | Không | EXP table, code giới hạn cấp |
| Skill và điểm | Có mô tả VNG | Chưa tổng hợp skill IDs/công thức | Không | Xuất bảng kỹ năng, skill tests |
| Trang bị | Có danh mục Lục/Cam/Hoàng Kim/... | Chưa tổng hợp item IDs/set | Không | Export bảng item, source drops/recipes |
| Thú cưỡi/pet/Linh Thú | Có nội dung VNG và custom | Có các file/script được kiểm kê | Không | Kiểm thử nhận thú, tiến hóa, cấp thưởng |
| Boss/hoạt động | Có | Chưa đối chiếu đủ | Không | Audit map/NPC/event scheduler |
| Cài đặt/chơi game | VNG có launcher riêng | Build module PASS | Không | Full release, VM smoke test |

### Hướng nghiên cứu kỹ thuật cho lần cập nhật tiếp

1. Trích danh sách class/skill/EXP/item/quest/map từ runtime/client/source (không sửa bytes gốc), lưu báo cáo dạng dữ liệu có hash và provenance.
2. Lập các phụ lục **Giáp Sĩ**, **Đạo Sĩ**, **Dị Nhân**: skill ID, tên, cấp mở, nội lực, điểm thuộc tính, vũ khí, trang bị, khu train, PvE/PvP.
3. Tạo **item catalog** theo nghề/tier/slot/set/recipe/drop, kiểm tra “best-in-slot” trên đúng phiên bản dự án.
4. Chạy Windows game VM cách ly, dùng nhân vật thử, thu bằng chứng hành trình từ tạo nhân vật đến lưu/đăng nhập lại.
5. Khi đã xác minh, đổi nhãn [OPEN] → [SOURCE] → [TESTED], ghi commit + phiên bản client/server + test ID.

Nguồn tham khảo chính: [VNG — Giáp Sĩ](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-giap-si.html), [VNG — Đạo Sĩ](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-dao-si.html), [VNG — Dị Nhân](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-di-nhan.html), [VNG — hệ thống trang bị](https://phongthan.vinagame.com.vn/tin-tuc/can-biet/he-thong-cac-trang-bi-phong-than.html), [VNG — FAQ](https://phongthan.vinagame.com.vn/cam-nang/huong-dan/hoi-va-dap.html), [MASTER_ROADMAP](MASTER_ROADMAP.md), [QUEST_SYSTEM_STATUS](QUEST_SYSTEM_STATUS.md), [REWARDS_AND_PETS](REWARDS_AND_PETS.md).
