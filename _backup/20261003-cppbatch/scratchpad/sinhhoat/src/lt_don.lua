-- Phong Than 2026-10-03 (sinhhoat): item 6/1/61379 "Linh Thu Don" (pet food). Right click: the active pet gets
-- PTLT_FOOD_EXP exp; consumed only when the pet really gained exp (not at the stage cap).
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

function main(nItemIdx)
	local r = PTLT_Feed()
	if r < 0 then
		Say("Ngươi chưa có linh thú. Gặp Linh Thú Sứ ở Tây Kỳ hoặc Triều Ca.", 1, "Đóng/PTSH_No")
		return 0
	end
	if r == 0 then
		Say("Linh thú đã đạt giới hạn cấp của giai đoạn này, hãy tìm Linh Thú Sứ để tiến hóa.", 1, "Đóng/PTSH_No")
		return 0
	end
	RemoveItem(nItemIdx, 1, 0)
	Msg2Player("Linh thú nhận " .. r .. " điểm kinh nghiệm. " .. PTLT_Label(GetTask(PTLT_T_ACT)) .. ".")
	return 0
end
