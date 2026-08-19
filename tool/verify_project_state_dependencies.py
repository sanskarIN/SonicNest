#!/usr/bin/env python3
"""Verify PROJECT_STATE.md dependency declarations against pubspec.yaml.

This checker is intentionally standard-library-only. It protects the
human-maintained project-state summary from silently drifting after dependency
upgrades without trying to replace Flutter's package resolver or pubspec.lock.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DIRECT_DEPENDENCIES = (
    "record",
    "just_audio",
    "just_audio_background",
    "just_audio_media_kit",
    "ffmpeg_kit_flutter_new_audio",
    "file_picker",
    "share_plus",
    "wakelock_plus",
)


class DependencyStateError(ValueError):
    """Raised when dependency-state inputs cannot be interpreted safely."""


def _unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def normalize_constraint(value: str) -> str:
    value = _unquote(value).strip()
    if value.startswith("^"):
        value = value[1:].strip()
    if not value:
        raise DependencyStateError("dependency constraint is empty")
    if any(token in value for token in (" ", ">", "<", "=", "||")):
        raise DependencyStateError(
            "dependency constraint is not a single pinned/compatible version "
            f"token: {value!r}"
        )
    return value


def parse_direct_dependencies(pubspec_text: str) -> dict[str, str]:
    lines = pubspec_text.splitlines()
    in_dependencies = False
    found: dict[str, str] = {}

    for raw in lines:
        if raw == "dependencies:":
            in_dependencies = True
            continue
        if in_dependencies and re.match(r"^[A-Za-z_][A-Za-z0-9_]*:\s*$", raw):
            break
        if not in_dependencies:
            continue

        match = re.match(r"^  ([A-Za-z_][A-Za-z0-9_]*):\s*(.*?)\s*$", raw)
        if not match:
            continue
        name, value = match.groups()
        if name not in DIRECT_DEPENDENCIES:
            continue
        if not value:
            raise DependencyStateError(
                f"{name} uses a nested dependency declaration; the project-state "
                "checker requires a direct version constraint"
            )
        if name in found:
            raise DependencyStateError(f"duplicate direct dependency entry: {name}")
        found[name] = normalize_constraint(value)

    missing = [name for name in DIRECT_DEPENDENCIES if name not in found]
    if missing:
        raise DependencyStateError(
            "pubspec.yaml is missing dependency entries required by PROJECT_STATE.md: "
            + ", ".join(missing)
        )
    return found


def parse_project_stack(project_state_text: str) -> dict[str, str]:
    match = re.search(
        r"(?ms)^stack:\n(?P<body>(?:  [^\n]*\n)+?)^supported_platform_targets:",
        project_state_text,
    )
    if not match:
        raise DependencyStateError(
            "PROJECT_STATE.md does not contain the canonical stack block"
        )

    stack: dict[str, str] = {}
    for raw in match.group("body").splitlines():
        entry = re.match(r"^  ([a-z_]+):\s*(.+?)\s*$", raw)
        if not entry:
            continue
        key, value = entry.groups()
        if key in stack:
            raise DependencyStateError(f"duplicate stack entry: {key}")
        stack[key] = value

    required = ("recorder", "player", "processing", "import_export", "screen_wake")
    missing = [key for key in required if key not in stack]
    if missing:
        raise DependencyStateError(
            "PROJECT_STATE.md stack is missing required entries: " + ", ".join(missing)
        )
    return stack


def expected_stack_values(dependencies: dict[str, str]) -> dict[str, str]:
    ffmpeg = dependencies["ffmpeg_kit_flutter_new_audio"]
    ffmpeg_parts = ffmpeg.split(".")
    processing_version = (
        f"{ffmpeg_parts[0]}.{ffmpeg_parts[1]}.x"
        if len(ffmpeg_parts) >= 2
        and ffmpeg_parts[0].isdigit()
        and ffmpeg_parts[1].isdigit()
        else ffmpeg
    )
    return {
        "recorder": f"record {dependencies['record']}",
        "player": (
            f"just_audio {dependencies['just_audio']} + "
            f"just_audio_background {dependencies['just_audio_background']} + "
            f"just_audio_media_kit {dependencies['just_audio_media_kit']}"
        ),
        "processing": f"ffmpeg_kit_flutter_new_audio {processing_version}",
        "import_export": (
            f"file_picker {dependencies['file_picker']} + "
            f"share_plus {dependencies['share_plus']}"
        ),
        "screen_wake": f"wakelock_plus {dependencies['wakelock_plus']}",
    }


def verify(pubspec_text: str, project_state_text: str) -> list[str]:
    dependencies = parse_direct_dependencies(pubspec_text)
    stack = parse_project_stack(project_state_text)
    expected = expected_stack_values(dependencies)
    errors: list[str] = []
    for key, expected_value in expected.items():
        actual = stack[key]
        if actual != expected_value:
            errors.append(
                f"PROJECT_STATE.md stack.{key} is stale: "
                f"expected {expected_value!r}, found {actual!r}"
            )
    return errors


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Verify that dependency/version declarations in PROJECT_STATE.md match "
            "the direct runtime dependency constraints in pubspec.yaml."
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
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        pubspec_text = args.pubspec.read_text(encoding="utf-8")
        project_state_text = args.project_state.read_text(encoding="utf-8")
        errors = verify(pubspec_text, project_state_text)
    except (OSError, UnicodeError, DependencyStateError) as exc:
        print(f"Dependency-state verification could not run: {exc}", file=sys.stderr)
        return 2

    if errors:
        print("SonicNest dependency-state verification FAILED:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("SonicNest dependency-state verification passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
