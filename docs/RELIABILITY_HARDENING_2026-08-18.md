# SonicNest Reliability Hardening — 2026-08-18

This note records repository-owned reliability work completed after the existing cross-platform release-automation baseline. It does not replace any physical-device, accessibility, stress, protected-signing, notarization, store-console, or stable-release evidence gate.

## Integrated reliability changes

### Cross-platform filename safety

- Sanitize caller-provided fallback names as well as normal recording titles.
- Protect Windows reserved device names even when they have suffix components such as `CON.notes`, `COM1.session`, and `LPT9.archive`.
- Truncate by Unicode code point rather than UTF-16 position.
- Bound sanitized stems to 120 Unicode code points and 220 UTF-8 bytes, leaving headroom for extensions and collision suffixes.
- Preserve multilingual/emoji titles when they are already within the safe bound.

### Coherent settings snapshot

`SettingsService` now persists the complete settings state as one versioned JSON snapshot under `settings_snapshot_v1` rather than issuing independent writes for each preference. Existing legacy keys remain readable for migration and corruption fallback, but new saves use the canonical snapshot.

This avoids a partially new settings state if a multi-key write sequence is interrupted or rejected partway through.

### Import cleanup failure isolation

If validation of a copied import fails and cleanup of the copied file also fails, `AudioImportService` still throws `AudioImportException` for the original selected source and records cleanup failure as additional diagnostic context. A cleanup exception can therefore no longer escape and unexpectedly replace the structured per-file import failure boundary.

### Generated extension validation

`StorageService` now validates extension text before joining it into generated recording, Trash, or temporary paths. Safe alphanumeric extensions are lowercased after an optional leading dot is removed. Empty, separator-containing, traversal-shaped, or otherwise invalid extension values are rejected.

Regression coverage includes `../wav`, `txt/../../outside`, empty extension input, and `.PCM` normalization.

## Pull-request integration

- PR: `#1` — `Harden generated file extension boundaries`
- Base before PR: `529b4fb728e7c0b87b7571f0be288d11bb2f3aab`
- Reviewed head: `b24954a284fa043c95b9c385cef1193cdc57e129`
- Merge commit: `a9dc730eba9811103c7f7267431664cda522c66f`

The initial PR validation correctly detected Dart-format drift in five continuation-touched files. Hosted canonical formatting was applied in focused commits. The temporary diagnostic CI edit was then reverted completely; the final PR contains no workflow change, and the permanent non-mutating formatter command remains authoritative.

At merge time the final restored-head workflow matrix was still queued. It is therefore not represented here as successful unless/until GitHub records completion evidence.

## Release boundary

SonicNest remains a **development preview**. Manual/credential-dependent gates remain open, including physical microphone permission/capture/routing, wired/USB/Bluetooth behavior, interruption/background/lock-screen/media buttons, real low-storage/permission/process/power-loss recovery, representative malformed/partial/damaged media, long-duration and large-library performance, accessibility audits, native visual review/screenshots, representative Linux/Windows package QA, Android/Apple/Windows protected signing, Apple notarization/store validation, and final stable-release approval.

## Validation update — 2026-08-18

The restored-head PR #1 matrix completed successfully for Repository Integrity Audit, Linux package CI, Windows build/package CI, Apple iOS/macOS builds, and the Flutter Linux debug build. Flutter analyze/test stopped at the committed-format gate because hosted Flutter stable 3.47.0 found only `test/audio_import_service_test.dart` and `test/settings_service_test.dart` still non-canonical. PR #2 applies the hosted stable formatter exactly, adds persisted numeric-integrity hardening, and restores the permanent non-mutating formatting workflow before final validation.

## PR #2 permanent-workflow validation trigger

The hosted formatter/ledger synchronization commit restored the permanent read-only CI workflow and removed its temporary helper files. Because that synchronization commit was pushed by GitHub Actions using `GITHUB_TOKEN`, its automatically created pull-request workflow runs required approval instead of executing. This repository-authored documentation commit intentionally retriggers PR #2 from the same clean source state under the permanent workflow contract; validation results are recorded only from the resulting executable run set.