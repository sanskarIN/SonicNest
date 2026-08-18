from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class FinalRepositoryContractTest(unittest.TestCase):
    def _text(self, relative: str) -> str:
        path = ROOT / relative
        self.assertTrue(path.is_file(), f"missing final-contract file: {relative}")
        return path.read_text(encoding="utf-8")

    def test_storage_service_exposes_only_managed_delete_boundaries(self) -> None:
        text = self._text("lib/services/storage_service.dart")
        self.assertNotIn("Future<void> deleteIfExists(", text)
        self.assertIn("deleteManagedAudioIfExists", text)
        self.assertIn("deleteManagedTemporaryIfExists", text)
        self.assertIn("deleteManagedCaptureIfExists", text)

    def test_recording_settings_reject_fractional_integer_persistence(self) -> None:
        text = self._text("lib/models/recording_settings.dart")
        self.assertIn("isFiniteWholeNumber", text)
        self.assertIn("value == value.truncate()", text)

    def test_future_settings_schema_is_refused_explicitly(self) -> None:
        text = self._text("lib/services/settings_service.dart")
        self.assertIn("UnsupportedSettingsSchemaException", text)
        self.assertIn("on UnsupportedSettingsSchemaException", text)
        self.assertIn("rethrow;", text)

    def test_current_dependency_and_action_contracts_are_locked(self) -> None:
        self._text("tool/tests/test_dependency_surface.py")
        self._text("tool/tests/test_github_action_versions.py")
        self._text("tool/tests/test_open_source_maintenance.py")

    def test_open_source_maintenance_surfaces_are_tracked(self) -> None:
        for relative in (
            ".github/CODEOWNERS",
            ".github/FUNDING.yml",
            ".github/ISSUE_TEMPLATE/config.yml",
            ".github/dependabot.yml",
            "docs/OPEN_SOURCE_MAINTENANCE.md",
        ):
            self._text(relative)

    def test_final_audit_preserves_development_preview_boundary(self) -> None:
        text = self._text("docs/FINAL_REPOSITORY_AUDIT_2026-08-18.md")
        self.assertIn("development preview", text)
        self.assertIn("Remaining manual and credential-dependent gates", text)
        self.assertIn("No additional repository-only feature", text)


if __name__ == "__main__":
    unittest.main()
