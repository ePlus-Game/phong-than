"""Regression checks for strict per-module, freshly-built x86 artifact verification."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools.verify_native_module_build import verify_modules, MODULE_OUTPUTS


class NativeModuleVerifierTests(unittest.TestCase):
    def test_missing_outputs_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            report = verify_modules(Path(directory), ["LuaLibDll", "Engine"])
        self.assertEqual(report["status"], "FAIL")
        self.assertEqual(report["modules"]["LuaLibDll"]["status"], "FAIL")
        self.assertEqual(report["modules"]["Engine"]["status"], "FAIL")

    def test_each_role_must_be_present_even_when_one_dll_exists(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            client = root / "Client" / "LuaLibDll.dll"
            client.parent.mkdir()
            client.write_bytes(b"fixture")
            with patch("tools.verify_native_module_build.inspect_pe", return_value=(1024, "a" * 64)):
                report = verify_modules(root, ["LuaLibDll"])
        self.assertEqual(report["status"], "FAIL")
        self.assertIn("Server/LuaLibDll.dll", str(report["modules"]["LuaLibDll"]["errors"]))

    def test_valid_outputs_report_hashes_but_no_runtime_claims(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for files in MODULE_OUTPUTS.values():
                for relative in files:
                    target = root / relative
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_bytes(b"fixture")
            with patch("tools.verify_native_module_build.inspect_pe", return_value=(1024, "b" * 64)):
                report = verify_modules(root, ["LuaLibDll", "Engine"])
        self.assertEqual(report["status"], "PASS")
        self.assertFalse(report["runtime_tested"])
        self.assertFalse(report["gameplay_tested"])
        self.assertEqual(len(report["modules"]["Engine"]["artifacts"]), 2)

    def test_invalid_executable_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for relative in MODULE_OUTPUTS["Engine"]:
                target = root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(b"not a PE file")
            report = verify_modules(root, ["Engine"])
        self.assertEqual(report["status"], "FAIL")
        self.assertIn("truncated", str(report["modules"]["Engine"]["errors"]))


if __name__ == "__main__":
    unittest.main()
