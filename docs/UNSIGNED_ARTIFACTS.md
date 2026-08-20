# Non-Production Release-Candidate Artifacts

SonicNest includes `.github/workflows/release-candidate.yml` to exercise release-mode compilation, packaging, Web bundling, and provenance without storing or using maintainer production signing/deployment credentials.

These artifacts are **validation outputs**, not public/store/host-ready releases. Their signing state is platform-specific: Android hosted candidates are intentionally verified as Android Debug-certificate/non-production artifacts, Windows and macOS candidate archives are not production-signed, iOS is built with `--no-codesign`, Linux is a development-preview package artifact, and Web is a checksummed static bundle for which native binary signing is not the distribution model.

## Why this workflow exists

Debug/native builds prove only part of the source/host surface. Release mode can expose different optimization, linker, resource, packaging, Web compilation, and platform configuration problems. The release-candidate workflow provides a reproducible repository-controlled gate before the maintainer introduces private native signing credentials or production Web hosting/deployment credentials in secure environments.

## Source preflight

Every release-candidate run begins with source preflight:

- generate Flutter host projects for Android, iOS, macOS, Linux, Windows, and Web from the selected stable SDK;
- resolve project dependencies;
- regenerate/apply SonicNest native/Web branding;
- verify checked-in Dart formatting without rewriting source;
- run Flutter static analysis;
- run unit tests.

Equivalent local commands are available in:

- `tool/release_preflight.sh`
- `tool/release_preflight.ps1`

## Produced validation artifacts

### Android

- release-mode APK;
- release-mode Android App Bundle;
- explicit package/application identity validation;
- APK/AAB signing-state inspection through `tool/verify_android_nonproduction_candidate.sh`;
- `ANDROID_SIGNING_STATE.txt` containing non-secret certificate/digest evidence;
- SHA-256 checksums;
- explicit release-candidate warning text.

The generated hosted release APK/AAB are expected to use the generated **Android Debug** certificate and are therefore classified as **NON-PRODUCTION**, not “unsigned.” The verifier requires package ID `io.github.sanskarin.sonic_nest`, label `SonicNest`, valid archive/signature structure, and the expected debug certificate before the candidate is uploaded as workflow evidence.

The repository does not provide the maintainer's Play upload key or Play App Signing private key. A hosted release-mode artifact must not be uploaded or described as a public Google Play production build merely because it compiled or has a debug certificate signature. See `docs/ANDROID_DISTRIBUTION_POLICY.md`.

### Linux

- release-mode Flutter desktop bundle compressed as a tar archive;
- Debian `.deb` installation package produced by `tool/build_linux_deb.sh`;
- structural verification of package control data, executable payload, desktop entry, AppStream metadata, deterministic SonicNest icon, and package checksum through `tool/verify_linux_deb.sh`;
- SHA-256 checksums for the candidate tar archive and `.deb`;
- explicit warning that release-candidate output is not yet approved for public distribution.

Debian `.deb` is the initial repository-supported Linux package target. Real-machine microphone/routing tests, accessibility review, long-duration/low-storage tests, representative package install/upgrade/uninstall testing, and desktop icon visual inspection remain separate release gates.

### Windows

- release-mode Flutter Windows runner bundle packaged as the repository-selected versioned x64 portable ZIP through `tool/build_windows_portable.ps1`;
- complete bundle checks for `sonic_nest.exe`, `flutter_windows.dll`, ICU data, and Flutter assets;
- isolated ZIP extraction and package-layout verification through `tool/verify_windows_portable.ps1`;
- bounded extracted-package startup smoke through `tool/smoke_test_windows_portable.ps1`;
- common private/signing-material rejection inside the validation archive;
- SHA-256 checksum and package-info record;
- explicit unsigned/non-publication warning.

The portable ZIP package format and initial GitHub Releases channel are repository decisions. What remains open is the maintainer-owned Authenticode credential/protected-signing process and real-system Windows evidence. A final stable public ZIP must contain the final signed binaries, pass `tool/verify_windows_portable.ps1 -RequireSignature`, pass the bounded package startup smoke, and use a SHA-256 generated after signing/package bytes are final. The hosted unsigned ZIP must never be relabeled as signed or stable.

### macOS

- release-mode `.app` bundle archived as ZIP;
- SHA-256 checksum;
- explicit non-public signing/notarization warning.

Public distribution still requires the maintainer's Apple Developer ID signing and notarization process plus real-hardware QA. See `docs/APPLE_DISTRIBUTION_POLICY.md`.

### iOS

- release-mode application bundle built with `--no-codesign` and archived for validation;
- SHA-256 checksum;
- explicit warning that it is not an installable App Store/TestFlight package.

An App Store/TestFlight candidate requires provisioning, signing, real-device testing, store metadata, privacy declarations, and the protected Apple distribution pipeline. See `docs/APPLE_DISTRIBUTION_POLICY.md`.

### Web

- release-mode static browser bundle produced by `flutter build web --release` through the shared default `lib/main.dart` entry point;
- generated site archived as `sonicnest-web-release.tar.gz`;
- `SHA256SUMS.txt` containing the exact archive digest;
- explicit development-preview warning describing the real-browser and production-hosting evidence boundary.

The Web candidate is not called “unsigned” in the same sense as a native executable. Its manifest classification records binary signing as not applicable to the static bundle. A successful Web artifact build/checksum proves compilation and byte identity only; it does not prove microphone permission/device behavior, capture/playback/share/download, accessibility, PWA behavior, browser cache/update behavior, TLS/DNS/hosting configuration, or public deployment approval. See `docs/WEB_SUPPORT.md` and `docs/WEB_QA_CHECKLIST.md`.

### Unified six-platform provenance manifest

After all **six** platform candidate jobs succeed, the workflow downloads those exact artifact sets into a final provenance job and runs `tool/build_release_candidate_manifest.py`.

The builder:

- re-verifies every platform payload against its platform `SHA256SUMS.txt`;
- requires Android, Linux, Windows, macOS, iOS, and Web evidence directories;
- requires Android's explicit `ANDROID_SIGNING_STATE.txt` non-production markers;
- binds the candidate evidence to the exact full Git source SHA and GitHub Actions run/attempt;
- records the application version from `pubspec.yaml`;
- records every downloaded evidence file with its SHA-256 and byte size;
- preserves platform-specific signing/distribution classifications, including Web's static-bundle signing classification;
- explicitly writes `stableReleaseApproved: false` for the hosted development-preview candidate.

The resulting `RELEASE_CANDIDATE_MANIFEST.json`, its own checksum file, and an explicit warning are uploaded as `sonicnest-release-candidate-manifest`. See `docs/RELEASE_CANDIDATE_MANIFEST.md` for the current six-platform provenance contract and historical five-platform evidence boundary.

## Historical evidence boundary

The hosted 2026-08-15 release-candidate/provenance evidence recorded elsewhere in the repository predates the 2026-08-20 Web target. Those runs remain valid only for their exact historical five-platform source revisions. They must not be described as proof that the current Web job, Web artifact, or six-platform manifest has passed hosted validation.

The current six-platform workflow requires fresh evidence from the exact current candidate before its configured Web/provenance paths are called validated.

## Artifact retention

The permanent manual workflow uses short-lived GitHub Actions artifacts. They exist to inspect release-mode packaging and should not be treated as a permanent download channel.

A stable native release should publish only artifacts produced from the final tested/tagged source revision in the maintainer's secure signing environment where signing is required. A stable Web release should deploy only the exact tested/tagged static bundle whose checksum/provenance and representative-browser/production-hosting evidence were reviewed.

## Checksum verification

Every workflow artifact directory includes `SHA256SUMS.txt`. Verify after downloading an artifact before comparing or transferring it into another validation environment.

Typical commands:

Linux/macOS:

```bash
sha256sum -c SHA256SUMS.txt
```

macOS systems without GNU `sha256sum` can compare with:

```bash
shasum -a 256 <artifact-file>
```

Windows PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 <artifact-file>
```

Compare the result with the checksum recorded alongside the artifact.

The Debian package builder also writes `<package>.deb.sha256` beside its direct build output under `build/linux-package/`; the package verifier compares that digest against the actual `.deb` bytes. The Windows portable builder writes the exact archive digest to `SHA256SUMS.txt`, and the Windows verifier checks that digest when the checksum file is present beside the archive. Android candidate verification writes the exact APK/AAB SHA-256 values into `ANDROID_SIGNING_STATE.txt` in addition to the candidate `SHA256SUMS.txt`. The Web candidate writes the exact `sonicnest-web-release.tar.gz` digest to its platform checksum file.

The unified provenance job re-verifies all six per-platform checksum records after GitHub Actions artifact download and then writes a checksum for the final JSON manifest itself. That second verification layer binds the downloaded evidence bytes to one source SHA/run; it does not change native production-signing state or convert a Web build into browser/hosting approval.

## What successful automation does not prove

A successful non-production release-candidate workflow does not complete any of these gates:

- native microphone hardware behavior;
- native background/interruption/routing behavior;
- low-storage recovery;
- long-duration/large-library stress testing;
- native or Web accessibility audits;
- native icon/splash or Web/PWA visual approval on real OS/browser surfaces;
- Linux `.deb` install/upgrade/uninstall quality on representative real systems;
- Windows portable extraction/launch/microphone/routing/accessibility/branding quality on representative real systems;
- Windows Authenticode production signing;
- Android Play upload-key/Play App Signing production identity;
- iOS App Store/TestFlight signing/provisioning;
- macOS Developer ID signing/notarization;
- Web microphone permission/input behavior on representative Chromium/Firefox/Safari families;
- Web long-session memory, share/download, PWA/installability, or cache-update behavior;
- Web production HTTPS, DNS/TLS, security-header, deployment, or rollback approval;
- store privacy/listing review;
- public distribution/deployment approval.

Those remain governed by `docs/QA_CHECKLIST.md`, `docs/WEB_QA_CHECKLIST.md`, `docs/RELEASING.md`, the platform distribution/signing policies, and reviewed release evidence.
