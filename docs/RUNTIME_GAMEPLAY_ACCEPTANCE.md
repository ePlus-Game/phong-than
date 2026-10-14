# Windows Runtime & Gameplay E2E — Acceptance Plan

> **Trạng thái:** CHƯA NGHIỆM THU. Bản cập nhật 14/10/2026, sau hotfix EXP [PR #70](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/70). Kế hoạch chạy thử nằm tại [Issue #71](https://github.com/ePlus-Game/phong-than-truyen-ky/issues/71).

## Mục tiêu và ranh giới bằng chứng

GitHub Actions đã **PASS** các bài kiểm tra C++ EXP, Core, Server, Client và 22/22 binary Windows x86. Những kết quả này chứng minh compile/link và kiểm tra tĩnh, **không xác nhận khởi động được 5 dịch vụ, mở map, login hoặc save/relogin**.

| Gate | Bằng chứng | Trạng thái |
| --- | --- | --- |
| EXP compile + 200-row server/client data test | [Run #38564658247](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38564658247) | PASS |
| Core modules x86 | [Run #38564658059](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38564658059) | PASS |
| Native Server x86 | [Run #38564658097](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38564658097) | PASS |
| Native Client x86 | [Run #38564658060](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38564658060) | PASS |
| Combined 22 binaries | [Run #38564658067](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38564658067) | PASS |
| Clean Windows loader/import | Chưa có bằng chứng VM | BLOCKED |
| 5 services/world maps ready | Chưa có bằng chứng VM | BLOCKED |
| Client login, quest, save/relogin | Chưa có bằng chứng VM | BLOCKED |
| EXP 129→132 và 199→200 runtime | Chưa có bằng chứng VM | BLOCKED |

## 1. Chuẩn bị môi trường thử an toàn

- Dùng VM Windows x86/x64 có khả năng chạy ứng dụng 32-bit, network riêng, **không trỏ tới account database, keys hoặc nhân vật production**.
- Snapshot VM và database rỗng trước test. Dùng account/role giả lập, dữ liệu mới. Bảo vệ log khỏi mật khẩu, token, SQL connection string, địa chỉ IP thật.
- Lấy binary từ quy trình build riêng đáng tin cậy, **không suy ra artifact được phát hành từ link Actions chỉ lưu hash/manifest**. Lưu commit SHA, compiler, architecture, danh sách DLL, SHA-256 và cách đóng gói.
- Giữ nguyên bản PAK/asset và runtime gốc; dùng bản sao thử nghiệm. Kiểm tra quyền sử dụng nguồn/assets trước khi phân phối.

## 1A. Kiểm tra bundle/runtime tự động (chỉ đọc)

Đã bổ sung công cụ [tools/runtime_preflight.py](../tools/runtime_preflight.py). Chạy trên bản sao **đã đóng gói đủ thư mục Client/Server**, tuyệt đối không trỏ vào runtime production. Công cụ xác minh 22 PE32/i386 (SHA-256, tên và role DLL/EXE), sự hiện diện của \`ServerCfg.ini\` và \`DataBase.ini\`, \`WorldSet.ini\` đúng 102 map, so khớp tên relay và cổng trong manifest. **Không khởi động game, mở DB, cập nhật cấu hình, thay PAK hoặc đọc mật khẩu**.

Trên Windows VM, từ thư mục checkout repository:

\`\`\`powershell
python tools/runtime_preflight.py --root "D:\PT-UAT\PhongThanRuntime-Staging" --mode runtime --manifest "PhongThanSource\Deploy\RUNTIME_CONTENT_MANIFEST.json" --expected-maps 102 --report "D:\PT-UAT\reports\runtime-preflight.json"
\`\`\`

Hoặc với bản build chỉ gồm 22 binary, chưa cấu hình chạy game:

\`\`\`powershell
python tools/runtime_preflight.py --root "D:\PT-UAT\OutputModern" --mode bundle --report "D:\PT-UAT\reports\bundle-preflight.json"
\`\`\`

**Kết quả:** \`READY_FOR_RUNTIME_TEST\` = vượt qua kiểm tra **tĩnh**, **không phải** server/world/login/gameplay PASS; \`BLOCKED\` = thiếu file, sai PE32, sai map hoặc manifest. File báo cáo chỉ chứa tên file tương đối, SHA-256, tình trạng và số map; không lưu connection string, tài khoản hay dữ liệu game. Sau khi static preflight đạt, phải thực hiện RT-01..04, GP-01..06, EXP-01..06 trong VM mới được đánh dấu Runtime PASS.

[Workflow kiểm thử công cụ](../.github/workflows/windows-runtime-preflight.yml) dùng các file PE giả để thử logic trên GitHub-hosted Windows. Workflow này **không** chạy game hoặc kiểm tra VM của bạn.

## 2. Windows loader và phụ thuộc

Audit tĩnh [P4](MASTER_ROADMAP.md) đã thấy bốn external import cần xác minh trên máy Windows: `dinput8.dll`, `odbc32.dll`, `msvcp140.dll`, `vcruntime140.dll`. Khi test, cài runtime Windows/DirectX/VC++ Redistributable từ nguồn được tin cậy rồi ghi kết quả tải từng EXE/DLL bằng Windows loader. **Không tải DLL lẻ từ nguồn không rõ ràng.**

Lệnh kiểm tra không làm thay đổi máy:

```powershell
Get-FileHash -Algorithm SHA256 .\Game.exe
Get-Item .\Game.exe | Select-Object Name,Length,LastWriteTime
Get-Process | Where-Object { $_.ProcessName -match 'Goddess|Account|Relay|Bishop|GameServer|Game' } |
  Select-Object ProcessName,Id,StartTime
Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
```

Ghi lại module nào không load, Win32 error code, thư viện còn thiếu. Không tự thay thế DLL bằng bản x86/x64 không tương thích.

## 3. Server topology (5 native services)

Các thành phần cần thử: **Goddess**, **PhongThanAccountServer**, **PhongThanRelay**, **Bishop**, **GameServer**. Xác minh dependencies/config thực tế trước khi quyết định thứ tự startup. Cho từng tiến trình chạy và xác nhận PID, trạng thái DB connection (đã lọc secrets), listener, world registration, trạng thái 102 maps. Không chấp nhận chỉ thấy process xuất hiện vài giây rồi crash là PASS.

| Mã | Tình huống | PASS khi |
| --- | --- | --- |
| RT-01 | Native EXE/DLL load | Không lỗi missing/import mismatch, x86 modules phù hợp |
| RT-02 | 5 services chạy | Mỗi service ổn định và có health/readiness thực tế |
| RT-03 | World/map registry | 102 map (nếu cấu hình chuẩn có đủ) đăng ký và có thể vào map test |
| RT-04 | Restart an toàn | Dừng từng service theo dependency, không nhân đôi session hay mất dữ liệu |

### 3A. Thu thập bằng chứng dịch vụ đang chạy (chỉ đọc)

Sau khi đã khởi động **bản sao server trên VM cách ly** bằng quy trình vận hành được kiểm soát, dùng script [Read-WindowsRuntimeEvidence.ps1](../tools/Read-WindowsRuntimeEvidence.ps1) để quan sát 5 service, PID của từng EXE, cổng TCP thực sự do PID đó sở hữu, cấu hình 102 map, và dấu \`WORLD_READY\` **mới** khớp Bishop PID/ServiceId/map count. Script chỉ đọc tiến trình/log/config và không tự bật/tắt game, không kết nối SQL. Cần tạo trước thư mục \`D:\PT-UAT\reports\` bên ngoài runtime.

\`\`\`powershell
powershell.exe -NoProfile -File tools\Read-WindowsRuntimeEvidence.ps1 -RuntimeRoot "D:\PT-UAT\PhongThanRuntime-Staging" -ManifestPath "PhongThanSource\Deploy\RUNTIME_CONTENT_MANIFEST.json" -ExpectedMapCount 102 -CheckClient -ReportPath "D:\PT-UAT\reports\live-readiness.json"
\`\`\`

- \`READY_FOR_LOGIN_CHECK\` = tất cả 5 service có một PID đúng đường dẫn, đúng cổng, và dấu WORLD_READY khớp phiên Bishop đang chạy. **Không đồng nghĩa đăng nhập hay lưu nhân vật đã PASS.**
- \`BLOCKED\` (exit code 2) = thiếu dịch vụ, thiếu cổng, sai manifest, sai map hoặc không có marker mới. Xem trường \`blockers\` của JSON để xử lý, không tự restart khi có phiên chơi thật.
- Báo cáo chỉ chứa tên dịch vụ, PID, cổng, cờ kết quả và tên lỗi; không chứa chuỗi cấu hình SQL, nội dung log, đường dẫn tuyệt đối hoặc danh tính người chơi. Chỉ dùng trên môi trường kiểm thử, tránh công khai port của server production.

Workflow [Windows live readiness evidence tool tests](../.github/workflows/windows-runtime-live-evidence.yml) kiểm thử parser marker/port với dữ liệu giả trên GitHub-hosted Windows; CI **không** tự bật 5 dịch vụ hay login. Chỉ đánh dấu RT-02/RT-03 PASS sau khi có báo cáo từ VM thật và người kiểm thử đối chiếu các cổng, logs với phiên thử.

## 4. Gameplay người chơi mới

Dùng account mới và nhân vật thử cho cả ba lớp **Giáp Sĩ ID 0, Đạo Sĩ ID 1, Dị Nhân ID 2**.

| Mã | Thử nghiệm | PASS khi |
| --- | --- | --- |
| GP-01 | Launcher/Client `Game.exe` mở và kết nối | Không crash; asset, UI và màn hình đăng nhập load được |
| GP-02 | Login + tạo 3 nghề | Class ID/name lưu đúng; có thể vào world và di chuyển |
| GP-03 | Đối chiếu NPC nhiệm vụ cấp 1 | NPC có tồn tại, nhận → hoàn thành → trả thưởng đúng 1 lần |
| GP-04 | Kỹ năng đầu tiên của từng nghề | Skill hiển thị và tác dụng thống nhất client/server |
| GP-05 | Logout/relogin | Cấp, EXP, inventory, quest progress, vị trí ổn định |
| GP-06 | Reconnect, server restart | Không rollback sai, không duplicate reward, không session mồ côi |

## 5. EXP sau PR #70

**Cap trong source:** `MAX_LEVEL=200`. Bảng dữ liệu gốc chứa 5.300.556.000 từ cấp 131–200, không vừa `int32`. Code mới **chỉ chuyển placeholder đã biết** sang mốc tương thích trong loader: **cấp 131 = 530.055.600**, **cấp 200 = 2.030.805.600**. Các dòng 1–130 giữ nguyên. Đây là chính sách cân bằng của **bản phục dựng**, không phải EXP chuẩn VNG.

| Mã | Kịch bản | PASS khi |
| --- | --- | --- |
| EXP-01 | Cấp 129→130, 130→131, 131→132 | Tăng cấp đúng, không XP âm hoặc vượt giới hạn |
| EXP-02 | Cấp 199→200, tiếp tục nhận XP | Dừng ở cấp 200; không reset EXP bất thường hoặc vượt 200 |
| EXP-03 | Nhận EXP thường, thưởng nhiều, bonus buff | Không tràn/cắt thành số âm; kết quả nhất quán |
| EXP-04 | Chuyển sinh / cộng EXP theo cấp | Không đọc ngoài mảng `MAX_TRANSLIFE_VALUE`, không mất điểm |
| EXP-05 | Save, logout, relogin tại cấp 130/131/200 | Mọi trạng thái được giữ đúng sau nạp |
| EXP-06 | Thử config sai trong môi trường dummy | Khởi tạo từ chối an toàn, không dùng `atoi` vô giới hạn |

Để hoàn tất các test cấp cao, chỉ dùng tài khoản GM/test trên VM snapshot; ghi kết quả API/GM command cụ thể sau khi kiểm chứng quyền hạn, không thử trên dữ liệu thật. **Không mở kết nối Internet/public alpha** trước khi các mốc M2/M3 đạt.

## 6. Mẫu bằng chứng và quyết định

Mỗi test lưu: `Test ID | build SHA | client/server hash | Windows/VM | database snapshot ID | input | expected | actual | pass/fail/blocked | sanitized log/screenshot ref | người kiểm tra`.

- **FAIL:** có lỗi tái hiện được, mở issue riêng với bước tái hiện và dấu vết tối thiểu.
- **BLOCKED:** thiếu VM, cấu hình test, asset hoặc quyền chạy; **không** được xem là PASS.
- **PASS:** có bằng chứng và xác minh trước/sau restart hoặc relogin với test có lưu trạng thái.
- **Gate M2/P5:** Issue #71 chỉ đóng khi RT + GP + EXP các ca bắt buộc đều đạt trên Windows VM.

## 7. Sau khi runtime PASS

1. Rà soát atomic/idempotent của giao dịch thưởng/vật phẩm (M3) trước khi mở cho người chơi thật.
2. Đối chiếu 2.703 hàng `Skills.txt`, class/skill availability và 126 NPC với gameplay đã chạy (M5).
3. Tạo dữ liệu cẩm nang đã kiểm chứng theo Giáp Sĩ/Đạo Sĩ/Dị Nhân, trang bị, drop/recipe và nhiệm vụ; tránh lấy thẳng bảng từ máy chủ VNG khác.
4. Chỉ sau M2/M3/M5 mới tổ chức private alpha có rollback rõ ràng.
