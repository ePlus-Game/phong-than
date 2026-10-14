# Repository hygiene — phân tách phát triển và archive lịch sử

> Kiểm kê ngày 14/10/2026. Đây là hướng dẫn dọn repo, **không** cho phép xóa file gốc khi chưa kiểm chứng khả năng khôi phục.

## Vì sao repo nhiều file?

Repo được import từ PT.zip để phục dựng nguyên bản nên trộn mã nguồn C++/Lua, runtime, PAK, trạng thái nhân vật, nhiều thế hệ build EXE/DLL/PDB, backup, log và tài liệu. `.gitignore` **không bỏ theo dõi** các file đã commit.

| Nhóm | Bằng chứng đã kiểm tra | Xử lý |
| --- | --- | --- |
| `PhongThanRuntime-Staging/ControlLogs/` | 212 file, nhiều `.log.err` rỗng | Lưu lịch sử riêng; log mới không được tracked |
| `PhongThanRuntime-Staging/Client/` | Có debug log ~85,6 MB và ~38,4 MB; nhiều PDB | Không ship cùng client phát hành |
| `PhongThanRuntime-Staging/Server/` | Có PDB, backup SQL, log runtime | Không đưa database và log live vào CI |
| `_backup/` | Nhiều snapshot theo ngày; bản admin-web-v7/v8 có cùng tree SHA | Chỉ cân nhắc giảm trùng sau khi có archive xác minh |
| `PhongThanSource/Output/`, `OutputModern/` | Binary/test/build cũ | Build mới ở external workspace, artifact có hash |
| `archive/` | Manifest PT.zip gốc | Giữ nguyên SHA-256/provenance |

**Không ước lượng dung lượng Git tiết kiệm bằng cách cộng số byte của file trùng.** Git deduplicate các blob cùng SHA. Xóa trong HEAD không làm các blob biến mất khỏi lịch sử.

## Kiểm kê tự động, an toàn

`tools/repository_hygiene.py` chỉ đọc metadata bằng `git ls-tree -r -l -z HEAD`, tổng hợp số file, logical size và blob references, không đọc nội dung log, SQL, PAK, save hoặc token. Báo cáo không công khai tên file nhạy cảm.

```bash
python tools/repository_hygiene.py --format markdown
python tools/repository_hygiene.py --format json --output hygiene-summary.json
python -m unittest discover -s tests -p test_repository_hygiene.py -v
```

Các category có thể chồng lặp. Logical bytes không phải network traffic hoặc dung lượng vật lý của Git object database.

Để tránh làm PR CI tải cây Git khổng lồ, báo cáo toàn repo chỉ chạy theo yêu cầu qua GitHub Actions **Historical repository inventory (manual)**. Job có timeout 15 phút, chỉ checkout script và không xuất log/SQL/save.

## Clone gọn cho công việc tools/docs

```bash
git clone --filter=blob:none --sparse https://github.com/ePlus-Game/phong-than-truyen-ky.git
cd phong-than-truyen-ky
git sparse-checkout set --cone tools tests overlays docs .github
```

Các file trực tiếp ở root vẫn có thể được checkout. Nếu cần sửa engine, dùng `git sparse-checkout add PhongThanSource/Sources PhongThanSource/Headers PhongThanSource/Build` và cân nhắc dung lượng. Không chạy `git sparse-checkout disable` khi thiếu dung lượng. Full build Windows cần profile riêng và runner cách ly; xem [M1_WINDOWS_BUILD.md](M1_WINDOWS_BUILD.md).

## Không cho phát sinh rác mới

- Bổ sung `.gitignore` cho backup cục bộ, thư mục build, control logs, runtime saves/SQL, snapshot và admin-generated files. Tracked historical files không bị xóa.
- Không commit account, nhân vật thật, token, key, log truy cập, transaction hoặc dump SQL. Chỉ phát hành binary qua pipeline có checksum; PDB/log debug phải có retention và rà soát bí mật.
- Không cho fork PR chạy trên Windows self-hosted runner chứa secrets, database hoặc player saves.

## Đợt dọn triệt để (chưa thực hiện)

1. Tạo baseline archive bất biến, xác minh full PT.zip manifest, 16 PAK lớn/102 chunks và backup độc lập.
2. Phân loại đường dẫn bắt buộc để build, startup, NPC/script và gameplay so với output có thể tái tạo.
3. Tách archive nguyên gốc, source repo phát triển và game release/artifact; giữ các mốc rollback.
4. Clone sạch, build Windows x86 và chạy kiểm thử phục hồi/runtime thực trước khi thay default branch.
5. Chỉ sau khi xác nhận đủ, thực hiện xóa/migration/history rewrite riêng; thay đổi history sẽ đổi SHA, ảnh hưởng mọi clone và PR.

Cần xử lý cẩn trọng các log có tên liên quan token trong lịch sử: không công khai nội dung, rà soát quyền truy cập và xoay vòng token nếu còn hiệu lực. Xóa trong HEAD không xóa Git history.
