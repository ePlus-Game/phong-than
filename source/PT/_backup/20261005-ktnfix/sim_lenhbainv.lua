-- lenhbainv 2026-10-04: "Lenh Bai Nhiem Vu" (61430) + "Lenh Bai Tiep Te Nhiem Vu" (61431) + auto-give (starter_gear.lua).
-- Run: run.ps1 -Main sim_lenhbainv.lua -Stack 100            (engine stack, out_lenhbainv.txt)
--      run.ps1 -Main sim_lenhbainv.lua -Stack 100 -Args1 emu  (entries padded to 47 frames of headroom, the minute tick
--                                                             to 40, like sim_luyencong.lua; out_lenhbainv_emu.txt)
-- Optional "live" in Args1: load the runtime files instead of scratchpad\lenhbainv\out (after deployment).
EMU = (strsub(SIM_ARG or "", 1, 3) == "emu")
LIVE = strfind(SIM_ARG or "", "live", 1, 1)
local outname = "out_lenhbainv"
if EMU then outname = outname .. "_emu" end
if LIVE then outname = outname .. "_live" end
writeto(outname .. ".txt")
FAILS = 0
CHECKS = 0
QUIET = nil
_ERRORMESSAGE = function(m) FAILS = FAILS + 1 write("ERR " .. m .. " [" .. tostring(TRACE) .. "]\n") end
if getinfo then _ERRORMESSAGE = function(m) FAILS = FAILS + 1 local s = "" local l = 2 while l < 12 do local i = getinfo(l) if not i then break end s = s .. " < " .. tostring(i.short_src) .. ":" .. tostring(i.currentline) l = l + 1 end write("ERR " .. m .. " [" .. tostring(TRACE) .. "]" .. s .. "\n") end end
function CHECK(c, what)
	CHECKS = CHECKS + 1
	if c then
		if not QUIET then write("  ok   " .. what .. "\n") end
	else
		FAILS = FAILS + 1 write("  FAIL " .. what .. "\n")
	end
end

OUT = "C:\\Users\\LICHNT~1.OFF\\AppData\\Local\\Temp\\claude\\D--Project-Email-Send\\d0824b0a-6cac-412d-8946-ef7c47e9c425\\scratchpad\\lenhbainv\\out\\"
if LIVE then OUT = "E:\\VL\\Phong than\\PT\\PhongThanRuntime-Staging\\Server\\" end

-- ---------------------------------------------------------------- engine stubs
PL = {}
PlayerIndex = 1
function P() return PL[PlayerIndex] end
function GetName() local p = P() if p then return p.name end return nil end
function GetLevel() return P().level end
function GetProfession() return P().prof end
function GetPlayerType() return P().prof end
function GetTask(i) return P().tasks[i] or 0 end
function SetTask(i, v) P().tasks[i] = v end
function GetWorldPos() local p = P() return p.map, p.x, p.y end
function SetFightState(v) P().fight = v end
function GetByte(v, n) return mod(floor(v / (256 ^ (n - 1))), 256) end
UNLOADED = {}
function SubWorldID2Idx(m) if UNLOADED[m] then return -1 end return m - 1000 end
NWFAIL = nil
NWLOG = {}
function NewWorld(m, x, y)
	tinsert(NWLOG, { m, x, y })
	if NWFAIL then return 0 end
	local p = P() p.map = m p.x = x p.y = y
	return 1
end
LASTSAY = "" LASTN = 0 LASTOPTS = {}
function Say(t, n, ...)
	LASTSAY = t LASTN = n LASTOPTS = {}
	local s = "SAY(" .. n .. ") " .. t
	for i = 1, getn(arg) do s = s .. "\n      | " .. arg[i] LASTOPTS[i] = arg[i] end
	if not QUIET then write(s .. "\n") end
end
MSGS = {}
function Msg2Player(s) tinsert(MSGS, s) if not QUIET then write("MSG " .. s .. "\n") end end
function LASTMSG() return MSGS[getn(MSGS)] or "" end
-- bag: keys "E,n" (event items, stack) / "N,g,d,p,lv" (VNG tuple, stack); each new key takes one free cell
function EKEY(n) return "E," .. n end
function NKEY(g, d, p, lv) return "N," .. g .. "," .. d .. "," .. p .. "," .. lv end
function HaveEventItemCount(n) return P().items[EKEY(n)] or 0 end
function HaveNormalItem(g, d, p, lv)
	local pl = P()
	if lv and lv >= 0 then return pl.items[NKEY(g, d, p, lv)] or 0 end
	local s = 0
	local l = 0
	while l <= 10 do s = s + (pl.items[NKEY(g, d, p, l)] or 0) l = l + 1 end
	return s
end
function HaveMagic(sk) return P().skills[sk] or -1 end
NOCREATE = {}
ADDS = 0
function BagAdd(key)
	local pl = P()
	if NOCREATE[key] then return 0 end
	if not pl.items[key] then
		if pl.free < 1 then return 0 end
		pl.free = pl.free - 1
		pl.items[key] = 0
	end
	pl.items[key] = pl.items[key] + 1
	ADDS = ADDS + 1
	return 100 + ADDS
end
function AddEventItem(n) return BagAdd(EKEY(n)) end
function AddNormalItemPile(g, d, p, lv, se, luck) return BagAdd(NKEY(g, d, p, lv)) end
function CalcFreeItemCellCount() return P().free end
NOROW = nil
function AddNormalItem(g, d, p, lv, se, luck)   -- token gift (never stacks)
	local pl = P()
	if pl.bagfull or NOROW or pl.free < 1 then return 0 end
	pl.free = pl.free - 1
	local k = NKEY(g, d, p, lv)
	pl.items[k] = (pl.items[k] or 0) + 1
	ADDS = ADDS + 1
	return 100 + ADDS
end
-- starter_gear.lua stubs
function AddItem(g, d, p, lv, se, luck) return 200 end
function AddItemID(i, x) end
function PTAdm_Log(id, st, txt) if not QUIET then write("LOG " .. id .. " " .. st .. " " .. txt .. "\n") end end
PTADM_MAX_PLAYER = 4
TICKERR = 0
function PTAdm_TickErr(m) TICKERR = TICKERR + 1 write("TICKERR " .. tostring(m) .. "\n") end
function PTAdm_Safe(fn) if fn then call(fn, {}, "x", PTAdm_TickErr) end end
DATEV = 20261004
function date(f) return "" .. DATEV end
ORIG_DOFILE = dofile
function dofile(p)
	if strsub(p, 1, 7) == "script\\" then return ORIG_DOFILE(OUT .. p) end
	return ORIG_DOFILE(p)
end

function NEWPLAYER(i, name, lv, map, prof)
	PL[i] = { name = name, level = lv, map = map, x = 1600, y = 3200, fight = 0, tasks = {}, items = {}, prof = prof or 0,
	          skills = {}, free = 60 }
end

-- ---------------------------------------------------------------- engine stack emulation
function HR_R(d) HR_MAX = d HR_R(d + 1) end
function HR_NOP() end
function Headroom()
	HR_MAX = 0
	local old = _ERRORMESSAGE
	call(HR_R, { 0 }, "x", HR_NOP)
	_ERRORMESSAGE = old
	return HR_MAX
end
EMU_MINH = 999
function EMU_PAD(target, f, a1)
	if Headroom() > target then return EMU_PAD(target, f, a1) end
	local h = Headroom()
	if h < EMU_MINH then EMU_MINH = h end
	return f(a1)
end
function RUN(name, f, a1, target)
	if not QUIET then write("== " .. name .. "\n") end
	if EMU then EMU_PAD(target or 47, f, a1) else f(a1) end
end
function CB(o)
	local p = strfind(o, "/[^/]*$")
	if not p then return nil end
	return strsub(o, p + 1)
end
function PICK(k, label)
	local o = LASTOPTS[k]
	if not o then CHECK(nil, "row " .. k .. " exists") return end
	local fn = CB(o)
	local f = getglobal(fn)
	CHECK(type(f) == "function", "row " .. k .. " callback " .. fn .. " defined")
	if type(f) == "function" then RUN(label or ("pick " .. fn), f) end
end
function FINDOPT(sub)
	local i = 1
	while LASTOPTS[i] do if strfind(LASTOPTS[i], sub, 1, 1) then return i end i = i + 1 end
	return nil
end
function OPTS_OK(where)
	local ok = (LASTN == getn(LASTOPTS)) and LASTN <= 7 and LASTN >= 1
	local i = 1
	while LASTOPTS[i] do
		local fn = CB(LASTOPTS[i])
		if not fn or type(getglobal(fn)) ~= "function" then ok = nil write("  bad row " .. LASTOPTS[i] .. "\n") end
		if strlen(LASTOPTS[i]) > 100 then ok = nil write("  long row " .. LASTOPTS[i] .. "\n") end
		i = i + 1
	end
	if strlen(LASTSAY) > 520 then ok = nil write("  long title " .. strlen(LASTSAY) .. "\n") end
	CHECK(ok, where .. ": " .. LASTN .. " rows (1..7), callbacks defined, texts short")
end
function RESET(prof, lv, map)
	local p = P()
	p.tasks = {} p.items = {} p.skills = {} p.free = 60 p.prof = prof p.level = lv p.map = map or 1020 p.fight = 0
end
function ACTIVE_FIND(c)
	local a = PTNV_Active()
	local i = 1
	while i <= a.n do if a[i].c == c then return a[i], i end i = i + 1 end
	return nil
end

-- ---------------------------------------------------------------- 1. load
NEWPLAYER(1, "KyUc1Thoi", 1, 1002, 0)
PlayerIndex = 1
ORIG_DOFILE(OUT .. "script\\phongthan\\item\\nhiemvu_lenhbai.lua")
CHECK(type(main) == "function" and PTNV_LOADED == nil and PTNV_Data == nil, "quest token loads, data not loaded at top level")
NV_MAIN = main
RUN("main lv1 Giap Si", main, 1)
OPTS_OK("main menu")
CHECK(LASTN == 7 and strfind(LASTOPTS[1], "PTNV_AP1", 1, 1), "main = Nhiem vu dang lam + 5 groups + close")
CHECK(PTNV_LOADED == 1 and type(PTNV_Active) == "function", "data loaded through dofile at call time")
nd = 0
while PTNV_DS[nd + 1] do nd = nd + 1 end
CHECK(nd >= 200, "destinations loaded: " .. nd)

-- 8c. lenhbainv4: every group -> quest -> step -> detail (all camps); fields, limits, go buttons
function DETAIL_OK(where)
	local ok = 1
	local s = LASTSAY .. "<enter>"
	local p = 1
	while p <= strlen(s) do
		local e = strfind(s, "<enter>", p, 1)
		local line = strsub(s, p, e - 1)
		if strlen(line) > 100 then ok = nil write("  line > 100 bytes (" .. where .. "): " .. line .. "\n") end
		p = e + 7
	end
	if strlen(LASTSAY) > 520 then ok = nil write("  detail page too long " .. where .. "\n") end
	return ok
end
function OPT_SLASH_OK()
	local i = 1
	while LASTOPTS[i] do
		local o = LASTOPTS[i]
		local p = strfind(o, "/", 1, 1)
		local q = strfind(o, "/[^/]*$")
		if p ~= q or strlen(o) > 100 then return nil end
		i = i + 1
	end
	return 1
end
QUIET = 1
qok, nq, nsteps, ngo, nlab = 1, 0, 0, 0, 1
seenq = {}
cpx = 0
while cpx <= 2 do
	g = 2
	while g <= 6 do
		RESET(cpx, 150, 1020)
		TRACE = "GQ" .. g
		RUN("GQ", getglobal("PTNV_GQ" .. g))
		gp = 1
		guard = 0
		while guard < 20 do
			guard = guard + 1
			if LASTN > 7 or not OPT_SLASH_OK() then qok = nil write("  bad group page " .. g .. "\n") end
			nrow = LASTN
			saveopts = {}
			i = 1
			while LASTOPTS[i] do saveopts[i] = LASTOPTS[i] i = i + 1 end
			i = 1
			while saveopts[i] do
				fn = CB(saveopts[i])
				if strfind(fn, "PTNV_GE", 1, 1) then
					-- open entry, walk all step pages and every step detail
					PTNV_Ctx().g = g PTNV_Ctx().gp = gp
					TRACE = "GE " .. fn .. " g" .. g .. " cp" .. cpx
					RUN("GE", getglobal(fn))
					q = PTNV_Ctx().q
					if strfind(LASTOPTS[1] or "", "PTNV_G", 1, 1) and not strfind(LASTOPTS[1] or "", "PTNV_GE", 1, 1) and not strfind(LASTOPTS[1] or "", "PTNV_GNX", 1, 1) then
						-- NPC list entry (PTNV_G<i> rows)
					elseif q and not seenq[q .. "_" .. cpx] then
						seenq[q .. "_" .. cpx] = 1
						nq = nq + 1
						Q = PTNV_Q[q]
						k = 1
						while k <= Q.n do
							nsteps = nsteps + 1
							RESET(cpx, 150, 1020)
							TRACE = "SD q" .. q .. " k" .. k
							PTNV_SDOpen(q, k)
							pages = 0
							fields = ""
							dg = 0
							guard2 = 0
							while guard2 < 10 do
								guard2 = guard2 + 1
								pages = pages + 1
								if LASTN < 2 or LASTN > 7 or not OPT_SLASH_OK() then qok = nil write("  bad detail rows q" .. q .. " k" .. k .. "\n") end
								if not DETAIL_OK("q" .. q .. " k" .. k) then qok = nil end
								fields = fields .. LASTSAY
								j = 1
								while LASTOPTS[j] do if strfind(LASTOPTS[j], "/PTNV_DG", 1, 1) then dg = dg + 1 end j = j + 1 end
								if not FINDOPT("/PTNV_DN") then break end
								RUN("DN", PTNV_DN)
							end
							if not strfind(fields, "Vi\214c c\199n l\181m", 1, 1) or not strfind(fields, "\167i\210u ki\214n", 1, 1) or not strfind(fields, "B\173\237c " .. k .. "/", 1, 1) then
								qok = nil write("  missing field q" .. q .. " k" .. k .. "\n")
							end
							if dg == 0 and not strfind(fields, "\167i\211m c\244 th\211", 1, 1) then qok = nil write("  no go button q" .. q .. " k" .. k .. " " .. Q.s[k].txt .. "\n") end
							-- every go button teleports once the gates are open
							t = PTNV_STargets(q, k)
							j = 1
							while j <= t.n do
								RESET(cpx, 150, 1020)
								SetTask(2252, 1) SetTask(2222, 27) SetTask(2283, 46) SetTask(1, 80) SetTask(2, 80) SetTask(3, 80) SetTask(597, 22)
								PTNV_Ctx().q = q PTNV_Ctx().k = k
								NWLOG = {}
								PTNV_DG(j)
								d = PTNV_DS[t[j]]
								if P().map ~= d.map or P().x ~= d.x then qok = nil write("  go failed q" .. q .. " k" .. k .. " -> " .. d.map .. "\n") end
								ngo = ngo + 1
								j = j + 1
							end
							k = k + 1
						end
					end
					RESET(cpx, 150, 1020)
					PTNV_Ctx().g = g PTNV_Ctx().gp = gp
					PTNV_GPage()
				end
				i = i + 1
			end
			nx = FINDOPT("/PTNV_GNX")
			if not nx then break end
			PICK(nx, "GN")
			gp = gp + 1
		end
		g = g + 1
	end
	cpx = cpx + 1
end
QUIET = nil
CHECK(qok, "all quests of the 5 groups for the 3 camps (" .. nq .. " quest views, " .. nsteps .. " step details, " .. ngo .. " go buttons): pages <= 7 rows, no '/' in labels, rows <= 100 bytes, detail lines <= 100 bytes, step + job + conditions present, every go button teleports")
-- every quest of the data reachable from some group (all camps)
allq = 1
q = 1
while q <= PTNV_NQ do
	Q = PTNV_Q[q]
	cp = Q.cp
	if cp < 0 then cp = 0 end
	if not seenq[q .. "_" .. cp] then allq = nil write("  quest not reachable " .. q .. " " .. Q.title .. "\n") end
	q = q + 1
end
CHECK(allq, "every one of the " .. PTNV_NQ .. " quests is listed in its group")
-- markers on the main story (Dao Si at 31)
RESET(1, 60, 1020) SetTask(1, 31)
qm = 1 while PTNV_Q[qm] and not (PTNV_Q[qm].c == 20 and PTNV_Q[qm].cp == 1) do qm = qm + 1 end
PTNV_QOpen(qm)
cur = FINDOPT("[>] ")
CHECK(cur ~= nil and FINDOPT("[x] ") ~= nil and strfind(LASTOPTS[cur], "H\229 H\251 M\222", 1, 1), "Dao Si main at 31: step list opens on the current page, [>] on 'gap Ho Hy Mi', [x] on earlier steps")
RESET(1, 90, 1020) SetTask(1, 81)
cq, all = PTNV_QCur(qm)
CHECK(cq == 0 and all == 1, "main story finished (81): every step marked done")
-- Tham Quan (lenhbainv4 fix): value -> doctor that really accepts it
function TQ_MAP(v) RESET(0, 40, 1021) SetTask(314, v) local e = ACTIVE_FIND(36) return e and e.r.dest and PTNV_DS[e.r.dest].map end
CHECK(TQ_MAP(19) == 1065 and TQ_MAP(21) == 1019 and TQ_MAP(14) == 1014 and TQ_MAP(22) == 1022 and TQ_MAP(5) == 1005, "Tham Quan: 19 -> Tran Duong 1065, 21 -> Tuyet Long linh 1019, 14 -> Dong Quan, 22 -> Hoang mac, 5 -> Sung thanh")
-- gate explanation in the detail (Vien Co before step 50)
RESET(0, 70, 1020) SetTask(3, 41)
local q0 = 1 while not (PTNV_Q[q0].c == 20 and PTNV_Q[q0].cp == 0) do q0 = q0 + 1 end
local k50 = 1 while not strfind(PTNV_Q[q0].s[k50].txt, "Vi\212n C\230", 1, 1) do k50 = k50 + 1 end
PTNV_SDOpen(q0, k50)
local txt = LASTSAY
while FINDOPT("/PTNV_DN") do RUN("DN", PTNV_DN) txt = txt .. LASTSAY end
CHECK(strfind(txt, "Kh\227a", 1, 1) and strfind(txt, "b\173\237c 50", 1, 1), "detail of the Vien Co step shows the lock and what is needed (main story step 50)")
-- from Nhiem vu dang lam to the full step detail
RESET(2, 10, 1004) SetTask(31, 5)
local ea, ka = ACTIVE_FIND(15)
RUN("act", PTNV_Act, ka)
local dr = FINDOPT("/PTNV_AD")
CHECK(dr ~= nil and LASTN <= 7, "active detail has 'Chi tiet tung buoc'")
if dr then PICK(dr, "AD") end
CHECK(strfind(LASTSAY, "M\198t Qu\251", 1, 1) ~= nil and FINDOPT("/PTNV_DG1") ~= nil, "opens the step detail (10 Mat Quy, go buttons)")


-- 2. destination sanity + every PTNV_G<i> teleports (gates satisfied), fight state by town
local towns = { [1001] = 1, [1002] = 1, [1003] = 1, [1004] = 1, [1020] = 1, [1021] = 1, [1052] = 1 }
local allok = 1
local i = 1
QUIET = 1
while i <= nd do
	local d = PTNV_DS[i]
	RESET(0, 150, 1021)
	SetTask(2252, 1) SetTask(2222, 27) SetTask(2283, 46) SetTask(3, 80) SetTask(597, 9)
	P().fight = 7
	RUN("G" .. i, getglobal("PTNV_G" .. i))
	local fight = 1
	if towns[d.map] then fight = 0 end
	if P().map ~= d.map or P().x ~= d.x or P().y ~= d.y or P().fight ~= fight or d.x < 500 or d.y < 500 then
		allok = nil write("  bad dest " .. i .. " map " .. d.map .. "\n")
	end
	if not strfind(LASTMSG(), "[" .. floor(d.x / 8) .. "," .. floor(d.y / 16) .. "]", 1, 1) then allok = nil end
	i = i + 1
end
QUIET = nil
CHECK(allok, "PTNV_G1..G" .. nd .. ": NewWorld to the arrival cell, fight 0 in towns / 1 elsewhere, message with screen pos")

-- 3. gates: Tien Ma / quest maps / Dong Di only when the chain is there
function GATE_TEST(map, setup, name)
	local j = 1
	local idx = nil
	while j <= nd do if PTNV_DS[j].map == map and PTNV_DS[j].gate > 0 then idx = j end j = j + 1 end
	if not idx then CHECK(nil, "gate dest on " .. map) return end
	RESET(0, 150, 1021) NWLOG = {}
	RUN("gate closed " .. map, getglobal("PTNV_G" .. idx))
	local closed = getn(NWLOG) == 0 and P().map == 1021
	setup()
	RUN("gate open " .. map, getglobal("PTNV_G" .. idx))
	CHECK(closed and P().map == map, name)
end
GATE_TEST(1074, function() SetTask(2222, 14) end, "1074 Bat Chu Son: blocked before step 14, open at 14")
GATE_TEST(1075, function() SetTask(2222, 27) end, "1075 Nguc Phap Son: open from 2222 >= 27")
GATE_TEST(1076, function() SetTask(2283, 46) end, "1076 Thanh Dia: open from 2283 >= 46")
GATE_TEST(1064, function() SetTask(3, 50) end, "1064 Vien Co: open from main step 50 (Giap Si task 3)")
GATE_TEST(1061, function() SetTask(3, 80) end, "1061: open from main step 80")

-- 4. group pages for every camp: <= 7 rows, all callbacks, every visible destination reachable through the pages
local camp = 0
while camp <= 2 do
	RESET(camp, 30, 1002 + camp)
	local g = 2
	while g <= 6 do
		local t = PTNV_List(g)
		local seen = {}
		local cnt = 0
		local p = 1
		local guard = 0
		RUN("page " .. g .. "_1", getglobal("PTNV_P" .. g .. "_1"))
		while guard < 20 do
			guard = guard + 1
			OPTS_OK("camp " .. camp .. " group " .. g .. " page " .. p)
			local k = 1
			while LASTOPTS[k] do
				local fn = CB(LASTOPTS[k])
				if strsub(fn, 1, 6) == "PTNV_G" then
					local di = tonumber(strsub(fn, 7))
					if not seen[di] then seen[di] = 1 cnt = cnt + 1 end
					local dd = PTNV_DS[di]
					if dd.camp >= 0 and dd.camp ~= camp then CHECK(nil, "foreign camp NPC shown " .. di) end
				end
				k = k + 1
			end
			local nx = FINDOPT("/PTNV_P" .. g .. "_" .. (p + 1))
			if not nx then break end
			PICK(nx, "next")
			p = p + 1
		end
		CHECK(cnt == t.n and cnt > 0, "camp " .. camp .. " group " .. g .. ": " .. cnt .. "/" .. t.n .. " NPCs over " .. p .. " page(s)")
		-- back from page 2 -> page 1, from page 1 -> main
		if p > 1 then
			RUN("p2", getglobal("PTNV_P" .. g .. "_2"))
			PICK(FINDOPT("/PTNV_P" .. g .. "_1"), "back to page 1")
		end
		PICK(FINDOPT("/main"), "back to main")
		CHECK(LASTN == 7 and strfind(LASTOPTS[1], "PTNV_AP1", 1, 1), "back reaches main menu")
		g = g + 1
	end
	camp = camp + 1
end

-- 5. blocked source maps, unloaded map, NewWorld failure
local blocked = { 1060, 1066, 1067, 1071, 1072, 1079, 1084, 1103 }
local bk = 1
i = 1
while blocked[i] do
	RESET(0, 60, blocked[i]) NWLOG = {}
	RUN("go from " .. blocked[i], PTNV_G1)
	if getn(NWLOG) > 0 or P().map ~= blocked[i] or not strfind(LASTSAY, "kh\171ng d\239ng", 1, 1) then bk = nil end
	i = i + 1
end
CHECK(bk, "Thien Lao / Van Tien / battlefield / Khai Minh / Huyen Vu / instances: no teleport, explanation shown")
RESET(0, 60, 1073) SetTask(2252, 1)
RUN("go from 1073", PTNV_G1)
CHECK(P().map == PTNV_DS[1].map, "usable inside Tien Ma maps (1073-1078) to go back")
RESET(0, 60, 1002) UNLOADED[PTNV_DS[nd].map] = 1 NWLOG = {}
RUN("unloaded", getglobal("PTNV_G" .. nd))
CHECK(getn(NWLOG) == 0 and P().map == 1002, "map not loaded: no NewWorld")
UNLOADED = {}
NWFAIL = 1 P().fight = 0
RUN("NewWorld fails", PTNV_G2)
CHECK(P().map == 1002 and P().fight == 0, "NewWorld 0: stays, fight state unchanged")
NWFAIL = nil

-- 6. Nhiem vu dang lam: scenarios
function DEST_IS(e, sub) return e and e.r.dest and strfind(PTNV_DS[e.r.dest].nm, sub, 1, 1) end
RESET(0, 1, 1002)
local e = ACTIVE_FIND(2)
CHECK(DEST_IS(e, "T\171 H\233"), "new Giap Si lv1: Hop Gam not taken -> To Ho")
CHECK(ACTIVE_FIND(1) ~= nil, "new Giap Si lv1: newbie2 not taken -> Quan Su")
RESET(0, 40, 1002)
CHECK(ACTIVE_FIND(2) == nil, "lv40: 'not taken' newbie rows hidden (lvmax 20)")
RESET(0, 5, 1002) SetTask(20, 13)
CHECK(DEST_IS(ACTIVE_FIND(2), "Tri\214u \167i\210n"), "Hop Gam 13 (Loan + Loi done) -> Trieu Dien")
RESET(1, 40, 1003) SetTask(1, 12)
CHECK(DEST_IS(ACTIVE_FIND(20), "Ho\181ng Phi H\230"), "Dao Si main 12 (Ly Tinh done) -> Hoang Phi Ho")
RESET(2, 70, 1004) SetTask(2, 63) SetTask(42, 5)
e = ACTIVE_FIND(20)
CHECK(DEST_IS(e, "T\171n V\242"), "Di Nhan main 63, task42=5 -> Ton Vu Tien The (missing bit 2)")
local need = PTNV_Need(e.r)
CHECK(need.n == 2 and need.tot == 2, "step 63: only the books of the bits already set (EV8 + EV7), " .. need.n .. "/" .. need.tot)
RESET(2, 90, 1075) SetTask(2222, 14) SetTask(2252, 2)
e = ACTIVE_FIND(60)
CHECK(DEST_IS(e, "(Ma)"), "Tien Ma 14, Ma camp -> Tu Hanh Su Bat Chu Son (Ma)")
local etm, ktm = ACTIVE_FIND(60)
RUN("go Tien Ma", PTNV_ActGo, ktm)
CHECK(P().map == 1074, "Tien Ma: teleport into 1074 allowed at step 14")
RESET(0, 8, 1002) SetTask(2180, 4) SetTask(2184, 1)
e = ACTIVE_FIND(1)
CHECK(DEST_IS(e, "T\171 H\233"), "newbie2 Giap Si chain 4 (904) step 1 -> To Ho")
need = PTNV_Need(e.r)
CHECK(need.tot == 1, "904: bi kip Te Huyet Tram missing")
P().skills[27] = 1
need = PTNV_Need(e.r)
CHECK(need.tot == 0, "904: skill already learnt -> nothing missing")
RESET(1, 50, 1020) SetTask(2142, 6)
e = ACTIVE_FIND(40)
need = PTNV_Need(e.r)
CHECK(need.tot == 50 and need.kinds == 1, "Thien Cong 6: 50 Dong thau (3,3,0 level 0)")
RESET(1, 20, 1003) SetTask(2169, 401005)
e = ACTIVE_FIND(44)
need = PTNV_Need(e.r)
CHECK(DEST_IS(e, "T\185p Th\173\172ng T\169y K\250") and need.tot == 5 and need[1].it.d == 4, "Van chuyen 401005 -> Tay Ky, 5 x (3,4)")
RESET(0, 60, 1020) SetTask(53, 13 * 256 + 1)
e = ACTIVE_FIND(33)
CHECK(DEST_IS(e, "Mi\170u C\173\172ng") and PTNV_Need(e.r).tot == 1, "Quy Tinh step 13 state 1 -> tower Mieu Cuong, EV42 missing")
P().items[EKEY(42)] = 2
CHECK(PTNV_Need(e.r).tot == 0, "Quy Tinh: never supplies over an existing copy (exact-count checks)")
RESET(0, 40, 1021) SetTask(314, 22)
CHECK(DEST_IS(ACTIVE_FIND(36), "\167\185i Phu") and PTNV_DS[ACTIVE_FIND(36).r.dest].map == 1022, "Tham Quan 22 -> field doctor on 1022")
RESET(0, 35, 1020) SetTask(900, 3)
CHECK(PTNV_DS[ACTIVE_FIND(52).r.dest].map == 1039, "Thi luyen Dong Hai 900=3 -> maze doctor on 1039")
SetTask(900, 6)
CHECK(DEST_IS(ACTIVE_FIND(52), "Na Tra"), "Thi luyen 900=6 -> Na Tra")
RESET(0, 65, 1021) SetTask(2355, 7) SetTask(2356, 1)
e = ACTIVE_FIND(70)
CHECK(e and e.r.kill == 1 and PTNV_DS[e.r.dest].map == 1026, "Giang Son step 7 fighting -> spot on 1026, fight step")
SetTask(2360, 1)
CHECK(ACTIVE_FIND(70) == nil, "Giang Son finished -> not listed")
RESET(0, 40, 1020) SetTask(2009, 3) SetTask(2010, 20261004)
CHECK(ACTIVE_FIND(50) ~= nil, "Van Tien quest of today listed")
SetTask(2010, 20261003)
CHECK(ACTIVE_FIND(50) == nil, "Van Tien quest of yesterday not listed")
RESET(0, 90, 1020) SetTask(3, 81)
CHECK(ACTIVE_FIND(20) == nil, "main chain finished (81) -> not listed")

-- 7. every quest-step row is reachable, its detail dialogs work (both tokens), and the supply never over-gives
ORIG_DOFILE(OUT .. "script\\phongthan\\item\\tiepte_lenhbai.lua")
TT_MAIN = main
CHECK(type(PTTT_Page) == "function" and type(PTTT_Give) == "function", "supply token loads (shared data kept)")
QUIET = 1
local rows, rowok, detok = 0, 1, 1
farmok, killrows, farmrows = 1, 0, 0
local c = 1
while c <= PTNV_NCO do
	local ch = PTNV_CH[PTNV_CO[c]]
	local j = 1
	while j <= ch.n do
		local r = ch.r[j]
		rows = rows + 1
		local cp = r.camp
		if cp < 0 then cp = 0 end
		local lv = r.lv
		if r.st == 1 and r.lvmax < lv then lv = -1 end
		if lv >= 0 then
			if lv < 1 then lv = 1 end
			RESET(cp, lv, 1020)
			SetTask(r.var, r.lo)
			if r.v2 > 0 then SetTask(r.v2, r.lo2) end
			if r.cond == 1 then SetTask(2010, DATEV) end
			local e2, k2 = ACTIVE_FIND(PTNV_CO[c])
			if not e2 or e2.r.var ~= r.var or r.lo < e2.r.lo or r.lo > e2.r.hi then
				rowok = nil write("  row not detected chain " .. PTNV_CO[c] .. " var " .. r.var .. " = " .. r.lo .. "\n")
			else
				RUN("act", PTNV_Act, k2)
				if LASTN < 1 or LASTN > 7 then detok = nil end
				RUN("tt", PTTT_Detail, k2)
				if LASTN < 1 or LASTN > 7 or strlen(LASTSAY) > 520 then detok = nil write("  bad detail " .. LASTSAY .. "\n") end
				local nd2 = PTNV_Need(e2.r)
				if nd2.tot > 0 then
					-- lenhbainv2: while items are missing an item step with a farm sends the player to the farm
					if e2.r.farm and e2.r.farm > 0 and PTNV_Target(e2.r) ~= e2.r.farm then farmok = nil write("  item step not sent to farm, chain " .. PTNV_CO[c] .. "\n") end
					RUN("give", PTTT_Give, k2)
					local nd3 = PTNV_Need(e2.r)
					if nd3.tot ~= 0 then detok = nil write("  not complete after give, chain " .. PTNV_CO[c] .. "\n") end
					local q = 1
					while q <= nd3.n do
						if nd3[q].have ~= nd3[q].it.n then detok = nil write("  over/under give " .. nd3[q].it.nm .. "\n") end
						q = q + 1
					end
					-- items complete: back to the NPC
					if e2.r.kill ~= 1 and e2.r.dest and e2.r.dest > 0 and PTNV_Target(e2.r) ~= e2.r.dest then farmok = nil write("  full items not sent to NPC, chain " .. PTNV_CO[c] .. "\n") end
				end
				-- lenhbainv2: every fight step has a target; with a farm the target is the farm and the teleport works
				if e2.r.kill == 1 then
					killrows = killrows + 1
					local tg = PTNV_Target(e2.r)
					if tg <= 0 then farmok = nil write("  fight step without target, chain " .. PTNV_CO[c] .. " var " .. r.var .. "\n") end
					if e2.r.farm and e2.r.farm > 0 then
						farmrows = farmrows + 1
						if tg ~= e2.r.farm then farmok = nil write("  fight step not sent to farm, chain " .. PTNV_CO[c] .. "\n") end
						SetTask(2252, 1) SetTask(2222, 27) SetTask(2283, 46)
						if GetTask(597) < 9 and PTNV_DS[tg].gate == 9 then SetTask(597, 22) end
						P().map = 1020 NWLOG = {}
						PTNV_Go(tg)
						local d = PTNV_DS[tg]
						if P().map ~= d.map or P().x ~= d.x or P().y ~= d.y then farmok = nil write("  farm teleport refused " .. d.map .. " chain " .. PTNV_CO[c] .. " var " .. r.var .. "=" .. r.lo .. "\n") end
					end
				end
			end
		end
		j = j + 1
	end
	c = c + 1
end
QUIET = nil
CHECK(rowok, "every one of " .. rows .. " quest-step rows is detected for its own task values")
CHECK(detok, "every detail dialog <= 7 rows; Xac nhan gives exactly the missing count (never over)")
CHECK(farmok, "fight steps: all " .. killrows .. " have a target, " .. farmrows .. " go to their bai quai (teleport OK); item steps go to the farm while items are missing, to the NPC once complete")

-- 7b. bai quai scenarios
function FARM_IS(e, map) return e and e.r.farm and e.r.farm > 0 and PTNV_DS[PTNV_Target(e.r)].map == map end
RESET(2, 10, 1004) SetTask(31, 5)
local ef = ACTIVE_FIND(15)
CHECK(FARM_IS(ef, 1013), "Tan Thuc Xi Vuu 5 (10 Mat Quy missing) -> bai Hoa Dien on Cu Loc 1013")
P().items[NKEY(3, 12, 0, 0)] = 10
CHECK(DEST_IS(ACTIVE_FIND(15), "H\203u Th\230"), "10 Mat Quy in bag -> Hau Tho")
RESET(0, 25, 1002) SetTask(897, 18) SetTask(898, 40)
CHECK(FARM_IS(ACTIVE_FIND(51), 1022), "Tru Yeu target Sa Hon (897 = 18) -> bai Sa Hon on Hoang mac 1022")
RESET(0, 40, 1001) SetTask(2148, 1) SetTask(2149, 7)
CHECK(FARM_IS(ACTIVE_FIND(42), 1015), "Sieu Do spot 7 -> Chieu Hon Tran on Manh Tan 1015")
RESET(0, 70, 1001) SetTask(2144, 1) SetTask(2145, 30000 + 1047)
CHECK(FARM_IS(ACTIVE_FIND(41), 1047), "Thien Cuong Hon star 3 map 1047 (mod 10000) -> 1047")
RESET(0, 85, 1055) SetTask(2152, 1) SetTask(2153, 42)
CHECK(FARM_IS(ACTIVE_FIND(43), 1056), "Hap Hon island 2 (mod 10) -> Phuong Truong 1056")
RESET(0, 75, 1002) SetTask(597, 3)
CHECK(FARM_IS(ACTIVE_FIND(53), 1045), "Dong Di 597 = 3 (598 counting) -> bai Lam Cot 1045 (open map, no gate)")
SetTask(598, 100)
CHECK(DEST_IS(ACTIVE_FIND(53), "Thi\210n Ng\228c"), "598 = 100 -> Dang Thien Ngoc")
RESET(1, 3, 1003) SetTask(2180, 2) SetTask(2184, 1)
CHECK(FARM_IS(ACTIVE_FIND(1), 1008), "newbie2 Dao Si 896 kill 8 Tuyet Quai -> 1008")
local e7, k7 = ACTIVE_FIND(1)
RUN("act farm", PTNV_Act, k7)
CHECK(strfind(LASTOPTS[1] or "", "PTNV_AG", 1, 1) and strfind(LASTSAY, "B\183i qu\184i", 1, 1), "detail shows 'Bai quai' + first row teleports there")
RUN("tt farm", PTTT_Detail, k7)
CHECK(strfind(LASTSAY, "L\214nh B\181i Nhi\214m V\244", 1, 1) ~= nil, "supply token: 'can tu danh' + hint to use Lenh Bai Nhiem Vu")

-- 8. supply token flow: room check, partial bag, creation failure, nothing to give
RESET(2, 60, 1021) SetTask(2, 34)
RUN("tt main", TT_MAIN, 1)
OPTS_OK("supply main")
local k3 = FINDOPT("Ch\221nh tuy\213n")
CHECK(k3 ~= nil, "supply main lists Chinh tuyen")
PICK(k3, "detail main 34")
CHECK(strfind(LASTSAY, "Ma huy\213t", 1, 1) and FINDOPT("/PTTT_OK"), "detail lists Ma huyet missing with a confirm row")
P().free = 0
PICK(FINDOPT("/PTTT_OK"), "confirm, bag full")
CHECK(HaveEventItemCount(19) == 0 and strfind(LASTSAY, "\171 tr\232ng", 1, 1), "bag full: nothing created, free cells asked")
P().free = 5
RUN("tt main", TT_MAIN, 1)
PICK(FINDOPT("Ch\221nh tuy\213n"), "detail")
PICK(FINDOPT("/PTTT_OK"), "confirm")
CHECK(HaveEventItemCount(19) == 1 and P().free == 4, "Ma huyet x1 given (1 cell)")
RUN("tt main", TT_MAIN, 1)
PICK(FINDOPT("Ch\221nh tuy\213n"), "detail again")
CHECK(not FINDOPT("/PTTT_OK"), "second time: nothing missing, no confirm row")
RESET(0, 40, 1020) SetTask(2142, 6) P().free = 1
NOCREATE[NKEY(3, 3, 0, 0)] = 1
local e4, k4 = ACTIVE_FIND(40)
RUN("give fails", PTTT_Give, k4)
CHECK(HaveNormalItem(3, 3, 0, 0) == 0 and strfind(LASTMSG(), "Kh\171ng t\185o", 1, 1), "creation failure reported, nothing dropped")
NOCREATE = {}
RUN("give ok", PTTT_Give, k4)
CHECK(HaveNormalItem(3, 3, 0, 0) == 50 and P().free == 0, "50 Dong thau stacked into the last free cell")
RESET(0, 40, 1020) SetTask(53, 13 * 256 + 2)
local e5, k5 = ACTIVE_FIND(33)
RUN("kill step give", PTTT_Give, k5)
CHECK(HaveEventItemCount(43) == 1 and strfind(LASTMSG(), "t\249 \174\184nh", 1, 1), "fight step: item given + note that the fight is not replaced")
CHECK(GetTask(53) == 13 * 256 + 2, "task variables never changed by the supply token")
RESET(0, 1, 1002) SetTask(2180, 99) SetTask(20, 19) SetTask(21, 9)
RUN("tt none", TT_MAIN, 1)
OPTS_OK("supply with no quest")

-- 8b. fallback without AddNormalItemPile: AddItem + AddItemIDStack(idx, 0) (the engine refuses < 2 arguments)
RESET(0, 40, 1020) SetTask(2142, 6) P().free = 2
local savedPile, savedAddItem = AddNormalItemPile, AddItem
STACKCALLS, STACKBAD = 0, 0
AddNormalItemPile = nil
FB = {}
function AddItem(g, d, p, lv, se, luck) FB.key = NKEY(g, d, p, lv) return 300 end
function GetMaxStackItem(idx) return 100 end
function AddItemIDStack(...)
	STACKCALLS = STACKCALLS + 1
	if getn(arg) < 2 then STACKBAD = STACKBAD + 1 return 0 end
	return BagAdd(FB.key)
end
function AddItemID(idx, p) return BagAdd(FB.key) end
local e8, k8 = ACTIVE_FIND(40)
RUN("give via fallback", PTTT_Give, k8)
CHECK(STACKCALLS > 0 and STACKBAD == 0 and HaveNormalItem(3, 3, 0, 0) == 50, "fallback stacks with AddItemIDStack(idx, 0): 50 Dong thau, never called with < 2 arguments")
AddNormalItemPile, AddItem = savedPile, savedAddItem
function AddItemID(i, x) end

-- 9. active list paging (many chains at once)
RESET(0, 30, 1002)
SetTask(20, 1) SetTask(21, 1) SetTask(23, 1) SetTask(26, 10) SetTask(25, 1) SetTask(24, 1) SetTask(2142, 1) SetTask(2316, 1)
SetTask(2144, 3) SetTask(2148, 2) SetTask(2152, 2) SetTask(2312, 2) SetTask(41, 1) SetTask(50, 1) SetTask(91, 1)
local a = PTNV_Active()
CHECK(a.n >= 10, "many chains in progress: " .. a.n)
RUN("act page 1", PTNV_AP1)
local pages = 1
local seen = 0
local guard = 0
while guard < 10 do
	guard = guard + 1
	OPTS_OK("active page " .. pages)
	local k = 1
	while LASTOPTS[k] do if strfind(LASTOPTS[k], "/PTNV_A", 1, 1) and not strfind(LASTOPTS[k], "/PTNV_AP", 1, 1) then seen = seen + 1 end k = k + 1 end
	local nx = FINDOPT("/PTNV_AP" .. (pages + 1))
	if not nx then break end
	PICK(nx, "next")
	pages = pages + 1
end
CHECK(seen == a.n, "active pages show all " .. a.n .. " entries over " .. pages .. " pages")
RUN("act 3", PTNV_A3)
OPTS_OK("active detail")
local a3 = PTNV_Active()[3]
PICK(1, "go")
local t3 = PTNV_Target(a3.r)
CHECK(t3 > 0 and P().x == PTNV_DS[t3].x and P().y == PTNV_DS[t3].y, "detail row 1 teleports to the target of the step")

-- ---------------------------------------------------------------- 10. auto-give (starter_gear.lua tick)
write("\n-- auto give\n")
PL = {}
NEWPLAYER(1, "TanThu", 1, 1002, 0)
NEWPLAYER(2, "CoToken", 55, 1035, 1)
PL[2].tasks[1950] = 2
PL[2].tasks[2610] = 1
PL[2].items[NKEY(6, 1, 61430, 1)] = 1
NEWPLAYER(4, "TuiDay", 80, 1050, 2)
PL[4].tasks[1950] = 2
PL[4].tasks[2610] = 1
PL[4].bagfull = 1
ORIG_DOFILE(OUT .. "script\\phongthan\\newbie\\starter_gear.lua")
CHECK(type(PTNB_Tick) == "function" and type(PTNB_NvTick) == "function" and type(PTNB_LcTick) == "function", "starter_gear.lua loads (PTNB_Tick, PTNB_LcTick, PTNB_NvTick)")
PTLC_GiveTick = function() end   -- luyencong part tested by sim_luyencong.lua
local oldmain = main
main = "servertimer-main"
RUN("tick 1", PTNB_Tick, nil, 40)
CHECK(main == "servertimer-main", "nhiemvu_give.lua does not overwrite the servertimer main()")
main = oldmain
PlayerIndex = 1
CHECK(HaveNormalItem(6, 1, 61430, -1) == 1 and HaveNormalItem(6, 1, 61431, -1) == 1 and GetTask(2611) == 1 and GetTask(2612) == 1, "new character: both tokens, tasks 2611/2612 = 1")
PlayerIndex = 2
CHECK(HaveNormalItem(6, 1, 61430, -1) == 1 and HaveNormalItem(6, 1, 61431, -1) == 1 and GetTask(2611) == 1, "owned quest token: not given twice, supply token given")
PlayerIndex = 4
CHECK(HaveNormalItem(6, 1, 61430, -1) == 0 and GetTask(2611) == 0 and GetTask(2612) == 0, "bag full: nothing, tasks stay 0")
local adds = ADDS
RUN("tick 2", PTNB_Tick, nil, 40)
PlayerIndex = 1
CHECK(HaveNormalItem(6, 1, 61430, -1) == 1, "tick 2: no duplicate")
CHECK(ADDS == adds, "tick 2: nothing created (bag-full player still full)")
PL[4].bagfull = nil
RUN("tick 3", PTNB_Tick, nil, 40)
PlayerIndex = 4
CHECK(GetTask(2611) == 1 and GetTask(2612) == 1, "bag freed: both tokens given")
NEWPLAYER(3, "ChuaCoPtfix", 20, 1015, 0)
PL[3].tasks[1950] = 2
NOROW = 1
RUN("tick 4 (no ptfix row)", PTNB_Tick, nil, 40)
PlayerIndex = 3
CHECK(GetTask(2611) == 0, "no magicscript row yet: task stays 0")
NOROW = nil
RUN("tick 5", PTNB_Tick, nil, 40)
PlayerIndex = 3
CHECK(GetTask(2611) == 1 and GetTask(2612) == 1, "after ptfix: given")
local saved = PTNV_GiveTick
PTNV_GiveTick = function() error("boom") end
RUN("tick with failing gift", PTNB_Tick, nil, 40)
CHECK(TICKERR == 1, "gift error caught by PTAdm_Safe")
PTNV_GiveTick = saved

if EMU then write("min headroom at entry = " .. EMU_MINH .. " frames\n") end
write("CHECKS=" .. CHECKS .. "\n")
write("FAILS=" .. FAILS .. "\n")
writeto()
