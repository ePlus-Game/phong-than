# lenhbainv: verify every destination against the live NPC dump and pick its arrival cell -> dests_final.json
import os, sys, json, collections
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
from dests import D
import cells

live = collections.defaultdict(list)
for l in open(os.path.join(H, "npcs_live.txt"), "rb").read().split(b"\n"):
    c = l.rstrip(b"\r").split(b"\t")
    if len(c) < 7:
        continue
    live[int(c[2])].append((int(c[3]), int(c[4]), int(c[1]), int(c[5])))

out = {}
bad = 0
for k, d in D.items():
    m, nx, ny = d["map"], d["nx"], d["ny"]
    others = [(x, y) for (x, y, t, lv) in live[m]]
    if d["kind"] == "npc":
        hit = [p for p in live[m] if abs(p[0] - nx) <= 1 and abs(p[1] - ny) <= 1]
        if not hit:
            print("NOT LIVE", k, m, nx, ny)
            bad += 1
        r = cells.pick(m, nx, ny, others)
    else:
        r = cells.pick(m, nx, ny, others, rmin=3, rmax=7, prefer=4)
    if r is None:
        print("NO CELL", k, m, nx, ny)
        bad += 1
        continue
    x, y, dist, srv, tier = r
    out[k] = dict(d, x=x, y=y, dist=dist, srv=srv, tier=tier)
json.dump(out, open(os.path.join(H, "dests_final.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=0)
print(len(out), "picked,", bad, "problems")
