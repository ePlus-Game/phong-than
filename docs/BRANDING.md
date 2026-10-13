# Phong Thần Truyền Kỳ — tên hiển thị

Tên game: **Phong Thần Truyền Kỳ** (PTTK).

| Ngữ cảnh | Tên |
|---|---|
| README, tài liệu, giao diện Web Admin | `Phong Thần Truyền Kỳ` |
| Client C++/INI và cửa sổ lệnh ASCII | `Phong Than Truyen Ky` |
| GitHub repository | [`ePlus-Game/phong-than-truyen-ky`](https://github.com/ePlus-Game/phong-than-truyen-ky) |

## Phạm vi

Tên hiển thị được cấu hình qua [`tools/build_branding_overlay.py`](../tools/build_branding_overlay.py). Công cụ đọc tệp đầu vào tại repository và xuất các tệp chỉnh sửa vào **thư mục bên ngoài** checkout.

| Tệp đầu vào | Thay đổi trong bản overlay |
|---|---|
| `PhongThanRuntime-Staging/Client/Ui/Setting.ini` | Tên game, thông báo thoát game |
| `PhongThanRuntime-Staging/Client/serverlist.ini` | Tên hai nhóm máy chủ; giữ nguyên tên máy chủ, IP |
| `PhongThanSource/Sources/GameClient/PhongThanClient.cpp` | Default game name và tiêu đề cửa sổ client sau khi build |
| `AdminWeb/index.html` | Browser title và tiêu đề trang |
| `PhongThan-Admin.cmd`, `PhongThan-CaiDat.cmd`, `PhongThan-ChayTatCa.cmd` | Tiêu đề cửa sổ console |
| `PhongThan-BangDieuKhien.cmd` | Tiêu đề cửa sổ mở bảng điều khiển |
| `PhongThanSource/Deploy/PhongThan-Control.ps1` | Tiêu đề form quản lý server/client |
| `PhongThanSource/Deploy/PhongThan-AccountForm.ps1` | Tiêu đề form tạo tài khoản |

Đường dẫn, tên file thực thi, DLL, PAK, map, NPC, chuỗi kết nối, `script/phongthan/*` và định danh giao thức vẫn giữ nguyên. Các file trong `PhongThanSource/` và `PhongThanRuntime-Staging/` không bị thay trực tiếp bởi PR đổi tên.

## Tạo bản hiển thị tên mới

Chạy từ thư mục gốc repository bằng Python 3.10+:

```powershell
# Xem danh sách thay đổi, chưa ghi file
python tools/build_branding_overlay.py --output-dir D:\PhongThanTruyenKy-Branding

# Xuất các tệp đã thay nhãn ra thư mục bên ngoài repository
python tools/build_branding_overlay.py --output-dir D:\PhongThanTruyenKy-Branding --write

# Kiểm tra tên và các ngữ cảnh chỉnh sửa
python -m unittest discover -s tests -p test_branding_overlay.py -v
```

Hoặc vào [GitHub Actions](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/workflows/legacy-source-audit.yml), chọn run thành công và tải artifact `phong-than-truyen-ky-branding-overlay`.

Để sử dụng, áp các tệp trong overlay lên **bản sao** client/source theo đúng đường dẫn tương đối, rồi build lại client Windows x86. Chỉ thay `Setting.ini` hoặc `serverlist.ini` không thay được mọi chuỗi có sẵn trong EXE hay tài nguyên PAK.

## Kiểm tra sau khi build

1. Màn hình chọn máy chủ hiển thị tên nhóm mới; địa chỉ và tên máy chủ không đổi.
2. Thanh tiêu đề game và hộp thoại thoát game hiển thị `Phong Than Truyen Ky`.
3. Web Admin và các form quản trị hiển thị tên tương ứng.
4. Đăng nhập, tạo nhân vật, chọn máy chủ và thoát game không thay đổi chức năng.

Logo, hình nền đăng nhập, SPR và video vẫn sử dụng tài nguyên hiện có. Việc chỉnh sửa hình ảnh là phần riêng, không nằm trong bản đổi chuỗi này.
