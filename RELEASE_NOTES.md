# SonicNest Release Notes

## v0.1.0 — Development Preview

SonicNest is an offline-first cross-platform sound and voice recorder built with Flutter. This development preview establishes the recorder, recording library, playback, editing, native branding, Linux packaging, platform bootstrap, CI, privacy, and open-source foundations required for later stable releases.

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
- Dedicated Linux package CI builds a release-mode Flutter bundle, creates the Debian package, validates its executable/metadata/icon/checksum structure, and publishes a short-retention validation artifact.
- Manual release-candidate automation includes the Linux `.deb` alongside the raw Linux bundle archive without treating either as public-release approval.
- Native-branding source revision `40c4a758debef136c2d8c977c321446cca2697cd` passed deterministic branding generation, analyzer/unit tests, Android and Linux core builds in run `31776174696`, Windows debug build in run `31776174725`, and macOS/unsigned-iOS debug builds in run `31776174715`.
- Apache-2.0 license, contribution/security/privacy/support documentation, architecture/build/branding/codec/Linux-packaging/QA documentation, and release procedure.

## Before v1.0.0

This preview must not be treated as a stable public recorder release until the physical-device, interruption, background, low-storage, long-recording, batch-performance, accessibility, native-brand visual-inspection, Linux package installation, signed-packaging, and store-release gates in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` have been completed with real evidence.

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
- Stable Linux release approval still requires representative real-system installation, launch, microphone/routing, accessibility, long-duration/low-storage, icon visual, uninstall, and distribution/signing-policy evidence.
