# M2 - Kiểm thử runtime Windows cách ly (chưa nghiệm thu)

> Cập nhật 14/10/2026. Đây là **quy trình UAT cần thực hiện**, không phải
> bằng chứng game đã chạy. [Roadmap](MASTER_ROADMAP.md) là nguồn trạng thái chính.

## Bằng chứng đã có

- [Full build #38531158753](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38531158753): 19/19 C++ projects, 22/22 PE32 x86 EXE/DLL mới, SHA-256.
- [Static DLL import audit #38546154123](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38546154123): 22/22 imports/delay-load analyzed, không có import DLL nội bộ sai Client/Server role.
- **Chưa kiểm chứng ở VM**: `dinput8.dll`, `odbc32.dll`, `msvcp140.dll`, `vcruntime140.dll`. Hai DLL cuối cần kiểm tra bộ Visual C++ Redistributable **x86** tương ứng. Import audit **không** kiểm tra exports, loader, COM, DirectX initialization hoặc gameplay.

## Quy tắc bảo vệ dữ liệu

- Chạy trên **Windows VM thử nghiệm có thể xóa/revert**, được cách ly mạng công khai; chỉ dùng source/runtime **bản sao** và database/tài khoản/nhân vật thử nghiệm.
- Không dùng production SQL, PAK/saves gốc làm môi trường ghi dữ liệu; không mount secrets, token GitHub hoặc credentials thật. Sao lưu và lập hash trước khi thử.
- Chỉ chạy native EXE trên máy/runner Windows tin cậy đã khóa quyền truy cập; **không** chạy PR fork hoặc mã không tin cậy trên self-hosted runner có dữ liệu game.
- Không tự triển khai chính bản build 22/22 này lên production. Staging cũ và `PhongThanRuntime-State` gốc phải giữ nguyên.
- Không upload full log, `.ini` chứa credentials, database, character save hoặc PAK lên Actions artifacts.

## Điều kiện tiền đề trên Windows VM

1. Máy hỗ trợ **x86 PE32**; MSVC runtime **x86** phù hợp được cài bằng nguồn chính thức. Kiểm tra sự hiện diện/version của `msvcp140.dll`, `vcruntime140.dll`, `dinput8.dll`, `odbc32.dll` trong môi trường đích (không lấy ngẫu nhiên DLL từ Internet).
2. Kiểm tra môi trường đồ họa/DirectX phù hợp trước khi thử Client; có thể cần các component legacy DirectX 9 của ứng dụng. Không suy ra tính tương thích chỉ từ CI compile.
3. Chuẩn bị SQL LocalDB và một **account database riêng cho UAT**; xác nhận cấu hình localhost và chỉ mở port cho máy thử nghiệm.
4. Tạo workspace/runtime **copy** riêng theo [RUNTIME_CONTENT_MANIFEST.json](../PhongThanSource/Deploy/RUNTIME_CONTENT_MANIFEST.json), gồm dữ liệu map/script/test fixtures cần thiết. Không copy dữ liệu nhân vật thật.
5. Đối chiếu manifest SHA-256 của 22 file xuất từ cùng một lần build. Kiểm tra tất cả EXE/DLL và dependent DLL có đúng kiến trúc/phiên bản trước khi khởi động; kiểm tra import/export thực trên VM.

## Kịch bản nghiệm thu

| Gate | Hành động | PASS khi |
| --- | --- | --- |
| R1 - Loader | Từ runtime bản sao, thử nạp các binary/phụ thuộc trên VM và ghi diagnostic | Không có missing DLL/entry point, lỗi x86/x64 hoặc lỗi init |
| R2 - Server | Từ **bản sao toàn bộ repo**, chạy `PhongThan-ChayTatCa.cmd` (không tham số để chưa mở Client) | Đủ `Goddess.exe`, `PhongThanAccountServer.exe`, `PhongThanRelay.exe`, `Bishop.exe`, `GameServer.exe` chạy đúng và giữ trạng thái |
| R3 - World | Đọc log **mới tạo sau thời điểm khởi động** và health check của `Start-NativeServer.ps1` | `WORLD_READY bishop_pid=<current PID> service=<expected> maps=102`; `READY_FOR_LOGIN` khớp phiên hiện tại |
| R4 - Account | Sử dụng tài khoản UAT, xác nhận login, tạo nhân vật thử và relogin | Không crash, không có lỗi đọc/ghi nhân vật |
| R5 - Persistence | Di chuyển bản đồ, test item/quest trong tài khoản UAT; logout/relogin | Vị trí, túi đồ, trạng thái quest giữ đúng; không mất hoặc nhân đôi item |
| R6 - Recovery | Stop/restart toàn bộ dịch vụ trong VM; thử reconnect và phục hồi từ backup UAT | Không bị partial startup, không mất dữ liệu; có thể phục hồi bằng snapshot |

> Lưu ý: `PhongThan-ChayTatCa.cmd game` mở cả Client và có thể chạy các bước
> setup/patch. Chỉ dùng khi **toàn bộ repo và runtime/database là bản sao**,
> không phải workspace gốc hoặc máy production.
> Launcher báo thành công chưa đủ: phải có R1-R6 và bằng chứng quan sát thực tế.

## Cách ghi nhận kết quả

- Ghi Windows version/architecture, VC++ x86 runtime version, DirectX component, SQL LocalDB version, 22-binary manifest SHA-256, commit và thời điểm bắt đầu.
- Ghi từng gate R1-R6 **PASS / FAIL / BLOCKED**, lý do ngắn và log **đã ẩn credentials / thông tin cá nhân**.
- Chỉ đánh dấu M2 `Runtime PASS` khi toàn bộ gate bắt buộc thành công trong **cùng một VM UAT**. Nếu thiếu dữ liệu/SDK/database thì đánh dấu BLOCKED, không hạ tiêu chí.
- Sau UAT, **dừng toàn bộ tiến trình và rollback/revert VM snapshot**. Dữ liệu và runtime gốc không thay đổi.

## Bước tiếp theo

Triển khai **test-only runtime packaging + loader smoke**, ưu tiên kiểm tra đủ 4 DLL được import audit liệt kê, sau đó chạy server bằng một bản sao dữ liệu có kiểm soát. Không bật tự chạy native EXE của fork PR trên GitHub-hosted CI.
