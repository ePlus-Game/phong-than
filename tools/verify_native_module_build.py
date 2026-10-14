#!/usr/bin/env python3
"""Verify fresh MSVC x86 module outputs without executing the legacy game.

CI checks out *source only* to a new external build directory. This verifier
checks its outputs; a staging EXE/DLL is never accepted as proof of compilation.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from .verify_windows_build import inspect_pe

MODULE_OUTPUTS = {
    "LuaLibDll": ("Client/LuaLibDll.dll", "Server/LuaLibDll.dll"),
    "Engine": ("Client/Engine.dll", "Server/Engine.dll"),
    "Common": ("lib/Common.lib",),
    "ExpandPackageStaticLib": ("lib/ExpandPackageStaticLib.lib",),
    "FilterTextStatic": ("lib/FilterText_StaticLib.lib",),
    "CoreServer": ("Server/CoreServer.dll",),
    "CoreClient": ("Client/CoreClient.dll",),
    "ExpandPackage": ("Client/ExpandPackage.dll", "Server/ExpandPackage.dll"),
    "FilterText": ("Client/FilterText.dll", "Server/FilterText.dll"),
    "Heaven": ("Client/Heaven.dll", "Server/Heaven.dll"),
    "Rainbow": ("Client/Rainbow.dll", "Server/Rainbow.dll"),
    "PhongThanRelay": ("Server/PhongThanRelay.exe",),
    "AccountServer": ("Server/PhongThanAccountServer.exe",),
    "Bishop": ("Server/Bishop.exe",),
    "Goddess": ("Server/Goddess.exe",),
    "GameServer": ("Server/GameServer.exe",),
    "Represent2": ("Client/Represent2.dll",),
    "Represent3": ("Client/Represent3.dll",),
    "GameClient": ("Client/Game.exe",),
}


def verify_modules(root: Path, modules: list[str]) -> dict:
    results: dict[str, dict] = {}
    success = True
    for module in modules:
        files = []
        errors = []
        for relative in MODULE_OUTPUTS[module]:
            candidate = root / relative
            if candidate.is_symlink():
                errors.append(f"{relative}: symlink not allowed")
                continue
            if not candidate.is_file():
                errors.append(f"{relative}: missing freshly-built artifact")
                continue
            try:
                if candidate.suffix.lower() == ".lib":
                    # COFF archives have a stable eight-byte signature; do not
                    # accept the presence of a stale or empty lib as success.
                    with candidate.open("rb") as handle:
                        if handle.read(8) != b"!<arch>\n":
                            raise ValueError("not a COFF .lib archive")
                    size = candidate.stat().st_size
                    if size <= 8:
                        raise ValueError("empty COFF archive")
                    with candidate.open("rb") as handle:
                        digest = hashlib.file_digest(handle, "sha256").hexdigest()
                else:
                    size, digest = inspect_pe(candidate, require_dll=candidate.suffix.lower() == ".dll")
            except (OSError, ValueError) as exc:
                errors.append(f"{relative}: {exc}")
                continue
            files.append({"path": relative, "bytes": size, "sha256": digest})
        results[module] = {
            "status": "FAIL" if errors else "PASS",
            "artifacts": files,
            "errors": errors,
        }
        if errors:
            success = False
    return {
        "status": "PASS" if success else "FAIL",
        "modules": results,
        "runtime_tested": False,
        "gameplay_tested": False,
        "source_build_only": True,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--module", choices=sorted(MODULE_OUTPUTS), action="append", required=True)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    report = verify_modules(args.output_root, args.module)
    result = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.report:
        args.report.write_text(result, encoding="utf-8")
    print(result, end="")
    return 0 if report["status"] == "PASS" else 2


if __name__ == "__main__":
    raise SystemExit(main())
