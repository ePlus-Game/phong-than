"""Source-only unit tests for the read-only game runtime diagnostic report."""
from __future__ import annotations

import contextlib
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path

from tools.inspect_runtime_diagnostics import evaluate, main, registry_status, skill_status


class RuntimeDiagnosticTests(unittest.TestCase):
    def test_registry_reports_capacity_and_load_failures(self):
        self.assertEqual(registry_status("loaded=5 failed=4725 capacity=5\n")["status"], "ALERT")
        self.assertEqual(registry_status("loaded=5293 failed=68 capacity=10000")["failed"], 68)
        self.assertEqual(registry_status("loaded=123 failed=0 capacity=10000")["status"], "OK")
        self.assertEqual(registry_status("loaded=9999 failed=0 capacity=5")["status"], "ALERT")

    def test_invalid_registry_fails_closed(self):
        self.assertEqual(registry_status("")["status"], "MISSING_EVIDENCE")
        self.assertEqual(registry_status("loaded=1 failed=0")["status"], "MALFORMED")
        self.assertEqual(registry_status("loaded=1 failed=0 capacity=5\njunk")["status"], "MALFORMED")

    def test_skill_1973_aggregates_unique_locations_and_events(self):
        raw = ("repair skill=1973 result=found height=2704 row=1605 style=2 max=1\n"
               "repair skill=1973 result=missing height=1604\n"
               "repair skill=1973 result=missing height=1604\n")
        report = skill_status(raw)
        self.assertEqual(report["found_events"], 1)
        self.assertEqual(report["missing_events"], 2)
        self.assertEqual(report["missing_skill_locations"], {"1973@1604": 2})
        self.assertEqual(report["status"], "ALERT")

    def test_unknown_skill_log_format_is_not_silently_ok(self):
        self.assertEqual(skill_status("repair skill=42 result=invalid height=0")["status"], "ALERT")
        self.assertEqual(skill_status("")["status"], "MISSING_EVIDENCE")

    def test_full_clean_fixture_and_no_false_gameplay_claim(self):
        r = evaluate("loaded=5 failed=0 capacity=5", "loaded=5293 failed=0 capacity=10000",
                     "repair skill=1973 result=found height=2704 row=1605 style=2 max=1",
                     "repair skill=1973 result=found height=2704 row=1605 style=2 max=1")
        self.assertFalse(r["requires_investigation"])
        self.assertFalse(r["gameplay_verified"])

    def test_cli_uses_only_aggregate_data(self):
        with tempfile.TemporaryDirectory() as tmp:
            files = []
            contents = [
                "loaded=5 failed=4725 capacity=5",
                "loaded=5293 failed=68 capacity=10000",
                "repair skill=1973 result=missing height=1604",
                "repair skill=1973 result=found height=2704 row=1605 style=2 max=1",
            ]
            for i, value in enumerate(contents):
                f = Path(tmp) / f"private-character-{i}.log"
                f.write_text(value, encoding="utf-8")
                files.append(f)
            old_argv = sys.argv
            output = io.StringIO()
            try:
                sys.argv = ["inspect", "--client-script-registry", str(files[0]),
                            "--server-script-registry", str(files[1]),
                            "--client-skill-log", str(files[2]),
                            "--server-skill-log", str(files[3])]
                with contextlib.redirect_stdout(output):
                    code = main()
            finally:
                sys.argv = old_argv
            self.assertEqual(code, 2)
            report = json.loads(output.getvalue())
            self.assertTrue(report["requires_investigation"])
            self.assertNotIn("private-character", output.getvalue())


if __name__ == "__main__":
    unittest.main()
