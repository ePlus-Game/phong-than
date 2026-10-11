# Tứ Tượng: vật phẩm lỗi, thưởng Thủ khố an toàn, Trưởng lão và Tinh Thạch

> Dự án: Phong Thần (bản local) · Ngày: 2026-10-02 · Người thực hiện: agent `tutuong_a`
> Trạng thái: **đã làm xong, đã chạy mô phỏng (0 lỗi)**. Có hiệu lực sau khi coordinator đóng gói ptfix mới, thêm 1 dòng vào `servertimer.lua` và người dùng khởi động lại server.
> Lựa chọn của người dùng: Túi Tứ Tượng 8/286 trao **mỗi loại 1** nguyên liệu; Tinh Phách rơi từ **4 ma vương** boss thế giới.

## Phần 1: Tổng quan
- **Lớp tương thích Lua 5** trong `pt_compat.lua`: có thêm `math.*`, `table.*`, `string.*`, `require` (không làm gì), `DelItemByID`, `FindAValidItemID`, `IsItemBind`, cùng các stub an toàn `GetPlayerVipLevel` (trả 0), `SetPlayerVipLevel`, `AddBindCoin`, `GetItemGen/GetItemDetail` (trả -1). Mỗi tên chỉ được gán khi đang là `nil`, nên không đè lên tên script đã tự định nghĩa.
- **Vật phẩm Tứ Tượng không còn lỗi script khi bấm dùng:**
  - **4 vật phẩm trao thưởng bình thường:** Túi Tứ Tượng 8/286 (IB shop), Túi Quà Tứ Tượng (Nhỏ) 6/1/1652, Túi quà nhỏ Lục Đạo Tứ Tượng 6/1/1835, và Huyền Vũ Thần Hồn Bảo Rương 6/1/1291. Riêng rương 1291 chỉ mở được khi có dữ liệu vật phẩm thưởng, xem điểm dưới.
  - **3 vật phẩm hiện thông báo và được giữ lại, không bị mất:**
    - Hộp Chu Tước 6/1/1329;
    - Thẻ Bạch Hổ 6/1/1304;
    - Rương 1291, khi phần thưởng "Mảnh Phù Thạch" không tạo được.
    Lý do: phần thưởng gốc **không có trong dữ liệu vật phẩm VN** của máy chủ này, xem Phần 2.3.
- **Nhiệm vụ Tứ Tượng ở Thủ khố Tây Kỳ và Triều Ca:**
  - kiểm tra 1 ô trống 2x2 và lấy đủ 10 nguyên liệu **trước** khi tính thưởng;
  - hành trang đầy thì không mất gì;
  - mọi phần khác giữ nguyên.
- **Trưởng lão Tứ Tượng** (NPC 677–680) xuất hiện theo lịch VNG: 00:00/15/30/45 và 12:00/15/30/45, ở cạnh ma vương trong 60 phút. Chuỗi chế tạo chạy trọn: **Tinh Phách → Ngưng Phách → Tứ Tượng Tinh Thạch**, và từ đó ghép được Hỗn Nguyên Châu (công thức #385 có sẵn).
- **Nguồn Tinh Phách:** người hạ 4 ma vương nhận **2 Tinh Phách** (không khóa), đúng hệ với ma vương:
  - Thiết Bố → Thổ (3/200);
  - Côn Bối → Hỏa (3/201);
  - Lam Bá → Phong (3/202);
  - Kim Trại → Thủy (3/203).

## Phần 2: Chi tiết

### 2.1 Lớp tương thích (`Server\script\phongthan\lib\pt_compat.lua`, thêm vào cuối file)
| Tên | Cách làm (Lua 4) |
|---|---|
| `math.random/floor/ceil/min/max/abs/mod/fmod/sqrt/pow/pi/huge` | Bảng hàm Lua 4. `math.random(n)` → `random(1,n)`, `math.random()` → `random()` |
| `table.getn/insert/remove/sort/concat` | `getn`, `tinsert`, `tremove`, `sort`, cùng một hàm `concat` tự viết |
| `string.len/sub/find/lower/upper/rep/format/gsub/byte/char` | Các hàm chuỗi Lua 4 |
| `require(x)` | Không làm gì, trả 1. Các module VNG như `common.luax` không tồn tại ở bản này |
| `DelItemByID(idx[,n])` | `RemoveItem(idx, n or 1, 0)`; engine tự kiểm tra vật phẩm có thuộc người chơi không. Trả 1 hoặc 0 |
| `FindAValidItemID(idx)` | Trả `idx` nếu `GetItemPartByID(idx) > 0`, ngược lại trả 0 |
| `IsItemBind(idx)` | `GetLockItem(idx)` bằng -2 (khóa vĩnh viễn) hoặc -3, thì trả 1 |
| `GetItemGen/GetItemDetail` | Trả -1. Engine không có hàm lấy loại/chi tiết theo index, nên script dùng 2 hàm này không trao gì, thay vì trao sai |
| `GetPlayerVipLevel` / `SetPlayerVipLevel` / `AddBindCoin` | Trả 0. Bản này không có hệ đặc quyền (VIP) và không có tiền khóa |

- Đã rà các script đang Include `pt_compat`: không script nào dùng biến toàn cục tên `math`, `table` hay `string`. Chỉ có biến `local string` và tham số `table`, đều không bị ảnh hưởng.
- Engine chỉ truyền **index vật phẩm** vào `main` (`KItemList::ExecuteScript`). Các script VNG kiểu mới khai báo `main(nLevel, nTime, nNpc, itemID)` nên luôn nhận `itemID = nil`. Vì vậy 6 script dưới đây được viết lại theo đúng cách engine gọi.

### 2.2 Sáu script vật phẩm (đóng vào ptfix qua plug-in `scratchpad\ptfix\extra_tutuong_a.py`)
| Vật phẩm | Đường dẫn script (id ptfix) | Hành vi mới |
|---|---|---|
| **8/286 Túi Tứ Tượng** (IB shop) | `\script\item\礼品包\sixianglibao.lua` (0ec11197). Trước đây **không tồn tại** | Cần 4 ô trống. Trừ túi bằng `CostIBItem`, trao **1 Địa Tâm, 1 Phong Lệ, 1 Thủy Hồn, 1 Hỏa Linh** (3/22–25, khóa) |
| 6/1/1652 Túi Quà Tứ Tượng (Nhỏ) (Khóa) | `\script\item\礼品包\四象小礼包.lua` (f870f2ee) | Giữ hành vi gốc: chọn 1 trong 4 loại, nhận 10 cái (khóa), trừ 1 túi. Đã bỏ `table.getn` và kiểu `Say(..., bảng)` |
| 6/1/1835 Túi quà nhỏ Lục Đạo Tứ Tượng | `\script\item\礼品包\六道四象小礼包.lua` (e9e00ec1) | 12 lựa chọn chia 2 trang. Nguyên liệu nhận được **giữ trạng thái khóa của túi**. Biến task **2020** giữ index túi giữa lúc mở menu và lúc chọn; khi chọn sẽ kiểm tra lại index và vật phẩm |
| 6/1/1291 Huyền Vũ Thần Hồn Bảo Rương (cùng bảng 1274/1275/1277) | `\script\item\玄武宝箱.lua` (edf5f5e4) | Giữ bảng tỉ lệ gốc và cơ chế nhân đôi lần đầu trong ngày (task byte 2029/1 của VNG). Script tạo thử mảnh đầu tiên: nếu không tạo được thì báo và giữ rương |
| 6/1/1329 Hộp Chu Tước Trấn Hồn Tinh Phách | `\script\item\镇魂晶魄朱雀包.lua` (f2571b94) | Hiện thông báo, hộp được giữ lại |
| 6/1/1304 Thẻ Trải Nghiệm Đặc Quyền Bạch Hổ | `\script\item\白虎特权体验卡7天定制版.lua` (f413f0a0) | Hiện thông báo "hệ thống Đặc Quyền chưa có", thẻ được giữ lại (nếu chạy theo logic cũ thì chỉ mất thẻ mà không được gì) |

- Các file rời cùng tên tiếng Trung trong `Server\script\item\...` vẫn còn đó nhưng engine không đọc được, vì đường dẫn GBK chỉ được đọc từ ptfix. Không cần xóa.

### 2.3 Vì sao 3 vật phẩm chưa trao thưởng được
| Vật phẩm | Thưởng theo script VNG | Dữ liệu VN của máy chủ |
|---|---|---|
| 6/1/1291 (và 1274/1275/1277) | Mảnh Phù Thạch 6/1/1276, 6/1/1281 | **Không có** dòng 1276/1281 trong `magicscript.txt` hiệu lực |
| 6/1/1329 | 3/1237 "Trấn Hồn Tinh Phách", 8/1732/2 "bùa biến thân Linh Sủng Chu Tước" | Ở bản VN, 3/1237 là **"Lôi Sát %"** và 8/1732 là một dòng buff. Trao theo mã cũ sẽ ra **vật phẩm sai**, nên không trao |
| 6/1/1304 | Đặc quyền Bạch Hổ 7 ngày qua `SetPlayerVipLevel` | Engine không có hệ VIP. Muốn có phải viết C++ hoặc tự thiết kế lại |

- Muốn các vật phẩm này trao thưởng, người dùng cần chọn **phần thưởng thay thế**, hoặc bổ sung dòng dữ liệu vật phẩm. Rương 1291 sẽ tự chạy khi có dòng 6/1/1281.

### 2.4 Thủ khố Tây Kỳ và Triều Ca: nhiệm vụ "Tứ Tượng"
- **Script:** `\script\西岐\仓库管理员.lua` (1cbd6c1b) và `\script\朝歌\仓库管理员.lua` (517a52ae), vá chồng lên bản đang có trong ptfix (đã có dòng Include `pt_compat`).
  - Hai NPC này **không** dùng `npc_fix\100x_thu_kho.lua` (các file đó chỉ dành cho map 1002/1003/1004), nên không đụng tới phần "Mở rương chứa đồ" coordinator vừa thêm.
- **Thay đổi trong `huan()`:**
  1. Ngay sau `if (HaveNormalItem(3,mã,0,0)>=10) then`, gọi `PTTK_TakeTen(mã)`. Hàm này:
     - cần `CalcFreeItemCellCount(2,2,0) >= 1`. Mọi phần thưởng đều không lớn hơn 2x2: pháp bảo 0/4, giày/đai/mũ 0/5–7;
     - xóa 10 nguyên liệu và **đếm** số đã xóa được. `HaveNormalItem` đếm cả rương chứa đồ, còn `DelNormalItem` chỉ xóa trong hành trang. Nếu xóa được dưới 10 thì trả lại số đã xóa (dạng **khóa**, để không thể dùng cách này "mở khóa" nguyên liệu) và dừng.
  2. Bỏ vòng `DelNormalItem` ở cuối hàm. Bốc thưởng, Earn 1200, AddCredit 5, `SetTask(55/54, 0)` và TaskNote vẫn như cũ.
- **Không dùng `QuestExchange`:** hàm này bỏ qua vật phẩm khóa, mà nguyên liệu từ Túi Tứ Tượng (Nhỏ) đều là đồ khóa, nên người chơi sẽ không nộp được.

### 2.5 Trưởng lão Tứ Tượng (file rời ASCII, `Server\script\phongthan\tutuong\`)
| Trưởng lão | Mẫu NPC | Giờ xuất hiện | Bản đồ (cạnh ma vương) | Script hội thoại |
|---|---|---|---|---|
| Thổ | 677 | 00:00, 12:00 | Sa Mạc chết 1026 (Thiết Bố 00:01) | `tt_elder_1.lua` |
| Thủy | 680 | 00:15, 12:15 | Long Uyên 1041 (Kim Trại 00:16) | `tt_elder_4.lua` |
| Hỏa | 678 | 00:30, 12:30 | Hiên Viên tầng 5 1031 (Côn Bối 00:31) | `tt_elder_2.lua` |
| Phong | 679 | 00:45, 12:45 | Băng Xuyên Cực 1036 (Lam Bá 00:46) | `tt_elder_3.lua` |

- **`tt_elder.lua` → `PTTT_Tick()`**, chạy mỗi phút:
  - trong khung `[giờ, giờ + 60 phút)` mà trưởng lão chưa có trên bản đồ thì gọi ra. Vị trí là điểm boss trong `wb_data.lua` cộng (24, 24) đơn vị (khoảng 3 ô ngang, 1,5 hàng dọc). Script hội thoại gắn qua `SetNpcScript`, có thông báo toàn server;
  - hết khung thì xóa NPC (`DelNpc`).
  - **Lần chạy đầu** (server mới mở hoặc servertimer nạp lại): `ReLoadScript` 4 script hội thoại và `ClearMapNpcWithName` theo tên GBK, để không còn trưởng lão "mồ côi". Nếu mở lại server giữa khung giờ, trưởng lão được gọi lại.
- **`tt_elder_lib.lua`, hội thoại**, gồm 6 dòng:
  - luyện 1 hoặc toàn bộ Tinh Phách cùng hệ thành Ngưng Phách (1:1, tối đa 100 mỗi lần);
  - hợp 1 hoặc tối đa Tứ Tượng Tinh Thạch (mỗi viên cần 1 Ngưng Phách Thổ + 1 Hỏa + 1 Phong + 1 Thủy). Trưởng lão nào cũng hợp được;
  - tìm hiểu;
  - kết thúc.
  Mỗi lần ghép:
  - cần 2 ô trống;
  - trao sản phẩm **trước**, sau đó mới lấy nguyên liệu;
  - thiếu nguyên liệu (hoặc nguyên liệu nằm trong rương chứa đồ) thì trả lại phần đã lấy và xóa sản phẩm vừa trao;
  - sản phẩm không khóa.
- **Tỉ lệ:** dữ liệu không ghi số lượng.
  - Mô tả 3/204–207 viết "kết hợp với 3 loại Ngưng Phách khác", nên đặt 4 loại × 1 → 1 Tinh Thạch.
  - Tinh Phách → Ngưng Phách đặt 1:1 **[tự chọn]**.
  - Một Hỗn Nguyên Châu cần 4 Tinh Thạch = 4 Tinh Phách mỗi hệ = 8 lượt hạ ma vương (mỗi lượt 2 Tinh Phách).
- **Không dùng biến task nào** cho trưởng lão. Vị trí NPC được giữ trong biến Lua `PTTT_NPC` của state servertimer.

### 2.6 Rơi Tinh Phách từ ma vương (`Server\script\phongthan\boss\wb_lib.lua`)
- Thêm bảng `PTWB_TINHPHACH` (`thiet_bo`=200, `con_boi`=201, `lam_ba`=202, `kim_trai`=203) và `PTWB_TINHPHACH_N = 2`.
- Thêm hàm `PTWB_GiveTinhPhach(b, pi)`, gọi từ `PTWB_GiveLoot` sau phần bảo vật hiếm. Hàm dùng `AddNormalItemPile(3, d, 0, 0, 0, 0)` để trao vào túi người hạ boss và gửi tin nhắn "mang đến Trưởng Lão".
- Như các phần thưởng boss khác, túi đầy thì không nhận được.
- Muốn đổi số lượng thì sửa `PTWB_TINHPHACH_N`.

### 2.7 Kiểm thử bằng mô phỏng
- **File:** `scratchpad\qtest\sim_tta.lua`, kết quả ở `out_tta.txt`. Chạy bằng PowerShell 32-bit và `run.ps1`. Kết quả: **69 kiểm tra đạt, 0 lỗi**.
  - **A. Lớp tương thích:** math, table, string, require, DelItemByID, IsItemBind, FindAValidItemID, các stub; không đè bảng `math` đã có; `TaskNote` và wrapper SayTask cũ vẫn hoạt động.
  - **B. Vật phẩm:**
    - túi 8/286: đủ chỗ, thiếu chỗ, không còn túi;
    - túi 1652: menu, nhận 10 cái, đầy túi;
    - túi 1835: 2 trang, giữ trạng thái khóa, index cũ bị từ chối;
    - rương 1291/1274: thiếu dữ liệu thì giữ rương, có dữ liệu thì trao 60/4 mảnh và ghi dấu ngày;
    - 1329 và 1304 đều được giữ lại.
  - **C. Thủ khố (cả 2 thành):** thiếu ô 2x2 thì không mất gì; chỉ có 7 cái trong hành trang thì trả lại 7 và giữ nhiệm vụ; đủ 10 thì trao pháp bảo và reset task 55/54.
  - **D. Lịch trưởng lão:** chạy 17 mốc giờ từ 23:59 đến 13:45, cộng một lần mở lại server lúc 00:20.
  - **E. Hội thoại trưởng lão:** luyện 1 và toàn bộ; hợp đá; thiếu loại; đầy túi; trao thất bại; Tinh Phách nằm trong rương chứa đồ.
  - **F. Boss thế giới:** 4 ma vương mỗi con trao 2 Tinh Phách đúng hệ; 8 boss còn lại không trao.
- **Bản dựng ptfix thử** `scratchpad\tutuong_a\ptfix_test.pak` (397 entry, chạy cùng plug-in của `tutuong_b`): 8 entry của plug-in này **giống từng byte** với file đã mô phỏng (`cmp.py`).

## Phần 3: Hành động (kiểm thử trong game sau khi khởi động lại server)
- [ ] **Coordinator:**
  - thêm hook servertimer `PTAdm_TtTick` (xem báo cáo);
  - đóng gói ptfix chính thức (có `extra_tutuong_a.py`);
  - ghi CHANGELOG.
- [ ] **Túi Tứ Tượng 8/286:** mua ở IB shop, bấm phải → nhận 4 nguyên liệu, túi mất. Thử lại khi túi còn dưới 4 ô trống → túi còn nguyên.
- [ ] **Túi 6/1/1652:** chọn Thủy Hồn → nhận 10 Thủy Hồn (khóa).
- [ ] **Túi 6/1/1835:** sang trang 2, chọn Tứ Tượng Tinh Hoa → nhận 1. Thử với túi khóa và túi không khóa.
- [ ] **Rương 1291, Hộp 1329, Thẻ 1304:** bấm phải → hiện thông báo, vật phẩm vẫn còn, không có lỗi script.
- [ ] **Thủ khố Tây Kỳ (map 20) / Triều Ca (map 21):**
  - nhận nhiệm vụ Tứ Tượng, gom 10 nguyên liệu → trả → nhận 1200 lượng, có thể kèm pháp bảo/trang bị;
  - thử lại khi hành trang đầy → báo cần ô 2x2, không mất nguyên liệu.
- [ ] **Lúc 00:00 hoặc 12:00:** Thổ Trưởng Lão xuất hiện ở Sa Mạc chết, cạnh chỗ Thiết Bố. Hạ Thiết Bố → nhận 2 Thổ Tinh Phách → nói chuyện với Trưởng Lão → "Luyện toàn bộ" → nhận 2 Thổ Ngưng Phách.
- [ ] **Gom đủ 4 loại Ngưng Phách** → "Hợp 1 Tứ Tượng Tinh Thạch" ở bất kỳ Trưởng Lão nào. Có 4 Tinh Thạch, 8 Tướng Quân Lệnh và 10 Dung Tinh Lộ → ghép Hỗn Nguyên Châu.
- [ ] **Sau 60 phút:** Trưởng Lão biến mất.
- [ ] **Người dùng quyết định:**
  - phần thưởng thay thế cho 1291 và 1329;
  - có làm hệ Đặc Quyền cho 1304 không;
  - số Tinh Phách mỗi lần hạ boss (hiện là 2) và tỉ lệ 1:1.

## Phần 4: Tài liệu tham khảo
- **File đã đổi** (bản sao lưu ở `E:\VL\Phong than\PT\_backup\20261002-tutuong_a\`):
  - `Server\script\phongthan\lib\pt_compat.lua`;
  - `Server\script\phongthan\boss\wb_lib.lua`.
- **File mới:**
  - `Server\script\phongthan\tutuong\tt_elder.lua`, `tt_elder_lib.lua`, `tt_elder_1..4.lua`;
  - plug-in `scratchpad\ptfix\extra_tutuong_a.py`.
- **Mã nguồn và công cụ:**
  - `scratchpad\tutuong_a\src\pak\*.lua` (nguồn UTF-8 của 6 script ptfix) và `src\loose\*.lua`;
  - `gen.py`: `sim` / `loose` / `install`, chuyển sang TCVN3 hoặc chuỗi escape `\ddd`;
  - `cmp.py`.
- **Báo cáo nghiên cứu:** `scratchpad\tutuong\tutuong_report.md`, các mục 2.1, 2.2, 2.5, 2.6, 2.8.
- **Liên quan:**
  - `bao-thuong-can-khon-tu-tuong-thu-kho-phong-than-20261002.md`;
  - `boss-the-gioi-lenh-bai-phong-than-20260930.md`;
  - phần Tứ Linh và Huyền Vũ do agent `tutuong_b` làm.
