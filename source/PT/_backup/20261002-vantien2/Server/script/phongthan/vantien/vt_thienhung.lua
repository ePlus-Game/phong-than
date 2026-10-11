-- Phong Than 2026-10-02: Thien Hung (Tay Ky), entry NPC of Van Tien tran. Spawned by the minute tick
-- (vt_timer.lua, template 247 = the VNG Van Tien gate). Solo friendly: a closed tran is opened on demand.
Include("\\script\\phongthan\\vantien\\vt_lib.lua")

function main()
	local opts = {}
	local n = 1
	while n <= 4 do
		local lock = ""
		if not PTVT_Unlocked(n) then lock = ", kh\227a" end
		tinsert(opts, "V\185n Ti\170n tr\203n (" .. PTVT_NAME[n] .. ") c\202p " .. PTVT_MINLV[n] .. "+ [" .. PTVT_StateText(n) .. lock .. "]/th_enter" .. n)
		n = n + 1
	end
	tinsert(opts, "Gi\237i thi\214u V\185n Ti\170n tr\203n/th_info")
	tinsert(opts, "K\213t th\243c \174\232i tho\185i/no")
	local t = { "<color=green>Thi\170n H\239ng<color>: Th\171ng Thi\170n Gi\184o Ch\241 b\181y V\185n Ti\170n tr\203n, ma ch\243ng l\233ng h\181nh. Ta chi\170u m\233 d\242ng s\220 t\245 c\202p <color=yellow>30<color> v\181o ph\184 tr\203n. Ng\173\172i mu\232n v\181o tr\203n n\181o?", getn(opts) }
	local i = 1
	while opts[i] do
		t[i + 2] = opts[i]
		i = i + 1
	end
	call(Say, t)
end

function th_enter(n)
	CloseDialog()
	PTVT_EnterRequest(n)
end

function th_enter1() th_enter(1) end
function th_enter2() th_enter(2) end
function th_enter3() th_enter(3) end
function th_enter4() th_enter(4) end

function th_info()
	Say("V\185n Ti\170n tr\203n g\229m 4 tr\203n: <color=yellow>Th\230<color> (c\202p 30+), <color=yellow>Th\241y<color> (51+), <color=yellow>H\225a<color> (71+), <color=yellow>Phong<color> (91+). Ph\184 tr\203n tr\173\237c s\207 m\235 kh\227a tr\203n sau d\239 ch\173a \174\241 c\202p. Trong tr\203n: h\185 <color=green>\164 V\169n, C\199u Th\241, Linh Nha, Kim Quang Ti\170n<color> \174\211 l\202y 4 l\214nh, Th\171ng Thi\170n Gi\184o Ch\241 s\207 xu\202t hi\214n \235 Th\199n B\221 Tr\203n \167i\211m (b\173\237c v\181o tr\203n nh\183n v\237i \174\241 4 l\214nh, ho\198c nh\234 \167\185i phu \174\173a v\181o). H\185 Th\171ng Thi\170n \174\173\238c th\173\235ng kinh nghi\214m, ng\169n l\173\238ng, nguy\170n li\214u v\181 4 B\182o r\173\172ng. M\231i tr\203n nh\203n th\173\235ng t\232i \174a " .. PTVT_DAILY_CAP .. " l\199n m\231i ng\181y. M\231i l\173\238t k\208o d\181i " .. floor(PTVT_FIGHT / 60) .. " ph\243t.", 2, "Tr\235 l\185i/main", "K\213t th\243c \174\232i tho\185i/no")
end

function no()
	CloseDialog()
end
