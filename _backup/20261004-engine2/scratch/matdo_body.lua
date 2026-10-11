
-- ------------------------------------------------------------------ settings
PTMD_CFG_FILE = "admin_bridge\\matdo_config.lua"
PTMD_STATUS = "admin_bridge\\matdo.txt"
PTMD_CAP = 44000        -- GetNpcCount() never above this (engine MAX_NPC 48000: room for bots, bosses, missions)
PTMD_ADD_CALLS = 4000   -- AddNpc calls per tick (spawn_main places 4000 per tick at start)
PTMD_DEL_MAX = 2500     -- DelNpc per tick when the factor is lowered / the budget moves to another map
PTMD_REV_CHUNK = 12000  -- SetNpcRevTime per tick in the revive pass
PTMD_HOT_KEEP = 15      -- a map keeps priority 15 ticks (minutes) after the last player left it
PTMD_REPASS = 30        -- revive pass repeated every 30 ticks even without a config change
PTMD_RETRY = 10         -- a slot whose AddNpc failed is retried after 10 ticks
PTMD_SLOT = 12          -- npc param slots: 12 = PTMD_TAG, 11 = slot e, 13 = map
PTMD_TAG = 7310417
PTMD_FPS = 18           -- game frames per second (ReviveFrame 540 = 30 s)
PTMD_MAXNPC = 48000
PTMD_DROP_SCRIPT = "\\script\\phongthan\\npc_fix\\mob_drop.lua"
PTMD_DX = { 1, 1, 0, -1, -1, -1, 0, 1 }
PTMD_DY = { 0, 1, 1, 1, 0, -1, -1, -1 }
PTMD_RAD = { 128, 64 }  -- extras stand 4 cells (then 2 cells) from their spawn point, 8 directions

-- ------------------------------------------------------------------ state (kept when this file is loaded again)
if PTMD_X == nil then PTMD_X = {} PTMD_XI = {} PTMD_XMAX = {} PTMD_XF = {} end
if PTMD_TICK == nil then PTMD_TICK = 0 end
if PTMD_HOT == nil then PTMD_HOT = {} end
if PTMD_SEEDS == nil then PTMD_SEEDS = {} PTMD_SEEDN = {} end
if PTMD_PN == nil then PTMD_PN = 0 PTMD_PNI = {} PTMD_PID = {} PTMD_PMAP = {} PTMD_PTID = {} end
if PTMD_CUR == nil then PTMD_CUR = {} PTMD_ALLOC = {} PTMD_WANT = {} end
if PTMD_D == nil then PTMD_D = 10 PTMD_R = 0 PTMD_ALL = 1 PTMD_SCOPE = {} PTMD_SIG = "" PTMD_SRC = "default" end
PTMD_MAPSET = {}
PTMD_K = 1
while PTMD_MAPS[PTMD_K] do
	PTMD_MAPSET[PTMD_MAPS[PTMD_K]] = 1
	if not PTMD_X[PTMD_MAPS[PTMD_K]] then
		PTMD_X[PTMD_MAPS[PTMD_K]] = {} PTMD_XI[PTMD_MAPS[PTMD_K]] = {} PTMD_XF[PTMD_MAPS[PTMD_K]] = {}
		PTMD_XMAX[PTMD_MAPS[PTMD_K]] = 0
	end
	PTMD_K = PTMD_K + 1
end

-- ------------------------------------------------------------------ config
function PTMD_CfgErr(m) PTMD_CFGERR = tostring(m) end

function PTMD_Clamp(v, a, b, def)
	if type(v) ~= "number" then return def end
	v = floor(v)
	if v < a then return a end
	if v > b then return b end
	return v
end

function PTMD_SetCfg(d, r, all, maps)
	d = PTMD_Clamp(d, 10, 30, 10)
	r = PTMD_Clamp(r, 0, 600, 0)
	if r > 0 and r < 3 then r = 3 end
	local a = 1
	if all == 0 then a = 0 end
	local sc = {}
	local sig = d .. ":" .. r .. ":" .. a
	local k = 1
	if a == 1 then
		while PTMD_MAPS[k] do sc[PTMD_MAPS[k]] = 1 k = k + 1 end
	elseif type(maps) == "table" then
		while maps[k] do
			if PTMD_MAPSET[maps[k]] and not sc[maps[k]] then sc[maps[k]] = 1 sig = sig .. ":" .. maps[k] end
			k = k + 1
		end
	end
	PTMD_D = d PTMD_R = r PTMD_ALL = a PTMD_SCOPE = sc PTMD_SIG = sig
end

-- admin_bridge\matdo_config.lua: PTMD_CFG = { density = 20, revive = 10, all = 1, maps = { ... } }
function PTMD_LoadCfg()
	local h = openfile(PTMD_CFG_FILE, "r")
	if not h then
		PTMD_SetCfg(10, 0, 1, nil)
		PTMD_SRC = "default"
		return
	end
	closefile(h)
	local old = PTMD_CFG
	PTMD_CFG = nil
	call(dofile, { PTMD_CFG_FILE }, "x", PTMD_CfgErr)
	if type(PTMD_CFG) ~= "table" then
		PTMD_CFG = old
		PTMD_SRC = "error"
		return
	end
	PTMD_SetCfg(PTMD_CFG.density, PTMD_CFG.revive, PTMD_CFG.all, PTMD_CFG.maps)
	PTMD_SRC = "file"
end

-- revive frames for a monster of template tid on map m (nil = leave it)
function PTMD_Frames(m, tid)
	if PTMD_SCOPE[m] and PTMD_R > 0 then return PTMD_R * PTMD_FPS end
	return PTMD_RF[tid]
end

function PTMD_Want(m)
	if not PTMD_SCOPE[m] then return 0 end
	return floor((PTMD_SEEDN[m] or 0) * (PTMD_D - 10) / 10)
end

-- ------------------------------------------------------------------ seeds and population
function PTMD_InitSeeds()
	local k = 1
	while PTMD_MAPS[k] do
		local m = PTMD_MAPS[k]
		if not PTMD_REGION[m] then
			if PT_SPAWN_DATA[m] then
				PTMD_SEEDS[m] = PT_SPAWN_DATA[m]
				PTMD_SEEDN[m] = getn(PT_SPAWN_DATA[m])
			else
				PTMD_SEEDN[m] = 0
			end
		end
		k = k + 1
	end
end

function PTMD_PopAdd(ni, id, m, tid)
	local p = PTMD_PN + 1
	PTMD_PN = p
	PTMD_PNI[p] = ni
	PTMD_PID[p] = id
	PTMD_PMAP[p] = m
	PTMD_PTID[p] = tid
end

-- spawn_main population (PT_SPAWN_NPCS) without the quest-target specials (PT_SPAWN_SPECIAL templates)
function PTMD_BuildPop()
	local sp = {}
	local k = 1
	while PTMD_MAPS[k] do
		local t = PT_SPAWN_SPECIAL and PT_SPAWN_SPECIAL[PTMD_MAPS[k]]
		local j = 1
		while t and t[j] do sp[PTMD_MAPS[k] * 10000 + t[j][1]] = 1 j = j + 1 end
		k = k + 1
	end
	k = 1
	while k <= (PT_SPAWN_NPCN or 0) do
		local ni = PT_SPAWN_NPCS[k]
		if ni and ni > 0 then
			local id = GetNpcID(ni)
			if id and id > 0 then
				local w = GetNpcPos(ni)
				local tid = GetNpcTemplateID(ni)
				if w and PTMD_MAPSET[w] and tid and PTMD_RF[tid] and not sp[w * 10000 + tid] then PTMD_PopAdd(ni, id, w, tid) end
			end
		end
		k = k + 1
	end
	PTMD_POPBUILT = 1
end

function PTMD_ExIdx(ex, t)
	if type(t) ~= "table" then return end
	local k, v = next(t, nil)
	while k do
		if type(v) == "number" then ex[v] = 1 end
		k, v = next(t, k)
	end
end

-- extra found by the scan (fresh script state, same server run): keep it in its slot, delete duplicates
function PTMD_Adopt(i, id)
	local m = GetNpcParam(i, 13)
	local e = GetNpcParam(i, 11)
	local X = PTMD_X[m]
	if X and e and e > 0 then
		if X[e] == i then return 1 end
		if not (X[e] and GetNpcID(X[e]) == PTMD_XI[m][e]) then
			X[e] = i
			PTMD_XI[m][e] = id
			if e > PTMD_XMAX[m] then PTMD_XMAX[m] = e end
			return 1
		end
	end
	DelNpc(i)
	return nil
end

-- one pass over every npc index: adopt tagged extras; collect the VNG Region_S monsters of PTMD_REGION maps
-- (normal templates PTMD_RW, not quest mobs of servertimer / newbie2, not tagged, not boss) as seeds
function PTMD_RegionSeed(i, id, w, x, y, tid)
	local t = PTMD_RS[w]
	if not t then t = {} PTMD_RS[w] = t PTMD_RSN[w] = 0 end
	local n = PTMD_RSN[w] + 1
	PTMD_RSN[w] = n
	local r = {}
	r[1] = tid
	r[2] = GetNpcLevel(i)
	r[3] = x * 32
	r[4] = y * 32
	r[5] = GetNpcName(i)
	t[n] = r
	PTMD_PopAdd(i, id, w, tid)
end

function PTMD_Scan()
	local ex = {}
	PTMD_ExIdx(ex, PTADM_MOBS)
	PTMD_ExIdx(ex, PTADM_SPAWNED)
	PTMD_ExIdx(ex, PTADM_NPCS)
	PTMD_ExIdx(ex, PTNB2_NPC_IDX)
	local et = {}
	local k = 1
	while PTADM_MOB_SPAWN and PTADM_MOB_SPAWN[k] do
		et[PTADM_MOB_SPAWN[k][1] * 10000 + PTADM_MOB_SPAWN[k][2]] = 1
		k = k + 1
	end
	PTMD_RS = {}
	PTMD_RSN = {}
	PTMD_ADOPTED = 0
	PTMD_DUPDEL = 0
	local i = 1
	while i < PTMD_MAXNPC do
		local id = GetNpcID(i)
		if id and id > 0 then
			if GetNpcParam(i, PTMD_SLOT) == PTMD_TAG then
				if PTMD_Adopt(i, id) then PTMD_ADOPTED = PTMD_ADOPTED + 1 else PTMD_DUPDEL = PTMD_DUPDEL + 1 end
			else
				local w, x, y = GetNpcPos(i)
				if PTMD_REGION[w] and not ex[i] then
					local tid = GetNpcTemplateID(i)
					if tid and PTMD_RW[tid] and not et[w * 10000 + tid] and GetNpcParam(i, 0) == 0 and (GetNpcBoss(i) or 0) == 0 then
						PTMD_RegionSeed(i, id, w, x, y, tid)
					end
				end
			end
		end
		i = i + 1
	end
	k = 1
	while PTMD_MAPS[k] do
		if PTMD_REGION[PTMD_MAPS[k]] then
			PTMD_SEEDS[PTMD_MAPS[k]] = PTMD_RS[PTMD_MAPS[k]] or {}
			PTMD_SEEDN[PTMD_MAPS[k]] = PTMD_RSN[PTMD_MAPS[k]] or 0
		end
		k = k + 1
	end
	PTMD_RS = nil
	PTMD_RSN = nil
	PTMD_SCANNED = 1
end

-- ------------------------------------------------------------------ players: maps with a player get priority
function PTMD_Hot()
	local old = PlayerIndex
	local i = 1
	PTMD_PLAYERS = 0
	while i <= (PTADM_MAX_PLAYER or 1200) do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" then
			local w = GetWorldPos()
			PTMD_PLAYERS = PTMD_PLAYERS + 1
			if w and PTMD_MAPSET[w] then PTMD_HOT[w] = PTMD_TICK end
		end
		i = i + 1
	end
	PlayerIndex = old
end

function PTMD_IsHot(m)
	if PTMD_HOT[m] and PTMD_TICK - PTMD_HOT[m] <= PTMD_HOT_KEEP then return 1 end
	return nil
end

function PTMD_HotOrder()
	local t = {}
	local n = 0
	local k = 1
	while PTMD_MAPS[k] do
		local m = PTMD_MAPS[k]
		if PTMD_IsHot(m) then
			n = n + 1
			local j = n
			while j > 1 and PTMD_HOT[t[j - 1]] < PTMD_HOT[m] do t[j] = t[j - 1] j = j - 1 end
			t[j] = m
		end
		k = k + 1
	end
	return t
end

-- ------------------------------------------------------------------ extras
-- drops / quest counters of the originals: the same ActionScript the other features bind to that template
function PTMD_Bind(ni, tid, m)
	if PTSD_DROPMAPS and PTSD_DROP_SCRIPT and PTSD_DROPMAPS[m] and PTSD_DROPMAPS[m][tid] then
		SetNpcScript(ni, PTSD_DROP_SCRIPT)
	elseif PTQ3_DROP_TPL and PTQ3_DROP_SCRIPT and PTQ3_DROP_TPL[tid] then
		SetNpcScript(ni, PTQ3_DROP_SCRIPT)
	elseif PTNB2_BIND_TID and PTNB2_MOB_SCRIPT and PTNB2_BIND_TID[tid] then
		SetNpcScript(ni, PTNB2_MOB_SCRIPT)
		if PTNB2_BOUND then PTNB2_BOUND[ni] = GetNpcID(ni) end
	elseif PT_SPAWN_DROP_TIDS and PT_SPAWN_DROP_TIDS[tid] then
		SetNpcScript(ni, PTMD_DROP_SCRIPT)
	end
end

-- valid extras of map m (drops entries whose npc was deleted by someone else: index + GetNpcID check)
function PTMD_CountMap(m)
	local X = PTMD_X[m]
	local e = 1
	local c = 0
	while e <= PTMD_XMAX[m] do
		if X[e] then
			if GetNpcID(X[e]) == PTMD_XI[m][e] then c = c + 1 else X[e] = nil PTMD_XI[m][e] = nil end
		end
		e = e + 1
	end
	e = PTMD_XMAX[m]
	while e > 0 and not X[e] do e = e - 1 end
	PTMD_XMAX[m] = e
	return c
end

-- slot e -> seed: odd seeds first, then even ones (seed rows run outward from the map entry, so any prefix of
-- slots is spread over the whole map), next round for e > n; 8 directions around the seed, then the seed point
function PTMD_SpawnSlot(m, sw, e, n)
	local r = mod(e - 1, n)
	local s = 2 * r + 1
	if r >= floor((n + 1) / 2) then s = 2 * (r - floor((n + 1) / 2)) + 2 end
	local row = PTMD_SEEDS[m][s]
	if not row then return nil end
	local d0 = mod(e * 3 + floor((e - 1) / n) * 5, 8)
	local ni = 0
	local k = 0
	while k < 16 and ni <= 0 do
		local d = mod(d0 + k, 8) + 1
		PTMD_CALLS = PTMD_CALLS + 1
		ni = AddNpc(row[1], row[2], sw, row[3] + PTMD_DX[d] * PTMD_RAD[floor(k / 8) + 1], row[4] + PTMD_DY[d] * PTMD_RAD[floor(k / 8) + 1], 1) or 0
		k = k + 1
	end
	if ni <= 0 then
		PTMD_CALLS = PTMD_CALLS + 1
		ni = AddNpc(row[1], row[2], sw, row[3], row[4], 0) or 0
	end
	if ni <= 0 then return nil end
	PTMD_X[m][e] = ni
	PTMD_XI[m][e] = GetNpcID(ni)
	if e > PTMD_XMAX[m] then PTMD_XMAX[m] = e end
	PTMD_CUR[m] = (PTMD_CUR[m] or 0) + 1
	SetNpcParam(ni, PTMD_SLOT, PTMD_TAG)
	SetNpcParam(ni, 11, e)
	SetNpcParam(ni, 13, m)
	if row[5] and row[5] ~= "" and GetNpcName(ni) ~= row[5] then SetNpcName(ni, row[5]) end
	PTMD_Bind(ni, row[1], m)
	if PTMD_SCOPE[m] and PTMD_R > 0 then SetNpcRevTime(ni, PTMD_R * PTMD_FPS) end
	return 1
end

-- remove extras of slots above the allocation (highest slot first)
function PTMD_Trim(m, budget)
	local X = PTMD_X[m]
	local e = PTMD_XMAX[m]
	local n = 0
	while e > PTMD_ALLOC[m] and n < budget do
		if X[e] then
			if GetNpcID(X[e]) == PTMD_XI[m][e] then
				DelNpc(X[e])
				n = n + 1
				PTMD_CUR[m] = PTMD_CUR[m] - 1
			end
			X[e] = nil
			PTMD_XI[m][e] = nil
		end
		e = e - 1
	end
	while e > 0 and not X[e] do e = e - 1 end
	PTMD_XMAX[m] = e
	return n
end

-- fill the empty slots 1..allocation of map m
function PTMD_Fill(m, live)
	local a = PTMD_ALLOC[m]
	local n = PTMD_SEEDN[m] or 0
	if a <= 0 or n <= 0 then return 0 end
	local sw = SubWorldID2Idx(m)
	if not sw or sw < 0 then return 0 end
	local X = PTMD_X[m]
	local F = PTMD_XF[m]
	local e = 1
	local added = 0
	while e <= a and PTMD_CALLS < PTMD_ADD_CALLS and live + added < PTMD_CAP do
		if not X[e] and (not F[e] or PTMD_TICK - F[e] >= PTMD_RETRY) then
			if PTMD_SpawnSlot(m, sw, e, n) then added = added + 1 F[e] = nil else F[e] = PTMD_TICK end
		end
		e = e + 1
	end
	return added
end

-- budget: maps with a player first (full factor), the others share what is left proportionally
function PTMD_Allocate(hot, avail)
	local k = 1
	while hot[k] do
		local a = PTMD_WANT[hot[k]]
		if a > avail then a = avail end
		PTMD_ALLOC[hot[k]] = a
		avail = avail - a
		k = k + 1
	end
	local rest = 0
	k = 1
	while PTMD_MAPS[k] do
		if not PTMD_IsHot(PTMD_MAPS[k]) then rest = rest + PTMD_WANT[PTMD_MAPS[k]] end
		k = k + 1
	end
	if rest <= 0 then return end
	if avail > rest then avail = rest end
	k = 1
	while PTMD_MAPS[k] do
		if not PTMD_IsHot(PTMD_MAPS[k]) then PTMD_ALLOC[PTMD_MAPS[k]] = floor(PTMD_WANT[PTMD_MAPS[k]] * avail / rest) end
		k = k + 1
	end
end

function PTMD_Sync()
	local mine = 0
	local k = 1
	while PTMD_MAPS[k] do
		local m = PTMD_MAPS[k]
		PTMD_CUR[m] = PTMD_CountMap(m)
		PTMD_WANT[m] = PTMD_Want(m)
		PTMD_ALLOC[m] = 0
		mine = mine + PTMD_CUR[m]
		k = k + 1
	end
	local cnt = GetNpcCount() or 0
	local avail = PTMD_CAP - (cnt - mine)
	if avail < 0 then avail = 0 end
	local hot = PTMD_HotOrder()
	PTMD_Allocate(hot, avail)
	local del = 0
	k = 1
	while PTMD_MAPS[k] and del < PTMD_DEL_MAX do
		del = del + PTMD_Trim(PTMD_MAPS[k], PTMD_DEL_MAX - del)
		k = k + 1
	end
	PTMD_CALLS = 0
	local added = 0
	k = 1
	while hot[k] do
		added = added + PTMD_Fill(hot[k], cnt - del + added)
		k = k + 1
	end
	k = 1
	while PTMD_MAPS[k] do
		if not PTMD_IsHot(PTMD_MAPS[k]) then added = added + PTMD_Fill(PTMD_MAPS[k], cnt - del + added) end
		k = k + 1
	end
	PTMD_MINE = mine - del + added
	PTMD_LASTADD = added
	PTMD_LASTDEL = del
end

-- ------------------------------------------------------------------ revive time
function PTMD_ReviveExtras()
	local j = 1
	while PTMD_MAPS[j] do
		local X = PTMD_X[PTMD_MAPS[j]]
		local e = 1
		while e <= PTMD_XMAX[PTMD_MAPS[j]] do
			if X[e] then
				local f = PTMD_Frames(PTMD_MAPS[j], GetNpcTemplateID(X[e]))
				if f then SetNpcRevTime(X[e], f) PTMD_RV_N = PTMD_RV_N + 1 end
			end
			e = e + 1
		end
		j = j + 1
	end
end

function PTMD_RevivePass()
	if PTMD_RV_K == nil or PTMD_RV_RUN ~= PTMD_SIG then
		if PTMD_RV_K == nil and PTMD_RV_DONE == PTMD_SIG and PTMD_TICK - (PTMD_RV_AT or 0) < PTMD_REPASS then return end
		PTMD_RV_K = 1
		PTMD_RV_RUN = PTMD_SIG
		PTMD_RV_N = 0
	end
	local k = PTMD_RV_K
	local last = k + PTMD_REV_CHUNK - 1
	if last > PTMD_PN then last = PTMD_PN end
	while k <= last do
		if GetNpcID(PTMD_PNI[k]) == PTMD_PID[k] then
			local f = PTMD_Frames(PTMD_PMAP[k], PTMD_PTID[k])
			if f then SetNpcRevTime(PTMD_PNI[k], f) PTMD_RV_N = PTMD_RV_N + 1 end
		end
		k = k + 1
	end
	PTMD_RV_K = k
	if k > PTMD_PN then
		PTMD_ReviveExtras()
		PTMD_RV_K = nil
		PTMD_RV_DONE = PTMD_SIG
		PTMD_RV_AT = PTMD_TICK
	end
end

-- ------------------------------------------------------------------ status for AdminWeb (admin_bridge\matdo.txt)
-- cfg / density x10 / revive s / all / source; total / npc count / extras / cap / seeds / state / added / removed /
-- revive progress / revive set / players; map / id / seeds / extras / allocation / wanted / hot / in scope / revive s
function PTMD_WriteStatus()
	local h = openfile(PTMD_STATUS .. ".tmp", "w")
	if not h then return end
	local seeds = 0
	local k = 1
	while PTMD_MAPS[k] do seeds = seeds + (PTMD_SEEDN[PTMD_MAPS[k]] or 0) k = k + 1 end
	local rv = "done"
	if PTMD_RV_K then rv = PTMD_RV_K .. "/" .. PTMD_PN end
	write(h, date("%Y-%m-%d %H:%M:%S") .. "\n")
	write(h, "cfg\t" .. PTMD_D .. "\t" .. PTMD_R .. "\t" .. PTMD_ALL .. "\t" .. PTMD_SRC .. "\n")
	write(h, "total\t" .. (GetNpcCount() or 0) .. "\t" .. (PTMD_MINE or 0) .. "\t" .. PTMD_CAP .. "\t" .. seeds .. "\t" .. (PTMD_STATE or "") .. "\t" .. (PTMD_LASTADD or 0) .. "\t" .. (PTMD_LASTDEL or 0) .. "\t" .. rv .. "\t" .. (PTMD_RV_N or 0) .. "\t" .. (PTMD_PLAYERS or 0) .. "\n")
	k = 1
	while PTMD_MAPS[k] do
		local m = PTMD_MAPS[k]
		local hot = 0
		local sc = 0
		local r = 0
		if PTMD_IsHot(m) then hot = 1 end
		if PTMD_SCOPE[m] then sc = 1 r = PTMD_R end
		write(h, "map\t" .. m .. "\t" .. (PTMD_SEEDN[m] or 0) .. "\t" .. (PTMD_CUR[m] or 0) .. "\t" .. (PTMD_ALLOC[m] or 0) .. "\t" .. (PTMD_WANT[m] or 0) .. "\t" .. hot .. "\t" .. sc .. "\t" .. r .. "\n")
		k = k + 1
	end
	closefile(h)
	remove(PTMD_STATUS)
	rename(PTMD_STATUS .. ".tmp", PTMD_STATUS)
end

-- ------------------------------------------------------------------ entry points
function PTMD_Run()
	PTMD_LoadCfg()
	if not PT_SPAWN_DONE or not PT_SPAWN_DATA then
		PTMD_STATE = "wait"
		PTMD_WriteStatus()
		return
	end
	if not PTMD_SEEDINIT then PTMD_InitSeeds() PTMD_SEEDINIT = 1 end
	if not PTMD_SCANNED then PTMD_Scan() end
	if not PTMD_POPBUILT then PTMD_BuildPop() end
	PTMD_STATE = "ok"
	PTMD_Hot()
	PTMD_Sync()
	PTMD_RevivePass()
	PTMD_WriteStatus()
end

function PTEXT_matdo_Tick()
	PTMD_TICK = PTMD_TICK + 1
	PTMD_Run()
end

-- AdminWeb "Ap dung": re-read the config and work at once (the minute tick continues afterwards)
function PTEXT_matdo_Apply(id)
	PTMD_RV_DONE = nil
	PTMD_Run()
	local rv = "xong"
	if PTMD_RV_K then rv = PTMD_RV_K .. "/" .. PTMD_PN end
	local s = "x" .. (PTMD_D / 10) .. ", hoi " .. PTMD_R .. "s (0 = Npcs.txt), " .. PTMD_ALL .. "=tat ca ban do; cau hinh " .. PTMD_SRC
	s = s .. "; them " .. (PTMD_LASTADD or 0) .. ", xoa " .. (PTMD_LASTDEL or 0) .. ", quai them " .. (PTMD_MINE or 0)
	s = s .. ", NPC " .. (GetNpcCount() or 0) .. "/" .. PTMD_CAP .. ", dat hoi " .. (PTMD_RV_N or 0) .. " quai (" .. rv .. ")"
	if PTMD_STATE ~= "ok" then s = s .. " - cho quai goc sinh xong" end
	if PTAdm_Log then PTAdm_Log(id, "OK", s) end
end
