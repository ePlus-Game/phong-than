"""Ensure release tooling archive never accidentally contains the game."""
import tempfile
import unittest
from pathlib import Path
from zipfile import ZipFile

from tools.package_recovery_toolkit import TOOLKIT_FILES, package

ROOT = Path(__file__).resolve().parents[1]


class PackageRecoveryToolkitTests(unittest.TestCase):
    def test_tooling_only_and_repeatable(self):
        self.assertTrue(all(path.startswith(("tools/", "docs/", "overlays/")) for path in TOOLKIT_FILES))
        self.assertFalse(any(path.endswith((".dll", ".exe", ".pak", ".bak")) for path in TOOLKIT_FILES))
        with tempfile.TemporaryDirectory() as tmp:
            first = Path(tmp) / "toolkit-a.zip"
            second = Path(tmp) / "toolkit-b.zip"
            a = package(ROOT, first)
            b = package(ROOT, second)
            self.assertEqual(a["sha256"], b["sha256"])
            self.assertFalse(a["source_archive_included"])
            self.assertFalse(a["game_executables_included"])
            with ZipFile(first) as zipped:
                self.assertEqual(set(zipped.namelist()), set(TOOLKIT_FILES))
