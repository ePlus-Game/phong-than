# Cửa sổ Tùy chọn: độ phân giải và âm thanh không hoạt động

> Dự án: Phong Thần (bản local) · Ngày: 2026-10-01
> Trạng thái:
> - **Độ phân giải:** đã có chỗ chỉnh trên web admin, có hiệu lực khi mở lại game. Ô chọn trong game cần C++.
> - **Âm thanh:** mã xử lý đủ, đang chờ người dùng mô tả triệu chứng cụ thể.

## Phần 1: Tổng quan
- **Cửa sổ** ESC → Tùy chọn là `KUiOptions`. File giao diện VNG nằm trong vng00.pak (mã `6bf7bc29`).
- **File VNG có các mục:**
  - `Music` / `Sound`: thanh trượt 0–100;
  - `CmbAniQuality`: ô chọn chất lượng hoạt ảnh;
  - **`Resolution`**: ô chọn 800×600 / 1024×768;
  - `MaxPlayerCount`: số người chơi hiển thị;
  - `ShortcutSet` và các nút bật/tắt.
- **Độ phân giải (kiểm chứng):** `KUiOptions` không có mã cho `Resolution`, `CmbAniQuality` hay `MaxPlayerCount`. Các mục này chỉ là hình vẽ, bấm không có tác dụng.
  - Client đọc độ phân giải **một lần lúc khởi động** từ `Client\config.ini` mục `[Client]`: `ScreenWidth`, `ScreenHeight` (800–1920), `FullScreen` (`PhongThanClient.cpp`, `KMyApp::GameInit` dòng 214–216).
- **Âm thanh:** mã có đủ các bước.
  1. Thanh `Music` / `Sound` gửi `GOI_OPTION_SETTING` với `OPTION_MUSIC_VALUE` / `OPTION_SOUND_VALUE`.
  2. Core gọi `KOption::SetMusicVolume` / `SetSndVolume` (thang 0–100), rồi `SetGameVolume`.
  3. Khi đóng cửa sổ, giá trị được lưu vào `UserData\UiCommon.ini`.
  - Tuy vậy `UiCommon.ini` hiện **chưa có** giá trị âm thanh nào, tức cửa sổ chưa từng được đóng bằng nút Xác nhận hoặc ESC theo đường lưu.
  - Đã thử điều khiển game qua chụp/bấm màn hình nhưng game không nhận phím ESC và cú bấm, nên chưa quan sát trực tiếp được.

## Phần 2: Chi tiết
### 2.1 Web admin: "Cài đặt client: độ phân giải" (tab Cài đặt server)
- Chọn 800×600 hoặc 1024×768 (giao diện VNG chỉ thiết kế cho hai mức này), cùng chế độ Cửa sổ / Toàn màn hình. Bấm "Lưu cài đặt client".
- API: `GET /api/clientcfg`, `POST /api/clientcfg`; hàm `Get-ClientCfg` / `Set-ClientCfg` trong `PhongThan-Admin.ps1`.
  - Chỉ sửa 3 khóa trong `[Client]`, giữ nguyên các dòng khác.
  - Mỗi lần lưu sao lưu `config.ini` vào `_backup\client-config\`.
  - Từ chối các độ phân giải khác.
- Có hiệu lực khi **thoát game rồi mở lại** (`PhongThan-MoGame.cmd`).
- **Kiểm thử trên bản sao** `config.ini`: đọc ra 1024×768 cửa sổ; ghi 800×600 toàn màn hình đúng; 1920×1080 bị từ chối. `PhongThan-Admin.ps1` không lỗi cú pháp.

### 2.2 Sửa gốc khi có trình biên dịch C++
- `KUiOptions`: thêm ô chọn `Resolution` (ghi `config.ini`, báo cần mở lại game), `CmbAniQuality` và `MaxPlayerCount`, theo các mục có sẵn trong file giao diện VNG.

## Phần 3: Hành động
- [ ] Mở lại web admin (để nạp API mới) → tab "Cài đặt server" → "Cài đặt client" → chọn độ phân giải → Lưu → thoát game, mở lại bằng `PhongThan-MoGame.cmd`.
- [ ] Âm thanh: cho biết triệu chứng cụ thể:
  - (a) kéo thanh âm lượng không được;
  - (b) kéo được nhưng âm lượng không đổi;
  - (c) game hoàn toàn không có tiếng.

## Phần 4: Tài liệu tham khảo
- `GameClient\Ui\UiCase\UiOptions.cpp` (LoadScheme 158–188, OnScrollBarPosChanged 388, Store/LoadSetting), `Core\Src\KOption.cpp`, `CoreShell.cpp` 3070.
- `GameClient\PhongThanClient.cpp` 171–226, `GameClient\Ui\ShortcutKey.cpp` 1447–1457 (lệnh đổi toàn màn hình ghi `config.ini`).
