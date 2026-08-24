from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

TOOL_PATH = Path(__file__).resolve().parents[1] / "verify_release_version.py"
SPEC = importlib.util.spec_from_file_location("verify_release_version", TOOL_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


PUBSPEC = """\
name: sonic_nest
version: 2.18.12+21812

dependencies:
  flutter:
    sdk: flutter
"""

PROJECT_STATE = """\
# SonicNest Project State

```yaml
project: SonicNest
current_version: 2.18.12
release_classification: development_preview_until_manual_release_gates_are_complete
```
"""


class ReleaseVersionVerifierTests(unittest.TestCase):
    def test_parse_pubspec_version(self) -> None:
        version = MODULE.parse_pubspec_version(PUBSPEC)
        self.assertEqual(version.semantic_version, "2.18.12")
        self.assertEqual(version.build_number, 21812)
        self.assertEqual(version.pubspec_version, "2.18.12+21812")

    def test_matching_metadata_passes(self) -> None:
        self.assertEqual(MODULE.verify(PUBSPEC, PROJECT_STATE), [])

    def test_stale_project_state_version_is_reported(self) -> None:
        stale = PROJECT_STATE.replace("2.18.12", "2.18.11")
        errors = MODULE.verify(PUBSPEC, stale)
        self.assertEqual(len(errors), 1)
        self.assertIn("current_version is stale", errors[0])
        self.assertIn("2.18.12", errors[0])

    def test_missing_build_number_is_rejected(self) -> None:
        malformed = PUBSPEC.replace("2.18.12+21812", "2.18.12")
        with self.assertRaises(MODULE.ReleaseVersionError):
            MODULE.parse_pubspec_version(malformed)

    def test_zero_build_number_is_rejected(self) -> None:
        malformed = PUBSPEC.replace("2.18.12+21812", "2.18.12+0")
        with self.assertRaises(MODULE.ReleaseVersionError):
            MODULE.parse_pubspec_version(malformed)

    def test_prerelease_project_state_version_is_rejected(self) -> None:
        malformed = PROJECT_STATE.replace("2.18.12", "2.18.12-rc.1")
        with self.assertRaises(MODULE.ReleaseVersionError):
            MODULE.parse_project_state_version(malformed)

    def test_duplicate_pubspec_version_is_rejected(self) -> None:
        malformed = PUBSPEC + "version: 9.9.9+9\n"
        with self.assertRaises(MODULE.ReleaseVersionError):
            MODULE.parse_pubspec_version(malformed)

    def test_cli_returns_zero_for_matching_files(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            pubspec = root / "pubspec.yaml"
            state = root / "PROJECT_STATE.md"
            pubspec.write_text(PUBSPEC, encoding="utf-8")
            state.write_text(PROJECT_STATE, encoding="utf-8")
            self.assertEqual(
                MODULE.main(
                    ["--pubspec", str(pubspec), "--project-state", str(state)]
                ),
                0,
            )

    def test_cli_returns_one_for_stale_state(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            pubspec = root / "pubspec.yaml"
            state = root / "PROJECT_STATE.md"
            pubspec.write_text(PUBSPEC, encoding="utf-8")
            state.write_text(
                PROJECT_STATE.replace("2.18.12", "2.18.11"),
                encoding="utf-8",
            )
            self.assertEqual(
                MODULE.main(
                    ["--pubspec", str(pubspec), "--project-state", str(state)]
                ),
                1,
            )

    def test_cli_returns_two_for_malformed_version(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            pubspec = root / "pubspec.yaml"
            state = root / "PROJECT_STATE.md"
            pubspec.write_text(
                PUBSPEC.replace("2.18.12+21812", "2.18.12"),
                encoding="utf-8",
            )
            state.write_text(PROJECT_STATE, encoding="utf-8")
            self.assertEqual(
                MODULE.main(
                    ["--pubspec", str(pubspec), "--project-state", str(state)]
                ),
                2,
            )


if __name__ == "__main__":
    unittest.main()
