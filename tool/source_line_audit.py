#!/usr/bin/env python3
"""Line-by-line hygiene checks for every tracked SonicNest text file."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_SUFFIXES = {
    ".dart",
    ".py",
    ".sh",
    ".ps1",
    ".yml",
    ".yaml",
    ".xml",
    ".desktop",
    ".json",
    ".toml",
    ".lock",
}
SOURCE_BASENAMES = {".gitignore"}


def tracked_files() -> list[str]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "ls-files", "-z"],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return [item.decode("utf-8") for item in result.stdout.split(b"\0") if item]


def is_source_like(relative: str) -> bool:
    path = Path(relative)
    return path.suffix.casefold() in SOURCE_SUFFIXES or path.name in SOURCE_BASENAMES


def inspect_text(relative: str, data: bytes) -> list[str]:
    errors: list[str] = []
    if b"\x00" in data[:8192]:
        return errors
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError as exc:
        return [f"{relative}: invalid UTF-8 text candidate ({exc})"]

    source_like = is_source_like(relative)
    if source_like and text.startswith("\ufeff"):
        errors.append(f"{relative}: UTF-8 BOM is not allowed in source/config files")
    if source_like and data and not data.endswith(b"\n"):
        errors.append(f"{relative}: missing final newline")

    for line_number, line in enumerate(text.splitlines(), start=1):
        stripped = line.lstrip()
        if stripped.startswith("<<<<<<< ") or stripped.startswith(">>>>>>> "):
            errors.append(
                f"{relative}:{line_number}: unresolved merge-conflict marker"
            )
        if source_like and line.endswith((" ", "\t")):
            errors.append(f"{relative}:{line_number}: trailing whitespace")

    return errors


def audit() -> list[str]:
    errors: list[str] = []
    for relative in tracked_files():
        path = ROOT / relative
        if not path.is_file():
            continue
        try:
            data = path.read_bytes()
        except OSError as exc:
            errors.append(f"{relative}: could not read tracked file ({exc})")
            continue
        errors.extend(inspect_text(relative, data))
    return errors


def main() -> int:
    try:
        errors = audit()
    except subprocess.CalledProcessError as exc:
        print(f"Source line audit could not query Git: {exc}", file=sys.stderr)
        return 2
    if errors:
        print("SonicNest source line audit FAILED:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("SonicNest source line audit passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
