"""Archive-preserving Phong Than Truyen Ky branding checks."""
from __future__ import annotations

import shutil
import tempfile
import unittest
from pathlib import Path

from tools.build_branding_overlay import (
    BrandError, DISPLAY_NAME, REPLACEMENTS, EXIT_PROMPT_ASCII,
    EXIT_PROMPT_TCVN, brand_content, generate,
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
                    # SetWindowText call is intentionally preserved after inserting
                    # a branded strcpy before it; old bytes remain as a substring.
                    if original not in replacement:
                        self.assertEqual(modified.count(original), 0)
                    self.assertIn(replacement.replace(b"\n", b"\r\n")
                                  if b"\r\n" in old else replacement, modified)


    def test_exit_dialog_keeps_legacy_tcvn3_and_old_archive_compatibility(self):
        path = "PhongThanRuntime-Staging/Client/Ui/Setting.ini"
        current = (REPO / path).read_bytes()
        self.assertEqual(current.count(EXIT_PROMPT_TCVN[0]), 1)
        fixed = brand_content(path, current)
        self.assertEqual(fixed.count(EXIT_PROMPT_TCVN[1]), 1)
        self.assertNotIn("22=Bạn có muốn thoát".encode("utf-8"), fixed)
        original_ascii = current.replace(EXIT_PROMPT_TCVN[0], EXIT_PROMPT_ASCII[0], 1)
        old_branded = brand_content(path, original_ascii)
        self.assertIn(EXIT_PROMPT_ASCII[1], old_branded)
        self.assertNotIn(EXIT_PROMPT_TCVN[1], old_branded)
        with self.assertRaisesRegex(BrandError, "branding context"):
            brand_content(path, current + EXIT_PROMPT_ASCII[0])

    def test_generated_overlay_preserves_original_files(self):
        snapshot = {rel: (self.source / rel).read_bytes() for rel in REPLACEMENTS}
        preview = generate(self.source, self.output)
        self.assertEqual(preview["name"], DISPLAY_NAME)
        self.assertEqual(preview["status"], "dry-run")
        self.assertFalse(self.output.exists())
        created = generate(self.source, self.output, write=True)
        self.assertEqual(created["status"], "written")
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
        self.assertIn(b'strcpy(g_szGameName, "Phong Than Truyen Ky");', cpp)

    def test_consistent_rebrand_across_game_and_admin_labels(self):
        generated = generate(self.source, self.output, write=True)
        self.assertEqual(generated["name"], "Phong Thần Truyền Kỳ")
        self.assertEqual(generated["ascii_name"], "Phong Than Truyen Ky")
        display_files = [
            "PhongThanRuntime-Staging/Client/Ui/Setting.ini",
            "PhongThanRuntime-Staging/Client/serverlist.ini",
            "PhongThanSource/Sources/GameClient/PhongThanClient.cpp",
            "AdminWeb/index.html",
            "PhongThan-Admin.cmd",
            "PhongThan-CaiDat.cmd",
            "PhongThan-ChayTatCa.cmd",
            "PhongThan-BangDieuKhien.cmd",
            "PhongThanSource/Deploy/PhongThan-Control.ps1",
            "PhongThanSource/Deploy/PhongThan-AccountForm.ps1",
        ]
        for relative in display_files:
            with self.subTest(file=relative):
                data = (self.output / relative).read_bytes()
                self.assertNotIn(b"Huyen Vuc Ky", data)
                self.assertNotIn("Huyền Vực Ký".encode("utf-8"), data)
                if relative.endswith("index.html"):
                    self.assertIn("Phong Thần Truyền Kỳ".encode("utf-8"), data)
                else:
                    self.assertIn(b"Phong Than Truyen Ky", data)

    def test_public_documents_use_current_name_without_draft_claims(self):
        for relative in ("README.md", "docs/BRANDING.md"):
            with self.subTest(file=relative):
                text = (REPO / relative).read_text(encoding="utf-8")
                self.assertIn("Phong Thần Truyền Kỳ", text)
                self.assertIn("Phong Than Truyen Ky", text)
                self.assertNotIn("Huyền Vực Ký", text)
                self.assertNotIn("Huyen Vuc Ky", text)
                self.assertNotIn("Tên thương hiệu dự kiến", text)
                self.assertNotIn("chưa tra cứu/đăng ký nhãn hiệu", text)

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
