# Phong Than 2026-10-01: "Lenh Bai Trieu Hoi" (magicscript 61003) for Di Nhan.
# VNG keeps the summon skills 450-461 in \settings\summonskill.txt (id, name, summonnpcid, cost...),
# which this engine never loads, so the summons are made in Lua: AddTotemNpc (owner + AiMode 11 =
# combat pet AI: follows, fights the owner's target, removed by the engine when the owner dies or
# changes map), SetNpcOwner(.., 0) copies the owner's combat stats, SetNpcCurCamp = owner's camp.
import os, sys, unicodedata
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low

def tcvn(s):
    o = bytearray()
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128: o.append(ord(ch))
        elif ch in low: o.append(low[ch])
        elif ch.lower() in low: o.append(low[ch.lower()])
        else: raise ValueError(ch)
    return bytes(o)

def L(s):
    return '"' + "".join("\\%d" % c if (c < 32 or c > 126 or c in (34, 92)) else chr(c) for c in tcvn(s)) + '"'

# summonskill.txt: id, name, summonnpcid ; learn level from skillbook.txt (459-461: no VNG book)
SUMMONS = [
    (450, "Lực Sĩ tế", 359, 5), (451, "Trường Cung tế", 360, 15), (452, "Thiên Vũ tế", 361, 25),
    (453, "Liên Nỗ tế", 362, 35), (454, "Hỏa Lôi tế", 403, 45), (455, "Toái Cốt tế", 404, 55),
    (456, "Lưu Tinh tế", 405, 65), (457, "Truy Hồn tế", 406, 75), (458, "Phong Quyển Tàn Vân", 407, 85),
    (459, "Cuồng Đào tế", 1345, 95), (460, "Ngự Sậu Bạo Phong", 1346, 105), (461, "Huyền Ảnh Tán Hoa", 2032, 120),
]

# 2026-10-03 (petmorph): VNG summon-beast appearances ("Trieu Hoi Thu ... Bien Than", magicscript 6/1/1982-1987,
# \script\item\summonbeastmorph_*.lua -> SetSummonBeastMorph + task 254). Npcs.txt templates 2651-2656.
MORPHS = [
    (2651, "Thỏ Vàng"), (2652, "Câu Trần Vàng"), (2653, "Chúc Thần Vàng"),
    (2654, "Tất Phương"), (2655, "Hạn Bạt"), (2656, "Hóa Xà"),
]

# 2026-10-03 (petexp): skill of each summon template (settings\phongthan\Npcs.txt Skill1..4, all four slots
# the same, Level1..4 = 1). skills.txt MaxLevel 10; the level script is physicsenhance_p = 20 + 5 * level.
# 359 Luc Si te uses 63 (plain npc attack, MaxLevel 0): no skill level for it.
PET_SKILL = {359: 0, 360: 141, 361: 139, 362: 132, 403: 142, 404: 143, 405: 144, 406: 140, 407: 145,
             1345: 388, 1346: 297, 2032: 1996}

rows = "\n".join('\t{%d, %d, %d, %s},' % (sid, tpl, lv, L(name)) for (sid, name, tpl, lv) in SUMMONS)
mrows = "\n".join('\t{%d, %s},' % (tpl, L(name)) for (tpl, name) in MORPHS)
wrappers = "\n".join("function PTTH_S%d() PTTH_Summon(%d) end" % (i + 1, i + 1) for i in range(len(SUMMONS)))
lwrappers = "\n".join("function PTTH_L%d() PTTH_LearnOne(%d) end" % (i + 1, i + 1) for i in range(len(SUMMONS)))
mwrappers = "\n".join("function PTTH_M%d() PTTH_SetMorph(%d) end" % (i, i) for i in range(len(MORPHS) + 1))

src = """-- Phong Than "Lenh Bai Trieu Hoi" (magicscript 61003, 2026-10-01): Di Nhan summons (VNG
-- \\settings\\summonskill.txt 450-461, not loaded by this engine). Permanent, never consumed.
--  * AddTotemNpc(tpl, level, SubWorld, mpsX, mpsY): owner = player, AiMode 11 (pet AI: follows,
--    attacks the owner's target; KNpcAI::ProcessAIType11 removes it when the owner dies/changes map)
--  * SetNpcOwner(npc, name, 0) copies the owner's damage/defence/speed/life max (0 = keep pet AI)
--  * task 1941 = pet npc index, 1942 = its template (checked before DelNpc so a reused slot is safe)
--  * 2026-10-02: menu row "Hoc ky nang trieu hoi" teaches the summon skills 450-461 (AddMagic lv 1)
--  * 2026-10-03: menu row "Doi hinh dang de tu" = VNG summon-beast appearance (task 254 = template
--    2651-2656, 0 = default). Token pet: re-summoned, then NpcPolyMorph(npc, tpl) before the first
--    sync, so clients load the new look at once; stats/skills stay from the summon template.
--    Skill pet (450-461): KSkill::Cast applies task 254 on every cast; SetSummonBeastMorph = live pet.
--  * 2026-10-03 (petexp): the pet has its own level/exp (\\script\\phongthan\\lib\\petexp_lib.lua, task
--    2505/2506, fed by npc_quests\\normal.lua). Summon level = pet level; PTPE_Apply adds life and skill level.
-- No top-level dofile: loose scripts are registered with cwd = their own folder. Include takes the logical
-- path (KPakFile, PAK-first), independent of cwd; protected so a missing lib never breaks the token.
function PTTH_PEErr(m) end
if Include then call(Include, { "\\\\script\\\\phongthan\\\\lib\\\\petexp_lib.lua" }, "x", PTTH_PEErr) end
PTTH_PROF = 2
PTTH_LIST = {
%(rows)s
}
PTTH_MORPH = {
%(mrows)s
}

function PTTH_IsMorph(t)
	if t ~= nil and t >= 2651 and t <= 2656 then return 1 end
	return nil
end

function PTTH_Owned()
	local idx = GetTask(1941)
	if idx == nil or idx <= 0 then return 0 end
	local st = GetNpcSettingIdx(idx)
	if st ~= GetTask(1942) and PTTH_IsMorph(st) == nil then return 0 end
	if GetNpcOwner(idx) ~= GetName() then return 0 end
	return idx
end

function PTTH_Find(tpl)
	local i = 1
	while PTTH_LIST[i] do
		if PTTH_LIST[i][2] == tpl then return i end
		i = i + 1
	end
	return 0
end

function PTTH_Dismiss()
	local idx = PTTH_Owned()
	if idx > 0 then DelNpc(idx) end
	SetTask(1941, 0)
	SetTask(1942, 0)
	return idx
end

function main(nItemIdx)
	if GetProfession() ~= PTTH_PROF then
		Say(%(m_prof)s, 1, %(m_close)s)
		return 0
	end
	-- coordinator 2026-10-03: the client dialog shows only the first rows, so the 12 summons moved to
	-- two sub-pages and the main menu keeps the functions (morph / learn were cut off before).
	local opts = {}
	local n = 0
	n = n + 1 opts[n] = %(o_page1)s
	n = n + 1 opts[n] = %(o_page2)s
	n = n + 1 opts[n] = %(o_learn)s
	n = n + 1 opts[n] = %(o_morph)s
	n = n + 1 opts[n] = %(o_recall)s
	n = n + 1 opts[n] = %(o_dismiss)s
	n = n + 1 opts[n] = %(m_close)s
	-- petexp: pet level / exp in the dialog text (no extra menu row: the client shows only the first rows)
	local title = %(m_title)s
	if PTPE_Info then title = title .. " " .. PTPE_Info() end
	local t = { title, n }
	local k = 1
	while k <= n do t[k + 2] = opts[k] k = k + 1 end
	call(Say, t)
	return 0
end

function PTTH_Page(first, last)
	local lv = GetLevel()
	local opts = {}
	local n = 0
	local i = first
	while i <= last and PTTH_LIST[i] do
		local s = PTTH_LIST[i]
		n = n + 1
		if lv >= s[3] then
			opts[n] = s[4] .. "/PTTH_S" .. i
		else
			opts[n] = s[4] .. %(m_need)s .. s[3] .. ")/PTTH_S" .. i
		end
		i = i + 1
	end
	n = n + 1 opts[n] = %(o_back)s
	n = n + 1 opts[n] = %(m_close)s
	local t = { %(m_title)s, n }
	local k = 1
	while k <= n do t[k + 2] = opts[k] k = k + 1 end
	call(Say, t)
end

function PTTH_Page1() PTTH_Page(1, 6) end
function PTTH_Page2() PTTH_Page(7, 12) end

function PTTH_Summon(k)
	local s = PTTH_LIST[k]
	if s == nil or GetProfession() ~= PTTH_PROF then return end
	if GetLevel() < s[3] then
		Say(%(m_lv)s .. s[3], 1, %(m_close)s)
		return
	end
	PTTH_Dismiss()
	-- coordinator 2026-10-04: one pet at a time, the summon-skill pet (Npc.m_nPetIdx) goes too
	if DelPet then DelPet() end
	local pn = GetPlayerNpcIdx()
	local w, x, y = GetNpcPos(pn)
	-- petexp: the pet's own level (task 2505) instead of the owner's; old behaviour if the lib is missing
	local plv = GetLevel()
	if PTPE_Level then plv = PTPE_Level() end
	local idx = AddTotemNpc(s[2], plv, SubWorld, x * 32 + 48, y * 32 + 48)
	if idx == nil or idx <= 0 then
		Say(%(m_fail)s, 1, %(m_close)s)
		return
	end
	SetNpcCurCamp(idx, GetCurCamp())
	SetNpcOwner(idx, GetName(), 0)
	SetTask(1941, idx)
	SetTask(1942, s[2])
	if PTPE_Apply then
		PTPE_Apply(idx, s[2], plv)
	else
		SetNpcName(idx, GetName())
	end
	local mt = GetTask(254)
	if PTTH_IsMorph(mt) and NpcPolyMorph then NpcPolyMorph(idx, mt) end
	if PTPE_Level then
		Msg2Player(%(m_ok)s .. s[4] .. %(m_oklv)s .. plv .. ")")
	else
		Msg2Player(%(m_ok)s .. s[4])
	end
end

function PTTH_Recall()
	local idx = PTTH_Owned()
	if idx <= 0 then
		Say(%(m_none)s, 1, %(m_close)s)
		return
	end
	local pn = GetPlayerNpcIdx()
	local w, x, y = GetNpcPos(pn)
	SetNpcPos(idx, x + 1, y + 1)
end

function PTTH_DismissMenu()
	if PTTH_Dismiss() > 0 then
		Msg2Player(%(m_gone)s)
	else
		Say(%(m_none)s, 1, %(m_close)s)
	end
end

function PTTH_No()
end

-- 2026-10-02 (petskill): teach the real summon skills 450-461 (skills.txt rows from ptfix plug-in
-- extra_petskill.py, SkillStyle 4 = native KSkill::Cast summon). Level 1, raised with skill points.
-- If the server still runs an older ptfix (no row), AddMagic fails: the empty slot is removed again.
function PTTH_Known(id)
	local l = HaveMagic(id)
	if l == nil or l <= 0 then return 0 end
	return l
end

function PTTH_Learn(k)
	local s = PTTH_LIST[k]
	if s == nil or GetProfession() ~= PTTH_PROF or GetLevel() < s[3] then return 0 end
	if PTTH_Known(s[1]) > 0 then return 0 end
	local r = AddMagic(s[1], 1)
	if r == nil or r <= 0 or PTTH_Known(s[1]) <= 0 then
		DelMagic(s[1])
		return -1
	end
	Msg2Player(%(m_learn_ok)s .. s[4])
	return 1
end

function PTTH_LearnMenu()
	if GetProfession() ~= PTTH_PROF then return end
	local lv = GetLevel()
	local t = { %(m_learn_title)s, 0 }
	local n = 0
	local i = 1
	while PTTH_LIST[i] do
		local s = PTTH_LIST[i]
		if lv >= s[3] and PTTH_Known(s[1]) == 0 then
			n = n + 1
			t[n + 2] = s[4] .. "/PTTH_L" .. i
		end
		i = i + 1
	end
	if n == 0 then
		Say(%(m_learn_none)s, 1, %(m_close)s)
		return
	end
	if n > 1 then n = n + 1 t[n + 2] = %(o_learn_all)s end
	n = n + 1 t[n + 2] = %(m_close)s
	t[2] = n
	call(Say, t)
end

function PTTH_LearnOne(k)
	local r = PTTH_Learn(k)
	if r > 0 then
		Say(%(m_learn_ok)s .. PTTH_LIST[k][4] .. %(m_learn_hint)s, 1, %(m_close)s)
	elseif r < 0 then
		Say(%(m_learn_fail)s, 1, %(m_close)s)
	end
end

function PTTH_LearnAll()
	local ok = 0
	local i = 1
	while PTTH_LIST[i] do
		local r = PTTH_Learn(i)
		if r < 0 then
			Say(%(m_learn_fail)s, 1, %(m_close)s)
			return
		end
		ok = ok + r
		i = i + 1
	end
	Say(%(m_learn_all)s .. ok .. %(m_learn_hint)s, 1, %(m_close)s)
end

-- 2026-10-03 (petmorph): VNG summon-beast appearance. task 254 = 2651..2656 (VNG items 6/1/1982-1987
-- store the same value), 0 = default look. Free here; only the look changes, never stats or skills.
function PTTH_MorphName(t)
	local i = 1
	while PTTH_MORPH[i] do
		if PTTH_MORPH[i][1] == t then return PTTH_MORPH[i][2] end
		i = i + 1
	end
	return %(m_default_name)s
end

function PTTH_MorphMenu()
	if GetProfession() ~= PTTH_PROF then return end
	local cur = GetTask(254)
	if PTTH_IsMorph(cur) == nil then cur = 0 end
	local t = { %(m_morph_title)s .. PTTH_MorphName(cur) .. ".", 0 }
	local n = 0
	local i = 1
	while PTTH_MORPH[i] do
		local e = PTTH_MORPH[i]
		n = n + 1
		if e[1] == cur then
			t[n + 2] = e[2] .. %(m_using)s .. "/PTTH_M" .. i
		else
			t[n + 2] = e[2] .. "/PTTH_M" .. i
		end
		i = i + 1
	end
	n = n + 1
	if cur == 0 then
		t[n + 2] = %(m_default_name)s .. %(m_using)s .. "/PTTH_M0"
	else
		t[n + 2] = %(o_default)s
	end
	n = n + 1 t[n + 2] = %(m_close)s
	t[2] = n
	call(Say, t)
end

function PTTH_SetMorph(m)
	if GetProfession() ~= PTTH_PROF then return end
	local tpl = 0
	if m > 0 then
		local e = PTTH_MORPH[m]
		if e == nil then return end
		tpl = e[1]
	end
	SetTask(254, tpl)
	local msg = %(m_morph_ok)s .. PTTH_MorphName(tpl) .. "."
	-- token pet: a NEW npc gets the look before its first sync (an in-place change is not redrawn
	-- by clients that already see the npc); stats and skills come from the summon template again
	local idx = PTTH_Owned()
	if idx > 0 then
		local k = PTTH_Find(GetTask(1942))
		if k > 0 and GetLevel() >= PTTH_LIST[k][3] then
			PTTH_Summon(k)
			if PTTH_Owned() > 0 then msg = msg .. %(m_morph_token)s end
		end
	end
	-- skill pet: KSkill::Cast reapplies task 254 on the next cast; also update the live one (server side)
	if tpl > 0 and SetSummonBeastMorph then SetSummonBeastMorph(tpl) end
	msg = msg .. %(m_morph_skill)s
	Say(msg, 1, %(m_close)s)
end

%(wrappers)s
%(lwrappers)s
%(mwrappers)s
""" % {"rows": rows, "wrappers": wrappers, "lwrappers": lwrappers, "mrows": mrows, "mwrappers": mwrappers,
       "o_morph": L("Đổi hình dạng đệ tử/PTTH_MorphMenu"),
       "o_page1": L("Gọi đệ tử (cấp 5-55)/PTTH_Page1"),
       "o_page2": L("Gọi đệ tử (cấp 65-120)/PTTH_Page2"),
       "o_back": L("Quay lại/main"),
       "m_morph_title": L("<color=yellow>Đổi hình dạng đệ tử<color>: chọn hình tượng Triệu Hồi Thú như VNG. Chỉ đổi ngoại hình, sức mạnh và kỹ năng của đệ tử giữ nguyên. Hình hiện tại: "),
       "m_using": L(" (đang dùng)"),
       "m_default_name": L("Hình dạng mặc định"),
       "o_default": L("Trở về hình dạng mặc định/PTTH_M0"),
       "m_morph_ok": L("Đã chọn hình dạng đệ tử: "),
       "m_morph_token": L(" Đệ tử lệnh bài đã được gọi lại với hình mới."),
       "m_morph_skill": L(" Đệ tử gọi bằng kỹ năng sẽ mang hình này từ lần dùng kỹ năng triệu hồi tiếp theo."),
       "o_learn": L("Học kỹ năng triệu hồi/PTTH_LearnMenu"),
       "o_learn_all": L("Học tất cả/PTTH_LearnAll"),
       "m_learn_title": L("<color=yellow>Học kỹ năng triệu hồi<color>: kỹ năng đệ tử thật của Dị Nhân, gán vào phím chuột để gọi đệ tử mà không cần lệnh bài. Chỉ hiện các kỹ năng đã đủ cấp và chưa học."),
       "m_learn_none": L("Không còn kỹ năng triệu hồi nào để học (chưa đủ cấp hoặc đã học hết)."),
       "m_learn_ok": L("Đã học kỹ năng triệu hồi: "),
       "m_learn_all": L("Số kỹ năng triệu hồi vừa học: "),
       "m_learn_hint": L(". Chọn kỹ năng ở ô kỹ năng chuột (hoặc bảng kỹ năng) để dùng; nâng cấp bằng điểm kỹ năng."),
       "m_learn_fail": L("Máy chủ chưa có dữ liệu kỹ năng triệu hồi (cần cài bản ptfix mới rồi khởi động lại máy chủ)."),
       "m_prof": L("Lệnh bài triệu hồi chỉ dành cho phái Dị Nhân."),
       "m_close": L("Đóng/PTTH_No"),
       "m_need": L(" (cần cấp "),
       "o_recall": L("Gọi đệ tử về bên cạnh/PTTH_Recall"),
       "o_dismiss": L("Thu hồi đệ tử/PTTH_DismissMenu"),
       "m_title": L("<color=yellow>Lệnh Bài Triệu Hồi<color>: chọn đệ tử để gọi ra trợ chiến. Gọi con mới thì con cũ biến mất; đổi bản đồ hoặc tử vong thì đệ tử tự rời đi, dùng lệnh bài gọi lại."),
       "m_lv": L("Chưa đủ cấp để gọi đệ tử này. Cần cấp "),
       "m_fail": L("Không gọi được đệ tử ở đây."),
       "m_ok": L("Đã gọi đệ tử: "),
       "m_oklv": L(" (cấp "),
       "m_none": L("Bạn chưa gọi đệ tử nào."),
       "m_gone": L("Đã thu hồi đệ tử.")}
# ---------------------------------------------------------------- 2026-10-03 petexp: pet level / exp library
data_rows = []
for (sid, name, tpl, lv) in SUMMONS:
    data_rows.append("\tif tpl == %d then return %d, %s end" % (tpl, PET_SKILL[tpl], L(name)))
lib = r"""-- Phong Than 2026-10-03 (petexp): Di Nhan pet ("de tu") level and exp. Generated by mktrieuhoi.py, do not
-- edit by hand. Included (protected) by \script\phongthan\item\trieuhoi_lenhbai.lua (summon, menu text) and
-- \script\phongthan\npc_quests\normal.lua (OnDeath: PlayerIndex = the player KNpcDeathCalcExp credited, i.e.
-- the owner when the owner or the pet kills; the pet's damage is booked on the owner).
--  * task 2505 = pet level (0 = never used, read as 1), task 2506 = exp inside the current level. One pair
--    for all 12 token pets and the skill pets 450-461: the player raises one pet, the token picks its form.
--  * gain per kill (pet alive: token pet on the same map within PTPE_RANGE cells of the owner, or a living
--    skill pet) = monster level, x4 while the pet is 10+ levels below its cap (catch-up), 1/4 (min 1) when
--    the monster is more than 10 levels below the pet. The owner's own exp is never touched.
--  * need(lv) = 2 * lv * (lv + 10); cap = min(owner level, 150): like VNG pets, never above the owner.
--  * strength (token pet; Lua has no handle on the skill pet m_nPetIdx): summon level = pet level, life max =
--    owner life max * (100 + lv) / 100, npc skill level = 1 + lv / 15 (max 10 = skills.txt MaxLevel; the pet
--    arrows scale physicsenhance_p 20 + 5 * level). SetNpcOwner(.., 0) still copies the owner's damage.
-- Functions and constants only (this file is also registered on its own at server start).
PTPE_T_LV = 2505
PTPE_T_EXP = 2506
PTPE_MAXLV = 150
PTPE_RANGE = 60
PTPE_PROF = 2

function PTPE_Level()
	local lv = GetTask(PTPE_T_LV)
	if lv == nil or lv < 1 then lv = 1 end
	if lv > PTPE_MAXLV then lv = PTPE_MAXLV end
	return lv
end

function PTPE_Cap()
	local c = GetLevel()
	if c == nil or c < 1 then c = 1 end
	if c > PTPE_MAXLV then c = PTPE_MAXLV end
	return c
end

function PTPE_Need(lv)
	return 2 * lv * (lv + 10)
end

function PTPE_SkillLv(lv)
	local s = 1 + floor(lv / 15)
	if s > 10 then s = 10 end
	return s
end

function PTPE_LifePct(lv)
	return 100 + lv
end

-- summon template -> npc skill id (0 = none), display name (nil = not a Di Nhan summon)
function PTPE_Data(tpl)
@DATA@
	return 0, nil
end

function PTPE_IsMorph(t)
	if t ~= nil and t >= 2651 and t <= 2656 then return 1 end
	return nil
end

-- owned token pet (task 1941/1942, same checks as PTTH_Owned); near = 1: alive on the owner's map, close by
function PTPE_TokenIdx(near)
	local idx = GetTask(1941)
	if idx == nil or idx <= 0 then return 0 end
	local st = GetNpcSettingIdx(idx)
	if st ~= GetTask(1942) and PTPE_IsMorph(st) == nil then return 0 end
	if GetNpcOwner(idx) ~= GetName() then return 0 end
	local pw, px, py = GetNpcPos(idx)
	if pw == nil or pw <= 0 then return 0 end
	if near then
		local w, x, y = GetNpcPos(GetPlayerNpcIdx())
		if pw ~= w then return 0 end
		if abs(px - x) > PTPE_RANGE or abs(py - y) > PTPE_RANGE then return 0 end
	end
	return idx
end

-- living skill pet (450-461): PetGetType() = template of Npc[player].m_nPetIdx while it is alive
function PTPE_SkillPet()
	if PetGetType == nil then return 0 end
	local t = PetGetType()
	if t == nil or t <= 0 then return 0 end
	if PTPE_IsMorph(t) then return 1 end
	local sk, nm = PTPE_Data(t)
	if nm then return 1 end
	return 0
end

-- give a token pet the strength of level lv (called after SetNpcOwner, and on level up)
function PTPE_Apply(idx, tpl, lv)
	if idx == nil or idx <= 0 then return 0 end
	local sk, nm = PTPE_Data(tpl)
	-- coordinator 2026-10-04: the pet carries its owner's name (user request), "[level]Owner"
	if nm and SetNpcName then SetNpcName(idx, "[" .. lv .. "]" .. GetName()) end
	local ol = 0
	if GetNpcLife then ol = GetNpcLife(GetPlayerNpcIdx()) end
	if ol ~= nil and ol > 0 and SetNpcLife then SetNpcLife(idx, floor(ol * PTPE_LifePct(lv) / 100), 1) end
	if sk ~= nil and sk > 0 and SetNpcSkill then
		local s = PTPE_SkillLv(lv)
		local i = 1
		while i <= 4 do
			SetNpcSkill(idx, sk, s, i)
			i = i + 1
		end
	end
	return 1
end

function PTPE_Gain(mlv)
	if mlv == nil or mlv < 1 then mlv = 1 end
	local lv = PTPE_Level()
	local g = mlv
	if lv + 10 <= PTPE_Cap() then g = g * 4 end
	if mlv + 10 < lv then
		g = floor(g / 4)
		if g < 1 then g = 1 end
	end
	return g
end

function PTPE_LevelUp(lv, cap)
	local msg = @M_UP1@ .. lv .. @M_UP2@ .. PTPE_LifePct(lv) .. @M_UP3@ .. PTPE_SkillLv(lv) .. "."
	if lv >= PTPE_MAXLV then
		msg = msg .. @M_MAX@
	elseif lv >= cap then
		msg = msg .. @M_CAP@
	end
	Msg2Player(msg)
	local idx = PTPE_TokenIdx(nil)
	if idx > 0 then PTPE_Apply(idx, GetTask(1942), lv) end
end

-- add n exp; returns the number of levels gained
function PTPE_AddExp(n)
	local lv = PTPE_Level()
	local cap = PTPE_Cap()
	local e = GetTask(PTPE_T_EXP)
	if e == nil or e < 0 then e = 0 end
	e = e + n
	local up = 0
	while lv < cap and e >= PTPE_Need(lv) do
		e = e - PTPE_Need(lv)
		lv = lv + 1
		up = up + 1
	end
	if lv >= cap and e > PTPE_Need(lv) then e = PTPE_Need(lv) end
	SetTask(PTPE_T_LV, lv)
	SetTask(PTPE_T_EXP, e)
	if up > 0 then PTPE_LevelUp(lv, cap) end
	return up
end

-- death-script hook (npc_quests\normal.lua OnDeath)
function PTPE_OnKill(npcindex)
	if PlayerIndex == nil or PlayerIndex <= 0 then return 0 end
	if GetProfession() ~= PTPE_PROF then return 0 end
	if PTPE_TokenIdx(1) <= 0 and PTPE_SkillPet() <= 0 then return 0 end
	return PTPE_AddExp(PTPE_Gain(GetNpcLevel(npcindex)))
end

-- one line for the Lenh Bai Trieu Hoi dialog text
function PTPE_Info()
	local lv = PTPE_Level()
	local s = @I1@ .. lv
	if lv >= PTPE_MAXLV then return s .. @I_MAX@ end
	s = s .. @I2@ .. GetTask(PTPE_T_EXP) .. "/" .. PTPE_Need(lv)
	if lv >= PTPE_Cap() then s = s .. @I_CAP@ end
	return s .. "<color>"
end
"""
for k, v in {"@DATA@": "\n".join(data_rows),
             "@M_UP1@": L("Đệ tử lên cấp "),
             "@M_UP2@": L("! Sinh lực đệ tử bằng "),
             "@M_UP3@": L("% sinh lực của chủ, kỹ năng đệ tử cấp "),
             "@M_CAP@": L(" Đệ tử đã bằng cấp của chủ: chủ lên cấp thì đệ tử mới lên tiếp."),
             "@M_MAX@": L(" Đệ tử đã đạt cấp tối đa."),
             "@I1@": L("<color=green>Đệ tử cấp "),
             "@I2@": L(", kinh nghiệm "),
             "@I_CAP@": L(" (đã bằng cấp chủ)"),
             "@I_MAX@": L(" (cấp tối đa)<color>")}.items():
    assert k in lib, k
    lib = lib.replace(k, v)
assert "@" not in lib.replace("@DATA", "")

base = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan"
p = base + r"\item\trieuhoi_lenhbai.lua"
pl = base + r"\lib\petexp_lib.lua"
if len(sys.argv) > 1:                    # test output
    p = sys.argv[1]
    pl = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(os.path.abspath(p)), "petexp_lib.lua")
open(pl, "wb").write(lib.replace("\n", "\r\n").encode("latin-1"))
open(p, "wb").write(src.replace("\n", "\r\n").encode("latin-1"))
print("ok", len(src), len(lib), p, pl)
