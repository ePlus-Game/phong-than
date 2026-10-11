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
-- No top-level dofile: loose scripts are registered with cwd = their own folder.
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
	local t = { %(m_title)s, n }
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
	local pn = GetPlayerNpcIdx()
	local w, x, y = GetNpcPos(pn)
	local idx = AddTotemNpc(s[2], GetLevel(), SubWorld, x * 32 + 48, y * 32 + 48)
	if idx == nil or idx <= 0 then
		Say(%(m_fail)s, 1, %(m_close)s)
		return
	end
	SetNpcCurCamp(idx, GetCurCamp())
	SetNpcOwner(idx, GetName(), 0)
	SetNpcName(idx, s[4])
	SetTask(1941, idx)
	SetTask(1942, s[2])
	local mt = GetTask(254)
	if PTTH_IsMorph(mt) and NpcPolyMorph then NpcPolyMorph(idx, mt) end
	Msg2Player(%(m_ok)s .. s[4])
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
       "m_none": L("Bạn chưa gọi đệ tử nào."),
       "m_gone": L("Đã thu hồi đệ tử.")}
p = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan\item\trieuhoi_lenhbai.lua"
if len(sys.argv) > 1: p = sys.argv[1]    # test output
open(p, "wb").write(src.replace("\n", "\r\n").encode("latin-1"))
print("ok", len(src))
