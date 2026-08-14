# SonicNest Project State

```yaml
project: SonicNest
repository: https://github.com/sanskarIN/SonicNest
current_phase: Cross-platform release hardening
current_version: 0.1.0
release_classification: development_preview_until_manual_release_gates_are_complete
stack:
  ui: Flutter / Dart
  recorder: record 7.1.1
  player: just_audio 0.10.6 + just_audio_background 0.0.1-beta.17 + just_audio_media_kit 2.1.0
  processing: ffmpeg_kit_flutter_new_audio 2.5.x
  persistence: local JSON metadata + shared_preferences
  import_export: file_picker 10.3.10 + share_plus 12.0.2
  screen_wake: wakelock_plus 1.4.0
  localization: in-project AppLocalizations scaffold; English currently supported
supported_platform_targets:
  - Android
  - iOS
  - macOS
  - Windows
  - Linux
completed_features:
  - project architecture and Material 3 design system
  - branded Flutter startup screen with recoverable startup failure state
  - local-first recording metadata and cross-platform-safe filename allocation
  - start countdown pause resume stop cancel recording lifecycle
  - cancellable 0 3 5 10 second recording countdown
  - recorder transition guards and failed-capture cleanup
  - runtime encoder support checks with intermediate capture fallback
  - M4A WAV FLAC Opus native paths when supported
  - MP3 OGG AAC and unsupported-native-format conversion pipeline
  - quality presets and custom settings
  - smart filename templates with prefix suffix category date time sequence and component date-time tokens
  - optional screen-wake behavior during active recording with stop cancel error cleanup
  - live waveform amplitude sampling and clipping indication
  - persisted waveform envelopes for recorded imported and processed audio
  - bookmarks during recording and bookmark playback seeking
  - searchable sortable filterable recording library
  - format folder exact-tag and date-range filters
  - favorites pins tags folders trash restore permanent delete
  - rename duplicate import export share
  - multi-selection bulk favorite pin share trash restore delete actions
  - managed storage statistics for recordings Trash and temporary files
  - guarded temporary-file cleanup
  - multi-recording batch format conversion with target-format selection progress and per-file failure isolation
  - batch conversion preserves source recordings and imports successful converted copies back into the managed library
  - desktop secondary/right-click access to existing recording action surfaces
  - playback seek speed volume repeat and optional skip-silence
  - previous and next non-Trash recording navigation
  - A-B playback selection loop
  - Android iOS and macOS media-session metadata and lock-screen/notification playback integration through just_audio_background
  - non-destructive keep-selection trim cut-selection split merge normalize fade silence removal
  - non-destructive silence insertion and gain-adjusted output copies
  - basic FFT noise cleanup compressor limiter high-pass and low-pass processing
  - bookmark position adjustment for cut-selection and silence-insertion output copies
  - draggable editor selection handles with undo redo reset
  - format export presets
  - light dark system themes and responsive navigation
  - reduced-motion preference and semantics/tooltips in key interactive surfaces
  - desktop Ctrl+1 through Ctrl+5 navigation shortcuts
  - desktop F9 F10 Ctrl+Alt+P and Ctrl+Alt+Arrow recorder/player shortcuts
  - English localization-ready delegate and primary navigation/startup string migration
  - About privacy support GitHub email and Buy Me a Coffee links
  - original vector branding assets
  - Android foreground recording service overrides
  - Bash and PowerShell reproducible platform bootstrap tooling
  - unit tests open-source docs GitHub project templates and release documentation
  - analyzer unit-test Android Linux Windows macOS and unsigned iOS build workflows
  - core CI path filtering that avoids documentation-only rebuild churn
  - detailed QA checklist release procedure development-preview release notes and remaining-work tracker
partial_features:
  - additional languages are not shipped yet; remaining hard-coded presentation strings must be migrated before translation expansion
  - Windows and Linux do not yet expose a dedicated SonicNest system-wide media-session integration beyond the selected desktop playback backend
  - desktop secondary-click opens the complete action surface but a cursor-anchored platform-native context menu can still be evaluated after usability testing
  - batch format conversion is implemented; direct multi-file export into a user-selected external destination remains a separate possible enhancement
  - advanced filter defaults require listening tests before claiming mastering-grade behavior
pending_manual_validation:
  - microphone permission accepted denied revoked and permanently denied behavior on devices
  - Android and Apple background lock-screen media-session and interruption behavior on physical devices
  - keep-screen-awake behavior on physical devices
  - countdown and rapid lifecycle interactions on physical devices
  - wired USB Bluetooth and built-in microphone routing where available
  - headphone Bluetooth reconnect and media-button behavior
  - low-storage failure and recovery
  - malformed audio imports across supported operating systems
  - batch conversion quality and large-batch behavior on representative real recordings
  - desktop secondary-click ergonomics on Windows macOS and Linux
  - advanced editor output quality on representative voice and music recordings
  - 30-minute and multi-hour recording soak tests
  - screen-reader audits with TalkBack VoiceOver Narrator and desktop tooling
  - large-library performance with thousands of recordings
  - real screenshots final native icon/launch asset review and store metadata
  - store packaging signing certificates provisioning notarization and release credentials
latest_automated_validation:
  validated_source_commit: 985f2dd1500a03b0b65ee58b142cf31f545b0cc5
  core_flutter_ci:
    run_id: 31772136038
    platform_bootstrap: success
    dependency_resolution: success
    formatter: success
    analyzer: success
    unit_tests: success
    android_debug_apk: success
    linux_debug_build: success
  windows_ci:
    run_id: 31772135970
    windows_debug_build: success
  apple_ci:
    run_id: 31772136081
    macos_debug_build: success
    ios_debug_no_codesign: success
  validation_relationship:
    - all listed core Windows and Apple workflows validate the same source revision 985f2dd1500a03b0b65ee58b142cf31f545b0cc5
    - documentation-only synchronization commits after the validated source do not trigger core CI by design
known_limitations:
  - codec availability and effective sample bitrate channel and DSP settings depend on OS device and runtime support
  - sharing silence-skip media-session input-device and screen-wake capabilities differ by platform backend
  - A-B loop is application-managed and requires real-device timing validation
  - generated platform hosts require the Flutter SDK and repository bootstrap tooling
  - batch conversion is sequential and non-destructive; very large batches require performance validation
  - automated compilation cannot substitute for microphone hardware interruption background lock-screen routing media-button accessibility storage-failure and long-duration QA
  - signed distributable packages require maintainer-owned signing material that must not be committed
branch: main
commit_identity:
  name: Sanskar
  email: sanskarin@outlook.in
next_exact_tasks:
  - execute docs/QA_CHECKLIST.md on representative Android iOS macOS Windows and Linux hardware
  - verify countdown screen-wake microphone routing interruption and media-session behavior on physical devices
  - listen-test and tune advanced processing presets against representative recordings
  - test large batch conversion sets and desktop secondary-click ergonomics on physical desktop systems
  - finish presentation-string localization migration before adding additional languages
  - evaluate dedicated Windows and Linux system media-session integration only where maintained platform support is suitable
  - evaluate cursor-anchored platform-native desktop context menus only if they materially improve usability over the implemented action surface
  - evaluate direct multi-file export to a user-selected external destination after real-world batch-conversion testing
  - profile multi-hour recordings and large libraries
  - resolve any reproducible device-only issues discovered by manual QA
  - capture real screenshots and review native icon launch assets from tested release candidates
  - prepare signing and store metadata only after manual release gates are satisfied
```


## Latest exact validation — external batch export

- Validated revision: `54b727db6dd887fb0b2df2d36cabb2cd78671d7a`
- Validation run: `31773250023`
- Analyzer/unit tests: **SUCCESS**
- Android/Linux/Windows/macOS/unsigned-iOS debug builds: **SUCCESS**
- Repository classification remains **development preview** because physical-device, accessibility, long-duration, low-storage, signing, packaging, and store-release gates remain evidence-dependent.


## Latest exact validation — localization and library hardening

- Validated revision: `3fa56d26fb6cb64ccddf2b71e7b8c677aa4aa69b`
- Validation run: `31774726146`
- Analyzer and unit tests: **SUCCESS**
- Android, Linux, Windows, macOS, and unsigned iOS debug builds: **SUCCESS**
- Primary Flutter presentation surfaces now use the localization catalog; English remains the only shipped locale.
- Advanced tag/date filters and desktop secondary-click recording actions are active in the current Library UI.
- Batch conversion external-copy and stop-after-current behavior is implemented and test-supported.
- Release classification remains **development preview** until evidence-dependent manual gates are complete.


## Latest exact validation — direct multi-file original export

- Validated revision: `7c4702afcb9859f3507ac151f23372f96acec50a`
- Validation run: `31775283791`
- Analyzer/unit tests and Android/Linux/Windows/macOS/unsigned-iOS debug builds: **SUCCESS**
- Direct selected-original export to a user-selected directory is implemented with collision-safe copies and per-file failure isolation.
- Real platform-picker, low-storage, permission-revocation, and large-batch evidence is still required before stable release.


## Latest exact validation — deterministic native branding

- Validated source revision: `40c4a758debef136c2d8c977c321446cca2697cd`
- Core run `31776174696`: brand source generation, analyzer, tests, Android branded APK, and Linux build **SUCCESS**.
- Windows run `31776174725`: native branding generation and Windows debug build **SUCCESS**.
- Apple run `31776174715`: native branding generation plus macOS and unsigned-iOS debug builds **SUCCESS**.
- Android/iOS native splash generation and Android/iOS/macOS/Windows launcher-icon generation are repository-automatable and implemented.
- Linux final package icon integration and all OS-level visual inspection remain manual/release-distribution gates.
- Release classification remains **development preview**.
