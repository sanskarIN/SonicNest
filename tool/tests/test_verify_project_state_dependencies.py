from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

TOOL_PATH = Path(__file__).resolve().parents[1] / "verify_project_state_dependencies.py"
SPEC = importlib.util.spec_from_file_location("verify_project_state_dependencies", TOOL_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


PUBSPEC = """\
name: sonic_nest
dependencies:
  flutter:
    sdk: flutter
  record: ^7.1.1
  just_audio: ^0.10.6
  just_audio_background: 0.0.1-beta.17
  just_audio_media_kit: ^2.1.0
  ffmpeg_kit_flutter_new_audio: ^2.5.0
  file_picker: 12.0.0-beta.7
  share_plus: 13.3.0
  wakelock_plus: 1.7.0
dev_dependencies:
  flutter_test:
    sdk: flutter
"""

PROJECT_STATE = """\
# SonicNest Project State

```yaml
stack:
  ui: Flutter / Dart
  recorder: record 7.1.1
  player: just_audio 0.10.6 + just_audio_background 0.0.1-beta.17 + just_audio_media_kit 2.1.0
  processing: ffmpeg_kit_flutter_new_audio 2.5.x
  persistence: local JSON metadata + shared_preferences
  import_export: file_picker 12.0.0-beta.7 + share_plus 13.3.0
  screen_wake: wakelock_plus 1.7.0
  localization: in-project AppLocalizations scaffold; English currently supported
supported_platform_targets:
  - Android
```
"""


class DependencyStateVerifierTests(unittest.TestCase):
    def test_parse_direct_dependencies_normalizes_caret_constraints(self) -> None:
        dependencies = MODULE.parse_direct_dependencies(PUBSPEC)
        self.assertEqual(dependencies["record"], "7.1.1")
        self.assertEqual(dependencies["ffmpeg_kit_flutter_new_audio"], "2.5.0")
        self.assertEqual(dependencies["file_picker"], "12.0.0-beta.7")

    def test_matching_project_state_passes(self) -> None:
        self.assertEqual(MODULE.verify(PUBSPEC, PROJECT_STATE), [])

    def test_stale_import_export_versions_are_reported(self) -> None:
        stale = PROJECT_STATE.replace(
            "file_picker 12.0.0-beta.7 + share_plus 13.3.0",
            "file_picker 10.3.10 + share_plus 12.0.2",
        )
        errors = MODULE.verify(PUBSPEC, stale)
        self.assertEqual(len(errors), 1)
        self.assertIn("stack.import_export is stale", errors[0])
        self.assertIn("file_picker 12.0.0-beta.7", errors[0])

    def test_stale_wakelock_version_is_reported(self) -> None:
        stale = PROJECT_STATE.replace("wakelock_plus 1.7.0", "wakelock_plus 1.4.0")
        errors = MODULE.verify(PUBSPEC, stale)
        self.assertEqual(len(errors), 1)
        self.assertIn("stack.screen_wake is stale", errors[0])

    def test_missing_required_dependency_is_rejected(self) -> None:
        malformed = PUBSPEC.replace("  share_plus: 13.3.0\n", "")
        with self.assertRaises(MODULE.DependencyStateError):
            MODULE.parse_direct_dependencies(malformed)

    def test_nested_required_dependency_is_rejected(self) -> None:
        malformed = PUBSPEC.replace(
            "  record: ^7.1.1\n",
            "  record:\n    path: ../record\n",
        )
        with self.assertRaises(MODULE.DependencyStateError):
            MODULE.parse_direct_dependencies(malformed)

    def test_compound_constraint_is_rejected_conservatively(self) -> None:
        malformed = PUBSPEC.replace("  record: ^7.1.1\n", "  record: '>=7.1.1 <8.0.0'\n")
        with self.assertRaises(MODULE.DependencyStateError):
            MODULE.parse_direct_dependencies(malformed)

    def test_missing_stack_block_is_rejected(self) -> None:
        with self.assertRaises(MODULE.DependencyStateError):
            MODULE.parse_project_stack("# no canonical stack\n")

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
                PROJECT_STATE.replace("wakelock_plus 1.7.0", "wakelock_plus 1.4.0"),
                encoding="utf-8",
            )
            self.assertEqual(
                MODULE.main(
                    ["--pubspec", str(pubspec), "--project-state", str(state)]
                ),
                1,
            )


if __name__ == "__main__":
    unittest.main()
