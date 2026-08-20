# Building SonicNest

## Requirements

- Flutter stable with Dart 3.12 or newer.
- Platform toolchains required by Flutter for the platform being built.
- Python 3 for the generated-host patch step.
- Web builds: a Flutter SDK with Web enabled; Chrome is convenient for local `flutter run -d chrome`, while release output is a static bundle and does not require Chrome to be deployed.
- Linux capture/build validation: PulseAudio utilities, FFmpeg, GTK development packages, and JSON-GLib development files used by the selected audio backends.
- Debian package validation: `dpkg-deb`, `desktop-file-validate`, and `appstreamcli` on a Debian/Ubuntu-compatible build host.
- Installed-package GUI startup smoke testing: `xvfb-run` on a disposable Linux validation host.
- Windows portable packaging: Windows PowerShell/PowerShell 7 with the built-in archive, process, and Authenticode inspection commands used by `tool/build_windows_portable.ps1`, `tool/verify_windows_portable.ps1`, and `tool/smoke_test_windows_portable.ps1`.
- Android release-candidate signing-state validation: Android SDK build-tools (`aapt`, `apksigner`), Java `keytool`/`jarsigner`, `unzip`, and `sha256sum` as used by `tool/verify_android_nonproduction_candidate.sh`.

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

The bootstrap scripts generate Flutter host projects for **Android, iOS, macOS, Linux, Windows, and Web** with the application organization `io.github.sanskarin`, then apply SonicNest-specific platform adjustments. Re-run the appropriate bootstrap script after switching to a materially different Flutter SDK.

`tool/apply_branding.sh` and `tool/apply_branding.ps1` generate the raster source images from `tool/generate_brand_assets_v2.dart`, then apply launcher icons and splash resources across the generated native and Web hosts. Generated PNG source images are intentionally ignored by Git because they are reproducible from code. See `docs/BRANDING.md`.

## Manual platform generation

If you need to generate hosts without the helper scripts:

```powershell
flutter create . --project-name sonic_nest --org io.github.sanskarin --platforms=android,ios,macos,linux,windows,web --no-pub
flutter pub get
```

After generation, apply the Android files under `tool/platform_overrides/` and run:

```powershell
python tool/patch_generated_platforms.py
```

Then generate/apply cross-platform branding:

```bash
dart tool/generate_brand_assets_v2.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Shared application entry point

`lib/main.dart` is now the default entry point for all six supported targets. Conditional exports isolate the dependency graphs:

- Dart IO platforms load `lib/bootstrap/bootstrap_native.dart`.
- Dart Web platforms load `lib/bootstrap/bootstrap_web.dart` using `dart.library.js_interop`.

Native-only `dart:io`, FFmpeg, managed-filesystem, and media-session dependencies therefore do not enter the Web compilation graph. `flutter run` and `flutter build web` use the normal default entry point; no special `--target` is required.

## Verify Dart and Flutter code

```bash
dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test
```

The formatting command is a non-mutating cleanliness check, matching core CI. If it reports drift, run ordinary `dart format lib test tool/generate_brand_assets_v2.dart`, review the formatter output, commit it, and rerun validation.

The repository CI treats analyzer errors/warnings as failures while allowing informational style lints to remain non-fatal.

Focused reliability checks can be run while changing local-library persistence, recovery, batch conversion, browser WAV output, or audio import behavior:

```bash
flutter test test/recording_entry_test.dart test/metadata_store_test.dart
flutter test test/app_controller_persistence_test.dart test/app_controller_recovery_test.dart
flutter test test/storage_service_test.dart test/storage_service_non_file_test.dart
flutter test test/audio_import_service_test.dart test/batch_conversion_service_test.dart
flutter test test/wav_encoder_test.dart test/bootstrap_integrity_test.dart
```

The deterministic suites cover malformed field decoding, corrupt-document preservation, interrupted `.bak` recovery, a 3,000-entry filesystem round-trip, managed-path mutation guards, active/Trash orphan reconstruction, persistence rollback, import cleanup, entity-aware filename collisions, batch conversion failure/stop isolation, PCM16 WAV-container correctness, and six-target bootstrap/CI invariants. They do not replace real malformed-audio corpus testing, filesystem-failure simulation on target devices, browser microphone testing, long-duration workloads, or large-library UI/performance profiling.

See `docs/METADATA_INTEGRITY.md`, `docs/MANAGED_STORAGE_BOUNDARY.md`, `docs/RECOVERY_TESTING.md`, `docs/BATCH_CONVERSION.md`, and `docs/WEB_SUPPORT.md` for the invariants behind those tests.

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

Web:

```bash
flutter config --enable-web
bash tool/bootstrap_platforms.sh
flutter pub get
bash tool/apply_branding.sh
flutter build web --release
```

On Windows use the PowerShell bootstrap/branding helpers before `flutter build web --release`.

Only run native build targets supported by the host OS. The Web release output is generated under `build/web/`. Native signing, provisioning profiles, keystores, certificates, store credentials, Web hosting credentials, and DNS/TLS secrets must remain outside the repository.

## Web development and capability boundary

Run the browser build locally with:

```bash
flutter config --enable-web
flutter run -d chrome
```

The Web implementation provides microphone permission handling, input selection, PCM16 capture, pause/resume, amplitude metering, pure-Dart WAV packaging, in-session playback, and explicit share/download. Native FFmpeg editing and durable managed-filesystem library semantics are intentionally unavailable in the browser because the current native dependencies do not provide Web implementations.

A successful Web compile does not prove microphone permissions, capture quality, alternate-device behavior, share/download, installability, responsive UI, accessibility, or production HTTPS/cache behavior. See `docs/WEB_SUPPORT.md`.

## Android non-production release candidate

The hosted release-candidate workflow compiles release-mode APK/AAB files without maintainer production signing credentials. Generated Flutter Android host defaults currently sign these validation artifacts with the Android Debug certificate, so SonicNest verifies and labels them **non-production** instead of “unsigned.”

After building:

```bash
flutter build apk --release
flutter build appbundle --release
bash tool/verify_android_nonproduction_candidate.sh
```

The verifier checks package ID `io.github.sanskarin.sonic_nest`, application label `SonicNest`, APK/AAB archive integrity, the APK/AAB Android Debug certificate state, and writes `ANDROID_SIGNING_STATE.txt` with non-secret certificate/digest evidence. A pass does not make the artifact eligible for Google Play production. See `docs/ANDROID_DISTRIBUTION_POLICY.md` for Play App Signing/upload-key boundaries.

## Windows portable package

A versioned x64 portable ZIP is the initial repository-supported Windows distribution package. Build and validate it after producing the release-mode Windows bundle:

```powershell
./tool/apply_branding.ps1
flutter build windows --release
./tool/build_windows_portable.ps1 -Configuration release -ArtifactSuffix unsigned
./tool/verify_windows_portable.ps1
./tool/smoke_test_windows_portable.ps1 -StartupSeconds 8
```

The builder packages the complete Flutter runner directory, writes a SHA-256 checksum and package-info record, and leaves signing credentials entirely outside the repository. The verifier extracts the archive into an isolated temporary directory, checks the required executable/runtime/data layout, rejects common private/signing material, and verifies the sibling checksum when present. The bounded startup smoke separately extracts the ZIP, starts `sonic_nest.exe`, requires the process to remain alive for the configured interval, then terminates it and cleans the temporary extraction where possible.

Hosted CI intentionally uses the `unsigned` artifact label. The startup smoke is only packaging/startup evidence; it is not microphone, routing, accessibility, branding, or trust verification. For a final public candidate, the maintainer-owned Authenticode process must be applied to the final binaries before packaging/checksum publication, then the exact ZIP must pass:

```powershell
./tool/verify_windows_portable.ps1 -ArchivePath '<final-portable-zip>' -RequireSignature
./tool/smoke_test_windows_portable.ps1 -ArchivePath '<final-portable-zip>' -StartupSeconds 8
```

See `docs/WINDOWS_PACKAGING.md` and `docs/WINDOWS_SIGNING_POLICY.md` for package, channel, signing, and evidence boundaries.

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

## Web release-candidate package

The manual release-candidate workflow creates a static Web validation payload after `flutter build web --release`:

```text
sonicnest-web-release.tar.gz
RELEASE_CANDIDATE_WARNING.txt
SHA256SUMS.txt
```

The Web payload is uploaded as `sonicnest-web-release-candidate`, downloaded by the unified manifest job, and re-verified by `tool/build_release_candidate_manifest.py`. A missing or tampered Web payload fails the six-platform manifest contract. See `docs/RELEASE_CANDIDATE_MANIFEST.md`.

## CI coverage

- `.github/workflows/ci.yml`: deterministic brand image generation, non-mutating format gate, analyzer, unit tests, branded Android debug APK, Linux debug build, and branded Web release build through the default entry point.
- `.github/workflows/linux-package.yml`: Linux release bundle, Debian package construction, structural verification, checksum verification, package-manager installation, installed-files/metadata checks, virtual-display startup smoke, uninstall cleanup checks, and short-retention CI artifact.
- `.github/workflows/windows.yml`: branded Windows debug build plus branded release-mode portable ZIP construction, package verification, checksum/package-info output, bounded extracted-package startup smoke, explicit unsigned warning, and short-retention validation artifact.
- `.github/workflows/macos.yml`: branded macOS debug build and branded iOS no-codesign debug build.
- `.github/workflows/release-candidate.yml`: manually triggered release-mode validation artifacts across Android, Linux, Windows, macOS, no-codesign iOS, and Web; Android verifies package identity/debug-certificate non-production signing, Windows reuses portable build/verify/smoke helpers, Linux reuses the Debian package builder/verifier, Web packages a checksummed static bundle, and the unified manifest requires all six targets.
- `.github/workflows/repository-audit.yml`: repository invariants, permanent-workflow permission safety, required package/policy markers, and syntax parsing for all tracked top-level Bash/PowerShell helpers.

CI build/package/install/startup-smoke success confirms compilation and repository-controlled package behavior on GitHub-hosted runners. Microphone hardware, audio routing, lock-screen/background behavior, device interruptions, real icon/launch visual inspection, browser permission/device behavior, browser share/download, production hosting, long-duration recording, package upgrade behavior on representative maintained systems, accessibility, production signing, and store/publication approval still require target-device, representative-browser, or maintainer-secure-environment validation.
