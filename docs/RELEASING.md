# Releasing SonicNest

SonicNest uses semantic versioning. A release must not be declared stable only because CI compiles the application. Recorder releases also require the hardware and lifecycle checks in `docs/QA_CHECKLIST.md`.

## 1. Prepare the source tree

1. Update the version in `pubspec.yaml`.
2. Update `CHANGELOG.md`, `RELEASE_NOTES.md`, `PROJECT_STATE.md`, and `what_changed.md`.
3. Run platform bootstrap using the Flutter SDK intended for release.
4. Resolve dependencies without introducing unreviewed lockfile or plugin changes.
5. Confirm that no secrets, signing files, local paths, certificates, provisioning profiles, or build outputs are staged.

## 2. Required automated checks

Run:

```bash
flutter pub get
dart format lib test
flutter analyze --no-fatal-infos
flutter test
```

Then require the GitHub workflows for Android, Linux, Windows, macOS, and unsigned iOS build validation to pass for the release commit.

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
- import, export, editing, Trash, restore, and permanent delete;
- 30-minute and multi-hour recording soak tests;
- screen-reader and keyboard navigation checks.

Record evidence and device/OS versions. Do not check off an item without actually testing it.

## 4. Signing boundaries

Signing material is maintainer-owned and must never be committed.

- Android: use a private upload/release keystore outside the repository.
- iOS/macOS: use the maintainer's Apple certificates, provisioning profiles, and notarization credentials.
- Windows: code signing is optional for development builds but recommended for public distribution.
- Linux: package/sign according to the selected distribution channel.

CI intentionally validates unsigned/debug builds unless a secure release environment is explicitly configured.

## 5. Build release candidates

Typical Flutter commands after platform bootstrap are:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build windows --release
flutter build linux --release
flutter build macos --release
flutter build ios --release
```

Platform availability depends on the build host. iOS and macOS require macOS/Xcode. Windows builds require Windows.

## 6. Final release review

Before tagging:

- verify Privacy, Security, Support, license, and third-party notices;
- verify the Buy Me a Coffee and project/contact links;
- capture real screenshots from the tested release candidate;
- confirm no known critical/high-priority reproducible defects remain;
- confirm all manual release gates are documented;
- review generated package sizes and included permissions.

## 7. Tag and publish

After all gates are satisfied, create an annotated semantic-version tag, publish release notes, and attach only verified distributable artifacts and checksums. Never publish a build that was not produced from the tagged source revision.
