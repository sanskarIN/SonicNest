# SonicNest

<p align="center">
  <img src="assets/logo/sonicnest_logo.svg" alt="SonicNest logo" width="420" />
</p>

**SonicNest** is a privacy-first, cross-platform sound and voice recorder built with Flutter. It combines reliable capture, a searchable recording library, playback, bookmarks, non-destructive editing/export, input-device awareness, theme/accessibility support, and a clean open-source architecture.

**Made by the Sanskar**

## Status

Current development version: **0.1.0**. The repository is structured as a production project, with CI, tests, open-source documentation, continuation state, and platform bootstrap automation.

## Major features

- Voice and general sound recording with start, pause, resume, stop, cancel, and safe save.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and raw AAC export paths where the runtime codec stack supports them.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom presets.
- Bitrate, sample rate, mono/stereo, automatic gain, echo cancellation, and noise suppression settings where the platform honors them.
- Live amplitude waveform, clipping warning, recording timer, markers/bookmarks, and input-device-aware recording services.
- Searchable library with favorites, pinned items, tags, folders, trash/restore, rename, duplicate, import, export, share, sorting, and filtering.
- Integrated player with seek, jump controls, volume, speed, repeat, and silence-skip support where available.
- Non-destructive FFmpeg-backed editing: trim, split, merge, normalize, fades, silence removal, and format conversion.
- Light, dark, and system themes; responsive phone/tablet/desktop navigation.
- Offline-first local metadata and audio storage. No hidden upload, tracking, or analytics.

## Supported platforms

The application architecture targets Android, iOS, macOS, Windows, and Linux. Platform host projects are generated with the installed Flutter SDK by `tool/bootstrap_platforms.sh`, then SonicNest-specific permissions/capabilities are applied. This keeps host scaffolding aligned with the Flutter SDK used to build the app.

## Quick start

```bash
git clone https://github.com/sanskarIN/SonicNest.git
cd SonicNest
bash tool/bootstrap_platforms.sh
flutter pub get
flutter run
```

On Windows PowerShell, run Flutter's equivalent platform generation command shown in `docs/BUILDING.md`, then apply the documented overrides.

## Quality commands

```bash
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

CI additionally validates representative platform builds on supported GitHub-hosted runners.

## Architecture

SonicNest separates models, services, controllers, presentation, reusable widgets, and platform configuration. See `docs/ARCHITECTURE.md`.

## Privacy

Recordings remain on-device by default. SonicNest does not upload microphone data or recordings without an explicit user-initiated action. See `PRIVACY.md`.

## Codec notes

Native recording uses platform encoders through `record`. Formats requiring transcoding use an audio-focused FFmpeg package. Capabilities vary by platform/device, so SonicNest checks recorder support and uses fallback/error behavior instead of claiming unsupported combinations. See `docs/CODECS.md`.

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
