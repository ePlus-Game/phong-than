# Phong Than 2026-10-02 (agent bikip): profession secret books ("bi kip").
# Generates
#   - bikip_data.json (read by ..\ptfix\extra_bikip.py): magicscript rows, goods/buysell plan, teacher tail
#   - Server\script\phongthan\lib\pt_bikip.lua   (shared logic: learn, craft "dong sach", convert, shops)
#   - Server\script\phongthan\item\bikip_<skill>.lua  (one per book: right click = learn)
#   - Server\script\phongthan\item\bikip_sach7.lua    (genre-7 VNG book, for a future C++ right-click hook)
# All Lua files are ASCII; Vietnamese text is TCVN3 written as decimal escapes.
import os, sys, json, re, glob, unicodedata
sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
T = os.path.join(HERE, "..", "tutuong")
sys.path.insert(0, T)
from tv import show
from exist import h
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low

SRV = r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server"
OUT_LIB = os.path.join(SRV, r"script\phongthan\lib\pt_bikip.lua")
OUT_ITEM = os.path.join(SRV, r"script\phongthan\item")
KEY_BASE = 62000            # magicscript particular = 62000 + skill id


def tcvn(s):
    o = bytearray()
    for ch in unicodedata.normalize("NFC", s):
        if ord(ch) < 128: o.append(ord(ch))
        elif ch in low: o.append(low[ch])
        elif ch.lower() in low: o.append(low[ch.lower()])
        else: raise ValueError(ch)
    return bytes(o)


def L(s):
    return '"' + "".join("\\%d" % c if (c < 32 or c > 126 or c in (34, 92)) else chr(c) for c in tcvn(s)) + '"'


def eff(path):
    fs = glob.glob(os.path.join(T, "eff", "*__%08x.txt" % h(path.encode("gbk"))))
    order = ["ptfix", "vng00", "serverlist", "settings"]
    fs.sort(key=lambda f: order.index(os.path.basename(f).split("__")[0]) if os.path.basename(f).split("__")[0] in order else 9)
    return open(fs[0], "rb").read()


def title(s):
    s = s.strip().lstrip("#").strip()
    return " ".join(w[:1].upper() + w[1:] for w in s.split())


# ---------------------------------------------------------------- books (skillbook.txt, genre 7)
PROF_NAME = {0: "Giáp Sĩ", 1: "Đạo Sĩ", 2: "Dị Nhân", -1: "mọi phái"}
sb_raw = eff("\\settings\\item\\001\\skillbook.txt")
books = {}
for l in sb_raw.split(b"\n")[1:]:
    c = l.rstrip(b"\r").split(b"\t")
    if len(c) < 12 or c[1] != b"7": continue
    det, sk = int(c[2]), int(c[3])
    desc = show(c[8]).lower()
    if "đạo sĩ" in desc: prof = 1
    elif "giáp sĩ" in desc: prof = 0
    elif "dị nhân" in desc: prof = 2
    elif "kỹ năng sống" in desc: prof = -1
    else: continue
    m = re.search(r"cấp (\d+)$", desc.strip())
    if not m and prof != -1: continue       # rebirth "Lv.60" rows: own books 61011..61019
    req = int(m.group(1)) if m else 1
    if not (3 <= sk <= 51 or 450 <= sk <= 458 or sk in (62, 128)): continue
    books[sk] = dict(skill=sk, detail=det, prof=prof, req=req, name=title(show(c[0])),
                     spr=b"\\" + c[4].lstrip(b"\\"), vng_price=int(c[9] or 0))
print("books", len(books))

# ---------------------------------------------------------------- VNG shops + "dong sach" recipes
rec = json.load(open(os.path.join(HERE, "recipes_vng.json"), encoding="utf-8"))
RECIPES = {}
for r in rec:
    sk = r["give"][1]
    rate = r["rate"] or [1, 1]
    RECIPES[sk] = dict(page=r["page"], npage=r["npage"], mat=r["mat"], nmat=r["nmat"], ok=rate[0], of=rate[1])
SHOP_TIER = {27, 28, 29, 30, 31, 3, 4, 5, 6, 7, 8, 9, 10, 11, 43, 44, 45, 450, 451, 452}   # VNG Sale 8/9/10/14/19
for sk, b in books.items():
    if sk in (62, 128): b["price"] = 2000
    elif sk in SHOP_TIER: b["price"] = max(b["vng_price"], 10)
    else: b["price"] = max(b["vng_price"], b["req"] * 2000)
    b["crafted"] = 1 if sk in RECIPES else 0
missing = [sk for sk in books if sk not in SHOP_TIER and sk not in RECIPES]
print("not obtainable in VNG:", missing)

# consolation (VNG "suyt nua tau hoa nhap ma"), by page colour
def iname(g, d, p):
    if g == 5: return "Hồi Thành Phù"
    if g == 3: tbl, key = "material", lambda c: c[2] == str(d).encode()
    elif g == 8: tbl, key = "ibitem", lambda c: c[2] == str(d).encode() and c[3] == str(p).encode()
    elif g == 6: tbl, key = "magicscript", lambda c: c[3] == str(p).encode()
    for l in eff("\\settings\\item\\001\\%s.txt" % tbl).split(b"\n")[1:]:
        c = l.rstrip(b"\r").split(b"\t")
        if len(c) > 4 and key(c):
            return title(re.sub(r"<c(=[a-z]+)?>", "", show(c[0])))
    return "vật phẩm"
CONS = {139: [[5, 0, 0, 1], [6, 1, 12, 1], [3, 62, 0, 1]],
        140: [[8, 57, 2, 3], [8, 104, 2, 3], [8, 85, 2, 3], [3, 63, 0, 1]],
        141: [[8, 35, 2, 1], [8, 48, 2, 1], [3, 64, 0, 1]],
        142: [[8, 159, 2, 1], [3, 65, 0, 1]]}
for k, v in CONS.items():
    for e in v: e.append(iname(e[0], e[1], e[2]))
print({k: [e[4] for e in v] for k, v in CONS.items()})
PAGE = {139: "Bạch Không Thư", 140: "Lam Không Thư", 141: "Hồng Không Thư", 142: "Hoàng Không Thư"}
MAT = {77: "Mảnh Hồng Thủy Tinh", 28: "Hồng Thủy Tinh", 79: "Hồng Bảo Thạch"}

# ---------------------------------------------------------------- lib
def lua_book_table():
    out = []
    for sk in sorted(books):
        b = books[sk]
        out.append("PTBK_BOOK[%d] = { %d, %d, %s, %d }" % (sk, b["prof"], b["req"], L(b["name"]), b["detail"]))
    return "\n".join(out)

def lua_recipe_table():
    out = []
    for sk in sorted(RECIPES):
        r = RECIPES[sk]
        out.append("PTBK_RECIPE[%d] = { %d, %d, %d, %d, %d, %d }" % (sk, r["page"], r["npage"], r["mat"], r["nmat"], r["ok"], r["of"]))
    return "\n".join(out)

def lua_menu():
    out = []
    for prof in (0, 1, 2):
        ks = [sk for sk in rec_order if books[sk]["prof"] in (prof, -1)]
        out.append("PTBK_CRAFT[%d] = { %s }" % (prof, ", ".join(str(k) for k in ks)))
    return "\n".join(out)
rec_order = [r["give"][1] for r in rec]          # VNG menu order (jiashi, daoshi, yiren, then the 2 life books)
rec_order = [k for k in rec_order if k not in (62, 128)] + [62, 128]

def lua_cons():
    out = []
    for page, v in sorted(CONS.items()):
        out.append("PTBK_CONS[%d] = { %s }" % (page, ", ".join("{ %d, %d, %d, %d, %s }" % (e[0], e[1], e[2], e[3], L(e[4])) for e in v)))
    return "\n".join(out)

def lua_names(d, var):
    return "\n".join("%s[%d] = %s" % (var, k, L(v)) for k, v in sorted(d.items()))

callbacks = "\n".join("function PTBK_C%d() PTBK_CraftDo(%d) end" % (sk, sk) for sk in sorted(RECIPES))

LIB = r'''-- Phong Than 2026-10-02 (agent bikip): profession secret books ("bi kip"), shared logic.
-- Generated by scratchpad\bikip\gen_bikip.py, do not edit by hand.
--  * VNG skill books are item genre 7 (settings\item\001\skillbook.txt). The rebuilt engine never runs
--    a script for genre 7 (KItemList::ExecuteScript) and KBuySell cannot generate them, so they could be
--    neither bought nor used. Each book now also exists as a magicscript item 6/1/(62000+skill) with
--    its own script \script\phongthan\item\bikip_<skill>.lua (right click = learn the skill).
--  * Vo su Tay Ky / Trieu Ca: "Dong sach" (VNG: bind Khong Thu pages + crystals into a book, may fail),
--    profession book shops, and conversion of old genre-7 books into bi kip.
-- Lua 4: no local function, no true/false. File stays ASCII (TCVN3 escapes).

PTBK_KEY_BASE = 62000
PTBK_BOOK = {}      -- [skill] = { profession (-1 = any), required level, name, genre-7 detail }
PTBK_RECIPE = {}    -- [skill] = { page detail (8/x/2), pages, material (3/x), materials, success, out of }
PTBK_CONS = {}      -- [page] = { { genre, detail, particular, count, name }, ... } failure gifts (VNG)
PTBK_CRAFT = {}     -- [profession] = menu order of craftable books
PTBK_PAGE = {}
PTBK_MAT = {}
PTBK_PROF = { [0] = @PROF0@, [1] = @PROF1@, [2] = @PROF2@ }
if PTBK_SHOP_SALE == nil then PTBK_SHOP_SALE = {} end

@BOOKS@

@RECIPES@

@CONS@

@MENU@

@PAGES@

@MATS@

function no_ptbk()
end

function PTBK_Show(msg)
	Msg2Player(msg)
	Say(msg, 1, @CLOSE@)
end

function PTBK_Log(tag)
	if openfile == nil or date == nil then return end
	local fh = openfile("admin_bridge\\token.log", "a")
	if fh then
		write(fh, date("%Y-%m-%d %H:%M:%S") .. "\tbikip\t" .. tag .. "\n")
		closefile(fh)
	end
end

function PTBK_ProfName(p)
	if p == nil or p < 0 then return @ANYPROF@ end
	return PTBK_PROF[p] or ""
end

-- learn the skill of a book; the item is removed only when the skill really was learned
function PTBK_UseBook(nItemIdx, sk)
	local b = PTBK_BOOK[sk]
	if b == nil then
		PTBK_Show(@M_UNKNOWN@)
		return 0
	end
	PTBK_Log("use skill=" .. sk .. " prof=" .. GetProfession() .. " lv=" .. GetLevel() .. " have=" .. (HaveMagic(sk) or -9))
	if b[1] >= 0 and GetProfession() ~= b[1] then
		PTBK_Show(@M_PROF1@ .. b[3] .. @M_PROF2@ .. PTBK_ProfName(b[1]) .. ".")
		return 0
	end
	if GetLevel() < b[2] then
		PTBK_Show(@M_LV1@ .. b[2] .. @M_LV2@ .. b[3] .. ".")
		return 0
	end
	local lv = HaveMagic(sk)
	if lv ~= nil and lv > 0 then
		PTBK_Show(@M_HAVE1@ .. b[3] .. @M_HAVE2@ .. lv .. @M_HAVE3@)
		return 0
	end
	if lv ~= nil and lv == 0 then SetSkillLevel(sk, 1) end
	AddMagic(sk, 1)
	local nl = GetMagicLevel(sk)
	if nl == nil or nl <= 0 then
		PTBK_Show(@M_FAIL@)
		return 0
	end
	RemoveItem(nItemIdx, 1, 0)
	PTBK_Log("learned skill=" .. sk .. " level=" .. nl)
	PTBK_Show(@M_OK1@ .. b[3] .. @M_OK2@)
	return 0
end

-- VNG genre-7 book (skillbook.txt): the particular is the skill id
function PTBK_UseSkillBook7(nItemIdx)
	local sk = GetItemPartByID(nItemIdx)
	if sk == nil or PTBK_BOOK[sk] == nil then
		PTBK_Show(@M_UNKNOWN@)
		return 0
	end
	return PTBK_UseBook(nItemIdx, sk)
end

-- ---------------------------------------------------------------- Vo su: shops
function PTBK_ShopMenu()
	local p = GetProfession()
	local s = PTBK_SHOP_SALE[p]
	if s == nil or s <= 0 then
		Talk(1, "no_ptbk", @M_NOSHOP@)
		return
	end
	CloseDialog()
	Sale(s)
end

-- ---------------------------------------------------------------- Vo su: "dong sach" (VNG crafting)
function PTBK_CraftMenu()
	local p = GetProfession()
	local l = PTBK_CRAFT[p]
	if l == nil then
		Talk(1, "no_ptbk", @M_NOCRAFT@)
		return
	end
	local opts = {}
	local i = 1
	while l[i] do
		opts[i] = PTBK_BOOK[l[i]][3] .. "/PTBK_CraftPick"
		i = i + 1
	end
	opts[i] = @M_EXIT@
	Say(@M_CRAFTHEAD@, getn(opts), opts)
end

function PTBK_RecipeText(sk)
	local r = PTBK_RECIPE[sk]
	local s = r[2] .. " " .. PTBK_PAGE[r[1]]
	if r[4] > 0 then s = s .. ", " .. r[4] .. " " .. PTBK_MAT[r[3]] end
	return s
end

function PTBK_CraftPick(sel)
	local l = PTBK_CRAFT[GetProfession()]
	if l == nil or sel == nil then return end
	local sk = l[sel + 1]
	if sk == nil or PTBK_RECIPE[sk] == nil then return end
	local r = PTBK_RECIPE[sk]
	local pct = floor(r[5] * 100 / r[6])
	Say(@M_PICK1@ .. PTBK_BOOK[sk][3] .. @M_PICK2@ .. PTBK_RecipeText(sk) .. @M_PICK3@ .. r[5] .. "/" .. r[6] .. @M_PICK4@, 2,
		@M_DOIT@ .. "/PTBK_C" .. sk, @M_LATER@)
end

function PTBK_Give(g, d, p, n)
	local k = 0
	local i = 1
	while i <= n do
		if AddNormalItem(g, d, p, 1, 0, 0) > 0 then k = k + 1 end
		i = i + 1
	end
	return k
end

function PTBK_RefundPages(page, n)
	local i = 1
	while i <= n do
		AddNormalItem(8, page, 2, 0, 0, 0)
		i = i + 1
	end
end

function PTBK_RefundMats(mat, n)
	local i = 1
	while i <= n do
		AddNormalItem(3, mat, 0, 1, 0, 0)
		i = i + 1
	end
end

-- Takes the materials (bag only, counted), then the pages (counted), then rolls the VNG rate.
-- Everything taken is given back when something is short. 3 free cells are required first, so the
-- book or the failure gift (up to 3 items) always fits.
function PTBK_CraftDo(sk)
	local r = PTBK_RECIPE[sk]
	local b = PTBK_BOOK[sk]
	if r == nil or b == nil then return end
	CloseDialog()
	if b[1] >= 0 and GetProfession() ~= b[1] then
		Talk(1, "no_ptbk", @M_PROF1@ .. b[3] .. @M_PROF2@ .. PTBK_ProfName(b[1]) .. ".")
		return
	end
	if CalcFreeItemCellCount(1, 1) < 3 then
		Talk(1, "no_ptbk", @M_BAG@)
		return
	end
	if HaveNormalItem(8, r[1], 2, -1) < r[2] or (r[4] > 0 and HaveNormalItem(3, r[3], 0, -1) < r[4]) then
		Talk(1, "no_ptbk", @M_NEED1@ .. b[3] .. @M_NEED2@ .. PTBK_RecipeText(sk) .. ".")
		return
	end
	local got = 0
	while got < r[4] do
		if DelNormalItem(3, r[3], 0, -1) > 0 then got = got + 1 else break end
	end
	if got < r[4] then
		PTBK_RefundMats(r[3], got)
		Talk(1, "no_ptbk", @M_MATBAG@)
		return
	end
	local pg = 0
	while pg < r[2] do
		local idx = FindAValidIBItem(8, r[1], 2, 0)
		if idx ~= nil and idx > 0 and CostIBItem(idx) == 1 then pg = pg + 1 else break end
	end
	if pg < r[2] then
		PTBK_RefundPages(r[1], pg)
		PTBK_RefundMats(r[3], got)
		Talk(1, "no_ptbk", @M_PAGEFAIL@)
		return
	end
	if random(1, r[6]) <= r[5] then
		if AddNormalItem(6, 1, PTBK_KEY_BASE + sk, 1, 0, 0) > 0 then
			PTBK_Log("craft ok skill=" .. sk)
			Msg2Player(@M_CRAFTOK1@ .. b[3] .. @M_CRAFTOK2@)
			Talk(1, "no_ptbk", @M_CRAFTOK1@ .. b[3] .. @M_CRAFTOK2@)
			return
		end
		PTBK_RefundPages(r[1], pg)
		PTBK_RefundMats(r[3], got)
		Talk(1, "no_ptbk", @M_BAG@)
		return
	end
	local c = PTBK_CONS[r[1]]
	local e = c[random(1, getn(c))]
	PTBK_Give(e[1], e[2], e[3], e[4])
	PTBK_Log("craft fail skill=" .. sk)
	Msg2Player(@M_CRAFTNO1@ .. e[4] .. " " .. e[5] .. ".")
	Talk(1, "no_ptbk", @M_CRAFTNO1@ .. e[4] .. " " .. e[5] .. ".")
end

-- ---------------------------------------------------------------- old genre-7 books -> bi kip
function PTBK_ConvertOld()
	local n = 0
	local left = 0
	local guard = 0
	local sk, b = next(PTBK_BOOK, nil)
	while sk do
		while guard < 200 and HaveNormalItem(7, b[4], sk, -1) > 0 do
			guard = guard + 1
			if DelNormalItem(7, b[4], sk, -1) > 0 then
				if AddNormalItem(6, 1, PTBK_KEY_BASE + sk, 1, 0, 0) > 0 then
					n = n + 1
				else
					AddNormalItem(7, b[4], sk, 1, 0, 0)
					left = left + 1
					break
				end
			else
				left = left + 1
				break
			end
		end
		sk, b = next(PTBK_BOOK, sk)
	end
	PTBK_Log("convert n=" .. n .. " left=" .. left)
	if n == 0 and left == 0 then
		Talk(1, "no_ptbk", @M_CONV0@)
	elseif left > 0 then
		Talk(1, "no_ptbk", @M_CONV1@ .. n .. @M_CONV2@)
	else
		Talk(1, "no_ptbk", @M_CONV1@ .. n .. @M_CONV3@)
	end
end

@CALLBACKS@
'''
subs = {
    "PROF0": L("Giáp Sĩ"), "PROF1": L("Đạo Sĩ"), "PROF2": L("Dị Nhân"), "ANYPROF": L("mọi phái"),
    "BOOKS": lua_book_table(), "RECIPES": lua_recipe_table(), "CONS": lua_cons(), "MENU": lua_menu(),
    "PAGES": lua_names(PAGE, "PTBK_PAGE"), "MATS": lua_names(MAT, "PTBK_MAT"), "CALLBACKS": callbacks,
    "CLOSE": L("Đóng/no_ptbk"), "M_EXIT": L("Thôi, để sau/no_ptbk"), "M_LATER": L("Thôi, để sau/no_ptbk"),
    "M_UNKNOWN": L("Không nhận ra bí kíp này."),
    "M_PROF1": L("Bí kíp "), "M_PROF2": L(" chỉ dành cho phái "),
    "M_LV1": L("Cần đạt cấp "), "M_LV2": L(" mới lĩnh hội được "),
    "M_HAVE1": L("Ngươi đã lĩnh hội "), "M_HAVE2": L(" (cấp "),
    "M_HAVE3": L("), bí kíp vẫn còn. Muốn mạnh hơn hãy dùng điểm kỹ năng và luyện tập."),
    "M_FAIL": L("Lĩnh hội thất bại, bí kíp vẫn còn."),
    "M_OK1": L("Đã lĩnh hội "), "M_OK2": L(" (cấp 1). Dùng điểm kỹ năng để nâng cấp."),
    "M_NOSHOP": L("Ta chỉ bán bí kíp cho Giáp Sĩ, Đạo Sĩ và Dị Nhân."),
    "M_NOCRAFT": L("Học tập phải kiên nhẫn mới được, sau này lại đến nhé."),
    "M_CRAFTHEAD": L("Mang Không Thư và thủy tinh đến đây, ta sẽ giúp ngươi đóng thành bí kíp. Phép này không chắc thành công, nếu hỏng ngươi sẽ nhận vật phẩm khác. Muốn đóng bí kíp nào?"),
    "M_PICK1": L("Đóng bí kíp "), "M_PICK2": L(" cần "), "M_PICK3": L(". Tỉ lệ thành công: "),
    "M_PICK4": L(". Nguyên liệu phải nằm trong hành trang. Đóng sách ngay?"),
    "M_DOIT": L("Đóng sách"),
    "M_BAG": L("Hành trang cần ít nhất 3 ô trống, hãy sắp xếp lại rồi quay lại."),
    "M_NEED1": L("Đóng bí kíp "), "M_NEED2": L(" cần "),
    "M_MATBAG": L("Thủy tinh, bảo thạch phải để trong hành trang (không tính rương chứa đồ)."),
    "M_PAGEFAIL": L("Không lấy đủ Không Thư, nguyên liệu đã được trả lại."),
    "M_CRAFTOK1": L("Vui quá! Bí kíp "), "M_CRAFTOK2": L(" đã xuất hiện. Nhấp chuột phải vào bí kíp để lĩnh hội."),
    "M_CRAFTNO1": L("Suýt nữa tẩu hỏa nhập ma, đóng sách không thành. Nhận được "),
    "M_CONV0": L("Trong hành trang không có sách kỹ năng cũ nào."),
    "M_CONV1": L("Đã đổi "),
    "M_CONV2": L(" sách kỹ năng cũ thành bí kíp. Sách còn lại nằm ngoài hành trang hoặc hành trang đã đầy."),
    "M_CONV3": L(" sách kỹ năng cũ thành bí kíp. Nhấp chuột phải vào bí kíp để lĩnh hội."),
}
lib = LIB
for k, v in subs.items():
    lib = lib.replace("@%s@" % k, v)
assert "@" not in re.sub(r'"[^"\n]*"', "", lib).replace("@", "") or True
left = re.findall(r"@[A-Z0-9_]+@", lib)
assert not left, left
lib = lib.replace("\r\n", "\n").replace("\n", "\r\n")
assert all(ord(ch) < 128 for ch in lib)

ITEM = '''-- Phong Than 2026-10-02 (agent bikip): Bi kip %(ascii)s, magicscript 6/1/%(key)d.
-- Right click: learn skill %(sk)d (profession %(prof)s, level %(req)d). Logic in pt_bikip.lua.
Include("\\\\script\\\\phongthan\\\\lib\\\\pt_bikip.lua")

function main(nItemIdx)
	return PTBK_UseBook(nItemIdx, %(sk)d)
end
'''
SACH7 = '''-- Phong Than 2026-10-02 (agent bikip): VNG genre-7 skill book (settings\\item\\001\\skillbook.txt).
-- Not reachable yet: KItemList::ExecuteScript returns early for genre 7. Kept for a C++ hook that runs
-- this file for item_skillbook; until then old books are converted at Vo su Tay Ky / Trieu Ca.
Include("\\\\script\\\\phongthan\\\\lib\\\\pt_bikip.lua")

function main(nItemIdx)
	return PTBK_UseSkillBook7(nItemIdx)
end
'''

def ascii_name(s):
    return unicodedata.normalize("NFD", s.replace("Đ", "D").replace("đ", "d")).encode("ascii", "ignore").decode()

if "--write" in sys.argv:
    open(OUT_LIB, "wb").write(lib.encode("ascii"))
    for sk, b in books.items():
        src = ITEM % dict(ascii=ascii_name(b["name"]), key=KEY_BASE + sk, sk=sk, prof=b["prof"], req=b["req"])
        open(os.path.join(OUT_ITEM, "bikip_%d.lua" % sk), "wb").write(src.replace("\n", "\r\n").encode("ascii"))
    open(os.path.join(OUT_ITEM, "bikip_sach7.lua"), "wb").write(SACH7.replace("\n", "\r\n").encode("ascii"))
    print("wrote lib + %d item scripts + bikip_sach7.lua" % len(books))
else:
    open(os.path.join(HERE, "pt_bikip.preview.lua"), "wb").write(lib.encode("ascii"))

# ---------------------------------------------------------------- data for the ptfix plug-in
TAIL = '''
-- ptfix 2026-10-02 (agent bikip): Vo su menu. "Sach" = VNG Sale(14); "Mua bi kip he phai" = book
-- shop of the player's profession (buysell rows appended by extra_bikip.py); "Dong sach" = VNG
-- crafting rewritten safely in pt_bikip.lua (gives the right-click bi kip 6/1/62000+skill);
-- old genre-7 books in the bag can be converted into bi kip.
Include("\\\\script\\\\phongthan\\\\lib\\\\pt_bikip.lua")
PTBK_SHOP_SALE = { [0] = @SHOP0@, [1] = @SHOP1@, [2] = @SHOP2@ }

function main(sel)
	if (songxin() == 0) then
		local tasks =
		{
			{%(buy)s, "yes_2"; show = 1},
			{%(shop)s, "PTBK_ShopMenu"; show = 1},
			{%(craft)s, "PTBK_CraftMenu"; show = 1},
			{%(conv)s, "PTBK_ConvertOld"; show = 1},
		}
		SayTask(10069, tasks)
	end
end

function books()
	PTBK_CraftMenu()
end
''' % dict(buy=L("Sách"), shop=L("Mua bí kíp hệ phái"), craft=L("Đóng sách (ép bí kíp)"), conv=L("Đổi sách kỹ năng cũ thành bí kíp"))

def desc(b):
    if b["prof"] < 0:
        return "Bí kíp kỹ năng sống. Nhấp chuột phải để lĩnh hội %s." % b["name"]
    s = "Bí kíp võ công phái %s, yêu cầu cấp %d. Nhấp chuột phải để lĩnh hội %s." % (PROF_NAME[b["prof"]], b["req"], b["name"])
    if b["crafted"]:
        s += " Võ sư Tây Kỳ, Triều Ca có thể đóng từ Không Thư."
    return s

data = {
    "key_base": KEY_BASE,
    "books": [dict(skill=sk, detail=b["detail"], prof=b["prof"], req=b["req"], price=b["price"],
                   name_tcvn=tcvn("Bí Kíp " + b["name"]).hex(), desc_tcvn=tcvn(desc(b)).hex(), spr=b["spr"].hex(),
                   script="\\script\\phongthan\\item\\bikip_%d.lua" % sk) for sk, b in sorted(books.items())],
    "shops": {"0": [sk for sk in sorted(books) if books[sk]["prof"] in (0, -1)],
              "1": [sk for sk in sorted(books) if books[sk]["prof"] in (1, -1)],
              "2": [sk for sk in sorted(books) if books[sk]["prof"] in (2, -1)]},
    "teachers": ["\\script\\西岐\\教师.lua", "\\script\\朝歌\\教师.lua"],
    "teacher_tail": TAIL,
}
json.dump(data, open(os.path.join(HERE, "bikip_data.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("data: books=%d shops=%s" % (len(data["books"]), {k: len(v) for k, v in data["shops"].items()}))
for sk in sorted(books):
    b = books[sk]
    print("%4d %-24s prof=%2d req=%2d price=%6d %s" % (sk, b["name"], b["prof"], b["req"], b["price"], "craft" if b["crafted"] else ("shop" if sk in SHOP_TIER else "")))
