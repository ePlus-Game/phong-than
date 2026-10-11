-- Phong Than 2026-10-03 (sinhhoat): Sinh Hoat Su (life skill teacher) in Tay Ky, Trieu Ca and the 3 newbie
-- villages (VNG \script\<city>\sheng_huo_ji_neng_lao_shi scripts are missing). Spawned by script\phongthan\ext\sinhhoat.lua.
-- Menu: first-time quests (taskinfo 1200 herbs, 1201 ore, 1202 fishing), teach the two life skill books
-- (62 Ban Co Khai Thien, 128 Ban Mon Long Phu), alchemy / cooking / crystal smelting, daily orders, Ton Su
-- (taskinfo 1509-1513, raises the skill cap 9 -> 10), skill sheet.
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

PTSH_HEAD = "<color=green>Sinh Hoạt Sư<color>: "

-- first-time quests: { taskinfo id, task var, material (genre 3), title, skill }
PTSH_Q = {}
PTSH_Q[1] = { 1200, PTSH_T_Q1200, 910, "Lần Đầu Hái Thuốc", 1, "Bạch Trà" }
PTSH_Q[2] = { 1201, PTSH_T_Q1201, 928, "Lần Đầu Khai Khoáng", 2, "Hoàng đồng" }
PTSH_Q[3] = { 1202, PTSH_T_Q1202, 944, "Lần Đầu Câu Cá", 3, "Tôm xanh" }
PTSH_Q_WHERE = { "bụi thảo dược ở Sùng Thành dã ngoại, Chân núi Côn Lôn, Miêu Cương, Kỳ Sơn",
	"mạch khoáng ở Yến Sơn, Cự Lộc, Thủ Dương sơn", "điểm câu cá ở Bắc Hải, Mạnh Tân, Đông Hải Thủy Vực" }
-- Ton Su: { taskinfo id, title, material type, id offset }
PTSH_TS = {}
PTSH_TS[1] = { 1510, "Thu Thập Tôn Sư", 1, 0, "thảo dược" }
PTSH_TS[2] = { 1509, "Khai Khoáng Tôn Sư", 2, 0, "khoáng thạch" }
PTSH_TS[3] = { 1511, "Điếu Ngư Tôn Sư", 3, 0, "cá" }
PTSH_TS[4] = { 1512, "Luyện Đơn Tôn Sư", 1, 46, "tinh hoa thảo dược" }
PTSH_TS[5] = { 1513, "Hỏa Trù Tôn Sư", 3, 28, "thịt cá" }
PTSH_TS_CASH = 500000
PTSH_TS_NEED = 10
-- recipes: sk skill, lv level, a / b inputs { type, id offset, tier from, tier to, count }, out { g, d, p, n }
PTSH_REC = {}
local r = {}
r = { sk = 4, lv = 1, name = "Tiểu Hồng Đơn x5", a = { 1, 46, 1, 3, 1 }, out = { 1, 0, 0, 5 } } PTSH_REC[1] = r
r = { sk = 4, lv = 1, name = "Tiểu Hoàn Đơn x5", a = { 1, 46, 1, 3, 1 }, out = { 1, 3, 0, 5 } } PTSH_REC[2] = r
r = { sk = 4, lv = 4, name = "Trung Hồng Đơn x5", a = { 1, 46, 4, 6, 1 }, out = { 1, 1, 0, 5 } } PTSH_REC[3] = r
r = { sk = 4, lv = 4, name = "Trung Hoàn Đơn x5", a = { 1, 46, 4, 6, 1 }, out = { 1, 4, 0, 5 } } PTSH_REC[4] = r
r = { sk = 4, lv = 7, name = "Đại Hồng Đơn x5", a = { 1, 46, 7, 10, 1 }, out = { 1, 2, 0, 5 } } PTSH_REC[5] = r
r = { sk = 4, lv = 7, name = "Đại Hoàn Đơn x5", a = { 1, 46, 7, 10, 1 }, out = { 1, 5, 0, 5 } } PTSH_REC[6] = r
r = { sk = 4, lv = 2, name = "Linh Thú Đơn", a = { 1, 46, 1, 10, 1 }, b = { 3, 28, 1, 10, 1 }, out = { 6, PTLT_I_DON, 0, 1 } } PTSH_REC[7] = r
r = { sk = 5, lv = 3, name = "Canh dưỡng linh thú (2 Linh Thú Đơn)", a = { 3, 28, 1, 10, 2 }, out = { 6, PTLT_I_DON, 0, 2 } } PTSH_REC[8] = r
r = { sk = 5, lv = 1, name = "Mâm cỗ (đổi kinh nghiệm)", a = { 3, 28, 1, 10, 5 }, out = { 0, 0, 0, 0 } } PTSH_REC[9] = r

function main()
	local t = PTSH_HEAD .. "Kỹ năng sống gồm thu thập (hái thuốc, khai khoáng, câu cá) và chế tác (luyện đơn, hỏa trù). Ngươi muốn làm gì?"
	Say(t, 8,
		"Nhiệm vụ sinh hoạt/PTSH_QMenu",
		"Học kỹ năng sống/PTSH_TeachMenu",
		"Luyện đơn, hỏa trù/PTSH_CraftMenu",
		"Chế luyện Thủy Tinh Nguyên Thạch/PTSH_Crystal",
		"Đơn đặt hàng hằng ngày/PTSH_Order",
		"Thăng cấp Tôn Sư/PTSH_TonSuMenu",
		"Xem kỹ năng sống/PTSH_Sheet",
		"Đóng/PTSH_No")
end

function PTSH_Sheet()
	local s = PTSH_HEAD .. "Kỹ năng sống của ngươi:"
	local k = 1
	while k <= 5 do
		local lv = PTSH_SkillLevel(k)
		s = s .. "\n" .. PTSH_SKILL_NAME[k] .. ": cấp " .. lv .. "/" .. PTSH_SkillCap(k) .. " (" .. PTSH_SkillExp(k) .. " điểm)"
		k = k + 1
	end
	local b1, b2 = "chưa", "chưa"
	if PTSH_HasBook(PTSH_BOOK_GATHER) == 1 then b1 = "đã" end
	if PTSH_HasBook(PTSH_BOOK_CRAFT) == 1 then b2 = "đã" end
	s = s .. "\nBàn Cổ Khai Thiên: " .. b1 .. " lĩnh hội. Ban Môn Lộng Phủ: " .. b2 .. " lĩnh hội."
	Say(s, 1, "Đóng/PTSH_No")
end

-- quests ---------------------------------------------------------------------------------------------------
function PTSH_QMenu()
	local t = { PTSH_HEAD .. "Ta có vài việc nhỏ để ngươi làm quen với kỹ năng sống.", 0 }
	local n = 0
	local i = 1
	while i <= 3 do
		local q = PTSH_Q[i]
		local st = GetTask(q[2])
		if st == 0 then
			n = n + 1 t[n + 2] = "Nhận: " .. q[4] .. "/PTSH_QA" .. i
		elseif st == 1 then
			n = n + 1 t[n + 2] = "Giao: " .. q[4] .. "/PTSH_QD" .. i
		end
		i = i + 1
	end
	if n == 0 then
		Say(PTSH_HEAD .. "Ngươi đã hoàn thành mọi nhiệm vụ nhập môn. Hãy rèn kỹ năng lên cấp 9 rồi tìm ta thăng cấp Tôn Sư.", 1, "Đóng/PTSH_No")
		return
	end
	n = n + 1 t[n + 2] = "Đóng/PTSH_No"
	t[2] = n
	call(Say, t)
end

function PTSH_QAccept(i)
	local q = PTSH_Q[i]
	if GetTask(q[2]) ~= 0 then return end
	SetTask(q[2], 1)
	local txt = "Mang về 1 " .. q[6] .. " cho Sinh Hoạt Sư. Tìm " .. PTSH_Q_WHERE[i] .. "."
	if i == 2 and PTSH_HasBook(PTSH_BOOK_GATHER) == 0 then txt = txt .. " Cần lĩnh hội Bàn Cổ Khai Thiên trước." end
	PTSH_Note(q[1], q[4], txt, 1)
	Say(PTSH_HEAD .. txt, 1, "Đã hiểu/PTSH_No")
end

function PTSH_QDeliver(i)
	local q = PTSH_Q[i]
	if GetTask(q[2]) ~= 1 then return end
	local list = { { 3, q[3], 0, 1 } }
	local r = PTSH_TakeAll(list)
	if r ~= 1 then
		Say(PTSH_HEAD .. "Ngươi chưa mang " .. q[6] .. " theo trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	SetTask(q[2], 2)
	AddOwnExp(3000)
	Earn(1000)
	PTSH_AddSkillExp(q[5], 10)
	PTSH_Note(q[1], q[4], "Hoàn thành", 2)
	Say(PTSH_HEAD .. "Tốt lắm! Thưởng 3000 kinh nghiệm, 1000 lượng và 10 điểm kỹ năng " .. PTSH_SKILL_NAME[q[5]] .. ".", 1, "Đóng/PTSH_No")
end

function PTSH_QA1() PTSH_QAccept(1) end
function PTSH_QA2() PTSH_QAccept(2) end
function PTSH_QA3() PTSH_QAccept(3) end
function PTSH_QD1() PTSH_QDeliver(1) end
function PTSH_QD2() PTSH_QDeliver(2) end
function PTSH_QD3() PTSH_QDeliver(3) end

-- life skill books ------------------------------------------------------------------------------------------
function PTSH_TeachMenu()
	Say(PTSH_HEAD .. "Bàn Cổ Khai Thiên cần để khai khoáng, Ban Môn Lộng Phủ cần để luyện đơn và hỏa trù. Mỗi kỹ năng ta dạy với giá " .. PTSH_TEACH_FEE .. " lượng (cũng có thể học bằng bí kíp ở Võ sư).", 3,
		"Học Bàn Cổ Khai Thiên/PTSH_Teach1",
		"Học Ban Môn Lộng Phủ/PTSH_Teach2",
		"Đóng/PTSH_No")
end

function PTSH_TeachOne(id, name)
	local r = PTSH_Teach(id)
	if r == 1 then
		Say(PTSH_HEAD .. "Ngươi đã lĩnh hội " .. name .. ".", 1, "Đóng/PTSH_No")
	elseif r == -2 then
		Say(PTSH_HEAD .. "Ngươi không đủ " .. PTSH_TEACH_FEE .. " lượng.", 1, "Đóng/PTSH_No")
	else
		Say(PTSH_HEAD .. "Máy chủ chưa có dữ liệu kỹ năng này, không dạy được.", 1, "Đóng/PTSH_No")
	end
end

function PTSH_Teach1() PTSH_TeachOne(PTSH_BOOK_GATHER, "Bàn Cổ Khai Thiên") end
function PTSH_Teach2() PTSH_TeachOne(PTSH_BOOK_CRAFT, "Ban Môn Lộng Phủ") end

-- crafting -----------------------------------------------------------------------------------------------------
function PTSH_CraftMenu()
	if PTSH_HasBook(PTSH_BOOK_CRAFT) == 0 then
		Say(PTSH_HEAD .. "Muốn luyện đơn, hỏa trù phải lĩnh hội <color=yellow>Ban Môn Lộng Phủ<color> trước.", 2, "Học Ban Môn Lộng Phủ/PTSH_Teach2", "Đóng/PTSH_No")
		return
	end
	local t = { PTSH_HEAD .. "Luyện đơn cấp " .. PTSH_SkillLevel(4) .. ", hỏa trù cấp " .. PTSH_SkillLevel(5) .. ". Chọn công thức (nguyên liệu phải để trong hành trang):", 0 }
	local n = 2
	t[3] = "Tinh luyện thảo dược (2 cùng loại -> 1 tinh hoa)/PTSH_Refine"
	t[4] = "Sơ chế cá (2 cùng loại -> 1 thịt)/PTSH_Clean"
	local i = 1
	while PTSH_REC[i] do
		n = n + 1
		t[n + 2] = PTSH_REC[i].name .. " [" .. PTSH_SKILL_NAME[PTSH_REC[i].sk] .. " " .. PTSH_REC[i].lv .. "]/PTSH_C" .. i
		i = i + 1
	end
	n = n + 1 t[n + 2] = "Đóng/PTSH_No"
	t[2] = n
	call(Say, t)
end

-- 2 of the same raw material (first..last) -> 1 product (id + off); skill k must reach the material tier
function PTSH_Convert(k, typ, off, title)
	if PTSH_HasBook(PTSH_BOOK_CRAFT) == 0 then return end
	if PTSH_Free() < 1 then
		Say(PTSH_HEAD .. "Hành trang đã đầy.", 1, "Đóng/PTSH_No")
		return
	end
	local lv = PTSH_SkillLevel(k)
	local t = 1
	while t <= lv do
		local ids = PTSH_MAT[typ][t]
		local j = 1
		while ids[j] do
			if PTSH_Count(3, ids[j], 0) >= 2 then
				if PTSH_Take(3, ids[j], 0, 2) == 2 then
					PTSH_Give(3, ids[j] + off, 0, 1)
					PTSH_AddSkillExp(k, 2 + floor(t / 2))
					Say(PTSH_HEAD .. title .. " thành công (nguyên liệu cấp " .. t .. ").", 2, "Làm tiếp/PTSH_" .. (k == 4 and "Refine" or "Clean"), "Đóng/PTSH_No")
					return
				end
				Say(PTSH_HEAD .. "Nguyên liệu phải để trong hành trang.", 1, "Đóng/PTSH_No")
				return
			end
			j = j + 1
		end
		t = t + 1
	end
	Say(PTSH_HEAD .. "Không có 2 nguyên liệu cùng loại hợp với cấp kỹ năng (cấp " .. lv .. ") trong hành trang.", 1, "Đóng/PTSH_No")
end

function PTSH_Refine() PTSH_Convert(4, 1, 46, "Tinh luyện") end
function PTSH_Clean() PTSH_Convert(5, 3, 28, "Sơ chế") end

function PTSH_Craft(i)
	local r = PTSH_REC[i]
	if r == nil or PTSH_HasBook(PTSH_BOOK_CRAFT) == 0 then return end
	local lv = PTSH_SkillLevel(r.sk)
	if lv < r.lv then
		Say(PTSH_HEAD .. "Cần " .. PTSH_SKILL_NAME[r.sk] .. " cấp " .. r.lv .. " (hiện cấp " .. lv .. ").", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_Free() < 2 then
		Say(PTSH_HEAD .. "Cần 2 ô trống trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_TierCount(r.a) < r.a[5] or (r.b and PTSH_TierCount(r.b) < r.b[5]) then
		Say(PTSH_HEAD .. "Không đủ nguyên liệu trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_TierTake(r.a) ~= 1 then
		Say(PTSH_HEAD .. "Nguyên liệu phải để trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	local takenA = PTSH_LAST_TAKEN
	if r.b and PTSH_TierTake(r.b) ~= 1 then
		PTSH_GiveBack(takenA)
		Say(PTSH_HEAD .. "Nguyên liệu phải để trong hành trang (đã trả lại phần đầu tiên).", 1, "Đóng/PTSH_No")
		return
	end
	local o = r.out
	local msg = ""
	if o[1] == 0 then
		local e = GetLevel() * 200 * lv
		AddOwnExp(e)
		msg = "Nhận " .. e .. " kinh nghiệm."
	else
		local got = PTSH_Give(o[1], o[2], o[3], o[4])
		msg = "Nhận " .. got .. " " .. r.name .. "."
	end
	PTSH_AddSkillExp(r.sk, 3)
	Say(PTSH_HEAD .. "Chế tác thành công. " .. msg, 2, "Làm tiếp/PTSH_C" .. i, "Đóng/PTSH_No")
end

function PTSH_C1() PTSH_Craft(1) end
function PTSH_C2() PTSH_Craft(2) end
function PTSH_C3() PTSH_Craft(3) end
function PTSH_C4() PTSH_Craft(4) end
function PTSH_C5() PTSH_Craft(5) end
function PTSH_C6() PTSH_Craft(6) end
function PTSH_C7() PTSH_Craft(7) end
function PTSH_C8() PTSH_Craft(8) end
function PTSH_C9() PTSH_Craft(9) end

-- crystal smelting: 1 Thuy Tinh Nguyen Thach -> 1 manh thuy tinh (needs Khai khoang 4)
function PTSH_Crystal()
	if PTSH_SkillLevel(2) < 4 then
		Say(PTSH_HEAD .. "Chế luyện thủy tinh cần Khai khoáng cấp 4.", 1, "Đóng/PTSH_No")
		return
	end
	local i = 1
	while PTSH_CRYSTAL[i] do
		local c = PTSH_CRYSTAL[i]
		if PTSH_Count(3, c[1], 0) >= 1 then
			if PTSH_Take(3, c[1], 0, 1) == 1 then
				PTSH_Give(3, c[2], 0, 1)
				PTSH_AddSkillExp(2, 3)
				Say(PTSH_HEAD .. "Chế luyện thành công một mảnh thủy tinh.", 2, "Làm tiếp/PTSH_Crystal", "Đóng/PTSH_No")
				return
			end
		end
		i = i + 1
	end
	Say(PTSH_HEAD .. "Không có Thủy Tinh Nguyên Thạch trong hành trang (đào được khi khai khoáng từ cấp 4).", 1, "Đóng/PTSH_No")
end

-- daily orders: 1 = 10 herbs, 2 = 10 ores, 3 = 10 fish (any tier)
function PTSH_Order()
	local d = PTSH_Day()
	if GetTask(PTSH_T_ODAY) ~= d then
		SetTask(PTSH_T_ODAY, d)
		SetTask(PTSH_T_ON, 0)
	end
	local done = GetTask(PTSH_T_ON)
	if done >= 3 then
		Say(PTSH_HEAD .. "Hôm nay ngươi đã giao đủ 3 đơn hàng. Mai hãy quay lại.", 1, "Đóng/PTSH_No")
		return
	end
	local k = done + 1
	local names = { "10 thảo dược", "10 khoáng thạch", "10 cá" }
	Say(PTSH_HEAD .. "Đơn hàng thứ " .. k .. "/3 hôm nay: giao <color=yellow>" .. names[k] .. "<color> (loại nào cũng được).", 2, "Giao hàng/PTSH_OrderDo", "Đóng/PTSH_No")
end

function PTSH_OrderDo()
	local d = PTSH_Day()
	if GetTask(PTSH_T_ODAY) ~= d then return end
	local done = GetTask(PTSH_T_ON)
	if done >= 3 then return end
	local k = done + 1
	local q = { k, 0, 1, 10, 10 }
	local r = PTSH_TierTake(q)
	if r ~= 1 then
		Say(PTSH_HEAD .. "Ngươi chưa đủ hàng trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	SetTask(PTSH_T_ON, k)
	local lv = GetLevel()
	local e = lv * lv * 12 + 5000
	AddOwnExp(e)
	Earn(lv * 200)
	PTSH_AddSkillExp(k, 5)
	local extra = ""
	if PTSH_Rand(1, 100) <= 30 and PTSH_Give(6, PTLT_I_DON, 0, 1) > 0 then extra = " Tặng thêm 1 Linh Thú Đơn." end
	Say(PTSH_HEAD .. "Đa tạ! Thưởng " .. e .. " kinh nghiệm và " .. (lv * 200) .. " lượng." .. extra, 1, "Đóng/PTSH_No")
end

-- Ton Su -----------------------------------------------------------------------------------------------------
function PTSH_TonSuMenu()
	local t = { PTSH_HEAD .. "Kỹ năng đạt cấp 9 có thể thăng cấp Tôn Sư (mở cấp 10): nộp " .. PTSH_TS_NEED .. " nguyên liệu cấp 8 trở lên của kỹ năng đó và " .. PTSH_TS_CASH .. " lượng.", 0 }
	local n = 0
	local k = 1
	while k <= 5 do
		if PTSH_Digit(GetTask(PTSH_T_TONSU), k) == 0 then
			n = n + 1 t[n + 2] = PTSH_TS[k][2] .. " (cấp hiện tại " .. PTSH_SkillLevel(k) .. ")/PTSH_TS" .. k
		end
		k = k + 1
	end
	if n == 0 then
		Say(PTSH_HEAD .. "Ngươi đã là Tôn Sư của cả năm kỹ năng sống!", 1, "Đóng/PTSH_No")
		return
	end
	n = n + 1 t[n + 2] = "Đóng/PTSH_No"
	t[2] = n
	call(Say, t)
end

function PTSH_TonSu(k)
	local ts = PTSH_TS[k]
	if PTSH_Digit(GetTask(PTSH_T_TONSU), k) == 1 then return end
	if PTSH_SkillLevel(k) < 9 then
		PTSH_Note(ts[1], ts[2], "Rèn " .. PTSH_SKILL_NAME[k] .. " lên cấp 9 rồi tìm Sinh Hoạt Sư.", 1)
		Say(PTSH_HEAD .. PTSH_SKILL_NAME[k] .. " phải đạt cấp 9.", 1, "Đóng/PTSH_No")
		return
	end
	local q = { ts[3], ts[4], 8, 10, PTSH_TS_NEED }
	if PTSH_TierCount(q) < PTSH_TS_NEED or GetCash() < PTSH_TS_CASH then
		PTSH_Note(ts[1], ts[2], "Nộp " .. PTSH_TS_NEED .. " " .. ts[5] .. " cấp 8 trở lên và " .. PTSH_TS_CASH .. " lượng cho Sinh Hoạt Sư.", 1)
		Say(PTSH_HEAD .. "Cần " .. PTSH_TS_NEED .. " " .. ts[5] .. " cấp 8 trở lên trong hành trang và " .. PTSH_TS_CASH .. " lượng.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_TierTake(q) ~= 1 then
		Say(PTSH_HEAD .. "Nguyên liệu phải để trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	if Pay(PTSH_TS_CASH) ~= 1 then
		PTSH_GiveBack(PTSH_LAST_TAKEN)
		Say(PTSH_HEAD .. "Ngươi không đủ ngân lượng.", 1, "Đóng/PTSH_No")
		return
	end
	SetTask(PTSH_T_TONSU, PTSH_SetDigit(GetTask(PTSH_T_TONSU), k, 1))
	PTSH_Note(ts[1], ts[2], "Hoàn thành", 2)
	AddOwnExp(GetLevel() * GetLevel() * 50)
	Say(PTSH_HEAD .. "Chúc mừng ngươi trở thành <color=yellow>" .. ts[2] .. "<color>! " .. PTSH_SKILL_NAME[k] .. " có thể lên cấp 10.", 1, "Đóng/PTSH_No")
end

function PTSH_TS1() PTSH_TonSu(1) end
function PTSH_TS2() PTSH_TonSu(2) end
function PTSH_TS3() PTSH_TonSu(3) end
function PTSH_TS4() PTSH_TonSu(4) end
function PTSH_TS5() PTSH_TonSu(5) end
