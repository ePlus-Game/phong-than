#!/usr/bin/env python3
"""Apply minimal VC6-compatible security fixes to a COPY of PhongThanSource.

This never patches the byte-exact source/PT archival tree inside this checkout.
Use --target /external/copy/PhongThanSource [--apply].
"""
from __future__ import annotations
import argparse
from pathlib import Path

PATCHES = {
    "Sources/MultiServer/GameServer/GameServer.cpp": (
        (
            b'fprintf(stderr, szerrmsg);',
            b'fprintf(stderr, "%s", szerrmsg ? szerrmsg : "");',
        ),
    ),
    "Sources/AccountServices/AccountServer/S3PDBSocketPool.cpp": (
        (
            b'\tif (m_pServer == NULL)\n\t\treturn FALSE;\n\n\tBOOL bRet = FALSE;\n\ttry\n\t{\n\t\tassert(pSend);\n\t\tpSend->Version',
            b'\tif (m_pServer == NULL || pSend == NULL ||\n'
            b'\t\tpSend->Size < sizeof(KAccountHead) || pSend->Size > MAX_PATH)\n'
            b'\t\treturn FALSE;\n\n\tBOOL bRet = FALSE;\n\ttry\n\t{\n\t\tpSend->Version',
        ),
        (
            b'\t\tassert(pSend->Size < MAX_PATH);\n',
            b'',
        ),
        (
            b"\tassert(m_pServer);\n"
            b"\tconst char* pInfo = m_pServer->GetClientInfo(uID);\n"
            b"\tunsigned long Address = inet_addr(pInfo);\n"
            b"\tint offset = 0;\n"
            b"\twhile(*(pInfo + offset) != ':')\n"
            b"\t\toffset++;\n"
            b"\toffset += 2;\t//skip : and blank\n"
            b"\tshort Port = atoi(pInfo + offset);",
            b"\tif (m_pServer == NULL)\n"
            b"\t\treturn FALSE;\n"
            b"\tconst char* pInfo = m_pServer->GetClientInfo(uID);\n"
            b"\tif (pInfo == NULL)\n"
            b"\t\treturn FALSE;\n"
            b"\tconst char* colon = strchr(pInfo, ':');\n"
            b"\tif (colon == NULL)\n"
            b"\t\treturn FALSE;\n"
            b"\tchar* endPort = NULL;\n"
            b"\tunsigned long port = strtoul(colon + 1, &endPort, 10);\n"
            b"\tif (endPort == colon + 1 || *endPort != '\\0' || port == 0 || port > 65535UL)\n"
            b"\t\treturn FALSE;\n"
            b"\tconst size_t ipLength = (size_t)(colon - pInfo);\n"
            b"\tif (ipLength == 0 || ipLength >= 16)\n"
            b"\t\treturn FALSE;\n"
            b"\tchar ip[16];\n"
            b"\tmemcpy(ip, pInfo, ipLength);\n"
            b"\tip[ipLength] = '\\0';\n"
            b"\tunsigned long Address = inet_addr(ip);\n"
            b"\tif (Address == INADDR_NONE)\n"
            b"\t\treturn FALSE;\n"
            b"\tshort Port = (short)(unsigned short)port;",
        ),
    ),
}


PATCHES["Build/Build-Modern.ps1"] = (
    (
        b'if (-not (Test-Path -LiteralPath $src)) { Add-Content $log "THIEU FILE: $src"; continue }',
        b'if (-not (Test-Path -LiteralPath $src)) { Add-Content $log "THIEU FILE: $src"; return @{ Ok = $false; Log = $log; Errors = @("THIEU FILE: $src") } }',
    ),
)
PATCHES["Build/Build-PhongThan.ps1"] = tuple(
    (
        ("Path='Sources\\{0}\\Release\\{1}';Role='{2}'".format(folder, filename, role)).encode("ascii"),
        ("Path=\"Sources\\{0}\\$Configuration\\{1}\";Role='{2}'".format(folder, filename, role)).encode("ascii"),
    )
    for folder, filename, role in (
        ("Engine", "Engine.dll", "Client"),
        ("Engine", "Engine.dll", "Server"),
        ("Library\\LuaLib", "LuaLibDll.dll", "Client"),
        ("Library\\LuaLib", "LuaLibDll.dll", "Server"),
    )
)



def harden(relative: str, original: bytes) -> bytes:
    """Patch only matching byte spans, preserving ALL untouched original bytes.

    Some recovered legacy sources contain mixed LF and CRLF newlines. Never
    normalize the whole file; search for each exact context in both styles.
    """
    if relative not in PATCHES:
        raise ValueError("not a known source path: " + relative)
    data = original
    for old, new in PATCHES[relative]:
        found = []
        for ending in (b"\r\n", b"\n"):
            needle = old.replace(b"\n", ending)
            replacement = new.replace(b"\n", ending)
            if data.count(needle) == 1 and needle not in [item[0] for item in found]:
                found.append((needle, replacement))
        if len(found) == 1:
            needle, replacement = found[0]
            data = data.replace(needle, replacement, 1)
        elif len(found) > 1:
            # CRLF patterns also contain LF bytes; prefer full CRLF match.
            if found[0][0] in data:
                data = data.replace(found[0][0], found[0][1], 1)
            else:
                raise ValueError("ambiguous source context: " + relative)
        elif new and any(
            new.replace(b"\n", ending) in data
            for ending in (b"\r\n", b"\n")
        ):
            continue
        elif not new and not any(
            old.replace(b"\n", ending) in data
            for ending in (b"\r\n", b"\n")
        ):
            continue
        else:
            raise ValueError("source context changed or ambiguous: " + relative)
    return data

def stage(target: Path, *, apply: bool) -> list[str]:
    target = target.resolve()
    repo_root = Path(__file__).resolve().parents[1]
    if apply and (target == repo_root or repo_root in target.parents):
        raise ValueError("Refusing to edit the tracked archive or any in-repository source.")
    staged: list[tuple[Path, bytes]] = []
    report: list[str] = []
    for rel in PATCHES:
        f = target.joinpath(*rel.split("/"))
        original = f.read_bytes()
        modified = harden(rel, original)
        # harden() already verifies exact source context or an installed patch.
        # Comparing LF-only replacement bytes to a CRLF source is incorrect.
        staged.append((f, modified))
        report.append(rel + (" (already patched)" if modified == original else " (needs patch)"))
    if apply:
        # Validate all source files before changing any file.
        for f, data in staged:
            if f.read_bytes() != data:
                f.write_bytes(data)
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", type=Path, required=True,
                        help="Path to an EXTERNAL COPY of PhongThanSource")
    parser.add_argument("--apply", action="store_true",
                        help="Apply after validation; without this option, dry-run only")
    args = parser.parse_args()
    for row in stage(args.target, apply=args.apply):
        print(row)
    print("Applied to copied tree" if args.apply else "Dry run; no files changed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
