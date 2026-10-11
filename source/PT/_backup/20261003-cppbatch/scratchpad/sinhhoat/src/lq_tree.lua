-- Phong Than 2026-10-03 (sinhhoat): Cay Than of Tam Nguyet Ky Son (planted by lq_hatgiong.lua).
-- OnTimer (SetNpcTimer, 5 min): ripe. main: the owner harvests (also when the timer did not run because nobody
-- was near: the planted time in param 3 is checked). Timeout (30 min): removed.
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

function PTLQ_TreeRipe(npc)
	if GetNpcParam(npc, 2) == 1 then return 1 end
	local p = GetNpcParam(npc, 3)
	local now = PTSH_Now()
	if now - p >= PTLQ_TREE_RIPE and now >= p then return 1 end
	return 0
end

function OnTimer(npc)
	if npc == nil or npc <= 0 or GetNpcParam(npc, 0) ~= PTSH_MG_TREE then return end
	SetNpcParam(npc, 2, 1)
	SetNpcName(npc, "Cây Thần (đã chín)")
end

function Timeout(npc)
	if npc and npc > 0 then DelNpc(npc) end
end

function main(npc)
	if npc == nil or npc <= 0 or GetNpcParam(npc, 0) ~= PTSH_MG_TREE then return end
	if GetNpcParam(npc, 1) ~= PTSH_Me() then
		Say("Đây là Cây Thần do người khác trồng.", 1, "Đóng/PTSH_No")
		return
	end
	if PTLQ_TreeRipe(npc) == 0 then
		local left = PTLQ_TREE_RIPE - (PTSH_Now() - GetNpcParam(npc, 3))
		if left < 0 then left = 0 end
		Say("Cây Thần chưa chín, còn khoảng " .. (floor(left / 60) + 1) .. " phút.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_Free() < 4 then
		Say("Cần 4 ô trống trong hành trang để hái quả.", 1, "Đóng/PTSH_No")
		return
	end
	SetNpcParam(npc, 0, 0)
	DelNpc(npc)
	local lv = GetLevel()
	local e = lv * lv * 20 + 5000
	AddOwnExp(e)
	local tmax = floor(lv / 15) + 1
	if tmax > 10 then tmax = 10 end
	local i = 1
	while i <= 3 do
		local t = PTSH_Rand(1, tmax)
		PTSH_Give(3, PTSH_Pick(PTSH_MAT[1][t]), 0, 1)
		i = i + 1
	end
	local id = PTLQ_TaskId(1029, 1617)
	PTSH_Note(id, "Tam Nguyệt Kỳ Sơn", "Hoàn thành", 2)
	Msg2Player("Hái được quả Cây Thần: " .. e .. " kinh nghiệm và 3 thảo dược.")
	PTLQ_EggChance(10)
end
