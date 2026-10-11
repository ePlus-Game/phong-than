-- ct_api.lua (Lua 4, Phong Than GameServer) - 2026-10-03 congthanh
-- Territory API layer for the VNG building scripts (\script\<GBK>\{shen dian, bing ying, lian dan lu,
-- ba chang}.lua). extra_congthanh.py appends to each of them:
--     PTCT_BUILDING = "<key>"
--     Include("\\script\\phongthan\\congthanh\\ct_api.lua")
-- so these definitions run after the script body and after pt_compat.lua (first line).
-- Personal mode (player owns a personal territory, task 2430 = 1): every city/tong call answers from
-- the player's own task values. Otherwise the call goes to the engine function when one exists
-- (C++ patch S\congthanh\cpp_patch.md adds the guild-mode natives) or answers "not available".
Include("\\script\\phongthan\\congthanh\\ct_lib.lua")

-- natives, captured once per Lua state (pt_compat fallbacks count as missing)
function PTCT_Native(f)
	if f == nil or f == PTCompat_Zero or f == PTCompat_Nop then return nil end
	if PTCT_API_SELF and PTCT_API_SELF[f] then return nil end
	return f
end
if PTCT_API_LOADED == nil then
	PTCT_API_LOADED = 1
	PTCT_C_IsOwnerCity = PTCT_Native(IsOwnerCity)
	PTCT_C_IsHaveTongRight = PTCT_Native(IsHaveTongRight)
	PTCT_C_GetBuildingState = PTCT_Native(GetBuildingState)
	PTCT_C_BuildingOperator = PTCT_Native(BuildingOperator)
	PTCT_C_DestroyBuilding = PTCT_Native(DestroyBuilding)
	PTCT_C_GetCityInfo = PTCT_Native(GetCityInfo)
	PTCT_C_GetCityTask = PTCT_Native(GetCityTask)
	PTCT_C_SetCityTask = PTCT_Native(SetCityTask)
	PTCT_C_AddCityIndexRes = PTCT_Native(AddCityIndexRes)
	PTCT_C_GetTongContri = PTCT_Native(GetTongContri)
	PTCT_C_AddTongContri = PTCT_Native(AddTongContri)
	PTCT_C_Msg2TongMember = PTCT_Native(Msg2TongMember)
	PTCT_C_AddTongAttr = PTCT_Native(AddTongAttr)
	PTCT_C_GetOwnCityLevel = PTCT_Native(GetOwnCityLevel)
end

-- the engine cuts "label/callback" at the FIRST "/" (LuaSelectUI strstr), so VNG labels such as
-- "N/v linh danh thue" would call a function named "v linh danh thue...": "/" in labels becomes "."
function PTCT_Clean(s)
	if type(s) ~= "string" then return s end
	local r = gsub(s, "/", ".")
	return r
end
-- "label/callback" string: callback = text after the LAST "/"
function PTCT_CleanOpt(s)
	if type(s) ~= "string" then return s end
	local p = nil
	local q = strfind(s, "/", 1, 1)
	while q do
		p = q
		q = strfind(s, "/", q + 1, 1)
	end
	if not p then return s end
	return PTCT_Clean(strsub(s, 1, p - 1)) .. strsub(s, p)
end

function PTCT_BId()
	if PTCT_BUILDING then return PTCT_BKEY[PTCT_BUILDING] end
	return nil
end

function PTCT_IsOwnerCity()
	if PTCT_Owns() then return 1 end
	if PTCT_C_IsOwnerCity then return PTCT_C_IsOwnerCity() end
	return 0
end

function PTCT_IsHaveTongRight(n)
	-- personal territory: no demolish / tax rights (the rows stay hidden)
	if PTCT_Owns() then return 0 end
	if PTCT_C_IsHaveTongRight then return PTCT_C_IsHaveTongRight(n) end
	return 0
end

function PTCT_GetBuildingState(idx)
	if PTCT_Owns() then
		if PTCT_Built(PTCT_BId()) then return 1 end
		return 0
	end
	if PTCT_C_GetBuildingState then return PTCT_C_GetBuildingState(idx) end
	-- guild mode (tong owns this city, C++ patch): the building NPC stands, so it is built
	if PTCT_C_IsOwnerCity and PTCT_C_IsOwnerCity() == 1 then return 1 end
	return 0
end

-- VNG building panel: (title, { {label, callback; show=0/1}, ... }). The "sm" row (building text) is
-- always offered, like the fixed info button of the VNG panel.
function PTCT_BuildingOperator(title, opers)
	local guild = nil
	if not PTCT_Owns() then
		if PTCT_C_BuildingOperator then return PTCT_C_BuildingOperator(title, opers) end
		if not (PTCT_C_IsOwnerCity and PTCT_C_IsOwnerCity() == 1) then
			Talk(1, "PTCT_No", PTCT_TXT.not_owner)
			return 0
		end
		guild = 1
	end
	local id = PTCT_BId()
	local b = nil
	if id then b = PTCT_B[id] end
	local rows = {}
	local n = 0
	local i = 1
	while opers and opers[i] do
		local o = opers[i]
		if type(o) == "table" and (o.show == 1 or o[2] == "sm") then
			n = n + 1
			rows[n] = { PTCT_Clean(o[1]), o[2]; show = 1 }
		end
		i = i + 1
	end
	local head = PTCT_CityName() .. " - " .. PTCT_TXT.lv .. PTCT_Level()
	if guild then
		local cn = PTCT_GetCityInfo()
		head = cn or ""
		if b then head = "<color=yellow>" .. b.name .. "<color> (" .. head .. ")" end
		SayTask(head, rows)
		return 1
	end
	if b then
		head = "<color=yellow>" .. b.name .. "<color> (" .. head .. ")"
		if not PTCT_Built(id) then
			head = head .. "\n" .. PTCT_TXT.not_built .. b.name .. PTCT_TXT.not_built2
		end
	end
	SayTask(head, rows)
	return 1
end

function PTCT_DestroyBuilding(idx)
	if PTCT_Owns() then
		Talk(1, "PTCT_No", PTCT_TXT.destroy)
		return 0
	end
	if PTCT_C_DestroyBuilding then return PTCT_C_DestroyBuilding(idx) end
	return 0
end

-- GetCityInfo: name, owned, tax, treasury, level-1 (VNG adds 1), template, owner name
function PTCT_GetCityInfo()
	if PTCT_Owns() then
		return PTCT_CityName(), 1, 0, 0, PTCT_Level() - 1, 0, GetName()
	end
	if PTCT_C_GetCityInfo then return PTCT_C_GetCityInfo() end
	return "", 0, 0, 0, 0, 0, ""
end

function PTCT_GetCityTask(id)
	if PTCT_Owns() then
		local t = PTCT_CityVar(id)
		if t then return GetTask(t) end
		return 0
	end
	if PTCT_C_GetCityTask then return PTCT_C_GetCityTask(id) end
	return 0
end

function PTCT_SetCityTask(id, v)
	if PTCT_Owns() then
		local t = PTCT_CityVar(id)
		if t then SetTask(t, v) return 1 end
		return 0
	end
	if PTCT_C_SetCityTask then return PTCT_C_SetCityTask(id, v) end
	return 0
end

function PTCT_AddCityIndexRes(k, n)
	if PTCT_Owns() then return PTCT_AddRes(k, n or 1) end
	if PTCT_C_AddCityIndexRes then return PTCT_C_AddCityIndexRes(k, n) end
	return 0
end

function PTCT_GetTongContri()
	if PTCT_Owns() then return PTCT_Contri() end
	if PTCT_C_GetTongContri then return PTCT_C_GetTongContri() end
	return 0
end

function PTCT_AddTongContri(n)
	if PTCT_Owns() then return PTCT_AddContri(n) end
	if PTCT_C_AddTongContri then return PTCT_C_AddTongContri(n) end
	return 0
end

function PTCT_Msg2TongMember(s)
	if PTCT_Owns() then
		Msg2Player(s)
		return
	end
	if PTCT_C_Msg2TongMember then return PTCT_C_Msg2TongMember(s) end
end

function PTCT_AddTongAttr(t, n)
	if PTCT_Owns() then
		local k = PTCT_T_ATTR
		if t == 0 then k = PTCT_T_HUNG end
		local v = GetTask(k) + (n or 0)
		if v < 0 then v = 0 end
		SetTask(k, v)
		return v
	end
	if PTCT_C_AddTongAttr then return PTCT_C_AddTongAttr(t, n) end
	return 0
end

function PTCT_GetOwnCityLevel()
	if PTCT_Owns() then return PTCT_Level() end
	if PTCT_C_GetOwnCityLevel then return PTCT_C_GetOwnCityLevel() end
	return 0
end

-- VNG Say(text, n, { "label/fn", ... }) (Trai linh task list): the rebuilt engine never adds an exit row and
-- pt_compat only handles the string form, so the table form gets one here (building states only).
if PTCT_Say_C == nil then PTCT_Say_C = Say end
function PTCT_Say(text, n, ...)
	if arg.n == 1 and type(arg[1]) == "table" and type(n) == "number" and n >= 0 then
		local t = {}
		local i = 1
		while i <= n do
			t[i] = PTCT_CleanOpt(arg[1][i])
			i = i + 1
		end
		t[n + 1] = PTCT_TXT.exit .. "/PTCT_No"
		return PTCT_Say_C(text, n + 1, t)
	end
	local a = { text, n }
	local k = 1
	while k <= arg.n do
		a[k + 2] = PTCT_CleanOpt(arg[k])
		k = k + 1
	end
	a.n = arg.n + 2
	return call(PTCT_Say_C, a)
end
if Say ~= PTCT_Say then Say = PTCT_Say end
-- SayTask rows { label, callback; show } (pt_compat wrapper kept underneath)
if PTCT_SayTask_C == nil then PTCT_SayTask_C = SayTask end
function PTCT_SayTask(id, rows)
	if type(rows) == "table" then
		local c = {}
		local i = 1
		while rows[i] do
			local o = rows[i]
			if type(o) == "table" then
				c[i] = { PTCT_Clean(o[1]), o[2]; show = o.show }
			else
				c[i] = o
			end
			i = i + 1
		end
		rows = c
	end
	return PTCT_SayTask_C(id, rows)
end
if SayTask ~= PTCT_SayTask then SayTask = PTCT_SayTask end

PTCT_API_SELF = {}
PTCT_API_SELF[PTCT_IsOwnerCity] = 1
PTCT_API_SELF[PTCT_IsHaveTongRight] = 1
PTCT_API_SELF[PTCT_GetBuildingState] = 1
PTCT_API_SELF[PTCT_BuildingOperator] = 1
PTCT_API_SELF[PTCT_DestroyBuilding] = 1
PTCT_API_SELF[PTCT_GetCityInfo] = 1
PTCT_API_SELF[PTCT_GetCityTask] = 1
PTCT_API_SELF[PTCT_SetCityTask] = 1
PTCT_API_SELF[PTCT_AddCityIndexRes] = 1
PTCT_API_SELF[PTCT_GetTongContri] = 1
PTCT_API_SELF[PTCT_AddTongContri] = 1
PTCT_API_SELF[PTCT_Msg2TongMember] = 1
PTCT_API_SELF[PTCT_AddTongAttr] = 1
PTCT_API_SELF[PTCT_GetOwnCityLevel] = 1

IsOwnerCity = PTCT_IsOwnerCity
IsHaveTongRight = PTCT_IsHaveTongRight
GetBuildingState = PTCT_GetBuildingState
BuildingOperator = PTCT_BuildingOperator
DestroyBuilding = PTCT_DestroyBuilding
GetCityInfo = PTCT_GetCityInfo
GetCityTask = PTCT_GetCityTask
SetCityTask = PTCT_SetCityTask
AddCityIndexRes = PTCT_AddCityIndexRes
GetTongContri = PTCT_GetTongContri
AddTongContri = PTCT_AddTongContri
Msg2TongMember = PTCT_Msg2TongMember
AddTongAttr = PTCT_AddTongAttr
GetOwnCityLevel = PTCT_GetOwnCityLevel

-- solo scale of the VNG data tables (only touches tables this building script defines)
function PTCT_Tune()
	if PTCT_BUILDING == "shendian" and type(huahui_open_task) == "table" and huahui_open_task[5] then
		local il = huahui_open_task[5].item_list
		local i = 1
		while il and il[i] do
			if il[i][3] and il[i][3] > PTCT_SHENDIAN_ITEM_DIV then
				il[i][3] = floor(il[i][3] / PTCT_SHENDIAN_ITEM_DIV)
			end
			i = i + 1
		end
	end
end
if PTCT_TUNED == nil then
	PTCT_TUNED = 1
	PTCT_Tune()
end
