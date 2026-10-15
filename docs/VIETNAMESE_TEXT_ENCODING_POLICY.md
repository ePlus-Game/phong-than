# Vì sao Phong Thần và Web Admin còn tiếng Việt không dấu?

## Kết quả rà soát (15/10/2026)

**Đây là hai kiểu xử lý khác nhau, không được gộp thành một quy tắc UTF-8.**

1. **Web Admin** (`AdminWeb/index.html`) là HTML UTF-8, hỗ trợ hiển thị
   đầy đủ dấu tiếng Việt. Tuy nhiên, API chạy bằng `AdminWeb/PhongThan-Admin.ps1`
   (Windows PowerShell **5.1**) chứa các chuỗi thông báo **ASCII không dấu**
   nhằm tránh lệ thuộc code page của máy. Khi nút phát đồ, quản lý tài khoản,
   backup... trả về `error`, `message` hay lịch sử lệnh, trình duyệt trước
   đây hiển thị nguyên văn các chuỗi không dấu đó.
2. **Game Client** (`PhongThanRuntime-Staging/Client`) sử dụng font bitmap
   ASF `14.fnt`, `16.fnt`, `18.fnt` và **mã TCVN3 một byte** ở nhiều
   file cũ. Một số text hiện không dấu thực sự là ASCII, chẳng hạn
   `22=Ban co muon thoat khoi Phong Than Online?` trong `Ui/Setting.ini`.
   Một số khác **có dấu nhưng hiển thị như `MÆc ®Þnh` khi mở bằng UTF-8**:
   không phải mọi trường hợp đều là thiếu bản dịch.
3. Các tên tài nguyên, `Lua` function, tên bộ phận và ID như
   `MagicScript`, `Server`, `NPC`, `PAK`, `role_...`, `NATIVE_DEPLOYMENT.json`
   là **định danh kỹ thuật**, không đổi hay dịch theo giao diện.
4. Các phím tìm kiếm không dấu và tên tài khoản **không dấu** có thể là
   **giới hạn đầu vào có chủ ý**, không phải lỗi bản dịch.

## Đã sửa trong đợt này

- Giao diện Web Admin đổi nhãn `CONTROL CENTER`, `Menu`, `Level`
  còn sót thành tiếng Việt.
- Thêm một bảng dịch **chỉ áp dụng lúc HIỂN THỊ**, gồm hơn 50 thông báo
  từ API và lỗi có tham số. `toast`, thông báo API, lịch sử lệnh và
  báo lỗi xác minh PAK đều sử dụng chung hàm `ptViMessage`.
- **Không sửa** payload Lua, event, token, account ID, PAK, SQL hoặc
  chuỗi được gửi/ghi vào GameServer; các câu chưa biết giữ nguyên,
  không tự động đoán dấu tiếng Việt.
- Chỉ thay chuỗi xác nhận thoát game `InfoString[22]` trong
  `Client/Ui/Setting.ini` thành **"Bạn có muốn thoát khỏi Phong Thần Online?"**
  bằng byte TCVN3 gốc; **không** chuyển file sang UTF-8. Mọi byte ký tự
  đặc biệt mới đều phải có bitmap trong cả ba font (đã kiểm tra trong CI).

## Còn lại

- Thông báo backend không nằm trong bảng dịch, mô tả lệnh động chưa có
  quy tắc rõ ràng, và text từ NPC/nhiệm vụ/chat có thể vẫn không dấu.
- Gói PAK đang được game ưu tiên đọc có thể **ghi đè nội dung INI loose**;
  `git pull` không đảm bảo màn hình game đổi ngay.
- Bản fix UI phải được mở lại **Web Admin**, không cần khởi động lại SQL
  hay GameServer. Bản sửa trong Client cần xác minh đường nạp tài nguyên
  thật và ảnh trước/sau; không tự ý chỉnh sửa PAK.
- Theo dõi font/bảng mã game tại
  [Issue #80](https://github.com/ePlus-Game/phong-than-truyen-ky/issues/80).
  Chỉ đóng issue khi các màn hình đăng nhập, NPC, vật phẩm và chat được
  nghiệm thu trên Windows.

## Kiểm thử

`node --test tests/admin_locale.test.cjs tests/admin_workspace.test.cjs`

Bộ kiểm thử kiểm tra nhãn giao diện, thông báo API và đường dẫn không bị
đổi, cũng như byte TCVN3 và glyph thực tế trong các font ASF 14/16/18.
Không cần Python. Đây là **regression source/byte**, không phải ảnh
nghiệm thu gameplay.

## Cấu trúc mới: một nguồn bản dịch UTF-8 cho Web Admin

Thay vì tiếp tục viết các câu tiếng Việt không dấu trong PowerShell rồi duy
trì một bảng sửa riêng trong JavaScript, Web Admin sử dụng
`AdminWeb/locales/vi-VN.json` làm **nguồn nội dung duy nhất**:

- `messages`: câu chính xác bằng tiếng Việt có dấu.
- `patterns`: thông báo có biến như tên nhân vật, ID lệnh, đường dẫn hoặc
  mã vật phẩm, dùng `{0}`, `{1}` cho dữ liệu thực tế.
- `AdminWeb/Ui-Localization.ps1`: Windows PowerShell 5.1 đọc file bằng
  **UTF-8 được khai báo tường minh** (không phụ thuộc code page), đồng thời
  dịch các trường thông báo của API ngay trước khi trả JSON.
- Trang `index.html` nhận cùng dữ liệu JSON đã được escape an toàn để
  hiển thị lịch sử hoặc xử lý tương thích với các API cũ. Không còn bản
  dịch nhân đôi nằm trong HTML.

**Chỉ các trường hiển thị** như `message`, `error`, `desc`, `detail`
và lý do lỗi PAK được dịch trong **bản JSON trả về**. Dữ liệu trong bộ nhớ,
các file trạng thái, ký tự tên nhân vật, SQL, Lua, PAK và ID không được sửa.
Các câu chưa xác nhận nghĩa chính xác vẫn giữ nguyên, tránh tự đoán dấu.

Thêm thông báo mới: viết tiếng Việt có dấu tại
`AdminWeb/locales/vi-VN.json` và thêm regression test. Không được tạo
thêm bảng dịch cố định tại HTML hay thay đổi byte trong dữ liệu game.

**Với Client**: file TCVN3 và bitmap FNT giữ nguyên kiến trúc cho đến khi
có lộ trình Unicode cho toàn bộ engine/renderer. UTF-8 của Web Admin không
có nghĩa rằng có thể đưa Unicode trực tiếp vào các file PAK của game.

Kiểm thử:
`node --test tests/admin_locale.test.cjs tests/admin_workspace.test.cjs`
và Windows PowerShell 5.1:
`powershell.exe -NoProfile -File tests/Test-AdminLocalization.ps1`.
