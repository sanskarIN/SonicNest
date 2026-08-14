# SonicNest QA Checklist

Do not mark SonicNest release-ready until these checks have been executed on representative target hardware. Automated compilation is necessary but it is not a substitute for microphone, storage, interruption, routing, accessibility, or long-duration validation.

## Automated source checks

- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze --no-fatal-infos`
- [ ] `flutter test`
- [ ] Android debug build succeeds.
- [ ] Linux debug build succeeds.
- [ ] Windows debug build succeeds.
- [ ] macOS debug build succeeds.
- [ ] unsigned iOS debug build succeeds.

## Startup and migration

- [ ] Fresh install opens through the SonicNest branded startup experience.
- [ ] Startup failure state is readable and retry works.
- [ ] Existing metadata/settings from an older development build load without data loss.
- [ ] Legacy recording settings that do not contain smart-naming fields receive safe defaults.
- [ ] Light, dark, and system theme selection remains correct across restart.

## Recording basics

- [ ] Start -> Stop saves a playable recording.
- [ ] Start -> Pause -> Resume -> Stop preserves elapsed time and audio.
- [ ] Start -> Discard removes the unfinished recording.
- [ ] Repeated rapid taps do not start duplicate recorders.
- [ ] Failed capture leaves no false library entry.
- [ ] Failed capture cleans its temporary output where possible.
- [ ] Recording markers/bookmarks save with the recording.
- [ ] Waveform/amplitude display updates while recording.
- [ ] Clipping indication reacts to a deliberately high input level.
- [ ] Recorder error acknowledgement returns to a usable idle state.

## Countdown and screen-wake preference

- [ ] 3-second countdown displays 3 -> 2 -> 1 -> recording.
- [ ] 5-second countdown displays the complete countdown.
- [ ] 10-second countdown displays the complete countdown.
- [ ] Cancel during countdown returns to idle without creating a file.
- [ ] F9 starts a countdown when configured.
- [ ] F9 cancels an active countdown.
- [ ] Pause/resume controls are unavailable until capture has actually started.
- [ ] `Keep screen awake` prevents display sleep during active capture on a supported physical device.
- [ ] Screen-wake state is released after Stop.
- [ ] Screen-wake state is released after Discard.
- [ ] Screen-wake state is released after recorder failure.
- [ ] Disabling the preference allows normal device screen-sleep behavior.

## Permission and interruption

Test on Android, iOS, macOS, Windows, and Linux where applicable:

- [ ] First permission grant.
- [ ] Permission denied.
- [ ] Permission revoked in OS settings.
- [ ] Microphone unavailable/in-use case produces a recoverable error.
- [ ] Incoming call/audio interruption behavior is verified.
- [ ] Alarm/audio-focus interruption behavior is verified.
- [ ] App background/foreground transition while recording.
- [ ] Screen lock/unlock while recording.
- [ ] Android foreground-service notification behavior.
- [ ] iOS background recording behavior under current OS policy.

## Input routing

Where hardware is available:

- [ ] Built-in microphone.
- [ ] Wired headset microphone.
- [ ] USB microphone/interface.
- [ ] Bluetooth microphone route.
- [ ] Switch input before recording.
- [ ] Verify input selection cannot be changed mid-recording when unsafe.
- [ ] Disconnect selected input during recording and verify recovery/error behavior.
- [ ] Reconnect Bluetooth/headset and verify the next recording can select it.

## Codec matrix

Test representative files for:

- [ ] M4A/AAC.
- [ ] WAV.
- [ ] FLAC.
- [ ] Opus.
- [ ] MP3 conversion fallback.
- [ ] OGG/Vorbis conversion fallback.
- [ ] raw AAC conversion fallback.
- [ ] Unsupported direct encoders use a supported intermediate capture format.
- [ ] Post-transcode removes the temporary capture file.
- [ ] Resulting files play in SonicNest and at least one external player per platform.

Verify on each target platform which settings are honored by the native recorder backend:

- [ ] Bitrate.
- [ ] Sample rate.
- [ ] Mono/stereo.
- [ ] Automatic gain.
- [ ] Echo cancellation.
- [ ] Noise suppression.

## Smart filename templates

- [ ] Default `{prefix}_{date}_{time}` template produces a valid unique filename.
- [ ] `{sequence}` increases without overwriting an existing recording or Trash item.
- [ ] `{category}` token renders the configured category.
- [ ] `{suffix}` token renders the configured suffix.
- [ ] Individual year/month/day/hour/minute/second tokens render correctly.
- [ ] Empty optional tokens do not leave repeated separators.
- [ ] Invalid filesystem characters are sanitized.
- [ ] Windows reserved names remain protected.
- [ ] Long names remain within safe filename limits.

## Recording library

- [ ] Search title.
- [ ] Search tag.
- [ ] Search notes.
- [ ] Search folder.
- [ ] Search bookmark/marker text.
- [ ] Sort newest/oldest.
- [ ] Sort title A-Z/Z-A.
- [ ] Sort duration.
- [ ] Sort file size.
- [ ] Filter by format.
- [ ] Filter by folder.
- [ ] Filter by exact tag.
- [ ] Filter from a selected date.
- [ ] Filter through a selected end date.
- [ ] Combined tag/date filtering behaves correctly.
- [ ] Clear advanced filters restores all matching scope entries.
- [ ] Favorite and unfavorite.
- [ ] Pin and unpin.
- [ ] Edit folder, tags, and notes.
- [ ] Rename keeps metadata and file consistent.
- [ ] Duplicate creates a new independent file and metadata ID.
- [ ] Import supported files.
- [ ] Reject unsupported import extensions.
- [ ] Export a copy to a user-selected path.
- [ ] Share one recording.
- [ ] Multi-select visible recordings.
- [ ] Select all visible recordings.
- [ ] Bulk favorite/unfavorite.
- [ ] Bulk pin/unpin.
- [ ] Bulk share.
- [ ] Bulk Trash/restore/delete.

## Trash and deletion

- [ ] Move to Trash preserves recoverable metadata.
- [ ] Restore allocates a non-colliding destination name.
- [ ] Permanent delete removes file and metadata.
- [ ] Empty Trash removes all Trash entries.
- [ ] Active playback stops before deleting the loaded file.
- [ ] Confirmation behavior matches the user preference.

## Managed storage

- [ ] Settings reports recording bytes/count accurately for a representative library.
- [ ] Trash bytes/count changes after Trash and restore operations.
- [ ] Temporary processing bytes/count changes after creating temporary media.
- [ ] Temporary cleanup removes stale temporary files when no recording is active.
- [ ] Temporary cleanup is blocked while recording.
- [ ] Files that are actively used by a platform codec are not destructively forced closed.

## Playback

- [ ] Load/play/pause/stop.
- [ ] Seek from beginning, middle, and near end.
- [ ] Jump backward/forward.
- [ ] Playback speeds 0.5x through 2x.
- [ ] Volume control.
- [ ] Repeat-one.
- [ ] Previous recording navigation.
- [ ] Next recording navigation.
- [ ] Previous/next excludes Trash entries.
- [ ] A-B loop seeks back to A at B.
- [ ] A-B loop handles a narrow valid selection.
- [ ] Clearing A-B loop returns to normal playback.
- [ ] Enabling repeat-one clears A-B loop safely.
- [ ] Bookmark seeking.
- [ ] Skip-silence on a supported backend.
- [ ] Skip-silence failure is graceful on unsupported backends.
- [ ] Media-session metadata matches the loaded recording where supported.
- [ ] Lock-screen/notification play-pause controls work where supported.
- [ ] Headphone/Bluetooth media buttons behave correctly where supported.

## Non-destructive editor

- [ ] Drag selection start handle on waveform.
- [ ] Drag selection end handle on waveform.
- [ ] Range slider and waveform handles remain synchronized.
- [ ] Selection undo.
- [ ] Selection redo.
- [ ] Selection reset.
- [ ] Keep selection as new copy.
- [ ] Cut selection from a new copy without modifying the original.
- [ ] Split produces two usable outputs.
- [ ] Merge creates a usable output from compatible input media.
- [ ] Normalize creates a playable new file.
- [ ] Fade in/out creates a playable new file.
- [ ] Silence removal creates a playable new file.
- [ ] Gain decrease creates a quieter valid copy.
- [ ] Gain increase creates a louder valid copy without processing failure.
- [ ] Silence insertion creates the expected timing shift.
- [ ] Bookmark times after inserted silence shift correctly.
- [ ] Bookmark times after cut are removed/shifted correctly.
- [ ] Basic noise cleanup creates a playable copy.
- [ ] Compressor creates a playable copy.
- [ ] Limiter creates a playable copy.
- [ ] High-pass filter creates a playable copy.
- [ ] Low-pass filter creates a playable copy.
- [ ] Export presets create expected target formats.
- [ ] Failed processing does not add a broken library entry.
- [ ] Original file remains bit-for-bit untouched by editor actions.

## Desktop shortcuts

- [ ] Ctrl+1 Home.
- [ ] Ctrl+2 Recorder.
- [ ] Ctrl+3 Library.
- [ ] Ctrl+4 Settings.
- [ ] Ctrl+5 About.
- [ ] F9 starts/stops recording or cancels countdown as appropriate.
- [ ] F10 pauses/resumes active recording.
- [ ] Ctrl+Alt+P toggles playback when a recording is loaded.
- [ ] Ctrl+Alt+Left jumps backward.
- [ ] Ctrl+Alt+Right jumps forward.
- [ ] Shortcuts do not unexpectedly destroy text input while editing metadata/settings.

## Accessibility and responsive UI

- [ ] 320-360px-wide phone layout has no overflow.
- [ ] Tablet layout.
- [ ] Narrow desktop window.
- [ ] Wide desktop window.
- [ ] Large text/font scaling.
- [ ] System dark mode.
- [ ] System light mode.
- [ ] Reduced-motion preference.
- [ ] Keyboard-only navigation on desktop.
- [ ] Focus order is understandable.
- [ ] Action controls have useful semantics/tooltips.
- [ ] Countdown announcements are understandable with screen readers.
- [ ] TalkBack audit on Android.
- [ ] VoiceOver audit on iOS.
- [ ] VoiceOver audit on macOS.
- [ ] Narrator audit on Windows.
- [ ] Linux assistive-technology audit.

## Localization readiness

- [ ] App starts with the supported English locale.
- [ ] Primary navigation obtains labels from the localization layer.
- [ ] Startup presentation obtains visible strings from the localization layer.
- [ ] Unsupported device locales fall back to English without startup failure.
- [ ] Before adding another language, migrate remaining hard-coded presentation strings and test text expansion.

## Low-storage and filesystem failure

- [ ] Begin recording with low free storage.
- [ ] Exhaust storage during a long recording in a controlled test environment.
- [ ] Fail an editor/export operation due to storage limits.
- [ ] Attempt import from an inaccessible/deleted source.
- [ ] Verify metadata is not persisted for a file that was never successfully created.
- [ ] Verify the app can recover after storage is made available again.

## Soak and performance

- [ ] 30-minute voice recording.
- [ ] Multi-hour recording where practical.
- [ ] Repeated start/stop cycle stress test.
- [ ] Repeated pause/resume cycle stress test.
- [ ] Large waveform extraction.
- [ ] Hundreds of recordings library behavior.
- [ ] Thousands of metadata entries library behavior.
- [ ] Long-audio seeking and editor operations do not exhibit uncontrolled memory growth.

## Privacy and release

- [ ] No recording upload occurs without an explicit user action.
- [ ] No analytics/telemetry dependency was introduced unintentionally.
- [ ] Privacy documentation matches the shipping build.
- [ ] Support/contact/Buy Me a Coffee links open correctly.
- [ ] Dependency licenses are reviewed.
- [ ] Real screenshots are captured from a tested release candidate.
- [ ] App-icon and launch assets are checked on each platform.
- [ ] Release notes match the tested source revision.
- [ ] Signing credentials are stored outside the repository.
- [ ] Release package is built from the tagged commit.
- [ ] Checksums are generated for downloadable artifacts where appropriate.

## Release rule

A checkbox is evidence, not decoration. If a test requires physical hardware, a platform account, signing identity, store dashboard, external device, screen reader, or long-running test, leave it unchecked until that test has actually been performed and recorded.


## External-folder batch export

- [ ] Choose an external destination folder on every supported platform where the picker exposes this capability.
- [ ] Export several converted copies and verify destination filenames/extensions.
- [ ] Pre-create a destination filename and verify `(2)`, `(3)`, etc. collision-safe naming.
- [ ] Remove/revoke the selected destination before copy and verify the managed library output remains valid.
- [ ] Trigger an external-copy failure and verify conversion success/failure counts remain correct.
- [ ] Request Stop after current file during a long conversion and verify the current output completes before the next item is skipped.
- [ ] Verify already completed outputs are not rolled back after a stop request.
