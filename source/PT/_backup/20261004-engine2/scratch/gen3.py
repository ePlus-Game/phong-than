# cankhon3 2026-10-04: patch npc_fix\1020_thai_tue.lua at byte level (TCVN3 + GBK file) from the backup.
# Buff rewards (Dai Hao, Bach Ho, Tu Vi, Thai Tue) -> ibitem effects of pt_ibitem_lib.lua instead of AddIBBuff
# (this engine casts the same-id SKILL); danh vong -> AddRepute (status page) + AddCredit (VNG wallet);
# item names Chi nhan / Moc nhan in the texts; yes_1 shows the effects in force.
# usage: python gen3.py [out]   (default: the runtime file)
import os, sys, unicodedata
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low as _low

SRC = r"E:\VL\Phong than\PT\_backup\20261004-cankhon3\1020_thai_tue.lua"
OUT = sys.argv[1] if len(sys.argv) > 1 else r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan\npc_fix\1020_thai_tue.lua"

def t(s):
    o = bytearray()
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128: o.append(ord(ch))
        elif ch in _low: o.append(_low[ch])
        elif ch.lower() in _low: o.append(_low[ch.lower()])
        else: raise ValueError(ch)
    return bytes(o)

def L(s):
    return t(s).replace(b"\n", b"\r\n")

b = open(SRC, "rb").read()
assert b.count(b"\r\n") == b.count(b"\n")

def rep(old, new, cnt=1):
    global b
    assert b.count(old) == cnt, (old, b.count(old))
    b = b.replace(old, new)

def repline(prefix, newline):
    """replace the whole line that starts with prefix (exactly one)"""
    global b
    lines = b.split(b"\r\n")
    hit = [i for i, l in enumerate(lines) if l.startswith(prefix)]
    assert len(hit) == 1, (prefix, hit)
    lines[hit[0]] = t(newline)
    b = b"\r\n".join(lines)

# 1. header + Include of the ibitem effect library
INC = b"Include(\"\\\\script\\\\phongthan\\\\lib\\\\pt_compat.lua\")\r\n"
rep(INC, L("-- 2026-10-04 cankhon3: the buff rewards use the ibitem effects of pt_ibitem_lib.lua (AddIBBuff cast the\n"
           "-- same-id skill: x2 experience became a marker without end, x1.5 became run speed); danh vong goes to\n"
           "-- the status page too (AddRepute). Doc: docs\\features\\can-khon-luan-quay-cpp-phong-than-20261002.md\n")
    + INC + b"Include(\"\\\\script\\\\phongthan\\\\ibitem\\\\pt_ibitem_lib.lua\")\r\n")

# 2. item names as the client shows them (ibitem 8/135 8/178 = Chi nhan, 8/174 8/179 = Moc nhan)
repline(b"PT_CKL_TXT_HINH = ", 'PT_CKL_TXT_HINH = "Chỉ nhân (Hình thế thân)"')
repline(b"PT_CKL_TXT_CAY = ", 'PT_CKL_TXT_CAY = "Mộc nhân (Cây thế thân)"')
repline(b"PT_CKL_TXT_HOW1 = ", 'PT_CKL_TXT_HOW1 = "Lượt đầu tiên mỗi ngày <color=green>miễn phí<color>. Lượt 2-3 cần 1 <color=green>Chỉ nhân<color> (Hình thế thân), lượt 4-6 cần 1 <color=green>Mộc nhân<color> (Cây thế thân), mỗi ngày tối đa 6 lượt."')
repline(b"PT_CKL_TXT_HOW2 = ", 'PT_CKL_TXT_HOW2 = "Chỉ nhân và Mộc nhân bán ở <color=yellow>Kỳ Trân Các<color> (nhấn F2), giá 1 xu mỗi cái; loại 9-10 xu (hiệu quả cao hơn) cũng dùng được. Không có vật phẩm thì trả <color=yellow>5 vạn lượng<color> (lượt 2-3) hoặc <color=yellow>10 vạn lượng<color> (lượt 4-6) để ta giúp xoay."')

# 3. helpers after the menu text
ANCHOR = [l for l in b.split(b"\r\n") if l.startswith(b"PT_CKL_TXT_MENU_HOW = ")]
assert len(ANCHOR) == 1
HELP = L("""

-- 2026-10-04 cankhon3 ------------------------------------------------------------------
-- VNG AddIBBuff(id) = the effect of ibitem 8/id: 12 Dao Linh tan (life regen +10, 1 h), 13 Dao To tan
-- (mana regen +10, 1 h), 175 Nhan doi diem kinh nghiem (+100 %, 1 h), 176 Nhan 1.5 diem kinh nghiem
-- (+50 %, 2 h). The engine (ScriptFuns.cpp ApplyNativeIBBuffState) casts the SKILL with that id instead:
-- 12 passive skill, 13 attack skill, 175 Thai Nguyen Dan marker that never ends, 176 Thai Ngu Dan (run
-- speed). Rewards now use pt_ibitem_lib.lua (experience: tasks 1906-1908, regen: generic slots 1921-1938;
-- servertimer PTAdm_IbTick re-applies after a stat recompute and expires them).
PT_CKL_GEN_LIFE = "Dao Linh t\\184n"
PT_CKL_GEN_MANA = "Dao T\\244 t\\184n"
PT_CKL_OLDIB = { 12, 13, 175, 176 }
PT_CKL_TXT_EXP = "Hiệu quả kinh nghiệm +"
PT_CKL_TXT_LIFE = "Hồi sinh lực +10"
PT_CKL_TXT_MANA = "Hồi nội lực +10"
PT_CKL_TXT_LEFT = ", thời hạn còn "
PT_CKL_TXT_NONE = "Hiện ngươi chưa có hiệu quả nào của Càn Khôn Luân."
PT_CKL_TXT_HAVE = "Hiệu quả đang có: "
PT_CKL_TXT_REP1 = "Bạn nhận được "
PT_CKL_TXT_REP2 = " điểm danh vọng, hiện có "
PT_CKL_TXT_REP3 = "Danh vọng hiện có: "

-- the ibitem effect library (Included at the top; loaded again at call time if that failed)
function PT_CKL_Lib()
	if not PTIB_Refresh and Include then Include("\\\\script\\\\phongthan\\\\ibitem\\\\pt_ibitem_lib.lua") end
	if PTIB_Refresh and PTIB_GrantGen and PTIB_GenId and PTIB_TimeText then return 1 end
	return nil
end

-- wrong IB states left by the old rewards (removed on the next spin of this player)
function PT_CKL_PurgeOldIB()
	if not HaveIBBuff or not RemoveIBBuff then return end
	local k = 1
	while PT_CKL_OLDIB[k] do
		if HaveIBBuff(PT_CKL_OLDIB[k]) == 1 then RemoveIBBuff(PT_CKL_OLDIB[k]) end
		k = k + 1
	end
end

-- experience buff in the single ibitem slot; never weaker or shorter than promised, never takes
-- away a running buff: same or stronger buff running -> + secs; weaker running -> new % until
-- max(old end, now + secs). Returns the seconds left.
function PT_CKL_ExpBuff(secs, pct)
	local now = SystemTime()
	local e = GetTask(PTIB_T_EXP_END)
	if e <= now then
		SetTask(PTIB_T_EXP_END, now + secs)
		SetTask(PTIB_T_EXP_PCT, pct)
		SetTask(PTIB_T_EXP_SKILL, 0)
	elseif GetTask(PTIB_T_EXP_PCT) >= pct then
		SetTask(PTIB_T_EXP_END, e + secs)
	else
		SetTask(PTIB_T_EXP_PCT, pct)
		if e < now + secs then SetTask(PTIB_T_EXP_END, now + secs) end
	end
	PTIB_Refresh()
	return GetTask(PTIB_T_EXP_END) - now
end

-- seconds left of a generic ibitem buff (by ibitem name), 0 when not running
function PT_CKL_GenLeft(name)
	local gid = PTIB_GenId(name)
	if not gid then return 0 end
	local now = SystemTime()
	local k = 0
	while k < PTIB_GEN_SLOTS do
		local e = GetTask(PTIB_T_GEN + 2 * k + 1)
		if GetTask(PTIB_T_GEN + 2 * k) == gid and e > now then return e - now end
		k = k + 1
	end
	return 0
end

-- buff sectors: 1 Dai Hao, 2 Bach Ho, 5 Tu Vi, 9 Thai Tue. Returns 1 when the effect is on.
function PT_CKL_Reward(k)
	if not PT_CKL_Lib() then PT_CKL_Trace("reward k=" .. k .. " no pt_ibitem_lib") return 0 end
	local left = 0
	local txt = ""
	if k == 1 or k == 2 then
		local name = PT_CKL_GEN_LIFE
		txt = PT_CKL_TXT_LIFE
		if k == 2 then name = PT_CKL_GEN_MANA txt = PT_CKL_TXT_MANA end
		local gid = PTIB_GenId(name)
		if gid then left = PTIB_GrantGen(gid, 3600) end
	elseif k == 5 then
		left = PT_CKL_ExpBuff(3600, 100)
		txt = PT_CKL_TXT_EXP .. GetTask(PTIB_T_EXP_PCT) .. "%"
	elseif k == 9 then
		left = PT_CKL_ExpBuff(7200, 50)
		txt = PT_CKL_TXT_EXP .. GetTask(PTIB_T_EXP_PCT) .. "%"
	end
	PT_CKL_Trace("reward k=" .. k .. " left=" .. left)
	if left <= 0 then return 0 end
	Msg2Player(txt .. PT_CKL_TXT_LEFT .. PTIB_TimeText(left))
	return 1
end

-- danh vong: the status page shows Repute (task 210); VNG AddCredit is kept (Xich Tung Tu wallet)
function PT_CKL_Repute(n)
	if AddRepute then AddRepute(n) end
	if AddCredit then AddCredit(n) end
	local r = 0
	if GetRepute then r = GetRepute() or 0 end
	Msg2Player(PT_CKL_TXT_REP1 .. n .. PT_CKL_TXT_REP2 .. r .. ".")
end

function PT_CKL_Effects()
	local s = ""
	if not PT_CKL_Lib() then return "" end
	local now = SystemTime()
	local e = GetTask(PTIB_T_EXP_END)
	if e > now then s = s .. PT_CKL_TXT_EXP .. GetTask(PTIB_T_EXP_PCT) .. "%" .. PT_CKL_TXT_LEFT .. PTIB_TimeText(e - now) .. " " end
	local l = PT_CKL_GenLeft(PT_CKL_GEN_LIFE)
	if l > 0 then s = s .. PT_CKL_TXT_LIFE .. PT_CKL_TXT_LEFT .. PTIB_TimeText(l) .. " " end
	l = PT_CKL_GenLeft(PT_CKL_GEN_MANA)
	if l > 0 then s = s .. PT_CKL_TXT_MANA .. PT_CKL_TXT_LEFT .. PTIB_TimeText(l) .. " " end
	if s == "" then s = PT_CKL_TXT_NONE else s = PT_CKL_TXT_HAVE .. s end
	local r = 0
	if GetRepute then r = GetRepute() or 0 end
	return s .. " " .. PT_CKL_TXT_REP3 .. r .. "."
end""")
b = b.replace(ANCHOR[0] + b"\r\n", ANCHOR[0] + HELP + b"\r\n", 1)

# 4. yes_1: third page with the effects in force
i = b.index(b"function yes_1()")
j = b.index(b"\")\r\nend;", i)
b = b[:j] + b"\", PT_CKL_Effects())\r\nend;" + b[j + len(b"\")\r\nend;"):]
rep(b"function yes_1()\r\n\tTalk(2,\"no\",", b"function yes_1()\r\n\tTalk(3,\"no\",")

# 5. Finished(): purge old IB states, buff sectors via PT_CKL_Reward, danh vong via PT_CKL_Repute
rep(b"\tPT_CKL_Trace(\"finished k=\" .. GetTask(72))\r\n",
    b"\tPT_CKL_Trace(\"finished k=\" .. GetTask(72))\r\n\tPT_CKL_PurgeOldIB()\r\n")
for k, bid in ((1, 12), (2, 13), (5, 175), (9, 176)):
    old = (b"\t\tif(HaveIBBuff(%d)==1)then\r\n\t\t\tRemoveIBBuff(%d)\r\n\t\tend\r\n\t\tlocal i=AddIBBuff(%d)\r\n" % (bid, bid, bid))
    rep(old, b"\t\tlocal i=PT_CKL_Reward(%d)\r\n" % k)
rep(b"\t\tAddCredit(15)\r\n", b"\t\tPT_CKL_Repute(15)\r\n")
rep(b"\t\tAddCredit(10)\r\n", b"\t\tPT_CKL_Repute(10)\r\n")

assert b"AddIBBuff(" not in b.split(b"function main()")[1]
assert b.count(b"\r\n") == b.count(b"\n")
open(OUT, "wb").write(b)
print("wrote", OUT, len(b))
