"""Regression coverage for the new Windows Core module evidence gate."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools.verify_native_module_build import MODULE_OUTPUTS, verify_modules


class CoreModuleEvidenceTests(unittest.TestCase):
    def test_core_modules_have_role_specific_fresh_outputs(self):
        self.assertEqual(MODULE_OUTPUTS["CoreServer"], ("Server/CoreServer.dll",))
        self.assertEqual(MODULE_OUTPUTS["CoreClient"], ("Client/CoreClient.dll",))
        self.assertEqual(MODULE_OUTPUTS["Common"], ("lib/Common.lib",))

    def test_all_missing_modules_fail_closed(self):
        with tempfile.TemporaryDirectory() as d:
            report = verify_modules(
                Path(d),
                ["Common", "ExpandPackageStaticLib", "FilterTextStatic", "CoreServer", "CoreClient"],
            )
        self.assertEqual(report["status"], "FAIL")
        self.assertEqual(len(report["modules"]), 5)

    def test_coff_archive_signature_and_sha256(self):
        with tempfile.TemporaryDirectory() as d:
            archive = Path(d) / "lib" / "Common.lib"
            archive.parent.mkdir(parents=True)
            archive.write_bytes(b"!<arch>\\n" + b"valid-fixture-data")
            report = verify_modules(Path(d), ["Common"])
        self.assertEqual(report["status"], "PASS", report)
        self.assertEqual(len(report["modules"]["Common"]["artifacts"][0]["sha256"]), 64)

    def test_non_coff_file_is_not_a_valid_static_library(self):
        with tempfile.TemporaryDirectory() as d:
            archive = Path(d) / "lib" / "Common.lib"
            archive.parent.mkdir(parents=True)
            archive.write_bytes(b"not-a-coff-library")
            report = verify_modules(Path(d), ["Common"])
        self.assertEqual(report["status"], "FAIL")
        self.assertIn("COFF", str(report["modules"]["Common"]["errors"]))

    def test_both_core_dlls_still_require_pe_verification(self):
        with tempfile.TemporaryDirectory() as d:
            for module in ("CoreServer", "CoreClient"):
                file = Path(d) / MODULE_OUTPUTS[module][0]
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_bytes(b"test")
            with patch("tools.verify_native_module_build.inspect_pe", return_value=(1024, "d" * 64)) as check:
                report = verify_modules(Path(d), ["CoreServer", "CoreClient"])
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(check.call_count, 2)
            self.assertFalse(report["gameplay_tested"])


if __name__ == "__main__":
    unittest.main()
