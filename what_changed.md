# What Changed — SonicNest

## 2026-08-14 — Complete integrated development and hardening pass

This file is the detailed continuation log for the SonicNest repository. It records implementation work, fixes, validation, known hardware-only release gates, and the exact state that should be used when development continues in another chat/session.

## Repository

- Repository: `https://github.com/sanskarIN/SonicNest`
- Branch: `main`
- Commit identity used for the development pass:
  - Name: `Sanskar`
  - Email: `sanskarin@outlook.in`
- Current application version: `0.1.0+1`
- Project license: Apache License 2.0
- Developer credit preserved in the application/repository: `Made by the Sanskar`

## Application foundation

- Flutter/Dart application architecture is implemented with separate models, services, controller, screens, reusable widgets, and core utilities.
- Material 3 responsive UI supports compact/mobile and wide/desktop navigation.
- Light, dark, and system theme modes are available.
- Reduced-motion preference and accessibility semantics are included where applicable.
- Desktop keyboard navigation supports Ctrl+1 through Ctrl+5 for Home, Recorder, Library, Settings, and About.
- Original SonicNest SVG branding is stored under `assets/logo/`.

## Recorder

Implemented:

- Microphone permission checking.
- Start, pause, resume, stop, save, cancel/discard.
- Transition guards to reduce repeated-tap race conditions.
- Runtime input-device enumeration and selection.
- Runtime encoder capability checks.
- Requested native encoding when the backend supports it.
- WAV/AAC intermediate capture fallback when the requested encoder cannot be used directly.
- Post-recording conversion for formats that require transcoding.
- Live dB-derived waveform envelope.
- Peak/clipping indication.
- Recording timer.
- Recording bookmarks/markers.
- Automatic safe filename generation.
- Android foreground recording service integration through generated-host overrides.
- Cleanup of failed/aborted capture files and foreground-service state.
- Recorder error state and recovery acknowledgement.

Target formats represented in the application:

- M4A/AAC
- WAV
- FLAC
- Opus
- MP3
- OGG/Vorbis
- AAC

Actual direct-capture availability remains dependent on the platform/device recorder backend. SonicNest uses capability checks and conversion fallbacks instead of claiming unsupported direct encoding.

## Audio processing and editor

Implemented FFmpeg-backed, non-destructive processing:

- Transcoding/format conversion.
- Trim.
- Split.
- Merge.
- Loudness normalization.
- Fade in/out.
- Silence removal.
- Output files are created as new recordings instead of overwriting the original.
- Draggable waveform trim-selection handles.
- Selection range slider.
- Selection undo, redo, and reset history.
- Common-format export preset control.
- Imported and processed media now receive persisted PCM-derived waveform envelopes rather than placeholder/no waveform data.
- PCM peak calculation was extracted to a pure utility and covered by unit tests.

## Recording library

Implemented:

- Search by title, tags, notes, folder, and bookmark text.
- Newest/oldest/name/duration/file-size sorting.
- Format filtering.
- Folder filtering.
- Favorites.
- Pins.
- Tags.
- Folders.
- Notes.
- Rename.
- Duplicate.
- Import.
- Export copy.
- Share.
- Trash.
- Restore.
- Permanent deletion.
- Empty Trash.
- Long-press/select-mode UI.
- Select-all-visible.
- Bulk add/remove favorites.
- Bulk pin/unpin.
- Bulk share.
- Bulk move to Trash.
- Bulk restore.
- Bulk permanent deletion.

File/metadata consistency was hardened so successful filesystem mutations are persisted incrementally and failed generated/imported outputs are cleaned up where possible.

## Playback

Implemented:

- Load/play/pause/stop.
- Seek.
- Jump backward/forward.
- Speed controls.
- Volume control.
- Repeat-one mode.
- Bookmark seeking.
- Optional silence skipping on backends that support it.
- Graceful unsupported-backend handling for silence skipping.
- Android, iOS, and macOS media-session metadata and notification/lock-screen transport integration through `just_audio_background`.
- Tagged `MediaItem` playback sources so OS media surfaces receive SonicNest title/album metadata.

Physical-device lock-screen, notification, interruption, and background behavior remains a manual QA gate. Dedicated Windows/Linux system-wide media-session integration is not currently claimed beyond the desktop playback backend.

## Settings

Implemented:

- Quality presets: speech, meeting, lecture, interview, podcast, music, high quality, lossless, small file, custom.
- Format selection.
- Bitrate selection.
- Sample-rate selection.
- Mono/stereo selection.
- Automatic gain preference.
- Echo cancellation preference.
- Noise suppression preference.
- Automatic filename prefix.
- Default playback speed.
- Playback jump interval.
- Default skip-silence preference.
- Theme selection.
- Reduced-motion preference.
- Permanent-delete confirmation preference.

Deprecated Flutter form APIs encountered during CI analysis were migrated to the current supported form initialization pattern used by this project.

## Persistence and safety

Implemented:

- Local recordings directory.
- Dedicated local Trash directory.
- Temporary processing/capture directory.
- Application-support JSON metadata store.
- Temporary-file + backup metadata replacement flow.
- Corrupt metadata backup behavior.
- Cross-platform-safe filename sanitization.
- Windows reserved-name protection.
- Duplicate filename allocation.
- Transactional-style controller hardening for import, generated processing outputs, duplicate, Trash, restore, permanent delete, and empty-Trash operations.

## Platform bootstrap

The repository intentionally generates Flutter host projects from the installed Flutter SDK instead of committing a large stale generated-host tree.

Implemented:

- `tool/bootstrap_platforms.sh` for Bash-capable environments.
- `tool/bootstrap_platforms.ps1` for Windows PowerShell.
- Stable organization/application namespace: `io.github.sanskarin`.
- Android manifest/activity/foreground-service overrides.
- iOS microphone usage description and audio background mode patch.
- macOS microphone entitlement/usage-description patch.
- Generated Windows and Linux application-title patches.
- Removal of Flutter's generated demo `widget_test.dart` so it cannot conflict with the SonicNest test suite.

Important namespace correction:

- The earlier generated organization `in.sanskar` caused an Android namespace failure because the leading `in` segment was rejected by the current Android build setup.
- Platform generation was standardized on `io.github.sanskarin`.
- Android Kotlin override packages and the Dart MethodChannel were aligned with the corrected namespace.

## Dependency compatibility fixes

`file_picker` required compatibility work during Android validation.

Final project constraint:

- `file_picker: 10.3.10`

The application uses `FilePicker.platform.pickFiles(...)` and `FilePicker.platform.saveFile(...)` for that compatible release. A temporary static-API migration made during this continuation was immediately superseded after reconciling the repository's intentionally pinned compatibility version.

`share_plus` remains on the dependency line compatible with the selected file picker / Windows dependency graph.

## CI and automated validation

### Previous fully green baseline

Core Flutter CI:
- Run ID: `31766868164`
- Source commit: `f2560ef02a1f046197188bd1e5112d43176a2b46`
- Analyzer: SUCCESS
- Unit tests: SUCCESS
- Android debug APK: SUCCESS
- Linux debug build: SUCCESS

Windows CI:
- Run ID: `31767240173`
- Windows debug build: SUCCESS

Apple CI:
- Run ID: `31767248520`
- macOS debug build: SUCCESS
- iOS debug no-codesign build: SUCCESS

### Latest code-validation cycle recorded before the advanced continuation

Source code commit under validation at that point: `59fe40b761ad52920d8640a4edb23b680db234c8`.

Core Flutter CI run `31769582811` reached:
- Platform host generation: SUCCESS
- `flutter pub get`: SUCCESS
- Dart formatting: SUCCESS
- Flutter static analysis: SUCCESS
- Unit tests: SUCCESS
- Linux debug build subsequently completed successfully.
- The Android build from that specific run was cancelled by a newer commit while compiling, not recorded as a source failure.

Windows run `31769582816` subsequently completed successfully.

Apple run `31769582823` subsequently completed successfully for macOS and unsigned iOS.

New commits trigger replacement workflow runs because the repository uses concurrency cancellation.

Automated compilation does not substitute for microphone hardware testing, interruption/background testing, long-duration recording tests, low-storage behavior, audio routing, accessibility testing with real assistive technologies, or signed store/release packaging.

## Tests present before the advanced continuation

- Safe filename sanitization and extension replacement.
- Windows reserved filename handling.
- Recording metadata JSON serialization/copy behavior.
- Recording settings presets, serialization, bounds, and format/transcoding decisions.
- PCM signed-16-bit little-endian peak extraction including silence, positive/negative full-scale, largest-absolute-sample selection, and incomplete trailing-byte handling.

## GitHub/open-source project files

Present and maintained:

- `README.md`
- `LICENSE`
- `NOTICE`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `PRIVACY.md`
- `SUPPORT.md`
- `ROADMAP.md`
- `PROJECT_STATE.md`
- `what_changed.md`
- issue templates
- pull request template
- CI workflows
- architecture/build/codec/QA documentation

## Important commits from the earlier continuation/hardening pass

The work was intentionally divided into many focused commits. Notable commit messages include:

- `fix: migrate file picker calls to v11 static API`
- `fix: import recording format extensions in player`
- `fix: import recording format extensions in library tile`
- `feat: extract persisted waveform envelopes from audio`
- `feat: persist waveforms for imported and processed audio`
- `feat: support sharing multiple recordings`
- `feat: add bulk recording library operations`
- `feat: add selectable recording tiles`
- `feat: add bulk selection and library actions`
- `feat: add draggable waveform selection handles`
- `feat: expose waveform selection interaction lifecycle`
- `feat: add editor selection undo redo and export presets`
- `feat: add desktop keyboard navigation shortcuts`
- `feat: add reusable PCM waveform peak utility`
- `refactor: reuse tested PCM waveform peak logic`
- `test: cover PCM waveform peak extraction`
- `ci: keep analyzer infos non-fatal while enforcing errors`
- `style: modernize recorder form and flow control`
- `style: modernize settings forms and callbacks`
- `style: place recording factories with constructors`
- `style: harden metadata store flow control`
- `fix: keep file operations and metadata transactionally consistent`
- `fix: add Android activity under valid package namespace`
- `fix: add Android foreground service under valid package namespace`
- `fix: align Android activity package with Flutter project namespace`
- `fix: align Android recording service with Flutter namespace`
- `fix: generate hosts with valid reverse-domain namespace`
- `fix: align Dart background channel with Android namespace`
- cleanup commits removing superseded/invalid Android package paths
- `fix: pin file picker to Android-compatible release`
- `fix: use file picker platform API for compatibility`
- `style: keep recording factories before instance members`
- `style: harden player service flow control`
- `style: harden storage service flow control`
- `style: harden recorder lifecycle flow control`
- `fix: patch generated Linux runner title at correct path`
- `feat: add native PowerShell platform bootstrap`
- `ci: add Windows desktop build validation`
- `ci: validate macOS and iOS host builds`
- `fix: update file picker calls for current API` (superseded in the same continuation after pinned-version reconciliation)
- `fix: render recording format labels without extension lookup`
- `fix: render recording format in library tiles reliably`
- `fix: keep file picker API aligned with pinned compatibility release`
- `docs: synchronize project state with media session integration`
- `docs: sync playback roadmap`
- `docs: document media session playback support`
- continuation-log synchronization commits

Earlier foundation commits are preserved in the repository history and remain part of the same project.

---

# Advanced continuation pass — current work

This section records the next development pass requested after the earlier hardening cycle. It is intentionally additive; the prior implementation history above has not been shortened or discarded.

## Smart recording names

Added `lib/core/naming_template.dart` and extended recording settings so automatic names are no longer limited to a fixed prefix/timestamp pattern.

Supported template tokens now include:

- `{prefix}`
- `{suffix}`
- `{category}`
- `{date}`
- `{time}`
- `{year}`
- `{month}`
- `{day}`
- `{hour}`
- `{minute}`
- `{second}`
- `{sequence}`

Rendered names continue through SonicNest's filesystem-safe filename sanitizer. Empty optional tokens collapse repeated separators. Sequence allocation accounts for saved recordings and Trash files to reduce accidental collisions, while the existing unique-path allocator remains the final collision guard.

Settings persistence now includes:

- `namingTemplate`
- `namingSuffix`
- `namingCategory`
- existing `namingPrefix`

Older JSON settings without the new fields load safe defaults.

New test coverage was added for token rendering, empty-token cleanup, date/time/sequence formatting, naming persistence, and legacy setting fallback.

Focused commits:

- `feat: add configurable recording name templates`
- `feat: persist smart recording naming options`
- `feat: use smart naming templates for recordings`
- `test: cover smart recording name templates`
- `test: cover recording naming settings persistence`

## Managed storage

`StorageService` now exposes managed storage statistics for:

- recordings bytes/count
- Trash bytes/count
- temporary processing bytes/count
- total managed bytes

It also exposes guarded temporary-file cleanup. Files that disappear during a statistics scan are tolerated, and cleanup does not forcibly fail the application when a platform codec still owns a temporary file.

The controller blocks temporary cleanup while recording is active. Settings surfaces the managed-storage totals and a temporary cleanup action.

Focused commits:

- `feat: add managed storage statistics and cleanup`
- `feat: expose smart naming and storage management settings`
- `fix: refresh storage safely after temporary cleanup`

## Branded startup flow

Added a Flutter startup presentation with:

- SonicNest brand mark
- app name/tagline
- startup progress state
- startup error message
- retry action
- developer credit

Controller initialization now happens after `runApp`, allowing Flutter to render a branded state while metadata/settings initialize. This does not falsely claim that every platform's native pre-Flutter launch-screen artwork has already been manually verified.

Focused commits:

- `feat: add fast branded startup splash screen`
- `feat: bootstrap app through branded splash`
- `feat: show startup UI while project state initializes`

## Recording countdown

The stored countdown preference is now functional rather than presentation-only.

Recorder lifecycle now distinguishes:

- idle
- countdown
- recording
- paused
- processing
- error

Countdown behavior:

- supports configured 0/3/5/10 second choices
- displays remaining seconds
- can be cancelled without creating a recording
- delays foreground recording startup until countdown finishes
- keeps pause/resume and marker operations unavailable until microphone capture has actually begun
- uses a generation token so cancellation prevents a delayed countdown from starting capture later

F9 desktop behavior is countdown-aware: it starts from idle, cancels countdown, and stops active capture as appropriate.

Focused commits:

- `feat: implement cancellable recording countdown`
- `feat: present and cancel recording countdown`
- `fix: make record shortcut countdown aware`

## Keep-screen-awake behavior

The previously stored `keepScreenAwake` recording preference now controls an actual screen wake lock during active capture through the project's pinned cross-platform wake-lock dependency.

Lifecycle cleanup releases the screen wake state after:

- normal Stop
- Discard/cancel
- recorder startup/runtime error
- recorder service disposal

The wake lock begins after countdown finishes, not while the user is merely waiting for the countdown. This is a display wake preference; it is not presented as a substitute for each platform's background-execution rules.

Focused commits:

- `feat: add cross-platform screen wake support`
- `feat: honor keep-screen-awake recording preference`
- `fix: keep wakelock dependency compatible with platform graph`

## Library filtering expansion

The controller now supports:

- exact case-insensitive tag filtering
- from-date filtering
- inclusive through-date filtering
- combined tag/date filtering
- a derived set of available tags
- clear-all advanced filters

A dedicated responsive advanced-filter control opens a bottom sheet with tag and date selectors. Existing search/scope/format/folder behavior remains in place.

Focused commits:

- `feat: add tag and date library filters`
- `feat: add advanced tag and date filter controls`
- `feat: surface advanced library filters across layouts`

## Playback expansion

Player service now includes application-managed A-B selection looping:

- set loop start/end
- clamp selection to loaded duration
- seek to A when playback reaches B
- clear selection loop
- avoid simultaneous repeat-one and A-B loop modes

Player UI now adds:

- A-B loop range dialog
- loop selection visualization on the waveform
- loop clear action
- previous recording
- next recording
- previous/next traversal excludes Trash entries

Focused commits:

- `feat: add selection loop playback support`
- `feat: add previous next and A-B loop playback controls`

A-B timing and OS-level media-session behavior remain physical-device QA items.

## Editor expansion

Added `AdvancedAudioProcessor` for additional FFmpeg-backed, non-destructive operations. All operations create new files; they do not overwrite the original recording.

New processing capabilities:

- cut a selected middle range from a copy by concatenating audio before/after the selection
- insert generated silence at the current playhead
- apply bounded gain in dB
- high-pass filtering
- low-pass filtering
- compressor processing
- limiter processing
- basic FFT-domain noise cleanup

The editor UI exposes:

- Keep selection as copy
- Cut selection from copy
- Normalize
- Remove silence
- Fade in/out
- Split at playhead
- Merge another file
- Basic noise cleanup
- Compressor
- Limiter
- High-pass voice filter
- Low-pass filter
- gain slider and gain-adjusted export
- silence duration picker and insertion at playhead
- existing format export presets

Bookmark positions are adjusted when a cut removes time or silence insertion adds time. Markers within a removed cut range are omitted from the resulting copy.

Focused commits:

- `feat: add advanced non-destructive audio processing`
- `feat: expand editor with cut silence gain and cleanup tools`

These DSP presets are functional processing paths, but they are not labeled as mastering-grade or perfect noise removal. Listening tests remain required before changing/tuning defaults.

## Desktop shortcut expansion

In addition to Ctrl+1 through Ctrl+5 navigation:

- F9: start/stop recording or cancel countdown
- F10: pause/resume recording
- Ctrl+Alt+P: play/pause loaded audio
- Ctrl+Alt+Left: configured backward jump
- Ctrl+Alt+Right: configured forward jump

Focused commits:

- `feat: add recorder and player desktop shortcuts`
- `fix: make record shortcut countdown aware`

## Localization-ready layer

Added `lib/l10n/app_localizations.dart` and connected localization delegates/supported locales to both startup and main MaterialApps.

Current supported locale:

- English

Primary navigation labels and startup presentation strings now use the localization layer. Remaining hard-coded presentation strings are explicitly tracked for migration before additional language translations are added.

A CI analyzer error exposed a missing explicit Cupertino localization import; that was corrected immediately.

Focused commits:

- `feat: add localization-ready presentation layer`
- `feat: configure application localization delegates`
- `refactor: localize startup presentation strings`
- `refactor: localize primary navigation labels`
- `fix: import Cupertino localization delegate explicitly`

## FFprobe API cleanup

After source analysis reached the new code, two informational analyzer findings identified redundant `await` calls around synchronous media-information access. They were removed independently in the processor and player services.

Focused commits:

- `style: remove redundant await from FFprobe metadata`
- `style: remove redundant await from player FFprobe metadata`

## Release documentation expansion

Added:

- `docs/RELEASING.md`
- `RELEASE_NOTES.md`
- `TODO.md`

`docs/RELEASING.md` documents source preparation, automated checks, physical-device requirements, signing boundaries, release candidate commands, final review, tagging, artifact/checksum expectations, and the rule that builds must match the tagged source.

`RELEASE_NOTES.md` describes v0.1.0 as a development preview and explicitly prevents it from being treated as stable until manual release gates are complete.

`TODO.md` contains only incomplete/evidence-dependent work: physical-device lifecycle testing, stress tests, accessibility, localization completion, real screenshots/assets, signing, packaging, and stable release gates.

The QA checklist was expanded in depth to cover:

- startup/migration
- recording basics
- countdown
- screen wake
- permissions/interruption
- input routing
- codec matrix
- smart filename templates
- library filters/actions
- Trash/deletion
- managed storage
- playback/A-B/media-session behavior
- advanced editor tools
- desktop shortcuts
- accessibility/responsiveness
- localization readiness
- low-storage/filesystem failures
- soak/performance
- privacy/release evidence

Focused commits:

- `docs: add reproducible release procedure`
- `docs: prepare SonicNest preview release notes`
- `docs: add evidence-based remaining release gates`
- `docs: expand QA for new recorder playback and editor features`
- `docs: document current SonicNest feature surface`
- `docs: record advanced recorder and editor continuation`
- `docs: advance roadmap after feature completion`
- `docs: synchronize current SonicNest project state`
- this continuation-log commit

## Current dependency lines relevant to the continuation

The project currently keeps the established compatibility choices and adds screen-wake support:

- `file_picker: 10.3.10`
- `share_plus: ^12.0.2`
- `record: ^7.1.1`
- `just_audio: ^0.10.6`
- `just_audio_background: 0.0.1-beta.17`
- `just_audio_media_kit: ^2.1.0`
- `ffmpeg_kit_flutter_new_audio: ^2.5.0`
- `wakelock_plus: 1.4.0`

The screen-wake dependency was deliberately pinned rather than allowing an unnecessary platform dependency upgrade to destabilize the already validated Windows/file-picker graph.

## Current test additions from this continuation

New/expanded automated tests include:

- smart filename template rendering
- date/time/sequence token rendering
- optional token separator cleanup
- empty rendered-template fallback
- smart naming setting JSON roundtrip
- legacy smart naming setting defaults
- existing channel/countdown bounds
- existing transcode-format behavior

Existing filename, metadata, recording-settings, and PCM waveform tests remain in place.

## CI state during this advanced continuation

The continuation generated many intentionally focused commits, and the workflows are configured so newer commits cancel older in-progress runs. Therefore a cancellation after a newer commit is not treated as a source-code failure.

During this pass:

- dependency resolution reached success with the new code and the pinned screen-wake dependency
- platform bootstrap reached success on the new dependency graph before source analysis
- source analysis initially identified a single actual localization delegate import error plus two non-fatal redundant-await informational findings
- the localization import error was fixed in `fix: import Cupertino localization delegate explicitly`
- the redundant-await findings were fixed in separate processor/player commits
- subsequent documentation synchronization commits intentionally caused replacement CI runs

At the time the first advanced `what_changed.md` update was committed, the documentation-synchronized HEAD still had replacement runs in progress. That temporary state has now been superseded by the final validation record below.

## Hardware/manual release gates that remain

The following cannot be truthfully completed by repository-only automation and must remain unchecked until tested on real target hardware/accounts:

- First-launch microphone permission acceptance/denial/permanent denial UX.
- Actual microphone capture quality on Android, iOS, macOS, Windows, and Linux.
- Configured countdown behavior on physical-device lifecycle edges.
- Keep-screen-awake behavior on physical devices and release builds.
- Wired/USB/Bluetooth/built-in microphone switching.
- Calls/alarms/audio-focus interruptions.
- Screen-lock/background recording behavior.
- Android foreground-service behavior across OEM/device variants.
- iOS background recording behavior under current OS policies.
- Android/iOS/macOS media-session and lock-screen playback behavior on physical hardware.
- Headphone/Bluetooth media-button and reconnect behavior.
- A-B loop timing on physical devices/backends.
- Low-storage and filesystem failure recovery.
- Advanced editor output quality against representative real voice/music recordings.
- 30-minute and multi-hour recording soak tests.
- Very large recording-library performance.
- TalkBack, VoiceOver, Narrator, and other assistive-technology audits.
- Complete presentation-string localization migration before non-English releases.
- Real screenshots captured from tested builds.
- Final native app-icon/launch asset review on each platform.
- Store signing, keystore/certificate/provisioning, notarization, store metadata, and release credentials.

Do not mark those items complete without real evidence.

## Exact continuation point

The repository is in cross-platform release-hardening state, not initial implementation state. The recorder/library/player/editor/settings/startup/release-documentation source has been materially expanded in this continuation. `PROJECT_STATE.md`, `ROADMAP.md`, `CHANGELOG.md`, `README.md`, `docs/QA_CHECKLIST.md`, `docs/RELEASING.md`, `RELEASE_NOTES.md`, `TODO.md`, and this file now describe the expanded state.

For the next continuation:

1. Read this file and `PROJECT_STATE.md` first.
2. Check the newest GitHub Actions runs before changing code.
3. If the newest run exposes a real compile/analyzer/test regression, fix it in a focused commit before adding more features.
4. Do not reimplement completed smart naming, countdown, screen-wake, A-B loop, tag/date filters, storage accounting, advanced editor, localization scaffold, media-session source work, or release docs.
5. Prioritize physical-device QA, listening tests, accessibility, localization completion, large-library/long-recording performance, real release assets, signing, packaging, and any reproducible issues found from those tests.
6. Keep evidence-dependent release gates unchecked until actual evidence exists.

## Final automated validation after CI concurrency correction

The core workflow was hardened so documentation-only commits no longer restart analyzer/Android/Linux validation. Its concurrency group was also versioned so an older GitHub runner allocation could not block the replacement validation run.

Focused commit:

- `ci: avoid documentation-only core rebuild churn`

Exact validated core run:

- Run ID: `31771542490`
- Validated commit: `594f94a7b55826d1f27abbdf2aadd0a17ae42991`
- Platform bootstrap: SUCCESS
- Dependency resolution: SUCCESS
- Dart formatting step: SUCCESS
- Flutter static analysis: SUCCESS
- Unit tests: SUCCESS
- Android debug APK build: SUCCESS
- Linux debug desktop build: SUCCESS

Source-equivalent desktop/Apple validation from the same final source revision before documentation-only synchronization:

- Windows run `31771214266`: SUCCESS
- Apple run `31771214284`: SUCCESS for macOS debug and unsigned iOS debug builds
- Source revision validated by those workflows: `3eed20635099bbcc2b4777d8a9881c0eb34caae0`

All commits after that Apple/Windows source revision and before the core CI workflow correction were documentation-only; the core run above validates the current source plus the CI workflow correction itself.

This completes the repository-automatable validation for this continuation. It does **not** complete the physical-device, accessibility, long-duration, listening-quality, signing, packaging, or store-release gates listed above and in `TODO.md` / `docs/QA_CHECKLIST.md`.
