# SonicNest User Guide

SonicNest is an offline-first sound and voice recorder for Android, iOS, macOS, Windows, and Linux. This guide describes the implemented application behavior in the current development preview. Hardware-dependent capabilities can vary by platform and device.

## 1. Home

Home provides a quick view of your local recording library:

- total saved recording count;
- total recorded duration;
- managed local storage used by saved recordings;
- Quick Record access;
- Batch Convert access;
- recent recordings.

Opening a recent recording starts the integrated playback flow. Use **View all** to move to the complete Library.

## 2. Create a recording

Open **Recorder** from the main navigation.

### Choose a quality preset

Available preset families include:

- Speech;
- Meeting;
- Lecture;
- Interview;
- Podcast;
- Music;
- High Quality;
- Lossless;
- Small File;
- Custom.

Presets provide sensible combinations of format, bitrate, sample rate, channels, and recorder processing preferences. Actual encoder/settings support depends on the active platform recorder backend.

### Choose an input

Where the recorder backend exposes input devices, SonicNest can enumerate available inputs before recording. Select the intended microphone before starting capture.

Input switching during an active recording should not be treated as universally safe; stop the recording first unless platform QA proves otherwise.

### Countdown

Settings can enable a 3, 5, or 10 second countdown. During countdown:

- no saved recording is created yet;
- the remaining time is displayed;
- the countdown can be cancelled;
- recorder pause/resume/bookmark controls remain unavailable until capture actually starts.

### Start, pause, resume, and stop

1. Press **Start recording**.
2. Wait for any configured countdown.
3. Use **Pause** and **Resume** when needed.
4. Use **Add marker** to place a bookmark at the current recording position.
5. Press **Stop & save** to finalize the recording.

The recorder shows elapsed time, live amplitude/waveform information, and a clipping warning when the sampled input level approaches the clipping threshold.

### Discard

Use **Discard** to cancel the active capture. SonicNest attempts to clean unfinished capture files and does not intentionally add a discarded capture to the Library.

## 3. Formats and encoder fallbacks

SonicNest represents these target formats:

- M4A/AAC;
- WAV;
- FLAC;
- Opus;
- MP3;
- OGG/Vorbis;
- AAC.

Direct recording support differs by OS/device/backend. SonicNest checks requested encoder support. When direct capture is unavailable, supported intermediate capture plus post-recording conversion may be used instead of falsely claiming native support.

Always perform platform-specific listening and external-player checks before relying on a codec path for an important recording.

## 4. Smart recording names

Settings include configurable naming fields and template tokens.

Supported template tokens include:

- `{prefix}`;
- `{suffix}`;
- `{category}`;
- `{date}`;
- `{time}`;
- `{year}`;
- `{month}`;
- `{day}`;
- `{hour}`;
- `{minute}`;
- `{second}`;
- `{sequence}`.

Rendered names pass through SonicNest filename sanitization. Empty optional values are cleaned up and final filesystem allocation remains collision-safe.

Example:

```text
{category}_{date}_{sequence}
```

could produce a safe name such as:

```text
Lecture_2026-08-14_004
```

## 5. Library

Library is the main recording-management surface.

### Search

Search covers available metadata including:

- title;
- folder;
- tags;
- notes;
- bookmark labels/notes.

### Scopes

Use the scope selector to view:

- All;
- Favorites;
- Pinned;
- Trash.

### Sort

Available sort modes include:

- newest/oldest;
- name A–Z/Z–A;
- longest/shortest;
- largest/smallest file.

### Filters

Library supports:

- format filtering;
- folder filtering;
- exact tag filtering;
- from-date filtering;
- through-date filtering;
- combined advanced filters.

Use **Clear filters** to remove advanced tag/date restrictions.

### Recording actions

Depending on whether the item is active or in Trash, actions include:

- Play;
- Edit audio;
- Rename;
- Tags, folder & notes;
- Pin/Unpin;
- Favorite/Unfavorite;
- Duplicate;
- Share;
- Export copy;
- Move to Trash;
- Restore;
- Delete permanently.

On desktop pointer devices, secondary/right-click opens the same recording action surface as the explicit action menu.

## 6. Multi-selection

Long-press/select a recording to enter multi-selection. Available bulk operations depend on the current scope and include:

- select all visible;
- favorite/unfavorite;
- pin/unpin;
- share;
- move to Trash;
- restore;
- permanent delete.

Permanent deletion is irreversible. If confirmation is enabled in Settings, SonicNest asks before destructive deletion.

## 7. Trash

Moving a recording to Trash keeps it recoverable until permanent deletion.

From Trash you can:

- restore individual recordings;
- restore selected recordings;
- permanently delete individual/selected recordings;
- empty Trash.

Restored filenames are allocated safely if a file with the original name already exists.

SonicNest also protects destructive library operations with a managed-storage boundary. Metadata cannot direct rename, duplicate, Trash, restore, or permanent-delete operations at unrelated files outside SonicNest's own managed audio locations.

## 8. Import, share, and export

### Import

Library can import supported audio files selected through the platform picker. Each selected file is copied into managed storage, media duration is probed, and a persisted waveform envelope is generated before the imported item is registered in the Library.

Multi-file import is failure-isolated. If one selected file is missing, cannot be copied, cannot be probed as audio, or fails waveform extraction:

- its incomplete managed copy is removed when one was created;
- that failure is recorded for the import summary;
- later selected files are still attempted;
- already completed imports remain saved;
- SonicNest reports how many selected files succeeded and names a limited set of failed selections.

A metadata-save failure is treated differently from a malformed audio file. SonicNest removes the just-created managed copy and stops the operation rather than claiming a Library item was safely registered when persistence failed.

Real malformed-audio corpus behavior across every supported operating system/backend remains part of release QA even though deterministic failure-isolation tests are included in the repository.

### Share

Single or multiple recordings can be passed to the platform share surface. Sharing is always an explicit user action.

### Export one copy

**Export copy** copies a selected recording to a user-selected destination without modifying the managed original.

### Direct multi-file original export

Open **Batch Convert**, select multiple saved recordings, then use the direct **Export copy** action to copy the selected originals to one chosen folder without transcoding.

Behavior:

- originals stay unchanged;
- existing destination files are not intentionally overwritten;
- numbered collision-safe names are allocated;
- one missing/failed source does not intentionally roll back successful copies;
- a summary reports completed/failed copies.

Real platform directory-picker, permission-revocation, low-storage, and very-large-batch behavior remain release QA gates.

## 9. Batch conversion

Open **Batch Convert** from Home.

1. Select one or more non-Trash recordings.
2. Choose the target format.
3. Optionally choose an external destination folder.
4. Start conversion.

SonicNest processes the selected entries sequentially:

- each successful conversion becomes a new managed Library entry;
- the source recording remains unchanged;
- markers are retained where appropriate;
- failures are isolated per file;
- optional external-copy failures are reported independently from successful managed conversions.

### Stop after current file

During conversion, **Stop after current file** asks SonicNest to finish the in-progress conversion safely and not begin another selected item. This is intentionally different from abruptly terminating an output write.

## 10. Playback

The integrated player supports:

- play/pause/stop;
- seek;
- configured jump backward/forward;
- volume;
- playback speed;
- repeat-one;
- previous/next non-Trash recording;
- A–B selection loop;
- bookmarks;
- optional skip-silence where the backend supports it.

### A–B loop

Choose an A–B range to repeatedly play a selected section. Repeat-one and A–B mode are kept mutually consistent.

### Media-session controls

Android, iOS, and macOS have media-session metadata/control integration in the current source. Real lock-screen/notification/Control Center/media-button behavior must still be verified on physical target hardware before stable release.

## 11. Audio Editor

Editor operations are non-destructive: they create new managed files instead of overwriting the source.

### Selection operations

- drag selection handles on the waveform;
- adjust with the range slider;
- Undo/Redo selection changes;
- Reset selection;
- Keep selection as copy;
- Cut selection from copy.

### Processing operations

Implemented processing paths include:

- Split;
- Merge;
- Normalize;
- Fade in/out;
- Remove silence;
- Insert silence;
- Gain adjustment;
- Basic FFT-domain noise cleanup;
- Compressor;
- Limiter;
- High-pass filter;
- Low-pass filter;
- Format conversion/export presets.

Bookmark timing is adjusted for implemented cut/silence-insertion operations where time is removed or inserted.

Advanced processing presets are functional tools, not a promise of mastering-grade audio. Listening tests remain important for representative voice/music material.

## 12. Settings

### Recording

Settings include:

- quality preset;
- format;
- bitrate;
- sample rate;
- mono/stereo;
- automatic gain preference;
- echo-cancellation preference;
- noise-suppression preference;
- smart naming fields/template;
- countdown;
- keep-screen-awake during active recording.

Some recorder processing settings are requests to the native backend and can be ignored when the platform does not support them.

### Playback

- default playback speed;
- jump interval;
- skip-silence default.

### Appearance and accessibility

- System/Light/Dark theme;
- Reduce motion.

### Safety and storage

- permanent-delete confirmation;
- managed recording/Trash/temporary storage statistics;
- temporary-audio cleanup when safe.

Temporary cleanup is disabled while an active recording could depend on temporary files.

## 13. Local metadata and managed recording recovery

SonicNest keeps recording-library metadata in a local JSON document separate from the audio files. The persistence layer uses a temporary file and a short-lived backup during replacement.

On startup:

- malformed optional fields fall back to safe values instead of crashing the whole Library;
- malformed individual recording objects are isolated so valid neighboring entries can still load;
- negative/non-finite duration, size, bitrate, sample-rate, channel, and marker-position metadata is normalized safely;
- non-finite waveform samples are discarded and finite recovered waveform values are bounded to the supported range;
- duplicate recording IDs and duplicate normalized file paths keep the first valid record and isolate later duplicates;
- structurally corrupt metadata is copied to a collision-safe timestamped `.corrupt.*` diagnostic file;
- if an interrupted replacement left a valid `recordings.json.bak`, SonicNest can restore that backup to the primary metadata path;
- a corrupt primary can fall back to a valid backup after preserving the corrupt primary for diagnosis;
- if neither primary nor backup can be recovered, SonicNest preserves corrupt diagnostics and writes a clean valid empty metadata document rather than repeatedly loading the same corrupt primary;
- metadata entries pointing outside SonicNest-managed recording/Trash storage, or to managed files that no longer exist, are removed during startup reconciliation;
- supported audio files still present at the top level of SonicNest's managed `Recordings` directory but missing from metadata are reconstructed as recovered Library entries.

### Recovered recordings

A reconstructed entry receives the `Recovered` tag and a recovery note. SonicNest reuses the managed filename, filesystem size, and modification time, then best-effort probes duration and waveform information.

If a preserved file is partially written or damaged enough that media probing fails, SonicNest can still keep the managed file visible with unknown technical metadata so it can be inspected, exported, renamed, or intentionally deleted rather than remaining a hidden orphan.

This recovery path is designed to preserve user audio after an interrupted metadata update. It does not recreate audio bytes that were externally deleted or irreversibly damaged.

### Persistence-safe mutations

Library metadata and managed file operations are coordinated so avoidable split states can be rolled back:

- metadata-only edits restore their previous in-memory value if persistence fails;
- rename, move-to-Trash, and restore move the file back when their matching metadata save fails;
- settings restore their previous in-memory snapshot if persistence fails;
- generated/processed output registration removes an unregistered output after persistence failure;
- permanent deletion persists metadata removal before deleting the managed file, preferring a recoverable orphan over irreversible loss if an interruption occurs between those steps;
- if managed file deletion fails while the file still exists, the metadata entry is restored and persisted again.

See `docs/METADATA_INTEGRITY.md` for the exact repository invariants and deterministic test coverage. Real low-storage, permission-revocation, abrupt-process/power-loss, and partially written-media behavior remains release QA work on representative target systems.

## 14. Desktop keyboard shortcuts

- `Ctrl+1`: Home
- `Ctrl+2`: Recorder
- `Ctrl+3`: Library
- `Ctrl+4`: Settings
- `Ctrl+5`: About
- `F9`: start/stop recording, or cancel countdown
- `F10`: pause/resume active recording
- `Ctrl+Alt+P`: play/pause loaded recording
- `Ctrl+Alt+Left`: configured jump backward
- `Ctrl+Alt+Right`: configured jump forward

Keyboard behavior must be checked with actual text fields/focus/navigation during desktop release QA.

## 15. Privacy

SonicNest is designed around local recording storage.

- Microphone capture is not automatically uploaded.
- There is no intended hidden analytics/telemetry flow in the core project.
- External sharing/export occurs through explicit user actions.
- Signing credentials and store secrets must not be stored in the repository.

See `PRIVACY.md` and `SECURITY.md` for project policy details.

## 16. Native branding and startup

Before Flutter paints, supported generated hosts use reproducible SonicNest native launcher/splash resources. After Flutter starts, SonicNest shows its branded Flutter startup screen while local settings/metadata initialize.

Native branding is generated from repository-controlled mark geometry. Structural generation/build validation does not replace real visual inspection on launchers, Dock, Finder, Windows shell surfaces, or signed release candidates.

See `docs/BRANDING.md`.

## 17. Development preview limitations

The current source has extensive automated compile/test coverage, but stable release still requires evidence for:

- physical microphone permissions/routing;
- calls/alarms/audio interruptions;
- background/lock-screen behavior;
- low-storage recovery;
- real permission-revocation and abrupt process/power-loss recovery behavior;
- real recovered-orphan behavior with playable, partially written, and damaged media;
- real malformed-audio imports across maintained target systems;
- long recordings and very large libraries/batches;
- TalkBack/VoiceOver/Narrator/Linux accessibility audits;
- real native-brand visual inspection;
- real screenshots;
- production signing/notarization;
- final package/store review.

Do not treat a CI artifact as a stable public release solely because it compiled.

## 18. Getting help

Use the support/contact links shown in the application About screen and repository `SUPPORT.md`. When reporting a hardware or release-QA problem, include the exact commit SHA, platform/OS version, device description, build source, steps performed, expected result, and actual result. The repository includes a structured **Device / Release QA report** issue form and `docs/RELEASE_EVIDENCE_TEMPLATE.md` for this purpose.
