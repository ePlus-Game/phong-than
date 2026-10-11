-- bot9x 2026-10-04 (from sim_dinhanbot.lua by bot9x\make_sim.py, section 15). Simulator test for the 2026-10-03 bot party (agent botparty): script\phongthan\bots\party.lua + bots.lua hooks
-- + party_npc.lua menu. Run: run.ps1 -Main sim_botparty.lua -Stack 100        (plain, engine stack size)
--                            run.ps1 -Main sim_botparty.lua -Stack 0 -Args1 emu (engine headroom emulation:
--   every tick entry padded to 40 free frames like the servertimer chain, menu entries to 47 like an NPC call)
dofile("sim.lua")
-- dinhanbot: party.lua under test (default: the new generated file; SIM_ARG "rt" = runtime copy)
PARTY_FILE = "C:\\Users\\LICHNT~1.OFF\\AppData\\Local\\Temp\\claude\\D--Project-Email-Send\\d0824b0a-6cac-412d-8946-ef7c47e9c425\\scratchpad\\botparty\\out\\party.lua"
if SIM_ARG and strfind(SIM_ARG, "rt", 1, 1) then PARTY_FILE = SRV .. "\\script\\phongthan\\bots\\party.lua" end
INC0 = Include
function Include(p) if strfind(p, "party.lua", 1, 1) then dofile(PARTY_FILE) else INC0(p) end end
OUT = "out_bot9x.txt"
EMU = nil
T_TICK, T_NPC = 40, 47
if SIM_ARG and strfind(SIM_ARG, "emu", 1, 1) then
	EMU = 1 OUT = "out_bot9x_emu.txt"
	-- optional "emu,<tick frames>,<npc frames>" to probe the stack margin
	local c = strfind(SIM_ARG, ",", 1, 1)
	if c then
		local c2 = strfind(SIM_ARG, ",", c + 1, 1)
		T_TICK = tonumber(strsub(SIM_ARG, c + 1, c2 - 1)) T_NPC = tonumber(strsub(SIM_ARG, c2 + 1))
		OUT = "out_bot9x_emu_" .. T_TICK .. "_" .. T_NPC .. ".txt"
	end
end
writeto(OUT)

-- ------------------------------------------------------------ headroom emulation (sim_nb2emu technique)
function HR_R(d) HR_MAX = d HR_R(d + 1) end
function HR_NOP() end
function Headroom()
	HR_MAX = 0
	local old = _ERRORMESSAGE
	call(HR_R, { 0 }, "x", HR_NOP)
	_ERRORMESSAGE = old
	return HR_MAX
end
EMU_MIN = {}
-- with run.ps1 -Db: function names / lines of the failing call chain
function EMU_TB()
	if getinfo == nil then return "" end
	local s, lv = "", 2
	while lv < 40 do
		local i = getinfo(lv, "Sln")
		if i == nil or i.name == "EMU_PAD" then break end
		s = s .. " < " .. tostring(i.name) .. ":" .. tostring(i.currentline)
		lv = lv + 1
	end
	return s
end
function EMU_PAD(target, f, a1, a2)
	if Headroom() > target then return EMU_PAD(target, f, a1, a2) end
	EMU_H = Headroom()
	return f(a1, a2)
end
-- protected call of an entry point, padded when EMU
function RUN(label, target, f, a1, a2)
	SIM_ERR = nil
	local r = nil
	if EMU then
		call(function() R_RET = EMU_PAD(%target, %f, %a1, %a2) end, {}, "x", function(m) SIM_ERR = m .. EMU_TB() end)
		if EMU_H and (EMU_MIN[label] == nil or EMU_H < EMU_MIN[label]) then EMU_MIN[label] = EMU_H end
	else
		call(function() R_RET = %f(%a1, %a2) end, {}, "x", function(m) SIM_ERR = m end)
	end
	if SIM_ERR then FAILN = FAILN + 1 write("  ERR [" .. label .. "] " .. SIM_ERR .. "\n") end
	return R_RET
end

SEED = 4242
function random(a, b)
	SEED = mod(SEED * 1103515245 + 12345, 2147483648)
	if a == nil then return SEED / 2147483648 end
	if b == nil then b = a a = 1 end
	return a + mod(floor(SEED / 65536), b - a + 1)
end
SIM_MIN = 9 * 60
function date(fmt)
	local h = mod(floor(SIM_MIN / 60), 24)
	local m = mod(SIM_MIN, 60)
	local hs = h .. "" if h < 10 then hs = "0" .. h end
	local ms = m .. "" if m < 10 then ms = "0" .. m end
	if fmt == "%H" then return hs end
	if fmt == "%M" then return ms end
	return "2026-10-03 " .. hs .. ":" .. ms .. ":00"
end

-- ------------------------------------------------------------ world
LOADED = {}
local ml = { 1002, 1003, 1004, 1020, 1021, 1005, 1006, 1007, 1008, 1011, 1012, 1015, 1017, 1018, 1065, 1022, 1024, 1027, 1019, 1016 }
SW2MAP = {}
for i = 1, getn(ml) do LOADED[ml[i]] = 1 SW2MAP[ml[i] + 100] = ml[i] end
function SubWorldID2Idx(m) if LOADED[m] then return m + 100 end return -1 end

NPC = {} FREE = {} NFREE = 0 NEXTIDX = 100 NEXTID = 5000
ADDS, DELS = 0, 0
function NewNpc(tpl, lv, sw, x, y)
	local i
	if NFREE > 0 then i = FREE[NFREE] FREE[NFREE] = nil NFREE = NFREE - 1 else i = NEXTIDX NEXTIDX = NEXTIDX + 1 end
	NEXTID = NEXTID + 1
	-- field by field: a 16-field constructor alone would take ~32 stack slots (Lua 4), more than the C engine call
	local n = {}
	n.id = NEXTID n.tpl = tpl n.lv = lv n.map = SW2MAP[sw] n.x = x n.y = y n.name = "TPL" .. tpl n.par = {}
	n.camp = 5 n.owner = "" n.ai = 1 n.life = 1000 n.cur = 1000 n.att = 0
	NPC[i] = n
	ADDS = ADDS + 1
	return i
end
function AddNpc(tpl, lv, sw, x, y, bar)
	if not SW2MAP[sw] then return 0 end
	if bar == 1 and mod(floor(x / 32) + floor(y / 32), 7) == 0 then return 0 end
	return NewNpc(tpl, lv, sw, x, y)
end
-- engine: owner = current player, AiMode 11, owner's camp
function AddTotemNpc(tpl, lv, sw, x, y)
	if not SW2MAP[sw] then return 0 end
	local p = PLAYERS[PlayerIndex]
	if not p then return 0 end
	local i = NewNpc(tpl, lv, sw, x, y)
	NPC[i].owner = p.name
	NPC[i].ai = 11
	NPC[i].camp = p.camp or 1
	NPC[i].ccamp = p.camp or 1
	TOTEMS = TOTEMS + 1
	return i
end
TOTEMS = 0
function DelNpc(i)
	local n = NPC[i]
	if not n or n.id == 0 then SIM_flag("DELNPC_ON_FREE_SLOT " .. i) return end
	n.id = 0 n.name = "" n.owner = ""
	NFREE = NFREE + 1 FREE[NFREE] = i
	DELS = DELS + 1
end
function GetNpcID(i) if i >= 48000 then return nil end local n = NPC[i] if n then return n.id end return 0 end
function GetNpcTemplateID(i) local n = NPC[i] if n then return n.tpl end return 0 end
function GetNpcSettingIdx(i) return GetNpcTemplateID(i) end
function GetNpcName(i) local n = NPC[i] if n then return n.name end return "" end
function SetNpcName(i, s) NPC[i].name = s end
function GetNpcOwner(i) if not PlayerIndex or PlayerIndex <= 0 then return nil end local n = NPC[i] if n then return n.owner end return "" end
function GetNpcPos(i) local n = NPC[i] if n and n.id ~= 0 then return n.map, floor(n.x / 32), floor(n.y / 32) end return 0, 0, 0 end
function SetNpcParam(i, k, v) NPC[i].par[k] = v end
function GetNpcParam(i, k) local n = NPC[i] if n then return n.par[k] or 0 end return 0 end
function SetNpcCamp(i, c) NPC[i].camp = c return 1 end
function SetNpcCurCamp(i, c) NPC[i].ccamp = c end

-- dinhanbot mocks (C++ PhongThanBotPet.h + SetNpcSkill)
SKCALLS = 0
function GetNpcLevel(i) local n = NPC[i] if n and n.id ~= 0 then return n.lv end return 0 end
function SetNpcSkill(i, id, lv, pos) SKCALLS = SKCALLS + 1 local n = NPC[i] if not n then return 0 end if not n.sk then n.sk = {} end n.sk[pos] = { id, lv } return 1 end
PETS_MADE = 0
function AddNpcPet(owner, tpl, nl, pl)
	local o = NPC[owner]
	if not o or o.id == 0 or o.cur <= 0 then return 0 end
	if o.pet and NPC[o.pet] and NPC[o.pet].id ~= 0 and NPC[o.pet].ownerNpc == owner then DelNpc(o.pet) end
	local i = NewNpc(tpl, nl, SubWorldID2Idx(o.map), o.x + 1, o.y + 1)
	local p = NPC[i]
	p.ai = 11 p.ownerNpc = owner p.ownerId = o.id p.owner = o.name p.pl = pl p.camp = o.camp p.ccamp = o.ccamp
	o.pet = i
	PETS_MADE = PETS_MADE + 1
	return i
end
function GetNpcPetIdx(owner)
	local o = NPC[owner]
	if not o or o.id == 0 then return 0 end
	local p = o.pet
	if not p or p <= 0 or not NPC[p] or NPC[p].id == 0 or NPC[p].ownerNpc ~= owner or NPC[p].ai ~= 11 then return 0 end
	return p
end
function GetNpcLife(i) local n = NPC[i] if n then return n.life end return 0 end   -- engine: life MAX
-- engine: attacker, attacker id, damage = life max - current life (attacker must be a live npc)
function GetNpcEnmityItem(i, k)
	local n = NPC[i]
	if not n or n.id == 0 then return 0, 0, 0 end
	local a = n.att
	if not a or a <= 0 or not NPC[a] or NPC[a].id == 0 then return 0, 0, 0 end
	local d = n.life - n.cur
	if d < 0 then d = 0 end
	return a, NPC[a].id, d
end
SCRIPTS = {}
function SetNpcScript(i, s) NPC[i].script = s end
TIMERS = {}
function SetNpcTimer(i, s, sec) if s ~= "\\script\\phongthan\\bots\\bots.lua" then SIM_flag("BAD_TIMER_SCRIPT " .. s) end TIMERS[i] = sec end
CHATS = {}
function NpcChat(i, s) tinsert(CHATS, NPC[i].name .. " > " .. s) end
WORLD = {}
function Msg2SubWorld(s) tinsert(WORLD, s) end
RELOADS = {}
function ReLoadScript(p) RELOADS[p] = (RELOADS[p] or 0) + 1 return 1 end

-- players (cells); per-player task variables
PLAYERS = {
	[3] = { name = "Lichnt", map = 1015, x = 1650, y = 3100, lv = 50, team = 1, dead = 0, camp = 1, task = {}, msg = {} },
	[7] = { name = "KhachQua", map = 1002, x = 1700, y = 3200, lv = 70, team = 1, dead = 0, camp = 2, task = {}, msg = {} },
}
PTADM_MAX_PLAYER = 20
function GetName() local p = PLAYERS[PlayerIndex] if p then return p.name end return "" end
function GetWorldPos() local p = PLAYERS[PlayerIndex] if p then return p.map, p.x, p.y end return 0, 0, 0 end
function GetLevel() local p = PLAYERS[PlayerIndex] if p then return p.lv end return 1 end
function GetTeamSize() local p = PLAYERS[PlayerIndex] if p then return p.team end return 0 end
function IsPlayerInDeath() local p = PLAYERS[PlayerIndex] if p then return p.dead end return 0 end
function GetTask(i) local p = PLAYERS[PlayerIndex] if p then return p.task[i] or 0 end return 0 end
function SetTask(i, v) local p = PLAYERS[PlayerIndex] if p then p.task[i] = v end end
function Msg2Player(s) local p = PLAYERS[PlayerIndex] if p then tinsert(p.msg, s) end end
BONUS = {}
function SetPartyBotBonus(pct) local p = PLAYERS[PlayerIndex] if p then BONUS[p.name] = pct end return 1 end
function GetPartyBotBonus() local p = PLAYERS[PlayerIndex] if p then return BONUS[p.name] or 0 end return 0 end

PTADM_DIR = "botparty_bridge\\"
CFG = PTADM_DIR .. "bots_config.lua"
STATUS = PTADM_DIR .. "bots.txt"
remove(CFG) remove(STATUS)
function writecfg(s) local h = openfile(CFG, "w") write(h, s) closefile(h) end
function readstatus()
	local r = {}
	readfrom(STATUS)
	local l = read("*l")
	while l do tinsert(r, l) l = read("*l") end
	readfrom()
	return r
end

PASS, FAILN = 0, 0
function check(c, m) if c then PASS = PASS + 1 write("  ok " .. m .. "\n") else FAILN = FAILN + 1 write("  FAIL " .. m .. "\n") end end

dofile(SRV .. "\\script\\phongthan\\boss\\wb_data.lua")
SIM_LOADERR = nil
call(dofile, { SRV .. "\\script\\phongthan\\bots\\bots.lua" }, "x", function(m) SIM_LOADERR = m end)
check(SIM_LOADERR == nil, "bots.lua + party.lua load " .. tostring(SIM_LOADERR))

-- party bots of a player (by the task slots), validated like the script does
function party(pi)
	local p = PLAYERS[pi]
	local r = { n = 0, bad = 0, far = 0, lvbad = 0, camp = 0, ai = 0, list = {} }
	local j = 0
	while j < 7 do
		local ni = p.task[2072 + j] or 0
		if ni > 0 then
			local n = NPC[ni]
			if n.id == 0 or n.owner ~= p.name or n.tpl < 2703 or n.tpl > 2720 or strsub(n.name, 1, strlen(PTBP_TAG)) ~= PTBP_TAG then
				r.bad = r.bad + 1
			else
				r.n = r.n + 1
				tinsert(r.list, ni)
				local dx = floor(n.x / 32) - p.x
				local dy = floor(n.y / 32) - p.y
				if n.map ~= p.map or dx * dx + dy * dy > 24 * 24 then r.far = r.far + 1 end
				if n.lv < p.lv - 2 or n.lv > p.lv + 2 then r.lvbad = r.lvbad + 1 end
				if n.camp ~= 0 or n.ccamp ~= 0 then r.camp = r.camp + 1 end
				if n.ai ~= 11 then r.ai = r.ai + 1 end
			end
		end
		j = j + 1
	end
	return r
end
-- every live party-tagged npc in the world (catches leaks / double spawns)
function worldparty()
	local n = 0
	for i, v in NPC do if v.id ~= 0 and strsub(v.name or "", 1, strlen(PTBP_TAG)) == PTBP_TAG then n = n + 1 end end
	return n
end
function freenear(pi, r)
	local p = PLAYERS[pi]
	local n = 0
	local k = 1
	while PTBOT_S.bots[k] do
		local b = PTBOT_S.bots[k]
		if PTBot_Alive(b) then
			local w, x, y = GetNpcPos(b.ni)
			if w == p.map and (x - p.x) * (x - p.x) + (y - p.y) * (y - p.y) <= r * r then n = n + 1 end
		end
		k = k + 1
	end
	return n
end
function engine_ai11p()
	for i, v in NPC do
		if v.id ~= 0 and v.ownerNpc then
			local o = NPC[v.ownerNpc]
			if not o or o.id ~= v.ownerId or o.map ~= v.map or o.cur <= 0 or v.cur <= 0 then DelNpc(i) end
		end
	end
end
-- engine AI 11: an owned bot is removed when its owner is on another map / dead
function engine_ai11()
	engine_ai11p()
	for i, v in NPC do
		if v.id ~= 0 and v.ai == 11 and v.owner ~= "" and not v.ownerNpc then
			local own = nil
			for pi, p in PLAYERS do if p.name == v.owner then own = p end end
			if not own or own.map ~= v.map or own.dead == 1 then DelNpc(i) end
		end
	end
end

-- dinhanbot helpers
function orphans()
	local o = 0
	for i, v in NPC do
		if v.id ~= 0 and v.ownerNpc then
			local b = NPC[v.ownerNpc]
			if not b or b.id ~= v.ownerId or b.cur <= 0 then o = o + 1 end
		end
	end
	return o
end
function petcount() local c = 0 for i, v in NPC do if v.id ~= 0 and v.ownerNpc then c = c + 1 end end return c end
function dn(pi)
	local r = { dn = 0, sk = 0, skbad = 0, pet = 0, petok = 0, list = {} }
	local l = party(pi).list
	for q = 1, getn(l) do
		local n = NPC[l[q]]
		if n.tpl >= 2715 and n.tpl <= 2720 then
			r.dn = r.dn + 1
			if n.sk and n.sk[4] and n.sk[4][1] == 44 and n.sk[4][2] == 10 and n.sk[1] and n.sk[1][1] == 49 then r.sk = r.sk + 1 end
			local p = 0
			if GetNpcPetIdx then p = GetNpcPetIdx(l[q]) end
			if p > 0 then
				r.pet = r.pet + 1
				tinsert(r.list, p)
				local pn = NPC[p]
				if pn.ai == 11 and pn.ownerNpc == l[q] and strsub(pn.name, 1, strlen(PTBP_PET_TAG)) == PTBP_PET_TAG and pn.ccamp == n.ccamp and pn.map == n.map then r.petok = r.petok + 1 end
			end
		elseif (n.sk and (n.sk[1] or n.sk[2] or n.sk[3])) or n.pet then
			r.skbad = r.skbad + 1
		end
	end
	return r
end
function tick(label)
	SIM_MIN = SIM_MIN + 1
	engine_ai11()
	engine_ai11p()
	RUN("PTBOT_Tick", T_TICK - 1, PTBOT_Tick)
	local a = party(3)
	if orphans() > 0 then SIM_flag("ORPHAN_PET " .. label) end
	write(label .. " pets=" .. petcount() .. " A=" .. a.n .. " bad=" .. a.bad .. " far=" .. a.far .. " bonusA=" .. tostring(BONUS["Lichnt"]) .. " B=" .. party(7).n .. " world=" .. worldparty() .. " free=" .. tostring(PTBOT_S.alive) .. " adds=" .. ADDS .. " dels=" .. DELS .. "\n")
	return a
end

-- ===== 1) default config (no file): enabled, follow 40, party 4 x 15%
local a = tick("T1")
check(a.n == 4 and a.bad == 0 and a.far == 0, "player on field 1015 gets 4 party bots next to him")
check(a.lvbad == 0 and a.camp == 0 and a.ai == 0, "party bots: level = player +-2, camp 0, AiMode 11")
check(party(7).n == 0, "player in town 1002 gets no party bot")
check(BONUS["Lichnt"] == 60 and BONUS["KhachQua"] == 0, "bonus 4 x 15 = 60% for the field player, 0 in town")
check(getn(PLAYERS[3].msg) == 1 and strfind(PLAYERS[3].msg[1], "+60%", 1, 1), "one join notice with the bonus")
local names = {}
local dupn = 0
for q = 1, getn(a.list) do local ni = a.list[q] if names[NPC[ni].name] then dupn = dupn + 1 end names[NPC[ni].name] = 1 end
check(dupn == 0, "party bot names are unique")
check((RELOADS["\\script\\phongthan\\bots\\party_npc.lua"] or 0) == 1, "menu script registered once")
local menus = 0
for i, v in NPC do if v.id ~= 0 and v.name == PTBP_NPC_NAME and v.script == PTBP_NPC_SCRIPT then menus = menus + 1 end end
check(menus == 3, "3 'Ho Tro To Doi' menu NPCs with the menu script")
check(NPC[a.list[1]].par[1] == 4 and TIMERS[a.list[1]], "party bot uses chat lines 4 and the bots.lua timer")
local st = readstatus()
check(st[getn(st)] == "party\t1\t4\t15\t1\t4\t1", "status party line: on, 4, 15%, 1 player, 4 bots, C++ ok (" .. tostring(st[getn(st)]) .. ")")
check(st[4] == "follow\t40\t40\t1", "follow line counts only the follow target player (" .. tostring(st[4]) .. ")")

-- ===== 2) stable: no respawn, no notice
local adds0 = ADDS
a = tick("T2")
check(a.n == 4 and ADDS == adds0 and getn(PLAYERS[3].msg) == 1, "second tick: nothing respawned, no new notice")
check(freenear(3, PTBOT_NEAR) == 0, "no free follow bot around the party player")
check(freenear(7, PTBOT_NEAR) >= 30, "free follow bots gather around the town player")
menus = 0
for i, v in NPC do if v.id ~= 0 and v.name == PTBP_NPC_NAME then menus = menus + 1 end end
check(menus == 3, "menu NPCs not duplicated")

-- ===== 3) a bot dies (AiMode 11 corpse), another wanders off: both replaced
local dead = a.list[1]
local deadid = NPC[dead].id
local monster = NewNpc(500, 30, 1115, 1660 * 32, 3100 * 32)
NPC[dead].att = monster NPC[dead].cur = -15
local lost = a.list[2]
local lostid = NPC[lost].id
NPC[lost].x = NPC[lost].x + 50 * 32
a = tick("T3")
check(a.n == 4 and NPC[dead].id ~= deadid and NPC[lost].id ~= lostid, "dead bot and lost bot removed and replaced")
check(worldparty() == 4, "no leaked party npc")
-- a dead bot whose killer is gone is not detected (no attacker): it stays until it is lost / the map changes
local dead2 = a.list[3]
NPC[dead2].att = 0 NPC[dead2].cur = -1
a = tick("T3b")
check(a.n == 4 and NPC[dead2].id ~= 0, "undetectable corpse kept (needs the C++ OnDeath hunk)")

-- ===== 4) stale slot: the index now belongs to a monster -> slot cleared, monster untouched
local victim = a.list[4]
DelNpc(victim)
local m2 = NewNpc(600, 30, 1115, 1650 * 32, 3100 * 32)   -- reuses the freed index
check(m2 == victim, "freed slot reused by a monster (setup)")
a = tick("T4")
check(NPC[m2].id ~= 0 and a.n == 4 and a.bad == 0, "monster in a stale slot not deleted, party refilled")

-- ===== 5) player goes to town: engine removes the bots, no respawn there, bonus 0
PLAYERS[3].map, PLAYERS[3].x, PLAYERS[3].y = 1003, 1700, 3100
a = tick("T5")
check(a.n == 0 and worldparty() == 0 and BONUS["Lichnt"] == 0, "town: party gone, bonus 0")
local s = 0 for j = 0, 6 do s = s + (PLAYERS[3].task[2072 + j] or 0) end
check(s == 0, "town: task slots cleared")

-- ===== 6) back on a field, personal count 2
PLAYERS[3].map, PLAYERS[3].x, PLAYERS[3].y = 1006, 1800, 3070
a = tick("T6")
check(a.n == 4 and getn(PLAYERS[3].msg) == 2, "new field map: party back + notice")
PLAYERS[3].task[2071] = 2
a = tick("T7")
check(a.n == 2 and worldparty() == 2 and BONUS["Lichnt"] == 30, "personal count 2: 2 bots, +30%")

-- ===== 7) personal off / on
PLAYERS[3].task[2070] = 2
a = tick("T8")
check(a.n == 0 and worldparty() == 0 and BONUS["Lichnt"] == 0, "personal mode off: party removed")
PLAYERS[3].task[2070] = 1
a = tick("T9")
check(a.n == 2, "personal mode on again")

-- ===== 8) real team / dead player / unloaded map
PLAYERS[3].team = 2
a = tick("T10")
check(a.n == 0 and worldparty() == 0, "real team: bot party leaves")
PLAYERS[3].team = 1
PLAYERS[3].dead = 1
a = tick("T11")
check(a.n == 0 and worldparty() == 0, "dead player: nothing spawned")
PLAYERS[3].dead = 0
PLAYERS[3].map = 1009    -- monster map not loaded on this server
a = tick("T12")
check(a.n == 0, "monster map not loaded: no spawn, no error")
PLAYERS[3].map, PLAYERS[3].task[2071] = 1015, 0

-- ===== 9) web admin config
writecfg("PTBOT_CFG = { enabled = 1, follow = 1, followCount = 10, spots = {}, party = 1, partyCount = 7, partyBonus = 10 }\n")
RUN("PTBOT_AdminApply", T_TICK - 1, PTBOT_AdminApply)
a = party(3)
check(a.n == 7 and BONUS["Lichnt"] == 70, "admin: 7 bots x 10% = +70% right after Apply")
st = readstatus()
check(st[getn(st)] == "party\t1\t7\t10\t1\t7\t1", "status party line after Apply (" .. tostring(st[getn(st)]) .. ")")
writecfg("PTBOT_CFG = { enabled = 1, follow = 1, followCount = 10, spots = {}, party = 0, partyCount = 7, partyBonus = 10 }\n")
a = tick("T13")
check(a.n == 0 and worldparty() == 0 and BONUS["Lichnt"] == 0, "admin party = 0: every party bot removed")
writecfg("PTBOT_CFG = { enabled = 1, follow = 1, followCount = 10, spots = {}, party = 1, partyCount = 99, partyBonus = -4 }\n")
a = tick("T14")
check(a.n == 7 and BONUS["Lichnt"] == 0, "clamped: count 99 -> 7, bonus -4 -> 0")
writecfg("PTBOT_CFG = { enabled = 0, follow = 1, followCount = 10, spots = {}, party = 1, partyCount = 4, partyBonus = 15 }\n")
a = tick("T15")
check(a.n == 0 and worldparty() == 0, "enabled 0: party bots removed too")
-- old config file without party keys -> party on, 4, 15
writecfg("PTBOT_CFG = { enabled = 1, follow = 1, followCount = 10, spots = {} }\n")
a = tick("T16")
check(a.n == 4 and BONUS["Lichnt"] == 60, "config written by the old web admin: party defaults")

-- ===== 10) server cap and second field player
PLAYERS[7].map, PLAYERS[7].x, PLAYERS[7].y = 1015, 1500, 3000
PTBP_MAX_TOTAL = 6
a = tick("T17")
check(party(3).n + party(7).n <= 6 and worldparty() <= 6, "server cap PTBP_MAX_TOTAL respected")
PTBP_MAX_TOTAL = 160
a = tick("T18")
check(party(3).n == 4 and party(7).n == 4 and worldparty() == 8, "two field players: 4 + 4")
local nn = {}
local d2 = 0
local l3 = party(3).list for q = 1, getn(l3) do nn[NPC[l3[q]].name] = 1 end
local l7 = party(7).list for q = 1, getn(l7) do if nn[NPC[l7[q]].name] then d2 = d2 + 1 end end
check(d2 == 0, "different names for the two parties")

-- ===== 11) older binary without SetPartyBotBonus (no C++ patch)
local keep = SetPartyBotBonus
SetPartyBotBonus = nil
PLAYERS[3].map = 1007 PLAYERS[3].msg = {}
engine_ai11()
a = tick("T19")
check(a.n == 4 and getn(PLAYERS[3].msg) == 1 and strfind(PLAYERS[3].msg[1], PTBP_TXT_NOBONUS, 1, 1), "no C++ patch: party works, notice says no bonus")
st = readstatus()
check(strsub(st[getn(st)], -2) == "\t0", "status: bonus not supported")
SetPartyBotBonus = keep

-- ===== 12) OnTimer chat of a party bot (registered bots.lua state)
local c0 = getn(CHATS)
local tries = 0
while getn(CHATS) == c0 and tries < 20 do RUN("OnTimer", T_NPC, OnTimer, a.list[1]) tries = tries + 1 end
check(getn(CHATS) > c0 and strfind(CHATS[getn(CHATS)], PTBP_TAG, 1, 1), "party bot chat bubble")
local okline = nil
for _, l in PTBOT_LINES[4] do if strfind(CHATS[getn(CHATS)], l, 1, 1) then okline = 1 end end
check(okline, "bubble taken from PTBOT_LINES[4]")

-- ===== 13) menu NPC (own script state emulation: party_npc.lua loaded on top)
PlayerIndex = 3
CUR_SCRIPT = "party_npc.lua"
SIM_LOADERR = nil
call(dofile, { SRV .. "\\script\\phongthan\\bots\\party_npc.lua" }, "x", function(m) SIM_LOADERR = m end)
check(SIM_LOADERR == nil, "party_npc.lua load " .. tostring(SIM_LOADERR))
DLG = nil
RUN("menu main", T_NPC, main)
check(DLG and getn(DLG.opts) == 5, "menu: 5 rows")
RUN("menu count", T_NPC, PTBPN_CountMenu)
check(DLG and getn(DLG.opts) == 9, "count menu: 9 rows")
RUN("menu C3", T_NPC, PTBPN_C3)
check(PLAYERS[3].task[2071] == 3, "count 3 stored")
local before = worldparty()
RUN("menu off", T_NPC, PTBPN_Off)
check(PLAYERS[3].task[2070] == 2 and worldparty() == before - 4, "menu off: own bots removed at once (others kept)")
RUN("menu info", T_NPC, PTBPN_Info)
check(DLG ~= nil, "info dialog")
RUN("menu on", T_NPC, PTBPN_On)
check(PLAYERS[3].task[2070] == 1, "menu on stored")
a = tick("T20")
check(a.n == 3, "after menu: 3 bots")


-- ===== 14) dinhanbot: Di Nhan bots use 44 in slot 4 and each one calls a de tu
check(orphans() == 0, "dinhanbot: no orphan de tu after sections 1-13")
check(PTBP_PET[1][1] == 359 and PTBP_PET[12][1] == 2032 and PTBP_PET[5][2] == 45, "pet table = PTTH_LIST (359..2032, 5..120)")
pt, pn2, pl2 = PTBP_PetPick(50)
check(pt == 403 and pn2 == 50 and pl2 == 2, "lv 50 -> 403 (Hoa Loi te) npc 50, pet lv 2 (" .. pt .. "," .. pn2 .. "," .. pl2 .. ")")
pt, pn2, pl2 = PTBP_PetPick(3)
check(pt == 359 and pn2 == 3 and pl2 == 1, "lv 3 -> 359 npc 3, pet lv 1")
pt, pn2, pl2 = PTBP_PetPick(64)
check(pt == 404 and pn2 == 60 and pl2 == 2, "lv 64 -> 404 npc 60, pet lv 2")
pt, pn2, pl2 = PTBP_PetPick(200)
check(pt == 2032 and pn2 == 165 and pl2 == 10, "lv 200 -> 2032 npc 165, pet lv 10")
PlayerIndex = 3
RUN("dismiss", T_NPC, PTBP_DismissAll)
PLAYERS[7].map, PLAYERS[7].x, PLAYERS[7].y = 1002, 1700, 3200
PLAYERS[7].task[2070] = 2      -- player 7: party off (towns have bots too since partytown)
PLAYERS[3].map, PLAYERS[3].x, PLAYERS[3].y, PLAYERS[3].lv = 1015, 1650, 3100, 50
PLAYERS[3].task[2070], PLAYERS[3].task[2071] = 1, 4
writecfg("PTBOT_CFG = { enabled = 1, follow = 1, followCount = 10, spots = {}, party = 1, partyCount = 4, partyBonus = 15 }\n")
engine_ai11()
a = tick("D1")
d = dn(3)
check(a.n == 4 and d.dn == 2, "4 party bots, 2 of them Di Nhan (roster slots 10 / 12) (" .. d.dn .. ")")
check(d.sk == d.dn and d.skbad == 0, "Di Nhan bots: slot 4 = 44 lv 10, slot 1 = 49; other bots untouched")
check(d.pet == d.dn and d.petok == d.dn, "each Di Nhan bot has one de tu: AI 11, owner = the bot, tag, same camp / map")
check(petcount() == d.dn and orphans() == 0, "no extra / orphan de tu")
p1 = NPC[d.list[1]]
check(p1.tpl == 403 and p1.lv == 50 and p1.pl == 2, "de tu template 403, npc level 50, pet level 2 for a level-50 player")
-- stable
made0 = PETS_MADE
a = tick("D2")
check(PETS_MADE == made0 and petcount() == 2, "stable: no de tu respawned")
-- de tu dies -> removed by the engine -> a new one next tick
NPC[d.list[1]].cur = -1
a = tick("D3")
d = dn(3)
check(PETS_MADE == made0 + 1 and d.pet == 2 and petcount() == 2, "dead de tu replaced (no corpse, no double)")
-- Di Nhan bot killed -> bot and de tu gone, both replaced
dnbot = nil
l3 = party(3).list
for q = 1, getn(l3) do if NPC[l3[q]].tpl >= 2715 and NPC[l3[q]].tpl <= 2720 then dnbot = l3[q] end end
oldpet = GetNpcPetIdx(dnbot)
oldpetid = NPC[oldpet].id
mon = NewNpc(500, 30, 1115, 1660 * 32, 3100 * 32)
NPC[dnbot].att = mon NPC[dnbot].cur = -15
a = tick("D4")
d = dn(3)
check(NPC[oldpet].id ~= oldpetid, "old de tu removed with its dead bot")
check(a.n == 4 and d.pet == d.dn and petcount() == d.dn and orphans() == 0, "replacement bot has its own de tu, nothing leaked")
-- bot lost (too far) -> PTBP_DelBot removes bot + de tu in the same call
for q = 1, getn(party(3).list) do local b = party(3).list[q] if NPC[b].tpl >= 2715 and NPC[b].tpl <= 2720 then dnbot = b end end
oldpet = GetNpcPetIdx(dnbot)
NPC[dnbot].x = NPC[dnbot].x + 50 * 32
PlayerIndex = 3
delsA = DELS
RUN("PTBP_DelBot", T_TICK - 1, PTBP_DelBot, dnbot)
check(DELS == delsA + 2 and NPC[oldpet].id == 0 and NPC[dnbot].id == 0, "PTBP_DelBot: bot + de tu deleted together")
a = tick("D5")
d = dn(3)
check(a.n == 4 and d.pet == d.dn and orphans() == 0, "refilled after DelBot")
-- menu off / DismissAll
RUN("dismiss2", T_NPC, PTBP_DismissAll)
check(petcount() == 0 and worldparty() == 0, "DismissAll: bots and de tu removed")
-- map change: engine removes the bots, then their de tu (owner gone)
a = tick("D6")
check(dn(3).pet == 2, "back: de tu again")
PLAYERS[3].map, PLAYERS[3].x, PLAYERS[3].y = 1006, 1800, 3070
a = tick("D7")
d = dn(3)
check(orphans() == 0 and petcount() == d.dn and d.pet == d.dn, "map change: old de tu gone, new party with de tu on the new map")
-- battlefield camp follows the bot
PLAYERS[3].map, PLAYERS[3].x, PLAYERS[3].y = 1071, 1600, 3200
LOADED[1071] = 1 SW2MAP[1171] = 1071
PLAYERS[3].task[2341] = 2
a = tick("D8")
d = dn(3)
check(d.dn == 0 or d.petok == d.dn, "Thuong Chu: de tu camp = bot camp (" .. d.petok .. "/" .. d.dn .. ")")
campok = 1
for q = 1, getn(d.list) do if NPC[d.list[q]].ccamp ~= 2 then campok = nil end end
check(campok, "Thuong Chu side 2: de tu current camp 2")
PLAYERS[3].task[2341] = 0
PLAYERS[3].map, PLAYERS[3].x, PLAYERS[3].y = 1015, 1650, 3100
a = tick("D9")
-- server limit
RUN("dismiss3", T_NPC, PTBP_DismissAll)
PTBP_PET_MAX_TOTAL = 1
PTBOT_S.petLast = 0
a = tick("D10")
check(petcount() == 1 and dn(3).sk == dn(3).dn, "server limit 1: one de tu, skills still swapped")
a = tick("D11")
check(petcount() == 1, "server limit kept on the next tick")
PTBP_PET_MAX_TOTAL = 60
a = tick("D12")
check(petcount() == dn(3).dn, "limit 60: every Di Nhan bot has a de tu")
-- older binary (no AddNpcPet / GetNpcPetIdx): skills fixed, no de tu, no error
kA, kG = AddNpcPet, GetNpcPetIdx
RUN("dismiss4", T_NPC, PTBP_DismissAll)
engine_ai11p()
AddNpcPet, GetNpcPetIdx = nil, nil
errs0 = FAILN
a = tick("D13")
d = dn(3)
check(FAILN == errs0 and a.n == 4 and d.sk == d.dn and d.pet == 0 and petcount() == 0, "no C++ dinhanbot: Di Nhan skill fix only, no de tu, no error")
RUN("dismiss5", T_NPC, PTBP_DismissAll)
check(worldparty() == 0, "old binary: DismissAll still works")
AddNpcPet, GetNpcPetIdx = kA, kG
a = tick("D14")
check(dn(3).pet == dn(3).dn and orphans() == 0, "C++ back: de tu again")
-- low-level player
RUN("dismiss6", T_NPC, PTBP_DismissAll)
PLAYERS[3].lv = 3
a = tick("D15")
d = dn(3)
check(d.pet == d.dn and d.list[1] and NPC[d.list[1]].tpl == 359 and NPC[d.list[1]].lv == 3 and NPC[d.list[1]].pl == 1, "level-3 player: de tu 359 level 3, pet level 1")

-- ===== 15) bot9x: slot 4 = level-90 skill of the class (Giap Si 42, Dao Si 26, Di Nhan keeps 44), level by bot level
function want9x(tpl)
	if tpl >= 2703 and tpl <= 2708 then return 42 end
	if tpl >= 2709 and tpl <= 2714 then return 26 end
	if tpl >= 2715 and tpl <= 2720 then return 44 end
	return 0
end
-- every party bot of player pi: slot 4 / level / flag / untouched slots
function sk9(pi)
	local r = { n = 0, ok = 0, lvok = 0, flag = 0, keep = 0, gs = 0, ds = 0, dn = 0 }
	local l = party(pi).list
	for q = 1, getn(l) do
		local n = NPC[l[q]]
		local w = want9x(n.tpl)
		r.n = r.n + 1
		if w == 42 then r.gs = r.gs + 1 elseif w == 26 then r.ds = r.ds + 1 else r.dn = r.dn + 1 end
		if n.sk and n.sk[4] and n.sk[4][1] == w then r.ok = r.ok + 1 end
		if n.sk and n.sk[4] and n.sk[4][2] == PTBP_SkLevel(n.lv) then r.lvok = r.lvok + 1 end
		if n.par[3] == 2 then r.flag = r.flag + 1 end
		if w == 44 then
			if n.sk[1] and n.sk[1][1] == 49 and not n.sk[2] and not n.sk[3] then r.keep = r.keep + 1 end
		elseif n.sk and not n.sk[1] and not n.sk[2] and not n.sk[3] then
			r.keep = r.keep + 1
		end
	end
	return r
end
check(PTBP_SkLevel(1) == 10 and PTBP_SkLevel(89) == 10 and PTBP_SkLevel(90) == 10 and PTBP_SkLevel(92) == 10, "skill level 10 below 93")
check(PTBP_SkLevel(93) == 11 and PTBP_SkLevel(105) == 15 and PTBP_SkLevel(119) == 19 and PTBP_SkLevel(120) == 20, "skill level +1 per 3 levels from 90")
check(PTBP_SkLevel(150) == 20 and PTBP_SkLevel(nil) == 10, "skill level capped at 20, nil -> 10")
-- every template 2703..2720 + foreign templates through PTBP_SkTick directly
tplok = 0
for tp = 2703, 2720 do
	local i = NewNpc(tp, 60, 1115, 1650 * 32, 3100 * 32)
	local r = PTBP_SkTick(i, 60)
	local n = NPC[i]
	if r == want9x(tp) and n.sk[4][1] == r and n.sk[4][2] == 10 and n.par[3] == 2 then tplok = tplok + 1 end
	DelNpc(i)
end
check(tplok == 18, "PTBP_SkTick: all 18 bot templates get their class skill (" .. tplok .. "/18)")
fi = NewNpc(500, 60, 1115, 1650 * 32, 3100 * 32)
fj = NewNpc(2721, 60, 1115, 1650 * 32, 3100 * 32)
check(PTBP_SkTick(fi, 60) == 0 and PTBP_SkTick(fj, 60) == 0 and NPC[fi].sk == nil and NPC[fj].sk == nil and NPC[fi].par[3] == nil, "monster / template 2721: untouched")
DelNpc(fi) DelNpc(fj)
-- live party, player level 50, 7 bots (all 3 classes)
RUN("dismiss9", T_NPC, PTBP_DismissAll)
PLAYERS[3].lv = 50 PLAYERS[3].task[2071] = 7
a = tick("K1")
r9 = sk9(3)
check(a.n == 7 and r9.gs > 0 and r9.ds > 0 and r9.dn > 0, "7 bots, all 3 classes (GS " .. r9.gs .. " DS " .. r9.ds .. " DN " .. r9.dn .. ")")
check(r9.ok == 7 and r9.lvok == 7 and r9.flag == 7, "slot 4 = 42 / 26 / 44, level 10, NpcParam 3 = 2 on every bot")
check(r9.keep == 7, "slots 1-3 untouched (Di Nhan: slot 1 = 49 only)")
check(dn(3).pet == dn(3).dn and orphans() == 0, "Di Nhan de tu still called")
-- set once
c0 = SKCALLS
a = tick("K2")
check(SKCALLS == c0 and sk9(3).ok == 7, "stable tick: SetNpcSkill not called again")
-- high level player: skill level from the bot level
RUN("dismiss10", T_NPC, PTBP_DismissAll)
PLAYERS[3].lv = 110
a = tick("K3")
r9 = sk9(3)
lvset = ""
for q = 1, getn(a.list) do lvset = lvset .. NPC[a.list[q]].lv .. ":" .. NPC[a.list[q]].sk[4][2] .. " " end
check(r9.ok == 7 and r9.lvok == 7, "level-110 player: skill level = PTBP_SkLevel(bot level) (" .. lvset .. ")")
-- bots spawned by the old dinhanbot party.lua (NpcParam 3 = 1, Di Nhan 44 lv 10, others template 41 / 18): upgraded
for q = 1, getn(a.list) do
	local n = NPC[a.list[q]]
	n.sk = nil n.par[3] = 0
	if n.tpl >= 2715 then n.sk = {} n.sk[4] = { 44, 10 } n.sk[1] = { 49, 10 } n.par[3] = 1 end
end
a = tick("K4")
check(sk9(3).ok == 7 and sk9(3).lvok == 7 and sk9(3).flag == 7, "old bots (flag 0 / dinhanbot flag 1) upgraded on the next tick")
-- engine without GetNpcLevel: player level is used
kL = GetNpcLevel
GetNpcLevel = nil
RUN("dismiss11", T_NPC, PTBP_DismissAll)
PLAYERS[3].lv = 120
a = tick("K5")
lvp = 0
for q = 1, getn(a.list) do if NPC[a.list[q]].sk[4][2] == 20 then lvp = lvp + 1 end end
check(lvp == 7, "no GetNpcLevel: level from the player level (120 -> 20)")
GetNpcLevel = kL
-- engine without SetNpcSkill: party works, no error
kS = SetNpcSkill
SetNpcSkill = nil
RUN("dismiss12", T_NPC, PTBP_DismissAll)
errs9 = FAILN
a = tick("K6")
nos = 0
for q = 1, getn(a.list) do if NPC[a.list[q]].sk == nil and NPC[a.list[q]].par[3] ~= 2 then nos = nos + 1 end end
check(FAILN == errs9 and a.n == 7 and nos == 7, "no SetNpcSkill: 7 bots, template skills, no error")
SetNpcSkill = kS
a = tick("K7")
check(sk9(3).ok == 7, "SetNpcSkill back: skills set on the next tick")
-- map change: new bots get the skill at once (same tick as the spawn)
PLAYERS[3].map, PLAYERS[3].x, PLAYERS[3].y = 1006, 1800, 3070
a = tick("K8")
check(a.n == 7 and sk9(3).ok == 7 and sk9(3).flag == 7, "map change: respawned bots have the skill in the spawn tick")
PLAYERS[3].task[2071] = 4
remove(CFG) remove(STATUS)
for k, v in EMU_MIN do write("  entry headroom " .. k .. " = " .. v .. " frames\n") end
local fk = SIM_keys(FLAGS)
for i = 1, getn(fk) do write("FLAG " .. fk[i] .. "\n") FAILN = FAILN + 1 end
write("RESULT pass=" .. PASS .. " fail=" .. FAILN .. "\n")
write("DONE\n")
writeto()
