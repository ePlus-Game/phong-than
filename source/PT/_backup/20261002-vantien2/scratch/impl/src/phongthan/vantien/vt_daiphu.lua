-- Phong Than 2026-10-02: Dai phu inside Van Tien tran (VNG yisheng, template 766). One at the entry and
-- one in each isolated Than Bi Tran Diem area, so nobody gets stuck after a trap: status, medicine,
-- teleport to Thong Thien, back to the entry, next tran (after the clear), leave to Tay Ky.
Include("\\script\\phongthan\\vantien\\vt_lib.lua")

function dp_tran()
	local w = GetWorldPos()
	return PTVT_MapToN(w)
end

function main()
	local n = dp_tran()
	if not n then
		CloseDialog()
		return
	end
	local opts = {}
	tinsert(opts, "Tình hình trận/dp_status")
	local st = 0
	if PTVT_IsOpen(n) == 1 then st = PTVT_GV(n, 0) end
	local mask = PTVT_GV(n, 1)
	if st == 2 and PTVT_CountTien(mask) == 4 and PTVT_Bit(mask, 16) == 0 then
		tinsert(opts, "Đưa ta đến Thần Bí Trận Điểm (Thông Thiên)/dp_boss")
	end
	if st == 3 and n < 4 then
		tinsert(opts, "Tiến vào Vạn Tiên trận (" .. PTVT_NAME[n + 1] .. ")/dp_next")
	end
	tinsert(opts, "Mua thuốc/dp_sale")
	tinsert(opts, "Về điểm vào trận/dp_entry")
	tinsert(opts, "Rời trận, về Tây Kỳ/dp_leave")
	tinsert(opts, "Kết thúc đối thoại/no")
	local t = { "<color=green>Đại phu<color>: Vạn Tiên trận nguy hiểm, cẩn thận giữ mạng. Ngươi cần gì?", getn(opts) }
	local i = 1
	while opts[i] do
		t[i + 2] = opts[i]
		i = i + 1
	end
	call(Say, t)
end

function dp_status()
	local n = dp_tran()
	if not n then return end
	local st = 0
	if PTVT_IsOpen(n) == 1 then st = PTVT_GV(n, 0) end
	local mask = PTVT_GV(n, 1)
	local txt = "Vạn Tiên trận (" .. PTVT_NAME[n] .. "): " .. PTVT_StateText(n) .. ". Đã hạ " .. PTVT_CountTien(mask) .. "/4 tiên"
	if PTVT_Bit(mask, 16) == 1 then txt = txt .. ", Thông Thiên Giáo Chủ đã bị hạ" end
	local s = PTVT_RestSeconds(n)
	if s > 0 then txt = txt .. ". Còn " .. floor(s / 60) .. " phút " .. mod(s, 60) .. " giây" end
	Say(txt .. ".", 2, "Trở lại/main", "Kết thúc đối thoại/no")
end

function dp_boss()
	local n = dp_tran()
	if not n then return end
	local mask = PTVT_GV(n, 1)
	if PTVT_IsOpen(n) ~= 1 or PTVT_GV(n, 0) ~= 2 or PTVT_CountTien(mask) < 4 then
		Msg2Player("Chưa hạ đủ 4 tiên, Thần Bí Trận Điểm chưa mở.")
		return
	end
	CloseDialog()
	-- the second Dai phu stands on a checked free cell inside the Thong Thien area
	SetPos(PTVT_D[n].doctors[2][1], PTVT_D[n].doctors[2][2])
	SetFightState(1)
	Msg2Player("Đã đến Thần Bí Trận Điểm.")
end

function dp_next()
	local n = dp_tran()
	if not n or n >= 4 then return end
	if PTVT_IsOpen(n) ~= 1 or PTVT_GV(n, 0) ~= 3 then
		Msg2Player("Phải phá trận này trước.")
		return
	end
	CloseDialog()
	PTVT_EnterRequest(n + 1)
end

function dp_sale()
	CloseDialog()
	Sale(1)
end

function dp_entry()
	local n = dp_tran()
	if not n then return end
	CloseDialog()
	SetPos(PTVT_D[n].entry[1], PTVT_D[n].entry[2])
end

function dp_leave()
	CloseDialog()
	PTVT_ToTown()
end

function no()
	CloseDialog()
end
