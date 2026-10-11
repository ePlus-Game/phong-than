-- Offline quest simulator for Phong Than npc_fix scripts (Lua 4.0, engine LuaLibDll).
-- Engine API is stubbed; each script keeps its own globals (per-state emulation).
SRV = "E:\\VL\\Phong than\\PT\\PhongThanRuntime-Staging\\Server"
NPCFIX = "\\script\\phongthan\\npc_fix\\"

-- ---------------------------------------------------------------- utils
function SIM_copy(t)
	if type(t) ~= "table" then return t end
	local r = {}
	for k, v in t do r[k] = SIM_copy(v) end
	return r
end

function SIM_keys(t)
	local r = {}
	for k, v in t do tinsert(r, k) end
	sort(r, function(a, b) return tostring(a) < tostring(b) end)
	return r
end

function SIM_ser(t)
	if type(t) ~= "table" then return tostring(t) end
	local ks = SIM_keys(t)
	local s = "{"
	for i = 1, getn(ks) do
		local k = ks[i]
		s = s .. tostring(k) .. "=" .. SIM_ser(t[k]) .. ","
	end
	return s .. "}"
end

SIM_OUT = {}
function SIM_log(s) tinsert(SIM_OUT, s) end

-- ---------------------------------------------------------------- world
function SIM_newworld(ptype, level)
	W = { task = {}, level = level, ptype = ptype, exp = 0, cash = 100000000, ext = 1000000,
	      map = 1002, items = {}, fight = 0 }
end
SIM_newworld(0, 1)

-- per-interaction trace
TR = nil
function SIM_tr(kind, a) if TR then tinsert(TR, { kind, a }) end end
FLAGS = {}          -- problems seen (deduped)
function SIM_flag(s) if not FLAGS[s] then FLAGS[s] = 1 end end
QUERIES = {}        -- item keys that were asked for and missing
LVQUERY = 0

function SIM_ikey(g, d, p) return tostring(g) .. "," .. tostring(d) .. "," .. tostring(p or 0) end
function SIM_icount(k) return W.items[k] or 0 end
function SIM_iadd(k, n)
	W.items[k] = (W.items[k] or 0) + n
	if W.items[k] <= 0 then W.items[k] = nil end
end

-- ---------------------------------------------------------------- dialog capture
DLG = nil
function SIM_opt(label, fn)
	if DLG == nil then DLG = { opts = {} } end
	tinsert(DLG.opts, { label = label, fn = fn })
end
function SIM_parseopt(s)
	if type(s) ~= "string" then return end
	local p = strfind(s, "/")
	if not p then SIM_opt(s, nil) return end
	local lab = strsub(s, 1, p - 1)
	local fn = strsub(s, p + 1)
	if strsub(fn, 1, 1) == "#" then fn = strsub(fn, 2) end
	SIM_opt(lab, fn)
end

-- exit row text (TCVN3): "Ket thuc doi thoai"
EXIT_TXT = strchar(75,213,116,32,116,104,243,99,32,174,232,105,32,116,104,111,185,105)
function SIM_checkexit(where)
	if DLG == nil then return end
	local ok = 0
	for i = 1, getn(DLG.opts) do
		local o = DLG.opts[i]
		if o.fn == nil or o.fn == "" or o.fn == "no" or o.fn == "OnCancel" or strfind(o.label or "", EXIT_TXT, 1, 1) then ok = 1 end
		if strfind(strlower(o.label or ""), "thoat", 1, 1) or strfind(strlower(o.fn or ""), "no", 1, 1) == 1 or strfind(strlower(o.fn or ""), "cancel", 1, 1) or strfind(strlower(o.fn or ""), "exit", 1, 1) or strfind(strlower(o.fn or ""), "end", 1, 1) then ok = 1 end
	end
	if ok == 0 then SIM_flag("NO_EXIT_ROW " .. CUR_SCRIPT .. " " .. where) end
end

-- ---------------------------------------------------------------- API stubs
PlayerIndex = 1
function GetTask(i) return W.task[i] or 0 end
function SetTask(i, v) W.task[i] = v SIM_tr("SetTask", i .. "=" .. tostring(v)) end
function GetLevel() LVQUERY = 1 return W.level end
function GetPlayerType() return W.ptype end
function GetSeries() return W.ptype end
function GetName() return "Tester" end
function GetSex() return 0 end
function Msg2Player(s) SIM_tr("Msg", s) end
function TopMessage(s) end
function AddGlobalCountNews(s) end
function AddGlobalNews(s) end
function Talk(n, cb, ...)
	DLG = { opts = {}, talk = 1 }
	if cb and cb ~= "" then SIM_opt("<talk>", cb) end
end
function Say(text, n, ...)
	DLG = { opts = {} }
	for i = 1, arg.n do
		if type(arg[i]) == "table" then
			for j = 1, getn(arg[i]) do SIM_parseopt(arg[i][j]) end
		else
			SIM_parseopt(arg[i])
		end
	end
	if n == 0 and getn(DLG.opts) == 0 then DLG = nil return end
	SIM_checkexit("Say")
end
function SayTask(id, tasks)
	DLG = { opts = {} }
	for i = 1, getn(tasks) do
		local t = tasks[i]
		if t.show == 1 or t.show == nil then SIM_opt(t[1], t[2]) end
	end
	SIM_checkexit("SayTask")
end
function MsgBox(id, yes, no)
	DLG = { opts = {} }
	if yes then SIM_opt("<yes>", yes) end
	SIM_opt("<no>", no or "")
end
function CloseDialog() DLG = nil end
function TaskNote(id, step) SIM_flag("NATIVE_TASKNOTE " .. CUR_SCRIPT .. " " .. tostring(id) .. ":" .. tostring(step)) end
function AddNote(a, b, text, d) SIM_tr("Note", text) end
function AddMissionNote(a, b, c, d) SIM_tr("Note", tostring(c)) end
function NewTaskNote() end
function HaveEventItem(id)
	local c = SIM_icount(SIM_ikey(4, id, 0))
	if c == 0 then QUERIES[SIM_ikey(4, id, 0)] = 1 end
	return c
end
HaveEventItemCount = HaveEventItem
function AddEventItem(id) SIM_iadd(SIM_ikey(4, id, 0), 1) SIM_tr("Item+", SIM_ikey(4, id, 0)) return 1 end
function DelEventItem(id)
	if SIM_icount(SIM_ikey(4, id, 0)) > 0 then SIM_iadd(SIM_ikey(4, id, 0), -1) return 1 end
	return 0
end
function HaveNormalItem(g, d, p, lv)
	local c = SIM_icount(SIM_ikey(g, d, p))
	if c == 0 then QUERIES[SIM_ikey(g, d, p)] = 1 end
	return c
end
function AddNormalItem(g, d, p, lv, se, luck) SIM_iadd(SIM_ikey(g, d, p), 1) SIM_tr("Item+", SIM_ikey(g, d, p)) return 1 end
function AddNormalItem2(g, d, p, lv, se, luck) SIM_iadd(SIM_ikey(g, d, p), 1) return 1 end
AddItem = AddNormalItem
function DelNormalItem(g, d, p, lv)
	local k = SIM_ikey(g, d, p)
	if SIM_icount(k) > 0 then SIM_iadd(k, -1) return 1 end
	return 0
end
function GetItemCount(g, d, p) return SIM_icount(SIM_ikey(g, d, p or 0)) end
function QuestExchange(task, from, to, req, rew)
	if task and task > 0 and GetTask(task) ~= from then return 0 end
	for i = 1, getn(req) do
		local r = req[i]
		local k = SIM_ikey(r[1], r[2], r[3])
		if SIM_icount(k) < (r[7] or 1) then QUERIES[k] = 1 return 0 end
	end
	for i = 1, getn(req) do local r = req[i] SIM_iadd(SIM_ikey(r[1], r[2], r[3]), -(r[7] or 1)) end
	for i = 1, getn(rew) do local r = rew[i] SIM_iadd(SIM_ikey(r[1], r[2], r[3]), r[7] or 1) SIM_tr("Item+", SIM_ikey(r[1], r[2], r[3])) end
	if task and task > 0 then SetTask(task, to) end
	return 1
end
function GreenEquipment() return 1 end
function GreenEquipmentTuple() return 0, 1, 1, 1, 1, 0, 1 end
function GetItemLevel2() return 1 end
function DelItem2() return 1 end
function ClearItem() return 1 end
function AddOwnExp(n) W.exp = W.exp + (n or 0) end
AddExp = AddOwnExp
function GetExp() return W.exp end
function GetNextExp() return 100000000 end
function AddCredit() end
function Earn(n) W.cash = W.cash + (n or 0) end
function Pay(n) if W.cash >= n then W.cash = W.cash - n return 1 end return 0 end
function GetCash() return W.cash end
function GetExtPoint() return W.ext end
function PayExtPoint(i, n) if W.ext >= n then W.ext = W.ext - n return 1 end return 0 end
function NewWorld(m, x, y) W.map = m SIM_tr("NewWorld", m) return 1 end
function GetWorldPos() return W.map, 1600, 3200 end
function GetNpcWorldPos(n) return W.map, 1600, 3200 end
function SubWorldID2Idx(m) return m end
function SubWorldIdx2ID(m) return m end
function GetTeamSize() return 1 end
function GetTeamMember(i) return PlayerIndex end
function IsCaptain() return 1 end
function GetTeam() return 0 end
function GetMissionV(i) return 0 end
function GetMSPlayerCount() return 0 end
function GetGlobalValue(i) return 0 end
function SystemTime() return 0 end
function GetMorphType() return 0 end
function IsPlayerInsideWeapon() return 0 end
function GetCamp() return 0 end
function GetPK() return 0 end
function CanMarry() return 0 end
function IsMarried() return 0 end
function HaveIBBuff() return 0 end
function GetByte(v, i)
	v = v or 0
	local d = 1
	for j = 2, i do d = d * 256 end
	return mod(floor(v / d), 256)
end
function SetByte(v, i, b)
	v = v or 0
	local d = 1
	for j = 2, i do d = d * 256 end
	local old = mod(floor(v / d), 256)
	return v + (b - old) * d
end
function GetBit(v, i)
	v = v or 0
	local d = 1
	for j = 2, i do d = d * 2 end
	return mod(floor(v / d), 2)
end
function SetBit(v, i, b)
	v = v or 0
	local d = 1
	for j = 2, i do d = d * 2 end
	local old = mod(floor(v / d), 2)
	return v + (b - old) * d
end
function random(a, b) if a == nil then return 0.5 end if b == nil then return 1 end return a end
function Sale(n) SIM_tr("Sale", n) end
function Include(p)
	local f = SRV .. p
	local fh = openfile(f, "r")
	if fh then closefile(fh) dofile(f) else SIM_flag("INCLUDE_NOT_LOOSE " .. p) end
end
function ReLoadScript(p) return 1 end
function SetNpcScript() end
function ExecuteScript() end

-- registered engine API: default stub; unregistered names stay nil (real engine errors)
SIM_REG = {}
function SIM_loadreg(file)
	readfrom(file)
	local l = read("*l")
	while l do SIM_REG[l] = 1 l = read("*l") end
	readfrom()
end
SIM_loadreg("registered.txt")
for k, v in SIM_REG do
	if getglobal(k) == nil then
		setglobal(k, function(...) SIM_tr("api", %k) return 0 end)
	end
end

-- ---------------------------------------------------------------- per-script modules
MODS = {}
function SIM_snapshot()
	local s = {}
	for k, v in globals() do s[k] = v end
	return s
end
function SIM_restore(snap)
	local g = globals()
	local ks = {}
	for k, v in g do if snap[k] ~= v then tinsert(ks, k) end end
	for i = 1, getn(ks) do g[ks[i]] = snap[ks[i]] end
end
function SIM_diff(snap)
	local d = {}
	for k, v in globals() do if snap[k] ~= v then d[k] = v end end
	return d
end

SIM_LOADERR = nil
function SIM_load(name)
	local snap = SIM_snapshot()
	CUR_SCRIPT = name
	SIM_LOADERR = nil
	call(dofile, { SRV .. NPCFIX .. name }, "x", function(m) SIM_LOADERR = m end)
	local mod = SIM_diff(snap)
	mod.CUR_SCRIPT = nil
	SIM_restore(snap)
	if SIM_LOADERR then SIM_flag("LOAD_ERROR " .. name .. " " .. SIM_LOADERR) end
	MODS[name] = mod
	return mod
end

SIM_ERR = nil
-- run fn of script `name` with its own globals; module globals persist
function SIM_run(name, fn, args)
	local mod = MODS[name]
	local snap = SIM_snapshot()
	for k, v in mod do setglobal(k, v) end
	CUR_SCRIPT = name
	local f = getglobal(fn)
	SIM_ERR = nil
	if type(f) ~= "function" then
		-- option strings like "func(1)" -> dostring
		if strfind(fn, "(", 1, 1) then
			call(dostring, { fn }, "x", function(m) SIM_ERR = m end)
		else
			SIM_ERR = "missing function " .. fn
		end
	else
		call(f, args or {}, "x", function(m) SIM_ERR = m end)
	end
	local after = SIM_diff(snap)
	for k, v in after do if k ~= "CUR_SCRIPT" and k ~= "DLG" and k ~= "TR" and k ~= "SIM_ERR" and k ~= "W" and k ~= "LVQUERY" and k ~= "FLAGS" and k ~= "QUERIES" then mod[k] = v end end
	local d2, dl, te, ww, lq = DLG, TR, SIM_ERR, W, LVQUERY
	SIM_restore(snap)
	DLG, TR, SIM_ERR, W, LVQUERY = d2, dl, te, ww, lq
	if SIM_ERR then SIM_flag("RUNTIME_ERROR " .. name .. ":" .. fn .. " " .. SIM_ERR) end
end
