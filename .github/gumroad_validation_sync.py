#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_SHA = "2c5f8c137af393bc37a89dd1f9ddcf78218a7c81"
RUNS = {
    "repository_integrity": 32030915095,
    "flutter_ci": 32030915177,
    "windows": 32030915108,
    "apple": 32030915143,
    "linux_package": 32030915109,
}


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    if not text.endswith("\n"):
        text += "\n"
    (ROOT / path).write_text(text, encoding="utf-8", newline="\n")


def commit(path: str, message: str) -> None:
    subprocess.run(["git", "add", "--", path], cwd=ROOT, check=True)
    if subprocess.run(["git", "diff", "--cached", "--quiet", "--", path], cwd=ROOT).returncode == 0:
        return
    subprocess.run(["git", "commit", "-m", message], cwd=ROOT, check=True)


def update_project_state() -> None:
    path = "PROJECT_STATE.md"
    text = read(path)
    marker = "current_phase: Cross-platform release hardening\n"
    if "gumroad_integration_validation:" not in text:
        block = f'''gumroad_integration_validation:
  source_revision: {SOURCE_SHA}
  repository_integrity_run: {RUNS["repository_integrity"]}
  flutter_ci_run: {RUNS["flutter_ci"]}
  windows_build_run: {RUNS["windows"]}
  apple_builds_run: {RUNS["apple"]}
  linux_package_run: {RUNS["linux_package"]}
  result: success
  scope: formatter + static analysis + Flutter tests + Android/Linux/Windows/macOS/iOS builds + Windows portable smoke + Debian build/install/smoke/uninstall + repository line/tooling audit
'''
        if marker not in text:
            raise RuntimeError("PROJECT_STATE current_phase marker missing")
        text = text.replace(marker, block + marker, 1)
        write(path, text)
        commit(path, "docs: record Gumroad integration validation state")


def update_what_changed() -> None:
    path = "what_changed.md"
    text = read(path)
    heading = "## Final validation evidence — Gumroad storefront integration"
    if heading in text:
        return
    block = f'''

{heading}

Validated source revision: `{SOURCE_SHA}`

- Repository Integrity Audit `{RUNS["repository_integrity"]}` — **SUCCESS**: repository invariants, every tracked text/source line, Python tooling regressions, Bash syntax, and PowerShell syntax.
- Flutter CI `{RUNS["flutter_ci"]}` — **SUCCESS**: committed Dart formatting, static analysis, full Flutter unit tests, Android debug APK, and Linux debug build.
- Windows Build `{RUNS["windows"]}` — **SUCCESS**: Windows debug build plus release portable package build, verification, extracted-package startup smoke, validation warning, and artifact upload.
- Apple Builds `{RUNS["apple"]}` — **SUCCESS**: macOS debug and iOS no-codesign debug builds.
- Linux Package CI `{RUNS["linux_package"]}` — **SUCCESS**: Linux release bundle, Debian package build/verification/metadata, package-manager installation, installed startup smoke, uninstall cleanup, and artifact upload.

The validation confirms the repository-owned Gumroad integration and supported automated build/test/package paths. It does **not** replace remaining physical-device microphone/routing/lifecycle/background tests, real accessibility audits, destructive storage/power/process recovery tests, large-library/long-duration soak tests, protected signing/notarization/store-console validation, or stable-release approval.
'''
    write(path, text.rstrip() + block + "\n")
    commit(path, "docs: append Gumroad integration validation evidence")


def main() -> None:
    update_project_state()
    update_what_changed()


if __name__ == "__main__":
    main()
