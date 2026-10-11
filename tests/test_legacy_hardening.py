"""Regression checks for the byte-exact PT source hardening overlay."""
import tempfile
import unittest
from pathlib import Path
from tools.legacy_hardening import PATCHES, harden, stage

ROOT = Path(__file__).resolve().parents[1] / "source/PT/PhongThanSource"


class HardeningTests(unittest.TestCase):
    def test_each_original_file_has_exact_patch_context(self):
        for rel in PATCHES:
            with self.subTest(path=rel):
                original = (ROOT / rel).read_bytes()
                fixed = harden(rel, original)
                self.assertNotEqual(fixed, original)
                self.assertEqual(harden(rel, fixed), fixed)
                self.assertEqual(b"\r\n" in fixed, b"\r\n" in original)

    def test_fixed_network_code_checks_input_at_runtime(self):
        rel = "Sources/AccountServices/AccountServer/S3PDBSocketPool.cpp"
        fixed = harden(rel, (ROOT / rel).read_bytes())
        self.assertIn(b"pSend->Size > MAX_PATH", fixed)
        self.assertIn(b"pSend->Size < sizeof(KAccountHead)", fixed)
        self.assertIn(b"if (pInfo == NULL)", fixed)
        self.assertIn(b"strchr(pInfo, ':')", fixed)
        self.assertNotIn(b"while(*(pInfo + offset) != ':')", fixed)
        self.assertNotIn(b"assert(pSend->Size < MAX_PATH)", fixed)

    def test_gameserver_format_string_is_fixed(self):
        rel = "Sources/MultiServer/GameServer/GameServer.cpp"
        fixed = harden(rel, (ROOT / rel).read_bytes())
        self.assertIn(b'fprintf(stderr, "%s", szerrmsg ? szerrmsg : "");', fixed)
        self.assertNotIn(b"fprintf(stderr, szerrmsg);", fixed)

    def test_dry_run_and_external_copy_apply(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp)
            for rel in PATCHES:
                dest = target / rel
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_bytes((ROOT / rel).read_bytes())
            before = [(target / rel).read_bytes() for rel in PATCHES]
            self.assertEqual(len(stage(target, apply=False)), len(PATCHES))
            self.assertEqual(before, [(target / rel).read_bytes() for rel in PATCHES])
            self.assertEqual(len(stage(target, apply=True)), len(PATCHES))
            self.assertEqual(len(stage(target, apply=True)), len(PATCHES))
            self.assertNotEqual(before, [(target / rel).read_bytes() for rel in PATCHES])

    def test_refuses_to_modify_archived_checkout(self):
        with self.assertRaisesRegex(ValueError, "Refusing"):
            stage(ROOT, apply=True)

    def test_fails_closed_for_unrecognized_content(self):
        rel = "Sources/MultiServer/GameServer/GameServer.cpp"
        with self.assertRaisesRegex(ValueError, "context changed"):
            harden(rel, b"completely unknown source")
