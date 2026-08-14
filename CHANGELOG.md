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
- Multi-recording batch format conversion with target-format selection, progress reporting, per-file failure isolation, preserved originals, marker retention, and library registration of successful outputs.
- Desktop secondary/right-click access to the existing complete recording action surface.
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
- The previously planned multi-file conversion capability is now implemented as a sequential non-destructive batch workflow; direct batch export to a user-selected external destination remains optional future work.
- Recording tiles now expose the same action surface through secondary/right-click without removing touch/long-press behavior.

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
- Source revision `985f2dd1500a03b0b65ee58b142cf31f545b0cc5` is green in core Flutter CI run `31772136038`: formatting, analyzer, unit tests, Android debug APK, and Linux debug build all succeeded.
- The same source revision is green in Windows run `31772135970` and Apple run `31772136081` for Windows debug, macOS debug, and unsigned iOS debug builds.
- The continuation intentionally does not convert physical-device microphone/background/interruption/routing/screen-wake/media-button/batch-performance checks into false automated claims.
- Exact newest workflow/run results are also recorded in `what_changed.md` and `PROJECT_STATE.md`.

## [0.1.0] - 2026-08-14

### Added
- Initial SonicNest repository license and project foundation.


### External batch export continuation
- Added optional user-selected external-folder copies after successful managed batch conversions.
- Added collision-safe destination naming without overwriting existing files.
- Added safe stop-after-current cancellation between batch items.
- Kept conversion and external-copy failures independently reported so a destination-copy failure does not invalidate a successful managed conversion.
- Validated revision `54b727db6dd887fb0b2df2d36cabb2cd78671d7a` with analyzer/tests and Android, Linux, Windows, macOS, and unsigned iOS debug builds in run `31773250023`.
