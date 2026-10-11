# Bí kíp hệ phái: mua, ép (đóng sách) và click phải để học

> Dự án: Phong Thần (bản local) · Ngày: 2026-10-02 · Người làm: agent bikip
> Trạng thái: **Đã làm, chờ cài.** Script Lua đã nằm trong `Server\script`. Dữ liệu PAK nằm trong plug-in `extra_bikip.py`; bản build thử (Server và Client) đạt. Có tác dụng sau khi build/cài ptfix mới và khởi động lại server, game.

## Phần 1: Tổng quan
- **Người dùng báo:** "Các bí kíp của hệ phái chưa ép và mua được, click dùng được."
- **Bí kíp hệ phái là gì:** sách kỹ năng VNG (`\settings\item\001\skillbook.txt`, loại vật phẩm 7). Có 60 cuốn cho 3 phái:
  - Giáp Sĩ 16 cuốn (kỹ năng 27–42);
  - Đạo Sĩ 24 cuốn (3–26);
  - Dị Nhân 18 cuốn (43–51 và đệ tử 450–458);
  - 2 sách kỹ năng sống dùng chung (62 Bàn Cổ Khai Thiên, 128 Ban Môn Lộng Phủ).
- **Cơ chế VNG:**
  - Sách cấp thấp (đến cấp 30) **mua** ở Võ sư. Tân Thủ thôn: `Sale(8)` Giáp Sĩ, `Sale(9)` Đạo Sĩ, `Sale(10)` Dị Nhân. Thư viện: `Sale(19)`. Võ sư Tây Kỳ/Triều Ca: `Sale(14)`.
  - Sách cấp cao **"ép"** ở Võ sư Tây Kỳ/Triều Ca, mục "Đóng sách": nộp Không Thư (Bạch/Lam/Hồng/Hoàng) cùng Mảnh Hồng Thủy Tinh, Hồng Thủy Tinh hoặc Hồng Bảo Thạch. Phép này có tỉ lệ (10–50%); thất bại thì nhận vật phẩm an ủi.
  - Học: click phải vào sách.
- **Vì sao hỏng (engine dựng lại):**
  1. **Click không làm gì:** `KItemList::ExecuteScript` thoát sớm với loại 7, và bảng `skillbook.txt` không có cột script. `item_action_diag.log` có 20 lần click loại 7 (`EatItemByID_EXECUTE genre=7`) nhưng không có dòng `ExecuteScript_BEGIN` nào.
  2. **Không mua được:** `GenerateShopItem` trong `KBuySell.cpp` thiếu nhánh `item_skillbook`. 80 dòng sách trong `goods.txt` bị bỏ qua.
     - Tệ hơn: mỗi dòng bị bỏ làm **mọi dòng hàng phía sau lùi 1 ô**. Vì vậy các tiệm dùng hàng sau dòng 452 (Sale 2–65) đang hiện và bán sai món.
  3. **Ép ra sách vô dụng:** script Võ sư VNG vẫn cho sách loại 7. Script này cũng trừ nguyên liệu trước mà không kiểm tra chỗ trống trong hành trang.
     - `HaveNormalItem` đếm cả rương chứa đồ, còn `DelNormalItem` chỉ lấy trong hành trang. Do đó có thể ép "miễn phí" khi nguyên liệu nằm trong rương.
- **Cách làm (chỉ Lua và dữ liệu, không sửa C++):**
  - Mỗi cuốn có thêm bản **magicscript 6/1/(62000 + mã kỹ năng)** tên "Bí Kíp …". Bản này có script riêng, click phải để học.
  - Các dòng sách trong `goods.txt` được đổi sang bí kíp. Nhờ vậy các tiệm VNG bán được, và mọi tiệm không còn bị lệch hàng do sách.
  - Thêm 3 tiệm "Bí kíp hệ phái" bán đủ sách của phái.
  - Viết lại "Đóng sách" an toàn, và thêm mục đổi sách cũ (loại 7) thành bí kíp.

## Phần 2: Chi tiết

### 2.1 Click phải để học (`script\phongthan\lib\pt_bikip.lua`, `PTBK_UseBook`)
- Mỗi bí kíp gọi `script\phongthan\item\bikip_<mã kỹ năng>.lua`. Có 60 file, tất cả `Include` thư viện chung.
- Các bước:
  1. Kiểm tra đúng phái (`GetProfession`). Sách kỹ năng sống thì phái nào cũng dùng được.
  2. Kiểm tra đủ cấp. Mốc cấp lấy theo mô tả VNG "Sách kỹ năng … cấp N".
  3. Chưa có kỹ năng: học cấp 1 (`AddMagic`). Nếu kỹ năng đang ở cấp 0 thì `SetSkillLevel` trước.
  4. Đọc lại `GetMagicLevel`. Chỉ khi học được thật mới `RemoveItem(idx, 1, 0)`.
  5. Đã có kỹ năng: báo "đã lĩnh hội" và giữ lại sách. Theo VNG, sách chỉ dạy cấp 1; cấp cao hơn tăng bằng điểm kỹ năng.
- Kết quả hiện bằng hộp thoại và dòng chat. Có ghi log `admin_bridge\token.log` (thẻ `bikip`).
- `bikip_sach7.lua` (`PTBK_UseSkillBook7`): dùng cho sách loại 7 cũ (mã kỹ năng = `GetItemPartByID`). File này chỉ chạy khi C++ gọi nó (xem 2.6).

### 2.2 Mua
- **Tiệm VNG** đã hiện bí kíp đúng món, đúng vị trí:
  - `Sale(8)`: 4 cuốn Giáp Sĩ;
  - `Sale(9)`: 8 cuốn Đạo Sĩ;
  - `Sale(10)`: 5 cuốn Dị Nhân;
  - `Sale(14)`: 3 cuốn;
  - `Sale(19)`: 20 cuốn.
- **Tiệm mới** (mục "Mua bí kíp hệ phái" ở Võ sư Tây Kỳ/Triều Ca, mở tiệm theo phái của người chơi):

| Sale | Phái | Số món |
|---|---|---|
| 66 | Giáp Sĩ | 16 + 2 sách sống |
| 67 | Đạo Sĩ | 24 + 2 |
| 68 | Dị Nhân | 18 + 2 |

- **Giá (bạc):**
  - Sách VNG vốn bán ở tiệm: giữ giá VNG, 40–30.000.
  - Sách VNG chỉ ép được: `cấp × 2.000`, tức 68.000–180.000.
  - Sách kỹ năng sống: 2.000.
- **Lưu ý:** 17 dòng sách Vũ Sĩ (hệ phái không có trong bản này) không khớp sách nào. Các dòng đó thành món giữ chỗ, và được gỡ khỏi các tiệm (12 ô ở Sale 14, 19, 65).

### 2.3 Ép bí kíp: "Đóng sách (ép bí kíp)" ở Võ sư Tây Kỳ/Triều Ca
- Công thức và tỉ lệ giữ đúng VNG, ví dụ:

| Bí kíp | Nguyên liệu | Tỉ lệ |
|---|---|---|
| Hoành Không Trảm | 1 Bạch Không Thư + 1 Mảnh Hồng Thủy Tinh | 2/10 |
| Lôi Phong Giáp | 2 Lam Không Thư + 1 Hồng Thủy Tinh | 2/10 |
| Khuynh Thành Nhất Kích | 1 Hoàng Không Thư + 3 Hồng Bảo Thạch | 1/10 |
| Bàn Cổ Khai Thiên | 1 Bạch Không Thư | 100% |

- Không Thư mua ở tiệm IB (tab Cường hóa / Tạp hóa, dòng 141–144). Hồng Thủy Tinh có ở `goods.txt`. Mảnh Hồng Thủy Tinh và Hồng Bảo Thạch lấy từ rơi đồ hoặc ghép.
- **Trình tự an toàn:**
  1. Cần 3 ô trống trong hành trang.
  2. Kiểm tra đủ số lượng.
  3. Lấy thủy tinh/bảo thạch trong hành trang (có đếm). Lấy thiếu thì trả lại và báo "phải để trong hành trang".
  4. Lấy Không Thư (có đếm). Lấy thiếu thì trả lại toàn bộ.
  5. Tung tỉ lệ. Thành công: nhận **bí kíp 6/1/62xxx** (click phải dùng được ngay). Thất bại: nhận vật phẩm an ủi VNG theo màu Không Thư (Hồi Thành Phù, Thổ Linh Phù, Tuyết Quái Phù ×3 …).
- **Đổi sách cũ:** mục "Đổi sách kỹ năng cũ thành bí kíp" đổi 1:1 mọi sách loại 7 trong hành trang. Nếu không thêm được bí kíp thì trả lại sách cũ.
  - Nguồn sách cũ: quà, nhiệm vụ VNG (khoảng 14 script còn `AddNormalItem(7, …)`), hoặc sách có sẵn trong hành trang.

### 2.4 Tệp
- **Mới, trong `Server\script\phongthan\`:**
  - `lib\pt_bikip.lua`
  - `item\bikip_<3..51, 62, 128, 450..458>.lua` (60 file)
  - `item\bikip_sach7.lua`
  - Toàn bộ là ASCII, chữ Việt viết bằng mã thoát TCVN3. Sinh từ `scratchpad\bikip\gen_bikip.py`.
- **Plug-in `scratchpad\ptfix\extra_bikip.py`**, đọc dữ liệu `scratchpad\bikip\bikip_data.json`:
  - `magicscript.txt` +60 dòng;
  - `goods.txt`: 80 dòng loại 7 được đổi;
  - `buysell.txt`: gỡ ô Vũ Sĩ, thêm 3 dòng tiệm;
  - Chỉ phía Server: nối thêm phần ghi đè menu vào `\script\西岐\教师.lua` và `\script\朝歌\教师.lua`. Hai đường dẫn GBK này phải nằm trong PAK. Phần nối thêm gồm `main`, `books` và `PTBK_SHOP_SALE`; `songxin`, `yes_2` và `Sale(14)` giữ nguyên.
- Không sửa file dự án nào có sẵn, nên không cần backup. `ky_nang_quyen_*.lua` và `sach_kn_*.lua` (61011–61019) giữ nguyên.

### 2.5 Kiểm tra
- **Mô phỏng Lua 4** (`qtest\sim_bikip.lua`, `out_bikip.txt`): mọi tình huống đều đạt.
  - Học: sai phái, thiếu cấp, học được, đã có, kỹ năng cấp 0, sách sống, sách đệ tử 453, sách loại 7 qua `bikip_sach7`, sách lạ.
  - Menu Võ sư: mở Sale 66/67/68 theo phái.
  - Đóng sách: thiếu đồ, túi chỉ còn 2 ô, thành công, thất bại (nhận quà an ủi), thủy tinh nằm trong rương (không mất gì), sai phái, Khuynh Thành, Bàn Cổ, Lôi Phong Giáp.
  - Đổi sách cũ: 3 cuốn; không có cuốn nào; thêm bí kíp lỗi thì trả lại sách cũ.
- **`qtest\sim_bikip_all.lua`:** cả 60 script bí kíp nạp được, học được và mất đúng 1 cuốn.
- **Build thử** `scratchpad\bikip\ptfix_test.pak` (Server, 406 mục, đủ 5 plug-in) và `ptfix_test_client.pak`:
  - `goods`, `buysell`, `magicscript` giống hệt nhau giữa Server và Client;
  - mô phỏng KBuySell: Sale 8/9/10/14/19/66/67/68 đúng vị trí, không lệch.

### 2.6 Giới hạn, cần C++ (đề xuất cho coordinator)
1. **Click phải sách loại 7 cũ:** trong `KItemList::ExecuteScript`, với `item_skillbook` hãy gọi `\script\phongthan\item\bikip_sach7.lua` (`main(nIdx)`). Lua đã sẵn.
2. **`KBuySell::Init`:** khi một dòng `goods.txt` không sinh được, nên giữ ô trống thay vì `continue`, để chỉ số không lệch.
   - Hiện còn 46 dòng hỏng (dòng 933 loại 4, và 45 dòng IB từ 1036 trở đi). Các tiệm dùng hàng sau dòng 933 vẫn lệch.
   - Nên thêm nhánh `item_skillbook`.
3. **`GenerateShopItem` với magicscript** dùng cột 2 của `goods.txt` làm khóa. Các dòng VNG "6 1 X" vì vậy hiện vật phẩm khóa 1 (Thái Ngự Đơn) thay vì X, ví dụ 本样变身符 ở tiệm Võ sư.
   - Bí kíp ghi khóa ở cột 2. Nếu sửa C++, hãy giữ quy tắc: cột 2 khác 1 thì dùng cột 2 làm khóa.

## Phần 3: Hành động (kiểm tra trong game)
- [ ] Coordinator build ptfix chính thức cho Server **và** Client (có `extra_bikip.py`), cài, rồi người dùng khởi động lại server và game. Script loose mới chỉ được đăng ký khi server khởi động.
- [ ] Giáp Sĩ cấp 6 trở lên ở Tân Thủ thôn: Võ sư → Học kỹ năng → tiệm có "Bí Kíp Tế Huyết Trảm" … Mua 1 cuốn, click phải: học được, sách mất.
- [ ] Click lại một bí kíp đã học: báo "đã lĩnh hội", sách còn.
- [ ] Võ sư Tây Kỳ → "Mua bí kíp hệ phái": mở tiệm đúng phái (18/26/20 món). Mua một cuốn cấp cao, kiểm tra giá.
- [ ] Mua 1 Bạch Không Thư ở tiệm IB, mang theo 1 Mảnh Hồng Thủy Tinh → Võ sư Tây Kỳ → "Đóng sách (ép bí kíp)" → Hoành Không Trảm. Thử vài lần: thành công ra bí kíp; thất bại ra Hồi Thành Phù/Thăm/Thổ Linh Phù.
- [ ] Để thủy tinh trong rương rồi ép: phải báo "để trong hành trang" và không mất Không Thư.
- [ ] Có sách loại 7 cũ (ví dụ phần thưởng nhiệm vụ) → "Đổi sách kỹ năng cũ thành bí kíp" → click phải học.
- [ ] Mở thử vài tiệm khác (vũ khí `Sale(2)`, thời trang …). Món hiện ra nay phải khớp tên VNG; trước đây bị lệch.

## Phần 4: Tài liệu tham khảo
- **Mã nguồn:**
  - `Core\Src\KItemList.cpp` (`NowEatItem` 1557, `ExecuteScript` 4771);
  - `KBuySell.cpp` (`GenerateShopItem` 50, `Init` 134–195);
  - `KBasPropTbl.CPP` (`KBPT_MagicScript::LoadRecord` 875, `KBPT_SkillBook` 1418);
  - `ScriptFuns.cpp` (`LuaAddMagic` 3533, `LuaGetItemPartByID` 3809, `LuaDelNormalItemCompat` 11191);
  - `PhongThanQuestItemTuple.h`.
- **Dữ liệu VNG:**
  - `vng00.pak`: `\settings\item\001\skillbook.txt`, `\settings\goods.txt`, `\settings\buysell.txt`;
  - script Võ sư `\script\西岐\教师.lua` (id a1175c2f), `\script\朝歌\教师.lua` (b081bc9e), Tân Thủ thôn `技能教师`.
- **Liên quan:**
  - `ky-nang-chuyen-sinh-60-120-180-phong-than-20261001.md` (sách 61011–61019);
  - `ky-nang-de-tu-di-nhan-phong-than-20261002.md` (kỹ năng 450–461);
  - `goi-va-ptfix-pak-phong-than-20260929.md` (cột đệm `buysell`).
- **Công cụ:**
  - `scratchpad\bikip\gen_bikip.py`, `verify_pak.py`, `parse_vosu.py` (bảng công thức `recipes_vng.json`), `simgoods.py`;
  - `qtest\sim_bikip.lua`, `sim_bikip_all.lua`.
