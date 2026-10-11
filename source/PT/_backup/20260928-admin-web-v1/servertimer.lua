-- Neutral Phong Than server heartbeat.
-- CoreServer calls main() once per minute; official scheduled gameplay is
-- provided by the Phong Than registries, not by inherited private-server data.
--
-- Local admin bridge (AdminWeb\PhongThan-Admin.ps1). The web tool writes Lua
-- calls to admin_bridge\pending.lua with an atomic replace; each minute the
-- queue is renamed to running.lua, executed once and deleted. Results go to
-- admin_bridge\result.log, online players to admin_bridge\online.txt.
-- Paths are relative to the GameServer working directory (runtime Server\).

PTADM_DIR = "admin_bridge\\"
PTADM_MAX_PLAYER = 1200
PTADM_NPCS = {}
PTADM_NPC_COUNT = 0

function PTAdm_Log(id, status, text)
	local h = openfile(PTADM_DIR .. "result.log", "a")
	if h then
		write(h, date("%Y-%m-%d %H:%M:%S") .. "\t" .. id .. "\t" .. status .. "\t" .. (text or "") .. "\n")
		closefile(h)
	end
end

function PTAdm_FindPlayer(name)
	local pi = GetPlayerIndexByName(name)
	if pi and pi > 0 then
		PlayerIndex = pi
		if GetName() then return pi end
	end
	return nil
end

function PTAdm_GiveTo(pi, g, d, p, lv, se, n)
	PlayerIndex = pi
	local ok = 0
	local k = 1
	while k <= n do
		local idx = AddItem(g, d, p, lv, se, 0)
		if idx and idx > 0 then
			AddItemID(idx, 0)
			ok = ok + 1
		end
		k = k + 1
	end
	return ok
end

-- Give n items (genre, detail, particular, level, series) to one online player.
function PTAdm_Give(id, name, g, d, p, lv, se, n, itemName)
	local pi = PTAdm_FindPlayer(name)
	if not pi then PTAdm_Log(id, "FAIL", "offline " .. name) return end
	local ok = PTAdm_GiveTo(pi, g, d, p, lv, se, n)
	if ok > 0 then Msg2Player("Admin t∆ng: " .. (itemName or "vÀt ph»m") .. " x" .. ok) end
	if ok == n then PTAdm_Log(id, "OK", name .. " +" .. ok) else PTAdm_Log(id, "FAIL", name .. " created " .. ok .. "/" .. n) end
end

-- Give items to every online player.
function PTAdm_GiveAll(id, g, d, p, lv, se, n, itemName)
	local i = 1
	local players = 0
	while i <= PTADM_MAX_PLAYER do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" then
			local ok = PTAdm_GiveTo(i, g, d, p, lv, se, n)
			if ok > 0 then
				PlayerIndex = i
				Msg2Player("Admin t∆ng: " .. (itemName or "vÀt ph»m") .. " x" .. ok)
				players = players + 1
			end
		end
		i = i + 1
	end
	PTAdm_Log(id, "OK", "players=" .. players)
end

function PTAdm_Money(id, name, amount)
	local pi = PTAdm_FindPlayer(name)
	if not pi then PTAdm_Log(id, "FAIL", "offline " .. name) return end
	Earn(amount)
	PTAdm_Log(id, "OK", name .. " money+" .. amount)
end

function PTAdm_Exp(id, name, amount)
	local pi = PTAdm_FindPlayer(name)
	if not pi then PTAdm_Log(id, "FAIL", "offline " .. name) return end
	AddOwnExp(amount)
	PTAdm_Log(id, "OK", name .. " exp+" .. amount)
end

function PTAdm_News(id, text)
	AddGlobalNews(text)
	PTAdm_Log(id, "OK", "news")
end

-- Spawn count NPCs of template row npc at map/x/y (GetWorldPos units: pixel/32).
function PTAdm_SpawnAt(id, npc, lv, mapId, x, y, count)
	local sw = SubWorldID2Idx(mapId)
	if not sw or sw < 0 then PTAdm_Log(id, "FAIL", "map " .. mapId .. " not loaded") return end
	local ok = 0
	local k = 1
	while k <= count do
		local dx = mod(k - 1, 5) * 2 - 4
		local dy = floor((k - 1) / 5) * 2
		if count == 1 then dx = 0 dy = 0 end
		local ni = AddNpc(npc, lv, sw, (x + dx) * 32, (y + dy) * 32, 0)
		if ni and ni > 0 then
			ok = ok + 1
			PTADM_NPC_COUNT = PTADM_NPC_COUNT + 1
			PTADM_NPCS[PTADM_NPC_COUNT] = ni
		end
		k = k + 1
	end
	if ok == count then PTAdm_Log(id, "OK", "spawned " .. ok) else PTAdm_Log(id, "FAIL", "spawned " .. ok .. "/" .. count) end
end

function PTAdm_SpawnNear(id, npc, lv, name, count)
	local pi = PTAdm_FindPlayer(name)
	if not pi then PTAdm_Log(id, "FAIL", "offline " .. name) return end
	local w, x, y = GetWorldPos()
	PTAdm_SpawnAt(id, npc, lv, w, x + 3, y + 3, count)
end

-- Remove every NPC spawned through the admin bridge since server start.
function PTAdm_ClearSpawned(id)
	local k = 1
	local n = 0
	while k <= PTADM_NPC_COUNT do
		if PTADM_NPCS[k] and PTADM_NPCS[k] > 0 then
			DelNpc(PTADM_NPCS[k])
			n = n + 1
		end
		PTADM_NPCS[k] = nil
		k = k + 1
	end
	PTADM_NPC_COUNT = 0
	PTAdm_Log(id, "OK", "removed " .. n)
end

function PTAdm_DumpOnline()
	local h = openfile(PTADM_DIR .. "online.tmp", "w")
	if not h then return end
	write(h, date("%Y-%m-%d %H:%M:%S") .. "\n")
	local i = 1
	while i <= PTADM_MAX_PLAYER do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" then
			local w, x, y = GetWorldPos()
			write(h, nm .. "\t" .. (GetAccount() or "") .. "\t" .. (GetLevel() or 0) .. "\t" .. (w or 0) .. "\t" .. (x or 0) .. "\t" .. (y or 0) .. "\n")
		end
		i = i + 1
	end
	closefile(h)
	remove(PTADM_DIR .. "online.txt")
	rename(PTADM_DIR .. "online.tmp", PTADM_DIR .. "online.txt")
end

function PTAdm_Tick()
	if rename(PTADM_DIR .. "pending.lua", PTADM_DIR .. "running.lua") then
		dofile(PTADM_DIR .. "running.lua")
		remove(PTADM_DIR .. "running.lua")
	end
	PTAdm_DumpOnline()
	PlayerIndex = nil
	local h = openfile(PTADM_DIR .. "heartbeat.txt", "w")
	if h then
		write(h, date("%Y-%m-%d %H:%M:%S"))
		closefile(h)
	end
end

function main()
	PTAdm_Tick()
end
