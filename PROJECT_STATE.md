# SonicNest Project State

```yaml
project: SonicNest
repository: https://github.com/sanskarIN/SonicNest
current_phase: Cross-platform release hardening
current_version: 0.1.0
stack:
  ui: Flutter / Dart
  recorder: record 7.1.1
  player: just_audio 0.10.6 + just_audio_media_kit 2.1.0
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
  - media-session and lock-screen playback controls need dedicated per-platform integration
  - richer native desktop context menus can be added after usability testing
  - true multi-file batch conversion/export remains a roadmap item
pending_manual_validation:
  - microphone permission accepted denied and permanently denied behavior on devices
  - Android and Apple background lock-screen and interruption behavior
  - wired USB Bluetooth and built-in microphone routing where available
  - low-storage failure and recovery
  - malformed audio imports across supported operating systems
  - 30-minute and multi-hour recording soak tests
  - screen-reader audits with TalkBack VoiceOver Narrator and desktop tooling
  - large-library performance with thousands of recordings
  - store packaging signing certificates provisioning and release credentials
latest_automated_validation:
  core_flutter_ci:
    run_id: 31766868164
    source_commit: f2560ef02a1f046197188bd1e5112d43176a2b46
    analyzer: success
    unit_tests: success
    android_debug_apk: success
    linux_debug_build: success
  windows_ci:
    run_id: 31767240173
    workflow_commit: 92801465e9647a652f006709ea851a0b0dfe0fea
    windows_debug_build: success
  apple_ci:
    run_id: 31767248520
    workflow_commit: e6ca3d1fa8cd3828644a8c865ab1601a0789262e
    macos_debug_build: success
    ios_debug_no_codesign: success
known_limitations:
  - codec availability and effective sample bitrate channel settings depend on OS device and runtime support
  - sharing and silence-skip capabilities differ by platform backend
  - generated platform hosts require the Flutter SDK and the repository bootstrap tooling
  - automated compilation cannot substitute for microphone hardware interruption background and long-duration QA
  - signed distributable packages require maintainer-owned signing material that must not be committed
branch: main
commit_identity:
  name: Sanskar
  email: sanskarin@outlook.in
next_exact_tasks:
  - execute docs/QA_CHECKLIST.md on representative Android iOS macOS Windows and Linux hardware
  - add dedicated media-session and lock-screen controls where platform APIs permit them
  - profile multi-hour recordings and large libraries
  - resolve any reproducible device-only issues discovered by manual QA
  - prepare signing and store metadata only after manual release gates are satisfied
```
