#!/usr/bin/env python3
"""Apply minimal VC6-compatible security fixes to a COPY of PhongThanSource.

This never patches the byte-exact root-level PhongThanSource archive inside this checkout.
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
            b'\t\t!PtRecovery::IsPacketLengthWithinBounds((size_t)pSend->Size,\n'
            b'\t\t\tsizeof(KAccountHead), MAX_PATH))\n'
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
            b"\tPtRecovery::GatewayEndpoint endpoint;\n"
            b"\tif (!PtRecovery::ParseGatewayEndpoint(pInfo, &endpoint))\n"
            b"\t\treturn FALSE;\n"
            b"\tunsigned long Address = inet_addr(endpoint.ipv4);\n"
            b"\tif (Address == INADDR_NONE)\n"
            b"\t\treturn FALSE;\n"
            b"\tshort Port = (short)endpoint.port;",
        ),
        (
            b'#include "S3PDBSocketPool.h"\n#include "S3PAccount.h"',
            b'#include "S3PDBSocketPool.h"\n#include "GatewayEndpointParser.h"\n#include "AccountPacketBounds.h"\n#include "S3PAccount.h"',
        ),
        (
            b'\t\t\tif (pData && 0 != datalength)\n'
            b'\t\t\t{\n'
            b'\t\t\t\tProcessClientData(pData, datalength);',
            b'\t\t\tif (pData && PtRecovery::IsPacketLengthWithinBounds(\n'
            b'\t\t\t\t\tdatalength, sizeof(PHONGTHAN_WIRE_HEADER),\n'
            b'\t\t\t\t\tPHONGTHAN_WIRE_MAX_PACKET_SIZE))\n'
            b'\t\t\t{\n'
            b'\t\t\t\tProcessClientData(pData, (DWORD)datalength);',
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


# Additional source and build fixes applied only to an external build copy.
PATCHES["Sources/MultiServer/GameServer/KSOServer.cpp"] = (
    (
        b'printf("Packing failed. %d, %d, %d\\n", lnID);',
        b'printf("Packing failed. id=%lu\\n", (unsigned long)lnID);',
    ),
)
PATCHES["Sources/AccountServices/AccountServer/main.cpp"] = (
    (
        b"static inline sLogProgram(BOOL bEnter)",
        b"static inline void sLogProgram(BOOL bEnter)",
    ),
    (
        b"if (SUCCEEDED( pFactroyFun( IID_IServerFactory, reinterpret_cast< void ** >(&pServerFactory ))))",
        b"if (pFactroyFun && SUCCEEDED( pFactroyFun( IID_IServerFactory, reinterpret_cast< void ** >(&pServerFactory ))) && pServerFactory)",
    ),
    (
        b"~TwoFixBuffer()\n\t{\n\t\t::LeaveCriticalSection(&m_switchsect);\n\t\t::DeleteCriticalSection(&m_switchsect);\n\t}",
        b"~TwoFixBuffer()\n\t{\n\t\t::DeleteCriticalSection(&m_switchsect);\n\t}",
    ),
    (
        b"if (nLen <= 0 || szInfo == NULL)\n\t\t\treturn FALSE;",
        b"if (nLen == 0 || szInfo == NULL ||\n\t\t\tnLen > MAX_BUFFER_LEN - sizeof(DWORD))\n\t\t\treturn FALSE;",
    ),
)
PATCHES["Build/Build-Modern.ps1"] += (
    (
        b"    $baseFlags = Convert-Cpp (Split-Args $p.Cpp) $p.Dir\n    # Bishop's headers",
        b"    $baseFlags = Convert-Cpp (Split-Args $p.Cpp) $p.Dir\n"
        b"    # Represent3 pulls a legacy basetsd.h via the DX9 project include path.\n"
        b"    # Prefer the installed Windows SDK shared headers to satisfy modern winnt.h.\n"
        b"    if ($name -eq 'Represent3') {\n"
        b"        $sdkShared = Join-Path $env:WindowsSdkDir ('Include\\' + $env:WindowsSDKVersion.TrimEnd('\\') + '\\shared')\n"
        b"        if (-not (Test-Path -LiteralPath (Join-Path $sdkShared 'basetsd.h'))) {\n"
        b"            throw 'Modern Windows SDK shared basetsd.h not found for Represent3.'\n"
        b"        }\n"
        b"        $baseFlags = @('/I' + $sdkShared) + @($baseFlags)\n"
        b"    }\n"
        b"    # Bishop's headers",
    ),
    (
        b"$r = Invoke-Tool 'rc.exe' @('/nologo', '/i', (Split-Path -Parent $rc), '/fo', $resOut, '/d', 'NDEBUG', '/l', '0x804', $rcSrc)",
        b"$r = Invoke-Tool 'rc.exe' @('/nologo', '/i', (Split-Path -Parent $rc), ('/fo' + $resOut), '/d', 'NDEBUG', '/l', '0x804', $rcSrc)",
    ),
)




# AccountServer legacy utilities relied on windows.h importing Winsock 1.
# The modern build deliberately suppresses Winsock 1 to avoid conflicts;
# include Winsock 2 before the Windows types instead, only on a build copy.
PATCHES["Sources/AccountServices/AccountServer/GlobalFun.h"] = (
    (
        b'#include "GlobalDTD.h"\n#include <WTypes.h>',
        b'#include <winsock2.h>\n#include "GlobalDTD.h"\n#include <WTypes.h>',
    ),
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

# Helper files belong to the patch working tree, not the original archive.
ADDITIONAL_FILES = {
    "Sources/AccountServices/AccountServer/GatewayEndpointParser.h":
        "overlays/legacy/GatewayEndpointParser.h",
    "Sources/AccountServices/AccountServer/AccountPacketBounds.h":
        "overlays/legacy/AccountPacketBounds.h",
}


def stage(target: Path, *, apply: bool) -> list[str]:
    target = target.resolve()
    repo_root = Path(__file__).resolve().parents[1]
    if apply and (target == repo_root or repo_root in target.parents):
        raise ValueError("Refusing to edit the tracked archive or any in-repository source.")

    staged: list[tuple[Path, bytes]] = []
    report: list[str] = []
    # Validate ALL patch contexts and helper files before changing any file.
    for rel in PATCHES:
        f = target.joinpath(*rel.split("/"))
        if f.is_symlink() or target not in f.resolve().parents:
            raise ValueError("Unsafe working-copy file: " + rel)
        original = f.read_bytes()
        modified = harden(rel, original)
        staged.append((f, modified))
        report.append(rel + (" (already patched)" if modified == original else " (needs patch)"))

    for rel, template in ADDITIONAL_FILES.items():
        dest = target.joinpath(*rel.split("/"))
        if dest.is_symlink() or target not in dest.resolve().parents:
            raise ValueError("Unsafe helper path: " + rel)
        data = (repo_root / template).read_bytes()
        if dest.exists() and (not dest.is_file() or dest.read_bytes() != data):
            raise ValueError("Conflicting helper file: " + rel)
        staged.append((dest, data))
        report.append(rel + (" (already installed)" if dest.exists() else " (new helper)"))

    if apply:
        for f, data in staged:
            if f.is_file():
                if f.read_bytes() != data:
                    f.write_bytes(data)
            else:
                f.parent.mkdir(parents=True, exist_ok=True)
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
