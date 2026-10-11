-- Phong Than 2026-10-02 (tutuong_a): T\248 T\173\238ng elders (Th\230/H\225a/Phong/Th\241y Tr\173\235ng L\183o, NPC tpl 677-680).
-- VNG schedule (settings\systemtimetask.txt, \script\boss_shua_xin\chang_lao_1..4.lua missing): 00:00/15/30/45 and
-- 12:00/15/30/45, each elder one minute before the ma v\173\172ng that holds it prisoner (wb_data.lua):
--   00:00 Th\230  -> Thi\213t B\232 (Sa M\185c ch\213t 1026)    00:15 Th\241y  -> Kim Tr\185i (Long Uy\170n 1041)
--   00:30 H\225a  -> C\171n B\232i (Hi\170n Vi\170n t\199ng 5 1031) 00:45 Phong -> Lam B\184 (B\168ng Xuy\170n C\249c 1036)
-- The elder stays PTTT_STAY minutes next to the boss spawn point; dialog in tt_elder_1..4.lua.
-- Loaded and ticked once a minute by servertimer.lua: PTTT_Tick().
PTTT_STAY = 60
PTTT_DX = 24
PTTT_DY = 24
PTTT_ELDERS = {
	{ key = "tho", tpl = 677, boss = "thiet_bo", sched = { "00:00", "12:00" }, name = "Th\230 Tr\173\235ng L\183o",
	  gbk = "\205\193\179\164\192\207", script = "\\script\\phongthan\\tutuong\\tt_elder_1.lua" },
	{ key = "thuy", tpl = 680, boss = "kim_trai", sched = { "00:15", "12:15" }, name = "Th\241y Tr\173\235ng L\183o",
	  gbk = "\203\174\179\164\192\207", script = "\\script\\phongthan\\tutuong\\tt_elder_4.lua" },
	{ key = "hoa", tpl = 678, boss = "con_boi", sched = { "00:30", "12:30" }, name = "H\225a Tr\173\235ng L\183o",
	  gbk = "\187\240\179\164\192\207", script = "\\script\\phongthan\\tutuong\\tt_elder_2.lua" },
	{ key = "phong", tpl = 679, boss = "lam_ba", sched = { "00:45", "12:45" }, name = "Phong Tr\173\235ng L\183o",
	  gbk = "\183\231\179\164\192\207", script = "\\script\\phongthan\\tutuong\\tt_elder_3.lua" },
}
PTTT_NPC = PTTT_NPC or {}

function PTTT_Min(hm)
	return tonumber(strsub(hm, 1, 2)) * 60 + tonumber(strsub(hm, 4, 5))
end

function PTTT_Boss(key)
	if not PTWB_LIST then dofile("script\\phongthan\\boss\\wb_data.lua") end
	local k = 1
	while PTWB_LIST[k] do
		if PTWB_LIST[k].key == key then return PTWB_LIST[k] end
		k = k + 1
	end
	return nil
end

-- the elder npc if it is still on its map
function PTTT_Alive(e, b)
	local ni = PTTT_NPC[e.key]
	if ni and ni > 0 then
		local w = GetNpcPos(ni)
		if w == b.map and GetNpcTemplateID(ni) == e.tpl then return ni end
	end
	return nil
end

-- 1 when now (minute of the day) is inside [start, start + PTTT_STAY) of one of the elder's times
function PTTT_InWindow(e, now)
	local k = 1
	while e.sched[k] do
		local d = mod(now - PTTT_Min(e.sched[k]) + 1440, 1440)
		if d < PTTT_STAY then return 1 end
		k = k + 1
	end
	return nil
end

function PTTT_Spawn(e, b)
	local sw = SubWorldID2Idx(b.map)
	if not sw or sw < 0 then return nil end
	local ni = AddNpc(e.tpl, 1, sw, (b.x + PTTT_DX) * 32, (b.y + PTTT_DY) * 32, 0)
	if not ni or ni <= 0 then ni = AddNpc(e.tpl, 1, sw, b.tpx * 32, b.tpy * 32, 0) end
	if not ni or ni <= 0 then return nil end
	SetNpcScript(ni, e.script)
	PTTT_NPC[e.key] = ni
	AddGlobalNews("<color=yellow>" .. e.name .. "<color> \174\183 xu\202t hi\214n t\185i <color=green>" .. b.mapname .. " [" .. b.dx .. "," .. b.dy .. "]<color>: mang Tinh Ph\184ch \174\213n \174\230i l\202y Ng\173ng Ph\184ch, gom 4 lo\185i Ng\173ng Ph\184ch \174\211 h\238p T\248 T\173\238ng Tinh Th\185ch!")
	return ni
end

function PTTT_Tick()
	local k = 1
	if not PTTT_INIT then
		-- server start or servertimer reload: register the dialog scripts and drop untracked copies
		while PTTT_ELDERS[k] do
			local e = PTTT_ELDERS[k]
			ReLoadScript(e.script)
			local b = PTTT_Boss(e.boss)
			if b then ClearMapNpcWithName(b.map, e.gbk) end
			k = k + 1
		end
		PTTT_NPC = {}
		PTTT_INIT = 1
		k = 1
	end
	local now = PTTT_Min(date("%H:%M"))
	while PTTT_ELDERS[k] do
		local e = PTTT_ELDERS[k]
		local b = PTTT_Boss(e.boss)
		if b then
			local ni = PTTT_Alive(e, b)
			if PTTT_InWindow(e, now) then
				if not ni then PTTT_Spawn(e, b) end
			elseif ni then
				DelNpc(ni)
				PTTT_NPC[e.key] = nil
			end
		end
		k = k + 1
	end
end
