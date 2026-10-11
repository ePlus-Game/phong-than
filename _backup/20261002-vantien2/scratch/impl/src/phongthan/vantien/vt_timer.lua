-- Phong Than 2026-10-02: Van Tien tran minute tick. Hook (servertimer.lua, once a minute):
--   function PTAdm_VtTick()
--     if not PTVT_Tick then dofile("script\\phongthan\\vantien\\vt_timer.lua") end
--     if PTVT_Tick then PTVT_Tick() end
--   end
-- (called from PTAdm_Tick after PTAdm_WbTick)
-- Jobs: register the scripts once (loose + the 8 VNG trap scripts of the Huyen maps), keep Thien Hung
-- in Tay Ky, open the 4 tran at the VNG hours, repair stale states and sweep players (logout inside,
-- leftover flags).
Include("\\script\\phongthan\\vantien\\vt_lib.lua")

PTVT_SCRIPTS = {
	"\\script\\phongthan\\vantien\\vt_thienhung.lua",
	"\\script\\phongthan\\vantien\\vt_daiphu.lua",
	"\\script\\phongthan\\vantien\\vt_boss.lua",
	"\\script\\phongthan\\vantien\\vt_chest.lua",
	"\\script\\missions\\mission01.lua",
	"\\script\\missions\\mission02.lua",
	"\\script\\missions\\mission03.lua",
	"\\script\\missions\\mission04.lua",
	"\\script\\timertask\\task01.lua",
	"\\script\\timertask\\task02.lua",
	"\\script\\timertask\\task03.lua",
	"\\script\\timertask\\task04.lua",
	"\\script\\timertask\\task05.lua",
	"\\script\\timertask\\task06.lua",
	"\\script\\timertask\\task07.lua",
	"\\script\\timertask\\task08.lua",
	"\\script\\timertask\\task09.lua",
}

function PTVT_Register()
	local k = 1
	while PTVT_SCRIPTS[k] do
		ReLoadScript(PTVT_SCRIPTS[k])
		k = k + 1
	end
	k = 1
	while PTVT_TRAP_SCRIPTS[k] do
		ReLoadScript(PTVT_TRAP_SCRIPTS[k])
		k = k + 1
	end
end

function PTVT_EnsureThienHung()
	local ni = PTVT_TH_NI
	if ni and ni > 0 and GetNpcName(ni) == PTVT_TH_NAME then
		local w = GetNpcPos(ni)
		if w == PTVT_TH[1] then return ni end
	end
	local sw = SubWorldID2Idx(PTVT_TH[1])
	if not sw or sw < 0 then return 0 end
	ni = AddNpc(PTVT_TH[4], 1, sw, PTVT_TH[2], PTVT_TH[3], 0)
	if ni and ni > 0 then
		SetNpcName(ni, PTVT_TH_NAME)
		SetNpcScript(ni, PTVT_TH_SCRIPT)
		PTVT_TH_NI = ni
		return ni
	end
	return 0
end

function PTVT_Schedule(hm)
	local h = 1
	while PTVT_SCHED[h] do
		local base = tonumber(strsub(PTVT_SCHED[h], 1, 2)) * 60 + tonumber(strsub(PTVT_SCHED[h], 4, 5))
		local n = 1
		while n <= 4 do
			local m = base + PTVT_SCHED_OFFSET[n]
			local slot = format("%02d:%02d", floor(m / 60), mod(m, 60))
			if slot == hm and PTVT_IsOpen(n) == 0 then
				if PTVT_Open(n, PTVT_PREP_SCHED) == 1 then
					AddGlobalNews("Vạn Tiên trận (" .. PTVT_NAME[n] .. ") mở theo giờ, " .. floor(PTVT_PREP_SCHED / 60) .. " phút nữa bắt đầu. Gặp Thiên Hùng ở Tây Kỳ để vào trận.")
				end
			end
			n = n + 1
		end
		h = h + 1
	end
end

-- players: back to Tay Ky when standing in a closed tran; re-registered after a relog inside an open
-- tran; logout-revive flag cleared once they are outside.
function PTVT_Sweep()
	local inside = {}
	local open = {}
	local n = 1
	while n <= 4 do
		open[n] = PTVT_IsOpen(n)
		if open[n] == 1 then
			if PTVT_GV(n, 0) == 0 then PTVT_SetGV(n, 0, 1) end
			local l = PTVT_Inside(n)
			local s = {}
			local i = 1
			while l[i] do
				s[l[i]] = 1
				i = i + 1
			end
			inside[n] = s
		else
			if PTVT_GV(n, 0) ~= 0 then PTVT_SetGV(n, 0, 0) end
			inside[n] = {}
		end
		n = n + 1
	end
	local moved = 0
	local i = 1
	while i <= PTVT_MAX_PLAYER do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" then
			local w = GetWorldPos()
			local t = PTVT_MapToN(w)
			if t then
				if open[t] ~= 1 then
					Msg2Player("Vạn Tiên trận (" .. PTVT_NAME[t] .. ") đã đóng, đưa về Tây Kỳ.")
					PTVT_ToTown()
					moved = moved + 1
				elseif not inside[t][i] then
					PTVT_UseWorld(t)
					AddMSPlayer(t, 1)
					PlayerIndex = i
					SetLogoutRV(1)
					SetTask(PTVT_T_INMAP, w)
					if PTVT_GV(t, 0) >= 2 then SetFightState(1) else SetFightState(0) end
					inside[t][i] = 1
				end
			elseif GetTask(PTVT_T_INMAP) ~= 0 then
				SetTask(PTVT_T_INMAP, 0)
				SetLogoutRV(0)
				PTVT_ClearTokens()
			end
		end
		i = i + 1
	end
	PlayerIndex = nil
	return moved
end

function PTVT_Tick()
	local oldSubWorld = SubWorld
	if not PTVT_REGISTERED then
		PTVT_Register()
		PTVT_REGISTERED = 1
	end
	PTVT_EnsureThienHung()
	PTVT_Schedule(date("%H:%M"))
	PTVT_Sweep()
	PlayerIndex = nil
	SubWorld = oldSubWorld
end

-- admin / test helper (web admin bridge): open tran n now
function PTVT_AdminOpen(n)
	if PTVT_Open(n, PTVT_PREP_DEMAND) == 1 then return 1 end
	return 0
end
