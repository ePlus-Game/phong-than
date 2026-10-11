-- newbie2 simulator test (2026-10-03): new-era newbie chain (taskinfo 894-925, 999-1010, 3003-3005).
-- Run: run.ps1 -Main sim_newbie2.lua (32-bit PowerShell) -> out_newbie2.txt
-- Plays the whole chain for each profession (Quan Su -> ... -> Tru Hoa -> Tru Hang), all 14 mat tich, checks the
-- old 2004 drops (mob_drop.lua) still run through nb2_mob.lua and that only task ids 2180-2219 are written.
dofile("sim.lua")
dofile("sim_nb2_npcs.lua")
writeto("out_newbie2.txt")
_ERRORMESSAGE = function(m) write("ERR " .. m .. "\n") end
FAILS = 0
function CHECK(cond, what) if cond then write("  ok   " .. what .. "\n") else write("  FAIL " .. what .. "\n") FAILS = FAILS + 1 end end
function L(s) write(s .. "\n") end

-- ------------------------------------------------------------------ world / engine stubs (state in tables only)
SIMW = { npcn = 0, time = 1000, notes = {}, msgs = {}, writes = {}, timers = {}, reload = {} }
NPC = {}
function SIM_addnpc(name, map, tpl, x, y)
	SIMW.npcn = SIMW.npcn + 1
	local i = SIMW.npcn
	NPC[i] = { name = name, map = map, tpl = tpl, x = x, y = y, id = 100000 + i, param = {}, script = nil }
	return i
end
function GetName() if PlayerIndex == 1 then return "Tester" end return nil end
function GetProfession() return W.ptype end
function GetPlayerID() if PlayerIndex == 1 then return 777 end return nil end
function GetGameTime() return SIMW.time end
function GetWorldPos() return W.map, W.x, W.y end
function SetTask(i, v) W.task[i] = v SIMW.writes[i] = 1 end
function GetNpcName(i) if NPC[i] then return NPC[i].name end return "" end
function GetNpcPos(i) if NPC[i] then return NPC[i].map, NPC[i].x, NPC[i].y end return 0, 0, 0 end
function GetNpcTemplateID(i) if NPC[i] then return NPC[i].tpl end return 0 end
function GetNpcID(i) if NPC[i] then return NPC[i].id end return 0 end
function SetNpcName(i, s) if NPC[i] then NPC[i].name = s end end
function SetNpcScript(i, s) if NPC[i] then NPC[i].script = s end end
function SetNpcParam(i, k, v) if NPC[i] then NPC[i].param[k] = v end end
function GetNpcParam(i, k) if NPC[i] then return NPC[i].param[k] or 0 end return 0 end
function SetNpcTimeout(i, f) if NPC[i] then NPC[i].timeout = f end end
function SetNpcTimer(i, s, sec) SIMW.timers[i] = s end
function DelNpc(i) NPC[i] = nil end
function SubWorldID2Idx(m) return m end
function AddNpc(tpl, lv, sw, x, y, b) return SIM_addnpc("tpl" .. tpl, sw, tpl, floor(x / 32), floor(y / 32)) end
function ReLoadScript(p) SIMW.reload[p] = 1 return 1 end
function HaveMagic(id) return W.magic and W.magic[id] or -1 end
function AddNote(a, b, text, d) tinsert(SIMW.notes, text) end
function Msg2Player(s) tinsert(SIMW.msgs, s) end
function RemoveItem(idx, n, x) if SIM_ITEMS[idx] then SIM_iadd(SIM_ITEMS[idx], -1) SIM_ITEMS[idx] = nil end return 1 end
function GetItemPartByID(idx) if SIM_ITEMS[idx] then return SIMW.itempart[idx] end return 0 end
function RestoreLife() end
function RestoreMana() end
function GetNpcIdx() return SIMW.curnpc or 0 end
function CalcFreeItemCellCount() return 30 end
function Sale(n) SIMW.sale = n end
SIM_ITEMS = {}
SIMW.itempart = {}
function giveitem(g, d, p, idx)
	SIM_iadd(SIM_ikey(g, d, p), 1)
	if idx then SIM_ITEMS[idx] = SIM_ikey(g, d, p) SIMW.itempart[idx] = p end
end
PT_TaskNote_C = function(id, st) tinsert(SIMW.notes, "NATIVE " .. id .. ":" .. st) end

-- ------------------------------------------------------------------ module loader (own globals per script)
function LOADP(name, path)
	local snap = SIM_snapshot()
	CUR_SCRIPT = name
	LERR = nil
	call(dofile, { path }, "x", function(m) LERR = m end)
	local e = LERR
	MODS[name] = SIM_diff(snap)
	MODS[name].CUR_SCRIPT = nil
	MODS[name].LERR = nil
	SIM_restore(snap)
	CHECK(e == nil, "load " .. name .. (e and (" " .. e) or ""))
end
function RUN(name, fn, args)
	DLG = nil
	PlayerIndex = 1
	SIM_run(name, fn, args or {})
	if SIM_ERR then L("  !! " .. name .. ":" .. fn .. " " .. SIM_ERR) FAILS = FAILS + 1 end
	return SIM_ERR == nil
end
function hasopt(fn)
	if not DLG then return nil end
	for i = 1, getn(DLG.opts) do if DLG.opts[i].fn == fn then return 1 end end
	return nil
end

-- ------------------------------------------------------------------ world population
PT_SPAWN_DONE = 1
PT_SPAWN_NPCS = {}
PT_SPAWN_NPCN = 0
for k = 1, getn(SIMNB2_NPCS) do
	local r = SIMNB2_NPCS[k]
	SIM_addnpc(r[2], r[1], 158, r[3], r[4])
end
-- field monsters of spawn_main (PT_SPAWN_NPCS) and the VNG region monsters of 1014/1016
FIELDMOBS = { { 0, 1005 }, { 1, 1008 }, { 2, 1013 }, { 4, 1008 }, { 5, 1011 }, { 6, 1011 }, { 7, 1007 }, { 7, 1015 }, { 8, 1009 },
	{ 9, 1012 }, { 11, 1005 }, { 13, 1015 }, { 15, 1017 }, { 24, 1018 }, { 3, 1006 }, { 16, 1017 }, { 9, 1011 }, { 9, 1010 }, { 16, 1010 }, { 13, 1018 } }
for k = 1, getn(FIELDMOBS) do
	local m = FIELDMOBS[k]
	local i = SIM_addnpc("mob" .. m[1], m[2], m[1], 1500 + k * 7, 3100 + k * 9)
	PT_SPAWN_NPCN = PT_SPAWN_NPCN + 1
	PT_SPAWN_NPCS[PT_SPAWN_NPCN] = i
	if m[1] == 0 or m[1] == 1 or m[1] == 2 or m[1] == 4 or m[1] == 6 or m[1] == 8 or m[1] == 3 then i = i end
end
REGIONMOBS = { { 10, 1014 }, { 12, 1014 }, { 11, 1016 }, { 15, 1016 }, { 18, 1016 } }
for k = 1, getn(REGIONMOBS) do SIM_addnpc("reg" .. REGIONMOBS[k][1], REGIONMOBS[k][2], REGIONMOBS[k][1], 1400 + k * 5, 3300) end
OTHER = SIM_addnpc("questmob", 1006, 100, 1700, 3300)   -- PTADM_MOB_SPAWN-like mob: must not be re-bound
NOTBOUND_FIELD = SIM_addnpc("strayKiemNhan", 1005, 0, 1450, 3000)   -- not in PT_SPAWN_NPCS, not 1014/1016

-- ------------------------------------------------------------------ load modules
NB2 = SRV .. "\\script\\phongthan\\newbie2\\"
LOADP("ext", SRV .. "\\script\\phongthan\\ext\\newbie2.lua")
LOADP("qs", NB2 .. "quan_su.lua")
LOADP("mob", NB2 .. "nb2_mob.lua")
LOADP("dp", NB2 .. "nb2_dp.lua")
LOADP("scroll", NB2 .. "nb2_scroll.lua")
for _, m in { "ext", "qs", "mob", "dp", "scroll" } do MODS[m].PTNB2_MAX_NPC = 1000 MODS[m].PTNB2_Err = function(e) L("  LUAERR " .. tostring(e)) FAILS = FAILS + 1 end end
D = MODS["ext"]   -- data tables (same in every module)

function tick() SIMW.time = SIMW.time + 60 * 18 RUN("ext", "PTEXT_newbie2_Tick") end
function qspoll() SIMW.time = SIMW.time + 3 * 18 RUN("qs", "OnTimer", { QS1 }) end

L("==================== ext tick: register, NPCs, monster binding")
tick()
tick()
CHECK(SIMW.reload["\\script\\phongthan\\newbie2\\quan_su.lua"] and SIMW.reload["\\script\\phongthan\\newbie2\\nb2_mob.lua"], "loose scripts registered (ReLoadScript)")
local nstub = 0
for p, v in SIMW.reload do if strfind(p, "\\script\\item\\", 1, 1) then nstub = nstub + 1 end end
CHECK(nstub == 14, "14 mat tich stubs registered (" .. nstub .. ")")
QSN = {}
local ndoc = 0
for i, n in NPC do
	if n.name == D.PTNB2_TXT.qs_name then QSN[n.map] = i end
	if n.name == D.PTNB2_N_DPTS or n.name == D.PTNB2_N_DPDQ then ndoc = ndoc + 1 end
end
QS1 = QSN[1002]
CHECK(QSN[1002] and QSN[1003] and QSN[1004], "3 Quan Su spawned (1002/1003/1004)")
CHECK(NPC[QS1].x == 1632 and NPC[QS1].y == 3200 and NPC[QS1].tpl == 211, "Quan Su 1002 at taskinfo 3003 [2,204,200]")
CHECK(ndoc == 2, "2 field doctors spawned (Tam Son, Dong Quan)")
CHECK(SIMW.timers[QS1] == "\\script\\phongthan\\newbie2\\quan_su.lua", "Quan Su poll timer armed")
local cnt = 0
for i, n in NPC do if n.name == D.PTNB2_TXT.qs_name then cnt = cnt + 1 end end
CHECK(cnt == 3, "second tick spawns nothing more (" .. cnt .. " Quan Su)")
local bound, bad = 0, 0
for i, n in NPC do
	if n.script == D.PTNB2_MOB_SCRIPT then bound = bound + 1 end
end
local want = 0
for k = 1, getn(FIELDMOBS) do if D.PTNB2_BIND_TID[FIELDMOBS[k][1]] then want = want + 1 end end
CHECK(bound == want + getn(REGIONMOBS), "target monsters bound to nb2_mob.lua (" .. bound .. ")")
CHECK(NPC[OTHER].script == nil and NPC[NOTBOUND_FIELD].script == nil, "quest mob / non-population NPC not re-bound")

-- ------------------------------------------------------------------ helpers to play
function findnpc(map, name)
	for i, n in NPC do if n.map == map and n.name == name then return i, n end end
	return nil
end
function findmob(tids, maps, w)
	for i, n in NPC do
		if n.script == D.PTNB2_MOB_SCRIPT and (n.param[0] or 0) == 0 then
			local okt = (tids == nil)
			if tids then for k = 1, getn(tids) do if tids[k] == n.tpl then okt = 1 end end end
			local okm = (maps == nil)
			if maps then for k = 1, getn(maps) do if maps[k] == n.map then okm = 1 end end end
			if w and n.map ~= w then okm = nil end
			if okt and okm then return i, n end
		end
	end
	return nil
end
function goto(i) W.map, W.x, W.y = NPC[i].map, NPC[i].x + 1, NPC[i].y + 2 end
function kill(i)
	W.map = NPC[i].map
	RUN("mob", "LastDamage", { i })
	if NPC[i] then RUN("mob", "DeathSelf", { i }) end
end
function cur()
	local p = W.ptype
	local qi = GetTask(2180)
	local e = D.PTNB2_CHAIN[p][qi]
	if not e then return nil end
	local q = D.PTNB2_Q[e[1]]
	local s = GetTask(2184)
	return q, s, q.s[s], qi
end
function tempmobs()
	local r = {}
	for i, n in NPC do if (n.param[0] or 0) == D.PTNB2_TAG then tinsert(r, i) end end
	return r
end
function notehas(id, txt)
	local t = MODS["ext"].PT_TASKINFO
	return 1
end

function playstep(q, s, st)
	if st.go then
		if st.lv and W.level < st.lv then W.level = st.lv end
		if st.book then giveitem(6, 1, st.book[2]) end
		local i = findnpc(st.go[1], st.go[2][1])
		if not i then L("  no NPC for step " .. q.id .. ":" .. s) return nil end
		goto(i)
		qspoll()
	elseif st.go2 then
		for k = 1, 2 do
			local i = findnpc(st.go2[k][1], st.go2[k][2][1])
			goto(i)
			qspoll()
		end
	elseif st.kill then
		for k = 1, st.kill.need do
			local i = findmob(st.kill.tids, st.kill.maps)
			if not i then L("  no mob for " .. q.id) return nil end
			kill(i)
		end
	elseif st.coll then
		if st.mark then kill(findmob(st.mark.tids, st.mark.maps)) end
		for g = 1, getn(st.coll) do
			local cg = st.coll[g]
			for k = 1, cg.need do
				local i = findmob(cg.tids, cg.maps)
				if not i then L("  no mob for coll " .. q.id) return nil end
				kill(i)
			end
		end
	elseif st.chest then
		W.map, W.x, W.y = 1002, 1600, 3200
		qspoll()
		CHECK(getn(tempmobs()) == 0, q.id .. " no Yeu Ma inside the village")
		W.map, W.x, W.y = 1005, 1700, 3000
		qspoll()
		local t = tempmobs()
		CHECK(getn(t) == st.chest, q.id .. " chest opened outside: " .. getn(t) .. " Yeu Ma (tpl 573, owner param)")
		for k = 1, getn(t) do
			CHECK(NPC[t[k]].tpl == 573 and NPC[t[k]].param[1] == 777, "  Yeu Ma " .. k .. " template/owner")
			kill(t[k])
		end
		CHECK(getn(tempmobs()) == 0, q.id .. " Yeu Ma removed after death (DeathSelf -> DelNpc)")
	elseif st.king then
		local guard = 0
		while guard < 10 do
			local q2, s2 = cur()
			if q2 ~= q or s2 ~= s then break end
			local t = tempmobs()
			if getn(t) > 0 then
				for k = 1, getn(t) do L("    king spawned tpl " .. NPC[t[k]].tpl .. " owner " .. tostring(NPC[t[k]].param[1])) kill(t[k]) end
			else
				local i = findmob({ st.king.tid }, st.king.maps)
				if not i then L("  no base mob for king " .. q.id) return nil end
				for k = 1, st.king.every do kill(i) end
			end
			guard = guard + 1
		end
	end
	return 1
end

function playchain(p)
	SIM_newworld(p, 1)
	W.x, W.y = 1600, 3200
	W.map = D.PTNB2_VILLAGE[p]
	W.magic = {}
	SIMW.notes = {}
	SIMW.msgs = {}
	SIMW.writes = {}
	L("==================== profession " .. p .. " (map " .. W.map .. ")")
	qspoll()
	CHECK(GetTask(2194) == 1 and getn(SIMW.notes) >= 1, "F11 hint 300" .. (3 + p) .. " shown once (" .. tostring(SIMW.notes[1]) .. ")")
	local nn = getn(SIMW.notes)
	qspoll()
	CHECK(getn(SIMW.notes) == nn, "hint not repeated")
	SIMW.curnpc = QSN[D.PTNB2_VILLAGE[p]]
	RUN("qs", "main")
	CHECK(hasopt("PTNB2_QsStart") and hasopt("no"), "Quan Su menu offers Mao Lu + exit row")
	RUN("qs", "PTNB2_QsStart")
	local q, s = cur()
	CHECK(q and q.id == D.PTNB2_CHAIN[p][1][1] and s >= 1, "Mao Lu accepted (" .. (q and q.id or "-") .. " step " .. tostring(s) .. ")")
	local done = {}
	local guard = 0
	local exp0 = W.exp
	while guard < 400 do
		guard = guard + 1
		q, s, st = cur()
		if not q then break end
		if s == 0 then
			W.level = q.lv
			qspoll()
		else
			local before = q.id .. ":" .. s
			if not playstep(q, s, st) then break end
			local q2, s2 = cur()
			local after = (q2 and (q2.id .. ":" .. s2)) or "end"
			if after == before and st.ti then
				-- turn-in at Quan Su instead of walking
				SIMW.curnpc = QSN[D.PTNB2_VILLAGE[p]]
				RUN("qs", "PTNB2_QsReport")
				L("    (turn-in via Quan Su report)")
				q2, s2 = cur()
				after = (q2 and (q2.id .. ":" .. s2)) or "end"
			end
			L("    " .. before .. " -> " .. after)
			if after == before then L("  STUCK at " .. before) FAILS = FAILS + 1 break end
			if not q2 or q2 ~= q then done[q.id] = 1 end
		end
	end
	local ch = D.PTNB2_CHAIN[p]
	local all = 1
	for k = 1, getn(ch) do if not done[ch[k][1]] then all = nil L("  not done: " .. ch[k][1]) end end
	CHECK(all and GetTask(2180) == getn(ch) + 1, "whole chain finished: " .. getn(ch) .. " quests, task 2180=" .. GetTask(2180))
	CHECK(W.exp > exp0, "experience rewarded (" .. (W.exp - exp0) .. ")")
	CHECK(SIM_icount("1,0,1") > 0 and SIM_icount("1,3,1") > 0, "potion rewards in bag")
	local sc = 0
	for k, v in W.items do if strfind(k, "6,1,3", 1, 1) == 1 then sc = sc + v end end
	CHECK(sc >= 2, "mat tich rewards / drops in bag (" .. sc .. ")")
	local fin = 0
	for k = 1, getn(SIMW.notes) do if strfind(SIMW.notes[k], D.PTNB2_TXT.completed, 1, 1) or strfind(SIMW.notes[k], "Nhi\214m v\244 ho\181n th\181nh", 1, 1) then fin = fin + 1 end end
	CHECK(fin >= getn(ch), "F11 'Nhiem vu hoan thanh' note for every quest (" .. fin .. ")")
	local nat = 0
	for k = 1, getn(SIMW.notes) do if strfind(SIMW.notes[k], "NATIVE", 1, 1) then nat = nat + 1 L("  native note " .. SIMW.notes[k]) end end
	CHECK(nat == 0, "every note rendered from taskinfo (no native 'Task N - step S')")
	local badw = ""
	for k, v in SIMW.writes do if k < 2180 or k > 2219 then badw = badw .. " " .. k end end
	CHECK(badw == "", "only task ids 2180-2219 written" .. badw)
	CHECK(getn(tempmobs()) == 0, "no temporary monster left")
end

for p = 0, 2 do playchain(p) end

-- ------------------------------------------------------------------ mat tich (all 14)
L("==================== mat tich / lenh 914-925, 1009, 1010")
SIM_newworld(0, 30)
W.x, W.y, W.map = 1600, 3200, 1002
SIMW.writes = {}
SIMW.notes = {}
local idx = 5000
for i = 1, getn(D.PTNB2_SCROLL) do
	local sc = D.PTNB2_SCROLL[i]
	idx = idx + 1
	giveitem(6, 1, sc[1], idx)
	RUN("scroll", "PTNB2_ScrollUse", { idx, sc[1] })
	CHECK(hasopt("PTNB2_ScrollYes") and hasopt("no"), sc[2] .. " item opens accept dialog")
	RUN("scroll", "PTNB2_ScrollYes")
	CHECK(SIM_icount(SIM_ikey(6, 1, sc[1])) == 0, sc[2] .. " item consumed")
	RUN("scroll", "PTNB2_ScrollUse", { idx, sc[1] })
	CHECK(not hasopt("PTNB2_ScrollYes"), sc[2] .. " second use refused while active")
	if sc[3] >= 0 then
		local m = findmob({ sc[3] }, nil)
		CHECK(m ~= nil, sc[2] .. " target template " .. sc[3] .. " is bound somewhere")
		for k = 1, sc[4] + 2 do if m then kill(m) end end
	else
		giveitem(3, D.PTNB2_C917[0][2], 0)
		giveitem(3, D.PTNB2_C917[0][2], 0)
	end
end
local active = 0
for i = 1, getn(D.PTNB2_SCROLL) do
	local v = GetByte(GetTask(D.PTNB2_T_SC[floor((i - 1) / 4) + 1]), mod(i - 1, 4) + 1)
	if v > 0 then active = active + 1 end
	if D.PTNB2_SCROLL[i][3] >= 0 then CHECK(v - 1 == D.PTNB2_SCROLL[i][4], D.PTNB2_SCROLL[i][2] .. " kills capped at " .. D.PTNB2_SCROLL[i][4] .. " (" .. (v - 1) .. ")") end
end
CHECK(active == 14, "14 mat tich active and complete")
local e0 = W.exp
goto(findnpc(1002, SIMNB2_NPCS[1][2]))   -- Tap hoa Thuong Sung Thanh
qspoll()
local left = 0
for i = 1, getn(D.PTNB2_SCROLL) do
	local v = GetByte(GetTask(D.PTNB2_T_SC[floor((i - 1) / 4) + 1]), mod(i - 1, 4) + 1)
	if v > 0 then left = left + 1 end
end
CHECK(left == 0, "all 14 turned in at Tap hoa Thuong (left " .. left .. ")")
CHECK(W.exp > e0, "mat tich experience (" .. (W.exp - e0) .. ")")
CHECK(SIM_icount(SIM_ikey(3, D.PTNB2_C917[0][2], 0)) == 0, "Thu thap: 2 materials taken")
local badw = ""
for k, v in SIMW.writes do if k < 2180 or k > 2219 then badw = badw .. " " .. k end end
CHECK(badw == "", "only task ids 2180-2219 written" .. badw)
-- report at Quan Su when nothing is pending
SIMW.curnpc = QS1
RUN("qs", "PTNB2_QsScroll")
CHECK(DLG and DLG.talk, "Quan Su: no finished mat tich -> message")

-- ------------------------------------------------------------------ old chain drops kept
L("==================== coexistence with the 2004 chain")
SIM_newworld(0, 3)
W.task[21] = 3          -- Tan Thuc (Lo Hung): 10 Doan Kiem from Kiem Nhan
local km = findmob({ 0 }, { 1005 })
kill(km)
CHECK(SIM_icount("3,10,0") == 1, "Kiem Nhan still drops Doan Kiem for old task 21=3 (mob_drop.lua chained)")
CHECK(W.task[21] == 3 and W.task[2180] == nil, "old task untouched, new chain not started by a kill")
SIM_newworld(1, 1)
W.map, W.x, W.y = 1003, 1600, 3200
RUN("qs", "PTNB2_QsStatus")
CHECK(DLG and DLG.talk, "status without chain -> message")

-- ------------------------------------------------------------------ report at Quan Su, foreign kill, timeout
L("==================== Quan Su report / foreign kill / timeout")
SIM_newworld(0, 5)
W.map, W.x, W.y = 1002, 1600, 3200
W.task[2180] = 2   -- 907 Tan Thu thi luyen
W.task[2184] = 2   -- step "phuc menh Tap hoa Thuong"
SIMW.curnpc = QS1
local e1 = W.exp
RUN("qs", "PTNB2_QsReport")
CHECK(GetTask(2180) == 3 and GetTask(2184) == 1 and W.exp > e1, "turn-in step accepted at Quan Su; next quest 906 auto-accepted at lv5")
W.task[2184] = 2
RUN("qs", "PTNB2_QsReport")
CHECK(DLG and DLG.talk and GetTask(2184) == 2, "visit step (Tuyet Lo to To Ho) is not accepted at Quan Su")
W.task[2180] = 6   -- 903 Tru yeu
W.task[2184] = 1
W.level = 10
W.map, W.x, W.y = 1006, 1650, 3100
qspoll()
local t = tempmobs()
CHECK(getn(t) == 4, "chest spawned 4 Yeu Ma")
GetPlayerID = function() return 999 end
kill(t[1])
GetPlayerID = function() if PlayerIndex == 1 then return 777 end return nil end
CHECK(GetTask(2185) == 0 and NPC[t[1]] == nil, "Yeu Ma killed by another player: not counted, removed")
RUN("mob", "Timeout", { t[2] })
CHECK(NPC[t[2]] == nil, "Timeout removes a temporary monster")
kill(t[3])
kill(t[4])
CHECK(GetTask(2185) == 2, "owner kills counted (2)")
SIMW.time = SIMW.time + 601 * 18
qspoll()
CHECK(getn(tempmobs()) == 2, "after the 10 min guard the missing 2 Yeu Ma respawn")
L("==================== other dialogs")
SIM_newworld(2, 12)
W.map, W.x, W.y = 1004, 1560, 3216
W.task[2180] = 6
W.task[2184] = 1
SIMW.curnpc = QSN[1004]
RUN("qs", "main")
CHECK(hasopt("PTNB2_QsStatus") and hasopt("PTNB2_QsReport") and hasopt("PTNB2_QsBook") and hasopt("no"), "Quan Su menu with an active quest (status/report/book/exit)")
RUN("qs", "PTNB2_QsStatus")
CHECK(DLG and DLG.talk, "status dialog shows the quest step")
RUN("qs", "PTNB2_QsBook")
CHECK(SIMW.sale == 68, "Di Nhan bi kip shop = Sale(68) (" .. tostring(SIMW.sale) .. ")")
RUN("qs", "PTNB2_QsInfo")
CHECK(DLG and DLG.talk, "info dialog")
local dp = findnpc(1016, D.PTNB2_N_DPTS)
SIMW.curnpc = dp
goto(dp)
RUN("dp", "main")
CHECK(hasopt("PTNB2_DpHeal") and hasopt("no"), "Dai phu Tam Son dialog (heal + exit)")
RUN("dp", "PTNB2_DpHeal")
W.task[2180] = 0
W.task[2184] = 0
RUN("qs", "PTNB2_QsStart")
RUN("qs", "PTNB2_QsStart")
CHECK(GetTask(2180) == 1 and GetTask(2184) == 1, "taking Mao Lu twice does nothing more")
L("FLAGS:")
for k, v in FLAGS do L("  " .. k) end
L("FAILS=" .. FAILS)
writeto()






