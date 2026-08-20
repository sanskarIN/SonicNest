from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))

import repository_audit  # noqa: E402


CRITICAL_REQUIRED_FILES = {
    "docs/CONTINUATION_2026-08-19_RELEASE_READINESS.md",
    "docs/DIAGNOSTICS_AND_QA.md",
    "docs/LINKS_AND_PROMOTION.md",
    "docs/MANUAL_QA_EVIDENCE.md",
    "docs/MANUAL_QA_REVIEW_TOOLING.md",
    "docs/OPEN_SOURCE_MAINTENANCE.md",
    "docs/RELEASE_CANDIDATE_MANIFEST.md",
    "docs/RELEASE_READINESS_REPORT.md",
    "docs/WEB_QA_CHECKLIST.md",
    "docs/WEB_SUPPORT.md",
    "lib/bootstrap/bootstrap.dart",
    "lib/bootstrap/bootstrap_native.dart",
    "lib/bootstrap/bootstrap_web.dart",
    "lib/main_web.dart",
    "lib/core/wav_encoder.dart",
    "test/bootstrap_integrity_test.dart",
    "test/wav_encoder_test.dart",
    "tool/build_release_candidate_manifest.py",
    "tool/build_release_readiness_report.py",
    "tool/patch_generated_platforms.py",
    "tool/verify_manual_qa_evidence.py",
    "tool/verify_release_readiness_report.py",
    "tool/tests/test_build_release_readiness_report.py",
    "tool/tests/test_dependency_surface.py",
    "tool/tests/test_final_repository_contract.py",
    "tool/tests/test_github_action_versions.py",
    "tool/tests/test_gumroad_integration.py",
    "tool/tests/test_manual_qa_evidence_cli.py",
    "tool/tests/test_manual_qa_evidence_verifier.py",
    "tool/tests/test_open_source_maintenance.py",
    "tool/tests/test_release_candidate_integration.py",
    "tool/tests/test_release_candidate_manifest.py",
    "tool/tests/test_release_readiness_cli.py",
    "tool/tests/test_repository_audit.py",
    "tool/tests/test_repository_required_surfaces.py",
    "tool/tests/test_verify_release_readiness_report.py",
    "tool/tests/test_web_platform_contract.py",
}


class RepositoryRequiredSurfaceRegressionTest(unittest.TestCase):
    def test_critical_release_and_maintenance_surfaces_are_required(self) -> None:
        required = set(repository_audit.REQUIRED_FILES)
        self.assertEqual(CRITICAL_REQUIRED_FILES - required, set())

    def test_required_file_entries_are_unique(self) -> None:
        required = repository_audit.REQUIRED_FILES
        self.assertEqual(len(required), len(set(required)))

    def test_every_required_file_exists(self) -> None:
        for relative in repository_audit.REQUIRED_FILES:
            self.assertTrue((ROOT / relative).is_file(), relative)


if __name__ == "__main__":
    unittest.main()
