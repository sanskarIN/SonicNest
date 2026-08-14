# SonicNest Troubleshooting

This guide covers recoverable problems in the current SonicNest development preview. It does not replace platform-specific release QA. If a problem is reproducible, record the exact commit/build, platform, OS version, device/hardware, input route, settings, steps, and logs before reporting it.

## 1. App does not finish startup

Symptoms:

- SonicNest remains on startup longer than expected;
- startup displays a recoverable error;
- Library/settings metadata cannot initialize.

Actions:

1. Use **Try again** from the startup failure screen.
2. Confirm the application can access its own local documents/support directories.
3. Check available storage.
4. If this is a development build, capture the console/error log from the same run.
5. Do not delete user recordings merely to clear a startup problem.

SonicNest separates generic localized startup failure copy from technical detail so an underlying filesystem/settings error can remain diagnosable.

## 2. Microphone permission denied

Symptoms:

- recording does not start;
- the OS permission prompt was denied;
- microphone access was later revoked in system settings.

Actions:

1. Review the platform's application microphone permission.
2. Grant microphone permission only if you intend to record.
3. Return to SonicNest and start a new recording attempt.
4. If permission is granted but capture still fails, verify another application is not exclusively using the input device.

Do not treat a successful permission grant on one OS/device as proof that every supported platform has passed release QA.

## 3. Countdown starts but recording never begins

Actions:

1. Cancel the countdown and try again.
2. Verify microphone permission.
3. Verify a valid input device is selected where device selection is exposed.
4. Check the recorder error message after countdown.
5. If the problem is reproducible, record the countdown value, preset/format, selected device, platform, and OS version.

Countdown cancellation is designed to prevent a delayed recording from starting after cancellation.

## 4. Input device is missing

Possible reasons:

- the recorder backend does not expose device enumeration on that platform;
- the device is disconnected;
- Bluetooth/headset routing has changed;
- the OS has not made the route available to the application.

Actions:

1. Reconnect the device before recording.
2. Close/reopen the Recorder screen or restart SonicNest if the platform backend does not refresh immediately.
3. Verify the input exists in OS sound settings.
4. Test the built-in microphone as a comparison.
5. Report the actual device model/route and OS version if SonicNest consistently differs from OS availability.

## 5. Requested format records using a fallback path

SonicNest checks native recorder encoder support. Some target formats require an intermediate capture plus post-recording conversion.

This is expected when the native recorder cannot directly encode the requested format.

If conversion fails:

1. Keep the original error/log.
2. Record the target format, preset, platform, and OS.
3. Check available storage because conversion temporarily needs additional space.
4. Try a natively common format such as the platform's normal M4A/AAC or WAV path to distinguish recorder failure from conversion failure.

Do not assume every bitrate/sample-rate/channel request is honored identically by every native encoder.

## 6. Clipping warning appears

The clipping indicator reflects sampled input amplitude approaching the clipping threshold.

Try:

- moving the source farther from the microphone;
- reducing input gain in the OS/audio interface where available;
- disabling excessive external preamp gain;
- choosing a more appropriate microphone/input.

SonicNest cannot recover audio information that was already clipped at the hardware/input stage.

## 7. Recording saved but will not play

Actions:

1. Check whether the file still exists in the managed recording location.
2. Try playing a different known-good recording.
3. Try the file in an external player appropriate for the platform.
4. Record the container/format and the path that produced the file (native capture versus conversion fallback).
5. Do not permanently delete the failing file before collecting reproducible diagnostics if it may reveal a codec bug.

## 8. Skip silence is unavailable or has no effect

Skip-silence support depends on the active playback backend/platform. SonicNest treats unsupported silence skipping as optional rather than a universal guarantee.

Normal playback, seek, speed, volume, previous/next, repeat-one, A–B loop, and bookmarks should remain usable even if silence skipping is unsupported.

## 9. A–B loop timing feels inaccurate

Application-managed A–B looping depends on player position updates and backend timing. If a repeat boundary is visibly/audibly wrong:

1. Record the platform/backend and file format.
2. Test a wider loop range to distinguish timing granularity from a logic failure.
3. Capture the chosen A and B positions.
4. Report whether the issue occurs consistently after seeking/reloading.

Real-device timing is a release QA gate.

## 10. Library search/filter returns an unexpected set

Review all active controls:

- scope (All/Favorites/Pinned/Trash);
- search query;
- sort mode;
- format filter;
- folder filter;
- exact tag filter;
- from date;
- through date.

Use **Clear filters** for advanced tag/date restrictions. Search can also match metadata such as notes, folder, tags, and bookmark text.

Pinned entries can be prioritized in non-Trash sorting behavior, so visible order may not be identical to a raw secondary sort alone.

## 11. A file cannot be restored from Trash under its original name

If another managed file already uses the original destination name, SonicNest allocates a non-colliding restored filename instead of overwriting the existing file.

This is expected safety behavior.

## 12. Import fails

Actions:

1. Confirm the source path/file still exists.
2. Confirm the extension is one of the application's supported import types.
3. Confirm SonicNest has permission to access the selected file/path under the current OS picker/security model.
4. Try a known-good audio file.
5. For malformed/corrupt files, keep a privacy-safe reproduction file if possible for QA.

A failed import should not intentionally leave a false Library entry; partially imported/generated outputs are cleaned up where possible.

## 13. Export destination already contains the same filename

SonicNest direct directory-copy behavior is collision-safe. Existing files are not intentionally overwritten; the next numbered filename is selected instead.

Example:

```text
voice.wav
voice (2).wav
voice (3).wav
```

If an external path disappears or permission is revoked between selection and copy, the failing item should be reported independently from other successful copies.

## 14. Batch conversion partially succeeds

Batch conversion intentionally isolates failures per item.

Expected behavior:

- successful earlier items stay registered;
- a failing item is reported;
- later items can continue unless **Stop after current file** was requested;
- external-copy failure does not intentionally invalidate a successful managed conversion.

For a reproducible failure, record:

- source format/file properties;
- target format;
- target external directory, if used;
- item position within the batch;
- available storage;
- exact error.

## 15. Stop after current file seems delayed

This control is designed to finish the current conversion safely. It does not intentionally terminate an output write mid-file.

The stop takes effect before starting the next selected item.

If the current conversion itself is very long, the UI can remain busy until that file finishes or fails.

## 16. Editor operation fails

Common causes include:

- malformed input media;
- unsupported codec/filter path;
- insufficient free storage;
- source file disappeared;
- selected range is invalid/too small for the operation;
- platform FFmpeg/backend limitation.

Actions:

1. Keep the original file unchanged.
2. Record the operation, range/settings, source format, duration, and error.
3. Check free storage.
4. Test another known-good source.
5. For DSP quality problems rather than processing errors, record listening observations; do not label a preset as universally broken based on one source without reproduction.

## 17. Managed storage number looks stale

Storage totals are calculated from the managed recording/Trash/temporary areas when the Settings storage section loads/rebuilds.

If the filesystem changed outside SonicNest, return to/reopen Settings to refresh the view. Temporary files may also disappear as processing cleanup completes.

## 18. Temporary cleanup is unavailable

Cleanup is intentionally disabled while an active recording could depend on temporary resources. Stop/cancel the recording safely before attempting cleanup.

## 19. Keep-screen-awake does not prevent background suspension

**Keep screen awake** is a display wake preference. It does not override platform background execution policy, microphone policy, process suspension, battery optimization, or OEM-specific restrictions.

Background/lock-screen recording requires separate physical-device validation for each platform.

## 20. Native icon or launch screen still looks like a default Flutter asset

For development builds generated from repository source:

1. Run platform bootstrap.
2. Run `flutter pub get`.
3. Apply branding:

Bash:

```bash
bash tool/apply_branding.sh
```

Windows PowerShell:

```powershell
./tool/apply_branding.ps1
```

4. Clean/rebuild if the platform build system or launcher is caching old assets.
5. Uninstall/reinstall on devices where launcher icon caches persist.

The deterministic source is `tool/generate_brand_assets_v2.dart`. See `docs/BRANDING.md`.

## 21. Native branding is cropped under a launcher mask

Automated generation cannot approve every real launcher crop/mask. Record:

- device/launcher;
- OS version;
- mask shape/themed-icon state;
- screenshot from the actual launcher;
- exact app source/build.

Do not "fix" one launcher by shrinking/repositioning the mark without checking the cross-platform branding QA matrix.

## 22. Release preflight fails formatting

The checked-in Dart source must already be formatter-clean for release preflight.

Run:

```bash
dart format lib test tool/generate_brand_assets_v2.dart
```

Review the changes, rerun tests/analyzer, and commit formatter output rather than weakening the release gate.

## 23. Unsigned release-candidate artifact cannot be installed/published

This can be expected.

The repository release-candidate workflow intentionally avoids maintainer production signing credentials. In particular:

- iOS no-codesign output is not an App Store installable package;
- macOS output is not a public notarized package;
- Windows output is not a finalized signed installer;
- Linux output is not a selected distribution package;
- Android output is not evidence that Play production signing/review gates are complete.

See `docs/UNSIGNED_ARTIFACTS.md` and `docs/RELEASING.md`.

## 24. GitHub Actions build passes but the app fails on hardware

Compilation is necessary but not sufficient for a recorder.

Create a **Device / Release QA report** using the repository issue form and include:

- exact commit SHA;
- workflow/local build source;
- device/machine;
- OS version;
- microphone/input route;
- relevant SonicNest settings;
- reproduction steps;
- expected versus actual result;
- safe logs/screenshots.

Do not upload tokens, signing credentials, private certificates, personal recordings, device serial numbers, or other sensitive information.

## 25. Before reporting a bug

Check:

- `what_changed.md` for the exact continuation state;
- `PROJECT_STATE.md` for supported/partial/manual-validation boundaries;
- `TODO.md` for known evidence-dependent gates;
- `docs/QA_CHECKLIST.md` for the expected validation procedure;
- `docs/RELEASE_EVIDENCE_TEMPLATE.md` for evidence fields;
- `SUPPORT.md` for support channels.

A high-quality report should make the problem reproducible without exposing private data.
