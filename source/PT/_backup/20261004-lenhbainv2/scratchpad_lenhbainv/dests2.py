# -*- coding: utf-8 -*-
# lenhbainv: destinations used only by "Nhiem vu dang lam" (exec'd at the end of dests.py; live positions 15:16)
A("nhamdaica", 1020, 1364, 3128, "Nhậm Đại Ca", 27, -1, "npc_regions 1020_12")
A("tt1002", 1002, 1745, 3154, "Tạp Thương Sùng Thành", 10, -1, "ext\\daily2.lua")
A("tt1003", 1003, 1608, 3209, "Tạp Thương Ngọc Hư", 10, -1, "ext\\daily2.lua")
A("tt1004", 1004, 1560, 3332, "Tạp Thương Xi Vưu", 10, -1, "ext\\daily2.lua")
A("tt1021", 1021, 1776, 3169, "Tạp Thương Triều Ca", 10, -1, "ext\\daily2.lua")
A("mob_chucngu", 1037, 1794, 3306, "Chúc Ngư (Thủy Vực)", 45, -1, "PTADM_MOB_SPAWN", "mob")
A("mob_thengu", 1037, 1632, 2832, "Thể Ngư (Thủy Vực)", 45, -1, "PTADM_MOB_SPAWN", "mob")
A("mob_thongu", 1037, 1776, 2864, "Thố Ngư (Thủy Vực)", 45, -1, "PTADM_MOB_SPAWN", "mob")
A("mob_duoclau", 1010, 1090, 3274, "Dược Lâu Tử (Thủ Dương sơn)", 55, -1, "PTADM_MOB_SPAWN", "mob")
A("mob_hoatru", 1022, 1463, 3073, "Hoa Trư (Hoang Mạc)", 30, -1, "PTADM_MOB_SPAWN", "mob")
# questfix3 2026-10-04: Khao nghiem (task 15) and Cuu Te (task 34) targets
A("mob_yemhoa", 1010, 1300, 3080, "Yểm Hỏa (Thủ Dương Sơn)", 7, -1, "spawn_1010.lua tid 8 (VNG [168,192])", "mob")
A("mob_docluc", 1013, 1892, 3064, "Độc Lục quái (Cự Lộc)", 12, -1, "spawn_1013.lua PT_SPAWN_SPECIAL tid 106", "mob")
A("toclinh1013", 1013, 1916, 3080, "Thủ lĩnh tộc nhân (Cự Lộc)", 12, -1, "ext\\questfix3.lua PTQ3_NPCS (spawned after the 15:16 dump)")
A("tower1006", 1006, 1736, 3152, "Phong Ấn Tháp Bắc Hải", 59, -1, "servertimer PTADM_NPC_SPAWN")
A("tower1007", 1007, 1608, 3344, "Phong Ấn Tháp Yến Sơn", 59, -1, "servertimer PTADM_NPC_SPAWN")
A("tower1012", 1012, 1568, 3168, "Phong Ấn Tháp Miêu Cương", 59, -1, "servertimer PTADM_NPC_SPAWN")
A("tower1013", 1013, 1736, 3152, "Phong Ấn Tháp Cự Lộc", 59, -1, "servertimer PTADM_NPC_SPAWN")
A("tower1010", 1010, 1088, 3168, "Phong Ấn Tháp Thủ Dương", 59, -1, "servertimer PTADM_NPC_SPAWN")
A("tower1009", 1009, 1656, 3248, "Phong Ấn Tháp Tây Côn Lôn", 59, -1, "servertimer PTADM_NPC_SPAWN")
A("tm1073_linhxa", 1073, 1776, 3600, "Linh Xà Thụ", 85, -1, "ext\\tienma.lua")
A("tm1075_laban", 1075, 1836, 3440, "La Bàn (vòng La Bàn)", 85, -1, "ext\\tienma45.lua")
A("tm1075_phaptru", 1075, 2023, 3196, "Pháp trụ Bắc", 85, -1, "ext\\tienma45.lua")
A("tm1076_king", 1076, 1712, 3648, "Vùng Ninh Vương, Lang Vương (Thánh Địa)", 85, -1, "tienma45\\tm45_lib.lua", "mob")
A("dd_thieunu", 1073, 1628, 3864, "Thiếu Nữ Di Tộc", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_bachdi", 1073, 1636, 3858, "Bạch Di", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_yenbaich", 1073, 1648, 3850, "Yển Bá Ích", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_yenthucdi", 1073, 1655, 3850, "Yển Thúc Di", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_lieunhan", 1073, 1642, 3842, "Liễu Nhân", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_yenphong", 1073, 1658, 3860, "Yển Phong", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_yenlong", 1073, 1640, 3870, "Yển Long", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_yenho", 1073, 1648, 3870, "Yển Hổ", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")
A("dd_yenlang", 1073, 1656, 3870, "Yển Lang", 70, -1, "ext\\sudo_dongdi.lua PTSD_NPCS")

# Giang Son Y Cuu kill spots (vienco\gs_data.lua), personal spawns around these cells
from chains import GS as _GS
for _k, (_m, _x, _y) in _GS.items():
    A("gs%d" % _k, _m, _x, _y, "Giang Sơn bước %d - bãi quái" % _k, 30, -1, "vienco\\gs_data.lua", "mob")

# field doctors (Tham Quan 314, trials 899-902): every live Dai Phu / doctor on maps 1005-1051
import os as _os
_seen = set()
for _l in open(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "npcs_live.txt"), "rb").read().split(b"\n"):
    _c = _l.rstrip(b"\r").split(b"\t")
    if len(_c) < 7:
        continue
    _t, _m, _x, _y = int(_c[1]), int(_c[2]), int(_c[3]), int(_c[4])
    if _t in (149, 150) and 1005 <= _m <= 1051 and _m not in _seen:
        _seen.add(_m)
        A("dp%d" % _m, _m, _x, _y, "Đại Phu dã ngoại", 20, -1, "live dump (tpl %d)" % _t)
