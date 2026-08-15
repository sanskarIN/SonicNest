# Release Candidate Provenance Manifest

SonicNest uses a machine-readable provenance manifest to bind one hosted cross-platform release-candidate run to the exact Git source revision and to the checksummed platform artifacts produced by that run.

This manifest is **validation evidence**, not stable-release approval. It never upgrades unsigned, no-codesign, Android Debug-signed, development-preview, or otherwise non-production artifacts into public production releases.

## Builder

The manifest is produced by:

```bash
python3 tool/build_release_candidate_manifest.py \
  --artifact android=<android-artifact-directory> \
  --artifact linux=<linux-artifact-directory> \
  --artifact windows=<windows-artifact-directory> \
  --artifact macos=<macos-artifact-directory> \
  --artifact ios=<ios-artifact-directory> \
  --source-sha <40-character-git-sha> \
  --workflow-run-id <github-actions-run-id> \
  --workflow-run-attempt <attempt-number> \
  --output RELEASE_CANDIDATE_MANIFEST.json
```

The builder uses only the Python standard library.

## Required platform evidence

Every platform artifact directory must contain `RELEASE_CANDIDATE_WARNING.txt` and `SHA256SUMS.txt`.

Android must also contain `ANDROID_SIGNING_STATE.txt`, including the expected package identity and the explicit `Android Debug certificate / NON-PRODUCTION` classification.

The builder rejects a candidate when:

- any required platform directory is missing;
- a required evidence file is missing;
- a checksum line is malformed;
- a checksum entry escapes its artifact directory;
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
- platform-specific build/signing/distribution classifications;
- every file in each downloaded platform artifact directory;
- file size and SHA-256 for every recorded file;
- the platform payload checksums re-verified from each `SHA256SUMS.txt`.

The final manifest directory also contains its own `SHA256SUMS.txt` and a release-candidate warning before being uploaded as `sonicnest-release-candidate-manifest`.

## Automated regression coverage

`tool/tests/test_release_candidate_manifest.py` covers:

- successful five-platform manifest construction;
- tampered payload rejection;
- payload-without-checksum rejection;
- checksum path-traversal rejection;
- Android signing-state marker enforcement;
- missing-platform rejection;
- full Git SHA enforcement.

The permanent Repository Integrity Audit compiles Python helpers and runs these tests whenever Python release tooling or its test suite changes.

## Hosted integration validation

The maintained release-candidate workflow downloads the five platform artifact sets only after all platform jobs succeed, re-verifies their payload checksum records through the builder, and then uploads the unified manifest as a separate short-retention artifact. Exact successful run evidence is recorded in the project state and continuation ledger after the hosted matrix completes.

## Evidence boundary

A green provenance-manifest job proves that the hosted artifacts downloaded by that job match their per-platform checksum records and that the manifest binds those bytes to the recorded source SHA and workflow run.

It does **not** prove:

- physical microphone permission/capture/routing behavior;
- Bluetooth, wired, USB, interruption, background, lock-screen, or media-button behavior;
- real low-storage or permission-revocation recovery;
- long-duration or large-library performance;
- accessibility quality;
- real launcher/splash/desktop visual quality;
- Android Play production signing;
- Apple signing/provisioning/notarization;
- Windows Authenticode trust;
- store acceptance or final `v1.0.0` approval.

Those gates remain evidence-dependent and must stay unchecked until they are actually completed on the exact release candidate.