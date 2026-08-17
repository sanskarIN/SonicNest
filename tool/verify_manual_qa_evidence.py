#!/usr/bin/env python3
"""Validate SonicNest manual-QA evidence exports without trusting release claims.

This tool checks only deterministic structure and consistency. It does not perform
hardware QA, accessibility review, signing, or distribution approval.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "lib/models/qa_check_catalog.dart"
SUPPORTED_BUNDLE_SCHEMA = 1
SUPPORTED_STATUSES = {"notRun", "passed", "failed", "blocked"}
REQUIRED_PRIVACY_FALSE = {
    "containsRecordingContent",
    "containsRecordingTitles",
    "containsFilePaths",
    "containsNotesTagsOrBookmarks",
    "containsInputDeviceNames",
    "containsFreeFormTesterNotes",
}


@dataclass(frozen=True)
class ValidationResult:
    path: Path
    errors: tuple[str, ...]
    warnings: tuple[str, ...]
    summary: dict[str, int | bool]
    platform: str | None

    @property
    def valid(self) -> bool:
        return not self.errors


def _parse_iso_utc(value: Any, label: str, errors: list[str]) -> datetime | None:
    if not isinstance(value, str) or not value.strip():
        errors.append(f"{label} must be a non-empty ISO-8601 timestamp string")
        return None
    normalized = value.replace("Z", "+00:00")
    try:
        parsed = datetime.fromisoformat(normalized)
    except ValueError:
        errors.append(f"{label} is not a valid ISO-8601 timestamp: {value!r}")
        return None
    if parsed.tzinfo is None:
        errors.append(f"{label} must include a timezone offset")
        return None
    return parsed.astimezone(timezone.utc)


def load_catalog_check_ids(catalog_path: Path = CATALOG_PATH) -> tuple[str, ...]:
    text = catalog_path.read_text(encoding="utf-8")
    marker = "static const checks = <QaCheckDefinition>["
    start = text.find(marker)
    if start < 0:
        raise ValueError(f"Could not locate QaCheckCatalog.checks in {catalog_path}")
    end = text.find("static final Set<String> checkIds", start)
    if end < 0:
        raise ValueError(f"Could not locate QaCheckCatalog.checkIds in {catalog_path}")
    checks_block = text[start:end]
    ids = tuple(re.findall(r"QaCheckDefinition\(\s*id:\s*'([^']+)'", checks_block))
    if not ids:
        raise ValueError(f"No QA check IDs found in {catalog_path}")
    duplicates = sorted({item for item in ids if ids.count(item) > 1})
    if duplicates:
        raise ValueError(f"Duplicate QA check IDs in catalog: {', '.join(duplicates)}")
    return ids


def _load_json(path: Path) -> tuple[dict[str, Any] | None, list[str]]:
    errors: list[str] = []
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as exc:
        return None, [f"Could not read evidence file: {exc}"]
    try:
        decoded = json.loads(raw)
    except json.JSONDecodeError as exc:
        return None, [f"Evidence file is not valid JSON: {exc}"]
    if not isinstance(decoded, dict):
        errors.append("Evidence root must be a JSON object")
        return None, errors
    return decoded, errors


def validate_bundle(
    path: Path,
    *,
    catalog_ids: tuple[str, ...],
    expected_version: str | None = None,
    require_all_passed: bool = False,
    require_diagnostics: bool = False,
    max_age_hours: float | None = None,
    now_utc: datetime | None = None,
) -> ValidationResult:
    data, load_errors = _load_json(path)
    if data is None:
        return ValidationResult(path, tuple(load_errors), (), {}, None)

    errors = list(load_errors)
    warnings: list[str] = []

    if data.get("schemaVersion") != SUPPORTED_BUNDLE_SCHEMA:
        errors.append(
            f"schemaVersion must be {SUPPORTED_BUNDLE_SCHEMA}; got {data.get('schemaVersion')!r}"
        )

    generated_at = _parse_iso_utc(data.get("generatedAtUtc"), "generatedAtUtc", errors)
    if generated_at is not None and max_age_hours is not None:
        reference = (now_utc or datetime.now(timezone.utc)).astimezone(timezone.utc)
        age_hours = (reference - generated_at).total_seconds() / 3600.0
        if age_hours < -0.01:
            errors.append("generatedAtUtc is in the future")
        elif age_hours > max_age_hours:
            errors.append(
                f"Evidence is too old: {age_hours:.1f} hours exceeds {max_age_hours:.1f} hours"
            )

    privacy = data.get("privacy")
    if not isinstance(privacy, dict):
        errors.append("privacy must be a JSON object")
    else:
        for key in sorted(REQUIRED_PRIVACY_FALSE):
            if privacy.get(key) is not False:
                errors.append(f"privacy.{key} must be false")

    app = data.get("app")
    if not isinstance(app, dict):
        errors.append("app must be a JSON object")
    else:
        if app.get("name") != "SonicNest":
            errors.append(f"app.name must be 'SonicNest'; got {app.get('name')!r}")
        version = app.get("version")
        if not isinstance(version, str) or not version:
            errors.append("app.version must be a non-empty string")
        elif expected_version is not None and version != expected_version:
            errors.append(
                f"app.version {version!r} does not match expected {expected_version!r}"
            )

    session = data.get("session")
    if not isinstance(session, dict):
        errors.append("session must be a JSON object")
    else:
        if session.get("schemaVersion") != 1:
            errors.append("session.schemaVersion must be 1")
        started_at = _parse_iso_utc(
            session.get("startedAtUtc"), "session.startedAtUtc", errors
        )
        updated_at = _parse_iso_utc(
            session.get("updatedAtUtc"), "session.updatedAtUtc", errors
        )
        if started_at is not None and updated_at is not None and updated_at < started_at:
            errors.append("session.updatedAtUtc must not be earlier than session.startedAtUtc")
        if generated_at is not None and updated_at is not None and generated_at < updated_at:
            errors.append("generatedAtUtc must not be earlier than session.updatedAtUtc")

    raw_checks = data.get("checks")
    checks_by_id: dict[str, dict[str, Any]] = {}
    if not isinstance(raw_checks, list):
        errors.append("checks must be a JSON array")
        raw_checks = []
    for index, check in enumerate(raw_checks):
        if not isinstance(check, dict):
            errors.append(f"checks[{index}] must be a JSON object")
            continue
        check_id = check.get("id")
        if not isinstance(check_id, str) or not check_id:
            errors.append(f"checks[{index}].id must be a non-empty string")
            continue
        if check_id in checks_by_id:
            errors.append(f"Duplicate check id in evidence: {check_id}")
            continue
        checks_by_id[check_id] = check

        status = check.get("status")
        if status not in SUPPORTED_STATUSES:
            errors.append(f"checks[{index}].status is invalid: {status!r}")
        updated = check.get("updatedAtUtc")
        if status == "notRun":
            if updated is not None:
                errors.append(f"{check_id}: notRun checks must have updatedAtUtc=null")
        elif status in SUPPORTED_STATUSES:
            _parse_iso_utc(updated, f"{check_id}.updatedAtUtc", errors)

        if not isinstance(check.get("category"), str) or not check.get("category"):
            errors.append(f"{check_id}: category must be a non-empty string")
        for flag in ("requiresPhysicalTarget", "requiresExternalTooling"):
            if not isinstance(check.get(flag), bool):
                errors.append(f"{check_id}: {flag} must be boolean")

    expected_ids = set(catalog_ids)
    actual_ids = set(checks_by_id)
    missing = sorted(expected_ids - actual_ids)
    unknown = sorted(actual_ids - expected_ids)
    if missing:
        errors.append(f"Evidence is missing catalog checks: {', '.join(missing)}")
    if unknown:
        errors.append(f"Evidence contains unknown checks: {', '.join(unknown)}")

    counts = {status: 0 for status in SUPPORTED_STATUSES}
    for check_id in catalog_ids:
        check = checks_by_id.get(check_id)
        if check is None:
            continue
        status = check.get("status")
        if status in counts:
            counts[status] += 1

    computed_summary: dict[str, int | bool] = {
        "totalChecks": len(catalog_ids),
        "assessedChecks": counts["passed"] + counts["failed"] + counts["blocked"],
        "passed": counts["passed"],
        "failed": counts["failed"],
        "blocked": counts["blocked"],
        "notRun": counts["notRun"],
        "allPassed": counts["passed"] == len(catalog_ids) and not missing and not unknown,
    }

    summary = data.get("summary")
    if not isinstance(summary, dict):
        errors.append("summary must be a JSON object")
    else:
        for key, expected in computed_summary.items():
            if summary.get(key) != expected:
                errors.append(
                    f"summary.{key} is inconsistent: expected {expected!r}, got {summary.get(key)!r}"
                )

    diagnostics = data.get("diagnostics")
    platform: str | None = None
    if diagnostics is None:
        if require_diagnostics:
            errors.append("diagnostics are required for this review")
        else:
            warnings.append("No diagnostics attached; platform/OS provenance is unavailable")
    elif not isinstance(diagnostics, dict):
        errors.append("diagnostics must be a JSON object when present")
    else:
        runtime = diagnostics.get("runtime")
        if not isinstance(runtime, dict):
            errors.append("diagnostics.runtime must be a JSON object")
        else:
            raw_platform = runtime.get("platform")
            if isinstance(raw_platform, str) and raw_platform.strip():
                platform = raw_platform.strip()
            else:
                errors.append("diagnostics.runtime.platform must be a non-empty string")

    if require_all_passed and computed_summary["allPassed"] is not True:
        errors.append("All catalog QA checks must be passed for --require-all-passed")

    return ValidationResult(
        path=path,
        errors=tuple(errors),
        warnings=tuple(warnings),
        summary=computed_summary,
        platform=platform,
    )


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Validate a SonicNest manual-QA JSON export. This is a structural review "
            "tool and never substitutes for the underlying physical/manual tests."
        )
    )
    parser.add_argument("evidence", nargs="+", type=Path, help="QA evidence JSON file(s)")
    parser.add_argument("--expected-version", help="Require an exact app version string")
    parser.add_argument(
        "--require-all-passed",
        action="store_true",
        help="Fail unless every current catalog check is marked passed",
    )
    parser.add_argument(
        "--require-diagnostics",
        action="store_true",
        help="Fail unless a privacy-safe diagnostics snapshot is attached",
    )
    parser.add_argument(
        "--max-age-hours",
        type=float,
        help="Fail when evidence was generated more than this many hours ago",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    if args.max_age_hours is not None and args.max_age_hours <= 0:
        print("error: --max-age-hours must be greater than zero", file=sys.stderr)
        return 2

    try:
        catalog_ids = load_catalog_check_ids()
    except (OSError, ValueError) as exc:
        print(f"error: could not load QA catalog: {exc}", file=sys.stderr)
        return 2

    any_invalid = False
    for path in args.evidence:
        result = validate_bundle(
            path,
            catalog_ids=catalog_ids,
            expected_version=args.expected_version,
            require_all_passed=args.require_all_passed,
            require_diagnostics=args.require_diagnostics,
            max_age_hours=args.max_age_hours,
        )
        status = "VALID" if result.valid else "INVALID"
        platform = f" platform={result.platform}" if result.platform else ""
        print(f"{status}: {path}{platform}")
        if result.summary:
            print(
                "  checks: "
                f"passed={result.summary.get('passed', 0)} "
                f"failed={result.summary.get('failed', 0)} "
                f"blocked={result.summary.get('blocked', 0)} "
                f"notRun={result.summary.get('notRun', 0)}"
            )
        for warning in result.warnings:
            print(f"  warning: {warning}")
        for error in result.errors:
            print(f"  error: {error}")
        any_invalid = any_invalid or not result.valid

    return 1 if any_invalid else 0


if __name__ == "__main__":
    raise SystemExit(main())
