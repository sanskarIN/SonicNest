# Building SonicNest

## Requirements

- Flutter stable with Dart 3.12 or newer.
- Platform toolchains required by Flutter for the platform being built.
- Python 3 for the generated-host patch step.
- Linux capture/build validation: PulseAudio utilities, FFmpeg, GTK development packages, and JSON-GLib development files used by the selected audio backends.

## Bootstrap host projects

macOS/Linux/Git Bash:

```bash
bash tool/bootstrap_platforms.sh
flutter pub get
```

Windows PowerShell:

```powershell
./tool/bootstrap_platforms.ps1
flutter pub get
```

The bootstrap scripts generate Flutter host projects with the application organization `io.github.sanskarin`, then apply SonicNest-specific Android, Apple, Linux, and Windows adjustments. Re-run the appropriate bootstrap script after switching to a materially different Flutter SDK.

## Manual platform generation

If you need to generate hosts without the helper scripts:

```powershell
flutter create . --project-name sonic_nest --org io.github.sanskarin --platforms=android,ios,macos,linux,windows --no-pub
flutter pub get
```

After generation, apply the Android files under `tool/platform_overrides/` and run:

```powershell
python tool/patch_generated_platforms.py
```

## Verify Dart and Flutter code

```bash
dart format lib test
flutter analyze --no-fatal-infos
flutter test
```

The repository CI treats analyzer errors/warnings as failures while allowing informational style lints to remain non-fatal. New source should still be formatted before commit.

## Platform builds

Android/Linux:

```bash
flutter build apk --debug
flutter build linux --debug
```

Windows:

```powershell
flutter build windows --debug
```

Apple targets on macOS:

```bash
flutter build macos --debug
flutter build ios --debug --no-codesign
```

Only run build targets supported by the host OS. Signing, provisioning profiles, keystores, certificates, and store credentials must remain outside the repository.

## CI coverage

- `.github/workflows/ci.yml`: analyzer, unit tests, Android debug APK, Linux debug build.
- `.github/workflows/windows.yml`: Windows debug desktop build.
- `.github/workflows/macos.yml`: macOS debug build and iOS no-codesign debug build.

CI build success confirms compilation on GitHub-hosted runners; microphone hardware, audio routing, lock-screen/background behavior, device interruptions, long-duration recording, and store signing still require target-device validation.
