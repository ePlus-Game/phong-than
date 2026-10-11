# ptfix plug-in of agent newbie2 (2026-10-03): new-era newbie chain (taskinfo 894-925, 999-1010, 3003-3005).
# Server side only. settings\item\001\magicscript.txt points the 14 mat tich / lenh items (6/1/303-309, 350-356) at
# GBK paths \script\item\<chinese>.lua that exist only as loose files, which this engine cannot open (GBK path vs
# Unicode file name), so a right click did nothing. Each path gets a small ASCII stub that includes the loose
# \script\phongthan\newbie2\nb2_scroll.lua and calls PTNB2_ScrollUse(item index, particular).
# The ext tick (script\phongthan\ext\newbie2.lua) registers the stubs with ReLoadScript on its first run.
# Independent of the other plug-ins (no shared entry); idempotent (marker "newbie2").

STUBS = [
    # (particular, taskinfo id, GBK file name)
    (303, 918, "靖人卷轴"), (304, 914, "环狗卷轴"), (305, 1009, "大踵人卷轴"), (306, 1010, "草仙婆婆"),
    (307, 915, "雪妖卷轴"), (308, 916, "雪原巨兽卷轴"), (309, 917, "收集卷轴"),
    (350, 925, "卷轴蛊雕"), (351, 919, "卷轴夏耕尸"), (352, 921, "卷轴红煞"), (353, 920, "卷轴甲壳人"),
    (354, 922, "卷轴黑煞蜂"), (355, 924, "卷轴鬼驭"), (356, 923, "卷轴旱龟"),
]


def stub(part, tid):
    return ("-- ptfix 2026-10-03 (newbie2): mat tich / lenh item 6/1/%d (taskinfo %d). The VNG script read task vars\r\n"
            "-- that nothing counted; logic now in \\script\\phongthan\\newbie2\\nb2_scroll.lua (kills: nb2_mob.lua).\r\n"
            "Include(\"\\\\script\\\\phongthan\\\\newbie2\\\\nb2_scroll.lua\")\r\n"
            "\r\n"
            "function main(nItemIdx)\r\n"
            "\treturn PTNB2_ScrollUse(nItemIdx, %d)\r\n"
            "end\r\n" % (part, tid, part)).encode("ascii")


def apply(ctx):
    if ctx["SIDE"] != "Server":
        return
    log = []
    ms = ctx["entries"].get(ctx["h"]("\\settings\\item\\001\\magicscript.txt"))
    if ms is None:
        n, ent = ctx["effective"](ctx["h"]("\\settings\\item\\001\\magicscript.txt"))
        ms = ctx["read_entry"](ctx["DATA"] + "\\" + n, ent) if ent else b""
    added = 0
    for part, tid, nm in STUBS:
        path = "\\script\\item\\%s.lua" % nm
        eid = ctx["h"](path)
        if path.encode("gbk") not in ms:
            log.append("WARN magicscript has no row for %s" % path.encode("gbk").hex())
        old = ctx["entries"].get(eid)
        if old is not None and b"newbie2" in old:
            log.append("already %08x" % eid); continue
        if old is not None:
            log.append("WARN %08x replaced an earlier ptfix entry" % eid)
        ctx["entries"][eid] = stub(part, tid)
        added += 1
    log.append("mat tich stubs: %d/%d" % (added, len(STUBS)))
    ctx["log"]["newbie2"] = log
