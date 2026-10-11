#!/usr/bin/env python3
"""Restore split PAK files in the flattened PT archive layout."""
import argparse
import csv
import hashlib
import os
from pathlib import Path

def translate(old):
    prefix = "source/PT/"
    if not old.startswith(prefix):
        raise ValueError("Unexpected archive path")
    parts = old[len(prefix):].split("/")
    if any(not x or x in (".", "..") or ":" in x or "\\" in x for x in parts):
        raise ValueError("Invalid archive path")
    if parts[0] == "docs":
        parts.insert(1, "original-pt")
    return Path(*parts)

def restore(root):
    root = root.resolve()
    manifest = root / "archive" / "PT_EXACT_ZIP_MANIFEST.csv"
    count = 0
    with manifest.open(encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            if row["storage"] != "split-git-parts":
                continue
            path = root / translate(row["git_or_archive_path"])
            if not path.resolve().is_relative_to(root):
                raise ValueError("Path outside repository")
            parts = sorted(Path(str(path) + ".parts").glob("part-*.bin"))
            if not parts:
                raise FileNotFoundError(str(path))
            path.parent.mkdir(parents=True, exist_ok=True)
            temp = path.with_name(path.name + ".restore-incomplete")
            digest = hashlib.sha256()
            length = 0
            try:
                with temp.open("wb") as dest:
                    for index, part in enumerate(parts):
                        if part.name != f"part-{index:04d}.bin" or part.is_symlink():
                            raise ValueError("Invalid chunk sequence")
                        with part.open("rb") as src:
                            while True:
                                data = src.read(1024 * 1024)
                                if not data:
                                    break
                                dest.write(data)
                                digest.update(data)
                                length += len(data)
                if length != int(row["uncompressed_bytes"]) or digest.hexdigest() != row["sha256"]:
                    raise ValueError("Restored PAK checksum mismatch: " + str(path))
                os.replace(temp, path)
            finally:
                temp.unlink(missing_ok=True)
            count += 1
            print("VERIFIED:", path.relative_to(root))
    print("Restored", count, "PAK files")
    return count

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    restore(parser.parse_args().repo_root)
