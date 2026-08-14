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

Dedicated OS media-session / lock-screen transport controls are intentionally still listed as future platform work rather than being falsely marked complete.

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

The application uses `FilePicker.platform.pickFiles(...)` and `FilePicker.platform.saveFile(...)` for that compatible release. This resolved the Android plugin registration/API combination that failed with the earlier dependency selection.

`share_plus` remains on the dependency line compatible with the selected file picker / Windows dependency graph.

## CI and automated validation

### Core Flutter CI

Validated run:

- Run ID: `31766868164`
- Source commit: `f2560ef02a1f046197188bd1e5112d43176a2b46`

Results:

- Platform host generation: SUCCESS
- `flutter pub get`: SUCCESS
- Dart formatting step: SUCCESS
- Flutter static analysis: SUCCESS
- Unit tests: SUCCESS
- Android debug APK build: SUCCESS
- Linux debug desktop build: SUCCESS

### Windows CI

Workflow: `.github/workflows/windows.yml`

Validated run:

- Run ID: `31767240173`
- Workflow commit: `92801465e9647a652f006709ea851a0b0dfe0fea`

Results:

- PowerShell platform bootstrap: SUCCESS
- Dependency resolution: SUCCESS
- Windows debug desktop build: SUCCESS

### Apple CI

Workflow: `.github/workflows/macos.yml`

Validated run:

- Run ID: `31767248520`
- Workflow commit: `e6ca3d1fa8cd3828644a8c865ab1601a0789262e`

Results:

- macOS platform bootstrap: SUCCESS
- macOS dependency resolution: SUCCESS
- macOS debug build: SUCCESS
- iOS platform bootstrap: SUCCESS
- iOS dependency resolution: SUCCESS
- iOS debug no-codesign build: SUCCESS

These results validate compilation and automated tests on GitHub-hosted runners. They do not substitute for microphone hardware testing, interruption/background testing, long-duration recording tests, low-storage behavior, audio routing, accessibility testing with real assistive technologies, or signed store/release packaging.

## Tests present

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

## Important commits from this continuation/hardening pass

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
- documentation synchronization commits for building, README, roadmap, changelog, project state, and this file

Earlier foundation commits are preserved in the repository history and remain part of the same project.

## Hardware/manual release gates that remain

The following cannot be truthfully completed by repository-only automation and must remain unchecked until tested on real target hardware/accounts:

- First-launch microphone permission acceptance/denial/permanent denial UX.
- Actual microphone capture quality on Android, iOS, macOS, Windows, and Linux.
- Wired/USB/Bluetooth/built-in microphone switching.
- Calls/alarms/audio-focus interruptions.
- Screen-lock/background recording behavior.
- Android foreground-service behavior across OEM/device variants.
- iOS background recording behavior under current OS policies.
- Low-storage and filesystem failure recovery.
- 30-minute and multi-hour recording soak tests.
- Very large recording-library performance.
- TalkBack, VoiceOver, Narrator, and other assistive-technology audits.
- Store signing, keystore/certificate/provisioning, notarization, and release credentials.

Do not mark those items complete without real evidence.

## Exact continuation point

Automated source analysis/tests and debug compilation are green for Android, Linux, Windows, macOS, and unsigned iOS using the workflows/runs recorded above. The repository is now in cross-platform release-hardening state rather than initial implementation state.

For the next continuation, start with `PROJECT_STATE.md`, this `what_changed.md`, `ROADMAP.md`, and the newest GitHub Actions runs. Prioritize physical-device QA findings and media-session/lock-screen integration rather than reimplementing completed recorder/library/editor functionality.
