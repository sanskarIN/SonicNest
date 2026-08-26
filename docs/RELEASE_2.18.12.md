# SonicNest 2.18.12 Release Preparation

This document defines the repository-owned preparation and evidence boundary for SonicNest **2.18.12**.

## Candidate identity

- Semantic version: `2.18.12`
- Flutter package version: `2.18.12+21812`
- Preparation branch: `release/2.18.12-prep`
- Supported targets: Android, iOS, macOS, Windows, Linux, and Web
- Current classification: development preview / release candidate preparation
- Stable/public approval: **not granted by the version bump alone**

The numeric build identifier `21812` is the build number selected for this candidate. `pubspec.yaml` remains the executable build source of truth, while `PROJECT_STATE.md` carries the human-readable semantic version. `tool/verify_release_version.py` rejects drift between those two declarations.

## Dependency transition

Version 2.18.12 preparation moves `file_picker` from `12.0.0-beta.7` to the stable `12.0.0` release.

`file_picker 12.0.0` changes the multi-file picker return shape used by SonicNest: `FilePicker.pickFiles()` now yields the selected `List<PlatformFile>` directly. SonicNest therefore consumes that list directly instead of reading the removed `.files` wrapper property.

The upgrade must not be treated as validated solely because dependency resolution succeeds. Native compilation, browser compilation, analyzer/tests, package workflows, and representative real picker operations remain required evidence.

## Automated acceptance gates

Before this candidate is merged or promoted, obtain fresh results for the exact candidate source revision:

- Repository Integrity Audit passes, including Python compilation, repository invariants, dependency-state verification, release-version verification, source-line hygiene, Python tooling regressions, release-readiness snapshot verification, and shell/PowerShell parsing.
- Flutter CI passes committed formatting, static analysis, the complete Flutter test suite, Android debug compilation, Linux debug compilation, and Web release compilation.
- Windows CI passes the maintained Windows build/package validation surface.
- Apple CI passes macOS and unsigned/no-codesign iOS build validation.
- Linux Package CI passes release bundle construction, Debian package verification, install/startup smoke, uninstall cleanup, and artifact publication.
- The manual Release Candidate Validation workflow passes Android, Linux, Windows, macOS, iOS, Web, and unified six-platform provenance from one exact source revision before candidate evidence is promoted.

Historical green runs remain historical evidence only. They do not substitute for a fresh 2.18.12 run.

## Manual and credential-dependent gates

Repository automation cannot truthfully close the following release gates:

- Real Android/iOS/macOS/Windows/Linux microphone permission, capture, routing, interruption, background/lifecycle, and device-switching tests.
- Representative Chromium, Firefox, and Safari/WebKit microphone, WAV, share/download, PWA, accessibility, and long-session tests.
- Low-storage, permission-revocation, abrupt-interruption, damaged-media, long-recording, large-library, and large-batch stress testing on real systems.
- TalkBack, VoiceOver, Narrator, Linux accessibility tooling, keyboard-only, zoom/text-scaling, and reduced-motion review.
- Final native icon/splash and Web/PWA visual inspection plus real screenshots from tested candidates.
- Google Play upload-key/App Signing configuration and protected Android signing.
- Apple provisioning, signing, notarization, TestFlight, and App Store Connect configuration.
- Windows Authenticode signing for the final public Windows package.
- Production Web hosting selection plus DNS, TLS, cache/service-worker, security-header, deployment-secret, and rollback validation.

Credentials and private signing material must remain outside the repository.

## Release evidence to record

For the exact six-platform candidate, record at minimum:

- Full source commit SHA.
- Workflow run ID and run attempt.
- Application version `2.18.12+21812`.
- Android APK and AAB SHA-256 values and signing classification.
- Linux bundle and Debian package SHA-256 values.
- Windows portable archive SHA-256 and signing classification.
- macOS archive SHA-256 and signing/notarization classification.
- iOS archive SHA-256 and signing classification.
- Web archive SHA-256 and static-bundle classification.
- Unified release-candidate manifest SHA-256.
- GitHub workflow artifact digest for the unified manifest artifact.
- Explicit `stableReleaseApproved` state.

Automated provenance proves build/checksum/source consistency. It does not prove hardware behavior, accessibility, store acceptance, protected signing, or production hosting.

## Promotion rule

Do not create or publish a stable `v2.18.12` tag merely because the repository version is `2.18.12`. Promotion requires the applicable automated, manual, signing, hosting, and distribution gates for the exact public candidate to be complete and reviewed.

Any reproducible issue discovered during candidate validation must be fixed in source, covered by a regression where practical, documented in `what_changed.md`, and validated again on the resulting source revision.
