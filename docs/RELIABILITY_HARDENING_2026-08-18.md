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
- Failed import cleanup now uses the managed-recording delete boundary.
- Core and advanced FFmpeg output cleanup uses the managed-recording delete boundary.
- PCM waveform and concat-list cleanup uses the managed-temporary delete boundary.
- Symlinks/non-regular managed entries remain rejected rather than followed for destructive cleanup.

Deterministic storage regressions cover managed temporary cleanup, external temporary-file preservation, active/temp capture cleanup, external capture preservation, unsupported temp capture rejection, and symlink refusal on supported hosts.

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

The initial PR validation correctly detected Dart-format drift in five continuation-touched files. Hosted canonical formatting was applied in focused commits. The temporary diagnostic CI edit was then reverted completely; the final PR contains no workflow change, and the permanent non-mutating formatter command remains authoritative.

At merge time the final restored-head workflow matrix was still queued. It is therefore not represented here as successful unless/until GitHub records completion evidence.

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

## Validation boundary

The repository pushes above trigger the maintained read-only validation workflows. This note does not pre-claim a formatter, analyzer, unit-test, or platform-build result that has not been retrieved as completed GitHub evidence.

## Release boundary

SonicNest remains a **development preview**. Manual/credential-dependent gates remain open, including physical microphone permission/capture/routing, wired/USB/Bluetooth behavior, interruption/background/lock-screen/media buttons, real low-storage/permission/process/power-loss recovery, representative malformed/partial/damaged media, long-duration and large-library performance, accessibility audits, native visual review/screenshots, representative Linux/Windows package QA, Android/Apple/Windows protected signing, Apple notarization/store validation, and final stable-release approval.
