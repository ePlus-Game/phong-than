-- Phong Than 2026-10-02: Van Tien tran (timed PvE dungeon, 4 tran on the Huyen maps 1079..1082).
-- Shared logic for the mission / timer scripts, Thien Hung, Dai phu, boss and chest scripts and the
-- minute tick. Lua 4. Every script runs in its own Lua state: shared state lives in
-- GlobalValue 400..419 (5 per tran), player tasks 2000..2005 (2006..2013: daily quest, vt_quest.lua)
-- and the engine mission objects.
--   GV base+0 state: 0 closed, 1 preparation, 2 fighting, 3 cleared (Thong Thien killed)
--   GV base+1 kill mask: 1,2,4,8 = the 4 tien, 16 = Thong Thien
--   GV base+2 session key   GV base+3 preparation seconds asked by the opener   GV base+4 chests opened
-- Generated from scratchpad vantien\impl\src (UTF-8) by build.py: text is TCVN3 escapes.
Include("\\script\\phongthan\\vantien\\vt_data.lua")
-- 2026-10-02 (vantien2): Thien Hung daily quest chain (tasks 2006..2013, kill credit helpers)
Include("\\script\\phongthan\\vantien\\vt_quest.lua")

function PTVT_GV(n, k)
	return GetGlobalValue(PTVT_GV0 + (n - 1) * 5 + k)
end

function PTVT_SetGV(n, k, v)
	SetGlobalValue(PTVT_GV0 + (n - 1) * 5 + k, v)
end

function PTVT_Pow2(i)
	local r = 1
	local k = 1
	while k < i do
		r = r * 2
		k = k + 1
	end
	return r
end

function PTVT_Bit(v, b)
	return mod(floor((v or 0) / b), 2)
end

function PTVT_MapToN(m)
	local n = 1
	while n <= 4 do
		if PTVT_MAPS[n] == m then return n end
		n = n + 1
	end
	return nil
end

-- point the SubWorld global of this Lua state at tran n (needed by every mission API)
function PTVT_UseWorld(n)
	local sw = SubWorldID2Idx(PTVT_MAPS[n])
	if sw and sw >= 0 then
		SubWorld = sw
		return sw
	end
	return nil
end

function PTVT_IsOpen(n)
	if not PTVT_UseWorld(n) then return 0 end
	if IsMission(n) == 1 then return 1 end
	return 0
end

function PTVT_Today()
	return tonumber(date("%Y%m%d")) or 0
end

function PTVT_NewKey(n)
	local key = (tonumber(date("%m%d%H%M")) or 0) * 10 + n
	local old = PTVT_GV(n, 2)
	if key <= old then key = old + 10 end
	return key
end

-- mission players that are still flagged available and stand on the tran map (deduplicated)
function PTVT_Inside(n)
	local res = {}
	if not PTVT_UseWorld(n) then return res end
	if IsMission(n) ~= 1 then return res end
	local old = PlayerIndex
	local seen = {}
	local cnt = GetMSPlayerCount(n) or 0
	local i = 1
	while i <= cnt do
		local pi = MSDIdx2PIdx(n, i)
		if pi and pi > 0 and not seen[pi] and GetPMParam(n, i, 0) == 1 then
			PlayerIndex = pi
			local nm = GetName()
			if nm and nm ~= "" then
				local w = GetWorldPos()
				if w == PTVT_MAPS[n] then
					seen[pi] = 1
					tinsert(res, pi)
				end
			end
		end
		i = i + 1
	end
	PlayerIndex = old
	return res
end

-- ------------------------------------------------------------------ player helpers (PlayerIndex set)
function PTVT_ClearTokens()
	local k = 1
	while k <= 4 do
		local d = PTVT_TOKEN[k]
		local guard = 0
		while guard < 60 and HaveNormalItem(3, d, 0, 0) >= 1 do
			DelNormalItem(3, d, 0, 0)
			guard = guard + 1
		end
		k = k + 1
	end
end

function PTVT_ToTown()
	SetFightState(0)
	SetLogoutRV(0)
	SetTask(PTVT_T_INMAP, 0)
	PTVT_ClearTokens()
	NewWorld(PTVT_TOWN[1], PTVT_TOWN[2], PTVT_TOWN[3])
end

function PTVT_Unlocked(n)
	local lv = GetLevel()
	if lv < PTVT_MINLV[1] then return nil end
	if lv >= PTVT_MINLV[n] then return 1 end
	if n > 1 and PTVT_Bit(GetTask(PTVT_T_PROGRESS), PTVT_Pow2(n - 1)) == 1 then return 1 end
	return nil
end

function PTVT_StateText(n)
	local st = 0
	if PTVT_IsOpen(n) == 1 then st = PTVT_GV(n, 0) end
	if st == 1 then return "đang chuẩn bị" end
	if st == 2 then return "đang chiến đấu" end
	if st == 3 then return "đã phá trận" end
	return "chưa mở"
end

-- opens the mission of tran n (InitMission spawns everything); 1 = opened, 2 = already open
function PTVT_Open(n, prep)
	if not PTVT_UseWorld(n) then return 0 end
	if IsMission(n) == 1 then return 2 end
	PTVT_SetGV(n, 3, prep)
	OpenMission(n)
	PTVT_UseWorld(n)
	if IsMission(n) == 1 then return 1 end
	return 0
end

function PTVT_Close(n)
	if not PTVT_UseWorld(n) then return 0 end
	if IsMission(n) == 1 then CloseMission(n) end
	PTVT_SetGV(n, 0, 0)
	return 1
end

-- teleport the current player into tran n and register him in the mission
function PTVT_Join(n)
	local d = PTVT_D[n]
	local pi = PlayerIndex
	PTVT_ClearTokens()
	NewWorld(PTVT_MAPS[n], d.entry[1], d.entry[2])
	PlayerIndex = pi
	local w = GetWorldPos()
	if w ~= PTVT_MAPS[n] then
		Msg2Player("Không thể vào Vạn Tiên trận (" .. PTVT_NAME[n] .. "): bản đồ chưa sẵn sàng.")
		return 0
	end
	PTVT_UseWorld(n)
	AddMSPlayer(n, 1)
	PlayerIndex = pi
	SetLogoutRV(1)
	SetTask(PTVT_T_INMAP, PTVT_MAPS[n])
	SetTask(PTVT_T_SESSION, PTVT_GV(n, 2))
	if PTVT_GV(n, 0) >= 2 then
		SetFightState(1)
		Msg2Player("Đã vào Vạn Tiên trận (" .. PTVT_NAME[n] .. "). Trận đang diễn ra: hạ 4 tiên để gọi Thông Thiên Giáo Chủ!")
	else
		SetFightState(0)
		Msg2Player("Đã vào Vạn Tiên trận (" .. PTVT_NAME[n] .. "). Trận sẽ bắt đầu sau ít giây, hãy chuẩn bị.")
	end
	Msg2MSAll(n, GetName() .. " đã vào Vạn Tiên trận.")
	return 1
end

-- entry request from Thien Hung (or the Dai phu "next tran" option). Solo: opens the tran on demand.
function PTVT_EnterRequest(n)
	if not PTVT_D[n] then return 0 end
	local lv = GetLevel()
	if lv < PTVT_MINLV[1] then
		Msg2Player("Phải đạt cấp " .. PTVT_MINLV[1] .. " mới có thể vào Vạn Tiên trận.")
		return 0
	end
	if not PTVT_Unlocked(n) then
		Msg2Player("Vạn Tiên trận (" .. PTVT_NAME[n] .. ") cần cấp " .. PTVT_MINLV[n] .. " hoặc đã phá Vạn Tiên trận (" .. PTVT_NAME[n - 1] .. ").")
		return 0
	end
	if not PTVT_UseWorld(n) then
		Msg2Player("Bản đồ Vạn Tiên trận (" .. PTVT_NAME[n] .. ") chưa được nạp trên máy chủ.")
		return 0
	end
	local pi = PlayerIndex
	if IsMission(n) == 1 and PTVT_GV(n, 0) == 3 then
		-- already cleared: start a fresh session when nobody is left inside
		local inside = PTVT_Inside(n)
		PlayerIndex = pi
		if getn(inside) == 0 then PTVT_Close(n) end
	end
	PTVT_UseWorld(n)
	if IsMission(n) ~= 1 then
		local r = PTVT_Open(n, PTVT_PREP_DEMAND)
		PlayerIndex = pi
		if r ~= 1 then
			Msg2Player("Không mở được Vạn Tiên trận (" .. PTVT_NAME[n] .. ").")
			return 0
		end
		AddGlobalNews(GetName() .. " đã mở <color=yellow>Vạn Tiên trận (" .. PTVT_NAME[n] .. ")<color> tại Thiên Hùng (Tây Kỳ).")
	end
	PlayerIndex = pi
	return PTVT_Join(n)
end

-- daily reward counter: 1 if this clear of tran n is still rewarded today
function PTVT_TakeDaily(n)
	local today = PTVT_Today()
	if GetTask(PTVT_T_DAY) ~= today then
		SetTask(PTVT_T_DAY, today)
		SetTask(PTVT_T_DAILY, 0)
	end
	local v = GetTask(PTVT_T_DAILY)
	local unit = 1
	local k = 1
	while k < n do
		unit = unit * 10
		k = k + 1
	end
	local c = mod(floor(v / unit), 10)
	if c >= PTVT_DAILY_CAP then return 0 end
	SetTask(PTVT_T_DAILY, v + unit)
	return 1
end

function PTVT_GiveMat(d)
	local idx = AddNormalItem(3, d, 0, 0, 0, 0)
	if idx and idx > 0 then return 1 end
	Msg2Player("Hành trang đầy, không nhận được " .. (PTVT_ITEM_NAME[d] or "vật phẩm") .. ".")
	return 0
end

-- reward of the Thong Thien kill for one participant (PlayerIndex set)
function PTVT_ClearReward(n)
	local prog = GetTask(PTVT_T_PROGRESS)
	local b = PTVT_Pow2(n)
	if PTVT_Bit(prog, b) == 0 then
		SetTask(PTVT_T_PROGRESS, prog + b)
		if n < 4 then
			Msg2Player("Lần đầu phá Vạn Tiên trận (" .. PTVT_NAME[n] .. "): đã mở khóa Vạn Tiên trận (" .. PTVT_NAME[n + 1] .. ").")
		end
	end
	if PTVT_TakeDaily(n) ~= 1 then
		Msg2Player("Hôm nay đã nhận đủ " .. PTVT_DAILY_CAP .. " lượt thưởng Vạn Tiên trận (" .. PTVT_NAME[n] .. "). Bảo rương sẽ không có thưởng cho ngươi.")
		return 0
	end
	SetTask(PTVT_T_ELIG, PTVT_GV(n, 2))
	local exp = PTVT_TT_EXP[n] * GetLevel()
	local money = PTVT_TT_MONEY[n]
	AddOwnExp(exp)
	Earn(money)
	PTVT_GiveMat(PTVT_ELEMENT[n])
	Msg2Player("Hạ Thông Thiên Giáo Chủ: nhận " .. exp .. " kinh nghiệm, " .. money .. " lượng và 1 " .. PTVT_ITEM_NAME[PTVT_ELEMENT[n]] .. ". Hãy đập 4 Bảo rương Thông Thiên!")
	return 1
end

-- reward of one chest for one eligible participant (PlayerIndex set)
function PTVT_ChestReward(n)
	local exp = PTVT_CHEST_EXP[n] * GetLevel()
	local money = PTVT_CHEST_MONEY[n]
	AddOwnExp(exp)
	Earn(money)
	local r = random(1, 100)
	local d = -1
	local k = 1
	while PTVT_CHEST_ROLL[k] do
		if r <= PTVT_CHEST_ROLL[k][1] then
			d = PTVT_CHEST_ROLL[k][2]
			if d == 0 then d = PTVT_ELEMENT[n] end
			break
		end
		k = k + 1
	end
	local txt = "Bảo rương: nhận " .. exp .. " kinh nghiệm, " .. money .. " lượng"
	if d > 0 and PTVT_GiveMat(d) == 1 then
		txt = txt .. " và 1 " .. (PTVT_ITEM_NAME[d] or "vật phẩm")
	end
	Msg2Player(txt .. ".")
	return d
end

-- ------------------------------------------------------------------ NPC spawning (SubWorld set)
function PTVT_AddNpc(tpl, lv, x, y)
	local ni = AddNpc(tpl, lv, SubWorld, x * 32, y * 32, 1)
	if not ni or ni <= 0 then ni = AddNpc(tpl, lv, SubWorld, x * 32, y * 32, 0) end
	if not ni or ni <= 0 then return 0 end
	return ni
end

function PTVT_SpawnBoss(n, tpl, lv, pos)
	local ni = PTVT_AddNpc(tpl, lv, pos[1], pos[2])
	if ni > 0 then
		SetNpcScript(ni, PTVT_BOSS_SCRIPT)
		SetNpcRevTime(ni, PTVT_NOREVIVE)
		AddMSNpc(n, ni, 2)
	end
	return ni
end

function PTVT_SpawnTT(n)
	local d = PTVT_D[n]
	PTVT_UseWorld(n)
	local ni = PTVT_SpawnBoss(n, d.tpl_tt, d.lv_tt, d.tt)
	Msg2MSAll(n, "Thông Thiên Giáo Chủ đã xuất hiện ở Thần Bí Trận Điểm! Mang đủ 4 lệnh bước vào trận nhãn, hoặc nhờ Đại phu đưa vào.")
	return ni
end

function PTVT_SpawnChests(n)
	local d = PTVT_D[n]
	PTVT_UseWorld(n)
	local c = 0
	local k = 1
	while d.chests[k] do
		local ni = PTVT_AddNpc(PTVT_TPL_CHEST, d.lv_chest, d.chests[k][1], d.chests[k][2])
		if ni > 0 then
			SetNpcName(ni, PTVT_CHEST_NAME)
			SetNpcScript(ni, PTVT_CHEST_SCRIPT)
			SetNpcRevTime(ni, PTVT_NOREVIVE)
			AddMSNpc(n, ni, 2)
			c = c + 1
		end
		k = k + 1
	end
	return c
end

-- ------------------------------------------------------------------ mission script entry points
function PTVT_InitMission(n)
	local d = PTVT_D[n]
	local key = PTVT_NewKey(n)
	PTVT_SetGV(n, 0, 1)
	PTVT_SetGV(n, 1, 0)
	PTVT_SetGV(n, 2, key)
	PTVT_SetGV(n, 4, 0)
	local prep = PTVT_GV(n, 3)
	if prep < 5 then prep = PTVT_PREP_DEMAND end
	PTVT_SetGV(n, 3, 0)
	local k = 1
	while k <= 4 do
		PTVT_SpawnBoss(n, d.tpl_tien[k], d.lv_tien, d.tien[k])
		k = k + 1
	end
	k = 1
	while d.mobs[k] do
		local m = d.mobs[k]
		local ni = PTVT_AddNpc(m[3], d.lv_mob, m[1], m[2])
		if ni > 0 then
			SetNpcScript(ni, PTVT_MOB_SCRIPT)   -- LastDamage -> quest kill credit (vt_quest.lua)
			AddMSNpc(n, ni, 2)
		end
		k = k + 1
	end
	k = 1
	while d.doctors[k] do
		local ni = PTVT_AddNpc(PTVT_TPL_DOCTOR, 1, d.doctors[k][1], d.doctors[k][2])
		if ni > 0 then
			SetNpcName(ni, PTVT_DOCTOR_NAME)
			SetNpcScript(ni, PTVT_DOCTOR_SCRIPT)
			AddMSNpc(n, ni, 2)
		end
		k = k + 1
	end
	StartMissionTimer(n, PTVT_TIMER_START + n, prep * 18)
	AddGlobalNews("<color=green>Vạn Tiên trận (" .. PTVT_NAME[n] .. ")<color> đã mở, đến <color=green>Thiên Hùng<color> ở Tây Kỳ để vào trận.")
end

function PTVT_RunMission(n)
	PTVT_SetGV(n, 0, 2)
	local list = PTVT_Inside(n)
	local old = PlayerIndex
	local i = 1
	while list[i] do
		PlayerIndex = list[i]
		SetFightState(1)
		i = i + 1
	end
	PlayerIndex = old
	Msg2MSAll(n, "Trận chiến bắt đầu! Hạ Ô Vân, Cầu Thủ, Linh Nha, Kim Quang Tiên để gọi Thông Thiên Giáo Chủ.")
end

function PTVT_EndMission(n)
	StopMissionTimer(n, PTVT_TIMER_START + n)
	StopMissionTimer(n, PTVT_TIMER_END + n)
	PTVT_SetGV(n, 0, 0)
	-- move every player standing on the map back to Tay Ky (mission players and anyone else)
	local old = PlayerIndex
	local i = 1
	while i <= PTVT_MAX_PLAYER do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" then
			local w = GetWorldPos()
			if w == PTVT_MAPS[n] then
				Msg2Player("Vạn Tiên trận (" .. PTVT_NAME[n] .. ") đã kết thúc.")
				PTVT_ToTown()
			end
		end
		i = i + 1
	end
	PlayerIndex = old
	AddLocalNews("Vạn Tiên trận (" .. PTVT_NAME[n] .. ") đã đóng.")
end

function PTVT_OnLeave(n, pi)
	local old = PlayerIndex
	PlayerIndex = pi
	SetFightState(0)
	PTVT_ClearTokens()
	local idx = PIdx2MSDIdx(n, pi)
	if idx and idx > 0 then SetPMParam(n, idx, 0, 0) end
	local nm = GetName()
	if nm and nm ~= "" then Msg2MSAll(n, nm .. " đã rời Vạn Tiên trận.") end
	PlayerIndex = old
end

function PTVT_OnStartTimer(n, timerId)
	StopMissionTimer(n, PTVT_TIMER_START + n)
	StartMissionTimer(n, PTVT_TIMER_END + n, PTVT_FIGHT * 18)
	RunMission(n)
end

function PTVT_OnEndTimer(n, timerId)
	StopMissionTimer(n, PTVT_TIMER_END + n)
	CloseMission(n)
	PTVT_SetGV(n, 0, 0)
end

-- ------------------------------------------------------------------ kill handlers
function PTVT_FindBoss(tpl)
	local n = 1
	while n <= 4 do
		local d = PTVT_D[n]
		if tpl == d.tpl_tt then return n, 5 end
		local k = 1
		while k <= 4 do
			if d.tpl_tien[k] == tpl then return n, k end
			k = k + 1
		end
		n = n + 1
	end
	return nil, nil
end

function PTVT_CountTien(mask)
	local c = 0
	local k = 1
	while k <= 4 do
		c = c + PTVT_Bit(mask, PTVT_Pow2(k))
		k = k + 1
	end
	return c
end

-- LastDamage of a tien / Thong Thien (PlayerIndex = kill owner). Credit goes to every participant
-- on the map, so a solo player still progresses when a bot or summon lands the last hit.
function PTVT_BossDeath(ni)
	local n, role = PTVT_FindBoss(GetNpcTemplateID(ni))
	if not n then return 0 end
	if not PTVT_UseWorld(n) then return 0 end
	if IsMission(n) ~= 1 or PTVT_GV(n, 0) < 2 then return 0 end
	local mask = PTVT_GV(n, 1)
	local b = PTVT_Pow2(role)
	if PTVT_Bit(mask, b) == 1 then return 0 end
	mask = mask + b
	PTVT_SetGV(n, 1, mask)
	local killer = PlayerIndex
	local list = PTVT_Inside(n)
	local i = 1
	if role <= 4 then
		while list[i] do
			PlayerIndex = list[i]
			if PTVT_GiveMat(PTVT_TOKEN[role]) == 1 then
				Msg2Player("Nhận được " .. PTVT_TOKEN_NAME[role] .. ".")
			end
			PlayerIndex = list[i]
			PTVT_QTien(role)
			i = i + 1
		end
		PlayerIndex = killer
		local c = PTVT_CountTien(mask)
		PTVT_UseWorld(n)
		Msg2MSAll(n, PTVT_BOSS_NAME[role] .. " đã bị hạ (" .. c .. "/4).")
		if c == 4 then PTVT_SpawnTT(n) end
	else
		PTVT_SetGV(n, 0, 3)
		PTVT_SpawnChests(n)
		while list[i] do
			PlayerIndex = list[i]
			PTVT_ClearReward(n)
			PlayerIndex = list[i]
			PTVT_QTT()
			i = i + 1
		end
		PlayerIndex = killer
		local nm = GetName() or ""
		AddGlobalNews("<color=yellow>" .. nm .. "<color> đã phá <color=green>Vạn Tiên trận (" .. PTVT_NAME[n] .. ")<color>, hạ Thông Thiên Giáo Chủ!")
	end
	PlayerIndex = killer
	return role
end

-- LastDamage of a chest: reward every eligible participant once per chest
function PTVT_ChestDeath(ni)
	if GetNpcTemplateID(ni) ~= PTVT_TPL_CHEST then return 0 end
	local w = GetNpcWorldPos(ni)
	local n = PTVT_MapToN(w)
	if not n then return 0 end
	if not PTVT_UseWorld(n) or IsMission(n) ~= 1 then return 0 end
	PTVT_SetGV(n, 4, PTVT_GV(n, 4) + 1)
	local key = PTVT_GV(n, 2)
	local killer = PlayerIndex
	local list = PTVT_Inside(n)
	local got = 0
	local i = 1
	while list[i] do
		PlayerIndex = list[i]
		if GetTask(PTVT_T_ELIG) == key then
			PTVT_ChestReward(n)
			got = got + 1
		else
			Msg2Player("Bảo rương không có phần thưởng cho ngươi (chưa hạ Thông Thiên lượt này hoặc đã đủ lượt hôm nay).")
		end
		i = i + 1
	end
	PlayerIndex = killer
	return got
end

-- ------------------------------------------------------------------ Dai phu helpers
function PTVT_RestSeconds(n)
	if not PTVT_UseWorld(n) or IsMission(n) ~= 1 then return 0 end
	local st = PTVT_GV(n, 0)
	local t = 0
	if st == 1 then t = GetMSRestTime(n, PTVT_TIMER_START + n) else t = GetMSRestTime(n, PTVT_TIMER_END + n) end
	return floor((t or 0) / 18)
end
