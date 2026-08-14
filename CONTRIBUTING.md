# Contributing to SonicNest

Thank you for helping improve SonicNest.

## Development workflow

1. Fork or branch from `main`.
2. Run `bash tool/bootstrap_platforms.sh` after cloning or changing Flutter SDK versions. On Windows PowerShell use `./tool/bootstrap_platforms.ps1`.
3. Run `flutter pub get`.
4. Regenerate/apply native SonicNest branding before platform compilation with `bash tool/apply_branding.sh` or `./tool/apply_branding.ps1`.
5. Keep changes focused and add tests for behavior changes.
6. Run formatting, analysis, tests, and the relevant platform/package build before opening a pull request.
7. Use Conventional Commit-style messages when practical.

## Required checks

```bash
dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test
```

Run the repository integrity audit when changing project structure, release automation, packaging, or protected project files:

```bash
python tool/repository_audit.py
```

Do not commit secrets, signing keys, personal recordings, build outputs, generated native-brand PNG source outputs, or local environment files.

## Audio changes

Audio code must preserve originals unless the user explicitly chooses destructive deletion. New codecs must have documented platform support and a licensing review in `docs/CODECS.md`. Recorder, routing, interruption, long-duration, and DSP-quality claims that depend on physical hardware must remain evidence-based rather than inferred from successful compilation.

## Native branding changes

The vector mark under `assets/logo/` and deterministic generator `tool/generate_brand_assets_v2.dart` are repository-controlled brand sources. Do not replace generated launcher/splash outputs manually and then treat those generated binaries as authoritative source.

After changing branding, regenerate it through the documented pipeline and build the affected platform. Real launcher, splash, icon-mask, shell, and package surfaces still require release-candidate visual review.

## Linux packaging changes

Debian `.deb` is the initial repository-supported Linux package format. Packaging-related changes must preserve the deterministic path documented in `docs/LINUX_PACKAGING.md`.

After a Linux packaging change on a compatible Linux host, run:

```bash
flutter config --enable-linux-desktop
bash tool/bootstrap_platforms.sh
flutter pub get
dart tool/generate_brand_assets_v2.dart
flutter build linux --release
bash tool/build_linux_deb.sh release
bash tool/verify_linux_deb.sh
```

Packaging changes must keep the application payload, desktop entry, AppStream metadata, hicolor icon, LICENSE/NOTICE, package control metadata, and SHA-256 verification coherent. Do not weaken structural validation to silence a packaging error; correct the package source or verifier instead.

A structurally valid `.deb` is not by itself a stable-release approval. Representative real-system installation, upgrade, uninstall, microphone/routing, accessibility, visual, and distribution/signing evidence remains governed by `docs/QA_CHECKLIST.md`, `docs/RELEASE_EVIDENCE_TEMPLATE.md`, and `docs/RELEASING.md`.

## Documentation and continuation state

When implementation or release-state changes materially, update the relevant documentation and append the continuation details to `what_changed.md` without deleting its earlier history. Keep `PROJECT_STATE.md`, `TODO.md`, `CHANGELOG.md`, `ROADMAP.md`, and release documentation aligned with the actual evidence state.

## Commit identity

Maintainers using local Git may configure:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```
