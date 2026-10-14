"""External-copy-only clean build preparation; tests use tiny fake trees."""
from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.prepare_modern_build import prepare_clean_copy


class ModernBuildPreparationTests(unittest.TestCase):
    def fixture(self, base: Path):
        repo = base / "checkout"
        source = repo / "PhongThanSource"
        work = base / "external workspace with spaces"
        (source / "Sources").mkdir(parents=True)
        (work / "Sources").mkdir(parents=True)
        (work / "Build").mkdir()
        (work / "Build/Build-Modern.ps1").write_text("# test fixture", encoding="utf-8")
        return repo, source, work

    def test_removes_only_copied_outputs_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as directory:
            repo, source, work = self.fixture(Path(directory))
            for root in (source, work):
                (root / "OutputModern/Client").mkdir(parents=True)
                (root / "OutputModern/Client/Game.exe").write_bytes(b"historic binary")
                (root / "Build/LogsModern").mkdir(parents=True)
                (root / "Build/LogsModern/GameClient.log").write_text("historic log")
            result = prepare_clean_copy(work, source, repo)
            self.assertEqual(result["removed"], ["OutputModern", "Build/LogsModern"])
            self.assertFalse((work / "OutputModern").exists())
            self.assertFalse((work / "Build/LogsModern").exists())
            self.assertTrue((source / "OutputModern/Client/Game.exe").exists())
            self.assertTrue((source / "Build/LogsModern/GameClient.log").exists())
            self.assertEqual(prepare_clean_copy(work, source, repo)["removed"], [])
            self.assertTrue((work / "Build/Build-Modern.ps1").exists())

    def test_refuses_checkout_source_and_ancestor(self):
        with tempfile.TemporaryDirectory() as directory:
            repo, source, work = self.fixture(Path(directory))
            for wrong in (repo, source, repo.parent, work / "Sources"):
                with self.subTest(path=wrong):
                    with self.assertRaisesRegex(ValueError, "outside"):
                        prepare_clean_copy(wrong, source, repo)

    def test_refuses_bad_copy_without_deletion(self):
        with tempfile.TemporaryDirectory() as directory:
            repo, source, work = self.fixture(Path(directory))
            (work / "OutputModern").mkdir()
            (work / "Sources").rmdir()
            with self.assertRaisesRegex(ValueError, "copied game source"):
                prepare_clean_copy(work, source, repo)
            self.assertTrue((work / "OutputModern").exists())

    def test_refuses_output_file_before_deleting_logs(self):
        with tempfile.TemporaryDirectory() as directory:
            repo, source, work = self.fixture(Path(directory))
            (work / "OutputModern").write_text("not a dir")
            (work / "Build/LogsModern").mkdir()
            with self.assertRaisesRegex(ValueError, "Expected directory"):
                prepare_clean_copy(work, source, repo)
            self.assertTrue((work / "Build/LogsModern").is_dir())

    def test_refuses_symlink_output_and_preserves_target(self):
        with tempfile.TemporaryDirectory() as directory:
            repo, source, work = self.fixture(Path(directory))
            target = Path(directory) / "outside output"
            target.mkdir()
            (target / "protect.txt").write_text("safe")
            try:
                (work / "OutputModern").symlink_to(target, target_is_directory=True)
            except (NotImplementedError, OSError):
                self.skipTest("Filesystem cannot create directory symlinks")
            with self.assertRaisesRegex(ValueError, "symlink or junction"):
                prepare_clean_copy(work, source, repo)
            self.assertTrue((target / "protect.txt").exists())


if __name__ == "__main__":
    unittest.main()
