-- Phong Than 2026-10-02: ActionScript of the 4 Bao ruong Thong Thien (template 1929, no DeathScript).
-- Breaking a chest (LastDamage) rewards every participant on the map who earned the Thong Thien
-- reward of this session (task 2004 = session key): exp, money and a material roll.
Include("\\script\\phongthan\\vantien\\vt_lib.lua")

function LastDamage(npcIndex)
	PTVT_ChestDeath(npcIndex)
end

function Revive(npcIndex)
end

function DeathSelf(npcIndex)
end
