# Release Candidate Provenance Manifest

SonicNest uses a machine-readable provenance manifest to bind one hosted cross-platform release-candidate run to the exact Git source revision and to the checksummed platform artifacts produced by that run.

The current maintained contract covers **Android, Linux, Windows, macOS, iOS, and Web**.

This manifest is **validation evidence**, not stable-release approval. It never upgrades unsigned, no-codesign, Android Debug-signed, browser-build, development-preview, or otherwise non-production artifacts into public production releases.

## Builder

The manifest is produced by:

```bash
python3 tool/build_release_candidate_manifest.py \
  --artifact android=<android-artifact-directory> \
  --artifact linux=<linux-artifact-directory> \
  --artifact windows=<windows-artifact-directory> \
  --artifact macos=<macos-artifact-directory> \
  --artifact ios=<ios-artifact-directory> \
  --artifact web=<web-artifact-directory> \
  --source-sha <40-character-git-sha> \
  --workflow-run-id <github-actions-run-id> \
  --workflow-run-attempt <attempt-number> \
  --output RELEASE_CANDIDATE_MANIFEST.json
```

The builder uses only the Python standard library.

## Required platform evidence

Every one of the six platform artifact directories must contain `RELEASE_CANDIDATE_WARNING.txt` and `SHA256SUMS.txt`.

Android must also contain `ANDROID_SIGNING_STATE.txt`, including the expected package identity and the explicit `Android Debug certificate / NON-PRODUCTION` classification.

The Web artifact directory contains the checksummed `sonicnest-web-release.tar.gz` static release bundle produced from `flutter build web --release`. Its classification explicitly records that binary signing is not applicable to the static Web bundle and that the artifact remains development-preview validation evidence.

Candidate evidence must consist of ordinary files/directories. The builder refuses a platform artifact directory that is itself a symbolic link and refuses any symbolic link found anywhere inside a platform artifact tree. This prevents provenance hashing from following a link to bytes outside the downloaded candidate directory, even when a checksum entry would otherwise match the linked target.

Checksum identities are normalized before verification: Windows-style separators are converted to `/`, relative path syntax is normalized by `pathlib`, and two checksum entries that collapse to the same normalized path are rejected. A candidate therefore cannot represent one payload twice through aliases such as `payload.zip` and `./payload.zip` or separator variants.

The builder rejects a candidate when:

- any required platform directory is missing, including Web;
- a platform artifact directory or any contained evidence/payload path is a symbolic link;
- a required evidence file is missing;
- a checksum line is malformed;
- a checksum entry escapes its artifact directory;
- two checksum entries normalize to the same artifact-relative path;
- a checksummed file is missing or has different bytes;
- a release payload exists without a matching entry in `SHA256SUMS.txt`;
- the Android signing-state report does not contain the required non-production markers;
- the source SHA is not a full 40-character Git commit SHA;
- workflow run identifiers are invalid.

## Manifest contents

The generated JSON records:

- schema version;
- SonicNest application version from `pubspec.yaml`;
- exact source Git SHA;
- GitHub Actions workflow run ID and attempt;
- development-preview release classification;
- an explicit `stableReleaseApproved: false` marker;
- platform-specific build/signing/distribution classifications for all six targets;
- every file in each downloaded platform artifact directory;
- file size and SHA-256 for every recorded file;
- the platform payload checksums re-verified from each `SHA256SUMS.txt`.

The final manifest directory also contains its own `SHA256SUMS.txt` and a release-candidate warning before being uploaded as `sonicnest-release-candidate-manifest`.

## Automated regression coverage

`tool/tests/test_release_candidate_manifest.py` covers:

- successful six-platform manifest construction;
- Web classification and browser-payload inclusion;
- native and Web tampered-payload rejection;
- payload-without-checksum rejection;
- checksum path-traversal rejection;
- duplicate normalized checksum-path rejection for dot-path and separator aliases;
- symlinked payload rejection even when its target checksum matches;
- symlinked required-metadata rejection;
- Android signing-state marker enforcement;
- missing-platform rejection;
- full Git SHA enforcement.

`tool/tests/test_release_candidate_integration.py` locks the maintained workflow integration, all six platform artifact arguments, Web release packaging, exact source/run binding, final manifest publication, and permanent Repository Integrity Audit execution of the Python release-tool suite.

## Current maintained workflow

The maintained release-candidate workflow waits for Android, Linux, Windows, macOS, iOS, and Web candidate jobs. It then downloads the six platform artifact sets, re-verifies their payload checksum records through the builder, and uploads one unified provenance manifest as a separate short-retention artifact.

The Web job:

1. enables Flutter Web;
2. regenerates the six platform hosts;
3. resolves dependencies and applies SonicNest branding;
4. builds `flutter build web --release` through the normal shared entry point;
5. archives the generated static site as `sonicnest-web-release.tar.gz`;
6. writes an explicit development-preview/browser-QA warning;
7. writes and later re-verifies the payload SHA-256.

A successful hosted Web build proves that the browser bundle compiled and that the archived bytes match their checksum. It does not prove microphone or browser-policy behavior on real browsers.

## Historical hosted integration evidence

The exact hosted evidence below predates Web release-candidate integration and therefore remains **five-platform historical evidence only**. It must not be read as validation of the current six-platform source revision.

Repository Integrity Audit run `31876149473` passed Python helper compilation, repository invariants, **10/10** Python release-tool tests, Bash helper parsing, and PowerShell helper parsing for its historical source revision.

Historical Release Candidate Validation evidence:

- source SHA: `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c`;
- Release Candidate Validation run: `31876035202`;
- run attempt: `1`;
- Source preflight: **SUCCESS**;
- Android release-mode non-production job: **SUCCESS**;
- Linux release-mode job: **SUCCESS**;
- Windows release portable build/verify/startup-smoke job: **SUCCESS**;
- macOS release-mode job: **SUCCESS**;
- iOS release-mode no-codesign job: **SUCCESS**;
- Unified candidate provenance manifest job: **SUCCESS**.

That historical run did **not** contain the current Web candidate job or Web manifest entry. The generated historical manifest records application version `0.1.0+1`, `releaseClassification: development-preview`, and `stableReleaseApproved: false`.

Historical manifest evidence:

- `RELEASE_CANDIDATE_MANIFEST.json` SHA-256: `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`;
- independent post-download recomputation: `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`;
- manifest workflow artifact digest: `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`.

The narrow push trigger used solely to obtain that historical evidence was removed after validation. The maintained release-candidate workflow remains manual `workflow_dispatch` only.

The full exact historical platform payload hashes and workflow artifact digests are preserved in `AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md` and the additive `../what_changed.md` continuation ledger. The current six-platform revision requires its own hosted validation evidence and does not inherit the older run automatically.

## Evidence boundary

A green current provenance-manifest job proves that the hosted artifacts downloaded by that job match their per-platform checksum records and that the manifest binds those bytes to the recorded source SHA and workflow run.

It does **not** prove:

- physical microphone permission/capture/routing behavior;
- Bluetooth, wired, USB, interruption, background, lock-screen, or media-button behavior;
- browser microphone permission prompts, device enumeration, capture/playback quality, or browser policy behavior;
- Web share/download behavior on every browser;
- Web responsive-layout, accessibility, PWA installation, cache, hosting, TLS, DNS, or deployment behavior;
- real low-storage or permission-revocation recovery;
- long-duration or large-library performance;
- accessibility quality;
- real launcher/splash/desktop/browser visual quality;
- Android Play production signing;
- Apple signing/provisioning/notarization;
- Windows Authenticode trust;
- store acceptance, production hosting approval, or final stable-release approval.

Those gates remain evidence-dependent and must stay unchecked until they are actually completed on the exact release candidate.
