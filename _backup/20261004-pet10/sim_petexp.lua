-- petexp 2026-10-03: Di Nhan pet level / exp (petexp_lib.lua + trieuhoi_lenhbai.lua + npc_quests\normal.lua).
-- Run: run.ps1 -Main sim_petexp.lua -Stack 100                (plain engine stack, out_petexp.txt)
--      run.ps1 -Main sim_petexp.lua -Stack 0 -Args1 emu       (every entry padded to the engine headroom of an
--                                                              NPC/item entry = 47 frames, out_petexp_emu.txt)
--      -Args1 "live" / "emu,live": test the deployed runtime files instead of scratchpad\petexp\out
EMU = strfind(SIM_ARG or "", "emu", 1, 1)
LIVE = strfind(SIM_ARG or "", "live", 1, 1)
dofile("sim.lua")       -- SRV, Include, death-script natives (GetByte...), registered-API default stubs
OUTF = "out_petexp.txt"
if EMU then OUTF = "out_petexp_emu.txt" end
if LIVE then OUTF = gsub(OUTF, "%.txt", "_live.txt") end
writeto(OUTF)
FAILS = 0
_ERRORMESSAGE = function(m) FAILS = FAILS + 1 write("ERR " .. m .. "\n") end
function CHECK(c, what) if c then write("  ok   " .. what .. "\n") else FAILS = FAILS + 1 write("  FAIL " .. what .. "\n") end end

PE_DIR = "C:\\Users\\LICHNT~1.OFF\\AppData\\Local\\Temp\\claude\\D--Project-Email-Send\\d0824b0a-6cac-412d-8946-ef7c47e9c425\\scratchpad\\petexp\\out\\"
LIB = PE_DIR .. "petexp_lib.lua"
TOKEN = PE_DIR .. "trieuhoi_lenhbai.lua"
NORMAL = PE_DIR .. "normal.lua"
if LIVE then
	LIB = SRV .. "\\script\\phongthan\\lib\\petexp_lib.lua"
	TOKEN = SRV .. "\\script\\phongthan\\item\\trieuhoi_lenhbai.lua"
	NORMAL = SRV .. "\\script\\phongthan\\npc_quests\\normal.lua"
end
write("lib=" .. LIB .. "\n")

-- ---------------------------------------------------------------- engine stubs (override sim.lua)
SIM_INCLUDE = Include
LIBMISSING = nil
function Include(p)
	if p == "\\script\\phongthan\\lib\\petexp_lib.lua" then
		if LIBMISSING then error("Include: cannot open " .. p) end
		dofile(LIB)
		return
	end
	SIM_INCLUDE(p)
end
PROF = 2 LV = 60 TASKS = {} NPCS = {} SubWorld = 3 MAGIC = {} LASTSAY = "" LASTN = 0 MSGS = {}
OW, OX, OY = 1002, 1500, 3000 OWNLIFE = 5000 SKILLPET = 0 MOBLV = 50 HARD = 0 PLAYERNPC = 10
function GetProfession() return PROF end
function GetLevel() return LV end
function GetName() return "EmLaAi" end
function GetTask(i) return TASKS[i] or 0 end
function SetTask(i, v) TASKS[i] = v end
function Say(t, n, ...) LASTSAY = t LASTN = n local s = "SAY(" .. n .. ") " .. t for i = 1, getn(arg) do s = s .. " | " .. arg[i] end write(s .. "\n") end
function Msg2Player(s) tinsert(MSGS, s) write("MSG " .. s .. "\n") end
function LASTMSG() return MSGS[getn(MSGS)] or "" end
function HaveMagic(id) if MAGIC[id] then return MAGIC[id] end return -1 end
function AddMagic(id, lv) MAGIC[id] = lv return 3 end
function DelMagic(id) MAGIC[id] = nil end
function GetPlayerNpcIdx() return PLAYERNPC end
NEXT = 500
function AddTotemNpc(t, l, w, x, y)
	NEXT = NEXT + 1
	NPCS[NEXT] = { tpl = t, owner = "EmLaAi", w = OW, x = floor(x / 32), y = floor(y / 32), lv = l, life = 300, name = "?", sk = {} }
	write("AddTotemNpc " .. t .. " lv" .. l .. " -> " .. NEXT .. "\n")
	return NEXT
end
function GetNpcSettingIdx(i) if NPCS[i] then return NPCS[i].tpl end return 0 end
function GetNpcOwner(i) if NPCS[i] then return NPCS[i].owner end return "" end
function GetNpcPos(i)
	if i == PLAYERNPC then return OW, OX, OY end
	if NPCS[i] then return NPCS[i].w, NPCS[i].x, NPCS[i].y end
	return 0, 0, 0
end
function DelNpc(i) write("DelNpc " .. i .. "\n") NPCS[i] = nil end
function SetNpcCurCamp(i, c) end
function GetCurCamp() return 1 end
-- ScriptFuns.cpp LuaSetNpcOwner: copies the owner's damage/AR/defence/speed and m_CurrentLifeMax
function SetNpcOwner(i, n, f) if NPCS[i] then NPCS[i].life = OWNLIFE end end
function SetNpcName(i, n) if NPCS[i] then NPCS[i].name = n end write("SetNpcName " .. i .. " " .. n .. "\n") end
function SetNpcPos(i, x, y) end
function GetNpcLife(i) if i == PLAYERNPC then return OWNLIFE end if NPCS[i] then return NPCS[i].life end return 0 end
function SetNpcLife(i, v, f) if NPCS[i] then NPCS[i].life = v end write("SetNpcLife " .. i .. " " .. v .. "\n") end
function SetNpcSkill(i, sk, lv, pos) if NPCS[i] then NPCS[i].sk[pos] = sk .. ":" .. lv end return 1 end
function NpcPolyMorph(i, t) write("NpcPolyMorph " .. i .. " " .. t .. "\n") if NPCS[i] then NPCS[i].tpl = t return 1 end return 0 end
function SetSummonBeastMorph(t) return 0 end
function PetGetType() return SKILLPET end
function GetNpcLevel(i) return MOBLV end
-- death script (normal.lua) natives
HARDCALLS = 0
function GetHardNpcAttrib(n) HARDCALLS = HARDCALLS + 1 return -1 end
function GetNpcWorldPos(n) return OW, 1600, 3200 end
function GetWorldPos() return OW, 1600, 3200 end
function GetNpcTemplateID(n) return 100 end
function GetTeamSize() return 0 end

-- ---------------------------------------------------------------- engine stack emulation (sim_nb2emu.lua)
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
function RUN(name, f, a1)
	write("== " .. name .. "\n")
	if EMU then EMU_PAD(47, f, a1) else f(a1) end
end

-- ---------------------------------------------------------------- load the three files
dofile(TOKEN)           -- includes the lib (protected Include)
CHECK(PTPE_Level ~= nil and PTPE_OnKill ~= nil and PTTH_Summon ~= nil, "token loaded, lib included")
dofile(NORMAL)          -- original OnDeath + Tu Linh wrapper + vng_tasknote + petexp wrapper
CHECK(PTPE_QuestOnDeath ~= nil and PTTL_QuestOnDeath ~= nil, "normal.lua: petexp wrapper over the Tu Linh wrapper")
TLHITS = 0
PTTL_OnKill = function(n) TLHITS = TLHITS + 1 end
function TASKV(lv, e) TASKS[2505] = lv TASKS[2506] = e end
function KILL(name) local h = HARDCALLS local t = TLHITS RUN(name, OnDeath, 77) return HARDCALLS - h, TLHITS - t end

-- ---------------------------------------------------------------- token menu / summon
RUN("main lv60, new pet", main, 1)
CHECK(LASTN == 7, "main menu still 7 rows, got " .. LASTN)
CHECK(strfind(LASTSAY, "<color=green>", 1, 1) and strfind(LASTSAY, " 1, kinh nghi\214m 0/22<color>", 1, 1), "title shows pet level 1, exp 0/22")

RUN("summon Luc Si te (pet lv 1)", PTTH_S1)
CHECK(NPCS[501] and NPCS[501].lv == 1, "AddTotemNpc with pet level 1 (not owner 60)")
CHECK(NPCS[501].name == "[1]L\249c S\220 t\213", "name [1]Luc Si te")
CHECK(NPCS[501].life == floor(5000 * 101 / 100), "life = owner 5000 * 101% = " .. NPCS[501].life)
CHECK(NPCS[501].sk[1] == nil, "Luc Si te (skill 63, MaxLevel 0): no skill level change")
CHECK(strfind(LASTMSG(), "(c\202p 1)", 1, 1), "summon message shows level")

TASKV(30, 0)
RUN("summon Toai Cot te (pet lv 30)", PTTH_S6)
CHECK(NPCS[501] == nil and NPCS[502] and NPCS[502].lv == 30 and NPCS[502].tpl == 404, "old pet removed, 404 at lv 30")
CHECK(NPCS[502].sk[1] == "143:3" and NPCS[502].sk[4] == "143:3", "skill 143 level 3 in slots 1-4")
CHECK(NPCS[502].life == 6500, "life 130% = 6500")
CHECK(GetTask(1941) == 502 and GetTask(1942) == 404, "task 1941/1942")

-- ---------------------------------------------------------------- death hook
MOBLV = 50
local h, t = KILL("kill lv50, pet lv30 near (catch-up x4)")
CHECK(h == 1 and t == 1, "original OnDeath and Tu Linh hook still ran")
CHECK(GetTask(2505) == 30 and GetTask(2506) == 200, "exp +200 (50 x4), got " .. GetTask(2506))
CHECK(TASKS[1] == nil and LV == 60, "owner untouched")

NPCS[502].x = OX + 61
KILL("pet 61 cells away")
CHECK(GetTask(2506) == 200, "far pet: no exp")
NPCS[502].x = OX + 5 NPCS[502].w = 1003
KILL("pet on another map")
CHECK(GetTask(2506) == 200, "other map: no exp")
NPCS[502].w = OW
NPCS[502].owner = "Khac"
KILL("slot reused by someone else's npc")
CHECK(GetTask(2506) == 200, "foreign npc in task 1941: no exp")
NPCS[502].owner = "EmLaAi"

TASKS[1941] = 0 SKILLPET = 405
KILL("no token pet, skill pet (405) alive")
CHECK(GetTask(2506) == 400, "skill pet: exp +200")
SKILLPET = 2653
KILL("skill pet with VNG look 2653")
CHECK(GetTask(2506) == 600, "morphed skill pet: exp +200")
SKILLPET = 0
KILL("no pet at all")
CHECK(GetTask(2506) == 600, "no pet: no exp")
TASKS[1941] = 502

-- level up with the live pet
TASKV(30, PTPE_Need(30) - 10)
local life0 = NPCS[502].life
KILL("level up 30 -> 31")
CHECK(GetTask(2505) == 31 and GetTask(2506) == 190, "lv 31, carry 190, got " .. GetTask(2505) .. "/" .. GetTask(2506))
CHECK(strfind(LASTMSG(), "c\202p 31", 1, 1) and strfind(LASTMSG(), "131%", 1, 1), "level-up message lv 31 / 131%")
CHECK(NPCS[502].name == "[31]To\184i C\232t t\213" and NPCS[502].life == 6550 and NPCS[502].sk[2] == "143:3", "live pet: name [31], life 6550, skill 3")

-- several levels at once
TASKV(10, 0) MOBLV = 500
KILL("big monster, pet lv 10")
CHECK(GetTask(2505) == 14 and GetTask(2506) == 12, "2000 exp: lv 10 -> 14 (need 400+462+528+598), rest 12, got " .. GetTask(2505) .. "/" .. GetTask(2506))
MOBLV = 50

-- gray monster, no catch-up
LV = 45 TASKV(40, 0) MOBLV = 20
KILL("lv20 monster, pet lv 40, owner 45")
CHECK(GetTask(2506) == 5, "gray monster 20/4 = 5, got " .. GetTask(2506))
MOBLV = 50

-- cap = owner level
LV = 60 TASKV(59, PTPE_Need(59) - 1)
KILL("reach the owner's level")
CHECK(GetTask(2505) == 60 and strfind(LASTMSG(), "b\187ng c\202p c\241a ch\241", 1, 1), "lv 60 = owner, cap message")
TASKS[2506] = PTPE_Need(60) - 20
KILL("at cap") KILL("at cap")
CHECK(GetTask(2505) == 60 and GetTask(2506) == PTPE_Need(60), "at cap: level stays 60, exp held at need " .. PTPE_Need(60))
RUN("menu at cap", main, 1)
CHECK(strfind(LASTSAY, "\174\183 b\187ng c\202p ch\241", 1, 1), "title: (da bang cap chu)")
LV = 61
KILL("owner levels to 61")
CHECK(GetTask(2505) == 61, "pet follows to 61")

-- max level 150
LV = 160 TASKV(149, PTPE_Need(149) - 1)
KILL("reach 150")
CHECK(GetTask(2505) == 150 and strfind(LASTMSG(), "t\232i \174a", 1, 1), "lv 150 + max message")
RUN("menu at 150", main, 1)
CHECK(strfind(LASTSAY, " 150 (c\202p t\232i \174a)<color>", 1, 1), "title: 150 (cap toi da)")
CHECK(PTPE_SkillLv(150) == 10 and PTPE_SkillLv(14) == 1 and PTPE_SkillLv(15) == 2, "skill level 1 + lv/15, max 10")
LV = 60

-- guards
PROF = 1 TASKV(20, 0)
KILL("not Di Nhan")
CHECK(GetTask(2506) == 0, "other profession: no exp")
PROF = 2
local hh, tt = 0, 0
PlayerIndex = 0
hh, tt = KILL("PlayerIndex 0")
PlayerIndex = 1
CHECK(GetTask(2506) == 0 and tt == 1, "no killer: no exp, Tu Linh/original chain still called")
SAVE_ONKILL = PTPE_OnKill
PTPE_OnKill = function(n) local x = nil return x.y end
FAILS0 = FAILS
hh, tt = KILL("hook raises an error")
PTPE_OnKill = SAVE_ONKILL
CHECK(hh == 1 and tt == 1, "error in the pet hook: original OnDeath still ran")
FAILS = FAILS0      -- the ERR line above is the expected, caught error

-- old behaviour when the lib is missing
SAVE = { PTPE_Level, PTPE_Apply, PTPE_Info }
PTPE_Level = nil PTPE_Apply = nil PTPE_Info = nil
RUN("summon without lib", PTTH_S1)
CHECK(NPCS[NEXT].lv == 60 and NPCS[NEXT].name == "L\249c S\220 t\213", "no lib: owner level and plain name (old behaviour)")
PTPE_Level = SAVE[1] PTPE_Apply = SAVE[2] PTPE_Info = SAVE[3]
LIBMISSING = 1
FAILS0 = FAILS
dofile(TOKEN)
LIBMISSING = nil
CHECK(FAILS == FAILS0 and PTTH_Summon ~= nil, "token file loads although the lib cannot be included")

-- morph regression with levels (petmorph flows)
TASKV(45, 0) LV = 60
RUN("summon Hoa Loi te lv45 then choose Tho Vang", function() PTTH_S5() PTTH_M1() end)
local k = NEXT
CHECK(NPCS[k].lv == 45 and NPCS[k].tpl == 2651 and GetTask(1942) == 403 and NPCS[k].sk[1] == "142:4", "re-summoned with look 2651, lv 45, skill 142 lv 4")
RUN("recall", PTTH_Recall)
RUN("dismiss", PTTH_DismissMenu)
CHECK(NPCS[k] == nil and GetTask(1941) == 0, "dismissed")
RUN("learn menu still works", PTTH_LearnMenu)
CHECK(LASTN == 8, "learn menu 6 + all + close")
RUN("page 2", PTTH_Page2)
CHECK(LASTN == 8, "page 2: 6 pets + back + close")

if EMU then write("min headroom at entry = " .. EMU_MINH .. " frames\n") end
write("FAILS=" .. FAILS .. "\n")
writeto()
