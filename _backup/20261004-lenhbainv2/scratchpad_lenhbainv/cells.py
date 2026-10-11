# lenhbainv: pick a walkable arrival cell 1-3 cells from an NPC.
#  client grid (Region_C obstacle == 0, no client trap), server Region_S (obst 0, or region without Region_S),
#  the cell AND its 8 neighbours walkable, no trap, not on another live NPC (>= 1 cell from every live NPC),
#  inside a large connected walkable area (>= 2000 cells, i.e. not a closed pocket).
# Grids: built with %TEMP%\ptspawn\grid.py build() and cached in scratchpad\lenhbainv\grid\ (not in %TEMP%).
import os, sys, pickle, re, collections, importlib.util
H = os.path.dirname(os.path.abspath(__file__))
S = os.path.dirname(H)
T = os.path.join(os.environ["TEMP"], "ptspawn")
sys.path.insert(0, os.path.join(S, "vantien", "impl"))
from mapgrid import Grid
GD = os.path.join(H, "grid")
os.makedirs(GD, exist_ok=True)
R = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server"
ws = open(os.path.join(R, "settings", "WorldSet.ini"), "rb").read()
WORLDS = {int(m.group(1)): m.group(2).decode("gbk") for m in re.finditer(rb"(?m)^(\d{4})=(.*?)\r?$", ws)}
_grid_mod = None


def client_grid(mid):
    global _grid_mod
    for p in (os.path.join(T, "grid_%d.pkl" % mid), os.path.join(GD, "grid_%d.pkl" % mid)):
        if os.path.exists(p):
            return pickle.load(open(p, "rb"))
    if _grid_mod is None:
        spec = importlib.util.spec_from_file_location("ptgrid", os.path.join(T, "grid.py"))
        _grid_mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(_grid_mod)
    g = _grid_mod.build(mid)
    pickle.dump(g, open(os.path.join(GD, "grid_%d.pkl" % mid), "wb"))
    return g


_cache = {}


def load(mid):
    if mid in _cache:
        return _cache[mid]
    g = client_grid(mid)
    walk = {c for c, v in g["cobs"].items() if v == 0 and c not in g["sobs"]}
    try:
        sg = Grid(WORLDS[mid])
    except Exception:
        sg = None
    _cache[mid] = (g, walk, sg)
    return _cache[mid]


def comp_size(walk, s, cap=4000):
    seen = {s}
    q = collections.deque([s])
    while q and len(seen) < cap:
        x, y = q.popleft()
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                p = (x + dx, y + dy)
                if p not in seen and p in walk:
                    seen.add(p)
                    q.append(p)
    return len(seen)


def pick1(mid, nx, ny, others=(), rmin=1, rmax=3, prefer=2, mincomp=2000):
    """returns (x, y, dist, note) or None"""
    g, walk, sg = load(mid)

    def srv_ok(p):
        if sg is None:
            return True
        v = sg.obst.get(p)
        return v == 0 or ((p[0] // 16, p[1] // 32) not in sg.regions)

    def trap(p):
        return p in g["traps"] or (sg is not None and p in sg.trap)

    occ = set(others)
    cands = []
    for dx in range(-rmax, rmax + 1):
        for dy in range(-rmax, rmax + 1):
            d = max(abs(dx), abs(dy))
            if d < rmin:
                continue
            p = (nx + dx, ny + dy)
            if trap(p):
                continue
            ok = all(((p[0] + i, p[1] + j) in walk) and srv_ok((p[0] + i, p[1] + j)) and not trap((p[0] + i, p[1] + j))
                     for i in (-1, 0, 1) for j in (-1, 0, 1))
            if not ok:
                continue
            if any(max(abs(p[0] - o[0]), abs(p[1] - o[1])) < 1 for o in occ):
                continue
            # prefer distance 2, then below the NPC (positive y = towards the camera), then straight lines
            cands.append((abs(d - prefer), 0 if dy > 0 else 1, abs(dx) + abs(dy), p, d))
    cands.sort()
    for c in cands:
        if comp_size(walk, c[3]) >= mincomp:
            srv = "srv" if (sg is not None and (c[3][0] // 16, c[3][1] // 32) in sg.regions) else "nosrv"
            return c[3][0], c[3][1], c[4], srv
    return None


def pick(mid, nx, ny, others=(), rmin=1, rmax=3, prefer=2):
    """tiers: near + big area, near + medium area, up to 6 cells + big area, near + any 3x3 area"""
    for (rm, mc, tier) in ((rmax, 200, 1), (rmax, 40, 2), (max(rmax, 6), 200, 3), (rmax, 9, 4)):
        r = pick1(mid, nx, ny, others, rmin, rm, prefer, mc)
        if r:
            return r + (tier,)
    return None


if __name__ == "__main__":
    mid, x, y = map(int, sys.argv[1:4])
    print(pick(mid, x, y))
