-- Phong Than 2026-10-03 (botparty): auto party with fake-player bots ("to doi bot"), VNG style.
-- Generated from scratchpad\botparty\src\party.lua by gen.py: strings shown to players are TCVN3 bytes written
-- as \ddd escapes, keep this file ASCII. Doc: docs\features\to-doi-bot-phong-than-20261003.md
--
-- Loaded by bots.lua (Include, servertimer state + the registered OnTimer state) and by party_npc.lua.
-- While a player stands on a map with monsters (PTBP_MAPS), up to N bots (default 4, VNG team max 8 with the
-- player) join him: AddTotemNpc = owner + AiMode 11 (KNpcAI::ProcessAIType11: follows the owner, attacks the
-- owner's target or the nearest enemy, removed by the engine when the owner changes map / dies / hides / logs
-- out). Name "[To doi] <roster name>", level = player level +-2, camp 0 (only monsters are enemies).
--
-- EXP: KNpc::CalcDamage already books every hit of an owned AiMode-11 NPC on its owner (KNpc.cpp
-- "if (Npc[nAttacker].m_nOwnerIdx && Npc[nAttacker].m_AiMode == 11) nAttacker = owner"), so a kill by a party bot
-- is a kill by the player (EXP, drops, quest LastDamage). No Lua credit is added here: it would count twice.
-- Party bonus (VNG +15% per member in range): SetPartyBotBonus(pct) from the botparty C++ patch
-- (scratchpad\botparty\cpp_patch.md); without it the bots still fight for the player, only the bonus is missing.
--
-- Player task variables (range 2070-2079 of agent bots, unused in loose and PAK scripts):
--   2070 mode   0 = server setting (on), 1 = on, 2 = off (menu "Ho Tro To Doi" in the newbie towns)
--   2071 count  0 = server setting, 1..7
--   2072..2078  npc index of party bot 1..7 (checked: template 2703-2720, name tag, GetNpcOwner == player)
-- Lua 4: no true/false, no local function, no string.*/table.*; one small statement per data record.

PTBP_T_MODE = 2070
PTBP_T_COUNT = 2071
PTBP_T_SLOT = 2072
PTBP_MAX = 7                -- VNG team = 8 with the player
PTBP_MAX_TOTAL = 160        -- party bots on the whole server
PTBP_DEF_COUNT = 4
PTBP_DEF_BONUS = 15         -- % EXP per party bot in range (KPlayer k = 100 + 15 * (members - 1))
PTBP_RANGE = 24             -- cells = PLAYER_SHARE_EXP_DISTANCE 768 mps / 32
PTBP_LOST = 34              -- cells: beyond the AI-11 leash (900 mps) for a whole minute = stuck or a corpse
PTBP_TPL_MIN = 2703
PTBP_TPL_MAX = 2720
PTBP_KIND = 4               -- SetNpcParam(npc, 1): chat lines PTBOT_LINES[4] of bots.lua
PTBP_TIMER_SCRIPT = "\\script\\phongthan\\bots\\bots.lua"
PTBP_NPC_SCRIPT = "\\script\\phongthan\\bots\\party_npc.lua"
PTBP_TAG = "[Tổ đội] "
PTBP_NPC_NAME = "Hỗ Trợ Tổ Đội"
PTBP_NPC_TPL = 211

-- names / templates (roster of bots.lua, one statement per record)
PTBP_N = {}
PTBP_N[1] = { "Thi\170nLong", 2705 }
PTBP_N[2] = { "H\190cPhong", 2716 }
PTBP_N[3] = { "MinhNguy\214t", 2714 }
PTBP_N[4] = { "HoaR\172i", 2706 }
PTBP_N[5] = { "Ng\228cLan", 2719 }
PTBP_N[6] = { "LongV\173\172ng", 2711 }
PTBP_N[7] = { "B\184\167ao", 2704 }
PTBP_N[8] = { "V\171Danh", 2715 }
PTBP_N[9] = { "PhongV\169n", 2710 }
PTBP_N[10] = { "Xu\169nH\185", 2718 }
PTBP_N[11] = { "LyLy", 2712 }
PTBP_N[12] = { "NhuM\215", 2720 }
PTBP_N[13] = { "Ti\211uLong", 2707 }
PTBP_N[14] = { "Ki\213mKh\184ch", 2709 }
PTBP_N[15] = { "Kh\171iNguy\170n", 2703 }
PTBP_N[16] = { "Tuy\213tS\172n", 2713 }
PTBP_N[17] = { "Thi\170nH\185", 2708 }
PTBP_N[18] = { "LongH\230", 2717 }

-- spawn offsets around the player (cells), one per party slot
PTBP_OFF = {}
PTBP_OFF[1] = { 2, 1 }
PTBP_OFF[2] = { -2, 1 }
PTBP_OFF[3] = { 1, -2 }
PTBP_OFF[4] = { -1, 2 }
PTBP_OFF[5] = { 3, -1 }
PTBP_OFF[6] = { -3, -1 }
PTBP_OFF[7] = { 0, 3 }

-- maps with monsters (runtime ids): generated populations script\phongthan\spawn\spawn_<map>.lua + the VNG
-- Region_S monster maps 1014 / 1016. Towns (1002-1004, 1020, 1021) and the arena 1001 are not listed.
PTBP_MAPS = {}
PTBP_MAPS[1005] = 1 PTBP_MAPS[1006] = 1 PTBP_MAPS[1007] = 1 PTBP_MAPS[1008] = 1
PTBP_MAPS[1009] = 1 PTBP_MAPS[1010] = 1 PTBP_MAPS[1011] = 1 PTBP_MAPS[1012] = 1
PTBP_MAPS[1013] = 1 PTBP_MAPS[1014] = 1 PTBP_MAPS[1015] = 1 PTBP_MAPS[1016] = 1
PTBP_MAPS[1017] = 1 PTBP_MAPS[1018] = 1 PTBP_MAPS[1019] = 1 PTBP_MAPS[1022] = 1
PTBP_MAPS[1023] = 1 PTBP_MAPS[1024] = 1 PTBP_MAPS[1025] = 1 PTBP_MAPS[1026] = 1
PTBP_MAPS[1027] = 1 PTBP_MAPS[1028] = 1 PTBP_MAPS[1029] = 1 PTBP_MAPS[1030] = 1
PTBP_MAPS[1031] = 1 PTBP_MAPS[1032] = 1 PTBP_MAPS[1033] = 1 PTBP_MAPS[1034] = 1
PTBP_MAPS[1035] = 1 PTBP_MAPS[1036] = 1 PTBP_MAPS[1037] = 1 PTBP_MAPS[1038] = 1
PTBP_MAPS[1039] = 1 PTBP_MAPS[1040] = 1 PTBP_MAPS[1041] = 1 PTBP_MAPS[1042] = 1
PTBP_MAPS[1043] = 1 PTBP_MAPS[1044] = 1 PTBP_MAPS[1045] = 1 PTBP_MAPS[1046] = 1
PTBP_MAPS[1047] = 1 PTBP_MAPS[1048] = 1 PTBP_MAPS[1049] = 1 PTBP_MAPS[1050] = 1
PTBP_MAPS[1051] = 1 PTBP_MAPS[1053] = 1 PTBP_MAPS[1054] = 1 PTBP_MAPS[1055] = 1
PTBP_MAPS[1056] = 1 PTBP_MAPS[1065] = 1 PTBP_MAPS[1072] = 1 PTBP_MAPS[1073] = 1
PTBP_MAPS[1074] = 1 PTBP_MAPS[1075] = 1 PTBP_MAPS[1076] = 1 PTBP_MAPS[1077] = 1
PTBP_MAPS[1078] = 1

-- "Ho Tro To Doi" dialog NPC (toggle / count), next to the Quan Su (Tan thu) of the 3 newbie towns
-- { map, template, cell x, cell y }; town grids have no Region_S obstacle there
PTBP_NPCS = {}
PTBP_NPCS[1] = { 1002, PTBP_NPC_TPL, 1635, 3203 }
PTBP_NPCS[2] = { 1003, PTBP_NPC_TPL, 1691, 3123 }
PTBP_NPCS[3] = { 1004, PTBP_NPC_TPL, 1563, 3219 }

PTBP_TXT_HEAD = "<color=yellow>[Tổ đội]<color> "
PTBP_TXT_JOIN = " đồng đội bot đã vào tổ đội, cùng bạn đánh quái."
PTBP_TXT_BONUS = " Kinh nghiệm tổ đội: +"
PTBP_TXT_NOBONUS = " (Máy chủ chưa cài bản cộng thêm kinh nghiệm tổ đội.)"

function PTBP_IsField(w)
	if not w or w <= 0 then return nil end
	if PTBP_MAPS[w] then return 1 end
	return nil
end

-- number of party bots the current player (PlayerIndex) should have now
function PTBP_Want(cfg)
	if type(cfg) ~= "table" or cfg.enabled ~= 1 or cfg.party ~= 1 then return 0 end
	if GetTask(PTBP_T_MODE) == 2 then return 0 end
	local w = GetWorldPos()
	if not PTBP_IsField(w) then return 0 end
	if GetTeamSize and GetTeamSize() > 1 then return 0 end
	if IsPlayerInDeath and IsPlayerInDeath() == 1 then return 0 end
	local n = GetTask(PTBP_T_COUNT)
	if not n or n <= 0 then n = cfg.partyCount or PTBP_DEF_COUNT end
	if n > PTBP_MAX then n = PTBP_MAX end
	if n < 0 then n = 0 end
	return n
end

function PTBP_Valid(ni, pname)
	if not ni or ni <= 0 then return nil end
	local id = GetNpcID(ni)
	if not id or id == 0 then return nil end
	local t = GetNpcTemplateID(ni)
	if not t or t < PTBP_TPL_MIN or t > PTBP_TPL_MAX then return nil end
	local nm = GetNpcName(ni)
	if type(nm) ~= "string" or strsub(nm, 1, strlen(PTBP_TAG)) ~= PTBP_TAG then return nil end
	if GetNpcOwner(ni) ~= pname then return nil end
	return 1
end

-- dead bot (AiMode 11 has no revive: without the C++ patch the corpse stays). GetNpcEnmityItem returns the
-- last attacker and damage = life max - current life; damage >= life max means current life <= 0.
function PTBP_Dead(ni)
	if not GetNpcEnmityItem then return nil end
	local a, aid, dmg = GetNpcEnmityItem(ni, 0)
	local mx = GetNpcLife(ni)
	if a and a > 0 and dmg and mx and mx > 0 and dmg >= mx then return 1 end
	return nil
end

function PTBP_Dist2(ni, w, x, y)
	local nw, nx, ny = GetNpcPos(ni)
	if nw ~= w or not nx then return 999999 end
	local dx = nx - x
	local dy = ny - y
	return dx * dx + dy * dy
end

-- tracked bot of slot j: 0 when the slot is empty, invalid, not wanted, dead or lost
function PTBP_Check(j, pname, w, x, y, want, seen)
	local var = PTBP_T_SLOT + j - 1
	local ni = GetTask(var)
	if not ni or ni <= 0 then return 0 end
	if seen[ni] or not PTBP_Valid(ni, pname) then
		SetTask(var, 0)
		return 0
	end
	if j > want or PTBP_Dead(ni) or PTBP_Dist2(ni, w, x, y) > PTBP_LOST * PTBP_LOST then
		DelNpc(ni)
		SetTask(var, 0)
		return 0
	end
	return ni
end

function PTBP_Spawn(j, w, x, y, lv, pi)
	local sw = SubWorldID2Idx(w)
	if not sw or sw < 0 then return 0 end
	local e = PTBP_N[mod(pi * 3 + j - 1, getn(PTBP_N)) + 1]
	local o = PTBP_OFF[j]
	local l = lv + random(-2, 2)
	if l < 1 then l = 1 end
	local ni = AddTotemNpc(e[2], l, sw, (x + o[1]) * 32 + 16, (y + o[2]) * 32 + 16)
	if not ni or ni <= 0 then return 0 end
	SetNpcName(ni, PTBP_TAG .. e[1])
	if SetNpcCamp then SetNpcCamp(ni, 0) end
	SetNpcCurCamp(ni, 0)
	SetNpcParam(ni, 1, PTBP_KIND)
	SetNpcParam(ni, 2, 0)
	SetNpcTimer(ni, PTBP_TIMER_SCRIPT, random(20, 60))
	return ni
end

function PTBP_Notice(n, pct)
	local s = PTBP_TXT_HEAD .. n .. PTBP_TXT_JOIN
	if SetPartyBotBonus then
		s = s .. PTBP_TXT_BONUS .. pct .. "%."
	else
		s = s .. PTBP_TXT_NOBONUS
	end
	Msg2Player(s)
end

-- one player (PlayerIndex = pi): drop invalid / dead / lost / extra bots, spawn the missing ones, set the bonus
function PTBP_Player(cfg, pi, pname, st)
	local want = PTBP_Want(cfg)
	if want > 0 and st.alive + want > PTBP_MAX_TOTAL then want = 0 end
	local w, x, y = GetWorldPos()
	local lv = GetLevel() or 1
	local alive = 0
	local near = 0
	local made = 0
	local seen = {}
	local j = 1
	while j <= PTBP_MAX do
		local ni = PTBP_Check(j, pname, w, x, y, want, seen)
		if ni == 0 and j <= want then
			ni = PTBP_Spawn(j, w, x, y, lv, pi)
			if ni > 0 then
				SetTask(PTBP_T_SLOT + j - 1, ni)
				made = made + 1
			end
		end
		if ni > 0 then
			seen[ni] = 1
			alive = alive + 1
			if PTBP_Dist2(ni, w, x, y) <= PTBP_RANGE * PTBP_RANGE then near = near + 1 end
		end
		j = j + 1
	end
	local pct = near * (cfg.partyBonus or 0)
	if want == 0 then pct = 0 end
	if SetPartyBotBonus then SetPartyBotBonus(pct) end
	if alive > 0 then st.players = st.players + 1 end
	st.alive = st.alive + alive
	st.made = st.made + made
	if made > 0 and alive == made then PTBP_Notice(alive, pct) end
	return alive
end

-- remove every party bot of the current player (menu "Tat to doi bot")
function PTBP_DismissAll()
	local pname = GetName()
	local n = 0
	local j = 1
	while j <= PTBP_MAX do
		local var = PTBP_T_SLOT + j - 1
		local ni = GetTask(var)
		if ni and ni > 0 then
			if PTBP_Valid(ni, pname) then
				DelNpc(ni)
				n = n + 1
			end
			SetTask(var, 0)
		end
		j = j + 1
	end
	if SetPartyBotBonus then SetPartyBotBonus(0) end
	return n
end

-- first party tick of a servertimer state (also after a hot reload): register the menu script and refresh the
-- registered bots.lua (OnTimer chat lines of the party bots)
function PTBP_Register()
	if PTBOT_S.partyReg then return end
	ReLoadScript(PTBP_NPC_SCRIPT)
	ReLoadScript(PTBP_TIMER_SCRIPT)
	PTBOT_S.partyReg = 1
end

function PTBP_EnsureNpcs()
	local S = PTBOT_S
	if not S.pnpc then S.pnpc = {} end
	local k = 1
	while PTBP_NPCS[k] do
		local s = PTBP_NPCS[k]
		local ni = S.pnpc[k]
		if not (ni and ni > 0 and GetNpcID(ni) ~= 0 and GetNpcTemplateID(ni) == s[2] and GetNpcName(ni) == PTBP_NPC_NAME) then
			local sw = SubWorldID2Idx(s[1])
			if sw and sw >= 0 then
				ni = AddNpc(s[2], 1, sw, s[3] * 32, s[4] * 32, 0)
				if ni and ni > 0 then
					SetNpcName(ni, PTBP_NPC_NAME)
					SetNpcScript(ni, PTBP_NPC_SCRIPT)
					S.pnpc[k] = ni
				end
			end
		end
		k = k + 1
	end
end

-- called once per minute from PTBOT_Tick (servertimer state) and by PTBOT_AdminApply
function PTBP_Tick(cfg)
	local S = PTBOT_S
	local st = { players = 0, alive = 0, made = 0 }
	S.partySt = st
	PTBP_Register()
	PTBP_EnsureNpcs()
	if not AddTotemNpc then return 0 end
	local maxp = PTADM_MAX_PLAYER or 1200
	local oldPI = PlayerIndex
	local i = 1
	while i <= maxp do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" then PTBP_Player(cfg, i, nm, st) end
		i = i + 1
	end
	PlayerIndex = oldPI
	return st.alive
end
