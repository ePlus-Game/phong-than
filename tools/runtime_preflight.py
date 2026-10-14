#!/usr/bin/env python3
"""Read-only preflight for a copied Windows Phong Than UAT runtime.

Never runs EXEs, connects to DB, changes assets, or reads database secrets.
Passing means only that the files are ready for Windows runtime testing.
"""
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path
try:
    from .verify_windows_build import verify_build
except ImportError:
    from verify_windows_build import verify_build

SERVER_EXES = (
    "Goddess.exe", "PhongThanAccountServer.exe", "PhongThanRelay.exe",
    "Bishop.exe", "GameServer.exe",
)
COUNT = re.compile(rb"(?m)^[ \t]*Count[ \t]*=[ \t]*(\d+)[ \t]*\r?$")


def count_maps(path: Path) -> int | None:
    if not path.is_file() or path.is_symlink():
        return None
    matches = COUNT.findall(path.read_bytes())
    return int(matches[0]) if len(matches) == 1 else None


def run_preflight(root: Path, *, mode: str = "runtime",
                  manifest: Path | None = None, expected_maps: int = 102) -> dict:
    if mode not in ("bundle", "runtime"):
        raise ValueError("invalid mode")
    if not 1 <= expected_maps <= 10000:
        raise ValueError("expected_maps outside permitted range")
    root = root.resolve()
    base = verify_build(root)
    failures = list(base["failures"])
    warnings = []
    checks = {}
    if mode == "runtime":
        server = root / "Server"
        for rel in ("Server/ServerCfg.ini", "Server/DataBase.ini",
                    "Server/maps/WorldSet.ini"):
            path = root.joinpath(*rel.split("/"))
            valid = path.is_file() and not path.is_symlink()
            checks[rel] = "PRESENT" if valid else "MISSING"
            if not valid:
                failures.append(f"{rel}: missing or invalid config")
        actual = count_maps(server / "maps" / "WorldSet.ini")
        checks["map_count"] = actual
        if actual != expected_maps:
            failures.append("world set expected %d maps; %s" % (
                expected_maps, "count missing or ambiguous" if actual is None
                else "found %d" % actual
            ))
        for old in ("S3Relay.exe", "S3RelayServer.exe",
                    "PhongThanRelayServer.exe"):
            if (server / old).exists():
                failures.append("obsolete relay executable present: " + old)
        checks["expected_services"] = list(SERVER_EXES)
    if manifest:
        if not manifest.is_file() or manifest.is_symlink():
            failures.append("runtime manifest missing or symlink")
        else:
            try:
                cfg = json.loads(manifest.read_text(encoding="utf-8-sig"))
                expected = int(cfg["DataRegistries"]["Gameplay"]["Map"]
                               ["ExpectedActiveMapCount"])
                if expected != expected_maps:
                    failures.append("manifest map count differs from expected")
                mapping = cfg["RuntimeSettings"]["ExpectedListeningPorts"]
                if ("PhongThanRelay.exe" not in mapping or
                        "S3Relay.exe" in mapping):
                    failures.append("manifest relay key obsolete; require PhongThanRelay.exe")
                if not set(SERVER_EXES).issubset(mapping):
                    failures.append("manifest missing a required native service")
                checks["manifest_topology"] = (
                    "VALID" if set(SERVER_EXES).issubset(mapping) and
                    "S3Relay.exe" not in mapping else "MISMATCH"
                )
            except (OSError, ValueError, TypeError, KeyError):
                failures.append("invalid runtime manifest schema")
    else:
        warnings.append("manifest omitted; port mapping not checked")
    return {
        "status": "READY_FOR_RUNTIME_TEST" if not failures else "BLOCKED",
        "scope": "read_only_static_preflight",
        "expected_binary_count": base["expected_binary_count"],
        "verified_binary_count": base["verified_binary_count"],
        "artifacts": base["artifacts"],
        "checks": checks, "failures": failures, "warnings": warnings,
        "process_started": False, "database_modified": False,
        "runtime_tested": False, "login_tested": False, "gameplay_tested": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--mode", choices=("bundle", "runtime"), default="runtime")
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--expected-maps", type=int, default=102)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    report = run_preflight(args.root, mode=args.mode, manifest=args.manifest,
                           expected_maps=args.expected_maps)
    data = json.dumps(report, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(data, encoding="utf-8")
    print(data, end="")
    return 0 if report["status"] == "READY_FOR_RUNTIME_TEST" else 2


if __name__ == "__main__":
    raise SystemExit(main())
