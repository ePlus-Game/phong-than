-- Phong Than "Lenh Bai Trieu Hoi" (magicscript 61003, 2026-10-01): Di Nhan summons (VNG
-- \settings\summonskill.txt 450-461, not loaded by this engine). Permanent, never consumed.
--  * AddTotemNpc(tpl, level, SubWorld, mpsX, mpsY): owner = player, AiMode 11 (pet AI: follows,
--    attacks the owner's target; KNpcAI::ProcessAIType11 removes it when the owner dies/changes map)
--  * SetNpcOwner(npc, name, 0) copies the owner's damage/defence/speed/life max (0 = keep pet AI)
--  * task 1941 = pet npc index, 1942 = its template (checked before DelNpc so a reused slot is safe)
-- No top-level dofile: loose scripts are registered with cwd = their own folder.
PTTH_PROF = 2
PTTH_LIST = {
	{450, 359, 5, "L\249c S\220 t\213"},
	{451, 360, 15, "Tr\173\234ng Cung t\213"},
	{452, 361, 25, "Thi\170n V\242 t\213"},
	{453, 362, 35, "Li\170n N\231 t\213"},
	{454, 403, 45, "H\225a L\171i t\213"},
	{455, 404, 55, "To\184i C\232t t\213"},
	{456, 405, 65, "L\173u Tinh t\213"},
	{457, 406, 75, "Truy H\229n t\213"},
	{458, 407, 85, "Phong Quy\211n T\181n V\169n"},
	{459, 1345, 95, "Cu\229ng \167\181o t\213"},
	{460, 1346, 105, "Ng\249 S\203u B\185o Phong"},
	{461, 2032, 120, "Huy\210n \182nh T\184n Hoa"},
}

function PTTH_Owned()
	local idx = GetTask(1941)
	if idx == nil or idx <= 0 then return 0 end
	if GetNpcSettingIdx(idx) ~= GetTask(1942) then return 0 end
	if GetNpcOwner(idx) ~= GetName() then return 0 end
	return idx
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
		Say("L\214nh b\181i tri\214u h\229i ch\216 d\181nh cho ph\184i D\222 Nh\169n.", 1, "\167\227ng/PTTH_No")
		return 0
	end
	local lv = GetLevel()
	local opts = {}
	local n = 0
	local i = 1
	while PTTH_LIST[i] do
		local s = PTTH_LIST[i]
		n = n + 1
		if lv >= s[3] then
			opts[n] = s[4] .. "/PTTH_S" .. i
		else
			opts[n] = s[4] .. " (c\199n c\202p " .. s[3] .. ")/PTTH_S" .. i
		end
		i = i + 1
	end
	n = n + 1 opts[n] = "G\228i \174\214 t\246 v\210 b\170n c\185nh/PTTH_Recall"
	n = n + 1 opts[n] = "Thu h\229i \174\214 t\246/PTTH_DismissMenu"
	n = n + 1 opts[n] = "\167\227ng/PTTH_No"
	local t = { "<color=yellow>L\214nh B\181i Tri\214u H\229i<color>: ch\228n \174\214 t\246 \174\211 g\228i ra tr\238 chi\213n. G\228i con m\237i th\215 con c\242 bi\213n m\202t; \174\230i b\182n \174\229 ho\198c t\246 vong th\215 \174\214 t\246 t\249 r\234i \174i, d\239ng l\214nh b\181i g\228i l\185i.", n }
	local k = 1
	while k <= n do t[k + 2] = opts[k] k = k + 1 end
	call(Say, t)
	return 0
end

function PTTH_Summon(k)
	local s = PTTH_LIST[k]
	if s == nil or GetProfession() ~= PTTH_PROF then return end
	if GetLevel() < s[3] then
		Say("Ch\173a \174\241 c\202p \174\211 g\228i \174\214 t\246 n\181y. C\199n c\202p " .. s[3], 1, "\167\227ng/PTTH_No")
		return
	end
	PTTH_Dismiss()
	local pn = GetPlayerNpcIdx()
	local w, x, y = GetNpcPos(pn)
	local idx = AddTotemNpc(s[2], GetLevel(), SubWorld, x * 32 + 48, y * 32 + 48)
	if idx == nil or idx <= 0 then
		Say("Kh\171ng g\228i \174\173\238c \174\214 t\246 \235 \174\169y.", 1, "\167\227ng/PTTH_No")
		return
	end
	SetNpcCurCamp(idx, GetCurCamp())
	SetNpcOwner(idx, GetName(), 0)
	SetNpcName(idx, s[4])
	SetTask(1941, idx)
	SetTask(1942, s[2])
	Msg2Player("\167\183 g\228i \174\214 t\246: " .. s[4])
end

function PTTH_Recall()
	local idx = PTTH_Owned()
	if idx <= 0 then
		Say("B\185n ch\173a g\228i \174\214 t\246 n\181o.", 1, "\167\227ng/PTTH_No")
		return
	end
	local pn = GetPlayerNpcIdx()
	local w, x, y = GetNpcPos(pn)
	SetNpcPos(idx, x + 1, y + 1)
end

function PTTH_DismissMenu()
	if PTTH_Dismiss() > 0 then
		Msg2Player("\167\183 thu h\229i \174\214 t\246.")
	else
		Say("B\185n ch\173a g\228i \174\214 t\246 n\181o.", 1, "\167\227ng/PTTH_No")
	end
end

function PTTH_No()
end

function PTTH_S1() PTTH_Summon(1) end
function PTTH_S2() PTTH_Summon(2) end
function PTTH_S3() PTTH_Summon(3) end
function PTTH_S4() PTTH_Summon(4) end
function PTTH_S5() PTTH_Summon(5) end
function PTTH_S6() PTTH_Summon(6) end
function PTTH_S7() PTTH_Summon(7) end
function PTTH_S8() PTTH_Summon(8) end
function PTTH_S9() PTTH_Summon(9) end
function PTTH_S10() PTTH_Summon(10) end
function PTTH_S11() PTTH_Summon(11) end
function PTTH_S12() PTTH_Summon(12) end
