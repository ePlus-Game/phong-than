-- sim_vienco.lua (agent vienco, 2026-10-03): Vien Co chien truong (PvE Thuong-Chu, map 1071) + Giang Son Y Cuu.
-- Scripts are read from scratchpad\vienco\out (generator output) unless SIM_ARG contains "runtime".
-- Stack emulation (as sim_nb2emu.lua): every entry point is padded so the free Lua stack equals the engine's
-- (47 frames for NPC/item entries, 40 for the ext tick). Run with run.ps1 -Stack 0 (emulated) or -Stack 100 (plain).
dofile("sim.lua")
OUTDIR = "..\\vienco\\out"
if strfind(SIM_ARG or "", "runtime", 1, 1) then OUTDIR = SRV end
EMU = not strfind(SIM_ARG or "", "noemu", 1, 1)
function SIM_path(p)
	if strfind(p, "\\script\\phongthan\\vienco\\", 1, 1) or strfind(p, "\\script\\phongthan\\ext\\", 1, 1) then
		return OUTDIR .. p
	end
	return SRV .. p
end
function Include(p)
	local f = SIM_path(p)
	local fh = openfile(f, "r")
	if fh then closefile(fh) dofile(f) else SIM_flag("INCLUDE_MISSING " .. p) end
end
OUTFILE = "out_vienco.txt"
if strfind(SIM_ARG or "", "noemu", 1, 1) then OUTFILE = "out_vienco_s100.txt" end
writeto(OUTFILE)

-- ---------------------------------------------------------------- stack emulation (copied from sim_nb2emu.lua)
function HR_R(d) HR_MAX = d HR_R(d + 1) end
function HR_NOP() end
function Headroom()
	HR_MAX = 0
	local old = _ERRORMESSAGE
	call(HR_R, { 0 }, "x", HR_NOP)
	_ERRORMESSAGE = old
	return HR_MAX
end
function EMU_PAD(target, f, a1, a2, a3)
	if Headroom() > target then
		return EMU_PAD(target, f, a1, a2, a3)
	end
	EMU_REC.h = Headroom()
	return f(a1, a2, a3)
end
EMU_MINH = {}
EMU_REC = {}

-- ---------------------------------------------------------------- multi-player world
PLAYERS = {}
function NEWP(idx, name, ptype, level)
	PLAYERS[idx] = { task = {}, level = level, ptype = ptype, exp = 0, cash = 1000000, map = 1001, x = 1510, y = 3289,
	                 items = {}, fight = 0, camp = 1, cur = 1, name = name, online = 1, punish = 1, msgs = {}, notes = {} }
	return PLAYERS[idx]
end
function P() return PLAYERS[PlayerIndex] end
function GetTask(i) return P().task[i] or 0 end
function SetTask(i, v) P().task[i] = v end
function GetLevel() return P().level end
function GetPlayerType() return P().ptype end
function GetName() return P().name end
function GetPK() return 0 end
function GetCash() return P().cash end
function Pay(n) if P().cash >= n then P().cash = P().cash - n return 1 end return 0 end
function Earn(n) P().cash = P().cash + n end
function AddOwnExp(n) P().exp = P().exp + n end
function GetWorldPos() return P().map, P().x, P().y end
function NewWorld(m, x, y) P().map = m P().x = x P().y = y return 1 end
function SetPos(x, y) P().x = x P().y = y end
function GetCamp() return P().camp end
function SetCurCamp(c) P().cur = c end
function SetFightState(n) P().fight = n end
function GetFightState() return P().fight end
function SetPunish(n) P().punish = n end
function SetLogoutRV(n) P().logout = n end
function SetTempRevPos(m, x, y) P().rev = m end
function Msg2Player(s) tinsert(P().msgs, s) end
function TopMessage(s) tinsert(P().msgs, "TOP " .. s) end
function AddNote(a, b, s, d) tinsert(P().notes, s) end
function AddNormalItem(g, d, p, lv) local k = g .. "," .. d .. "," .. p P().items[k] = (P().items[k] or 0) + 1 return 1 end
function GetPlayerID(i)
	local idx = i or PlayerIndex
	if PLAYERS[idx] and PLAYERS[idx].online == 1 then return 1000000 + idx * 7 end
	return nil
end
NEWS = {}
function AddGlobalCountNews(s) tinsert(NEWS, s) end

-- globals, time
GV = {}
function GetGlobalValue(i) return GV[i] or 0 end
function SetGlobalValue(i, v) GV[i] = v end
TIME = { Y = 2026, m = 10, d = 3, H = 10, M = 5, j = 276 }
function date(fmt)
	local s = fmt
	s = gsub(s, "%%Y", format("%04d", TIME.Y))
	s = gsub(s, "%%m", format("%02d", TIME.m))
	s = gsub(s, "%%d", format("%02d", TIME.d))
	s = gsub(s, "%%H", format("%02d", TIME.H))
	s = gsub(s, "%%M", format("%02d", TIME.M))
	s = gsub(s, "%%j", format("%03d", TIME.j))
	return s
end

-- NPCs
NPC = {}
NPCC = { n = 100 }
function SubWorldID2Idx(m) if m >= 1001 and m <= 1083 then return m end return -1 end
function AddNpc(tpl, lv, sw, x, y, rem)
	NPCC.n = NPCC.n + 1
	NPC[NPCC.n] = { tpl = tpl, lv = lv, map = sw, x = floor(x / 32), y = floor(y / 32), name = "", param = {}, script = nil, rem = rem }
	return NPCC.n
end
function GetNpcName(i) if NPC[i] then return NPC[i].name end return "" end
function SetNpcName(i, s) if NPC[i] then NPC[i].name = s end end
function SetNpcScript(i, s) if NPC[i] then NPC[i].script = s end end
function SetNpcParam(i, k, v) if NPC[i] then NPC[i].param[k] = v end end
function GetNpcParam(i, k) if NPC[i] then return NPC[i].param[k] or 0 end return 0 end
function GetNpcTemplateID(i) if NPC[i] then return NPC[i].tpl end return 0 end
function GetNpcPos(i) if NPC[i] then return NPC[i].map, NPC[i].x, NPC[i].y end return 0, 0, 0 end
function SetNpcTimeout(i, t) if NPC[i] then NPC[i].timeout = t end end
function SetNpcCurCamp(i, c) if NPC[i] then NPC[i].camp = c end end
function NpcIdx2PIdx(i) if NPC[i] and NPC[i].player then return NPC[i].player end return 0 end
function DelNpc(i) NPC[i] = nil end
RL = { n = 0 }
function ReLoadScript(p) RL.n = RL.n + 1 return 1 end

-- ---------------------------------------------------------------- module loader
function load(key, rel)
	local snap = SIM_snapshot()
	CUR_SCRIPT = key
	SIM_LOADERR = nil
	call(dofile, { OUTDIR .. rel }, "x", function(m) SIM_LOADERR = m end)
	local mod = SIM_diff(snap)
	mod.CUR_SCRIPT = nil
	SIM_restore(snap)
	if SIM_LOADERR then SIM_flag("LOAD_ERROR " .. key .. " " .. SIM_LOADERR) end
	MODS[key] = mod
end
-- placeholders of the region data and a player standing next to one (must not be renamed)
function placeholder(x, y, name)
	local i = AddNpc(500, 1, 1071, x * 32, y * 32, 0)
	NPC[i].name = name
	NPC[i].script = "\\script\\phongthan\\npc_restore\\1071_xx.lua"
	return i
end
PH1 = placeholder(1897, 3041, "Nguyen Soai")
PH2 = placeholder(1848, 3056, "Tuong Linh Thuong")
PH3 = placeholder(1936, 3040, "Tuong Linh Chu")
PH4 = placeholder(1424, 3248, "Tiep Dan Thuong")
PH5 = placeholder(2320, 3296, "Tiep Dan Chu")
PLNPC = placeholder(1849, 3057, "SomePlayer")
NPC[PLNPC].player = 9

D = "\\script\\phongthan\\vienco\\"
load("ext", "\\script\\phongthan\\ext\\vienco.lua")
load("chiensu", D .. "vc_chiensu.lua")
load("vantrong", D .. "vc_vantrong.lua")
load("khuong", D .. "vc_khuongthuong.lua")
load("info", D .. "vc_info.lua")
load("mob", D .. "vc_mob.lua")
load("gs", D .. "gs_dukhanh.lua")
load("gsmob", D .. "gs_mob.lua")

-- run fn of module key (padded to the engine stack headroom)
function RUN(key, fn, args)
	local mod = MODS[key]
	local f = mod[fn]
	if EMU and type(f) == "function" then
		local target = 47
		if key == "ext" then target = 40 end
		mod[fn] = function(a1, a2, a3) return EMU_PAD(%target, %f, a1, a2, a3) end
	end
	DLG = nil
	SIM_run(key, fn, args or {})
	if EMU and type(f) == "function" then mod[fn] = f end
	local k = key .. ":" .. fn
	if EMU_REC.h and (EMU_MINH[k] == nil or EMU_REC.h < EMU_MINH[k]) then EMU_MINH[k] = EMU_REC.h end
	EMU_REC.h = nil
	if SIM_ERR then write("   LUAERR [" .. k .. "] " .. SIM_ERR .. "\n") FAILS = (FAILS or 0) + 1 end
end
function opts()
	local s = ""
	if DLG then for i = 1, getn(DLG.opts) do s = s .. " [" .. tostring(DLG.opts[i].fn) .. "]" end end
	return s
end
function T(key, fn, args)
	RUN(key, fn, args)
	local p = P()
	local s = key .. ":" .. fn .. " -> opts" .. opts()
	if p then
		s = s .. " map=" .. p.map .. " side=" .. GetTask(2341) .. " mis=" .. GetTask(2344) .. " score=" .. GetTask(2342) .. " flag=" .. GetTask(2349) .. " rank=" .. GetTask(2345) .. "/" .. GetTask(2346) .. " exp=" .. p.exp .. " cash=" .. p.cash .. " cur=" .. p.cur
		for i = 1, getn(p.msgs) do s = s .. "\n   MSG " .. p.msgs[i] end
		p.msgs = {}
	end
	write(s .. "\n")
end
function CHECK(cond, what)
	if cond then write("OK   " .. what .. "\n") else write("FAIL " .. what .. "\n") FAILS = (FAILS or 0) + 1 end
end
function count(pred)
	local c = 0
	for i, n in NPC do if pred(n) then c = c + 1 end end
	return c
end
function findarmy(side, kind)
	for i, n in NPC do if n.param[1] == 7740 and n.param[3] == side and n.param[2] == kind then return i end end
	return 0
end
function TICK(h, m)
	TIME.H = h TIME.M = m
	local old = PlayerIndex
	RUN("ext", "PTEXT_vienco_Tick", {})
	PlayerIndex = old
end

-- ================================================================= 1. ext tick: NPCs, placeholders, round open
write("== ext tick 10:05\n")
PlayerIndex = 0
TICK(10, 5)
CHECK(RL.n == 16, "16 scripts registered (11 loose + 5 PAK), got " .. RL.n)
CHECK(count(function(n) return n.script and strfind(n.script, "vienco", 1, 1) and n.param[1] ~= 7740 end) >= 4 + 5, "fixed NPCs + 5 placeholders bound to vienco scripts")
CHECK(NPC[PH1].script == D .. "vc_info.lua" and NPC[PH4].script == D .. "vc_info.lua" and NPC[PH5].script == D .. "vc_info.lua", "placeholders adopted")
CHECK(NPC[PLNPC].name == "SomePlayer", "player near a placeholder untouched")
CHECK(count(function(n) return n.param[1] == 7740 end) == 38, "38 army NPCs (2 x 12 soldiers, 4 scouts, 2 flags, 1 totem)")
CHECK(GetGlobalValue(2340) == 2 and GetGlobalValue(2341) == 10031000, "round open key 10031000")
CHECK(NPC[findarmy(1, 1)].camp == 1 and NPC[findarmy(2, 4)].camp == 2, "army camps 1 / 2")
CHECK(NPC[findarmy(2, 1)].tpl == 1952 and NPC[findarmy(1, 3)].tpl == 419 and NPC[findarmy(2, 4)].tpl == 418, "army templates")
local before = NPCC.n
TICK(10, 6)
CHECK(NPCC.n == before, "second tick idempotent")
NPC[findarmy(1, 1)] = nil
TICK(10, 7)
CHECK(NPCC.n == before + 1 and count(function(n) return n.param[1] == 7740 end) == 38, "missing soldier re-spawned")

-- ================================================================= 2. player A joins Chu
write("== player A (Chu)\n")
NEWP(1, "Alpha", 0, 60)
PlayerIndex = 1
T("chiensu", "main")
T("chiensu", "vc_enter")
T("chiensu", "vc_zhou")
CHECK(P().map == 1071 and GetTask(2341) == 2 and P().cur == 2 and P().cash == 950000, "A in 1071, side Chu, camp 2, fee paid")
CHECK(GetGlobalValue(2350) == 1, "A in slot 1")
T("khuong", "main")
T("khuong", "vc_mission")
T("khuong", "vc_accept")
CHECK(GetTask(2344) == 1001, "Vi Quoc Lap Cong kill 1 (rank 0)")
T("khuong", "vc_sortie")
CHECK(P().fight == 1 and P().x >= 2328, "sortie to the Chu front")
T("vantrong", "main")
-- kill an own-side soldier: nothing
T("mob", "LastDamage", { findarmy(2, 1) })
CHECK(GetTask(2342) == 0 and GetTask(2344) == 1001, "own army kill ignored")
T("mob", "LastDamage", { findarmy(1, 1) })
CHECK(GetTask(2342) == 1 and GetTask(2344) == 1 and GetGlobalValue(2343) >= 1, "enemy soldier: score 1, mission done")
T("mob", "LastDamage", { findarmy(1, 3) })
CHECK(GetTask(2349) == 10031000, "carrying the Thuong flag")
local s2 = GetGlobalValue(2343)
T("khuong", "main")
CHECK(GetTask(2349) == 0 and GetTask(2342) == 11 and GetGlobalValue(2343) == s2 + 5, "flag delivered: +10 / side +5")
T("mob", "LastDamage", { findarmy(1, 4) })
T("mob", "LastDamage", { findarmy(1, 2) })
CHECK(GetTask(2342) == 19, "totem +5, scout +3 -> 19")
T("khuong", "vc_mission")
T("khuong", "vc_status")

-- ================================================================= 3. player B joins Thuong, leaves the map
write("== player B (Thuong)\n")
NEWP(2, "Beta", 1, 55)
PlayerIndex = 2
T("chiensu", "vc_enter")
T("chiensu", "vc_shang")
CHECK(P().map == 1071 and GetTask(2341) == 1 and P().cur == 1 and GetGlobalValue(2351) == 2, "B in, Thuong, slot 2")
T("vantrong", "main")
T("vantrong", "vc_mission")
T("vantrong", "vc_accept")
SetTask(2344, 5001)
P().map = 1020
TICK(10, 8)
PlayerIndex = 2
CHECK(P().cur == 1 and GetGlobalValue(2351) == 0 and P().punish == 1, "B left 1071: camp restored, slot freed")
T("chiensu", "vc_enter")
CHECK(P().map == 1071 and P().cash == 950000 and GetGlobalValue(2351) == 2, "B re-enters the same round free")
-- player C joins Thuong and goes offline before the end
NEWP(3, "Gamma", 2, 70)
PlayerIndex = 3
T("chiensu", "vc_enter") T("chiensu", "vc_shang")
T("vantrong", "vc_accept")
SetTask(2344, 1)
P().online = 0

-- ================================================================= 4. settle at 10:45
write("== settle 10:45\n")
PlayerIndex = 0
TICK(10, 45)
CHECK(GetGlobalValue(2340) == 0 and GetGlobalValue(2344) == 10031000, "round closed, last = 10031000")
CHECK(GetGlobalValue(2345) == 2, "Chu wins (" .. GetGlobalValue(2342) .. " : " .. GetGlobalValue(2343) .. ")")
CHECK(count(function(n) return n.param[1] == 7740 end) == 0, "armies removed")
PlayerIndex = 1
CHECK(P().map == 1001 and GetTask(2344) == 2 and GetTask(2341) == 0 and P().cur == 1 and P().exp > 0, "A home, reward pending, camp restored, exp " .. P().exp)
PlayerIndex = 2
CHECK(P().map == 1001 and GetTask(2344) == 0, "B (loser, win objective) -> mission cancelled")
local nw = NEWS[getn(NEWS)]
write("   NEWS " .. nw .. "\n")
CHECK(strfind(nw, "Alpha", 1, 1) ~= nil, "best fighter Alpha in the news")

-- ================================================================= 5. rewards / rank
write("== reward\n")
PlayerIndex = 1
local e0 = P().exp
T("chiensu", "main")
T("chiensu", "vc_reward")
CHECK(GetTask(2344) == 0 and P().exp - e0 == 60 * 2000 * 2 and GetTask(2346) == 1, "reward 240000 exp, rank count 1")
SetTask(2344, 2) SetTask(2345, 3) SetTask(2346, 1)
T("chiensu", "vc_reward")
CHECK(GetTask(2345) == 4 and P().items["0,2,6"] == 1, "rank 4 + Tinh Cang armor 0/2/6 lv5")
T("chiensu", "vc_rank")
-- lazy result for the offline player C
PlayerIndex = 3
P().online = 1
T("chiensu", "main")
CHECK(GetTask(2344) == 2 and GetTask(2341) == 0, "offline player resolved lazily (done -> reward)")

-- ================================================================= 6. forced round, info NPC, daily limit
write("== force open\n")
PlayerIndex = 0
TIME.H = 10 TIME.M = 50
RUN("ext", "PTVC_ForceOpen", {})
CHECK(GetGlobalValue(2340) == 2 and GetGlobalValue(2341) == 10031050 and count(function(n) return n.param[1] == 7740 end) == 38, "forced round open")
TICK(10, 51)
CHECK(GetGlobalValue(2340) == 2, "forced round survives minute 51")
PlayerIndex = 1
T("chiensu", "vc_enter") T("chiensu", "vc_shang")
CHECK(P().map == 1071 and GetTask(2341) == 1, "A joins Thuong in the forced round")
T("vantrong", "vc_accept")
SetTask(2344, 0)
T("vantrong", "vc_accept")
SetTask(2344, 0)
T("vantrong", "vc_mission")
CHECK(GetTask(2344) == 0 and GetTask(2348) == 3, "daily limit 3 reached (" .. GetTask(2348) .. ")")
T("info", "main")
T("info", "vc_home")
CHECK(P().map == 1001 and GetTask(2341) == 0 and P().cur == 1, "info NPC: back home")
PlayerIndex = 0
local k = 0
while k < 45 do TICK(11, mod(k, 45)) k = k + 1 end
CHECK(GetGlobalValue(2340) == 2 and GetGlobalValue(2341) == 10031100, "after the forced round the 11:00 round runs")

-- ================================================================= 7. Giang Son Y Cuu
write("== Giang Son Y Cuu\n")
NEWP(4, "Delta", 1, 50)
PlayerIndex = 4
P().map = 1021
T("gs", "main")
T("gs", "gs_begin")
T("gs", "gs_accept")
CHECK(GetTask(2355) == 1 and GetTask(2356) == 1 and count(function(n) return n.param[1] == 7742 and n.param[2] == 11 end) == 3, "step 1: 3 Sa Hon spawned on 1022")
T("gs", "gs_resummon")
CHECK(count(function(n) return n.param[1] == 7742 end) == 3, "re-summon refused within 10 minutes")
-- a wrong-step target does not count
local stray = AddNpc(17, 30, 1022, 0, 0, 1) NPC[stray].param = { [1] = 7742, [2] = 21, [3] = 1 }
RUN("gsmob", "LastDamage", { stray })
CHECK(GetTask(2358) == 0, "target of another step ignored")
function killstep()
	local guard = 0
	while GetTask(2356) == 1 and guard < 20 do
		local victim = 0
		for i, n in NPC do if victim == 0 and n.param[1] == 7742 and n.param[2] == GetTask(2355) * 10 + GetTask(2357) then victim = i end end
		if victim == 0 then write("   no target for step " .. GetTask(2355) .. " stage " .. GetTask(2357) .. "\n") return end
		RUN("gsmob", "LastDamage", { victim })
		if NPC[victim] and NPC[victim].timeout == 18 then RUN("gsmob", "Timeout", { victim }) end
		guard = guard + 1
	end
end
local step = 1
local gated = 0
while GetTask(2360) ~= 1 and step <= 25 do
	if GetTask(2356) == 0 then
		T("gs", "main")
		T("gs", "gs_accept")
		if GetTask(2356) == 0 then
			gated = gated + 1
			P().level = P().level + 10
			T("gs", "gs_accept")
		end
	end
	killstep()
	CHECK(GetTask(2356) == 2, "step " .. GetTask(2355) .. " done")
	T("gs", "main")
	T("gs", "gs_report")
	step = step + 1
end
CHECK(GetTask(2360) == 1 and GetTask(2355) == 20, "Giang Son Y Cuu finished (19 steps)")
CHECK(gated >= 2, "level gates (60 / 70 / 80) enforced: " .. gated)
CHECK((P().items["3,41,0"] or 0) == 5 and (P().items["3,81,0"] or 0) == 3, "item rewards: 5 Lam bao thach, 3 Qua nhan sam")
write("   Delta exp " .. P().exp .. " cash " .. P().cash .. " notes " .. getn(P().notes) .. "\n")
T("gs", "main")
-- expired target removed by Timeout
local old = AddNpc(17, 30, 1022, 0, 0, 1) NPC[old].param = { [1] = 7742, [2] = 11, [3] = 1 }
RUN("gsmob", "Timeout", { old })
CHECK(NPC[old] == nil, "expired target deleted")

-- ================================================================= done
for k, v in EMU_MINH do write("  entry headroom " .. k .. " = " .. v .. " frames\n") end
local fk = SIM_keys(FLAGS)
for i = 1, getn(fk) do write("FLAG " .. fk[i] .. "\n") end
write("FAILS=" .. tostring(FAILS or 0) .. "\n")
writeto()
