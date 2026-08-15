# SonicNest Release Notes

## v0.1.0 — Development Preview

SonicNest is an offline-first cross-platform sound and voice recorder built with Flutter. This development preview establishes the recorder, recording library, playback, editing, native branding, Linux packaging, metadata recovery, managed-audio orphan reconstruction, resilient import, platform bootstrap, CI, privacy, and open-source foundations required for later stable releases.

### Recorder

- Start, configurable/cancellable countdown, pause, resume, stop, save, and discard recordings.
- Runtime encoder capability checks with native capture when available and safe post-recording conversion fallback when needed.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and AAC format paths.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom presets.
- Bitrate, sample-rate, channel, automatic-gain, echo-cancellation, and noise-suppression preferences.
- Input-device enumeration and selection where the recorder backend exposes devices.
- Recording timer, waveform/amplitude display, clipping warning, and bookmarks.
- Smart recording-name templates with date, time, sequence, category, prefix, and suffix tokens.
- Optional keep-screen-awake behavior during active recording with lifecycle cleanup.
- Android foreground recording-service integration through reproducible platform overrides.

### Library and storage

- Search recording titles, folders, tags, notes, and bookmark text.
- Sort by date, title, duration, and file size.
- Filter by scope, format, folder, exact tag, and date range.
- Favorites, pins, folders, tags, notes, multi-select, and bulk actions.
- Trash, restore, permanent deletion, and empty-Trash workflow.
- Import, duplicate, export copy, and system sharing.
- Multi-file import validates selections independently and cleans copied managed files when copy/probe/waveform processing fails, allowing later valid selections to continue.
- Recording metadata tolerates malformed optional fields and malformed individual records instead of allowing one damaged object to block Library startup.
- Unsafe negative/non-finite numeric metadata is normalized, malformed waveform members are filtered, and recovered waveform samples are bounded.
- Structurally corrupt metadata is preserved to timestamped diagnostic copies, valid `.bak` metadata can recover an interrupted replacement or a corrupt primary, and an unrecoverable store is reset to a clean valid document after diagnostics are preserved.
- Duplicate recording IDs and duplicate normalized file paths are isolated after the first valid entry.
- Startup reconciliation rejects metadata entries outside SonicNest-managed recording/Trash paths or entries referencing missing files.
- Managed-storage mutation guards prevent rename, duplicate, Trash, restore, and permanent-delete operations from acting on unrelated external paths.
- Startup orphan recovery reconstructs metadata for supported audio that still exists in the managed `Recordings` directory but is missing from the JSON index, including best-effort recovery for damaged/partial media when probing or waveform extraction fails.
- Library mutation persistence is rollback-aware: metadata-only updates restore prior state on save failure, file moves are rolled back when their metadata update fails, and permanent deletion persists metadata first so an interruption prefers a recoverable orphan over irreversible data loss.
- Multi-recording batch format conversion with target-format selection, progress, per-file failure isolation, retained source recordings, and successful-output registration in the managed library.
- Direct multi-file original export to a user-selected folder without transcoding, with collision-safe destination naming and per-file failure isolation.
- Desktop secondary/right-click access to recording actions while preserving touch and explicit menu interactions.
- Managed storage accounting for recordings, Trash, and temporary processing files.

### Playback

- Play, pause, stop, seek, jump, volume, speed, repeat-one, and optional silence skipping.
- Previous/next recording navigation.
- A–B selection looping.
- Bookmark seeking.
- Media-session metadata/background playback integration on supported mobile/Apple targets.

### Non-destructive editor

- Keep/trim selection, cut selection, split, and merge.
- Format conversion.
- Normalization, fade in/out, and silence removal.
- Gain-adjusted copies and silence insertion.
- Basic FFT noise cleanup.
- High-pass and low-pass filters.
- Compressor and limiter processing.
- Undo/redo/reset for editor selection changes.
- Original recordings are not overwritten by editor operations.

### Experience

- Material 3 responsive phone/tablet/desktop layouts.
- Light, dark, and system themes.
- Reduced-motion preference and semantic labels.
- Keyboard navigation and recorder/player desktop shortcuts.
- Branded Flutter startup screen with error recovery.
- Primary Flutter presentation centralized in the localization catalog; English is currently shipped.
- Deterministic native launcher/application branding for Android, iOS, macOS, and Windows from repository-controlled SonicNest mark geometry.
- Reproducible native Android/iOS splash resources, including Android 12+ launch configuration and light/dark launch colors.
- Debian `.deb` package integration for Linux with a desktop launcher, AppStream metadata, deterministic SonicNest icon installation, licensing notices, and checksum generation.
- About, privacy, support, GitHub, and Buy Me a Coffee integration.

### Project quality

- Reproducible host-project bootstrap for Android, iOS, macOS, Windows, and Linux.
- Reproducible native-brand generation via Bash and PowerShell helpers.
- GitHub Actions for analyzer/unit tests plus representative platform debug builds that apply native branding before Android, Windows, macOS, and iOS compilation.
- Dedicated Linux package CI builds a release-mode Flutter bundle, creates and structurally verifies the Debian package, installs it through the package manager, verifies installed metadata/payload, smoke-starts the packaged GUI under a bounded virtual display, removes the package, verifies package-owned integration cleanup, and publishes a short-retention validation artifact.
- Manual release-candidate automation includes the Linux `.deb` alongside the raw Linux bundle archive without treating either as public-release approval.
- Metadata regression tests cover invalid JSON, invalid document structure, malformed-record isolation, corrupt numeric/waveform normalization, duplicate ID/path isolation, interrupted backup recovery, corrupt-primary fallback, clean reset when no valid store remains, and a deterministic 3,000-entry filesystem round-trip.
- Managed-storage tests cover protected external paths, collision-safe path allocation, and supported managed-file discovery.
- Orphan-recovery tests cover known-entry deduplication, damaged-media best-effort reconstruction, and every represented recording format.
- Import regression tests cover successful managed import plus cleanup after selected-source copy, media-probe, and waveform-extraction failures.
- Repository integrity rejects unapproved temporary/one-shot workflow files and rejects maintained permanent workflows that request `contents: write`.
- Native-branding source revision `40c4a758debef136c2d8c977c321446cca2697cd` passed deterministic branding generation, analyzer/unit tests, Android and Linux core builds in run `31776174696`, Windows debug build in run `31776174725`, and macOS/unsigned-iOS debug builds in run `31776174715`.
- Linux Debian package source revision `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` passed release Linux compilation, Debian package construction, structural verification, desktop/AppStream validation, checksum verification, package inspection, package-manager installation, installed-payload validation, virtual-display startup smoke, package-manager removal, uninstall cleanup verification, and artifact upload in run `31785105648`.
- Metadata/import reliability revision `a88aeadadda017b0aced4dbc25c8426a27364b77` passed formatting, analyzer, unit tests, Android debug APK, and Linux debug build in core run `31807193932`; the cross-platform controller revision `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` also passed Windows run `31807141053` and Apple run `31807141166` for Windows, macOS, and unsigned-iOS debug builds.
- Managed-storage/orphan-recovery source revision `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` passed formatting, static analysis, the complete unit-test suite, Android debug APK, and Linux debug build in core run `31867130926`; Windows run `31867130920` passed; Apple run `31867130998` passed for macOS and unsigned iOS; Linux Package CI run `31867130938` passed the release build, Debian verification/install/startup/uninstall path and artifact upload.
- Repository Integrity Audit run `31867543888` passed after the managed-recovery documentation and project-state synchronization were committed.
- Apache-2.0 license, contribution/security/privacy/support documentation, architecture/build/branding/codec/Linux-packaging/metadata-integrity/QA documentation, and release procedure.

## Before v1.0.0

This preview must not be treated as a stable public recorder release until the physical-device, interruption, background, low-storage, abrupt-process/power-loss recovery, real damaged/partial-media recovery, long-recording, malformed-real-media corpus, large-library performance, batch-performance, accessibility, native-brand visual-inspection, representative Linux installation/upgrade, signed-packaging, and store-release gates in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` have been completed with real evidence.

### Batch export destination update

- Batch Convert can optionally copy successful converted files into a user-selected folder.
- Selected original recordings can also be copied directly to a user-selected folder without transcoding.
- Existing destination files are protected with collision-safe numbered names.
- External-copy failures are reported independently from managed conversion failures.
- Long conversion batches can stop safely after the current file instead of intentionally interrupting an in-progress output write.

### Native branding update

- SonicNest native launcher/splash raster sources are generated deterministically from project-controlled mark geometry rather than maintained as drifting binary source files.
- Android adaptive/full/monochrome launcher inputs, iOS icons, macOS icons, Windows icons, and Android/iOS native splash resources are generated reproducibly.
- Generated branding compiled successfully in representative Android, Windows, macOS, and unsigned-iOS debug builds.
- Final visual approval remains a real release-candidate QA task, especially for launcher masks/crops, Windows shell surfaces, Apple small icon sizes, dark-mode launch screens, Linux desktop icon surfaces, and final signed packages.

### Linux Debian packaging update

- Debian `.deb` is the initial repository-supported Linux installation format.
- The package installs the complete Flutter bundle under `/opt/sonicnest`, a freedesktop desktop entry, the generated SonicNest icon in the hicolor icon hierarchy, AppStream metadata, LICENSE, and NOTICE.
- Package construction derives the release version from `pubspec.yaml`, preserves architecture metadata, and writes a SHA-256 checksum beside the `.deb`.
- A dedicated verifier checks package control metadata, executable permissions, desktop launcher identity, AppStream identity, icon presence, and checksum integrity, with `desktop-file-validate` and `appstreamcli` validation when available.
- Linux Package CI additionally installs the generated package through `apt-get`, validates the installed payload, starts the packaged application under a bounded Xvfb display, removes the package, and verifies package-owned application/desktop/icon/AppStream cleanup.
- Recovery-hardening source `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` passed the complete current Linux package workflow in run `31867130938`.
- Stable Linux release approval still requires representative real-system installation, launch, microphone/routing, accessibility, long-duration/low-storage, icon visual, upgrade/uninstall, and distribution/signing-policy evidence.

### Metadata integrity, managed recovery, and resilient import update

- Recording metadata deserialization type-checks optional fields, filters malformed collection members, isolates malformed nested markers and recording objects, and normalizes unsafe numeric/waveform values.
- Structurally corrupt metadata documents are preserved with timestamped diagnostic copies instead of being silently discarded.
- Interrupted metadata replacement can recover a valid `recordings.json.bak`; a corrupt primary can also fall back to a valid backup after preserving the corrupt primary.
- When no valid primary/backup remains, SonicNest preserves diagnostics and writes a clean empty metadata store so the same corrupt primary does not repeatedly re-trigger recovery on every startup.
- Duplicate recording IDs and normalized file paths are isolated, and startup removes stale/out-of-bound metadata before managed orphan scanning.
- The metadata regression suite exercises a real filesystem save/load path with 3,000 entries while checking ordering/identity samples and temporary/backup cleanup.
- Audio import validation has a dedicated service that owns managed-copy validation and cleanup after probe/waveform failures.
- Multi-file import continues after isolated missing/corrupt selections and reports partial success while keeping metadata persistence failures fail-fast and transactional for the just-created managed copy.
- Managed-path mutation guards prevent metadata from directing destructive library operations at unrelated external paths.
- Rename/Trash/restore and metadata-only updates roll back their in-memory/filesystem changes when metadata persistence fails; permanent delete uses metadata-first ordering so an interrupted operation leaves an orphan that can be rediscovered rather than silently destroying unindexed audio.
- `LibraryRecoveryService` reconstructs missing metadata for supported managed recordings at startup and keeps damaged/partial preserved files visible even when duration/waveform probing cannot succeed.
- Real malformed-media corpora, abrupt-power/process-kill, low-storage/filesystem-permission recovery, real damaged/partial orphan media, and real large-library UI/memory profiling remain manual release gates rather than being inferred from synthetic tests.


## 2026-08-15 — Managed storage, recovery, batch, and release-policy hardening

This development-preview continuation tightens the local-data boundary and makes the tested batch path the production batch path. Managed recording authority now requires a supported regular audio file in SonicNest-managed active/Trash storage; symbolic links, directories, unsupported regular files, missing paths, and external paths are not trusted as recording instructions. Startup reconciliation and orphan recovery preserve active-versus-Trash state, and recording/Trash accounting follows the same supported top-level regular-audio definition.

External copy allocation is now entity-aware, so directories and broken symbolic links occupy names just like existing files. `BatchConversionService` owns sequential conversion, managed registration, optional external copy, failure isolation, generated-output cleanup, progress, and stop-after-current semantics; `BatchConvertScreen` uses that service directly. Leaving the screen requests stop after the current item instead of intentionally starting another selected conversion.

`RecorderService` now lazily creates the native `AudioRecorder` backend. Controller/service construction no longer touches the native method channel until recorder functionality is requested, which removes a unit-test/native-channel coupling without bypassing microphone permission or production recorder checks.

The project also now has explicit policy decisions for future localization and Linux distribution. Product-facing text is localized while raw OS/plugin/FFmpeg/filesystem diagnostics remain technical evidence. The initial public Linux channel is GitHub Releases with the verified Debian `.deb` and SHA-256 checksum; SonicNest does not initially operate a custom APT repository and does not claim signing that has not actually been performed with maintainer-owned credentials.

Validation evidence: core run `31870224720` is green on revision `e47b290a7255f126cfcf1436444a90cc32d10823` for static analysis, all 87 unit tests, Android debug, and Linux debug. Windows run `31870087266`, Apple run `31870087249`, and Linux Package CI run `31870087317` are green on application-code revision `72797fa477b9d88e2138b7ddf1d0f845cdd549ca`; the later `e47b290...` change corrects only a persistence test fixture.

One repository-hygiene item remains explicit: the core job currently formats 30 of 54 checked-in Dart files before analysis/tests. Behavior validation is green on the formatted checkout, but the tracked tree is not yet claimed formatter-clean. Physical-device, filesystem-failure, accessibility, long-duration, representative-package, signing, and stable-release evidence remains intentionally incomplete.
