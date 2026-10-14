#!/usr/bin/env python3
"""Fail-closed inventory, PE32 x86 header and SHA-256 verification for a copied Windows build.

This checks structural properties of the generated binaries. It cannot prove that
the programs actually start, have all their dynamic dependencies, or pass gameplay.
No game processes are launched and no binary data is uploaded.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path

# The Modern builder emits these names (which differ from certain legacy
# staging names, e.g. PhongThanRelay.exe vs PhongThanRelayServer.exe).
EXPECTED: dict[str, tuple[str, ...]] = {
    "Client": (
        "Game.exe", "Engine.dll", "LuaLibDll.dll", "CoreClient.dll",
        "ExpandPackage.dll", "FilterText.dll", "Heaven.dll", "Rainbow.dll",
        "Represent2.dll", "Represent3.dll",
    ),
    "Server": (
        "Engine.dll", "LuaLibDll.dll", "CoreServer.dll",
        "ExpandPackage.dll", "FilterText.dll", "Heaven.dll", "Rainbow.dll",
        "PhongThanAccountServer.exe", "PhongThanRelay.exe",
        "Bishop.exe", "Goddess.exe", "GameServer.exe",
    ),
}

PE32_MAGIC = 0x10B
I386_MACHINE = 0x14C
EXECUTABLE_FLAG = 0x0002
DLL_FLAG = 0x2000


def inspect_pe(path: Path, *, require_dll: bool) -> tuple[int, str]:
    """Return (file byte size, SHA256). Reject truncation, x64 and DLL/EXE mismatch."""
    size = path.stat().st_size
    if size < 512:
        raise ValueError("truncated file (less than 512 bytes)")
    with path.open("rb") as handle:
        header = handle.read(64)
        if len(header) != 64 or header[:2] != b"MZ":
            raise ValueError("missing MZ executable header")
        pe_offset = struct.unpack_from("<I", header, 0x3C)[0]
        if pe_offset < 64 or pe_offset > min(size - 26, 1_048_576):
            raise ValueError("invalid PE offset")
        handle.seek(pe_offset)
        pe = handle.read(26)
        if len(pe) < 26 or pe[:4] != b"PE\0\0":
            raise ValueError("missing PE signature")
        machine, sections, _, _, _, optional_size, flags = struct.unpack_from(
            "<HHIIIHH", pe, 4
        )
        if machine != I386_MACHINE:
            raise ValueError("not an x86/i386 binary")
        if sections == 0 or optional_size < 96:
            raise ValueError("missing PE sections or optional header")
        if pe_offset + 24 + optional_size > size:
            raise ValueError("truncated PE optional header")
        magic = struct.unpack_from("<H", pe, 24)[0]
        if magic != PE32_MAGIC:
            raise ValueError("not a PE32 image")
        if not flags & EXECUTABLE_FLAG:
            raise ValueError("PE executable image flag missing")
        if bool(flags & DLL_FLAG) != require_dll:
            raise ValueError("DLL/EXE image type mismatch")

        handle.seek(0)
        digest = hashlib.sha256()
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return size, digest.hexdigest()


def verify_build(output_root: Path) -> dict:
    """Read-only verification. Only output names, sizes and hashes are reported."""
    artifacts: list[dict] = []
    failures: list[str] = []
    output_root = output_root.resolve()

    if not output_root.is_dir():
        failures.append("OutputModern directory does not exist")
    else:
        for role, names in EXPECTED.items():
            for name in names:
                rel = f"{role}/{name}"
                path = output_root / role / name
                if path.is_symlink():
                    failures.append(f"{rel}: symlink not allowed")
                    continue
                if not path.is_file():
                    failures.append(f"{rel}: missing binary")
                    continue
                try:
                    size, digest = inspect_pe(path, require_dll=name.lower().endswith(".dll"))
                except (OSError, ValueError) as exc:
                    failures.append(f"{rel}: {exc}")
                    continue
                artifacts.append({
                    "path": rel,
                    "bytes": size,
                    "sha256": digest,
                    "machine": "I386",
                    "image_type": "DLL" if name.lower().endswith(".dll") else "EXE",
                })
    expected_count = sum(len(names) for names in EXPECTED.values())
    return {
        "status": "PASS" if not failures else "FAIL",
        "expected_binary_count": expected_count,
        "verified_binary_count": len(artifacts),
        "artifacts": artifacts,
        "failures": failures,
        "runtime_tested": False,
        "network_tested": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--report", type=Path, help="JSON output file (contains filenames/hashes only)")
    args = parser.parse_args()
    report = verify_build(args.output_root)
    data = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.report is not None:
        args.report.write_text(data, encoding="utf-8")
    print(data, end="")
    return 0 if report["status"] == "PASS" else 2


if __name__ == "__main__":
    raise SystemExit(main())
