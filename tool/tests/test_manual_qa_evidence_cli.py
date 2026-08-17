from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parents[1]
VERIFIER = TOOL_DIR / "verify_manual_qa_evidence.py"
CATALOG = TOOL_DIR.parent / "lib/models/qa_check_catalog.dart"


def catalog_ids() -> list[str]:
    text = CATALOG.read_text(encoding="utf-8")
    marker = "static const checks = <QaCheckDefinition>["
    start = text.index(marker)
    end = text.index("static final Set<String> checkIds", start)
    block = text[start:end]
    ids: list[str] = []
    for piece in block.split("QaCheckDefinition(")[1:]:
        prefix = piece.split("categoryId:", 1)[0]
        token = prefix.split("id:", 1)[1].strip().split(",", 1)[0].strip()
        ids.append(token.strip("'\""))
    return ids


def valid_bundle() -> dict[str, object]:
    ids = catalog_ids()
    checks = [
        {
            "id": check_id,
            "category": "test",
            "status": "passed",
            "updatedAtUtc": "2026-08-17T09:00:00.000Z",
            "requiresPhysicalTarget": True,
            "requiresExternalTooling": False,
        }
        for check_id in ids
    ]
    return {
        "schemaVersion": 1,
        "generatedAtUtc": "2026-08-17T09:10:00.000Z",
        "privacy": {
            "containsRecordingContent": False,
            "containsRecordingTitles": False,
            "containsFilePaths": False,
            "containsNotesTagsOrBookmarks": False,
            "containsInputDeviceNames": False,
            "containsFreeFormTesterNotes": False,
        },
        "app": {"name": "SonicNest", "version": "0.1.0+1"},
        "summary": {
            "totalChecks": len(checks),
            "assessedChecks": len(checks),
            "passed": len(checks),
            "failed": 0,
            "blocked": 0,
            "notRun": 0,
            "allPassed": True,
        },
        "session": {
            "schemaVersion": 1,
            "startedAtUtc": "2026-08-17T08:00:00.000Z",
            "updatedAtUtc": "2026-08-17T09:00:00.000Z",
        },
        "checks": checks,
        "diagnostics": {"runtime": {"platform": "android"}},
    }


class ManualQaEvidenceCliTest(unittest.TestCase):
    def run_cli(self, bundle: dict[str, object], *arguments: str):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory) / "evidence.json"
            evidence.write_text(json.dumps(bundle), encoding="utf-8")
            return subprocess.run(
                [sys.executable, str(VERIFIER), *arguments, str(evidence)],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )

    def test_cli_accepts_strict_valid_bundle(self) -> None:
        result = self.run_cli(
            valid_bundle(),
            "--expected-version",
            "0.1.0+1",
            "--require-diagnostics",
            "--require-all-passed",
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("VALID:", result.stdout)
        self.assertIn("platform=android", result.stdout)

    def test_cli_rejects_version_mismatch(self) -> None:
        result = self.run_cli(
            valid_bundle(),
            "--expected-version",
            "9.9.9+9",
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("does not match expected", result.stdout)

    def test_cli_rejects_nonpositive_age_policy(self) -> None:
        result = self.run_cli(valid_bundle(), "--max-age-hours", "0")
        self.assertEqual(result.returncode, 2)
        self.assertIn("greater than zero", result.stderr)


if __name__ == "__main__":
    unittest.main()
