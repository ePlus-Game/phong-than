-- Phong Than 2026-10-02: Thien Hung (Tay Ky), entry NPC of Van Tien tran. Spawned by the minute tick
-- (vt_timer.lua, template 247 = the VNG Van Tien gate). Solo friendly: a closed tran is opened on demand.
Include("\\script\\phongthan\\vantien\\vt_lib.lua")

function main()
	local opts = {}
	local n = 1
	while n <= 4 do
		local lock = ""
		if not PTVT_Unlocked(n) then lock = ", khóa" end
		tinsert(opts, "Vạn Tiên trận (" .. PTVT_NAME[n] .. ") cấp " .. PTVT_MINLV[n] .. "+ [" .. PTVT_StateText(n) .. lock .. "]/th_enter" .. n)
		n = n + 1
	end
	tinsert(opts, "Giới thiệu Vạn Tiên trận/th_info")
	tinsert(opts, "Kết thúc đối thoại/no")
	local t = { "<color=green>Thiên Hùng<color>: Thông Thiên Giáo Chủ bày Vạn Tiên trận, ma chúng lộng hành. Ta chiêu mộ dũng sĩ từ cấp <color=yellow>30<color> vào phá trận. Ngươi muốn vào trận nào?", getn(opts) }
	local i = 1
	while opts[i] do
		t[i + 2] = opts[i]
		i = i + 1
	end
	call(Say, t)
end

function th_enter(n)
	CloseDialog()
	PTVT_EnterRequest(n)
end

function th_enter1() th_enter(1) end
function th_enter2() th_enter(2) end
function th_enter3() th_enter(3) end
function th_enter4() th_enter(4) end

function th_info()
	Say("Vạn Tiên trận gồm 4 trận: <color=yellow>Thổ<color> (cấp 30+), <color=yellow>Thủy<color> (51+), <color=yellow>Hỏa<color> (71+), <color=yellow>Phong<color> (91+). Phá trận trước sẽ mở khóa trận sau dù chưa đủ cấp. Trong trận: hạ <color=green>Ô Vân, Cầu Thủ, Linh Nha, Kim Quang Tiên<color> để lấy 4 lệnh, Thông Thiên Giáo Chủ sẽ xuất hiện ở Thần Bí Trận Điểm (bước vào trận nhãn với đủ 4 lệnh, hoặc nhờ Đại phu đưa vào). Hạ Thông Thiên được thưởng kinh nghiệm, ngân lượng, nguyên liệu và 4 Bảo rương. Mỗi trận nhận thưởng tối đa " .. PTVT_DAILY_CAP .. " lần mỗi ngày. Mỗi lượt kéo dài " .. floor(PTVT_FIGHT / 60) .. " phút.", 2, "Trở lại/main", "Kết thúc đối thoại/no")
end

function no()
	CloseDialog()
end
