from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = ROOT / "tool" / "build_release_readiness_report.py"
SPEC = importlib.util.spec_from_file_location("build_release_readiness_report", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)

ChecklistItem = MODULE.ChecklistItem
RELEASE_VERSION = "2.18.12"
STABLE_TAG_MARKER = MODULE.stable_tag_marker(RELEASE_VERSION)
build_report = MODULE.build_report
parse_checklist = MODULE.parse_checklist
parse_release_version = MODULE.parse_release_version
render_markdown = MODULE.render_markdown


class ReleaseReadinessReportTest(unittest.TestCase):
    def test_parse_release_version_uses_pubspec_semantic_version(self) -> None:
        self.assertEqual(
            "2.18.12",
            parse_release_version("name: sonic_nest\nversion: 2.18.12+21812\n"),
        )

    def test_parse_release_version_rejects_missing_build_number(self) -> None:
        with self.assertRaisesRegex(ValueError, "MAJOR.MINOR.PATCH\\+BUILD"):
            parse_release_version("name: sonic_nest\nversion: 2.18.12\n")

    def test_parse_release_version_rejects_duplicate_version_lines(self) -> None:
        with self.assertRaisesRegex(ValueError, "exactly one"):
            parse_release_version(
                "version: 2.18.12+21812\nversion: 9.9.9+999\n"
            )

    def test_stable_tag_marker_uses_requested_release_version(self) -> None:
        self.assertEqual(
            "Tag `v2.18.12` only after all required stable-release gates are complete.",
            STABLE_TAG_MARKER,
        )

    def test_parse_checklist_preserves_sections_and_states(self) -> None:
        items = parse_checklist(
            [
                "# Remaining work",
                "## Hardware",
                "- [ ] Test microphone routing.",
                "- [x] Add deterministic baseline.",
                "## Signing and distribution",
                f"- [ ] {STABLE_TAG_MARKER}",
            ]
        )

        self.assertEqual(3, len(items))
        self.assertEqual("Hardware", items[0].section)
        self.assertFalse(items[0].complete)
        self.assertTrue(items[1].complete)
        self.assertEqual("Signing and distribution", items[2].section)

    def test_checklist_before_section_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "before a level-two section"):
            parse_checklist(["- [ ] Orphaned task"])

    def test_malformed_checklist_state_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "Malformed checklist item"):
            parse_checklist(["## Hardware", "- [?] Ambiguous state"])

    def test_malformed_checklist_spacing_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "Malformed checklist item"):
            parse_checklist(["## Hardware", "- [ ]Missing separator"])

    def test_duplicate_level_two_section_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "Duplicate level-two section"):
            parse_checklist(
                [
                    "## Hardware",
                    "- [ ] First hardware check",
                    "## Hardware",
                    "- [ ] Second hardware check",
                ]
            )

    def test_duplicate_checklist_identity_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "Duplicate checklist item"):
            parse_checklist(
                [
                    "## Hardware",
                    "- [ ] Test microphone routing.",
                    "- [x] Test microphone routing.",
                ]
            )

    def test_same_checklist_text_in_different_sections_is_allowed(self) -> None:
        items = parse_checklist(
            [
                "## Android",
                "- [ ] Visual review",
                "## iOS",
                "- [ ] Visual review",
                "## Signing and distribution",
                f"- [ ] {STABLE_TAG_MARKER}",
            ]
        )
        self.assertEqual(3, len(items))

    def test_unchecked_tag_gate_keeps_release_unapproved(self) -> None:
        report = build_report(
            [
                ChecklistItem("Hardware", "Physical test", False),
                ChecklistItem("Signing and distribution", STABLE_TAG_MARKER, False),
            ],
            "TODO.md",
            RELEASE_VERSION,
        )

        self.assertFalse(report["stableReleaseApproved"])
        self.assertEqual(2, report["summary"]["pending"])
        self.assertEqual(0, report["summary"]["completed"])

    def test_completed_tag_gate_is_not_enough_when_other_work_is_pending(self) -> None:
        report = build_report(
            [
                ChecklistItem("Hardware", "Physical test", False),
                ChecklistItem("Signing and distribution", STABLE_TAG_MARKER, True),
            ],
            "TODO.md",
            RELEASE_VERSION,
        )

        self.assertFalse(report["stableReleaseApproved"])

    def test_release_can_only_be_approved_when_every_item_is_complete(self) -> None:
        report = build_report(
            [
                ChecklistItem("Hardware", "Physical test", True),
                ChecklistItem("Signing and distribution", STABLE_TAG_MARKER, True),
            ],
            "TODO.md",
            RELEASE_VERSION,
        )

        self.assertTrue(report["stableReleaseApproved"])
        self.assertEqual([], report["pendingItems"])

    def test_missing_tag_gate_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "exactly one canonical"):
            build_report(
                [ChecklistItem("Hardware", "Physical test", False)],
                "TODO.md",
                RELEASE_VERSION,
            )

    def test_outdated_tag_gate_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "v2.18.12"):
            build_report(
                [
                    ChecklistItem(
                        "Signing",
                        MODULE.stable_tag_marker("2.18.11"),
                        False,
                    )
                ],
                "TODO.md",
                RELEASE_VERSION,
            )

    def test_duplicate_tag_gate_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "exactly one canonical"):
            build_report(
                [
                    ChecklistItem("Signing", STABLE_TAG_MARKER, False),
                    ChecklistItem("Signing", STABLE_TAG_MARKER, False),
                ],
                "TODO.md",
                RELEASE_VERSION,
            )

    def test_markdown_summary_only_lists_sections_with_pending_items(self) -> None:
        report = build_report(
            [
                ChecklistItem("Completed section", "Done", True),
                ChecklistItem("Hardware", "Physical test", False),
                ChecklistItem("Signing and distribution", STABLE_TAG_MARKER, False),
            ],
            "TODO.md",
            RELEASE_VERSION,
        )

        markdown = render_markdown(report)

        self.assertIn("Stable release approved: **no**", markdown)
        self.assertIn("**Hardware**: 1", markdown)
        self.assertIn("**Signing and distribution**: 1", markdown)
        self.assertNotIn("**Completed section**:", markdown)


if __name__ == "__main__":
    unittest.main()
