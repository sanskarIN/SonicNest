# SonicNest Web Support

SonicNest treats Web as a first-class build target alongside Android, iOS, macOS, Windows, and Linux.

## Entry point

`lib/main.dart` is the shared application entry point for every target. It conditionally selects:

- `lib/bootstrap/bootstrap_native.dart` when `dart.library.io` is available.
- `lib/bootstrap/bootstrap_web.dart` when `dart.library.js_interop` is available.

The Web branch delegates to `lib/main_web.dart`, which intentionally has no `dart:io`, native FFmpeg, native filesystem, or native media-session dependency.

This arrangement keeps `flutter run` and `flutter build web` on the normal project entry point while preventing native-only packages from entering the browser compilation graph. The `dart.library.js_interop` condition also follows the modern Dart Web capability marker rather than relying on deprecated HTML-library detection.

## Browser recorder capabilities

The browser surface currently provides:

- microphone permission handling;
- input-device enumeration and selection;
- synchronized microphone-picker state when browser device refresh changes or removes the selected device;
- mono or stereo capture requests;
- automatic gain, echo cancellation, and noise suppression requests where the browser honors them;
- PCM16 stream recording;
- pause, resume, stop, and cancel;
- live amplitude metering;
- elapsed recording time while capture is active;
- finished-recording duration derived from the actual captured PCM16 frame count rather than the UI timer;
- complete mono/stereo PCM frame validation before WAV creation;
- fail-closed cleanup of partial in-memory capture state after start/stream/control-transition failures;
- fail-closed recovery when the browser closes the capture stream unexpectedly without reporting an explicit stream error;
- generation invalidation so stale stream errors or completion callbacks cannot overwrite a later Stop/Cancel/dispose transition;
- transition locking so microphone/channel/processing input settings cannot change while recorder state is uncertain;
- local PCM16-to-WAV packaging in pure Dart;
- in-session recording list;
- WAV playback from an in-memory byte stream;
- same-recording pause/resume without reloading the source from the beginning;
- awaited playback operations plus player-wide asynchronous error observation;
- stale playing-row cleanup when playback or a new source load fails;
- explicit share/download with browser download fallback;
- light, dark, and system theme support;
- responsive browser layout;
- no automatic audio upload or analytics.

A browser capture-stream failure or unexpected clean stream completion does not create a finished recording from partial bytes. SonicNest cancels the recorder where possible, closes capture/amplitude subscriptions, discards the incomplete in-memory buffer, resets timer/amplitude state, returns the recorder to the stopped state, and presents a recoverable message so the user can start a new recording.

Recorder control transitions use the same safety boundary. A Pause/Resume failure is treated as an unknown backend state and the incomplete capture is discarded rather than allowing the UI and microphone backend to diverge. Stop and Cancel invalidate the current stream generation before their backend transition, so a late error or completion callback from the old stream cannot race the requested control action. A Stop failure is recovered fail-closed. Cancel always discards local PCM and closes local capture/amplitude subscriptions even if browser cancellation itself throws; SonicNest then attempts a backend Stop fallback. If neither browser operation can confirm microphone shutdown, the UI explains that local capture was discarded and instructs the user to reload if the browser microphone indicator remains active.

Input-device and processing settings share a single transition lock. They are unavailable not only while capture is actively recording/paused, but also while start/pause/resume/stop/cancel work is in flight. This prevents the controls from displaying a setting that differs from the configuration currently being negotiated with the browser recorder backend.

The microphone form field is keyed by the selected browser-device ID. Flutter form-field `initialValue` initializes/reset the internal field state rather than continuously tracking later application state, so a selected-device change remounts the field. When a refresh discovers that the previously selected device no longer exists, `_selectedDevice` is reset and the visible picker returns to the browser-default state instead of retaining a stale removed-device label.

In-session playback keeps the same loaded byte source when the user pauses and resumes a recording. Playback operations are awaited so immediate backend failures can be surfaced through SonicNest's recoverable message path. SonicNest also subscribes to `AudioPlayer.errorStream` for player errors emitted after an immediate operation has returned. An asynchronous playback failure clears the active row; switching to a different recording clears the previous row before loading the new source so a failed source load cannot leave stale selection state. The error paths coordinate their reporting so the same active-recording failure is not deliberately surfaced twice merely because both the player-wide stream and the awaited operation observe it.

Widget disposal invalidates the active capture generation before local subscriptions and recorder/player resources are disposed. It also cancels both player state and player-error subscriptions. This prevents late capture or playback callbacks from trying to revive state owned by a page that is leaving the widget tree.

## Native-only capability boundary

The native SonicNest application remains the feature-complete target for filesystem-managed libraries and FFmpeg editing. The current dependency set does not provide Web implementations for the native FFmpeg package or `path_provider`, so the browser build does not pretend those features exist.

The Web surface therefore does not currently claim:

- durable SonicNest managed-library persistence across browser sessions;
- Trash/recovery filesystem semantics;
- FFmpeg-backed editing, conversion, normalization, filters, or batch conversion;
- native foreground services;
- native lock-screen/media-session integration;
- native package signing or platform-store integration.

This is an explicit capability boundary, not a hidden failure path. Web users can record, play, and download/share WAV recordings without those native services.

## Reproducible platform generation

Both bootstrap scripts generate all six Flutter hosts when any required host is missing:

```text
android,ios,macos,linux,windows,web
```

Use either:

```bash
bash tool/bootstrap_platforms.sh
```

or on Windows PowerShell:

```powershell
./tool/bootstrap_platforms.ps1
```

Branding tooling also requires and updates the generated Web host. Web launcher metadata and splash generation are enabled in `pubspec.yaml`.

## Run in a browser

After bootstrapping and resolving dependencies:

```bash
flutter config --enable-web
flutter run -d chrome
```

The default `lib/main.dart` automatically selects the browser bootstrap.

## Build the Web release

```bash
flutter config --enable-web
bash tool/bootstrap_platforms.sh
flutter pub get
bash tool/apply_branding.sh
flutter build web --release
```

On Windows, use the PowerShell bootstrap/branding scripts before the same Flutter build command.

The deployable static site is written to `build/web/` by Flutter. Hosting, DNS, TLS, cache headers, and production deployment credentials remain deployment-environment responsibilities and are not committed to this repository.

## Core CI contract

`.github/workflows/ci.yml` contains a dedicated Web release-build job. It:

1. enables Flutter Web;
2. generates all platform hosts;
3. resolves dependencies;
4. applies SonicNest branding;
5. runs `flutter build web --release` through the shared default entry point.

The normal validation job still runs formatting, analyzer checks, and the complete Flutter unit-test suite. `test/wav_encoder_test.dart` validates the pure-Dart WAV header/payload logic, PCM frame-alignment rejection, and byte-derived duration behavior used by browser recording. `tool/tests/test_web_platform_contract.py` locks browser isolation, start/stream recovery, unexpected stream-completion recovery, generation invalidation, fail-closed Pause/Resume/Stop behavior, Cancel cleanup/fallback markers, recorder-transition input locking, microphone-picker synchronization, same-recording playback resume, and player-wide asynchronous error-observation/cleanup markers. `test/bootstrap_integrity_test.dart` locks the six-target bootstrap list, conditional application entry point, and Web build command.

## Release-candidate evidence

`.github/workflows/release-candidate.yml` also contains a Web release-candidate job. It builds the browser release through the same default entry point, archives the generated static site as `sonicnest-web-release.tar.gz`, writes an explicit development-preview warning, writes `SHA256SUMS.txt`, and uploads `sonicnest-web-release-candidate`.

The unified release-candidate provenance manifest now requires all six targets:

```text
android, linux, windows, macos, ios, web
```

`tool/build_release_candidate_manifest.py` rejects a missing Web candidate, a Web payload whose bytes no longer match its checksum, and any other platform evidence that violates the same fail-closed artifact rules. The Web entry records release build classification, marks binary signing as not applicable to the static bundle, and remains explicitly development-preview evidence.

See `docs/RELEASE_CANDIDATE_MANIFEST.md` for the complete provenance contract. Historical release-candidate runs that predate Web integration remain historical five-platform evidence and do not validate the current six-platform revision.

## Browser compatibility and manual QA

Microphone capture depends on browser permission APIs and a secure browsing context in production. Actual input-device behavior, permission prompts, capture quality, playback, browser download/share behavior, responsive layout, and installability should be checked on representative current browsers before a public Web release.

At minimum, manual Web QA should cover current Chromium, Firefox, and Safari families on desktop and mobile form factors where available. A browser passing the build job does not by itself prove microphone hardware or browser-policy behavior.

Recommended evidence includes:

- first-run allow/deny microphone flows;
- permission revocation and retry;
- default and alternate microphone selection;
- selected-device display synchronization after refresh/removal;
- mono and stereo requests where supported;
- input settings remaining locked during recorder transition work and restoring after recovery;
- pause/resume timing and audio continuity;
- injected/real capture interruption followed by clean stopped-state recovery with no partial recording inserted;
- clean capture-stream termination without an explicit error followed by the same fail-closed recovery;
- injected Pause/Resume/Stop backend failures followed by clean fail-closed recovery;
- Cancel when browser cancellation succeeds, when cancellation throws but Stop fallback succeeds, and when neither operation can confirm microphone shutdown;
- late stream errors/completion callbacks during Stop/Cancel not changing the newly requested state;
- navigation/reload/disposal during capture not reviving stale recorder UI state;
- saved WAV duration compared with independently observed audio duration, including pause/resume cases;
- long capture and memory behavior;
- playback pause then resume on the same row without restarting at zero;
- playback completion, different-source load failure, asynchronous player error recovery, and repeated playback;
- share/download success and generated WAV playback outside SonicNest;
- narrow/mobile and wide/desktop responsive layouts;
- keyboard/focus and screen-reader basics;
- light/dark/system theme behavior;
- PWA/browser installability where the target browser exposes installation;
- production HTTPS hosting and cache-update behavior.

## Privacy

The browser implementation records into local process memory and does not automatically upload audio. A finished recording stays in the current in-memory session until the page is refreshed/closed or the user deletes it. Failed/incomplete capture buffers are discarded rather than promoted into the session list. Users should explicitly download/share recordings they want to retain.

Any future durable browser storage implementation must preserve SonicNest's privacy-first model and document browser quota, eviction, backup, deletion, and recovery semantics before being presented as equivalent to the native managed library.
