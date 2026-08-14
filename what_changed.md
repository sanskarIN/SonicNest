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
