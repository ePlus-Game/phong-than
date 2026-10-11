-- Phong Than 2026-10-02: Thien Hung (Tay Ky), entry NPC of Van Tien tran. Spawned by the minute tick
-- (vt_timer.lua, PTVT_TH[4] = template 202 passerby054, the immortal look of Da Bao Dao Nhan; before
-- 2026-10-02 vantien2 it was 247 = the VNG gate). Solo friendly: a closed tran is opened on demand.
-- 2026-10-02 (vantien2): VNG daily quest chain of Thien Hung (script b5deef29) ported, functions thq_*;
-- data and kill credit in vt_quest.lua, tasks 2006..2013.
Include("\\script\\phongthan\\vantien\\vt_lib.lua")

function main()
	local opts = {}
	local n = 1
	while n <= 4 do
		local lock = ""
		if not PTVT_Unlocked(n) then lock = ", khóa" end
		tinsert(opts, "Vạn Tiên trận (" .. PTVT_NAME[n] .. ") cấp " .. PTVT_MINLV[n] .. "+ [" .. PTVT_StateText(n) .. lock .. "]/th_enter" .. n)
		n = n + 1
	end
	if GetLevel() >= PTVT_MINLV[1] then
		if GetTask(PTVT_T_QLV) == 0 then
			tinsert(opts, "Nhiệm vụ: điều tra Lục Hồn Phiên/thq_renwu1")
		else
			tinsert(opts, "Nhiệm vụ ngày Vạn Tiên trận/thq_renwu2")
			tinsert(opts, "Đẳng cấp Vạn Tiên trận/thq_chaxun")
		end
	end
	tinsert(opts, "Giới thiệu Vạn Tiên trận/th_info")
	tinsert(opts, "Kết thúc đối thoại/no")
	local t = { "<color=green>Thiên Hùng<color>: Thông Thiên Giáo Chủ bày Vạn Tiên trận, ma chúng lộng hành. Ta chiêu mộ dũng sĩ từ cấp <color=yellow>30<color> vào phá trận. Ngươi muốn vào trận nào?", getn(opts) }
	local i = 1
	while opts[i] do
		t[i + 2] = opts[i]
		i = i + 1
	end
	call(Say, t)
end

function th_enter(n)
	CloseDialog()
	PTVT_EnterRequest(n)
end

function th_enter1() th_enter(1) end
function th_enter2() th_enter(2) end
function th_enter3() th_enter(3) end
function th_enter4() th_enter(4) end

function th_info()
	Say("Vạn Tiên trận gồm 4 trận: <color=yellow>Thổ<color> (cấp 30+), <color=yellow>Thủy<color> (51+), <color=yellow>Hỏa<color> (71+), <color=yellow>Phong<color> (91+). Phá trận trước sẽ mở khóa trận sau dù chưa đủ cấp. Trong trận: hạ <color=green>Ô Vân, Cầu Thủ, Linh Nha, Kim Quang Tiên<color> để lấy 4 lệnh, Thông Thiên Giáo Chủ sẽ xuất hiện ở Thần Bí Trận Điểm (bước vào trận nhãn với đủ 4 lệnh, hoặc nhờ Đại phu đưa vào). Hạ Thông Thiên được thưởng kinh nghiệm, ngân lượng, nguyên liệu và 4 Bảo rương. Mỗi trận nhận thưởng tối đa " .. PTVT_DAILY_CAP .. " lần mỗi ngày. Mỗi lượt kéo dài " .. floor(PTVT_FIGHT / 60) .. " phút. Mỗi ngày ta giao một <color=yellow>nhiệm vụ Vạn Tiên trận<color>: hoàn thành để nhận kinh nghiệm, ngân lượng, tăng đẳng cấp Vạn Tiên trận và nhận trang bị bộ ở đẳng cấp 1, 4, 7, 9.", 2, "Trở lại/main", "Kết thúc đối thoại/no")
end

function no()
	CloseDialog()
end

-- ------------------------------------------------------------------ daily quest chain (VNG b5deef29)
function thq_say(txt)
	Say("<color=green>Thiên Hùng<color>: " .. txt, 2, "Trở lại/main", "Kết thúc đối thoại/no")
end

-- level shown to the player = task value - 1 (VNG chaxun)
function thq_chaxun()
	local v = GetTask(PTVT_T_QLV)
	if v <= 0 then
		thq_say("Ngươi chưa nhận nhiệm vụ Vạn Tiên trận nào.")
		return
	end
	local lv = v - 1
	local s = "Đẳng cấp Vạn Tiên trận của ngươi hiện là <color=green>" .. lv .. "<color>. "
	if lv >= 10 then
		s = s .. "Đã đạt đẳng cấp cao nhất!"
	elseif v <= PTVT_Q_LEVELREQ[PTVT_QSuit()] then
		s = s .. "Hoàn thành thêm <color=green>" .. GetTask(PTVT_T_QNEED) .. "<color> lần nhiệm vụ Vạn Tiên trận nữa thì có thể thăng cấp."
	else
		s = s .. "Ngươi phải đủ cấp vào <color=green>Vạn Tiên trận cao hơn một bậc<color> mới có thể tiếp tục thăng cấp."
	end
	thq_say(s)
end

-- intro quest: investigate the Luc Hon Phien (ask the Dai phu inside the tran)
function thq_renwu1()
	local st = GetTask(PTVT_T_QSTATE)
	if GetTask(PTVT_T_QLV) ~= 0 then
		thq_renwu2()
		return
	end
	if st == 0 then
		Say("<color=green>Thiên Hùng<color>: Trăm năm trước, Phong Thần bảng hiện thế dẫn tới một trận hạo kiếp. Triệt Giáo của Thông Thiên Giáo Chủ trái ý trời, lập trận ngăn cản việc Phong Thần; Xiển Giáo liên thủ với Tây Phương giáo chủ mới phá được trận, đánh bại Thông Thiên. Gần đây nghe nói pháp đàn của hắn treo một lá cờ ác gọi là <color=green>Lục Hồn Phiên<color>, không rõ nhằm mục đích gì. Ngươi giúp ta điều tra lai lịch lá cờ này chứ?", 2, "Nhận nhiệm vụ/thq_yes1", "Để sau/no")
	elseif st == PTVT_Q_DONE then
		SetTask(PTVT_T_QLV, 1)
		SetTask(PTVT_T_QNEED, 1)
		SetTask(PTVT_T_QSTATE, 0)
		AddOwnExp(5000)
		Msg2Player("Bạn nhận được 5000 điểm kinh nghiệm.")
		thq_say("Thì ra <color=green>Lục Hồn Phiên<color> không có trong Vạn Tiên trận, xem ra vẫn phải tiếp tục tìm kiếm. Phần thưởng này ngươi hãy nhận lấy. Vạn Tiên trận là nơi rèn luyện lý tưởng; từ nay mỗi ngày hãy đến nhận <color=yellow>nhiệm vụ Vạn Tiên trận<color>.")
	else
		thq_say("Có thể Lục Hồn Phiên nằm trong Vạn Tiên trận. Hãy vào trận và tìm <color=green>Đại phu<color> trong đó hỏi xem.")
	end
end

function thq_yes1()
	SetTask(PTVT_T_QSTATE, 1)
	Msg2Player("Tiếp nhận nhiệm vụ: điều tra Lục Hồn Phiên trong Vạn Tiên trận (hỏi Đại phu trong trận).")
	thq_say("Có thể Lục Hồn Phiên nằm trong Vạn Tiên trận. Trước khi điều tra, tốt nhất hãy tìm <color=green>Đại phu<color> trong Vạn Tiên trận hỏi xem.")
end

-- normal reward of a finished daily quest: 0 = no level change, 1 = level up, 2 = capped by the tran bracket
function thq_reward_normal()
	if GetTask(PTVT_T_QSTATE) ~= PTVT_Q_DONE then return -1 end
	SetTask(PTVT_T_QSTATE, 0)
	local v = GetTask(PTVT_T_QLV)
	if v < 1 then v = 1 end
	if v > 11 then v = 11 end
	local exp = PTVT_Q_REWARD[v][1] * GetLevel() * 2
	local money = PTVT_Q_REWARD[v][2]
	AddOwnExp(exp)
	Earn(money)
	Msg2Player("Bạn nhận được " .. money .. " lượng và " .. exp .. " điểm kinh nghiệm.")
	if v <= 10 and v <= PTVT_Q_LEVELREQ[PTVT_QSuit()] then
		local need = GetTask(PTVT_T_QNEED) - 1
		if need <= 0 then
			SetTask(PTVT_T_QLV, v + 1)
			SetTask(PTVT_T_QNEED, PTVT_Q_LEVELUP[v])
			return 1
		end
		SetTask(PTVT_T_QNEED, need)
		return 0
	end
	return 2
end

function thq_reward_text(ret)
	local s = "Ngươi đã hoàn thành nhiệm vụ, hãy nhận phần thưởng."
	if ret == 1 then
		s = s .. " Đẳng cấp Vạn Tiên trận của ngươi tăng lên <color=green>" .. (GetTask(PTVT_T_QLV) - 1) .. "<color>; nhiệm vụ sau sẽ khó hơn nhưng phần thưởng nhiều hơn."
	elseif ret == 2 and GetTask(PTVT_T_QLV) <= 10 then
		s = s .. " Ngươi phải đủ cấp vào Vạn Tiên trận cao hơn một bậc mới có thể tăng đẳng cấp Vạn Tiên trận."
	end
	return s
end

-- set reward choice (quest level 2 / 5 / 8 / 10 with one quest left): 5 parts, 3 at level 8
function thq_reward_add()
	local v = GetTask(PTVT_T_QLV)
	local idx = PTVT_Q_SETIDX[v]
	local pt = GetPlayerType()
	if not idx or GetTask(PTVT_T_QSTATE) ~= PTVT_Q_DONE then
		CloseDialog()
		return
	end
	if not pt or pt < 0 or pt > 2 then
		thq_say("Không xác định được hệ phái của ngươi, chưa thể trao trang bị.")
		return
	end
	local opts = {}
	local a = 1
	local b = 5
	if v == 8 then
		a = 2
		b = 4
	end
	local i = a
	while i <= b do
		tinsert(opts, PTVT_Q_SETNAME[pt + 1][idx] .. " " .. PTVT_Q_PARTNAME[pt + 1][i] .. "/thq_item" .. i)
		i = i + 1
	end
	tinsert(opts, "Để sau/no")
	local t = { "<color=green>Thiên Hùng<color>: Đẳng cấp Vạn Tiên trận của ngươi đã đạt <color=green>" .. (v - 1) .. "<color>. Ngoài phần thưởng lần này, ngươi được chọn 1 món trang bị:", getn(opts) }
	i = 1
	while opts[i] do
		t[i + 2] = opts[i]
		i = i + 1
	end
	call(Say, t)
end

function thq_item(i)
	local v = GetTask(PTVT_T_QLV)
	local slv = PTVT_Q_SETLV[v]
	local idx = PTVT_Q_SETIDX[v]
	local pt = GetPlayerType()
	if not slv or GetTask(PTVT_T_QSTATE) ~= PTVT_Q_DONE or GetTask(PTVT_T_QNEED) ~= 1 or GetTask(PTVT_T_QDAY) ~= PTVT_Today() then
		CloseDialog()
		return
	end
	if (v == 8 and (i < 2 or i > 4)) or i < 1 or i > 5 then
		CloseDialog()
		return
	end
	if not pt or pt < 0 or pt > 2 then
		CloseDialog()
		return
	end
	local name = PTVT_Q_SETNAME[pt + 1][idx] .. " " .. PTVT_Q_PARTNAME[pt + 1][i]
	local it = AddNormalItem(0, PTVT_Q_PART[i], pt + 6, slv, 0, 0, 0)
	if not it or it <= 0 then
		thq_say("Hành trang của ngươi đã đầy, hãy dọn bớt rồi quay lại nhận <color=green>" .. name .. "<color>.")
		return
	end
	AddGlobalCountNews("<color=green>" .. (GetName() or "") .. "<color> đạt đẳng cấp Vạn Tiên trận " .. (v - 1) .. ", được <color=green>Thiên Hùng<color> tặng <color=green>" .. name .. "<color>.", 20)
	Msg2Player("Nhận được " .. name .. ".")
	local ret = thq_reward_normal()
	thq_say(thq_reward_text(ret))
end

function thq_item1() thq_item(1) end
function thq_item2() thq_item(2) end
function thq_item3() thq_item(3) end
function thq_item4() thq_item(4) end
function thq_item5() thq_item(5) end

-- Thuong Kim Bai: a new daily quest after today's one, max 2 per day
function thq_cost_ib()
	local today = PTVT_Today()
	if GetTask(PTVT_T_QIBDAY) ~= today then
		SetTask(PTVT_T_QIBDAY, today)
		SetTask(PTVT_T_QIBCNT, 0)
	end
	local it = FindAValidIBItem(PTVT_Q_IB[1], PTVT_Q_IB[2], PTVT_Q_IB[3], PTVT_Q_IB[4])
	if not it or it < 1 then
		thq_say("Ngươi không có <color=green>Thưởng Kim Bài<color>.")
		return
	end
	if GetTask(PTVT_T_QIBCNT) >= 2 then
		thq_say("Hôm nay ngươi đã dùng 2 lần Thưởng Kim Bài, ngày mai hãy quay lại.")
		return
	end
	if GetTask(PTVT_T_QSTATE) ~= 0 or GetTask(PTVT_T_QDAY) ~= today then
		thq_renwu2()
		return
	end
	if CostIBItem(it) ~= 1 then
		thq_say("Không dùng được Thưởng Kim Bài.")
		return
	end
	SetTask(PTVT_T_QIBCNT, GetTask(PTVT_T_QIBCNT) + 1)
	SetTask(PTVT_T_QDAY, 0)
	thq_renwu2()
end

function thq_renwu2()
	local today = PTVT_Today()
	local st = GetTask(PTVT_T_QSTATE)
	if GetTask(PTVT_T_QLV) == 0 then
		thq_renwu1()
		return
	end
	if st == 0 then
		if GetTask(PTVT_T_QDAY) == today then
			Say("<color=green>Thiên Hùng<color>: Nhiệm vụ hôm nay ngươi đã hoàn thành. Nếu có <color=green>Thưởng Kim Bài<color> có thể đổi lấy nhiệm vụ mới (tối đa 2 lần mỗi ngày). Ngươi muốn dùng Thưởng Kim Bài không?", 3, "Dùng Thưởng Kim Bài/thq_cost_ib", "Trở lại/main", "Kết thúc đối thoại/no")
			return
		end
		SetTask(PTVT_T_QDAY, today)
		local v = GetTask(PTVT_T_QLV)
		if v > 11 then v = 11 end
		if v == 8 and GetTask(PTVT_T_QNEED) == 1 then
			SetTask(PTVT_T_QCOUNT, 0)
			SetTask(PTVT_T_QSTATE, 10)
			Msg2Player("Nhiệm vụ Vạn Tiên trận: vào trận hỏi Đại phu về lệnh bài đặc biệt.")
			thq_say("Vạn Tiên trận có những nơi người thường không thể đến được, muốn đến phải có <color=green>lệnh bài đặc biệt<color>. Nghe nói có kẻ đã biến mất khi đứng gần vật tổ trong đó. Hãy vào trận hỏi <color=green>Đại phu<color>. Mong ngươi bình an trở về.")
			return
		end
		local list = PTVT_Q_TASKS[v]
		local pick = list[random(1, getn(list))]
		local kind = pick[1]
		local count = pick[2]
		if kind <= 3 then
			count = floor(count / PTVT_Q_KILL_DIV)
			if count < 1 then count = 1 end
		end
		SetTask(PTVT_T_QCOUNT, count)
		SetTask(PTVT_T_QSTATE, kind)
		Msg2Player("Đã nhận nhiệm vụ Vạn Tiên trận, hạn trong hôm nay.")
		thq_say("Nhiệm vụ lần này: vào Vạn Tiên trận tiêu diệt " .. PTVT_QTarget(kind, count) .. ". Ngươi phải hoàn thành trong <color=red>hôm nay<color> mới nhận được phần thưởng.")
		return
	end
	if st == PTVT_Q_DONE then
		if GetTask(PTVT_T_QDAY) ~= today then
			SetTask(PTVT_T_QCOUNT, 0)
			SetTask(PTVT_T_QSTATE, 0)
			thq_say("Nhiệm vụ đã quá thời hạn quy định, không thể nhận phần thưởng.")
			return
		end
		local v = GetTask(PTVT_T_QLV)
		if GetTask(PTVT_T_QNEED) == 1 and (v == 2 or v == 5 or v == 10) then
			thq_reward_add()
			return
		end
		if GetTask(PTVT_T_QNEED) == 1 and v == 8 then
			SetTask(PTVT_T_QPASS, 1)
			Say("<color=green>Thiên Hùng<color>: Thì ra là vậy! Từ nay ngươi không cần lệnh bài cũng có thể vào Thần Bí Trận Điểm (nhờ Đại phu trong trận). Tiêu diệt Thông Thiên Giáo Chủ là tâm nguyện của mọi chiến binh, đi hay không tùy ngươi!", 2, "Nhận thưởng/thq_reward_add", "Để sau/no")
			return
		end
		local ret = thq_reward_normal()
		thq_say(thq_reward_text(ret))
		return
	end
	-- quest in progress
	if st ~= 1 and GetTask(PTVT_T_QDAY) ~= today then
		SetTask(PTVT_T_QCOUNT, 0)
		SetTask(PTVT_T_QSTATE, 0)
		thq_say("Nhiệm vụ đã quá thời hạn quy định, không thể nhận phần thưởng. Hãy nhận nhiệm vụ mới.")
		return
	end
	if st == 10 then
		thq_say("Hãy vào Vạn Tiên trận hỏi <color=green>Đại phu<color> về lệnh bài đặc biệt. Nghe nói có kẻ đã biến mất khi đứng gần vật tổ trong đó.")
		return
	end
	local kind = PTVT_QType(st)
	local count = GetTask(PTVT_T_QCOUNT)
	if kind == 8 then count = 4 - PTVT_CountTien(floor(st / 256)) end
	thq_say("Ngươi hãy đi tiêu diệt " .. PTVT_QTarget(kind, count) .. ". Mau đi mau về!")
end
