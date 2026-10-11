-- Simulator test for Van Tien tran (agent vantien, 2026-10-02). Lua 4.
-- Emulates the engine pieces the scripts use: GlobalValue, NPCs, missions (players, NPCs, timers,
-- OnLeave on map change), NewWorld, dialogs (sim.lua Say), kills (ActionScript LastDamage).
-- Every script is loaded as its own module (own globals = own Lua state, like the engine).
-- Run: run.ps1 -Main sim_vantien.lua [-Args1 runtime]   (default: staged build in vantien\impl\out)
dofile("sim.lua")
VT_OUTFILE = "out_vantien.txt"
if SIM_ARG == "runtime" then
	SRV = "E:\\VL\\Phong than\\PT\\PhongThanRuntime-Staging\\Server"
	VT_OUTFILE = "out_vantien_runtime.txt"
else
	SRV = "C:\\Users\\LICHNT~1.OFF\\AppData\\Local\\Temp\\claude\\D--Project-Email-Send\\d0824b0a-6cac-412d-8946-ef7c47e9c425\\scratchpad\\vantien\\impl\\out"
end
VT_EFF = "C:\\Users\\LICHNT~1.OFF\\AppData\\Local\\Temp\\claude\\D--Project-Email-Send\\d0824b0a-6cac-412d-8946-ef7c47e9c425\\scratchpad\\vantien\\eff\\"
writeto(VT_OUTFILE)
_ERRORMESSAGE = function(m) write("LUAERR " .. m .. "\n") end

-- ---------------------------------------------------------------- checks
VT_OK = 0
VT_FAIL = 0
function CHK(c, label)
	if c then
		VT_OK = VT_OK + 1
		write("  ok   " .. label .. "\n")
	else
		VT_FAIL = VT_FAIL + 1
		write("  FAIL " .. label .. "\n")
	end
end
function SEC(s) write("== " .. s .. "\n") end

-- ---------------------------------------------------------------- engine model
ENG = { gv = {}, npcs = {}, next = 100, ms = {}, log = {}, frame = 0, reload = {}, loaded = { [1020] = 1, [1002] = 1, [1079] = 1, [1080] = 1, [1081] = 1, [1082] = 1 } }
P = {}
CLOCK = { hm = "15:07", ymd = "20261002" }
RND = {}
function VT_log(s) tinsert(ENG.log, s) end

function date(f)
	if f == "%H:%M" then return CLOCK.hm end
	if f == "%Y%m%d" then return CLOCK.ymd end
	if f == "%m%d%H%M" then return strsub(CLOCK.ymd, 5, 8) .. strsub(CLOCK.hm, 1, 2) .. strsub(CLOCK.hm, 4, 5) end
	if f == "%H%M" then return strsub(CLOCK.hm, 1, 2) .. strsub(CLOCK.hm, 4, 5) end
	return CLOCK.ymd .. " " .. CLOCK.hm
end
function random(a, b)
	if getn(RND) > 0 then
		local v = RND[1]
		tremove(RND, 1)
		return v
	end
	if a == nil then return 0.5 end
	return a
end

function GetGlobalValue(i) return ENG.gv[i] or 0 end
function SetGlobalValue(i, v) ENG.gv[i] = v end
function SubWorldID2Idx(m) if m and ENG.loaded[m] then return m end return -1 end
function SubWorldIdx2ID(i) return i end
function ReLoadScript(p) tinsert(ENG.reload, p) return 1 end

-- NPCs
function AddNpc(...)
	if arg.n < 6 then return nil end
	local sw = arg[3]
	if not sw or not ENG.loaded[sw] then return 0 end
	ENG.next = ENG.next + 1
	ENG.npcs[ENG.next] = { tpl = arg[1], lv = arg[2], sw = sw, x = arg[4], y = arg[5], name = "", script = nil }
	return ENG.next
end
function DelNpc(ni) if ENG.npcs[ni] then ENG.npcs[ni].deleted = 1 end end
function SetNpcName(ni, s) if ENG.npcs[ni] then ENG.npcs[ni].name = s end end
function GetNpcName(ni) local n = ENG.npcs[ni] if n and not n.deleted then return n.name end return "" end
function SetNpcScript(ni, s) if ENG.npcs[ni] then ENG.npcs[ni].script = s end end
function SetNpcRevTime(ni, v) if ENG.npcs[ni] then ENG.npcs[ni].rev = v end end
function GetNpcTemplateID(ni) local n = ENG.npcs[ni] if n and not n.deleted then return n.tpl end return -1 end
function GetNpcPos(ni) local n = ENG.npcs[ni] if n and not n.deleted then return n.sw, n.x / 32, n.y / 32 end return 0, 0, 0 end
GetNpcWorldPos = GetNpcPos

-- players
function VT_newplayer(pi, name, level, map)
	P[pi] = { name = name, level = level, map = map, x = 1580, y = 3030, task = {}, items = {}, exp = 0, cash = 0, fight = 0, lrv = 0, msgs = {}, sale = 0 }
end
function PL() return P[PlayerIndex or 0] end
function GetName() local p = PL() if p then return p.name end return nil end
function GetLevel() local p = PL() if p then return p.level end return 0 end
function GetTask(i) local p = PL() if p then return p.task[i] or 0 end return 0 end
function SetTask(i, v) local p = PL() if p then p.task[i] = v end end
function GetWorldPos() local p = PL() if p then return p.map, p.x, p.y end return 0, 0, 0 end
function SetPos(x, y) local p = PL() if p then p.x = x p.y = y VT_log("SetPos " .. p.name .. " " .. x .. "," .. y) end end
function SetFightState(v) local p = PL() if p then p.fight = v end end
function GetFightState() local p = PL() if p then return p.fight end return 0 end
function SetLogoutRV(v) local p = PL() if p then p.lrv = v end end
function Msg2Player(s) local p = PL() if p then tinsert(p.msgs, s) end end
function TopMessage(s) end
function AddOwnExp(n) local p = PL() if p then p.exp = p.exp + n end end
function Earn(n) local p = PL() if p then p.cash = p.cash + n end end
function Sale(n) local p = PL() if p then p.sale = n end end
function VT_ik(g, d, pp) return g .. "," .. d .. "," .. (pp or 0) end
function AddNormalItem(g, d, pp, lv, se, lu)
	local p = PL()
	if not p or p.bagfull then return 0 end
	local k = VT_ik(g, d, pp)
	p.items[k] = (p.items[k] or 0) + 1
	return 5000
end
function HaveNormalItem(g, d, pp, lv) local p = PL() if p then return p.items[VT_ik(g, d, pp)] or 0 end return 0 end
function DelNormalItem(g, d, pp, lv)
	local p = PL()
	local k = VT_ik(g, d, pp)
	if p and (p.items[k] or 0) > 0 then
		p.items[k] = p.items[k] - 1
		if p.items[k] == 0 then p.items[k] = nil end
		return 1
	end
	return 0
end
function AddGlobalNews(s) VT_log("NEWS " .. s) end
function AddLocalNews(s) VT_log("LNEWS " .. s) end
function AddGlobalCountNews(s) VT_log("NEWS " .. s) end

-- modules
VT_PATHMOD = {}
function VT_load(name, rel)
	local snap = SIM_snapshot()
	CUR_SCRIPT = name
	SIM_LOADERR = nil
	call(dofile, { SRV .. rel }, "x", function(m) SIM_LOADERR = m end)
	local mod = SIM_diff(snap)
	mod.CUR_SCRIPT = nil
	SIM_restore(snap)
	if SIM_LOADERR then SIM_flag("LOAD_ERROR " .. name .. " " .. SIM_LOADERR) end
	MODS[name] = mod
	VT_PATHMOD[strlower(rel)] = name
	return mod
end
function VT_call(name, fn, args, sw, pi)
	if not MODS[name] then SIM_flag("NO_MODULE " .. name) return end
	if sw then MODS[name].SubWorld = sw end
	if pi then MODS[name].PlayerIndex = pi end
	local keep = PlayerIndex
	SIM_run(name, fn, args or {})
	PlayerIndex = keep
end
function VT_modname(path)
	local p = strlower(path)
	return VT_PATHMOD[p]
end

-- missions
function VT_ms(sw, n) if sw == nil then return nil end if ENG.ms[sw] then return ENG.ms[sw][n] end return nil end
function VT_curms(n) return VT_ms(getglobal("SubWorld"), n) end
function OpenMission(n)
	local sw = getglobal("SubWorld")
	if not sw or not ENG.loaded[sw] then return end
	if VT_ms(sw, n) then return end
	if not ENG.ms[sw] then ENG.ms[sw] = {} end
	ENG.ms[sw][n] = { pl = {}, npcs = {}, timers = {} }
	VT_call(format("mission%02d", n), "InitMission", { n }, sw)
end
function IsMission(n) if VT_curms(n) then return 1 end return 0 end
function RunMission(n) local sw = getglobal("SubWorld") if VT_ms(sw, n) then VT_call(format("mission%02d", n), "RunMission", { n }, sw) end end
function CloseMission(n)
	local sw = getglobal("SubWorld")
	local ms = VT_ms(sw, n)
	if not ms then return end
	VT_call(format("mission%02d", n), "EndMission", { n }, sw)
	local i = 1
	while ms.npcs[i] do
		if ENG.npcs[ms.npcs[i]] then ENG.npcs[ms.npcs[i]].deleted = 1 end
		i = i + 1
	end
	ENG.ms[sw][n] = nil
end
function StartMissionTimer(n, id, frames) local ms = VT_curms(n) if ms then ms.timers[id] = { left = frames, iv = frames } end end
function StopMissionTimer(n, id) local ms = VT_curms(n) if ms then ms.timers[id] = nil end end
function GetMSRestTime(n, id) local ms = VT_curms(n) if ms and ms.timers[id] then return ms.timers[id].left end return 0 end
function AddMSPlayer(...)
	local n = arg[1]
	local pi = PlayerIndex
	if arg.n >= 3 then pi = arg[2] end
	local ms = VT_curms(n)
	if not ms then return 0 end
	tinsert(ms.pl, { pi = pi, avail = 1 })
	return getn(ms.pl)
end
function AddMSNpc(n, ni, g) local ms = VT_curms(n) if ms then tinsert(ms.npcs, ni) return getn(ms.npcs) end return 0 end
function GetMSPlayerCount(n) local ms = VT_curms(n) if ms then return getn(ms.pl) end return 0 end
function MSDIdx2PIdx(n, i) local ms = VT_curms(n) if ms and ms.pl[i] then return ms.pl[i].pi end return 0 end
function GetPMParam(n, i, k) local ms = VT_curms(n) if ms and ms.pl[i] and k == 0 then return ms.pl[i].avail end return 0 end
function SetPMParam(n, i, k, v) local ms = VT_curms(n) if ms and ms.pl[i] and k == 0 then ms.pl[i].avail = v end end
function PIdx2MSDIdx(n, pi)
	local ms = VT_curms(n)
	if not ms then return 0 end
	local i = 1
	while ms.pl[i] do
		if ms.pl[i].pi == pi then return i end
		i = i + 1
	end
	return 0
end
function Msg2MSAll(n, s) VT_log("MSALL" .. n .. " " .. s) end
function NewWorld(m, x, y)
	local p = PL()
	if not p then return 0 end
	if not m or not ENG.loaded[m] then return 0 end
	local old = p.map
	local pi = PlayerIndex
	if old ~= m and ENG.ms[old] then
		local n = 1
		while n <= 20 do
			if ENG.ms[old][n] then VT_call(format("mission%02d", n), "OnLeave", { pi }, old) end
			n = n + 1
		end
	end
	PlayerIndex = pi
	p.map = m p.x = x p.y = y
	VT_log("NewWorld " .. p.name .. " " .. m)
	return 1
end
-- engine time: fire mission timers
function VT_advance(frames)
	local fires = {}
	for sw, t in ENG.ms do
		for n, ms in t do
			for id, tm in ms.timers do
				tm.left = tm.left - frames
				if tm.left <= 0 then
					tm.left = tm.iv
					tinsert(fires, { sw, n, id })
				end
			end
		end
	end
	local i = 1
	while fires[i] do
		local f = fires[i]
		if VT_ms(f[1], f[2]) and VT_ms(f[1], f[2]).timers[f[3]] then
			VT_call(format("task%02d", f[3]), "OnMissionTimer", { f[3] }, f[1])
		end
		i = i + 1
	end
end
-- a kill: ActionScript LastDamage with PlayerIndex = kill owner
function VT_kill(ni, pi)
	local n = ENG.npcs[ni]
	if not n or n.deleted or n.dead then return end
	n.dead = 1
	if n.script then
		local m = VT_modname(n.script)
		if m then VT_call(m, "LastDamage", { ni }, nil, pi) else SIM_flag("UNREGISTERED_SCRIPT " .. n.script) end
	end
end
-- talk to an NPC (main) or pick an option
function VT_talk(name, fn, pi)
	DLG = nil
	VT_call(name, fn, {}, nil, pi)
	local s = ""
	if DLG then
		local i = 1
		while DLG.opts[i] do
			s = s .. " [" .. tostring(DLG.opts[i].fn) .. "]"
			i = i + 1
		end
	end
	return s
end
function VT_hasopt(s, fn) return strfind(s, "[" .. fn .. "]", 1, 1) ~= nil end
function VT_npcs(sw, tpl)
	local r = {}
	for ni, n in ENG.npcs do
		if n.sw == sw and not n.deleted and (tpl == nil or n.tpl == tpl) then tinsert(r, ni) end
	end
	sort(r)
	return r
end
function VT_items(p) return SIM_ser(P[p].items) end
function VT_lastmsg(p) local m = P[p].msgs return m[getn(m)] or "" end

-- ---------------------------------------------------------------- load modules
VT_load("lib", "\\script\\phongthan\\vantien\\vt_lib.lua")
VT_load("timer", "\\script\\phongthan\\vantien\\vt_timer.lua")
VT_load("th", "\\script\\phongthan\\vantien\\vt_thienhung.lua")
VT_load("dp", "\\script\\phongthan\\vantien\\vt_daiphu.lua")
VT_load("boss", "\\script\\phongthan\\vantien\\vt_boss.lua")
VT_load("chest", "\\script\\phongthan\\vantien\\vt_chest.lua")
VT_load("mob", "\\script\\phongthan\\vantien\\vt_mob.lua")
for n = 1, 4 do VT_load(format("mission%02d", n), format("\\script\\missions\\mission%02d.lua", n)) end
for id = 1, 9 do VT_load(format("task%02d", id), format("\\script\\timertask\\task%02d.lua", id)) end
-- VNG trap script (script.pak, Tho trap 1) to check that the tokens open it
do
	-- reload the trap as a module from its own file
	local snap = SIM_snapshot()
	call(dofile, { VT_EFF .. "b0215909.lua" }, "x", function(m) SIM_flag("TRAP_LOAD " .. m) end)
	MODS["trap"] = SIM_diff(snap)
	SIM_restore(snap)
end
D = MODS["lib"].PTVT_D
NAME = MODS["lib"].PTVT_NAME
GV0 = MODS["lib"].PTVT_GV0
function ST(n) return GetGlobalValue(GV0 + (n - 1) * 5) end
function MASK(n) return GetGlobalValue(GV0 + (n - 1) * 5 + 1) end
function KEY(n) return GetGlobalValue(GV0 + (n - 1) * 5 + 2) end

-- ---------------------------------------------------------------- T1 entry
SEC("T1 entry: Thien Hung spawn + entry rules")
VT_newplayer(1, "Solo", 25, 1020)
VT_newplayer(7, "BotA", 60, 1020)
VT_call("timer", "PTVT_Tick", {})
-- 2026-10-02 vantien2: Thien Hung template 247 (gate look) -> PTVT_TH[4] = 202 (passerby054, human)
TH_TPL = MODS["lib"].PTVT_TH[4]
local th = VT_npcs(1020, TH_TPL)
CHK(TH_TPL == 202 and getn(th) == 1, "tick spawned Thien Hung (template 202, human look) in Tay Ky 1020")
CHK(th[1] and ENG.npcs[th[1]].script == "\\script\\phongthan\\vantien\\vt_thienhung.lua", "Thien Hung has the dialog script")
CHK(th[1] and ENG.npcs[th[1]].x == 50464 and ENG.npcs[th[1]].y == 96896, "Thien Hung at mps 50464,96896")
CHK(getn(ENG.reload) == 26, "first tick registered 18 loose scripts (vt_mob added) + 8 VNG trap scripts (" .. getn(ENG.reload) .. ")")
VT_call("timer", "PTVT_Tick", {})
CHK(getn(VT_npcs(1020, TH_TPL)) == 1 and getn(ENG.reload) == 26, "second tick: no duplicate NPC, no re-register")
local o = VT_talk("th", "main", 1)
CHK(VT_hasopt(o, "th_enter1") and VT_hasopt(o, "th_enter4") and VT_hasopt(o, "no"), "Thien Hung menu: 4 tran + exit" .. o)
VT_talk("th", "th_enter1", 1)
CHK(P[1].map == 1020 and IsMission(1) == 0, "level 25 refused")
P[1].level = 45
VT_talk("th", "th_enter2", 1)
CHK(P[1].map == 1020, "level 45 refused for Thuy (needs 51 or Tho cleared)")
VT_talk("th", "th_enter1", 1)
SubWorld = 1079
CHK(IsMission(1) == 1 and ST(1) == 1, "level 45 opened Tho on demand (mission 1, state 1 = preparation)")
CHK(P[1].map == 1079 and P[1].x == D[1].entry[1] and P[1].y == D[1].entry[2], "teleported to the Tho entry")
CHK(P[1].fight == 0 and P[1].lrv == 1 and P[1].task[2005] == 1079 and P[1].task[2003] == KEY(1), "fight 0 during preparation, logout-revive on, tasks 2005/2003 set")
local ms = VT_ms(1079, 1)
CHK(getn(ms.pl) == 1 and ms.pl[1].pi == 1, "player registered in mission 1")
CHK(getn(ms.npcs) == 4 + 12 + 3, "mission NPCs: 4 tien + 12 mobs + 3 Dai phu (" .. getn(ms.npcs) .. ")")
local tien = { VT_npcs(1079, 1904)[1], VT_npcs(1079, 1905)[1], VT_npcs(1079, 1906)[1], VT_npcs(1079, 1907)[1] }
CHK(tien[4] and ENG.npcs[tien[1]].rev == 1555200 and ENG.npcs[tien[1]].script == "\\script\\phongthan\\vantien\\vt_boss.lua", "tien: boss script + no revive")
CHK(ms.timers[6] and ms.timers[6].left == 20 * 18, "start timer 6 = 20 s preparation")
-- a second player joins the running session (no reopen)
VT_newplayer(2, "Friend", 70, 1020)
VT_talk("th", "th_enter1", 2)
CHK(P[2].map == 1079 and getn(VT_ms(1079, 1).pl) == 2, "second player joins the same session")

-- ---------------------------------------------------------------- T2 mission flow
SEC("T2 mission flow: start, kills, Thong Thien, clear")
VT_kill(tien[1], 1)
CHK(MASK(1) == 0 and HaveNormalItem(3, 66, 0, 0) == 0, "no kill credit during preparation")
VT_advance(20 * 18)
ms = VT_ms(1079, 1)
CHK(ST(1) == 2 and P[1].fight == 1 and P[2].fight == 1, "start timer: state 2, players in fight state")
CHK(ms.timers[6] == nil and ms.timers[2] and ms.timers[2].left == 1800 * 18, "timer 6 stopped, end timer 2 = 30 min")
ENG.npcs[tien[1]].dead = nil
-- bot (not in the mission) lands the last hit of tien 1: participants still get the token
P[7].map = 1079
VT_kill(tien[1], 7)
PlayerIndex = 1
CHK(HaveNormalItem(3, 66, 0, 0) == 1, "Solo got Thanh long lenh (bot killed Ô Vân)")
PlayerIndex = 2
CHK(HaveNormalItem(3, 66, 0, 0) == 1, "Friend got Thanh long lenh")
PlayerIndex = 7
CHK(HaveNormalItem(3, 66, 0, 0) == 0, "bot outside the mission got nothing")
VT_call("boss", "LastDamage", { tien[1] }, nil, 1)
VT_call("boss", "LastDamage", { tien[1] }, nil, 1)
PlayerIndex = 1
CHK(HaveNormalItem(3, 66, 0, 0) == 1 and MASK(1) == 1, "duplicate LastDamage: no second token")
o = VT_talk("dp", "main", 1)
CHK(not VT_hasopt(o, "dp_boss"), "Dai phu: no Thong Thien teleport before 4 tien")
VT_kill(tien[2], 1)
VT_kill(tien[3], 2)
CHK(getn(VT_npcs(1079, 1908)) == 0, "Thong Thien not yet spawned after 3 tien")
VT_kill(tien[4], 1)
local tt = VT_npcs(1079, 1908)
CHK(MASK(1) == 15 and getn(tt) == 1, "4 tien killed: Thong Thien spawned")
CHK(tt[1] and ENG.npcs[tt[1]].x == D[1].tt[1] * 32 and ENG.npcs[tt[1]].rev == 1555200, "Thong Thien at the Than Bi Tran Diem cell, no revive")
PlayerIndex = 1
CHK(HaveNormalItem(3, 66, 0, 0) == 1 and HaveNormalItem(3, 67, 0, 0) == 1 and HaveNormalItem(3, 68, 0, 0) == 1 and HaveNormalItem(3, 69, 0, 0) == 1, "Solo holds the 4 lenh")
-- VNG trap (script.pak b0215909, Tho trap 1) accepts the tokens
VT_call("trap", "main", { 0 }, nil, 1)
PlayerIndex = 1
CHK(P[1].x == 1336 and P[1].y == 3212 and HaveNormalItem(3, 66, 0, 0) == 0, "VNG trap: 4 lenh -> SetPos(1336,3212) Than Bi Tran Diem, lenh consumed")
o = VT_talk("dp", "main", 2)
CHK(VT_hasopt(o, "dp_boss"), "Dai phu offers the Thong Thien teleport")
VT_talk("dp", "dp_boss", 2)
CHK(P[2].x == D[1].doctors[2][1] and P[2].y == D[1].doctors[2][2] and P[2].fight == 1, "Dai phu teleport into the Thong Thien area")
local exp0, cash0 = P[1].exp, P[1].cash
VT_kill(tt[1], 2)
CHK(ST(1) == 3 and MASK(1) == 31, "Thong Thien killed: state 3 (cleared)")
local chests = VT_npcs(1079, 1929)
CHK(getn(chests) == 4 and ENG.npcs[chests[1]].script == "\\script\\phongthan\\vantien\\vt_chest.lua", "4 chests spawned with the chest script")
CHK(P[1].exp - exp0 == 600 * 45 and P[1].cash - cash0 == 10000, "clear reward Solo: 600 x level 45 exp, 10000 money")
PlayerIndex = 1
CHK(HaveNormalItem(3, 110, 0, 0) == 1, "clear reward: 1 Dia Tam (Tho element)")
CHK(P[1].task[2000] == 1 and P[1].task[2004] == KEY(1) and P[1].task[2002] == 1 and P[1].task[2001] == 20261002, "progress bit 1, chest eligibility key, daily count 1")
CHK(P[2].task[2000] == 1 and P[2].exp == 600 * 70, "Friend rewarded too (level 70)")

-- ---------------------------------------------------------------- T3 chest rewards
SEC("T3 chest rewards")
VT_newplayer(3, "Late", 50, 1020)
VT_talk("th", "th_enter1", 3)
CHK(P[3].map == 1079 and getn(VT_ms(1079, 1).pl) == 3, "late player joins the cleared session (others inside)")
RND = { 10, 10, 50, 50, 70, 70, 90, 90 }   -- 2 eligible participants per chest (Solo, Friend)
exp0, cash0 = P[1].exp, P[1].cash
local e3 = P[3].exp
local k
for k = 1, 4 do VT_kill(chests[k], 1) end
CHK(P[1].exp - exp0 == 4 * 300 * 45 and P[1].cash - cash0 == 4 * 3000, "4 chests: 4 x (300 x 45 exp + 3000 money)")
PlayerIndex = 1
CHK(HaveNormalItem(3, 110, 0, 0) == 2, "roll 10 -> Dia Tam")
CHK(HaveNormalItem(3, 77, 0, 0) == 1, "roll 50 -> Manh Hong thuy tinh")
CHK(HaveNormalItem(3, 78, 0, 0) == 1, "roll 70 -> Manh Lam thuy tinh")
CHK(HaveNormalItem(3, 136, 0, 0) == 1, "roll 90 -> Hoan Nguyen Thach")
CHK(P[3].exp == e3, "late player (no Thong Thien credit) gets nothing from chests")
CHK(GetGlobalValue(GV0 + 4) == 4, "chest counter 4")
P[2].bagfull = 1
RND = { 99 }
VT_kill(chests[1], 1)
CHK(GetGlobalValue(GV0 + 4) == 4, "a broken chest stays dead (no revive): no second reward")
P[2].bagfull = nil

-- ---------------------------------------------------------------- T2b leave + advance 1 -> 4
SEC("T2b leave and advance tran 1 -> 4")
VT_talk("dp", "dp_leave", 3)
CHK(P[3].map == 1020 and P[3].fight == 0 and P[3].lrv == 0 and P[3].task[2005] == 0, "Late leaves to Tay Ky (fight 0, logout-revive off)")
CHK(VT_ms(1079, 1).pl[3].avail == 0, "OnLeave marks the mission slot unavailable")
VT_talk("dp", "dp_leave", 2)
o = VT_talk("dp", "main", 1)
CHK(VT_hasopt(o, "dp_next"), "Dai phu offers the next tran after the clear")
o = VT_talk("dp", "dp_status", 1)
CHK(VT_hasopt(o, "main"), "Dai phu status page")
VT_talk("dp", "dp_sale", 1)
CHK(P[1].sale == 1, "Dai phu opens shop 1 (medicine)")
VT_talk("dp", "dp_entry", 1)
CHK(P[1].x == D[1].entry[1] and P[1].y == D[1].entry[2], "Dai phu: back to the entry")
o = VT_talk("th", "th_info", 1)
CHK(VT_hasopt(o, "main") and VT_hasopt(o, "no"), "Thien Hung info page")
function VT_clear(n, pi)
	SubWorld = PTVT_MAPS_SIM[n]
	VT_advance(PREP_FRAMES)
	local base = 1904 + (n - 1) * 5
	local j
	for j = 0, 3 do VT_kill(VT_npcs(PTVT_MAPS_SIM[n], base + j)[1], pi) end
	VT_kill(VT_npcs(PTVT_MAPS_SIM[n], base + 4)[1], pi)
end
PTVT_MAPS_SIM = { 1079, 1080, 1081, 1082 }
PTVT_POW = { 1, 3, 7, 15 }
PREP_FRAMES = 20 * 18
for n = 2, 4 do
	VT_talk("dp", "dp_next", 1)
	SubWorld = PTVT_MAPS_SIM[n]
	CHK(P[1].map == PTVT_MAPS_SIM[n] and IsMission(n) == 1, "advanced to tran " .. n .. " (map " .. PTVT_MAPS_SIM[n] .. ") at level 45 thanks to the previous clear")
	local prev = VT_ms(PTVT_MAPS_SIM[n - 1], n - 1)
	CHK(prev and prev.pl[1].avail == 0, "left tran " .. (n - 1) .. " (OnLeave)")
	VT_clear(n, 1)
	CHK(ST(n) == 3 and P[1].task[2000] == PTVT_POW[n], "tran " .. n .. " cleared, progress mask " .. tostring(P[1].task[2000]))
end
o = VT_talk("dp", "main", 1)
CHK(not VT_hasopt(o, "dp_next"), "tran 4: no next tran option")
PlayerIndex = 1
CHK(HaveNormalItem(3, 111, 0, 0) == 1 and HaveNormalItem(3, 112, 0, 0) == 1 and HaveNormalItem(3, 113, 0, 0) == 1, "element materials of Thuy/Hoa/Phong received")
VT_talk("dp", "dp_leave", 1)
CHK(P[1].map == 1020 and P[1].lrv == 0, "left tran 4 to Tay Ky")
-- end timer closes the missions and cleans the NPCs
SubWorld = 1082
local npcs4 = VT_ms(1082, 4).npcs
VT_advance(1800 * 18)
SubWorld = 1082
CHK(IsMission(4) == 0 and ST(4) == 0, "end timer: mission 4 closed, state 0")
CHK(ENG.npcs[npcs4[1]].deleted == 1, "mission NPCs removed by StopMission")
SubWorld = 1079
CHK(IsMission(1) == 0, "mission 1 closed by its end timer")

-- ---------------------------------------------------------------- T2c end with a player inside, daily cap
SEC("T2c timer end kicks players out; daily cap")
VT_talk("th", "th_enter1", 1)
SubWorld = 1079
CHK(IsMission(1) == 1 and P[1].map == 1079, "Tho reopened")
VT_advance(PREP_FRAMES)
VT_advance(1800 * 18)
SubWorld = 1079
CHK(IsMission(1) == 0 and P[1].map == 1020 and P[1].fight == 0 and P[1].lrv == 0, "end timer kicked the player to Tay Ky")
-- second clear today: rewarded, third: not
VT_talk("th", "th_enter1", 1)
VT_clear(1, 1)
CHK(P[1].task[2002] == 1112, "second Tho clear rewarded (daily digit 2) " .. tostring(P[1].task[2002]))
-- restart while cleared and empty -> new session
VT_talk("dp", "dp_leave", 1)
local key1 = KEY(1)
VT_talk("th", "th_enter1", 1)
CHK(KEY(1) ~= key1 and ST(1) == 1, "cleared + empty session restarted with a new key")
exp0 = P[1].exp
VT_clear(1, 1)
CHK(P[1].exp == exp0 and P[1].task[2002] == 1112, "third Tho clear today: no reward (cap 2)")
exp0 = P[1].exp
VT_kill(VT_npcs(1079, 1929)[1], 1)
CHK(P[1].exp == exp0, "chests give nothing beyond the cap")
CLOCK.ymd = "20261003"
VT_talk("dp", "dp_leave", 1)
VT_talk("th", "th_enter1", 1)
VT_clear(1, 1)
CHK(P[1].task[2002] == 1 and P[1].task[2001] == 20261003, "next day: counter reset, rewarded again")

-- ---------------------------------------------------------------- T4 minute tick: schedule + sweep
SEC("T4 schedule and sweep")
VT_talk("dp", "dp_leave", 1)
SubWorld = 1079
CloseMission(1)
CLOCK.hm = "10:05"
VT_call("timer", "PTVT_Tick", {})
SubWorld = 1080
CHK(IsMission(2) == 1 and VT_ms(1080, 2).timers[7].left == 300 * 18, "10:05 schedule opened Thuy with 5 min preparation")
SubWorld = 1079
CHK(IsMission(1) == 0, "10:05 does not open Tho")
-- relog inside an open tran: re-registered by the sweep
P[5] = nil
VT_newplayer(5, "Relog", 60, 1080)
VT_call("timer", "PTVT_Tick", {})
SubWorld = 1080
CHK(PIdx2MSDIdx(2, 5) > 0 and P[5].lrv == 1, "sweep re-registered a player found inside the open tran")
-- standing in a closed tran: sent to Tay Ky
VT_newplayer(6, "Lost", 60, 1081)
P[6].task[2005] = 1081
VT_call("timer", "PTVT_Tick", {})
CHK(P[6].map == 1020 and P[6].task[2005] == 0, "sweep moved a player out of a closed tran")
P[6].task[2005] = 1081
P[6].lrv = 1
VT_call("timer", "PTVT_Tick", {})
CHK(P[6].task[2005] == 0 and P[6].lrv == 0, "sweep cleared the leftover flag outside")

-- ---------------------------------------------------------------- report
SEC("log (last 12)")
local n0 = getn(ENG.log) - 11
if n0 < 1 then n0 = 1 end
for k = n0, getn(ENG.log) do write("  " .. ENG.log[k] .. "\n") end
local fk = SIM_keys(FLAGS)
for k = 1, getn(fk) do write("FLAG " .. fk[k] .. "\n") end
write("RESULT ok=" .. VT_OK .. " fail=" .. VT_FAIL .. " flags=" .. getn(fk) .. "\n")
writeto()
