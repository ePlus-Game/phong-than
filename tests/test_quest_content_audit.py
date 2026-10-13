"""Regression tests for the read-only Phong Than quest integrity auditor."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from tools.quest_content_audit import QuestAuditError, audit

def digest(data):
    return hashlib.sha256(data).hexdigest()

class QuestAuditTests(unittest.TestCase):
    def write(self, name, data):
        p = self.root / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(data)
    def write_json(self, name, data):
        self.write(name, json.dumps(data).encode("utf-8"))
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.base = Path(temp.name)
        self.root = self.base / "PhongThanSource"
        normal_dir = "Deploy/ProjectContent/NpcQuests/"
        original, patch, compiled = b"original", b"patch", b"compiled"
        self.write("SourceMigration/NpcLuaLibrary/objects/"+digest(original)+".lua", original)
        self.write(normal_dir+"normal_patch.lua", patch)
        self.write(normal_dir+"compiled/script/phongthan/npc_quests/normal.lua", compiled)
        self.write_json(normal_dir+"normal_provenance.json",
            dict(schema=1, logical=r"\script\phongthan\npc_quests\normal.lua",
                 source=dict(object="objects/"+digest(original)+".lua",
                             evidence=dict(sha256=digest(original), bytes=len(original))),
                 source_sha256=digest(original), patch_sha256=digest(patch),
                 sha256=digest(compiled), bytes=len(compiled),
                 original_pak_modified=False, quest_rules_changed=False))
        xorig, xpatch = b"xich", b"xich patch"
        xcompiled = xorig+b"\r\n"+xpatch
        self.write("Tests/fixtures/XichTungTu/original.lua", xorig)
        self.write("Tests/fixtures/XichTungTu/patched.lua", xcompiled)
        self.write(normal_dir+"xich_tung_tu_patch.lua", xpatch)
        self.write(normal_dir+"compiled/script/phongthan/npc_services/xich_tung_tu.lua", xcompiled)
        self.write_json(normal_dir+"xich_tung_tu_provenance.json",
            dict(schema=1, logical=r"\script\phongthan\npc_services\xich_tung_tu.lua",
                 source=dict(sha256=digest(xorig), bytes=len(xorig)),
                 original_sha256=digest(xorig), appendix_sha256=digest(xpatch),
                 sha256=digest(xcompiled), original_pak_modified=False,
                 original_map_modified=False))
        to_ho, extra = b"toho", b"transaction"
        self.write("Tests/fixtures/NpcQuestOriginal/to_ho.lua", to_ho)
        self.write("Deploy/ProjectContent/NpcRestoration/quest_overrides/to_ho_task20.lua", extra)
        self.write("Tests/fixtures/NpcQuestOriginal/to_ho_transactional.lua", to_ho+b"\r\n"+extra)
        self.proof = dict(scope="ORIGINAL_LUA4_STATE_API_TESTS_NOT_RUNTIME_VALIDATION",
            originals=[dict(fixture="to_ho.lua",sha256=digest(to_ho),bytes=len(to_ho))],
            derived=dict(original="to_ho.lua",fixture="to_ho_transactional.lua",
                appendix=r"Deploy\ProjectContent\NpcRestoration\quest_overrides\to_ho_task20.lua",
                appendix_sha256=digest(extra), sha256=digest(to_ho+b"\r\n"+extra)),
            chains=[dict(world=1002,task=20,states=[0,1,10,17])])
        self.write_json("Tests/fixtures/NpcQuestOriginal/provenance.json", self.proof)
        self.write_json("Deploy/VNG_TASK_NOTE_CONTRACT.json",
            dict(Schema=1, TaskNote=dict(RequiredArguments=["taskId","step"],
                                         WireProjection="UI_NOTEINFO",JournalHeaderCount=36)))
    def test_pass_and_do_not_claim_gameplay(self):
        info = audit(self.base)
        self.assertEqual(info["status"], "pass")
        self.assertFalse(info["all_npc_quests_complete"])
        self.assertFalse(info["gameplay_accepted"])
    def test_stale_normal_patch(self):
        self.write("Deploy/ProjectContent/NpcQuests/normal_patch.lua", b"modified")
        with self.assertRaisesRegex(QuestAuditError, "SHA-256 mismatch"):
            audit(self.base)
    def test_stale_xich_fixture(self):
        self.write("Tests/fixtures/XichTungTu/patched.lua", b"stale")
        with self.assertRaisesRegex(QuestAuditError, "Xich Tung Tu patched Lua"):
            audit(self.base)
    def test_stale_to_ho_transaction(self):
        self.write("Deploy/ProjectContent/NpcRestoration/quest_overrides/to_ho_task20.lua", b"changed")
        with self.assertRaisesRegex(QuestAuditError, "SHA-256 mismatch"):
            audit(self.base)
    def test_duplicate_quest_id(self):
        self.proof["chains"].append(self.proof["chains"][0])
        self.write_json("Tests/fixtures/NpcQuestOriginal/provenance.json", self.proof)
        with self.assertRaisesRegex(QuestAuditError, "duplicate or invalid quest chain"):
            audit(self.base)
    def test_unsafe_fixture_filename(self):
        self.proof["originals"][0]["fixture"] = "../out.lua"
        self.write_json("Tests/fixtures/NpcQuestOriginal/provenance.json", self.proof)
        with self.assertRaisesRegex(QuestAuditError, "unsafe/duplicate"):
            audit(self.base)
    def test_journal_contract_drift(self):
        self.write_json("Deploy/VNG_TASK_NOTE_CONTRACT.json",
            dict(Schema=1,TaskNote=dict(RequiredArguments=["step"],
                                        WireProjection="UI_NOTEINFO",JournalHeaderCount=36)))
        with self.assertRaisesRegex(QuestAuditError, "TaskNote"):
            audit(self.base)

if __name__ == "__main__":
    unittest.main()
