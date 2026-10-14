# Phong Thần Truyền Kỳ — dự án phục dựng game

**Tên game:** Phong Thần Truyền Kỳ (**PTTK**). Tên hiển thị cho client C++/INI cũ: `Phong Than Truyen Ky`.

Repository: [ePlus-Game/phong-than-truyen-ky](https://github.com/ePlus-Game/phong-than-truyen-ky).

Dự án gồm mã nguồn game, dữ liệu runtime và công cụ phục dựng, kiểm tra, build. Tên file chạy và đường dẫn kỹ thuật hiện có (`Game.exe`, `PhongThanSource`, `PhongThanRuntime-Staging`, `script/phongthan/*`) được giữ nguyên để tương thích.

- [Cập nhật tên hiển thị trong bản build](docs/BRANDING.md)
- **[Master Roadmap — build, gameplay, online, multi-server](docs/MASTER_ROADMAP.md)**
- [Lộ trình refactor engine và network](docs/REFACTORING.md)
- [Ma trận kiểm thử / tiêu chí nghiệm thu](docs/TEST_MATRIX.md)
- **[EXE dùng để làm gì? Native/legacy server, client, test và bản build cũ](docs/EXECUTABLE_GUIDE.md)**
- [M1: Full build Windows x86 và xác minh 22 EXE/DLL](docs/M1_WINDOWS_BUILD.md)
- [Tình trạng hệ thống nhiệm vụ](docs/QUEST_SYSTEM_STATUS.md)
- [Phát thưởng và Linh Thú](docs/REWARDS_AND_PETS.md)
- [Bộ cài phụ thuộc và hướng dẫn cài lần đầu](install/README.md)

## Cấu trúc

```text
pt/
├── PhongThanSource/           # Source C/C++, build scripts gốc
├── PhongThanRuntime-Staging/  # Runtime Client/Server gốc
├── PhongThanRuntime-State/    # Dữ liệu trạng thái trong PT.zip gốc
├── AdminWeb/                  # Công cụ quản trị gốc
├── install/                   # Bộ cài ban đầu: SQL LocalDB (MSI, bootstrapper)
├── _backup/                   # Bản lưu trong PT.zip gốc
├── PhongThan-*.cmd            # Script khởi chạy gốc (chưa xác minh an toàn)
├── CHANGELOG.md               # Changelog gốc
├── docs/
│   ├── original-pt/           # Nội dung PT/docs/ của ZIP gốc
│   └── REPOSITORY_LAYOUT.md   # Giải thích tổ chức source mới
├── archive/                    # Manifest SHA-256 và đường dẫn lịch sử
├── tools/                      # Công cụ kiểm tra, ghép PAK, thử build
├── tests/                      # Kiểm thử công cụ
└── .github/workflows/          # Kiểm thử CI
```

Nội dung trước đây tại `source/PT/` đã được đưa lên **ngay thư mục gốc**.
Không sao chép lại source cũ. Toàn bộ blob gốc được giữ nguyên SHA Git;
riêng thư mục `PT/docs/` được chuyển sang `docs/original-pt/`
để không trùng với tài liệu duy trì repository. Hai bộ cài gốc từ
`Setup/` cũng được **đổi đường dẫn Git** sang `install/` (giữ nguyên blob SHA).
Các lệnh mở game/cài đặt `.cmd` vẫn ở root để giữ khả năng chạy như cũ.

## Tải source về máy

Mở trang repository và chọn **Code → Download ZIP**. Do dữ liệu rất lớn,
GitHub có thể gặp giới hạn khi tạo/tải ZIP; dùng Git nếu cần độ tin cậy cao.

Sau khi clone hoặc tải và giải nén toàn bộ dữ liệu, để ghép và kiểm tra
**16 PAK lớn** đang chia thành **102 phần**, mở terminal tại thư mục `pt`:

```powershell
python tools/restore_split_files.py --repo-root .
```

Các PAK được khôi phục về vị trí trực tiếp dưới root và được kiểm tra SHA-256.
Phải có đủ các file `*.pak.parts/part-*.bin` và đủ dung lượng ổ đĩa.

Để chạy bộ kiểm thử công cụ:

```powershell
python -m unittest discover -s tests -v
```

Muốn thử build có kiểm soát, xem [hướng dẫn hardening](docs/LEGACY_HARDENING.md) và [lộ trình refactor](docs/REFACTORING.md).
Source gốc không được chỉnh sửa trực tiếp; hãy build trên một **bản sao**
ở ngoài checkout, tốt nhất trong Windows x86 VM cách ly.

## Kiểm tra dữ liệu và môi trường

Manifest SHA-256 trong `archive/` và cách ánh xạ đường dẫn từ `source/PT/...`
được mô tả tại [cấu trúc repository](docs/REPOSITORY_LAYOUT.md).

Kho có dữ liệu và file thực thi từ môi trường cũ. Khi thử nghiệm, sử dụng
môi trường cách ly và bản sao bên ngoài checkout; không đưa tài khoản,
dữ liệu nhân vật hoặc cấu hình riêng vào pull request.
