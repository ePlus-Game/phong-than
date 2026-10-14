# Install — công cụ cài đặt môi trường Phong Thần Truyền Kỳ

Thư mục này chỉ chứa **bộ cài phụ thuộc dùng khi thiết lập máy lần đầu**,
không phải các bản `Game.exe` hoặc server executable để chơi game.

| File | Chức năng | Khi nào cần |
| --- | --- | --- |
| `SqlLocalDB.msi` | Cài Microsoft SQL Server Express LocalDB, lưu database tài khoản trong môi trường chạy thử cục bộ | Lần đầu dựng máy Windows chưa có LocalDB |
| `SQL2022-SSEI-Expr.exe` | Microsoft SQL Server 2022 Express bootstrapper; có thể tải bộ cài LocalDB nếu không dùng MSI có sẵn | Chỉ khi cần tải/cài lại bộ cài |
| `../PhongThan-CaiDat.cmd` | Entry point cài môi trường tại root: gọi `AdminWeb/PhongThan-Setup.ps1` | Sau khi clone/copy game, trên Windows thử nghiệm |

**Không nhầm** hai file trên với các binary gameplay nằm ở
`PhongThanRuntime-Staging/{Client,Server}/`. Các binary được biên dịch nằm trong
bản sao build `OutputModern/`, không di chuyển vào đây.

## Cách sử dụng

1. Dùng **Windows VM hoặc máy thử nghiệm cách ly**, không có dữ liệu tài khoản thật.
2. Kiểm tra nguồn gốc và **chữ ký số Authenticode** của bộ cài Microsoft, và
   đối chiếu phiên bản với nguồn chính thức. Binary trong archive cũ không tự
   động được coi là an toàn.
3. Chạy `PhongThan-CaiDat.cmd` tại **thư mục gốc repository**; script sẽ dùng
   bộ cài từ `install/` và khôi phục account database trên môi trường đã chuẩn bị.
4. Xem [hướng dẫn cài đặt local](../huong-dan-cai-dat-phong-than-20260928.md)
   và [sơ đồ các EXE](../docs/EXECUTABLE_GUIDE.md). Hướng dẫn tháng 9/2026 là
   ghi nhận lịch sử, **không phải chứng nhận bản game hiện tại chạy online**.

`AdminWeb/PhongThan-Setup.ps1` có fallback về `Setup/` để hỗ trợ các bản
archive cũ. Layout mới chính thức là `install/`.

## Bảo toàn provenance khi chuyển thư mục

Hai bộ cài chỉ được **đổi đường dẫn trong Git**, giữ nguyên blob SHA và size;
không chỉnh sửa/giải nén/rebuild:

| File mới | Git blob SHA-1 (trước = sau di chuyển) | Bytes |
| --- | --- | ---: |
| `install/SQL2022-SSEI-Expr.exe` | `39f02b7794c2078e2516e49ab7119f965e9a8fba` | 4,606,792 |
| `install/SqlLocalDB.msi` | `09d4af8ddf467180dd87ddd61fa8e0cb626f0cac` | 68,452,352 |

SHA ở đây là **Git blob object ID**, không phải SHA-256 tệp hay chứng minh
nguồn cài an toàn. Bảng lịch sử `archive/` giữ nguyên tên đường dẫn ban đầu
`Setup/` để đối chiếu PT.zip gốc.
