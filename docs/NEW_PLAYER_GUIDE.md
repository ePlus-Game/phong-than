# Cẩm nang tân thủ — Phong Thần Truyền Kỳ

> **Tình trạng:** Tài liệu đang xây dựng, cập nhật 14/10/2026. Đây là dự án phục dựng. **Chưa nghiệm thu gameplay trực tiếp**; hướng dẫn dưới đây không cam kết mọi tính năng hoạt động trong bản build hiện tại.

## 1. Bắt đầu ở đâu?

1. Theo dõi [README dự án](../README.md) để biết phiên bản và cách cài đặt đã được xác minh.
2. Chỉ tải client từ nguồn phát hành chính thức của dự án khi có bản phát hành được xác nhận. **Chưa có hướng dẫn đăng ký, tải và vào server được nghiệm thu**.
3. Khi có bản chơi thử, ưu tiên trải nghiệm nhân vật mới với túi đồ trống và giữ lại thông tin lỗi để báo nhóm phát triển; không dùng tài khoản hoặc dữ liệu nhân vật quan trọng trên môi trường thử nghiệm.

## 2. Chọn hệ phái

Dự án cần đối chiếu dữ liệu nhân vật và kỹ năng trong source/runtime để xác nhận **tên chính xác của ba hệ phái, nhánh phát triển, ưu nhược điểm và bộ kỹ năng khả dụng**. Không sử dụng tên, kỹ năng hoặc chỉ số của các phiên bản Phong Thần khác làm dữ liệu mặc định.

| Hệ phái | Vai trò / cách chơi | Lộ trình kỹ năng | Trạng thái |
| --- | --- | --- | --- |
| Hệ phái 1 — chờ xác minh tên | Chưa kiểm chứng | Chưa kiểm chứng | Cần đối chiếu source/PAK |
| Hệ phái 2 — chờ xác minh tên | Chưa kiểm chứng | Chưa kiểm chứng | Cần đối chiếu source/PAK |
| Hệ phái 3 — chờ xác minh tên | Chưa kiểm chứng | Chưa kiểm chứng | Cần đối chiếu source/PAK |

## 3. Cấp độ và tăng sức mạnh

**Cấp tối đa của nhân vật: chưa xác minh.** Cần xác định giới hạn thực thi phía server, bảng EXP/cấp độ và UI client trước khi công bố. Không lấy level cap từ trang giới thiệu hoặc phiên bản máy chủ khác.

Khi gameplay được nghiệm thu, phần này sẽ bổ sung:
- Lộ trình từ cấp đầu đến cấp tối đa, chia theo mốc nhiệm vụ/bản đồ đã kiểm chứng.
- Điểm thuộc tính, kỹ năng và điều kiện học kỹ năng riêng của từng hệ phái.
- Cách kiếm tiền và vật phẩm phù hợp với người mới; không gợi ý địa điểm cày cấp chưa được kiểm thử.

## 4. Trang bị và vật phẩm

**Bộ trang bị cao cấp nhất của mỗi hệ phái: chưa xác minh.** Cần đọc bảng vật phẩm/thuộc tính/điều kiện mặc trang bị, nguồn rơi hoặc đổi vật phẩm từ dữ liệu runtime; kiểm tra client thực sự hiển thị và server thực sự cấp được.

| Hệ phái | Trang bị khởi đầu | Trang bị nâng cấp | Trang bị cuối game | Nguồn sở hữu |
| --- | --- | --- | --- | --- |
| Hệ phái 1 | Chưa xác minh | Chưa xác minh | Chưa xác minh | Chưa xác minh |
| Hệ phái 2 | Chưa xác minh | Chưa xác minh | Chưa xác minh | Chưa xác minh |
| Hệ phái 3 | Chưa xác minh | Chưa xác minh | Chưa xác minh | Chưa xác minh |

**Lưu ý an toàn vật phẩm trong bản thử nghiệm:** Một số luồng phát quà và hoàn nguyên liệu của Linh Thú đã được rà soát ở mức source, nhưng chưa đảm bảo giao dịch nguyên tử hoặc phục hồi sau crash. Không thử các thao tác trao đổi/nâng cấp có giá trị trên dữ liệu quan trọng. Xem [Phát quà và Linh Thú](REWARDS_AND_PETS.md).

## 5. Nhiệm vụ, bản đồ, thú

- **Nhiệm vụ:** Đã có kiểm kê script, nhưng không đồng nghĩa mọi nhánh nhiệm vụ đều chơi được. Xem [Trạng thái nhiệm vụ](QUEST_SYSTEM_STATUS.md).
- **Thú cưỡi:** Có dữ liệu bảng `horse.txt`, chưa xác nhận tất cả cách nhận và nâng cấp.
- **Đệ tử Dị Nhân:** Source có hệ thống tăng kinh nghiệm/cấp 1–10, không phải Linh Thú.
- **Linh Thú:** Source runtime có nội dung cho 8 Linh Thú và 4 giai đoạn tiến hóa; chưa thể khẳng định các thao tác đều vận hành ổn định trong gameplay. Xem [Phát quà và Linh Thú](REWARDS_AND_PETS.md).

## 6. Câu hỏi thường gặp

**Level tối đa là bao nhiêu?** Chưa có kết quả đối chiếu đủ tin cậy giữa server, bảng EXP và client.

**Nên chọn hệ phái nào cho người mới?** Chưa thể khuyến nghị trước khi xác nhận tên hệ phái, kỹ năng và độ cân bằng thực tế.

**Trang bị mạnh nhất là gì?** Chưa xác minh bảng item và nguồn sở hữu; không nên dựa vào hình ảnh từ phiên bản khác.

**Đã có thể chơi ổn định chưa?** Chưa. Roadmap xác nhận một số bước build Windows x86 đã PASS nhưng full release và gameplay end-to-end vẫn chưa nghiệm thu. Xem [Master Roadmap](MASTER_ROADMAP.md).

## 7. Checklist để hoàn thiện cẩm nang

- [ ] Trích tên ba hệ phái, nhánh kỹ năng, điểm thuộc tính từ source/runtime kèm đường dẫn và ID.
- [ ] Xác định cap level bằng code server + EXP table + kiểm thử client.
- [ ] Đối chiếu danh sách trang bị (ID, tên, hệ phái, yêu cầu cấp, chỉ số, cách nhận).
- [ ] Kiểm thử chuỗi nhiệm vụ tân thủ, NPC, bản đồ và phần thưởng bằng Windows client/server.
- [ ] Viết lộ trình level 1 → tối đa và build đề xuất từng hệ phái trên gameplay đã nghiệm thu.
- [ ] Thêm ảnh chụp gameplay thực tế và lịch sử phiên bản khi có bản chơi thử.

### Quy tắc cập nhật tài liệu

Mỗi thông tin gameplay mới phải có **nguồn dữ liệu cụ thể** (đường dẫn file, ID, tên bảng, logic liên quan), **kết quả kiểm thử** và **phiên bản/commit**. Phân biệt rõ: `phát hiện trong source` → `kiểm thử runtime` → `đã xác nhận gameplay`. Không biến giả thuyết thành hướng dẫn chính thức.
