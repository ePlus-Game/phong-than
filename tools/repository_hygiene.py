#!/usr/bin/env python3
"""Read-only Git-tree inventory of historical archive and generated-file clutter.

Uses tree metadata only; no runtime logs, database contents or PAKs are read.
Output contains aggregate counts and byte totals, never sensitive filenames.
"""
from __future__ import annotations

import argparse
from collections import Counter
import json
from pathlib import Path
import subprocess

GROUPS = (
    "original_backups",
    "runtime_logs",
    "debug_symbols",
    "historical_build_outputs",
    "sql_and_character_state",
    "split_pak_parts",
)
DISPLAY = {
    "original_backups": "Original _backup/ copies",
    "runtime_logs": "Runtime and control logs",
    "debug_symbols": "PDB and linker debug files",
    "historical_build_outputs": "Historical compiled/build outputs",
    "sql_and_character_state": "Database or character state (sensitive)",
    "split_pak_parts": "Split large PAK assets",
}
VISIBLE_ROOTS = {
    "PhongThanSource", "PhongThanRuntime-Staging", "PhongThanRuntime-State",
    "_backup", "AdminWeb", "install", "archive", "docs", "tools", "tests",
    ".github", "overlays",
}


def parse_tree(data: bytes):
    """Yield (repository relative path, size, SHA) from git ls-tree -r -l -z."""
    for record in data.split(b"\x00"):
        if not record:
            continue
        try:
            header, raw_path = record.split(b"\t", 1)
            mode, kind, raw_sha, raw_size = header.split(b" ")
        except ValueError as exc:
            raise ValueError("Malformed Git tree entry") from exc
        if kind != b"blob":
            continue
        if len(raw_sha) != 40 or (not raw_size.isdigit() and raw_size != b"-"):
            raise ValueError("Malformed Git blob metadata")
        path = raw_path.decode("utf-8", "surrogateescape")
        yield path, (int(raw_size) if raw_size.isdigit() else None), raw_sha.decode("ascii")


def groups_for(path: str):
    norm = path.replace("\\", "/")
    lower = norm.lower()
    name = lower.rsplit("/", 1)[-1]
    if norm.startswith("_backup/"):
        yield "original_backups"
    if norm.startswith("PhongThanRuntime-Staging/") and (
        name.endswith(".log") or name.endswith(".log.err")
        or "/ControlLogs/" in norm
    ):
        yield "runtime_logs"
    if name.endswith((".pdb", ".ilk", ".idb", ".pch", ".ncb")):
        yield "debug_symbols"
    if (
        norm.startswith("PhongThanSource/Output/")
        or norm.startswith("PhongThanSource/OutputModern/")
        or norm.startswith("PhongThanSource/Build/LogsModern/")
    ):
        yield "historical_build_outputs"
    if (
        norm.startswith("PhongThanRuntime-State/")
        or norm.startswith("PhongThanRuntime-Staging/Server/CharacterStore/")
        or norm.startswith("PhongThanRuntime-Staging/Server/database/")
        or norm.startswith("PhongThanRuntime-Staging/Server/databasetong/")
        or norm.startswith("PhongThanRuntime-Staging/Server/databasetongmember/")
    ):
        yield "sql_and_character_state"
    if ".pak.parts/part-" in lower and name.endswith(".bin"):
        yield "split_pak_parts"


def summarize(entries) -> dict:
    root_count: Counter[str] = Counter()
    root_bytes: Counter[str] = Counter()
    class_count: Counter[str] = Counter()
    class_bytes: Counter[str] = Counter()
    blobs: Counter[str] = Counter()
    number = 0
    bytes_total = 0
    sizes_available = True
    for path, size, sha in entries:
        number += 1
        if size is None:
            sizes_available = False
        else:
            bytes_total += size
        root = path.split("/", 1)[0]
        if root not in VISIBLE_ROOTS:
            root = "Other root items"
        root_count[root] += 1
        root_bytes[root] += size or 0
        blobs[sha] += 1
        for group in groups_for(path):
            class_count[group] += 1
            class_bytes[group] += size or 0
    return {
        "tracked_files": number,
        "logical_bytes": bytes_total if sizes_available else None,
        "repeated_blob_references": sum(count - 1 for count in blobs.values() if count > 1),
        "roots": [
            {"group": key, "files": root_count[key], "logical_bytes": root_bytes[key] if sizes_available else None}
            for key in sorted(root_count, key=lambda x: (-root_count[x] if not sizes_available else -root_bytes[x], x))
        ],
        "categories": [
            {"group": key, "files": class_count[key], "logical_bytes": class_bytes[key] if sizes_available else None}
            for key in GROUPS
        ],
        "note": (
            "Size is the sum of tracked blob references, not disk or network usage. "
            "Categories overlap. Identical Git blobs are already deduplicated by Git. "
            "This report does not inspect contents or authorize deletion."
        ),
    }


def markdown(report: dict) -> str:
    def mib(size: int) -> str:
        return f"{size / 1048576:,.1f} MiB" if size is not None else "not measured"

    lines = [
        "### Repository hygiene (read-only Git tree)",
        f"Tracked files: **{report['tracked_files']:,}**; "
        f"logical bytes: **{mib(report['logical_bytes'])}**. "
        "No file contents inspected.",
        "",
        "| Category (overlapping) | Files | Logical size |",
        "| --- | ---: | ---: |",
    ]
    for item in report["categories"]:
        lines.append(
            f"| {DISPLAY[item['group']]} | {item['files']:,} | "
            f"{mib(item['logical_bytes'])} |"
        )
    lines.extend([
        "",
        f"Repeated Git blob references: **{report['repeated_blob_references']:,}** "
        "(not recoverable storage savings: Git deduplicates identical blobs).",
        "",
        report["note"],
        "",
        "No historical files were removed. Do not publish live logs, character "
        "data, SQL backups or credentials as CI artifacts.",
    ])
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--no-sizes", action="store_true", help="Count paths and blob references without fetching blobs in partial clone")
    args = parser.parse_args()
    result = subprocess.run(
        ["git", "-C", str(args.repo_root), "ls-tree", "-r"] + ([] if args.no_sizes else ["-l"]) + ["-z", "HEAD"],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False,
    )
    if result.returncode:
        raise SystemExit("Unable to read tracked Git tree (no content read)")
    report = summarize(parse_tree(result.stdout))
    out = (json.dumps(report, indent=2, ensure_ascii=True) + "\n"
           if args.format == "json" else markdown(report))
    if args.output:
        args.output.write_text(out, encoding="utf-8")
    else:
        print(out, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
