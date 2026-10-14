"""Synthetic Git-tree inventory tests; no project data read or mutated."""
from __future__ import annotations

import unittest

from tools.repository_hygiene import groups_for, markdown, parse_tree, summarize


def blob(path: str, size: int, sha: str = "a" * 40) -> bytes:
    return (
        f"100644 blob {sha} {size}".encode("ascii")
        + b"\t" + path.encode("utf-8") + b"\x00"
    )


class RepositoryHygieneTests(unittest.TestCase):
    def test_counts_and_dedup_without_exposing_names(self):
        records = (
            blob("_backup/legacy.bin", 50)
            + blob("PhongThanRuntime-Staging/Client/a.log", 123)
            + blob("PhongThanRuntime-Staging/Server/database/private-account.bak", 200)
            + blob("PhongThanSource/OutputModern/Client/Game.exe", 100)
            + blob("PhongThanRuntime-Staging/Client/file.pak.parts/part-0000.bin", 90)
            + blob("PhongThanSource/Output/Server/Engine.pdb", 20, "b" * 40)
        )
        summary = summarize(parse_tree(records))
        self.assertEqual(summary["tracked_files"], 6)
        self.assertEqual(summary["logical_bytes"], 583)
        self.assertEqual(summary["repeated_blob_references"], 4)
        groups = {x["group"]: x for x in summary["categories"]}
        self.assertEqual(groups["original_backups"]["files"], 1)
        self.assertEqual(groups["runtime_logs"]["files"], 1)
        self.assertEqual(groups["debug_symbols"]["files"], 1)
        self.assertEqual(groups["historical_build_outputs"]["files"], 2)
        self.assertEqual(groups["sql_and_character_state"]["files"], 1)
        self.assertEqual(groups["split_pak_parts"]["files"], 1)
        public = markdown(summary)
        self.assertNotIn("private-account", public)
        self.assertNotIn("legacy.bin", public)
        self.assertNotIn("Game.exe", public)

    def test_null_delimited_paths_with_unicode_and_tabs(self):
        raw = blob("PhongThanSource/Sources/võ công\tbản gốc.cpp", 15)
        self.assertEqual(next(parse_tree(raw))[1], 15)
        self.assertEqual(len(list(parse_tree(raw))), 1)

    def test_malformed_entries_fail_closed(self):
        with self.assertRaisesRegex(ValueError, "Malformed Git"):
            list(parse_tree(b"bad record\x00"))

    def test_other_paths_are_not_categorized_as_runtime(self):
        self.assertEqual(list(groups_for("docs/MASTER_ROADMAP.md")), [])
        self.assertEqual(list(groups_for("tests/test_something.py")), [])
        self.assertEqual(list(groups_for("_backup/a.log")), ["original_backups"])


if __name__ == "__main__":
    unittest.main()
