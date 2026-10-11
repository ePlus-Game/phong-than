> **Historical analysis of a different, much smaller PT.rar archive.** The source tree described below is not the current full PT.zip repository. See [current layout](REPOSITORY_LAYOUT.md).

# BÁO CÁO PHÂN TÍCH TĨNH — PHONG THẦN 2 / PT.rar

**Ngày phân tích:** 09/10/2026  
**Đầu vào:** `PT.rar` (RAR 5, 29,852,839 byte)  
**SHA-256 đầu vào:** `27cf7658890ee1fcd71c238e97da0a5a4d49e167693267edc771277d8a7a7834`  
**Phương pháp:** Kiểm tra nội dung và mã nguồn tại chỗ; không chạy bất kỳ EXE/DLL nào, không biên dịch; không có môi trường Visual C++ 6.0 để build thử.

## 1. Tóm tắt đánh giá

- **Đây là bộ mã nguồn C/C++ Phong Thần 2 (封神榜2)**, gồm source client, các header và thư viện tĩnh/server đã biên dịch, project Visual C++ 6.0.
- **Không phải bản offline all-in-one**, chưa thể chạy server và client ngay sau giải nén.
- Về server, source trong `Server/lord` chỉ có `src/lord.cpp` làm điểm khởi chạy, phần quan trọng phụ thuộc các thư viện đã biên dịch và DLL bên ngoài.
- `Game.lib` và `FSInterface.lib` trong `Share/Lib/Release` là **import libraries** tham chiếu `Game.dll`/`FSInterface.dll`; **không tìm thấy hai DLL này** trong gói.
- **Không có** `.exe`, `.sql`, `.db`, `.sqlite`, `.lua` trong gói; không có bộ bản đồ/quái/NPC/nhiệm vụ đầy đủ để xác nhận vận hành game offline.
- **Ưu tiên phục hồi**: `Game.dll` và `FSInterface.dll` tương thích, bộ dữ liệu game, database `fsonline2` và thông số kết nối local; sau đó mới xử lý build.

## 2. Thống kê file

| Chỉ tiêu | Kết quả |
|---|---:|
| File trong RAR và đã trích xuất | 3.847 |
| Thư mục trong RAR | 206 |
| Dung lượng giải nén khai báo | 147.763.501 byte |
| Source C++ (`.cpp`) | 824 |
| Source C (`.c`) | 97 |
| Header `.h` | 1096 |
| Header `.hpp` | 1464 |
| Visual C++ project (`.dsp`) | 22 |
| Visual C++ workspace (`.dsw`) | 2 |
| `.lib` | 44 |
| `.dll` | 3 |
| `.exe` / `.sql` / `.lua` | 0 / 0 / 0 |

**Theo thư mục chính:** `Base`: 162 file, `Client`: 3,139 file, `Server`: 15 file, `Share`: 531 file.

**Cảnh báo kiểm tra RAR:** Bộ giải nén báo lỗi khối tại `Client/Represent/Represent2/Debug/vc60.pdb` và lỗi block checksum tại `Server/lord/Release/vc60.idb`. Kiểm tra sau giải nén: đủ 3.847 đường dẫn file và kích thước từng file trùng metadata RAR; tuy nhiên điều này **không chứng minh hai file lỗi có nội dung nguyên vẹn**. Đây là file dữ liệu hỗ trợ biên dịch/debug, không phải mã nguồn C++ chính. Không nên dùng các file `.pdb/.idb` này như trạng thái build đáng tin cậy.

## 3. Cấu trúc và vai trò module

```text
《封神榜2》源代码/
├── Base/
│   ├── Common/            # C++ networking, utility, IO, crypto, threads
│   └── LuaLib/            # Lua runtime / compiler and libraries
├── Client/
│   ├── Faith/             # Game client Win32 (.dsp target: Application)
│   ├── Core/              # Logic and model game phía client (Core_lib)
│   ├── Engine/            # Client engine DLL project
│   ├── Represent/         # Graphics / representation DLL project
│   ├── cegui_blaze/       # CEGUI và widget libraries
│   ├── layout/            # Layout static library
│   ├── fontlib/           # Font library
│   └── Autoupdate/        # Updater and UpdateDLL
├── Server/
│   └── lord/
│       ├── lord.dsp       # Win32 Console Application
│       └── src/
│           ├── lord.cpp   # Server entry point
│           └── lord.cfg   # Cấu hình mạng, paysys, DB
└── Share/
    ├── Header/           # Shared protocol, engine, interface declarations
    └── Lib/              # Debug/Release precompiled libraries
```

`lord.cpp` gọi `CreateController()` → `Startup()` → vòng lặp `yield()` → `Stop()/Release()`, không chứa game engine hay database implementation. Để chạy phụ thuộc thực thi thực sự bên trong `minister.lib`, `CoreServer.lib` và các binary khác.

## 4. Build targets (22 project `.dsp`)

| Nhóm | Target / loại |
|---|---|
| Server | `Server/lord/lord.dsp` → `lord.exe` Console x86 |
| Client | `Client/Faith/Faith.dsp` → Win32 Application |
| Client engine | `Client/Engine/Engine.dsp` → DLL |
| Graphics | `Client/Represent/Represent2/Represent2.dsp` → DLL |
| Core, Base, Lua | `Client/Core/Core_lib.dsp`, `Base/Common/Common.dsp`, `Base/LuaLib/LuaLib.dsp` → static libraries |
| UI | `Client/cegui_blaze/...` → CEGUI DLL/static libraries |
| Updater | `Client/Autoupdate/autoupdate/AutoUpdate.dsp` → EXE; `updatedll/UpdateDLL.dsp` → DLL |
| Others | Font, layout libraries |

**Toolchain gốc:** Microsoft Developer Studio 6.0 (`.dsp`, `.dsw`), Win32/x86, MSVC runtime cổ (`MSVCP60.dll` xuất hiện trong DLL đồ họa); có tham chiếu MySQL, OpenSSL, Boost.Regex, Lua, DirectX/CEGUI. Chưa có project VS hiện đại (`.sln`/`.vcproj`), CMakeLists hoặc script build tự động.

**Bất thường ở source/project cần xử lý:**

- `Base/Common/Common.dsp` có khoảng 35 đường dẫn source/header được liệt kê nhưng không tồn tại tại vị trí tương ứng, kể cả khi so tên không phân biệt hoa thường; ví dụ `Share/Header/Common/Timer.h`, `Base/Header/Common/Buffer.h`.
- `Base/LuaLib/LuaLib.dsp` tham chiếu `src/luadebug.h` không thấy.
- `Client/Autoupdate/autoupdate/AutoUpdate.dsp` tham chiếu nhiều asset hình ảnh không có trong gói (ví dụ `res/background.jpg`).
- `Client/Core/Core_lib.dsp` khớp đầy đủ tên nguồn khi kiểm tra case-insensitive (Windows); lỗi paths trên Linux có thể do khác hoa/thường.
- `Client/Faith/Faith.dsp` còn thiếu một số file tham chiếu (`ChatTipWndItem.h`, `ReadMe.txt`), cần xác minh có bắt buộc cho build hay không.

Các chỉ số thiếu đường dẫn là **phân tích tĩnh trên archive**, không phải kết quả thực tế của compiler; có thể có file được generate hoặc file có thể bỏ khỏi project.

## 5. Thư viện có sẵn so với DLL bị thiếu

**Đã có các thư viện để nghiên cứu/link:** `CoreServer.lib`, `CoreClient.lib`, `minister.lib`, `netmod.lib`, `DBWrap.lib`, `Common.lib`, `LuaLib.lib`, `Game.lib`, `FSInterface.lib`, `libmysql.lib`, `libeay32.lib`, `libboost_regex...lib` (khác nhau theo Debug/Release).

- `Share/Lib/Release/Game.lib` là import library (archive members được đặt tên `Game.dll`).
- `Share/Lib/Release/FSInterface.lib` là import library (archive members được đặt tên `FSInterface.dll`).
- Trong các file đã trích xuất **không có** `Game.dll` hoặc `FSInterface.dll`. Tại runtime sẽ không thể sử dụng các import này nếu chưa khôi phục DLL đúng ABI/phiên bản.
- Có sẵn `Client/Represent/Represent2/Release/Graphic.dll` nhưng PE import table của nó cũng yêu cầu `Game.dll`.
- `.lib` `CoreServer`, `minister`, `DBWrap` chứa nhiều COFF object đã biên dịch; không có nghĩa các module này đã có đầy đủ source để chỉnh sửa.

## 6. Database, tài nguyên game và cấu hình

`Server/lord/src/lord.cfg` nêu:

- `[lord]`: cổng game `8888`, hàng chờ `8889`, cấu hình giới hạn người chơi/NPC/vật phẩm.
- `[Paysys]`: kết nối dịch vụ thanh toán ở IP mạng LAN cũ.
- `[DBSecure]`: database tên `fsonline2`, địa chỉ DB nội bộ và credential cấu hình cũ.

**Không lưu lại credential hoặc mật khẩu trong báo cáo.** Khi triển khai local, cần thay toàn bộ IP/DB user/mật khẩu bằng biến cấu hình phát triển, vô hiệu hóa kết nối thanh toán production/cũ, và bảo đảm game server chỉ nghe địa chỉ local hoặc VM private network.

Không phát hiện tập tin SQL dump hay SQLite trong archive; **không thể biết schema DB** chỉ từ file cfg. Cần tìm đúng DB dump hoặc nghiên cứu interface `Share/Header/DBWrap` và các symbol trong `.lib` để xây dựng schema mới.

Không có bộ dữ liệu live của bản đồ, script Lua gameplay, sprite/audio/pack game được đóng gói cùng archive (một số BMP/ICO là tài nguyên UI và updater, không đủ để chơi).

## 7. Rủi ro bảo mật / mã nguồn cũ

- `Server/lord/src/lord.cpp` có lời gọi `gets(szInput)` (API không giới hạn đầu vào, rủi ro buffer overflow). Thay bằng `fgets()` hoặc hàm nhập có kiểm soát trước khi triển khai.
- Source và thư viện nhắm VC6, có các phiên bản thư viện tuổi đời cao; **không public Internet** hoặc mở port khi chưa rà soát bảo mật.
- Các DLL/OBJ/LIB được trích xuất **chưa được phân tích malware động hoặc kiểm tra nguồn gốc chữ ký**. Nên build/test trong VM cách ly, snapshot trước khi chạy.
- Mã nguồn/binaries có thể thuộc bản quyền Kingsoft hoặc đối tác; cần xem quyền sử dụng trước khi public/redistribute.

## 8. Lộ trình thực tế để tiếp tục phát triển

**Giai đoạn 0 — Sao lưu và kiểm kê (đã làm):** archive ZIP, manifest SHA-256, phân loại source/binary, liệt kê blocker.

**Giai đoạn 1 — Tạo VM build legacy:** Windows x86 trong VMware, Visual C++ 6.0 SP6 hoặc compiler Windows tương thích sau khi kiểm thử; DirectX SDK legacy, CRT, include/lib paths; sử dụng VM offline nếu có thể. **Không chạy sẵn binary chưa xác minh.**

**Giai đoạn 2 — Thử build phần tương đối độc lập:** `Base/LuaLib`, `Base/Common` (sửa thiếu header) → `Client/Core/Core_lib` → `Client/Engine` / `Client/Represent` → `Client/Faith`; log lỗi/đưa về project riêng.

**Giai đoạn 3 — Khôi phục DLL và DB:** ưu tiên xác định nguồn hợp pháp cho `Game.dll`, `FSInterface.dll` đúng client/version; tìm DB `fsonline2` có schema + sample data; nếu không có thì xây các module replacement / protocol emulator từ interface và phân tích mạng ở mức local.

**Giai đoạn 4 — Server offline LAN:** chuẩn hóa IP 127.0.0.1 hoặc host-only adapter, cấu hình DB local, loại kết nối Paysys cũ, tạo tài khoản test, xác minh login → chọn nhân vật → vào bản đồ → thử save/load.

**Giai đoạn 5 — Refactor:** tạo build scripts/CMake theo từng module (không giả định source tương thích VS2022), test tự động phần logic tách rời, thay `gets` và credential hardcode, migrate dependencies và thiết lập license/repo private.

## 9. Cần tìm thêm gì? (ưu tiên)

1. **`Game.dll`, `FSInterface.dll` đúng đời Phong Thần 2** hoặc full runtime client tương ứng.
2. **SQL dump / schema database `fsonline2`**, các account tables và world/NPC data.
3. **Game data resources**: map, config, NPC/item tables, animation/texture/music, script gameplay.
4. **Server binaries**: `lord.exe` build matching libraries và các dịch vụ liên quan nếu có.
5. **Môi trường build** phù hợp với ABI MSVC6 x86; SDK/headers còn thiếu, và dự án `.dsp` cần điều chỉnh.

## 10. Kết luận

**Giá trị lớn nhất hiện tại:** nghiên cứu cấu trúc client, protocol/header, engine, luồng login và port một phần logic C++ sang code mới. **Không đủ để dựng bản offline hoàn chỉnh ngay:** thiếu runtime DLL cốt lõi, DB và dữ liệu game. Không nên nhầm Phong Thần 2 với Phong Thần 1 VinaGame; code này không chứng minh hai bản tương thích.

### Đối chiếu với cộng đồng

Diễn đàn 藏宝湾 có chủ đề chia sẻ source `封神榜2` ngày 16/10/2024, cũng ghi nhận vấn đề compile `GameDll`, `Faith` và thiếu data/database:
https://www.iopq.net/forum.php?mod=viewthread&tid=17130496

### File đi kèm

- `PT_extracted.zip`: toàn bộ cây source sau giải nén, giữ nguyên tên file.
- `PT_source_manifest.csv`: đường dẫn, dung lượng, SHA-256 từng file trích xuất.
- `PT.rar`: file người dùng đã cung cấp, không thay đổi.
