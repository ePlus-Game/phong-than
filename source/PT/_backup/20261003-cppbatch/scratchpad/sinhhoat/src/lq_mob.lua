-- Phong Than 2026-10-03 (sinhhoat): challenge boars of Khieu chien cuc han (spawned by lq_chienthu.lua).
-- npc param 0 = 2370300, 1 = owner player id, 2 = challenge start (SystemTime). The engine calls LastDamage with
-- PlayerIndex = killer (KNpc.cpp DoDeath, kind_normal + ActionScript); the template (1369/1370) has no
-- DeathScript, so the npc does not revive; DelNpc in the handler is deferred by the engine. Timeout = 10 min TTL.
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

function LastDamage(npc)
	if npc == nil or npc <= 0 then return end
	if GetNpcParam(npc, 0) ~= PTSH_MG_MOB then return end
	local owner = GetNpcParam(npc, 1)
	local start = GetNpcParam(npc, 2)
	SetNpcParam(npc, 0, 0)
	DelNpc(npc)
	if owner ~= PTSH_Me() then return end
	if PTLQ_ChalRunning() ~= start or start <= 0 then return end
	local k = GetTask(PTLQ_T_KILL) + 1
	SetTask(PTLQ_T_KILL, k)
	if k < PTLQ_CHAL_KILLS then
		Msg2Player("Khiêu chiến cực hạn: " .. k .. "/" .. PTLQ_CHAL_KILLS)
		return
	end
	SetTask(PTLQ_T_CHAL, 0)
	SetTask(PTLQ_T_KILL, 0)
	local lv = GetLevel()
	local e = lv * lv * 40 + 10000
	AddOwnExp(e)
	Earn(lv * 300)
	PTSH_Give(6, PTLT_I_DON, 0, 2)
	local id = PTLQ_TaskId(204, 1615)
	PTSH_Note(id, "Khiêu chiến cực hạn", "Hoàn thành", 2)
	Msg2Player("Khiêu chiến cực hạn thành công! Thưởng " .. e .. " kinh nghiệm, " .. (lv * 300) .. " lượng, 2 Linh Thú Đơn.")
	PTLQ_EggChance(8)
end

function Timeout(npc)
	if npc and npc > 0 then DelNpc(npc) end
end

function main(npc)
end
