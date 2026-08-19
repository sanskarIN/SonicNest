#!/usr/bin/env python3
"""Build a deterministic machine-readable view of SonicNest's remaining work.

This helper parses Markdown checklist items from TODO.md. It does not perform,
validate, or close any physical-device, accessibility, signing, distribution,
or other external release gate. Its purpose is to prevent repository tooling
from accidentally treating unchecked manual/external work as completed.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

SCHEMA_VERSION = 1
DEFAULT_SOURCE = Path("TODO.md")
DEFAULT_OUTPUT = Path("build/release-readiness.json")
CHECKLIST_RE = re.compile(r"^- \[(?P<state>[ xX])\] (?P<label>.+?)\s*$")
HEADING_RE = re.compile(r"^## (?P<section>.+?)\s*$")
STABLE_TAG_MARKER = "Tag `v1.0.0` only after all required stable-release gates are complete."


@dataclass(frozen=True)
class ChecklistItem:
    section: str
    label: str
    complete: bool

    def to_json(self) -> dict[str, object]:
        return {
            "section": self.section,
            "label": self.label,
            "complete": self.complete,
        }


def parse_checklist(lines: Iterable[str]) -> list[ChecklistItem]:
    """Parse level-two sections and checklist items while preserving order."""

    current_section = "Uncategorized"
    items: list[ChecklistItem] = []

    for raw_line in lines:
        line = raw_line.rstrip("\n")
        heading = HEADING_RE.match(line)
        if heading:
            current_section = heading.group("section")
            continue

        checklist = CHECKLIST_RE.match(line)
        if not checklist:
            continue

        items.append(
            ChecklistItem(
                section=current_section,
                label=checklist.group("label"),
                complete=checklist.group("state").casefold() == "x",
            )
        )

    return items


def build_report(items: list[ChecklistItem], source: str) -> dict[str, object]:
    """Build a stable JSON-serializable report from parsed checklist items."""

    pending = [item for item in items if not item.complete]
    completed = [item for item in items if item.complete]
    stable_tag_items = [item for item in items if item.label == STABLE_TAG_MARKER]

    if len(stable_tag_items) != 1:
        raise ValueError(
            "TODO must contain exactly one canonical v1.0.0 stable-release tag gate"
        )

    stable_release_approved = stable_tag_items[0].complete and not pending

    section_counts: dict[str, dict[str, int]] = {}
    for item in items:
        counts = section_counts.setdefault(item.section, {"pending": 0, "completed": 0})
        counts["completed" if item.complete else "pending"] += 1

    return {
        "schemaVersion": SCHEMA_VERSION,
        "source": source,
        "stableReleaseApproved": stable_release_approved,
        "summary": {
            "total": len(items),
            "pending": len(pending),
            "completed": len(completed),
        },
        "sections": [
            {
                "name": section,
                "pending": counts["pending"],
                "completed": counts["completed"],
            }
            for section, counts in section_counts.items()
        ],
        "pendingItems": [item.to_json() for item in pending],
    }


def render_markdown(report: dict[str, object]) -> str:
    """Render a concise human-readable companion summary."""

    summary = report["summary"]
    assert isinstance(summary, dict)
    pending = int(summary["pending"])
    total = int(summary["total"])
    approved = bool(report["stableReleaseApproved"])

    lines = [
        "# SonicNest Release Readiness Snapshot",
        "",
        f"- Source: `{report['source']}`",
        f"- Checklist items: **{total}**",
        f"- Pending items: **{pending}**",
        f"- Stable release approved: **{'yes' if approved else 'no'}**",
        "",
        "This snapshot is repository bookkeeping only. It does not perform or verify "
        "physical-device, accessibility, signing, store-console, or other external tests.",
        "",
        "## Pending items by section",
        "",
    ]

    sections = report["sections"]
    assert isinstance(sections, list)
    for section in sections:
        assert isinstance(section, dict)
        count = int(section["pending"])
        if count:
            lines.append(f"- **{section['name']}**: {count}")

    lines.append("")
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--markdown-output", type=Path)
    parser.add_argument(
        "--assert-not-ready",
        action="store_true",
        help="fail if the parsed checklist claims the stable release is approved",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source = args.source
    text = source.read_text(encoding="utf-8")
    items = parse_checklist(text.splitlines())
    if not items:
        raise SystemExit(f"No checklist items found in {source}")

    report = build_report(items, source.as_posix())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    if args.markdown_output is not None:
        args.markdown_output.parent.mkdir(parents=True, exist_ok=True)
        args.markdown_output.write_text(render_markdown(report), encoding="utf-8")

    if args.assert_not_ready and report["stableReleaseApproved"]:
        raise SystemExit("Stable release unexpectedly reports as approved")

    print(
        "Release readiness report written: "
        f"{args.output} ({report['summary']['pending']} pending; "
        f"stableReleaseApproved={str(report['stableReleaseApproved']).lower()})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
