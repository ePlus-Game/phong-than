"""Synthetic structural PE fixtures; these tests do not build or run the legacy game."""
from __future__ import annotations

import contextlib
import io
import json
import struct
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from tools.verify_windows_build import EXPECTED, inspect_pe, main, verify_build


def make_pe(*, machine=0x14C, dll=False, magic=0x10B, flags=None) -> bytes:
    data = bytearray(512)
    data[:2] = b"MZ"
    struct.pack_into("<I", data, 0x3C, 0x80)
    if flags is None:
        flags = 0x0002 | (0x2000 if dll else 0)
    struct.pack_into("<4sHHIIIHH", data, 0x80,
                     b"PE\0\0", machine, 1, 0, 0, 0, 224, flags)
    struct.pack_into("<H", data, 0x80 + 24, magic)
    return bytes(data)


class WindowsBuildVerifierTests(unittest.TestCase):
    def populate(self, root: Path) -> None:
        for role, filenames in EXPECTED.items():
            directory = root / role
            directory.mkdir(parents=True, exist_ok=True)
            for name in filenames:
                (directory / name).write_bytes(make_pe(dll=name.lower().endswith(".dll")))

    def test_complete_two_role_inventory_passes_structural_checks(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.populate(root)
            report = verify_build(root)
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(report["expected_binary_count"], 22)
            self.assertEqual(report["verified_binary_count"], 22)
            self.assertFalse(report["runtime_tested"])
            self.assertFalse(report["network_tested"])
            self.assertNotIn(tmp, json.dumps(report))
            self.assertEqual(len(report["artifacts"][0]["sha256"]), 64)

    def test_missing_game_or_server_fails_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.populate(root)
            (root / "Client" / "Game.exe").unlink()
            (root / "Server" / "GameServer.exe").unlink()
            report = verify_build(root)
            self.assertEqual(report["status"], "FAIL")
            self.assertEqual(report["verified_binary_count"], 20)
            self.assertIn("Client/Game.exe: missing binary", report["failures"])
            self.assertIn("Server/GameServer.exe: missing binary", report["failures"])

    def test_x64_and_wrong_optional_header_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Game.exe"
            path.write_bytes(make_pe(machine=0x8664))
            with self.assertRaisesRegex(ValueError, "x86"):
                inspect_pe(path, require_dll=False)
            path.write_bytes(make_pe(magic=0x20B))
            with self.assertRaisesRegex(ValueError, "PE32"):
                inspect_pe(path, require_dll=False)

    def test_dll_and_exe_type_confusion_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Game.exe"
            path.write_bytes(make_pe(dll=True))
            with self.assertRaisesRegex(ValueError, "DLL/EXE"):
                inspect_pe(path, require_dll=False)
            path.write_bytes(make_pe(dll=False))
            with self.assertRaisesRegex(ValueError, "DLL/EXE"):
                inspect_pe(path, require_dll=True)

    def test_missing_signature_truncated_file_and_non_executable(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Game.exe"
            path.write_bytes(b"MZ")
            with self.assertRaisesRegex(ValueError, "truncated"):
                inspect_pe(path, require_dll=False)
            path.write_bytes(b"MZ" + b"\x00" * 510)
            with self.assertRaisesRegex(ValueError, "PE offset"):
                inspect_pe(path, require_dll=False)
            path.write_bytes(make_pe(flags=0))
            with self.assertRaisesRegex(ValueError, "executable image"):
                inspect_pe(path, require_dll=False)

    def test_cli_fails_closed_and_writes_anonymous_report(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "OutputModern"
            root.mkdir()
            report_path = Path(tmp) / "result.json"
            capture = io.StringIO()
            with patch("sys.argv", ["verify_windows_build", "--output-root",
                                    str(root), "--report", str(report_path)]):
                with contextlib.redirect_stdout(capture):
                    result = main()
            self.assertEqual(result, 2)
            data = json.loads(report_path.read_text(encoding="utf-8"))
            self.assertEqual(data["status"], "FAIL")
            self.assertTrue(data["failures"])
            self.assertNotIn(tmp, capture.getvalue())


if __name__ == "__main__":
    unittest.main()
