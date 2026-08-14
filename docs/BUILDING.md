# Building SonicNest

## Requirements

- Flutter stable with Dart 3.12 or newer.
- Platform toolchains required by Flutter for the platform being built.
- Python 3 for the generated-host patch step.
- Linux capture/build validation: PulseAudio utilities, FFmpeg, GTK development packages, and JSON-GLib development files used by the selected audio backends.
- Debian package validation: `dpkg-deb`, `desktop-file-validate`, and `appstreamcli` on a Debian/Ubuntu-compatible build host.
- Installed-package GUI startup smoke testing: `xvfb-run` on a disposable Linux validation host.

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

Focused reliability checks can be run while changing local-library persistence or audio import behavior:

```bash
flutter test test/recording_entry_test.dart test/metadata_store_test.dart
flutter test test/audio_import_service_test.dart
```

The metadata suite covers malformed field decoding, corrupt-document preservation, interrupted `.bak` recovery, and a 3,000-entry filesystem round-trip. The import suite covers successful managed imports and cleanup after copy/probe/waveform failures. These deterministic tests do not replace real malformed-audio corpus testing, filesystem-failure simulation on target devices, or large-library UI/performance profiling.

See `docs/METADATA_INTEGRITY.md` for the persistence/recovery invariants behind those tests.

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

Debian `.deb` is the initial repository-supported Linux installation package. Build and structurally validate it after producing a Linux bundle:

```bash
dart tool/generate_brand_assets_v2.dart
flutter build linux --release
bash tool/build_linux_deb.sh release
bash tool/verify_linux_deb.sh
```

The package embeds the complete Flutter bundle under `/opt/sonicnest`, installs the deterministic SonicNest icon into the freedesktop hicolor icon hierarchy, installs a `.desktop` launcher and AppStream metadata, includes project licensing notices, and writes a SHA-256 checksum beside the `.deb` in `build/linux-package/`.

On a disposable Debian/Ubuntu-compatible validation host with `xvfb-run` installed, the package can also be installed and startup-smoke-tested through the same path used by Linux Package CI:

```bash
PACKAGE="$(find build/linux-package -maxdepth 1 -type f -name 'sonicnest_*.deb' -print -quit)"
sudo apt-get install -y "./$PACKAGE"
bash tool/smoke_test_installed_linux_deb.sh
sudo apt-get remove -y sonicnest
```

The smoke script checks the installed package state and files, re-validates desktop/AppStream metadata, then starts the packaged application under a bounded virtual X display. It is intentionally not a microphone, real-desktop, accessibility, upgrade, long-duration, or release-approval test.

See `docs/LINUX_PACKAGING.md` for package layout, dependencies, CI behavior, installation testing, evidence levels, and release boundaries.

## CI coverage

- `.github/workflows/ci.yml`: deterministic brand image generation, analyzer, unit tests, branded Android debug APK, Linux debug build.
- `.github/workflows/linux-package.yml`: Linux release bundle, Debian package construction, structural verification, checksum verification, package-manager installation, installed-files/metadata checks, virtual-display startup smoke, uninstall cleanup checks, and short-retention CI artifact.
- `.github/workflows/windows.yml`: branded Windows debug desktop build.
- `.github/workflows/macos.yml`: branded macOS debug build and branded iOS no-codesign debug build.
- `.github/workflows/release-candidate.yml`: manually triggered release-mode validation artifacts, including the structurally verified Linux `.deb`.

CI build/install-smoke success confirms compilation and repository-controlled package behavior on GitHub-hosted runners; microphone hardware, audio routing, lock-screen/background behavior, device interruptions, real icon/launch visual inspection, long-duration recording, package upgrade behavior on representative maintained systems, accessibility, and store/signing approval still require target-device validation.
