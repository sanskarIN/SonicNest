from pathlib import Path


RELEASE_MARKER = '## 2026-08-16 — Privacy-safe Diagnostics & QA evidence'
RELEASE_SECTION = '''

## 2026-08-16 — Privacy-safe Diagnostics & QA evidence

SonicNest now includes an About-accessible **Diagnostics & QA** screen for reproducible physical-device, support, storage, lifecycle, and accessibility evidence. Diagnostics are generated only when the user opens or refreshes the screen. SonicNest does not automatically upload a report.

The report can be copied as deterministic JSON or shared as Markdown. It records the SonicNest version/build, platform/runtime information, aggregate Library counts, managed-storage totals and probe status, recorder state, input-device count when safely available, default-versus-custom input selection, and non-content recording/playback/interface preferences needed to reproduce behavior.

The privacy contract intentionally excludes recording/audio content, recording titles, file paths, notes, tags, bookmarks, smart-naming prefix/template/suffix/category text, and input-device names. Input enumeration contributes only a count and selected-input class, and SonicNest skips that probe while recording is active so opening diagnostics does not introduce another recorder-backend enumeration during capture.

App version metadata is centralized in `AppConstants`, and About plus diagnostics now consume the same canonical version/build source. `docs/DIAGNOSTICS_AND_QA.md`, `README.md`, `TODO.md`, and `ROADMAP.md` document the evidence workflow and clearly state that a generated report does not close microphone, routing, interruption, background, low-storage/filesystem, performance, accessibility, signing, package, store, or other real-target release gates.

Regression coverage injects private smart-naming sentinel text and verifies that neither JSON nor Markdown can serialize it; verifies the exact explicit privacy flags; verifies deterministic report sections; verifies unavailable probe behavior without invented values; and covers the diagnostics localization catalog.

Hosted validation for source `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910` is Flutter CI run `31932491771`: the non-mutating Dart formatter gate passed with **59 files / 0 changed**, static analysis reported **No issues found**, the complete unit suite passed **94/94 tests**, the Linux debug build passed, and the Android debug APK build passed.

The 2026-08-15 five-platform release-candidate/provenance artifacts predate this diagnostics feature. Their hashes and signing classifications remain valid evidence for their exact historical source revisions, but they are not presented as release artifacts containing the 2026-08-16 diagnostics implementation. Stable-release approval remains blocked on the existing real-device, sustained-workload, accessibility, protected-signing, distribution-console, and final-approval gates.
'''

OLD_VALIDATION = '''latest_automated_validation:
  formatter_clean_source_commit: 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c
  canonical_format_commit: 22c1d46e077625d6e1964d56716700727d1800dc
  non_mutating_format_gate_commit: 704b0f60aae8f179f4f41875c336d2052b45391e
  core_flutter_ci:
    run_id: 31870933447
    source_commit: 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c
    dart_format_check: success_non_mutating
    analyzer: success
    unit_tests: success_complete_suite
    android_debug_apk: success
    linux_debug_build: success
'''
NEW_VALIDATION = '''latest_automated_validation:
  formatter_clean_source_commit: 00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910
  canonical_format_commit: 3d91ace5814e908dbf9c66d556e528042debfa52
  non_mutating_format_gate_commit: 32ced086fac27fd2f4f808674afa511647a863e9
  core_flutter_ci:
    run_id: 31932491771
    source_commit: 00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910
    dart_format_check: success_non_mutating_59_files_0_changed
    analyzer: success_no_issues
    unit_tests: success_complete_suite_94_tests
    android_debug_apk: success
    linux_debug_build: success
'''
FEATURE_MARKER = '  - English localization-ready delegate with primary Flutter presentation surfaces migrated to the localization catalog\n'
FEATURE_ADDITION = '''  - English localization-ready delegate with primary Flutter presentation surfaces migrated to the localization catalog
  - About-accessible user-initiated Diagnostics & QA screen with deterministic JSON copy and Markdown sharing
  - privacy-safe diagnostics contract excluding recording content titles paths notes tags bookmarks smart-naming text and input-device names
  - aggregate diagnostics for runtime Library managed storage recorder state input count and non-content settings
  - diagnostics input enumeration skipped while recording is active to avoid a concurrent recorder-backend probe
  - regression coverage enforcing diagnostics serialization privacy unavailable-probe behavior and localization labels
'''
DIAGNOSTICS_BLOCK = '''diagnostics_qa:
  implementation_source_commit: 00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910
  core_ci_run_id: 31932491771
  access: About -> Diagnostics & QA
  generation: user_initiated_only
  automatic_upload: false
  exports:
    - deterministic JSON clipboard copy
    - privacy-safe Markdown share file
  privacy_excludes:
    - recording content
    - recording titles
    - file paths
    - notes tags and bookmarks
    - smart-naming prefix template suffix and category text
    - input-device names
  evidence_includes:
    - canonical app version and build
    - platform OS locale Dart runtime and logical processor count
    - aggregate saved Trash favorite and pinned counts
    - aggregate managed storage bytes and file counts with probe status
    - recorder state input-probe status and input count
    - default-versus-custom selected input classification
    - non-content recording playback appearance and delete-confirmation settings
  active_recording_input_probe: skipped
  documentation: docs/DIAGNOSTICS_AND_QA.md
  release_gate_effect: supporting_evidence_only_no_manual_gate_closed
release_evidence_boundary:
  diagnostics_feature_date: 2026-08-16
  note: The 2026-08-15 five-platform release-candidate and unified provenance artifacts predate Diagnostics & QA and are evidence only for their exact historical source revisions.
'''

CHANGES_MARKER = '## 2026-08-16 — Privacy-safe in-app diagnostics and QA evidence'
CHANGES_SECTION = '''

## 2026-08-16 — Privacy-safe in-app diagnostics and QA evidence

### Continuation objective

The previous repository state had no remaining repository-only release-automation gap; the unchecked release list was dominated by physical-device microphone/routing/lifecycle tests, sustained recording and batch workloads, real filesystem/storage failures, accessibility audits, protected signing/notarization, distribution-console work, and final release approval. This continuation therefore implemented the next code-side feature that materially improves those remaining evidence workflows without pretending to replace them: a privacy-safe in-app Diagnostics & QA report.

### Diagnostic report model and privacy contract

- Added `lib/services/diagnostic_report_service.dart` with deterministic `DiagnosticReport` JSON and Markdown serialization plus schema versioning.
- Added canonical app/runtime evidence: app version/build, OS family, OS version string, locale, Dart runtime, and logical processor count.
- Added aggregate Library evidence only: saved, Trash, favorite, and pinned counts.
- Added aggregate managed-storage evidence through `StorageStats`: recordings, Trash, temporary bytes/file counts, total managed bytes, and an explicit probe-success flag.
- Added recorder-state evidence: recorder status, input-probe success, input-device count when safely available, and system-default-versus-custom input classification.
- Added non-content recording configuration: format, preset, bit rate, sample rate, channels, automatic gain, echo cancellation, noise suppression, countdown, and keep-screen-awake.
- Added non-content playback/interface evidence: default speed, skip interval, skip-silence, theme, reduced motion, and permanent-delete confirmation.
- The report deliberately does **not** receive or serialize recording objects, recording titles, recording paths, recording/audio content, notes, tags, bookmarks, smart-naming prefix/template/suffix/category text, or input-device names.
- JSON contains an explicit privacy object with every sensitive-content flag set to `false`.

### In-app Diagnostics & QA surface

- Added `lib/screens/diagnostics_screen.dart` and an **About -> Diagnostics & QA** entry in `lib/screens/about_screen.dart`.
- Diagnostics are generated only when the user opens or refreshes the surface; no automatic upload path was added.
- Storage and input-device probes fail independently and render as unavailable rather than fabricating values.
- Input-device enumeration is deliberately skipped while the recorder is active, avoiding a new recorder-backend enumeration during capture.
- Added **Copy JSON** through the system clipboard and **Share report** through a temporary Markdown file plus the existing explicit system-share service.
- The report surface uses constrained responsive layout, selectable diagnostic values, semantic loading text, retry behavior, and existing Material 3 conventions.

### Localization and canonical application metadata

- Added `lib/l10n/diagnostics_localizations.dart` for Diagnostics & QA product-facing text.
- Added `test/diagnostics_localizations_test.dart` for catalog labels, privacy copy, and helper formatting.
- Centralized `appVersion`, `appBuildNumber`, `appVersionWithBuild`, and `appDisplayVersion` in `lib/core/constants.dart`.
- Updated About and diagnostics to consume the same canonical application version source.
- Kept raw runtime/OS/backend values technical, consistent with the existing localization policy.

### Privacy and serialization regression coverage

- Added `test/diagnostic_report_service_test.dart`.
- The suite verifies deterministic machine-readable sections and expected app/library/storage/recorder/settings values.
- The suite verifies the exact privacy object rather than checking only one field.
- The suite injects sentinel values into smart-naming prefix, template, suffix, and category and proves those secret values cannot occur in JSON or Markdown output.
- The suite proves smart-naming field keys are absent from JSON.
- The suite verifies failed storage/input probes remain `null` / unavailable rather than being represented by invented metrics.
- Diagnostics localization tests verify privacy copy explicitly names recording content, titles, paths, notes, tags, bookmarks, and input-device names as excluded.

### Documentation and QA integration

- Added `docs/DIAGNOSTICS_AND_QA.md` with access instructions, privacy contract, report-field definitions, physical-QA usage, support-sharing guidance, and explicit evidence limitations.
- Updated `README.md` with the Diagnostics & QA feature, privacy behavior, and documentation link.
- Updated `TODO.md` so remaining hardware/lifecycle/reliability/accessibility/signing tasks can use diagnostics as supporting evidence without checking any manual gate off.
- Updated `ROADMAP.md` with the v0.4/v0.5 diagnostics milestone and a dedicated diagnostics evidence status section.
- Updated `RELEASE_NOTES.md` with the 2026-08-16 diagnostics continuation and exact core-CI evidence.
- Updated `PROJECT_STATE.md` with the current diagnostics contract, validated source revision, and explicit historical-release-artifact boundary.

### Formatter discovery, exact repair, and permanent gate restoration

The first hosted validation exposed canonical Dart-format drift in four new files. Rather than weakening the existing read-only formatter gate or guessing at formatting, a temporary CI revision ran the same hosted Dart formatter, printed its exact diff, and intentionally failed. That exact output was then committed file-by-file. The temporary formatter-diff step was removed, and `.github/workflows/ci.yml` was restored to the permanent non-mutating command:

`dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart`

The final validated source passes this gate with **59 files, 0 changed**.

### Analyzer defect found and fixed

After formatting was repaired, hosted static analysis found one integration error limited to the two new test files: they imported `package:sonicnest/...`, while `pubspec.yaml` canonically declares `name: sonic_nest`. Production diagnostics code was not changed for this issue. Both test import sets were corrected to `package:sonic_nest/...`, then the complete validation suite was rerun.

### Final automated validation

Final diagnostics source revision: `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910`.

Flutter CI run `31932491771` validates that exact source:

- Dart formatting enforcement: **success**, 59 files checked, 0 changed.
- Static analysis: **success**, `No issues found!`.
- Unit tests: **success**, complete suite **94/94**.
- Linux debug build: **success**.
- Android debug APK build: **success**.

The 2026-08-15 cross-platform release-candidate and provenance artifacts remain historical evidence for their exact older source revisions. They predate the Diagnostics & QA implementation and are intentionally **not** described as artifacts containing this feature. Windows/macOS/iOS/package/signing evidence for this newer source is not invented or inferred from those older artifacts.

### Commit ledger for this continuation

Each repository write continued to use `Sanskar <sanskarin@outlook.in>`.

- `e1bf8a67039e15fecad29ec133aab0c22086f69b` — `feat: add privacy-safe diagnostic report model`
- `e50c606bc7dd084e7999ca2d4307f1f595cf0d73` — `test: cover diagnostic report privacy and serialization`
- `c5af027198ec97498ea04833a30d85ef94f42341` — `refactor: centralize SonicNest version metadata`
- `953276429cb11468d35ca348bcaae343af17a72e` — `feat: localize diagnostics and QA evidence strings`
- `820d5cd09145f1e25d386a6a07cb2b7e12d4630d` — `feat: add in-app diagnostics and QA evidence screen`
- `db9319721629f5efa9e79ce3323e61b9a1f43a76` — `feat: expose diagnostics from About screen`
- `6513333cfce625a40864179eea02b74d7a43fd91` — `fix: complete diagnostics labels`
- `601e913e45da78077390946c5824e68ee62c07b3` — `fix: complete diagnostics screen integration`
- `f70a5f41cdbbc48b6559e7d2b429bac01bfaffcb` — `refactor: reuse canonical app metadata in diagnostics`
- `51ce8005a3f284f321f3039036bcd06f777f21ec` — `test: cover diagnostics localization catalog`
- `6d39b5354a413a14f6d0985c997875ccfebd1d42` — `test: enforce diagnostics privacy contract`
- `617b7e8b4caa5faa50d9f2d0acf5a0f53d621659` — `docs: add privacy-safe diagnostics QA guide`
- `384b3a50bf85f31b6f7bea81e4a22537c1012bb0` — `docs: document in-app diagnostics and QA reports`
- `0f3661d7198f0285c550267cb3f02c2ffbcbb0ad` — `ci: expose canonical diagnostics formatting diff` (temporary hosted formatter-diff revision)
- `80ab45ed55da6a66fc849ac5f1b72ca049634ea2` — `style: format diagnostics localization`
- `95d86c2d82beb0a43b6304d1c058c58cbe62f694` — `style: format diagnostics screen`
- `b510b205dfff59110399b3e60db3c903c7f8669b` — `style: format diagnostic report service`
- `3d91ace5814e908dbf9c66d556e528042debfa52` — `style: format diagnostic report tests`
- `32ced086fac27fd2f4f808674afa511647a863e9` — `ci: restore non-mutating Dart formatting gate`
- `ec9495ce66586c7e150d98a3dd6b3dcfa84f36eb` — `docs: connect diagnostics to remaining QA gates`
- `8658eadd12f83a3cfa56e2a7741a27d938d8b764` — `docs: record diagnostics QA milestone in roadmap`
- `b782ca8bf58fe614c8bcc708039c7a4f28457ed8` — `fix: use canonical package name in diagnostics report tests`
- `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910` — `fix: use canonical package name in diagnostics localization tests`

### Validation-run ledger

- Run `31932084698` exposed the initial formatting drift in the diagnostics source.
- Run `31932234819` printed the hosted formatter's exact four-file canonical diff from the temporary formatter-diff revision.
- Run `31932376857` confirmed the restored formatting gate and Linux build, then exposed the two test-only package-name imports during analyzer validation.
- Run `31932491771` is the final clean diagnostics validation run: formatter, analyzer, 94 tests, Android debug, and Linux debug all succeeded on `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910`.

### Remaining release boundary

No physical-device, real-filesystem, accessibility, production-signing, notarization, store-console, package-visual, sustained-performance, or stable-release gate is marked complete merely because diagnostics now exists. `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md` remain the authority for those evidence requirements. Diagnostics improves reproducibility and support evidence; it does not substitute synthetic metadata for a test that must occur on real hardware or in a protected maintainer release environment.
'''


def append_if_missing(path: Path, marker: str, section: str) -> None:
    text = path.read_text(encoding='utf-8')
    if marker not in text:
        path.write_text(text + section, encoding='utf-8')


def update_release_notes() -> None:
    append_if_missing(Path('RELEASE_NOTES.md'), RELEASE_MARKER, RELEASE_SECTION)


def update_project_state() -> None:
    path = Path('PROJECT_STATE.md')
    text = path.read_text(encoding='utf-8')
    if OLD_VALIDATION in text:
        text = text.replace(OLD_VALIDATION, NEW_VALIDATION, 1)
    elif NEW_VALIDATION not in text:
        raise RuntimeError('Expected latest_automated_validation block not found')
    if '  - About-accessible user-initiated Diagnostics & QA screen' not in text:
        if FEATURE_MARKER not in text:
            raise RuntimeError('Expected completed_features localization marker not found')
        text = text.replace(FEATURE_MARKER, FEATURE_ADDITION, 1)
    if 'diagnostics_qa:\n' not in text:
        marker = 'partial_features:\n'
        if marker not in text:
            raise RuntimeError('Expected partial_features marker not found')
        text = text.replace(marker, DIAGNOSTICS_BLOCK + marker, 1)
    path.write_text(text, encoding='utf-8')


def update_what_changed() -> None:
    append_if_missing(Path('what_changed.md'), CHANGES_MARKER, CHANGES_SECTION)


def main() -> None:
    update_release_notes()
    update_project_state()
    update_what_changed()


if __name__ == '__main__':
    main()
