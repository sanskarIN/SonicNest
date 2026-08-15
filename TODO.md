# SonicNest Remaining Work

This file intentionally contains only work that is still incomplete, requires physical-device evidence, or depends on maintainer-owned release credentials. Completed implementation belongs in `what_changed.md` and `PROJECT_STATE.md`.

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

## Reliability and stress validation

Repository automation now provides deterministic baselines for malformed metadata decoding, non-finite/negative numeric normalization, bounded waveform recovery, duplicate ID/path isolation, structural metadata corruption preservation, interrupted `.bak` recovery, corrupt-store reset, a 3,000-entry metadata save/load round-trip, managed-path mutation guards, persistence rollback for library mutations, supported-file discovery, orphaned managed-audio reconstruction, isolated import copy/probe/waveform failures, entity-safe managed/external filename collisions, and deterministic batch-conversion failure/stop behavior. The checks below intentionally remain incomplete because they require real filesystems, media corpora, devices, UI/performance profiling, abrupt process/device interruption, or sustained workloads rather than synthetic regression coverage alone.

- [ ] Low-storage recording and export failure tests.
- [ ] Disk/file permission failure recovery tests.
- [ ] Abrupt process/device interruption while metadata and managed audio are being updated, followed by recovery verification.
- [ ] Verify recovered-orphan behavior with real playable, partially written, and damaged managed audio on every maintained platform.
- [ ] Repeated start/stop stress test.
- [ ] Repeated pause/resume stress test.
- [ ] 30-minute recordings on representative platforms.
- [ ] Multi-hour recording soak tests where practical.
- [ ] Large-library profiling with thousands of metadata entries.
- [ ] Very long audio playback/editor behavior without excessive memory growth.
- [ ] Malformed/corrupt import corpus testing.
- [ ] Large batch-conversion profiling with mixed formats and durations.
- [ ] Batch conversion under low-storage conditions.
- [ ] Verify per-file batch failure isolation using deliberately malformed or unsupported media.

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
- [ ] Large text/scaling review on small phones and desktop windows.
- [ ] Keyboard-only end-to-end desktop review.
- [ ] Reduced-motion behavior review.
- [ ] Batch conversion screen with large text and keyboard-only interaction.

## Branding and release assets

- [x] Implement deterministic native launcher-icon source generation from SonicNest-controlled mark geometry.
- [x] Implement reproducible Android/iOS native splash resource generation.
- [x] Integrate launcher-icon generation for Android, iOS, macOS, and Windows build workflows.
- [x] Select Debian `.deb` as the initial Linux installation format and integrate the deterministic SonicNest icon with its desktop entry and AppStream package metadata.
- [ ] Visually review generated Android launcher icons across legacy/adaptive/themed masks on real devices.
- [ ] Visually review generated iOS and macOS icons at small/large OS sizes on real Apple hardware.
- [ ] Visually review generated Windows icon in Explorer, taskbar, Start, shortcuts, and final package/installer surfaces.
- [ ] Install the generated Linux `.deb` on representative Debian/Ubuntu-family systems and visually review launcher/menu/task-switcher icon surfaces.
- [ ] Verify native launch/splash assets in signed/release Android and iOS configurations, including dark mode.
- [ ] Capture real screenshots from tested builds; do not use fabricated screenshots.
- [ ] Prepare store/listing copy and privacy declarations for each selected distribution channel.

## Signing and distribution

- [ ] Configure private Android upload/release signing outside the repository.
- [ ] Configure Apple certificates/provisioning/notarization outside the repository.
- [ ] Decide and configure Windows signing for public distribution.
- [x] Select Debian `.deb` as the initial repository-supported Linux package target.
- [x] Decide the public Linux distribution channel and repository/package signing policy. Initial channel: GitHub Releases with verified `.deb` + SHA-256 checksum; no initial APT repository. See `docs/LINUX_DISTRIBUTION_POLICY.md`.
- [ ] Produce signed release candidates where the selected distribution channel requires signing.
- [ ] Complete the release checklist in `docs/RELEASING.md`.
- [ ] Tag `v1.0.0` only after all required stable-release gates are complete.

## External batch export validation

- [ ] Verify direct original-file multi-export on each supported platform.
- [ ] Verify mixed-success direct export when one selected source disappears before copying.
- [ ] Verify directory-picker availability/behavior on Android, iOS, macOS, Windows, and Linux.
- [ ] Verify collision-safe numbering in real user folders.
- [ ] Verify destination disappearance or permission revocation after selection.
- [ ] Verify low-storage behavior during external copies.
- [ ] Verify Stop after current file during long conversions.
- [ ] Verify closing/navigating away from Batch Convert during processing.
- [ ] Profile very large batches and mixed-format batches.

## Localization

- [x] Migrate primary Flutter presentation strings, including Batch Convert and desktop recording actions, into the localization layer.
- [x] Decide whether backend diagnostic/error details should be translated or intentionally retained as technical text before adding non-English releases. See `docs/LOCALIZATION_POLICY.md`.
- [ ] Add additional locales only with translation review, text-expansion testing, and translation QA.
