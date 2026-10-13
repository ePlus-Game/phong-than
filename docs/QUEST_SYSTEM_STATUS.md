# Hệ thống nhiệm vụ Phong Thần — hiện trạng và lộ trình refactor

Kiểm kê ngày 13/10/2026, dựa trên source và tài liệu kiểm thử tháng 9/2026. Đây không phải nghiệm thu gameplay mới.

## Đã có nền tảng

- Lua 4, NPC dialog, dữ liệu tiến độ nhiệm vụ theo người chơi, TaskNote/UI_NOTEINFO.
- QuestExchange: kiểm thử giao vật phẩm và nhận thưởng an toàn, xử lý túi đầy, sai stage, thất bại giữa chừng và bấm lặp.
- 5 chuỗi gốc đã được kiểm thử (task 20, 11, 31, 23, 26); tài liệu NPC_QUEST_FOUNDATION_HANDOFF.md ghi nhận 24 tình huống/1.112 assertion, tiến độ diệt quái 68 assertion.
- Lưu/đọc trạng thái nhiệm vụ tại SavePlayerTaskList/LoadPlayerTaskList đã có bằng chứng kiểm thử độc lập.
- Các bản Lua quest diệt quái, Tô Hộ và Xích Tùng Tử có bằng chứng xuất xứ và nguồn patch riêng.

## Chưa hoàn thành

- Trong chiến dịch 126 NPC, 84 script mới hướng dẫn, chưa phải quest giao dịch hoàn chỉnh. 42 script khác có nhánh Lua gốc nhưng chưa nghiệm thu mọi nhánh thực tế.
- Một NPC hiện chưa có vị trí hợp lệ do thiếu geometry.
- Các chuỗi nhiệm vụ, quest ngày, điều kiện phái/level, nhận thưởng một lần, UI journal, save/load/reconnect và chuyển NPC chưa được nghiệm thu end-to-end toàn bộ.
- Không nên đồng nhất kiểm thử Lua 4, kiểm thử giao dịch mô phỏng và build thành công với game đã playable.

## Triển khai tiếp theo

1. Dùng tools/quest_content_audit.py để xác minh SHA-256 nguồn Lua VNG, file compiled, appendix Tô Hộ/Xích Tùng Tử, 12 fixture Lua và contract TaskNote. Không sửa PAK, save hoặc runtime.
2. Lập ma trận từng nhiệm vụ: map/NPC, hash script, task ID, step, nhận/hoàn thành, monster/item, điều kiện, thưởng, save/restart và trạng thái test.
3. Rà 42 nhánh gốc và bổ sung test giao dịch thật theo từng script; không thay task ID hoặc phần thưởng nếu chưa kiểm chứng.
4. Triển khai nghiệp vụ của 84 script còn hướng dẫn, có test túi đầy, hết nguyên liệu, quest trùng, offline, party, rollback và thưởng đúng một lần.
5. Nghiệm thu build Windows x86 trên bản sao source, rồi chạy thử nhận nhiệm vụ → diệt quái → giao vật phẩm → nhận thưởng → restart trên client/server cô lập.

## Phạm vi CI

- Workflow quest-content-integrity.yml chạy Python unit tests và kiểm tra SHA-256.
- Sparse checkout chỉ tải script nhỏ, fixture, JSON; không tải PAK hoặc runtime lớn.
- CI không thực thi game và không khẳng định mọi nhiệm vụ đã hoàn chỉnh.

Xem thêm: PhongThanSource/Docs/NPC_QUEST_FOUNDATION_HANDOFF.md,
NPC_AUTHORED_126_RESULT.md và NPC_LUA_FOUNDATION_RESULT.md.
