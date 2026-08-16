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

---

# Batch conversion and desktop context-action continuation

This section records the repository-implementable work completed after the advanced continuation above. The earlier history is intentionally preserved in full and has not been shortened.

## Desktop secondary/right-click recording actions

`RecordingTile` now accepts secondary-click gestures. On desktop pointer systems, a secondary/right-click opens the same complete recording action surface that was already available through the explicit More button. This preserves the existing primary-click, touch, long-press, selection, favorite, and menu behavior instead of introducing a separate inconsistent action model.

Implemented behavior:

- secondary/right-click support at the recording-tile interaction layer
- optional secondary-tap callback hook for future cursor-anchored menu work
- default secondary-click fallback to the existing `onMore` action surface
- no removal or replacement of touch/long-press behavior

Focused commits:

- `feat: support desktop recording context gestures`
- `feat: open recording actions on desktop right click`

A cursor-anchored platform-native context menu remains optional future work and should only be added if Windows/macOS/Linux usability testing shows that it materially improves the implemented action surface.

## Multi-recording batch conversion

Added `lib/screens/batch_convert_screen.dart` and exposed it from the Home screen through a dedicated **Batch Convert** entry.

The workflow supports:

- selecting one or many saved non-Trash recordings
- select-all / clear-all selection behavior
- selecting a target `RecordingFormat`
- sequential conversion with visible progress
- per-file success/failure isolation
- preserving the original source recordings
- retaining recording markers on converted copies
- reusing each source recording's known bitrate/sample-rate/channel metadata when available
- falling back to current recording settings when imported media has unknown metadata
- registering successful outputs through the normal processed-file/library pipeline
- deleting an output path after a failed registration attempt where cleanup is possible
- continuing later items after one conversion fails
- user-visible completion status showing successful and failed counts

The batch workflow intentionally processes sequentially instead of launching every FFmpeg job simultaneously. This keeps memory/storage pressure more predictable and makes per-file progress/failure handling easier to audit. Very large batches remain a performance/manual-QA gate.

Focused commits:

- `feat: add multi-recording batch conversion workflow`
- `feat: expose batch conversion from home`

## Documentation synchronized after batch/context work

The following project-state files were updated without replacing the historical continuation record:

- `PROJECT_STATE.md`
- `CHANGELOG.md`
- `ROADMAP.md`
- `README.md`
- `TODO.md`
- `what_changed.md`

The documentation now distinguishes completed multi-recording format conversion from the separate possible enhancement of direct multi-file export into a user-selected external destination.

Focused documentation commits include:

- `docs: record validated batch conversion and desktop actions`
- `docs: record batch conversion and desktop context access`
- `docs: advance batch conversion and desktop interaction roadmap`
- `docs: document batch conversion and desktop context actions`
- `docs: track batch and desktop validation gates`
- this `what_changed.md` append commit

## Exact validation for batch conversion and desktop context actions

Validated source revision:

- `985f2dd1500a03b0b65ee58b142cf31f545b0cc5`

Core Flutter CI:

- Run ID: `31772136038`
- Dart formatting: SUCCESS
- Flutter static analysis: SUCCESS
- Unit tests: SUCCESS
- Android debug APK: SUCCESS
- Linux debug build: SUCCESS

Windows CI:

- Run ID: `31772135970`
- Windows debug build: SUCCESS

Apple CI:

- Run ID: `31772136081`
- macOS debug build: SUCCESS
- unsigned iOS debug build: SUCCESS

All listed workflows validate the same source revision. Documentation-only synchronization commits after that revision do not alter application source and do not trigger the core Flutter workflow because its path filters intentionally exclude documentation-only changes.

## Remaining evidence-dependent gates after this continuation

Repository automation is green, but the following remain intentionally unclaimed until real evidence exists:

- large batch conversion performance and storage-pressure testing
- low-storage batch failure/recovery behavior
- mixed/corrupt-media batch conversion testing
- secondary/right-click ergonomics on real Windows, macOS, and Linux desktop systems
- whether a cursor-anchored native context menu is actually preferable
- direct multi-file export to a user-selected external destination
- all previously listed microphone, routing, interruption, background, screen-wake, media-session, accessibility, localization, soak, signing, packaging, screenshot, and store-release gates

The exact continuation point is now: repository-implementable smart naming, countdown, screen wake, advanced filtering, A-B playback, expanded non-destructive editor processing, localization scaffolding, media-session source integration, managed storage, desktop shortcuts, secondary-click recording actions, and multi-recording batch format conversion are implemented. Future work should be driven primarily by real device/desktop QA, large-batch/large-library performance, listening tests, localization completion, release assets, signing, packaging, and defects discovered from those evidence-producing checks.

---

# Final validation for external batch export and safe cancellation

The newest batch workflow adds optional copies to a user-selected external folder and a safe **Stop after current file** cancellation boundary.

Exact validation evidence:

- Validated revision: `54b727db6dd887fb0b2df2d36cabb2cd78671d7a`
- One-shot validation run: `31773250023`
- Flutter static analysis: SUCCESS
- Unit tests: SUCCESS
- Android debug APK: SUCCESS
- Linux debug build: SUCCESS
- Windows debug build: SUCCESS
- macOS debug build: SUCCESS
- unsigned iOS debug build: SUCCESS

The external copy is intentionally performed only after the managed SonicNest conversion/library registration succeeds. Destination-copy failure therefore does not roll back a valid managed-library output. Existing destination names are protected with collision-safe numbered filenames. Cancellation is observed between files so a running FFmpeg write is not intentionally terminated mid-file.

Manual validation still required: directory-picker behavior and access persistence on real platforms, destination removal/revocation, low-storage external-copy behavior, very large batches, closing/navigating away during processing, and long-running stop-after-current behavior.

---

# Localization, library interaction, and batch reliability continuation

Validated implementation added in this continuation:

- Batch Convert now honors **Stop after current file** between items rather than describing cancellation without wiring it.
- Batch Convert can optionally copy successful managed outputs to a user-selected external directory.
- External copies use collision-safe numbered filenames and never intentionally overwrite an existing destination file.
- External-copy failures are reported independently and do not roll back a successfully registered SonicNest library conversion.
- External copy behavior moved into `ExternalActions.copyFileToDirectoryCollisionSafe` with temporary-directory unit coverage for normal copies, collisions, missing sources, and missing destinations.
- Native file and directory pickers now use platform-default dialog titles, allowing the host OS to provide localized native picker chrome.
- Home, About/support, Recorder, Player, Library, Settings, Batch Convert, Editor, startup failure presentation, and reusable recording-tile controls were routed through the application localization layer.
- Dynamic localization paths now cover batch progress/failure counts, library deletion counts, storage summaries, recorder statuses, player controls, and editor processing statuses.
- Added localization catalog smoke tests for baseline locale support and dynamic batch/library/editor/storage text.
- Restored exact-tag and date-range filters directly in the responsive Library filter surface.
- Restored desktop secondary-click access to recording actions.
- Removed the duplicate legacy floating advanced-filter component so one responsive filter surface owns the behavior.
- Removed the obsolete pre-localization `AppStrings` constants file.
- Startup loading and startup failure are now distinct states; the generic failure copy comes from localization while diagnostic detail remains available.

Exact automated validation:

- Validated revision: `3fa56d26fb6cb64ccddf2b71e7b8c677aa4aa69b`
- One-shot validation run: `31774726146`
- Dart formatting: SUCCESS
- Flutter static analysis: SUCCESS
- Unit tests: SUCCESS
- Android debug APK: SUCCESS
- Linux debug build: SUCCESS
- Windows debug build: SUCCESS
- macOS debug build: SUCCESS
- unsigned iOS debug build: SUCCESS

Release classification remains **development preview**. Physical microphone, routing, interruption/background, low-storage, accessibility, long-duration, large-library, real screenshot/icon, signing, notarization, packaging, and store-dashboard gates still require real evidence and remain unchecked.

---

# Direct multi-file original export continuation

Implemented after the localization/library hardening pass:

- Added `ExternalCopyBatchResult` and `ExternalActions.copyFilesToDirectoryCollisionSafe`.
- Multi-file copies continue past per-file failures and return independent success/failure counts.
- Added unit tests for complete batch success, mixed success with a missing source, and collision-safe numbering when multiple sources share a basename.
- Batch Convert now exposes direct export of selected original recordings without transcoding.
- Direct original export uses a user-selected directory and preserves the original recording files.
- Existing destination files are never intentionally overwritten; numbered names are allocated instead.
- Direct-export failures are summarized without deleting or rolling back successful copies.

Exact automated validation:

- Validated revision: `7c4702afcb9859f3507ac151f23372f96acec50a`
- Validation run: `31775283791`
- Dart formatting: SUCCESS
- Flutter static analysis: SUCCESS
- Unit tests: SUCCESS
- Android debug APK: SUCCESS
- Linux debug build: SUCCESS
- Windows debug build: SUCCESS
- macOS debug build: SUCCESS
- unsigned iOS debug build: SUCCESS

Physical directory-picker behavior, permission revocation, low-storage copies, and very large batch behavior remain manual evidence gates.

---

# Native launcher and splash branding continuation

This continuation replaces generated Flutter-default native artwork with a reproducible SonicNest-controlled branding pipeline while keeping visual release approval as an evidence-dependent manual gate.

## Deterministic native brand source

- Added `tool/generate_brand_assets_v2.dart` as the single canonical raster generator.
- The generator is pure Dart and reproduces SonicNest's gradient, microphone/stand mark, and sound bars from repository-controlled geometry.
- It deterministically writes `assets/generated/sonicnest_icon.png`, `assets/generated/sonicnest_icon_foreground.png`, and `assets/generated/sonicnest_splash.png`.
- Generated PNGs are ignored by Git because the generator is the source of truth.
- A superseded first-pass raster generator was removed so the repository has only one branding implementation.

## Native launcher and splash generation

- Added reproducible Bash branding via `tool/apply_branding.sh`.
- Added reproducible Windows PowerShell branding via `tool/apply_branding.ps1`.
- Both paths run the deterministic raster generator and then apply native launcher/splash resources through the configured Flutter tooling.
- Android launcher resources include full, adaptive-foreground, and monochrome/themed-icon source paths.
- Android native splash resources include Android 12+ configuration and dark/light launch colors.
- iOS launcher icons and native splash resources are generated from the SonicNest brand source.
- macOS application icon resources are generated from the SonicNest brand source.
- Windows application icon resources are generated from the SonicNest brand source.
- Linux receives deterministic brand source PNG generation, while final desktop-entry/package icon integration remains tied to the distribution format selected later.

## Build integration

- `pubspec.yaml` now contains the launcher-icon and native-splash configuration.
- `.github/workflows/ci.yml` generates deterministic brand source images during validation and applies native branding before Android compilation.
- `.github/workflows/windows.yml` applies SonicNest native branding before the Windows debug build.
- `.github/workflows/macos.yml` applies SonicNest native branding before macOS and unsigned-iOS debug builds.
- `docs/BUILDING.md` and `docs/BRANDING.md` document reproducible generation and the visual-QA boundary.
- README quick-start commands now include the native-brand application step.

## Exact automated validation

Validated source revision: `40c4a758debef136c2d8c977c321446cca2697cd`

Core Flutter CI run `31776174696`:
- deterministic brand image generation: SUCCESS
- Dart formatting: SUCCESS
- Flutter static analysis: SUCCESS
- unit tests: SUCCESS
- Android native branding generation: SUCCESS
- Android debug APK: SUCCESS
- Linux deterministic brand source generation: SUCCESS
- Linux debug build: SUCCESS

Windows run `31776174725`:
- Windows native branding generation: SUCCESS
- Windows debug build: SUCCESS

Apple run `31776174715`:
- macOS native branding generation: SUCCESS
- macOS debug build: SUCCESS
- iOS native branding/splash generation: SUCCESS
- unsigned iOS debug build: SUCCESS

## Evidence-dependent branding gates that remain

Automated resource generation and compilation prove structural validity, not visual release approval. The following remain intentionally unchecked until real release-candidate evidence exists:

- Android legacy/adaptive/themed icon crop and mask review on real launchers.
- iOS/macOS icon inspection at small and large OS-rendered sizes.
- Windows Explorer/taskbar/Start/shortcut/final package icon inspection.
- Signed/release Android and iOS launch/splash inspection, including dark mode.
- Linux package/desktop-entry icon integration after choosing a distribution format.
- Real screenshots and store listing assets from tested release candidates.

The project remains a **development preview** until the broader hardware, accessibility, stress, signing, packaging, and store-release gates are completed with evidence.

---

# Linux Debian packaging continuation — 2026-08-14

This section records the complete repository-owned Linux packaging continuation. All earlier `what_changed.md` history above is preserved unchanged. The project remains a development preview because package structure can be automated, while real-system audio, accessibility, visual, long-duration, signing, and distribution approval require evidence outside repository-only CI.

## Debian package selected as the initial Linux distribution format

Debian `.deb` is now the initial repository-supported Linux installation package for SonicNest. This resolves the previous repository-level packaging-format decision without pretending that a public distribution channel, repository signing policy, or real-system installation QA has already been completed.

The package is produced from the Flutter Linux bundle rather than by committing generated Linux host scaffolding or binary package output.

Implemented package layout:

- `/opt/sonicnest/` — complete Flutter Linux bundle.
- `/usr/share/applications/sonicnest.desktop` — freedesktop launcher entry.
- `/usr/share/icons/hicolor/512x512/apps/sonicnest.png` — deterministic generated SonicNest icon.
- `/usr/share/metainfo/io.github.sanskarIN.SonicNest.metainfo.xml` — AppStream metadata.
- `/usr/share/doc/sonicnest/LICENSE` — Apache-2.0 project license.
- `/usr/share/doc/sonicnest/NOTICE` — project notices.

The packaged launcher executes `/opt/sonicnest/sonic_nest` and resolves the icon through the freedesktop icon name `sonicnest`.

## Linux package source files

Added and maintained:

- `packaging/linux/debian/sonicnest.desktop`
- `packaging/linux/debian/io.github.sanskarIN.SonicNest.metainfo.xml`
- `tool/build_linux_deb.sh`
- `tool/verify_linux_deb.sh`
- `.github/workflows/linux-package.yml`
- `docs/LINUX_PACKAGING.md`

The AppStream metadata identifies the application as `io.github.sanskarIN.SonicNest`, uses the valid lowercase developer identifier `io.github.sanskarin`, exposes `sonicnest.desktop` as the launchable, declares `sonic_nest` as the provided binary, records Apache-2.0 as the project license, and includes an OARS 1.1 content-rating element.

The desktop entry uses the final validated category set `AudioVideo;Recorder;` to avoid duplicate main-menu category warnings.

## Deterministic Debian package builder

`tool/build_linux_deb.sh` now:

- accepts `debug`, `profile`, or `release` build modes, defaulting to release;
- requires `dpkg-deb`;
- requires the deterministic SonicNest brand image generated from repository source;
- requires exactly one matching `build/linux/*/<mode>/bundle` directory so it cannot silently package the wrong build;
- requires the bundled `sonic_nest` executable;
- derives the Debian package version from `pubspec.yaml`, removing Flutter `+build` metadata by default;
- derives architecture from `dpkg --print-architecture` unless an explicit controlled override is provided;
- stages the Flutter bundle, desktop entry, AppStream metadata, hicolor icon, LICENSE, and NOTICE;
- writes Debian control metadata including installed size, maintainer, homepage, and runtime dependencies;
- builds with `dpkg-deb --root-owner-group --build`;
- writes a SHA-256 checksum beside the generated `.deb`.

The declared package dependencies currently include:

- `libc6`
- `libgtk-3-0`
- `libstdc++6`
- `libjson-glib-1.0-0`
- `ffmpeg`
- `pulseaudio-utils`

A bundle-discovery depth mistake found during implementation was corrected in a separate focused commit before the final package validation.

## Debian package verifier

`tool/verify_linux_deb.sh` extracts the package and verifies repository-owned structural invariants:

- Debian control file exists and identifies package `sonicnest`.
- Version and architecture fields exist.
- `/opt/sonicnest/sonic_nest` exists and remains executable.
- the SonicNest hicolor icon exists and is non-empty.
- the desktop entry exists and points to `/opt/sonicnest/sonic_nest` with `Icon=sonicnest`.
- the AppStream application ID and desktop launchable identity are present.
- `desktop-file-validate` runs when available.
- `appstreamcli validate --no-net` runs when available.
- the recorded package SHA-256 is compared with the actual `.deb` bytes.

The first verifier implementation exposed a checksum-path bug because the checksum file recorded a path that was then checked from a different working directory. That root cause was corrected so verification compares the expected digest directly with the actual package bytes and no longer depends on the caller's working directory.

## Dedicated Linux package CI

Added `.github/workflows/linux-package.yml` with a release-mode package validation job that:

- checks out the repository;
- installs Flutter stable;
- installs Linux build, audio, desktop-file, AppStream, and package validation dependencies;
- enables Flutter Linux desktop;
- regenerates platform hosts;
- resolves dependencies;
- regenerates deterministic SonicNest branding;
- builds the Flutter Linux release bundle;
- builds the Debian package;
- verifies the Debian package;
- prints package metadata and contents for inspection;
- uploads the `.deb` and checksum as a short-retention CI artifact.

The workflow uses read-only repository contents permission and path filtering so unrelated documentation changes do not unnecessarily rebuild the Linux package.

## Release-candidate integration

`.github/workflows/release-candidate.yml` now builds and verifies the Debian `.deb` in its Linux release-candidate job in addition to the raw Linux bundle archive.

The release-candidate output continues to include explicit warning text. A structurally verified `.deb` is not presented as approved for public distribution until real-machine audio, accessibility, long-duration, low-storage, visual, installation, upgrade/uninstall, signing, and distribution-policy gates are complete.

## Repository integrity hardening

`tool/repository_audit.py` was expanded to require the Linux packaging source files and workflows and to protect package invariants including:

- desktop launcher identity, executable path, icon name, terminal mode, and validated menu category set;
- AppStream application ID, lowercase developer ID, desktop launchable, binary, Apache-2.0 license, and OARS content rating;
- package builder use of `dpkg-deb`, applications/icons/metainfo destinations, and checksum generation;
- Linux package workflow release build, package builder, package verifier, artifact upload, and read-only contents permission;
- release-candidate workflow inclusion of Debian package construction and verification.

The credential-material audit initially matched its own embedded private-key detector signature. Only the audit source itself is now excluded from that signature scan, while every other tracked text file remains scanned. Repository integrity returned to green after that correction.

## CI failure/fix chronology

The package path was validated by allowing CI to expose real structural problems and fixing the causes rather than weakening the gates.

### Initial package workflow

Run `31782740611`:

- Flutter Linux release build: SUCCESS.
- Debian package construction: SUCCESS.
- Package verification reached the checksum step and failed because of the working-directory-dependent checksum path.

Focused fix:

- commit `c0381eb59c34b0dc965784d74730615eb95bfcbb` — checksum verification made independent of the current working directory.

A separate desktop-file cleanup removed duplicate menu categories before the first complete green package run.

### First complete green package validation

Run `31783018282` on source `dd31bf7800becd09424309cc99e42d324f4f8f8e`:

- Flutter Linux release build: SUCCESS.
- Debian package construction: SUCCESS.
- Package verification: SUCCESS.
- desktop-file validation: SUCCESS.
- AppStream validation: SUCCESS.
- package metadata/content inspection: SUCCESS.
- checksum verification: SUCCESS.
- artifact upload: SUCCESS.

This established the first complete green Debian package path.

### Repository-audit correction

Repository integrity run `31783107110` then exposed the audit self-signature false positive. The audit was corrected in focused commit `114fd4fe638b9d05af7919b9c850ff7ed45dfaf6` so only its own detector source is excluded from credential-signature scanning.

Repository audit run `31783355163` subsequently completed successfully.

### AppStream metadata hardening

A later metadata modernization intentionally reran strict AppStream validation. Run `31783467780` successfully built the release bundle and `.deb` but rejected the mixed-case developer identifier:

- invalid developer ID observed: `io.github.sanskarIN`.

The developer identifier was corrected to the valid lowercase reverse-domain identity `io.github.sanskarin` in source revision `f2c773e59b27a2aaac77e0590e20441ed7eba03f`.

### Latest exact Linux package validation

Linux Package CI run `31783749267` validated source revision `f2c773e59b27a2aaac77e0590e20441ed7eba03f` and completed the entire job successfully:

- Linux build dependencies: SUCCESS.
- Flutter Linux desktop enablement: SUCCESS.
- host-project bootstrap: SUCCESS.
- dependency resolution: SUCCESS.
- deterministic branding generation: SUCCESS.
- Flutter Linux release bundle: SUCCESS.
- Debian `.deb` construction: SUCCESS.
- package payload verification: SUCCESS.
- desktop-file validation: SUCCESS.
- AppStream metadata validation: SUCCESS.
- checksum verification: SUCCESS.
- package metadata/content inspection: SUCCESS.
- package artifact upload: SUCCESS.

This is the latest exact automated validation evidence for the Linux package source. Documentation synchronization commits made afterward do not change the package inputs and therefore do not replace the validated package source revision.

## Documentation synchronized in this continuation

Linux package implementation and release boundaries are now documented across:

- `README.md`
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- `ROADMAP.md`
- `PROJECT_STATE.md`
- `RELEASE_NOTES.md`
- `TODO.md`
- `docs/README.md`
- `docs/BUILDING.md`
- `docs/BRANDING.md`
- `docs/LINUX_PACKAGING.md`
- `docs/QA_CHECKLIST.md`
- `docs/RELEASING.md`
- `docs/RELEASE_EVIDENCE_TEMPLATE.md`
- `docs/TROUBLESHOOTING.md`
- `docs/UNSIGNED_ARTIFACTS.md`
- `what_changed.md`

`CONTRIBUTING.md` now requires packaging changes to use the deterministic build/verify path and explicitly prohibits weakening structural validation simply to silence an error.

`docs/QA_CHECKLIST.md` now distinguishes repository implementation/automation evidence from real Debian/Ubuntu-family install, launch, microphone, desktop-icon, upgrade, and uninstall evidence.

`docs/RELEASE_EVIDENCE_TEMPLATE.md` now has dedicated fields for Linux package workflow/run, `.deb` checksum, structural verification, exact distribution/desktop/architecture, fresh install, menu/direct launch, microphone, playback/import/export, AppStream behavior, upgrade, and uninstall observations.

`docs/TROUBLESHOOTING.md` now covers missing Linux bundle discovery, missing application-menu integration, package checksum mismatch, and microphone failure from an installed `.deb` without confusing those physical-system failures with automated package-structure results.

## Focused commits created during this continuation

The work was deliberately divided into many commits instead of one large change. Commit subjects included:

- `packaging: add Linux desktop entry`
- `packaging: add Linux AppStream metadata`
- `build: add deterministic Debian package builder`
- `fix: locate generated Linux bundle correctly`
- `build: add Debian package verifier`
- `docs: add Linux Debian packaging guide`
- `ci: add Linux Debian package validation workflow`
- `ci: add Debian package to release candidates`
- `docs: index Linux packaging documentation`
- `docs: document Debian build and verification commands`
- `docs: integrate Debian packaging into release procedure`
- `ci: audit Linux packaging invariants`
- `docs: mark Linux package integration implemented`
- `fix: verify Debian checksum independent of working directory`
- `packaging: remove duplicate Linux menu categories`
- `docs: advance roadmap with Debian packaging`
- `docs: connect Linux brand assets to Debian packaging`
- `docs: describe Debian release-candidate artifacts`
- `fix: avoid repository audit self-matching signatures`
- `docs: synchronize project state with Debian package validation`
- `docs: record Linux Debian packaging in changelog`
- `docs: add Debian evidence fields to release template`
- `packaging: modernize Linux AppStream metadata`
- `fix: use valid AppStream developer identifier`
- `docs: expand Debian package QA gates`
- `docs: add Linux package troubleshooting`
- `docs: align contributing workflow with Linux packaging`
- `ci: lock validated Linux metadata invariants`
- `docs: record latest Linux package validation`
- `docs: synchronize project state with latest Debian validation`
- `docs: add latest Debian validation to release notes`
- `docs: update Debian package QA evidence`
- this additive continuation-ledger commit.

## Remaining evidence-dependent work after the Debian packaging continuation

Repository-owned Debian package construction and structural validation are implemented. The following remain intentionally incomplete because they require real systems, hardware, long-running tests, or maintainer-owned release credentials:

- install the exact candidate `.deb` on representative Debian-family and Ubuntu-family systems;
- verify the candidate SHA-256 before installation;
- verify application-menu/launcher startup and direct `/opt/sonicnest/sonic_nest` startup;
- verify launcher, menu, task-switcher, scaling, and AppStream icon/identity behavior on real desktop environments;
- verify microphone permission/capture and built-in/wired/USB/Bluetooth routing where available;
- verify playback, import, export, conversion, and editor behavior from the installed package;
- verify package upgrade behavior from a prior compatible candidate;
- verify uninstall removes package-owned application files/desktop integration without silently deleting user recording-library data;
- run TalkBack/VoiceOver/Narrator/Linux accessibility-tool audits on appropriate targets;
- run low-storage, malformed-media, large-library, large-batch, 30-minute, and multi-hour tests;
- complete real native-icon/launch visual review and capture screenshots from exact tested candidates;
- decide the public Linux distribution channel;
- decide and configure any Debian repository/package signing policy in the maintainer's secure environment;
- complete Android/Apple/Windows signing/notarization/store release gates with maintainer-owned credentials.

These items remain unchecked in `TODO.md` and `docs/QA_CHECKLIST.md` where applicable. No repository-only build result is used to claim physical-device or stable-release approval.

## Exact continuation point after Linux packaging

SonicNest now has a repository-supported, deterministic Debian `.deb` package path with native icon integration, desktop/AppStream metadata, SHA-256 verification, dedicated CI, release-candidate integration, repository-audit invariants, troubleshooting, contribution rules, release evidence fields, and synchronized project documentation.

The latest package source validation is revision `f2c773e59b27a2aaac77e0590e20441ed7eba03f`, Linux Package CI run `31783749267`, with the complete release-build/package/verify/inspect/upload job green.

The next legitimate work is evidence-driven: install/test the package on representative real Linux systems, continue the broader physical-device/audio/accessibility/stress QA matrix, fix reproducible defects found there, and only then prepare signed/public distribution artifacts. The repository must continue to be classified as a **development preview** until those gates are completed with real evidence.

---

# Metadata integrity and resilient import continuation — 2026-08-14

This continuation hardened SonicNest local-library persistence, multi-file audio import failure isolation, and repository workflow hygiene while preserving all earlier continuation history.

## Removed obsolete write-enabled continuation workflows

The repository still contained six temporary/one-shot workflows from earlier continuation operations. They were removed from `main` in focused commits instead of being treated as permanent automation:

- `9a4680226652f384462a8c001cc4b73d0c7435de` — removed `temporary-final-evidence-and-audit.yml`.
- `26d543d8ed3d3182ac5e8db091fa28da790665fb` — removed `temporary-smoke-evidence-finalization-v2.yml`.
- `ee159138bd4094c5d5089a3ec286d139312f09bc` — removed `temporary-smoke-evidence-finalization-v3.yml`.
- `41e7898e4f6f4ce34b5865bf666e0bb5549cd639` — removed `continuation-records-gate.yml`.
- `c79c29f73b191a2105e21ed90936be77a499e4fc` — removed `continuation-release-artifacts-validation.yml`.
- `350d02eab727e57a70602df7a1792e9b2e718328` — removed `continuation-repository-audit-validation.yml`.

Commit `9ce23f8a90ee3d7f83c9130e8141bf21ab2883c2` permanently hardened `tool/repository_audit.py` so only the maintained workflow set is allowed on `main` and maintained workflows cannot request `contents: write`. Temporary/one-shot write-enabled workflows are therefore repository-integrity failures if they remain tracked.

## Defensive recording metadata decoding

Commit `e3c4574c54318c64dc2d5350963914f18b39a0c5` hardened `RecordingEntry` and nested marker decoding. Optional fields are now type-checked instead of relying on unchecked casts. Malformed tag/waveform members are filtered, malformed marker objects are isolated, invalid dates/formats receive safe fallbacks, and one bad optional value cannot abort the entire Library startup path.

Commit `948d2f3955758dd911920f430e701623a2fd02ab` added regression coverage for malformed optional recording metadata and nested values while preserving the existing round-trip and Trash-state tests.

## Metadata document corruption isolation

Commit `5aff26c2d6bc32614eb5142fd7e0eaa2783c2096` hardened `MetadataStore` with injectable support-directory/clock dependencies, structural JSON validation, timestamped collision-safe corrupt-document copies, per-record isolation, and required non-empty recording ID/file-path checks.

Commit `2c5741bd11b24c6acdf976bc788d3a1993e3ea45` added filesystem regression tests for invalid JSON, invalid `recordings` document structure, malformed-record isolation, and a deterministic 3,000-entry save/load round-trip through the real metadata JSON persistence path.

## Interrupted metadata replacement recovery

Commit `91957963b97188894a069e2c4f3b0ce962ad9899` closed the replacement crash window around `recordings.json`, `.tmp`, and `.bak` files.

Startup recovery now:

1. prefers a valid primary metadata document and removes a stale completed backup;
2. restores a valid `.bak` when the primary is missing after an interrupted replacement;
3. preserves a structurally corrupt primary to a timestamped diagnostic copy;
4. restores a valid backup after primary corruption;
5. preserves a corrupt backup for diagnosis rather than silently accepting it;
6. continues isolating malformed individual entries inside otherwise valid metadata.

Commit `657959433cff0305c78ffd84873d6b7b71b13746` added direct tests for missing-primary backup recovery and corrupt-primary valid-backup fallback. Commit `e4ce01100b0c095efbf25f667e709f70820364ef` corrected typed empty-result inference discovered by static analysis before the final green validation.

`docs/METADATA_INTEGRITY.md` was added in commit `05371b4204f12420b6a43a535f9fb19189ee4a59` to document the save/recovery sequence, diagnostic-copy rules, per-record isolation, large-library deterministic regression gate, and manual evidence boundary.

## Per-file resilient audio import

Commit `995afc80dfa5c4f92dab63b8b57d333ff2b8e2b7` added `AudioImportService` as the testable per-file managed-import boundary.

For each source, the service:

- copies the selected source into managed SonicNest storage;
- derives the managed target format from the copied extension;
- probes audio duration;
- generates the persisted waveform envelope;
- reads managed file size;
- returns validated import data only after those steps succeed;
- deletes the copied managed file if validation fails after the copy was created;
- reports an `AudioImportException` with the failing source path instead of leaking an orphaned managed copy.

Import-service regression tests were added in commit `4b1b7d38df9bfe4055b45138dca2719e1a5dc10f`, with focused test-source corrections in `9666773d552709d51737155975bd7e82d98d9325` and `a88aeadadda017b0aced4dbc25c8426a27364b77`.

Commit `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` wired the service into `AppController.importAudio()`.

The controller now processes selected files sequentially and independently. A missing/corrupt/unprobeable/waveform-invalid source records an isolated failure and later selected files continue. Each successful file is persisted immediately. If metadata persistence itself fails, SonicNest removes the just-added in-memory entry, deletes the just-created managed file, and rethrows instead of pretending the Library mutation succeeded.

Partial import failures produce a bounded summary with the number of successful selections and a limited list of failed filenames.

## Exact automated validation

Core Flutter CI run `31807193932` validated revision `a88aeadadda017b0aced4dbc25c8426a27364b77` with the complete core path green:

- deterministic branding source generation: SUCCESS;
- Dart formatting gate: SUCCESS;
- Flutter static analysis: SUCCESS;
- full unit-test suite including metadata/import regressions: SUCCESS;
- Android debug APK build: SUCCESS;
- Linux debug build: SUCCESS.

The cross-platform controller source revision `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` also passed:

- Windows build run `31807141053`: SUCCESS;
- Apple build run `31807141166`: macOS debug SUCCESS and unsigned-iOS debug SUCCESS.

Repository Integrity Audit run `31808325649` passed on revision `44adfb292b1b26074ad7659a2b3843b62069db9f` after the cleaned permanent workflow set, workflow allowlist/read-only invariant, QA evidence, architecture, and roadmap synchronization were in place.

## Documentation synchronized

This continuation synchronized the implemented behavior and evidence boundary across focused documentation commits including:

- `af55271a62be1d79be2874a1974fd228d11e90bc` — README reliability behavior;
- `1bebfecd5e99bfab8bc7655f4d30e945218d9715` — contributor reliability requirements;
- `79cbe2b0821219f5fbf943668c7fbb1b4c756008` — focused build/test commands;
- `7a9dc7e7397b3bf9487e74a9162e850f9aaa6cf0` — user-guide recovery/import behavior;
- `32b4a270a49e318857a009a188970f349fa0980c` — troubleshooting recovery/import behavior;
- `c7b9c41a8afcf83ff03ae5a014c9968f2f09c5e4` and `d1c01a987dea994734c012c46507d4918e8d0fbc` — changelog implementation and final validation evidence;
- `a44d0c1008a82b63ac83ffff1fb8f367077c8d86` — TODO distinction between deterministic baselines and manual gates;
- `3e85956b5f479888d2aaf6b4d1abc8387b154f84` — project-state synchronization;
- `3b4462c22ee0daf954f574e75755173018f39e09` — release-note reliability update;
- `448578dcc252929b5f6acb4332eaa5e4731f7756` — exact README validation evidence;
- `a50967f38bcb6c576577d6f77dc59cfff428e6a3` — QA automation evidence plus explicit unchecked real-system gates;
- `a6e71a851c249775b131e68cc10ea1e2b5900c76` — architecture transaction/recovery boundaries;
- `44adfb292b1b26074ad7659a2b3843b62069db9f` — roadmap reliability status.

## Ledger append safety correction

Commit `0b22cd4cfa592fd5c94925129c6c0a5daf02b497` created the first one-shot ledger helper, but its YAML block scalar ended before the embedded shell heredoc content and run `31808444941` failed before modifying or pushing `what_changed.md`. The failed helper was corrected rather than leaving it as permanent write-enabled automation.

## Evidence-dependent work intentionally left open

The deterministic repository gates do not substitute for the remaining real-world checks. SonicNest still requires evidence for:

- malformed/corrupt real-media corpus imports on each maintained platform;
- low-storage recording/import/export/editor behavior;
- filesystem permission loss and recovery;
- abrupt process/power interruption behavior on representative systems;
- real Library UI startup/search/filter/scroll/memory performance with thousands of entries;
- long-duration recording and playback/editor stress;
- microphone permission/routing and interruption behavior;
- Bluetooth/wired/USB input and media-button behavior;
- accessibility audits;
- physical native-brand visual review;
- representative Debian/Ubuntu package installation, upgrade, microphone routing, visual integration, and uninstall evidence;
- signing, notarization, store metadata, screenshots, and final distribution approval.

The 3,000-entry regression test proves metadata persistence integrity only; it does not prove real UI performance. Controlled import test doubles prove failure-isolation logic only; they do not prove every malformed real-world codec/container case.

SonicNest therefore remains a **development preview** until the evidence-dependent release gates in `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md` are complete.

---

# Managed storage, transaction, and orphan-recovery hardening — 2026-08-15

This continuation builds directly on the metadata/import reliability work above. It preserves the existing project history and concentrates on repository-testable failure modes that can otherwise split local audio files from the JSON library index. Physical-device, real-filesystem interruption, accessibility, and signing gates remain evidence-dependent and are not marked complete.

## Managed audio mutation boundary

`StorageService` now applies a strict managed-storage boundary before path-changing or destructive recording-library operations.

Implemented safeguards:

- normalized absolute path checks for SonicNest-managed `Recordings` and `.trash` directories;
- rename rejects a source outside active managed recordings;
- move-to-Trash rejects a source outside active managed recordings;
- restore rejects a source outside managed Trash;
- duplicate rejects a source outside SonicNest managed audio storage;
- permanent-delete helper rejects paths outside managed recording/Trash storage;
- external files remain untouched when a tampered/out-of-bound metadata path reaches these methods;
- document/temp directory providers are injectable for deterministic filesystem tests.

Focused commits:

- `472ef2d0aa1903858473a31b2d2596d8ef55a769` — `fix: guard managed audio storage mutations`.
- `ac1fbe8a160fba985df6aca396696b1d7d7f8355` — `test: cover managed storage path guards`.

The managed-path checks are an application safety boundary. They do not claim that SonicNest is a hostile-code filesystem sandbox; operating-system permissions and real filesystem semantics remain part of release security.

## Corrupted numeric and waveform metadata normalization

Recording metadata decoding now treats unsafe numeric values as damaged metadata rather than allowing negative, non-finite, or out-of-range values to leak into library behavior.

Implemented normalization:

- negative/non-finite duration becomes a safe fallback;
- negative/non-finite file size becomes a safe fallback;
- negative/non-finite bitrate and sample rate become safe fallbacks;
- negative/non-finite marker positions become safe fallbacks;
- `channels: 0` remains valid as the existing unknown imported-media state;
- negative/non-finite channel counts fall back safely;
- non-finite waveform samples are removed;
- recovered waveform samples are bounded to `0.0..1.0`.

Focused commits:

- `7400aaf81502069f53395f767b44f1b66c5485de` — `fix: normalize corrupted numeric recording metadata`.
- `e51a16cd9fd9edf9fe42fc1470596c8c3d5614f7` — `test: cover corrupt numeric metadata normalization`.
- `1625362496d0f2d5cb4fd84bfa80fa1be195d56b` — `fix: preserve unknown channel metadata safely`.
- `b596e1afea0b1bec48ce36eae420f33633c80fb0` — `test: preserve unknown channels and bounded waveforms`.

## Corrupt-store reset and duplicate isolation

`MetadataStore` now handles the no-valid-primary/no-valid-backup case without leaving a corrupt primary active indefinitely.

Startup behavior now includes:

- preserve corrupt primary/backup documents to collision-safe timestamped diagnostic files;
- recover a valid backup when available;
- if no valid source remains, write a structurally valid empty metadata document after preserving diagnostics;
- avoid creating the same corrupt-primary diagnostic copy again on every subsequent startup;
- keep only the first valid entry when duplicate recording IDs are present;
- keep only the first valid entry when duplicate normalized file paths are present;
- retain per-record malformed-object isolation from the prior continuation.

Focused commits:

- `3c7a2b1b0f8d663a7940d6ca11cfeec81b2e5a69` — `fix: harden metadata recovery and duplicate isolation`.
- `7a8d98302652731ef8cf0990642f1793f320bd8b` — `test: cover metadata duplicate and reset recovery`.

## Persistence-safe library mutations

`AppController` now treats metadata persistence as part of the filesystem operation instead of assuming a successful file move automatically means a successful library mutation.

Implemented behavior:

- processed-output registration restores the previous selection and removes an unregistered generated output if metadata persistence fails;
- rename moves the audio file back to its original path if the updated metadata cannot be persisted;
- single-entry metadata updates restore the previous in-memory recording/selection after a persistence failure;
- batch metadata updates restore the previous in-memory library/selection after a persistence failure;
- move-to-Trash rolls the file back when metadata persistence fails;
- restore rolls the file back when metadata persistence fails;
- settings changes restore the previous in-memory settings when persistence fails;
- permanent deletion persists metadata removal before deleting the managed file, deliberately preferring a recoverable orphan over irreversible loss if a process stops between those steps;
- if the managed file deletion fails while the file still exists, the removed metadata entry is restored and persisted again;
- rollback failure paths surface explicit state errors rather than silently pretending the operation completed consistently.

Focused commit:

- `f7756ae091febed7e5f08eb65a81e777e3706aa4` — `fix: make library mutations persistence-safe`.

Bulk filesystem operations can still complete some earlier items before a later item encounters a genuine filesystem failure; the invariant is per-item consistency and data preservation, not an unsupported claim of a multi-file ACID transaction.

## Managed-file discovery

`StorageService` now exposes the repository-owned recording files that are eligible for crash/orphan recovery.

The discovery path:

- scans only the top level of the managed `Recordings` directory;
- does not recurse into arbitrary nested directories;
- accepts only represented audio extensions: M4A, WAV, FLAC, Opus, MP3, OGG, and AAC;
- ignores unrelated files;
- returns deterministic sorted results;
- reuses the same supported-extension set for managed imports.

Focused commits:

- `9bb0dc8162ac914b30e18c37ae42b7349a016d5b` — `feat: expose recoverable managed recording files`.
- `7b2a34d20db98f6feb5129b754d96faa8861541a` — `test: cover recoverable managed file discovery`.

## Orphaned managed-audio recovery

Added `lib/services/library_recovery_service.dart` and wired it into application startup after metadata/path reconciliation.

The recovery service:

- compares normalized managed recording paths with the loaded metadata index;
- ignores managed audio already represented by metadata;
- derives the recording format from the managed file extension;
- captures filesystem size and modification time;
- best-effort probes duration;
- best-effort extracts a waveform envelope;
- still reconstructs a library entry when duration probing or waveform extraction fails, so a preserved damaged/partial file remains visible for inspection/export/deletion instead of becoming a hidden orphan;
- assigns a new unique metadata ID;
- preserves unknown bitrate/sample-rate/channel metadata as zero rather than inventing technical properties;
- tags reconstructed entries `Recovered` and records the recovery reason in notes;
- persists recovered entries through the normal metadata transaction.

This closes an important data-preservation loop: if managed audio was successfully written but the process stopped before its metadata could be safely registered, the next startup can reconstruct the missing index entry. It also allows supported managed recordings to reappear after an unrecoverable metadata document has been preserved and reset.

Focused commits:

- `116a2fb419266f872e0b268af30b7c6570a83559` — `feat: add managed library orphan recovery service`.
- `59aedbe2b3db376490c42c9b5442d2769c22277a` — `test: cover managed orphan recording recovery`.
- `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` — `feat: recover orphaned managed audio at startup`.

## New deterministic regression coverage

The continuation added/expanded direct filesystem and model tests for:

- managed rename/Trash/restore staying inside SonicNest storage;
- external-path mutation rejection;
- permanent-delete protection for unrelated external files;
- collision-safe recording allocation;
- supported top-level managed-file discovery;
- negative/non-finite numeric metadata normalization;
- zero/unknown imported channel metadata preservation;
- finite/bounded waveform metadata recovery;
- corrupt metadata reset after diagnostic preservation;
- prevention of repeated corrupt-primary diagnostic copies after a successful reset;
- duplicate ID isolation;
- duplicate file-path isolation;
- preservation of both corrupt primary and corrupt backup before reset;
- orphan recording reconstruction;
- known-entry deduplication during orphan scanning;
- damaged-media orphan recovery when probe/waveform operations fail;
- recovery for every represented recording format;
- the pre-existing 3,000-entry metadata filesystem round-trip.

## Documentation synchronized in this continuation

Updated repository documentation now includes the new managed-storage and recovery invariants:

- `docs/METADATA_INTEGRITY.md` documents corruption normalization, duplicate isolation, managed-path reconciliation, orphan recovery, and persistence-safe mutation behavior;
- `SECURITY.md` documents the managed audio mutation boundary and limits of that boundary;
- `README.md` surfaces orphan recovery, path guards, and persistence rollback behavior without changing the development-preview classification;
- `TODO.md` narrows remaining reliability work to real filesystem/device/corpus/stress evidence rather than already-covered deterministic logic;
- `CHANGELOG.md` records the new reliability implementation and its exact validation state;
- `what_changed.md` preserves all prior continuation history and appends this full continuation record.

Focused documentation commits created so far in this continuation:

- `40f02323779132b9a8e111ea01b7f3beb442ffb8` — `docs: document managed library recovery hardening`.
- `338eb3219eb77a862d338e701f5ad4d9401bd539` — `docs: document managed audio mutation boundary`.
- `610a72e32ca6bddcde448a9b4e7424a89e051c8a` — `docs: surface managed library recovery safeguards`.
- `648a73dcee806687d8cba71ea1b1567ddeac0058` — `docs: narrow remaining reliability work to evidence gates`.
- `b5ae1f5a4f99d765ada329d89be613db75d3b97f` — `docs: record managed library recovery hardening`.
- this additive `what_changed.md` continuation commit.

## Exact automated validation state at this ledger update

The application-source revision under final validation is:

- `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` — `feat: recover orphaned managed audio at startup`.

Core Flutter CI run `31867130926` has completed successfully for:

- host generation;
- dependency resolution;
- deterministic branding source generation;
- Dart formatting;
- Flutter static analysis;
- the complete unit-test suite including the new storage/metadata/orphan regressions;
- Linux debug build.

At the moment of this ledger append, the Android debug-build job in that exact core run is still compiling and is therefore **not** pre-claimed as successful.

Cross-platform validation on the same source revision:

- Windows run `31867130920`: Windows debug build **SUCCESS**;
- Apple run `31867130998`: macOS debug build **SUCCESS** and unsigned-iOS debug build **SUCCESS**.

Linux Package CI run `31867130938` on the same source revision is **SUCCESS** for:

- Flutter Linux release build;
- Debian `.deb` construction;
- package verification;
- package metadata inspection;
- package-manager installation;
- installed-package virtual-display startup smoke;
- package-manager uninstall;
- artifact upload.

Intermediate workflow runs cancelled by newer source commits during this continuation are concurrency replacements, not source failure evidence. Only the final-source workflow results above are used as the exact continuation evidence.

## Evidence-dependent work intentionally left open after this continuation

The following work cannot be truthfully completed through repository-only automation and remains unchecked:

- low-storage recording/import/export/editor failure behavior on real systems;
- permission revocation and filesystem error recovery on representative target systems;
- abrupt process/device/power interruption during real metadata/audio writes and verification of the resulting recovery behavior;
- real playable, partially written, and damaged managed-audio orphan recovery on every maintained platform;
- privacy-safe malformed real-media corpus testing;
- real large-library startup/search/filter/scroll/memory profiling;
- long-duration recording and editor/playback soak testing;
- microphone permission, routing, background, interruption, Bluetooth/wired/USB behavior;
- real media-session and media-button behavior;
- accessibility audits;
- real native-brand visual inspection and screenshots;
- representative Debian/Ubuntu package installation/upgrade/audio-routing/accessibility/visual evidence;
- maintainer-owned signing, provisioning, notarization, store dashboards, and public distribution approval.

The project remains a **development preview**. Repository regression tests and hosted builds materially reduce known software risk, but they do not constitute physical-device or stable-release evidence.

## Exact continuation point

Do not reimplement the storage guard, corrupt-store reset, duplicate metadata isolation, transaction rollback behavior, or orphan recovery in the next continuation. Start by checking the final Android result for source `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe`; if it succeeds, synchronize that exact result into project-state/release evidence documentation. After that, further legitimate work is evidence-driven unless a new reproducible repository defect is identified.

## 2026-08-15 — Storage boundary, batch execution, release-policy, and validation continuation

This section is additive. All earlier continuation history above remains intact.

### Managed storage authority and filesystem safety

- `StorageService` now treats a path as managed audio only when it is inside the allowed active/Trash location, has a supported recording extension, and resolves to a regular file when inspected with symbolic-link following disabled.
- Rename, duplicate, move-to-Trash, restore, and permanent-delete guards therefore refuse external paths, unsupported regular files, symbolic links, directories, and other non-regular filesystem entries.
- Managed destination allocation checks `FileSystemEntity.type(..., followLinks: false)` and treats ordinary files, directories, symbolic links, broken symbolic links, and uninspectable paths as occupied.
- Recording/Trash counts and byte totals now use the same supported top-level regular-audio definition used by startup recovery. Temporary processing storage remains separate because backend work products can legitimately use non-audio/nested artifacts.
- Automatic recording sequence counting now counts managed active/Trash audio rather than unrelated directory contents; collision-safe destination allocation remains the final overwrite guard.
- Startup reconciliation is covered end-to-end for safe indexed entries, unsafe external/unsupported/missing metadata removal, active orphan reconstruction, Trash orphan reconstruction, and no duplicate reconstruction across restart.

### External export collision hardening

- External copy allocation is now entity-aware rather than regular-file-only. A destination basename occupied by a directory, symbolic link, or broken symbolic link is not selected for overwrite/following.
- Batch original export still preserves successful copies when a later source fails.
- Deterministic tests cover ordinary collisions, directory collisions, broken-link collisions on supported hosts, missing sources, unavailable destinations, duplicate basenames, and mixed-success batches.

### Batch conversion production service

- Added `lib/services/batch_conversion_service.dart` as the deterministic sequential execution boundary used by production Batch Convert.
- The service prefers known source bitrate/sample-rate/channel metadata and falls back to current recording settings only when source values are unknown.
- Each conversion is registered into the managed Library before an optional external-folder copy. An external-copy failure therefore does not invalidate a conversion already preserved in SonicNest.
- Per-file transcode/registration failure is isolated; later files continue unless a stop request is active.
- Failed generated-output registration removes the output only when storage confirms it is eligible managed audio. A caller-supplied external path is preserved.
- Stop behavior is explicitly "Stop after current file": the service checks before starting an item and after completing the current item rather than forcibly terminating FFmpeg mid-write.
- `BatchConvertScreen` now delegates to this service. Disposing/leaving the screen raises the same stop request so another selected item is not intentionally started after the current conversion completes.
- `test/batch_conversion_service_test.dart` covers transcode failure isolation, registration cleanup, external-output protection, external-copy isolation, stop-before/after-current behavior, progress, and source technical-setting precedence.

### Recorder construction hardening

- `RecorderService` no longer instantiates `AudioRecorder` in its constructor. The native recorder backend is created lazily when input-device/permission/capture functionality actually needs it.
- This removes constructor/disposal-time native method-channel side effects from pure controller tests without weakening production microphone permission checks or recorder capability checks.
- After the lazy-backend change, the controller suite reached real persistence logic instead of failing during native plugin construction.

### Persistence-test correction

- The stopped-recording metadata-save regression initially created its output before `AppController.initialize()`. With active orphan recovery implemented, startup correctly reconstructed that file, so the fixture was testing the wrong phase.
- The corrected test creates the completed managed audio after startup and then injects metadata-save failure during `stopRecording()`.
- The expected invariant is now tested directly: the unsaved in-memory entry is removed, the completed managed audio remains on disk, and restart recovery can reconstruct it later.

### Localization policy decision

- Added `docs/LOCALIZATION_POLICY.md`.
- Ordinary product-facing labels, actions, confirmations, summaries, and high-level errors belong in localization.
- Raw operating-system, plugin, FFmpeg, filesystem, path, and backend diagnostic detail remains technical/source-language evidence unless SonicNest maps a stable backend code to its own localized message.
- Diagnostic evidence remains privacy-sensitive and is not uploaded automatically.
- Additional locales remain gated on translation review, expansion/layout checks, plural behavior, accessibility, and RTL review where applicable.

### Linux public distribution policy decision

- Added `docs/LINUX_DISTRIBUTION_POLICY.md`.
- The initial public Linux channel is GitHub Releases with the repository-verified Debian `.deb` plus SHA-256 checksum.
- SonicNest does not initially operate a custom APT repository, so APT repository-index signing is not applicable to this first channel.
- Development-preview CI packages may remain unsigned but cannot be represented as signed stable artifacts. Any future signature policy uses maintainer-owned credentials outside the repository.
- Real representative-system install/audio/desktop/accessibility/upgrade evidence remains a stable-release gate.

### Documentation synchronized in this continuation

Updated or added: `README.md`, `SECURITY.md`, `TODO.md`, `docs/ARCHITECTURE.md`, `docs/BATCH_CONVERSION.md`, `docs/LINUX_DISTRIBUTION_POLICY.md`, `docs/LOCALIZATION_POLICY.md`, `docs/MANAGED_STORAGE_BOUNDARY.md`, `docs/METADATA_INTEGRITY.md`, `docs/RECOVERY_INDEX.md`, `docs/RELEASING.md`, `docs/TROUBLESHOOTING.md`, `docs/USER_GUIDE.md`, `docs/QA_CHECKLIST.md`, `CHANGELOG.md`, `RELEASE_NOTES.md`, `PROJECT_STATE.md`, and this additive ledger.

Ledger/state synchronization commits generated in this final pass:

- `c0c01ef543591c611761f3b821b3448b76e7f8df` — `docs: record final recovery and batch QA evidence`.
- `c94f162cfae0f12916a31c485d4a5707ecc8e95d` — `docs: record storage batch and release hardening changes`.
- `fbc5ece5676fb18d103b9d0a219c2af30e05ef95` — `docs: add current development preview hardening notes`.
- `8da55fd1ae640a17a44a00e9588addee2c4a19e2` — `docs: synchronize final hardening project state`.
- this `what_changed.md` append commit follows those records.

### Exact application/source validation relationship

Application-code revision:

- `72797fa477b9d88e2138b7ddf1d0f845cdd549ca` — `fix: lazily initialize native recorder backend`.
- This revision contains the final application code from the storage-boundary, external-export, batch-service/UI, and lazy-recorder continuation.
- Windows run `31870087266`: **SUCCESS**.
- Apple run `31870087249`: **SUCCESS** for macOS debug and unsigned-iOS debug.
- Linux Package CI run `31870087317`: **SUCCESS** for the maintained Debian package pipeline.

Final source/test revision:

- `e47b290a7255f126cfcf1436444a90cc32d10823` — `test: isolate stopped-recording persistence rollback scenario`.
- Its additional change is a test-fixture correction; it does not alter application code.
- Core Flutter CI run `31870224720`: static analysis **SUCCESS**, complete **87/87** test suite **SUCCESS**, Android debug **SUCCESS**, Linux debug **SUCCESS**.

### Formatter boundary intentionally not overclaimed

The core CI job runs `dart format` before analysis/tests and reported `Formatted 54 files (30 changed)`. Therefore:

- analyzer/tests/build behavior is green on the formatter-normalized checkout;
- the committed Dart tree is **not** claimed formatter-clean;
- `TODO.md` now explicitly tracks committing the formatter output for the CI toolchain;
- after that source cleanup is committed, CI should become a non-mutating formatting enforcement gate rather than silently correcting drift before validation.

This is the remaining repository-only hygiene item identified in this continuation. It is intentionally not hidden by the otherwise green validation result.

### Release/evidence boundary

The project remains a **development preview**. Still-open work is evidence-dependent: physical microphone permission/routing, background/lock-screen/interruption behavior, real low-storage/permission/process/power-loss recovery, playable/partially-written/damaged real-media recovery, malformed-media corpus testing, large-library/large-batch/long-duration profiling, screen-reader/accessibility audits, native-brand visual review, representative Debian/Ubuntu install/audio/upgrade/desktop evidence, real screenshots, Windows signing decision, Android/Apple signing/notarization, and final stable release approval.

Do not convert those unchecked gates to completed status from hosted unit/build evidence alone.

### Exact continuation point

Do not reimplement the managed-path boundary, active/Trash orphan reconstruction, entity-aware collision rules, batch execution service, lazy recorder construction, Linux GitHub Releases policy, or diagnostic localization policy in the next continuation. The next repository-only task is the formatter-cleanup/enforcement item in `TODO.md`. After that, remaining work is primarily real-system evidence and maintainer-owned signing/release work unless a new reproducible repository defect is found.

## 2026-08-15 — Canonical formatting, distribution copy, Windows signing policy, and final automated validation

This additive section supersedes the earlier temporary formatter-hygiene warning while preserving the full history above.

### Canonical Dart formatting is closed

- `22c1d46e077625d6e1964d56716700727d1800dc` — `style: commit canonical Dart formatting`; the stable Flutter/Dart formatter output for `lib`, `test`, and `tool/generate_brand_assets_v2.dart` is now tracked.
- `704b0f60aae8f179f4f41875c336d2052b45391e` — `ci: enforce Dart formatting without mutating source`; core CI now runs `dart format --output=none --set-exit-if-changed ...` and fails on drift instead of silently rewriting validation checkout source.
- `6d379e23edce9eb0f09d65412426b678c01e900f` — formatter-hygiene TODOs closed.
- The temporary format helper self-removed; no write-enabled formatter helper remains in the final repository.

### Formatter-clean source revision and exact automated evidence

Formatter-clean source revision: `4e0fbf16534a60e2d3209c5ec5f54d4982903f8c`. The final application changes from this continuation are included before this revision; later commits described below are documentation/policy only.

- Core Flutter CI run `31870933447`: non-mutating Dart format check **SUCCESS**, static analysis **SUCCESS**, full unit suite **SUCCESS**, Android debug build **SUCCESS**, Linux debug build **SUCCESS**.
- Windows run `31870933908`: Windows debug build **SUCCESS**.
- Apple run `31870933903`: macOS debug build **SUCCESS** and unsigned-iOS debug build **SUCCESS**.
- Linux Package CI run `31870933982`: Linux release bundle **SUCCESS**, Debian package build/verify **SUCCESS**, install **SUCCESS**, installed-app smoke **SUCCESS**, uninstall **SUCCESS**, artifact upload **SUCCESS**.
- This closes the earlier repository-only formatting drift. No formatter-cleanliness limitation remains open in `TODO.md`.

### Store/distribution listing and privacy copy

- `a4c3068c5fb07a9d4f801ce9227188c58ea87950` — added `docs/STORE_LISTING.md` with source-controlled short/long descriptions, feature bullets, privacy statements, microphone/files/local-data/share declarations, Android/Apple/macOS/Windows/Linux distribution drafts, screenshot/privacy rules, and submission review checklist.
- `40621aeb847ae5c21e9d9b825cd761947aac2a58` — marked the repository-side listing/privacy draft complete while retaining exact-candidate store-console review as release work.
- `cd1a9b926c416a40101cca6f96993b1f24d71c28` and `ebf887c2b046429a864efd41678e8a39ed3eccb4` — release guide/README aligned with non-mutating formatting and listing review.

### Windows public signing policy

- `02af50f6ba7d59d2cc08838f9e5c230b0d096524` — added `docs/WINDOWS_SIGNING_POLICY.md`. Stable public Windows distributables should be Authenticode-signed with a maintainer-controlled identity.
- `43556d9b313754812510cab9d97aaab361172086` — split the completed policy decision from the still-open private certificate/signing-service and final installer/package configuration work.
- `6ac8b079c3ec002df87f3b001d22ab1cf48da359` — release guide aligned with that policy.
- No signing private key, password, certificate bundle, or provider credential is committed.

### Final state synchronization commits

- `286ed75c1ec0f816a5ec983d6ec3781b244c0ce9` — `docs: record formatter-clean cross-platform QA evidence`.
- `b32d96379ed2abcac207576818999a59d8a92ec8` — `docs: record formatter-clean release hardening changes`.
- `77103bdba4f9bd1da1b9571f61eb08739d04afe5` — `docs: add formatter-clean development preview validation note`.
- `fd4a21578724c6b822f421eda890941a80da4b8d` — `docs: set formatter-clean final automated project state`.
- `c803d077b2aaeb95f7995470ab886b9429728853` — `docs: link Windows signing policy from README`.
- this `what_changed.md` append commit follows those records.

### Remaining boundary

Repository-only implementation/policy work identified in this continuation is complete. Remaining unchecked items are intentionally evidence/credential dependent: physical microphone permissions/routing, interruptions/background/lock-screen behavior, low-storage and real permission/process/power-loss recovery, real partially written/damaged media, long-duration and large-library/batch profiling, accessibility audits, real branding/screenshots, representative Linux installation/audio/upgrade/desktop review, Android/Apple private signing, Windows Authenticode credential/service and final installer integration, signed candidate production, release checklist completion, and final `v1.0.0` approval.

Do not mark those items complete from hosted CI alone.

## 2026-08-15 — Final release-mode packaging, distribution policy, workflow security, and evidence continuation

This section is additive and preserves every earlier continuation record above. It closes the repository-owned release-automation work that remained after formatter cleanup without turning hosted build/package results into physical-device or stable-release approval.

### Windows portable package format and shared validation path

- The initial repository-supported Windows package format is now a versioned x64 portable ZIP built from the complete Flutter release runner bundle.
- `tool/build_windows_portable.ps1` creates the portable archive, validates required runner/data payload, rejects sensitive/signing-material patterns from the package input, writes package metadata, and records SHA-256 output.
- `tool/verify_windows_portable.ps1` extracts the package and verifies `sonic_nest.exe`, `flutter_windows.dll`, Flutter data/assets, checksum metadata, and optional Authenticode status.
- `tool/smoke_test_windows_portable.ps1` extracts the package and performs a bounded startup smoke against the packaged executable rather than a copied standalone binary.
- Permanent Windows CI and the manual release-candidate workflow use the same builder/verifier/startup-smoke helpers so the two package paths cannot silently drift.
- The initial public Windows channel remains GitHub Releases; stable public Windows binaries require final maintainer-owned Authenticode signing and post-signing checksum generation.

Permanent Windows Build run `31872928500` independently passed Windows debug compilation plus release build, portable ZIP construction, structural verification, extracted-package startup smoke, warning/checksum metadata generation, and artifact publication.

### Android non-production release-candidate classification

The hosted Android release build produced signed APK/AAB bytes, so describing them as unsigned would have been inaccurate. The release-candidate path was corrected to inspect and record the actual signing state.

- Added `tool/verify_android_nonproduction_candidate.sh`.
- The verifier confirms package identity `io.github.sanskarin.sonic_nest` and application label `SonicNest`.
- It verifies APK signatures with Android tooling and checks the AAB signature before upload.
- It requires the hosted certificate to be the generated Android Debug identity and writes `ANDROID_SIGNING_STATE.txt`.
- Release-candidate filenames now use `nonproduction` rather than `unsigned` for Android.
- Hosted Android artifacts are explicitly **NON-PRODUCTION** and are not substitutes for the protected Google Play upload-key/Play App Signing candidate.

Final hosted Android certificate evidence:

- DN: `C=US, O=Android, CN=Android Debug`
- SHA-256: `ccbfe6b04e1859cf9064c9e5a2c8f9fe1d73be92e6ef1454142b9d2fbfff89e1`
- SHA-1: `fc13d257c05e8fcb704723cec1bd9aa6d5663e29`

### Android and Apple distribution policies

Repository-side channel/signing decisions are now explicit rather than left as ambiguous release work:

- `docs/ANDROID_DISTRIBUTION_POLICY.md` selects Google Play as the initial Android public channel, Play App Signing as the production signing model, and a separate maintainer-controlled upload key outside the repository.
- `docs/APPLE_DISTRIBUTION_POLICY.md` selects TestFlight/App Store for iOS and signed/notarized GitHub Releases as the initial macOS public channel.
- Hosted macOS and iOS release-mode artifacts remain unsigned/no-codesign validation evidence only.
- Actual Android upload-key/Play Console, Apple provisioning/signing/notarization/App Store Connect, and Windows Authenticode credentials remain maintainer-owned and outside the repository.

### Full clean cross-platform release-candidate validation

A clean source revision was frozen and validated without changing it underneath the matrix:

- Candidate source SHA: `048870ec8dc26a16e2451310460d3e03c9084dc7`
- Release Candidate Validation run: `31873121457`
- Source preflight: **SUCCESS**
- Android release-mode non-production APK/AAB build: **SUCCESS**
- Android package/signing-state verification: **SUCCESS**
- Linux release bundle and Debian package build/verification: **SUCCESS**
- Windows release portable build/verification/extracted startup smoke: **SUCCESS**
- macOS release-mode archive: **SUCCESS**
- iOS release-mode no-codesign archive: **SUCCESS**

Exact inner artifact SHA-256 values:

- Android APK: `1fe7ea48d771209f4bfea097fc7d9e723cff00411b2541ee848e7ec20d6c271e`
- Android AAB: `ecaf9842980b17af06f3b3f90898d286a3b38ebf0b15259271af2f07dab72f4f`
- Linux raw release bundle: `a5fe64b440bf19b1b8a74e5a5ff875e645c2da7661bd8492e1a910160de179f8`
- Linux Debian `.deb`: `414f11ad877c7c51861a14817cd3900d2bb77d3b49ea949d601e3686d5346498`
- Windows portable ZIP: `60f5680548b0352d5230b6d40acc17a8b8b12d075b2ce1fd08c6209f565e3eb1`
- macOS release archive: `364c0d8f84c2779c45a36e13fd59d6bbcceebe03f62662a41dc4e2f9178d4af3`
- iOS no-codesign archive: `8d1209b94aa1aaff4369dff041ace9698bf4dcd5e0e6363a0fd470c50ee2e54d`

Workflow artifact digests:

- Android: `sha256:05581adf264aa0c425edc27afbd9ae174a219599c460bc94ea8400e3c70929f7`
- Linux: `sha256:8e129ff08c559ec684d78d509c5311281f2239f58ba6d9b4954fd0d9e34c84ab`
- Windows: `sha256:895f74a0decba44ddd104bd2eb148fda059be656fd2edff0cb9f77cfe296c271`
- macOS: `sha256:c7972d5fb532bd253be3503f1596212c96767279778716bc2301dc95e517e4e3`
- iOS: `sha256:c9a61440a727202ac763a927b79486120a85d4674e919d4f255f67fe5cd497ea`

These exact values are preserved in `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md` so workflow retention/expiration does not erase the evidence record.

### Repository integrity hardening

`tool/repository_audit.py` was strengthened beyond its earlier workflow guard:

- tracked workflow discovery now includes both `.yml` and `.yaml` files;
- unapproved workflows under either extension fail the audit;
- permanent workflow write scopes are rejected with whitespace/case-tolerant matching;
- scalar `permissions: write-all` is explicitly rejected;
- the Android non-production verifier, Windows package builder/verifier/startup smoke, Android/Apple/Windows policy documents, and exact automated evidence record are required repository invariants;
- Bash and PowerShell helper parsing remains part of the maintained audit workflow.

Validation:

- Clean candidate-tree Repository Integrity Audit run `31873122160` on `048870ec8dc26a16e2451310460d3e03c9084dc7`: **SUCCESS**.
- Strengthened audit commit `64c121fa0e5c81531a3710b1d67b88fb3dfc93db` — `chore: close workflow audit extension and write-all gaps`.
- Strengthened Repository Integrity Audit run `31874506476`: **SUCCESS**.

### Exact evidence/documentation commits in this continuation

Focused commits include:

- `64c121fa0e5c81531a3710b1d67b88fb3dfc93db` — `chore: close workflow audit extension and write-all gaps`.
- `9bde66ff9bb7763131d5b09cfb73d0aad4da06b1` — `docs: add exact automated release candidate evidence`.
- `7a9dae274295598cc6aed2dc37f0e59cc2512e3d` — `docs: index exact automated release evidence`.
- `6e10651f04976fd9b555b0b47ddba3dbe9166754` — `chore: require automated release evidence record`.
- `09044264b3572d42d931ecec21eb28b83e8a4c50` — `docs: synchronize project state with release candidate evidence`.
- `a4add5eb47eb8ddb808d3da6e00b33914f5bc9b8` — `docs: close repository-owned release automation tasks`.
- `841a788872ec9ecf40ab2e338808cf1ac3a61154` — `docs: record final automated release candidate validation`.
- `ae0cf577bdae0c0f618f8733056974cc624677fb` — `docs: add final hosted release candidate evidence`.
- `d366a5476ce5277117f060641659a628b4fe9c07` — `docs: add exact cross-platform release QA evidence`.
- this additive `what_changed.md` commit follows the documentation synchronization above.

### Current repository-owned completion boundary

No additional repository-only release-automation gap is currently identified. The maintained source now has:

- formatter-clean source-quality validation;
- cross-platform release-mode hosted artifact generation;
- Android non-production signing-state verification;
- Linux Debian package validation;
- Windows portable package build/verify/startup-smoke validation;
- macOS release-mode validation;
- iOS release-mode no-codesign validation;
- explicit Android, Apple, Windows, and Linux public-channel/signing policies;
- exact candidate hashes/digests preserved in source control;
- permanent workflow allowlisting and read-only workflow enforcement.

The remaining work is intentionally not converted into repository-complete status because it requires evidence that hosted automation cannot truthfully provide:

- physical Android/iOS/macOS/Windows/Linux microphone permission/capture/routing tests;
- built-in, wired, USB, Bluetooth, and external-interface input behavior;
- call/alarm/audio-focus interruption, background, lock-screen, and media-button behavior;
- real low-storage, filesystem permission, process-kill, device/power-loss, malformed-media, partially written-media, and orphan-recovery scenarios;
- 30-minute and multi-hour recording soak tests;
- real large-library, long-audio, large-batch, and low-resource performance profiling;
- TalkBack, VoiceOver, Narrator, Linux accessibility-tool, large-text, keyboard-only, and reduced-motion audits;
- native launcher/splash/desktop visual review and real screenshots from exact tested candidates;
- representative Debian/Ubuntu install/upgrade/audio/desktop/uninstall evidence;
- representative Windows portable microphone/routing/accessibility/branding/cleanup evidence;
- protected Android Play upload-key/App Signing production candidate;
- Apple provisioning, protected signing, notarization, TestFlight/App Store Connect validation;
- Windows Authenticode signing/trust verification on the exact final public package;
- final stable-release checklist approval and `v1.0.0` tag.

SonicNest therefore remains a **development preview**. The next continuation should not reimplement the closed release automation; it should consume real-system/maintainer evidence or fix a newly reproducible repository defect.


## 2026-08-15 — Unified release-candidate provenance manifest continuation

This section is additive. All earlier SonicNest continuation history above remains preserved unchanged. This continuation did not alter recorder/runtime application behavior; it hardened repository-owned release evidence so a hosted cross-platform candidate can be tied to one exact source revision and its downloaded platform artifact bytes without overstating stable-release readiness.

### Machine-readable provenance builder

Added `tool/build_release_candidate_manifest.py` as a Python-standard-library-only release evidence tool. It requires Android, Linux, Windows, macOS, and iOS candidate artifact directories, verifies each platform `SHA256SUMS.txt`, requires Android `ANDROID_SIGNING_STATE.txt`, prevents absolute/parent-traversal checksum references, rejects missing/mismatched or unchecksummed release payloads, validates a full 40-character source SHA plus positive run ID/attempt, reads the application version from `pubspec.yaml`, and records every evidence file's SHA-256/size/role.

Hosted manifest output explicitly records `releaseClassification: development-preview`, preserves platform signing classifications, and sets `stableReleaseApproved: false`.

Focused commit:

- `86e0bbab9b8e31c81c57814277f8f3ef41d34399` — `feat: add release candidate provenance manifest builder`.

### Regression coverage and permanent audit integration

Added `tool/tests/test_release_candidate_manifest.py` covering complete construction, tampering, missing checksum coverage, checksum path traversal, Android signing-state markers, missing platforms, and full-SHA enforcement.

Added `tool/tests/test_release_candidate_integration.py` locking the final workflow aggregation job, all five platform inputs, source/run binding, manifest publication, and permanent Python tooling test execution.

Focused commits:

- `252c71dc6c8a1b566ad544601ede954b7a35f365` — `test: cover release candidate manifest verification`;
- `3d4787afb00a3729f09dcfd2ad07189752dc5f88` — `test: lock release candidate manifest workflow integration`;
- `a970bf6c9100b5bfd00821a002b682473b0c1e59` — `ci: validate Python release tooling in repository audit`.

Repository Integrity Audit run `31876149473` completed successfully with Python helper compilation, repository invariants, **10/10** Python release-tool tests, Bash helper parsing, and PowerShell helper parsing all green.

### Unified release-candidate workflow job

Commit `e6182098ce205ef9f6008c5bd1418055c12377c3` added **Unified candidate provenance manifest** to `.github/workflows/release-candidate.yml` with `needs: [android, linux, windows, macos, ios]`.

After all five platform jobs succeed, the job downloads those exact artifact sets through `actions/download-artifact@v4`, invokes the manifest builder using `${GITHUB_SHA}`, `${GITHUB_RUN_ID}`, and `${GITHUB_RUN_ATTEMPT}`, writes `RELEASE_CANDIDATE_MANIFEST.json`, writes its own checksum and development-preview warning, and uploads `sonicnest-release-candidate-manifest`.

### Documentation and contribution contract

Added and synchronized:

- `docs/RELEASE_CANDIDATE_MANIFEST.md`;
- `docs/README.md` index;
- `CONTRIBUTING.md` provenance requirements;
- `docs/UNSIGNED_ARTIFACTS.md` unified artifact behavior;
- `docs/RELEASE_EVIDENCE_TEMPLATE.md` manifest evidence fields;
- `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md` exact hosted provenance record;
- `TODO.md` repository-automation completion state;
- `PROJECT_STATE.md` exact provenance validation relationship.

Focused commits include:

- `0aca44f9e35aca9c4b2c4da927935785413d2ca0` — `docs: document unified release candidate provenance manifest`;
- `e087cf82a023de62d021e029cc67785f8c67fa9e` — `docs: index release candidate provenance manifest`;
- `eac04f1dfe2959342556cd72764bc40720a52f09` — `docs: add release provenance contribution checks`;
- `bd5fe0b6820f41e3105e179c6a644080258157b9` — `docs: document unified candidate provenance artifact`;
- `77b80c290c4a47d16884c944fee4accfed54525a` — `docs: add unified provenance manifest evidence fields`;
- `0af3a861d8161d05b7c9ac084731c0d5b0b41433` — `docs: close hosted provenance manifest validation`;
- `23658ef6a152b37d9a2b960c62b8c3d2e05477a2` — `docs: record unified hosted provenance validation`;
- `f345d6e8bd2e0a523c44a6f849b5c98e56fe0b03` — `docs: synchronize project state with provenance validation`.

### Controlled hosted validation and cleanup

The connector available for this continuation did not expose workflow dispatch. The maintained release-candidate workflow therefore temporarily received a narrow push trigger limited to `docs/RELEASE_CANDIDATE_MANIFEST.md` solely to obtain hosted evidence.

- `61186265e6eafeafadd2c51354dc0485f971f64d` — `ci: add one-time manifest validation trigger path`;
- `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c` — `docs: trigger hosted provenance manifest validation`.

After validation, the temporary trigger was removed:

- `79b5195e7f207ebc1076e38faecb5c4c9c2447e7` — `ci: restore manual release candidate trigger`.

The maintained release-candidate workflow is again manual `workflow_dispatch` only.

### Exact hosted provenance validation

Release Candidate Validation run `31876035202` on source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c`, attempt `1`, completed **SUCCESS**.

Successful jobs:

- Source preflight;
- Android release-mode non-production artifacts;
- Linux release-mode artifacts;
- Windows release-mode artifact including portable build/verify/extracted startup smoke;
- macOS release-mode artifact;
- iOS no-codesign release-mode artifact;
- Unified candidate provenance manifest.

The generated manifest records application version `0.1.0+1`, source SHA `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c`, run `31876035202`, attempt `1`, release classification `development-preview`, and `stableReleaseApproved: false`.

Manifest JSON SHA-256 recorded by the workflow and independently recomputed after downloading the artifact:

- `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`

Manifest workflow artifact digest:

- `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`

Platform payload SHA-256 values re-verified by the unified manifest:

- Android APK: `1457f53822af974de18905ba4d103b3c9a8fe2f66080848a48cd591f6287f9b8`
- Android AAB: `029571a665ec3359cdee5cb2b5c8357c8b3c450ef3fcb1f63d8f808eb635e99a`
- Linux raw release bundle: `fbecb458fec864d451f0ba67e0b70f58f34710de883d5d4c8c86e32ab3238bd6`
- Linux Debian `.deb`: `eee447e80713f8c4102c200349cfae0873da1948dc0e2740f1b7d058a07d26e1`
- Windows portable ZIP: `c0cbc9ef7d00481e9f39fc058d5747779372dd61454a542eb5ce487d2da68ff3`
- macOS release archive: `0a4b2ac2c097e0f53eabbf84909ddc8f28bd28bd8bc37a0ea189b4ebc810733a`
- iOS no-codesign archive: `a6b77c3d3a5badc305c7d7ebfc3a5a646197b48f09c1000854980fcffaaf17a7`

Workflow artifact digests from the same run:

- Android: `sha256:9a123c791ca5fce6391be017f0873ffa770f317f7c8fc75d975c38731820d0d6`
- Linux: `sha256:5a80aeb576c5cfea3d9c58f65a29e4e8aadb306d6bc59d0c71beafc5ee7e36ed`
- Windows: `sha256:1ad4aee180fcb114d5f7b8a40d9e458dd0e7e8abcdbc661e7bfad3dbbc4489b3`
- macOS: `sha256:e578be6e601502c25169399d650e245013852f26799bcf599a893d6d001efb99`
- iOS: `sha256:ee6d63de19d362efc400df6beec326c8a04019bfab093d23b76af8ffa12a571d`
- Unified manifest: `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`

### Current completion boundary

No additional repository-only release-automation gap is currently identified. Remaining work requires physical/representative systems, sustained workloads, assistive technologies, real media/filesystem failures, protected maintainer credentials, store dashboards, or final release approval.

Still intentionally open are microphone permission/capture/routing, wired/USB/Bluetooth/external-interface behavior, interruption/background/lock-screen/media buttons, low-storage/permission/process/power-loss recovery, real damaged/malformed media, long-duration/stress/performance profiling, desktop interaction/accessibility audits, native visual review and real screenshots, representative Linux/Windows package QA, Android Play production signing, Apple provisioning/signing/notarization/TestFlight/App Store, Windows Authenticode, final release checklist approval, and `v1.0.0` tagging.

SonicNest therefore remains a **development preview**. The provenance manifest proves hosted artifact checksum/source/run consistency; it does not replace those real-world or protected-signing gates.


## 2026-08-16 — Privacy-safe in-app diagnostics and QA evidence

### Continuation objective

The previous repository state had no remaining repository-only release-automation gap; the unchecked release list was dominated by physical-device microphone/routing/lifecycle tests, sustained recording and batch workloads, real filesystem/storage failures, accessibility audits, protected signing/notarization, distribution-console work, and final release approval. This continuation therefore implemented the next code-side feature that materially improves those remaining evidence workflows without pretending to replace them: a privacy-safe in-app Diagnostics & QA report.

### Diagnostic report model and privacy contract

- Added `lib/services/diagnostic_report_service.dart` with deterministic `DiagnosticReport` JSON and Markdown serialization plus schema versioning.
- Added canonical app/runtime evidence: app version/build, OS family, OS version string, locale, Dart runtime, and logical processor count.
- Added aggregate Library evidence only: saved, Trash, favorite, and pinned counts.
- Added aggregate managed-storage evidence through `StorageStats`: recordings, Trash, temporary bytes/file counts, total managed bytes, and an explicit probe-success flag.
- Added recorder-state evidence: recorder status, input-probe success, input-device count when safely available, and system-default-versus-custom input classification.
- Added non-content recording configuration: format, preset, bit rate, sample rate, channels, automatic gain, echo cancellation, noise suppression, countdown, and keep-screen-awake.
- Added non-content playback/interface evidence: default speed, skip interval, skip-silence, theme, reduced motion, and permanent-delete confirmation.
- The report deliberately does **not** receive or serialize recording objects, recording titles, recording paths, recording/audio content, notes, tags, bookmarks, smart-naming prefix/template/suffix/category text, or input-device names.
- JSON contains an explicit privacy object with every sensitive-content flag set to `false`.

### In-app Diagnostics & QA surface

- Added `lib/screens/diagnostics_screen.dart` and an **About -> Diagnostics & QA** entry in `lib/screens/about_screen.dart`.
- Diagnostics are generated only when the user opens or refreshes the surface; no automatic upload path was added.
- Storage and input-device probes fail independently and render as unavailable rather than fabricating values.
- Input-device enumeration is deliberately skipped while the recorder is active, avoiding a new recorder-backend enumeration during capture.
- Added **Copy JSON** through the system clipboard and **Share report** through a temporary Markdown file plus the existing explicit system-share service.
- The report surface uses constrained responsive layout, selectable diagnostic values, semantic loading text, retry behavior, and existing Material 3 conventions.

### Localization and canonical application metadata

- Added `lib/l10n/diagnostics_localizations.dart` for Diagnostics & QA product-facing text.
- Added `test/diagnostics_localizations_test.dart` for catalog labels, privacy copy, and helper formatting.
- Centralized `appVersion`, `appBuildNumber`, `appVersionWithBuild`, and `appDisplayVersion` in `lib/core/constants.dart`.
- Updated About and diagnostics to consume the same canonical application version source.
- Kept raw runtime/OS/backend values technical, consistent with the existing localization policy.

### Privacy and serialization regression coverage

- Added `test/diagnostic_report_service_test.dart`.
- The suite verifies deterministic machine-readable sections and expected app/library/storage/recorder/settings values.
- The suite verifies the exact privacy object rather than checking only one field.
- The suite injects sentinel values into smart-naming prefix, template, suffix, and category and proves those secret values cannot occur in JSON or Markdown output.
- The suite proves smart-naming field keys are absent from JSON.
- The suite verifies failed storage/input probes remain `null` / unavailable rather than being represented by invented metrics.
- Diagnostics localization tests verify privacy copy explicitly names recording content, titles, paths, notes, tags, bookmarks, and input-device names as excluded.

### Documentation and QA integration

- Added `docs/DIAGNOSTICS_AND_QA.md` with access instructions, privacy contract, report-field definitions, physical-QA usage, support-sharing guidance, and explicit evidence limitations.
- Updated `README.md` with the Diagnostics & QA feature, privacy behavior, and documentation link.
- Updated `TODO.md` so remaining hardware/lifecycle/reliability/accessibility/signing tasks can use diagnostics as supporting evidence without checking any manual gate off.
- Updated `ROADMAP.md` with the v0.4/v0.5 diagnostics milestone and a dedicated diagnostics evidence status section.
- Updated `RELEASE_NOTES.md` with the 2026-08-16 diagnostics continuation and exact core-CI evidence.
- Updated `PROJECT_STATE.md` with the current diagnostics contract, validated source revision, and explicit historical-release-artifact boundary.

### Formatter discovery, exact repair, and permanent gate restoration

The first hosted validation exposed canonical Dart-format drift in four new files. Rather than weakening the existing read-only formatter gate or guessing at formatting, a temporary CI revision ran the same hosted Dart formatter, printed its exact diff, and intentionally failed. That exact output was then committed file-by-file. The temporary formatter-diff step was removed, and `.github/workflows/ci.yml` was restored to the permanent non-mutating command:

`dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart`

The final validated source passes this gate with **59 files, 0 changed**.

### Analyzer defect found and fixed

After formatting was repaired, hosted static analysis found one integration error limited to the two new test files: they imported `package:sonicnest/...`, while `pubspec.yaml` canonically declares `name: sonic_nest`. Production diagnostics code was not changed for this issue. Both test import sets were corrected to `package:sonic_nest/...`, then the complete validation suite was rerun.

### Final automated validation

Final diagnostics source revision: `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910`.

Flutter CI run `31932491771` validates that exact source:

- Dart formatting enforcement: **success**, 59 files checked, 0 changed.
- Static analysis: **success**, `No issues found!`.
- Unit tests: **success**, complete suite **94/94**.
- Linux debug build: **success**.
- Android debug APK build: **success**.

The 2026-08-15 cross-platform release-candidate and provenance artifacts remain historical evidence for their exact older source revisions. They predate the Diagnostics & QA implementation and are intentionally **not** described as artifacts containing this feature. Windows/macOS/iOS/package/signing evidence for this newer source is not invented or inferred from those older artifacts.

### Commit ledger for this continuation

Each repository write continued to use `Sanskar <sanskarin@outlook.in>`.

- `e1bf8a67039e15fecad29ec133aab0c22086f69b` — `feat: add privacy-safe diagnostic report model`
- `e50c606bc7dd084e7999ca2d4307f1f595cf0d73` — `test: cover diagnostic report privacy and serialization`
- `c5af027198ec97498ea04833a30d85ef94f42341` — `refactor: centralize SonicNest version metadata`
- `953276429cb11468d35ca348bcaae343af17a72e` — `feat: localize diagnostics and QA evidence strings`
- `820d5cd09145f1e25d386a6a07cb2b7e12d4630d` — `feat: add in-app diagnostics and QA evidence screen`
- `db9319721629f5efa9e79ce3323e61b9a1f43a76` — `feat: expose diagnostics from About screen`
- `6513333cfce625a40864179eea02b74d7a43fd91` — `fix: complete diagnostics labels`
- `601e913e45da78077390946c5824e68ee62c07b3` — `fix: complete diagnostics screen integration`
- `f70a5f41cdbbc48b6559e7d2b429bac01bfaffcb` — `refactor: reuse canonical app metadata in diagnostics`
- `51ce8005a3f284f321f3039036bcd06f777f21ec` — `test: cover diagnostics localization catalog`
- `6d39b5354a413a14f6d0985c997875ccfebd1d42` — `test: enforce diagnostics privacy contract`
- `617b7e8b4caa5faa50d9f2d0acf5a0f53d621659` — `docs: add privacy-safe diagnostics QA guide`
- `384b3a50bf85f31b6f7bea81e4a22537c1012bb0` — `docs: document in-app diagnostics and QA reports`
- `0f3661d7198f0285c550267cb3f02c2ffbcbb0ad` — `ci: expose canonical diagnostics formatting diff` (temporary hosted formatter-diff revision)
- `417d65463191f5fdd0c6db62ae3a69dfe64de7ba` — `style: format diagnostics localization`
- `4f147c917542ba734cb9795049dc2b76299eec0f` — `style: format diagnostics screen`
- `ef5cdaedb956dd80263d640d9213692a3179e416` — `style: format diagnostic report service`
- `403aee21f783cc78e3c8eaa7a3ca2de0184379c1` — `style: format diagnostic report tests`
- `32ced086fac27fd2f4f808674afa511647a863e9` — `ci: restore non-mutating Dart formatting gate`
- `ec9495ce66586c7e150d98a3dd6b3dcfa84f36eb` — `docs: connect diagnostics to remaining QA gates`
- `8658eadd12f83a3cfa56e2a7741a27d938d8b764` — `docs: record diagnostics QA milestone in roadmap`
- `b782689e8d4c6ddade972d08dd74467674980229` — `fix: use canonical package name in diagnostics report tests`
- `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910` — `fix: use canonical package name in diagnostics localization tests`

### Validation-run ledger

- Run `31932084698` exposed the initial formatting drift in the diagnostics source.
- Run `31932234819` printed the hosted formatter's exact four-file canonical diff from the temporary formatter-diff revision.
- Run `31932376857` confirmed the restored formatting gate and Linux build, then exposed the two test-only package-name imports during analyzer validation.
- Run `31932491771` is the final clean diagnostics validation run: formatter, analyzer, 94 tests, Android debug, and Linux debug all succeeded on `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910`.

### Remaining release boundary

No physical-device, real-filesystem, accessibility, production-signing, notarization, store-console, package-visual, sustained-performance, or stable-release gate is marked complete merely because diagnostics now exists. `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md` remain the authority for those evidence requirements. Diagnostics improves reproducibility and support evidence; it does not substitute synthetic metadata for a test that must occur on real hardware or in a protected maintainer release environment.


### Documentation-ledger maintenance commits for this continuation

The authoritative Git history was re-read after the first ledger append. Five stale intermediate SHA references in the newly appended commit list were corrected to the actual commits shown by GitHub history. No production code, tests, privacy behavior, or validation result changed during this correction.

Documentation/helper commits created after the main diagnostics source validation were:

- `b21e0cfa0202a3689f69ad796585a88fc7fce38e` — staged the first temporary documentation workflow; it was syntactically invalid and executed no jobs or document changes.
- `00c73533b49cfde03d42dfb2d2e6018f8612528d` — added the temporary repository-side ledger updater.
- `073181fbe53c3660d5e9d6b3f82df27daa6f5e3e` — corrected the temporary workflow so the updater could run.
- `4fd9c41e6d6e102b17793c3afd37fe1ffb6739db` — `docs: add diagnostics QA release notes`.
- `af611101792dc3c208b2ce092e34f126f025afe9` — `docs: sync diagnostics project state`.
- `ef24bb09490c47c18cbdf580d4ffee4eac269358` — `docs: record diagnostics and QA continuation`.
- `f8f3769bccb76677a15f4b8dba4018a83b222881` — removed the temporary one-shot documentation workflow.
- `fdb82d78310ec2c61a2d50b18d84dd2e1d28a7f5` — removed the temporary documentation updater.

The cleaned repository must not retain either temporary helper after ledger correction. The permanent Repository Integrity Audit remains the authority for enforcing that cleanup.
