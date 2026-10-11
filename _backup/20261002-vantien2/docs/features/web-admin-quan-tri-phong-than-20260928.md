# Tính năng: Web quản trị local (phát đồ, lệnh bài, tiền đồng, kỹ năng, level, thú cưỡi, sự kiện, boss)

> Dự án: Phong Thần (bản local) · Ngày yêu cầu: 2026-09-28 (bổ sung tài liệu 2026-09-29) · Trạng thái: **Đang dùng**. Mở bằng `PhongThan-Admin.cmd` hoặc `PhongThan-ChayTatCa.cmd`, địa chỉ `http://localhost:8765/`.

## Phần 1: Tổng quan
- **Yêu cầu:**
  - Web chạy trên máy này để tạo sự kiện, phát đồ, tạo boss.
  - Dùng "toàn bộ", tác động ngay (real-time), viết bằng PowerShell + HTML, chỉ truy cập từ máy này.
- **Cách hoạt động:**
  - Web (PowerShell HttpListener) ghi lệnh Lua vào `Server\admin_bridge\pending.lua`.
  - `servertimer.lua` chạy lệnh vào giây 00 mỗi phút, ghi kết quả vào `result.log`, danh sách online vào `online.txt` và nhịp sống vào `heartbeat.txt`.
  - Mọi yêu cầu API phải có header `X-PT-Token`, để trang web khác không gửi lệnh vào được.
- **Mã vật phẩm lấy từ bảng trong PAK**, vì GameServer đọc PAK trước file rời. Khi khởi động, web tự trích 15 bảng vào `AdminWeb\data\pak_item_tables`.

## Phần 2: Chi tiết các tab
| Tab | Chức năng | Ghi chú kỹ thuật |
|---|---|---|
| Tổng quan | Trạng thái 5 tiến trình server, người chơi online (cấp, phái, vị trí) | `online.txt`, `heartbeat.txt` |
| Phát đồ | Tìm 48.554 vật phẩm theo tên/mã, phát cho 1 người hoặc tất cả; nút **Túi tân thủ (lệnh bài admin)**; **Tiền đồng** = vật phẩm "Xu" (nhiệm vụ 47, cộng dồn 100/ô); **Kim Nguyên Bảo** (nguyên liệu 1183); tặng lượng, kinh nghiệm; **tăng level 1–200** | `SetLevel` làm mất kỹ năng (`RollBackSkills`), nên web lưu cấp kỹ năng 1–60 rồi khôi phục |
| Bí kíp / Kỹ năng | Chọn phái (Giáp Sĩ 27–42, Đạo Sĩ 3–26, Dị Nhân 43–51), dạy/đặt cấp 1–10, phát Kỹ Năng Quyển 5624–5626 | Kiểm tra đúng phái |
| Thú cưỡi | Chỉ hiện thú cưỡi đúng phái của nhân vật được chọn (Giáp Sĩ 103, Đạo Sĩ 111, Dị Nhân 102 mẫu) | Yêu cầu loại 37 |
| Đồ lục | Xem `do-luc-he-phai-phong-than-20260928.md` | |
| Vũ khí lục, Đồ max & Pháp bảo | Xem `vu-khi-luc-do-max-cuong-hoa-phong-than-20260928.md` | |
| Boss / NPC | Tạo boss/NPC cạnh người chơi hoặc tại tọa độ; xóa boss đã tạo | `PTAdm_SpawnAt/SpawnNear/ClearSpawned` |
| Thông báo | Gửi thông báo toàn server | |
| Sự kiện | Hẹn giờ theo ngày trong tuần, chuỗi hành động (phát đồ, thông báo, boss) | `AdminWeb\data\events.json` |
| Tài khoản | Tạo tài khoản, đổi mật khẩu (cả cấp 2), đặt điểm xu tài khoản (ExtPoint, Kỳ Trân Các) | SQL LocalDB `account` |
| Lịch sử lệnh | Trạng thái từng lệnh: Đang chờ / Thành công / Lỗi | `result.log` |
| Cài đặt server | Xem `cai-dat-server-localdb-phong-than-20260929.md` | |

- **Tài khoản `lichnt`:** đã tạo ngày 2026-09-28 và được thêm vào `[Grant] Accounts` của `PhongThanStarterBag.ini` để tự nhận Túi tân thủ.
- **Tra cứu mã vật phẩm offline:** `Tra-cuu-vat-pham.txt` (48.554 mục).
- **Bản sao lưu:** `_backup\20260928-admin-web` đến `-v7`, và `_backup\20260929-admin-web-v8`.

## Phần 3: Hành động
- [ ] Mở web, chọn nhân vật đang online, rồi phát đồ. Món đồ vào túi trong tối đa 1 phút.
- [ ] Lệnh bị lỗi: xem cột "Chi tiết" ở tab Lịch sử lệnh.

## Phần 4: Tài liệu tham khảo
- `AdminWeb\PhongThan-Admin.ps1` (bắt buộc giữ ASCII), `AdminWeb\index.html`, `Server\script\servertimer.lua`
