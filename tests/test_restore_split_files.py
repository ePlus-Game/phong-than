"""Verify safe historical paths and byte-checked split-file restoration."""
import csv
import hashlib
import tempfile
import unittest
from pathlib import Path
from tools.restore_split_files import restore, translate

class RestoreSplitFilesTests(unittest.TestCase):
    def test_paths(self):
        self.assertEqual(translate("source/PT/PhongThanSource/README.md"), Path("PhongThanSource/README.md"))
        self.assertEqual(translate("source/PT/docs/features/a.md"), Path("docs/original-pt/features/a.md"))
        for invalid in ("source/PT/../oops", "source/PT/a/../../oops", "source/PT/a\\b", "source/PT/C:/a", "other/file"):
            with self.subTest(path=invalid):
                with self.assertRaises(ValueError):
                    translate(invalid)

    def test_verified_restore(self):
        with tempfile.TemporaryDirectory() as name:
            root = Path(name)
            payload = b"example test data (not game content)"
            target = root / "PhongThanRuntime-Staging/Client/data/sample.pak"
            parts = Path(str(target) + ".parts")
            parts.mkdir(parents=True)
            (parts / "part-0000.bin").write_bytes(payload[:10])
            (parts / "part-0001.bin").write_bytes(payload[10:])
            manifest = root / "archive/PT_EXACT_ZIP_MANIFEST.csv"
            manifest.parent.mkdir(parents=True)
            with manifest.open("w", newline="", encoding="utf-8") as fh:
                writer = csv.DictWriter(fh, fieldnames=("storage", "git_or_archive_path", "uncompressed_bytes", "sha256"))
                writer.writeheader()
                writer.writerow({
                    "storage": "split-git-parts",
                    "git_or_archive_path": "source/PT/PhongThanRuntime-Staging/Client/data/sample.pak",
                    "uncompressed_bytes": len(payload),
                    "sha256": hashlib.sha256(payload).hexdigest(),
                })
            self.assertEqual(restore(root), 1)
            self.assertEqual(target.read_bytes(), payload)
            (parts / "part-0001.bin").write_bytes(b"CORRUPTED")
            with self.assertRaises(ValueError):
                restore(root)
            self.assertEqual(target.read_bytes(), payload)

if __name__ == "__main__":
    unittest.main()
