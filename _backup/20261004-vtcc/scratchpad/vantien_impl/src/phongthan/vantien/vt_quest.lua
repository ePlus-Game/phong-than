-- Phong Than 2026-10-02 (agent vantien2): Thien Hung daily quest chain, port of the VNG script b5deef29
-- ("Van Tien tran linh nhiem vu xu", lixuewu). Shared data + kill credit, included by vt_lib.lua, so the
-- boss / mob / Dai phu scripts can credit the quest. The dialog lives in vt_thienhung.lua.
-- VNG used tasks 405..409, bit 1 of 404 and 767/768; the loose VNG npcdeath scripts of templates 53..60
-- still touch 407..409, so the port uses the Van Tien task range 2006..2013 instead:
PTVT_T_QLV = 2006      -- VNG 405: Van Tien level + 1 (0 = intro not done, 1 = level 0 ... 11 = level 10)
PTVT_T_QNEED = 2007    -- VNG 406: quests still needed for the next level
PTVT_T_QCOUNT = 2008   -- VNG 407: kills left (quest type 2 / 3)
PTVT_T_QSTATE = 2009   -- VNG 408: 0 none, 1 intro (ask the Dai phu), 2 / 3 kill mobs, 4..7 kill tien k-3,
                       --          8 + 256 * mask kill the 4 tien, 9 Thong Thien, 10 ask the Dai phu, 100000 done
PTVT_T_QDAY = 2010     -- VNG 409: day (YYYYMMDD) of the current daily quest
PTVT_T_QPASS = 2011    -- VNG 404 bit 1: 1 = Dai phu may send the player to Than Bi Tran Diem without the 4 lenh
PTVT_T_QIBDAY = 2012   -- VNG 767: day of the Thuong Kim Bai counter
PTVT_T_QIBCNT = 2013   -- VNG 768: Thuong Kim Bai used today (max 2)
PTVT_Q_DONE = 100000
PTVT_Q_KILL_DIV = 5    -- solo balance: VNG asked 50..500 kills, here 10..100 (12 mobs per tran, they revive)
PTVT_Q_IB = {8, 138, 2, 0}    -- Thuong Kim Bai (IB item): resets the daily quest, max 2 per day

-- VNG tables (index = value of PTVT_T_QLV)
PTVT_Q_REWARD = {{400,5000},{500,5000},{500,5000},{600,5000},{600,10000},{700,10000},
	{700,20000},{800,20000},{800,30000},{900,40000},{1000,50000}}
PTVT_Q_LEVELUP = {3,5,8,12,18,25,35,50,100,0}
PTVT_Q_LEVELREQ = {2,5,8,10}                -- max quest level per tran bracket (player level 30/51/71/91+)
PTVT_Q_TASKS = {
	{{2,50}},{{2,100}},{{2,100},{3,100}},{{4,1},{5,1},{6,1},{7,1}},
	{{2,150},{3,150}},{{2,200},{3,200},{4,1},{5,1},{6,1},{7,1}},{{2,300},{3,300}},
	{{2,400},{3,400},{8,1},{9,1}},{{2,500},{3,500},{8,1},{9,1}},
	{{2,500},{3,500},{8,1},{9,1}},{{2,500},{3,500},{8,1},{9,1}}
}
-- set reward: quest level -> item level / set index (VNG task_lvl_2_sel_lvl / sel_idx)
PTVT_Q_SETLV = {[2] = 3, [5] = 5, [8] = 7, [10] = 9}
PTVT_Q_SETIDX = {[2] = 1, [5] = 2, [8] = 3, [10] = 4}
PTVT_Q_PART = {2, 5, 6, 7, 9}               -- detail: armor, boot, belt, helm, pendant (item 0, d, type + 6, lv)
PTVT_Q_SETNAME = {
	{"Vũ Khúc", "Tinh Cang", "Khai Thiên", "Chấn Đán"},
	{"Xích Tùng", "Thái Ất", "Thông Thiên", "Hồng Quân"},
	{"Báo Thần", "Giác Thú", "Lam Điêu", "Kháng Long"}
}
PTVT_Q_PARTNAME = {
	{"Giáp", "Chiến Ngoa", "Yêu Đái", "Khôi", "Phi Phong"},
	{"Đạo Bào", "Lý", "Cân", "Quán", "Lệnh"},
	{"Hộ Giáp", "Ngoa", "Yêu Đái", "Trụ", "Kết"}
}
-- quest target names: [2] / [3] by tran bracket (mob templates 53/55/57/59 and 54/56/58/60)
PTVT_Q_MOBNAME = {
	[2] = {{"Thiết Trùng", "sinh lực rất mạnh, hộ giáp Lôi yếu"}, {"Ngọc Nữ", "sinh lực rất mạnh, hộ giáp Thổ yếu"}, {"Lam Cốt", "sinh lực và tấn công cơ bản cao"}, {"Đới Trại", "sinh lực và phòng thủ ma pháp cao"}},
	[3] = {{"Phi Giáp", "sinh lực và tấn công cơ bản cao"}, {"Dã Mao", "sinh lực rất cao, hộ giáp Hỏa yếu"}, {"Ma Nữ", "sinh lực rất mạnh, không dễ phát hiện"}, {"Lục Ngô Thần", "sinh lực và phòng thủ ma pháp cao"}}
}

function PTVT_QSuit()
	local lv = GetLevel()
	if lv > 90 then return 4 end
	if lv > 70 then return 3 end
	if lv > 50 then return 2 end
	return 1
end

function PTVT_QType(state)
	return mod(state or 0, 256)
end

-- text of a quest target (kind 2..9), count included when > 1
function PTVT_QTarget(kind, count)
	local s = "<color=red>"
	if count and count > 1 then s = s .. count .. " " end
	if kind == 2 or kind == 3 then
		local m = PTVT_Q_MOBNAME[kind][PTVT_QSuit()]
		return s .. m[1] .. "<color> (" .. m[2] .. ")"
	end
	if kind >= 4 and kind <= 7 then
		return s .. PTVT_BOSS_NAME[kind - 3] .. "<color> (một trong tứ tiên của Vạn Tiên trận, rất giỏi ma pháp)"
	end
	if kind == 8 then
		return s .. "4 tiên thủ trận<color> (Ô Vân, Cầu Thủ, Linh Nha, Kim Quang Tiên; nên lập đội cùng tác chiến)"
	end
	return s .. PTVT_BOSS_NAME[5] .. "<color> (đứng đầu ma chúng trong Vạn Tiên trận, pháp lực vô biên)"
end

-- 1 = the daily quest of the current player is still valid today; otherwise it is cleared (VNG: expired)
function PTVT_QAlive()
	if GetTask(PTVT_T_QDAY) == PTVT_Today() then return 1 end
	SetTask(PTVT_T_QCOUNT, 0)
	SetTask(PTVT_T_QSTATE, 0)
	Msg2Player("Nhiệm vụ Vạn Tiên trận đã quá hạn, hãy gặp Thiên Hùng nhận nhiệm vụ mới.")
	return nil
end

function PTVT_QFinish(txt)
	SetTask(PTVT_T_QCOUNT, 0)
	SetTask(PTVT_T_QSTATE, PTVT_Q_DONE)
	Msg2Player(txt .. " Hãy về gặp Thiên Hùng (Tây Kỳ) nhận thưởng.")
end

-- kill of a quest mob (kind 2 / 3) for the current player
function PTVT_QMob(kind)
	if GetTask(PTVT_T_QSTATE) ~= kind then return 0 end
	if not PTVT_QAlive() then return 0 end
	local c = GetTask(PTVT_T_QCOUNT)
	if c <= 0 then return 0 end
	c = c - 1
	SetTask(PTVT_T_QCOUNT, c)
	local nm = PTVT_Q_MOBNAME[kind][PTVT_QSuit()][1]
	if c == 0 then
		PTVT_QFinish("Hoàn thành nhiệm vụ diệt " .. nm .. ".")
	else
		Msg2Player("Nhiệm vụ Vạn Tiên trận: còn phải diệt " .. c .. " " .. nm .. ".")
	end
	return 1
end

-- kill of tien k (1..4) for the current player
function PTVT_QTien(k)
	local st = GetTask(PTVT_T_QSTATE)
	local t = PTVT_QType(st)
	if t == k + 3 then
		if not PTVT_QAlive() then return 0 end
		PTVT_QFinish("Hoàn thành nhiệm vụ hạ " .. PTVT_BOSS_NAME[k] .. ".")
		return 1
	end
	if t == 8 and st ~= PTVT_Q_DONE then
		if not PTVT_QAlive() then return 0 end
		local mask = floor(st / 256)
		local b = PTVT_Pow2(k)
		if PTVT_Bit(mask, b) == 0 then mask = mask + b end
		local c = PTVT_CountTien(mask)
		if c >= 4 then
			PTVT_QFinish("Đã hạ đủ 4 tiên thủ trận.")
		else
			SetTask(PTVT_T_QSTATE, 8 + mask * 256)
			Msg2Player("Nhiệm vụ Vạn Tiên trận: đã hạ " .. PTVT_BOSS_NAME[k] .. ", còn " .. (4 - c) .. " tiên thủ trận.")
		end
		return 1
	end
	return 0
end

function PTVT_QTT()
	if GetTask(PTVT_T_QSTATE) ~= 9 then return 0 end
	if not PTVT_QAlive() then return 0 end
	PTVT_QFinish("Đã chiến thắng Thông Thiên Giáo Chủ.")
	return 1
end

-- Dai phu inside the tran: intro (1) and the level 8 "special token" quest (10). 1 = done now.
function PTVT_QDoctor()
	local st = GetTask(PTVT_T_QSTATE)
	if st == 1 then
		SetTask(PTVT_T_QSTATE, PTVT_Q_DONE)
		Msg2Player("Đại phu: Lục Hồn Phiên không có trong Vạn Tiên trận. Hãy về báo cho Thiên Hùng.")
		return 1
	end
	if st == 10 then
		if not PTVT_QAlive() then return 0 end
		SetTask(PTVT_T_QSTATE, PTVT_Q_DONE)
		SetTask(PTVT_T_QPASS, 1)
		Msg2Player("Đại phu: vật tổ trong trận đưa người tới Thần Bí Trận Điểm. Từ nay ta có thể đưa ngươi vào đó không cần lệnh bài. Hãy về báo cho Thiên Hùng.")
		return 1
	end
	return 0
end

-- credit a quest mob kill to the kill owner and his team members standing on the same map
function PTVT_QMobCredit(kind, w)
	local owner = PlayerIndex
	local seen = {}
	if owner and owner > 0 then
		seen[owner] = 1
		PTVT_QMob(kind)
		PlayerIndex = owner
		if GetTeam() then
			local size = GetTeamSize() or 0
			local i = 1
			while i <= size do
				PlayerIndex = owner
				local pi = GetTeamMember(i)
				if pi and pi > 0 and not seen[pi] then
					seen[pi] = 1
					PlayerIndex = pi
					local mw = GetWorldPos()
					if mw == w then PTVT_QMob(kind) end
				end
				i = i + 1
			end
		end
	end
	PlayerIndex = owner
end

-- LastDamage of a tran mob (templates 53..60, spawned by PTVT_InitMission)
function PTVT_MobDeath(ni)
	local tpl = GetNpcTemplateID(ni)
	if not tpl or tpl < 53 or tpl > 60 then return 0 end
	local w = GetNpcWorldPos(ni)
	if not PTVT_MapToN(w) then return 0 end
	local kind = 3
	if mod(tpl, 2) == 1 then kind = 2 end
	PTVT_QMobCredit(kind, w)
	return kind
end
