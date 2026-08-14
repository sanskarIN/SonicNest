# SonicNest

<p align="center">
  <img src="assets/logo/sonicnest_logo.svg" alt="SonicNest logo" width="420" />
</p>

**SonicNest** is a privacy-first, cross-platform sound and voice recorder built with Flutter. It combines reliable capture, a searchable recording library, playback, bookmarks, non-destructive editing/export, input-device awareness, theme/accessibility support, and a clean open-source architecture.

**Made by the Sanskar**

## Status

Current development version: **0.1.0**. The repository is structured as a production project with automated analysis/tests, Android/Linux/Windows/macOS/iOS build validation workflows, open-source documentation, continuation state, and reproducible platform bootstrap tooling.

## Major features

- Voice and general sound recording with start, pause, resume, stop, cancel, safe cleanup, and recoverable error handling.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and raw AAC output/export paths where the runtime codec stack supports them.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom presets.
- Bitrate, sample rate, mono/stereo, automatic gain, echo cancellation, and noise suppression settings where the platform honors them.
- Live amplitude waveform, clipping warning, recording timer, markers/bookmarks, and input-device-aware recording services.
- Persisted waveform envelopes for recorded, imported, and processed media.
- Searchable library with favorites, pinned items, tags, folders, trash/restore, rename, duplicate, import, export, share, sorting, filtering, and multi-selection bulk actions.
- Integrated player with seek, jump controls, volume, speed, repeat, bookmarks, and silence-skip support where available.
- Android, iOS, and macOS media-session metadata plus notification/lock-screen playback integration using `just_audio_background` and tagged media sources.
- Non-destructive FFmpeg-backed editing: trim, split, merge, normalize, fades, silence removal, format conversion, draggable selection handles, selection undo/redo, and export presets.
- Light, dark, and system themes; responsive phone/tablet/desktop navigation; keyboard navigation shortcuts.
- Offline-first local metadata and audio storage. No hidden upload, tracking, or analytics.
- Android foreground recording-service integration through reproducible platform overrides.

## Supported platforms

The application architecture targets Android, iOS, macOS, Windows, and Linux. Platform host projects are generated with the installed Flutter SDK by `tool/bootstrap_platforms.sh` on Bash-capable environments or `tool/bootstrap_platforms.ps1` on Windows, then SonicNest-specific permissions/capabilities are applied. This keeps host scaffolding aligned with the Flutter SDK used to build the app.

## Quick start

macOS/Linux/Git Bash:

```bash
git clone https://github.com/sanskarIN/SonicNest.git
cd SonicNest
bash tool/bootstrap_platforms.sh
flutter pub get
flutter run
```

Windows PowerShell:

```powershell
git clone https://github.com/sanskarIN/SonicNest.git
cd SonicNest
./tool/bootstrap_platforms.ps1
flutter pub get
flutter run
```

## Quality commands

```bash
flutter pub get
dart format lib test
flutter analyze --no-fatal-infos
flutter test
```

GitHub Actions additionally compiles representative debug builds for Android, Linux, Windows, macOS, and unsigned iOS host validation. Hardware-dependent recorder, interruption, background, and lock-screen behavior still requires real target devices.

## Architecture

SonicNest separates models, services, controllers, presentation, reusable widgets, and platform configuration. See `docs/ARCHITECTURE.md`.

## Privacy

Recordings remain on-device by default. SonicNest does not upload microphone data or recordings without an explicit user-initiated action. See `PRIVACY.md`.

## Codec notes

Native recording uses platform encoders through `record`. Formats requiring transcoding use an audio-focused FFmpeg package. Capabilities vary by platform/device, so SonicNest checks recorder support and uses fallback/error behavior instead of claiming unsupported combinations. See `docs/CODECS.md`.

## Building and validation

See `docs/BUILDING.md` for platform bootstrap commands, CI coverage, and signing boundaries. See `docs/QA_CHECKLIST.md` for the manual hardware/release checklist.

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
