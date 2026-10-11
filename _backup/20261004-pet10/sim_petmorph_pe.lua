-- petexp 2026-10-03: run sim_petmorph.lua unchanged against the NEW trieuhoi_lenhbai.lua + petexp_lib.lua
-- (scratchpad\petexp\out, or the deployed files with -Args1 "live" / "emu,live"). Only change: the coordinator's
-- 7-row token menu (2026-10-03) replaces the old 17-row check. Output out_petmorph_pe[_emu][_live].txt.
PE_OUT = "C:\\Users\\LICHNT~1.OFF\\AppData\\Local\\Temp\\claude\\D--Project-Email-Send\\d0824b0a-6cac-412d-8946-ef7c47e9c425\\scratchpad\\petexp\\out\\"
PE_TOKEN = PE_OUT .. "trieuhoi_lenhbai.lua"
PE_LIB = PE_OUT .. "petexp_lib.lua"
PE_LIVE = strfind(SIM_ARG or "", "live", 1, 1)
if PE_LIVE then
	PE_TOKEN = "E:\\VL\\Phong than\\PT\\PhongThanRuntime-Staging\\Server\\script\\phongthan\\item\\trieuhoi_lenhbai.lua"
	PE_LIB = "E:\\VL\\Phong than\\PT\\PhongThanRuntime-Staging\\Server\\script\\phongthan\\lib\\petexp_lib.lua"
end
function PE_STUBS()
	Include = function(p) if p == "\\script\\phongthan\\lib\\petexp_lib.lua" then dofile(PE_LIB) end end
	GetNpcLife = function(i) return 5000 end
	SetNpcLife = function(i, v, f) end
	SetNpcSkill = function(i, s, l, p) return 1 end
	PetGetType = function() return 0 end
end
SIM_ARG0 = SIM_ARG
if strfind(SIM_ARG or "", "emu", 1, 1) then SIM_ARG = "emu" else SIM_ARG = "" end
readfrom("sim_petmorph.lua")
SRC = read("*a")
readfrom()
local sfx = ""
if PE_LIVE then sfx = "_live" end
SRC = gsub(SRC, 'writeto%("out_petmorph_emu%.txt"%)', 'writeto("out_petmorph_pe_emu' .. sfx .. '.txt")')
SRC = gsub(SRC, 'writeto%("out_petmorph%.txt"%)', 'writeto("out_petmorph_pe' .. sfx .. '.txt")')
SRC = gsub(SRC, 'dofile%("[^"]*petmorph\\\\trieuhoi_lenhbai%.lua"%)', 'PE_STUBS() dofile(PE_TOKEN) write("petexp lib loaded: " .. tostring(PTPE_Level ~= nil) .. "\\n")')
SRC = gsub(SRC, 'LASTN == 17, "main menu 17 options %(limit 20%), got "', 'LASTN == 7, "main menu 7 rows (coordinator token menu), got "')
dostring(SRC)
