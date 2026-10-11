-- petexp 2026-10-03: run sim_petskill.lua unchanged against the NEW trieuhoi_lenhbai.lua + petexp_lib.lua
-- -> out_petskill_pe.txt (no ERR lines expected; menus differ from out_petskill.txt by the 7-row token menu).
PE_OUT = "C:\\Users\\LICHNT~1.OFF\\AppData\\Local\\Temp\\claude\\D--Project-Email-Send\\d0824b0a-6cac-412d-8946-ef7c47e9c425\\scratchpad\\petexp\\out\\"
PE_TOKEN = PE_OUT .. "trieuhoi_lenhbai.lua"
PE_LIB = PE_OUT .. "petexp_lib.lua"
if strfind(SIM_ARG or "", "live", 1, 1) then
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
readfrom("sim_petskill.lua")
SRC = read("*a")
readfrom()
SRC = gsub(SRC, 'writeto%("out_petskill%.txt"%)', 'writeto("out_petskill_pe.txt")')
SRC = gsub(SRC, 'dofile%("[^"]*petskill\\\\trieuhoi_lenhbai%.lua"%)', 'PE_STUBS() dofile(PE_TOKEN) write("petexp lib loaded: " .. tostring(PTPE_Level ~= nil) .. "\\n")')
dostring(SRC)
