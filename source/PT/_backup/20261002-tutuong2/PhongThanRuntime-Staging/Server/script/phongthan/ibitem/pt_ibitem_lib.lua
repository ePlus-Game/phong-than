-- pt_ibitem_lib.lua (Lua 4, ASCII). Phong Than 2026-09-30: ibitem effects the rebuilt engine does
-- not implement (docs\features\vat-pham-ibitem-lo-buff-phong-than-20260929.md). Shared by the item
-- script (pt_ibitem.lua) and the minute tick in servertimer.lua (PTAdm_IbTick).
-- All effects are native attributes applied with ModifyAttrib. The engine recomputes a player's stats
-- (equip change, relog) and wipes them; a +1% experience sentinel, held while any effect is on, makes
-- that visible through GetNpcExpRate(), and PTIB_Refresh() then re-applies.
-- Tasks (unused by VNG): 1906/1907/1908 exp expiry/%/skill x2; 1911/1912 life expiry/rate;
-- 1913/1914 mana expiry/rate; 1909 GetNpcExpRate() after applying; 1917-1920 what is applied now
-- (exp incl. sentinel, skill x2, life, mana).
Include("\\script\\phongthan\\ibitem\\pt_ibitem_data.lua")
PTIB_T_EXP_END = 1906
PTIB_T_EXP_PCT = 1907
PTIB_T_EXP_SKILL = 1908
PTIB_T_SNAP = 1909
PTIB_T_LIFE_END = 1911
PTIB_T_LIFE_RATE = 1912
PTIB_T_MANA_END = 1913
PTIB_T_MANA_RATE = 1914
PTIB_T_A_EXP = 1917
PTIB_T_A_SKILL = 1918
PTIB_T_A_LIFE = 1919
PTIB_T_A_MANA = 1920
PTIB_A_EXP = 181
PTIB_A_SKILLEXP = 187
PTIB_A_LIFE = 88
PTIB_A_MANA = 92

-- generic stat buffs: PTIB_GEN_SLOTS slots of { buff id (PTIB_GEN), expiry }, plus the id applied now
PTIB_GEN_SLOTS = 6
PTIB_T_GEN = 1921      -- 1921/1922, 1923/1924, ... 1931/1932
PTIB_T_GEN_A = 1933    -- 1933..1938

function PTIB_GenAttrs(id, sign)
	local g = PTIB_GEN[id]
	if g == nil then return end
	local i = 2
	while g[i] do
		ModifyAttrib(g[i], sign * g[i + 1], 0, 0, 0)
		i = i + 2
	end
end

-- make the applied generic buffs match the active slots (reset = engine wiped everything)
function PTIB_GenSync(reset)
	local k = 0
	while k < PTIB_GEN_SLOTS do
		local want = 0
		if GetTask(PTIB_T_GEN + 2 * k + 1) > 0 then want = GetTask(PTIB_T_GEN + 2 * k) end
		local have = GetTask(PTIB_T_GEN_A + k)
		if reset == 1 then have = 0 end
		if want ~= have then
			if have ~= 0 then PTIB_GenAttrs(have, -1) end
			if want ~= 0 then PTIB_GenAttrs(want, 1) end
		end
		SetTask(PTIB_T_GEN_A + k, want)
		k = k + 1
	end
end

function PTIB_Expire(tEnd, tVal, msg, now)
	local e = GetTask(tEnd)
	if e > 0 and now >= e then
		SetTask(tEnd, 0)
		if tVal then SetTask(tVal, 0) end
		Msg2Player(msg)
	end
end

function PTIB_Refresh()
	local now = SystemTime()
	PTIB_Expire(PTIB_T_EXP_END, PTIB_T_EXP_PCT, "Hi\214u qu\182 t\168ng kinh nghi\214m \174\183 h\213t.", now)
	if GetTask(PTIB_T_EXP_END) == 0 then SetTask(PTIB_T_EXP_SKILL, 0) end
	PTIB_Expire(PTIB_T_LIFE_END, PTIB_T_LIFE_RATE, "Hi\214u qu\182 h\229i ph\244c sinh l\249c \174\183 h\213t.", now)
	PTIB_Expire(PTIB_T_MANA_END, PTIB_T_MANA_RATE, "Hi\214u qu\182 h\229i ph\244c n\233i l\249c \174\183 h\213t.", now)
	local k = 0
	local genOn = 0
	while k < PTIB_GEN_SLOTS do
		local e = GetTask(PTIB_T_GEN + 2 * k + 1)
		if e > 0 and now >= e then
			SetTask(PTIB_T_GEN + 2 * k, 0)
			SetTask(PTIB_T_GEN + 2 * k + 1, 0)
			Msg2Player("M\233t hi\214u qu\182 v\203t ph\200m \174\183 h\213t.")
		elseif e > 0 then
			genOn = 1
		end
		k = k + 1
	end
	local any = genOn
	if GetTask(PTIB_T_EXP_END) > 0 or GetTask(PTIB_T_LIFE_END) > 0 or GetTask(PTIB_T_MANA_END) > 0 then any = 1 end
	local wExp = GetTask(PTIB_T_EXP_PCT) + any
	local wSkill = GetTask(PTIB_T_EXP_SKILL)
	local wLife = GetTask(PTIB_T_LIFE_RATE)
	local wMana = GetTask(PTIB_T_MANA_RATE)
	local aExp = GetTask(PTIB_T_A_EXP)
	local aSkill = GetTask(PTIB_T_A_SKILL)
	local aLife = GetTask(PTIB_T_A_LIFE)
	local aMana = GetTask(PTIB_T_A_MANA)
	local genApplied = 0
	k = 0
	while k < PTIB_GEN_SLOTS do
		if GetTask(PTIB_T_GEN_A + k) ~= 0 then genApplied = 1 end
		k = k + 1
	end
	local reset = 0
	if (aExp ~= 0 or aSkill ~= 0 or aLife ~= 0 or aMana ~= 0 or genApplied == 1) and (GetNpcExpRate() or 0) ~= GetTask(PTIB_T_SNAP) then
		-- the engine recomputed the stats: nothing of ours is applied any more
		aExp = 0 aSkill = 0 aLife = 0 aMana = 0
		reset = 1
	end
	PTIB_GenSync(reset)
	if aExp == wExp and aSkill == wSkill and aLife == wLife and aMana == wMana then return end
	if aExp ~= 0 then ModifyAttrib(PTIB_A_EXP, -aExp, 0, 0, 0) end
	if aSkill ~= 0 then ModifyAttrib(PTIB_A_SKILLEXP, 0, 0, 0, 0) end
	if aLife ~= 0 then ModifyAttrib(PTIB_A_LIFE, -aLife, 0, 0, 0) end
	if aMana ~= 0 then ModifyAttrib(PTIB_A_MANA, -aMana, 0, 0, 0) end
	if wExp ~= 0 then ModifyAttrib(PTIB_A_EXP, wExp, 0, 0, 0) end
	if wSkill ~= 0 then ModifyAttrib(PTIB_A_SKILLEXP, 100, 0, 0, 0) end
	if wLife ~= 0 then ModifyAttrib(PTIB_A_LIFE, wLife, 0, 0, 0) end
	if wMana ~= 0 then ModifyAttrib(PTIB_A_MANA, wMana, 0, 0, 0) end
	SetTask(PTIB_T_A_EXP, wExp)
	SetTask(PTIB_T_A_SKILL, wSkill)
	SetTask(PTIB_T_A_LIFE, wLife)
	SetTask(PTIB_T_A_MANA, wMana)
	SetTask(PTIB_T_SNAP, GetNpcExpRate() or 0)
end

-- minute tick (servertimer.lua) for each online player
function PTIB_Tick()
	if GetTask(PTIB_T_EXP_END) == 0 and GetTask(PTIB_T_LIFE_END) == 0 and GetTask(PTIB_T_MANA_END) == 0 and
	   GetTask(PTIB_T_A_EXP) == 0 and GetTask(PTIB_T_A_LIFE) == 0 and GetTask(PTIB_T_A_MANA) == 0 and GetTask(PTIB_T_A_SKILL) == 0 then
		local k = 0
		local on = 0
		while k < PTIB_GEN_SLOTS do
			if GetTask(PTIB_T_GEN + 2 * k + 1) > 0 or GetTask(PTIB_T_GEN_A + k) ~= 0 then on = 1 end
			k = k + 1
		end
		if on == 0 then return end
	end
	PTIB_Refresh()
end

function PTIB_TimeText(sec)
	if sec >= 7200 then return floor(sec / 3600) .. " gi\234." end
	return floor(sec / 60) .. " ph\243t."
end
