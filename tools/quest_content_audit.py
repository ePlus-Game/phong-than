#!/usr/bin/env python3
"""Verify pinned quest Lua provenance without PAK/runtime writes or gameplay claims."""
from __future__ import annotations
import argparse
import hashlib
import json
import re
from pathlib import Path

class QuestAuditError(ValueError):
    pass

def load_bytes(path):
    if path.is_symlink() or not path.is_file():
        raise QuestAuditError("missing or unsafe quest input: " + str(path))
    return path.read_bytes()

def manifest(path):
    try:
        data = json.loads(load_bytes(path).decode("utf-8-sig"))
    except (UnicodeError, ValueError) as exc:
        raise QuestAuditError("invalid quest manifest: " + str(path)) from exc
    if not isinstance(data, dict):
        raise QuestAuditError("quest manifest is not an object")
    return data

def verify(path, digest, size=None):
    if not isinstance(digest, str) or not re.fullmatch("[a-f0-9]{64}", digest):
        raise QuestAuditError("invalid quest SHA-256")
    data = load_bytes(path)
    if hashlib.sha256(data).hexdigest() != digest:
        raise QuestAuditError("quest SHA-256 mismatch: " + str(path))
    if size is not None and len(data) != size:
        raise QuestAuditError("quest size mismatch: " + str(path))
    return data

def audit(repo):
    base = repo / "PhongThanSource"
    content = base / "Deploy/ProjectContent/NpcQuests"
    fixtures = base / "Tests/fixtures"
    normal = manifest(content / "normal_provenance.json")
    upstream = normal["source"]
    upstream_sha = normal["source_sha256"]
    if normal.get("schema") != 1 or normal.get("original_pak_modified") is not False \
       or normal.get("quest_rules_changed") is not False \
       or normal.get("logical") != r"\script\phongthan\npc_quests\normal.lua" \
       or upstream["evidence"]["sha256"] != upstream_sha \
       or upstream["object"].replace("\\", "/") != "objects/" + upstream_sha + ".lua":
        raise QuestAuditError("normal.lua original source identity changed")
    verify(base / "SourceMigration/NpcLuaLibrary/objects" / (upstream_sha + ".lua"),
           upstream_sha, upstream["evidence"]["bytes"])
    verify(content / "normal_patch.lua", normal["patch_sha256"])
    verify(content / "compiled/script/phongthan/npc_quests/normal.lua",
           normal["sha256"], normal["bytes"])

    xich = manifest(content / "xich_tung_tu_provenance.json")
    if xich.get("schema") != 1 or xich.get("original_pak_modified") is not False \
       or xich.get("original_map_modified") is not False \
       or xich.get("logical") != r"\script\phongthan\npc_services\xich_tung_tu.lua" \
       or xich.get("original_sha256") != xich["source"]["sha256"]:
        raise QuestAuditError("Xich Tung Tu provenance contract changed")
    original = verify(fixtures / "XichTungTu/original.lua",
                      xich["original_sha256"], xich["source"]["bytes"])
    appendix = verify(content / "xich_tung_tu_patch.lua", xich["appendix_sha256"])
    compiled = verify(content / "compiled/script/phongthan/npc_services/xich_tung_tu.lua",
                      xich["sha256"])
    if compiled != original + b"\r\n" + appendix or \
       load_bytes(fixtures / "XichTungTu/patched.lua") != compiled:
        raise QuestAuditError("Xich Tung Tu patched Lua is not original plus verified appendix")

    source_tests = manifest(fixtures / "NpcQuestOriginal/provenance.json")
    scripts = source_tests.get("originals")
    chains = source_tests.get("chains")
    if source_tests.get("scope") != "ORIGINAL_LUA4_STATE_API_TESTS_NOT_RUNTIME_VALIDATION" \
       or not isinstance(scripts, list) or not scripts \
       or not isinstance(chains, list) or not chains:
        raise QuestAuditError("unexpected original Lua4 quest validation scope")
    seen = set()
    for item in scripts:
        filename = item["fixture"]
        if not isinstance(filename, str) or not re.fullmatch("[a-z0-9_]+[.]lua", filename) \
           or filename in seen:
            raise QuestAuditError("unsafe/duplicate quest test fixture")
        seen.add(filename)
        verify(fixtures / "NpcQuestOriginal" / filename, item["sha256"], item["bytes"])
    derivation = source_tests["derived"]
    if derivation.get("original") != "to_ho.lua" or \
       derivation.get("fixture") != "to_ho_transactional.lua" or \
       derivation.get("appendix", "").replace("\\", "/") != \
         "Deploy/ProjectContent/NpcRestoration/quest_overrides/to_ho_task20.lua" \
       or "to_ho.lua" not in seen:
        raise QuestAuditError("unrecognized To Ho task transaction")
    addition = verify(base / "Deploy/ProjectContent/NpcRestoration/quest_overrides/to_ho_task20.lua",
                      derivation["appendix_sha256"])
    rendered = verify(fixtures / "NpcQuestOriginal/to_ho_transactional.lua",
                      derivation["sha256"])
    if rendered != load_bytes(fixtures / "NpcQuestOriginal/to_ho.lua") + b"\r\n" + addition:
        raise QuestAuditError("To Ho script is not reviewed original plus transaction")
    unique = set()
    for chain in chains:
        key = (chain["world"], chain["task"])
        steps = chain["states"]
        if key in unique or not all(type(i) is int and i >= 0 for i in key) \
           or not isinstance(steps, list) or not steps \
           or not all(type(i) is int and i >= 0 for i in steps):
            raise QuestAuditError("duplicate or invalid quest chain")
        unique.add(key)

    journal = manifest(base / "Deploy/VNG_TASK_NOTE_CONTRACT.json")
    note = journal.get("TaskNote", {})
    if journal.get("Schema") != 1 \
       or note.get("RequiredArguments") != ["taskId", "step"] \
       or note.get("WireProjection") != "UI_NOTEINFO" \
       or note.get("JournalHeaderCount") != 36:
        raise QuestAuditError("TaskNote journal protocol contract changed")
    return dict(status="pass", original_fixture_count=len(scripts),
                reviewed_quest_chain_count=len(chains), checked_compiled_lua=2,
                scope="PROVENANCE_ONLY", gameplay_accepted=False,
                all_npc_quests_complete=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    try:
        args = parser.parse_args()
        print(json.dumps(audit(args.root.resolve()), indent=2))
    except (QuestAuditError, KeyError, TypeError) as exc:
        raise SystemExit("QUEST AUDIT FAILED: " + str(exc)) from exc
