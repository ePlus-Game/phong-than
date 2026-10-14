import tempfile
import unittest
from pathlib import Path
from tools.gameplay_code_audit import audit, scan_file, markdown, inspect_level_cap

class GameplayCodeAuditTests(unittest.TestCase):
    def test_legacy_encoding_and_lines(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            path = root / "sample.txt"
            path.write_bytes("header\nGiáp Sĩ\nMAX_PLAYER_LEVEL=200\n".encode("gb18030"))
            row = scan_file(path, root)
            self.assertEqual(row["encoding"], "gb18030")
            self.assertTrue(any(h["topic"] == "class" and h["line"] == 2 for h in row["hits"]))
            self.assertTrue(any(h["topic"] == "level" and h["line"] == 3 for h in row["hits"]))

    def test_player_level_cap_and_overflow(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            hdr = root / "PhongThanSource/Sources/Core/Src/GameDataDef.h"
            exp = root / "PhongThanRuntime-Staging/Server/settings/npc/player/level_exp.txt"
            hdr.parent.mkdir(parents=True, exist_ok=True)
            exp.parent.mkdir(parents=True, exist_ok=True)
            hdr.write_text("#define MAX_LEVEL 200\n", encoding="utf-8")
            exp.write_bytes("等级\\t经验\r\n1\t100\r\n131\t5300556000\r\n200\t5300556000\r\n".replace("\\t", "\t").encode("gb18030"))
            info = inspect_level_cap(root)
            self.assertEqual(info["declared_max_level"], 200)
            self.assertEqual(info["last_exp_level"], 200)
            self.assertEqual(info["exp_over_int32_from"], 131)

    def test_missing_roots_reported(self):
        with tempfile.TemporaryDirectory() as temp:
            data = audit(Path(temp))
            self.assertEqual(data["files_scanned"], 0)
            self.assertIn("candidate matches only", markdown(data))

if __name__ == "__main__":
    unittest.main()
