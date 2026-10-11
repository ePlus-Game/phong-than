-- Phong Than 2026-10-02: starter gear for new characters (see mknewbie.py).
--  weapon: meleeweapon particular 900/901/902 (ptfix v13 rows, level 1, every attribute at max)
--  horse : Trac Ma / Trac Tuoc / Trac Diep (horse particular 24/25/26, level 1, 4 fixed attributes)
-- Task 1950 is set only after the weapon really exists, so the gift waits for ptfix v13.
PTNB_TASK = 1950
PTNB_MAXLV = 10

function PTNB_GivePlayer(nm)
	local prof = GetProfession()
	if prof == nil or prof < 0 or prof > 2 then return end
	local w = AddItem(0, 0, 900 + prof, 1, 1000, 0)
	if w == nil or w <= 0 then return end
	AddItemID(w, 0)
	local hs = AddItem(0, 10, 24 + prof, 1, 1000, 0)
	if hs and hs > 0 then AddItemID(hs, 0) end
	SetTask(PTNB_TASK, 1)
	Msg2Player("Qu\181 t\169n th\241: v\242 kh\221 c\202p 1 thu\233c t\221nh t\232i \174a v\181 th\243 c\173\236i \174\183 \174\173\238c \174\173a v\181o h\181nh trang.")
	if PTAdm_Log then PTAdm_Log("newbie", "OK", nm .. " prof=" .. prof .. " weapon=" .. w .. " horse=" .. tostring(hs)) end
end

function PTNB_Tick()
	local i = 1
	while i <= PTADM_MAX_PLAYER do
		PlayerIndex = i
		local nm = GetName()
		if nm and nm ~= "" and GetTask(PTNB_TASK) == 0 then
			if GetLevel() <= PTNB_MAXLV then
				PTNB_GivePlayer(nm)
			else
				SetTask(PTNB_TASK, 2)
			end
		end
		i = i + 1
	end
	PlayerIndex = nil
end
