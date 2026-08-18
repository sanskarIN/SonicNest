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

`SettingsService` persists the complete settings state as one versioned JSON snapshot under `settings_snapshot_v1` rather than issuing independent writes for each preference. Existing legacy keys remain readable for migration and damaged-snapshot fallback, while new saves use the canonical snapshot.

This avoids a partially new settings state if a multi-key write sequence is interrupted or rejected partway through.

### Persisted integer integrity

`RecordingSettings.fromJson()` now accepts integer-only values only when the persisted number is finite and mathematically whole. Fractional bitrate, sample-rate, channel, and countdown values are rejected to the established safe fallback instead of being silently truncated through `toInt()`.

Regression coverage explicitly supplies fractional values for every affected integer-only field.

### Future settings-schema preservation

A canonical settings document carrying a recognizable integer schema version newer than this build is no longer treated as ordinary corruption. `UnsupportedSettingsSchemaException` stops loading so an older SonicNest build cannot silently reinterpret a future snapshot through legacy/default preferences and later overwrite it.

Malformed JSON and malformed/non-integer schema data retain the existing damaged-snapshot fallback behavior. This mirrors the forward-compatibility boundary already used by `MetadataStore`.

### Import cleanup failure isolation

If validation of a copied import fails and cleanup of the copied file also fails, `AudioImportService` still throws `AudioImportException` for the original selected source and records cleanup failure as additional diagnostic context. A cleanup exception can therefore no longer escape and unexpectedly replace the structured per-file import failure boundary.

### Generated extension validation

`StorageService` validates extension text before joining it into generated recording, Trash, or temporary paths. Safe alphanumeric extensions are lowercased after an optional leading dot is removed. Empty, separator-containing, traversal-shaped, or otherwise invalid extension values are rejected.

Regression coverage includes `../wav`, `txt/../../outside`, empty extension input, and `.PCM` normalization.

### Managed cleanup authority

Cleanup paths distinguish managed audio, managed temporary files, and recorder capture files instead of relying on an unrestricted arbitrary-path delete helper.

- `deleteManagedAudioIfExists` is restricted to supported regular audio inside managed Recordings/Trash storage.
- `deleteManagedTemporaryIfExists` accepts only regular filesystem entries inside the SonicNest temporary directory.
- `deleteManagedCaptureIfExists` accepts only regular supported-audio files inside the managed Recordings or temporary capture directories.
- A recorder backend returning an unexpected external path therefore cannot cause SonicNest cleanup to delete that external file.
- Recorder stop rejects a backend-returned output path that does not equal the exact capture destination SonicNest supplied.
- Recorder stop additionally requires the final output to be a regular managed recording before reporting success.
- Failed import cleanup uses the managed-recording delete boundary.
- Controller rollback cleanup for processed outputs, failed imported-entry persistence, and failed duplicate persistence uses the managed-recording delete boundary.
- Core and advanced FFmpeg output cleanup uses the managed-recording delete boundary.
- PCM waveform and concat-list cleanup uses the managed-temporary delete boundary.
- Temporary processor cleanup is best effort so a secondary filesystem cleanup error cannot replace a processing success/failure result.
- Symlinks/non-regular managed entries remain rejected rather than followed for destructive cleanup.
- After every application caller migrated to these intent-specific operations, the obsolete unrestricted `StorageService.deleteIfExists()` helper was removed from the service API.

Deterministic storage regressions cover managed temporary cleanup, external temporary-file preservation, active/temp capture cleanup, external capture preservation, unsupported temp capture rejection, and symlink refusal on supported hosts.

### Batch conversion cleanup isolation

A failed metadata registration after a successful conversion can require rollback deletion of the generated managed output. That cleanup is best effort. Any cleanup inspection/deletion failure is isolated to the failed batch item rather than aborting the entire conversion loop or replacing the original conversion/registration error.

A dedicated regression injects managed-cleanup failure, verifies the original first-item failure remains in `conversionFailures`, and verifies a later selected item is still processed successfully.

### Permanent workflow hygiene regression

A stale one-shot formatter/ledger workflow and its trigger marker remained tracked after their intended operation. The permanent repository audit already classified that state as invalid, so the temporary write-enabled workflow was removed rather than allowlisted or weakening the audit.

A Python regression locks both sides of this policy:

- the tracked `.github/workflows/*.yml|*.yaml` set must exactly match the permanent allowlist; and
- permanent workflows must not request `write-all` or any repository write scope prohibited by `repository_audit.py`.

### Open-source maintenance completion

The final repository pass added maintained review/issue/dependency/funding surfaces without changing product release status:

- `.github/CODEOWNERS` routes default review ownership to `@sanskarIN`;
- `.github/FUNDING.yml` exposes the optional Gumroad and Buy Me a Coffee destinations;
- `.github/ISSUE_TEMPLATE/config.yml` disables blank issues and directs security/support reports to the maintained guidance;
- `.github/dependabot.yml` requests weekly Dart/Flutter and GitHub Actions update proposals;
- `docs/OPEN_SOURCE_MAINTENANCE.md` documents contributor/maintainer expectations and the evidence boundary;
- `tool/tests/test_open_source_maintenance.py` protects these repository surfaces from silent removal or drift.

Dependency-update proposals remain subject to normal compatibility review and SonicNest quality gates.

## Pull-request integration and cleanup

### PR #1

- PR: `#1` — `Harden generated file extension boundaries`
- Base before PR: `529b4fb728e7c0b87b7571f0be288d11bb2f3aab`
- Reviewed head: `b24954a284fa043c95b9c385cef1193cdc57e129`
- Merge commit: `a9dc730eba9811103c7f7267431664cda522c66f`

The earlier pull-request validation work exposed formatter drift in continuation-touched files and preserved the permanent non-mutating formatter command as the repository authority.

### PR #2

PR `#2` contained a valid persisted-integer hardening patch but also obsolete temporary write-enabled formatter/ledger machinery against an older base. It was closed as **superseded**, and only its valid numeric parser/test behavior was integrated directly through focused `main` commits. The temporary workflow was deliberately not merged.

### PR #3 formatter diagnosis and final validation

PR `#3` was initially used to obtain the exact Flutter 3.47.0 formatter diff after local Flutter/Dart tooling was unavailable. The temporary diagnostic branch edit replaced the formatter step only on that validation branch. The permanent repository audit rejected that diagnostic edit because the required non-mutating formatter invariant was absent. The branch was then force-reset, removing the diagnostic workflow edit completely.

The diagnostic formatter output changed exactly three files on the examined merge snapshot:

- `test/audio_import_service_test.dart`
- `test/settings_service_test.dart`
- `test/storage_service_test.dart`

Those exact canonical changes were applied to `main` as focused commits. No analyzer/unit-test success is claimed from the intentional formatter-diff run because the job stopped after emitting the diff.

PR `#3` is now titled **Final SonicNest repository validation**. Its branch was reset to current `main` and contains only the permanent `tool/tests/test_final_repository_contract.py` addition. The branch contains no temporary write-enabled workflow.

## Focused continuation commits

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
- `342fb74f69904f96382fae4b3ad9525609e8650e` — `refactor: remove unrestricted storage delete helper`
- `0099b692df0eb41276ff48dc58a1fecbd4e11b33` — `fix: reject fractional persisted integer settings`
- `48d580c932c3eb3699ff088a90299e5601ef6fae` — `test: cover fractional persisted integer rejection`
- `a9f0098f4855d9758482ad40e64a7fb974ee78c2` — `fix: preserve unsupported future settings snapshots`
- `7caa6582debaccfcac52f816d84738dc684ac057` — `test: protect unsupported future settings schema`
- `aadfca9e03d9569c7d2141a987cc59e25c21a297` — `chore: add repository code ownership`
- `796984b895eb7c90b3fc0e6ad3878faa4da34710` — `chore: add project funding links`
- `99fa814bbc594a6fccdaf7980f6d9b966f60b8d4` — `chore: route support and security issues`
- `eb340c513e212743a3d2163b4716561df9f5c03a` — `chore: add weekly dependency update checks`
- `eb86197e27e30621af109c379aaffb10ec812982` — `docs: add open source maintenance guide`
- `fe9ffec0abba6e28c68f6340b3b8bbb80bea61a1` — `test: lock open source maintenance surfaces`
- `b54bc6a78856fa04565d274c9df5e8aba0f7df73` — `docs: add final repository completion audit`

## Validation evidence and boundary

Diagnostic PR `#3` evidence retrieved before the clean reset:

- Repository Integrity Audit run `32138198587`: **failed as designed** because the temporary diagnostic branch edit removed the required `dart format --output=none --set-exit-if-changed` invariant.
- Flutter CI run `32138198565`, analyze/test job `95714489892`: formatter diagnostic completed and emitted the exact three-file diff above; analyzer and unit tests were skipped after the intentional diff failure.

Final clean PR `#3` validation head initially triggered as `80af1c225d1a7a40191cbf2f7233866128b7a174`, with maintained read-only Flutter CI, Repository Integrity Audit, Windows Build, and Apple Builds. This document does not pre-claim those runs while they are queued/running; exact completed results belong in `docs/FINAL_REPOSITORY_AUDIT_2026-08-18.md` and the final continuation ledger after retrieval.

## Final repository audit

See `FINAL_REPOSITORY_AUDIT_2026-08-18.md` for the final repository-owned source/tooling/open-source/documentation audit and the exact distinction between repository completion and still-open real-system/protected-release evidence.

## Release boundary

SonicNest remains a **development preview**. Manual/credential-dependent gates remain open, including physical microphone permission/capture/routing, wired/USB/Bluetooth behavior, interruption/background/lock-screen/media buttons, real low-storage/permission/process/power-loss recovery, representative malformed/partial/damaged media, long-duration and large-library performance, accessibility audits, native visual review/screenshots, representative Linux/Windows package QA, Android/Apple/Windows protected signing, Apple notarization/store validation, additional-locale review, and final stable-release approval.
