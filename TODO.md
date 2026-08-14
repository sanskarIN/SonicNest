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

- [ ] Low-storage recording and export failure tests.
- [ ] Disk/file permission failure recovery tests.
- [ ] Repeated start/stop stress test.
- [ ] Repeated pause/resume stress test.
- [ ] 30-minute recordings on representative platforms.
- [ ] Multi-hour recording soak tests where practical.
- [ ] Large-library profiling with thousands of metadata entries.
- [ ] Very long audio playback/editor behavior without excessive memory growth.
- [ ] Malformed/corrupt import corpus testing.

## Accessibility and UX validation

- [ ] TalkBack audit.
- [ ] VoiceOver audit on iOS.
- [ ] VoiceOver audit on macOS.
- [ ] Narrator audit on Windows.
- [ ] Linux desktop accessibility-tool audit.
- [ ] Large text/scaling review on small phones and desktop windows.
- [ ] Keyboard-only end-to-end desktop review.
- [ ] Reduced-motion behavior review.

## Localization

- [ ] Finish migrating remaining hard-coded presentation strings into the localization layer before adding non-English translations.
- [ ] Add translation QA once additional languages are introduced.

## Branding and release assets

- [ ] Capture real screenshots from tested builds; do not use fabricated screenshots.
- [ ] Generate/review final native app-icon sets from the approved SonicNest mark on each platform.
- [ ] Verify native launch/splash assets in signed/release configurations.
- [ ] Prepare store listing copy and privacy declarations for each selected distribution channel.

## Signing and distribution

- [ ] Configure private Android upload/release signing outside the repository.
- [ ] Configure Apple certificates/provisioning/notarization outside the repository.
- [ ] Decide and configure Windows signing for public distribution.
- [ ] Decide Linux packaging/distribution targets.
- [ ] Produce signed release candidates.
- [ ] Complete the release checklist in `docs/RELEASING.md`.
- [ ] Tag `v1.0.0` only after all required stable-release gates are complete.
