"""Test release preflight without downloading or running game assets."""
import tempfile
import unittest
from pathlib import Path
from tools.release_preflight import check_source

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "PhongThanSource"


class ReleasePreflightTests(unittest.TestCase):
    def test_external_workspace_and_original_source_context(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = check_source(SOURCE, Path(tmp) / "pt-build", "Modern")
            self.assertEqual(result["status"], "preflight_passed")
            self.assertFalse(result["game_built"])
            self.assertGreaterEqual(result["source_paths_verified"], 4)

    def test_reject_workspace_inside_checkout(self):
        with self.assertRaisesRegex(ValueError, "outside"):
            check_source(SOURCE, ROOT / "build", "VC6")

    def test_reject_archive_as_workspace(self):
        with self.assertRaisesRegex(ValueError, "outside|separate"):
            check_source(SOURCE, SOURCE, "Modern")
