#!/usr/bin/env bash
set -euo pipefail

marker='# Continuation — 2026-08-18 — Reliability and persistence hardening'
if ! grep -Fq "$marker" what_changed.md; then
  cat >> what_changed.md <<'EOF'

# Continuation — 2026-08-18 — Reliability and persistence hardening

## Repository-owned work completed

- Hardened recording filenames across filesystems: sanitized fallback names, protected Windows reserved device names including suffixed forms, preserved Unicode code points, and bounded stems to 120 code points / 220 UTF-8 bytes.
- Replaced independent settings writes with one versioned `settings_snapshot_v1` JSON snapshot while retaining legacy keys as read-only migration/corruption fallback.
- Added canonical-snapshot precedence, damaged-snapshot fallback, wrong-type fallback, roundtrip, and no-new-legacy-write regression coverage.
- Hardened persisted integer decoding so fractional bitrate, sample-rate, channel-count, and countdown values are rejected to established safe defaults instead of silently truncated. Valid whole-number clamping remains unchanged.
- Preserved `AudioImportException` as the primary per-file import error even when cleanup of an invalid copied import also fails; cleanup failure remains diagnostic context.
- Validated generated recording/Trash/temp extensions before path joining, rejecting empty, separator-containing, traversal-shaped, or otherwise unsafe extension text while normalizing safe extensions.
- Added regression coverage for filename safety, settings snapshots, fractional persisted integer fields, import double-failure isolation, path traversal-shaped extensions, collision allocation, and managed-storage boundaries.

## PR #1 validation evidence

Restored head `b24954a284fa043c95b9c385cef1193cdc57e129` produced:

- Repository Integrity Audit: success.
- Linux Package CI: success, including release bundle, Debian package creation/verification, metadata inspection, install, smoke test, uninstall, and artifact upload.
- Windows Build: success, including debug build, release portable package creation/verification, startup smoke test, and artifact upload.
- Apple Builds: success for iOS no-codesign debug and macOS debug.
- Flutter CI Linux debug build: success.
- Flutter analyze/test stopped only at the committed-format gate because hosted Flutter stable 3.47.0 found two continuation regression files still non-canonical. The permanent formatting gate was not weakened; PR #2 applies the exact hosted stable formatter output and restores the permanent CI workflow before its final validation pass.

## Integration history

- PR #1: `Harden generated file extension boundaries`.
- PR #1 reviewed head: `b24954a284fa043c95b9c385cef1193cdc57e129`.
- PR #1 merge commit: `a9dc730eba9811103c7f7267431664cda522c66f`.
- Follow-up PR #2 isolates persisted numeric-integrity hardening and exact hosted formatter correction. It is not treated as integrated until merged.

## Release boundary

SonicNest remains a **development preview**. Physical microphone/routing tests, wired/USB/Bluetooth behavior, interruption/background/lock-screen/media-button behavior, real low-storage/permission/process/power-loss recovery, representative damaged-media tests, long-duration/large-library performance, accessibility audits, native visual QA, representative target-system package QA, protected signing, Apple notarization/store-console validation, and final stable-release approval remain open.
EOF
fi

state_marker='## 2026-08-18 reliability hardening state'
if ! grep -Fq "$state_marker" PROJECT_STATE.md; then
  cat >> PROJECT_STATE.md <<'EOF'

## 2026-08-18 reliability hardening state

- PR #1 integrated generated-path and associated reliability hardening at `a9dc730eba9811103c7f7267431664cda522c66f`.
- Filenames now protect cross-platform reserved/length/Unicode boundaries.
- Settings use canonical versioned snapshot persistence with legacy read fallback.
- Fractional persisted integer fields are rejected instead of silently truncated.
- Import cleanup failure cannot replace the structured import failure boundary.
- Generated managed-path extensions are validated before path allocation.
- PR #1 passed repository integrity, Linux package, Windows build/package, Apple iOS/macOS build, and Flutter Linux debug-build evidence. Its analyze/test job stopped only at a two-file committed-format gate; PR #2 applies the exact hosted formatter output and restores the permanent gate.
- Release classification remains `development_preview_until_manual_release_gates_are_complete`; manual/credential-dependent release gates remain open.
EOF
fi

evidence_marker='## Validation update — 2026-08-18'
if ! grep -Fq "$evidence_marker" docs/RELIABILITY_HARDENING_2026-08-18.md; then
  cat >> docs/RELIABILITY_HARDENING_2026-08-18.md <<'EOF'

## Validation update — 2026-08-18

The restored-head PR #1 matrix completed successfully for Repository Integrity Audit, Linux package CI, Windows build/package CI, Apple iOS/macOS builds, and the Flutter Linux debug build. Flutter analyze/test stopped at the committed-format gate because hosted Flutter stable 3.47.0 found only `test/audio_import_service_test.dart` and `test/settings_service_test.dart` still non-canonical. PR #2 applies the hosted stable formatter exactly, adds persisted numeric-integrity hardening, and restores the permanent non-mutating formatting workflow before final validation.
EOF
fi

git checkout origin/main -- .github/workflows/ci.yml
git rm .github/workflows/temporary-pr-format-ledger-sync.yml
git rm tool/temporary_sync_reliability_ledgers.sh
git config user.name 'Sanskar'
git config user.email 'sanskarin@outlook.in'
git add -A
if ! git diff --cached --quiet; then
  git commit -m 'style: apply hosted formatter and sync reliability ledgers'
  git push origin "HEAD:${GITHUB_HEAD_REF}"
fi
