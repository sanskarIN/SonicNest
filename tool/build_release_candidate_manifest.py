#!/usr/bin/env python3
"""Build a machine-readable manifest for SonicNest hosted release candidates."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

EXPECTED_PLATFORMS = ("android", "linux", "windows", "macos", "ios", "web")
REQUIRED_METADATA = {
    "android": (
        "RELEASE_CANDIDATE_WARNING.txt",
        "SHA256SUMS.txt",
        "ANDROID_SIGNING_STATE.txt",
    ),
    "linux": ("RELEASE_CANDIDATE_WARNING.txt", "SHA256SUMS.txt"),
    "windows": ("RELEASE_CANDIDATE_WARNING.txt", "SHA256SUMS.txt"),
    "macos": ("RELEASE_CANDIDATE_WARNING.txt", "SHA256SUMS.txt"),
    "ios": ("RELEASE_CANDIDATE_WARNING.txt", "SHA256SUMS.txt"),
    "web": ("RELEASE_CANDIDATE_WARNING.txt", "SHA256SUMS.txt"),
}
CLASSIFICATIONS = {
    "android": {
        "build": "release",
        "signing": "Android Debug certificate",
        "distribution": "NON-PRODUCTION hosted validation only",
    },
    "linux": {
        "build": "release",
        "signing": "unsigned repository validation artifact",
        "distribution": "development-preview hosted validation only",
    },
    "windows": {
        "build": "release",
        "signing": "unsigned",
        "distribution": "development-preview hosted validation only",
    },
    "macos": {
        "build": "release",
        "signing": "unsigned / not notarized",
        "distribution": "development-preview hosted validation only",
    },
    "ios": {
        "build": "release",
        "signing": "no-codesign",
        "distribution": "development-preview hosted validation only",
    },
    "web": {
        "build": "release",
        "signing": "not applicable to static web bundle",
        "distribution": "development-preview hosted validation only",
    },
}
PAYLOAD_SUFFIXES = (".apk", ".aab", ".deb", ".zip", ".tar.gz")

_SHA256_LINE = re.compile(r"^([0-9a-fA-F]{64})\s+\*?(.+?)\s*$")
_VERSION_LINE = re.compile(r"^version:\s*([^\s#]+)\s*(?:#.*)?$", re.MULTILINE)


class ManifestError(RuntimeError):
    """Raised when candidate evidence cannot be verified safely."""


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_version(pubspec: Path) -> str:
    try:
        text = pubspec.read_text(encoding="utf-8")
    except OSError as exc:
        raise ManifestError(f"Could not read pubspec: {pubspec}: {exc}") from exc
    match = _VERSION_LINE.search(text)
    if not match:
        raise ManifestError(f"Could not find a top-level version in {pubspec}.")
    return match.group(1)


def parse_artifact_arg(value: str) -> tuple[str, Path]:
    if "=" not in value:
        raise argparse.ArgumentTypeError("artifact must use PLATFORM=PATH syntax")
    platform, raw_path = value.split("=", 1)
    platform = platform.strip().lower()
    raw_path = raw_path.strip()
    if platform not in EXPECTED_PLATFORMS:
        raise argparse.ArgumentTypeError(
            f"unsupported platform {platform!r}; expected one of "
            f"{', '.join(EXPECTED_PLATFORMS)}"
        )
    if not raw_path:
        raise argparse.ArgumentTypeError("artifact path cannot be empty")
    return platform, Path(raw_path)


def parse_checksum_file(path: Path) -> dict[str, str]:
    checksums: dict[str, str] = {}
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        raise ManifestError(f"Could not read checksum file {path}: {exc}") from exc

    for line_number, line in enumerate(lines, start=1):
        if not line.strip():
            continue
        match = _SHA256_LINE.match(line)
        if not match:
            raise ManifestError(
                f"Malformed SHA-256 entry in {path} at line {line_number}: {line!r}"
            )
        digest = match.group(1).lower()
        relative = match.group(2).strip()
        if relative in checksums:
            raise ManifestError(f"Duplicate SHA-256 entry {relative!r} in {path}.")
        checksums[relative] = digest

    if not checksums:
        raise ManifestError(f"No SHA-256 entries found in {path}.")
    return checksums


def is_payload(path: Path) -> bool:
    name = path.name.lower()
    return any(name.endswith(suffix) for suffix in PAYLOAD_SUFFIXES)


def _reject_symbolic_links(platform: str, directory: Path) -> None:
    if directory.is_symlink():
        raise ManifestError(
            f"{platform} artifact directory must not be a symbolic link: {directory}"
        )
    for path in directory.rglob("*"):
        if path.is_symlink():
            relative = path.relative_to(directory).as_posix()
            raise ManifestError(
                f"{platform} artifact directory contains a symbolic link: {relative}"
            )


def verify_platform_directory(platform: str, directory: Path) -> dict[str, object]:
    if not directory.is_dir():
        raise ManifestError(f"{platform} artifact directory does not exist: {directory}")
    _reject_symbolic_links(platform, directory)

    for required_name in REQUIRED_METADATA[platform]:
        if not (directory / required_name).is_file():
            raise ManifestError(
                f"{platform} artifact directory is missing required metadata: "
                f"{required_name}"
            )

    checksum_path = directory / "SHA256SUMS.txt"
    expected_checksums = parse_checksum_file(checksum_path)
    checksum_verification: list[dict[str, object]] = []
    normalized_checksum_paths: set[str] = set()

    for relative_name, expected_digest in sorted(expected_checksums.items()):
        relative_path = Path(relative_name.replace("\\", "/"))
        if relative_path.is_absolute() or ".." in relative_path.parts:
            raise ManifestError(
                f"{platform} checksum entry escapes its artifact directory: "
                f"{relative_name}"
            )
        normalized_relative = relative_path.as_posix()
        if normalized_relative in normalized_checksum_paths:
            raise ManifestError(
                f"Duplicate normalized SHA-256 path in {checksum_path}: "
                f"{normalized_relative!r}"
            )
        normalized_checksum_paths.add(normalized_relative)

        target = directory / relative_path
        if not target.is_file():
            raise ManifestError(
                f"{platform} checksum entry references a missing file: {relative_name}"
            )
        actual_digest = sha256_file(target)
        if actual_digest != expected_digest:
            raise ManifestError(
                f"{platform} checksum mismatch for {relative_name}: "
                f"expected {expected_digest}, got {actual_digest}"
            )
        checksum_verification.append(
            {
                "path": normalized_relative,
                "sha256": actual_digest,
                "sizeBytes": target.stat().st_size,
            }
        )

    files = []
    for path in sorted(candidate for candidate in directory.rglob("*") if candidate.is_file()):
        relative = path.relative_to(directory).as_posix()
        files.append(
            {
                "path": relative,
                "sha256": sha256_file(path),
                "sizeBytes": path.stat().st_size,
                "role": "payload" if is_payload(path) else "metadata",
            }
        )

    payloads = [entry for entry in files if entry["role"] == "payload"]
    if not payloads:
        raise ManifestError(f"{platform} artifact directory contains no release payload.")

    checked_paths = {entry["path"] for entry in checksum_verification}
    unchecked_payloads = [
        entry["path"] for entry in payloads if entry["path"] not in checked_paths
    ]
    if unchecked_payloads:
        raise ManifestError(
            f"{platform} release payloads are missing from SHA256SUMS.txt: "
            + ", ".join(unchecked_payloads)
        )

    if platform == "android":
        signing_text = (directory / "ANDROID_SIGNING_STATE.txt").read_text(
            encoding="utf-8", errors="replace"
        )
        required_markers = (
            "Package: io.github.sanskarin.sonic_nest",
            "Classification: Android Debug certificate / NON-PRODUCTION",
        )
        for marker in required_markers:
            if marker not in signing_text:
                raise ManifestError(
                    "Android signing-state report is missing required marker: "
                    f"{marker}"
                )

    return {
        "platform": platform,
        **CLASSIFICATIONS[platform],
        "files": files,
        "verifiedChecksums": checksum_verification,
    }


def build_manifest(
    artifact_dirs: dict[str, Path],
    source_sha: str,
    workflow_run_id: str,
    workflow_run_attempt: str,
    pubspec: Path,
) -> dict[str, object]:
    missing = [platform for platform in EXPECTED_PLATFORMS if platform not in artifact_dirs]
    extra = [platform for platform in artifact_dirs if platform not in EXPECTED_PLATFORMS]
    if missing:
        raise ManifestError(f"Missing platform artifact directories: {', '.join(missing)}")
    if extra:
        raise ManifestError(f"Unexpected platform artifact directories: {', '.join(extra)}")

    source_sha = source_sha.strip().lower()
    if not re.fullmatch(r"[0-9a-f]{40}", source_sha):
        raise ManifestError(
            "source SHA must be a full 40-character hexadecimal Git commit SHA"
        )

    run_id = workflow_run_id.strip()
    run_attempt = workflow_run_attempt.strip()
    if not run_id.isdigit() or int(run_id) <= 0:
        raise ManifestError("workflow run ID must be a positive integer")
    if not run_attempt.isdigit() or int(run_attempt) <= 0:
        raise ManifestError("workflow run attempt must be a positive integer")

    platforms = [
        verify_platform_directory(platform, artifact_dirs[platform])
        for platform in EXPECTED_PLATFORMS
    ]

    return {
        "schemaVersion": 1,
        "project": "SonicNest",
        "applicationVersion": parse_version(pubspec),
        "sourceSha": source_sha,
        "workflow": {
            "name": "Release Candidate Validation",
            "runId": int(run_id),
            "runAttempt": int(run_attempt),
        },
        "releaseClassification": "development-preview",
        "stableReleaseApproved": False,
        "platforms": platforms,
    }


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build and verify a SonicNest release-candidate provenance manifest."
    )
    parser.add_argument(
        "--artifact", action="append", type=parse_artifact_arg, required=True
    )
    parser.add_argument("--source-sha", required=True)
    parser.add_argument("--workflow-run-id", required=True)
    parser.add_argument("--workflow-run-attempt", default="1")
    parser.add_argument("--pubspec", type=Path, default=Path("pubspec.yaml"))
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    artifact_dirs: dict[str, Path] = {}
    for platform, path in args.artifact:
        if platform in artifact_dirs:
            print(f"Duplicate --artifact entry for {platform}.", file=sys.stderr)
            return 2
        artifact_dirs[platform] = path

    try:
        manifest = build_manifest(
            artifact_dirs=artifact_dirs,
            source_sha=args.source_sha,
            workflow_run_id=args.workflow_run_id,
            workflow_run_attempt=args.workflow_run_attempt,
            pubspec=args.pubspec,
        )
    except ManifestError as exc:
        print(f"Release candidate manifest validation failed: {exc}", file=sys.stderr)
        return 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote verified release candidate manifest: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
