#!/usr/bin/env python3
"""Verify SonicNest release-version metadata stays synchronized.

The Flutter package version in pubspec.yaml is the build source of truth. This
helper keeps PROJECT_STATE.md and the runtime AppConstants version/build values
aligned with it while enforcing an explicit positive numeric build number.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import NamedTuple

ROOT = Path(__file__).resolve().parents[1]


class ReleaseVersionError(ValueError):
    """Raised when release-version metadata cannot be interpreted safely."""


class ReleaseVersion(NamedTuple):
    semantic_version: str
    build_number: int

    @property
    def pubspec_version(self) -> str:
        return f"{self.semantic_version}+{self.build_number}"


def _single_match(pattern: str, text: str, label: str) -> str:
    matches = re.findall(pattern, text, flags=re.MULTILINE)
    if len(matches) != 1:
        raise ReleaseVersionError(
            f"expected exactly one {label}; found {len(matches)}"
        )
    return matches[0].strip()


def _parse_semantic_version(value: str, label: str) -> str:
    if re.fullmatch(r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)", value) is None:
        raise ReleaseVersionError(f"{label} must use MAJOR.MINOR.PATCH")
    return value


def parse_pubspec_version(pubspec_text: str) -> ReleaseVersion:
    value = _single_match(
        r"^version:\s*([^\s#]+)\s*(?:#.*)?$",
        pubspec_text,
        "pubspec version",
    )
    match = re.fullmatch(
        r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)\+([1-9]\d*)",
        value,
    )
    if match is None:
        raise ReleaseVersionError(
            "pubspec version must use MAJOR.MINOR.PATCH+BUILD with a positive "
            "numeric build number"
        )
    major, minor, patch, build = match.groups()
    return ReleaseVersion(
        semantic_version=f"{major}.{minor}.{patch}",
        build_number=int(build),
    )


def parse_project_state_version(project_state_text: str) -> str:
    value = _single_match(
        r"^current_version:\s*([^\s#]+)\s*(?:#.*)?$",
        project_state_text,
        "PROJECT_STATE.md current_version",
    )
    return _parse_semantic_version(value, "PROJECT_STATE.md current_version")


def parse_runtime_version(constants_text: str) -> ReleaseVersion:
    semantic_version = _single_match(
        r"^\s*static const appVersion = '([^']+)';\s*$",
        constants_text,
        "AppConstants.appVersion",
    )
    build = _single_match(
        r"^\s*static const appBuildNumber = '([^']+)';\s*$",
        constants_text,
        "AppConstants.appBuildNumber",
    )
    _parse_semantic_version(semantic_version, "AppConstants.appVersion")
    if re.fullmatch(r"[1-9]\d*", build) is None:
        raise ReleaseVersionError(
            "AppConstants.appBuildNumber must be a positive numeric build number"
        )
    return ReleaseVersion(semantic_version, int(build))


def verify(
    pubspec_text: str,
    project_state_text: str,
    constants_text: str,
) -> list[str]:
    pubspec_version = parse_pubspec_version(pubspec_text)
    project_version = parse_project_state_version(project_state_text)
    runtime_version = parse_runtime_version(constants_text)
    errors: list[str] = []
    if project_version != pubspec_version.semantic_version:
        errors.append(
            "PROJECT_STATE.md current_version is stale: "
            f"expected {pubspec_version.semantic_version!r}, found {project_version!r}"
        )
    if runtime_version.semantic_version != pubspec_version.semantic_version:
        errors.append(
            "AppConstants.appVersion is stale: "
            f"expected {pubspec_version.semantic_version!r}, "
            f"found {runtime_version.semantic_version!r}"
        )
    if runtime_version.build_number != pubspec_version.build_number:
        errors.append(
            "AppConstants.appBuildNumber is stale: "
            f"expected {pubspec_version.build_number!r}, "
            f"found {runtime_version.build_number!r}"
        )
    return errors


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Verify that SonicNest pubspec, PROJECT_STATE, and runtime version "
            "metadata agree."
        )
    )
    parser.add_argument(
        "--pubspec",
        type=Path,
        default=ROOT / "pubspec.yaml",
        help="pubspec.yaml path",
    )
    parser.add_argument(
        "--project-state",
        type=Path,
        default=ROOT / "PROJECT_STATE.md",
        help="PROJECT_STATE.md path",
    )
    parser.add_argument(
        "--constants",
        type=Path,
        default=ROOT / "lib" / "core" / "constants.dart",
        help="runtime constants Dart file path",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        pubspec_text = args.pubspec.read_text(encoding="utf-8")
        project_state_text = args.project_state.read_text(encoding="utf-8")
        constants_text = args.constants.read_text(encoding="utf-8")
        errors = verify(pubspec_text, project_state_text, constants_text)
    except (OSError, UnicodeError, ReleaseVersionError) as exc:
        print(f"Release-version verification could not run: {exc}", file=sys.stderr)
        return 2

    if errors:
        print("SonicNest release-version verification FAILED:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    version = parse_pubspec_version(pubspec_text)
    print(
        "SonicNest release-version verification passed: "
        f"{version.pubspec_version}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
