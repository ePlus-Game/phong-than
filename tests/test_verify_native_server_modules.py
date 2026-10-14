"""Native server module output contract; these tests never execute game binaries."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools.verify_native_module_build import MODULE_OUTPUTS, verify_modules


class ServerBuildEvidenceTests(unittest.TestCase):
    def test_required_service_binaries_are_role_specific(self):
        roles = {
            "PhongThanRelay": "Server/PhongThanRelay.exe",
            "AccountServer": "Server/PhongThanAccountServer.exe",
            "Bishop": "Server/Bishop.exe",
            "Goddess": "Server/Goddess.exe",
            "GameServer": "Server/GameServer.exe",
        }
        for module, relative in roles.items():
            with self.subTest(module=module):
                self.assertEqual(MODULE_OUTPUTS[module], (relative,))

    def test_missing_server_binary_fails_closed(self):
        with tempfile.TemporaryDirectory() as d:
            report = verify_modules(Path(d), ["Bishop", "Goddess", "GameServer"])
        self.assertEqual(report["status"], "FAIL")
        self.assertEqual(len(report["modules"]), 3)

    def test_server_exe_checks_pe_image_type(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            for module in ("Bishop", "Goddess", "GameServer"):
                path = root / MODULE_OUTPUTS[module][0]
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"non-pe-test-fixture")
            with patch("tools.verify_native_module_build.inspect_pe", return_value=(512, "f" * 64)) as pe:
                report = verify_modules(root, ["Bishop", "Goddess", "GameServer"])
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(pe.call_count, 3)
            self.assertTrue(all(not c.kwargs["require_dll"] for c in pe.call_args_list))
            self.assertFalse(report["runtime_tested"])

    def test_server_dll_checks_pe_image_type(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            for relative in MODULE_OUTPUTS["Heaven"]:
                path = root / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"non-pe-test-fixture")
            with patch("tools.verify_native_module_build.inspect_pe", return_value=(512, "0" * 64)) as pe:
                report = verify_modules(root, ["Heaven"])
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(pe.call_count, 2)
            self.assertTrue(all(c.kwargs["require_dll"] for c in pe.call_args_list))


if __name__ == "__main__":
    unittest.main()
