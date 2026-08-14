# Changelog

All notable project changes are documented here.

## [Unreleased]

### Added
- Cross-platform Flutter application foundation.
- Recorder, library, player, editor, settings, About/support, and local metadata architecture.
- Native and transcoded audio-format pipeline.
- Responsive design system, themes, accessibility semantics, waveform visualization, markers, trash, search, sorting, import/export, and sharing.
- Persisted PCM-derived waveform envelopes for imported and processed audio.
- Multi-selection library operations for favorites, pins, sharing, Trash, restore, and permanent deletion.
- Draggable waveform editor selection, selection undo/redo/reset, and format export presets.
- Desktop Ctrl+1 through Ctrl+5 navigation shortcuts.
- Native PowerShell platform bootstrap alongside the Bash bootstrap path.
- Windows desktop CI plus macOS and unsigned iOS build-validation workflows.
- PCM waveform peak unit tests and expanded settings/metadata/file-name tests.

### Changed
- Platform organization/namespace standardized on `io.github.sanskarin`.
- File picker pinned to the Android-compatible `10.3.10` release and accessed through its platform API.
- Recorder cleanup and library file/metadata mutations hardened to reduce orphaned-file and inconsistent-metadata states.
- Generated Linux/Windows host title patching aligned with current Flutter host paths.
- CI now separates analyzer informational lints from errors/warnings while still running formatting, analysis, and unit tests.

### Fixed
- Android namespace generation that previously used the reserved/invalid `in` prefix.
- Android file-picker plugin registration/build incompatibility encountered with the prior dependency selection.
- File-picker API mismatches across supported dependency versions.
- Recording-format extension imports used by player/library presentation.
- Generated template widget-test interference during dynamic platform bootstrap.
- Recorder capture cleanup after startup/cancel failures and unsupported encoder fallback behavior.

### Validation
- Flutter analyzer succeeds on the hardened source.
- Unit tests succeed in GitHub Actions.
- Android debug APK build succeeds in GitHub Actions.
- Linux debug desktop build succeeds in GitHub Actions.
- Windows, macOS, and unsigned iOS build workflows are included for cross-platform validation; final per-run status is recorded in `what_changed.md`/`PROJECT_STATE.md` when observed.
- Hardware-dependent microphone/background/interruption/long-duration behavior remains a manual target-device QA requirement.

## [0.1.0] - 2026-08-14

### Added
- Initial SonicNest repository license and project foundation.
