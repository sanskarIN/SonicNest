from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class OpenSourceMaintenanceRegressionTest(unittest.TestCase):
    def _text(self, relative: str) -> str:
        path = ROOT / relative
        self.assertTrue(path.is_file(), f"missing maintained file: {relative}")
        return path.read_text(encoding="utf-8")

    def test_codeowners_routes_default_review(self) -> None:
        text = self._text(".github/CODEOWNERS")
        self.assertIn("* @sanskarIN", text)

    def test_funding_keeps_canonical_optional_support_links(self) -> None:
        text = self._text(".github/FUNDING.yml")
        self.assertIn("https://ramsandesh.gumroad.com", text)
        self.assertIn("https://buymeacoffee.com/sanskarIN", text)

    def test_issue_routing_disables_blank_reports_and_links_guidance(self) -> None:
        text = self._text(".github/ISSUE_TEMPLATE/config.yml")
        self.assertIn("blank_issues_enabled: false", text)
        self.assertIn("SECURITY.md", text)
        self.assertIn("SUPPORT.md", text)

    def test_dependabot_monitors_pub_and_github_actions_weekly(self) -> None:
        text = self._text(".github/dependabot.yml")
        self.assertIn("version: 2", text)
        self.assertIn('package-ecosystem: "pub"', text)
        self.assertIn('package-ecosystem: "github-actions"', text)
        self.assertGreaterEqual(text.count('interval: "weekly"'), 2)

    def test_maintenance_guide_preserves_release_boundary(self) -> None:
        text = self._text("docs/OPEN_SOURCE_MAINTENANCE.md")
        self.assertIn("development preview", text)
        self.assertIn("Dependabot", text)
        self.assertIn("CODEOWNERS", text)
        self.assertIn("Repository Integrity Audit", text)


if __name__ == "__main__":
    unittest.main()
