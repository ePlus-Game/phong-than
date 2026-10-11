"""Fixture-based tests for static recovery inventory; no game execution."""
import tempfile
import unittest
from pathlib import Path

from tools.recovery_inventory import inventory, as_markdown


class RecoveryInventoryTest(unittest.TestCase):
    def test_missing_runtime_and_bundled_import_libraries(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "PhongThanSource/Lib/release").mkdir(parents=True)
            (root / "PhongThanSource/Sources/MultiServer/Common").mkdir(parents=True)
            (root / "PhongThanSource/Lib/release/Game.lib").write_bytes(b"placeholder")
            (root / "PhongThanSource/Sources/MultiServer/Common/demo.cpp").write_text("/* fixture */")
            (root / "PhongThanSource/Sources/MultiServer/Common/demo.dsp").write_text(
                '# Microsoft Developer Studio Project File - Name="demo"\n'
                '# TARGTYPE "Win32 (x86) Application"\n'
                'SOURCE=.\\demo.cpp\n'
                '# ADD LINK32 Game.lib kernel32.lib ThirdParty.lib\n'
            )
            data = inventory(root)
            self.assertEqual(data["project_count"], 1)
            self.assertEqual(data["project_paths"]["present_references"], 1)
            self.assertEqual(data["runtime"]["Game.dll"], [])
            self.assertEqual(data["database_schema_files"], [])
            self.assertIn("game.lib", data["projects"][0]["bundled_release"])
            self.assertIn("thirdparty.lib", data["projects"][0]["external_or_sdk"])
            self.assertIn("Not found", as_markdown(data))


if __name__ == "__main__":
    unittest.main()
