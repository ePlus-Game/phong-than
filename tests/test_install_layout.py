"""Installer-layout regression checks without downloading binary MSI/EXE assets.

Git tree pointers are validated instead of inspecting or executing the installers.
This protects the original binary blobs in sparse GitHub Actions checkouts.
"""
from __future__ import annotations

import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BLOBS = {
    "install/SQL2022-SSEI-Expr.exe": "39f02b7794c2078e2516e49ab7119f965e9a8fba",
    "install/SqlLocalDB.msi": "09d4af8ddf467180dd87ddd61fa8e0cb626f0cac",
}


class InstallerLayoutTests(unittest.TestCase):
    def test_setup_uses_install_folder_and_safe_legacy_fallback(self):
        setup = (ROOT / "AdminWeb/PhongThan-Setup.ps1").read_text(encoding="utf-8")
        self.assertIn("$InstallDir = Join-Path $Root 'install'", setup)
        self.assertIn("$LegacySetupDir = Join-Path $Root 'Setup'", setup)
        self.assertIn("$InstallDir = $LegacySetupDir", setup)
        self.assertIn("$Msi = Join-Path $InstallDir 'SqlLocalDB.msi'", setup)
        self.assertIn("$Ssei = Join-Path $InstallDir 'SQL2022-SSEI-Expr.exe'", setup)
        self.assertIn("SqlLocalDB.msi", setup)
        self.assertIn("SQL2022-SSEI-Expr.exe", setup)
        self.assertNotIn("$SetupDir", setup)

    def test_root_entry_point_still_invokes_setup(self):
        root_command = (ROOT / "PhongThan-CaiDat.cmd").read_text(encoding="utf-8")
        self.assertIn(r"%~dp0AdminWeb\PhongThan-Setup.ps1", root_command)
        self.assertIn("-Step all", root_command)

    def test_repository_documentation_points_to_new_layout(self):
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        install_doc = (ROOT / "install/README.md").read_text(encoding="utf-8")
        self.assertIn("install/", readme)
        self.assertIn("SQL2022-SSEI-Expr.exe", install_doc)
        self.assertIn("SqlLocalDB.msi", install_doc)
        self.assertIn("PhongThan-CaiDat.cmd", install_doc)

    def test_binary_moves_keep_exact_git_blob_sha_without_checkout(self):
        git_dir = subprocess.run(
            ["git", "-C", str(ROOT), "rev-parse", "--git-dir"],
            capture_output=True, text=True, check=False,
        )
        if git_dir.returncode != 0:
            self.skipTest("Git metadata unavailable (e.g. project exported as ZIP)")
        for path, sha in BLOBS.items():
            with self.subTest(path=path):
                result = subprocess.run(
                    ["git", "-C", str(ROOT), "ls-tree", "HEAD", "--", path],
                    capture_output=True, text=True, check=True,
                )
                match = re.fullmatch(
                    r"100644 blob ([0-9a-f]{40})\t" + re.escape(path) + r"\n?",
                    result.stdout,
                )
                self.assertIsNotNone(match, f"Missing expected Git blob for {path}")
                self.assertEqual(match.group(1), sha)
        old = subprocess.run(
            ["git", "-C", str(ROOT), "ls-tree", "HEAD", "--", "Setup"],
            capture_output=True, text=True, check=True,
        )
        self.assertEqual(old.stdout.strip(), "", "Historical Setup/ directory should be empty")


if __name__ == "__main__":
    unittest.main()
