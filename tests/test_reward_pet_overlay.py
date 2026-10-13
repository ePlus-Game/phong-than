"""Safe-overlay tests against the tracked original Phong Than Lua files."""
from __future__ import annotations
import tempfile
import unittest
from pathlib import Path

from tools.reward_pet_overlay import GIFT, PET, PATCHES, patch, stage

REPO = Path(__file__).resolve().parents[1]
SOURCES = {
    GIFT: REPO / "PhongThanSource/Deploy/ProjectContent/script/servertimer.lua",
    PET: REPO / "PhongThanRuntime-Staging/Server/script/phongthan/sinhhoat/lt_npc.lua",
}


class RewardPetOverlayTests(unittest.TestCase):
    def test_original_contexts_and_idempotency(self):
        for rel, file in SOURCES.items():
            with self.subTest(rel=rel):
                original = file.read_bytes()
                changed = patch(rel, original)
                self.assertNotEqual(original, changed)
                self.assertEqual(changed, patch(rel, changed))
                self.assertEqual(original.count(b"\r\n") > 0, changed.count(b"\r\n") > 0)
                self.assertEqual(original.count(b"\r\n"), changed.count(b"\r\n") -
                                 sum(new.count("\n") - old.count("\n") for old, new in PATCHES[rel])
                                 if b"\r\n" in original else 0)

    def test_admin_broadcast_does_not_log_partial_as_ok(self):
        changed = patch(GIFT, SOURCES[GIFT].read_bytes())
        self.assertIn(b'if partial > 0 or failed > 0 then status = "PARTIAL" end', changed)
        self.assertIn(b'PTAdm_Log(id, status, "targets=" .. targets', changed)
        self.assertNotIn(b'PTAdm_Log(id, "OK", "players=" .. players)', changed)

    def test_pet_egg_failure_attempts_refund_before_reporting_success(self):
        changed = patch(PET, SOURCES[PET].read_bytes())
        self.assertIn(b"if PTSH_Give(6, PTLT_I_EGG0 + k, 0, 1) ~= 1 then", changed)
        self.assertIn(b"Earn(PTLT_EGG_CASH)", changed)
        self.assertIn(b"if restored ~= PTLT_EGG_DON then", changed)
        self.assertIn(b"can lien he GM", changed)

    def _fixture(self, dest):
        for rel, src in SOURCES.items():
            file = dest.joinpath(*rel.split("/"))
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_bytes(src.read_bytes())

    def test_dry_run_apply_and_repeat(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            self._fixture(root)
            before = {rel: (root / rel).read_bytes() for rel in SOURCES}
            self.assertEqual(len(stage(root)), len(SOURCES))
            self.assertEqual(before, {rel: (root / rel).read_bytes() for rel in SOURCES})
            stage(root, apply=True)
            after = {rel: (root / rel).read_bytes() for rel in SOURCES}
            self.assertNotEqual(before, after)
            stage(root, apply=True)
            self.assertEqual(after, {rel: (root / rel).read_bytes() for rel in SOURCES})

    def test_conflict_aborts_without_writing_any_file(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            self._fixture(root)
            (root / PET).write_bytes(b"unknown content")
            gift_before = (root / GIFT).read_bytes()
            with self.assertRaisesRegex(ValueError, "context"):
                stage(root, apply=True)
            self.assertEqual((root / GIFT).read_bytes(), gift_before)

    def test_unrecognized_file_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "Unknown"):
            patch("script/anywhere.lua", b"something")

    def test_prevent_in_repo_apply(self):
        with self.assertRaisesRegex(ValueError, "Refusing"):
            stage(REPO, apply=True)


if __name__ == "__main__":
    unittest.main()
