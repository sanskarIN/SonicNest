from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = ROOT / "tool" / "verify_release_readiness_report.py"
SPEC = importlib.util.spec_from_file_location("verify_release_readiness_report", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)

validate_report = MODULE.validate_report


def valid_report() -> dict[str, object]:
    return {
        "schemaVersion": 1,
        "source": "TODO.md",
        "stableReleaseApproved": False,
        "summary": {"total": 3, "pending": 2, "completed": 1},
        "sections": [
            {"name": "Hardware", "pending": 1, "completed": 1},
            {"name": "Signing", "pending": 1, "completed": 0},
        ],
        "pendingItems": [
            {"section": "Hardware", "label": "Physical test", "complete": False},
            {"section": "Signing", "label": "Signing test", "complete": False},
        ],
    }


class VerifyReleaseReadinessReportTest(unittest.TestCase):
    def test_accepts_consistent_report(self) -> None:
        self.assertEqual([], validate_report(valid_report()))

    def test_rejects_unknown_schema(self) -> None:
        report = valid_report()
        report["schemaVersion"] = 2
        self.assertTrue(any("Unsupported schemaVersion" in error for error in validate_report(report)))

    def test_rejects_inconsistent_summary(self) -> None:
        report = valid_report()
        report["summary"] = {"total": 99, "pending": 2, "completed": 1}
        self.assertIn("summary.total must equal pending + completed", validate_report(report))

    def test_rejects_zero_item_report_even_when_approval_is_false(self) -> None:
        report = {
            "schemaVersion": 1,
            "source": "TODO.md",
            "stableReleaseApproved": False,
            "summary": {"total": 0, "pending": 0, "completed": 0},
            "sections": [],
            "pendingItems": [],
        }
        self.assertIn("summary.total must be greater than zero", validate_report(report))

    def test_rejects_zero_item_report_claiming_stable_approval(self) -> None:
        report = {
            "schemaVersion": 1,
            "source": "TODO.md",
            "stableReleaseApproved": True,
            "summary": {"total": 0, "pending": 0, "completed": 0},
            "sections": [],
            "pendingItems": [],
        }
        self.assertIn("summary.total must be greater than zero", validate_report(report))

    def test_rejects_approval_with_pending_work(self) -> None:
        report = valid_report()
        report["stableReleaseApproved"] = True
        self.assertIn(
            "stableReleaseApproved cannot be true while work is pending",
            validate_report(report),
        )

    def test_rejects_section_count_drift(self) -> None:
        report = valid_report()
        report["sections"] = [
            {"name": "Hardware", "pending": 0, "completed": 1},
            {"name": "Signing", "pending": 1, "completed": 0},
        ]
        self.assertIn("Section pending counts must equal summary.pending", validate_report(report))

    def test_rejects_duplicate_sections(self) -> None:
        report = valid_report()
        report["sections"] = [
            {"name": "Hardware", "pending": 1, "completed": 1},
            {"name": "Hardware", "pending": 1, "completed": 0},
        ]
        self.assertTrue(any("Duplicate section name" in error for error in validate_report(report)))

    def test_rejects_pending_item_marked_complete(self) -> None:
        report = valid_report()
        pending_items = report["pendingItems"]
        assert isinstance(pending_items, list)
        item = dict(pending_items[0])
        item["complete"] = True
        pending_items[0] = item
        self.assertTrue(any("complete must be false" in error for error in validate_report(report)))

    def test_rejects_pending_item_for_unknown_section(self) -> None:
        report = valid_report()
        pending_items = report["pendingItems"]
        assert isinstance(pending_items, list)
        item = dict(pending_items[0])
        item["section"] = "Unknown"
        pending_items[0] = item
        self.assertTrue(any("does not exist in sections" in error for error in validate_report(report)))

    def test_rejects_duplicate_pending_item_identity(self) -> None:
        report = valid_report()
        report["summary"] = {"total": 4, "pending": 3, "completed": 1}
        report["sections"] = [
            {"name": "Hardware", "pending": 2, "completed": 1},
            {"name": "Signing", "pending": 1, "completed": 0},
        ]
        pending_items = report["pendingItems"]
        assert isinstance(pending_items, list)
        pending_items.append(dict(pending_items[0]))
        self.assertTrue(
            any("Duplicate pending item identity" in error for error in validate_report(report))
        )


if __name__ == "__main__":
    unittest.main()
