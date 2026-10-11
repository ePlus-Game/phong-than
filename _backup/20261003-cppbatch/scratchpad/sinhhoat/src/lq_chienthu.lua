-- Phong Than 2026-10-03 (sinhhoat): item 6/1/61381 "Chien Thu Khieu Chien" (Le Quan, Khieu chien cuc han,
-- taskinfo 204 / 1615). Right click outside town: 7 challenge boars appear around the player (owned through npc
-- param 1 = player id, param 2 = start time); kills are counted in lq_mob.lua (LastDamage). Consumed on success.
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

function main(nItemIdx)
	if PTLQ_ChalRunning() > 0 then
		Say("Ngươi đang trong một cuộc khiêu chiến, hãy hạ hết heo thử thách trước.", 1, "Đóng/PTSH_No")
		return 0
	end
	if PTSH_InCity() == 1 then
		Say("Trong thành không thể khiêu chiến. Hãy ra ngoài thành rồi dùng Chiến Thư.", 1, "Đóng/PTSH_No")
		return 0
	end
	local n = PTLQ_SpawnChallenge()
	if n > 0 then RemoveItem(nItemIdx, 1, 0) end
	return 0
end

function PTLQ_SpawnChallenge()
	local w = GetWorldPos()
	local sw = SubWorldID2Idx(w)
	if sw == nil or sw < 0 then return 0 end
	local pn = GetPlayerNpcIdx()
	local pw, x, y = GetNpcPos(pn)
	local now = PTSH_Now()
	local me = PTSH_Me()
	local lv = GetLevel()
	local last = getn(PTLQ_MOB_OFF)
	local n = 0
	local i = 1
	while i <= last do
		local o = PTLQ_MOB_OFF[i]
		local tpl = PTLQ_MOB_TPL
		local name = "Heo Rừng Thử Thách"
		if i == last then
			tpl = PTLQ_BOSS_TPL
			name = "Trư Vương Thử Thách"
		end
		local m = AddNpc(tpl, lv, sw, (x + o[1]) * 32, (y + o[2]) * 32, 0)
		if m and m > 0 then
			SetNpcName(m, name)
			SetNpcScript(m, PTSH_S_MOB)
			SetNpcParam(m, 0, PTSH_MG_MOB)
			SetNpcParam(m, 1, me)
			SetNpcParam(m, 2, now)
			SetNpcTimeout(m, PTLQ_CHAL_SEC * 18)
			n = n + 1
		end
		i = i + 1
	end
	if n == 0 then
		Say("Không thả được heo thử thách ở đây.", 1, "Đóng/PTSH_No")
		return 0
	end
	SetTask(PTLQ_T_CHAL, now)
	SetTask(PTLQ_T_KILL, PTLQ_CHAL_KILLS - n)
	Msg2Player("Khiêu chiến cực hạn bắt đầu: hạ " .. n .. " heo thử thách trong 10 phút!")
	return n
end
