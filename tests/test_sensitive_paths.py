"""Only metadata is inspected by the public archive risk inventory."""
import unittest
from tools.audit_sensitive_paths import audit, categorize, markdown


class SensitivePathTests(unittest.TestCase):
    def test_flags_runtime_private_data_without_reading_it(self):
        samples = [
            "source/PT/PhongThanRuntime-Staging/Server/database/account.bak",
            "source/PT/PhongThanRuntime-Staging/Server/CharacterStore/role_abc.pthc",
            "source/PT/PhongThanRuntime-Staging/Server/admin_bridge/token.log",
            "source/PT/PhongThanRuntime-Staging/Server/DataBase.ini",
            "source/PT/PhongThanSource/__historical_git__/original-dot-git.zip",
            "source/PT/PhongThanSource/Sources/MultiServer/GameServer/GameServer.cpp",
        ]
        result = audit(samples)
        self.assertEqual(result["tracked_files"], 6)
        for category in ("database_or_other_backup", "character_save_data",
                         "runtime_database_files", "operational_logs",
                         "server_configuration", "archived_git_history"):
            self.assertGreater(result["possible_sensitive_categories"].get(category, 0), 0)
        self.assertEqual(categorize(samples[-1]), set())
        self.assertNotIn("role_abc", markdown(result))
        self.assertNotIn("token.log", markdown(result))
