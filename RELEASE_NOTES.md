# SonicNest Release Notes

## v0.1.0 — Development Preview

SonicNest is an offline-first cross-platform sound and voice recorder built with Flutter. This development preview establishes the recorder, recording library, playback, editing, platform bootstrap, CI, privacy, and open-source foundations required for later stable releases.

### Recorder

- Start, pause, resume, stop, save, and discard recordings.
- Runtime encoder capability checks with native capture when available and safe post-recording conversion fallback when needed.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and AAC format paths.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom presets.
- Bitrate, sample-rate, channel, automatic-gain, echo-cancellation, and noise-suppression preferences.
- Input-device enumeration and selection where the recorder backend exposes devices.
- Recording timer, waveform/amplitude display, clipping warning, and bookmarks.
- Smart recording-name templates with date, time, sequence, category, prefix, and suffix tokens.
- Android foreground recording-service integration through reproducible platform overrides.

### Library and storage

- Search recording titles, folders, tags, notes, and bookmark text.
- Sort by date, title, duration, and file size.
- Filter by scope, format, folder, tag, and date range.
- Favorites, pins, folders, tags, notes, multi-select, and bulk actions.
- Trash, restore, permanent deletion, and empty-Trash workflow.
- Import, duplicate, export copy, and system sharing.
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
- About, privacy, support, GitHub, and Buy Me a Coffee integration.

### Project quality

- Reproducible host-project bootstrap for Android, iOS, macOS, Windows, and Linux.
- GitHub Actions for analyzer/unit tests plus representative platform debug builds.
- Apache-2.0 license, contribution/security/privacy/support documentation, architecture/build/codec/QA documentation, and release procedure.

## Before v1.0.0

This preview must not be treated as a stable public recorder release until the physical-device, interruption, background, low-storage, long-recording, accessibility, signed-packaging, and store-release gates in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` have been completed with real evidence.
