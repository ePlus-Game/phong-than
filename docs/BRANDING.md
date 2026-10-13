# Huyền Vực Ký — đổi thương hiệu game an toàn

Ngày đề xuất: 13/10/2026

- **Tên hiển thị mới:** Huyền Vực Ký
- **Tên ASCII dành cho client C++/INI cũ:** `Huyen Vuc Ky`
- **Trạng thái:** tên đề xuất, chưa tra cứu/đăng ký nhãn hiệu đầy đủ.
- **GitHub slug lịch sử:** `ePlus-Game/phong-than` (không đổi URL repository).
- **Tên kỹ thuật legacy:** `PhongThanSource`, `PhongThanRuntime-Staging`, `Game.exe`, `PhongThanAccountServer.exe`, `*.pak`, đường dẫn `script/phongthan/*`: giữ nguyên.

## Phạm vi đổi tên thực tế

Tạo *overlay* trên bản sao ngoài repository bằng `tools/build_branding_overlay.py`.

| Tệp nguồn được đọc | Nội dung được đổi trong overlay |
|---|---|
| `PhongThanRuntime-Staging/Client/Ui/Setting.ini` | GameName, hộp thoại thoát game, tiêu đề thông báo |
| `PhongThanRuntime-Staging/Client/serverlist.ini` | Nhãn nhóm máy chủ, không đổi IP/port hoặc tên bản đồ |
| `AdminWeb/index.html` | Browser title và tiêu đề trang quản trị |
| `PhongThanSource/Sources/GameClient/PhongThanClient.cpp` | Default game name và tên cửa sổ sau rebuild (kể cả khi cấu hình PAK cũ ghi đè tên) |

Overlay sửa đúng các chuỗi được xác minh và giữ byte/encoding nguồn ngoài phần
đổi; không ghi bất kỳ tệp nào trong kho nguồn, bản staging hoặc PAK gốc.

## Tạo overlay và áp dụng

Dùng Python 3.10+ tại root repo:

```powershell
# 1. Kiểm tra ngữ cảnh, không ghi file
python tools/build_branding_overlay.py --output-dir D:\HuyenVucKy-Branding

# 2. Xuất các tệp nhỏ đã thay nhãn ra ngoài checkout
python tools/build_branding_overlay.py --output-dir D:\HuyenVucKy-Branding --write

# 3. Chạy kiểm thử tại nguồn (không chạy Game.exe)
python -m unittest discover -s tests -p test_branding_overlay.py -v
```

Khi muốn build/chạy thử: tạo **bản sao riêng** của Client/Server và source ở
ngoài checkout. Sau đó merge các tệp trong `D:\HuyenVucKy-Branding` vào bản
sao theo đúng đường dẫn tương đối; build lại client từ source đã được đổi tên.
Nếu không rebuild, cấu hình UI có thể hiển thị tên mới, còn title/ảnh/video
nhúng trong EXE/PAK vẫn có thể dùng nhãn cũ. **Không thay byte PAK trực tiếp**;
muốn đổi splash/logo/các màn hình nhúng cần dựng lại assets do dự án sở hữu
hoặc được cấp phép rồi đóng gói qua pipeline mới.

## Trước khi phát hành thương mại hoặc công khai

- [ ] Tra cứu tên và nhãn hiệu tại cơ sở dữ liệu chính thức, tên miền và các cửa hàng game;
  xin tư vấn pháp lý trước khi sử dụng thương mại.
- [ ] Chứng minh quyền sử dụng **mã nguồn**, PAK, ảnh/SPR, icon, logo, âm thanh,
  nhạc, video, thoại, nhân vật, tên NPC, bản đồ và nội dung cốt truyện.
- [ ] Gỡ/thay thế các tài nguyên hoặc đoạn mã không có giấy phép phù hợp bằng
  tài nguyên độc lập, do nhóm phát triển tạo ra hoặc được cấp phép; không
  chỉ đổi tên/đổi màu tài nguyên có bản quyền.
- [ ] Rà bản phát hành, manifest và version info của `Game.exe`, launcher,
  màn hình đăng nhập, thông báo, tài liệu, website, chính sách/credits.
- [ ] Nếu game được phát hành online tại Việt Nam, kiểm tra nghĩa vụ thủ tục
  cho trò chơi điện tử và yêu cầu chứng minh quyền sở hữu trí tuệ.
- [ ] Nghiệm thu build Windows x86 và UI thực tế: tiêu đề ứng dụng, danh sách
  máy chủ, cửa sổ lỗi/thoát, splash, hỗ trợ CP936/TCVN3.

**Không nên quảng cáo là game "không dính bản quyền" chỉ vì đổi tên.**
Bản lưu gốc công khai vẫn chứa dữ liệu/đường dẫn lịch sử; muốn phân phối một
sản phẩm độc lập phải làm thêm kiểm toán IP và clean-room content package.
