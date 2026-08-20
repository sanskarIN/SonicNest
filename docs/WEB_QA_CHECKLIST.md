# SonicNest Web QA Checklist

This checklist covers the manual evidence that cannot be proven by `flutter build web --release`, unit tests, or checksum/provenance validation.

Do not mark the Web target publicly release-ready until the exact candidate has been exercised on representative current browsers and the production hosting configuration has been reviewed.

## Automated repository gates

For the exact candidate revision:

- [ ] `dart format --output=none --set-exit-if-changed lib test tool/generate_brand_assets_v2.dart`
- [ ] `flutter analyze --no-fatal-infos`
- [ ] `flutter test`
- [ ] `flutter build web --release`
- [ ] `test/wav_encoder_test.dart` passes.
- [ ] `test/bootstrap_integrity_test.dart` passes.
- [ ] Repository Integrity Audit passes.
- [ ] Manual Release Candidate Validation Web job succeeds.
- [ ] `sonicnest-web-release.tar.gz` is produced.
- [ ] Web `SHA256SUMS.txt` verifies the exact archive.
- [ ] Unified `RELEASE_CANDIDATE_MANIFEST.json` contains the Web platform entry and `stableReleaseApproved: false` until all remaining gates are completed.

A checked automated item proves only its own source/build/artifact invariant. It does not prove browser microphone or hosting behavior.

## Browser families

Exercise the exact candidate on representative maintained versions where available:

- [ ] Chromium-family desktop browser on Windows.
- [ ] Chromium-family desktop browser on macOS or Linux.
- [ ] Chromium-family mobile browser on Android.
- [ ] Firefox desktop.
- [ ] Firefox mobile where supported by the release scope.
- [ ] Safari desktop on macOS.
- [ ] Safari/WebKit mobile on iOS/iPadOS.

Record exact browser/OS versions in external release evidence. Do not hard-code a historical browser version into the product as a permanent compatibility guarantee.

## Secure-context and startup

- [ ] Production candidate is served over HTTPS.
- [ ] HTTP is redirected to HTTPS where applicable.
- [ ] First load renders the SonicNest branded startup/application surface without console-fatal errors.
- [ ] Refresh loads successfully at the deployed route/base path.
- [ ] Direct navigation to the deployed application URL works.
- [ ] Browser back/forward behavior does not leave capture in an unsafe state.
- [ ] Reload while idle is clean.
- [ ] Reload during active capture produces browser-appropriate interruption behavior without claiming the recording was saved.

## Microphone permission

- [ ] First-run permission prompt is triggered only by an explicit recording/user action where browser policy requires it.
- [ ] Allow permission starts capture successfully.
- [ ] Deny permission produces a readable recoverable message.
- [ ] Permission previously denied can be retried after browser/site settings are changed.
- [ ] Permission revoked after a prior successful capture is handled safely.
- [ ] No recording/library success state is shown when permission is unavailable.
- [ ] Microphone permission is not requested merely by loading the page.

## Input devices

- [ ] Browser default microphone works.
- [ ] Input-device list appears after permission where the browser exposes labels/devices.
- [ ] Alternate built-in/external microphone can be selected where supported.
- [ ] Selected device is used for the next recording where the browser honors selection.
- [ ] Device unplug/removal before capture is handled safely.
- [ ] Device removal during capture produces a recoverable stop/error path rather than false success.
- [ ] Refresh-device action does not interrupt an active capture.
- [ ] Device selection is disabled while capture is active.

## Recording lifecycle

- [ ] Record starts once per user action.
- [ ] Rapid repeated Record taps do not create duplicate active recorders.
- [ ] Pause stops elapsed-time progression and audio capture as expected by the browser backend.
- [ ] Resume continues the same recording.
- [ ] Stop creates one finished in-session WAV recording.
- [ ] Cancel discards the unfinished in-memory capture.
- [ ] Stop after pause works.
- [ ] Repeated start/stop sessions work without a page refresh.
- [ ] Recorder failure returns the UI to a usable state.
- [ ] No finished recording is inserted when no audio bytes were captured.

## Audio constraints and channels

Where supported by the browser/hardware combination:

- [ ] Mono request records a valid WAV.
- [ ] Stereo request records a valid WAV.
- [ ] Automatic-gain request does not break capture.
- [ ] Echo-cancellation request does not break capture.
- [ ] Noise-suppression request does not break capture.
- [ ] Browser-adjusted effective sample rate/channel count still produces a valid WAV header.
- [ ] A browser that ignores an optional constraint still records or fails clearly rather than corrupting output.

## Amplitude and timing

- [ ] Live amplitude meter responds to microphone input.
- [ ] Meter remains bounded and does not display NaN/infinite values.
- [ ] Quiet input approaches the lower meter range.
- [ ] Timer advances while actively recording.
- [ ] Timer does not advance while paused.
- [ ] Timer resets for a new capture.
- [ ] Display remains usable during a long recording.

## WAV integrity

For recordings produced on each representative browser:

- [ ] SonicNest can play the finished in-memory WAV.
- [ ] Downloaded/shared WAV opens in at least one independent audio player.
- [ ] WAV duration is reasonably consistent with the captured session.
- [ ] Mono/stereo channel metadata matches the effective capture configuration.
- [ ] No obvious header corruption exists after repeated recordings.
- [ ] Long-capture output remains playable.

## Playback

- [ ] Play starts the selected recording.
- [ ] Pause works.
- [ ] Replaying the same recording works.
- [ ] Switching to a different recording works.
- [ ] Playback completion returns the row/UI to a non-playing state.
- [ ] Deleting the currently selected/playing in-session item stops playback safely.
- [ ] Audio output route follows normal browser/OS behavior.

## Share and download

- [ ] Browser native share succeeds where Web Share with files is supported.
- [ ] Download fallback succeeds where native share is unavailable.
- [ ] Generated filename is safe and recognizable.
- [ ] Downloaded file MIME/type association is appropriate for WAV.
- [ ] User cancellation of share/download does not corrupt in-session state.
- [ ] Repeated downloads do not modify the in-memory source recording.

## Session-memory boundary

- [ ] UI clearly explains that browser recordings are retained only for the current page session.
- [ ] Refreshing/closing the page does not claim that an unsaved browser recording is durably stored.
- [ ] No automatic upload occurs.
- [ ] No hidden analytics/network recording transfer occurs.
- [ ] Deleting an in-session item removes it from the current session list.
- [ ] Memory behavior is reviewed with multiple medium/large recordings.
- [ ] Long recording memory pressure is tested on a representative lower-memory mobile browser.

## Responsive UI

- [ ] Narrow mobile portrait layout has no clipped controls.
- [ ] Mobile landscape remains usable.
- [ ] Tablet width remains usable.
- [ ] Desktop narrow window remains usable.
- [ ] Desktop wide window respects the content-width design.
- [ ] Long microphone labels truncate without breaking layout.
- [ ] Recording rows remain usable with long generated metadata strings.
- [ ] 200% browser zoom remains usable on desktop.

## Accessibility

- [ ] Keyboard focus order is logical on desktop browsers.
- [ ] Record/Pause/Resume/Stop/Cancel controls have understandable accessible labels.
- [ ] Download/delete buttons expose understandable labels.
- [ ] Focus is visible.
- [ ] Text remains readable in light and dark themes.
- [ ] Screen-reader smoke test covers recorder controls and at least one finished recording.
- [ ] Browser zoom/text scaling does not hide essential actions.
- [ ] Reduced-motion/browser accessibility settings do not prevent core operation.

## Theme and visual branding

- [ ] Light theme renders correctly.
- [ ] Dark theme renders correctly.
- [ ] System theme follows browser/OS preference.
- [ ] Generated favicon/app icon is recognizable.
- [ ] Startup/splash transition does not flash an obviously incorrect brand background.
- [ ] Installed PWA icon/launch treatment is visually checked where browser install is supported.
- [ ] High-DPI display rendering is checked.

## PWA/installability

Where the browser exposes installation:

- [ ] Web manifest is accepted by browser tooling.
- [ ] Install prompt/menu path works.
- [ ] Installed application opens the expected SonicNest route.
- [ ] Installed icon/name are correct.
- [ ] Updating the deployed app does not leave the installed app permanently pinned to an obsolete bundle.
- [ ] Uninstall/removal follows normal browser/OS behavior.

Installability may differ by browser and OS. Failure of a browser to expose a PWA install UI is not automatically an application defect if that browser/platform does not support the same installation model.

## Hosting and cache policy

- [ ] Production host serves `index.html` with an appropriate cache policy for update discovery.
- [ ] Fingerprinted/static assets use an appropriate cache policy.
- [ ] MIME types are correct for generated JavaScript/Wasm/assets.
- [ ] Compression does not corrupt generated assets.
- [ ] Service-worker/cache update behavior is tested after deploying a changed candidate.
- [ ] Rollback procedure is documented/tested for a bad deployment.
- [ ] Deployment does not expose repository secrets or source-only private material.
- [ ] Security headers are reviewed for the selected host without blocking required Flutter/audio behavior.

## Privacy and security review

- [ ] Microphone capture begins only through the expected user flow.
- [ ] No captured audio is transmitted automatically.
- [ ] Browser console/network inspection shows no unexpected recording upload.
- [ ] Share/download is user initiated.
- [ ] No signing/deployment credentials are embedded in the static bundle.
- [ ] Public source maps/debug artifacts follow the chosen release policy.
- [ ] Third-party dependency notices remain satisfied for Web distribution.

## Release evidence boundary

A Web target may be called build-supported when the repository Web build passes. It may be called candidate-artifact-supported when the checksummed Web release-candidate artifact and unified manifest pass. It should be called publicly release-ready only after the applicable browser, accessibility, privacy, and production-hosting checks above have been executed on the exact candidate and reviewed.

See also:

- `docs/WEB_SUPPORT.md`
- `docs/BUILDING.md`
- `docs/ARCHITECTURE.md`
- `docs/CODECS.md`
- `docs/BRANDING.md`
- `docs/RELEASE_CANDIDATE_MANIFEST.md`
- `docs/QA_CHECKLIST.md`
- `TODO.md`
