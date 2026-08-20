# SonicNest Project State

```yaml
project: SonicNest
repository: https://github.com/sanskarIN/SonicNest
public_links:
  gumroad_store: https://ramsandesh.gumroad.com
  buy_me_a_coffee: https://buymeacoffee.com/sanskarIN
  github_profile: https://www.github.com/sanskarIN
  gumroad_badge: assets/branding/gumroad_store_badge.svg
gumroad_integration_validation:
  source_revision: 2c5f8c137af393bc37a89dd1f9ddcf78218a7c81
  repository_integrity_run: 32030915095
  flutter_ci_run: 32030915177
  windows_build_run: 32030915108
  apple_builds_run: 32030915143
  linux_package_run: 32030915109
  result: success
  scope: formatter + static analysis + Flutter tests + Android/Linux/Windows/macOS/iOS builds + Windows portable smoke + Debian build/install/smoke/uninstall + repository line/tooling audit
current_phase: Six-platform cross-platform release hardening
current_version: 0.1.0
release_classification: development_preview_until_manual_release_gates_are_complete
stack:
  ui: Flutter / Dart
  recorder: record 7.1.1
  player: just_audio 0.10.6 + just_audio_background 0.0.1-beta.17 + just_audio_media_kit 2.1.0
  processing: ffmpeg_kit_flutter_new_audio 2.5.x
  persistence: local JSON metadata + shared_preferences
  import_export: file_picker 12.0.0-beta.7 + share_plus 13.3.0
  screen_wake: wakelock_plus 1.7.0
  localization: in-project AppLocalizations scaffold; English currently supported
supported_platform_targets:
  - Android
  - iOS
  - macOS
  - Windows
  - Linux
  - Web
web_platform:
  shared_entry_point: lib/main.dart
  conditional_bootstrap: dart.library.js_interop -> lib/bootstrap/bootstrap_web.dart
  browser_entry_surface: lib/main_web.dart
  capture: PCM16 stream through record with pure-Dart WAV packaging
  session_storage: in-memory only until explicit share/download
  native_only_features_not_claimed: FFmpeg editing + durable managed-filesystem library/recovery + native media sessions
  build_command: flutter build web --release
  core_ci_build: required
  release_candidate_artifact: sonicnest-web-release.tar.gz + SHA-256
  unified_candidate_manifest: required as sixth platform
  documentation: docs/WEB_SUPPORT.md
  qa_checklist: docs/WEB_QA_CHECKLIST.md
  public_release_status: pending representative browser and production-hosting evidence
android_distribution:
  initial_public_channel: Google Play
  signing_model: Play App Signing with a separate maintainer-controlled upload key
  hosted_release_candidate: release-mode APK/AAB signed only by Android Debug certificate and explicitly NON-PRODUCTION
  policy: docs/ANDROID_DISTRIBUTION_POLICY.md
  signing_credentials: maintainer-owned and outside repository
apple_distribution:
  ios_public_channel: TestFlight then Apple App Store
  macos_initial_public_channel: signed and notarized GitHub Releases
  hosted_release_candidate: macOS unsigned archive plus iOS no-codesign archive
  policy: docs/APPLE_DISTRIBUTION_POLICY.md
  signing_credentials: maintainer-owned and outside repository
windows_distribution:
  initial_package_format: versioned x64 portable ZIP
  build_script: tool/build_windows_portable.ps1
  verify_script: tool/verify_windows_portable.ps1
  startup_smoke_script: tool/smoke_test_windows_portable.ps1
  public_channel: GitHub Releases
  stable_signing: Authenticode required for public stable binaries
  policy: docs/WINDOWS_PACKAGING.md + docs/WINDOWS_SIGNING_POLICY.md
  signing_credentials: maintainer-owned and outside repository
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
web_distribution:
  artifact_format: generated static Flutter Web bundle archived as .tar.gz for candidate evidence
  production_channel: HTTPS static hosting provider/domain not yet selected as a stable-release claim
  signing_model: binary signing not applicable to static Web bundle; checksum/provenance plus hosting controls apply
  hosting_dns_tls_credentials: deployment-environment owned and outside repository
  policy: docs/WEB_SUPPORT.md
  qa: docs/WEB_QA_CHECKLIST.md
completed_features:
  - canonical Gumroad storefront highlighted in the shared app shell About startup README support and maintained public documentation with regression protection
  - project architecture and Material 3 design system
  - shared default application entry point with conditional Dart IO and dart.library.js_interop bootstrap isolation
  - browser-safe Web recorder that excludes dart:io native FFmpeg path-provider and native media-session dependency paths
  - Web microphone permission input-device selection PCM16 stream capture pause resume stop cancel and amplitude metering
  - pure-Dart PCM16 RIFF/WAV packaging with mono stereo header and invalid-input regression coverage
  - in-memory browser session recording list with byte-stream WAV playback and explicit share/download fallback
  - Web light dark system theme support and responsive browser layout
  - branded Flutter startup screen with recoverable startup failure state on native application targets
  - local-first recording metadata and cross-platform-safe filename allocation on native managed-storage targets
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
  - MP3 OGG AAC and unsupported-native-format conversion pipeline on native targets
  - explicit Web codec boundary using PCM16 capture and WAV output without false FFmpeg/transcoding claims
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
  - About-accessible user-initiated Diagnostics & QA screen with deterministic JSON copy and Markdown sharing
  - privacy-safe diagnostics contract excluding recording content titles paths notes tags bookmarks smart-naming text and input-device names
  - aggregate diagnostics for runtime Library managed storage recorder state input count and non-content settings
  - diagnostics input enumeration skipped while recording is active to avoid a concurrent recorder-backend probe
  - regression coverage enforcing diagnostics serialization privacy unavailable-probe behavior and localization labels
  - About-accessible Manual QA evidence sessions with fixed source-controlled check IDs versioned local persistence deterministic JSON/Markdown export and optional privacy-safe diagnostics attachment
  - offline manual-QA JSON structural verifier that binds evidence to the current QA catalog and checks schema timestamps privacy flags summary consistency optional exact version diagnostics freshness and all-pass review policy
  - unit and CLI regression coverage for manual-QA evidence verification executed by the permanent Repository Integrity Audit
  - About privacy support GitHub email and Buy Me a Coffee links
  - original vector branding assets
  - deterministic cross-platform branding source raster generation
  - Android iOS Web splash generation and Android iOS macOS Windows Web launcher icon generation
  - Android foreground recording service overrides
  - Bash and PowerShell reproducible six-platform bootstrap tooling for Android iOS macOS Linux Windows and Web
  - Debian Linux package builder verifier desktop entry AppStream metadata generated icon integration and package checksums
  - hosted-runner Debian package install installed-payload GUI startup smoke and uninstall cleanup validation
  - dedicated Linux Debian package CI and Debian release-candidate artifact integration
  - versioned Windows x64 portable ZIP builder verifier checksum/package-info output and bounded extracted-package startup smoke
  - Android hosted release-candidate package identity and non-production Debug-certificate verification
  - current cross-platform release-candidate workflow producing Android Linux Windows macOS iOS and Web release-mode validation artifacts from one source revision
  - Web release-candidate static bundle packaging with explicit warning and SHA-256 evidence
  - exact historical automated release evidence record with inner artifact SHA-256 values and workflow artifact digests
  - unified machine-readable release-candidate provenance manifest contract that now requires and re-verifies all six platform payload checksum records and binds evidence to the full source SHA workflow run and attempt
  - hosted provenance manifest explicitly preserves per-platform signing classifications and stableReleaseApproved false
  - Python release-tool unit and workflow-integration regressions including Web tamper rejection executed by the permanent Repository Integrity Audit
  - repository workflow allowlist rejecting leftover temporary one-shot workflows and permanent write permissions including write-all
  - repository audit recognizes both .yml and .yaml workflow files
  - repository audit rejects committed generated web host scaffolding alongside native generated hosts
  - repository audit requires Web bootstrap entry point WAV encoder Web docs Web QA tests CI and release-candidate markers
  - unit tests open-source docs GitHub project templates and release documentation
  - analyzer unit-test Android Linux Windows macOS unsigned iOS and Web build workflows
  - core CI path filtering that avoids documentation-only rebuild churn
  - detailed native QA checklist dedicated Web QA checklist release procedure development-preview release notes and remaining-work tracker
  - supported-extension regular-file managed audio boundary with symbolic-link and non-file refusal
  - entity-safe collision allocation for managed and external destinations including broken symbolic links
  - active and Trash orphan reconstruction with startup unsafe-metadata removal
  - managed-audio-only recording and Trash statistics plus sequence counting
  - deterministic BatchConversionService used by the production Batch Convert screen
  - stop-after-current behavior shared by the Batch Convert stop control and screen disposal
  - lazy native AudioRecorder construction without constructor-time method-channel side effects
  - localization policy separating translated product summaries from raw technical diagnostic evidence
  - GitHub Releases selected as the initial public Linux Debian package channel
  - source-controlled store listing and privacy declaration draft for Android Apple macOS Windows and Linux distribution review plus dedicated Web support/privacy/release guidance
  - Android distribution policy selects Google Play and Play App Signing with a separate upload key
  - Apple distribution policy selects TestFlight/App Store for iOS and signed/notarized GitHub Releases for initial macOS public distribution
  - Windows stable public signing policy requires Authenticode while actual signing credentials/service remain maintainer-owned
  - deterministic dependency-state summary verification against pubspec.yaml
diagnostics_qa:
  implementation_source_commit: 00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910
  core_ci_run_id: 31932491771
  access: About -> Diagnostics & QA
  generation: user_initiated_only
  automatic_upload: false
  exports:
    - deterministic JSON clipboard copy
    - privacy-safe Markdown share file
  privacy_excludes:
    - recording content
    - recording titles
    - file paths
    - notes tags and bookmarks
    - smart-naming prefix template suffix and category text
    - input-device names
  evidence_includes:
    - canonical app version and build
    - platform OS locale Dart runtime and logical processor count
    - aggregate saved Trash favorite and pinned counts
    - aggregate managed storage bytes and file counts with probe status
    - recorder state input-probe status and input count
    - default-versus-custom selected input classification
    - non-content recording playback appearance and delete-confirmation settings
  active_recording_input_probe: skipped
  documentation: docs/DIAGNOSTICS_AND_QA.md
  release_gate_effect: supporting_evidence_only_no_manual_gate_closed
manual_qa_evidence:
  implementation_source_commit: 87c91697c9b11358e03334b3e642cbcb3959dc1c
  validated_core_source_commit: 0eb56abad482c8c296d9f80ef060ebddbba95e7b
  core_ci_run_id: 31934843541
  access:
    - About -> Manual QA evidence
    - Diagnostics & QA -> Open QA evidence with this snapshot
  storage_key: sonicnest.qaEvidenceSession.v1
  schema_version: 1
  statuses:
    - notRun
    - passed
    - failed
    - blocked
  serialized_status_writes: true
  immutable_current_catalog_ids: true
  stale_check_ids_dropped: true
  free_form_tester_notes: false
  automatic_upload: false
  diagnostic_snapshot_attachment: explicit_user_navigation_only
  exports:
    - deterministic JSON clipboard copy
    - privacy-safe Markdown share file
  release_gate_effect: supporting_evidence_only_no_manual_gate_closed
  documentation: docs/MANUAL_QA_EVIDENCE.md
manual_qa_review_tooling:
  verifier_source_commit: b40af1c6996da2809f25ed6300b6abbdb2f84220
  regression_source_commit: c65f01e62dcca9c250e6b304fcc137e9a78c8b84
  verifier: tool/verify_manual_qa_evidence.py
  documentation: docs/MANUAL_QA_REVIEW_TOOLING.md
  current_catalog_source: lib/models/qa_check_catalog.dart
  checks:
    - bundle and session schema versions
    - timezone-aware generation and session timestamp ordering
    - sensitive-data privacy flags remain false
    - exact current catalog membership with no missing unknown or duplicate IDs
    - status and assessed/notRun timestamp rules
    - recomputed summary consistency
    - optional exact application version
    - optional diagnostics runtime platform
    - optional evidence freshness
    - optional all-current-checks-passed policy
  release_gate_effect: structural_supporting_evidence_only_no_manual_gate_closed
  repository_integrity_run_id: 32016347023
  repository_integrity_result: success
platform_bootstrap_integrity:
  preserves_analysis_options_bash: true
  preserves_analysis_options_powershell: true
  committed_format_check_precedes_generated_host_bootstrap: true
  generated_targets: android,ios,macos,linux,windows,web
  conditional_default_entry_point: true
  web_generated_host_commit_rejected_by_repository_audit: true
  regression_test: test/bootstrap_integrity_test.dart
web_cross_platform_state:
  implementation_date: 2026-08-20
  default_entry_point: lib/main.dart
  browser_surface: lib/main_web.dart
  wav_encoder: lib/core/wav_encoder.dart
  core_ci_web_release_build: configured
  release_candidate_web_artifact: configured
  unified_six_platform_manifest: configured
  repository_contract_test: tool/tests/test_web_platform_contract.py
  hosted_validation_for_current_revision: pending
  real_browser_validation: pending
  production_hosting_validation: pending
release_evidence_boundary:
  diagnostics_feature_date: 2026-08-16
  historical_note: The 2026-08-15 release-candidate and unified provenance artifacts are five-platform historical evidence only; they predate Diagnostics & QA and the 2026-08-20 Web target.
  current_note: The current six-platform implementation has new runtime build workflow and provenance changes and therefore requires its own hosted validation; it does not inherit green status from the historical five-platform runs.
partial_features:
  - English is the only shipped locale; diagnostic-text policy is decided, while additional locales still require translation review, text-expansion testing, and accessibility QA
  - Windows and Linux do not yet expose a dedicated SonicNest system-wide media-session integration beyond the selected desktop playback backend
  - desktop secondary-click opens the complete action surface but a cursor-anchored platform-native context menu can still be evaluated after usability testing
  - advanced filter and audio-processing defaults require listening tests before claiming mastering-grade behavior
  - deterministic corrupt-import and orphan-recovery failure isolation is covered but representative malformed and partially written real-media corpus testing remains manual
  - deterministic 3000-entry metadata persistence is covered but real large-library UI memory and performance profiling remains manual
  - managed-path and rollback behavior is deterministically covered but real permission revocation low-storage abrupt-process and power-loss filesystem behavior remains manual
  - Debian package structure and hosted-runner install/startup/uninstall smoke are automated and the initial GitHub Releases channel is selected, while representative-system microphone routing desktop rendering accessibility and upgrade evidence remain manual release gates
  - Windows portable packaging and hosted extracted-startup smoke are automated, while real microphone routing accessibility visual review and Authenticode trust remain manual or credential-dependent release gates
  - Android release-mode APK/AAB compilation and Debug-certificate classification are automated, while protected upload-key/Play App Signing and physical-device/store validation remain maintainer/manual gates
  - macOS release-mode and iOS no-codesign release-mode compilation are automated, while Apple provisioning signing notarization TestFlight/App Store and real-hardware validation remain maintainer/manual gates
  - Web recording playback and share/download are implemented with browser-safe dependencies while native FFmpeg editing durable managed-library persistence Trash/recovery and native media sessions remain intentionally native-only capability boundaries
  - Web compile candidate packaging and checksum/provenance contracts are automated while representative Chromium Firefox Safari microphone accessibility PWA and production HTTPS hosting evidence remains manual
pending_manual_validation:
  - microphone permission accepted denied revoked and permanently denied behavior on native devices
  - Android and Apple background lock-screen media-session and interruption behavior on physical devices
  - keep-screen-awake behavior on physical devices
  - countdown and rapid lifecycle interactions on physical devices
  - wired USB Bluetooth and built-in microphone routing where available
  - headphone Bluetooth reconnect and media-button behavior
  - low-storage failure and recovery
  - disk and file permission failure recovery on target systems
  - abrupt process device and power interruption during metadata and managed-audio mutations followed by recovery verification
  - recovered-orphan behavior with real playable partially written and damaged audio on each maintained native platform
  - malformed audio imports across supported native operating systems using representative corpus files
  - batch conversion and direct export quality large-batch destination-loss and low-storage behavior on representative real recordings
  - desktop secondary-click ergonomics on Windows macOS and Linux
  - advanced editor output quality on representative voice and music recordings
  - 30-minute and multi-hour recording soak tests
  - screen-reader audits with TalkBack VoiceOver Narrator and desktop tooling
  - large-library UI memory and performance with thousands of recordings
  - Debian package install launch upgrade uninstall microphone routing and desktop icon visual behavior on representative Debian Ubuntu family systems
  - Windows portable ZIP extraction microphone routing playback import export accessibility branding and cleanup on representative Windows systems
  - real screenshots final native icon launch asset review and store metadata
  - Android protected upload-key Play App Signing and Play Console candidate validation
  - Apple provisioning signing notarization TestFlight App Store Connect and protected release validation
  - Windows Authenticode signing and trust verification on the exact final public package
  - Web microphone allow deny revoke retry and alternate-input behavior on representative current Chromium Firefox and Safari families
  - Web mono stereo effective configuration amplitude pause resume stop cancel playback and external WAV integrity on representative browsers
  - Web share API and download fallback behavior across browsers that expose different capabilities
  - Web long-capture and multiple-recording memory behavior on representative desktop and lower-memory mobile browsers
  - Web responsive zoom keyboard screen-reader theme branding and PWA/installability review
  - Web production HTTPS DNS TLS cache-update security-header rollback and deployment review
  - stable release approval and v1.0.0 tag only after all required evidence gates complete
latest_automated_validation:
  formatter_clean_source_commit: 0eb56abad482c8c296d9f80ef060ebddbba95e7b
  canonical_format_commit: 403aee21f783cc78e3c8eaa7a3ca2de0184379c1
  non_mutating_format_gate_commit: 32ced086fac27fd2f4f808674afa511647a863e9
  current_six_platform_revision:
    status: implementation_committed_pending_fresh_hosted_validation
    reason: Web runtime bootstrap CI release-candidate provenance audit and documentation changes postdate every historical green run recorded below
  core_flutter_ci:
    run_id: 31934843541
    source_commit: 0eb56abad482c8c296d9f80ef060ebddbba95e7b
    dart_format_check: success_non_mutating_committed_source_before_bootstrap
    analyzer: success_no_issues
    unit_tests: success_complete_suite
    android_debug_apk: success
    linux_debug_build: success
  release_candidate:
    run_id: 31873121457
    source_commit: 048870ec8dc26a16e2451310460d3e03c9084dc7
    historical_scope: Android Linux Windows macOS iOS only; predates Web target
    source_preflight: success
    android_release_nonproduction: success
    android_debug_certificate_verification: success
    linux_release_and_deb: success
    windows_release_portable_build_verify_startup_smoke: success
    macos_release_unsigned_archive: success
    ios_release_no_codesign_archive: success
    android_apk_sha256: 1fe7ea48d771209f4bfea097fc7d9e723cff00411b2541ee848e7ec20d6c271e
    android_aab_sha256: ecaf9842980b17af06f3b3f90898d286a3b38ebf0b15259271af2f07dab72f4f
    linux_bundle_sha256: a5fe64b440bf19b1b8a74e5a5ff875e645c2da7661bd8492e1a910160de179f8
    linux_deb_sha256: 414f11ad877c7c51861a14817cd3900d2bb77d3b49ea949d601e3686d5346498
    windows_portable_sha256: 60f5680548b0352d5230b6d40acc17a8b8b12d075b2ce1fd08c6209f565e3eb1
    macos_archive_sha256: 364c0d8f84c2779c45a36e13fd59d6bbcceebe03f62662a41dc4e2f9178d4af3
    ios_archive_sha256: 8d1209b94aa1aaff4369dff041ace9698bf4dcd5e0e6363a0fd470c50ee2e54d
    evidence_document: docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md
  provenance_release_candidate:
    run_id: 31876035202
    source_commit: b95d77c4b69c9798f1ecb48d5f69583c4e08de5c
    run_attempt: 1
    historical_scope: five-platform provenance only; no Web artifact or manifest entry
    source_preflight: success
    android_release_nonproduction: success
    linux_release_and_deb: success
    windows_release_portable_build_verify_startup_smoke: success
    macos_release_unsigned_archive: success
    ios_release_no_codesign_archive: success
    unified_manifest: success
    application_version: 0.1.0+1
    release_classification: development-preview
    stable_release_approved: false
    manifest_json_sha256: 8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e
    manifest_artifact_digest: sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3
    android_apk_sha256: 1457f53822af974de18905ba4d103b3c9a8fe2f66080848a48cd591f6287f9b8
    android_aab_sha256: 029571a665ec3359cdee5cb2b5c8357c8b3c450ef3fcb1f63d8f808eb635e99a
    linux_bundle_sha256: fbecb458fec864d451f0ba67e0b70f58f34710de883d5d4c8c86e32ab3238bd6
    linux_deb_sha256: eee447e80713f8c4102c200349cfae0873da1948dc0e2740f1b7d058a07d26e1
    windows_portable_sha256: c0cbc9ef7d00481e9f39fc058d5747779372dd61454a542eb5ce487d2da68ff3
    macos_archive_sha256: 0a4b2ac2c097e0f53eabbf84909ddc8f28bd28bd8bc37a0ea189b4ebc810733a
    ios_archive_sha256: a6b77c3d3a5badc305c7d7ebfc3a5a646197b48f09c1000854980fcffaaf17a7
    evidence_document: docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md
  permanent_windows_package_ci:
    run_id: 31872928500
    source_commit: 9a974f865e2dc189f08735fc6464b989eaa99eb4
    windows_debug_build: success
    windows_release_build: success
    portable_build: success
    portable_verify: success
    extracted_startup_smoke: success
    artifact_publication: success
  repository_integrity:
    candidate_clean_tree_run_id: 31873122160
    candidate_clean_tree_source_commit: 048870ec8dc26a16e2451310460d3e03c9084dc7
    candidate_clean_tree_result: success
    strengthened_audit_run_id: 31874506476
    strengthened_audit_source_commit: 64c121fa0e5c81531a3710b1d67b88fb3dfc93db
    strengthened_audit_result: success
    python_release_tooling_run_id: 31876149473
    python_release_tooling_result: success
    python_release_tool_tests: 10_of_10_passed
    manual_qa_verifier_run_id: 32016347023
    manual_qa_verifier_source_commit: c65f01e62dcca9c250e6b304fcc137e9a78c8b84
    manual_qa_verifier_result: success
  validation_relationship:
    - formatter-clean revision 4e0fbf16534a60e2d3209c5ec5f54d4982903f8c remains the exact historical debug/source-quality baseline with analysis tests Android and Linux debug validation
    - release-candidate revision 048870ec8dc26a16e2451310460d3e03c9084dc7 remains the earlier green five-native-platform release-mode hosted artifact baseline
    - provenance release-candidate revision b95d77c4b69c9798f1ecb48d5f69583c4e08de5c validates the unified machine-readable checksum/source/run binding on the historical five-platform hosted matrix
    - the 2026-08-20 Web expansion changes runtime bootstrap browser code CI release-candidate provenance auditing and documentation after those historical revisions and therefore requires fresh validation
    - manual-QA verifier revision c65f01e62dcca9c250e6b304fcc137e9a78c8b84 passed permanent Repository Integrity Audit run 32016347023 including Python compilation and tool regression discovery
    - stable release still requires the unchecked real-system browser and maintainer-credential gates
known_limitations:
  - codec availability and effective sample bitrate channel and DSP settings depend on OS device browser and runtime support
  - sharing silence-skip media-session input-device and screen-wake capabilities differ by platform backend
  - A-B loop is application-managed and requires real-device timing validation
  - generated platform hosts require the Flutter SDK and repository bootstrap tooling
  - batch conversion and direct export are sequential and non-destructive; very large batches require performance validation
  - deterministic import and orphan-recovery failures use controlled test doubles and do not substitute for malformed or partially written real-media corpora on each native platform
  - deterministic 3000-entry metadata roundtrip proves persistence integrity rather than real UI latency memory pressure or filesystem performance
  - metadata and managed-storage rollback/recovery tests do not substitute for low-storage abrupt-power process-kill permission-revocation and filesystem-failure evidence on real systems
  - metadata backup/orphan recovery cannot recreate audio bytes deleted or irreversibly damaged outside SonicNest
  - hosted-runner Linux package smoke proves install installed-payload startup-window and uninstall behavior only on the CI runner and does not prove representative real-system audio routing desktop integration accessibility upgrade or long-duration quality
  - hosted Windows startup smoke proves only bounded launch of the extracted portable package and does not prove microphone routing accessibility desktop integration or Authenticode trust
  - hosted Android release-mode artifacts are signed by the Android Debug certificate and are intentionally non-production
  - hosted macOS and iOS release-mode artifacts are unsigned/no-codesign validation artifacts and are not public Apple distributables
  - Web release compilation and checksummed static packaging do not prove real browser permission microphone playback share PWA accessibility memory or production-hosting behavior
  - current Web session recordings are memory-backed and must be explicitly downloaded/shared for retention; durable native managed-library and recovery semantics are not claimed on Web
  - native FFmpeg editing/conversion is not exposed on Web because the selected native FFmpeg dependency has no browser implementation
  - unified provenance manifest proves hosted artifact checksum/source/run consistency only and does not convert validation artifacts into stable signed or hosted distributables
  - manual-QA structural verification proves export/catalog/privacy/summary consistency only and does not authenticate the tester or reproduce the physical accessibility stress filesystem branding signing hosting or distribution observation
  - automated compilation cannot substitute for microphone hardware interruption background lock-screen routing media-button accessibility browser-policy storage-failure and long-duration QA
  - signed native distributable packages and production Web hosting credentials require maintainer-owned material that must not be committed
branch: main
commit_identity:
  name: Sanskar
  email: sanskarin@outlook.in
next_exact_tasks:
  - execute docs/QA_CHECKLIST.md on representative Android iOS macOS Windows and Linux hardware
  - execute docs/WEB_QA_CHECKLIST.md on representative Chromium Firefox and Safari browser families
  - verify countdown screen-wake microphone routing interruption and media-session behavior on physical devices
  - verify Web permission input selection capture pause resume WAV playback share/download and session-memory behavior on representative browsers
  - validate a production-like HTTPS Web host including cache updates PWA behavior security headers and rollback before public Web release
  - run abrupt process interruption permission failure and low-storage recovery scenarios against the managed metadata and orphan-recovery paths on representative native systems
  - run real playable partially written and damaged managed-audio orphan recovery scenarios on each maintained native platform
  - run a privacy-safe malformed audio corpus through import on each maintained native platform and record per-file results
  - profile thousands of Library entries in the real UI for latency memory and scrolling behavior rather than relying only on metadata serialization tests
  - install the Debian package on representative Debian Ubuntu family systems and verify launcher icon microphone routing upgrade and uninstall behavior with release evidence
  - extract the Windows portable ZIP on representative Windows systems and verify microphone routing accessibility branding cleanup and final Authenticode status for a public candidate
  - listen-test and tune advanced processing presets against representative recordings
  - test large batch conversion and direct-export sets plus desktop secondary-click ergonomics on physical desktop systems
  - evaluate dedicated Windows and Linux system media-session integration only where maintained platform support is suitable
  - evaluate cursor-anchored platform-native desktop context menus only if they materially improve usability over the implemented action surface
  - profile multi-hour recordings and large libraries
  - profile long and repeated Web captures for browser memory pressure
  - resolve any reproducible device/browser-only issues discovered by manual QA
  - capture real screenshots and review native and Web/PWA icon launch assets from tested release candidates
  - configure protected Android Apple Windows signing and production Web deployment credentials only in maintainer-owned release environments after manual gates are satisfied
  - tag v1.0.0 only after the exact signed/hosted public candidates complete every required release gate
```

## Current six-platform expansion — 2026-08-20

- SonicNest now targets Android, iOS, macOS, Windows, Linux, and Web from one shared default Flutter entry point.
- Native startup was isolated behind a Dart IO conditional bootstrap; Web startup is isolated behind `dart.library.js_interop` so native-only imports do not enter browser compilation.
- The Web recorder supports microphone permission, input enumeration/selection, PCM16 streaming, pause/resume/stop/cancel, amplitude metering, local WAV packaging, in-session playback, and explicit share/download fallback.
- `lib/core/wav_encoder.dart` and `test/wav_encoder_test.dart` provide a pure-Dart WAV container path and deterministic regression coverage.
- Both platform bootstrap scripts now generate `android,ios,macos,linux,windows,web`.
- Branding generation now includes Web launcher/icon metadata and Web splash resources.
- Core CI has a dedicated `flutter build web --release` job through the normal `lib/main.dart` entry point.
- Manual Release Candidate Validation now creates a checksummed `sonicnest-web-release.tar.gz` artifact and the unified provenance manifest requires all six platform artifact directories.
- `tool/tests/test_web_platform_contract.py` plus repository-audit invariants protect the Web entry point, six-target bootstrap, branding, CI, release candidate, provenance, and documentation surfaces.
- `docs/WEB_SUPPORT.md` and `docs/WEB_QA_CHECKLIST.md` document browser capabilities, native-only boundaries, privacy, browser QA, PWA/hosting checks, and release evidence.
- Historical green runs listed below remain valid only for their exact historical source revisions. None of the 2026-08-15 five-platform runs is being reused as proof that the current Web implementation builds or works in real browsers.
- Current classification remains **development preview** until fresh hosted six-platform validation plus representative real-browser and production-hosting evidence is obtained.

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

- Validated source revision: `40c4a758debef136c2d8c977c321446cca2697cd`.
- Core run `31776174696`: brand source generation, analyzer, tests, Android branded APK, and Linux build **SUCCESS**.
- Windows run `31776174725`: native branding generation and Windows debug build **SUCCESS**.
- Apple run `31776174715`: native branding generation plus macOS and unsigned-iOS debug builds **SUCCESS**.
- Android/iOS native splash generation and Android/iOS/macOS/Windows launcher-icon generation are repository-automatable and implemented in that historical revision.
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
- Historical formatter drift from that run was later closed by canonical formatting and a non-mutating CI gate.
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

## Historical five-platform automated release-candidate validation — 2026-08-15

- Candidate source revision: `048870ec8dc26a16e2451310460d3e03c9084dc7`.
- Release Candidate Validation run `31873121457`: **SUCCESS** across Source preflight, Android release-mode non-production APK/AAB, Linux release bundle + Debian package, Windows release portable ZIP + verify + extracted startup smoke, macOS release archive, and iOS release no-codesign archive.
- This run predates the 2026-08-20 Web target and therefore contains no Web build or browser artifact evidence.
- Android Debug-certificate identity and non-production classification were verified before upload; exact certificate and artifact hashes are recorded in `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md`.
- Windows permanent package CI run `31872928500` independently passed release build, portable package construction/verification, extracted startup smoke, and artifact publication.
- Clean candidate-tree repository audit run `31873122160`: **SUCCESS**.
- Strengthened repository audit run `31874506476` on commit `64c121fa0e5c81531a3710b1d67b88fb3dfc93db`: **SUCCESS** after adding `.yaml` workflow recognition and `write-all`/write-scope rejection.
- The automated evidence is release-mode structural/build/package evidence only. SonicNest remains a **development preview** until physical-device, representative real-system/browser, accessibility, long-duration/performance, protected signing/notarization, production hosting, and stable-release approval gates are completed.

## Historical five-platform unified release-candidate provenance validation — 2026-08-15

- Provenance source revision: `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c`.
- Release Candidate Validation run `31876035202`: **SUCCESS** for Source preflight, Android, Linux, Windows, macOS, iOS, and the final **Unified candidate provenance manifest** job.
- This run predates Web candidate integration. Its manifest contains five platform entries and must not be used as evidence for the current six-platform implementation.
- `tool/build_release_candidate_manifest.py` at that historical revision re-verified all five platform payloads against each artifact set's `SHA256SUMS.txt`, required the Android Debug/NON-PRODUCTION signing-state markers, and bound the result to the exact full source SHA, workflow run, workflow attempt, and application version.
- Manifest application version: `0.1.0+1`.
- Manifest release classification: `development-preview`.
- Manifest `stableReleaseApproved`: `false`.
- `RELEASE_CANDIDATE_MANIFEST.json` SHA-256: `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`.
- Independent post-download recomputation matched the recorded manifest SHA-256 exactly.
- Manifest workflow artifact digest: `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`.
- Permanent Repository Integrity Audit run `31876149473` passed Python compilation, repository invariants, **10/10** Python release-tool tests, Bash syntax, and PowerShell syntax for that historical source.
- The temporary narrow documentation-path push trigger used to obtain this validation was removed in commit `79b5195e7f207ebc1076e38faecb5c4c9c2447e7`; the permanent release-candidate workflow is again manual `workflow_dispatch` only.
- This provenance evidence proves historical hosted checksum/source/run consistency. It does not complete Web build/browser evidence or physical-device, real-system, accessibility, protected signing/notarization, store, hosting, or stable-release gates.

## Latest source-line hardening — 2026-08-17

- Added a permanent tracked-text/source line audit to the Repository Integrity Audit workflow.
- Removed recorder cleanup ownership of an uncreated target candidate path; cleanup now targets only recorder-owned capture/output files.
- Recorder cancellation now attempts a backend stop fallback when backend cancellation fails and always releases background/wake state through cleanup paths.
- Core and advanced FFmpeg processing remove partial managed outputs when processing or output validation fails.
- Metadata loading now refuses unsupported integer schema versions without rewriting or classifying newer metadata as corruption; malformed schema types remain corruption-isolated.
- Stable-release classification remains unchanged: physical-device, accessibility, stress, protected-signing, store/hosting, and final approval gates remain manual/credential-dependent.
