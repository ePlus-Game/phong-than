# -*- coding: utf-8 -*-
# lenhbainv2 (2026-10-04): "bai quai" destinations (farms.json from farm.py, arrival cells already picked there)
# + Dang Thien Ngoc (Tam San, VNG region NPC, live dump 15:16 tpl 191). Exec'd at the end of dests.py.
import json as _json
A("dangthienngoc", 1016, 1627, 3169, "Đặng Thiền Ngọc (Tam Sơn)", 70, -1, "region 1016 (VNG), live dump tpl 191")
for _k, _f in _json.load(open(__file__.replace("dests.py", "farms.json"), encoding="utf-8")).items():
    A(_k, _f["map"], _f["nx"], _f["ny"], _f["label"], _f["lv"], -1, _f["src"], "farm")
    D[_k].update(x=_f["x"], y=_f["y"], dist=_f["dist"], tier=_f["tier"], srv="farm", cluster=_f["cluster"], mlv=_f["mlv"])
