-- Phong Than 2026-10-03 (sinhhoat): gather node (herb bush / ore vein / fishing spot). Spawned and respawned by
-- script\phongthan\ext\sinhhoat.lua; npc param 0 = 2370100 + type (1 herb, 2 ore, 3 fish), param 1 = uses left.
-- One click = one gather (cooldown PTSH_COOLDOWN seconds); the node disappears after PTSH_NODE_USES gathers and
-- the ext tick puts it back a few minutes later.
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

PTSH_NODE_TITLE = { "Bụi thảo dược", "Mạch khoáng", "Điểm câu cá" }
PTSH_NODE_VERB = { "hái", "đào", "câu" }

function main(npc)
	if npc == nil or npc <= 0 then return end
	local typ = GetNpcParam(npc, 0) - PTSH_MG_NODE
	if typ < 1 or typ > 3 then return end
	SetTask(PTSH_T_DLG, npc)
	PTSH_Gather(npc, typ)
end

function PTSH_Gather(npc, typ)
	local k = typ          -- skill index = node type (1 herb, 2 ore, 3 fish)
	if typ == 2 and PTSH_HasBook(PTSH_BOOK_GATHER) == 0 then
		Say("<color=green>" .. PTSH_NODE_TITLE[typ] .. "<color>: muốn khai khoáng phải lĩnh hội kỹ năng sống <color=yellow>Bàn Cổ Khai Thiên<color> (Sinh Hoạt Sư dạy, hoặc dùng bí kíp).", 1, "Đóng/PTSH_No")
		return
	end
	local now = PTSH_Now()
	local last = GetTask(PTSH_T_GTIME)
	if now - last < PTSH_COOLDOWN and now >= last then
		Msg2Player("Đang " .. PTSH_NODE_VERB[typ] .. ", hãy chờ một chút rồi bấm lại.")
		return
	end
	if PTSH_Free() < 1 then
		Say("Hành trang đã đầy, không còn chỗ chứa.", 1, "Đóng/PTSH_No")
		return
	end
	local left = GetNpcParam(npc, 1)
	if left <= 0 then
		Msg2Player("Nơi này đã cạn, hãy tìm chỗ khác.")
		return
	end
	SetTask(PTSH_T_GTIME, now)
	local lv = PTSH_SkillLevel(k)
	local t = PTSH_Rand(lv - 2, lv)
	if t < 1 then t = 1 end
	local id = PTSH_Pick(PTSH_MAT[typ][t])
	local n = 1
	if typ == 2 and PTSH_Rand(1, 100) <= 20 then n = 2 end
	local got = PTSH_Give(3, id, 0, n)
	if got <= 0 then
		Msg2Player("Không nhận được vật phẩm (hành trang đầy?).")
		return
	end
	Msg2Player("Đã " .. PTSH_NODE_VERB[typ] .. " được " .. got .. " nguyên liệu cấp " .. t .. ".")
	if typ == 2 and lv >= 4 and PTSH_Rand(1, 100) <= 5 then
		local c = PTSH_Pick(PTSH_CRYSTAL)
		if PTSH_Give(3, c[1], 0, 1) > 0 then Msg2Player("May mắn! Đào được một viên Thủy Tinh Nguyên Thạch.") end
	end
	PTSH_AddSkillExp(k, 2 + floor(t / 3))
	left = left - 1
	SetNpcParam(npc, 1, left)
	if left <= 0 then
		DelNpc(npc)
	end
end

function Timeout(npc)
	if npc and npc > 0 then DelNpc(npc) end
end
