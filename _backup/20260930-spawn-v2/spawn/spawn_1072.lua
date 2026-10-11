-- Phong Than generated monster population for map 1072 (Khai Minh dao / 开明岛). Generated 2026-09-28 by
-- %TEMP%\ptspawn\gen_spawn.py. NOT original VNG placement data (none survives for this map):
-- templates are chosen from quest/script evidence, positions are generated on client Region_C
-- walkable cells that are also free in server Region_S obstacle data, >=12 cells from exits.
-- Row = { template (Npcs.txt data row, 0-based), level, mpsX, mpsY }.  Confidence: H
-- Evidence: Templates 红名岛的怪1-3 (red-name island monsters, ani051 = Phi Thu art) with loose death scripts npcdeath\red1-3.lua (reduce PK, count 'Phi Tho' for task 586); quest 'Khai Minh Dao tieu diet 10 Phi Tho'
--   tid 421 lv 40 x15  红名岛的怪1 Phi Tho
--   tid 422 lv 60 x24  红名岛的怪2 Phi Tho
--   tid 423 lv 80 x8  红名岛的怪3 Phi Tho

PT_SPAWN_DATA[1072] = {}
PTSpawn_Put(1072, {
	{421,40,48848,100816},
	{421,40,48944,100720},
	{421,40,48912,100816},
	{421,40,48464,104144},
	{421,40,48368,104144},
	{421,40,48432,104272},
	{422,60,49264,99472},
	{422,60,49328,99568},
	{422,60,49232,99568},
	{422,60,49200,99472},
	{421,40,51760,102192},
	{421,40,51664,102288},
	{421,40,51600,102192},
	{421,40,51760,102288},
	{421,40,51632,102096},
	{421,40,47472,103152},
	{421,40,47376,103152},
	{421,40,47600,103216},
	{421,40,47408,103216},
	{422,60,48912,102640},
	{422,60,48944,102736},
	{422,60,48976,102512},
	{422,60,48912,102480},
	{422,60,50000,101744},
	{422,60,50064,101872},
	{422,60,50064,101776},
	{422,60,50000,101680},
	{422,60,50000,101840},
	{422,60,50928,99952},
	{422,60,50864,99888},
	{422,60,50864,100048},
	{422,60,49264,105232},
	{422,60,49168,105168},
	{422,60,49264,105136},
	{422,60,49136,105232},
	{422,60,49168,105104},
	{422,60,47696,100016},
	{422,60,47792,99920},
	{422,60,47664,99888},
	{423,80,51408,104272},
	{423,80,51344,104272},
	{423,80,51312,104144},
	{423,80,51504,104240},
	{423,80,51472,104400},
	{423,80,47664,101648},
	{423,80,47760,101520},
	{423,80,47632,101552}
})
