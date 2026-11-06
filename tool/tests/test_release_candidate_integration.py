from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class ReleaseCandidateIntegrationTest(unittest.TestCase):
    def test_manifest_builder_and_documentation_are_tracked(self) -> None:
        self.assertTrue((ROOT / "tool/build_release_candidate_manifest.py").is_file())
        self.assertTrue((ROOT / "docs/RELEASE_CANDIDATE_MANIFEST.md").is_file())
        self.assertTrue((ROOT / "docs/RELEASE_2.18.12.md").is_file())

    def test_release_candidate_workflow_publishes_unified_manifest(self) -> None:
        workflow = (ROOT / ".github/workflows/release-candidate.yml").read_text(
            encoding="utf-8"
        )
        required_markers = (
            "Unified candidate provenance manifest",
            "actions/download-artifact@v8",
            "pattern: sonicnest-*-release-candidate",
            "tool/build_release_candidate_manifest.py",
            "RELEASE_CANDIDATE_MANIFEST.json",
            "sonicnest-release-candidate-manifest",
            "--artifact android=",
            "--artifact linux=",
            "--artifact windows=",
            "--artifact macos=",
            "--artifact ios=",
            "--artifact web=",
            "sonicnest-web-release-candidate",
            "sonicnest-web-release.tar.gz",
            "flutter build web --release",
            "--source-sha \"${GITHUB_SHA}\"",
            "--workflow-run-id \"${GITHUB_RUN_ID}\"",
        )
        for marker in required_markers:
            with self.subTest(marker=marker):
                self.assertIn(marker, workflow)

    def test_repository_audit_runs_release_metadata_checks(self) -> None:
        workflow = (ROOT / ".github/workflows/repository-audit.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn("push:\n    branches: [main]", workflow)
        self.assertIn("pull_request:\n    branches: [main]", workflow)
        self.assertNotIn("paths:", workflow)
        self.assertIn("python3 tool/repository_audit.py", workflow)
        self.assertIn("python3 tool/verify_project_state_dependencies.py", workflow)
        self.assertIn("python3 tool/verify_release_version.py", workflow)
        self.assertIn("python3 tool/source_line_audit.py", workflow)
        self.assertIn("python3 -m unittest discover", workflow)
        self.assertIn("python3 -m py_compile", workflow)

    def test_release_preflights_verify_dependency_and_version_metadata(self) -> None:
        bash = (ROOT / "tool/release_preflight.sh").read_text(encoding="utf-8")
        powershell = (ROOT / "tool/release_preflight.ps1").read_text(
            encoding="utf-8"
        )
        for marker in (
            "tool/verify_project_state_dependencies.py",
            "tool/verify_release_version.py",
        ):
            with self.subTest(marker=marker, shell="bash"):
                self.assertIn(marker, bash)
            with self.subTest(marker=marker, shell="powershell"):
                self.assertIn(marker, powershell)


if __name__ == "__main__":
    unittest.main()
