"""Synthetic PE fixtures: verify import scanning without running the game."""
from pathlib import Path
import struct
import tempfile
import unittest

from tools.audit_windows_imports import ImportFormatError, audit_build, read_imports
from tools.verify_windows_build import EXPECTED


def pe_fixture(import_names=(), delay_import_names=(), *, malformed=False):
    buf = bytearray(2048)
    buf[:2] = b"MZ"
    struct.pack_into("<I", buf, 0x3C, 0x80)
    struct.pack_into("<4sHHIIIHH", buf, 0x80,
                     b"PE\0\0", 0x14C, 1, 0, 0, 0, 224, 0x0002)
    opt = 0x98
    struct.pack_into("<H", buf, opt, 0x10B)
    struct.pack_into("<I", buf, opt + 28, 0x400000)
    struct.pack_into("<I", buf, opt + 60, 0x200)
    struct.pack_into("<I", buf, opt + 92, 16)
    section = opt + 224
    buf[section:section + 8] = b".idata\0\0"
    struct.pack_into("<IIII", buf, section + 8, 0x600, 0x1000, 0x600, 0x200)
    at = 0x600
    if import_names:
        for index, name in enumerate(import_names):
            encoded = name.encode("ascii") + b"\0"
            struct.pack_into("<IIIII", buf, 0x200 + index * 20,
                             0, 0, 0, 0x1000 + at - 0x200, 0)
            buf[at:at + len(encoded)] = encoded
            at += len(encoded)
        struct.pack_into("<II", buf, opt + 104, 0x1000, (len(import_names) + 1) * 20)
    if delay_import_names:
        at = max(at, 0x6E0)
        for index, name in enumerate(delay_import_names):
            encoded = name.encode("ascii") + b"\0"
            struct.pack_into("<II", buf, 0x400 + index * 32,
                             1, 0x1000 + at - 0x200)
            buf[at:at + len(encoded)] = encoded
            at += len(encoded)
        struct.pack_into("<II", buf, opt + 96 + 13 * 8,
                         0x1200, (len(delay_import_names) + 1) * 32)
    if malformed:
        struct.pack_into("<II", buf, opt + 104, 0x9000, 20)
    return bytes(buf)


class ImportAuditTests(unittest.TestCase):
    def test_no_imports(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Game.exe"
            path.write_bytes(pe_fixture())
            self.assertEqual(read_imports(path), ([], []))

    def test_normal_and_delay_imports(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Game.exe"
            path.write_bytes(pe_fixture(["kernel32.DLL", "Engine.DLL"],
                                        ["d3dx9_43.dll"]))
            self.assertEqual(read_imports(path),
                             (["engine.dll", "kernel32.dll"], ["d3dx9_43.dll"]))

    def test_bad_directory_fails_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Game.exe"
            path.write_bytes(pe_fixture(malformed=True))
            with self.assertRaisesRegex(ImportFormatError, "unmapped"):
                read_imports(path)

    def populate(self, root):
        for role, names in EXPECTED.items():
            for name in names:
                path = root / role / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(pe_fixture())

    def test_local_system_and_external_are_distinguished(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.populate(root)
            (root / "Client" / "Game.exe").write_bytes(
                pe_fixture(["Engine.dll", "kernel32.dll", "d3dx9_43.dll"]))
            result = audit_build(root)
            self.assertEqual(result["status"], "PASS", result["failures"])
            self.assertEqual(result["analyzed_binary_count"], 22)
            game = next(x for x in result["artifacts"] if x["path"] == "Client/Game.exe")
            self.assertEqual(game["classifications"]["local"], ["engine.dll"])
            self.assertEqual(game["classifications"]["windows"], ["kernel32.dll"])
            self.assertEqual(game["classifications"]["external"], ["d3dx9_43.dll"])
            self.assertFalse(result["os_loader_tested"])
            self.assertFalse(result["runtime_tested"])
            self.assertNotIn(tmp, str(result))

    def test_import_from_wrong_game_role_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.populate(root)
            (root / "Client" / "Game.exe").write_bytes(pe_fixture(["CoreServer.dll"]))
            result = audit_build(root)
            self.assertEqual(result["status"], "FAIL")
            self.assertIn("coreserver.dll", result["failures"][0])

    def test_missing_binary_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = audit_build(Path(tmp))
            self.assertEqual(result["status"], "FAIL")
            self.assertEqual(result["analyzed_binary_count"], 0)


if __name__ == "__main__":
    unittest.main()
