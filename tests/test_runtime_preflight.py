"""Synthetic PE fixtures: tests never execute a game binary or connect to SQL."""
from __future__ import annotations
import json
import struct
import tempfile
import unittest
from pathlib import Path
from tools.runtime_preflight import count_maps, run_preflight
from tools.verify_windows_build import EXPECTED


def fake_pe(dll: bool) -> bytes:
    buf = bytearray(512)
    buf[:2] = b"MZ"
    struct.pack_into("<I", buf, 0x3C, 0x80)
    struct.pack_into("<4sHHIIIHH", buf, 0x80, b"PE\0\0", 0x14C,
                     1, 0, 0, 0, 224, 0x0002 | (0x2000 if dll else 0))
    struct.pack_into("<H", buf, 0x80 + 24, 0x10B)
    return bytes(buf)


class ReadOnlyRuntimeTests(unittest.TestCase):
    def populate(self, root: Path) -> Path:
        for role, filenames in EXPECTED.items():
            folder = root / role
            folder.mkdir(parents=True, exist_ok=True)
            for name in filenames:
                (folder / name).write_bytes(fake_pe(name.endswith(".dll")))
        (root / "Server/maps").mkdir(parents=True)
        (root / "Server/maps/WorldSet.ini").write_bytes(b"[WorldSet]\r\nCount=102\r\n")
        (root / "Server/ServerCfg.ini").write_text("[Relay]\nServiceId=1001\nSECRET=never_log\n")
        (root / "Server/DataBase.ini").write_text("password=DO_NOT_LOG\n")
        manifest = root.parent / "manifest.json"
        manifest.write_text(json.dumps({
            "DataRegistries": {"Gameplay": {"Map": {"ExpectedActiveMapCount": 102}}},
            "RuntimeSettings": {"ExpectedListeningPorts": {
                name: [5001] for name in (
                    "Goddess.exe", "PhongThanAccountServer.exe",
                    "PhongThanRelay.exe", "Bishop.exe", "GameServer.exe"
                )
            }}
        }), encoding="utf-8")
        return manifest

    def test_static_ready_does_not_claim_runtime(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "runtime"
            manifest = self.populate(root)
            result = run_preflight(root, manifest=manifest)
            self.assertEqual(result["status"], "READY_FOR_RUNTIME_TEST")
            self.assertEqual(result["verified_binary_count"], 22)
            self.assertFalse(result["runtime_tested"])
            self.assertFalse(result["process_started"])
            self.assertFalse(result["database_modified"])
            self.assertFalse(result["gameplay_tested"])
            exported = json.dumps(result)
            for secret in (tmp, "DO_NOT_LOG", "never_log"):
                self.assertNotIn(secret, exported)

    def test_map_count_missing_wrong_and_ambiguous(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "runtime"
            manifest = self.populate(root)
            path = root / "Server/maps/WorldSet.ini"
            for data in (b"Count=96\r\n", b"Count=102\r\nCount=102\r\n", b""):
                path.write_bytes(data)
                self.assertEqual(run_preflight(root, manifest=manifest)["status"], "BLOCKED")
            path.unlink()
            self.assertIsNone(count_maps(path))

    def test_wrong_relay_binary_and_manifest_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "runtime"
            manifest = self.populate(root)
            (root / "Server/S3Relay.exe").write_bytes(fake_pe(False))
            self.assertTrue(any("obsolete" in x for x in
                                run_preflight(root, manifest=manifest)["failures"]))
            (root / "Server/S3Relay.exe").unlink()
            cfg = json.loads(manifest.read_text())
            ports = cfg["RuntimeSettings"]["ExpectedListeningPorts"]
            ports["S3Relay.exe"] = ports.pop("PhongThanRelay.exe")
            manifest.write_text(json.dumps(cfg), encoding="utf-8")
            self.assertTrue(any("manifest relay key" in x for x in
                                run_preflight(root, manifest=manifest)["failures"]))

    def test_missing_server_binary_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "runtime"
            manifest = self.populate(root)
            (root / "Server/GameServer.exe").unlink()
            report = run_preflight(root, manifest=manifest)
            self.assertEqual(report["status"], "BLOCKED")
            self.assertTrue(any("GameServer.exe" in x for x in report["failures"]))

    def test_bundle_mode_never_claims_gameplay(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "bundle"
            self.populate(root)
            for rel in ("Server/maps/WorldSet.ini", "Server/ServerCfg.ini",
                        "Server/DataBase.ini"):
                (root / rel).unlink()
            result = run_preflight(root, mode="bundle")
            self.assertEqual(result["status"], "READY_FOR_RUNTIME_TEST")
            self.assertFalse(result["login_tested"])


if __name__ == "__main__":
    unittest.main()
