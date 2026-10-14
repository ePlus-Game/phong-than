#!/usr/bin/env python3
"""Stage narrowly scoped C++ compatibility patches in an EXTERNAL AccountServer build copy.

The archive and staged runtime inside the Git repository are never patched.
The full-game builder continues to use legacy_hardening.stage for all projects.
"""
from __future__ import annotations

import argparse
from pathlib import Path

from tools.legacy_hardening import ADDITIONAL_FILES, harden

ACCOUNT_PATCH_PATHS = (
    "Build/Build-Modern.ps1",
    "Sources/AccountServices/AccountServer/main.cpp",
    "Sources/AccountServices/AccountServer/S3PDBSocketPool.cpp",
)


def prepare(target: Path) -> list[str]:
    repository = Path(__file__).resolve().parents[1]
    target = target.resolve()
    if target == repository or repository in target.parents:
        raise ValueError("refusing in-repository modifications")
    if not target.is_dir():
        raise ValueError("missing external build workspace")

    # Validate every patch/context and helper collision before writing anything.
    pending: list[tuple[Path, bytes]] = []
    for rel in ACCOUNT_PATCH_PATHS:
        path = target.joinpath(*rel.split("/"))
        if path.is_symlink() or not path.is_file() or target not in path.resolve().parents:
            raise ValueError("missing/unsafe AccountServer source: " + rel)
        patched = harden(rel, path.read_bytes())
        pending.append((path, patched))
    for rel, template in ADDITIONAL_FILES.items():
        path = target.joinpath(*rel.split("/"))
        if path.is_symlink() or target not in path.resolve().parents:
            raise ValueError("unsafe AccountServer helper: " + rel)
        data = (repository / template).read_bytes()
        if path.exists() and (not path.is_file() or path.read_bytes() != data):
            raise ValueError("conflicting AccountServer helper: " + rel)
        pending.append((path, data))
    for path, data in pending:
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.is_file() or path.read_bytes() != data:
            path.write_bytes(data)
    return [str(path.relative_to(target)).replace("\\", "/") for path, _ in pending]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", type=Path, required=True)
    args = parser.parse_args()
    for result in prepare(args.target):
        print("STAGED " + result)
    print("External AccountServer build copy prepared; no game build has run.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
