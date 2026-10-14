"""Contract tests for newly compiled Windows x86 Client targets."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools.verify_native_module_build import MODULE_OUTPUTS, verify_modules


class ClientBuildEvidenceTests(unittest.TestCase):
    def test_required_client_targets(self):
        self.assertEqual(MODULE_OUTPUTS["GameClient"], ("Client/Game.exe",))
        self.assertEqual(MODULE_OUTPUTS["Represent2"], ("Client/Represent2.dll",))
        self.assertEqual(MODULE_OUTPUTS["Represent3"], ("Client/Represent3.dll",))

    def test_shared_dlls_are_checked_for_both_roles(self):
        for module in ("LuaLibDll", "Engine", "ExpandPackage", "FilterText", "Heaven", "Rainbow"):
            with self.subTest(module=module):
                self.assertEqual(len(MODULE_OUTPUTS[module]), 2)
                self.assertTrue(MODULE_OUTPUTS[module][0].startswith("Client/"))
                self.assertTrue(MODULE_OUTPUTS[module][1].startswith("Server/"))

    def test_missing_game_executable_fails(self):
        with tempfile.TemporaryDirectory() as d:
            report = verify_modules(Path(d), ["GameClient"])
        self.assertEqual(report["status"], "FAIL")
        self.assertIn("Game.exe", str(report["modules"]["GameClient"]["errors"]))

    def test_client_exe_is_not_dll(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            game = root / "Client" / "Game.exe"
            game.parent.mkdir(parents=True)
            game.write_bytes(b"pe-fixture")
            with patch("tools.verify_native_module_build.inspect_pe", return_value=(512, "a" * 64)) as inspect:
                report = verify_modules(root, ["GameClient"])
            self.assertEqual(report["status"], "PASS")
            self.assertFalse(inspect.call_args.kwargs["require_dll"])
            self.assertFalse(report["gameplay_tested"])

    def test_renderer_dll_must_be_marked_dll(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            for module in ("Represent2", "Represent3"):
                file = root / MODULE_OUTPUTS[module][0]
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_bytes(b"pe-fixture")
            with patch("tools.verify_native_module_build.inspect_pe", return_value=(512, "b" * 64)) as inspect:
                report = verify_modules(root, ["Represent2", "Represent3"])
            self.assertEqual(report["status"], "PASS")
            self.assertTrue(all(call.kwargs["require_dll"] for call in inspect.call_args_list))


if __name__ == "__main__":
    unittest.main()
