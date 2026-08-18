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

### Managed cleanup authority

Cleanup paths now distinguish managed audio, managed temporary files, and recorder capture files instead of relying on an unrestricted file-delete helper.

- `deleteManagedTemporaryIfExists` accepts only regular filesystem entries inside the SonicNest temporary directory.
- `deleteManagedCaptureIfExists` accepts only regular supported-audio files inside the managed Recordings or temporary capture directories.
- A recorder backend returning an unexpected external path therefore cannot cause SonicNest cleanup to delete that external file.
- Recorder stop now rejects a backend-returned output path that does not equal the exact capture destination SonicNest supplied.
- Recorder stop additionally requires the final output to be a regular managed recording before reporting success.
- Failed import cleanup now uses the managed-recording delete boundary.
- Controller rollback cleanup for processed outputs, failed imported-entry persistence, and failed duplicate persistence uses the managed-recording delete boundary.
- Core and advanced FFmpeg output cleanup uses the managed-recording delete boundary.
- PCM waveform and concat-list cleanup uses the managed-temporary delete boundary.
- Temporary processor cleanup is best effort so a secondary filesystem cleanup error cannot replace a processing success/failure result.
- Symlinks/non-regular managed entries remain rejected rather than followed for destructive cleanup.

Deterministic storage regressions cover managed temporary cleanup, external temporary-file preservation, active/temp capture cleanup, external capture preservation, unsupported temp capture rejection, and symlink refusal on supported hosts.

### Batch conversion cleanup isolation

A failed metadata registration after a successful conversion can require rollback deletion of the generated managed output. That cleanup is now best effort. Any cleanup inspection/deletion failure is isolated to the failed batch item rather than aborting the entire conversion loop or replacing the original conversion/registration error.

A dedicated regression injects managed-cleanup failure, verifies the original first-item failure remains in `conversionFailures`, and verifies a later selected item is still processed successfully.

### Permanent workflow hygiene regression

A stale one-shot formatter/ledger workflow and its trigger marker remained tracked after their intended operation. The permanent repository audit already classified that state as invalid, so the temporary write-enabled workflow was removed rather than allowlisted or weakening the audit.

A Python regression now locks both sides of this policy:

- the tracked `.github/workflows/*.yml|*.yaml` set must exactly match the permanent allowlist; and
- permanent workflows must not request `write-all` or any repository write scope prohibited by `repository_audit.py`.

## Pull-request integration

- PR: `#1` — `Harden generated file extension boundaries`
- Base before PR: `529b4fb728e7c0b87b7571f0be288d11bb2f3aab`
- Reviewed head: `b24954a284fa043c95b9c385cef1193cdc57e129`
- Merge commit: `a9dc730eba9811103c7f7267431664cda522c66f`

The earlier pull-request validation work exposed formatter drift in continuation-touched files and preserved the permanent non-mutating formatter command as the repository authority.

A later PR `#3` validation pass was deliberately used to obtain the exact Flutter 3.47.0 formatter diff after local Flutter/Dart tooling was unavailable. The temporary diagnostic branch edit replaced the formatter step only on that validation branch. The permanent repository audit rejected that edit because the required non-mutating formatter invariant was absent. The diagnostic branch was then force-reset to current `main`, removing that workflow edit completely before clean validation.

The diagnostic formatter output changed exactly three files on the examined merge snapshot:

- `test/audio_import_service_test.dart`
- `test/settings_service_test.dart`
- `test/storage_service_test.dart`

Those exact canonical changes were applied to `main` as three focused commits. No successful analyzer/unit-test claim is made from that diagnostic run because its analyze/test job intentionally stopped after the formatting diff was emitted.

## Focused continuation commits after PR integration

- `d48176428ef05f797b3df23c01abfea1c90e0e33` — `ci: remove stale hosted formatter sync workflow`
- `b7118493736c2b321f38c4d2f72d5ee817b42ea8` — `chore: remove stale formatter sync trigger`
- `a03efb87adb14539cece2d384c6bcda1252cd024` — `test: lock permanent workflow allowlist and read-only scopes`
- `89c72d310570ff9098ba9f94a917b2166aac36d4` — `fix: guard recorder and temporary cleanup paths`
- `87e8facec30f46dc97ac255115f2707aa446c13a` — `test: cover guarded capture and temporary cleanup`
- `e4d388bcdbe1618860648d54101ff7744b50f17a` — `fix: restrict recorder cleanup to managed capture files`
- `0e147452adf8d671027a4e12771422c860cec53d` — `fix: guard failed import cleanup inside managed storage`
- `cb071eab08fe116081a374e1ba674adad9c026f8` — `test: align import cleanup fake with managed delete boundary`
- `3a1b1bddac7e26e09ec28a532a3b40b362949ea9` — `fix: keep audio processing cleanup inside managed storage`
- `2e5af811b49963f6189c0475d096ea78f0e0bbbc` — `fix: guard advanced processor cleanup outputs`
- `b06f93ebcc81f49c989caf0f9cb1f8cc20788537` — `fix: use managed deletion for controller rollback cleanup`
- `89d58fc8b3f00fd6e1ba691c90b636a9f3176335` — `fix: reject unexpected recorder output paths`
- `d645b63b2e04a22a91d4b79bc729e552e552fa65` — `fix: keep temporary cleanup best effort during processing`
- `3b0623eb422dbb6244dadcff772c77117730d358` — `fix: isolate batch rollback cleanup failures`
- `004355895ae39756c5e0e6154d73b742b8a09f7a` — `test: cover isolated batch cleanup failure`
- `6d533089973ee11bb46dd3ca555bca0ff203e6f9` — `fix: preserve batch failure across any cleanup error`
- `dedfc691c16b317878d6ee27a1b63970289d3e21` — `style: apply canonical import test formatting`
- `5c3a5f229755cd40a5964e7ebe3239e99f39861a` — `style: apply canonical settings test formatting`
- `ee4e5f374b856cd8736a3ef7d1c63a4c91302583` — `style: apply canonical storage test formatting`

## Validation evidence and boundary

Diagnostic PR `#3` evidence retrieved before the clean reset:

- Repository Integrity Audit run `32138198587`: **failed as designed** because the temporary diagnostic branch edit removed the required `dart format --output=none --set-exit-if-changed` invariant.
- Flutter CI run `32138198565`, analyze/test job `95714489892`: formatter diagnostic completed and emitted the exact three-file diff above; analyzer and unit tests were skipped after the intentional diff failure.

After the diagnostic branch was reset to canonical `main`, PR `#3` was reopened with only the focused `test/managed_cleanup_regression_test.dart` addition. Its maintained read-only workflows are the final validation path. This note does not pre-claim their success while they remain queued/running.

## Release boundary

SonicNest remains a **development preview**. Manual/credential-dependent gates remain open, including physical microphone permission/capture/routing, wired/USB/Bluetooth behavior, interruption/background/lock-screen/media buttons, real low-storage/permission/process/power-loss recovery, representative malformed/partial/damaged media, long-duration and large-library performance, accessibility audits, native visual review/screenshots, representative Linux/Windows package QA, Android/Apple/Windows protected signing, Apple notarization/store validation, and final stable-release approval.
