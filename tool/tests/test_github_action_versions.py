from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ROOT / ".github" / "workflows"


class GitHubActionVersionRegressionTest(unittest.TestCase):
    def _workflow_texts(self) -> dict[str, str]:
        return {
            path.name: path.read_text(encoding="utf-8")
            for path in sorted(WORKFLOWS.glob("*.y*ml"))
        }

    def test_all_checkout_uses_are_v7(self) -> None:
        texts = self._workflow_texts()
        checkout_lines = [
            line.strip()
            for text in texts.values()
            for line in text.splitlines()
            if "actions/checkout@" in line
        ]
        self.assertTrue(checkout_lines)
        self.assertTrue(
            all("actions/checkout@v7" in line for line in checkout_lines),
            checkout_lines,
        )

    def test_all_upload_artifact_uses_are_v7(self) -> None:
        texts = self._workflow_texts()
        upload_lines = [
            line.strip()
            for text in texts.values()
            for line in text.splitlines()
            if "actions/upload-artifact@" in line
        ]
        self.assertTrue(upload_lines)
        self.assertTrue(
            all("actions/upload-artifact@v7" in line for line in upload_lines),
            upload_lines,
        )

    def test_release_candidate_download_uses_v8(self) -> None:
        text = (WORKFLOWS / "release-candidate.yml").read_text(encoding="utf-8")
        download_lines = [
            line.strip()
            for line in text.splitlines()
            if "actions/download-artifact@" in line
        ]
        self.assertEqual(download_lines, ["uses: actions/download-artifact@v8"])


if __name__ == "__main__":
    unittest.main()
