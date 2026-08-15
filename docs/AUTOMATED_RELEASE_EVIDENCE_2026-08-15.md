# SonicNest Automated Release Evidence — 2026-08-15

This record captures repository/hosted-runner evidence for the final automated release-candidate validation completed on 2026-08-15. It is intentionally narrower than stable-release approval: physical-device microphone/routing/interruption QA, accessibility, sustained workload tests, real-system package review, private signing/notarization, and store/release approval remain separate evidence gates.

## Candidate identity

- Repository: `sanskarIN/SonicNest`
- Branch: `main`
- Release-candidate source SHA: `048870ec8dc26a16e2451310460d3e03c9084dc7`
- Workflow: `Release Candidate Validation`
- Workflow run: `31873121457`
- Result: **SUCCESS**
- Application version represented by package metadata: `0.1.0`

The candidate SHA is the clean source revision after the one-shot dispatcher removed itself. Later documentation and repository-audit hardening commits do not change the candidate application/runtime code or the artifacts listed below.

## Source preflight

The `Source preflight` job completed successfully for the same candidate SHA, including:

- platform-independent release preflight;
- non-mutating Dart formatting check;
- Flutter static analysis;
- complete unit-test suite.

## Android release-mode non-production evidence

Job: `Android release-mode non-production artifacts` — **SUCCESS**.

The hosted candidate intentionally uses the generated Android Debug certificate and is therefore **NON-PRODUCTION**. It is not a Google Play production/upload candidate.

Package identity/signing report:

- Package: `io.github.sanskarin.sonic_nest`
- Application label: `SonicNest`
- Certificate DN: `C=US, O=Android, CN=Android Debug`
- Certificate SHA-256: `ccbfe6b04e1859cf9064c9e5a2c8f9fe1d73be92e6ef1454142b9d2fbfff89e1`
- Certificate SHA-1: `fc13d257c05e8fcb704723cec1bd9aa6d5663e29`
- APK SHA-256: `1fe7ea48d771209f4bfea097fc7d9e723cff00411b2541ee848e7ec20d6c271e`
- AAB SHA-256: `ecaf9842980b17af06f3b3f90898d286a3b38ebf0b15259271af2f07dab72f4f`
- Workflow artifact digest: `sha256:05581adf264aa0c425edc27afbd9ae174a219599c460bc94ea8400e3c70929f7`

Files produced inside the workflow artifact:

- `sonicnest-android-release-nonproduction.apk`
- `sonicnest-android-release-nonproduction.aab`
- `ANDROID_SIGNING_STATE.txt`
- `SHA256SUMS.txt`
- `RELEASE_CANDIDATE_WARNING.txt`

The verification step used Android package/signature tooling to confirm package identity and the Debug-certificate/non-production classification before artifact upload.

## Linux release-mode evidence

Job: `Linux release-mode artifacts` — **SUCCESS**.

- Raw release bundle archive SHA-256: `a5fe64b440bf19b1b8a74e5a5ff875e645c2da7661bd8492e1a910160de179f8`
- Debian package: `sonicnest_0.1.0_amd64.deb`
- Debian package SHA-256: `414f11ad877c7c51861a14817cd3900d2bb77d3b49ea949d601e3686d5346498`
- Workflow artifact digest: `sha256:8e129ff08c559ec684d78d509c5311281f2239f58ba6d9b4954fd0d9e34c84ab`

The job completed Flutter Linux release compilation, Debian package construction, repository structural verification, checksum generation, and artifact upload. Representative real-system microphone/routing/accessibility/upgrade/desktop evidence remains separate.

## Windows release-mode portable evidence

Job: `Windows release-mode artifact` — **SUCCESS**.

- Package format: versioned x64 portable ZIP
- Package: `sonicnest-windows-x64-v0.1.0-portable-unsigned.zip`
- Portable ZIP SHA-256: `60f5680548b0352d5230b6d40acc17a8b8b12d075b2ce1fd08c6209f565e3eb1`
- Workflow artifact digest: `sha256:895f74a0decba44ddd104bd2eb148fda059be656fd2edff0cb9f77cfe296c271`

The job completed:

- Flutter Windows release compilation;
- portable ZIP construction from the complete Flutter runner bundle;
- structural package verification;
- bounded extracted-package startup smoke;
- checksum/package-info generation;
- explicit unsigned/development warning;
- artifact upload.

The hosted portable is unsigned. Final public Windows distribution still requires maintainer-owned Authenticode signing and verification on the exact packaged binaries, plus representative real-system recorder/accessibility/visual QA.

## macOS release-mode evidence

Job: `macOS release-mode artifact` — **SUCCESS**.

- Archive: `sonicnest-macos-release-unsigned.zip`
- Archive SHA-256: `364c0d8f84c2779c45a36e13fd59d6bbcceebe03f62662a41dc4e2f9178d4af3`
- Workflow artifact digest: `sha256:c7972d5fb532bd253be3503f1596212c96767279778716bc2301dc95e517e4e3`

The hosted artifact is not a notarized public macOS release. Apple signing/notarization and real-hardware QA remain protected/manual release work.

## iOS release-mode no-codesign evidence

Job: `iOS no-codesign release-mode artifact` — **SUCCESS**.

- Archive: `sonicnest-ios-release-unsigned.zip`
- Archive SHA-256: `8d1209b94aa1aaff4369dff041ace9698bf4dcd5e0e6363a0fd470c50ee2e54d`
- Workflow artifact digest: `sha256:c9a61440a727202ac763a927b79486120a85d4674e919d4f255f67fe5cd497ea`

The archive is an unsigned/no-codesign validation artifact and is not an installable App Store package. Provisioning, protected signing, TestFlight/App Store validation, physical-device QA, and accessibility remain separate gates.

## Permanent Windows package CI evidence

Permanent Windows Build run `31872928500` also completed successfully before the final candidate run. Its release portable-package job independently passed:

- Windows release build;
- portable package construction;
- structural verification;
- extracted-package startup smoke;
- warning/checksum metadata generation;
- artifact upload.

This independent permanent-workflow result verifies that the Windows package/startup path is not dependent on the manual release-candidate workflow.

## Repository integrity evidence

- Repository Integrity Audit run `31873122160` passed on candidate SHA `048870ec8dc26a16e2451310460d3e03c9084dc7` after the dispatcher self-removal.
- Repository Integrity Audit run `31874506476` passed on later audit-hardening commit `64c121fa0e5c81531a3710b1d67b88fb3dfc93db`.
- The later audit hardening recognizes both `.yml` and `.yaml` workflow files and rejects permanent workflow write scopes including `permissions: write-all`.

## Release boundary

This automated record does **not** complete or imply any of the following:

- physical microphone permission, capture, input-routing, interruption, background, lock-screen, Bluetooth/headset, or media-button validation;
- real low-storage, filesystem-permission, abrupt process/device/power-loss, malformed-media, or partially written-media evidence;
- 30-minute/multi-hour recording soak tests;
- real large-library or large-batch performance profiling;
- TalkBack, VoiceOver, Narrator, Linux accessibility-tool, large-text, or keyboard-only audits;
- real native icon/splash/desktop visual inspection or production screenshots;
- representative Debian/Ubuntu install/upgrade/audio/desktop review;
- Android protected upload-key/Play App Signing production candidate;
- Apple provisioning/signing/notarization/App Store Connect completion;
- Windows Authenticode signing;
- stable-release approval or `v1.0.0` tagging.

SonicNest therefore remains a **development preview** until the evidence-dependent gates in `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md` are completed for the exact public release source/artifacts.