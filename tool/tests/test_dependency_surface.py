from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class DependencySurfaceRegressionTest(unittest.TestCase):
    def test_security_reviewed_runtime_versions_are_tracked(self) -> None:
        pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
        self.assertIn("file_picker: 11.0.3", pubspec)
        self.assertIn("wakelock_plus: 1.5.2", pubspec)

    def test_file_picker_uses_v11_static_api(self) -> None:
        source = (ROOT / "lib/services/external_actions.dart").read_text(
            encoding="utf-8"
        )
        self.assertNotIn("FilePicker.platform", source)
        self.assertIn("FilePicker.pickFiles(", source)
        self.assertIn("FilePicker.saveFile(", source)
        self.assertIn("FilePicker.getDirectoryPath(", source)


if __name__ == "__main__":
    unittest.main()
