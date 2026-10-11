-- Phong Than 2026-10-02: ActionScript of the 4 tien and Thong Thien Giao Chu in Van Tien tran.
-- SetNpcScript (ActionScript) -> the engine calls LastDamage(npc) with PlayerIndex = kill owner
-- (KNpc::DoDeath, kind_normal); the template DeathScript (npcdeath\normal.lua) still runs as usual.
-- The bosses get SetNpcRevTime(24 h) and are removed by the engine when the mission closes.
Include("\\script\\phongthan\\vantien\\vt_lib.lua")

function LastDamage(npcIndex)
	PTVT_BossDeath(npcIndex)
end

function Revive(npcIndex)
end

function DeathSelf(npcIndex)
end
