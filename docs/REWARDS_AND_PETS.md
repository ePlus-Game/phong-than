# Phát quà và hệ thống thú — kiểm kê và hardening

Ngày rà soát: 13/10/2026. Nguồn: mã nguồn thực tế trong repository, KHÔNG phải xác nhận client/server chạy trực tiếp.

## Phát quà: đã có, nhưng chưa bảo đảm chính xác mọi trường hợp

- `AdminWeb/PhongThan-Admin.ps1` nhận lệnh `give`, `giveall`, tặng tiền/EXP; hàng đợi
  `admin_bridge/pending.lua` được thực thi trong `script/servertimer.lua` mỗi phút.
- `PTAdm_Give` chỉ phát cho người online, có log FAIL khi phát thiếu;
  `PTAdm_GiveAll` ở nguồn cũ ghi OK ngay cả khi chỉ một phần người chơi nhận đủ.
- `PhongThanRuntime-Staging/Server/script/phongthan/content/dg_lib.lua`
  triển khai quà đăng nhập ngày và mốc 7 ngày. Trạng thái claim dùng task 2541..2543,
  có cơ chế chờ túi trống. **Rủi ro P0:** `PTDG_Deliver` trừ số quà chờ TRƯỚC khi
  `PTDG_GiveList` gọi AddNormalItemPile. Hàm cấp quà đếm số thành công nhưng
  caller bỏ qua và vẫn thông báo đã nhận. Nếu phát lỗi giữa chừng, có thể mất
  quà mà không được khôi phục, hoặc khó xác định số lượng thực nhận.
- Bridge hiện không có bảo đảm exactly-once qua crash; không nên tự động retry
  lệnh phát quà thất bại một phần vì có thể cấp trùng.

**Bản vá overlay:** log `giveall` phân biệt OK/PARTIAL, ghi
targets/complete/partial/failed. Quà đăng nhập kiểm tra số vật phẩm
`AddNormalItemPile` thực sự trả về thành công, chỉ hiển thị thông báo
nhận đủ quà nếu số lượng khớp; nếu thiếu sẽ báo người chơi và ghi
`Server/admin_bridge/dailygift_result.log` (PARTIAL).

**Giới hạn còn lại:** `PTDG_Deliver` vẫn giảm số quà chờ trước khi cấp,
và `PTDG_GiveList` gọi `Earn` không trả về một receipt có thể kiểm tra.
Nếu cấp một phần, hệ thống **không tự phát bù**, do phát lại toàn bộ
có thể nhân đôi vật phẩm/tiền. Cần API grant có transaction/receipt bền
vững và công cụ đối soát GM trước khi sửa luồng trừ số quà chờ.

## Thú: ba hệ thống khác nhau

1. **Thú cưỡi:** bảng `horse.txt`, hiển thị thú cưỡi và admin grant có sẵn.
   Không đồng nghĩa có ép/trộn/cộng cấp thú cưỡi.
2. **Đệ tử Dị Nhân:** `PhongThanBotPet.h` và `petexp_lib.lua`, thức ăn
   `nuoithu_lib.lua` hỗ trợ kinh nghiệm, cấp 1..10. Có thể gọi pet, không phải
   hệ thống tịnh hóa Linh Thú.
3. **Linh Thú:** `sinhhoat/sh_lib.lua`, `lt_npc.lua`, `lt_lenh.lua` gồm
   8 linh thú, 4 giai đoạn tiến hóa, cấp tối đa theo giai đoạn, đổi trứng,
   triệu hồi và cho ăn. Chức năng tiến hóa dùng vật liệu/tiền theo bảng
   `PTLT_EVO`. Đây là gameplay custom đang có trong staging, chưa chứng minh
   tương đương hệ thống ép/tịnh hóa của phiên bản VNG.

**Rủi ro đổi trứng:** `PTLT_Egg` trong source cũ trừ 20 Linh Thú Đơn và
100.000 lượng rồi gọi `PTSH_Give` cấp trứng mà không kiểm tra thành công.
Overlay mới phát hiện thất bại, thử hoàn tiền và nguyên liệu, cảnh báo cần
GM nếu hoàn nguyên liệu không đủ. Đây chỉ là xử lý lỗi có bù, **không phải
giao dịch nguyên tử bền vững**.

**Rủi ro tiến hóa:** `PTLT_Evo` trừ các nhóm vật liệu qua
`PTSH_TierTake` và `Pay`, khi lỗi hoàn tác bằng `PTSH_GiveBack`.
Overlay mới kiểm tra số lượng trả lại khi hoàn vật liệu theo cấp hoặc
hoàn trong `PTSH_TakeAll`. Nếu thiếu, ghi
`Server/admin_bridge/pet_refund_result.log` (PARTIAL) và cảnh báo
người chơi liên hệ GM. Chưa có xử lý giao dịch nguyên tử hoặc bù
tự động sau crash/disconnect.

Tham khảo luật gốc VNG: https://phongthan.vinagame.com.vn/su-kien/tinh-hoa-linh-thu/tinh-hoa-342.html
có NPC Thầy Tướng Số, linh lực, nguyên liệu tịnh hóa, đổi tư chất và
giới hạn cho ăn theo ngày. **Không tự động áp dụng** các ID, tỷ lệ, chi phí
2015 cho bản gameplay hiện tại nếu chưa đối chiếu PAK/phiên bản.

## Cách áp dụng (không sửa source/PAK gốc)

Tạo một **bản sao Server ở ngoài checkout Git** có ít nhất:

- `script/servertimer.lua`
- `script/phongthan/sinhhoat/lt_npc.lua`
- `script/phongthan/content/dg_lib.lua`
- `script/phongthan/sinhhoat/sh_lib.lua`

Sau đó chạy:

```bash
python tools/reward_pet_overlay.py --target /external/copy/Server
python tools/reward_pet_overlay.py --target /external/copy/Server --apply
python -m unittest discover -s tests -p test_reward_pet_overlay.py -v
```

Bản vá tìm đúng ngữ cảnh byte, hỗ trợ CRLF/LF, từ chối dữ liệu lệch và
idempotent. Nó KHÔNG tự deploy, restart hoặc sửa source game gốc.

## Đối soát phát thiếu, hoàn vật liệu và test hồi quy

Sau khi áp overlay lên **bản sao server**, log nằm trong `Server/admin_bridge/`.
Có thể lấy báo cáo tổng hợp lỗi mà không hiển thị tên nhân vật:

```bash
python tools/reconcile_reward_logs.py \
  --daily-log '/isolated/Server/admin_bridge/dailygift_result.log' \
  --pet-log '/isolated/Server/admin_bridge/pet_refund_result.log' \
  --admin-log '/isolated/Server/admin_bridge/result.log' \
  --fail-on-anomaly
python -m unittest discover -s tests -p test_reconcile_reward_logs.py -v
```

Chỉ truyền những đường dẫn log đã tồn tại; có thể bỏ từng tuỳ chọn nếu nguồn log đó
chưa được tạo. Exit code `2` báo cần người quản trị đối soát, không có thao tác
cấp bù hay sửa số lượng. Báo cáo chỉ chứa số liệu tổng hợp, không in tên nhân vật.

**Kiểm thử bắt buộc trong Windows VM sau khi có engine transaction:** thử túi đầy,
thiếu vật phẩm, lệnh `giveall` lặp, server crash giữa 2 item, logout trong lúc
trao đổi, rollback lỗi và restart. Snapshot tiền, vật phẩm, task trước/sau;
đối soát theo request ID và receipt bền vững. Không được đánh dấu PASS chỉ vì
bài Python đọc log thành công.

## Refactor tiếp theo

1. Native transaction `GrantReward` có request ID duy nhất, validate bảng item,
   kiểm tra capacity, cấp đủ hoặc không cấp, receipt bền vững và log GM.
2. Chuyển quà ngày/7 ngày và quà GM sang receipt queue, tách trạng thái
   `pending/processing/applied/failed`. Không phát lại nếu một phần đã thành công.
3. Cấu trúc `PetEvolutionRecipe` theo đúng PAK: nguồn, nguyên liệu, tiền,
   tiến hóa/đổi tư chất, hậu quả thất bại, định danh thú, giới hạn cấp.
4. Test đầy túi, người chơi offline, item không hợp lệ, tạo trứng thất bại,
   thiếu tiền, gọi 2 lần, logout/restart và xác minh không duplicate/mất đồ.
5. Nghiệm thu với Windows x86 Client/Server cô lập trước khi bật trên live.
