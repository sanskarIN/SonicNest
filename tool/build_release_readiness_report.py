#!/usr/bin/env python3
"""Build a deterministic machine-readable view of SonicNest's remaining work.

This helper parses Markdown checklist items from TODO.md. It does not perform,
validate, or close any physical-device, accessibility, signing, distribution,
or other external release gate. Its purpose is to prevent repository tooling
from accidentally treating unchecked manual/external work as completed.

The canonical stable-tag checklist item is derived from the semantic version in
pubspec.yaml so a release-version change cannot leave this tooling pinned to an
older tag name.
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
DEFAULT_PUBSPEC = Path("pubspec.yaml")
CHECKLIST_RE = re.compile(r"^- \[(?P<state>[ xX])\] (?P<label>.+?)\s*$")
CHECKLIST_PREFIX_RE = re.compile(r"^- \[")
HEADING_RE = re.compile(r"^## (?P<section>.+?)\s*$")
PUBSPEC_VERSION_RE = re.compile(
    r"^version:\s*(?P<version>[^\s#]+)\s*(?:#.*)?$",
    re.MULTILINE,
)
RELEASE_VERSION_RE = re.compile(
    r"(?P<semantic>(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*))"
    r"\+(?P<build>[1-9]\d*)"
)


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


def parse_release_version(pubspec_text: str) -> str:
    """Return MAJOR.MINOR.PATCH from the single valid pubspec version line."""

    matches = list(PUBSPEC_VERSION_RE.finditer(pubspec_text))
    if len(matches) != 1:
        raise ValueError(
            "pubspec must contain exactly one top-level version declaration"
        )
    value = matches[0].group("version")
    release = RELEASE_VERSION_RE.fullmatch(value)
    if release is None:
        raise ValueError(
            "pubspec version must use MAJOR.MINOR.PATCH+BUILD with a positive "
            "numeric build number"
        )
    return release.group("semantic")


def stable_tag_marker(release_version: str) -> str:
    """Return the canonical TODO checklist text for the current stable tag."""

    if re.fullmatch(
        r"(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)",
        release_version,
    ) is None:
        raise ValueError("release version must use MAJOR.MINOR.PATCH")
    return (
        f"Tag `v{release_version}` only after all required stable-release gates "
        "are complete."
    )


def parse_checklist(lines: Iterable[str]) -> list[ChecklistItem]:
    """Parse level-two sections and checklist items while preserving order.

    Ambiguous repeated section headings or repeated checklist identities fail
    closed instead of being silently merged into release evidence.
    """

    current_section: str | None = None
    items: list[ChecklistItem] = []
    seen_sections: set[str] = set()
    seen_items: set[tuple[str, str]] = set()

    for line_number, raw_line in enumerate(lines, start=1):
        line = raw_line.rstrip("\n")
        heading = HEADING_RE.match(line)
        if heading:
            section = heading.group("section")
            if section in seen_sections:
                raise ValueError(
                    f"Duplicate level-two section {section!r} at line {line_number}"
                )
            seen_sections.add(section)
            current_section = section
            continue

        checklist = CHECKLIST_RE.match(line)
        if checklist:
            if current_section is None:
                raise ValueError(
                    f"Checklist item appears before a level-two section at line {line_number}"
                )
            label = checklist.group("label")
            identity = (current_section, label)
            if identity in seen_items:
                raise ValueError(
                    "Duplicate checklist item in section "
                    f"{current_section!r} at line {line_number}: {label!r}"
                )
            seen_items.add(identity)
            items.append(
                ChecklistItem(
                    section=current_section,
                    label=label,
                    complete=checklist.group("state").casefold() == "x",
                )
            )
            continue

        if CHECKLIST_PREFIX_RE.match(line):
            raise ValueError(f"Malformed checklist item at line {line_number}: {line}")

    return items


def build_report(
    items: list[ChecklistItem],
    source: str,
    release_version: str,
) -> dict[str, object]:
    """Build a stable JSON-serializable report from parsed checklist items."""

    pending = [item for item in items if not item.complete]
    completed = [item for item in items if item.complete]
    expected_tag_marker = stable_tag_marker(release_version)
    stable_tag_items = [item for item in items if item.label == expected_tag_marker]

    if len(stable_tag_items) != 1:
        raise ValueError(
            "TODO must contain exactly one canonical "
            f"v{release_version} stable-release tag gate"
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
    parser.add_argument("--pubspec", type=Path, default=DEFAULT_PUBSPEC)
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
    pubspec_text = args.pubspec.read_text(encoding="utf-8")
    release_version = parse_release_version(pubspec_text)
    items = parse_checklist(text.splitlines())
    if not items:
        raise SystemExit(f"No checklist items found in {source}")

    report = build_report(items, source.as_posix(), release_version)
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
