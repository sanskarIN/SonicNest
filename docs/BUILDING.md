# Building SonicNest

## Requirements

- Flutter stable with Dart 3.12 or newer.
- Platform toolchains required by Flutter for the platform being built.
- Python 3 for the generated-host patch step.
- Linux capture/build validation: PulseAudio utilities, FFmpeg, GTK development packages, and JSON-GLib development files used by the selected audio backends.
- Debian package validation: `dpkg-deb`, `desktop-file-validate`, and `appstreamcli` on a Debian/Ubuntu-compatible build host.

## Bootstrap host projects

macOS/Linux/Git Bash:

```bash
bash tool/bootstrap_platforms.sh
flutter pub get
bash tool/apply_branding.sh
```

Windows PowerShell:

```powershell
./tool/bootstrap_platforms.ps1
flutter pub get
./tool/apply_branding.ps1
```

The bootstrap scripts generate Flutter host projects with the application organization `io.github.sanskarin`, then apply SonicNest-specific Android, Apple, Linux, and Windows adjustments. Re-run the appropriate bootstrap script after switching to a materially different Flutter SDK.

`tool/apply_branding.sh` and `tool/apply_branding.ps1` generate the raster source images from `tool/generate_brand_assets_v2.dart`, then apply launcher icons and native Android/iOS splash resources. Generated PNG source images are intentionally ignored by Git because they are reproducible from code. See `docs/BRANDING.md`.

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

Then generate/apply native branding:

```bash
dart tool/generate_brand_assets_v2.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Verify Dart and Flutter code

```bash
dart format lib test tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test
```

The repository CI treats analyzer errors/warnings as failures while allowing informational style lints to remain non-fatal. New source should still be formatted before commit.

## Platform builds

Android/Linux:

```bash
bash tool/apply_branding.sh
flutter build apk --debug
flutter build linux --debug
```

Windows:

```powershell
./tool/apply_branding.ps1
flutter build windows --debug
```

Apple targets on macOS:

```bash
bash tool/apply_branding.sh
flutter build macos --debug
flutter build ios --debug --no-codesign
```

Only run build targets supported by the host OS. Signing, provisioning profiles, keystores, certificates, and store credentials must remain outside the repository.

## Debian Linux package

Debian `.deb` is the initial repository-supported Linux installation package. Build and validate it after producing a Linux bundle:

```bash
dart tool/generate_brand_assets_v2.dart
flutter build linux --release
bash tool/build_linux_deb.sh release
bash tool/verify_linux_deb.sh
```

The package embeds the complete Flutter bundle under `/opt/sonicnest`, installs the deterministic SonicNest icon into the freedesktop hicolor icon hierarchy, installs a `.desktop` launcher and AppStream metadata, includes project licensing notices, and writes a SHA-256 checksum beside the `.deb` in `build/linux-package/`.

See `docs/LINUX_PACKAGING.md` for package layout, dependencies, CI behavior, installation testing, and release boundaries.

## CI coverage

- `.github/workflows/ci.yml`: deterministic brand image generation, analyzer, unit tests, branded Android debug APK, Linux debug build.
- `.github/workflows/linux-package.yml`: Linux release bundle, Debian package construction, desktop/AppStream/icon/package verification, checksum verification, and short-retention CI artifact.
- `.github/workflows/windows.yml`: branded Windows debug desktop build.
- `.github/workflows/macos.yml`: branded macOS debug build and branded iOS no-codesign debug build.
- `.github/workflows/release-candidate.yml`: manually triggered release-mode validation artifacts, including the structurally verified Linux `.deb`.

CI build success confirms compilation and structural packaging on GitHub-hosted runners; microphone hardware, audio routing, lock-screen/background behavior, device interruptions, real icon/launch visual inspection, long-duration recording, package installation behavior on representative real systems, and store/signing approval still require target-device validation.
