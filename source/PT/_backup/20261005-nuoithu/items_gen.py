# hanhtrang (2026-10-04): generate the Lua of the "Lenh Bai Hanh Trang" (magicscript 61500).
# Output (ASCII, TCVN3 as \ddd escapes, CRLF) to scratchpad\items\out\script\phongthan\:
#   item\hanhtrang_lenhbai.lua  item script: common part + menus + main (open box, clean bag, pickup / clean settings)
#   item\hanhtrang_lib.lua      common part + minute tick + web admin entry, no main(): dofile'd into the servertimer state
#   ext\hanhtrang.lua           PTEXT_hanhtrang_Tick for servertimer PTADM_EXT_NAMES ("hanhtrang")
# Unicode text between guillemets inside Lua string literals is converted to TCVN3 escapes.
# Doc: docs\features\hanh-trang-phong-than-20261004.md
import os, re
from tcvnc import L

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out", "script", "phongthan")
NL = "\r\n"

# pickup filter bits (client PhongThanAutoFight.inl PTAF_PK_*), menu order
PICK = [
    (0, "Tiền"), (1, "Đồ trắng"), (2, "Đồ xanh, lục (có thuộc tính)"), (3, "Đồ hoàng kim (đồ bộ)"),
    (4, "Bí kíp, sách kỹ năng"), (5, "Pháp bảo, pháp khí, ấn"), (6, "Nguyên liệu, đá quý"), (7, "Đồ nhiệm vụ"),
    (8, "Thuốc"), (9, "Đồ khác (sự kiện, vật phẩm IB...)"), (10, "Tự nhặt khi bật tự đánh"),
]
PICK_DEF = sum(1 << b for b in (0, 2, 3, 4, 5, 6, 7, 9, 10))
assert PICK_DEF == 0x6FD
PAGES = [(0, 1, 2, 3), (4, 5, 6, 7), (8, 9, 10)]

COMMON = r'''PTHT_ITEM = 61500
PTHT_T_PICK = 2640    -- pickup filter: 0 = default, else 2^30 + bits (client PhongThanAutoFight.inl PTAF_PK_*)
PTHT_T_SELL = 2641    -- clean-bag filter: 0 = default, else 2^30 + bits (0 white, 1 broken, 2 magic below level, 3 auto)
PTHT_T_BLV = 2642     -- magic equipment sold only below this item level (2..11, else 5)
PTHT_T_GIVEN = 2643   -- 1 = token given (auto gift)
PTHT_T_FIGHT = 2644   -- map id where the token switched the fight state off to open the box (0 = none)
PTHT_T_NOW = 2645     -- SystemTime() at the last sync (client buff bar clock)
PTHT_FLAG = 1073741824
PTHT_PICK_DEF = @PICK_DEF@
PTHT_SELL_DEF = 3
PTHT_BLV_DEF = 5
PTHT_FREE_AUTO = 3
PTHT_LOG = "hanhtrang_sell.log"

function PTHT_No()
end

function PTHT_Say(title, o)
	local n = getn(o)
	local t = { title, n }
	local k = 1
	while k <= n do t[k + 2] = o[k] k = k + 1 end
	call(Say, t)
end

function PTHT_Pow(k)
	local v = 1
	local i = 0
	while i < k do v = v * 2 i = i + 1 end
	return v
end

-- 1 when bit k of v is set (Lua 4: no bit operators)
function PTHT_Bit(v, k)
	local q = floor(v / PTHT_Pow(k))
	if q - floor(q / 2) * 2 == 1 then return 1 end
	return nil
end

function PTHT_Mask(task, def)
	local v = GetTask(task)
	if v < PTHT_FLAG then return def end
	return v - PTHT_FLAG
end

-- store a filter and send it to the client (VNG s2c_synctaskvalue, read by PhongThanAutoFight.inl)
function PTHT_SetMask(task, m)
	SetTask(task, PTHT_FLAG + m)
	SyncTaskValue(task)
end

function PTHT_Toggle(task, def, k)
	local m = PTHT_Mask(task, def)
	if PTHT_Bit(m, k) then m = m - PTHT_Pow(k) else m = m + PTHT_Pow(k) end
	PTHT_SetMask(task, m)
	return m
end

function PTHT_BlueLv()
	local v = GetTask(PTHT_T_BLV)
	if v < 2 or v > 11 then return PTHT_BLV_DEF end
	return v
end

-- map id when the box / clean bag may be used here (field maps and cities), else nil: never in events,
-- instances, battlefields, Van Tien tran, Tien Ma, Thien Lao (1060)
function PTHT_MapOk()
	local m = GetWorldPos()
	if not m then return nil end
	if m >= 1001 and m <= 1057 then return m end
	if m == 1065 or (m >= 1074 and m <= 1078) then return m end
	return nil
end

function PTHT_LogPath()
	return (PTADM_DIR or "admin_bridge\\") .. PTHT_LOG
end

-- Clean bag rule (docs: Phan 2.3). Only equipment (genre 0) in the bag (place 3), never: equipped / quick bar
-- (other places), detail 4 phap bao / phap khi / an, 10 horse, 11 signet, 12 ornament, set equipment (quality 3),
-- locked or bound (GetLockItem ~= 0), lock-sell (engine), price 0, "tan thu" items. Every other genre is never
-- sold: medicine, event, materials / gems / book materials, quest, town portal, magicscript (lenh bai, bi kip),
-- skill books, ibitem. Returns the shop money (KBuySell::Sell, native PTItemSaleInfo), name, quality, level.
function PTHT_SellOne(idx, smask, blv)
	if not PTItemSaleInfo then return nil end
	local g, d, p, lvl = FindItemEx(idx)
	if g ~= 0 or not d then return nil end
	if d == 4 or d >= 10 then return nil end
	local place, q, money, ok = PTItemSaleInfo(idx)
	if place ~= 3 or ok ~= 1 or not money or money <= 0 then return nil end
	local lk = GetLockItem(idx)
	if lk and lk ~= 0 then return nil end
	local want = nil
	if q == 0 and PTHT_Bit(smask, 0) then want = 1 end
	if q == 2 and PTHT_Bit(smask, 1) then want = 1 end
	if q == 1 and PTHT_Bit(smask, 2) and lvl and lvl < blv then want = 1 end
	if not want then return nil end
	local nm = GetNameItem(idx) or "?"
	if strfind(nm, "«tân thủ»", 1, 1) or strfind(nm, "«Tân thủ»", 1, 1) or strfind(nm, "«Tân Thủ»", 1, 1) then return nil end
	return money, nm, q, lvl
end

-- current PlayerIndex: every bag item the filter would sell, { n, total, [i] = { idx, d, p, nm, money } }
function PTHT_Scan()
	local smask = PTHT_Mask(PTHT_T_SELL, PTHT_SELL_DEF)
	local blv = PTHT_BlueLv()
	local L = { n = 0, total = 0 }
	local y = 0
	while y < 10 do
		local x = 0
		while x < 6 do
			local idx = FindItemEx(3, x, y, 0)
			if idx and idx > 0 then
				local money, nm = PTHT_SellOne(idx, smask, blv)
				if money then
					local g, d, p = FindItemEx(idx)
					local s = {}
					s.idx = idx
					s.d = d
					s.p = p
					s.nm = nm
					s.money = money
					L.n = L.n + 1
					L[L.n] = s
					L.total = L.total + money
				end
			end
			x = x + 1
		end
		y = y + 1
	end
	return L
end

-- sell the listed items that are still in the bag, still the same item and still match the filter
-- (RemoveItem + Earn = what the shop does); one log line per item. Returns count, money.
function PTHT_Sell(L, why)
	local smask = PTHT_Mask(PTHT_T_SELL, PTHT_SELL_DEF)
	local blv = PTHT_BlueLv()
	local n = 0
	local tot = 0
	local h = nil
	if openfile then h = openfile(PTHT_LogPath(), "a") end
	local stamp = ""
	if date then stamp = date("%Y-%m-%d %H:%M:%S") end
	local who = GetName() or "?"
	local i = 1
	while i <= L.n do
		local s = L[i]
		local g, d, p = FindItemEx(s.idx)
		if g == 0 and d == s.d and p == s.p then
			local money, nm = PTHT_SellOne(s.idx, smask, blv)
			if money and RemoveItem(s.idx, 0, 0) == 1 then
				Earn(money)
				n = n + 1
				tot = tot + money
				if h then write(h, stamp .. "\t" .. who .. "\t" .. why .. "\t" .. nm .. "\t" .. money .. "\n") end
			end
		end
		i = i + 1
	end
	if h then closefile(h) end
	return n, tot
end

function PTHT_SellDesc()
	local m = PTHT_Mask(PTHT_T_SELL, PTHT_SELL_DEF)
	local r = ""
	if PTHT_Bit(m, 0) then r = "«đồ trắng»" end
	if PTHT_Bit(m, 1) then
		if r ~= "" then r = r .. ", " end
		r = r .. "«đồ hỏng»"
	end
	if PTHT_Bit(m, 2) then
		if r ~= "" then r = r .. ", " end
		r = r .. PTHT_BlueText()
	end
	if r == "" then r = "«chưa chọn loại nào»" end
	return r
end

function PTHT_BlueText()
	local b = PTHT_BlueLv()
	if b >= 11 then return "«đồ xanh mọi cấp»" end
	return "«đồ xanh dưới cấp »" .. b
end
'''

ITEM = r'''-- Phong Than "Lenh Bai Hanh Trang" (magicscript 61500, 2026-10-04, agent items). Permanent, never consumed
-- (KItemList::ExecuteScript only calls main; this script never removes the item). Generated by
-- scratchpad\items\gen.py - edit the generator, not this file. Doc: docs\features\hanh-trang-phong-than-20261004.md
-- Right click: open the store box anywhere (SetFightState(0) + OpenBox(2), as the Thu Kho), "Don tui" (sell bag
-- junk at the shop price after a confirmation list, log admin_bridge\hanhtrang_sell.log), pickup filter (task 2640,
-- client auto pickup Alt+P), clean-bag filter (tasks 2641 / 2642). Lua 4, no top-level dofile, menus <= 7 rows.

@COMMON@
PTHT_PEND = {}

function PTHT_Blocked()
	Say("«<color=yellow>Lệnh Bài Hành Trang<color>: không mở rương / dọn túi được ở bản đồ này (sự kiện, phó bản, chiến trường, Vạn Tiên, Thiên Lao). Hãy ra bản đồ ngoài hoặc về thành.»", 1, "«Đóng»/PTHT_No")
end

function main(nItemIdx)
	PTHT_Main()
	return 0
end

function PTHT_Main()
	local o = {}
	tinsert(o, "«Mở rương chứa đồ (Rương 1 - 5)»/PTHT_Box")
	tinsert(o, "«Dọn túi: bán đồ rác»/PTHT_Clean")
	tinsert(o, "«Cài đặt tự nhặt đồ»/PTHT_P1")
	tinsert(o, "«Cài đặt dọn túi»/PTHT_S")
	if GetTask(PTHT_T_FIGHT) > 0 then tinsert(o, "«Bật lại trạng thái chiến đấu»/PTHT_Fight") end
	tinsert(o, "«Đóng»/PTHT_No")
	PTHT_Say("«<color=yellow>Lệnh Bài Hành Trang<color>: mở rương ở mọi nơi, dọn túi bán đồ rác, chọn loại đồ tự nhặt (Alt+P: theo lệnh bài / luôn bật / tắt). Dọn túi đang bán: »" .. PTHT_SellDesc() .. ".", o)
end

-- ---------------------------------------------------------------- B3 store box
function PTHT_Box()
	local m = PTHT_MapOk()
	if not m then
		PTHT_Blocked()
		return
	end
	if GetFightState() == 1 then
		-- KItemList::ExchangeItem refuses to put items into a box page in fight mode
		SetTask(PTHT_T_FIGHT, m)
		SetFightState(0)
		Msg2Player("«Đã tạm tắt trạng thái chiến đấu để cất đồ vào rương. Cất xong chọn \"Bật lại trạng thái chiến đấu\" trên lệnh bài; nếu quên, khoảng 3 phút sau sẽ tự bật lại.»")
	end
	Msg2Player("«Rương chứa đồ: bấm mũi tên phải trong khung rương để sang Rương 2 - 5 (mở thêm rương ở Thủ Khố).»")
	OpenBox(2)
end

function PTHT_Fight()
	local m = GetTask(PTHT_T_FIGHT)
	SetTask(PTHT_T_FIGHT, 0)
	if m > 0 and GetWorldPos() == m and GetFightState() == 0 then
		SetFightState(1)
		Msg2Player("«Đã bật lại trạng thái chiến đấu.»")
	else
		Msg2Player("«Không cần bật lại trạng thái chiến đấu (đã bật hoặc đã đổi bản đồ).»")
	end
end

-- ---------------------------------------------------------------- B2 clean bag
function PTHT_Clean()
	if not PTItemSaleInfo then
		Say("«Dọn túi cần bản CoreServer.dll mới (hàm PTItemSaleInfo, đợt Hành Trang). Báo admin cài bản server mới; trong lúc chờ có thể bán ở cửa hàng hoặc Lệnh Bài Hủy Đồ.»", 1, "«Đóng»/PTHT_No")
		return
	end
	if not PTHT_MapOk() then
		PTHT_Blocked()
		return
	end
	local nm = GetName()
	local L = PTHT_Scan()
	if L.n == 0 then
		PTHT_PEND[nm] = nil
		Say("«Không có món nào khớp bộ lọc dọn túi (»" .. PTHT_SellDesc() .. "«). Không bao giờ bán: đồ đang mặc, đồ khóa, đồ nhiệm vụ, bí kíp, pháp bảo, lệnh bài, nguyên liệu, đá quý, đồ hoàng kim.»", 2, "«Cài đặt dọn túi»/PTHT_S", "«Đóng»/PTHT_No")
		return
	end
	PTHT_PEND[nm] = L
	Msg2Player("«Dọn túi - danh sách sẽ bán (»" .. L.n .. "« món):»")
	local i = 1
	while i <= L.n do
		Msg2Player(i .. ". " .. L[i].nm .. " - " .. L[i].money .. "« lượng»")
		i = i + 1
	end
	Say("«Sẽ bán <color=yellow>»" .. L.n .. "« món<color>, thu »" .. L.total .. "« lượng (giá cửa hàng). Danh sách từng món ở khung chat. Đồng ý bán?»", 3, "«Đồng ý bán »" .. L.n .. "« món»/PTHT_CleanOK", "«Cài đặt dọn túi»/PTHT_S", "«Hủy»/PTHT_No")
end

function PTHT_CleanOK()
	local nm = GetName()
	local L = PTHT_PEND[nm]
	PTHT_PEND[nm] = nil
	if not L then
		Msg2Player("«Danh sách dọn túi đã hết hạn, hãy chọn Dọn túi lại.»")
		return
	end
	local n, tot = PTHT_Sell(L, "tay")
	Msg2Player("«Dọn túi: đã bán »" .. n .. "/" .. L.n .. "« món, thu »" .. tot .. "« lượng. Nhật ký xem ở web admin (Hành Trang).»")
end

-- ---------------------------------------------------------------- pickup filter (task 2640)
function PTHT_PickRow(k, label)
	local m = PTHT_Mask(PTHT_T_PICK, PTHT_PICK_DEF)
	local x = "[ ] "
	if PTHT_Bit(m, k) then x = "[x] " end
	return x .. label .. "/PTHT_PT" .. k
end

@PICKFUNCS@
function PTHT_PickDef()
	SetTask(PTHT_T_PICK, 0)
	SyncTaskValue(PTHT_T_PICK)
	Msg2Player("«Đã khôi phục bộ lọc nhặt đồ mặc định: mọi thứ trừ đồ trắng và thuốc, nhặt khi bật tự đánh.»")
	PTHT_P3()
end

-- ---------------------------------------------------------------- clean-bag filter (tasks 2641 / 2642)
function PTHT_SellRow(k, label)
	local m = PTHT_Mask(PTHT_T_SELL, PTHT_SELL_DEF)
	local x = "[ ] "
	if PTHT_Bit(m, k) then x = "[x] " end
	return x .. label .. "/PTHT_ST" .. k
end

function PTHT_S()
	local o = {}
	tinsert(o, PTHT_SellRow(0, "«Bán đồ trắng»"))
	tinsert(o, PTHT_SellRow(1, "«Bán đồ hỏng (độ bền 0)»"))
	tinsert(o, PTHT_SellRow(2, "«Bán »" .. PTHT_BlueText()))
	tinsert(o, "«Đổi cấp đồ xanh được bán»/PTHT_SLv")
	tinsert(o, PTHT_SellRow(3, "«Tự dọn khi túi còn »" .. PTHT_FREE_AUTO .. "« ô trống»"))
	tinsert(o, "«Quay lại»/PTHT_Main")
	tinsert(o, "«Đóng»/PTHT_No")
	PTHT_Say("«<color=yellow>Cài đặt dọn túi<color>: chỉ bán trang bị trong túi theo giá cửa hàng. Không bao giờ bán: đồ đang mặc, đồ khóa, đồ nhiệm vụ, bí kíp, pháp bảo, lệnh bài, nguyên liệu, đá quý, đồ hoàng kim, đồ tân thủ.»", o)
end

function PTHT_ST0() PTHT_Toggle(PTHT_T_SELL, PTHT_SELL_DEF, 0) PTHT_S() end
function PTHT_ST1() PTHT_Toggle(PTHT_T_SELL, PTHT_SELL_DEF, 1) PTHT_S() end
function PTHT_ST2() PTHT_Toggle(PTHT_T_SELL, PTHT_SELL_DEF, 2) PTHT_S() end
function PTHT_ST3() PTHT_Toggle(PTHT_T_SELL, PTHT_SELL_DEF, 3) PTHT_S() end

function PTHT_SLv()
	local b = PTHT_BlueLv() + 2
	if b > 11 then b = 3 end
	SetTask(PTHT_T_BLV, b)
	PTHT_S()
end
'''

LIB = r'''-- Phong Than 2026-10-04 (agent items): Lenh Bai Hanh Trang, servertimer side. Generated by scratchpad\items\gen.py.
-- No main() here: dofile'd into the servertimer state by script\phongthan\ext\hanhtrang.lua (minute tick, needs
-- "hanhtrang" in PTADM_EXT_NAMES) and by the web admin bridge commands. Every minute, for each online player:
--  * filters the admin set while the character was offline (admin_bridge\hanhtrang_pending.txt) are applied;
--  * the token is given once (task 2643 = 1 when given or already owned);
--  * the fight state switched off by the token for the box comes back after about 3 minutes (same map only);
--  * task 2640 (pickup filter), 2645 (SystemTime) and the IB item buff tasks of pt_ibitem_lib.lua (1906, 1907,
--    1911, 1913, 2021, 1921..1932) are sent to the client (pickup + buff bar of CoreClient.dll);
--  * "auto clean" (bit 3 of task 2641): with <= 3 free bag cells, the junk of the filter is sold.

@COMMON@
PTHT_PEND_FILE = "hanhtrang_pending.txt"
PTHT_FT = {}

function PTHT_PendPath()
	return (PTADM_DIR or "admin_bridge\\") .. PTHT_PEND_FILE
end

-- PTHT_PENDS[name] = { pick, sell, blv } (-1 = unchanged); file lines pick<TAB>sell<TAB>blv<TAB>name
function PTHT_LoadPend()
	if PTHT_PENDS then return end
	PTHT_PENDS = {}
	local h = openfile(PTHT_PendPath(), "r")
	if not h then return end
	local l = read(h, "*l")
	while l do
		local a = strfind(l, "\t", 1, 1)
		local b = nil
		local c = nil
		if a then b = strfind(l, "\t", a + 1, 1) end
		if b then c = strfind(l, "\t", b + 1, 1) end
		if a and b and c then
			local p = {}
			p[1] = tonumber(strsub(l, 1, a - 1))
			p[2] = tonumber(strsub(l, a + 1, b - 1))
			p[3] = tonumber(strsub(l, b + 1, c - 1))
			local nm = strsub(l, c + 1)
			if p[1] and p[2] and p[3] and nm ~= "" then PTHT_PENDS[nm] = p end
		end
		l = read(h, "*l")
	end
	closefile(h)
end

function PTHT_SavePend()
	local h = openfile(PTHT_PendPath(), "w")
	if not h then return end
	local nm, p = next(PTHT_PENDS, nil)
	while nm do
		write(h, p[1] .. "\t" .. p[2] .. "\t" .. p[3] .. "\t" .. nm .. "\n")
		nm, p = next(PTHT_PENDS, nm)
	end
	closefile(h)
end

-- current PlayerIndex: apply { pick, sell, blv } (-1 = unchanged; pick / sell are bit masks)
function PTHT_ApplySet(p)
	if p[1] >= 0 then PTHT_SetMask(PTHT_T_PICK, p[1]) end
	if p[2] >= 0 then PTHT_SetMask(PTHT_T_SELL, p[2]) end
	if p[3] >= 2 and p[3] <= 11 then SetTask(PTHT_T_BLV, p[3]) end
end

-- web admin (bridge). Online: applied and sent now. Offline: kept for the next login (file survives a restart).
function PTHT_AdminSet(id, name, pick, sell, blv)
	PTHT_LoadPend()
	local p = { pick or -1, sell or -1, blv or -1 }
	local pi = nil
	if PTAdm_FindPlayer then pi = PTAdm_FindPlayer(name) end
	if pi then
		PTHT_ApplySet(p)
		Msg2Player("«Admin đã đổi cài đặt Lệnh Bài Hành Trang (tự nhặt đồ / dọn túi). Dọn túi đang bán: »" .. PTHT_SellDesc() .. ".")
		if PTHT_PENDS[name] then
			PTHT_PENDS[name] = nil
			PTHT_SavePend()
		end
		if PTAdm_Log then PTAdm_Log(id, "OK", name .. " online: pick " .. GetTask(PTHT_T_PICK) .. " sell " .. GetTask(PTHT_T_SELL) .. " blv " .. PTHT_BlueLv()) end
		PlayerIndex = nil
		return 1
	end
	PTHT_PENDS[name] = p
	PTHT_SavePend()
	if PTAdm_Log then PTAdm_Log(id, "OK", "offline " .. name .. ": pick " .. p[1] .. " sell " .. p[2] .. " blv " .. p[3] .. " ap khi dang nhap") end
	return 0
end

-- current PlayerIndex: give the token once (1 when given now)
function PTHT_GiveOne()
	if GetTask(PTHT_T_GIVEN) ~= 0 then return 0 end
	local have = HaveNormalItem(6, 1, PTHT_ITEM, -1)
	if have and have > 0 then
		SetTask(PTHT_T_GIVEN, 1)
		return 0
	end
	local r = AddNormalItem(6, 1, PTHT_ITEM, 1, 0, 0)
	if r and r > 0 then
		SetTask(PTHT_T_GIVEN, 1)
		return 1
	end
	return 0
end

-- SetTask(t, GetTask(t)) turns an unset task into "0": the client then knows it is really 0
function PTHT_Sync(t)
	SetTask(t, GetTask(t))
	SyncTaskValue(t)
end

function PTHT_SyncAll()
	PTHT_Sync(PTHT_T_PICK)
	if SystemTime then
		SetTask(PTHT_T_NOW, SystemTime())
		SyncTaskValue(PTHT_T_NOW)
	end
	PTHT_Sync(1906)
	PTHT_Sync(1907)
	PTHT_Sync(1911)
	PTHT_Sync(1913)
	PTHT_Sync(2021)
	local t = 1921
	while t <= 1932 do
		PTHT_Sync(t)
		t = t + 1
	end
end

-- the fight state switched off by the token for the box comes back on the 3rd tick (same map only)
function PTHT_FightTick(nm)
	local m = GetTask(PTHT_T_FIGHT)
	if m <= 0 then
		PTHT_FT[nm] = nil
		return
	end
	local c = (PTHT_FT[nm] or 0) + 1
	PTHT_FT[nm] = c
	if c < 3 then return end
	PTHT_FT[nm] = nil
	SetTask(PTHT_T_FIGHT, 0)
	if GetWorldPos() == m and GetFightState() == 0 then
		SetFightState(1)
		Msg2Player("«Lệnh Bài Hành Trang: đã tự bật lại trạng thái chiến đấu (mở rương đã lâu).»")
	end
end

function PTHT_AutoClean(nm)
	if not PTItemSaleInfo then return end
	if not PTHT_Bit(PTHT_Mask(PTHT_T_SELL, PTHT_SELL_DEF), 3) then return end
	if not PTHT_MapOk() then return end
	local free = CalcFreeItemCellCount()
	if not free or free > PTHT_FREE_AUTO then return end
	local L = PTHT_Scan()
	if L.n <= 0 then return end
	local n, tot = PTHT_Sell(L, "tu dong")
	if n > 0 then
		Msg2Player("«Túi gần đầy: Lệnh Bài Hành Trang đã tự bán »" .. n .. "« món rác (»" .. PTHT_SellDesc() .. "«), thu »" .. tot .. "« lượng.»")
		if PTAdm_Log then PTAdm_Log("hanhtrang", "OK", nm .. " auto clean " .. n .. " items " .. tot) end
	end
end

-- current PlayerIndex, name nm
function PTHT_TickOne(nm)
	local p = PTHT_PENDS[nm]
	if p then
		PTHT_ApplySet(p)
		PTHT_PENDS[nm] = nil
		PTHT_SavePend()
		Msg2Player("«Admin đã đổi cài đặt Lệnh Bài Hành Trang cho bạn khi bạn vắng mặt.»")
		if PTAdm_Log then PTAdm_Log("hanhtrang", "OK", nm .. " pending set applied") end
	end
	if PTHT_GiveOne() > 0 then
		Msg2Player("«Bạn nhận được Lệnh Bài Hành Trang: nhấp phải để mở rương ở mọi nơi, dọn túi bán đồ rác, chọn loại đồ tự nhặt (Alt+P bật/tắt). Dùng vĩnh viễn, không mất.»")
		if PTAdm_Log then PTAdm_Log("hanhtrang", "OK", nm .. " +Lenh Bai Hanh Trang") end
	end
	PTHT_FightTick(nm)
	PTHT_SyncAll()
	PTHT_AutoClean(nm)
end

function PTHT_Tick()
	PTHT_LoadPend()
	local i = 1
	local max = PTADM_MAX_PLAYER or 0
	while i <= max do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" then PTHT_TickOne(nm) end
		i = i + 1
	end
	PlayerIndex = nil
end
'''

EXT = r'''-- Phong Than 2026-10-04 (agent items): minute tick of the Lenh Bai Hanh Trang (pickup filter sync, IB buff bar
-- sync, auto gift, auto clean, fight state back after the box). Run by servertimer.lua PTAdm_ExtTick when
-- "hanhtrang" is in PTADM_EXT_NAMES (protected call). The dofile happens inside the function (tick time,
-- cwd = Server), never at the top level.
function PTEXT_hanhtrang_Tick()
	if not PTHT_Tick then dofile("script\\phongthan\\item\\hanhtrang_lib.lua") end
	if PTHT_Tick then PTHT_Tick() end
end
'''


def pickfuncs():
    o = []
    for pi, bits in enumerate(PAGES):
        pg = pi + 1
        o.append("function PTHT_P%d()" % pg)
        o.append("\tlocal o = {}")
        for b in bits:
            o.append('\ttinsert(o, PTHT_PickRow(%d, "«%s»"))' % (b, dict(PICK)[b]))
        if pg == 3:
            o.append('\ttinsert(o, "«Khôi phục mặc định»/PTHT_PickDef")')
        if pg < 3:
            o.append('\ttinsert(o, "«Trang sau»/PTHT_P%d")' % (pg + 1))
        o.append('\ttinsert(o, "«Quay lại»/PTHT_Main")')
        o.append('\ttinsert(o, "«Đóng»/PTHT_No")')
        o.append('\tPTHT_Say("«<color=yellow>Tự nhặt đồ<color> (trang %d/3): [x] = nhặt. Alt+P đổi: theo lệnh bài (khi tự đánh) / luôn bật (cả khi đứng yên) / tắt. Không nhặt đồ người chơi vứt ra.»", o)' % pg)
        o.append("end")
        o.append("")
        for b in bits:
            o.append("function PTHT_PT%d() PTHT_Toggle(PTHT_T_PICK, PTHT_PICK_DEF, %d) PTHT_P%d() end" % (b, b, pg))
        o.append("")
    return "\n".join(o)


def conv(src):
    src = src.replace("@PICKFUNCS@", pickfuncs()).replace("@PICK_DEF@", str(PICK_DEF))
    out = re.sub("«(.*?)»", lambda m: L(m.group(1)), src)
    out.encode("ascii")  # must be pure ASCII
    return out.replace("\r\n", "\n").replace("\n", NL)


def write(rel, text):
    p = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "wb").write(text.encode("ascii"))
    print(rel, len(text))


common = COMMON
write(r"item\hanhtrang_lenhbai.lua", conv(ITEM.replace("@COMMON@", common)))
write(r"item\hanhtrang_lib.lua", conv(LIB.replace("@COMMON@", common)))
write(r"ext\hanhtrang.lua", conv(EXT))
