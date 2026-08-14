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
  - detailed QA checklist release procedure development-preview release notes and remaining-work tracker
partial_features:
  - additional languages are not shipped yet; remaining hard-coded presentation strings must be migrated before translation expansion
  - Windows and Linux do not yet expose a dedicated SonicNest system-wide media-session integration beyond the selected desktop playback backend
  - richer native desktop context menus remain conditional on usability evidence
  - true multi-file batch conversion/export remains a roadmap item
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
  - advanced editor output quality on representative voice and music recordings
  - 30-minute and multi-hour recording soak tests
  - screen-reader audits with TalkBack VoiceOver Narrator and desktop tooling
  - large-library performance with thousands of recordings
  - real screenshots final native icon/launch asset review and store metadata
  - store packaging signing certificates provisioning notarization and release credentials
latest_automated_validation:
  source_and_docs_head_at_state_update: b17ca5b6f004da4ad71f63c62cafe253e5562203
  newest_core_flutter_ci_at_state_update:
    run_id: 31771331644
    state: pending_at_document_update
  previous_fully_green_baseline:
    core_flutter_ci_run_id: 31769746659
    core_flutter_ci_commit: 09269684f9a9936d39caf9340fd70eb25ae4ebb4
    analyzer: success
    unit_tests: success
    android_debug_apk: success
    linux_debug_build: success
    windows_ci_run_id: 31769582816
    windows_ci_commit: 59fe40b761ad52920d8640a4edb23b680db234c8
    windows_debug_build: success
    apple_ci_run_id: 31769582823
    apple_ci_commit: 59fe40b761ad52920d8640a4edb23b680db234c8
    macos_debug_build: success
    ios_debug_no_codesign: success
known_limitations:
  - codec availability and effective sample bitrate channel and DSP settings depend on OS device and runtime support
  - sharing silence-skip media-session input-device and screen-wake capabilities differ by platform backend
  - A-B loop is application-managed and requires real-device timing validation
  - generated platform hosts require the Flutter SDK and repository bootstrap tooling
  - automated compilation cannot substitute for microphone hardware interruption background lock-screen routing media-button accessibility storage-failure and long-duration QA
  - signed distributable packages require maintainer-owned signing material that must not be committed
branch: main
commit_identity:
  name: Sanskar
  email: sanskarin@outlook.in
next_exact_tasks:
  - keep all latest CI workflows green after final documentation synchronization
  - execute docs/QA_CHECKLIST.md on representative Android iOS macOS Windows and Linux hardware
  - verify countdown screen-wake microphone routing interruption and media-session behavior on physical devices
  - listen-test and tune advanced processing presets against representative recordings
  - finish presentation-string localization migration before adding additional languages
  - evaluate dedicated Windows and Linux system media-session integration only where maintained platform support is suitable
  - evaluate richer desktop context menus after usability testing
  - evaluate true multi-file batch conversion/export after large-library testing
  - profile multi-hour recordings and large libraries
  - resolve any reproducible device-only issues discovered by manual QA
  - capture real screenshots and review native icon launch assets from tested release candidates
  - prepare signing and store metadata only after manual release gates are satisfied
```
