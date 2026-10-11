#!/usr/bin/env python3
"""Read-only inventory of Phong Than 2 source, runtime blockers and linker dependencies.

Only reads repository files: never builds or executes legacy binaries.
"""
import argparse
import json
import re
from pathlib import Path

if __package__:
    from .audit_legacy_projects import audit
else:
    from audit_legacy_projects import audit

LINK_RE = re.compile(r"^# ADD LINK32 (.+)$", re.M)
LIB_RE = re.compile(r"(?i)(?<![\w.-])([\w.-]+\.lib)(?![\w.-])")
SDK_LIBS = {
    "kernel32.lib", "user32.lib", "gdi32.lib", "winspool.lib",
    "comdlg32.lib", "advapi32.lib", "shell32.lib", "ole32.lib",
    "oleaut32.lib", "uuid.lib", "odbc32.lib", "odbccp32.lib",
    "ws2_32.lib", "wininet.lib", "winmm.lib", "comctl32.lib",
    "shlwapi.lib", "comsupp.lib", "atl.lib",
}
RUNTIME_CHECKS = ("Game.dll", "FSInterface.dll")
ASSET_EXTS = {".spr", ".pak", ".map", ".mp3", ".wav", ".sql", ".sqlite", ".db"}


def inventory(root: Path) -> dict:
    root = root.resolve()
    paths = [p for p in root.rglob("*") if p.is_file() and not any(
        segment in {".git", "build", "__pycache__"} for segment in p.relative_to(root).parts
    )]
    by_name = {}
    for path in paths:
        by_name.setdefault(path.name.lower(), []).append(path.relative_to(root).as_posix())
    all_refs = audit(root)
    libs = {}
    for configuration in ("Debug", "Release"):
        folder = root / "PhongThanSource" / "Lib" / configuration.lower()
        libs[configuration] = {p.name.lower() for p in folder.glob("*.lib")} if folder.is_dir() else set()
    projects = []
    for dsp in sorted(root.rglob("*.dsp")):
        contents = dsp.read_bytes().decode("latin-1")
        names = sorted(set(name.lower() for line in LINK_RE.findall(contents)
                           for name in LIB_RE.findall(line)))
        project = {
            "project": dsp.relative_to(root).as_posix(),
            "referenced_link_libraries": names,
            "bundled_release": [n for n in names if n in libs["Release"]],
            "bundled_debug": [n for n in names if n in libs["Debug"]],
            "external_or_sdk": [n for n in names if n not in libs["Release"]
                                and n not in libs["Debug"]],
        }
        projects.append(project)
    assets = {}
    for ext in sorted(ASSET_EXTS):
        assets[ext] = sum(path.suffix.lower() == ext for path in paths)
    return {
        "project_count": len(projects),
        "project_paths": {
            k: all_refs[k] for k in (
                "project_count", "source_references", "present_references",
                "missing_references", "dynamic_references"
            )
        },
        "bundled_libraries": {c: sorted(v) for c, v in libs.items()},
        "runtime": {
            name: by_name.get(name.lower(), []) for name in RUNTIME_CHECKS
        },
        "database_schema_files": sorted(
            p.relative_to(root).as_posix() for p in paths
            if p.suffix.lower() in {".sql", ".sqlite", ".db"}
        ),
        "game_asset_extension_counts": assets,
        "projects": projects,
    }


def as_markdown(report: dict) -> str:
    r = report["project_paths"]
    lines = [
        "# Offline recovery dependency audit", "",
        "**Static inspection only; no build of the Windows game was attempted.**", "",
        "## Summary", "",
        "- VC6 projects: {}".format(report["project_count"]),
        "- Project file references: {} resolved / {} unresolved / {} dynamic".format(
            r["present_references"], r["missing_references"], r["dynamic_references"]
        ),
        "- Database dump/schema files: {}".format(len(report["database_schema_files"])),
        "- Bundled .lib files: Release {} / Debug {}".format(
            len(report["bundled_libraries"]["Release"]),
            len(report["bundled_libraries"]["Debug"])
        ),
        "", "## Required DLL runtime inventory", "",
        "| Runtime dependency | Found paths |",
        "| --- | --- |",
    ]
    for name, paths in report["runtime"].items():
        lines.append("| {} | {} |".format(name, ", ".join(paths) if paths else "**Not found**"))
    lines.extend(["", "## Game asset extension counts", ""])
    for ext, count in report["game_asset_extension_counts"].items():
        lines.append("- {}: {}".format(ext, count))
    lines.extend([
        "", "## Project linker libraries", "",
        "The external column includes normal Windows SDK libraries and potentially missing",
        "third-party imports. It is **not** automatically a linker error.", "",
        "| Project | Bundled Release | Bundled Debug | External/SDK |",
        "| --- | ---: | ---: | --- |",
    ])
    for p in report["projects"]:
        externals = ", ".join(p["external_or_sdk"])
        lines.append("| {} | {} | {} | {} |".format(
            p["project"], len(p["bundled_release"]), len(p["bundled_debug"]), externals
        ))
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--json", type=Path)
    parser.add_argument("--markdown", type=Path)
    args = parser.parse_args()
    report = inventory(args.root)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if args.markdown:
        args.markdown.parent.mkdir(parents=True, exist_ok=True)
        args.markdown.write_text(as_markdown(report), encoding="utf-8")
    print(as_markdown(report).split("## Project linker libraries")[0])


if __name__ == "__main__":
    main()
