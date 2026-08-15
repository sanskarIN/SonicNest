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

These generic checkboxes are intended to be executed again for the exact release-candidate revision. Current repository evidence for completed reliability continuations is recorded separately below so one historical CI run is not mistaken for final-release approval.

### Repository reliability automation evidence

- [x] Malformed optional recording metadata is covered by tolerant decoder regression tests.
- [x] Malformed individual metadata records are isolated while valid neighboring entries remain loadable.
- [x] Structurally invalid metadata documents are preserved to timestamped diagnostic copies.
- [x] Interrupted replacement recovery from a valid `recordings.json.bak` is covered by filesystem tests.
- [x] Corrupt-primary fallback to a valid backup is covered while preserving the corrupt primary for diagnosis.
- [x] Corrupt primary and backup documents with no valid recovery source are both preserved before a clean valid metadata store is written.
- [x] A recovered/reset corrupt primary is not copied repeatedly on every later startup.
- [x] Duplicate recording IDs and duplicate normalized file paths keep the first valid metadata record and isolate later duplicates.
- [x] Negative/non-finite duration, size, bitrate, sample-rate, channel, and marker-position metadata is normalized safely.
- [x] Non-finite waveform samples are removed and recovered finite waveform values are bounded.
- [x] `channels: 0` remains available as the unknown imported-media state rather than being rewritten as invented channel data.
- [x] A deterministic 3,000-entry metadata save/load filesystem round-trip is covered by the test suite.
- [x] Managed rename, duplicate, Trash, restore, and permanent-delete operations reject unrelated external paths.
- [x] Collision-safe managed recording allocation is covered by filesystem tests.
- [x] Supported top-level managed recording discovery is covered without recursive arbitrary-directory scanning.
- [x] Managed orphan recovery skips already indexed paths and reconstructs missing supported files.
- [x] Damaged-media orphan recovery preserves the managed file as a visible recovered entry even when duration/waveform probing fails.
- [x] Managed orphan reconstruction is covered for every represented recording format.
- [x] Audio import copy failure is isolated without deleting an unrelated managed path.
- [x] Audio import probe/waveform failures remove the copied managed file.
- [x] Multi-file import controller logic continues after isolated malformed/missing audio failures while metadata-persistence failure remains fail-fast.
- [x] Metadata-only single/batch controller mutations restore previous in-memory state when persistence fails.
- [x] Rename, move-to-Trash, and restore contain rollback behavior when their matching metadata persistence fails.
- [x] Permanent delete persists metadata before managed-file deletion and restores metadata if deletion fails while the file remains present.
- [x] Core Flutter CI run `31807193932` validated source `a88aeadadda017b0aced4dbc25c8426a27364b77`: formatting, analyzer, unit tests, Android debug APK, and Linux debug build all succeeded.
- [x] Windows run `31807141053` and Apple run `31807141166` validated import-controller source `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` across Windows, macOS, and unsigned-iOS debug builds.
- [x] Managed-recovery source `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` passed formatting, analyzer, the complete unit-test suite, Android debug APK, and Linux debug build in core run `31867130926`.
- [x] Windows run `31867130920` validated the same managed-recovery source revision with a successful Windows debug build.
- [x] Apple run `31867130998` validated the same managed-recovery source revision with successful macOS and unsigned-iOS debug builds.
- [x] Linux Package CI run `31867130938` validated the same managed-recovery source revision through release build, Debian construction/verification, package-manager installation, installed-payload validation, bounded GUI startup smoke, uninstall cleanup, and artifact upload.
- [x] Repository Integrity Audit run `31867543888` validated the synchronized recovery-hardening project state and permanent workflow invariants.

- [x] Managed storage now requires a supported regular audio file and refuses symbolic links, directories, unsupported regular files, and external paths as recording authority.
- [x] Managed and external destination allocation treats ordinary files, directories, symbolic links, and broken symbolic links as occupied instead of overwriting/following them.
- [x] Recording/Trash statistics and automatic sequence counting are covered against the same supported top-level regular-audio definition used by recovery.
- [x] Active and managed-Trash orphan reconstruction plus startup removal of unsafe/missing/unsupported metadata is covered end-to-end by controller tests.
- [x] A completed stopped recording whose metadata save fails remains on disk for later orphan recovery while its unsaved in-memory entry is removed.
- [x] Failed processed-output and batch-registration cleanup is covered so a generated managed output can be removed without deleting a caller-supplied external path.
- [x] Deterministic batch conversion tests cover per-file transcode failure isolation, external-copy failure isolation, stop-before/after-current behavior, and source-setting precedence.
- [x] Recorder-service construction no longer eagerly instantiates the native recorder method channel; the backend is created only when recorder functionality is actually used.
- [x] Core Flutter CI run `31870224720` validated source/test revision `e47b290a7255f126cfcf1436444a90cc32d10823`: analyzer **SUCCESS**, complete **87/87** unit suite **SUCCESS**, Android debug build **SUCCESS**, and Linux debug build **SUCCESS**.
- [x] Windows run `31870087266`, Apple run `31870087249`, and Linux Package CI run `31870087317` are **SUCCESS** on application-code revision `72797fa477b9d88e2138b7ddf1d0f845cdd549ca`, which contains the final application code changes; `e47b290...` is a later test-only correction.
- [ ] Checked-in Dart formatting is not yet clean under the CI Flutter/Dart toolchain: core run `31870224720` formatted 30 of 54 Dart files before analysis/tests. This repository-hygiene gap is tracked in `TODO.md` and must not be represented as formatter-clean release evidence.

The automated entries above do **not** complete the unchecked real malformed-media corpus, real partially written orphan media, low-storage, permission-failure, abrupt process/power interruption, large-library UI/performance, accessibility, or physical-device gates later in this checklist.

## Startup and migration

- [ ] Fresh install opens through the SonicNest branded startup experience.
- [ ] Startup failure state is readable and retry works.
- [ ] Existing metadata/settings from an older development build load without data loss.
- [ ] Legacy recording settings that do not contain smart-naming fields receive safe defaults.
- [ ] Light, dark, and system theme selection remains correct across restart.
- [ ] A valid primary metadata file removes a stale completed `.bak` without changing valid Library entries.
- [ ] A missing primary plus valid `.bak` restores the backup on a representative real filesystem.
- [ ] A corrupt primary plus valid `.bak` preserves the corrupt primary and restores the backup on a representative real filesystem.
- [ ] Corrupt primary and backup inputs are preserved before a clean store is created when neither is usable.
- [ ] Startup reconciliation removes a deliberately stale missing-file metadata entry without touching unrelated files.
- [ ] Startup reconciliation rejects an out-of-managed-storage metadata path without modifying the external file.
- [ ] A supported orphan audio file in managed `Recordings` is reconstructed and visibly tagged `Recovered`.
- [ ] A recovered valid audio file plays/exports normally after reconstruction.
- [ ] A privacy-safe partially written/damaged managed orphan remains visible even if probing fails.
- [ ] Restart after successful orphan reconstruction does not create a duplicate recovered entry.

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
- [ ] Tampered/out-of-bound metadata cannot cause permanent deletion of an unrelated external file.
- [ ] Controlled deletion failure with the managed file still present restores the metadata entry.
- [ ] Controlled process interruption after metadata-first deletion but before file deletion is recovered as a managed orphan on next startup.

## Managed storage

- [ ] Settings reports recording bytes/count accurately for a representative library.
- [ ] Trash bytes/count changes after Trash and restore operations.
- [ ] Temporary processing bytes/count changes after creating temporary media.
- [ ] Temporary cleanup removes stale temporary files when no recording is active.
- [ ] Temporary cleanup is blocked while recording.
- [ ] Files that are actively used by a platform codec are not destructively forced closed.
- [ ] Rename refuses a source path outside managed active recordings.
- [ ] Duplicate refuses a source path outside managed recording/Trash storage.
- [ ] Move to Trash refuses a source path outside managed active recordings.
- [ ] Restore refuses a source path outside managed Trash.
- [ ] Managed delete refuses a source path outside managed recording/Trash storage.
- [ ] Collision-safe allocation never overwrites an existing same-title managed recording.

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
- [ ] Attempt import from an inaccessible/deleted source on each maintained target platform.
- [ ] Verify metadata is not persisted for a file that was never successfully created under a real filesystem failure.
- [ ] Verify the app can recover after storage is made available again.
- [ ] Exercise an interrupted metadata replacement under controlled real filesystem/process interruption and verify the recovery record.
- [ ] Force a metadata-save failure after rename and verify the file returns to its original path.
- [ ] Force a metadata-save failure after move-to-Trash and verify the file returns to active managed storage.
- [ ] Force a metadata-save failure after restore and verify the file returns to Trash.
- [ ] Interrupt the process after a managed recording exists but before metadata registration; verify next startup reconstructs exactly one `Recovered` entry.
- [ ] Interrupt permanent deletion after metadata removal but before managed file deletion; verify next startup recovers the preserved orphan.
- [ ] Revoke or deny access to a managed file during mutation and verify SonicNest surfaces a recoverable failure without deleting unrelated data.

## Malformed-media import and recovery corpus

- [ ] Import privacy-safe truncated audio files on Android.
- [ ] Import privacy-safe truncated audio files on iOS.
- [ ] Import privacy-safe truncated audio files on macOS.
- [ ] Import privacy-safe truncated audio files on Windows.
- [ ] Import privacy-safe truncated audio files on Linux.
- [ ] Include mislabeled extensions, unsupported codec/container combinations, zero-byte files, and probe failures where safe to reproduce.
- [ ] Select malformed and valid files together and verify later valid files continue after isolated failures on each target platform.
- [ ] Verify failed managed copies are cleaned and no false Library entries remain.
- [ ] Place a privacy-safe valid supported orphan file in managed `Recordings`; verify it is reconstructed once.
- [ ] Place a privacy-safe truncated/partially written supported orphan in managed `Recordings`; verify the file remains visible even when probing fails.
- [ ] Verify an unsupported extension in managed `Recordings` is not auto-indexed as audio.
- [ ] Verify nested arbitrary files are not recursively pulled into the Library by orphan recovery.

## Soak and performance

- [ ] 30-minute voice recording.
- [ ] Multi-hour recording where practical.
- [ ] Repeated start/stop cycle stress test.
- [ ] Repeated pause/resume cycle stress test.
- [ ] Large waveform extraction.
- [ ] Hundreds of recordings library behavior.
- [ ] Thousands of metadata entries library UI behavior and startup latency.
- [ ] Thousands-entry Library memory/scroll/search/filter profiling.
- [ ] Long-audio seeking and editor operations do not exhibit uncontrolled memory growth.
- [ ] Orphan scan startup cost is profiled with a large real managed recording directory.

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

A checkbox is evidence, not decoration. If a test requires physical hardware, a platform account, signing identity, store dashboard, external device, screen reader, real filesystem failure, abrupt process interruption, partially written media, or long-running test, leave it unchecked until that test has actually been performed and recorded.

## External-folder batch export

- [ ] Choose an external destination folder on every supported platform where the picker exposes this capability.
- [ ] Export several converted copies and verify destination filenames/extensions.
- [ ] Pre-create a destination filename and verify `(2)`, `(3)`, etc. collision-safe naming.
- [ ] Remove/revoke the selected destination before copy and verify the managed library output remains valid.
- [ ] Trigger an external-copy failure and verify conversion success/failure counts remain correct.
- [ ] Request Stop after current file during a long conversion and verify the current output completes before the next item is skipped.
- [ ] Verify already completed outputs are not rolled back after a stop request.

## Localization migration continuation

- [ ] Verify Home, Recorder, Library, Player, Editor, Settings, Batch Convert, About/support, and startup visible labels are sourced from the localization catalog.
- [ ] Verify Library exact-tag/from-date/through-date filters work together after the UI restoration.
- [ ] Verify secondary-click on desktop recordings opens the same safe action surface as the More button.
- [ ] Verify long localized strings do not overflow compact phone and narrow desktop layouts before adding another locale.
- [ ] Verify backend diagnostic details remain understandable when combined with localized generic error copy.

## Direct original-file batch export

- [ ] Select several saved recordings and export their originals to a user-selected directory without transcoding.
- [ ] Verify same-basename originals receive collision-safe numbered destination names.
- [ ] Verify an existing destination file is not overwritten.
- [ ] Verify one missing/unavailable source does not roll back other successful copies.
- [ ] Verify destination disappearance/permission revocation produces a recoverable result.
- [ ] Verify low-storage behavior.
- [ ] Verify very large files and large selected batches on representative target hardware.

## Native launcher and splash branding QA

Repository implementation/automation evidence:

- [x] Deterministic SonicNest brand raster generator executes in CI.
- [x] Android launcher/splash generation executes before representative Android compilation.
- [x] Windows icon generation executes before representative Windows compilation.
- [x] macOS icon generation executes before representative macOS compilation.
- [x] iOS icon/native-splash generation executes before representative unsigned-iOS compilation.
- [x] Generated branding source PNGs are reproducible and ignored as authoritative Git source.

Android real-device/release-candidate review:

- [ ] Legacy launcher icon has safe margins and no clipped microphone/sound bars.
- [ ] Adaptive icon looks correct under circle, rounded-square, squircle, and other launcher masks.
- [ ] Themed/monochrome icon remains recognizable where supported.
- [ ] Android 11-and-earlier native launch screen is visually correct.
- [ ] Android 12+ splash is centered, correctly scaled, and not cropped.
- [ ] Light and dark launch-screen backgrounds/contrast are acceptable.
- [ ] App icon appearance is checked in launcher, app info/settings, recent-apps surfaces where applicable, and notification-related surfaces that use application branding.

iOS/macOS real-device/release-candidate review:

- [ ] iOS icon is inspected on at least one real iPhone at normal home-screen scale.
- [ ] iOS icon remains readable at smaller Settings/Search/App Library surfaces.
- [ ] iOS launch screen is checked in light and dark appearance on representative device sizes.
- [ ] macOS icon is checked in Finder, Dock, Spotlight, and application-switcher surfaces.
- [ ] macOS icon remains readable at small Finder/list sizes and large Dock sizes.

Windows real-device/release-candidate review:

- [ ] Windows icon is checked in Explorer.
- [ ] Windows icon is checked in taskbar/pinned-taskbar surfaces.
- [ ] Windows icon is checked in Start/Search and shortcut surfaces.
- [ ] Final installer/package icon is checked once a distribution format is selected.

Linux Debian packaging review:

Repository implementation/automation evidence:

- [x] Debian `.deb` is selected as the initial repository-supported Linux installation format.
- [x] The deterministic SonicNest icon is installed into the hicolor icon hierarchy and referenced by the packaged desktop entry.
- [x] AppStream metadata is installed by the Debian package builder.
- [x] Package verification checks control metadata, executable permissions, desktop entry, AppStream metadata, icon presence, and SHA-256 integrity.
- [x] Historical Linux Package CI run `31783749267` validated source `f2c773e59b27a2aaac77e0590e20441ed7eba03f` through structural package verification.
- [x] Linux Package CI run `31785105648` validated source `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` through release build, `.deb` construction, structural verification, package-manager installation, installed-payload validation, bounded virtual-display startup smoke, package-manager removal, uninstall cleanup verification, and artifact upload.
- [x] Current recovery-hardening Linux Package CI run `31867130938` validated source `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` through the same complete automated release-build/package/install/startup/uninstall/artifact path.

Real-system/release-candidate review:

- [ ] Fresh-install the exact candidate `.deb` on a representative Debian-family system.
- [ ] Fresh-install the exact candidate `.deb` on a representative Ubuntu-family system.
- [ ] Verify the package checksum before installation.
- [ ] Launch SonicNest from the application menu/launcher.
- [ ] Launch SonicNest directly from `/opt/sonicnest/sonic_nest`.
- [ ] Verify launcher, menu, task-switcher, and AppStream surfaces use the expected SonicNest icon/identity.
- [ ] Verify microphone permission/capture and representative playback/import/export behavior from the installed package.
- [ ] Verify managed metadata/orphan recovery with a privacy-safe controlled scenario in the installed package.
- [ ] Verify upgrade behavior from a prior compatible candidate package.
- [ ] Verify uninstall removes the package-owned application payload and desktop integration.
- [ ] Verify no user recording/library data is silently deleted merely because the application package is removed.
- [ ] Record tested distribution version, desktop environment, architecture, exact `.deb` filename, SHA-256, and observations in the release evidence record.

Release evidence:

- [ ] Capture real screenshots from the exact tested release candidate.
- [ ] Record device/OS versions used for native-brand visual QA.
- [ ] Confirm the signed/release package still contains the reviewed native resources.
- [ ] Do not substitute generated mockups for real release-candidate screenshots.
