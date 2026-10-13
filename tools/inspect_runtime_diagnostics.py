#!/usr/bin/env python3
"""Read-only aggregate check of saved native client/server Lua and skill diagnostics.

Designed for *copied test logs*. Does not contact game services or expose
log lines, character names, server addresses or filesystem paths in JSON.
A saved log is historical evidence, not proof of current runtime health.
"""
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path

REGISTRY = re.compile(r"loaded=(\d+)\s+failed=(\d+)\s+capacity=(\d+)")
SKILL = re.compile(r"repair skill=(\d+)\s+result=(found|missing)\s+height=(\d+)(?:\s+row=\d+\s+style=\d+\s+max=\d+)?")


def registry_status(contents: str) -> dict:
    records = [s.strip() for s in contents.splitlines() if s.strip()]
    if not records:
        return {"status": "MISSING_EVIDENCE"}
    if len(records) != 1:
        return {"status": "MALFORMED", "records": len(records)}
    match = REGISTRY.fullmatch(records[0])
    if not match:
        return {"status": "MALFORMED", "records": 1}
    loaded, failed, capacity = map(int, match.groups())
    status = "OK" if loaded > 0 and failed == 0 and capacity >= loaded else "ALERT"
    return {"status": status, "loaded": loaded, "failed": failed, "capacity": capacity}


def skill_status(contents: str) -> dict:
    found: Counter[str] = Counter()
    missing: Counter[str] = Counter()
    unknown = 0
    for line in contents.splitlines():
        if not line.strip():
            continue
        match = SKILL.fullmatch(line.strip())
        if not match:
            # Preserve evidence of unfamiliar result variants instead of silently
            # treating them as successful repairs.
            unknown += 1
            continue
        skill_id, result, height = match.groups()
        (found if result == "found" else missing)[f"{skill_id}@{height}"] += 1
    # Aggregating by ID/height avoids exposing raw log data or reporting
    # repeated identical repair messages as independent skill IDs.
    status = ("MISSING_EVIDENCE" if not contents.strip() else
              "ALERT" if missing or unknown else "OK")
    return {
        "status": status,
        "found_events": sum(found.values()),
        "missing_events": sum(missing.values()),
        "unrecognized_events": unknown,
        "missing_skill_locations": dict(sorted(missing.items())),
    }


def evaluate(client_registry: str | None = None, server_registry: str | None = None,
             client_skill: str | None = None, server_skill: str | None = None) -> dict:
    registry = {
        "client": registry_status(client_registry or ""),
        "server": registry_status(server_registry or ""),
    }
    skills = {
        "client": skill_status(client_skill or ""),
        "server": skill_status(server_skill or ""),
    }
    result = {
        "script_registry": registry,
        "skill_repair": skills,
        "historical_log_evidence_only": True,
        "gameplay_verified": False,
    }
    result["requires_investigation"] = any(
        part["status"] != "OK"
        for group in (registry, skills)
        for part in group.values()
    )
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client-script-registry", type=Path, required=True)
    parser.add_argument("--server-script-registry", type=Path, required=True)
    parser.add_argument("--client-skill-log", type=Path, required=True)
    parser.add_argument("--server-skill-log", type=Path, required=True)
    args = parser.parse_args()
    try:
        texts = [p.read_text(encoding="utf-8", errors="replace") for p in (
            args.client_script_registry, args.server_script_registry,
            args.client_skill_log, args.server_skill_log,
        )]
    except OSError:
        # Deliberately do not echo raw path, exception or file content.
        print(json.dumps({"status": "MISSING_INPUT", "requires_investigation": True}))
        return 2
    report = evaluate(*texts)
    print(json.dumps(report, indent=2, sort_keys=True))
    return 2 if report["requires_investigation"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
