#!/usr/bin/env python3
"""Static preflight for a patched Windows build in a separate workspace."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

from tools.legacy_hardening import PATCHES, harden


def check_source(source: Path, destination: Path, toolchain: str,
                 *, check_sdk: bool = False) -> dict:
    repo_root = Path(__file__).resolve().parents[1]
    source = source.resolve(strict=True)
    destination = destination.resolve()
    if destination == repo_root or repo_root in destination.parents:
        raise ValueError("Workspace must be outside the Git checkout")
    if (destination == source or source in destination.parents
            or destination in source.parents):
        raise ValueError("Workspace must be separate from source tree")
    if toolchain not in ("Modern", "VC6"):
        raise ValueError("Unsupported toolchain")
    if not (source / "Sources").is_dir():
        raise ValueError("Missing game Sources directory")
    patch_files = []
    for rel in PATCHES:
        original = source.joinpath(*rel.split("/"))
        if not original.is_file():
            raise ValueError("Missing required source: " + rel)
        raw = original.read_bytes()
        modified = harden(rel, raw)
        if not modified:
            raise ValueError("Empty patch result: " + rel)
        patch_files.append({"path": rel, "needs_patch": modified != raw})
    if check_sdk:
        sdk_paths = (
            "ThirdParty/WindowsSDK/GDIPlus/Include/Gdiplus.h",
            "ThirdParty/WindowsSDK/GDIPlus/Lib/x86/GdiPlus.lib",
            "ThirdParty/dx9csdk/Include/d3dx9.h",
            "ThirdParty/dx9csdk/Lib/d3d9.lib",
            "ThirdParty/dx9csdk/Lib/ddraw.lib",
        )
        missing = [s for s in sdk_paths if not (source / s).is_file()]
        if missing:
            raise ValueError("Required SDK components are missing: " + ", ".join(missing))
    return {
        "status": "preflight_passed",
        "toolchain": toolchain,
        "workspace": str(destination),
        "source_paths_verified": len(patch_files),
        "files": patch_files,
        "sdk_verified": check_sdk,
        "game_built": False,
        "client_server_smoke_tested": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--workspace", type=Path, required=True)
    parser.add_argument("--toolchain", choices=("Modern", "VC6"), default="Modern")
    parser.add_argument("--check-sdk", action="store_true")
    args = parser.parse_args()
    result = check_source(args.source_root, args.workspace, args.toolchain,
                          check_sdk=args.check_sdk)
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
