-- Phong Than 2026-10-03 (sinhhoat): item 6/1/61380 "Hat Giong Ky Son" (Le Quan, Tam Nguyet Ky Son, taskinfo
-- 1029 / 1617). Right click on Ky Son (1017): a sapling (template 1808) grows where the player stands; npc param
-- 0 = 2370200, 1 = owner player id, 2 = ripe flag, 3 = planted (SystemTime). lq_tree.lua: OnTimer after 5 min
-- (ripe), main = harvest, Timeout = removed after 30 min. Consumed on success.
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

function main(nItemIdx)
	local w = GetWorldPos()
	if w ~= PTLQ_TREE_MAP then
		Say("Mầm cây thần bí chỉ hợp đất <color=yellow>Kỳ Sơn<color>. Hãy đến Kỳ Sơn rồi trồng.", 1, "Đóng/PTSH_No")
		return 0
	end
	local sw = SubWorldID2Idx(w)
	if sw == nil or sw < 0 then return 0 end
	local pn = GetPlayerNpcIdx()
	local pw, x, y = GetNpcPos(pn)
	local t = AddNpc(PTLQ_TREE_TPL, 1, sw, x * 32 + 16, y * 32 + 16, 0)
	if t == nil or t <= 0 then
		Say("Không trồng được ở chỗ này, hãy thử chỗ khác.", 1, "Đóng/PTSH_No")
		return 0
	end
	SetNpcName(t, "Cây Thần (" .. GetName() .. ")")
	SetNpcScript(t, PTSH_S_TREE)
	SetNpcParam(t, 0, PTSH_MG_TREE)
	SetNpcParam(t, 1, PTSH_Me())
	SetNpcParam(t, 2, 0)
	SetNpcParam(t, 3, PTSH_Now())
	SetNpcTimer(t, PTSH_S_TREE, PTLQ_TREE_RIPE)
	SetNpcTimeout(t, PTLQ_TREE_LIFE * 18)
	RemoveItem(nItemIdx, 1, 0)
	Msg2Player("Đã trồng Cây Thần. Khoảng 5 phút nữa cây sẽ chín, hãy quay lại hái quả (cây tự biến mất sau 30 phút).")
	return 0
end
