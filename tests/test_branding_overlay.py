"""Archive-preserving Huyen Vuc Ky branding checks."""
from __future__ import annotations

import shutil
import tempfile
import unittest
from pathlib import Path

from tools.build_branding_overlay import (
    BrandError, DISPLAY_NAME, REPLACEMENTS, brand_content, generate,
)

REPO = Path(__file__).resolve().parents[1]


class BrandingOverlayTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.temp = Path(tmp.name)
        self.source = self.temp / "legacy"
        self.output = self.temp / "output"
        for relative in REPLACEMENTS:
            path = self.source / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(REPO / relative, path)

    def test_real_imported_sources_have_exact_anchors(self):
        # Tests run on the real archived text inputs, not made-up fixtures.
        for relative in REPLACEMENTS:
            with self.subTest(file=relative):
                old = (REPO / relative).read_bytes()
                modified = brand_content(relative, old)
                self.assertNotEqual(old, modified)
                for original, replacement in REPLACEMENTS[relative]:
                    self.assertEqual(old.count(original), 1)
                    self.assertEqual(modified.count(original), 0)
                    self.assertIn(replacement.replace(b"\n", b"\r\n")
                                  if b"\r\n" in old else replacement, modified)

    def test_generated_overlay_preserves_original_files(self):
        snapshot = {rel: (self.source / rel).read_bytes() for rel in REPLACEMENTS}
        preview = generate(self.source, self.output)
        self.assertEqual(preview["name"], DISPLAY_NAME)
        self.assertEqual(preview["status"], "dry-run")
        self.assertFalse(self.output.exists())
        created = generate(self.source, self.output, write=True)
        self.assertEqual(created["status"], "written")
        self.assertFalse(created["gameplay_assets_cleared_for_distribution"])
        for relative in REPLACEMENTS:
            self.assertEqual((self.source / relative).read_bytes(), snapshot[relative])
            self.assertEqual((self.output / relative).read_bytes(),
                             brand_content(relative, snapshot[relative]))
        self.assertEqual(generate(self.source, self.output, write=True)["status"], "written")

    def test_does_not_replace_map_names_or_technical_paths(self):
        generate(self.source, self.output, write=True)
        serverlist = (self.output / "PhongThanRuntime-Staging/Client/serverlist.ini").read_bytes()
        self.assertIn(b"0_Title=Phong Than Dai", serverlist)
        self.assertIn(b"0_Address=127.0.0.1", serverlist)
        cpp = (self.output / "PhongThanSource/Sources/GameClient/PhongThanClient.cpp").read_bytes()
        self.assertIn(b'SetWindowText(g_GetMainHWnd(), g_szGameName);', cpp)
        self.assertIn(b'strcpy(g_szGameName, "Huyen Vuc Ky");', cpp)

    def test_changed_archival_anchor_fails_without_writes(self):
        target = self.source / "PhongThanRuntime-Staging/Client/serverlist.ini"
        target.write_bytes(target.read_bytes().replace(b"Phong Than Online (DEV AG v1)",
                                                      b"Unknown server", 1))
        with self.assertRaisesRegex(BrandError, "branding context"):
            generate(self.source, self.output, write=True)
        self.assertFalse(self.output.exists())

    def test_refuses_writing_inside_original_tree(self):
        with self.assertRaisesRegex(BrandError, "original archive"):
            generate(self.source, self.source / "generated", write=True)

    def test_unknown_input_fails_closed(self):
        with self.assertRaisesRegex(BrandError, "Unknown branding file"):
            brand_content("Game.exe", b"anything")


if __name__ == "__main__":
    unittest.main()
