from __future__ import annotations

import json
import sys
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_DIR))

import verify_manual_qa_evidence as verifier


class ManualQaEvidenceVerifierTest(unittest.TestCase):
    def setUp(self) -> None:
        self.catalog_ids = ("android_microphone_permission", "talkback_audit")
        self.now = datetime(2026, 8, 17, 9, 30, tzinfo=timezone.utc)

    def bundle(self, *, all_passed: bool = False) -> dict[str, object]:
        statuses = {
            "android_microphone_permission": "passed",
            "talkback_audit": "passed" if all_passed else "notRun",
        }
        checks: list[dict[str, object]] = []
        for check_id in self.catalog_ids:
            status = statuses[check_id]
            checks.append(
                {
                    "id": check_id,
                    "category": "test",
                    "status": status,
                    "updatedAtUtc": (
                        "2026-08-17T09:00:00.000Z" if status != "notRun" else None
                    ),
                    "requiresPhysicalTarget": True,
                    "requiresExternalTooling": check_id == "talkback_audit",
                }
            )
        passed = sum(check["status"] == "passed" for check in checks)
        failed = sum(check["status"] == "failed" for check in checks)
        blocked = sum(check["status"] == "blocked" for check in checks)
        not_run = sum(check["status"] == "notRun" for check in checks)
        return {
            "schemaVersion": 1,
            "generatedAtUtc": "2026-08-17T09:10:00.000Z",
            "privacy": {key: False for key in verifier.REQUIRED_PRIVACY_FALSE},
            "app": {"name": "SonicNest", "version": "0.1.0+1"},
            "summary": {
                "totalChecks": len(checks),
                "assessedChecks": passed + failed + blocked,
                "passed": passed,
                "failed": failed,
                "blocked": blocked,
                "notRun": not_run,
                "allPassed": passed == len(checks),
            },
            "session": {
                "schemaVersion": 1,
                "startedAtUtc": "2026-08-17T08:00:00.000Z",
                "updatedAtUtc": "2026-08-17T09:00:00.000Z",
            },
            "checks": checks,
            "diagnostics": {"runtime": {"platform": "android"}},
        }

    def validate(self, bundle: dict[str, object], **kwargs):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "evidence.json"
            path.write_text(json.dumps(bundle), encoding="utf-8")
            return verifier.validate_bundle(
                path,
                catalog_ids=self.catalog_ids,
                now_utc=self.now,
                **kwargs,
            )

    def test_accepts_consistent_bundle(self) -> None:
        result = self.validate(self.bundle(), require_diagnostics=True)
        self.assertTrue(result.valid, result.errors)
        self.assertEqual(result.platform, "android")
        self.assertEqual(result.summary["passed"], 1)
        self.assertEqual(result.summary["notRun"], 1)

    def test_rejects_summary_drift(self) -> None:
        bundle = self.bundle()
        summary = bundle["summary"]
        assert isinstance(summary, dict)
        summary["passed"] = 2
        result = self.validate(bundle)
        self.assertFalse(result.valid)
        self.assertTrue(any("summary.passed" in error for error in result.errors))

    def test_rejects_unknown_and_missing_checks(self) -> None:
        bundle = self.bundle()
        checks = bundle["checks"]
        assert isinstance(checks, list)
        checks.pop()
        checks.append(
            {
                "id": "unknown_check",
                "category": "test",
                "status": "notRun",
                "updatedAtUtc": None,
                "requiresPhysicalTarget": False,
                "requiresExternalTooling": False,
            }
        )
        result = self.validate(bundle)
        self.assertFalse(result.valid)
        self.assertTrue(any("missing catalog checks" in error for error in result.errors))
        self.assertTrue(any("unknown checks" in error for error in result.errors))

    def test_require_all_passed_is_strict(self) -> None:
        result = self.validate(self.bundle(), require_all_passed=True)
        self.assertFalse(result.valid)
        self.assertTrue(any("--require-all-passed" in error for error in result.errors))

        result = self.validate(self.bundle(all_passed=True), require_all_passed=True)
        self.assertTrue(result.valid, result.errors)

    def test_rejects_stale_evidence(self) -> None:
        result = self.validate(self.bundle(), max_age_hours=0.1)
        self.assertFalse(result.valid)
        self.assertTrue(any("too old" in error for error in result.errors))

    def test_rejects_privacy_contract_regression(self) -> None:
        bundle = self.bundle()
        privacy = bundle["privacy"]
        assert isinstance(privacy, dict)
        privacy["containsFilePaths"] = True
        result = self.validate(bundle)
        self.assertFalse(result.valid)
        self.assertTrue(any("containsFilePaths" in error for error in result.errors))

    def test_load_catalog_ids_reads_check_definitions(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "qa_check_catalog.dart"
            path.write_text(
                """
                abstract final class QaCheckCatalog {
                  static const checks = <QaCheckDefinition>[
                    QaCheckDefinition(id: 'first', categoryId: 'x', evidenceLabel: 'x'),
                    QaCheckDefinition(id: 'second', categoryId: 'x', evidenceLabel: 'x'),
                  ];
                  static final Set<String> checkIds = Set<String>.unmodifiable([]);
                }
                """,
                encoding="utf-8",
            )
            self.assertEqual(
                verifier.load_catalog_check_ids(path),
                ("first", "second"),
            )


if __name__ == "__main__":
    unittest.main()
