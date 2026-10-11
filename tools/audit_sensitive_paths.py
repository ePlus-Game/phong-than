#!/usr/bin/env python3
"""Inventory paths that may contain private/runtime data. Never print contents.

Informational by default: the original PT.zip has already been made public.
This is not a secret scanner and does not establish that publication is safe.
"""
from __future__ import annotations
import argparse
from collections import Counter
import json
from pathlib import Path
import subprocess


def categorize(path: str) -> set[str]:
    p = path.replace("\\", "/").lower()
    found: set[str] = set()
    if p.endswith((".bak", ".bak.gz", ".sql.bak")):
        found.add("database_or_other_backup")
    if "/characterstore/" in p or p.endswith(".pthc"):
        found.add("character_save_data")
    if any("/server/" + x + "/" in p for x in (
            "database", "databasetong", "databasetongmember",
            "tongdb", "tongmemberdb", "dbfriend")):
        found.add("runtime_database_files")
    if p.endswith(".log") or "/logs/" in p or "/payserver_log/" in p:
        found.add("operational_logs")
    if "/phongthanruntime-staging/server/" in p and p.endswith((".ini", ".cfg")):
        found.add("server_configuration")
    if p.endswith("original-dot-git.zip"):
        found.add("archived_git_history")
    return found


def audit(paths: list[str]) -> dict:
    counts: Counter[str] = Counter()
    for path in paths:
        counts.update(categorize(path))
    return {
        "tracked_files": len(paths),
        "possible_sensitive_categories": dict(sorted(counts.items())),
        "caution": (
            "Filenames only; contents were not opened. These categories may be "
            "test data or sensitive. Public Git history persists after deletion."
        ),
    }


def markdown(report: dict) -> str:
    lines = [
        "# Public archive risk inventory", "",
        "Read-only filename audit; no account names, tokens or file contents emitted.",
        "",
        f"Tracked files reviewed: {report['tracked_files']}", "",
        "| Category | Matching paths |", "| --- | ---: |",
    ]
    for key, count in report["possible_sensitive_categories"].items():
        lines.append(f"| {key.replace('_', ' ')} | {count} |")
    lines.extend(["", "This is a warning, not a disclosure clearance. "
                  "Review files privately and remove/rotate real secrets.",
                  "Deleting files in new commits does not remove Git history."])
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json", type=Path)
    ap.add_argument("--markdown", type=Path)
    ap.add_argument("--strict", action="store_true",
                    help="Fail if suspicious categories exist (not CI default).")
    args = ap.parse_args()
    completed = subprocess.run(
        ["git", "ls-files", "-z"], capture_output=True, check=True
    )
    paths = [
        x.decode("utf-8", "surrogateescape")
        for x in completed.stdout.split(b"\x00") if x
    ]
    report = audit(paths)
    if args.json:
        args.json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    md = markdown(report)
    if args.markdown:
        args.markdown.write_text(md, encoding="utf-8")
    print(md)
    return int(args.strict and bool(report["possible_sensitive_categories"]))


if __name__ == "__main__":
    raise SystemExit(main())
