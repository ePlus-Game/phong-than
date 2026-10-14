# Cẩm nang tân thủ — Phong Thần Truyền Kỳ

> **Tình trạng:** Tài liệu đang xây dựng, cập nhật 14/10/2026. Đây là dự án phục dựng. **Chưa nghiệm thu gameplay trực tiếp**; hướng dẫn dưới đây không cam kết mọi tính năng hoạt động trong bản build hiện tại.

## 1. Bắt đầu ở đâu?

1. Theo dõi [README dự án](../README.md) để biết phiên bản và cách cài đặt đã được xác minh.
2. Chỉ tải client từ nguồn phát hành chính thức của dự án khi có bản phát hành được xác nhận. **Chưa có hướng dẫn đăng ký, tải và vào server được nghiệm thu**.
3. Khi có bản chơi thử, ưu tiên trải nghiệm nhân vật mới với túi đồ trống và giữ lại thông tin lỗi để báo nhóm phát triển; không dùng tài khoản hoặc dữ liệu nhân vật quan trọng trên môi trường thử nghiệm.

## 2. Ba hệ phái trong game

Ba hệ phái đã được xác định trong đợt nghiên cứu trước: **Côn Lôn, Thiên Sơn và Tiêu Dao**. Tên hệ phái là dữ kiện nghiên cứu đã có; mô tả vai trò chiến đấu, kỹ năng cụ thể và điểm cộng tối ưu vẫn cần đối chiếu với phiên bản runtime hiện tại.

| Hệ phái | Đã xác định | Hướng dẫn chuyên sâu sẽ bổ sung |
| --- | --- | --- |
| **Côn Lôn** | Tên hệ phái | NPC gia nhập, vũ khí, hệ kỹ năng, điểm thuộc tính, trang bị cuối game |
| **Thiên Sơn** | Tên hệ phái | NPC gia nhập, vũ khí, hệ kỹ năng, điểm thuộc tính, trang bị cuối game |
| **Tiêu Dao** | Tên hệ phái | NPC gia nhập, vũ khí, hệ kỹ năng, điểm thuộc tính, trang bị cuối game |

**Gợi ý tân thủ:** Hãy chọn hệ phái theo kỹ năng và phong cách chơi sau khi xem mô tả trong client. Chưa nên đầu tư toàn bộ điểm kỹ năng hoặc nguyên liệu hiếm theo build của một máy chủ khác.

## 3. Cấp độ và lộ trình phát triển

**Cấp tối đa theo kết quả nghiên cứu trước: 150.** Mốc này vẫn cần được tái đối chiếu bằng cấu hình/logic giới hạn cấp của server, bảng EXP và client trước khi gắn nhãn “đã kiểm thử gameplay”.

### Lộ trình cho tân thủ

1. **Bắt đầu:** tạo nhân vật, kiểm tra hướng dẫn và các nhiệm vụ đầu tiên trong client; làm quen di chuyển, NPC, túi đồ, kỹ năng.
2. **Khi mở hệ phái:** tìm hiểu kỹ năng và điều kiện gia nhập trong bản đang chơi; tránh dựa vào tọa độ/NPC của phiên bản khác khi chưa xác nhận.
3. **Trong quá trình tăng cấp:** ưu tiên nội dung nhiệm vụ có phần thưởng đã nghiệm thu; kiểm tra điều kiện cấp trước khi dùng hoặc nâng cấp trang bị.
4. **Khi tiến tới cấp 150:** tra cứu bảng kinh nghiệm, điều kiện mở kỹ năng và nguồn đồ cuối game theo dữ liệu của server; các mốc EXP, khu luyện cấp và nhiệm vụ cụ thể còn phải xác minh.

## 4. Trang bị và nâng cấp

Kết quả nghiên cứu trước xác định **chín nhóm trang bị**: **vũ khí, giáp, mũ, hộ uyển, hộ phù, ngọc bội, dây chuyền, nhẫn, giày**.

| Nhóm | Điều nên kiểm tra trước khi sử dụng |
| --- | --- |
| Vũ khí | Yêu cầu hệ phái, cấp, thuộc tính và kỹ năng liên quan |
| Giáp, mũ, hộ uyển, giày | Điều kiện trang bị, phòng thủ và các chỉ số bổ sung |
| Hộ phù, ngọc bội, dây chuyền, nhẫn | Điều kiện cấp, thuộc tính đặc biệt, khả năng kết hợp bộ |

**Trang bị cao cấp nhất theo từng hệ phái** chưa đủ dữ liệu để công bố tên/ID/chỉ số; không đồng nghĩa danh sách trang bị chưa được nghiên cứu. Bảng dưới đây là phần cần hoàn thiện bằng dữ liệu item thực tế:

| Hệ phái | Trang bị cuối game | Cấp yêu cầu | Chỉ số / hiệu ứng | Cách sở hữu |
| --- | --- | --- | --- | --- |
| Côn Lôn | Chưa đối chiếu ID/tên | Chưa đối chiếu | Chưa đối chiếu | Chưa đối chiếu |
| Thiên Sơn | Chưa đối chiếu ID/tên | Chưa đối chiếu | Chưa đối chiếu | Chưa đối chiếu |
| Tiêu Dao | Chưa đối chiếu ID/tên | Chưa đối chiếu | Chưa đối chiếu | Chưa đối chiếu |

**Thận trọng khi cường hóa/trao đổi trong bản thử nghiệm:** các luồng phát quà và hoàn nguyên liệu Linh Thú chưa có bảo đảm giao dịch nguyên tử hoặc phục hồi khi crash. Xem [Phát quà và Linh Thú](REWARDS_AND_PETS.md).

## 5. Nhiệm vụ, bản đồ, thú

- **Nhiệm vụ:** Đã có kiểm kê script, nhưng không đồng nghĩa mọi nhánh nhiệm vụ đều chơi được. Xem [Trạng thái nhiệm vụ](QUEST_SYSTEM_STATUS.md).
- **Thú cưỡi:** Có dữ liệu bảng `horse.txt`, chưa xác nhận tất cả cách nhận và nâng cấp.
- **Đệ tử Dị Nhân:** Source có hệ thống tăng kinh nghiệm/cấp 1–10, không phải Linh Thú.
- **Linh Thú:** Source runtime có nội dung cho 8 Linh Thú và 4 giai đoạn tiến hóa; chưa thể khẳng định các thao tác đều vận hành ổn định trong gameplay. Xem [Phát quà và Linh Thú](REWARDS_AND_PETS.md).

## 6. Câu hỏi thường gặp

**Level tối đa là bao nhiêu?** Theo nghiên cứu trước là **150**, đang chờ kiểm thử trực tiếp với server/client hiện hành.

**Có những hệ phái nào?** **Côn Lôn, Thiên Sơn và Tiêu Dao**. Khuyến nghị build cụ thể vẫn cần xác minh kỹ năng và độ cân bằng.

**Trang bị mạnh nhất là gì?** Đã ghi nhận chín nhóm trang bị; tên bộ cuối game, ID, chỉ số và nguồn sở hữu từng hệ phái chưa được đối chiếu đủ.

**Đã có thể chơi ổn định chưa?** Chưa. Roadmap xác nhận một số bước build Windows x86 đã PASS nhưng full release và gameplay end-to-end vẫn chưa nghiệm thu. Xem [Master Roadmap](MASTER_ROADMAP.md).

## 7. Checklist để hoàn thiện cẩm nang

- [x] Khôi phục tên ba hệ phái từ nghiên cứu trước: Côn Lôn, Thiên Sơn, Tiêu Dao.
- [ ] Đối chiếu nhánh kỹ năng, điểm thuộc tính từng hệ phái với source/runtime kèm đường dẫn và ID.
- [x] Ghi lại mốc cấp tối đa **150** từ nghiên cứu trước (chưa kiểm thử runtime).
- [ ] Kiểm tra lại cap level bằng code server + EXP table + kiểm thử client.
- [x] Khôi phục danh sách chín nhóm trang bị từ nghiên cứu trước.
- [ ] Đối chiếu danh sách trang bị (ID, tên, hệ phái, yêu cầu cấp, chỉ số, cách nhận).
- [ ] Kiểm thử chuỗi nhiệm vụ tân thủ, NPC, bản đồ và phần thưởng bằng Windows client/server.
- [ ] Viết lộ trình level 1 → tối đa và build đề xuất từng hệ phái trên gameplay đã nghiệm thu.
- [ ] Thêm ảnh chụp gameplay thực tế và lịch sử phiên bản khi có bản chơi thử.

### Quy tắc cập nhật tài liệu

Mỗi thông tin gameplay mới phải có **nguồn dữ liệu cụ thể** (đường dẫn file, ID, tên bảng, logic liên quan), **kết quả kiểm thử** và **phiên bản/commit**. Phân biệt rõ: `phát hiện trong source` → `kiểm thử runtime` → `đã xác nhận gameplay`. Không biến giả thuyết thành hướng dẫn chính thức.
