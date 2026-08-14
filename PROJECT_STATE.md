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
linux_distribution:
  initial_package_format: Debian .deb
  install_prefix: /opt/sonicnest
  desktop_entry: packaging/linux/debian/sonicnest.desktop
  appstream_metadata: packaging/linux/debian/io.github.sanskarIN.SonicNest.metainfo.xml
  icon_target: /usr/share/icons/hicolor/512x512/apps/sonicnest.png
  build_script: tool/build_linux_deb.sh
  verify_script: tool/verify_linux_deb.sh
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
  - optional external-folder copies for successful batch conversions with collision-safe naming
  - direct multi-file original export to a user-selected directory with per-file failure isolation
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
  - English localization-ready delegate with primary Flutter presentation surfaces migrated to the localization catalog
  - About privacy support GitHub email and Buy Me a Coffee links
  - original vector branding assets
  - deterministic native branding source raster generation
  - Android iOS native splash generation and Android iOS macOS Windows launcher icon generation
  - Android foreground recording service overrides
  - Bash and PowerShell reproducible platform bootstrap tooling
  - Debian Linux package builder verifier desktop entry AppStream metadata generated icon integration and package checksums
  - dedicated Linux Debian package CI and Debian release-candidate artifact integration
  - unit tests open-source docs GitHub project templates and release documentation
  - analyzer unit-test Android Linux Windows macOS and unsigned iOS build workflows
  - core CI path filtering that avoids documentation-only rebuild churn
  - detailed QA checklist release procedure development-preview release notes and remaining-work tracker
partial_features:
  - English is the only shipped locale; backend diagnostic and error text localization policy must be decided before additional locales are released
  - Windows and Linux do not yet expose a dedicated SonicNest system-wide media-session integration beyond the selected desktop playback backend
  - desktop secondary-click opens the complete action surface but a cursor-anchored platform-native context menu can still be evaluated after usability testing
  - advanced filter and audio-processing defaults require listening tests before claiming mastering-grade behavior
  - Debian package structure is automated but real installation upgrade uninstall microphone routing icon rendering accessibility and signing/distribution policy remain manual release gates
pending_manual_validation:
  - microphone permission accepted denied revoked and permanently denied behavior on devices
  - Android and Apple background lock-screen media-session and interruption behavior on physical devices
  - keep-screen-awake behavior on physical devices
  - countdown and rapid lifecycle interactions on physical devices
  - wired USB Bluetooth and built-in microphone routing where available
  - headphone Bluetooth reconnect and media-button behavior
  - low-storage failure and recovery
  - malformed audio imports across supported operating systems
  - batch conversion and direct export quality large-batch destination-loss and low-storage behavior on representative real recordings
  - desktop secondary-click ergonomics on Windows macOS and Linux
  - advanced editor output quality on representative voice and music recordings
  - 30-minute and multi-hour recording soak tests
  - screen-reader audits with TalkBack VoiceOver Narrator and desktop tooling
  - large-library performance with thousands of recordings
  - Debian package install launch upgrade uninstall and desktop icon visual behavior on representative Debian Ubuntu family systems
  - real screenshots final native icon launch asset review and store metadata
  - store packaging signing certificates provisioning notarization and release credentials
latest_automated_validation:
  application_source_commit: 40c4a758debef136c2d8c977c321446cca2697cd
  core_flutter_ci:
    run_id: 31776174696
    brand_generation: success
    analyzer: success
    unit_tests: success
    android_debug_apk: success
    linux_debug_build: success
  windows_ci:
    run_id: 31776174725
    brand_generation: success
    windows_debug_build: success
  apple_ci:
    run_id: 31776174715
    brand_generation: success
    macos_debug_build: success
    ios_debug_no_codesign: success
  linux_package_ci:
    validated_source_commit: dd31bf7800becd09424309cc99e42d324f4f8f8e
    run_id: 31783018282
    linux_release_build: success
    debian_package_build: success
    desktop_entry_validation: success
    appstream_validation: success
    package_payload_verification: success
    checksum_verification: success
    artifact_upload: success
  validation_relationship:
    - core Windows and Apple workflows validate deterministic native branding source revision 40c4a758debef136c2d8c977c321446cca2697cd
    - Linux package workflow validates package implementation through revision dd31bf7800becd09424309cc99e42d324f4f8f8e including checksum-verifier fix c0381eb59c34b0dc965784d74730615eb95bfcbb
    - documentation-only synchronization commits after validated source revisions do not trigger all application build workflows by design
known_limitations:
  - codec availability and effective sample bitrate channel and DSP settings depend on OS device and runtime support
  - sharing silence-skip media-session input-device and screen-wake capabilities differ by platform backend
  - A-B loop is application-managed and requires real-device timing validation
  - generated platform hosts require the Flutter SDK and repository bootstrap tooling
  - batch conversion and direct export are sequential and non-destructive; very large batches require performance validation
  - automated Linux package verification proves package structure rather than real-system audio routing installation UX or desktop icon quality
  - automated compilation cannot substitute for microphone hardware interruption background lock-screen routing media-button accessibility storage-failure and long-duration QA
  - signed distributable packages require maintainer-owned signing material that must not be committed
branch: main
commit_identity:
  name: Sanskar
  email: sanskarin@outlook.in
next_exact_tasks:
  - execute docs/QA_CHECKLIST.md on representative Android iOS macOS Windows and Linux hardware
  - verify countdown screen-wake microphone routing interruption and media-session behavior on physical devices
  - install the Debian package on representative Debian Ubuntu family systems and verify launch icon microphone routing upgrade and uninstall behavior
  - decide the public Linux distribution channel and any Debian repository/package signing policy
  - listen-test and tune advanced processing presets against representative recordings
  - test large batch conversion and direct-export sets plus desktop secondary-click ergonomics on physical desktop systems
  - decide backend diagnostic text localization policy before adding additional languages
  - evaluate dedicated Windows and Linux system media-session integration only where maintained platform support is suitable
  - evaluate cursor-anchored platform-native desktop context menus only if they materially improve usability over the implemented action surface
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
- OS-level visual inspection remains a manual/release-distribution gate.
- Release classification remains **development preview**.

## Latest exact validation — Linux Debian packaging

- Debian `.deb` is the initial repository-supported Linux installation format.
- Package workflow validated source revision: `dd31bf7800becd09424309cc99e42d324f4f8f8e`.
- Validation run: `31783018282`.
- Flutter Linux release build: **SUCCESS**.
- Debian package construction: **SUCCESS**.
- Desktop entry validation: **SUCCESS**.
- AppStream metadata validation: **SUCCESS**.
- Executable, icon, control metadata, package payload, and checksum verification: **SUCCESS**.
- Package artifact upload: **SUCCESS**.
- The successful source includes checksum-verifier fix `c0381eb59c34b0dc965784d74730615eb95bfcbb`.
- Real package installation/upgrade/uninstall behavior, microphone routing, accessibility, desktop icon visual inspection, public distribution policy, and signing remain manual release gates.
- Release classification remains **development preview**.
