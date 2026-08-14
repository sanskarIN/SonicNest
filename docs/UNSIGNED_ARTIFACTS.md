# Unsigned Release-Candidate Artifacts

SonicNest includes `.github/workflows/release-candidate.yml` to exercise release-mode compilation and packaging without storing or using maintainer production signing credentials.

These artifacts are **validation outputs**, not public/store-ready releases.

## Why this workflow exists

Debug builds prove that source and platform hosts compile, but release mode can expose different optimization, linker, resource, packaging, and platform configuration problems. The release-candidate workflow provides a reproducible repository-only gate before the maintainer introduces private signing credentials in a secure environment.

## Source preflight

Every release-candidate run begins with source preflight:

- generate Flutter host projects from the selected stable SDK;
- resolve project dependencies;
- regenerate/apply SonicNest native branding;
- verify checked-in Dart formatting;
- run Flutter static analysis;
- run unit tests.

Equivalent local commands are available in:

- `tool/release_preflight.sh`
- `tool/release_preflight.ps1`

## Produced validation artifacts

### Android

- release-mode APK;
- release-mode Android App Bundle;
- SHA-256 checksums;
- explicit release-candidate warning text.

The repository does not provide maintainer production signing credentials. A release-mode artifact produced by this workflow must not be uploaded as a public production build merely because it compiled.

### Linux

- release-mode Flutter desktop bundle compressed as a tar archive;
- SHA-256 checksum;
- explicit warning that this is not a finalized Linux package.

A final Linux distribution target, desktop entry, package metadata, icon integration, and signing policy remain separate release decisions.

### Windows

- release-mode Windows runner bundle compressed as a ZIP archive;
- SHA-256 checksum;
- explicit unsigned/non-publication warning.

A final installer/package format and production code-signing policy remain release gates.

### macOS

- release-mode `.app` bundle archived as ZIP;
- SHA-256 checksum;
- explicit unsigned/not-notarized warning.

Public distribution still requires the maintainer's Apple signing and notarization process plus real-hardware QA.

### iOS

- release-mode application bundle built with `--no-codesign` and archived for validation;
- SHA-256 checksum;
- explicit warning that it is not an installable App Store package.

An App Store/TestFlight candidate requires provisioning, signing, real-device testing, store metadata, privacy declarations, and the normal Apple distribution pipeline.

## Artifact retention

The permanent manual workflow uses short-lived GitHub Actions artifacts. They exist to inspect release-mode packaging and should not be treated as a permanent download channel.

A stable release should publish only artifacts produced from the final tested/tagged source revision in the maintainer's secure signing environment, with checksums recorded in the corresponding release evidence record.

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

## What successful automation does not prove

A successful unsigned release-candidate workflow does not complete any of these gates:

- microphone hardware behavior;
- background/interruption/routing behavior;
- low-storage recovery;
- long-duration/large-library stress testing;
- accessibility audits;
- native icon/splash visual approval on real OS surfaces;
- production signing or notarization;
- installer/package quality;
- store privacy/listing review;
- public distribution approval.

Those remain governed by `docs/QA_CHECKLIST.md`, `docs/RELEASING.md`, and a completed copy of `docs/RELEASE_EVIDENCE_TEMPLATE.md`.
