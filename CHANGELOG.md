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
- Direct multi-file original export to a user-selected directory with collision-safe naming and per-file failure isolation.
- Desktop secondary/right-click access to the existing complete recording action surface.
- Deterministic SonicNest native brand raster generation from repository-controlled mark geometry.
- Reproducible Android/iOS native splash generation and Android/iOS/macOS/Windows launcher-icon generation.
- Bash and PowerShell native-brand application commands plus dedicated branding documentation.
- Debian `.deb` selected as the initial repository-supported Linux package target.
- Linux desktop entry, AppStream metadata, deterministic hicolor icon installation, Debian package builder, package verifier, package checksum output, dedicated Linux package CI, and release-candidate `.deb` integration.
- Hosted-runner Debian package install, installed-payload validation, virtual-display startup smoke, package-manager removal, and uninstall cleanup checks.
- `docs/LINUX_PACKAGING.md` with deterministic build, structural verification, hosted-runner smoke, installation-test, and release-boundary guidance.
- `docs/RELEASING.md`, `RELEASE_NOTES.md`, and `TODO.md` for evidence-based release management.
- Expanded manual QA matrix covering recorder lifecycle, codec fallback, smart naming, A-B looping, storage, editor processing, accessibility, localization readiness, stress testing, packaging, and signing/release boundaries.

### Changed
- Platform organization/namespace standardized on `io.github.sanskarin`.
- File picker pinned to the Android-compatible `10.3.10` release and accessed through its platform API.
- Recorder cleanup and library file/metadata mutations hardened to reduce orphaned-file and inconsistent-metadata states.
- Generated Linux/Windows host title patching aligned with current Flutter host paths.
- CI now separates analyzer informational lints from errors/warnings while still running formatting, analysis, and unit tests.
- Recording title generation now runs through filesystem-safe template rendering instead of a fixed timestamp-only pattern.
- Recorder active-state handling now distinguishes countdown from actual microphone capture.
- Player loop handling now keeps repeat-one and A-B loop modes mutually consistent.
- Settings storage cleanup now routes through a public controller operation rather than presentation-layer notifier access.
- FFprobe media-information access was aligned with the current package API to remove redundant `await` calls.
- Multi-file conversion and direct original-file export are implemented as sequential, non-destructive workflows; remaining work is real-platform picker, low-storage, large-batch, and failure-recovery validation.
- Recording tiles now expose the same action surface through secondary/right-click without removing touch/long-press behavior.
- Permanent Android/Windows/Apple workflows now regenerate native SonicNest brand resources before compiling representative debug builds.
- Release hardening now treats Debian package construction, structural verification, package-manager installation, installed GUI startup smoke, and uninstall cleanup as automated Linux gates while retaining representative-system microphone, accessibility, visual, upgrade, signing, and distribution evidence as manual gates.

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
- Superseded first-pass native raster generator removed so one type-safe deterministic implementation remains canonical.
- Linux Debian verifier checksum validation no longer depends on the current working directory.
- Linux desktop entry no longer declares duplicate main menu categories.
- Repository credential-material audit no longer false-positives on its own detector signature source while continuing to scan all other tracked text files.
- AppStream developer metadata now uses the valid lowercase reverse-domain developer identifier required by current validation tooling.

### Validation
- Source revision `985f2dd1500a03b0b65ee58b142cf31f545b0cc5` is green in core Flutter CI run `31772136038`: formatting, analyzer, unit tests, Android debug APK, and Linux debug build all succeeded.
- The same source revision is green in Windows run `31772135970` and Apple run `31772136081` for Windows debug, macOS debug, and unsigned iOS debug builds.
- Native branding source revision `40c4a758debef136c2d8c977c321446cca2697cd` is green in core run `31776174696`, Windows run `31776174725`, and Apple run `31776174715`; deterministic branding generation, analyzer/tests, Android/Linux/Windows/macOS debug builds, and unsigned iOS debug build all succeeded.
- Historical Linux package source revision `f2c773e59b27a2aaac77e0590e20441ed7eba03f` is green in structural-only Linux Package CI run `31783749267`.
- Current Linux package source revision `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` is green in Linux Package CI run `31785105648`: release Linux build, `.deb` construction, structural verification, desktop/AppStream validation, checksum verification, package inspection, package-manager installation, installed-payload validation, virtual-display application startup smoke, package-manager removal, uninstall cleanup verification, and artifact upload all succeeded.
- Repository audit run `31785152042` is green on revision `e0b9658a4cb18a61ac42046a6914ca080df7eb51` after making the installed-package smoke script and install/remove CI markers mandatory repository invariants.
- The continuation intentionally does not convert representative-system microphone/background/interruption/routing/screen-wake/media-button/batch-performance/native-brand visual inspection/accessibility/upgrade/signing checks into false automated claims.
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

### Localization and library hardening continuation
- Routed primary application screens and reusable recording controls through the localization catalog.
- Added localization smoke tests and dynamic status/count strings.
- Restored responsive exact-tag/date filters and secondary-click recording actions.
- Removed duplicate legacy advanced-filter UI and obsolete `AppStrings`.
- Added safe between-file batch cancellation and collision-safe optional external-folder copies with unit-tested filesystem behavior.
- Validated revision `3fa56d26fb6cb64ccddf2b71e7b8c677aa4aa69b` in run `31774726146` across analyzer/tests and all five platform debug-build targets.

### Direct multi-file original export continuation
- Added resilient multi-file directory-copy results and collision-safe batch copying.
- Added direct export of selected original recordings without transcoding.
- Added mixed-success and duplicate-basename filesystem tests.
- Validated revision `7c4702afcb9859f3507ac151f23372f96acec50a` in run `31775283791` across analyzer/tests and all five platform debug-build targets.

### Native launcher and splash branding continuation
- Added one canonical pure-Dart deterministic native brand raster generator.
- Added reproducible Bash/PowerShell application of Android/iOS native splash resources and Android/iOS/macOS/Windows launcher/application icons.
- Integrated brand generation into permanent core, Windows, and Apple build workflows.
- Added `docs/BRANDING.md` and updated build/quick-start guidance.
- Validated native branding source revision `40c4a758debef136c2d8c977c321446cca2697cd` in core run `31776174696`, Windows run `31776174725`, and Apple run `31776174715`.

### Linux Debian packaging continuation
- Selected Debian `.deb` as the initial repository-supported Linux installation package.
- Added deterministic desktop launcher, AppStream metadata, SonicNest hicolor icon installation, licensing notices, package control metadata, and SHA-256 output.
- Added package construction and structural verification scripts plus a dedicated GitHub Actions package workflow.
- Added `.deb` output to the manual release-candidate workflow while preserving non-public release warnings.
- Added an installed-package smoke script and CI path that installs the generated `.deb`, validates installed files/metadata, starts the packaged application under a bounded virtual display, removes the package, and checks package-owned integration cleanup.
- Added Linux packaging documentation and synchronized branding/build/release/roadmap/TODO/project-state documentation.
- Fixed an initial verifier checksum-path failure and a desktop category validation warning in focused follow-up commits.
- Hardened AppStream metadata after validation correctly rejected an invalid mixed-case developer identifier.
- Structural-only package validation succeeded for source `f2c773e59b27a2aaac77e0590e20441ed7eba03f` in run `31783749267`.
- The stronger install/start/uninstall package validation succeeded for source `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` in run `31785105648`.
