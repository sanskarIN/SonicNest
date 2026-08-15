#!/usr/bin/env python3
"""Repository-only integrity checks for SonicNest.

The audit intentionally avoids network access and does not make release-readiness
claims. It protects repository invariants that can be checked deterministically.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = (
    "README.md",
    "LICENSE",
    "NOTICE",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "PRIVACY.md",
    "SECURITY.md",
    "SUPPORT.md",
    "ROADMAP.md",
    "PROJECT_STATE.md",
    "TODO.md",
    "what_changed.md",
    "pubspec.yaml",
    "analysis_options.yaml",
    "docs/ARCHITECTURE.md",
    "docs/BATCH_CONVERSION.md",
    "docs/BUILDING.md",
    "docs/BRANDING.md",
    "docs/CODECS.md",
    "docs/LINUX_DISTRIBUTION_POLICY.md",
    "docs/LINUX_PACKAGING.md",
    "docs/LOCALIZATION_POLICY.md",
    "docs/MANAGED_STORAGE_BOUNDARY.md",
    "docs/METADATA_INTEGRITY.md",
    "docs/QA_CHECKLIST.md",
    "docs/RECOVERY_INDEX.md",
    "docs/RECOVERY_TESTING.md",
    "docs/RELEASING.md",
    "docs/RELEASE_EVIDENCE_TEMPLATE.md",
    "docs/STORE_LISTING.md",
    "docs/UNSIGNED_ARTIFACTS.md",
    "docs/USER_GUIDE.md",
    "docs/TROUBLESHOOTING.md",
    "docs/WINDOWS_SIGNING_POLICY.md",
    "packaging/linux/debian/sonicnest.desktop",
    "packaging/linux/debian/io.github.sanskarIN.SonicNest.metainfo.xml",
    "tool/bootstrap_platforms.sh",
    "tool/bootstrap_platforms.ps1",
    "tool/apply_branding.sh",
    "tool/apply_branding.ps1",
    "tool/generate_brand_assets_v2.dart",
    "tool/build_linux_deb.sh",
    "tool/verify_linux_deb.sh",
    "tool/smoke_test_installed_linux_deb.sh",
    "tool/release_preflight.sh",
    "tool/release_preflight.ps1",
    ".github/workflows/ci.yml",
    ".github/workflows/linux-package.yml",
    ".github/workflows/windows.yml",
    ".github/workflows/macos.yml",
    ".github/workflows/release-candidate.yml",
    ".github/workflows/repository-audit.yml",
)

ALLOWED_WORKFLOW_FILES = {
    ".github/workflows/ci.yml",
    ".github/workflows/linux-package.yml",
    ".github/workflows/windows.yml",
    ".github/workflows/macos.yml",
    ".github/workflows/release-candidate.yml",
    ".github/workflows/repository-audit.yml",
}

FORBIDDEN_TRACKED_SUFFIXES = (
    ".jks",
    ".keystore",
    ".p12",
    ".pfx",
    ".mobileprovision",
    ".pem",
)

FORBIDDEN_TRACKED_BASENAMES = {
    ".env",
    "key.properties",
    "google-services.json",
    "GoogleService-Info.plist",
}

GENERATED_HOST_PREFIXES = (
    "android/",
    "ios/",
    "macos/",
    "linux/",
    "windows/",
)

ALLOWED_GENERATED_HOST_PATH_PREFIXES: tuple[str, ...] = ()

PRIVATE_MATERIAL_PATTERNS = (
    re.compile(r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"),
    re.compile(r"-----BEGIN ENCRYPTED PRIVATE KEY-----"),
    re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
)

FORBIDDEN_PERMANENT_WORKFLOW_WRITE_PERMISSIONS = (
    "actions: write",
    "checks: write",
    "contents: write",
    "deployments: write",
    "id-token: write",
    "issues: write",
    "packages: write",
    "pages: write",
    "pull-requests: write",
    "repository-projects: write",
    "security-events: write",
    "statuses: write",
)

SELF_AUDIT_PATH = "tool/repository_audit.py"
MAX_TRACKED_FILE_BYTES = 10 * 1024 * 1024


def git_lines(*args: str) -> list[str]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), *args],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return [line for line in result.stdout.splitlines() if line]


def tracked_files() -> list[str]:
    return git_lines("ls-files")


def is_text_candidate(path: Path) -> bool:
    try:
        data = path.read_bytes()[:8192]
    except OSError:
        return False
    return b"\x00" not in data


def audit() -> list[str]:
    errors: list[str] = []

    for relative in REQUIRED_FILES:
        if not (ROOT / relative).is_file():
            errors.append(f"Required repository file is missing: {relative}")

    tracked = tracked_files()
    tracked_set = set(tracked)
    tracked_workflows = {
        relative
        for relative in tracked
        if relative.startswith(".github/workflows/") and relative.endswith(".yml")
    }

    for relative in sorted(tracked_workflows - ALLOWED_WORKFLOW_FILES):
        errors.append(
            "Unapproved GitHub Actions workflow is tracked; temporary/one-shot workflows "
            f"must not remain on main: {relative}"
        )

    for relative in sorted(tracked_workflows & ALLOWED_WORKFLOW_FILES):
        workflow_path = ROOT / relative
        try:
            workflow_text = workflow_path.read_text(encoding="utf-8", errors="ignore")
        except OSError as exc:
            errors.append(f"Could not read workflow {relative}: {exc}")
            continue
        for permission in FORBIDDEN_PERMANENT_WORKFLOW_WRITE_PERMISSIONS:
            if permission in workflow_text:
                errors.append(
                    "Permanent workflow must stay read-only and must not request "
                    f"{permission!r}: {relative}"
                )

    for relative in tracked:
        path = ROOT / relative
        basename = path.name
        lower = relative.lower()

        if basename in FORBIDDEN_TRACKED_BASENAMES:
            errors.append(f"Sensitive/generated configuration must not be tracked: {relative}")
        if lower.endswith(FORBIDDEN_TRACKED_SUFFIXES):
            errors.append(f"Signing/private material must not be tracked: {relative}")
        if relative.startswith("assets/generated/") and lower.endswith(".png"):
            errors.append(
                "Generated native branding PNGs must stay reproducible rather than tracked: "
                f"{relative}"
            )
        if any(relative.startswith(prefix) for prefix in GENERATED_HOST_PREFIXES):
            if not any(
                relative.startswith(prefix)
                for prefix in ALLOWED_GENERATED_HOST_PATH_PREFIXES
            ):
                errors.append(
                    "Generated top-level Flutter host scaffolding must not be committed; "
                    f"use tool/bootstrap_platforms.* instead: {relative}"
                )
        try:
            size = path.stat().st_size
        except OSError as exc:
            errors.append(f"Could not stat tracked file {relative}: {exc}")
            continue
        if size > MAX_TRACKED_FILE_BYTES:
            errors.append(
                f"Tracked file exceeds {MAX_TRACKED_FILE_BYTES // (1024 * 1024)} MiB: "
                f"{relative} ({size} bytes)"
            )

    for relative in tracked:
        # The audit source contains the detector signatures by design. Skipping only
        # this exact file prevents self-matches without exempting any other source.
        if relative == SELF_AUDIT_PATH:
            continue
        path = ROOT / relative
        if not path.is_file() or not is_text_candidate(path):
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        for pattern in PRIVATE_MATERIAL_PATTERNS:
            if pattern.search(text):
                errors.append(f"Possible private credential material detected in: {relative}")
                break

    license_text = (
        (ROOT / "LICENSE").read_text(encoding="utf-8", errors="ignore")
        if (ROOT / "LICENSE").exists()
        else ""
    )
    if "Apache License" not in license_text or "Version 2.0" not in license_text:
        errors.append("LICENSE does not look like the expected Apache License 2.0 text.")

    pubspec = (
        (ROOT / "pubspec.yaml").read_text(encoding="utf-8", errors="ignore")
        if (ROOT / "pubspec.yaml").exists()
        else ""
    )
    required_pubspec_fragments = (
        "name: sonic_nest",
        "publish_to: 'none'",
        "flutter_launcher_icons:",
        "flutter_native_splash:",
        "assets/generated/sonicnest_icon.png",
    )
    for fragment in required_pubspec_fragments:
        if fragment not in pubspec:
            errors.append(f"pubspec.yaml is missing required project invariant: {fragment}")

    desktop_file = ROOT / "packaging/linux/debian/sonicnest.desktop"
    if desktop_file.exists():
        desktop_text = desktop_file.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "Type=Application",
            "Name=SonicNest",
            "Exec=/opt/sonicnest/sonic_nest",
            "Icon=sonicnest",
            "Terminal=false",
            "Categories=AudioVideo;Recorder;",
        ):
            if fragment not in desktop_text:
                errors.append(
                    f"sonicnest.desktop is missing required package invariant: {fragment}"
                )

    metainfo_file = (
        ROOT / "packaging/linux/debian/io.github.sanskarIN.SonicNest.metainfo.xml"
    )
    if metainfo_file.exists():
        metainfo_text = metainfo_file.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "<id>io.github.sanskarIN.SonicNest</id>",
            '<developer id="io.github.sanskarin">',
            '<launchable type="desktop-id">sonicnest.desktop</launchable>',
            "<binary>sonic_nest</binary>",
            "<project_license>Apache-2.0</project_license>",
            '<content_rating type="oars-1.1" />',
        ):
            if fragment not in metainfo_text:
                errors.append(
                    "Linux AppStream metadata is missing required package invariant: "
                    f"{fragment}"
                )

    linux_builder = ROOT / "tool/build_linux_deb.sh"
    if linux_builder.exists():
        builder_text = linux_builder.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "dpkg-deb --root-owner-group --build",
            "/usr/share/applications",
            "/usr/share/icons/hicolor/512x512/apps",
            "/usr/share/metainfo",
            "sha256sum",
        ):
            if fragment not in builder_text:
                errors.append(
                    f"build_linux_deb.sh is missing required packaging invariant: {fragment}"
                )

    installed_smoke = ROOT / "tool/smoke_test_installed_linux_deb.sh"
    if installed_smoke.exists():
        smoke_text = installed_smoke.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "dpkg-query",
            "/opt/sonicnest/sonic_nest",
            "desktop-file-validate",
            "appstreamcli validate --no-net",
            "xvfb-run",
            "timeout 8s",
        ):
            if fragment not in smoke_text:
                errors.append(
                    "smoke_test_installed_linux_deb.sh is missing required install-smoke invariant: "
                    f"{fragment}"
                )

    release_workflow = ROOT / ".github/workflows/release-candidate.yml"
    if release_workflow.exists():
        workflow_text = release_workflow.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "workflow_dispatch:",
            "RELEASE_CANDIDATE_WARNING.txt",
            "SHA256SUMS.txt",
            "actions/upload-artifact@v4",
            "contents: read",
            "tool/build_linux_deb.sh release",
            "tool/verify_linux_deb.sh",
            "sonicnest-android-release-unsigned.apk",
            "sonicnest-windows-release-unsigned.zip",
            "sonicnest-macos-release-unsigned.zip",
            "sonicnest-ios-release-unsigned.zip",
        ):
            if fragment not in workflow_text:
                errors.append(
                    f"release-candidate.yml is missing required safety/output marker: {fragment}"
                )

    linux_package_workflow = ROOT / ".github/workflows/linux-package.yml"
    if linux_package_workflow.exists():
        workflow_text = linux_package_workflow.read_text(
            encoding="utf-8", errors="ignore"
        )
        for fragment in (
            "flutter build linux --release",
            "tool/build_linux_deb.sh release",
            "tool/verify_linux_deb.sh",
            "sudo apt-get install -y \"./$PACKAGE\"",
            "tool/smoke_test_installed_linux_deb.sh",
            "sudo apt-get remove -y sonicnest",
            "actions/upload-artifact@v4",
            "contents: read",
        ):
            if fragment not in workflow_text:
                errors.append(
                    f"linux-package.yml is missing required validation marker: {fragment}"
                )

    for relative in ("tool/release_preflight.sh", "tool/release_preflight.ps1"):
        preflight_path = ROOT / relative
        if preflight_path.exists():
            preflight_text = preflight_path.read_text(encoding="utf-8", errors="ignore")
            for fragment in (
                "dart format --output=none --set-exit-if-changed",
                "flutter analyze --no-fatal-infos",
                "flutter test",
            ):
                if fragment not in preflight_text:
                    errors.append(
                        f"{relative} is missing required non-mutating validation marker: {fragment}"
                    )

    ci_workflow = ROOT / ".github/workflows/ci.yml"
    if ci_workflow.exists():
        ci_text = ci_workflow.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "dart format --output=none --set-exit-if-changed",
            "flutter analyze --no-fatal-infos",
            "flutter test",
        ):
            if fragment not in ci_text:
                errors.append(f"ci.yml is missing required validation marker: {fragment}")

    store_listing = ROOT / "docs/STORE_LISTING.md"
    if store_listing.exists():
        listing_text = store_listing.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "SonicNest",
            "microphone",
            "privacy",
            "Google Play",
            "Apple App Store",
            "Microsoft",
            "GitHub Releases",
        ):
            if fragment.lower() not in listing_text.lower():
                errors.append(
                    f"STORE_LISTING.md is missing required distribution/privacy marker: {fragment}"
                )

    windows_signing = ROOT / "docs/WINDOWS_SIGNING_POLICY.md"
    if windows_signing.exists():
        signing_text = windows_signing.read_text(encoding="utf-8", errors="ignore")
        for fragment in (
            "Authenticode",
            "private",
            "unsigned",
            "maintainer",
        ):
            if fragment.lower() not in signing_text.lower():
                errors.append(
                    "WINDOWS_SIGNING_POLICY.md is missing required signing-boundary marker: "
                    f"{fragment}"
                )

    gitignore = (
        (ROOT / ".gitignore").read_text(encoding="utf-8", errors="ignore")
        if (ROOT / ".gitignore").exists()
        else ""
    )
    for fragment in (
        "*.jks",
        "*.keystore",
        "*.p12",
        "*.mobileprovision",
        ".env",
        "assets/generated/*.png",
    ):
        if fragment not in gitignore:
            errors.append(f".gitignore is missing required protection: {fragment}")

    if "tool/generate_brand_assets.dart" in tracked_set:
        errors.append("Superseded brand generator is still tracked.")

    if (ROOT / "what_changed.md").exists():
        line_count = len(
            (ROOT / "what_changed.md").read_text(encoding="utf-8").splitlines()
        )
        if line_count < 100:
            errors.append(
                "what_changed.md is unexpectedly short; continuation history may have been truncated."
            )

    return errors


def main() -> int:
    try:
        errors = audit()
    except subprocess.CalledProcessError as exc:
        print(f"Repository audit could not query Git: {exc}", file=sys.stderr)
        return 2

    if errors:
        print("SonicNest repository audit FAILED:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("SonicNest repository audit passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
