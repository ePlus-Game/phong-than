-- Phong Than 2026-10-03 (botparty): dialog of the "Ho Tro To Doi" NPC (spawned by party.lua PTBP_EnsureNpcs in
-- the 3 newbie towns, script registered by PTBP_Register). Per-player switch of the bot party: task 2070 mode
-- (0 server setting, 1 on, 2 off), task 2071 count (0 server setting, 1..7). The bots themselves are managed by
-- the minute tick (bots.lua -> PTBP_Tick); here only the switch is stored, "off" also removes the bots at once.
-- Generated from scratchpad\botparty\src\party_npc.lua by gen.py (TCVN3 escapes, ASCII file).
Include("\\script\\phongthan\\bots\\party.lua")

function PTBPN_ModeText()
	if GetTask(PTBP_T_MODE) == 2 then return "<color=red>đang tắt<color>" end
	return "<color=green>đang bật<color>"
end

function PTBPN_CountText()
	local n = GetTask(PTBP_T_COUNT)
	if not n or n <= 0 then return "theo máy chủ (mặc định " .. PTBP_DEF_COUNT .. ")" end
	return n .. " đồng đội"
end

function main()
	local s = "<color=yellow>Hỗ Trợ Tổ Đội<color>: khi bạn ra bãi quái (bản đồ có quái), đồng đội bot tự vào tổ đội, đi theo, đánh cùng mục tiêu với bạn. Quái do đồng đội hạ được tính như bạn hạ, kinh nghiệm cộng thêm theo số đồng đội ở gần như tổ đội VNG. Về thành hoặc vào tổ đội thật thì đồng đội tự rời.\nTổ đội bot: " .. PTBPN_ModeText() .. ". Số đồng đội: " .. PTBPN_CountText() .. "."
	Say(s, 5, "Bật tổ đội bot/PTBPN_On", "Tắt tổ đội bot/PTBPN_Off", "Chọn số đồng đội/PTBPN_CountMenu", "Cách tính kinh nghiệm tổ đội/PTBPN_Info", "Kết thúc đối thoại/no")
end

function PTBPN_On()
	SetTask(PTBP_T_MODE, 1)
	Say("Đã bật tổ đội bot. Ra bãi quái, chậm nhất 1 phút đồng đội sẽ tới.", 1, "Kết thúc đối thoại/no")
end

function PTBPN_Off()
	SetTask(PTBP_T_MODE, 2)
	local n = PTBP_DismissAll()
	Say("Đã tắt tổ đội bot. Đồng đội rời đội: " .. n .. ".", 1, "Kết thúc đối thoại/no")
end

function PTBPN_CountMenu()
	Say("Chọn số đồng đội bot (tổ đội VNG tối đa 8 người kể cả bạn):", 9, "1 đồng đội/PTBPN_C1", "2 đồng đội/PTBPN_C2", "3 đồng đội/PTBPN_C3", "4 đồng đội/PTBPN_C4", "5 đồng đội/PTBPN_C5", "6 đồng đội/PTBPN_C6", "7 đồng đội/PTBPN_C7", "Theo máy chủ/PTBPN_C0", "Kết thúc đối thoại/no")
end

function PTBPN_SetCount(n)
	SetTask(PTBP_T_COUNT, n)
	Say("Số đồng đội bot: " .. PTBPN_CountText() .. ". Áp dụng trong vòng 1 phút.", 1, "Kết thúc đối thoại/no")
end

function PTBPN_Info()
	local b = 0
	if GetPartyBotBonus then b = GetPartyBotBonus() end
	local s = "Mỗi đồng đội bot đứng gần bạn (trong khoảng chia kinh nghiệm của tổ đội) cộng thêm kinh nghiệm khi đánh quái, mặc định +" .. PTBP_DEF_BONUS .. "% mỗi người (quản trị chỉnh trên web). Bot không lấy phần kinh nghiệm nào. Chỉ áp dụng khi bạn chưa vào tổ đội thật."
	if GetPartyBotBonus then
		s = s .. " Hiện tại: +" .. b .. "%."
	else
		s = s .. " Máy chủ chưa cài bản cộng thêm kinh nghiệm tổ đội: đồng đội vẫn đánh giúp, quái vẫn tính cho bạn."
	end
	Say(s, 1, "Kết thúc đối thoại/no")
end

function PTBPN_C0() PTBPN_SetCount(0) end
function PTBPN_C1() PTBPN_SetCount(1) end
function PTBPN_C2() PTBPN_SetCount(2) end
function PTBPN_C3() PTBPN_SetCount(3) end
function PTBPN_C4() PTBPN_SetCount(4) end
function PTBPN_C5() PTBPN_SetCount(5) end
function PTBPN_C6() PTBPN_SetCount(6) end
function PTBPN_C7() PTBPN_SetCount(7) end

function no()
end
