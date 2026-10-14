#!/usr/bin/env python3
"""Apply a byte-preserving 32-bit EXP compatibility hotfix to legacy C++.

The two .cpp source files contain non-UTF8 comments. Do not decode/rewrite them
through UTF-8 APIs: replace only exact ASCII fragments, retain every other byte.
"""
from __future__ import annotations
import argparse
import sys
from pathlib import Path

FILES = {
    "PhongThanSource/Sources/Core/Src/KPlayerSet.cpp": (
        ("#include \"KPlayerSet.h\"",
         "#include \"KPlayerSet.h\"\n#include \"PhongThanExpCompat.h\""),
        (
            "if(i == 0)\n"
            "\t\t\t\tLevelExp.GetInteger(j + 2, 2, 0, &m_nLevelExp[j]);\n"
            "\t\t\tLevelExp.GetInteger(j + 2, 3+i, 0, &m_nLevelExpAdd[i][j]);",
            "if (i == 0)\n"
            "\t\t\t{\n"
            "\t\t\t\tchar value[64];\n"
            "\t\t\t\tvalue[0] = 0;\n"
            "\t\t\t\tif (!LevelExp.GetString(j + 2, 2, \"\", value, sizeof(value)) ||\n"
            "\t\t\t\t\t!PhongThanParseBaseLevelExp(value, j + 1, &m_nLevelExp[j]))\n"
            "\t\t\t\t{\n"
            "\t\t\t\t\tprintf(\"[PHONGTHAN][PLAYER][FATAL] Invalid level EXP at level %d: %s\\n\", j + 1, value);\n"
            "\t\t\t\t\treturn FALSE;\n"
            "\t\t\t\t}\n"
            "\t\t\t}\n"
            "\t\t\tchar bonus[64] = \"0\";\n"
            "\t\t\tLevelExp.GetString(j + 2, 3+i, \"0\", bonus, sizeof(bonus));\n"
            "\t\t\tif (!PhongThanParseNonnegativeInt32(bonus, &m_nLevelExpAdd[i][j]) ||\n"
            "\t\t\t\tm_nLevelExpAdd[i][j] > INT_MAX - m_nLevelExp[j])\n"
            "\t\t\t{\n"
            "\t\t\t\tprintf(\"[PHONGTHAN][PLAYER][FATAL] Invalid transcendence EXP: level=%d, translife=%d\\n\", j + 1, i);\n"
            "\t\t\t\treturn FALSE;\n"
            "\t\t\t}"
        ),
        ("if (nLevel < 1 || nLevel > MAX_LEVEL)\n\t\treturn 0;\n\treturn m_nLevelExp[nLevel - 1] + m_nLevelExpAdd[nTranslife][nLevel - 1];",
         "if (nLevel < 1 || nLevel > MAX_LEVEL ||\n\t\tnTranslife < 0 || nTranslife >= MAX_TRANSLIFE_VALUE)\n\t\treturn 0;\n\treturn m_nLevelExp[nLevel - 1] + m_nLevelExpAdd[nTranslife][nLevel - 1];"),
    ),
    "PhongThanSource/Sources/Core/Src/KPlayer.cpp": (
        ("#include \"KPlayer.h\"", "#include \"KPlayer.h\"\n#include \"PhongThanExpCompat.h\""),
        ("nExp *= g_ExpRate;", "nExp = PhongThanClampPositiveExp(static_cast<long long>(nExp) * g_ExpRate);"),
        ("nGetExp = nGetExp *\n\t\t(MAX_PERCENT + Npc[m_nIndex].m_CurrentExpEnhance) / MAX_PERCENT;",
         "nGetExp = PhongThanClampPositiveExp(\n\t\tstatic_cast<long long>(nGetExp) *\n\t\t(MAX_PERCENT + static_cast<long long>(Npc[m_nIndex].m_CurrentExpEnhance)) / MAX_PERCENT);"),
        ("m_nExp += nGetExp;", "m_nExp = PhongThanClampSignedExp(static_cast<long long>(m_nExp) + nGetExp);"),
        ("AddSkillExp(nGetExp * g_Skill120ExpRate / MAX_PERCENT);",
         "AddSkillExp(PhongThanClampSignedExp(static_cast<long long>(nGetExp) * g_Skill120ExpRate / MAX_PERCENT));"),
        ("m_nExp += nExp;", "m_nExp = PhongThanClampSignedExp(static_cast<long long>(m_nExp) + nExp);"),
    ),
}

def transformed(path: Path, replacements: tuple, *, check: bool = False) -> bool:
    raw = path.read_bytes()
    data = raw
    for old, new in replacements:
        # Legacy files can mix LF and CRLF in the same blob. Match each anchor
        # independently; do not normalize or re-encode the rest of the file.
        matched = False
        for newline in (b"\n", b"\r\n"):
            old_bytes = old.encode("ascii").replace(b"\n", newline)
            new_bytes = new.encode("ascii").replace(b"\n", newline)
            # Some replacements (e.g. an include insertion) contain the
            # old anchor. Check the full patched fragment *first*.
            if data.count(new_bytes) == 1:
                matched = True
                break
            if data.count(old_bytes) == 1:
                data = data.replace(old_bytes, new_bytes, 1)
                matched = True
                break
        if not matched:
            raise ValueError(f"expected unique patch anchor missing in {path}: {old[:80]}")
    if check and data != raw:
        raise ValueError(f"missing EXP patch in {path}")
    if data != raw and not check:
        path.write_bytes(data)
        return True
    return False

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    for relative, replacements in FILES.items():
        path = args.root / relative
        changed = transformed(path, replacements, check=args.check)
        print(("updated " if changed else "verified ") + relative)
    return 0

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(f"EXP patch refused: {exc}", file=sys.stderr)
        raise SystemExit(1)
