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

# Anchor exact original Lua 4 contexts, not wildcard regexes.
PATCHES = {
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
