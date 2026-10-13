#!/usr/bin/env python3
"""Minimal Lua 4 safety patches for a COPY of the Phong Than runtime server.

The original game sources, tracked staging runtime, PAKs and saves are read-only.
Run --target /external/copy/Server (dry-run) then add --apply.
"""
from __future__ import annotations

import argparse
from pathlib import Path

GIFT = "script/servertimer.lua"
PET = "script/phongthan/sinhhoat/lt_npc.lua"
DAILY = "script/phongthan/content/dg_lib.lua"
PET_MATERIALS = "script/phongthan/sinhhoat/sh_lib.lua"

# Anchor exact original Lua 4 contexts, not wildcard regexes.
PATCHES = {
    DAILY:     (
        (
            "\treturn got\nend\n\n-- deliver queued gifts to the current player",
            "\treturn got\nend\n\n-- A partial gift grant must not be reported as complete or blindly replayed.\nfunction PTDG_GrantChecked(kind, list, money)\n\tlocal expected = 0\n\tlocal k = 1\n\twhile list[k] do\n\t\tlocal count = tonumber(list[k].n) or 1\n\t\tlocal j = 1\n\t\twhile j <= count do\n\t\t\texpected = expected + 1\n\t\t\tj = j + 1\n\t\tend\n\t\tk = k + 1\n\tend\n\tlocal got = PTDG_GiveList(list, money)\n\tif got == expected then return 1 end\n\tlocal h = openfile(\"admin_bridge\\\\dailygift_result.log\", \"a\")\n\tif h then\n\t\twrite(h, date(\"%Y-%m-%d %H:%M:%S\") .. \"\\tPARTIAL\\t\" ..\n\t\t\t(GetName() or \"?\") .. \"\\t\" .. kind .. \"\\titems=\" .. got ..\n\t\t\t\"/\" .. expected .. \"\\n\")\n\t\tclosefile(h)\n\tend\n\tMsg2Player(PTDG_HEAD .. \"Loi nhan qua \" .. kind .. \": \" .. got ..\n\t\t\"/\" .. expected .. \" vat pham. Lien he GM; khong tu phat lai.\")\n\treturn 0\nend\n\n-- deliver queued gifts to the current player",
        ),
        (
            "\t\tPTDG_GiveList(cfg.daily, tonumber(cfg.moneyDaily) or 0)\n\t\tMsg2Player(",
            "\t\tif PTDG_GrantChecked(\"daily\", cfg.daily, tonumber(cfg.moneyDaily) or 0) == 1 then\n\t\t\tMsg2Player(",
        ),
        (
            "PTDG_Names(cfg.daily, tonumber(cfg.moneyDaily) or 0))\n\tend\n\tlocal nb",
            "PTDG_Names(cfg.daily, tonumber(cfg.moneyDaily) or 0))\n\t\tend\n\tend\n\tlocal nb",
        ),
        (
            "\t\tPTDG_GiveList(cfg.big, tonumber(cfg.moneyBig) or 0)\n\t\tMsg2Player(",
            "\t\tif PTDG_GrantChecked(\"streak7\", cfg.big, tonumber(cfg.moneyBig) or 0) == 1 then\n\t\t\tMsg2Player(",
        ),
        (
            "PTDG_Names(cfg.big, tonumber(cfg.moneyBig) or 0))\n\tend\n\treturn 0",
            "PTDG_Names(cfg.big, tonumber(cfg.moneyBig) or 0))\n\t\tend\n\tend\n\treturn 0",
        ),
    ),
    PET_MATERIALS:     (
        (
            "\treturn k\nend\n\n-- take n of one item from the bag",
            "\treturn k\nend\n\n-- Log missing compensation instead of silently assuming inventory was restored.\nfunction PTSH_RefundWarn(kind, missing)\n\tif missing <= 0 then return end\n\tlocal h = openfile(\"admin_bridge\\\\pet_refund_result.log\", \"a\")\n\tif h then\n\t\twrite(h, date(\"%Y-%m-%d %H:%M:%S\") .. \"\\tPARTIAL\\t\" ..\n\t\t\t(GetName() or \"?\") .. \"\\t\" .. kind .. \"\\tmissing=\" .. missing .. \"\\n\")\n\t\tclosefile(h)\n\tend\n\tMsg2Player(\"Loi hoan vat lieu (\" .. missing .. \" mon). Lien he GM de kiem tra.\")\nend\n\n-- take n of one item from the bag",
        ),
        (
            "\t\t\t\tPTSH_Give(r[1], r[2], r[3], got[j])\n\t\t\t\tj = j + 1",
            "\t\t\t\tlocal restored = PTSH_Give(r[1], r[2], r[3], got[j])\n\t\t\t\tif restored < got[j] then\n\t\t\t\t\tPTSH_RefundWarn(\"takeall\", got[j] - restored)\n\t\t\t\tend\n\t\t\t\tj = j + 1",
        ),
        (
            "function PTSH_GiveBack(taken)\n\tif taken == nil then return end\n\tfor id, g in taken do PTSH_Give(3, id, 0, g) end\nend",
            "function PTSH_GiveBack(taken)\n\tif taken == nil then return 0 end\n\tlocal missing = 0\n\tfor id, g in taken do\n\t\tlocal restored = PTSH_Give(3, id, 0, g)\n\t\tif restored < g then missing = missing + g - restored end\n\tend\n\tPTSH_RefundWarn(\"tier\", missing)\n\treturn missing\nend",
        ),
    ),
    GIFT: (
        (
            """function PTAdm_GiveAll(id, g, d, p, lv, se, n, itemName)
\tlocal i = 1
\tlocal players = 0
""",
            """function PTAdm_GiveAll(id, g, d, p, lv, se, n, itemName)
\tlocal i = 1
\tlocal players = 0
\tlocal targets = 0
\tlocal complete = 0
\tlocal partial = 0
\tlocal failed = 0
""",
        ),
        (
            """\t\t\t\tplayers = players + 1
\t\t\tend
\t\tend
\t\ti = i + 1
\tend
\tPTAdm_Log(id, "OK", "players=" .. players)""",
            """\t\t\t\tplayers = players + 1
\t\t\tend
\t\t\ttargets = targets + 1
\t\t\tif ok == n then
\t\t\t\tcomplete = complete + 1
\t\t\telseif ok > 0 then
\t\t\t\tpartial = partial + 1
\t\t\telse
\t\t\t\tfailed = failed + 1
\t\t\tend
\t\tend
\t\ti = i + 1
\tend
\tlocal status = "OK"
\tif partial > 0 or failed > 0 then status = "PARTIAL" end
\tPTAdm_Log(id, status, "targets=" .. targets .. " complete=" .. complete ..
\t\t" partial=" .. partial .. " failed=" .. failed)""",
        ),
    ),
    PET: (
        (
            """\tif Pay(PTLT_EGG_CASH) ~= 1 then
\t\tPTSH_Give(6, PTLT_I_DON, 0, PTLT_EGG_DON)
\t\treturn
\tend
\tPTSH_Give(6, PTLT_I_EGG0 + k, 0, 1)""",
            """\tif Pay(PTLT_EGG_CASH) ~= 1 then
\t\tlocal restored = PTSH_Give(6, PTLT_I_DON, 0, PTLT_EGG_DON)
\t\tif restored ~= PTLT_EGG_DON then
\t\t\tMsg2Player("Loi hoan vat lieu doi trung; can lien he GM.")
\t\tend
\t\treturn
\tend
\tif PTSH_Give(6, PTLT_I_EGG0 + k, 0, 1) ~= 1 then
\t\tEarn(PTLT_EGG_CASH)
\t\tlocal restored = PTSH_Give(6, PTLT_I_DON, 0, PTLT_EGG_DON)
\t\tif restored ~= PTLT_EGG_DON then
\t\t\tMsg2Player("Loi hoan vat lieu doi trung; can lien he GM.")
\t\telse
\t\t\tMsg2Player("Khong tao duoc trung Linh Thu. Da yeu cau hoan tien va vat lieu.")
\t\tend
\t\treturn
\tend""",
        ),
    ),
}


def patch(relative: str, original: bytes) -> bytes:
    if relative not in PATCHES:
        raise ValueError("Unknown game script: " + relative)
    data = original
    for old_text, new_text in PATCHES[relative]:
        old, new = old_text.encode("ascii"), new_text.encode("ascii")
        candidates = (
            (old.replace(b"\n", b"\r\n"), new.replace(b"\n", b"\r\n")),
            (old, new),
        )
        if any(data.count(new_value) == 1 for _, new_value in candidates):
            continue  # already patched; idempotent even when the old is a prefix
        exact = [(needle, replacement) for needle, replacement in candidates
                 if data.count(needle) == 1]
        if exact:
            # Prefer full CRLF match if the source has Windows endings.
            needle, replacement = exact[0]
            data = data.replace(needle, replacement, 1)
            continue
        raise ValueError("Changed, missing or repeated patch context: " + relative)
    return data


def stage(target: Path, *, apply: bool = False) -> list[str]:
    repo_root = Path(__file__).resolve().parents[1]
    target = target.resolve()
    if apply and (target == repo_root or repo_root in target.parents):
        raise ValueError("Refusing to patch original repository or tracked staging.")
    if not target.is_dir():
        raise ValueError("Target must be an existing external Server directory.")

    # All inputs are validated before any writes; no PAK or character data touched.
    pending: list[tuple[Path, bytes]] = []
    results: list[str] = []
    for relative in PATCHES:
        dest = target.joinpath(*relative.split("/"))
        if dest.is_symlink() or not dest.is_file() or target not in dest.resolve().parents:
            raise ValueError("Missing or unsafe runtime Lua path: " + relative)
        original = dest.read_bytes()
        modified = patch(relative, original)
        pending.append((dest, modified))
        results.append(relative + (" (already patched)" if original == modified else " (needs patch)"))
    if apply:
        for dest, modified in pending:
            if dest.read_bytes() != modified:
                dest.write_bytes(modified)
    return results


def main() -> None:
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--target", type=Path, required=True)
    cli.add_argument("--apply", action="store_true", help="Apply only to an external copied Server directory")
    args = cli.parse_args()
    for result in stage(args.target, apply=args.apply):
        print(result)
    print("Applied to external copy" if args.apply else "Dry-run; no files changed")


if __name__ == "__main__":
    main()
