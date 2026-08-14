# What Changed — SonicNest

## 2026-08-14 — v0.1.0 integrated foundation

### New features
- Selected Flutter/Dart for the cross-platform application and UI layer.
- Added `record` microphone capture with start, pause, resume, stop, cancel, amplitude monitoring, effective configuration callbacks, and input-device services.
- Added runtime encoder support checks. Unsupported direct encoders fall back to a compatible intermediate capture encoder and post-recording conversion instead of silently pretending support.
- Added an audio processing layer for MP3, OGG/Vorbis, AAC and editor/export conversion plus trim, split, merge, normalize, fade, and silence removal.
- Added local recordings library metadata persistence, favorites, pins, tags, folders, Trash/restore, permanent deletion, rename, duplicate, import, export, and sharing.
- Added playback with seek, jump, speed, volume, repeat, bookmarks, and silence-skip where the active backend supports it.
- Added responsive Material 3 UI, light/dark/system themes, recorder waveform, settings, About/support links, GitHub contacts, business/support email, and Buy Me a Coffee integration.
- Added original SonicNest vector logo/mark assets and the exact developer credit `Made by the Sanskar`.
- Added Android foreground recording service overrides and reproducible Flutter platform-host bootstrap tooling for Android, iOS, macOS, Windows, and Linux.
- Added Apache-2.0 project documentation, privacy/security/support/contribution docs, codec/build/architecture/QA docs, issue templates, PR template, and GitHub Actions.

### Important implementation files
- `lib/main.dart`, `lib/app.dart`
- `lib/controllers/app_controller.dart`
- `lib/services/recorder_service.dart`
- `lib/services/player_service.dart`
- `lib/services/audio_processor.dart`
- `lib/services/storage_service.dart`
- `lib/services/metadata_store.dart`
- `lib/screens/recorder_screen.dart`
- `lib/screens/library_screen.dart`
- `lib/screens/player_screen.dart`
- `lib/screens/editor_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/screens/about_screen.dart`
- `tool/bootstrap_platforms.sh`
- `.github/workflows/ci.yml`

### Bug-prevention and fixes
- Added atomic-style metadata replacement with backup recovery behavior.
- Added cross-platform-safe filename sanitization, Windows reserved-name protection, and unique-file allocation.
- Added recorder transition guards for repeated start/pause/resume/stop actions.
- Editor operations always create new files rather than overwriting the original.
- Added explicit encoder capability checks and conversion fallback.
- Fixed GitHub profile constant naming used by the About screen.
- Fixed reserved filename behavior so source and tests agree.

### Tests added
- Safe filename sanitization and extension handling.
- Recording metadata serialization/copy behavior.
- Recording settings serialization, bounds, presets, and transcoding decisions.

### Validation status
- The local ChatGPT execution container does not contain Flutter/Dart, so no local Flutter build/test output has been fabricated.
- GitHub Actions `Flutter CI` run #1 was triggered from commit `ee38db47cd0c728e54332b1dbb6cdcfd0bc6ea06` and was `in_progress` when this file was written.
- The workflow runs formatting, static analysis, unit tests, Android debug build, and Linux debug build.
- Physical-device, interruption, low-storage, audio-device switching, and multi-hour soak tests still require actual target hardware.

### Git history created in this development pass
- `chore: initialize Flutter project configuration`
- `feat: add recording models and shared core utilities`
- `feat: add safe local storage and metadata persistence`
- `feat: add audio processing playback and external actions`
- `feat: implement recording lifecycle and application controller`
- `feat: add responsive application shell`
- `feat: add reusable recording library tile`
- `feat: add original SonicNest vector mark`
- `feat: add efficient waveform visualization`
- `feat: build home dashboard and quick recorder entry`
- `feat: implement recorder screen with live waveform and markers`
- `feat: build searchable recording library with trash and metadata`
- `fix: expose canonical GitHub profile URL constant`
- `feat: add waveform player with bookmarks and speed controls`
- `feat: add recording playback and accessibility settings`
- `feat: add About privacy support and developer links`
- `feat: add non-destructive audio editor workflow`
- `fix: normalize reserved filenames consistently`
- `test: cover safe recording filename handling`
- `test: cover recording metadata persistence`
- `test: cover recording quality settings and codec modes`
- `chore: add cross-platform host bootstrap and Android background recording integration`
- `fix: fall back safely when requested recorder codec is unsupported`
- `docs: add architecture build privacy security and project documentation`
- `feat: add original SonicNest branding assets`
- `chore: add GitHub project automation and templates`

### Next work
1. Read the newest GitHub Actions job results and logs.
2. Fix all analyzer/test/build failures and rerun validation.
3. Validate microphone permissions, background/interruption recovery, format outputs, and long recordings on target devices.
4. Continue the remaining roadmap items before any v1.0.0 completion claim.
