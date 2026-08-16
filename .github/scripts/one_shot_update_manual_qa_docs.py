from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding="utf-8")


def insert_before_once(text: str, marker: str, block: str, unique: str) -> str:
    if unique in text:
        return text
    if marker not in text:
        raise RuntimeError(f"Missing marker: {marker}")
    return text.replace(marker, block + "\n\n" + marker, 1)


def insert_after_once(text: str, marker: str, block: str, unique: str) -> str:
    if unique in text:
        return text
    if marker not in text:
        raise RuntimeError(f"Missing marker: {marker}")
    return text.replace(marker, marker + "\n" + block, 1)


# QA checklist: explain the in-app evidence workflow without checking manual gates.
path = "docs/QA_CHECKLIST.md"
text = read(path)
qa_block = """## Manual evidence capture in the app

SonicNest now provides two complementary, user-initiated evidence surfaces:

- **About → Diagnostics & QA** captures privacy-safe runtime, aggregate Library/storage, recorder-state, and non-content settings context.
- From a collected Diagnostics report, **Open QA evidence with this snapshot** opens the manual evidence ledger while carrying that exact in-memory privacy-safe `DiagnosticReport` into the exported evidence bundle.
- **About → Manual QA evidence** opens the same status ledger without first collecting diagnostics.
- Each source-controlled manual check can be marked **Not run**, **Passed**, **Failed**, or **Blocked**. The local session stores only fixed check IDs, status values, and timestamps; it has no free-form tester-note field.
- Evidence can be copied as deterministic JSON or explicitly shared as Markdown. SonicNest never automatically uploads either evidence type.

An in-app status is supporting evidence entered by the tester, **not** an automated assertion and **not** an automatic release-gate closure. The unchecked hardware, storage, accessibility, package, signing, and distribution checks below remain unchecked until the corresponding real test has actually been performed and reviewed. See `docs/MANUAL_QA_EVIDENCE.md` and `docs/DIAGNOSTICS_AND_QA.md`."""
text = insert_before_once(text, "## Automated source checks", qa_block, "## Manual evidence capture in the app")
write(path, text)

# Releasing: make evidence collection part of the release procedure without weakening release approval.
path = "docs/RELEASING.md"
text = read(path)
release_block = """## In-app manual evidence ledger

For candidate QA, use **About → Manual QA evidence** to record the tester-reported state of the source-controlled manual checks. When runtime/storage/recorder/settings context matters, first open **About → Diagnostics & QA** and choose **Open QA evidence with this snapshot** so the current privacy-safe diagnostic report travels with the exported manual evidence bundle.

The ledger stores only fixed check IDs, `notRun`/`passed`/`failed`/`blocked` status values, and timestamps. It has no free-form tester-note field and does not automatically upload evidence. The exact candidate source/artifact, target hardware/OS, signing state, and any external observations still need to be identified in the release evidence record. A manually selected `Passed` status never overrides the required hardware, accessibility, filesystem, signing, notarization, store-console, or final approval gates."""
text = insert_before_once(text, "## 1. Prepare the source tree", release_block, "## In-app manual evidence ledger")
write(path, text)

# Diagnostics guide: document the now-reachable combined bundle path.
path = "docs/DIAGNOSTICS_AND_QA.md"
text = read(path)
needle = "The manual evidence workflow can export JSON or Markdown and is documented in `docs/MANUAL_QA_EVIDENCE.md`. Its export model can also carry an already collected `DiagnosticReport` when a caller explicitly supplies one; the normal About entry remains usable without collecting diagnostics first."
replacement = "After a Diagnostics report is collected, choose **Open QA evidence with this snapshot** to pass that exact in-memory privacy-safe `DiagnosticReport` into the manual evidence screen and its JSON/Markdown bundle. The normal **About → Manual QA evidence** entry remains available without collecting diagnostics first. The manual evidence workflow is documented in `docs/MANUAL_QA_EVIDENCE.md`."
if needle in text:
    text = text.replace(needle, replacement, 1)
elif replacement not in text:
    raise RuntimeError("Diagnostics companion paragraph marker changed")
write(path, text)

# CHANGELOG: add current milestone bullets to Unreleased sections.
path = "CHANGELOG.md"
text = read(path)
added = """- About-accessible Manual QA evidence sessions backed by a source-controlled release-check catalog, versioned local persistence, `Not run`/`Passed`/`Failed`/`Blocked` states, reset handling, and serialized status writes.
- Deterministic Manual QA evidence JSON/Markdown export with explicit privacy flags, complete current-catalog status coverage, stale-ID removal, immutable persisted check IDs, and no free-form tester-note field.
- Diagnostics-to-QA evidence navigation that explicitly carries the current privacy-safe diagnostic snapshot into the exported manual evidence bundle.
- Regression coverage for QA session serialization, persistence sanitization/reset, catalog integrity/stable IDs, localization completeness, export privacy, diagnostics attachment labels, and bootstrap analyzer-configuration preservation."""
text = insert_after_once(text, "### Added", added, "About-accessible Manual QA evidence sessions")
changed = """- Platform bootstrap now preserves the tracked `analysis_options.yaml` on Bash and PowerShell when `flutter create .` regenerates missing host folders.
- Core CI validates committed Dart formatting before generated platform-host state, preventing bootstrap-generated analyzer configuration from changing formatter behavior for tracked source.
- Manual QA evidence status persistence is serialized so simultaneous UI selections cannot race from the same previous session state."""
text = insert_after_once(text, "### Changed", changed, "Platform bootstrap now preserves the tracked `analysis_options.yaml`")
write(path, text)

# RELEASE_NOTES: append the milestone and its evidence boundary.
path = "RELEASE_NOTES.md"
text = read(path)
release_notes = """## 2026-08-16 — Manual QA evidence sessions

SonicNest now includes an About-accessible **Manual QA evidence** workflow for the remaining real-device/system release checks. The source-controlled catalog groups microphone/lifecycle, reliability/stress, desktop interaction, accessibility/UX, branding/package, and external-export evidence. Each check is recorded as `notRun`, `passed`, `failed`, or `blocked` with a UTC timestamp.

The versioned local session uses `sonicnest.qaEvidenceSession.v1`. Unknown/stale check IDs are discarded during load/save, the current catalog ID set is immutable at runtime, malformed/unsupported persisted sessions fall back to a fresh session, reset clears recorded statuses, and UI status writes are serialized so two selections cannot overwrite one another from the same previous state.

Evidence exports are deterministic JSON or user-shared Markdown. The bundle contains fixed check IDs/status/timestamps and explicit privacy flags; it does not collect free-form tester notes, recording content, recording titles, file paths, notes/tags/bookmarks, smart-naming text, or input-device names. **Diagnostics & QA → Open QA evidence with this snapshot** passes the current privacy-safe diagnostic report into the manual evidence bundle; **About → Manual QA evidence** remains usable without diagnostics. No evidence is automatically uploaded.

Validation of this milestone also exposed and fixed a repository bootstrap/CI invariant: `flutter create .` could rewrite tracked `analysis_options.yaml` before the permanent formatting gate, which changed Dart formatter behavior for unrelated tracked files. Bash and PowerShell bootstrap now preserve the tracked analyzer configuration, core CI validates committed formatting before generated host state, and regression tests lock both contracts.

Automated evidence: core Flutter CI run `31934843541` on source `0eb56abad482c8c296d9f80ef060ebddbba95e7b` passed committed-source formatting, static analysis, the complete unit suite, and Linux debug compilation; Android debug compilation is recorded separately in the authoritative state once the same run completes. Production UI revision `87c91697c9b11358e03334b3e642cbcb3959dc1c` passed Apple run `31934094160` (macOS and no-codesign iOS), Windows run `31934094196` (debug plus release portable package build/verify/startup smoke), and Linux Package CI run `31934094139` (release bundle, Debian package build/verify/install/startup smoke/uninstall).

These tools improve evidence quality; they do **not** close microphone/routing, interruption/background, low-storage/filesystem, sustained-performance, accessibility, representative package, signing/notarization, store-console, or stable-release gates by themselves."""
if "## 2026-08-16 — Manual QA evidence sessions" not in text:
    text = text.rstrip() + "\n\n" + release_notes + "\n"
write(path, text)

# PROJECT_STATE: insert milestone blocks and update the current core validation pointers.
path = "PROJECT_STATE.md"
text = read(path)
manual_block = """manual_qa_evidence:
  implementation_source_commit: 87c91697c9b11358e03334b3e642cbcb3959dc1c
  validated_core_source_commit: 0eb56abad482c8c296d9f80ef060ebddbba95e7b
  core_ci_run_id: 31934843541
  access:
    - About -> Manual QA evidence
    - Diagnostics & QA -> Open QA evidence with this snapshot
  storage_key: sonicnest.qaEvidenceSession.v1
  schema_version: 1
  statuses:
    - notRun
    - passed
    - failed
    - blocked
  serialized_status_writes: true
  immutable_current_catalog_ids: true
  stale_check_ids_dropped: true
  free_form_tester_notes: false
  automatic_upload: false
  diagnostic_snapshot_attachment: explicit_user_navigation_only
  exports:
    - deterministic JSON clipboard copy
    - privacy-safe Markdown share file
  release_gate_effect: supporting_evidence_only_no_manual_gate_closed
  documentation: docs/MANUAL_QA_EVIDENCE.md
platform_bootstrap_integrity:
  preserves_analysis_options_bash: true
  preserves_analysis_options_powershell: true
  committed_format_check_precedes_generated_host_bootstrap: true
  regression_test: test/bootstrap_integrity_test.dart"""
text = insert_before_once(text, "release_evidence_boundary:", manual_block, "manual_qa_evidence:")
# Preserve historical candidate/provenance blocks but move latest core pointers forward.
text = re.sub(r"  formatter_clean_source_commit: [0-9a-f]+", "  formatter_clean_source_commit: 0eb56abad482c8c296d9f80ef060ebddbba95e7b", text, count=1)
core_pattern = re.compile(r"  core_flutter_ci:\n(?:    .*\n)+?(?=  release_candidate:)")
core_replacement = """  core_flutter_ci:
    run_id: 31934843541
    source_commit: 0eb56abad482c8c296d9f80ef060ebddbba95e7b
    dart_format_check: success_non_mutating_committed_source_before_bootstrap
    analyzer: success_no_issues
    unit_tests: success_complete_suite
    android_debug_apk: pending_same_run_at_ledger_generation
    linux_debug_build: success
"""
text, count = core_pattern.subn(core_replacement, text, count=1)
if count != 1:
    raise RuntimeError("Could not replace latest core Flutter CI block")
write(path, text)

# what_changed.md is additive only. Append the complete continuation record and exact git history.
path = "what_changed.md"
text = read(path)
heading = "# Continuation — 2026-08-16 — Manual QA Evidence Sessions"
if heading not in text:
    log = subprocess.check_output(
        ["git", "log", "--reverse", "--format=- `%H` — %s", "c15373e3664a53d12f5350baf36801fe736b6464..HEAD"],
        cwd=ROOT,
        text=True,
    ).strip()
    section = f"""{heading}

## Milestone selected

The previous repository-only release automation and provenance work was already complete. The remaining release gates are dominated by physical-device audio/lifecycle behavior, real filesystem/storage failures, sustained workloads, accessibility tooling, representative package behavior, protected signing/notarization, store-console review, and final release approval. This continuation therefore added a repository-supported **manual QA evidence session** so those real tests can be recorded consistently without falsely converting them into automation.

## Manual QA evidence model and catalog

- Added `QaEvidenceStatus` with `notRun`, `passed`, `failed`, and `blocked`.
- Added versioned `QaEvidenceSession`/`QaCheckResult` serialization with UTC session and per-check timestamps.
- `notRun` is represented by absence from persisted results rather than redundant explicit records.
- Malformed or unsupported persisted sessions fall back to a fresh local session.
- Added a source-controlled six-category check catalog: microphone/lifecycle, reliability/stress, desktop interaction, accessibility/UX, branding/package validation, and external batch export.
- The catalog mirrors the still-open evidence areas in `TODO.md` while deliberately leaving protected signing/store approval outside an artificial in-app completion percentage.
- Persisted check IDs are unique snake_case compatibility identifiers; the current ID set is immutable at runtime and unknown/stale IDs are dropped.

## Persistence and privacy

- Added `QaEvidenceStore` using `SharedPreferences` key `sonicnest.qaEvidenceSession.v1`.
- Load/save/reset are explicit and persistence failures surface instead of being silently ignored.
- Status writes in the screen are globally serialized; a race found during this continuation was fixed so two rapid selections cannot save from the same previous session state.
- Reset is locked while a status write is active.
- The evidence model has no free-form tester-note field.
- JSON explicitly records privacy flags showing no recording content, titles, file paths, notes/tags/bookmarks, input-device names, or free-form tester notes.
- Evidence is generated/copied/shared only after user actions and is never automatically uploaded.

## Evidence export and UI

- Added deterministic JSON and Markdown evidence bundles with total/assessed/pass/fail/blocked/not-run counts.
- Every current catalog check appears in exports, including `notRun`, so incomplete sessions cannot masquerade as smaller completed catalogs.
- Markdown uses explicit `[PASS]`, `[FAIL]`, `[BLOCKED]`, and `[NOT RUN]` markers.
- Added About → **Manual QA evidence** with expandable categories, progress, status selectors, reset, JSON copy, Markdown share, and accessibility semantics.
- Added Diagnostics & QA → **Open QA evidence with this snapshot**. The current in-memory privacy-safe `DiagnosticReport` is passed explicitly into the manual evidence screen and included in its bundle.
- The direct About entry remains usable without collecting diagnostics first.
- A manually selected `Passed` state remains tester-entered supporting evidence only; no repository checkbox or stable-release gate is changed automatically.

## Regression coverage

Added/expanded tests for:

- QA session JSON round-trip, malformed fallback, status removal, and stale-ID filtering;
- SharedPreferences load/save/reset and current-catalog sanitization;
- deterministic bundle counts and privacy flags;
- sentinel smart-naming text proving attached diagnostics cannot leak private naming data;
- category/check uniqueness and category references;
- stable persisted snake_case IDs, lookup behavior, and immutable ID-set behavior;
- localization coverage for every source-controlled category/check and the Diagnostics attachment action;
- platform bootstrap analyzer-configuration preservation and CI format-order invariants.

## Bootstrap/formatter root cause found and fixed

Validation initially produced contradictory formatting results: source-only hosted formatting reported no changes while permanent core CI failed its formatting gate. A controlled reproduction of the permanent pre-format sequence proved that `flutter create .` inside platform bootstrap rewrote tracked `analysis_options.yaml`. Under that generated analyzer configuration, Dart formatting then wanted to rewrite 18 unrelated tracked source/test files.

The repository boundary was corrected rather than accepting those unrelated rewrites:

- Bash platform bootstrap now backs up and restores tracked `analysis_options.yaml` on exit (or removes a generated copy if the file did not originally exist).
- PowerShell bootstrap now performs the same preservation through `try/finally`.
- Core CI validates committed Dart formatting immediately after Flutter setup, before platform-host generation can introduce generated state.
- `test/bootstrap_integrity_test.dart` locks all three invariants.

After that correction the permanent committed-source formatting gate passed.

## Analyzer issues found and fixed

The first analyzer pass then exposed two constructor-order informational lints in `QaEvidenceSession` and a real Dart test bug where PowerShell `$AnalysisOptionsBackup`/`$AnalysisOptions` text was accidentally parsed as Dart interpolation. Constructors were reordered and the PowerShell assertion was changed to a raw Dart string. The subsequent analyzer passed with no issues.

## Cross-platform evidence

- Core Flutter CI run `31934843541`, source `0eb56abad482c8c296d9f80ef060ebddbba95e7b`: committed-source formatting **SUCCESS**, static analysis **SUCCESS**, complete unit suite **SUCCESS**, Linux debug build **SUCCESS**; Android debug build remained in progress at the exact moment this ledger section was generated and is not falsely recorded as complete here.
- Apple run `31934094160`, production revision `87c91697c9b11358e03334b3e642cbcb3959dc1c`: macOS debug **SUCCESS**, iOS no-codesign debug **SUCCESS**.
- Windows run `31934094196`, production revision `87c91697c9b11358e03334b3e642cbcb3959dc1c`: Windows debug **SUCCESS**; release build, portable ZIP construction, verification, bounded extracted startup smoke, warning, and artifact upload **SUCCESS**.
- Linux Package CI run `31934094139`, production revision `87c91697c9b11358e03334b3e642cbcb3959dc1c`: Linux release build, Debian package build/verification, install, installed startup smoke, uninstall, and artifact upload **SUCCESS**.

## Release boundary preserved

No physical-device microphone/routing, background/interruption, low-storage/filesystem, long-duration, accessibility, representative package, protected signing/notarization, store-console, or stable-release checkbox was marked complete merely because the evidence ledger exists. `TODO.md` intentionally retains those unchecked gates.

## Commit history for this continuation through ledger generation

{log}
"""
    text = text.rstrip() + "\n\n" + section + "\n"
write(path, text)
