# Releasing SonicNest

SonicNest uses semantic versioning. A release must not be declared stable only because CI compiles the application. Recorder releases also require the hardware, accessibility, branding, lifecycle, storage, and distribution checks in `docs/QA_CHECKLIST.md`.

## 1. Prepare the source tree

1. Update the version in `pubspec.yaml`.
2. Update `CHANGELOG.md`, `RELEASE_NOTES.md`, `PROJECT_STATE.md`, and `what_changed.md`.
3. Run platform bootstrap using the Flutter SDK intended for release.
4. Resolve dependencies without introducing unreviewed lockfile or plugin changes.
5. Regenerate deterministic SonicNest native-brand source images and native icon/splash resources using `tool/apply_branding.sh` or `tool/apply_branding.ps1`.
6. Confirm that no secrets, signing files, local paths, certificates, provisioning profiles, or build outputs are staged.
7. Confirm generated branding PNG source outputs remain reproducible and are not accidentally committed as authoritative source files.

## 2. Required automated checks

Run on a Bash-capable validation host:

```bash
flutter pub get
dart tool/generate_brand_assets_v2.dart
dart format lib test tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test
```

For platform builds, apply branding after bootstrap/dependency resolution and before compiling:

```bash
bash tool/bootstrap_platforms.sh
flutter pub get
bash tool/apply_branding.sh
```

On Windows use:

```powershell
./tool/bootstrap_platforms.ps1
flutter pub get
./tool/apply_branding.ps1
```

Require the GitHub workflows for Android, Linux, Windows, macOS, and unsigned iOS build validation to pass for the release source revision. Android, Windows, macOS, and iOS builds must include the generated native SonicNest branding resources. Linux must at least generate the deterministic source artwork until a final distribution/package target supplies the desktop/package icon integration.

## 3. Required manual recorder checks

Complete `docs/QA_CHECKLIST.md` on representative physical hardware. At minimum verify:

- microphone permission accepted, denied, and revoked;
- start, pause, resume, stop, cancel, and save;
- repeated rapid lifecycle actions;
- screen lock and background behavior;
- interruption by calls/alarms/audio focus changes where applicable;
- wired, USB, Bluetooth, and built-in input routing where hardware exists;
- low-storage behavior;
- multiple output formats and conversion fallbacks;
- import, single/multi-file export, batch conversion, editing, Trash, restore, and permanent delete;
- destination permission loss and low-storage behavior during external copies;
- 30-minute and multi-hour recording soak tests;
- large-library and large-batch profiling;
- screen-reader and keyboard navigation checks.

Record evidence and device/OS versions. Do not check off an item without actually testing it.

## 4. Required native-brand visual review

Automated generation/compilation confirms resource validity, not final visual quality. Before a stable tag, inspect a release candidate on the intended OS surfaces.

Android:
- legacy launcher icon;
- adaptive launcher masks on multiple launcher shapes;
- themed/monochrome icon where supported;
- pre-Android-12 launch screen;
- Android 12+ splash behavior;
- light and dark launch-screen appearance.

iOS/macOS:
- iOS home-screen icon at normal and accessibility/display scales;
- iOS launch screen on representative device sizes and light/dark appearances;
- macOS Dock, Finder, Spotlight, and application icon sizes.

Windows:
- Explorer icon;
- taskbar icon;
- Start/search surfaces;
- shortcut and final installer/package surfaces once packaging is chosen.

Linux:
- choose a distribution/package target;
- integrate the generated SonicNest icon with its desktop entry/package metadata;
- inspect launcher/menu/task-switcher surfaces on the selected desktop environments.

Capture real screenshots from tested builds rather than fabricated or mock release screenshots.

## 5. Signing boundaries

Signing material is maintainer-owned and must never be committed.

- Android: use a private upload/release keystore outside the repository.
- iOS/macOS: use the maintainer's Apple certificates, provisioning profiles, and notarization credentials.
- Windows: code signing is optional for development builds but recommended for public distribution.
- Linux: package/sign according to the selected distribution channel.

CI intentionally validates unsigned/debug builds unless a secure release environment is explicitly configured.

## 6. Build release candidates

After platform bootstrap, dependency resolution, and `apply_branding`, typical Flutter commands are:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build windows --release
flutter build linux --release
flutter build macos --release
flutter build ios --release
```

Platform availability depends on the build host. iOS and macOS require macOS/Xcode. Windows builds require Windows. Signing identities/credentials must be injected only from the maintainer's secure release environment.

## 7. Final release review

Before tagging:

- verify Privacy, Security, Support, license, and third-party notices;
- verify the Buy Me a Coffee and project/contact links;
- verify generated native icon/splash resources visually on real release candidates;
- capture real screenshots from the tested release candidate;
- verify store/listing assets match the exact tested build;
- confirm no known critical/high-priority reproducible defects remain;
- confirm all manual release gates are documented;
- review generated package sizes and included permissions;
- confirm the release source revision matches the revision validated and signed.

## 8. Tag and publish

After all gates are satisfied, create an annotated semantic-version tag, publish release notes, and attach only verified distributable artifacts and checksums. Never publish a build that was not produced from the tagged source revision.
