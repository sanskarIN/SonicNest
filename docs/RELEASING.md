# Releasing SonicNest

SonicNest uses semantic versioning. A release must not be declared stable only because CI compiles the application. Recorder releases also require the hardware, accessibility, branding, lifecycle, storage, packaging, and distribution checks in `docs/QA_CHECKLIST.md`.

Selected initial public channels:

- **Android:** Google Play with Play App Signing and a separately protected maintainer upload key. See `docs/ANDROID_DISTRIBUTION_POLICY.md`.
- **iOS:** TestFlight/App Store with maintainer-owned Apple signing/provisioning. See `docs/APPLE_DISTRIBUTION_POLICY.md`.
- **macOS:** signed/notarized GitHub Releases. See `docs/APPLE_DISTRIBUTION_POLICY.md`.
- **Windows:** GitHub Releases with a versioned x64 portable ZIP containing the final Authenticode-verified binaries and a checksum generated after signing/package bytes are final. See `docs/WINDOWS_PACKAGING.md` and `docs/WINDOWS_SIGNING_POLICY.md`.
- **Linux:** GitHub Releases with the verified Debian `.deb` and its SHA-256 checksum. See `docs/LINUX_DISTRIBUTION_POLICY.md`.

## In-app manual evidence ledger

For candidate QA, use **About → Manual QA evidence** to record the tester-reported state of the source-controlled manual checks. When runtime/storage/recorder/settings context matters, first open **About → Diagnostics & QA** and choose **Open QA evidence with this snapshot** so the current privacy-safe diagnostic report travels with the exported manual evidence bundle.

The ledger stores only fixed check IDs, `notRun`/`passed`/`failed`/`blocked` status values, and timestamps. It has no free-form tester-note field and does not automatically upload evidence. The exact candidate source/artifact, target hardware/OS, signing state, and any external observations still need to be identified in the release evidence record. A manually selected `Passed` status never overrides the required hardware, accessibility, filesystem, signing, notarization, store-console, or final approval gates.

## 1. Prepare the source tree

1. Update the version in `pubspec.yaml`.
2. Update `CHANGELOG.md`, `RELEASE_NOTES.md`, `PROJECT_STATE.md`, and `what_changed.md`.
3. Run platform bootstrap using the Flutter SDK intended for release.
4. Resolve dependencies without introducing unreviewed lockfile or plugin changes.
5. Regenerate deterministic SonicNest native-brand source images and native icon/splash resources using `tool/apply_branding.sh` or `tool/apply_branding.ps1`.
6. Confirm that no secrets, signing files, local paths, certificates, provisioning profiles, service-account credentials, or build outputs are staged.
7. Confirm generated branding PNG source outputs remain reproducible and are not accidentally committed as authoritative source files.
8. Confirm the Android package/signing policy in `docs/ANDROID_DISTRIBUTION_POLICY.md` matches the intended Play candidate.
9. Confirm the iOS/macOS signing/distribution policy in `docs/APPLE_DISTRIBUTION_POLICY.md` matches the intended Apple candidates.
10. For Linux, confirm the Debian package metadata under `packaging/linux/debian/` matches the release identity, launcher behavior, and AppStream information.
11. For Windows, confirm the portable package contract and public signing boundary in `docs/WINDOWS_PACKAGING.md` and `docs/WINDOWS_SIGNING_POLICY.md` match the intended candidate.
12. Review `docs/STORE_LISTING.md` against the exact release candidate before copying listing/privacy material into a distribution console.

## 2. Required automated checks

Run on a Bash-capable validation host:

```bash
flutter pub get
dart tool/generate_brand_assets_v2.dart
dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test
```

The formatting command is intentionally non-mutating. If it reports drift, run ordinary `dart format` locally, review and commit the canonical formatter output, and rerun the preflight rather than allowing release validation to rewrite source silently.

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

Require the maintained GitHub workflows for Android, Linux, Linux Debian packaging, Windows, macOS, and iOS no-codesign validation to pass for the release source revision. Android, Windows, macOS, and iOS builds must include generated SonicNest branding resources.

The manual release-candidate workflow must additionally prove the repository-controlled release-mode packaging paths:

- Android: build APK/AAB, verify package ID and label, inspect signatures using `tool/verify_android_nonproduction_candidate.sh`, and explicitly classify hosted Android Debug-certificate artifacts as **NON-PRODUCTION**.
- Linux: build the release bundle and Debian package and run `tool/verify_linux_deb.sh`.
- Windows: build the release bundle, create the versioned portable ZIP using `tool/build_windows_portable.ps1`, verify it using `tool/verify_windows_portable.ps1`, and run the bounded extracted-package startup smoke using `tool/smoke_test_windows_portable.ps1`.
- macOS: compile/package the release-mode app as non-public signing/notarization evidence only.
- iOS: compile/package the release-mode app with `--no-codesign` as non-installable validation evidence only.

The repository integrity audit must also pass, including all tracked top-level Bash and PowerShell helper parsing, permanent-workflow read-only permission checks, required policy/document presence, package-script invariants, and release-candidate safety markers.

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
- extract the complete versioned portable ZIP rather than launching a copied standalone executable;
- verify Explorer icon behavior for the packaged executable;
- verify taskbar and Start/search surfaces reached through normal Windows interaction;
- verify the extracted portable folder contains the complete runtime/data bundle;
- confirm the portable channel does not claim installer-created shortcuts, registry entries, services, file associations, or machine-wide state that it does not create;
- verify final Authenticode status on the exact public candidate.

Linux:
- install the repository-generated Debian `.deb` on representative Debian/Ubuntu-family systems;
- verify the generated SonicNest icon appears through the installed desktop entry and AppStream metadata;
- inspect launcher/menu/task-switcher surfaces on the tested desktop environments;
- verify package install, upgrade, launch, and uninstall behavior before publishing the package.

Capture real screenshots from tested builds rather than fabricated or mock release screenshots.

## 5. Signing boundaries

Signing material is maintainer-owned and must never be committed.

- **Android:** production distribution uses Google Play. Use Play App Signing and a separately protected maintainer upload key. Hosted candidate APK/AAB output is verified as Android Debug-certificate **NON-PRODUCTION** evidence and must not be relabeled as a Play production candidate. See `docs/ANDROID_DISTRIBUTION_POLICY.md`.
- **iOS:** use maintainer-owned Apple certificates, provisioning, App Store Connect configuration, and TestFlight/App Store distribution. Hosted `--no-codesign` output is not installable App Store evidence.
- **macOS:** initial public distribution uses GitHub Releases only after Developer ID signing and notarization. Hosted macOS candidate output is not a signed/notarized public artifact. See `docs/APPLE_DISTRIBUTION_POLICY.md`.
- **Windows:** the initial public channel is the versioned x64 portable ZIP. Public stable Windows binaries must follow `docs/WINDOWS_SIGNING_POLICY.md`; package the final signed bytes, verify the packaged executable with `tool/verify_windows_portable.ps1 -RequireSignature`, run the bounded startup smoke, and generate the public ZIP checksum only after those bytes are final. Hosted CI remains unsigned.
- **Linux:** GitHub Releases is the initial channel for the verified Debian `.deb` plus checksum. SonicNest does not initially operate an APT repository, so APT repository-index signing is not applicable. Development-preview CI packages can remain unsigned and must not be represented as signed stable artifacts.

Any detached signatures, signing services, store credentials, certificates, keys, provisioning profiles, service-account JSON, passwords, or notarization credentials must remain outside this public repository.

## 6. Build release candidates

After platform bootstrap, dependency resolution, and branding generation, typical Flutter commands are:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build windows --release
flutter build linux --release
flutter build macos --release
flutter build ios --release
```

For hosted Android engineering evidence, verify the generated non-production signing state:

```bash
bash tool/verify_android_nonproduction_candidate.sh
```

This command is not the protected Google Play signing flow. The final Play upload candidate must be produced in the maintainer's protected environment using the configured upload key/Play App Signing process.

For the selected Linux package target:

```bash
bash tool/build_linux_deb.sh release
bash tool/verify_linux_deb.sh
```

For the selected Windows portable package target, on Windows PowerShell:

```powershell
./tool/build_windows_portable.ps1 -Configuration release -ArtifactSuffix unsigned
./tool/verify_windows_portable.ps1
./tool/smoke_test_windows_portable.ps1 -StartupSeconds 8
```

The Windows `unsigned` suffix is for hosted/development candidate evidence only. After maintainer-owned signing is actually performed for a final public candidate, package the signed bundle with an appropriate label and require signature verification plus startup smoke on the exact resulting archive:

```powershell
./tool/verify_windows_portable.ps1 -ArchivePath '<final-portable-zip>' -RequireSignature
./tool/smoke_test_windows_portable.ps1 -ArchivePath '<final-portable-zip>' -StartupSeconds 8
```

Platform availability depends on the build host. iOS and macOS require macOS/Xcode. Windows builds require Windows. Debian package construction requires a compatible Linux host with `dpkg-deb`. Signing identities/credentials must be injected only from the maintainer's secure release environment.

The manual `.github/workflows/release-candidate.yml` workflow creates release-mode **non-production validation artifacts** across Android, Linux, Windows, macOS, and no-codesign iOS. Those artifacts remain non-public candidates until all manual and credential-dependent gates are complete.

## 7. Protected distribution steps

### Android / Google Play

1. Enroll/configure Play App Signing and protect the upload key outside the repository.
2. Build the exact upload AAB from the frozen source/version in the secure environment.
3. Record the upload-certificate fingerprint and AAB checksum in release evidence.
4. Upload to the intended Play testing track first where applicable.
5. Validate the Play-distributed candidate on representative physical devices.
6. Complete current Play Data safety, permission/foreground-service, listing, and policy review.
7. Promote only after the stable checklist is complete.

### iOS / TestFlight and App Store

1. Configure the maintainer Apple Team, signing certificate, provisioning, App Store Connect ownership, and protected credentials.
2. Archive the exact candidate with the intended signing/provisioning state.
3. Verify effective entitlements, bundle ID, version/build, and microphone/background declarations.
4. Upload to TestFlight/App Store Connect.
5. Validate the distributed TestFlight candidate on physical devices.
6. Complete current App Privacy/listing review and submit only after stable gates are complete.

### macOS / GitHub Releases

1. Build the exact release candidate on a supported macOS/Xcode host.
2. Apply the intended Developer ID signing to the app and nested code.
3. Verify signing and entitlements.
4. Notarize with protected credentials and verify/staple as appropriate to the chosen archive flow.
5. Package the exact signed/notarized bytes, generate the final SHA-256, and test the downloaded artifact on representative macOS systems.

### Windows / GitHub Releases

1. Apply the selected Authenticode process to final release binaries.
2. Build the portable ZIP from those final signed bytes.
3. Run `tool/verify_windows_portable.ps1 -RequireSignature` and the bounded startup smoke on the exact ZIP.
4. Generate the public SHA-256 only after signing/package bytes are final.
5. Validate microphone/routing/accessibility/branding/cleanup on representative Windows systems.

### Linux / GitHub Releases

1. Build and verify the exact Debian `.deb` from the tagged source.
2. Validate fresh install, launch, microphone/audio-stack behavior, upgrade where applicable, desktop integration, accessibility, and uninstall on representative Debian/Ubuntu-family systems.
3. Publish the exact verified `.deb` and matching SHA-256 only after candidate approval.

## 8. Final release review

Before tagging/publishing:

- verify Privacy, Security, Support, license, and third-party notices;
- verify the Buy Me a Coffee and project/contact links;
- verify generated native icon/splash resources visually on real release candidates;
- verify selected platform signing/distribution policies match the exact candidate;
- verify the Linux `.deb` real-system install/upgrade/uninstall evidence;
- verify the Windows portable ZIP real-system extraction/launch/recorder/accessibility/branding evidence and Authenticode verification;
- verify Android Play and Apple TestFlight/App Store evidence where those channels are being shipped;
- verify macOS signing/notarization evidence where macOS is being shipped;
- capture real screenshots from the tested release candidate;
- review `docs/STORE_LISTING.md` against the exact tested build and current distribution-console requirements;
- confirm no known critical/high-priority reproducible defects remain;
- confirm all manual release gates are documented;
- review generated package sizes and included permissions;
- confirm every published artifact comes from the exact tested/tagged source revision and every signing claim matches the exact distributed bytes.

## 9. Tag and publish

After all gates are satisfied, create an annotated semantic-version tag, publish release notes, and attach/upload only verified distributable artifacts and checksums.

For Android, use the protected Google Play flow in `docs/ANDROID_DISTRIBUTION_POLICY.md`. Do not use the hosted Android Debug-certificate candidate as a production upload.

For iOS, use the TestFlight/App Store flow in `docs/APPLE_DISTRIBUTION_POLICY.md`. For macOS, publish only the signed/notarized candidate through the selected GitHub Releases channel.

For Linux, publish the verified `.deb` and its SHA-256 checksum on the corresponding GitHub Release and identify the tested Debian/Ubuntu-family environments in the release notes. Do not claim APT repository support unless a separately maintained and signed repository is actually deployed.

For Windows, publish the final Authenticode-verified versioned x64 portable ZIP and its SHA-256 checksum on the corresponding GitHub Release. Identify the Windows versions/architectures actually tested and the non-secret signing identity information recorded in `docs/RELEASE_EVIDENCE_TEMPLATE.md`. Do not claim Microsoft Store, MSIX, MSI, installer, or managed-update support unless that separate channel has actually been built and validated.

Never publish a build that was not produced from the tagged source revision.
