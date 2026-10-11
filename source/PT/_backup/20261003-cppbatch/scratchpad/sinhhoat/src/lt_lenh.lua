-- Phong Than 2026-10-03 (sinhhoat): item 6/1/61370 "Linh Thu Lenh" (permanent, never consumed). Right click:
-- summon / dismiss the active pet, call it back, choose another owned pet, feed a Linh Thu Don, status.
-- The pet is an AiMode-11 follower (AddTotemNpc) without combat skills; the minute tick
-- (script\phongthan\ext\sinhhoat.lua) gives pet exp and owner exp while fighting and re-summons it after a map
-- change or death.
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

PTLT_HEAD = "<color=yellow>Linh Thú Lệnh<color>: "

function main(nItemIdx)
	if PTLT_OwnedCount() == 0 then
		Say(PTLT_HEAD .. "Ngươi chưa có linh thú nào. Hãy gặp Linh Thú Sứ ở Tây Kỳ hoặc Triều Ca để nhận linh thú đầu tiên.", 1, "Đóng/PTSH_No")
		return 0
	end
	local k = GetTask(PTLT_T_ACT)
	if PTLT_Stage(k) <= 0 then
		k = 1
		while k <= 8 and PTLT_Stage(k) <= 0 do k = k + 1 end
		SetTask(PTLT_T_ACT, k)
	end
	local out = PTLT_Owned()
	local t = { PTLT_HEAD .. "Linh thú hiện tại: <color=yellow>" .. PTLT_Label(k) .. "<color>.", 0 }
	local n = 0
	if out > 0 then
		n = n + 1 t[n + 2] = "Thu hồi linh thú/PTLT_Off"
		n = n + 1 t[n + 2] = "Gọi linh thú về bên cạnh/PTLT_Recall"
	else
		n = n + 1 t[n + 2] = "Triệu hồi linh thú/PTLT_On"
	end
	n = n + 1 t[n + 2] = "Đổi linh thú khác/PTLT_ChooseMenu"
	n = n + 1 t[n + 2] = "Cho ăn Linh Thú Đơn/PTLT_FeedMenu"
	n = n + 1 t[n + 2] = "Xem trạng thái/PTLT_Status"
	n = n + 1 t[n + 2] = "Đóng/PTSH_No"
	t[2] = n
	call(Say, t)
	return 0
end

function PTLT_On()
	if PTLT_Summon() > 0 then
		Msg2Player("Đã triệu hồi linh thú " .. PTLT_PET[GetTask(PTLT_T_ACT)][1] .. ".")
	else
		Say(PTLT_HEAD .. "Không triệu hồi được linh thú ở đây.", 1, "Đóng/PTSH_No")
	end
end

function PTLT_Off()
	PTLT_Dismiss(0)
	Msg2Player("Đã thu hồi linh thú.")
end

function PTLT_Recall()
	local idx = PTLT_Owned()
	if idx <= 0 then return end
	local pw, x, y = GetNpcPos(GetPlayerNpcIdx())
	SetNpcPos(idx, x + 1, y + 1)
end

function PTLT_ChooseMenu()
	local t = { PTLT_HEAD .. "Chọn linh thú:", 0 }
	local n = 0
	local k = 1
	while k <= 8 do
		if PTLT_Stage(k) > 0 then
			n = n + 1 t[n + 2] = PTLT_Label(k) .. "/PTLT_S" .. k
		end
		k = k + 1
	end
	n = n + 1 t[n + 2] = "Đóng/PTSH_No"
	t[2] = n
	call(Say, t)
end

function PTLT_Choose(k)
	if PTLT_Stage(k) <= 0 then return end
	local was = PTLT_Owned()
	SetTask(PTLT_T_ACT, k)
	if was > 0 then PTLT_Summon() end
	Msg2Player("Linh thú hiện tại: " .. PTLT_Label(k) .. ".")
end

function PTLT_FeedMenu()
	local have = PTSH_Count(6, PTLT_I_DON, 0)
	Say(PTLT_HEAD .. "Mỗi Linh Thú Đơn cho linh thú hiện tại " .. PTLT_FOOD_EXP .. " điểm kinh nghiệm. Ngươi có " .. have .. " viên.", 3, "Cho ăn 1 viên/PTLT_Feed1", "Cho ăn 10 viên/PTLT_Feed10", "Đóng/PTSH_No")
end

function PTLT_FeedN(n)
	local done = 0
	while done < n do
		if PTSH_Take(6, PTLT_I_DON, 0, 1) < 1 then break end
		local r = PTLT_Feed()
		if r <= 0 then
			PTSH_Give(6, PTLT_I_DON, 0, 1)
			break
		end
		done = done + 1
	end
	local k = GetTask(PTLT_T_ACT)
	if done == 0 then
		Say(PTLT_HEAD .. "Không cho ăn được (không có Linh Thú Đơn trong hành trang, hoặc linh thú đã đạt giới hạn cấp của giai đoạn).", 1, "Đóng/PTSH_No")
		return
	end
	Msg2Player("Đã cho ăn " .. done .. " Linh Thú Đơn. " .. PTLT_Label(k) .. ".")
end

function PTLT_Feed1() PTLT_FeedN(1) end
function PTLT_Feed10() PTLT_FeedN(10) end

function PTLT_Status()
	local s = PTLT_HEAD .. "Linh thú của ngươi:"
	local k = 1
	while k <= 8 do
		if PTLT_Stage(k) > 0 then
			local lv = PTLT_Level(k)
			local e = GetTask(PTLT_T_EXP0 + k) - PTLT_ExpFor(lv)
			s = s .. "\n" .. PTLT_Label(k) .. " (" .. e .. "/" .. PTLT_Need(lv) .. ")"
		end
		k = k + 1
	end
	Say(s, 1, "Đóng/PTSH_No")
end

function PTLT_S1() PTLT_Choose(1) end
function PTLT_S2() PTLT_Choose(2) end
function PTLT_S3() PTLT_Choose(3) end
function PTLT_S4() PTLT_Choose(4) end
function PTLT_S5() PTLT_Choose(5) end
function PTLT_S6() PTLT_Choose(6) end
function PTLT_S7() PTLT_Choose(7) end
function PTLT_S8() PTLT_Choose(8) end
