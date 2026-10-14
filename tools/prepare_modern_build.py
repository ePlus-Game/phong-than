#!/usr/bin/env python3
"""Remove archived Modern build outputs from a verified EXTERNAL source copy.

Only the copied OutputModern and Build/LogsModern directories are removed.
The original PhongThanSource archive is never changed by this command.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil


TARGETS = ("OutputModern", "Build/LogsModern")


def _overlaps(first: Path, second: Path) -> bool:
    return first == second or first in second.parents or second in first.parents


def _is_link(path: Path) -> bool:
    is_junction = getattr(os.path, "isjunction", lambda _: False)
    return path.is_symlink() or is_junction(path)


def prepare_clean_copy(work_root: Path, source_root: Path, repo_root: Path) -> dict:
    """Refuse paths that overlap source/checkout or traverse a link/junction."""
    for value in (work_root, source_root, repo_root):
        if _is_link(value):
            raise ValueError("Root cannot be a symlink or junction")

    work = work_root.resolve(strict=True)
    source = source_root.resolve(strict=True)
    repo = repo_root.resolve(strict=True)
    if not (work.is_dir() and source.is_dir() and repo.is_dir()):
        raise ValueError("All roots must be directories")
    if _overlaps(work, source) or _overlaps(work, repo):
        raise ValueError("WorkRoot must be outside the source and repository")

    if not (work / "Sources").is_dir() or not (work / "Build/Build-Modern.ps1").is_file():
        raise ValueError("WorkRoot does not look like a copied game source")

    # Validate all targets before removing any directory.
    paths = []
    for target in TARGETS:
        path = work / target
        for part in (path, *list(path.parents)[:-1]):
            if part == work:
                break
            if _is_link(part):
                raise ValueError(f"Build output is a symlink or junction: {target}")
        if path.exists():
            if not path.is_dir():
                raise ValueError(f"Expected directory, not a file: {target}")
            paths.append((target, path))

    for _, path in paths:
        shutil.rmtree(path)

    return {
        "status": "clean_copy_ready",
        "removed": [target for target, _ in paths],
        "source_archive_modified": False,
        "game_built": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-root", type=Path, required=True)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--repo-root", type=Path, required=True)
    args = parser.parse_args()
    result = prepare_clean_copy(args.work_root, args.source_root, args.repo_root)
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
