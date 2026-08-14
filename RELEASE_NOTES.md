# SonicNest Release Notes

## v0.1.0 — Development Preview

SonicNest is an offline-first cross-platform sound and voice recorder built with Flutter. This development preview establishes the recorder, recording library, playback, editing, native branding, Linux packaging, metadata recovery, resilient import, platform bootstrap, CI, privacy, and open-source foundations required for later stable releases.

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
- Structurally corrupt metadata is preserved to timestamped diagnostic copies, and valid `.bak` metadata can recover an interrupted replacement or a corrupt primary.
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
- Metadata regression tests cover invalid JSON, invalid document structure, malformed-record isolation, interrupted backup recovery, corrupt-primary fallback, and a deterministic 3,000-entry filesystem round-trip.
- Import regression tests cover successful managed import plus cleanup after selected-source copy, media-probe, and waveform-extraction failures.
- Repository integrity now rejects unapproved temporary/one-shot workflow files and rejects maintained permanent workflows that request `contents: write`.
- Native-branding source revision `40c4a758debef136c2d8c977c321446cca2697cd` passed deterministic branding generation, analyzer/unit tests, Android and Linux core builds in run `31776174696`, Windows debug build in run `31776174725`, and macOS/unsigned-iOS debug builds in run `31776174715`.
- Linux Debian package source revision `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` passed release Linux compilation, Debian package construction, structural verification, desktop/AppStream validation, checksum verification, package inspection, package-manager installation, installed-payload validation, virtual-display startup smoke, package-manager removal, uninstall cleanup verification, and artifact upload in run `31785105648`.
- Metadata/import reliability revision `a88aeadadda017b0aced4dbc25c8426a27364b77` passed formatting, analyzer, unit tests, Android debug APK, and Linux debug build in core run `31807193932`; the cross-platform controller revision `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` also passed Windows run `31807141053` and Apple run `31807141166` for Windows, macOS, and unsigned-iOS debug builds.
- Repository integrity run `31807662729` passed on revision `c7b9c41a8afcf83ff03ae5a014c9968f2f09c5e4` after the permanent workflow allowlist/read-only invariant and cleanup of obsolete one-shot workflows were active.
- Apache-2.0 license, contribution/security/privacy/support documentation, architecture/build/branding/codec/Linux-packaging/metadata-integrity/QA documentation, and release procedure.

## Before v1.0.0

This preview must not be treated as a stable public recorder release until the physical-device, interruption, background, low-storage, long-recording, malformed-real-media corpus, large-library performance, batch-performance, accessibility, native-brand visual-inspection, representative Linux installation/upgrade, signed-packaging, and store-release gates in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` have been completed with real evidence.

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
- The latest automated package source is `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` from Linux Package CI run `31785105648`.
- Stable Linux release approval still requires representative real-system installation, launch, microphone/routing, accessibility, long-duration/low-storage, icon visual, upgrade/uninstall, and distribution/signing-policy evidence.

### Metadata integrity and resilient import update

- Recording metadata deserialization now type-checks optional fields, filters malformed collection members, and isolates malformed nested markers and recording objects.
- Structurally corrupt metadata documents are preserved with timestamped diagnostic copies instead of being silently discarded.
- Interrupted metadata replacement can recover a valid `recordings.json.bak`; a corrupt primary can also fall back to a valid backup after preserving the corrupt primary.
- The metadata regression suite exercises a real filesystem save/load path with 3,000 entries while checking ordering/identity samples and temporary/backup cleanup.
- Audio import validation now has a dedicated service that owns managed-copy validation and cleanup after probe/waveform failures.
- Multi-file import continues after isolated missing/corrupt selections and reports partial success while keeping metadata persistence failures fail-fast and transactional for the just-created managed copy.
- Real malformed-media corpora, abrupt-power/low-storage/filesystem-permission recovery, and real large-library UI/memory profiling remain manual release gates rather than being inferred from synthetic tests.
