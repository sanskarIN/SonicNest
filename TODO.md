# SonicNest Remaining Work

This file intentionally contains only work that is still incomplete, requires physical-device/browser evidence, depends on maintainer-owned release credentials/hosting, or is a verified repository-hygiene gap. Completed implementation belongs in `what_changed.md`, `PROJECT_STATE.md`, and the final repository audit.

## Repository hygiene

- [x] Keep the canonical Gumroad storefront (`https://ramsandesh.gumroad.com`) highlighted across the shared app shell, About/startup surfaces, README/support/public docs, and protect the integration with repository regression coverage.
- [x] Commit the Dart formatter output for the CI Flutter/Dart toolchain. Historical core CI run `31870224720` exposed formatting drift; canonical stable-toolchain formatter output is now committed in `22c1d46e077625d6e1964d56716700727d1800dc`.
- [x] After the tracked Dart tree is formatter-clean, change CI formatting from a mutating preparation step to a non-mutating enforcement gate. Core CI now uses `dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart` via `704b0f60aae8f179f4f41875c336d2052b45391e`.
- [x] Audit both `.yml` and `.yaml` workflow files and reject permanent workflow write scopes including `permissions: write-all`; strengthened audit run `31874506476` passed on `64c121fa0e5c81531a3710b1d67b88fb3dfc93db`.
- [x] Keep the exact historical hosted release-candidate evidence source-controlled and audit-required in `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md`.
- [x] Compile Python release helpers and run repository-owned release-tool regressions in the permanent Repository Integrity Audit. Historical run `31876149473` passed all **10/10** Python tests plus repository, Bash, and PowerShell checks for its exact five-platform source revision.
- [x] Add an offline structural verifier for exported manual-QA JSON so release review can detect malformed evidence, catalog drift, inconsistent summaries, privacy-contract regressions, version mismatch, and optional staleness without claiming the underlying physical/manual tests were performed.
- [x] Remove stale/temporary write-enabled formatter/ledger workflows and lock the exact maintained workflow allowlist plus permanent read-only permission boundary with regression coverage.
- [x] Replace unrestricted internal cleanup with intent-specific managed recording/Trash, temporary, and recorder-capture deletion boundaries; remove the obsolete `StorageService.deleteIfExists()` helper after all callers migrate.
- [x] Reject fractional persisted values for integer-only recording settings instead of silently truncating them.
- [x] Refuse recognizable unsupported future settings-snapshot schema versions so an older build cannot silently reinterpret and later overwrite a newer settings document.
- [x] Complete the public open-source maintenance surface with CODEOWNERS, structured issue routing, optional funding links, weekly Dart/Flutter and GitHub Actions dependency-update proposals, maintainer documentation, and permanent regression coverage.
- [x] Publish `docs/FINAL_REPOSITORY_AUDIT_2026-08-18.md` and keep repository-complete work distinct from still-open physical/accessibility/signing/store/stable-release evidence.
- [x] Keep the dependency/version stack summarized in `PROJECT_STATE.md` synchronized with `pubspec.yaml` using `tool/verify_project_state_dependencies.py`, focused regression coverage, documentation, and a permanent read-only Repository Integrity Audit step.
- [x] Add Web as the sixth generated Flutter target and reject committed generated `web/` host scaffolding through `tool/repository_audit.py`.
- [x] Protect Web bootstrap, browser entry point, WAV encoder, branding, core CI, release-candidate packaging, six-platform provenance, documentation, and QA surfaces with `tool/tests/test_web_platform_contract.py` and repository-required-file invariants.

## Repository-owned release automation

Historical five-platform items remain checked only for their exact historical source revisions. The current six-platform implementation adds Web and therefore requires fresh hosted evidence.

- [x] Historical five-platform release-candidate matrix run `31873121457` on `048870ec8dc26a16e2451310460d3e03c9084dc7` passed Source preflight plus Android, Linux, Windows, macOS, and iOS release-mode jobs.
- [x] Verify Android hosted release APK/AAB package identity and explicitly classify the generated Android Debug certificate as **NON-PRODUCTION** before artifact upload.
- [x] Produce checksummed Android release-mode non-production APK/AAB evidence without storing production signing material in the repository.
- [x] Produce and verify the Linux release bundle and Debian `.deb` in the release-candidate workflow.
- [x] Produce, structurally verify, and bounded-startup-smoke the versioned Windows x64 portable ZIP in both permanent Windows CI and the release-candidate workflow.
- [x] Produce macOS release-mode unsigned and iOS release-mode no-codesign validation archives.
- [x] Record exact inner artifact SHA-256 values and workflow artifact digests for the historical hosted candidate in `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md`.
- [x] Historical five-platform `tool/build_release_candidate_manifest.py` behavior was validated against all five native platform checksum records and recorded `stableReleaseApproved: false`.
- [x] Historical five-platform provenance run `31876035202` on source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c` passed preflight, Android, Linux, Windows, macOS, iOS, and the final provenance job. Historical manifest JSON SHA-256: `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`; artifact digest: `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`.
- [x] Add a Web release-candidate job that builds `flutter build web --release`, archives `sonicnest-web-release.tar.gz`, writes a development-preview warning and SHA-256 record, and uploads `sonicnest-web-release-candidate`.
- [x] Extend `tool/build_release_candidate_manifest.py` so Web is mandatory as the sixth platform with static-bundle signing classification and checksum verification.
- [x] Add Web manifest regression coverage including tampered-browser-payload rejection and workflow-integration markers.
- [x] Extend the core CI workflow with a branded Web release build through the normal shared `lib/main.dart` entry point.
- [ ] Obtain a fresh successful core CI run for the current six-platform source revision, including formatting, analyzer, complete Flutter tests, Android/Linux builds, and Web release build.
- [ ] Obtain a fresh successful Repository Integrity Audit run for the current six-platform source revision, including Python compilation, Web platform contract tests, release-manifest tests, dependency-state verification, and shell/PowerShell parsing.
- [ ] Run the current manual Release Candidate Validation workflow and obtain successful Android, Linux, Windows, macOS, iOS, Web, and unified six-platform provenance jobs from one exact source revision.
- [ ] Record the resulting Web archive SHA-256, unified six-platform manifest SHA-256, workflow artifact digest, exact source SHA, run ID, and run attempt in a new current evidence document without rewriting the 2026-08-15 historical record.

Repository-only implementation for the six Flutter targets is now represented in source, tooling, CI configuration, release-candidate configuration, regression tests, and documentation. The unchecked items above are intentionally still open because no fresh hosted result for the current post-Web revision has been observed through the available repository connector in this work session.

SonicNest includes the user-initiated **Diagnostics & QA** report described in `docs/DIAGNOSTICS_AND_QA.md`. Use a fresh privacy-safe report as supporting evidence for relevant native manual tests below. The report intentionally excludes recording content, recording titles, file paths, notes, tags, bookmarks, smart-naming text, and input-device names, and it does **not** close any physical-device, accessibility, filesystem, signing, browser, hosting, or distribution gate by itself.

SonicNest also includes **About → Manual QA evidence**, documented in `docs/MANUAL_QA_EVIDENCE.md`. The local ledger mirrors native manual evidence categories and records only fixed check IDs, `Not run`/`Passed`/`Failed`/`Blocked` status values, and timestamps; it has no free-form tester-note field. Use it to make real-device/system testing reproducible and exportable. JSON exports can be reviewed offline with `tool/verify_manual_qa_evidence.py`; structural verification is supporting evidence only. Browser-specific evidence is tracked separately in `docs/WEB_QA_CHECKLIST.md`.

## Hardware and lifecycle validation

- [ ] Android microphone permission allow/deny/revoke tests on physical devices.
- [ ] iOS microphone permission allow/deny/revoke tests on physical devices.
- [ ] macOS microphone permission and entitlement verification on physical hardware.
- [ ] Windows microphone capture/routing verification.
- [ ] Linux microphone capture/routing verification across at least one PulseAudio/PipeWire environment.
- [ ] Built-in, wired-headset, USB, Bluetooth, and external-interface input switching where supported.
- [ ] Incoming-call/alarm/audio-focus interruption tests.
- [ ] Background recording and device-lock tests.
- [ ] Android foreground-service OEM/device variation tests.
- [ ] iOS background-recording policy/lifecycle tests.
- [ ] Headphone/Bluetooth disconnect and reconnect tests during playback and recording.

## Web/browser validation

Use `docs/WEB_QA_CHECKLIST.md` for the detailed browser evidence contract.

- [ ] Test the exact Web candidate on representative current Chromium-family desktop and Android browsers.
- [ ] Test the exact Web candidate on representative current Firefox desktop/mobile scope where supported.
- [ ] Test the exact Web candidate on Safari desktop and iOS/iPadOS WebKit where available.
- [ ] Verify first-run microphone allow/deny, permission revocation, settings-based recovery, and no permission request merely from loading the page.
- [ ] Verify browser-default and alternate input-device enumeration/selection where exposed.
- [ ] Verify mono/stereo requests, effective sample/channel configuration, automatic gain, echo cancellation, and noise suppression without corrupt output.
- [ ] Verify Record/Pause/Resume/Stop/Cancel, amplitude meter, timer behavior, repeated captures, and recorder-error recovery.
- [ ] Verify generated WAV files in SonicNest and at least one independent external player.
- [ ] Verify browser native share where supported and download fallback where native share-with-files is unavailable.
- [ ] Verify multiple recordings and long captures for reasonable memory behavior, especially on a lower-memory mobile browser.
- [ ] Verify responsive layout, 200% zoom, keyboard focus, screen-reader basics, light/dark/system themes, and generated Web/PWA branding.
- [ ] Verify PWA/installability behavior where the browser/OS exposes installation.
- [ ] Validate production HTTPS hosting, MIME types, cache/update behavior, security headers, rollback, and deployment without embedded secrets.
- [ ] Confirm browser network inspection shows no automatic recording upload or hidden analytics.

## Reliability and stress validation

Repository automation provides deterministic baselines for malformed metadata/settings decoding, non-finite/negative/fractional numeric normalization, bounded waveform recovery, duplicate ID/path isolation, structural metadata corruption preservation, future-schema refusal, interrupted `.bak` recovery, corrupt-store reset, a 3,000-entry metadata save/load round-trip, managed-path mutation/cleanup guards, persistence rollback for library mutations, supported-file discovery, orphaned managed-audio reconstruction, isolated import copy/probe/waveform failures, entity-safe managed/external filename collisions, deterministic batch-conversion failure/stop behavior, pure-Dart WAV container output, Linux package install/startup smoke, and Windows portable-package structure/startup smoke. The checks below intentionally remain incomplete because they require real filesystems, media corpora, devices, browsers, UI/performance profiling, abrupt process/device interruption, or sustained workloads rather than synthetic/hosted regression coverage alone.

- [ ] Low-storage recording and export failure tests.
- [ ] Disk/file permission failure recovery tests.
- [ ] Abrupt process/device interruption while metadata and managed audio are being updated, followed by recovery verification.
- [ ] Verify recovered-orphan behavior with real playable, partially written, and damaged managed audio on every maintained native platform.
- [ ] Repeated start/stop stress test.
- [ ] Repeated pause/resume stress test.
- [ ] 30-minute recordings on representative native platforms.
- [ ] Multi-hour recording soak tests where practical.
- [ ] Large-library profiling with thousands of metadata entries.
- [ ] Very long audio playback/editor behavior without excessive memory growth.
- [ ] Malformed/corrupt import corpus testing.
- [ ] Large batch-conversion profiling with mixed formats and durations.
- [ ] Batch conversion under low-storage conditions.
- [ ] Verify per-file batch failure isolation using deliberately malformed or unsupported media.
- [ ] Long Web capture and repeated Web session recording memory profiling.

## Desktop interaction validation

- [ ] Verify secondary/right-click recording actions on Windows.
- [ ] Verify secondary/right-click recording actions on macOS.
- [ ] Verify secondary/right-click recording actions on Linux.
- [ ] Confirm secondary-click does not interfere with primary tap/double-click, keyboard focus, or touch long-press behavior.
- [ ] Evaluate whether a cursor-anchored platform-native context menu materially improves usability over the implemented action surface before adding more native menu code.

## Accessibility and UX validation

- [ ] TalkBack audit.
- [ ] VoiceOver audit on iOS.
- [ ] VoiceOver audit on macOS.
- [ ] Narrator audit on Windows.
- [ ] Linux desktop accessibility-tool audit.
- [ ] Web screen-reader/keyboard audit on representative Chromium, Firefox, and Safari families.
- [ ] Large text/scaling review on small phones, desktop windows, and browser zoom/text scaling.
- [ ] Keyboard-only end-to-end desktop review.
- [ ] Reduced-motion behavior review.
- [ ] Batch conversion screen with large text and keyboard-only interaction.
- [ ] Browser recorder controls and in-session recording rows expose understandable labels and visible focus.

## Branding and release assets

- [x] Implement deterministic cross-platform launcher-icon source generation from SonicNest-controlled mark geometry.
- [x] Implement reproducible Android/iOS/Web splash resource generation.
- [x] Integrate launcher-icon generation for Android, iOS, macOS, Windows, and Web build workflows.
- [x] Select Debian `.deb` as the initial Linux installation format and integrate the deterministic SonicNest icon with its desktop entry and AppStream package metadata.
- [x] Select a versioned x64 portable ZIP as the initial repository-supported Windows package format and add deterministic package build/verification plus hosted unsigned validation artifacts. See `docs/WINDOWS_PACKAGING.md`.
- [x] Add a bounded hosted Windows portable startup smoke after extraction. This is packaging/startup evidence only and does not close real microphone/routing/accessibility/branding gates.
- [ ] Visually review generated Android launcher icons across legacy/adaptive/themed masks on real devices.
- [ ] Visually review generated iOS and macOS icons at small/large OS sizes on real Apple hardware.
- [ ] Visually review generated Windows icon in Explorer, taskbar, Start, shortcuts, and extracted portable-package surfaces.
- [ ] Install the generated Linux `.deb` on representative Debian/Ubuntu-family systems and visually review launcher/menu/task-switcher icon surfaces.
- [ ] Verify native launch/splash assets in signed/release Android and iOS configurations, including dark mode.
- [ ] Visually review Web favicon/app icon, startup background, installed-PWA icon, high-DPI rendering, and cache refresh after a brand-resource change.
- [ ] Capture real screenshots from tested native and Web builds; do not use fabricated screenshots.
- [x] Prepare source-controlled store/listing copy and privacy declarations for the selected native distribution channels plus dedicated Web support/privacy guidance. Final store consoles and production hosting remain release-candidate review work.

## Signing, hosting, and distribution

- [x] Decide Android signing/distribution policy: Google Play is the initial public Android channel, using Play App Signing with a separate maintainer-controlled upload key. See `docs/ANDROID_DISTRIBUTION_POLICY.md`.
- [ ] Provision/configure the actual Android Play Console/App Signing/upload-key credentials outside the repository and produce the protected signed upload candidate.
- [x] Decide Apple distribution policy: iOS uses TestFlight/App Store; macOS initially uses signed/notarized GitHub Releases. See `docs/APPLE_DISTRIBUTION_POLICY.md`.
- [ ] Configure actual Apple certificates/provisioning/App Store Connect/notarization credentials in the maintainer's protected release environment.
- [x] Decide Windows public signing policy: stable public Windows distributables should use maintainer-controlled Authenticode signing; unsigned CI/development artifacts remain clearly labeled. See `docs/WINDOWS_SIGNING_POLICY.md`.
- [x] Decide the initial Windows package format and public channel: versioned x64 portable ZIP through GitHub Releases, built from the complete Flutter release bundle. See `docs/WINDOWS_PACKAGING.md`.
- [ ] Provision/configure the actual Windows signing certificate or secure signing service and apply it to the final public portable package in a protected release environment outside the repository.
- [x] Select Debian `.deb` as the initial repository-supported Linux package target.
- [x] Decide the public Linux distribution channel and repository/package signing policy. Initial channel: GitHub Releases with verified `.deb` + SHA-256 checksum; no initial APT repository. See `docs/LINUX_DISTRIBUTION_POLICY.md`.
- [x] Define the repository-side Web build, checksum/provenance, privacy, capability, and QA boundaries in `docs/WEB_SUPPORT.md`, `docs/WEB_QA_CHECKLIST.md`, and `docs/RELEASE_CANDIDATE_MANIFEST.md`.
- [ ] Select and review the production Web hosting provider/domain/channel for the stable release.
- [ ] Configure production DNS/TLS/deployment credentials outside the repository and verify no credentials are embedded in `build/web/`.
- [ ] Review production Web cache/service-worker/security-header/rollback behavior against the exact final browser candidate.
- [ ] Produce signed native release candidates where the selected distribution channel requires signing.
- [ ] Complete the release checklist in `docs/RELEASING.md` including Web evidence.
- [ ] Tag `v2.18.12` only after all required stable-release gates are complete.

## External batch export validation

These items apply to native managed-filesystem targets. Web uses explicit share/download instead of the native external-directory export model.

- [ ] Verify direct original-file multi-export on each supported native platform.
- [ ] Verify mixed-success direct export when one selected source disappears before copying.
- [ ] Verify directory-picker availability/behavior on Android, iOS, macOS, Windows, and Linux.
- [ ] Verify collision-safe numbering in real user folders.
- [ ] Verify destination disappearance or permission revocation after selection.
- [ ] Verify low-storage behavior during external copies.
- [ ] Verify Stop after current file during long conversions.
- [ ] Verify closing/navigating away from Batch Convert during processing.
- [ ] Profile very large batches and mixed-format batches.

## Localization

- [x] Migrate primary native Flutter presentation strings, including Batch Convert and desktop recording actions, into the localization layer.
- [x] Decide whether backend diagnostic/error details should be translated or intentionally retained as technical text before adding non-English releases. See `docs/LOCALIZATION_POLICY.md`.
- [ ] Extend the Web recorder surface into the localization catalog before claiming non-English Web releases.
- [ ] Add additional locales only with translation review, text-expansion testing, and translation QA on native and Web targets.
