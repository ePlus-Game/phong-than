"""Launcher regression contracts; no game binaries or database are executed."""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


class WindowsLauncherTests(unittest.TestCase):
    def test_game_missing_executable_fails_before_client_patching(self):
        bat = read("PhongThan-MoGame.cmd")
        self.assertIn('if not exist "%CLIENT_EXE%" (', bat)
        self.assertIn("exit /b 2", bat)
        self.assertLess(bat.index('if not exist "%CLIENT_EXE%"'), bat.index("PhongThan-ClientPatch.ps1"))
        self.assertLess(bat.index("PhongThan-ClientPatch.ps1"), bat.index('start "" /D'))
        self.assertIn("if errorlevel 1 (", bat)
        self.assertIn("exit /b 0", bat)

    @unittest.skipUnless(os.name == "nt", "Windows cmd.exe integration check")
    def test_game_missing_executable_returns_errorlevel_2_on_windows(self):
        # Run only the missing-file path in an empty temporary checkout.
        # This must return before launching PowerShell or any historical EXE.
        with tempfile.TemporaryDirectory(prefix="pt launcher with spaces ") as directory:
            launcher = Path(directory) / "PhongThan-MoGame.cmd"
            shutil.copyfile(ROOT / "PhongThan-MoGame.cmd", launcher)
            completed = subprocess.run(
                ["cmd.exe", "/d", "/c", str(launcher)],
                cwd=directory, capture_output=True, text=True, timeout=10,
            )
            self.assertEqual(completed.returncode, 2, completed.stdout + completed.stderr)
            self.assertIn("Game.exe", completed.stdout)

    def test_setup_and_all_launchers_propagate_errors(self):
        for path, target in (
            ("PhongThan-CaiDat.cmd", "PhongThan-Setup.ps1"),
            ("PhongThan-ChayTatCa.cmd", "PhongThan-RunAll.ps1"),
        ):
            with self.subTest(path=path):
                bat = read(path)
                self.assertIn(target, bat)
                self.assertIn('set "EXIT_CODE=%ERRORLEVEL%"', bat)
                self.assertIn("exit /b %EXIT_CODE%", bat)
        self.assertIn('if /I "%~1"=="game"', read("PhongThan-ChayTatCa.cmd"))
        self.assertIn("-WithClient", read("PhongThan-ChayTatCa.cmd"))

    def test_server_only_run_does_not_patch_client(self):
        script = read("AdminWeb/PhongThan-RunAll.ps1")
        self.assertIn("if ($WithClient) {\n        Step 'Kiem tra va client", script)
        self.assertEqual(script.count("PhongThan-ClientPatch.ps1"), 1)
        self.assertIn("if ($LASTEXITCODE -ne 0) { throw 'Client patch", script)
        self.assertIn("$WithClient -and -not (Test-Path -LiteralPath $ClientExe -PathType Leaf)", script)

    def test_native_server_requires_full_topology_and_readiness(self):
        script = read("AdminWeb/PhongThan-RunAll.ps1")
        for name in (
            "Goddess.exe", "PhongThanAccountServer.exe", "PhongThanRelay.exe",
            "Bishop.exe", "GameServer.exe",
        ):
            self.assertIn(name, script)
        self.assertIn("$missing.Count -gt 0", script)
        self.assertIn("READY_FOR_LOGIN", script)
        self.assertIn("WORLD_READY", script)

    def test_doc_describes_limitations(self):
        text = read("docs/LAUNCHER_BEHAVIOR.md")
        self.assertIn("không", text)
        self.assertIn("WORLD_READY", text)
        self.assertIn("Game.exe", text)


if __name__ == "__main__":
    unittest.main()
