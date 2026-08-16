# SonicNest

<p align="center">
  <img src="assets/logo/sonicnest_logo.svg" alt="SonicNest logo" width="420" />
</p>

**SonicNest** is a privacy-first, cross-platform sound and voice recorder built with Flutter. It combines reliable capture, a searchable recording library, playback, bookmarks, non-destructive editing/export, input-device awareness, theme/accessibility support, and a clean open-source architecture.

**Made by the Sanskar**

## Status

Current development version: **0.1.0**. The repository is structured as a production project with automated analysis/tests, Android/Linux/Windows/macOS/iOS build validation workflows, Debian Linux package validation, Windows portable-package validation, non-production release-candidate validation, open-source documentation, continuation state, reproducible platform bootstrap and branding tooling, and explicit manual release gates. This is still a development preview until the physical-device and signed-release checklist is complete.

## Major features

- Voice and general sound recording with start, configurable/cancellable countdown, pause, resume, stop, cancel, safe cleanup, and recoverable error handling.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and raw AAC output/export paths where the runtime codec stack supports them.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom presets.
- Bitrate, sample rate, mono/stereo, automatic gain, echo cancellation, and noise suppression settings where the platform honors them.
- Smart filename templates with prefix, suffix, category, date/time, individual date/time fields, and sequence tokens.
- Optional keep-screen-awake behavior during active recording, with cleanup after stop/cancel/failure.
- Live amplitude waveform, clipping warning, recording timer, markers/bookmarks, and input-device-aware recording services.
- Persisted waveform envelopes for recorded, imported, processed, and recovered managed media.
- Searchable library with favorites, pinned items, tags, folders, trash/restore, rename, duplicate, import, export, share, sorting, format/folder/tag/date filtering, and multi-selection bulk actions.
- Multi-file import isolates copy/probe/waveform failures so a corrupt or missing selected audio file is cleaned up and does not prevent later valid selections from being imported.
- Local metadata decoding tolerates damaged optional fields and malformed individual records, normalizes unsafe numeric/waveform values, isolates duplicate IDs/paths, preserves structurally corrupt metadata for diagnostics, and can recover a valid `.bak` left by an interrupted metadata replacement.
- Startup orphan recovery reconstructs metadata for supported regular audio files that still exist in managed `Recordings` or `.trash` after a crash, interrupted metadata write/deletion, or unrecoverable metadata reset; damaged media remains visible with best-effort metadata instead of being silently discarded.
- Managed-storage guards require supported regular audio and reject external, unsupported, symbolic-link, and non-file metadata paths before rename, duplicate, move-to-Trash, restore, or permanent-delete operations.
- Persistence-safe library mutations restore in-memory metadata and roll filesystem moves back when metadata persistence fails; permanent deletion persists metadata first so a crash prefers a recoverable orphan over irreversible data loss.
- Collision-safe managed and external destinations treat existing files, directories, symbolic links, and broken links as occupied instead of overwriting/following them.
- Batch tools can convert several recordings or copy selected originals directly to a user-selected folder with collision-safe naming.
- Desktop secondary/right-click access to the same complete recording action surface used by touch/menu workflows.
- Multi-recording batch format conversion uses a deterministic service with target-format selection, progress, per-file conversion failure isolation, external-copy failure isolation, preserved source files, retained markers, and successful-output registration in the library.
- **Stop after current file** prevents another batch item from starting after the current conversion finishes; leaving Batch Convert raises the same stop request instead of forcibly killing the active encoder.
- Managed storage statistics for recordings, Trash, and temporary processing files, plus guarded temporary-file cleanup. Recording/Trash totals count supported top-level regular managed audio rather than arbitrary files in those directories.
- Integrated player with seek, jump controls, volume, speed, repeat-one, previous/next recording navigation, A-B selection looping, bookmarks, and silence-skip support where available.
- Android, iOS, and macOS media-session metadata plus notification/lock-screen playback integration using `just_audio_background` and tagged media sources.
- Non-destructive FFmpeg-backed editing: keep selection, cut selection, split, merge, normalize, fades, silence removal/insertion, gain changes, basic noise cleanup, compressor, limiter, high-pass/low-pass filters, format conversion, draggable selection handles, selection undo/redo, and export presets.
- In-app **Diagnostics & QA** reports provide privacy-safe runtime, aggregate library/storage, recorder-state, and settings evidence for physical-device/support testing. Reports exclude recording content, titles, paths, notes, tags, bookmarks, smart-naming text, and input-device names; they are created only on user request and are never automatically uploaded.
- In-app **Manual QA evidence** sessions mirror the remaining real-device/system release checks and persist only fixed check IDs, `Not run`/`Passed`/`Failed`/`Blocked` status, and timestamps. Evidence can be copied as JSON or explicitly shared as Markdown, has no free-form tester-note field, drops stale catalog IDs, and never turns a manual observation into an automatic release approval.
- Native launcher/splash branding generated reproducibly from project-controlled SonicNest mark geometry, plus branded Flutter startup UI with startup-error recovery.
- Debian `.deb` packaging for Linux with desktop entry, AppStream metadata, generated SonicNest icon integration, package checksums, structural verification, hosted-runner installation/startup smoke, and uninstall cleanup verification.
- Initial public Linux distribution policy: verified `.deb` + SHA-256 checksum through GitHub Releases; no initial custom APT repository.
- Versioned x64 portable ZIP packaging for Windows with complete Flutter runner-bundle validation, credential-material checks, SHA-256 output, bounded extracted-package startup smoke, optional final Authenticode verification, and hosted unsigned package artifacts.
- Initial Windows public distribution policy: GitHub Releases with the final Authenticode-verified portable ZIP and its post-signing SHA-256 checksum; Microsoft Store/MSIX/MSI/installer channels are not currently claimed.
- Android release-candidate validation verifies package identity and explicitly classifies hosted release-mode APK/AAB output as Android Debug-certificate **non-production** artifacts instead of calling them unsigned.
- Initial Android public distribution policy: Google Play with Play App Signing and a separately protected maintainer-controlled upload key; hosted CI has no production Play signing credentials.
- Initial Apple distribution policy: TestFlight/App Store for iOS and signed/notarized GitHub Releases for macOS; hosted Apple artifacts remain no-codesign/non-publication validation output.
- Localization-ready presentation layer with primary Flutter surfaces centralized in the localization catalog; English is currently the shipped locale. Product-facing text is localized while raw backend diagnostics remain technical evidence.
- Light, dark, and system themes; responsive phone/tablet/desktop navigation; reduced-motion preference; keyboard navigation and recorder/player shortcuts.
- Offline-first local metadata and audio storage. No hidden upload, tracking, or analytics.
- Android foreground recording-service integration through reproducible platform overrides.
- Lazy native recorder initialization: constructing application/controller services does not touch the recorder method channel until recorder functionality is actually requested.
- Source-controlled cross-platform store/distribution listing and privacy copy that must be reviewed against the exact release candidate before submission.

## Desktop shortcuts

- `Ctrl+1` through `Ctrl+5`: Home, Recorder, Library, Settings, About.
- `F9`: start/stop recording, or cancel an active countdown.
- `F10`: pause/resume recording.
- `Ctrl+Alt+P`: play/pause the loaded recording.
- `Ctrl+Alt+Left` / `Ctrl+Alt+Right`: jump backward/forward by the configured interval.
- Secondary/right-click on a recording tile opens its recording action surface on desktop pointer devices.

## Batch conversion

Open **Batch Convert** from Home, select one or more saved non-Trash recordings, choose the target format, and start conversion. SonicNest processes selected items sequentially. The source recording is never overwritten; successful converted files are registered as new Library recordings and a failure in one item does not discard earlier successful outputs. Optional external copies happen only after the managed result is registered, so an unavailable external destination does not invalidate a conversion already preserved in SonicNest.

See `docs/BATCH_CONVERSION.md` for execution ordering, failure isolation, stop semantics, and the manual-evidence boundary.

## Supported platforms

The application architecture targets Android, iOS, macOS, Windows, and Linux. Platform host projects are generated with the installed Flutter SDK by `tool/bootstrap_platforms.sh` on Bash-capable environments or `tool/bootstrap_platforms.ps1` on Windows, then SonicNest-specific permissions/capabilities are applied. Native brand resources are generated after dependency resolution with `tool/apply_branding.sh` or `tool/apply_branding.ps1`. This keeps host scaffolding and native resources reproducible from repository source.

Google Play is the initial Android public channel. Production distribution requires maintainer-owned Play Console/App Signing/upload-key configuration outside this repository. See `docs/ANDROID_DISTRIBUTION_POLICY.md`.

iOS uses TestFlight/App Store as the initial Apple mobile channel; macOS initially uses signed/notarized GitHub Releases. See `docs/APPLE_DISTRIBUTION_POLICY.md`.

Debian `.deb` is the initial repository-supported Linux installation package. It is built from the generated Flutter Linux release bundle rather than committed binary output. The initial public Linux channel is GitHub Releases; see `docs/LINUX_DISTRIBUTION_POLICY.md`.

A versioned x64 portable ZIP is the initial repository-supported Windows package. It is built from the complete generated Flutter Windows release bundle. Hosted validation ZIPs are unsigned; a stable public Windows ZIP must satisfy the Authenticode and real-system gates before publication through the initial GitHub Releases channel. See `docs/WINDOWS_PACKAGING.md` and `docs/WINDOWS_SIGNING_POLICY.md`.

## Quick start

macOS/Linux/Git Bash:

```bash
git clone https://github.com/sanskarIN/SonicNest.git
cd SonicNest
bash tool/bootstrap_platforms.sh
flutter pub get
bash tool/apply_branding.sh
flutter run
```

Windows PowerShell:

```powershell
git clone https://github.com/sanskarIN/SonicNest.git
cd SonicNest
./tool/bootstrap_platforms.ps1
flutter pub get
./tool/apply_branding.ps1
flutter run
```

## Quality commands

```bash
flutter pub get
dart tool/generate_brand_assets_v2.dart
dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test
```

The formatting step is an enforcement check and must not rewrite source during validation. If it reports drift, apply canonical `dart format` locally, review/commit that output, and rerun validation.

GitHub Actions additionally compile representative debug builds for Android, Linux, Windows, macOS, and unsigned iOS host validation. The Linux package workflow builds a release-mode Linux bundle, creates a Debian package, verifies its payload/metadata/icon/checksum structure, installs it through the package manager, smoke-starts the installed application under a bounded virtual display, removes the package, verifies package-owned integration cleanup, and publishes a short-retention validation artifact. The Windows workflow also builds a release-mode Windows bundle, creates a versioned portable ZIP, verifies its required runtime/data layout and checksum, checks for common private/signing material, smoke-starts the extracted package for a bounded interval, adds an explicit unsigned warning, and publishes a short-retention validation artifact. The manual release-candidate workflow validates Android package identity/debug-certificate non-production signing state and creates release-mode evidence for Android, Linux, Windows, macOS, and no-codesign iOS.

The repository audit validates required project/policy files, sensitive-material rules, permanent-workflow read-only permissions, package/release invariants, and parses all tracked `tool/*.sh` and `tool/*.ps1` helpers.

Hardware-dependent recorder, interruption, background, routing, screen-wake, media-button, batch-performance, native-brand visual inspection, representative Linux installation, Windows real-system portable-package behavior, filesystem-failure, malformed-real-media, accessibility, production signing, store submission, and lock-screen behavior still require real target-system or protected maintainer-environment evidence. The Manual QA evidence screen provides a local/exportable status ledger for those observations but does not mark repository gates complete. Exact latest validated source/workflow relationships are maintained in `PROJECT_STATE.md` and `what_changed.md`; older historical validation revisions remain in the repository history rather than being presented here as the current state.

## Build a Windows portable package

On a Windows build host with Flutter desktop prerequisites:

```powershell
flutter config --enable-windows-desktop
./tool/bootstrap_platforms.ps1
flutter pub get
./tool/apply_branding.ps1
flutter build windows --release
./tool/build_windows_portable.ps1 -Configuration release -ArtifactSuffix unsigned
./tool/verify_windows_portable.ps1
./tool/smoke_test_windows_portable.ps1 -StartupSeconds 8
```

The hosted/development path uses the `unsigned` label. A final public candidate must be packaged from the final signed binaries and must pass `./tool/verify_windows_portable.ps1 -ArchivePath '<final-portable-zip>' -RequireSignature` plus the bounded package startup smoke before its final SHA-256 is published. See `docs/WINDOWS_PACKAGING.md`.

## Build a Linux Debian package

On a Debian/Ubuntu-compatible Linux build host with the Flutter Linux prerequisites, `dpkg-deb`, `desktop-file-utils`, and AppStream tools installed:

```bash
flutter config --enable-linux-desktop
bash tool/bootstrap_platforms.sh
flutter pub get
dart tool/generate_brand_assets_v2.dart
flutter build linux --release
bash tool/build_linux_deb.sh release
bash tool/verify_linux_deb.sh
```

The `.deb` and its SHA-256 checksum are written under `build/linux-package/`. See `docs/LINUX_PACKAGING.md` before installation or release testing.

## Architecture

SonicNest separates models, services, controllers, presentation, reusable widgets, localization scaffolding, and platform configuration. See `docs/ARCHITECTURE.md`.

## Privacy

Recordings remain on-device by default. SonicNest does not upload microphone data or recordings without an explicit user-initiated action. Diagnostics are generated only on request, exclude recording/library content and file paths, and are not automatically uploaded. Manual QA evidence stores only fixed check IDs, status values, and timestamps; it collects no free-form tester notes and is exported/shared only through explicit user actions. See `PRIVACY.md`, `docs/DIAGNOSTICS_AND_QA.md`, and `docs/MANUAL_QA_EVIDENCE.md`.

## Codec notes

Native recording uses platform encoders through `record`. Formats requiring transcoding use an audio-focused FFmpeg package. Capabilities vary by platform/device, so SonicNest checks recorder support and uses fallback/error behavior instead of claiming unsupported combinations. See `docs/CODECS.md`.

## Building, integrity, recovery, localization, packaging, QA, and releases

- `docs/BUILDING.md` — platform bootstrap/build commands.
- `docs/METADATA_INTEGRITY.md` — metadata corruption isolation, transaction rollback, reconciliation, and orphan recovery.
- `docs/MANAGED_STORAGE_BOUNDARY.md` — supported regular-file boundaries, symbolic-link refusal, collision safety, and accounting.
- `docs/RECOVERY_TESTING.md` — reproducible recovery validation scenarios.
- `docs/BATCH_CONVERSION.md` — conversion ordering, failure isolation, stop behavior, and external-copy rules.
- `docs/LOCALIZATION_POLICY.md` — user-facing translation versus raw technical diagnostic policy.
- `docs/DIAGNOSTICS_AND_QA.md` — privacy contract, report fields, sharing behavior, and physical-QA evidence guidance.
- `docs/MANUAL_QA_EVIDENCE.md` — local manual-test status sessions, privacy boundary, persistence, export format, and release-evidence usage.
- `docs/BRANDING.md` — deterministic native icon/splash generation.
- `docs/ANDROID_DISTRIBUTION_POLICY.md` — Google Play, Play App Signing, upload-key, and Android candidate-signing boundary.
- `docs/APPLE_DISTRIBUTION_POLICY.md` — TestFlight/App Store and macOS signed/notarized distribution boundary.
- `docs/LINUX_PACKAGING.md` — Debian package construction and verification.
- `docs/LINUX_DISTRIBUTION_POLICY.md` — initial GitHub Releases `.deb` distribution/signing boundary.
- `docs/WINDOWS_PACKAGING.md` — initial Windows portable ZIP package/channel, structural verification, and bounded startup-smoke contract.
- `docs/WINDOWS_SIGNING_POLICY.md` — stable public Windows Authenticode policy and private-credential boundary.
- `docs/STORE_LISTING.md` — source-controlled listing copy and privacy-declaration draft for distribution review.
- `docs/UNSIGNED_ARTIFACTS.md` — platform-specific non-production candidate-artifact classification and boundaries.
- `docs/QA_CHECKLIST.md` — hardware and stable-release evidence checklist.
- `docs/RELEASING.md` — release procedure.
- `RELEASE_NOTES.md` — development-preview release notes.
- `TODO.md` — evidence-based remaining gates.

## Contributing

Please read `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md` before contributing.

## Support and links

- GitHub profile: https://www.github.com/sanskarIN
- Repository: https://github.com/sanskarIN/SonicNest
- Business: sanskarin@outlook.in
- Business: sanskarin.business@gmail.com
- Support: supportramsandesh@gmail.com
- ☕ Buy Me a Coffee: https://buymeacoffee.com/sanskarIN

## License

Apache License 2.0. See `LICENSE` and `NOTICE`. Dependency licenses remain their own.
