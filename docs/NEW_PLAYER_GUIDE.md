# Cẩm nang tân thủ — Phong Thần Truyền Kỳ

> **Tình trạng:** Tài liệu đang xây dựng, cập nhật 14/10/2026. Đây là dự án phục dựng. **Chưa nghiệm thu gameplay trực tiếp**; hướng dẫn dưới đây không cam kết mọi tính năng hoạt động trong bản build hiện tại.

## 1. Bắt đầu ở đâu?

1. Theo dõi [README dự án](../README.md) để biết phiên bản và cách cài đặt đã được xác minh.
2. Chỉ tải client từ nguồn phát hành chính thức của dự án khi có bản phát hành được xác nhận. **Chưa có hướng dẫn đăng ký, tải và vào server được nghiệm thu**.
3. Khi có bản chơi thử, ưu tiên trải nghiệm nhân vật mới với túi đồ trống và giữ lại thông tin lỗi để báo nhóm phát triển; không dùng tài khoản hoặc dữ liệu nhân vật quan trọng trên môi trường thử nghiệm.

> **Hướng dẫn theo nhiệm vụ và mốc cấp:** [Lộ trình tân thủ của Giáp Sĩ, Đạo Sĩ và Dị Nhân](BEGINNER_QUESTS.md).

## 2. Ba hệ phái: Giáp Sĩ, Đạo Sĩ, Dị Nhân

**Đính chính:** Ba hệ phái theo cẩm nang Phong Thần VinaGame là **Giáp Sĩ, Đạo Sĩ và Dị Nhân**. Tài liệu trước đã nhầm Côn Lôn, Thiên Sơn, Tiêu Dao thành hệ phái. Không dùng ba tên này để hướng dẫn chọn lớp nhân vật.

| Hệ phái | Phong cách chơi theo tài liệu VNG | Gợi ý tân thủ |
| --- | --- | --- |
| **Giáp Sĩ** | Cận chiến, sức mạnh, thể lực và giáp phòng ngự; có thể cưỡi thần thú | Hợp với người thích áp sát và chiến đấu trực diện |
| **Đạo Sĩ** | Ma pháp âm dương, ngũ hành, địa/thủy/phong/hỏa; di chuyển bằng thần điểu | Hợp với người thích đánh bằng phép |
| **Dị Nhân** | Triệu hồi trợ thủ như lực sĩ, tinh quân, thiên quân, thần thú; bùa chú tiêu hao đối phương; có cánh | Hợp với người thích triệu hồi và phối hợp hiệu ứng |

Nguồn chính thức: [Giáp Sĩ](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-giap-si.html), [Đạo Sĩ](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-dao-si.html), [Dị Nhân](https://phongthan.vinagame.com.vn/cam-nang/gioi-thieu/tam-gioi-di-nhan.html). Đây là mô tả **bản gốc VNG**; kỹ năng và gameplay trong bản phục dựng cần kiểm thử riêng.

### Ví dụ nhiệm vụ cấp 1 (theo VNG; chưa xác nhận ở bản phục dựng)

| Hệ phái | Nhiệm vụ | NPC / vị trí |
| --- | --- | --- |
| Giáp Sĩ | Hộp Gấm | Tô Hộ (200,204), Sùng Thành Đại Doanh |
| Đạo Sĩ | Bách Lý | Từ Hàng Đạo Nhân (206,196) |
| Dị Nhân | Khai Trí | Thiếu Hạo (198,204) |

**Lưu ý:** Không nhầm tên địa danh, ví dụ Côn Lôn, với tên hệ phái. Để có hướng dẫn kỹ năng, cộng điểm, nhiệm vụ và trang bị chính xác cho bản phục dựng, cần đối chiếu code và chạy gameplay.

## 3. Cấp độ và lộ trình phát triển

**Giới hạn cấp được định nghĩa trong code: 200.** Kiểm tra `GameDataDef.h:74` và `KPlayer.cpp`; file `settings/npc/player/level_exp.txt` có 200 dòng. **Chưa được nghiệm thu đạt cấp 200 thực tế** vì dữ liệu EXP từ cấp 131 có giá trị lớn hơn số nguyên 32-bit mà engine đang sử dụng. Xem [báo cáo đối chiếu source](GAMEPLAY_SOURCE_AUDIT.md).

### Lộ trình cho tân thủ

1. **Bắt đầu:** tạo nhân vật, kiểm tra hướng dẫn và các nhiệm vụ đầu tiên trong client; làm quen di chuyển, NPC, túi đồ, kỹ năng.
2. **Khi mở hệ phái:** tìm hiểu kỹ năng và điều kiện gia nhập trong bản đang chơi; tránh dựa vào tọa độ/NPC của phiên bản khác khi chưa xác nhận.
3. **Trong quá trình tăng cấp:** ưu tiên nội dung nhiệm vụ có phần thưởng đã nghiệm thu; kiểm tra điều kiện cấp trước khi dùng hoặc nâng cấp trang bị.
4. **Khi đạt cấp cao:** tra cứu bảng kinh nghiệm, điều kiện mở kỹ năng và nguồn đồ cuối game theo dữ liệu của server; các mốc EXP, khu luyện cấp và nhiệm vụ cụ thể còn phải xác minh.

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
| Giáp Sĩ | Chưa đối chiếu ID/tên | Chưa đối chiếu | Chưa đối chiếu | Chưa đối chiếu |
| Đạo Sĩ | Chưa đối chiếu ID/tên | Chưa đối chiếu | Chưa đối chiếu | Chưa đối chiếu |
| Dị Nhân | Chưa đối chiếu ID/tên | Chưa đối chiếu | Chưa đối chiếu | Chưa đối chiếu |

**Thận trọng khi cường hóa/trao đổi trong bản thử nghiệm:** các luồng phát quà và hoàn nguyên liệu Linh Thú chưa có bảo đảm giao dịch nguyên tử hoặc phục hồi khi crash. Xem [Phát quà và Linh Thú](REWARDS_AND_PETS.md).

## 5. Nhiệm vụ, bản đồ, thú

- **Nhiệm vụ:** Đã có kiểm kê script, nhưng không đồng nghĩa mọi nhánh nhiệm vụ đều chơi được. Xem [Trạng thái nhiệm vụ](QUEST_SYSTEM_STATUS.md).
- **Thú cưỡi:** Có dữ liệu bảng `horse.txt`, chưa xác nhận tất cả cách nhận và nâng cấp.
- **Đệ tử Dị Nhân:** Source có hệ thống tăng kinh nghiệm/cấp 1–10, không phải Linh Thú.
- **Linh Thú:** Source runtime có nội dung cho 8 Linh Thú và 4 giai đoạn tiến hóa; chưa thể khẳng định các thao tác đều vận hành ổn định trong gameplay. Xem [Phát quà và Linh Thú](REWARDS_AND_PETS.md).

## 6. Câu hỏi thường gặp

**Level tối đa là bao nhiêu?** **200 theo định nghĩa trong code**, nhưng chưa có kiểm thử chứng minh nhân vật có thể lên cấp 200 ổn định; có rủi ro xử lý EXP từ cấp 131.

**Có những hệ phái nào?** **Giáp Sĩ, Đạo Sĩ và Dị Nhân**. Khuyến nghị build cụ thể vẫn cần xác minh kỹ năng và độ cân bằng.

**Trang bị mạnh nhất là gì?** Đã ghi nhận chín nhóm trang bị; tên bộ cuối game, ID, chỉ số và nguồn sở hữu từng hệ phái chưa được đối chiếu đủ.

**Đã có thể chơi ổn định chưa?** Chưa. Roadmap xác nhận một số bước build Windows x86 đã PASS nhưng full release và gameplay end-to-end vẫn chưa nghiệm thu. Xem [Master Roadmap](MASTER_ROADMAP.md).

## 7. Checklist để hoàn thiện cẩm nang

- [x] Xác minh tên ba hệ phái theo cẩm nang VNG: Giáp Sĩ, Đạo Sĩ, Dị Nhân.
- [ ] Đối chiếu nhánh kỹ năng, điểm thuộc tính từng hệ phái với source/runtime kèm đường dẫn và ID.
- [x] Đã đối chiếu MAX_LEVEL=200 và bảng EXP server/client 1–200 từ code.
- [ ] Nghiệm thu xử lý EXP cấp 131–200 vượt signed-int32 và kiểm thử nhân vật tăng cấp trong game.
- [ ] Kiểm tra lại cap level bằng code server + EXP table + kiểm thử client.
- [x] Khôi phục danh sách chín nhóm trang bị từ nghiên cứu trước.
- [ ] Đối chiếu danh sách trang bị (ID, tên, hệ phái, yêu cầu cấp, chỉ số, cách nhận).
- [ ] Kiểm thử chuỗi nhiệm vụ tân thủ, NPC, bản đồ và phần thưởng bằng Windows client/server.
- [ ] Viết lộ trình level 1 → tối đa và build đề xuất từng hệ phái trên gameplay đã nghiệm thu.
- [ ] Thêm ảnh chụp gameplay thực tế và lịch sử phiên bản khi có bản chơi thử.

### Quy tắc cập nhật tài liệu

Mỗi thông tin gameplay mới phải có **nguồn dữ liệu cụ thể** (đường dẫn file, ID, tên bảng, logic liên quan), **kết quả kiểm thử** và **phiên bản/commit**. Phân biệt rõ: `phát hiện trong source` → `kiểm thử runtime` → `đã xác nhận gameplay`. Không biến giả thuyết thành hướng dẫn chính thức.
