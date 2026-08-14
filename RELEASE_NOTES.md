# SonicNest Release Notes

## v0.1.0 — Development Preview

SonicNest is an offline-first cross-platform sound and voice recorder built with Flutter. This development preview establishes the recorder, recording library, playback, editing, platform bootstrap, CI, privacy, and open-source foundations required for later stable releases.

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
- English localization-ready presentation layer for future translation expansion.
- About, privacy, support, GitHub, and Buy Me a Coffee integration.

### Project quality

- Reproducible host-project bootstrap for Android, iOS, macOS, Windows, and Linux.
- GitHub Actions for analyzer/unit tests plus representative platform debug builds.
- Source revision `985f2dd1500a03b0b65ee58b142cf31f545b0cc5` passed analyzer/unit tests and Android, Linux, Windows, macOS, and unsigned iOS debug builds.
- Apache-2.0 license, contribution/security/privacy/support documentation, architecture/build/codec/QA documentation, and release procedure.

## Before v1.0.0

This preview must not be treated as a stable public recorder release until the physical-device, interruption, background, low-storage, long-recording, batch-performance, accessibility, signed-packaging, and store-release gates in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` have been completed with real evidence.


### Batch export destination update

- Batch Convert can optionally copy successful converted files into a user-selected folder.
- Existing destination files are protected with collision-safe numbered names.
- External-copy failures are reported independently from managed conversion failures.
- Long batches can stop safely after the current file instead of intentionally interrupting an in-progress output write.
