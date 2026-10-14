# MASTER ROADMAP — Phong Thần Truyền Kỳ

> Cập nhật: **14/10/2026**. Nguồn sự thật cho tiến độ kỹ thuật của dự án.
> Mục tiêu: **build được game Windows x86 → vận hành ổn định → nghiệm thu gameplay → private online → multi-server → phát hành**.
> Roadmap là kế hoạch; không được diễn giải các giai đoạn chưa nghiệm thu thành tính năng đã chạy.

## Nguyên tắc / Definition of Done

1. **Bảo toàn dữ liệu gốc:** không sửa byte nguồn `PhongThanSource/`, runtime staging gốc, PAK, SQL/character save. Áp overlay lên **bản sao ngoài checkout**; kiểm tra hash/manifest trước và sau.
2. **Tách hai loại bằng chứng:** source/unit test PASS != build Windows PASS != server smoke PASS != client gameplay PASS != Internet/public-ready.
3. **Giữ tương thích:** ưu tiên sửa C++98/Lua 4 có giới hạn; không đổi ABI, network packet, save schema, ID vật phẩm/nhiệm vụ nếu chưa có migration/compat test.
4. **Mỗi PR:** phạm vi nhỏ, mô tả mức rủi ro, test tái lập, cách rollback; không dùng thông tin tài khoản/nhân vật thật làm fixture hoặc upload log nhạy cảm.
5. **Triển khai:** backup kiểm tra được, maintenance window, kiểm tra phiên đang chơi, restart có kiểm soát và smoke test hậu triển khai. Không tự động phát lại giao dịch vật phẩm một phần.
6. **Runner tin cậy:** không cho PR fork chạy mã trên máy Windows self-hosted có game/runtime, chứng thực hoặc database production.

## Trạng thái được xác nhận

| ID | Dòng công việc | Trạng thái | Bằng chứng | Giới hạn |
| --- | --- | --- | --- | --- |
| F01 | C++98 parser, kiểm tra giới hạn packet và nguồn vá Account/GameServer | **Implemented / source-tested** | [PR #18](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/18), [#19](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/19), [#26](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/26) | Chưa chứng minh toàn bộ bản build Windows hoạt động |
| F02 | Báo cáo phát quà thiếu và hoàn vật liệu Linh Thú | **Implemented / source-tested** | [PR #25](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/25), [#29](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/29) | Chưa có transaction nguyên tử hoặc exactly-once |
| F03 | Chuẩn hóa Ubuntu CI, bỏ test trùng và lập ma trận nghiệm thu | **Implemented / CI PASS** | [PR #27](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/27) | Không chạy client/server |
| F04 | Windows PowerShell/source smoke và workflow Windows x86 thủ công | **Implemented / smoke CI PASS** | [PR #28](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/28) | Workflow **full build** cần runner `pt-game-build`, chưa có kết quả full build |
| F05 | Đọc log Lua registry, kỹ năng và chẩn đoán sai lệch | **Implemented / source-tested** | [PR #30](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/30) | Log lịch sử không chứng minh lỗi live |
| F06 | Provenance quest / kiểm kê NPC | **Audited, not gameplay-accepted** | [PR #20](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/20), [QUEST_SYSTEM_STATUS.md](QUEST_SYSTEM_STATUS.md) | 84 script NPC chỉ hướng dẫn; các nhánh khác chưa nghiệm thu hết |
| F07 | GitHub-hosted Windows x86 module build: `LuaLibDll`, `Engine` | **Windows module build PASS** | [PR #50](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/50), [run #38520540848](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38520540848) | `Engine` vẫn liên kết thư viện legacy `Lib/release`; chưa full build 22 binary, chưa runtime/gameplay |
| F08 | GitHub-hosted Windows x86 Core: `Common`, `ExpandPackageStaticLib`, `FilterTextStatic`, `CoreServer`, `CoreClient` | **Windows module build PASS** | [PR #52](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/52), [run #38523254976](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38523254976) | 7/7 module gate PASS với thư viện legacy; chưa full build 22 binary, chưa gameplay |
| F09 | GitHub-hosted Windows x86 Server: 5 EXE và 10 module phụ thuộc | **Windows server build PASS** | [PR #54](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/54), [run #38526607624](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38526607624) | 15/15 compile/link + PE32/COFF/SHA PASS; chưa chạy dịch vụ, DB, gameplay; linker còn thư viện legacy |

Trạng thái quy ước: **Planned → Implemented → CI PASS → Windows Build PASS → Runtime PASS → Gameplay/UAT PASS → Released**. Một feature chỉ được chuyển giai đoạn khi có artifact, log hoặc test ID tương ứng, không cập nhật theo phỏng đoán.

## Tiến độ M1 chi tiết - cập nhật 14/10/2026

| Pha | Trạng thái | Bằng chứng / Gate | Việc còn lại |
| --- | --- | --- | --- |
| **P1 - Core x86** | **PASS (7/7 module)** | [Windows Core #38523254976](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38523254976) | Thư viện legacy vẫn là linker input; chưa kiểm thử chạy game |
| **P2 - Native Server x86** | **PASS (15/15 module)** | [Windows Server #38526607624](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38526607624): 5 service EXE mới, DLL/COFF + SHA-256 | Chưa khởi động server, DB hoặc world |
| **P3 - Client x86** | **Đang triển khai / chưa PASS** | GitHub-hosted Windows build mới của `Represent2`, `Represent3`, `Game.exe` cùng phụ thuộc | Compiler/linker + PE32 + hash |
| **P4 - Full release x86** | **Chưa nghiệm thu** | Cần một lần build mới có **22/22 role-specific EXE/DLL** và manifest độc lập | Kiểm tra dependency import / package / không dùng binary cũ |
| **P5 - Runtime & Gameplay E2E** | **Chưa nghiệm thu** | Windows VM/runner cách ly; 5 tiến trình, 102 maps, login/save/relogin | Không dùng production account hoặc nhân vật thật |

**Điều kiện:** P1 và P2 PASS *không* có nghĩa M1 hoàn tất, và mọi bản binary/PAK/SQL staging gốc phải được giữ nguyên. Chưa phát hành public trước khi hoàn thành P4/P5.

## Milestone bắt buộc theo thứ tự phụ thuộc

| Milestone | Ưu tiên | Phạm vi và deliverable | Gate nghiệm thu | Trạng thái |
| --- | --- | --- | --- | --- |
| **M0 — Repository & CI baseline** | P0 | Tối giản job trùng, phân tầng PR/source/Windows, audit dữ liệu nhạy cảm, changelog và checklist | Test Python/C++98, quest provenance và smoke Windows hiện có PASS | **Một phần hoàn thành** |
| **M1 — Reproducible Windows x86 build** | P0 | Build mới trên workspace riêng, xác nhận dependency EXE/DLL, compiler/linker, SHA-256, compatibility; sau đó incremental build theo graph | Tất cả module bắt buộc build PASS trên Windows x86, binary manifest hợp lệ, smoke test sau build | **Chưa nghiệm thu** |
| **M2 — Runtime & account persistence** | P0 | 5 native services, account/role, map registry, load/save, graceful stop, reconnect, crash recovery | World-ready 102 maps; login → tạo nhân vật → đi map → save → logout → relogin; không mất tiến độ | **Chưa nghiệm thu E2E** |
| **M3 — Inventory & reward transactions** | P0 | Transaction/receipt bền vững, idempotency key, ledger/GM reconciliation, nguyên liệu/tiền/quà, rollback | Túi đầy, tiền thiếu, bấm lặp, offline, crash từng bước, restart: không mất/nhân đôi item | **Chỉ có diagnostic overlay** |
| **M4 — Network, protocol & resilience** | P1 | Packet bounds, ownership/RAII tương thích C++98, state machine login/reconnect/transfer, timeout và flood handling | Unit/fuzz protocol + integration session trùng/ngắt mạng; không crash, không session mồ côi | **Một phần source-tested** |
| **M5 — Lua, Skills, Assets & Quest** | P1 | Đối chiếu skill `1973` và PAK, Lua registry, sprite/audio, nghiệp vụ 126 NPC, quest lifecycle | Test tất cả script quan trọng, kỹ năng các hệ phái, NPC/quest: nhận → hoàn thành → thưởng 1 lần → reload | **Chưa hoàn chỉnh** |
| **M6 — Client UX & performance** | P1 | Renderer DirectDraw/Direct3D, độ phân giải/DPI, input, UI, âm thanh, loading, memory leak | Windows UI smoke ở các độ phân giải; Alt+Tab, đổi map, đánh quái, render sprite, không crash | **Chưa nghiệm thu** |
| **M7 — Private online Alpha** | P0 trước public | Windows host có mạng thật, split bind public/private, auth, firewall, TLS/tunnel phù hợp, backup, cập nhật client | 2+ máy khác mạng đăng nhập; server chỉ mở cổng cần thiết; save/reconnect/recovery PASS | **Chưa triển khai** |
| **M8 — Multi-server & admin ops** | P1 sau M7 | Nhiều server độc lập (database, state, log, ports, secrets riêng) và dashboard; sau đó mới chia nhiều GameServer chung world | 2 instance chạy song song; không trùng ports/ServiceId; dữ liệu nhân vật cách ly; restart từng instance an toàn | **Chưa triển khai** |
| **M9 — Closed Beta → Release** | P0 phát hành | Load/soak, capacity, security review, observability, rollback/restore, packaging, release notes | Test 10–30 client beta, xác nhận backup restore, không mất đồ, lỗi P0=0, vận hành theo runbook | **Chưa đủ điều kiện** |

### M0 — CI và repository

- [x] Chuẩn hóa unit test và loại bỏ phần test lặp trong Linux CI ([PR #27](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/27)).
- [x] Windows PowerShell syntax + marker readiness smoke; cấu hình manual build ([PR #28](https://github.com/ePlus-Game/phong-than-truyen-ky/pull/28)).
- [ ] Kiểm soát source/PAK binary archive bằng allowlist SHA; bật quy định chống đưa credential vào PR.
- [ ] Thêm workflow job summary (số test/pass/fail, nhóm test, artifact provenance) và links điều hướng.
- [ ] Audit lịch sử repository public và **xoay vòng credential thực còn sử dụng**; không đưa secret vào issue.

### M1 — Build, EXE và update client

- [ ] Chuẩn bị runner Windows x86 riêng, MSVC, DX9 SDK, Windows SDK, dung lượng đủ; giới hạn branch và quyền runner.
- [ ] Chạy workflow `windows-x86-build.yml` thủ công trên `main` và lưu log/hashes; sửa compiler errors bằng overlay nhỏ.
- [ ] Kiểm tra `Game.exe`, `GameServer.exe`, `PhongThanAccountServer.exe` cùng toàn bộ DLL dependency, manifest, architecture x86.
- [x] Thêm bộ xác minh 22 binary PE32/i386, loại EXE/DLL, kích thước và SHA-256 trên output build; test bằng fixture giả lập (chưa có kết quả build thực). Xem [M1_WINDOWS_BUILD.md](M1_WINDOWS_BUILD.md).
- [x] Xác nhận 2 module native build/link Windows thật: `PhongThanRelay.exe` và `PhongThanAccountServer.exe` (MSVC x86, PE32, SHA-256), theo [M1_WINDOWS_BUILD.md](M1_WINDOWS_BUILD.md); **không thay thế gate full build/gameplay**.
- [x] GitHub-hosted Windows đã build/link thêm `LuaLibDll.dll` và `Engine.dll` (fresh x86 PE32, SHA-256); `Engine` còn phụ thuộc thư viện legacy. [Bằng chứng](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38520540848).
- [x] Hosted Windows Core gate build/link 7/7 target, gồm `Common`, `ExpandPackageStaticLib`, `FilterTextStatic`, `CoreServer.dll`, `CoreClient.dll`; PE32/COFF + SHA-256 PASS. [Run #38523254976](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38523254976).
- [x] Hosted Windows Server gate build/link 15/15 target, gồm đủ 5 EXE `Goddess`, `PhongThanAccountServer`, `PhongThanRelay`, `Bishop`, `GameServer`; SHA-256 + PE32/COFF PASS. [Run #38526607624](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/runs/38526607624). Chưa xác nhận runtime.
- [ ] Phân loại thay đổi: **Lua/config/data: không rebuild EXE**; **C++: chỉ module & dependency**; **release: clean full build**.
- [ ] Thiết kế incremental build không tái sử dụng cache không tương thích; kiểm tra clean vs incremental artifacts.
- [ ] Tách content patching khỏi native binary delivery, ký/hash artifact; xác minh quyền phân phối assets.

### M2–M3 — Trước khi mở online

- [ ] Một VM Windows với DB thử nghiệm và tài khoản dummy; snapshot/restore trước khi test hủy dữ liệu.
- [ ] Check native topology với 5 services (`Goddess`, `AccountServer`, `PhongThanRelay`, `Bishop`, `GameServer`), không nhầm topology staging cũ 6 services.
- [ ] Reconnect/save/load và graceful stop: không kill force nếu đang có phiên người chơi thực.
- [ ] Inventory receipt duy nhất và đối soát mỗi giao dịch; chặn replay quà/nguyên liệu một phần.
- [ ] Mutation tests cho từng bước của phát quà, đổi trứng/tiến hóa, giao đồ, giao dịch người chơi.

### M4–M6 — Gameplay và engine

- [ ] Fuzz parser handshake/relay/map/role, packet cắt cụt, kích thước biên, duplicate service và stale session.
- [ ] Luồng `client → gateway → world → map → reconnect`: log correlation ID không lộ thông tin nhạy cảm.
- [ ] Đối chiếu `settings/Skills.txt` / table PAK và cả 2 phía client/server; làm rõ ID kỹ năng `1973`.
- [ ] Đánh dấu từng NPC/script: **implemented / original source found / static-tested / runtime-tested / incomplete**.
- [ ] UAT quest đạt level/phái, túi đầy, logout/restart, nhiệm vụ hoàn tất một lần; không sửa ID theo phỏng đoán.
- [ ] Profiling CPU/RAM/network và render Windows thật; không tuyên bố tối ưu nếu chưa đo baseline.

### M7–M9 — Online và nhiều server

- [ ] Private Alpha: 1 world/server trước; cấu hình IP public **cho client entrypoint** thay vì `127.0.0.1`, các dịch vụ DB/relay để trong private network; không public SQL LocalDB.
- [ ] Kiểm chứng handshake và địa chỉ/port mà Bishop trả về (không chỉ sửa `serverlist.ini`); rule firewall tối thiểu, rate limiting, bảo vệ credential.
- [ ] Multi-server **độc lập trước**: instance dir/state DB/log/secrets riêng, không ghi chồng file; biến cổng và `ServiceId` thành cấu hình; tên chọn server ở client.
- [ ] Sau khi có 2 instance độc lập mới thử **shared-world**: đăng ký bản đồ phân vùng, kiểm tra ownership, routing và chuyển map không mất nhân vật.
- [ ] Giám sát game/DB, snapshot backup, DR drill, rollback bin & script, load/soak và beta trước public.

## Thứ tự PR tiếp theo (đề xuất, chưa được mở/merge)

| PR đề xuất | Phụ thuộc | Kết quả phải xuất |
| --- | --- | --- |
| P1 Windows build reality check | M0 | Full Windows build run, error list có dẫn log; fix x86 build theo module |
| P2 Login-save test harness | P1 | Test account + process health + save/reconnect end-to-end trong VM |
| P3 Atomic reward design & engine tests | P2 | Receipt/idempotency implementation + fault-injection tests và rollback |
| P4 Lua/skill registry audit | P1/P2 | Bằng chứng skill/script loader sau run, không chỉ log lịch sử |
| P5 Quest and NPC acceptance | P3/P4 | Quest matrix, test giao dịch thật, từng NPC có status |
| P6 Online closed-alpha launch checklist | P2/P3/P4 | IP public reachability + firewall + rollback/restore demo |
| P7 Independent multi-server manager | P6 | Instance configuration generator + collision tests + 2-server isolated UAT |
| P8 Shared-world routing (optional) | P7 | Unique map ownership / transfer / session recovery stress tests |
| P9 Release hardening | P2–P8 | Client installer, version/hash manifest, beta/soak report, release gate |

## Release gate bắt buộc

Không thông báo "game online hoàn chỉnh" hoặc "multi-server ready" nếu thiếu **đồng thời**:
- CI source/tests pass ở đúng SHA release;
- binary Windows x86 build PASS với checksum của client/server/required DLL;
- 102-map world readiness + login/save/reconnect UAT pass trên môi trường thử;
- reward/item fault injection & rollback không bị dup/mất trạng thái;
- kiểm thử thực từ máy ở mạng Internet khác + hardening;
- backup có diễn tập restore, có giám sát và phương án rollback.

## Liên kết theo dõi

- [Refactoring chi tiết](REFACTORING.md)
- [Ma trận kiểm thử](TEST_MATRIX.md)
- [Báo cáo quà, vật phẩm và Linh Thú](REWARDS_AND_PETS.md)
- [Trạng thái quest/NPC](QUEST_SYSTEM_STATUS.md)
- [GitHub Actions](https://github.com/ePlus-Game/phong-than-truyen-ky/actions)
- [Danh sách PR](https://github.com/ePlus-Game/phong-than-truyen-ky/pulls)
