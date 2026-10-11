# Ghi chú dựng lại UiShop.ini / UiStoreBox.ini / UiTrade.ini (Phong Thần client)

## Phần 1: Tổng quan

- **Phát hiện chính:** VNG từng phát hành layout cho cả ba cửa sổ, nằm trong PAK dưới **tên tiếng Trung** (tìm theo nội dung, không theo tên):
  - `\ui\ui3\储物箱.ini` (id `6a5d8c4c`, serverlist.pak + ui.pak) → Thủ khố
  - Shop VNG ui3 (id `6b593be4`, tên chưa giải được) → kiểu **danh sách** `ItemBox_0..13`, `BuyBtn1/SellBtn1`, KHÔNG khớp code dựng lại (code dùng 1 ma trận `ItemBox`)
  - Trade VNG ui3 (id `d84aceb8`, tên chưa giải được) → cùng tên section với `KUiTrade` (SelfItemsBox, OtherItemsBox, OkBtn, TradeBtn, CancelBtn, InfoText…), thiếu `TakewithItemsBox/TakewithMoney/AddMoney/ReduceMoney`
  - Bonus: `\ui\ui3\买卖确认.ini` (id `80247c8c`) = layout cho `UiTradeConfirmWnd.ini`; `\ui\ui3\取钱界面.ini` (id `2857fc01`) = layout cho `UiGetMoney.ini`. Hai file này **cũng đang thiếu** và ảnh hưởng trực tiếp tới Shop và Thủ khố.
- Các file nháp dựng từ hình học VNG + ánh xạ sang đúng section/key mà C++ đọc. Mọi sprite đã kiểm tra tồn tại trong index PAK client (hash `FileNameToId`) và đọc header SPR.
- Mã hóa: GBK, CRLF (đã assert). Comment đầu file bằng ASCII.

| File nháp | Nguồn | Độ tin cậy |
|---|---|---|
| UiShop.ini | Tự dựng trên `买卖面板.spr` | Key: cao · Hình học: trung bình (lưới 6x10 đè lên art dạng danh sách) |
| UiStoreBox.ini | Ánh xạ từ `储物箱.ini` VNG | Key: cao · Hình học: khá (10 hàng ép vào art 8 hàng) |
| UiTrade.ini | Ánh xạ từ trade ui3 VNG | Key: cao · Hình học ô trade: cao · Túi đồ nổi bên phải: trung bình-thấp (UX) |
| UiTradeConfirmWnd.ini (bonus) | Copy nguyên `买卖确认.ini` | Cao |
| UiGetMoney.ini (bonus) | Copy nguyên `取钱界面.ini` | Cao |

## Phần 2: Chi tiết

### 2.1 Section/key C++ đọc

Đường dẫn gốc: `E:\VL\Phong than\PT\PhongThanSource\Sources\GameClient\Ui\`

**KUiShop** — `UiCase\UiShop.cpp:26` (`SCHEME_INI "UiShop.ini"`), `LoadScheme` 97–114:
| Section | Dòng | Kiểu (UiShop.h) |
|---|---|---|
| Main | 103 | KWndShowAnimate |
| ItemBox | 104 | KWndObjectMatrix (`EnablePickPut(false)` 112) |
| BuyBtn / SellBtn / RepairBtn | 105–107 | KWndButton (CheckBox — code gọi `CheckButton`) |
| LeftBtn / RightBtn | 108–109 | KWndButton (Enable khi >1 trang, 302–303) |
| CloseBtn | 110 | KWndButton |

**KUiStoreBox** — `UiCase\UiStoreBox.cpp:24`, `LoadScheme` 187–203:
Main (192, KWndShowAnimate) · Money (193, KWndText32) · GetMoneyBtn (194) · CloseBtn (195) · ItemBox (196, KWndObjectMatrix, `EnableTracePutPos(true)`) · CurPage (198, KWndText32, text do code set 111–136) · LeftBtn (199) · RightBtn (200).

**KUiTrade** — `UiCase\UiTrade.cpp:27`, `LoadScheme(KIniFile*)` 148–176:
Main (150) · TakewithItemsBox (151, matrix) · TakewithMoney (152, KWndText32) · SelfItemsBox (153, matrix) · SelfMoney (154, **KWndEdit32**) · OkBtn (155) · CancelBtn (156) · TradeBtn (157) · AddMoney (158) · ReduceMoney (159) · OtherName (160) · OtherItemsBox (161) · OtherMoney (162) · InfoText (163) · thêm key `[InfoText] WaitTradeMsgColor / LockMsgColor / UnlockMsgColor` (167–172).

**Key của lớp cơ sở (Elem\)**
| Lớp | File:dòng | Key |
|---|---|---|
| KWndWindow | WndWindow.cpp:237–289 | Width, Height, Left, Top, Disable, Moveable, Value, FollowMove, FollowSize, DummyWnd |
| KWndImage | WndImage.cpp:34–81 | Trans, ImgType, Image, Frame, EffectImage (Width/Height=0 → lấy theo SPR) |
| KWndMovingImage | WndMovingImage.cpp:37–47 | EndPos |
| KWndShowAnimate | WndShowAnimate.cpp:29–43 | StartPos |
| KWndButton | WndButton.cpp:73–118 | Up, Down, DisableFrame, NoOverSound, Over, OverFrame, CheckBox, CheckOver, SendHoldMsg, TipHover, Tip |
| KWndText | WndText.cpp:146–197 | Font, HAlign, VAlign, Color, BorderColor, Text, MultiLine, TipHover, Tip |
| KWndEdit | WndEdit.cpp:94–167 | MultiLine, Password, Type (0 = chỉ số), MaxLen, Color, BorderColor, Font, FocusBKColor(Alpha), Shadow, TipHover, Tip |
| KWndObjectMatrix | WndObjContainer.cpp:388–420 | HUnits, VUnits (ô = Width/HUnits), HaveBgColor, AcceptFree, UnitBorder |

Các key VNG như `PopupPos`, `CalculateWay`, `TextFont` không được code dựng lại đọc → đã bỏ.

### 2.2 Ràng buộc kích thước lưới (từ Core)

- Shop: `CoreShell.cpp:1201–1251` xếp hàng vào `KInventory` 6x10 mỗi trang (`KBuySell.cpp:25–26, 354`), `KInventory::FindRoom` (KInventory.cpp:206–229) duyệt **theo cột** → bắt buộc `HUnits=6 VUnits=10`, nếu 6x8 thì hàng 9–10 mỗi cột bị mất.
- Thủ khố: `GameDataDef.h:428–429` REPOSITORY 6x10 (cả 5 rương mở rộng, KItemList.cpp:959–964) → 6x10.
- Trade: `TRADE_ROOM` 10x4 (GameDataDef.h:431–432); vị trí do người thả quyết định → dùng tập con 5x3 như VNG là an toàn **nếu cả hai client dùng cùng file**.
- Túi đồ: `EQUIPMENT_ROOM` 6x10 → `TakewithItemsBox` 6x10.
- Icon vật phẩm PT: 1x1 ô, SPR 32x32 (kiểm tra `\spr\item\medecine\小红.spr`, `\spr\item\equip\衣服11.spr`…). Item thường vẽ qua `PaintInventorySlot` (co icon vừa ô, KItem.cpp:856); hàng shop vẽ qua `KBuySell::PaintItem` → `KItem::Paint` **không co**, neo góc trái-trên ô (KBuySell.cpp:712–728).

### 2.3 Sprite đã dùng (đã xác minh trong PAK client)

| Sprite | Kích thước | Frame | PAK |
|---|---|---|---|
| `\spr\Ui4\买卖\买卖面板.spr` | 282x409 | 1 | update0_164-166 |
| `\Spr\Ui4\买卖\买.spr` ("Mua") | 22x11 | 2 | update0_164-166 |
| `\Spr\Ui4\买卖\卖.spr` ("Bán") | 20x12 | 2 | update0_164-166 |
| `\Spr\Ui4\买卖\修理键_3.spr` (búa) | 20x20 | 2 | update0_122-163 |
| `\Spr\Ui4\买卖\上一页.spr` / `下一页.spr` ("Trang trước/sau") | 55x14 | 2 | update0_164-166 |
| `\spr\Ui4\按钮\关闭键.spr` | 20x20 | 3 | update0_164-166 |
| `\spr\Ui4\储物箱\新储物箱.spr` ("Rương chứa đồ") | 259x425 | 1 | update0_164-166 |
| `\spr\Ui4\储物箱\取钱.spr` ("Rút tiền") | 47x19 | 3 | update0_164-166 |
| `\Spr\Ui4\交易\交易.spr` ("Giao dịch") | 260x400 | 1 | update0_164-166 |
| `\Spr\Ui4\交易\锁定.spr` ("Khóa") / `确定.spr` ("Xác định") / `取消.spr` ("Hủy") | 47x19 | 3 | update0_164-166 |
| `\Spr\UI4\主界面\聊天\向上滚动.spr` / `向下滚动.spr` (±tiền) | 15x15 | 2 | update0_164-166 |
| Bonus: `特殊对话条\输入文字条.spr` 235x135, `买进` 125x69, `卖出` 152x68, `修理` 133x68, `加数量/减数量` 13x13, `按钮\确定/取消` 47x19, `取钱条.spr` 232x133 | | | |

Không tồn tại (đã thử, không dùng): `买卖面板卖.spr` (VNG ini tham chiếu nhưng thiếu), `买卖面板买.spr`, `储物箱\上一页.spr`, `交易\加钱.spr`, `Ui3\*`. Trong bản copy `UiTradeConfirmWnd.ini` có `[ImmortalImgTitle]` trỏ tới `仙魔声望买进.spr` bị thiếu — section này code không đọc, vô hại.

Tọa độ ô lấy bằng cách giải mã SPR và đo profile pixel: trade ô 33px bước 41x37 bắt đầu (30,46)/(30,204); thủ khố ô bước 36 bắt đầu (22,74); thanh đáy shop (34..246, 355..379). Ảnh mock kiểm tra: `png\mock_UiShop.png`, `mock_UiStoreBox.png`, `mock_UiTrade.png`.

## Phần 3: Hành động / Rủi ro còn lại

### Những điểm C++ vẫn có thể làm hỏng cửa sổ
1. **`UiTradeConfirmWnd.ini` thiếu** → click trái vào hàng khi chưa bật "Mua" mở `KUiTradeConfirm` vô hình (UiShop.cpp:194–200); click phải cần giữ Shift (207–221). → cài kèm bonus `UiTradeConfirmWnd.ini`.
2. **`UiGetMoney.ini` thiếu** → nút "Rút tiền" của Thủ khố mở hộp vô hình (UiStoreBox.cpp:220). → cài kèm bonus `UiGetMoney.ini`.
3. Thủ khố không có nút gửi tiền trong code (chỉ `GOI_MONEY_INOUT_STORE_BOX` với false = rút, 247–252); click phải vật phẩm là no-op (`OnClickItem` 254–265 không gửi request); kéo-thả chỉ chạy khi `UIS_S_IDLE` (268).
4. Trade: `m_OtherName.SetText(pOther->Name)` chạy trước khi kiểm tra `pOther` (UiTrade.cpp:50–52) → crash nếu NULL (lỗi có sẵn). Tooltip đồ đối phương dùng bước cứng 26px (UiTrade.cpp:266) → lệch vị trí với ô 41x37 (chỉ thẩm mỹ).
5. Trade: `TakewithItemsBox` không có chỗ trên art VNG → đặt **nổi bên phải panel** (x 264..480). Cần `DummyWnd=1` + `Trans=1` ở `[Main]` để click tới được con nằm ngoài ảnh (KWndWindow::PtInWindow WndWindow.cpp ~319, KWndImage::PtInWindow WndImage.cpp:87–100). Nền trống, đè lên `KUiItem` (Left=273) nếu đang mở. Phương án khác: đặt `Width=0/Height=0` để ẩn và kéo từ `KUiItem` (chưa kiểm chứng việc kéo chéo cửa sổ khi status = `UIS_S_TRADE_PLAYER`).
6. Shop: lưới 6x10 (ô 40x30) đè lên art dạng danh sách 2x7 → lệch thẩm mỹ; icon 32px không co nên chồng 2px theo chiều dọc.
7. Thủ khố: art vẽ 6x8 ô 36px, lưới cần 6x10 → hàng 29px, icon co ~25px, đường kẻ art không khớp hàng.
8. **Nghi vấn ngoài phạm vi:** `Client\Ui\ui3\UiItem.ini` (copy từ `随身物品.ini` VNG) dùng `HUnits=5 VUnits=7`, trong khi Core dựng lại có `EQUIPMENT_ROOM 6x10` (GameDataDef.h:425–426) và `UiItem.cpp` không phân trang → đồ ở cột 6 / hàng 8–10 của túi sẽ không hiển thị. Nên kiểm tra.
9. Chuỗi hiển thị: Tip của `RepairBtn` là byte VNG gốc (mã VN cũ, tiền tố `$`) copy nguyên; các nút khác không có Tip.

### Checklist cài đặt (người dùng tự làm)
- [ ] Backup `Client\Ui\ui3\` trước khi chép.
- [ ] Chép `UiShop.ini`, `UiStoreBox.ini`, `UiTrade.ini` (+ khuyến nghị `UiTradeConfirmWnd.ini`, `UiGetMoney.ini`) vào `E:\VL\Phong than\PT\PhongThanRuntime-Staging\Client\Ui\ui3\` (không có trong PAK nên file rời sẽ được đọc, giống UiTaskNote.ini).
- [ ] Test: NPC `Sale(n)` → shop hiện, đổi trang, bật Mua/Bán/Sửa; Thủ khố → kéo thả, Trang trước/sau, Rút tiền; Trade 2 client → đặt đồ, ±tiền, Khóa → Xác định.
- [ ] Nếu cần tinh chỉnh vị trí: sửa Left/Top trong ini, không cần build lại.

## Phần 4: Tài liệu tham khảo
- File nháp: `...\scratchpad\uiini\UiShop.ini`, `UiStoreBox.ini`, `UiTrade.ini`, `UiTradeConfirmWnd.ini`, `UiGetMoney.ini`
- Layout VNG gốc đã giải nén: `...\uiini\hits\*.ini` (GBK)
- Công cụ: `pk.py` (hash + đọc PAK theo thứ tự package.ini + đọc header SPR), `sprpng.py` (giải mã SPR → PNG), `gen.py` (sinh file + kiểm tra sprite), `mock.py` (ảnh mock bố cục)
