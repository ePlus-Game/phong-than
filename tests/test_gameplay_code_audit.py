import tempfile
import unittest
from pathlib import Path
from tools.gameplay_code_audit import audit, scan_file, markdown

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

    def test_missing_roots_reported(self):
        with tempfile.TemporaryDirectory() as temp:
            data = audit(Path(temp))
            self.assertEqual(data["files_scanned"], 0)
            self.assertIn("candidate matches only", markdown(data))

if __name__ == "__main__":
    unittest.main()
