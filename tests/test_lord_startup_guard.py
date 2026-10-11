"""Static guard against uninitialized controller use in the VC6 lord entrypoint.

Does not execute or compile the proprietary server binary.
"""
import re
import unittest
from pathlib import Path

LORD_SOURCE = (
    Path(__file__).resolve().parents[1] / "Server" / "lord" / "src" / "lord.cpp"
)


class LordStartupGuardTests(unittest.TestCase):
    def test_controller_is_initialized_and_creation_checked(self):
        source = LORD_SOURCE.read_bytes().decode("latin-1")
        self.assertRegex(source, r"IController\s*\*\s*pController\s*=\s*0\s*;")
        self.assertRegex(
            source,
            r"if\s*\(\s*INVALID_VALUE\s*==\s*CreateController\s*\(\s*pController\s*\)",
        )
        self.assertRegex(source, r"\|\|\s*!pController")
        self.assertLess(
            source.index("CreateController( pController )"),
            source.index("pController->Startup"),
        )

    def test_controller_released_on_failed_startup(self):
        source = LORD_SOURCE.read_bytes().decode("latin-1")
        start = source.index("if( INVALID_VALUE == pController->Startup")
        block = source[start:source.index("\n\t}", start) + 3]
        self.assertIn("pController->Release( );", block)
        self.assertLess(block.index("pController->Release( );"), block.index("return 1;"))

    def test_failed_startup_returns_nonzero(self):
        source = LORD_SOURCE.read_bytes().decode("latin-1")
        self.assertRegex(
            source,
            r"if\s*\(\s*INVALID_VALUE\s*==\s*pController->Startup"
            r"\(\s*nDaemon\s*\)\s*\)\s*\{[^}]*return\s+1\s*;",
        )


if __name__ == "__main__":
    unittest.main()
