# Generate the loose Lua files of agent sinhhoat: src\*.lua (UTF-8, Vietnamese literals) -> ASCII Lua where every
# non-ASCII character becomes a TCVN3 \ddd escape (the encoding of the surrounding VNG scripts).
# usage: python gen.py [outroot]   (default: the runtime Server\script\phongthan)
import os, sys, unicodedata
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.environ["TEMP"], "ptspawn"))
from tcvn import low as _low
OUT = sys.argv[1] if len(sys.argv) > 1 else r"E:\VL\Phong than\PT\PhongThanRuntime-Staging\Server\script\phongthan"

def tcvn_char(ch):
    if ch in _low: return _low[ch]
    if ch.lower() in _low: return _low[ch.lower()]
    raise ValueError("no TCVN3 for %r" % ch)

def conv(text):
    o = []
    for ch in unicodedata.normalize("NFC", text):
        if ord(ch) < 128: o.append(ch)
        else: o.append("\\%03d" % tcvn_char(ch))
    return "".join(o)

def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = conv(text).replace("\r\n", "\n").replace("\n", "\r\n").encode("ascii")
    open(path, "wb").write(data)
    return len(data)

files = []
src = os.path.join(HERE, "src")
for f in sorted(os.listdir(src)):
    if not f.endswith(".lua"): continue
    text = open(os.path.join(src, f), encoding="utf-8").read()
    if f == "ext_sinhhoat.lua":
        dst = os.path.join(OUT, "ext", "sinhhoat.lua")
    else:
        dst = os.path.join(OUT, "sinhhoat", f)
    files.append((dst, write(dst, text)))
for k in range(1, 9):
    text = ("-- Phong Than 2026-10-03 (sinhhoat): item 6/1/%d \"Trung Linh Thu\" (egg of pet %d, see sh_lib.lua PTLT_PET).\n"
            "-- Right click: the pet hatches (consumed), kept when the pet is already owned.\n"
            "Include(\"\\\\script\\\\phongthan\\\\sinhhoat\\\\sh_lib.lua\")\n\n"
            "function main(nItemIdx)\n\treturn PTLT_UseEgg(nItemIdx, %d)\nend\n") % (61370 + k, k, k)
    dst = os.path.join(OUT, "sinhhoat", "lt_trung_%d.lua" % k)
    files.append((dst, write(dst, text)))
for p, n in files: print(n, p)
