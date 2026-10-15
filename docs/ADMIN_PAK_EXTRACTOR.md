# Mở khóa phát vật phẩm bằng cách xác minh PAK thật

## Vì sao `git pull` chưa đủ?

Mã công cụ đọc PAK đã build được trên GitHub Actions, nhưng Git không mang
theo các file EXE/DLL của Actions artifact. Web Admin cố ý khóa cấp vật phẩm
nếu **không đọc thành công tất cả 15 bảng vật phẩm từ PAK mà Server sử dụng**.
Giao diện vẫn mở và chức năng tài khoản vẫn dùng được.

## Cài tự động trên Windows (ưu tiên)

1. `git pull --ff-only origin main` tại thư mục game (chỉ khi working tree sạch).
2. Nếu đã có **GitHub CLI (`gh`) và đăng nhập**, nhấp đúp
   `AdminWeb/Install-Pak-Extractor.cmd`.
3. Script chỉ lấy artifact **Windows PAK extractor build** từ workflow
   **thành công trên nhánh `main`**. Lần build `main` đầu tiên có thể cần
   vài phút sau khi merge.
4. Script kiểm tra đủ `PakEntryExtract.exe`, `Engine.dll`, `LuaLibDll.dll`
   là PE32 x86, sau đó **thử trích xuất 15 bảng thật vào thư mục tạm**.
5. Chỉ nếu 15/15 bảng đọc thành công, script mới sao lưu file công cụ cũ
   (nếu có) rồi cài 3 file vào `AdminWeb/bin/`. Không ghi hay sửa PAK.
6. Đóng **riêng cửa sổ Web Admin** rồi mở lại; không tắt SQL/GameServer/Bishop.
   Trong màn hình Phát đồ sẽ thấy "Đã xác minh đủ 15 bảng vật phẩm từ PAK".

Dùng PowerShell nếu muốn xem lỗi trực tiếp:

```powershell
.\AdminWeb\Install-Pak-Extractor.cmd
```

## Nếu máy chưa cài GitHub CLI

Không bắt buộc cài thêm phần mềm. Mở:
[Windows PAK extractor build – GitHub Actions](https://github.com/ePlus-Game/phong-than-truyen-ky/actions/workflows/windows-pak-extractor.yml)

Chọn lần chạy **Success / main**, tải artifact
`phongthan-pak-extractor-win32` (file ZIP) từ mục **Artifacts**.
Sau đó chạy:

```powershell
.\AdminWeb\Install-Pak-Extractor.cmd -ZipPath "C:\Users\YourUser\Downloads\phongthan-pak-extractor-win32.zip"
```

Đường dẫn ZIP là ví dụ: thay bằng vị trí file bạn đã tải thực tế.
Đừng dùng EXE/DLL từ trang tải không rõ nguồn.

## Khi cài nhưng vẫn báo khóa

Bộ cài sẽ ghi cụ thể lỗi, chẳng hạn không tìm thấy file PAK, thiếu DLL,
không tìm thấy một bảng `settings/item/001/*.txt` trong PAK, hoặc lỗi
giải nén. Trang Phát đồ cũng hiển thị tối đa 2 lỗi đầu và số lỗi còn lại.

**Không mở khóa bằng cách sửa boolean**, vì một số mã item từ dữ liệu loose
có thể khác PAK đang chạy. Nếu `PakVerified=false`, phát đồ vẫn khóa.

## Phạm vi an toàn

- Không thay đổi 16+ file PAK, SQL LocalDB, nhân vật, cấu hình server.
- DLL của extractor chỉ được cài vào `AdminWeb/bin`, không sao chép vào
  thư mục Client/Server, vì có thể không tương thích runtime đang chạy.
- CI chỉ chứng minh công cụ build và khởi chạy không tham số; **không thử PAK
  thật trên máy bạn**. Bước test 15/15 trên máy local là điều kiện để bật.
- Số process không chứng minh Bishop đã hoàn tất `WORLD_READY`. Đây là
  điều kiện riêng để đăng nhập game, không liên quan đến kiểm tra bảng item.
