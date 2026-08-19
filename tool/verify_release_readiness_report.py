#!/usr/bin/env python3
"""Verify a SonicNest release-readiness JSON report without external dependencies."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

SUPPORTED_SCHEMA_VERSION = 1


def _is_non_negative_int(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool) and value >= 0


def validate_report(report: Any) -> list[str]:
    errors: list[str] = []
    if not isinstance(report, dict):
        return ["Report root must be a JSON object"]

    if report.get("schemaVersion") != SUPPORTED_SCHEMA_VERSION:
        errors.append(
            f"Unsupported schemaVersion: {report.get('schemaVersion')!r}; "
            f"expected {SUPPORTED_SCHEMA_VERSION}"
        )

    source = report.get("source")
    if not isinstance(source, str) or not source.strip():
        errors.append("source must be a non-empty string")

    approved = report.get("stableReleaseApproved")
    if not isinstance(approved, bool):
        errors.append("stableReleaseApproved must be a boolean")

    summary = report.get("summary")
    if not isinstance(summary, dict):
        errors.append("summary must be an object")
        total = pending = completed = None
    else:
        total = summary.get("total")
        pending = summary.get("pending")
        completed = summary.get("completed")
        for key, value in (
            ("summary.total", total),
            ("summary.pending", pending),
            ("summary.completed", completed),
        ):
            if not _is_non_negative_int(value):
                errors.append(f"{key} must be a non-negative integer")
        if all(_is_non_negative_int(value) for value in (total, pending, completed)):
            if total == 0:
                errors.append("summary.total must be greater than zero")
            if total != pending + completed:
                errors.append("summary.total must equal pending + completed")
            if approved is True and pending != 0:
                errors.append("stableReleaseApproved cannot be true while work is pending")

    sections = report.get("sections")
    section_pending = 0
    section_completed = 0
    seen_sections: set[str] = set()
    if not isinstance(sections, list):
        errors.append("sections must be an array")
    else:
        for index, section in enumerate(sections):
            prefix = f"sections[{index}]"
            if not isinstance(section, dict):
                errors.append(f"{prefix} must be an object")
                continue
            name = section.get("name")
            if not isinstance(name, str) or not name.strip():
                errors.append(f"{prefix}.name must be a non-empty string")
            elif name in seen_sections:
                errors.append(f"Duplicate section name: {name}")
            else:
                seen_sections.add(name)

            pending_count = section.get("pending")
            completed_count = section.get("completed")
            if not _is_non_negative_int(pending_count):
                errors.append(f"{prefix}.pending must be a non-negative integer")
            else:
                section_pending += pending_count
            if not _is_non_negative_int(completed_count):
                errors.append(f"{prefix}.completed must be a non-negative integer")
            else:
                section_completed += completed_count

    if _is_non_negative_int(pending) and section_pending != pending:
        errors.append("Section pending counts must equal summary.pending")
    if _is_non_negative_int(completed) and section_completed != completed:
        errors.append("Section completed counts must equal summary.completed")

    pending_items = report.get("pendingItems")
    seen_pending_items: set[tuple[str, str]] = set()
    if not isinstance(pending_items, list):
        errors.append("pendingItems must be an array")
    else:
        if _is_non_negative_int(pending) and len(pending_items) != pending:
            errors.append("pendingItems length must equal summary.pending")
        for index, item in enumerate(pending_items):
            prefix = f"pendingItems[{index}]"
            if not isinstance(item, dict):
                errors.append(f"{prefix} must be an object")
                continue
            section = item.get("section")
            label = item.get("label")
            complete = item.get("complete")
            valid_section = isinstance(section, str) and bool(section.strip())
            valid_label = isinstance(label, str) and bool(label.strip())
            if not valid_section:
                errors.append(f"{prefix}.section must be a non-empty string")
            elif seen_sections and section not in seen_sections:
                errors.append(f"{prefix}.section does not exist in sections: {section}")
            if not valid_label:
                errors.append(f"{prefix}.label must be a non-empty string")
            if valid_section and valid_label:
                identity = (section, label)
                if identity in seen_pending_items:
                    errors.append(
                        f"Duplicate pending item identity: section={section!r}, label={label!r}"
                    )
                else:
                    seen_pending_items.add(identity)
            if complete is not False:
                errors.append(f"{prefix}.complete must be false")

    return errors


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        report = json.loads(args.report.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"Could not read release readiness report: {exc}") from exc

    errors = validate_report(report)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    print(f"Release readiness report verified: {args.report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
