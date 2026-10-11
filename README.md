# Phong Thần 2 — source & original PT.zip archive

Repository này lưu trữ **bộ PT.zip gốc** (99.352 mục) cùng công cụ kiểm tra,
phục hồi và nghiên cứu build. **Chưa xác nhận Client/Server có thể chạy game.**

## Cấu trúc

```text
pt/
├── PhongThanSource/           # Source C/C++, build scripts gốc
├── PhongThanRuntime-Staging/  # Runtime Client/Server gốc
├── PhongThanRuntime-State/    # Dữ liệu trạng thái trong PT.zip gốc
├── AdminWeb/                  # Công cụ quản trị gốc
├── Setup/                     # Bộ cài đặt gốc
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
để không trùng với tài liệu duy trì repository.

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

## Chứng thực và bảo mật

Manifest SHA-256 gốc còn nguyên trong `archive/`, có nhãn đường dẫn lịch sử
`source/PT/...` để giữ bằng chứng import; công cụ restore sẽ tự chuyển sang
đường dẫn hiện tại. Xem [chi tiết ánh xạ](docs/REPOSITORY_LAYOUT.md).

**Cảnh báo:** Đây là repository PUBLIC, có thể chứa sao lưu tài khoản,
dữ liệu nhân vật, cấu hình cũ, nhật ký và tài liệu thuộc sở hữu bên thứ ba.
Không dùng bản này trên hệ thống production, không chạy các file thực thi cũ
trực tiếp và không giả định việc công khai repository là cho phép phân phối
nội dung. Di chuyển/xóa file ở commit mới cũng không xóa chúng khỏi lịch sử Git.
