# Changelog

All notable project changes are documented here.

## [Unreleased]

### Added
- Source-controlled cross-platform distribution listing and privacy declaration draft in `docs/STORE_LISTING.md`.
- Windows public Authenticode signing policy in `docs/WINDOWS_SIGNING_POLICY.md`, while private credential/service configuration remains outside the repository.
- `BatchConversionService` as the production sequential batch execution boundary with deterministic per-file conversion/export failure isolation and stop-after-current behavior.
- Supported-regular-audio and symbolic-link/non-file regression coverage for managed storage, startup reconciliation, storage accounting, and external copy destinations.
- `docs/LOCALIZATION_POLICY.md` defining localized product text versus intentionally raw technical diagnostic evidence.
- `docs/LINUX_DISTRIBUTION_POLICY.md` selecting GitHub Releases with verified Debian `.deb` plus SHA-256 checksum as the initial public Linux channel, without an initial custom APT repository.
- End-to-end controller startup reconciliation tests covering unsafe metadata removal plus active and Trash orphan reconstruction.
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
- `docs/METADATA_INTEGRITY.md` with local-library corruption isolation, interrupted-replacement recovery, diagnostic-copy, and large-library regression guidance.
- Dedicated audio-import validation service plus deterministic copy/probe/waveform failure cleanup tests.
- Metadata regression tests for malformed field decoding, invalid document structure, per-record isolation, interrupted `.bak` recovery, corrupt-primary fallback, and a 3,000-entry filesystem round-trip.
- Managed-storage mutation guards for rename, duplicate, Trash, restore, and permanent delete so tampered metadata paths cannot direct destructive operations outside SonicNest-controlled audio storage.
- Startup orphan-audio recovery that reconstructs library metadata for supported managed recording files missing from the JSON index, including best-effort recovery when media probing or waveform extraction fails.
- Storage/recovery regression tests covering protected external paths, collision-safe allocation, recoverable-file discovery, orphan deduplication, damaged-media recovery, and every represented recording format.
- `docs/RELEASING.md`, `RELEASE_NOTES.md`, and `TODO.md` for evidence-based release management.
- Expanded manual QA matrix covering recorder lifecycle, codec fallback, smart naming, A-B looping, storage, editor processing, accessibility, localization readiness, stress testing, packaging, and signing/release boundaries.

### Changed
- Canonical Dart formatter output is now committed; core CI and release preflight use a non-mutating `dart format --output=none --set-exit-if-changed` enforcement gate.
- Release guidance now requires candidate-specific review of the store/privacy draft and aligns stable Windows distribution with the Authenticode policy.
- Managed audio authority now requires a supported extension and a regular file inspected without following symbolic links; path text inside `Recordings`/`.trash` alone is insufficient.
- Recording/Trash storage totals and automatic recording sequence counting now use the same supported top-level regular-audio definition as recovery.
- External export collision detection now treats files, directories, symbolic links, broken links, and uninspectable destination paths as occupied.
- Batch Convert now delegates its production loop to the tested `BatchConversionService`; leaving the screen raises the same stop-after-current request instead of intentionally starting another item.
- `RecorderService` now lazily constructs `AudioRecorder`, eliminating constructor-time native method-channel side effects while preserving production recorder behavior when used.
- Linux distribution policy is now decided: GitHub Releases is the initial `.deb` channel; maintainer signing credentials remain outside the repository.
- Backend diagnostic localization policy is now decided: user-facing summaries are localized while raw OS/plugin/FFmpeg/filesystem details remain technical evidence.
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
- Multi-file audio import now processes selections independently so one missing/corrupt/unprobeable file does not block later valid selections; metadata-persistence failures remain fail-fast.
- Recording tiles now expose the same action surface through secondary/right-click without removing touch/long-press behavior.
- Permanent Android/Windows/Apple workflows now regenerate native SonicNest brand resources before compiling representative debug builds.
- Release hardening now treats Debian package construction, structural verification, package-manager installation, installed GUI startup smoke, and uninstall cleanup as automated Linux gates while retaining representative-system microphone, accessibility, visual, upgrade, signing, and distribution evidence as manual gates.
- Repository integrity policy now allowlists maintained permanent workflows and rejects leftover temporary/one-shot workflow files or permanent workflows requesting `contents: write`.
- Metadata decoding now normalizes negative/non-finite numeric values, bounds recovered waveform samples, preserves `channels: 0` as the unknown imported-media state, and isolates duplicate recording IDs or normalized file paths after the first valid entry.
- Failed/corrupt metadata recovery now preserves diagnostic copies and writes a clean valid empty store when no valid primary/backup exists, preventing the same corrupt primary from being copied on every startup.
- Controller library mutations now restore in-memory state and roll moved files back when metadata persistence fails; permanent deletion persists metadata before managed-file deletion so an interruption prefers a recoverable orphan over irreversible data loss.
- Startup reconciliation now accepts only existing files inside SonicNest-managed recording/Trash storage before orphan recovery reconstructs missing managed recording entries.

### Fixed
- Controller recovery tests no longer instantiate the native recorder backend merely by constructing/disposal of a recorder service.
- The stopped-recording metadata-persistence rollback test now creates its completed file after startup so it tests stop-time failure rather than being correctly consumed by startup orphan recovery.
- Generated batch-output cleanup now checks managed-audio authority before deletion, preventing cleanup from deleting an external caller path.
- External-copy filename allocation no longer selects a basename occupied by a directory or broken symbolic link.
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
- Malformed optional recording metadata no longer throws through unchecked casts during Library startup.
- A malformed individual metadata record no longer prevents valid neighboring records from loading.
- Structurally corrupt metadata is preserved to collision-safe timestamped diagnostic copies instead of being silently discarded.
- An interrupted metadata replacement that leaves only `recordings.json.bak` can now restore that backup automatically.
- A corrupt primary metadata document can now fall back to a valid backup after preserving the corrupt primary for diagnosis.
- Corrupt primary/backup documents with no valid recovery source no longer remain as the active primary indefinitely after diagnostic preservation.
- Duplicate recording IDs and duplicate normalized managed file paths no longer create multiple active metadata entries after load.
- Out-of-bound metadata file paths no longer survive startup reconciliation or reach destructive managed-storage mutations.
- Rename, Trash, restore, metadata-only edits, settings updates, processed-output registration, and permanent deletion now have explicit persistence rollback/data-preservation behavior instead of leaving avoidable file/index split states after a save failure.
- Failed audio imports clean copied managed files after probe/waveform failures and no longer abort later selected files solely because one selected audio item is malformed.
- Obsolete temporary/one-shot write-enabled continuation workflows were removed from `main`.

### Validation
- Formatter-clean source revision `4e0fbf16534a60e2d3209c5ec5f54d4982903f8c` passed core run `31870933447`: non-mutating format gate, static analysis, full unit suite, Android debug, and Linux debug all succeeded.
- The same formatter-clean source revision passed Windows run `31870933908`, Apple run `31870933903` (macOS + unsigned iOS), and Linux Package CI run `31870933982` including package install/smoke/uninstall.
- Core Flutter CI run `31870224720` is fully green on source/test revision `e47b290a7255f126cfcf1436444a90cc32d10823`: static analysis, all 87 unit tests, Android debug APK, and Linux debug build succeeded.
- Windows run `31870087266`, Apple run `31870087249`, and Linux Package CI run `31870087317` are green on application-code revision `72797fa477b9d88e2138b7ddf1d0f845cdd549ca`, covering Windows debug, macOS debug, unsigned-iOS debug, and the verified Debian package path.
- CI currently formats 30 of 54 checked-in Dart files before analysis/tests; this is tracked as an unresolved repository-hygiene item and is not claimed as formatter-clean source evidence.
- Source revision `985f2dd1500a03b0b65ee58b142cf31f545b0cc5` is green in core Flutter CI run `31772136038`: formatting, analyzer, unit tests, Android debug APK, and Linux debug build all succeeded.
- The same source revision is green in Windows run `31772135970` and Apple run `31772136081` for Windows debug, macOS debug, and unsigned iOS debug builds.
- Native branding source revision `40c4a758debef136c2d8c977c321446cca2697cd` is green in core run `31776174696`, Windows run `31776174725`, and Apple run `31776174715`; deterministic branding generation, analyzer/tests, Android/Linux/Windows/macOS debug builds, and unsigned iOS debug build all succeeded.
- Historical Linux package source revision `f2c773e59b27a2aaac77e0590e20441ed7eba03f` is green in structural-only Linux Package CI run `31783749267`.
- Current Linux package source revision `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` is green in Linux Package CI run `31785105648`: release Linux build, `.deb` construction, structural verification, desktop/AppStream validation, checksum verification, package inspection, package-manager installation, installed-payload validation, virtual-display application startup smoke, package-manager removal, uninstall cleanup verification, and artifact upload all succeeded.
- Repository audit run `31785152042` is green on revision `e0b9658a4cb18a61ac42046a6914ca080df7eb51` after making the installed-package smoke script and install/remove CI markers mandatory repository invariants.
- Windows run `31807141053` and Apple run `31807141166` are green on import-controller source revision `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` for Windows debug, macOS debug, and unsigned iOS debug builds.
- Core Flutter CI run `31807193932` is fully green on import-test revision `a88aeadadda017b0aced4dbc25c8426a27364b77`: formatting, analyzer, unit tests, Android debug APK, and Linux debug build all succeeded.
- Repository Integrity Audit run `31807662729` is green on revision `c7b9c41a8afcf83ff03ae5a014c9968f2f09c5e4` with the cleaned permanent workflow set and workflow allowlist/read-only invariant active.
- Recovery-hardening source revision `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` is fully green in core run `31867130926`: formatting, static analysis, complete unit-test suite, Android debug APK, and Linux debug build all succeeded.
- The same recovery-hardening source revision is green in Windows run `31867130920` and Apple run `31867130998` for Windows debug, macOS debug, and unsigned iOS debug builds.
- Linux Package CI run `31867130938` is green on the same recovery-hardening source revision: Linux release build, Debian construction/verification, package-manager install, installed-package smoke, uninstall, and artifact upload succeeded.
- Repository Integrity Audit run `31867543888` is green after recovery-hardening project-state/documentation synchronization and the permanent workflow invariants remained active.
- The continuation intentionally does not convert representative-system microphone/background/interruption/routing/screen-wake/media-button/batch-performance/native-brand visual inspection/accessibility/upgrade/signing, real filesystem interruption, or malformed/partially written real-media checks into false automated claims.
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

### Metadata integrity and resilient import continuation
- Added tolerant recording metadata decoding so malformed optional fields and nested markers cannot crash the entire Library load.
- Added structural metadata validation, per-record isolation, timestamped corrupt-document preservation, interrupted `.bak` recovery, and valid-backup fallback after a corrupt primary.
- Added deterministic metadata tests including a 3,000-entry filesystem save/load round-trip.
- Added `AudioImportService` to isolate managed-copy, media-probe, waveform-extraction, and cleanup behavior for selected files.
- Changed multi-file import so isolated malformed/missing audio selections are reported and skipped while later valid selections continue; genuine metadata persistence failures still stop safely and clean the just-created unregistered file.
- Added direct import service tests for valid imports plus copy/probe/waveform failures.
- Removed obsolete write-enabled continuation workflows and hardened the repository audit with a permanent workflow allowlist and read-only permission invariant.
- Added metadata-integrity, contributor, build, user-guide, and troubleshooting documentation for the new reliability behavior and its manual-QA boundaries.
