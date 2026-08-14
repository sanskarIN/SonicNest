# SonicNest

<p align="center">
  <img src="assets/logo/sonicnest_logo.svg" alt="SonicNest logo" width="420" />
</p>

**SonicNest** is a privacy-first, cross-platform sound and voice recorder built with Flutter. It combines reliable capture, a searchable recording library, playback, bookmarks, non-destructive editing/export, input-device awareness, theme/accessibility support, and a clean open-source architecture.

**Made by the Sanskar**

## Status

Current development version: **0.1.0**. The repository is structured as a production project with automated analysis/tests, Android/Linux/Windows/macOS/iOS build validation workflows, Debian Linux package validation, open-source documentation, continuation state, reproducible platform bootstrap and branding tooling, and explicit manual release gates. This is still a development preview until the physical-device and signed-release checklist is complete.

## Major features

- Voice and general sound recording with start, configurable/cancellable countdown, pause, resume, stop, cancel, safe cleanup, and recoverable error handling.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and raw AAC output/export paths where the runtime codec stack supports them.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom presets.
- Bitrate, sample rate, mono/stereo, automatic gain, echo cancellation, and noise suppression settings where the platform honors them.
- Smart filename templates with prefix, suffix, category, date/time, individual date/time fields, and sequence tokens.
- Optional keep-screen-awake behavior during active recording, with cleanup after stop/cancel/failure.
- Live amplitude waveform, clipping warning, recording timer, markers/bookmarks, and input-device-aware recording services.
- Persisted waveform envelopes for recorded, imported, and processed media.
- Searchable library with favorites, pinned items, tags, folders, trash/restore, rename, duplicate, import, export, share, sorting, format/folder/tag/date filtering, and multi-selection bulk actions.
- Multi-file import isolates copy/probe/waveform failures so a corrupt or missing selected audio file is cleaned up and does not prevent later valid selections from being imported.
- Local metadata decoding tolerates damaged optional fields and malformed individual records, preserves structurally corrupt metadata for diagnostics, and can recover a valid `.bak` left by an interrupted metadata replacement.
- Batch tools can convert several recordings or copy selected originals directly to a user-selected folder with collision-safe naming.
- Desktop secondary/right-click access to the same complete recording action surface used by touch/menu workflows.
- Multi-recording batch format conversion with target-format selection, progress, per-file failure isolation, preserved source files, retained markers, and successful-output registration in the library.
- Managed storage statistics for recordings, Trash, and temporary processing files, plus guarded temporary-file cleanup.
- Integrated player with seek, jump controls, volume, speed, repeat-one, previous/next recording navigation, A-B selection looping, bookmarks, and silence-skip support where available.
- Android, iOS, and macOS media-session metadata plus notification/lock-screen playback integration using `just_audio_background` and tagged media sources.
- Non-destructive FFmpeg-backed editing: keep selection, cut selection, split, merge, normalize, fades, silence removal/insertion, gain changes, basic noise cleanup, compressor, limiter, high-pass/low-pass filters, format conversion, draggable selection handles, selection undo/redo, and export presets.
- Native launcher/splash branding generated reproducibly from project-controlled SonicNest mark geometry, plus branded Flutter startup UI with startup-error recovery.
- Debian `.deb` packaging for Linux with desktop entry, AppStream metadata, generated SonicNest icon integration, package checksums, structural verification, hosted-runner installation/startup smoke, and uninstall cleanup verification.
- Localization-ready presentation layer with primary Flutter surfaces centralized in the localization catalog; English is currently the shipped locale.
- Light, dark, and system themes; responsive phone/tablet/desktop navigation; reduced-motion preference; keyboard navigation and recorder/player shortcuts.
- Offline-first local metadata and audio storage. No hidden upload, tracking, or analytics.
- Android foreground recording-service integration through reproducible platform overrides.

## Desktop shortcuts

- `Ctrl+1` through `Ctrl+5`: Home, Recorder, Library, Settings, About.
- `F9`: start/stop recording, or cancel an active countdown.
- `F10`: pause/resume recording.
- `Ctrl+Alt+P`: play/pause the loaded recording.
- `Ctrl+Alt+Left` / `Ctrl+Alt+Right`: jump backward/forward by the configured interval.
- Secondary/right-click on a recording tile opens its recording action surface on desktop pointer devices.

## Batch conversion

Open **Batch Convert** from Home, select one or more saved non-Trash recordings, choose the target format, and start conversion. SonicNest processes the selected items sequentially so each output can be tracked independently. The source recording is never overwritten; successful converted files are registered as new library recordings and a failure in one item does not discard earlier successful outputs.

## Supported platforms

The application architecture targets Android, iOS, macOS, Windows, and Linux. Platform host projects are generated with the installed Flutter SDK by `tool/bootstrap_platforms.sh` on Bash-capable environments or `tool/bootstrap_platforms.ps1` on Windows, then SonicNest-specific permissions/capabilities are applied. Native brand resources are generated after dependency resolution with `tool/apply_branding.sh` or `tool/apply_branding.ps1`. This keeps host scaffolding and native resources reproducible from repository source.

Debian `.deb` is the initial repository-supported Linux installation package. It is built from the generated Flutter Linux release bundle rather than committed binary output.

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
dart format lib test tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test
```

GitHub Actions additionally compiles representative debug builds for Android, Linux, Windows, macOS, and unsigned iOS host validation. A dedicated Linux package workflow builds a release-mode Linux bundle, creates a Debian package, verifies its payload/metadata/icon/checksum structure, installs it through the package manager, smoke-starts the installed application under a bounded virtual display, removes the package, verifies package-owned integration cleanup, and publishes a short-retention validation artifact. Hardware-dependent recorder, interruption, background, routing, screen-wake, media-button, batch-performance, native-brand visual inspection, representative Linux installation, and lock-screen behavior still requires real target devices.

The current batch-conversion/right-click source revision `985f2dd1500a03b0b65ee58b142cf31f545b0cc5` passed analyzer and unit tests plus Android, Linux, Windows, macOS, and unsigned iOS debug builds in GitHub Actions. This automated result does not replace the physical-device release checklist.

The metadata/import reliability revision `a88aeadadda017b0aced4dbc25c8426a27364b77` passed formatting, static analysis, all unit tests, Android debug APK, and Linux debug build in core Flutter CI run `31807193932`. The cross-platform import-controller source revision `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` also passed Windows run `31807141053` and Apple run `31807141166` for Windows, macOS, and unsigned-iOS debug builds. Repository Integrity Audit run `31807662729` passed after obsolete one-shot workflows were removed and the permanent workflow allowlist/read-only invariant was active. These automated results do not substitute for real malformed-media corpus, low-storage/permission/power-loss, large-library UI/performance, accessibility, hardware, or signing/release evidence.

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

Recordings remain on-device by default. SonicNest does not upload microphone data or recordings without an explicit user-initiated action. See `PRIVACY.md`.

## Codec notes

Native recording uses platform encoders through `record`. Formats requiring transcoding use an audio-focused FFmpeg package. Capabilities vary by platform/device, so SonicNest checks recorder support and uses fallback/error behavior instead of claiming unsupported combinations. See `docs/CODECS.md`.

## Building, metadata integrity, branding, packaging, QA, and releases

See `docs/BUILDING.md` for platform bootstrap/build commands, `docs/METADATA_INTEGRITY.md` for local-library corruption isolation and interrupted-save recovery, `docs/BRANDING.md` for deterministic native icon/splash generation, `docs/LINUX_PACKAGING.md` for Debian packaging, `docs/QA_CHECKLIST.md` for the full hardware/release checklist, `docs/RELEASING.md` for the release procedure, `RELEASE_NOTES.md` for the development-preview notes, and `TODO.md` for evidence-based remaining gates.

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

### External folder copies and safe stopping

Batch Convert can optionally copy each successful converted output to a user-selected folder. SonicNest avoids destination overwrites with numbered names and keeps the managed library result even if the external copy fails. During a long batch, **Stop after current file** prevents new items from starting after the current conversion finishes. The source revision implementing this behavior passed analyzer/tests and all five platform debug-build targets in validation run `31773250023`.

### Localization-ready presentation

SonicNest currently ships English, but primary Flutter presentation text is centralized in `lib/l10n/app_localizations.dart` across startup, Home, Recorder, Library, Player, Editor, Settings, Batch Convert, About/support, and reusable recording controls. Additional languages still require translation, text-expansion review, and platform accessibility QA before release.
