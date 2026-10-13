#!/usr/bin/env python3
"""Produce Huyen Vuc Ky user-facing branding in an external build overlay.

The PT archive/source mirror is immutable: this program NEVER updates inputs.
It emits only text files (no PAK, icon, executable or private character data).
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

DISPLAY_NAME = "Huyền Vực Ký"
LEGACY_ENCODED_NAME = "Huyen Vuc Ky"

# Use byte-exact replacement to avoid corrupting the legacy CP936/TCVN3 text.
# Locations like "Phong Than Dai" and all serialized identifiers stay intact.
REPLACEMENTS = {
    "PhongThanRuntime-Staging/Client/Ui/Setting.ini": [
        (b"GameName=Phong Than Online", b"GameName=Huyen Vuc Ky"),
        (b"22=Ban co muon thoat khoi Phong Than Online?",
         b"22=Ban co muon thoat khoi Huyen Vuc Ky?"),
        (b"23=Phong Than Online", b"23=Huyen Vuc Ky"),
    ],
    "PhongThanRuntime-Staging/Client/serverlist.ini": [
        (b"Region_0=Phong Than Online (DEV AG v1)",
         b"Region_0=Huyen Vuc Ky (DEV)"),
        (b"Region_1=Cum May Chu Phong Than",
         b"Region_1=Cum May Chu Huyen Vuc Ky"),
    ],
    "AdminWeb/index.html": [
        ("<title>Phong Thần Admin</title>".encode("utf-8"),
         ("<title>" + DISPLAY_NAME + " Admin</title>").encode("utf-8")),
        ("<h1>Phong Thần Admin</h1>".encode("utf-8"),
         ("<h1>" + DISPLAY_NAME + " Admin</h1>").encode("utf-8")),
    ],
    "PhongThanSource/Sources/GameClient/PhongThanClient.cpp": [
        (b'char g_szGameName[128] = "Phong Than Online";',
         b'char g_szGameName[128] = "Huyen Vuc Ky";'),
        (b'pSetting->GetString("Main", "GameName", "Phong Than Online", g_szGameName, sizeof(g_szGameName));',
         b'pSetting->GetString("Main", "GameName", "Huyen Vuc Ky", g_szGameName, sizeof(g_szGameName));'),
        (b"        SetWindowText(g_GetMainHWnd(), g_szGameName);",
         b'        strcpy(g_szGameName, "Huyen Vuc Ky");\n'
         b"        SetWindowText(g_GetMainHWnd(), g_szGameName);"),
    ],
}


class BrandError(ValueError):
    pass


def brand_content(path: str, data: bytes) -> bytes:
    if path not in REPLACEMENTS:
        raise BrandError("Unknown branding file: " + path)
    for original, replacement in REPLACEMENTS[path]:
        # Preserve original line endings, especially historic game/client files.
        if b"\r\n" in data and b"\r\n" not in replacement:
            replacement = replacement.replace(b"\n", b"\r\n")
        if data.count(original) != 1:
            raise BrandError("Changed or repeated branding context: " + path)
        data = data.replace(original, replacement, 1)
    return data


def generate(source_root: Path, output_root: Path, *, write: bool = False) -> dict:
    source_root = source_root.resolve()
    output_root = output_root.resolve()
    if write and (output_root == source_root or source_root in output_root.parents):
        raise BrandError("Refusing to write into original archive checkout")
    if write and (output_root == source_root.parent and source_root.parent == output_root):
        raise BrandError("Unsafe output directory")
    if write and output_root.is_symlink():
        raise BrandError("Output directory must not be a symlink")
    products = {}
    for relative in REPLACEMENTS:
        path = source_root.joinpath(*relative.split("/"))
        if path.is_symlink() or not path.is_file() or source_root not in path.resolve().parents:
            raise BrandError("Missing or unsafe input file: " + relative)
        raw = path.read_bytes()
        edited = brand_content(relative, raw)
        if edited == raw:
            raise BrandError("No branding change produced: " + relative)
        products[relative] = edited

    if write:
        output_root.mkdir(parents=True, exist_ok=True)
        for relative, payload in products.items():
            dest = output_root.joinpath(*relative.split("/"))
            if output_root not in dest.resolve().parents or dest.is_symlink():
                raise BrandError("Unsafe overlay destination: " + relative)
            if dest.exists() and dest.read_bytes() != payload:
                raise BrandError("Overlay output has unexpected edits: " + relative)
        for relative, payload in products.items():
            dest = output_root.joinpath(*relative.split("/"))
            dest.parent.mkdir(parents=True, exist_ok=True)
            if not dest.exists():
                dest.write_bytes(payload)
    return {
        "name": DISPLAY_NAME,
        "ascii_name": LEGACY_ENCODED_NAME,
        "status": "written" if write else "dry-run",
        "files": sorted(products.keys()),
        "original_archive_changed": False,
        "gameplay_assets_cleared_for_distribution": False,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path,
                        default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--write", action="store_true",
                        help="Write patch files to external overlay directory")
    args = parser.parse_args()
    try:
        result = generate(args.source_root, args.output_dir, write=args.write)
        print(json.dumps(result, ensure_ascii=False, indent=2))
    except BrandError as exc:
        raise SystemExit("BRAND FAILED: " + str(exc)) from exc


if __name__ == "__main__":
    main()
