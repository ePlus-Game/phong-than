#!/usr/bin/env python3
"""Offline import inventory for fresh Windows x86 Client/Server build outputs.

Parse normal and delay-loaded DLL names only. No PE is executed or loaded.
A PASS is structural, not evidence of Windows loader or gameplay readiness.
"""
from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path

from tools.verify_windows_build import EXPECTED

WINDOWS_DLLS = frozenset({
    "advapi32.dll", "bcrypt.dll", "cabinet.dll", "comctl32.dll", "comdlg32.dll",
    "crypt32.dll", "d3d9.dll", "ddraw.dll", "dsound.dll", "gdi32.dll",
    "gdiplus.dll", "imm32.dll", "iphlpapi.dll", "kernel32.dll", "mpr.dll",
    "msimg32.dll", "msvcrt.dll", "netapi32.dll", "ntdll.dll", "ole32.dll",
    "oleacc.dll", "oleaut32.dll", "opengl32.dll", "psapi.dll", "rpcrt4.dll",
    "secur32.dll", "setupapi.dll", "shell32.dll", "shlwapi.dll", "urlmon.dll",
    "user32.dll", "userenv.dll", "uxtheme.dll", "version.dll", "winhttp.dll",
    "wininet.dll", "winmm.dll", "winspool.drv", "ws2_32.dll", "wsock32.dll",
})


class ImportFormatError(ValueError):
    """Invalid or truncated PE import metadata."""


def _u16(buf: bytes, offset: int) -> int:
    if offset < 0 or offset + 2 > len(buf):
        raise ImportFormatError("truncated PE metadata")
    return struct.unpack_from("<H", buf, offset)[0]


def _u32(buf: bytes, offset: int) -> int:
    if offset < 0 or offset + 4 > len(buf):
        raise ImportFormatError("truncated PE metadata")
    return struct.unpack_from("<I", buf, offset)[0]


def read_imports(path: Path) -> tuple[list[str], list[str]]:
    """Read bounded PE32 IMAGE_IMPORT_DESCRIPTOR and ImgDelayDescr tables."""
    buf = path.read_bytes()
    if len(buf) < 256 or buf[:2] != b"MZ":
        raise ImportFormatError("missing DOS header")
    pe = _u32(buf, 0x3C)
    if pe < 64 or pe + 24 > len(buf) or buf[pe:pe + 4] != b"PE\0\0":
        raise ImportFormatError("invalid PE signature")
    if _u16(buf, pe + 4) != 0x14C:
        raise ImportFormatError("not an i386 image")
    num_sections = _u16(buf, pe + 6)
    optional_size = _u16(buf, pe + 20)
    opt = pe + 24
    if _u16(buf, opt) != 0x10B or optional_size < 96 or opt + optional_size > len(buf):
        raise ImportFormatError("invalid PE32 optional header")
    number_dirs = _u32(buf, opt + 92)
    size_headers = _u32(buf, opt + 60)
    image_base = _u32(buf, opt + 28)
    if num_sections == 0 or num_sections > 96 or pe + 24 + optional_size + num_sections * 40 > len(buf):
        raise ImportFormatError("invalid section table")
    sections: list[tuple[int, int, int]] = []
    section_start = opt + optional_size
    for index in range(num_sections):
        sh = section_start + index * 40
        virtual_address = _u32(buf, sh + 12)
        raw_size = _u32(buf, sh + 16)
        raw_offset = _u32(buf, sh + 20)
        if raw_size and (raw_offset > len(buf) or raw_size > len(buf) - raw_offset):
            raise ImportFormatError("section raw data extends beyond file")
        sections.append((virtual_address, raw_size, raw_offset))

    def rva_to_offset(rva: int, length: int = 1) -> int:
        if rva <= 0 or length < 0:
            raise ImportFormatError("invalid RVA")
        if rva < size_headers and length <= size_headers - rva and rva + length <= len(buf):
            return rva
        for start, raw_size, raw_offset in sections:
            if start <= rva and rva - start < raw_size and length <= raw_size - (rva - start):
                return raw_offset + (rva - start)
        raise ImportFormatError("unmapped import RVA")

    def name_from_rva(rva: int) -> str:
        off = rva_to_offset(rva)
        null = buf.find(b"\0", off, min(len(buf), off + 260))
        if null < 0:
            raise ImportFormatError("unterminated import DLL name")
        try:
            name = buf[off:null].decode("ascii").strip()
        except UnicodeDecodeError as exc:
            raise ImportFormatError("non-ASCII import DLL name") from exc
        if not name or any(ord(c) < 33 or ord(c) > 126 for c in name):
            raise ImportFormatError("invalid import DLL name")
        if "/" in name or "\\" in name or ":" in name or ".." in name:
            raise ImportFormatError("unsafe import DLL name")
        return name.lower()

    def directory(index: int) -> tuple[int, int]:
        if index >= number_dirs or optional_size < 96 + (index + 1) * 8:
            return (0, 0)
        return (_u32(buf, opt + 96 + 8 * index), _u32(buf, opt + 100 + 8 * index))

    def read_directory(index: int, entry_size: int, dll_offset: int, is_delay: bool = False) -> list[str]:
        rva, length = directory(index)
        if not rva and not length:
            return []
        if not rva or length < entry_size or length > len(buf) * 4:
            raise ImportFormatError("incomplete import directory")
        found: list[str] = []
        terminated = False
        for entry_index in range(min(length // entry_size, 1024)):
            at = rva_to_offset(rva + entry_size * entry_index, entry_size)
            entry = buf[at:at + entry_size]
            if entry == bytes(entry_size):
                terminated = True
                break
            dll_rva = struct.unpack_from("<I", entry, dll_offset)[0]
            if is_delay and not (struct.unpack_from("<I", entry, 0)[0] & 1):
                if dll_rva < image_base:
                    raise ImportFormatError("invalid delay import VA")
                dll_rva -= image_base
            found.append(name_from_rva(dll_rva))
        if not terminated:
            raise ImportFormatError("unterminated import descriptor table")
        return sorted(set(found))

    return read_directory(1, 20, 12), read_directory(13, 32, 4, is_delay=True)


def audit_build(output_root: Path) -> dict:
    """Fail if a project-local imported DLL is missing; list unproven externals."""
    artifacts: list[dict] = []
    failures: list[str] = []
    external: set[str] = set()
    project_dlls = {
        name.casefold() for names in EXPECTED.values() for name in names
        if name.lower().endswith(".dll")
    }
    for role, names in EXPECTED.items():
        available = {n.casefold() for n in names}
        for name in names:
            rel = f"{role}/{name}"
            path = output_root / role / name
            if path.is_symlink() or not path.is_file():
                failures.append(f"{rel}: missing or symlinked binary")
                continue
            try:
                regular, delayed = read_imports(path)
            except (OSError, ValueError) as exc:
                failures.append(f"{rel}: {exc}")
                continue
            groups = {"local": [], "windows": [], "external": [], "cross_role_missing": []}
            for dll in sorted(set(regular + delayed)):
                key = dll.casefold()
                if key in available:
                    groups["local"].append(dll)
                elif key in project_dlls:
                    groups["cross_role_missing"].append(dll)
                    failures.append(f"{rel}: game DLL {dll} missing from {role}")
                elif key in WINDOWS_DLLS or key.startswith(("api-ms-win-", "ext-ms-win-")):
                    groups["windows"].append(dll)
                else:
                    groups["external"].append(dll)
                    external.add(dll)
            artifacts.append({"path": rel, "imports": regular, "delay_imports": delayed,
                              "classifications": groups})
    return {
        "status": "FAIL" if failures else "PASS",
        "expected_binary_count": sum(len(names) for names in EXPECTED.values()),
        "analyzed_binary_count": len(artifacts),
        "external_runtime_dependencies_unverified": sorted(external),
        "artifacts": artifacts,
        "failures": failures,
        "os_loader_tested": False,
        "runtime_tested": False,
        "gameplay_tested": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = audit_build(args.output_root)
    data = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.report:
        args.report.write_text(data, encoding="utf-8")
    print(data, end="")
    return 0 if result["status"] == "PASS" else 2


if __name__ == "__main__":
    raise SystemExit(main())
