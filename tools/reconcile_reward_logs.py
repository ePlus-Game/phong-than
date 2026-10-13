#!/usr/bin/env python3
"""Read-only summary of reward and pet-refund anomaly logs from an isolated game server.

Does not modify saves, items, Lua queues, account data or log inputs. Reports only
aggregate counts, never player names, account IDs or individual transaction IDs.
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

COUNTS = re.compile(r"\bitems=(\d+)/(\d+)\b")
MISSING = re.compile(r"\bmissing=(\d+)\b")
ADMIN = re.compile(r"\btargets=(\d+)\s+complete=(\d+)\s+partial=(\d+)\s+failed=(\d+)\b")


def summarize(daily: str = "", pet: str = "", admin: str = "") -> dict:
    stats = {
        "daily_partial": 0,
        "daily_missing_items": 0,
        "pet_refund_partial": 0,
        "pet_missing_items": 0,
        "admin_partial_or_failed": 0,
        "admin_incomplete_targets": 0,
        "unrecognized_log_lines": 0,
    }

    for line in daily.splitlines():
        if not line.strip():
            continue
        cols = line.split("\t")
        if len(cols) < 5 or cols[1] != "PARTIAL":
            stats["unrecognized_log_lines"] += 1
            continue
        match = COUNTS.search(cols[4])
        if not match:
            stats["unrecognized_log_lines"] += 1
            continue
        got, expected = map(int, match.groups())
        if expected < got or got < 0:
            stats["unrecognized_log_lines"] += 1
            continue
        stats["daily_partial"] += 1
        stats["daily_missing_items"] += expected - got

    for line in pet.splitlines():
        if not line.strip():
            continue
        cols = line.split("\t")
        if len(cols) < 5 or cols[1] != "PARTIAL":
            stats["unrecognized_log_lines"] += 1
            continue
        match = MISSING.search(cols[4])
        if not match or int(match.group(1)) <= 0:
            stats["unrecognized_log_lines"] += 1
            continue
        stats["pet_refund_partial"] += 1
        stats["pet_missing_items"] += int(match.group(1))

    for line in admin.splitlines():
        if not line.strip():
            continue
        cols = line.split("\t", 3)
        if len(cols) < 4 or cols[2] not in ("PARTIAL", "FAIL"):
            # Ordinary OK records and unrelated admin commands do not signal a
            # reward issue; never use a freeform player name as an error message.
            continue
        stats["admin_partial_or_failed"] += 1
        match = ADMIN.search(cols[3])
        if match:
            targets, complete, partial, failed = map(int, match.groups())
            if complete + partial + failed != targets:
                stats["unrecognized_log_lines"] += 1
            else:
                stats["admin_incomplete_targets"] += partial + failed

    stats["requires_gm_reconciliation"] = any(
        stats[k] > 0 for k in (
            "daily_partial", "pet_refund_partial", "admin_partial_or_failed",
            "unrecognized_log_lines",
        )
    )
    stats["safe_to_automatically_retry"] = False
    stats["proof_of_atomic_game_transactions"] = False
    return stats


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--daily-log", type=Path)
    parser.add_argument("--pet-log", type=Path)
    parser.add_argument("--admin-log", type=Path)
    parser.add_argument("--fail-on-anomaly", action="store_true")
    args = parser.parse_args()

    def load(path: Path | None) -> str:
        if path is None:
            return ""
        return path.read_text(encoding="utf-8", errors="replace")

    report = summarize(load(args.daily_log), load(args.pet_log), load(args.admin_log))
    print(json.dumps(report, indent=2))
    return 2 if args.fail_on_anomaly and report["requires_gm_reconciliation"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
