# SonicNest Final Repository Audit — 2026-08-18

This document records the final repository-owned implementation, reliability, dependency, open-source maintenance, documentation, and automated-validation audit performed on SonicNest before the remaining work becomes exclusively real-device/system, accessibility, protected-signing, store-console, translation-review, or stable-release evidence.

It must not be used to claim that those manual/credential-dependent gates have been completed.

## Repository classification

- Project: **SonicNest**
- Repository: `https://github.com/sanskarIN/SonicNest`
- License: Apache License 2.0
- Current development line: `0.1.0+1`
- Release classification: **development preview**
- Canonical Gumroad storefront: `https://ramsandesh.gumroad.com`
- Final validation PR: `#15`
- Validated PR head: `a31792c2f758ef321131239f2a683cc9eb51a0b1`
- Final contract merge commit: `a5a68f81369f46d2127219940254aa3563d81576`

## Final source audit findings

### Persisted integer settings integrity

The final audit confirmed that `RecordingSettings.fromJson()` previously accepted finite fractional numbers for integer-only fields because `toInt()` silently truncated them.

The parser now requires finite whole numbers before integer-only values are accepted. Fractional persisted values for bitrate, sample rate, channels, and countdown fall back to the established safe values instead of being silently truncated.

Regression coverage verifies the fractional-input boundary.

### Future settings-schema preservation

The canonical settings snapshot already used a versioned `settings_snapshot_v1` document, but an integer schema version unknown to the current application was previously treated like damaged data and could fall through to legacy/default preferences.

The final audit adds `UnsupportedSettingsSchemaException` so an unsupported integer settings schema is refused explicitly and the stored snapshot remains untouched. Malformed JSON and malformed/non-integer schema data still use the existing legacy corruption fallback.

This matches the repository’s existing forward-compatibility rule for recording metadata: an older SonicNest build must not silently reinterpret or overwrite a structurally recognizable newer schema.

### Managed cleanup authority

Earlier 2026-08-18 hardening established separate destructive boundaries for:

- managed recording/Trash audio;
- managed temporary processor files; and
- managed recorder capture files.

The final audit confirmed all application callers had migrated away from the old unrestricted `StorageService.deleteIfExists()` helper, and that obsolete helper was removed from the public storage-service API.

Current cleanup/rollback rules therefore use intent-specific managed-storage operations rather than an unrestricted arbitrary-path delete method.

### Recorder output path validation

Recorder stop accepts only the exact capture destination SonicNest supplied to the recorder backend and requires the final saved result to be a regular managed recording before reporting success. Unexpected backend-returned external paths are rejected rather than used for cleanup or result registration.

### Batch failure isolation

Batch conversion rollback cleanup is best effort. A secondary cleanup failure cannot replace the original conversion/registration failure or abort later selected items. External-output paths are not deleted as part of managed rollback.

### FilePicker v12 import/export migration

The final maintenance pass moved SonicNest away from the earlier FilePicker compatibility pin after current validation exposed both security/maintenance pressure and Android Gradle Plugin registration behavior in the newer lines.

The final reviewed plugin graph is:

- `file_picker: 12.0.0-beta.7`
- `share_plus: 13.3.0`
- `wakelock_plus: 1.7.0`

No `dependency_overrides` workaround is used.

The migration required several real validation-driven corrections:

1. `file_picker 11.0.3` was rejected after Android compilation reproduced the upstream legacy-Kotlin/AGP registration failure where `GeneratedPluginRegistrant.java` could not resolve `FilePickerPlugin`.
2. The FilePicker 12 beta line was selected because it contains the upstream AGP/plugin-registration correction.
3. `share_plus` was moved to `13.3.0` to align the transitive Windows dependency graph with FilePicker’s win32 6.x line.
4. `wakelock_plus` was moved to `1.7.0` to complete the same current win32/Kotlin-compatible graph rather than forcing a transitive dependency override.
5. FilePicker v12 source APIs were migrated: multi-file selection uses `pickFiles()`, single-file selection uses `pickFile()`, and deprecated `allowMultiple` calls are gone.
6. SonicNest deliberately does **not** use FilePicker v12 `saveFile(bytes:)` for large audio exports. Single-recording export still streams through `File.copy`: FilePicker selects a destination directory, SonicNest allocates a collision-safe destination filename, and the controller copies the managed recording to that path.

`tool/tests/test_dependency_surface.py` and `tool/tests/test_final_repository_contract.py` lock the final dependency/API/export boundary.

### GitHub Actions maintenance

Dependabot surfaced the maintained GitHub Actions runtime upgrades during the final pass. SonicNest reviewed and merged:

- `actions/checkout@v7`
- `actions/upload-artifact@v7`
- `actions/download-artifact@v8`

The repository audit was advanced to require the current artifact-action majors, and `tool/tests/test_github_action_versions.py` rejects regression to the old maintained-workflow action versions.

### Workflow hygiene

The stale one-shot hosted formatter workflow and trigger marker were removed from `main`. Permanent repository workflow policy remains:

- only the maintained workflow allowlist may be tracked under `.github/workflows/`;
- permanent workflows may not request `permissions: write-all` or prohibited repository write scopes; and
- committed Dart formatting remains a non-mutating validation gate.

A Python regression locks the permanent workflow set and read-only permission boundary.

## Open-source repository completion

The final repository audit adds/locks the following maintainer surfaces:

- `.github/CODEOWNERS` — default review ownership for `@sanskarIN`;
- `.github/FUNDING.yml` — optional Gumroad and Buy Me a Coffee support destinations;
- `.github/ISSUE_TEMPLATE/config.yml` — disables blank issues and routes security/support questions to maintained guidance;
- `.github/dependabot.yml` — weekly Dart/Flutter (`pub`) and GitHub Actions version-update proposals;
- `docs/OPEN_SOURCE_MAINTENANCE.md` — maintainer/contributor guide for ownership, issues, dependency updates, funding, security, quality gates, and release boundaries;
- `tool/tests/test_open_source_maintenance.py` — permanent regression coverage for these maintenance surfaces.

Dependency-bot pull requests remain proposals only. They do not bypass SonicNest formatter, analysis, tests, package/build validation, compatibility review, or affected manual QA gates.

## Documentation completion

The maintained documentation set covers:

- project overview and quick start;
- end-user recording/library/playback/editor behavior;
- architecture and codec behavior;
- build/platform bootstrap instructions;
- deterministic branding;
- metadata integrity and recovery;
- managed storage boundaries;
- batch conversion/export behavior;
- diagnostics and manual QA evidence;
- offline QA-evidence verification;
- troubleshooting;
- Linux Debian packaging/distribution;
- Windows portable packaging/signing policy;
- Android and Apple distribution/signing policy;
- store listing/privacy copy;
- release-candidate artifact classification and provenance;
- release procedure and evidence template;
- security, privacy, support, contribution, conduct, and open-source maintenance;
- final repository audit, project state, TODO gates, changelog/release notes, and additive continuation history.

`docs/README.md` remains the documentation index.

## Source-marker audit

Repository code search during the final pass did not identify unresolved `TODO`, `FIXME`, `XXX`, `HACK`, or `UnimplementedError` markers in the maintained application source. `TODO.md` is intentionally a release/evidence tracker, not an unfinished-source marker list.

## Pull-request cleanup

Several validation/dependency PRs were deliberately superseded rather than merged when hosted validation exposed a more accurate next step:

- PR `#2` — valid numeric-settings logic integrated directly; obsolete temporary formatter/ledger workflow excluded.
- PRs `#10`–`#14` — preserved as validation chronology for formatter, Android plugin-registration, dependency-solver, and FilePicker v12 API findings; none is treated as final evidence.
- PR `#15` — final clean validation vehicle; its only branch-only change was the permanent final repository-contract regression. It passed the complete maintained matrix and was squash-merged as `a5a68f81369f46d2127219940254aa3563d81576`.

Temporary diagnostic/workflow branches were reset or closed and no temporary write-enabled workflow is tracked on `main`.

## Final automated validation

Final validated source/test head: `a31792c2f758ef321131239f2a683cc9eb51a0b1`.

### Repository Integrity Audit

- Run: `32155054646`
- Result: **SUCCESS**
- Covered repository invariants, tracked-source line hygiene, Python tooling/regressions, Bash syntax, PowerShell syntax, maintained workflow allowlist/read-only policy, current GitHub Actions majors, open-source maintenance surfaces, dependency/API contract, and final repository contract.

### Flutter CI

- Run: `32155054681`
- Result: **SUCCESS**
- Committed Dart formatting: **SUCCESS**
- Dependency resolution: **SUCCESS**
- Flutter static analysis: **SUCCESS**
- Complete Flutter unit/regression suite: **SUCCESS**
- Android debug APK: **SUCCESS**
- Linux debug build: **SUCCESS**

### Windows Build

- Run: `32155054632`
- Result: **SUCCESS**
- Windows debug build: **SUCCESS**
- Windows release build: **SUCCESS**
- Portable ZIP build: **SUCCESS**
- Portable structural verification: **SUCCESS**
- Extracted-package startup smoke: **SUCCESS**
- Development-preview warning generation: **SUCCESS**
- Artifact upload through `actions/upload-artifact@v7`: **SUCCESS**

### Apple Builds

- Run: `32155054751`
- Result: **SUCCESS**
- macOS debug build: **SUCCESS**
- iOS no-codesign debug build: **SUCCESS**

All four maintained workflow families above validated the exact PR head `a31792c2f758ef321131239f2a683cc9eb51a0b1`. PR `#15` then merged the permanent final-contract test to `main` as `a5a68f81369f46d2127219940254aa3563d81576`.

## Remaining manual and credential-dependent gates

The following remain intentionally open and must not be marked complete from repository automation alone:

- physical microphone permission/capture/routing across maintained platforms;
- built-in/wired/USB/Bluetooth/external-interface behavior;
- interruption, background, lock-screen, foreground-service, reconnect, and media-button behavior;
- real low-storage, permission-loss, process/device/power interruption and recovery;
- representative malformed, partially written, and damaged real-media testing;
- long-duration recording/playback/editor soak tests;
- large-library and large-batch UI/memory/performance profiling;
- TalkBack, VoiceOver, Narrator, Linux accessibility, large-text, keyboard-only, and reduced-motion audits;
- real launcher/splash/icon visual review and real screenshots;
- representative Debian/Ubuntu package install/upgrade/audio/desktop/uninstall QA;
- representative Windows portable-package microphone/routing/accessibility/branding/cleanup QA;
- protected Android upload-key/Play App Signing candidate;
- Apple provisioning/signing/notarization/TestFlight/App Store Connect validation;
- Windows Authenticode signing/trust verification on the exact final public package;
- additional locales with translation review and layout/accessibility QA;
- final release checklist approval and `v1.0.0` tag.

## Completion boundary

No additional reproducible repository-owned feature, tooling, documentation, deterministic reliability, dependency-maintenance, workflow-maintenance, or open-source-maintenance gap is identified by this final audit.

Future repository changes should be driven by:

1. a reproducible defect;
2. reviewed dependency/security maintenance;
3. evidence from the real-system/manual gates above; or
4. an explicitly approved new product feature.

Until the remaining evidence and protected-release requirements are complete, SonicNest remains a **development preview**.
