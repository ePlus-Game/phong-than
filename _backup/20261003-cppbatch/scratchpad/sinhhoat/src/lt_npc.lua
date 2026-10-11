-- Phong Than 2026-10-03 (sinhhoat): Linh Thu Su (pet keeper) in Tay Ky and Trieu Ca. Gives the Linh Thu Lenh,
-- the first pet (free), pet eggs for Linh Thu Don + silver, and the growth stages of taskinfo 2035-2070
-- (4 stages per pet; stage s caps the pet at level s*10; each evolution swaps the VNG pet template).
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

PTLT_HEAD = "<color=green>Linh Thú Sứ<color>: "
-- evolution from stage s: essence (tinh hoa) / meat (thit) tiers, extra item, silver
PTLT_EVO = {}
PTLT_EVO[1] = { q1 = { 1, 46, 1, 3, 10 }, q2 = { 3, 28, 1, 3, 10 }, cash = 50000 }
PTLT_EVO[2] = { q1 = { 1, 46, 4, 6, 10 }, q2 = { 3, 28, 4, 6, 10 }, x = { 3, 88, 0, 1 }, xname = "Mảnh Hoàng thủy tinh", cash = 200000 }
PTLT_EVO[3] = { q1 = { 1, 46, 7, 10, 10 }, q2 = { 3, 28, 7, 10, 10 }, x = { 3, 89, 0, 1 }, xname = "Hoàng thủy tinh", cash = 500000 }
PTLT_EVO_TIER = { "cấp 1-3", "cấp 4-6", "cấp 7 trở lên" }

function main()
	local t = { PTLT_HEAD .. "Linh thú đi theo chủ nhân khi chiến đấu sẽ lên cấp, giúp chủ nhân thêm kinh nghiệm và tha về nguyên liệu. Ngươi cần gì?", 0 }
	local n = 0
	if PTLT_OwnedCount() == 0 then
		n = n + 1 t[n + 2] = "Nhận linh thú đầu tiên (miễn phí)/PTLT_FirstMenu"
	end
	n = n + 1 t[n + 2] = "Nhận Linh Thú Lệnh/PTLT_GiveLenh"
	n = n + 1 t[n + 2] = "Tiến hóa linh thú/PTLT_EvoMenu"
	n = n + 1 t[n + 2] = "Đổi Trứng Linh Thú/PTLT_EggMenu"
	n = n + 1 t[n + 2] = "Giới thiệu linh thú/PTLT_Info"
	n = n + 1 t[n + 2] = "Đóng/PTSH_No"
	t[2] = n
	call(Say, t)
end

function PTLT_Info()
	Say(PTLT_HEAD .. "Có 8 linh thú: Hồ Hỷ Mị, Na Tra, Lôi Chấn Tử, Thạch Cơ, Thái Ất, Đắc Kỷ, Thân Công Báo, Hoàng Phi Hổ. Mỗi con có 4 giai đoạn trưởng thành, giai đoạn s giới hạn cấp s x 10. Linh thú lên cấp khi đi theo ngươi chiến đấu (mỗi phút) hoặc ăn Linh Thú Đơn (Sinh Hoạt Sư chế, Lễ Quan tặng). Trứng có thể đổi ở đây hoặc nhận từ hoạt động Lễ Quan.", 1, "Đóng/PTSH_No")
end

function PTLT_GiveLenh()
	if PTSH_Count(6, PTLT_I_LENH, 0) > 0 then
		Say(PTLT_HEAD .. "Ngươi đã có Linh Thú Lệnh rồi.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_Free() < 1 or PTSH_Give(6, PTLT_I_LENH, 0, 1) < 1 then
		Say(PTLT_HEAD .. "Hành trang đã đầy.", 1, "Đóng/PTSH_No")
		return
	end
	Say(PTLT_HEAD .. "Cầm lấy Linh Thú Lệnh: nhấp phải để triệu hồi, đổi, cho ăn và xem linh thú.", 1, "Đóng/PTSH_No")
end

function PTLT_PetMenu(head, prefix, mode)
	local t = { head, 0 }
	local n = 0
	local k = 1
	while k <= 8 do
		local s = PTLT_Stage(k)
		if (mode == 0 and s == 0) or (mode == 1 and s > 0) or mode == 2 then
			n = n + 1
			local lab = PTLT_PET[k][1]
			if s > 0 then lab = PTLT_Label(k) end
			t[n + 2] = lab .. "/" .. prefix .. k
		end
		k = k + 1
	end
	if n == 0 then
		Say(PTLT_HEAD .. "Không có linh thú nào phù hợp.", 1, "Đóng/PTSH_No")
		return
	end
	n = n + 1 t[n + 2] = "Đóng/PTSH_No"
	t[2] = n
	call(Say, t)
end

-- first pet --------------------------------------------------------------------------------------------------
function PTLT_FirstMenu()
	if PTLT_OwnedCount() > 0 then return end
	PTLT_PetMenu(PTLT_HEAD .. "Chọn linh thú đầu tiên của ngươi:", "PTLT_F", 0)
end

function PTLT_First(k)
	if PTLT_OwnedCount() > 0 or k < 1 or k > 8 then return end
	PTLT_SetStage(k, 1)
	SetTask(PTLT_T_EXP0 + k, 0)
	SetTask(PTLT_T_ACT, k)
	if PTSH_Count(6, PTLT_I_LENH, 0) <= 0 then PTSH_Give(6, PTLT_I_LENH, 0, 1) end
	PTSH_Note(PTLT_PET[k][6], PTLT_STAGE_NAME[k][1], "Nhận linh thú " .. PTLT_PET[k][1] .. ". Cho đi theo khi chiến đấu đến cấp 10 rồi tìm Linh Thú Sứ tiến hóa.", 1)
	Say(PTLT_HEAD .. "Ngươi đã nhận <color=yellow>" .. PTLT_PET[k][1] .. "<color>. Nhấp phải Linh Thú Lệnh để triệu hồi.", 1, "Đóng/PTSH_No")
end

-- eggs -----------------------------------------------------------------------------------------------------------
function PTLT_EggMenu()
	PTLT_PetMenu(PTLT_HEAD .. "Mỗi trứng giá " .. PTLT_EGG_DON .. " Linh Thú Đơn và " .. PTLT_EGG_CASH .. " lượng. Chọn trứng:", "PTLT_E", 2)
end

function PTLT_Egg(k)
	if k < 1 or k > 8 then return end
	if PTSH_Free() < 1 then
		Say(PTLT_HEAD .. "Hành trang đã đầy.", 1, "Đóng/PTSH_No")
		return
	end
	if GetCash() < PTLT_EGG_CASH or PTSH_Count(6, PTLT_I_DON, 0) < PTLT_EGG_DON then
		Say(PTLT_HEAD .. "Cần " .. PTLT_EGG_DON .. " Linh Thú Đơn trong hành trang và " .. PTLT_EGG_CASH .. " lượng.", 1, "Đóng/PTSH_No")
		return
	end
	local list = { { 6, PTLT_I_DON, 0, PTLT_EGG_DON } }
	if PTSH_TakeAll(list) ~= 1 then
		Say(PTLT_HEAD .. "Linh Thú Đơn phải để trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	if Pay(PTLT_EGG_CASH) ~= 1 then
		PTSH_Give(6, PTLT_I_DON, 0, PTLT_EGG_DON)
		return
	end
	PTSH_Give(6, PTLT_I_EGG0 + k, 0, 1)
	Say(PTLT_HEAD .. "Đây là <color=yellow>Trứng Linh Thú " .. PTLT_PET[k][1] .. "<color>, nhấp phải để ấp nở.", 1, "Đóng/PTSH_No")
end

-- evolution ----------------------------------------------------------------------------------------------------------
function PTLT_EvoMenu()
	PTLT_PetMenu(PTLT_HEAD .. "Chọn linh thú muốn tiến hóa:", "PTLT_V", 1)
end

function PTLT_EvoNeed(k, s)
	local e = PTLT_EVO[s]
	local txt = "Đạt cấp " .. (s * 10) .. ", nộp 10 tinh hoa thảo dược " .. PTLT_EVO_TIER[s] .. ", 10 thịt cá " .. PTLT_EVO_TIER[s]
	if e.x then txt = txt .. ", 1 " .. e.xname end
	return txt .. " và " .. e.cash .. " lượng."
end

function PTLT_Evo(k)
	local s = PTLT_Stage(k)
	if s <= 0 then return end
	if s >= 4 then
		Say(PTLT_HEAD .. PTLT_PET[k][1] .. " đã đạt giai đoạn cuối: " .. PTLT_STAGE_NAME[k][4] .. ".", 1, "Đóng/PTSH_No")
		return
	end
	local e = PTLT_EVO[s]
	local need = PTLT_EvoNeed(k, s)
	local tid = PTLT_PET[k][6] + s
	if PTLT_Level(k) < s * 10 then
		PTSH_Note(tid, PTLT_STAGE_NAME[k][s + 1], need, 1)
		Say(PTLT_HEAD .. PTLT_PET[k][1] .. " phải đạt cấp " .. (s * 10) .. " (hiện cấp " .. PTLT_Level(k) .. "). Điều kiện: " .. need, 1, "Đóng/PTSH_No")
		return
	end
	local ok = 1
	if PTSH_TierCount(e.q1) < 10 or PTSH_TierCount(e.q2) < 10 or GetCash() < e.cash then ok = 0 end
	if e.x and PTSH_Count(e.x[1], e.x[2], e.x[3]) < e.x[4] then ok = 0 end
	if ok == 0 then
		PTSH_Note(tid, PTLT_STAGE_NAME[k][s + 1], need, 1)
		Say(PTLT_HEAD .. "Chưa đủ điều kiện (nguyên liệu để trong hành trang). " .. need, 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_TierTake(e.q1) ~= 1 then
		Say(PTLT_HEAD .. "Nguyên liệu phải để trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	local t1 = PTSH_LAST_TAKEN
	if PTSH_TierTake(e.q2) ~= 1 then
		PTSH_GiveBack(t1)
		Say(PTLT_HEAD .. "Nguyên liệu phải để trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	local t2 = PTSH_LAST_TAKEN
	if e.x and PTSH_TakeAll({ e.x }) ~= 1 then
		PTSH_GiveBack(t1)
		PTSH_GiveBack(t2)
		Say(PTLT_HEAD .. e.xname .. " phải để trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	if Pay(e.cash) ~= 1 then
		PTSH_GiveBack(t1)
		PTSH_GiveBack(t2)
		if e.x then PTSH_Give(e.x[1], e.x[2], e.x[3], e.x[4]) end
		return
	end
	PTLT_SetStage(k, s + 1)
	PTSH_Note(tid, PTLT_STAGE_NAME[k][s + 1], "Hoàn thành", 2)
	if s + 1 < 4 then PTSH_Note(tid + 1, PTLT_STAGE_NAME[k][s + 2], PTLT_EvoNeed(k, s + 1), 1) end
	if GetTask(PTLT_T_ACT) == k and PTLT_Owned() > 0 then PTLT_Summon() end
	Say(PTLT_HEAD .. PTLT_PET[k][1] .. " tiến hóa thành công: <color=yellow>" .. PTLT_STAGE_NAME[k][s + 1] .. "<color>! Giới hạn cấp mới: " .. ((s + 1) * 10) .. ".", 1, "Đóng/PTSH_No")
end

function PTLT_F1() PTLT_First(1) end
function PTLT_F2() PTLT_First(2) end
function PTLT_F3() PTLT_First(3) end
function PTLT_F4() PTLT_First(4) end
function PTLT_F5() PTLT_First(5) end
function PTLT_F6() PTLT_First(6) end
function PTLT_F7() PTLT_First(7) end
function PTLT_F8() PTLT_First(8) end
function PTLT_E1() PTLT_Egg(1) end
function PTLT_E2() PTLT_Egg(2) end
function PTLT_E3() PTLT_Egg(3) end
function PTLT_E4() PTLT_Egg(4) end
function PTLT_E5() PTLT_Egg(5) end
function PTLT_E6() PTLT_Egg(6) end
function PTLT_E7() PTLT_Egg(7) end
function PTLT_E8() PTLT_Egg(8) end
function PTLT_V1() PTLT_Evo(1) end
function PTLT_V2() PTLT_Evo(2) end
function PTLT_V3() PTLT_Evo(3) end
function PTLT_V4() PTLT_Evo(4) end
function PTLT_V5() PTLT_Evo(5) end
function PTLT_V6() PTLT_Evo(6) end
function PTLT_V7() PTLT_Evo(7) end
function PTLT_V8() PTLT_Evo(8) end
