#!/usr/bin/env python3
"""Read-only inventory of source and CP936/GB18030 gameplay tables."""
from __future__ import annotations
import argparse
import json
import re
from collections import Counter
from pathlib import Path

ROOTS = (
    "PhongThanSource/Sources",
    "PhongThanRuntime-Staging/Server/settings",
    "PhongThanRuntime-Staging/Client/settings",
    "PhongThanRuntime-Staging/Server/script/phongthan",
)
EXT = {".txt", ".ini", ".lua", ".cpp", ".h", ".hpp", ".inl", ".cfg", ".csv", ".tab", ".json"}
PATTERNS = {
    "class": re.compile(r"giáp\s*sĩ|đạo\s*sĩ|dị\s*nhân|giap\s*si|dao\s*si|di\s*nhan|playerclass|profession|fightclass|nseries", re.I),
    "level": re.compile(r"max.?level|level.?max|level.?cap|cap.?level|player.?level|level.?exp|levelup|upgrade.?level|cấp\s*tối\s*đa", re.I),
    "skill": re.compile(r"skill.?id|skill.?level|skill.?table|learn.?skill|magic.?skill|sách\s*kỹ\s*năng|skill\.txt", re.I),
    "equipment": re.compile(r"equipment|equip.?item|set.?bonus|item.?level|zhuang.?bei|hoang.?kim|trang.?bị|recipe.?id|compose.?recipe", re.I),
    "quest": re.compile(r"quest.?id|quest.?exchange|task.?id|tô\s*hộ|phong\s*bá|thiếu\s*hạo|từ\s*hàng", re.I),
}
NAME_HINT = re.compile(r"level|exp|skill|magic|equip|item|player|profession|series|quest|task|recipe|horse|pet", re.I)
EXCLUDED = {"Output", "OutputModern", ".git", "node_modules", "obj", "Debug", "Release", "packages", "bin"}
LIMIT = 100

def decode_legacy(raw: bytes) -> tuple[str, str]:
    for enc in ("utf-8-sig", "gb18030", "cp1252"):
        try:
            return raw.decode(enc), enc
        except UnicodeDecodeError:
            pass
    return raw.decode("utf-8", errors="replace"), "utf-8-replace"

def scan_file(path: Path, root: Path) -> dict:
    text, encoding = decode_legacy(path.read_bytes())
    rel = path.relative_to(root).as_posix()
    hits = []
    for line_no, line in enumerate(text.splitlines(), 1):
        for topic, pattern in PATTERNS.items():
            if pattern.search(line):
                hits.append({"topic": topic, "path": rel, "line": line_no,
                             "snippet": re.sub(r"\s+", " ", line).strip()[:160]})
    return {"path": rel, "encoding": encoding, "name_hint": bool(NAME_HINT.search(path.name)), "hits": hits}

def inspect_level_cap(root: Path) -> dict:
    """Read the actual player cap macro + EXP rows; do not claim playability."""
    macro = root / "PhongThanSource/Sources/Core/Src/GameDataDef.h"
    server = root / "PhongThanRuntime-Staging/Server/settings/npc/player/level_exp.txt"
    client = root / "PhongThanRuntime-Staging/Client/settings/npc/player/level_exp.txt"
    result = {"declared_max_level": None, "exp_rows": 0,
              "last_exp_level": None, "exp_over_int32_from": None,
              "server_client_identical": None, "warnings": []}
    if macro.is_file():
        code, _ = decode_legacy(macro.read_bytes())
        m = re.search(r"(?m)^\s*#define\s+MAX_LEVEL\s+(\d+)\b", code)
        if m:
            result["declared_max_level"] = int(m.group(1))
    if server.is_file():
        txt, _ = decode_legacy(server.read_bytes())
        rows = []
        for line in txt.splitlines():
            m = re.match(r"^\s*(\d+)\s+(\d+)\s*$", line)
            if m:
                rows.append((int(m.group(1)), int(m.group(2))))
        result["exp_rows"] = len(rows)
        if rows:
            result["last_exp_level"] = max(level for level, _ in rows)
        large = [(level, exp) for level, exp in rows if exp > 2147483647]
        if large:
            result["exp_over_int32_from"] = large[0][0]
            result["warnings"].append(
                "EXP value above signed 32-bit range; inspect KTabFile::GetInteger (atoi) and KPlayerSet int arrays")
    if server.is_file() and client.is_file():
        result["server_client_identical"] = server.read_bytes() == client.read_bytes()
    if result["declared_max_level"] and result["last_exp_level"]:
        if result["last_exp_level"] != result["declared_max_level"]:
            result["warnings"].append("MAX_LEVEL differs from last level in EXP file")
    return result

def inspect_skill_table(root: Path) -> dict:
    """Summarize Skills.txt without assuming CharClass equals a player sect."""
    path = root / "PhongThanRuntime-Staging/Server/settings/Skills.txt"
    client = root / "PhongThanRuntime-Staging/Client/settings/Skills.txt"
    info = {"valid_skill_rows": 0, "columns": 0, "charclass_counts": {},
            "server_client_identical": None}
    if not path.is_file():
        return info
    content, _ = decode_legacy(path.read_bytes())
    rows = content.splitlines()
    if not rows:
        return info
    header = rows[0].split("\t")
    info["columns"] = len(header)
    if "SkillId" not in header or "CharClass" not in header:
        return info
    i = header.index("SkillId")
    j = header.index("CharClass")
    values = Counter()
    for row in rows[1:]:
        cells = row.split("\t")
        if len(cells) <= max(i, j) or not cells[i].strip().isdigit():
            continue
        info["valid_skill_rows"] += 1
        values[cells[j].strip()] += 1
    info["charclass_counts"] = dict(values)
    if client.is_file():
        info["server_client_identical"] = path.read_bytes() == client.read_bytes()
    return info

def audit(root: Path) -> dict:
    result = {"roots": [], "files_scanned": 0, "skipped": Counter(),
              "encodings": Counter(), "candidate_files": [], "hits": {k: [] for k in PATTERNS}}
    for prefix in ROOTS:
        folder = root / prefix
        if not folder.is_dir():
            result["skipped"]["missing:" + prefix] += 1
            continue
        result["roots"].append(prefix)
        for path in sorted(folder.rglob("*")):
            if not path.is_file() or any(part in EXCLUDED for part in path.parts):
                continue
            if path.suffix.lower() not in EXT:
                continue
            size = path.stat().st_size
            if not size or size > 1500000:
                result["skipped"]["empty-or-large"] += 1
                continue
            try:
                row = scan_file(path, root)
            except (OSError, ValueError):
                result["skipped"]["unreadable"] += 1
                continue
            result["files_scanned"] += 1
            result["encodings"][row["encoding"]] += 1
            if row["name_hint"]:
                result["candidate_files"].append(row["path"])
            for hit in row["hits"]:
                category = hit["topic"]
                if len(result["hits"][category]) < LIMIT:
                    result["hits"][category].append(hit)
    result["level_cap"] = inspect_level_cap(root)
    result["skill_table"] = inspect_skill_table(root)
    result["encodings"] = dict(result["encodings"])
    result["skipped"] = dict(result["skipped"])
    return result

def markdown(data: dict) -> str:
    lines = [
        "# Phong Than gameplay source inventory — candidate matches only",
        "",
        "Read-only static scan, NOT proof of max level, best equipment, or playable game.",
        "Verify the live configuration and code execution before publishing player guidance.",
        "",
        "Roots: " + ", ".join(data["roots"]),
        "Files: " + str(data["files_scanned"]),
        "Encodings: " + json.dumps(data["encodings"], ensure_ascii=False),
        "Skipped: " + json.dumps(data["skipped"], ensure_ascii=False),
        "",
        "## Player level cap cross-check",
        "",
        json.dumps(data.get("level_cap", {}), ensure_ascii=False, indent=2),
        "",
        "## Skills.txt cross-check (CharClass does not prove player sect)",
        "",
        json.dumps(data.get("skill_table", {}), ensure_ascii=False, indent=2),
        "",
        "## Candidate filenames (first 120)",
    ]
    lines.extend("- " + item for item in data["candidate_files"][:120])
    for topic, hits in data["hits"].items():
        lines.extend(["", "## " + topic + " candidates (" + str(len(hits)) + " sampled)"])
        lines.extend("- " + h["path"] + ":" + str(h["line"]) + " — " + h["snippet"]
                     for h in hits)
    return "\n".join(lines) + "\n"

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path, default=Path("gameplay-source-audit.md"))
    parser.add_argument("--json", type=Path)
    opts = parser.parse_args()
    results = audit(opts.root.resolve())
    opts.output.parent.mkdir(parents=True, exist_ok=True)
    opts.output.write_text(markdown(results), encoding="utf-8")
    if opts.json:
        opts.json.parent.mkdir(parents=True, exist_ok=True)
        opts.json.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    print("Scanned:", results["files_scanned"], "files")
    print("Encodings:", results["encodings"])
    print("Hits:", {k: len(v) for k, v in results["hits"].items()})
    return 0 if results["files_scanned"] else 2

if __name__ == "__main__":
    raise SystemExit(main())
