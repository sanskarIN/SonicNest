# Releasing SonicNest

SonicNest uses semantic versioning. A release must not be declared stable only because CI compiles the application. Recorder releases also require the hardware, browser, accessibility, branding, lifecycle, storage, packaging/hosting, and distribution checks in `docs/QA_CHECKLIST.md` and `docs/WEB_QA_CHECKLIST.md`.

Selected/defined initial public-channel strategy:

- **Android:** Google Play with Play App Signing and a separately protected maintainer upload key. See `docs/ANDROID_DISTRIBUTION_POLICY.md`.
- **iOS:** TestFlight/App Store with maintainer-owned Apple signing/provisioning. See `docs/APPLE_DISTRIBUTION_POLICY.md`.
- **macOS:** signed/notarized GitHub Releases. See `docs/APPLE_DISTRIBUTION_POLICY.md`.
- **Windows:** GitHub Releases with a versioned x64 portable ZIP containing the final Authenticode-verified binaries and a checksum generated after signing/package bytes are final. See `docs/WINDOWS_PACKAGING.md` and `docs/WINDOWS_SIGNING_POLICY.md`.
- **Linux:** GitHub Releases with the verified Debian `.deb` and its SHA-256 checksum. See `docs/LINUX_DISTRIBUTION_POLICY.md`.
- **Web:** reproducible static Flutter Web output served over production HTTPS. The repository defines build, checksum/provenance, privacy, and browser-QA requirements, while the final public hosting provider/domain remains a release decision. See `docs/WEB_SUPPORT.md` and `docs/WEB_QA_CHECKLIST.md`.

## In-app manual evidence ledger

For native candidate QA, use **About → Manual QA evidence** to record the tester-reported state of the source-controlled manual checks. When runtime/storage/recorder/settings context matters, first open **About → Diagnostics & QA** and choose **Open QA evidence with this snapshot** so the current privacy-safe diagnostic report travels with the exported manual evidence bundle.

The ledger stores only fixed check IDs, `notRun`/`passed`/`failed`/`blocked` status values, and timestamps. It has no free-form tester-note field and does not automatically upload evidence. The exact candidate source/artifact, target hardware/OS, signing state, and any external observations still need to be identified in the release evidence record. A manually selected `Passed` status never overrides the required hardware, accessibility, filesystem, signing, notarization, browser, hosting, store-console, or final approval gates.

Before accepting an exported JSON ledger into native release evidence, run `python3 tool/verify_manual_qa_evidence.py <evidence.json>`. For candidate-bound review, use the applicable `--expected-version`, `--require-diagnostics`, and freshness policy described in `docs/MANUAL_QA_REVIEW_TOOLING.md`. The verifier detects structural/catalog/privacy/summary inconsistencies; it does not prove that the tester performed the underlying check.

Web-specific manual evidence is currently maintained through `docs/WEB_QA_CHECKLIST.md` and the release evidence record rather than being inferred from the native in-app ledger.

## 1. Prepare the source tree

1. Update the version in `pubspec.yaml`.
2. Update `CHANGELOG.md`, `RELEASE_NOTES.md`, `PROJECT_STATE.md`, and `what_changed.md`.
3. Run platform bootstrap using the Flutter SDK intended for release; confirm all six generated hosts are available: Android, iOS, macOS, Linux, Windows, and Web.
4. Resolve dependencies without introducing unreviewed lockfile or plugin changes.
5. Regenerate deterministic SonicNest native/Web brand source images and icon/splash resources using `tool/apply_branding.sh` or `tool/apply_branding.ps1`.
6. Confirm that no secrets, signing files, local paths, certificates, provisioning profiles, service-account credentials, Web deployment credentials, or build outputs are staged.
7. Confirm generated branding PNG source outputs and generated platform host trees remain reproducible and are not accidentally committed as authoritative source files.
8. Confirm the Android package/signing policy in `docs/ANDROID_DISTRIBUTION_POLICY.md` matches the intended Play candidate.
9. Confirm the iOS/macOS signing/distribution policy in `docs/APPLE_DISTRIBUTION_POLICY.md` matches the intended Apple candidates.
10. For Linux, confirm the Debian package metadata under `packaging/linux/debian/` matches the release identity, launcher behavior, and AppStream information.
11. For Windows, confirm the portable package contract and public signing boundary in `docs/WINDOWS_PACKAGING.md` and `docs/WINDOWS_SIGNING_POLICY.md` match the intended candidate.
12. For Web, confirm `docs/WEB_SUPPORT.md` and `docs/WEB_QA_CHECKLIST.md` match the intended browser/hosting release scope and that production host/DNS/TLS/deployment credentials remain outside the repository.
13. Review `docs/STORE_LISTING.md` against the exact native release candidate before copying listing/privacy material into a distribution console; separately review Web-facing privacy/capability copy against the deployed browser candidate.

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

Require maintained GitHub validation for the exact source revision, including core formatting/analyzer/tests, Android and Linux builds, the Web release build, Linux Debian packaging, Windows build/package validation, and macOS/iOS no-codesign validation. Android, Windows, macOS, iOS, and Web build surfaces must include generated SonicNest branding resources.

The manual release-candidate workflow must additionally prove the repository-controlled release-mode packaging paths:

- Android: build APK/AAB, verify package ID and label, inspect signatures using `tool/verify_android_nonproduction_candidate.sh`, and explicitly classify hosted Android Debug-certificate artifacts as **NON-PRODUCTION**.
- Linux: build the release bundle and Debian package and run `tool/verify_linux_deb.sh`.
- Windows: build the release bundle, create the versioned portable ZIP using `tool/build_windows_portable.ps1`, verify it using `tool/verify_windows_portable.ps1`, and run the bounded extracted-package startup smoke using `tool/smoke_test_windows_portable.ps1`.
- macOS: compile/package the release-mode app as non-public signing/notarization evidence only.
- iOS: compile/package the release-mode app with `--no-codesign` as non-installable validation evidence only.
- Web: run `flutter build web --release`, archive the generated static site as `sonicnest-web-release.tar.gz`, and produce a matching `SHA256SUMS.txt` plus development-preview warning.

The unified candidate provenance job must download **all six** platform artifact sets and successfully build `RELEASE_CANDIDATE_MANIFEST.json` with `stableReleaseApproved: false` until stable gates are complete. A missing or checksum-mismatched Web payload must fail the same provenance contract as a native payload. See `docs/RELEASE_CANDIDATE_MANIFEST.md`.

The repository integrity audit must also pass, including Python tooling tests, tracked-text/source auditing, generated-host boundaries including `web/`, permanent-workflow read-only permission checks, required policy/document presence, package-script invariants, six-platform bootstrap/CI/release markers, and tracked top-level Bash/PowerShell helper parsing.

## 3. Required native recorder checks

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

Record evidence and device/OS versions. Export the corresponding manual-QA JSON where the in-app ledger is used, structurally verify it with `tool/verify_manual_qa_evidence.py`, and preserve the verified file with the candidate evidence. Do not check off an item without actually testing it; structural verification is not a substitute for the observation.

## 4. Required Web/browser checks

Complete `docs/WEB_QA_CHECKLIST.md` against the exact candidate bytes intended for deployment. At minimum verify:

- current representative Chromium, Firefox, and Safari/WebKit families where available;
- production-like HTTPS secure-context behavior;
- microphone allow/deny/revoke/retry behavior;
- default and alternate microphone enumeration/selection where exposed;
- Record/Pause/Resume/Stop/Cancel, amplitude, timing, repeated captures, and error recovery;
- mono/stereo and effective sample/channel behavior where supported;
- generated WAV integrity in SonicNest and an independent player;
- playback completion/replay/switching and delete-while-playing behavior;
- Web Share with files where supported plus download fallback where it is not;
- long/repeated capture memory behavior on desktop and lower-memory mobile browsers;
- responsive layout, browser zoom, keyboard focus, screen-reader basics, and light/dark/system themes;
- PWA/install behavior where the browser exposes it;
- production MIME types, cache/service-worker update behavior, security headers, rollback, and deployment secret hygiene;
- browser network inspection proving there is no automatic recording upload or hidden analytics.

The Web implementation intentionally keeps completed recordings in the current page session unless the user explicitly shares/downloads them. Do not claim native managed-library persistence, Trash/recovery, FFmpeg editing, or native media-session parity on Web while those browser implementations do not exist.

## 5. Required brand visual review

Automated generation/compilation confirms resource validity, not final visual quality. Before a stable tag, inspect the exact release candidate on intended OS/browser surfaces.

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

Web:
- verify favicon/app icon rendering on representative browser/OS combinations;
- verify startup background/splash transition in light/dark/system settings;
- inspect installed-PWA icon/launch treatment where supported;
- verify high-DPI and mobile home-screen icon treatment where applicable;
- verify a branding update does not remain indefinitely hidden behind stale browser/PWA cache state.

Capture real screenshots from tested builds rather than fabricated or mock release screenshots.

## 6. Signing, credentials, and hosting boundaries

Signing/deployment material is maintainer-owned and must never be committed.

- **Android:** production distribution uses Google Play. Use Play App Signing and a separately protected maintainer upload key. Hosted candidate APK/AAB output is verified as Android Debug-certificate **NON-PRODUCTION** evidence and must not be relabeled as a Play production candidate. See `docs/ANDROID_DISTRIBUTION_POLICY.md`.
- **iOS:** use maintainer-owned Apple certificates, provisioning, App Store Connect configuration, and TestFlight/App Store distribution. Hosted `--no-codesign` output is not installable App Store evidence.
- **macOS:** initial public distribution uses GitHub Releases only after Developer ID signing and notarization. Hosted macOS candidate output is not a signed/notarized public artifact. See `docs/APPLE_DISTRIBUTION_POLICY.md`.
- **Windows:** the initial public channel is the versioned x64 portable ZIP. Public stable Windows binaries must follow `docs/WINDOWS_SIGNING_POLICY.md`; package the final signed bytes, verify the packaged executable with `tool/verify_windows_portable.ps1 -RequireSignature`, run the bounded startup smoke, and generate the public ZIP checksum only after those bytes are final. Hosted CI remains unsigned.
- **Linux:** GitHub Releases is the initial channel for the verified Debian `.deb` plus checksum. SonicNest does not initially operate an APT repository, so APT repository-index signing is not applicable. Development-preview CI packages can remain unsigned and must not be represented as signed stable artifacts.
- **Web:** executable binary signing is not the distribution model for the static bundle. Stable Web publication requires exact-build checksum/provenance evidence plus reviewed HTTPS hosting, DNS/TLS, cache/update/security-header behavior, rollback, and protected deployment credentials. Host tokens, DNS credentials, TLS private keys, CI deployment secrets, or service-account material must remain outside this public repository/static bundle.

Any detached signatures, signing services, store credentials, certificates, keys, provisioning profiles, service-account JSON, passwords, deployment tokens, DNS credentials, or notarization credentials must remain outside this public repository.

## 7. Build release candidates

After platform bootstrap, dependency resolution, and branding generation, typical Flutter commands are:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build linux --release
flutter build web --release
```

On their required host operating systems also build:

```text
flutter build windows --release
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

For Web, preserve the exact deployable `build/web/` candidate and/or the release-candidate workflow's `sonicnest-web-release.tar.gz` plus SHA-256/provenance evidence. Do not silently rebuild different bytes between browser QA and production deployment without repeating candidate evidence.

Platform availability depends on the build host. iOS and macOS require macOS/Xcode. Windows builds require Windows. Debian package construction requires a compatible Linux host with `dpkg-deb`. Web release compilation is handled by Flutter Web tooling, while real microphone behavior and production hosting still require representative browsers and an HTTPS deployment environment.

The manual `.github/workflows/release-candidate.yml` workflow is configured to create release-mode **non-production validation artifacts** across Android, Linux, Windows, macOS, no-codesign iOS, and Web, followed by one six-platform provenance manifest. Those artifacts remain non-public candidates until all applicable manual and credential/hosting-dependent gates are complete.

## 8. Protected distribution and deployment steps

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

### Web / production HTTPS host

1. Freeze the exact source/version and exact `build/web/` bytes that completed automated and browser QA.
2. Select/configure the intended host/domain and protected deployment credentials outside the repository.
3. Deploy over HTTPS with reviewed MIME types, cache/service-worker update policy, and security headers compatible with microphone/audio functionality.
4. Verify the production URL on representative browsers, including microphone permission/capture/playback/share/download and responsive/accessibility checks applicable to the target scope.
5. Verify update propagation by deploying a controlled newer candidate and confirming clients do not remain permanently pinned to obsolete cached assets.
6. Verify rollback to a known-good bundle.
7. Inspect the production network/static bundle for accidental credentials, unexpected recording upload, or hidden analytics.
8. Record the deployed artifact checksum/provenance, host/domain, deployment timestamp/revision, browser/OS evidence, and reviewer in release evidence.

## 9. Final release review

Before tagging/publishing/deploying:

- verify Privacy, Security, Support, license, and third-party notices;
- verify the Buy Me a Coffee and project/contact links;
- verify generated native and Web/PWA icon/splash/startup resources visually on real release candidates;
- verify selected platform signing/distribution/hosting policies match the exact candidate;
- verify the Linux `.deb` real-system install/upgrade/uninstall evidence;
- verify the Windows portable ZIP real-system extraction/launch/recorder/accessibility/branding evidence and Authenticode verification;
- verify Android Play and Apple TestFlight/App Store evidence where those channels are being shipped;
- verify macOS signing/notarization evidence where macOS is being shipped;
- verify Web browser QA and production HTTPS/cache/security/rollback evidence where Web is being shipped;
- capture real screenshots from the tested release candidate;
- review `docs/STORE_LISTING.md` against the exact tested native builds and current distribution-console requirements;
- structurally verify every accepted native manual-QA JSON export with `tool/verify_manual_qa_evidence.py` and the candidate-specific version/diagnostics/freshness policy;
- review completed `docs/WEB_QA_CHECKLIST.md` evidence for the exact deployed Web candidate;
- confirm no known critical/high-priority reproducible defects remain;
- confirm all manual release gates are documented and backed by reviewed evidence rather than ledger/checklist status alone;
- review generated native package and Web bundle sizes and included permissions/content;
- confirm every published/deployed artifact comes from the exact tested/tagged source revision and every signing/hosting claim matches the exact distributed bytes.

## 10. Tag, publish, and deploy

After all gates are satisfied, create an annotated semantic-version tag, publish release notes, and attach/upload/deploy only verified distributable artifacts and checksums/provenance records.

For Android, use the protected Google Play flow in `docs/ANDROID_DISTRIBUTION_POLICY.md`. Do not use the hosted Android Debug-certificate candidate as a production upload.

For iOS, use the TestFlight/App Store flow in `docs/APPLE_DISTRIBUTION_POLICY.md`. For macOS, publish only the signed/notarized candidate through the selected GitHub Releases channel.

For Linux, publish the verified `.deb` and its SHA-256 checksum on the corresponding GitHub Release and identify the tested Debian/Ubuntu-family environments in the release notes. Do not claim APT repository support unless a separately maintained and signed repository is actually deployed.

For Windows, publish the final Authenticode-verified versioned x64 portable ZIP and its SHA-256 checksum on the corresponding GitHub Release. Identify the Windows versions/architectures actually tested and the non-secret signing identity information recorded in release evidence. Do not claim Microsoft Store, MSIX, MSI, installer, or managed-update support unless that separate channel has actually been built and validated.

For Web, deploy only the exact static bundle that completed the required automated provenance and real-browser/hosting review. Identify the tested browser/OS scope and production domain/host evidence in the release notes. Do not claim native managed-library/FFmpeg feature parity or offline persistence beyond what the tested browser implementation actually provides.

Never publish or deploy a build that was not produced from the tagged source revision.
