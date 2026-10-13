"""Regression tests for the read-only and redacted GM reward anomaly summary."""
from __future__ import annotations

import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path

from tools.reconcile_reward_logs import main, summarize


class RewardReconcileTests(unittest.TestCase):
    def test_partial_daily_and_pet_compensation(self):
        daily = "2026-10-13 11:11:11\tPARTIAL\tPrivateCharacter\tdaily\titems=1/3\n"
        pet = "2026-10-13 11:12:11\tPARTIAL\tPrivateCharacter\ttier\tmissing=2\n"
        result = summarize(daily, pet)
        self.assertEqual(result["daily_missing_items"], 2)
        self.assertEqual(result["pet_missing_items"], 2)
        self.assertTrue(result["requires_gm_reconciliation"])
        self.assertFalse(result["safe_to_automatically_retry"])
        self.assertFalse(result["proof_of_atomic_game_transactions"])
        self.assertNotIn("PrivateCharacter", json.dumps(result))

    def test_admin_partial_summary_and_invalid_totals(self):
        valid = "2026-10-13 11:20:01\tqueuedid\tPARTIAL\ttargets=4 complete=2 partial=1 failed=1\n"
        invalid = "2026-10-13 11:21:01\tqueuedid\tPARTIAL\ttargets=10 complete=2 partial=1 failed=1\n"
        ok = "2026-10-13 11:22:01\tqueuedid\tOK\ttargets=1 complete=1 partial=0 failed=0\n"
        report = summarize(admin=valid + invalid + ok)
        self.assertEqual(report["admin_partial_or_failed"], 2)
        self.assertEqual(report["admin_incomplete_targets"], 2)
        self.assertEqual(report["unrecognized_log_lines"], 1)

    def test_truncated_lines_and_impossible_counts_are_flagged(self):
        report = summarize("truncated\n2026-10-13\tPARTIAL\tUser\tdaily\titems=8/3", "2026\tPARTIAL\tUser\ttier\tmissing=0")
        self.assertEqual(report["daily_partial"], 0)
        self.assertEqual(report["pet_refund_partial"], 0)
        self.assertEqual(report["unrecognized_log_lines"], 3)
        self.assertTrue(report["requires_gm_reconciliation"])

    def test_no_input_is_clean_but_never_a_transaction_proof(self):
        report = summarize()
        self.assertFalse(report["requires_gm_reconciliation"])
        self.assertFalse(report["proof_of_atomic_game_transactions"])

    def test_cli_does_not_write_or_expose_player_names(self):
        with tempfile.TemporaryDirectory() as tmp:
            file = Path(tmp) / "daily.log"
            original = "2026-10-13 11:11:11\tPARTIAL\tSensitiveName\tdaily\titems=1/2\n"
            file.write_text(original, encoding="utf-8")
            import sys
            old = sys.argv
            output = io.StringIO()
            try:
                sys.argv = ["reconcile_reward_logs", "--daily-log", str(file), "--fail-on-anomaly"]
                with contextlib.redirect_stdout(output):
                    exit_code = main()
            finally:
                sys.argv = old
            self.assertEqual(exit_code, 2)
            self.assertEqual(file.read_text(encoding="utf-8"), original)
            self.assertNotIn("SensitiveName", output.getvalue())
            self.assertEqual(json.loads(output.getvalue())["daily_missing_items"], 1)


if __name__ == "__main__":
    unittest.main()
