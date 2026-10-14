"""External-copy-only AccountServer compatibility staging contract."""
from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.stage_accountserver_smoke import ACCOUNT_PATCH_PATHS, prepare

ROOT = Path(__file__).resolve().parents[1]


class AccountServerStageTests(unittest.TestCase):
    def seed(self, target: Path) -> dict[str, bytes]:
        result = {}
        for relative in ACCOUNT_PATCH_PATHS:
            original = (ROOT / relative.replace("Build/", "PhongThanSource/Build/").replace(
                "Sources/", "PhongThanSource/Sources/", 1)).read_bytes()
            dest = target / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(original)
            result[relative] = original
        return result

    def test_applies_exact_patches_to_copy_without_touching_archive(self):
        before = {rel: (ROOT / "PhongThanSource" / rel).read_bytes()
                  for rel in ACCOUNT_PATCH_PATHS}
        with tempfile.TemporaryDirectory(prefix="pt-account-build-") as d:
            target = Path(d) / "PT"
            target.mkdir()
            self.seed(target)
            patched_files = prepare(target)
            self.assertEqual(len(patched_files), len(ACCOUNT_PATCH_PATHS) + 2)
            self.assertIn("Sources/AccountServices/AccountServer/GatewayEndpointParser.h", patched_files)
            self.assertIn(b"static inline void sLogProgram", (target / ACCOUNT_PATCH_PATHS[1]).read_bytes())
            self.assertIn(b"PtRecovery::GatewayEndpoint endpoint", (target / ACCOUNT_PATCH_PATHS[2]).read_bytes())
            self.assertIn(b"('/fo' + $resOut)", (target / ACCOUNT_PATCH_PATHS[0]).read_bytes())
            snapshot = {f: (target / f).read_bytes() for f in patched_files}
            self.assertEqual(prepare(target), patched_files)
            self.assertEqual(snapshot, {f: (target / f).read_bytes() for f in patched_files})
        self.assertEqual(before, {rel: (ROOT / "PhongThanSource" / rel).read_bytes()
                                  for rel in ACCOUNT_PATCH_PATHS})

    def test_rejects_original_checkout(self):
        with self.assertRaisesRegex(ValueError, "in-repository"):
            prepare(ROOT / "PhongThanSource")

    def test_bad_source_context_fails_before_writing_others(self):
        with tempfile.TemporaryDirectory(prefix="pt-account-build-") as d:
            target = Path(d) / "PT"
            target.mkdir()
            self.seed(target)
            original_main = (target / ACCOUNT_PATCH_PATHS[1]).read_bytes()
            (target / ACCOUNT_PATCH_PATHS[2]).write_bytes(b"malformed C++")
            with self.assertRaisesRegex(ValueError, "source context"):
                prepare(target)
            self.assertEqual((target / ACCOUNT_PATCH_PATHS[1]).read_bytes(), original_main)
            self.assertFalse((target / "Sources/AccountServices/AccountServer/GatewayEndpointParser.h").exists())


if __name__ == "__main__":
    unittest.main()
