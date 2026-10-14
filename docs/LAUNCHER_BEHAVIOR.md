# Launcher Windows — hành vi và giới hạn

Các launcher `PhongThan-*.cmd` tại root chỉ là **điểm vào**. Chúng **không** chứng minh game đã build đầy đủ hay chơi được; xem [ma trận nghiệm thu](TEST_MATRIX.md) và [master roadmap](MASTER_ROADMAP.md). Chỉ chạy trong Windows VM cách ly với dữ liệu thử, sau khi đã kiểm tra chữ ký và nguồn gốc của EXE/MSI.

| Launcher | Hành vi | Khi lỗi |
| --- | --- | --- |
| `PhongThan-CaiDat.cmd` | Chạy `AdminWeb/PhongThan-Setup.ps1 -Step all` (có thể cài LocalDB, khôi phục DB) | Trả về exit code khác 0, giữ màn hình để xem log |
| `PhongThan-ChayTatCa.cmd` | Khôi phục PAK thiếu bằng PowerShell (không cần Python), chuẩn bị database, chạy 5 native services, mở admin; **không** tự vá client | Trả về lỗi nếu DB/server không sẵn sàng hoặc thấy server chỉ chạy một phần |
| `PhongThan-ChayTatCa.cmd game` | Như trên, thêm kiểm tra/vá client rồi khởi chạy `Game.exe` | Chặn nếu thiếu EXE hoặc script vá báo lỗi |
| `PhongThan-MoGame.cmd` | Kiểm tra `Game.exe`, gọi script vá tương thích, rồi mở client | Mã 2 nếu thiếu EXE; mã 1 nếu vá/mở thất bại |

Khôi phục PAK đọc `archive/PT_EXACT_ZIP_MANIFEST.csv` và chỉ ghép khi file chưa tồn tại; dữ liệu mới được xác minh kích thước và SHA-256 trước khi đưa vào runtime. Nếu thiếu phần hoặc hash sai, launcher dừng an toàn. File PAK đã tồn tại được kiểm tra kích thước để tránh đọc lại nhiều GB mỗi lần chạy; kiểm tra toàn bộ SHA-256 bằng `powershell.exe -NoProfile -File .\tools\Restore-SplitPaks.ps1 -RepoRoot . -VerifyExisting`. Không sửa PAK trong khi server đang chạy.

Các file `.cmd` cài đặt và chạy tất cả có `pause` như trước để giữ cửa sổ sau khi hoàn thành/lỗi; mã thoát được chuyển tiếp khi đóng cửa sổ. Lệnh `start` của Windows chỉ xác nhận yêu cầu tạo tiến trình, **không** xác nhận client đã vào game thành công.

## Server đang chạy một phần

`PhongThan-RunAll.ps1` kiểm tra tên của đủ **5** executable native (`Goddess.exe`, `PhongThanAccountServer.exe`, `PhongThanRelay.exe`, `Bishop.exe`, `GameServer.exe`) trong thư mục staging server. Nếu chỉ thấy một phần, launcher báo lỗi và không tự bật chồng server mới. Đối với lần khởi động mới, script native phải trả về `READY_FOR_LOGIN` sau tín hiệu `WORLD_READY`. Khi đủ 5 process đã chạy từ trước, kiểm tra tên tiến trình **không thay thế** kiểm tra health, port, log, dữ liệu nhân vật hoặc readiness thực tế. Cần xác minh `WORLD_READY` với đúng Bishop PID trong log.

**Đã kiểm tra chuỗi gọi lồng nhau:** `PhongThan-ChayTatCa.cmd` → `PhongThan-RunAll.ps1` → `Start-NativeServer.ps1`. Server-only **không được gọi** `PhongThan-ClientPatch.ps1`. `PhongThan-RunAll.ps1` phát hiện server đang chạy một phần và từ chối **trước khi** chuẩn bị DB hoặc vá client; nếu đủ 5 service, launcher bỏ qua setup/restore DB. `Start-NativeServer.ps1` cũng kiểm tra tiến trình trước LocalDB/khôi phục DB và dừng ngay nếu lệnh setup database trả mã lỗi. Các thay đổi này là hàng rào bảo vệ startup, **không thay thế nghiệm thu save/relogin**.

## Giới hạn bảo toàn dữ liệu

- Chế độ server/admin-only không gọi byte-patch client. Chỉ hai đường mở client nêu trên mới kích hoạt script vá hiện có; script này **có thể ghi lại binary runtime và manifest** và cần được chạy trên **bản sao phục dựng**, không dùng dữ liệu live.
- Khi phát hiện lỗi vá, launcher ngừng tiếp tục nhưng **không tự rollback** các byte đã thay đổi trước khi xảy ra lỗi. Kiểm tra thư mục `_backup/client-patch/`, manifest và hash trước khi thử lại.
- Không coi việc script vá trả code 0 là kiểm chứng đầy đủ chữ ký/version của mọi binary; script có thể bỏ qua file bị khóa hoặc không khớp phiên bản. Không triển khai public từ kết quả này.
- Không kill force hoặc tự khởi động lại một cụm đã chạy một phần nếu có thể tồn tại phiên người chơi; cần thao tác vận hành thủ công theo quy trình sao lưu.

## Web Admin: thieu PakEntryExtract.exe

Web Admin dung `PhongThanSource/Output/Tools/PakEntryExtract.exe` de trich bang item tu PAK. File nay la output build, khong duoc commit trong repo. Khi chua co file, Admin tu nap 15 bang `PhongThanRuntime-Staging/Server/settings/item/001/*.txt` (loose fallback), hien canh bao va **khoa phat vat pham/tao ma item** de tranh sai item ID vi game uu tien du lieu trong PAK. Khong coi bang loose la tuong duong PAK.

De bat lai tinh nang phat vat pham dung ma PAK, build tool tu source bang `PhongThanSource/Build/Build-PakEntryExtract.ps1` (can VC6 CL.EXE va `Sources/Engine/Release/Engine.lib`). Khong can build tool de mo cac trang Admin khong phu thuoc ma item.

Neu Web Admin gap loi khi khoi dong, cua so Admin PowerShell se giu mo va ghi `PhongThanRuntime-State/logs/admin-startup.log`. Thay doi nay khong tu dong khoi dong lai 5 native services hoac sua database.
