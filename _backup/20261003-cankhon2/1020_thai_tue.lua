-- Phong Than npc_fix 2026-09-30: Thai Tue Su (Can Khon Luan), map 1020; original script.pak \script\caipiao\taisui.lua (pinyin of GBK path).
-- changes: Include pt_compat (exit row, multi-use CostIBItem).
-- 2026-10-02: CoreServer has Roulette(k, names) (server-side spin shown as top messages, ~5-6 s; Finished() is
-- called by the engine when the spin stops on sector k; no reward if aborted by logout/death/map change) and
-- RouletteBusy(). On an older engine without Roulette the fallback below gives the reward immediately.
Include("\\script\\phongthan\\lib\\pt_compat.lua")
-- sector names in the order of Finished() (task 72 = k), TCVN3
PT_CKL_NAMES = "Ngò Quû|§¹i Hao|B¹ch Hæ|Thiªn CÈu|B¸ch ViÖt|Tö Vi|Thiªn §øc|Th¸i ¢m|Th¸i D­¬ng|Th¸i TuÕ|TiÓu Hao|DŞch M·"
if not Roulette then
	function Roulette(k)
		Finished()
		return 1
	end
end
function PT_CKL_Busy()
	if RouletteBusy and RouletteBusy() == 1 then
		Talk(1, "no", "Cµn Kh«n Lu©n ®ang quay, h·y chê kÕt qu¶!")
		return 1
	end
	return nil
end

--description: Ì«ËêÖ®ÂÖ¡ª¡ªÌ«ËêÖ®ÂÖ
--author:chensong
--date: 2004/7/14
--11079	#Ì«ËêÊ¦£ºÌ«ËêÖ®ÂÖÊÇÉÏ¹ÅÕ½ÕùÒÅÁôÏÂÀ´µÄÉñÆ÷£¬Í¨¹ıËüÄÜÖªµÀÒ»¸ö?µÄÎ´À´¡£µ±ÄãµÈ¼¶´ïµ½40¼¶ÒÔºó,Äã¾Í¿ÉÒÔÊÔ×Å×ª¶¯Ëü¿´¿´ÄãµÄÔËÊÆ±ä»¯£¡
--11080	#Ì«ËêÊ¦£ºÕâ¸öÊÇÉÏ¹ÅÕ½ÕùÒÅÁôÏÂÀ´µÄÉñÆ÷£¬Í¨¹ıËüÄÜÖªµÀÒ»¸ö?µÄÎ´À´¡£¿ÉÏ§Äã·¥ÖÊ»¹²î£¬¾­ÊÜ²»³ÑÉñÆ÷ÁéÁ¦µÄ³å»÷¡£Äã»¹ÊÇÒÔºó²]À´°É£¡
--11081	#Ì«ËêÊ¦£ºÌ«ËêÖ®ÂÖ·ÖÎªÊ®¶ş²¿·Ö£¬·Ö±ğ´ú±íÎå¹í¡¢´óºÄ¡¢°×»¢¡¢Ìì¹·¡¢°ÙÔ½¡¢×ÏÎ¢¡¢ÌìµÂ¡¢Ì«Òõ¡¢Ì«Ñô¡¢Ì«Ëê¡¢Ğ¡ºÄ¡¢æäÂí£¡
--11082	#Ì«ËêÊ¦£ºÒ»¸ö?×ª¶¯Ì«ËêÖ®ÂÖ£¬µ±ÂÖÉÏµÄºì¹â×îºóÖ¸ÏòÄ³Ò»²¿·Ö£¬Õâ¸ö²¿·Ö¾Í´ú±í³ÑÕâ¸ö?ÔÚÎ´À´Ò»¶ÎÊ±¼äÄÚ»á·¢ÉúµÄÒ»Ğ©ÊÂ¡£ÌıÆğÀ´ÊÇ²»ÊÇºÜ²»¿ÉË¼Òé£¬Òª²»ÒªÊÔÊÔ£¿
--11083	#Ì«ËêÊ¦£ºÄã½ñÌìÒÑ¾­³ĞÊÜ³ÑÒ»´ÎÌ«ËêÖ®ÂÖµÄÁéÁ¦³å»÷³Ñ£¬¹ıÒ»ÈÕÉí·¥»Ö¸´³Ñ²]À´°É£¡
--11084	#Ì«ËêÊ¦£ºÄãµÄ·¥ÖÊ»¹ºÜ?£¬¾­ÊÜ²»ÆğÌ«ËêÖ®ÂÖµÄÁéÁ¦³å»÷£¬»¹ÊÇ¹ıĞ©ÈÕ×Ó£¬µÈÄã25¼¶³Ñ²]À´°É£¡
--11085	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÎå¹í£¬Äã¿ÉÒÔÖØĞÂ×ª¶¯Ò»´ÎÌ«ËêÖ®ÂÖ¡£
--11086	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇ´óºÄ£¬Äã½«ÔÚÎ´À´1Ğ¡Ê±ÄÚ»ñµÃ¼ÓËÙÉúÃü»Ø¸´ËÙ¶È10µÄ×´Ì¬¡£ÇëÄãºÃºÃ¼ÓÒÔÀûÓÃ¡£
--11088	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇ°×»¢£¬Äã½«ÔÚÎ´À´1Ğ¡Ê±ÄÚ»ñµÃ¼ÓËÙÄÚÁ¦»Ø¸´ËÙ¶È10µÄ×´Ì¬¡£ÇëÄãºÃºÃ¼ÓÒÔÀûÓÃ¡£
--11089	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÌì¹·£¬Äã½«»ñµÃ10µÄÉùÍûÖµ£¬ÇëÄãºÃºÃ¼ÓÒÔÀûÓÃ¡£
--11091	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇ°ÙÔ½£¬Äã½«»ñµÃ15µÄÉùÍûÖµ£¬ÇëÄãºÃºÃ¼ÓÒÔÀûÓÃ¡£
--11092	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇ×ÏÎ¢£¬Äã½«»ñµÃÔÚÎ´À´1Ğ¡Ê±ÄÚ¾­ÑéÖµ2±¶µÄ×´Ì¬¡£ÇëÄãºÃºÃ¼ÓÒÔÀûÓÃ¡£
--11093	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÌìµÂ£¬Äã½«Ò»´ÎĞÔ»ñµÃ50000½ğÇ®¡£
--11097	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÌ«Òõ£¬ÄãÊÜÌ«ÒõÉñµÄ¸£Ôó£¬½«Ò»´ÎĞÔ»ñµÃ20000½ğÇ®¡£
--11098	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÌ«Òõ£¬±¾Ó¦ÊÜµ½Ì«ÒõÉñµÄ¸£Ôó»ñµÃ20000½ğÇ®£¬µ«ÊÇÄãÊÇÄĞµÄ£¬ËùÒÔÖ»ÄÜºÍ»ñ?Ò»°ëµÄ¸£ÔË£¬­âÊÇ¿ÉÏ§¡£
--11099	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÌ«Ñô£¬ÄãÊÜÌ«ÑôÉñµÄ¸£Ôó£¬½«Ò»´ÎĞÔ»ñµÃ20000½ğÇ®¡£
--11100	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÌ«Ñô£¬±¾Ó¦ÊÜµ½Ì«ÑôÉñµÄ¸£Ôó»ñµÃ20000½ğÇ®£¬µ«ÊÇÄãÊÇÅ®µÄ£¬ËùÒÔÖ»ÄÜºÍ»ñ?Ò»°ëµÄ¸£ÔË£¬­âÊÇ¿ÉÏ§¡£
--11101	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇÌ«Ëê£¬Äã½«»ñµÃÔÚÎ´À´2Ğ¡Ê±ÄÚ¾­ÑéÖµ1.5±¶µÄ×´Ì¬¡£ÇëÄãºÃºÃ¼ÓÒÔÀûÓÃ¡£
--11103	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇĞ¡ºÄ£¬Äã½«Ò»´ÎĞÔ»ñµÃ30000¾­Ñé¡£
--11104	#Ì«ËêÊ¦£ºÄã×ª¶¯µ½µÄÊÇæäÂí£¬ËùÎ½ºÃÔËµ±Í·£¬¹§Ï²Äã£¬Äã»ñµÃ³Ñ10Íò¾­Ñé°¡£¡
--764,¼ÇÂ¼µ±Ìì×ª¶¯´ÎÊı



function main()
	local UTask_cp_2=GetTask(72)
	tasks = 
			{
			 {"Xoay Cµn Kh«n lu©n","yes_2";show=0},
			 {"Cµn Kh«n Lu©n","yes_1";show=1},
			 {"H×nh thÕ th©n","zhiren";show=1},
			 {"C©y ThÕ th©n","muren";show=1}
			}
	if(GetLevel()>=40)then
		tasks[1].show=1
	end;
	SayTask(11079,tasks)
end;

function muren()
	Talk(2,"no","Cµn Kh«n Lu©n lµ thÇn khİ th­îng cæ, tuy h×nh thÕ th©n cã thÓ gióp ng­¬i høng chŞu nh­ng mçi lÇn chuyÓn ®éng søc Ğp t¨ng thªm ta e h×nh thÕ th©n còng kh«ng gióp ®­îc g×!","<color=green>C©y ThÕ th©n<color> cã thÓ høng chŞu søc Ğp lín. Mçi ngµy chØ sö dông ®­îc <color=green>3 lÇn<color> mµ th«i!")
end

function zhiren()
	Talk(2,"no","Cµn Kh«n Lu©n lµ thÇn khİ th­îng cæ, chuyÓn ®éng 1 lÇn sÏ tiªu hao nguyªn thÇn cña ng­¬i, mét ngµy sau míi håi phôc. Nh­ng ta cã c¸ch gióp ng­¬i quay Cµn Kh«n Lu©n nhiÒu lÇn trong 1 ngµy. Cã muèn thö kh«ng?","Lóc Cµn Kh«n Lu©n chuyÓn ®éng ph¶i cã vËt hÊp thu chÊn ®éng cña nã, <color=green>H×nh thÕ th©n<color> cã thÓ gióp ng­¬i høng chŞu søc m¹nh Êy nh÷ng mçi ngµy chØ dïng ®­îc <color=green>2 lÇn<color> mµ th«i!")
end

function yes_1()
	Talk(2,"no","Cµn Kh«n Lu©n chia lµm 12 phÇn gåm <color=green>Ngò Quû, §¹i Hao, B¹ch Hæ, Thiªn CÈu, B¸ch ViÖt, Tö Vi, Thiªn §øc, Th¸i D­¬ng, Th¸i ¢m, Th¸i TuÕ, TiÓu Hao, DŞch M·<color>!","Cµn Kh«n Lu©n lµ thÇn khİ l­u l¹i tõ thêi th­îng cæ cã thÓ gióp con ng­êi biÕt ®­îc t­¬ng lai. Khi ng­¬i ®¹t <color=green>cÊp 40<color> cã thÓ thö xoay ®Ó xem sè mÖnh cña m×nh.")
end;

function yes_2()
	if PT_CKL_Busy() then return end
	local count = GetIBBuffCount()
	if(count<16)then
		MsgBox(11082,"yes_3","no")
	else
		Talk(1,"no","Tr¹ng th¸i cña ng­¬i kh«ng phï hîp ¶nh h­ëng ®Õn sù ph¸n ®o¸n cña Cµn Kh«n Lu©n. NÕu muèn thö l¹i t¾t bá nh÷ng tr¹ng th¸i Êy!")
	end
end;

function yes_3()
	if PT_CKL_Busy() then return end
	local LastBuyTime = GetTask(73) -- ×îºóÒ»´Î¹ººjÊ±¼ä
	local NowBuyTime = SystemTime()    -- ÏÖÔÚÊ±¼ä
	local i=FindAValidIBItem(8,135,2,0)
	local j=FindAValidIBItem(8,174,2,0)
	local m=FindAValidIBItem(8,178,2,0)
	local n=FindAValidIBItem(8,179,2,0)
	if(ceil(LastBuyTime / 86400) == ceil(NowBuyTime / 86400)) then-- ºj¹ı³Ñ,´¦ÀíÌáÊ¾
		if(GetTask(764)<=2)then
			if(i~=0)then	--cishu<=2&have(zhiren)
				CostIBItem(i)
				rolling()
			elseif(m~=0)then
				CostIBItem(m)
				rolling()
			else
				local t=GetTask(764)
				Talk(1,"no","H«m nay ng­¬i ®· xoay <color=red>"..t.."<color> lÇn Cµn Kh«n Lu©n, nÕu muèn thö l¹i ph¶i cã <color=green>C©y thÕ th©n<color>!")
			end
		elseif(GetTask(764)>2)and(GetTask(764)<=5)then
			if(j~=0)then
				CostIBItem(j)
				rolling()
			elseif(n~=0)then
				CostIBItem(n)
				rolling()
			else
				local t=GetTask(764)
				Talk(1,"no","H«m nay ng­¬i ®· xoay <color=red>"..t.."<color> lÇn Cµn Kh«n Lu©n, nÕu muèn thö l¹i ph¶i cã <color=green>H×nh thÕ th©n<color>!")
			end
		elseif(GetTask(764)>=6)then
			Talk(1,"no","MÆc dï ng­¬i dïng ®ñ lo¹i h×nh thÕ th©n ®Ó høng chŞu søc Ğp cña Cµn Kh«n Lu©n nh­ng do sè lÇn quay qu¸ nhiÒu, thÓ chÊt cña ng­¬i ®· yÕu, lÇn sau quay l¹i ®i!")
		end
	else
		SetTask(764,0)
		rolling()
	end
end

function rolling()
	local UTask_cp_2=GetTask(72)
	local buytime=GetTask(73)
	local LastBuyTime = GetTask(73) -- ×îºóÒ»´Î¹ººjÊ±¼ä
	local NowBuyTime = SystemTime()    -- ÏÖÔÚÊ±¼ä
	local t = random(1,100)  -- Éú³ÉÖĞ½±ºÅ
	local k = 0
	if(t<=10)then
		k=0
	elseif(t<=19)then
		k=1
	elseif(t<=28)then
		k=2
	elseif(t<=37)then
		k=3
	elseif(t<=48)then
		k=4
	elseif(t<=55)then
		k=5
	elseif(t<=62)then
		k=6
	elseif(t<=72)then
		k=7
	elseif(t<=82)then
		k=8
	elseif(t<=89)then
		k=9
	elseif(t<=99)then
		k=10
	else
		k=11
	end
	CloseDialog()
	SetTask(73,NowBuyTime) -- ³É¹¦Ê±¼ÇÂ¼ÏÂ×îºóÒ»´Î¹ººjÊ±¼ä
	SetTask(72,k) 
	SetTask(764,GetTask(764)+1)
	if not Roulette(k, PT_CKL_NAMES) then
		Finished() -- engine refused the spin: give the reward now
	end -- ¿Í»§¶Ë´ò¿ª½çÃæ
end;

function Finished() -- ¿Í»§¶Ë²Ù×÷Íê±Ï
	local UTask_cp_2=GetTask(72)
	local NowTime=SystemTime()
	local UTask_cp_time=GetTask(75)
	local NowTime=SystemTime()
	local Name=GetName()
	local UTask_jingyan=GetTask(8)
	local addexp=GetLevel()*100
	AddOwnExp(addexp)
	TopMessage("Mçi vßng nhËn ®­îc <color=green>"..addexp.."®iÓm kinh nghiÖm.")
	if (UTask_cp_2==0) then
		SetTask(764,GetTask(764)-1)
		MsgBox("Ng­¬i ®· quay ®Õn <color=green>Ngò Quû<color>, cã thÓ quay l¹i mét lÇn!","rolling","no")
		Msg2Player("B¹n nhËn ®­îc thªm 1 l­ît quay")
	elseif (UTask_cp_2==1) then
		if(HaveIBBuff(12)==1)then
			RemoveIBBuff(12)
		end
		local i=AddIBBuff(12)
		if(i==1)then
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>§¹i Hao<color>, nhËn ®­îc: håi sinh lùc + 10 ®iÓm trong 1 giê. H·y tËn dông dŞp may cña m×nh!")
			Msg2Player("B¹n nhËn ®­îc håi sinh lùc + 10 ®iÓm trong 1 giê. ")
		else
			Talk(1,"no","Tr¹ng th¸i cña ng­¬i ®· x¶y ra xung ®ét kh«ng thÓ ph¸t huy t¸c dông!")
		end
	elseif (UTask_cp_2==2) then
		if(HaveIBBuff(13)==1)then
			RemoveIBBuff(13)
		end
		local i=AddIBBuff(13)
		if(i==1)then
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>B¹ch Hæ<color>, nhËn ®­îc Håi Néi lùc + 10 ®iÓm trong 1 giê. H·y tËn dông dŞp may cña m×nh!")
			Msg2Player("B¹n nhËn ®­îc: Håi Néi lùc + 10 ®iÓm trong 1 giê. ")
		else
			Talk(1,"no","Tr¹ng th¸i cña ng­¬i ®· x¶y ra xung ®ét kh«ng thÓ ph¸t huy t¸c dông!")
		end
	elseif (UTask_cp_2==3) then
		Talk(1,"no","B¹n ®· quay ®Õn <color=green>Thiªn CÈu<color>, nhËn ®­îc 15 ®iÓm danh väng.") 
		AddCredit(15)
		Msg2Player("B¹n nhËn ®­îc 15 ®iÓm danh väng.")
	elseif (UTask_cp_2==4) then
		Talk(1,"no","B¹n ®· quay ®Õn <color=green>B¸ch ViÖt<color>, nhËn ®­îc 10 ®iÓm danh väng.") 
		AddCredit(10)
		Msg2Player("B¹n nhËn ®­îc 10 ®iÓm danh väng.")
	elseif (UTask_cp_2==5) then
		if(HaveIBBuff(175)==1)then
			RemoveIBBuff(175)
		end
		local i=AddIBBuff(175)
		if(i==1)then
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>Tö Vi<color>, nhËn ®­îc nh©n ®«i kinh nghiÖm trong 1 giê.")
			Msg2Player("B¹n nhËn ®­îc nh©n ®«i kinh nghiÖm trong 1 giê.")
		else
			Talk(1,"no","Tr¹ng th¸i cña ng­¬i ®· x¶y ra xung ®ét kh«ng thÓ ph¸t huy t¸c dông!")
		end
	elseif (UTask_cp_2==6) then
		Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>Thiªn §øc<color>, nhËn ®­îc 5 v¹n l­îng.")
		Earn(50000)
		Msg2Player("B¹n nhËn ®­îc 5 v¹n l­îng.")
	elseif (UTask_cp_2==7) then
		if (GetSex()==1) then
			Earn(20000)
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>Th¸i ¢m<color>, nhËn ®­îc phóc tr¹ch cña Th¸i ¢m thÇn vµ 2 v¹n l­îng.")
			Msg2Player("B¹n nhËn ®­îc 2 v¹n l­îng.")
		else
			Earn(10000)
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>Th¸i ¢m<color>, nhËn ®­îc phóc tr¹ch cña Th¸i ¢m thÇn vµ 2 v¹n l­îng. §¸ng tiÕc b¹n lµ nam nªn chØ nhËn ®­îc mét n÷a phóc tr¹ch!")
			Msg2Player("B¹n nhËn ®­îc 1w l­îng.")
		end;
	elseif (UTask_cp_2==8) then
		if (GetSex()==0) then
			Earn(20000)
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>Th¸i D­¬ng<color>, nhËn ®­îc phóc tr¹ch cña Th¸i D­¬ng thÇn vµ 2 v¹n l­îng.")
			Msg2Player("B¹n nhËn ®­îc 2 v¹n l­îng.")
		else
			Earn(10000)
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>Th¸i D­¬ng<color>, nhËn ®­îc phóc tr¹ch cña Th¸i D­¬ng thÇn vµ 2 v¹n l­îng. §¸ng tiÕc b¹n lµ n÷ chØ nhËn ®­îc mét n÷a phóc tr¹ch.")
			Msg2Player("B¹n nhËn ®­îc 1w l­îng.")
		end;
	elseif (UTask_cp_2==9) then
		if(HaveIBBuff(176)==1)then
			RemoveIBBuff(176)
		end
		local i=AddIBBuff(176)
		if(i==1)then
			Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>Th¸i TuÕ<color>,  nhËn ®­îc  nh©n 1.5 kinh nghiÖm trong 2 giê.")
			Msg2Player("B¹n nhËn ®­îc nh©n 1.5 kinh nghiÖm trong 2 giê.")
		else
			Talk(1,"no","Tr¹ng th¸i cña ng­¬i ®· x¶y ra xung ®ét kh«ng thÓ ph¸t huy t¸c dông!")
		end
	elseif (UTask_cp_2==10) then
		Talk(1,"no","B¹n ®· quay ®Õn<color=green>TiÓu Hao<color>,  nhËn ®­îc 3 v¹n ®iÓm kinh nghiÖm.")
		AddOwnExp(30000)
		Msg2Player("B¹n nhËn ®­îc 3 v¹n ®iÓm kinh nghiÖm.")
	else
		Talk(1,"no","Ng­¬i ®· quay ®Õn <color=green>DŞch M·<color>,  nhËn ®­îc <color=yellow>10 v¹n ®iÓm kinh nghiÖm<color>!")
		AddOwnExp(100000)
		AddGlobalCountNews("Lóc Cµn Kh«n Lu©n chuyÓn ®éng, <color=green>"..GetName().."<color> nhËn ®­îc <color=yellow>10w ®iÓm kinh nghiÖm<color>, xem ra vËn may cña b¹n ®· ®Õn!",3)
		Msg2Player("B¹n nhËn ®­îc 10w ®iÓm kinh nghiÖm.")
	end;
	SetTask(72,0) 
end;

function no()
		CloseDialog()
end;






