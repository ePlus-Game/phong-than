# Danh mục EXE — Phong Thần Truyền Kỳ

> Kiểm kê repository tại **14/10/2026**. Đây là tài liệu **vai trò và vị trí** của chương trình, **không phải** xác nhận mọi bản EXE đều dùng được. Phân biệt tên file và đường dẫn; không nên chạy tất cả các EXE cùng lúc.

## Tại sao có nhiều file EXE?

Cây Git `PhongThanSource/` tại thời điểm kiểm kê có **106 mục `.exe` với 77 tên khác nhau**; đó **không phải 106 dịch vụ server**. Bên cạnh những chương trình chạy game còn có binary biên dịch cũ, bản build VC6/VS2022, bản sao release, công cụ phát triển và các bài kiểm thử đã biên dịch. `_backup/` còn lưu nhiều bản sao theo ngày; `Setup/` có bộ cài đặt bên thứ ba.

**Luôn đối chiếu thư mục**: hai file tên `Game.exe` có thể được build từ những mốc khác nhau. Không chọn bản chạy theo tên file hoặc dung lượng, không tự động chọn file mới hơn dựa vào timestamp; kiểm tra manifest SHA-256, tương thích DLL/config và quy trình triển khai.

## A. Runtime native hiện tại (1 client + 5 server)

`PhongThanSource/Deploy/Start-NativeServer.ps1` khởi động **đúng 5 tiến trình server** ở `PhongThanRuntime-Staging/Server/`, trong thứ tự sau. Client dùng `PhongThanSource/Deploy/Start-StagingClient.ps1`.

| EXE | Nơi chạy | Vai trò chính | Port kiểm tra bởi script native |
| --- | --- | --- | --- |
| `Game.exe` | Máy người chơi / `PhongThanRuntime-Staging/Client` | Ứng dụng client Windows, hiển thị màn hình game, nhập liệu, chiến đấu và tương tác; kết nối tới cụm server | Client kết nối outbound, không phải dịch vụ server |
| `Goddess.exe` | Server | Dịch vụ vai trò/dữ liệu và điều phối bên trong cụm (legacy DBRole/Goddess) | 5001 |
| `PhongThanAccountServer.exe` | Server | Dịch vụ tài khoản và xác thực, truy cập database tài khoản qua cấu hình riêng | 5002 |
| `PhongThanRelay.exe` | Server | Native relay: đăng ký dịch vụ, chuyển tiếp và định tuyến thông điệp/phiên trong cụm | 5003 |
| `Bishop.exe` | Server | Gateway/điều phối thế giới, đăng ký GameServer/bản đồ và dẫn hướng kết nối game | 5622, 5632 |
| `GameServer.exe` | Server | Gameplay phía server: nhân vật, bản đồ, NPC/quái, script và trạng thái thế giới | 6666 |

**Quan trọng:** Các port trên là giá trị mà startup script **kiểm tra**, không phải gợi ý mở chúng ra Internet. Account DB và các dịch vụ nội bộ phải đặt sau firewall/private network. Server cần xác minh `WORLD_READY` với đúng Bishop PID, ServiceId và số bản đồ mong đợi (hiện là 102) trước khi coi là sẵn sàng đăng nhập.

Cách khởi động có điều khiển: `PhongThanSource/Deploy/PhongThan-Control.ps1` / `PhongThan-Control.cmd`; xem [hướng dẫn bảng điều khiển](../PhongThanSource/Deploy/PhongThan-Control.README.md). Không chạy EXE server bằng cách nhấp đúp từng file, vì thứ tự, thư mục làm việc, database và trạng thái thế giới có phụ thuộc.

## B. Các EXE server legacy — không phải tất cả đều cần chạy

| EXE legacy | Vai trò/phân biệt | Được gọi trong topology nào? |
| --- | --- | --- |
| `PhongThanRelayServer.exe` | RelayServer cũ thuộc `Sources/AccountServices/RelayServer`; không đồng nhất với **native mới** `PhongThanRelay.exe` | `Start-StagingServer.ps1` chế độ **cũ** (6 tiến trình) |
| `S3Relay.exe` | Relay phía thế giới/game, kết nối gateway, DBRole và GameServer; tài liệu gốc mô tả Host/Chat/Tong | `Start-StagingServer.ps1` chế độ **cũ** |
| `S3RelayServer.exe` | Bản EXE lịch sử khác nằm ở `Sources/AccountServices/RelayServer/Release` và `Output/Server`; không thấy trong startup native hiện tại | **Không** nằm trong danh sách native năm dịch vụ |
| `Sword3PaySys.exe` | Tên EXE cũ của nhánh AccountServer/PaySys; **không phải** chương trình thanh toán mới cần khởi động thêm | **Không** nằm trong danh sách native năm dịch vụ |

Script `Start-StagingServer.ps1` khi không phát hiện `NATIVE_DEPLOYMENT.json` dùng topology sáu tiến trình: `Goddess.exe`, `PhongThanAccountServer.exe`, `PhongThanRelayServer.exe`, `Bishop.exe`, `S3Relay.exe`, `GameServer.exe`.

**Không chạy chung** 2 topology vì có thể đụng port, database, session và file log. `PhongThanRelayServer.exe` và `PhongThanRelay.exe` **không phải** chỉ là hai tên của cùng một binary.

Tài liệu legacy của `S3Relay`: [S3Relay/ReadMe.txt](../PhongThanSource/Sources/MultiServer/S3Relay/ReadMe.txt). Tài liệu cho relay account cũ: [RelayServer/ReadMe.txt](../PhongThanSource/Sources/AccountServices/RelayServer/ReadMe.txt).

## C. Bản build khác nhau nằm ở đâu?

| Thư mục | Ý nghĩa | Có nên chạy trực tiếp? |
| --- | --- | --- |
| `PhongThanRuntime-Staging/Client/`, `.../Server/` | Bản runtime được chuẩn bị cho các script khởi động | Chỉ qua control/start script, trong môi trường cách ly |
| `PhongThanSource/Output/Client/`, `.../Server/` | Kết quả build/deploy lịch sử (có thể chứa nhiều loại relay) | Không thay thế runtime chỉ vì trùng tên |
| `PhongThanSource/Output/*/release/` | Bản phát hành hoặc bản sao đầu ra cũ | Giữ để đối chiếu/rollback |
| `PhongThanSource/OutputModern/Client/`, `.../Server/` | Binary từ quy trình MSVC hiện đại đã lưu trong archive; **không tự động là bản CI mới nhất** | Chỉ dùng sau verify manifest |
| `PhongThanSource/Sources/*/Release/` | Đầu ra của từng VC6 project hoặc bản đã biên dịch trước đó | Không dùng làm đường dẫn triển khai chính |
| `PhongThanSource/Sources/*/Modern/Win32Release/` | Đầu ra biên dịch theo từng project hiện đại | Artifact trung gian; cần thu thập đủ dependency |
| `_backup/` | Bản sao hồi phục theo ngày (nhiều EXE trùng tên) | Không chạy trực tiếp hoặc xóa tự động |
| `Setup/SQL2022-SSEI-Expr.exe` | Trình cài Microsoft SQL Server Express, **không phải file game** | Chỉ cài khi cần trong môi trường quản trị tin cậy |

**Chú ý:** Repo lưu byte gốc nên không dọn các EXE cũ bằng cách xóa file tracked. Nếu muốn giảm kích thước clone hoặc đơn giản hóa phát hành, cần chiến lược archive/release riêng, không sửa cây gốc.

## D. Những EXE phục vụ phát triển, kiểm thử (không phải tiến trình game)

### `PhongThanSource/Output/Tools/` — 36 chương trình

| Nhóm chức năng | Các EXE hiện thấy |
| --- | --- |
| Kiểm tra tài khoản/giao thức/NPC | `PhongThanLoginProbe.exe`, `PhongThanLoginRoleTests.exe`, `PhongThanWorldProtocolTests.exe`, `PhongThanNpcUiTests.exe`, `PhongThanRegionNpcTests.exe`, `RoleCreationUiTests.exe` |
| Kiểm tra thiết bị/vật phẩm | `EquipmentColumnTests.exe`, `EquipmentEngineTests.exe`, `EquipmentMetadataWireTests.exe`, `EquipmentProjectionTests.exe`, `EquipmentStoreRoundTrip.exe`, `GoldEquipmentRulesTests.exe`, `ItemDisplayTests.exe`, `ItemSeriesTests.exe`, `StarterBagCatalogTests.exe` |
| Bảng dữ liệu/hệ số/âm thanh | `SetTableTests.exe`, `PowerExpressionTests.exe`, `UpgradePowerTests.exe`, `UpgradeStatsTests.exe`, `WaveFormatTests.exe`, `AuditSetEntries.exe` |
| Audit PAK/SPR và script | `PakEntryAudit.exe`, `PakEntryBulkExtract.exe`, `PakEntryExtract.exe`, `SprLoaderAudit.exe`, `LuaApiBinarySmoke.exe` |
| Debug và stress | `EngineDebugSink.exe`, `FindInputUi.exe`, `IniUpdateStress.exe` |
| **Thay đổi dữ liệu thử nghiệm / phải thẩm định trước** | `GrantGold100.exe`, `GrantTestGiapSi.exe`, `GrantTinhQuan10.exe`, `RepairGrantedInventory.exe`, `SeedComposeUat.exe`, `UnlockTestStorage.exe`, `PositionNpcUat.exe` |

Các nhóm trên dựa vào **tên và vị trí công cụ**, không phải chứng nhận rằng mọi binary đều chỉ đọc hoặc đã được kiểm tra side effect. **Không chạy** chương trình Grant/Repair/Seed/Unlock/Position, công cụ trích xuất ghi file, stress test hay network probe trên dữ liệu nhân vật thật.

### Các thư mục `Output/*Tests*/` và `Output/Npc*`

- `NpcLuaIncludeTests/` (16 EXE): `Compose`, `Context`, `EquipmentCompose`, `EquipmentComposeTests`, `EquipmentStoreRoundTrip`, `Exchange`, `Include`, `ItemUpgradeState`, `ItemUpgradeStateTests`, `NpcComposeRecipeTests`, `NpcComposeTransactionTests`, `QuestItemTuple`, `Transaction`, `UpgradeStore`, `XichTungTu`, `XichTungTuTests` (tất cả hậu tố `.exe`).
- `NpcRestorationTests/` (12 EXE): `CaptureCrash`, `Inspect`, `LuaTests`, `NpcRegionLifecycleTests`, `OriginalNpcQuestTests`, `PositionNpc`, `QuestDeathProgressTests`, `RainbowSendTests`, `RegionTests`, `ResourcePipeline`, `Resources`, `Visibility` (tất cả hậu tố `.exe`).
- Các test độc lập: `EquipmentPresentationTests.exe`, `ExperienceItem1355Tests.exe`, `NpcSceneMembershipTests.exe`, `WaveFormatTests.exe`, `Output/PakConcurrentTest/test.exe`.

Chúng là binary kiểm thử chuyên biệt, **không phải NPC hoặc server mới cần bật**. Một số test có thể yêu cầu fixture, file data hoặc thay đổi bản test; luôn đọc script/test source trước khi thực thi.

## E. DLL và `.lib` khác gì EXE?

- `.exe`: tiến trình Windows có thể khởi chạy, bao gồm game, dịch vụ và công cụ/test.
- `.dll`: thư viện nạp vào tiến trình, ví dụ `CoreServer.dll`, `CoreClient.dll`, `Engine.dll`, `LuaLibDll.dll`, `Represent2.dll`, `Represent3.dll`. **Không** khởi chạy như một EXE độc lập.
- `.lib`: thư viện liên kết/import cho compiler, không phải tiến trình dịch vụ.
- `Build-Modern.ps1` có 19 target build (gồm các static lib, DLL và EXE); [ma trận build Windows](M1_WINDOWS_BUILD.md) yêu cầu 22 **đầu ra theo vai trò Client/Server**, trong đó có nhiều DLL trùng tên ở hai thư mục, **không phải 22 EXE**.

## F. Để vận hành và tìm tài liệu

1. [PhongThan-Control.README.md](../PhongThanSource/Deploy/PhongThan-Control.README.md) — cách start/stop/client/account local.
2. [Start-NativeServer.ps1](../PhongThanSource/Deploy/Start-NativeServer.ps1) — **nguồn sự thật** cho 5 server/port hiện tại.
3. [Start-StagingServer.ps1](../PhongThanSource/Deploy/Start-StagingServer.ps1) — topology cũ 6 server khi chưa có native deployment marker.
4. [M1_WINDOWS_BUILD.md](M1_WINDOWS_BUILD.md) — artifact matrix, build x86 và CI.
5. [REPOSITORY_LAYOUT.md](REPOSITORY_LAYOUT.md) — các thư mục archive/runtime/backup.
6. [MASTER_ROADMAP.md](MASTER_ROADMAP.md) — tiến độ refactor/game online.

**Nguyên tắc:** Giữ archive byte-exact; chỉ build trên bản sao bên ngoài checkout; không nhấp đúp chạy EXE từ `_backup`, `Sources/*/Release` hay `Output/Tools` để thử server. Bảo vệ account DB, save nhân vật, config, log và secrets.
