# SonicNest Project State

```yaml
project: SonicNest
repository: https://github.com/sanskarIN/SonicNest
current_phase: Cross-platform release hardening
current_version: 0.1.0
stack:
  ui: Flutter / Dart
  recorder: record 7.1.1
  player: just_audio 0.10.6 + just_audio_background 0.0.1-beta.17 + just_audio_media_kit 2.1.0
  processing: ffmpeg_kit_flutter_new_audio 2.5.x
  persistence: local JSON metadata + shared_preferences
  import_export: file_picker 10.3.10 + share_plus 12.0.2
supported_platform_targets:
  - Android
  - iOS
  - macOS
  - Windows
  - Linux
completed_features:
  - project architecture and Material 3 design system
  - local-first recording metadata and cross-platform-safe filename allocation
  - start pause resume stop cancel recording lifecycle
  - recorder transition guards and failed-capture cleanup
  - runtime encoder support checks with intermediate capture fallback
  - M4A WAV FLAC Opus native paths when supported
  - MP3 OGG AAC and unsupported-native-format conversion pipeline
  - quality presets and custom settings
  - live waveform amplitude sampling and clipping indication
  - persisted waveform envelopes for recorded imported and processed audio
  - bookmarks during recording and bookmark playback seeking
  - searchable sortable filterable recording library
  - favorites pins tags folders trash restore permanent delete
  - rename duplicate import export share
  - multi-selection bulk favorite pin share trash restore delete actions
  - playback seek speed volume repeat and optional skip-silence
  - Android iOS and macOS media-session metadata and lock-screen/notification playback integration through just_audio_background
  - non-destructive trim split merge normalize fade silence removal
  - draggable editor selection handles with undo redo reset
  - format export presets
  - light dark system themes and responsive navigation
  - desktop Ctrl+1 through Ctrl+5 navigation shortcuts
  - About privacy support GitHub email and Buy Me a Coffee links
  - original vector branding assets
  - Android foreground recording service overrides
  - Bash and PowerShell reproducible platform bootstrap tooling
  - unit tests open-source docs and GitHub project templates
  - analyzer unit-test Android Linux Windows macOS and unsigned iOS build workflows
partial_features:
  - Windows and Linux do not yet expose a dedicated SonicNest system-wide media-session integration beyond the selected desktop playback backend
  - richer native desktop context menus can be added after usability testing
  - true multi-file batch conversion/export remains a roadmap item
pending_manual_validation:
  - microphone permission accepted denied and permanently denied behavior on devices
  - Android and Apple background lock-screen media-session and interruption behavior on physical devices
  - wired USB Bluetooth and built-in microphone routing where available
  - low-storage failure and recovery
  - malformed audio imports across supported operating systems
  - 30-minute and multi-hour recording soak tests
  - screen-reader audits with TalkBack VoiceOver Narrator and desktop tooling
  - large-library performance with thousands of recordings
  - store packaging signing certificates provisioning and release credentials
latest_automated_validation:
  code_commit_under_validation: 59fe40b761ad52920d8640a4edb23b680db234c8
  core_flutter_ci:
    run_id: 31769582811
    analyzer: success
    unit_tests: success
    android_debug_apk: in_progress_at_document_update
    linux_debug_build: in_progress_at_document_update
  windows_ci:
    run_id: 31769582816
    windows_debug_build: in_progress_at_document_update
  apple_ci:
    run_id: 31769582823
    macos_debug_build: in_progress_at_document_update
    ios_debug_no_codesign: in_progress_at_document_update
  previous_fully_green_baseline:
    core_flutter_ci_run_id: 31766868164
    windows_ci_run_id: 31767240173
    apple_ci_run_id: 31767248520
known_limitations:
  - codec availability and effective sample bitrate channel settings depend on OS device and runtime support
  - sharing and silence-skip capabilities differ by platform backend
  - generated platform hosts require the Flutter SDK and the repository bootstrap tooling
  - automated compilation cannot substitute for microphone hardware interruption background lock-screen and long-duration QA
  - signed distributable packages require maintainer-owned signing material that must not be committed
branch: main
commit_identity:
  name: Sanskar
  email: sanskarin@outlook.in
next_exact_tasks:
  - keep all latest CI workflows green after documentation synchronization
  - execute docs/QA_CHECKLIST.md on representative Android iOS macOS Windows and Linux hardware
  - verify Android iOS and macOS media-session and lock-screen behavior on physical devices
  - evaluate dedicated Windows and Linux system media-session integration where platform APIs and maintained Flutter plugins permit it
  - add richer desktop context-menu affordances after usability testing
  - evaluate true multi-file batch conversion/export after large-library testing
  - profile multi-hour recordings and large libraries
  - resolve any reproducible device-only issues discovered by manual QA
  - prepare signing and store metadata only after manual release gates are satisfied
```
