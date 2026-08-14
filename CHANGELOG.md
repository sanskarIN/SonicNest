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
- Smart recording-name templates with prefix/suffix/category/date/time/sequence tokens and backward-compatible settings persistence.
- Configurable, visible, cancellable recording countdown.
- Optional keep-screen-awake behavior for active capture.
- Managed recording/Trash/temporary storage statistics and guarded temporary cleanup.
- Exact tag and date-range library filters with a dedicated responsive filter control.
- Previous/next recording navigation and A-B playback selection loops.
- Extended non-destructive audio processing for cut-selection copies, silence insertion, gain adjustment, FFT noise cleanup, compressor, limiter, high-pass, and low-pass output copies.
- Branded Flutter startup screen with recoverable startup-error UI.
- English localization-ready presentation layer and delegates for future translation work.
- Additional desktop recorder/player shortcuts: F9, F10, Ctrl+Alt+P, and Ctrl+Alt+Arrow jump controls.
- `docs/RELEASING.md`, `RELEASE_NOTES.md`, and `TODO.md` for evidence-based release management.
- Expanded manual QA matrix covering recorder lifecycle, codec fallback, smart naming, A-B looping, storage, editor processing, accessibility, localization readiness, stress testing, and signing/release boundaries.

### Changed
- Platform organization/namespace standardized on `io.github.sanskarin`.
- File picker pinned to the Android-compatible `10.3.10` release and accessed through its platform API.
- Recorder cleanup and library file/metadata mutations hardened to reduce orphaned-file and inconsistent-metadata states.
- Generated Linux/Windows host title patching aligned with current Flutter host paths.
- CI now separates analyzer informational lints from errors/warnings while still running formatting, analysis, and unit tests.
- Recording title generation now runs through filesystem-safe template rendering instead of a fixed timestamp-only pattern.
- Recorder active-state handling now distinguishes countdown from actual microphone capture.
- Player loop handling now keeps repeat-one and A-B selection modes mutually consistent.
- Settings storage cleanup now routes through a public controller operation rather than presentation-layer notifier access.
- FFprobe media-information access was aligned with the current package API to remove redundant `await` calls.

### Fixed
- Android namespace generation that previously used the reserved/invalid `in` prefix.
- Android file-picker plugin registration/build incompatibility encountered with the prior dependency selection.
- File-picker API mismatches across supported dependency versions.
- Recording-format extension imports used by player/library presentation.
- Generated template widget-test interference during dynamic platform bootstrap.
- Recorder capture cleanup after startup/cancel failures and unsupported encoder fallback behavior.
- Localization delegate import required for the Cupertino fallback delegate.
- Record keyboard shortcut behavior during an active countdown.
- Screen-wake cleanup after stop, cancel, recorder failure, and service disposal.

### Validation
- Flutter analyzer/unit tests and platform debug-build workflows remain the automated validation gates.
- The continuation intentionally does not convert physical-device microphone/background/interruption/routing/screen-wake/media-button checks into false automated claims.
- Exact newest workflow/run results are recorded in `what_changed.md` and `PROJECT_STATE.md` after the final continuation commit is observed.

## [0.1.0] - 2026-08-14

### Added
- Initial SonicNest repository license and project foundation.
