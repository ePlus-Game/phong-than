-- Phong Than 2026-10-03 (sinhhoat): Le Quan (festival official). The VNG scripts \script\<city>\li_guan (Le Quan).lua were
-- 189-byte stubs ("Ta phu trach cong bo cac su kien moi nhat"); the ptfix plug-in extra_sinhhoat.py turns them
-- into forwarders to this file, and script\phongthan\ext\sinhhoat.lua spawns a Le Quan in Tay Ky, Trieu Ca and
-- the 3 newbie villages at the taskinfo positions.
-- Activities (event hours 12:00-13:59 and 19:00-22:59, announced by the ext tick):
--   * daily festival gift (any time, once a day);
--   * Tam Nguyet Ky Son (taskinfo 1029 / 1617): a Hat Giong Ky Son, planted on Ky Son (1017), ripe after 5 min;
--   * Khieu chien cuc han (taskinfo 204 / 1615): a Chien Thu Khieu Chien, right click outside town = 7 challenge
--     boars around the player (lq_chienthu.lua), kill all in 10 min (lq_mob.lua).
Include("\\script\\phongthan\\sinhhoat\\sh_lib.lua")

PTLQ_HEAD = "<color=green>Lễ Quan<color>: "

function main()
	local st = "Đang đóng (mở 12:00-13:59 và 19:00-22:59)."
	if PTLQ_Open() == 1 then st = "<color=yellow>Đang mở!<color>" end
	Say(PTLQ_HEAD .. "Lão phu phụ trách các lễ hội. Hoạt động lễ hội: " .. st, 5,
		"Nhận lễ vật hằng ngày/PTLQ_Gift",
		"Tam Nguyệt Kỳ Sơn (nhận hạt giống)/PTLQ_Seed",
		"Khiêu chiến cực hạn/PTLQ_Chal",
		"Lịch và giải thích hoạt động/PTLQ_Info",
		"Đóng/PTSH_No")
end

function PTLQ_Info()
	Say(PTLQ_HEAD .. "Lễ vật hằng ngày: mỗi ngày một lần. Tam Nguyệt Kỳ Sơn: nhận tối đa " .. PTLQ_SEED_MAX .. " Hạt Giống Kỳ Sơn mỗi ngày, đến <color=yellow>Kỳ Sơn<color> nhấp phải để trồng, 5 phút sau cây chín thì hái quả. Khiêu chiến cực hạn: nhận Chiến Thư Khiêu Chiến (tối đa " .. PTLQ_CHAL_MAX .. " mỗi ngày), ra ngoài thành nhấp phải, " .. PTLQ_CHAL_KILLS .. " con heo thử thách xuất hiện quanh ngươi, hạ hết trong 10 phút sẽ có thưởng. Phần thưởng có thể có Trứng Linh Thú.", 1, "Đóng/PTSH_No")
end

function PTLQ_Gift()
	local d = PTSH_Day()
	if GetTask(PTLQ_T_GIFT) == d then
		Say(PTLQ_HEAD .. "Hôm nay ngươi đã nhận lễ vật rồi.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_Free() < 3 then
		Say(PTLQ_HEAD .. "Cần 3 ô trống trong hành trang.", 1, "Đóng/PTSH_No")
		return
	end
	SetTask(PTLQ_T_GIFT, d)
	local lv = GetLevel()
	local e = lv * lv * 10 + 2000
	AddOwnExp(e)
	PTSH_Give(6, PTLT_I_DON, 0, 2)
	PTSH_Give(3, PTSH_Pick(PTSH_MAT[1][1]), 0, 1)
	Say(PTLQ_HEAD .. "Lễ vật hôm nay: " .. e .. " kinh nghiệm, 2 Linh Thú Đơn và 1 thảo dược.", 1, "Đóng/PTSH_No")
end

function PTLQ_Seed()
	if PTLQ_Open() == 0 then
		Say(PTLQ_HEAD .. "Tam Nguyệt Kỳ Sơn chỉ mở 12:00-13:59 và 19:00-22:59.", 1, "Đóng/PTSH_No")
		return
	end
	if PTLQ_DayCount(PTLQ_T_SEED) >= PTLQ_SEED_MAX then
		Say(PTLQ_HEAD .. "Hôm nay ngươi đã nhận đủ " .. PTLQ_SEED_MAX .. " hạt giống.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_Free() < 1 or PTSH_Give(6, PTLQ_I_SEED, 0, 1) < 1 then
		Say(PTLQ_HEAD .. "Hành trang đã đầy.", 1, "Đóng/PTSH_No")
		return
	end
	PTLQ_DayInc(PTLQ_T_SEED)
	local id = PTLQ_TaskId(1029, 1617)
	PTSH_Note(id, "Tam Nguyệt Kỳ Sơn", "Mang Hạt Giống Kỳ Sơn đến Kỳ Sơn, nhấp phải để trồng; 5 phút sau hái quả.", 1)
	Say(PTLQ_HEAD .. "Đây là mầm cây thần bí từ Thiên cung, chỉ hợp đất Kỳ Sơn. Hãy đến <color=yellow>Kỳ Sơn<color> nhấp phải hạt giống để trồng, 5 phút sau quay lại hái quả.", 1, "Đóng/PTSH_No")
end

function PTLQ_Chal()
	local s = PTLQ_ChalRunning()
	if s > 0 then
		local left = PTLQ_CHAL_SEC - (PTSH_Now() - s)
		Say(PTLQ_HEAD .. "Thử thách đang diễn ra: đã hạ " .. GetTask(PTLQ_T_KILL) .. "/" .. PTLQ_CHAL_KILLS .. ", còn " .. floor(left / 60) .. " phút.", 2, "Bỏ thử thách/PTLQ_ChalStop", "Đóng/PTSH_No")
		return
	end
	if PTLQ_Open() == 0 then
		Say(PTLQ_HEAD .. "Khiêu chiến cực hạn chỉ mở 12:00-13:59 và 19:00-22:59.", 1, "Đóng/PTSH_No")
		return
	end
	if PTLQ_DayCount(PTLQ_T_CDAY) >= PTLQ_CHAL_MAX then
		Say(PTLQ_HEAD .. "Hôm nay ngươi đã nhận đủ " .. PTLQ_CHAL_MAX .. " Chiến Thư.", 1, "Đóng/PTSH_No")
		return
	end
	if PTSH_Free() < 1 or PTSH_Give(6, PTLQ_I_SCROLL, 0, 1) < 1 then
		Say(PTLQ_HEAD .. "Hành trang đã đầy.", 1, "Đóng/PTSH_No")
		return
	end
	PTLQ_DayInc(PTLQ_T_CDAY)
	local id = PTLQ_TaskId(204, 1615)
	PTSH_Note(id, "Khiêu chiến cực hạn", "Ra ngoài thành, nhấp phải Chiến Thư Khiêu Chiến rồi hạ " .. PTLQ_CHAL_KILLS .. " heo thử thách trong 10 phút.", 1)
	Say(PTLQ_HEAD .. "Cầm lấy <color=yellow>Chiến Thư Khiêu Chiến<color>. Ra ngoài thành nhấp phải, " .. PTLQ_CHAL_KILLS .. " con heo thử thách sẽ xuất hiện quanh ngươi; hạ hết trong 10 phút để nhận thưởng.", 1, "Đóng/PTSH_No")
end

function PTLQ_ChalStop()
	SetTask(PTLQ_T_CHAL, 0)
	SetTask(PTLQ_T_KILL, 0)
	Msg2Player("Đã bỏ thử thách. Heo thử thách sẽ tự biến mất.")
end