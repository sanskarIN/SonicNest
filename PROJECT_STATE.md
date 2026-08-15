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
  installed_smoke_script: tool/smoke_test_installed_linux_deb.sh
  public_channel: GitHub Releases
  public_artifacts: verified Debian .deb + SHA-256 checksum
  apt_repository: not initially operated
  signing_credentials: maintainer-owned and outside repository
completed_features:
  - project architecture and Material 3 design system
  - branded Flutter startup screen with recoverable startup failure state
  - local-first recording metadata and cross-platform-safe filename allocation
  - tolerant metadata field decoding and malformed-record isolation
  - structural metadata corruption preservation with timestamped diagnostic copies
  - interrupted metadata replacement recovery from recordings.json.bak
  - corrupt-primary fallback to a valid metadata backup
  - invalid unrecoverable metadata reset to a clean valid store after preserving diagnostics
  - duplicate metadata ID and normalized file-path isolation
  - negative and non-finite numeric metadata normalization
  - finite bounded recovered waveform metadata normalization
  - managed-path startup reconciliation for metadata entries
  - deterministic 3000-entry metadata filesystem save/load regression coverage
  - managed storage mutation guards protecting external paths from rename duplicate Trash restore and permanent delete
  - persistence rollback for single and batch metadata edits settings changes generated-output registration rename Trash and restore
  - metadata-first permanent delete with restoration when managed file deletion fails
  - supported top-level managed recording-file discovery for recovery
  - orphaned managed audio metadata reconstruction at startup with best-effort media probing and waveform extraction
  - deterministic orphan recovery tests across every represented recording format including damaged-media best-effort behavior
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
  - persisted waveform envelopes for recorded imported processed and recovered audio
  - bookmarks during recording and bookmark playback seeking
  - searchable sortable filterable recording library
  - format folder exact-tag and date-range filters
  - favorites pins tags folders trash restore permanent delete
  - rename duplicate import export share
  - multi-file audio import with per-file copy probe waveform failure isolation and managed-copy cleanup
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
  - hosted-runner Debian package install installed-payload GUI startup smoke and uninstall cleanup validation
  - dedicated Linux Debian package CI and Debian release-candidate artifact integration
  - repository workflow allowlist rejecting leftover temporary one-shot workflows and permanent contents-write permissions
  - unit tests open-source docs GitHub project templates and release documentation
  - analyzer unit-test Android Linux Windows macOS and unsigned iOS build workflows
  - core CI path filtering that avoids documentation-only rebuild churn
  - detailed QA checklist release procedure development-preview release notes and remaining-work tracker
  - supported-extension regular-file managed audio boundary with symbolic-link and non-file refusal
  - entity-safe collision allocation for managed and external destinations including broken symbolic links
  - active and Trash orphan reconstruction with startup unsafe-metadata removal
  - managed-audio-only recording and Trash statistics plus sequence counting
  - deterministic BatchConversionService used by the production Batch Convert screen
  - stop-after-current behavior shared by the Batch Convert stop control and screen disposal
  - lazy native AudioRecorder construction without constructor-time method-channel side effects
  - localization policy separating translated product summaries from raw technical diagnostic evidence
  - GitHub Releases selected as the initial public Linux Debian package channel
  - source-controlled store listing and privacy declaration draft for Android Apple macOS Windows and Linux distribution review
  - Windows stable public signing policy requires Authenticode while actual signing credentials/service and final installer integration remain maintainer-owned
partial_features:
  - English is the only shipped locale; diagnostic-text policy is decided, while additional locales still require translation review, text-expansion testing, and accessibility QA
  - Windows and Linux do not yet expose a dedicated SonicNest system-wide media-session integration beyond the selected desktop playback backend
  - desktop secondary-click opens the complete action surface but a cursor-anchored platform-native context menu can still be evaluated after usability testing
  - advanced filter and audio-processing defaults require listening tests before claiming mastering-grade behavior
  - deterministic corrupt-import and orphan-recovery failure isolation is covered but representative malformed and partially written real-media corpus testing remains manual
  - deterministic 3000-entry metadata persistence is covered but real large-library UI memory and performance profiling remains manual
  - managed-path and rollback behavior is deterministically covered but real permission revocation low-storage abrupt-process and power-loss filesystem behavior remains manual
  - Debian package structure and hosted-runner install/startup/uninstall smoke are automated and the initial GitHub Releases channel is selected, while representative-system microphone routing desktop rendering accessibility upgrade and any optional public artifact-signing credentials remain manual release gates
pending_manual_validation:
  - microphone permission accepted denied revoked and permanently denied behavior on devices
  - Android and Apple background lock-screen media-session and interruption behavior on physical devices
  - keep-screen-awake behavior on physical devices
  - countdown and rapid lifecycle interactions on physical devices
  - wired USB Bluetooth and built-in microphone routing where available
  - headphone Bluetooth reconnect and media-button behavior
  - low-storage failure and recovery
  - disk and file permission failure recovery on target systems
  - abrupt process device and power interruption during metadata and managed-audio mutations followed by recovery verification
  - recovered-orphan behavior with real playable partially written and damaged audio on each maintained platform
  - malformed audio imports across supported operating systems using representative corpus files
  - batch conversion and direct export quality large-batch destination-loss and low-storage behavior on representative real recordings
  - desktop secondary-click ergonomics on Windows macOS and Linux
  - advanced editor output quality on representative voice and music recordings
  - 30-minute and multi-hour recording soak tests
  - screen-reader audits with TalkBack VoiceOver Narrator and desktop tooling
  - large-library UI memory and performance with thousands of recordings
  - Debian package install launch upgrade uninstall microphone routing and desktop icon visual behavior on representative Debian Ubuntu family systems
  - real screenshots final native icon launch asset review and store metadata
  - store packaging signing certificates provisioning notarization and release credentials
latest_automated_validation:
  formatter_clean_source_commit: 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c
  canonical_format_commit: 22c1d46e077625d6e1964d56716700727d1800dc
  non_mutating_format_gate_commit: 704b0f60aae8f179f4f41875c336d2052b45391e
  core_flutter_ci:
    run_id: 31870933447
    source_commit: 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c
    dart_format_check: success_non_mutating
    analyzer: success
    unit_tests: success_complete_suite
    android_debug_apk: success
    linux_debug_build: success
  windows_ci:
    run_id: 31870933908
    source_commit: 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c
    windows_debug_build: success
  apple_ci:
    run_id: 31870933903
    source_commit: 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c
    macos_debug_build: success
    ios_debug_no_codesign: success
  linux_package_ci:
    run_id: 31870933982
    source_commit: 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c
    result: success
    release_bundle: success
    deb_build_and_verify: success
    package_install: success
    installed_app_smoke: success
    package_uninstall: success
    artifact_publication: success
  validation_relationship:
    - formatter-clean revision 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c contains the final validated application/source state for this continuation
    - later commits are documentation policy state and do not alter application runtime code
    - stable release still requires the unchecked real-system and maintainer-credential gates
known_limitations:
  - codec availability and effective sample bitrate channel and DSP settings depend on OS device and runtime support
  - sharing silence-skip media-session input-device and screen-wake capabilities differ by platform backend
  - A-B loop is application-managed and requires real-device timing validation
  - generated platform hosts require the Flutter SDK and repository bootstrap tooling
  - batch conversion and direct export are sequential and non-destructive; very large batches require performance validation
  - deterministic import and orphan-recovery failures use controlled test doubles and do not substitute for malformed or partially written real-media corpora on each platform
  - deterministic 3000-entry metadata roundtrip proves persistence integrity rather than real UI latency memory pressure or filesystem performance
  - metadata and managed-storage rollback/recovery tests do not substitute for low-storage abrupt-power process-kill permission-revocation and filesystem-failure evidence on real systems
  - metadata backup/orphan recovery cannot recreate audio bytes deleted or irreversibly damaged outside SonicNest
  - hosted-runner Linux package smoke proves install installed-payload startup-window and uninstall behavior only on the CI runner and does not prove representative real-system audio routing desktop integration accessibility upgrade or long-duration quality
  - automated compilation cannot substitute for microphone hardware interruption background lock-screen routing media-button accessibility storage-failure and long-duration QA
  - signed distributable packages require maintainer-owned signing material that must not be committed
branch: main
commit_identity:
  name: Sanskar
  email: sanskarin@outlook.in
next_exact_tasks:
  - commit the CI-toolchain Dart formatter output and then make formatting a non-mutating enforcement gate
  - execute docs/QA_CHECKLIST.md on representative Android iOS macOS Windows and Linux hardware
  - verify countdown screen-wake microphone routing interruption and media-session behavior on physical devices
  - run abrupt process interruption permission failure and low-storage recovery scenarios against the managed metadata and orphan-recovery paths on representative systems
  - run real playable partially written and damaged managed-audio orphan recovery scenarios on each maintained platform
  - run a privacy-safe malformed audio corpus through import on each maintained platform and record per-file results
  - profile thousands of Library entries in the real UI for latency memory and scrolling behavior rather than relying only on metadata serialization tests
  - install the Debian package on representative Debian Ubuntu family systems and verify launcher icon microphone routing upgrade and uninstall behavior with release evidence
  - listen-test and tune advanced processing presets against representative recordings
  - test large batch conversion and direct-export sets plus desktop secondary-click ergonomics on physical desktop systems
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
- Package workflow validated source revision: `a07468b4b7c14a76b9bce537bbe0455e4539e6bf`.
- Validation run: `31785105648`.
- Flutter Linux release build: **SUCCESS**.
- Debian package construction: **SUCCESS**.
- Desktop entry validation: **SUCCESS**.
- AppStream metadata validation: **SUCCESS**.
- Executable, icon, control metadata, package payload, and checksum verification: **SUCCESS**.
- Package-manager installation: **SUCCESS**.
- Installed package payload and metadata verification: **SUCCESS**.
- Virtual-display packaged-app startup smoke: **SUCCESS**.
- Package-manager removal: **SUCCESS**.
- Package-owned application/desktop/icon/AppStream cleanup after uninstall: **SUCCESS**.
- Package artifact upload: **SUCCESS**.
- The validated source includes installed-package smoke script commit `45c94018c9c9c8074421e419125e38fe2b29c4d3` and CI install/smoke/uninstall commit `a07468b4b7c14a76b9bce537bbe0455e4539e6bf`.
- Repository audit run `31785152042` on revision `e0b9658a4cb18a61ac42046a6914ca080df7eb51` also passed after making installed-smoke invariants mandatory.
- Earlier structural-only package run `31783749267` remains historical evidence; the newer run supersedes it for automated Linux package validation.
- Representative real-system package installation/upgrade/uninstall behavior, microphone routing, accessibility, desktop icon visual inspection, public distribution policy, and signing remain manual release gates.
- Release classification remains **development preview**.

## Latest exact validation — metadata integrity and resilient imports

- Core validation source revision: `a88aeadadda017b0aced4dbc25c8426a27364b77`.
- Core Flutter CI run: `31807193932` — formatting, analyzer, unit tests, Android debug APK, and Linux debug build **SUCCESS**.
- Cross-platform controller source revision: `3bf63e69186a7a538f7d0587f3d361e00c2e29e9`.
- Windows run `31807141053`: Windows debug build **SUCCESS**.
- Apple run `31807141166`: macOS debug and unsigned-iOS debug builds **SUCCESS**.
- Metadata tests cover invalid JSON, invalid document structure, malformed-record isolation, interrupted backup recovery, corrupt-primary fallback, and a 3,000-entry filesystem round-trip.
- Import tests cover valid managed import plus cleanup on source-copy, media-probe, and waveform-extraction failure.
- Multi-file import now continues after isolated malformed/missing audio failures and reports partial success; a metadata persistence failure remains fail-fast and cleans the just-created unregistered managed file.
- Repository Integrity Audit run `31807662729` on revision `c7b9c41a8afcf83ff03ae5a014c9968f2f09c5e4` passed after temporary/one-shot workflows were removed and the permanent workflow allowlist/read-only invariant was active.
- Real malformed-media corpus testing, real large-library UI/memory profiling, low-storage/permission/power-loss recovery, and physical-device release QA remain evidence-dependent manual gates.
- Release classification remains **development preview**.

## Latest exact validation — managed storage and orphan recovery hardening

- Application source revision: `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe`.
- Core Flutter CI run `31867130926`: formatting, static analysis, full unit-test suite, Android debug APK, and Linux debug build **SUCCESS**.
- Windows CI run `31867130920`: Windows debug build **SUCCESS**.
- Apple CI run `31867130998`: macOS debug build and unsigned-iOS debug build **SUCCESS**.
- Linux Package CI run `31867130938`: Linux release build, Debian construction/verification, package-manager installation, installed-package startup smoke, package removal/cleanup, and artifact upload **SUCCESS**.
- Repository Integrity Audit run `31867491653` on documentation revision `704220ecf254c91967648380f6efdb18a856e6a3`: **SUCCESS**.
- New deterministic coverage includes managed-path mutation guards, protected external files, corrupt numeric/waveform normalization, corrupt-store reset, duplicate ID/path isolation, filesystem move rollback behavior, supported-file discovery, and orphan recovery across every represented format.
- Real low-storage/permission/process-kill/power-loss scenarios, real damaged/partially written media recovery, large-library UI profiling, hardware audio routing, accessibility, signing, and public release approval remain evidence-dependent.
- Release classification remains **development preview**.


## Latest exact validation — storage, recovery, batch, and lazy-recorder hardening

- Final application-code revision: `72797fa477b9d88e2138b7ddf1d0f845cdd549ca`.
- Final source/test revision: `e47b290a7255f126cfcf1436444a90cc32d10823`; its additional change is a test-fixture correction, not application code.
- Core Flutter CI run `31870224720`: analyzer **SUCCESS**, complete **87/87** test suite **SUCCESS**, Android debug **SUCCESS**, Linux debug **SUCCESS**.
- Windows run `31870087266`: Windows debug build **SUCCESS** on the final application-code revision.
- Apple run `31870087249`: macOS debug and unsigned-iOS debug builds **SUCCESS** on the final application-code revision.
- Linux Package CI run `31870087317`: Debian package workflow **SUCCESS** on the final application-code revision.
- Initial Linux public channel decision: GitHub Releases with verified `.deb` plus SHA-256 checksum; no initial custom APT repository.
- Diagnostic localization decision: translate product-facing summaries; preserve raw OS/plugin/FFmpeg/filesystem backend detail as technical evidence.
- Formatter boundary: core CI currently mutates formatting for 30 of 54 Dart files before analysis/tests. The tracked tree is therefore **not yet claimed formatter-clean**; this is explicitly tracked in `TODO.md`.
- Release classification remains **development preview** until the remaining physical-device, real-filesystem, accessibility, representative-package, long-duration, signing, and stable-release gates are completed.


## Formatter-clean final automated validation — 2026-08-15

- Canonical formatting commit: `22c1d46e077625d6e1964d56716700727d1800dc`.
- Non-mutating core CI formatting enforcement: `704b0f60aae8f179f4f41875c336d2052b45391e`.
- Formatter-clean source revision: `4e0fbf16534a60e2d3209c5ec5f54d4982903f8c`.
- Core run `31870933447`: format enforcement **SUCCESS**, static analysis **SUCCESS**, full unit suite **SUCCESS**, Android debug **SUCCESS**, Linux debug **SUCCESS**.
- Windows run `31870933908`: **SUCCESS**.
- Apple run `31870933903`: macOS debug **SUCCESS**, unsigned-iOS debug **SUCCESS**.
- Linux Package CI run `31870933982`: release bundle, package build/verification, install, installed-app smoke, uninstall, artifact publication **SUCCESS**.
- Store/listing/privacy draft: `docs/STORE_LISTING.md`.
- Windows public signing policy: `docs/WINDOWS_SIGNING_POLICY.md`; actual maintainer signing credentials/service configuration remains open.
- Linux public channel remains GitHub Releases with verified `.deb` + SHA-256 checksum; no initial custom APT repository.
- Release classification remains **development preview** pending the unchecked real-device/filesystem/accessibility/performance/branding/signing/release evidence gates.
