# Building SonicNest

## Requirements

- Flutter stable with Dart 3.12 or newer.
- Platform toolchains required by Flutter for the platform being built.
- Linux capture: PulseAudio utilities and FFmpeg packages are required by the selected Linux audio backends.
- Linux FFmpeg builds may additionally need JSON-GLib development files.

## Bootstrap host projects

```bash
bash tool/bootstrap_platforms.sh
flutter pub get
```

The bootstrap script runs Flutter's platform generator and then applies SonicNest-specific permissions/capabilities. Re-run it after switching to a materially different Flutter SDK.

## Windows bootstrap

If Bash is unavailable, generate the hosts manually from PowerShell:

```powershell
flutter create . --project-name sonic_nest --org in.sanskar --platforms=android,ios,macos,linux,windows
flutter pub get
```

Then apply the Android override files and run `python tool/patch_generated_platforms.py`.

## Verify

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Platform builds

```bash
flutter build apk --debug
flutter build ios --no-codesign
flutter build macos
flutter build windows
flutter build linux
```

Only run build targets supported by the host OS. Signing/provisioning is intentionally left to the repository maintainer and must not be committed.
