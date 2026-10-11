#!/usr/bin/env python3
"""Reproducibly package ONLY recovery tools; no original PT.zip or game files."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED

TOOLKIT_FILES = (
    "tools/legacy_hardening.py",
    "tools/release_preflight.py",
    "tools/Build-PatchedGame.ps1",
    "tools/audit_sensitive_paths.py",
    "docs/LEGACY_HARDENING.md",
    "docs/releases/v0.1.0-recovery.1.md",
)


def package(root: Path, destination: Path) -> dict:
    root = root.resolve()
    destination = destination.resolve()
    destination.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(destination, "w", compression=ZIP_DEFLATED, compresslevel=9) as z:
        for relative in TOOLKIT_FILES:
            source = root / relative
            if not source.is_file():
                raise FileNotFoundError(source)
            entry = ZipInfo(relative, (2026, 10, 11, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.external_attr = 0o644 << 16
            z.writestr(entry, source.read_bytes())
    data = destination.read_bytes()
    report = {
        "file": destination.name,
        "bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
        "source_archive_included": False,
        "game_executables_included": False,
        "files": list(TOOLKIT_FILES),
    }
    destination.with_suffix(".sha256").write_text(
        report["sha256"] + "  " + destination.name + "\n", encoding="utf-8"
    )
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = package(Path(__file__).resolve().parents[1], args.output)
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
