# SonicNest Architecture

## Design goals

Reliability and recording safety take priority over visual polish. The project uses service boundaries so recorder, processing, storage, player, metadata recovery, orphan reconstruction, import validation, batch conversion, external export, browser recording, and UI logic can be tested and evolved independently.

Cross-platform support is capability-aware rather than pretending every runtime exposes the same operating-system services. The six supported Flutter targets share one default entry point, while native-only dependencies are isolated from the browser compilation graph.

## Layers

- `lib/bootstrap/`: conditional application startup that selects native or Web dependency graphs from the shared `lib/main.dart` entry point.
- `lib/models/`: immutable recording and settings data with defensive metadata decoding and numeric/waveform normalization.
- `lib/services/`: native filesystem, metadata, microphone recorder, player, FFmpeg processing, external actions, isolated audio-import validation, managed-library orphan recovery, and deterministic batch-conversion orchestration.
- `lib/controllers/`: native application orchestration, state transitions, persistence rollback, and startup reconciliation.
- `lib/screens/`: feature-level native presentation and user interaction.
- `lib/widgets/`: reusable responsive components.
- `lib/core/`: theme, constants, naming/file helpers, utility types, and the platform-neutral PCM16 WAV encoder.
- `lib/main_web.dart`: browser-safe recorder presentation/orchestration that imports no `dart:io`, native FFmpeg, native path-provider, or native media-session layer.

## Conditional application bootstrap

`lib/main.dart` is intentionally tiny:

```dart
import 'bootstrap/bootstrap.dart';

Future<void> main() => bootstrapSonicNest();
```

`lib/bootstrap/bootstrap.dart` conditionally exports the correct implementation:

- `dart.library.io` selects `bootstrap_native.dart` for Android, iOS, macOS, Windows, and Linux.
- `dart.library.js_interop` selects `bootstrap_web.dart` for browser builds.
- `bootstrap_unsupported.dart` is an explicit fail-closed fallback for an unknown Dart runtime.

This separation is architectural, not merely visual. The native branch may import `dart:io`, `path_provider`, FFmpeg, native media sessions, and managed-filesystem services. The Web branch never imports those native-only dependency paths, allowing the normal `flutter build web` command to compile from the same default application entry point.

## Native managed storage and metadata recovery

Audio files live in the application documents directory under `SonicNest/Recordings`. Metadata is stored separately as JSON under application support. Trash moves audio to the dedicated local `SonicNest/.trash` directory until permanent deletion.

`StorageService` owns the managed-audio filesystem boundary. A recording path is accepted as managed audio only when it:

1. is inside an allowed active/Trash location;
2. has a supported recording extension; and
3. currently resolves to a regular file when inspected without following symbolic links.

Rename and move-to-Trash require a supported regular file inside active `Recordings`; restore requires one inside managed Trash; duplicate accepts one in either managed location; permanent delete refuses out-of-bound, unsupported, symbolic-link, and non-file paths.

Destination allocation treats every existing filesystem entity as occupied, including directories and broken symbolic links. A path that cannot be inspected safely is also treated as occupied instead of being selected as a write destination.

Startup reconciliation independently removes metadata entries that point outside managed directories, reference missing files, use unsupported extensions, or resolve to symbolic links/non-regular entries.

`MetadataStore` owns the metadata replacement/recovery boundary. A completed save is first written and flushed to `recordings.json.tmp`; an existing primary is moved to `recordings.json.bak`; the completed temp file becomes the new primary; the backup is removed only after replacement succeeds.

Startup treats the primary and backup as recoverable state:

1. If the primary is valid, load it and remove a stale backup.
2. If the primary is missing but a valid backup exists, restore the backup to the primary path.
3. If the primary is structurally corrupt, preserve a collision-safe timestamped diagnostic copy.
4. If a valid backup exists after primary corruption, restore it and continue with the recovered entries.
5. If neither primary nor backup is valid, preserve corrupt inputs and write a clean structurally valid empty store.
6. If an individual record is malformed, isolate that record while retaining valid neighbors.
7. If duplicate recording IDs or normalized file paths appear, retain the first valid record and isolate later duplicates.

Model decoding type-checks optional fields, filters malformed list members, skips malformed nested markers, rejects negative/non-finite numeric metadata, preserves zero as the imported-media unknown-channel state, and bounds finite recovered waveform samples to `0.0..1.0`.

These managed-filesystem semantics belong to the native branch. The browser implementation does not claim equivalent durable filesystem recovery semantics.

## Managed orphan recovery

`LibraryRecoveryService` closes the opposite side of metadata reconciliation: a supported regular audio file can remain safely inside managed storage while its metadata record is missing after an interrupted persistence or deletion operation.

At startup, after invalid/stale metadata entries have been removed, the recovery service:

1. Enumerates supported top-level regular audio files in managed `Recordings` and `.trash`, with link following disabled.
2. Normalizes known metadata paths and skips files already represented by the Library index.
3. Derives the represented recording format from the extension.
4. Reads filesystem size and modification time.
5. Best-effort probes duration and extracts a waveform envelope.
6. Keeps a damaged/partial preserved file recoverable even if probing or waveform extraction fails.
7. Creates a new unique metadata ID without inventing unknown bitrate/sample-rate/channel properties.
8. Tags the reconstructed entry `Recovered` and records the recovery reason in notes.
9. Preserves active-orphan state for `Recordings` and Trash state for `.trash`.
10. Persists reconstructed entries through the ordinary metadata transaction.

Recovery does not follow symbolic links, recurse into arbitrary nested directories, or index unsupported files merely because they are inside a managed directory.

## Library mutation transaction ordering

`AppController` coordinates filesystem and metadata mutations so an operation does not silently leave avoidable split-brain state.

- A completed stopped recording whose metadata write fails is removed from the unsaved in-memory index while the managed audio remains for restart recovery.
- Metadata-only single and batch updates restore previous in-memory state if persistence fails.
- Settings restore their previous in-memory snapshot if settings persistence fails.
- Rename, move-to-Trash, and restore move the file first, persist matching metadata, and move the file back if metadata persistence fails.
- Processed-output registration removes unpersisted in-memory state and generated managed output when registration cannot be committed; caller-supplied external paths are not deleted by cleanup.
- Import registration removes the just-created managed copy if metadata persistence fails.
- Permanent delete removes and persists metadata first, then deletes the managed file. If interruption occurs between those steps, startup orphan recovery can rediscover the preserved active/Trash file instead of losing it irreversibly.
- If physical deletion fails while the file still exists, metadata is restored and persisted again.

The design provides per-item consistency and recovery behavior. It does not claim multi-file ACID transactions or immunity to hostile filesystem changes.

See `docs/METADATA_INTEGRITY.md`, `docs/MANAGED_STORAGE_BOUNDARY.md`, and `docs/RECOVERY_TESTING.md` for the detailed contract.

## Native recording pipeline

`RecorderService` deliberately does not instantiate the native `AudioRecorder` in its constructor. The native backend is created lazily when an operation actually needs recorder-plugin functionality. This keeps service construction free of native method-channel side effects, improves deterministic controller testing, and does not change production microphone behavior once recording/list-device functionality is invoked.

The native recording path is:

1. Validate microphone permission and recorder state.
2. Resolve requested format/preset and query encoder support.
3. Record directly when the requested encoder is supported.
4. Otherwise use a supported intermediate encoder and transcode after stop.
5. Sample dBFS amplitude for the live waveform and persisted envelope.
6. On successful stop, create metadata and persist it.
7. If metadata persistence fails after final audio exists, remove the unsaved in-memory entry but preserve the managed audio for startup recovery.
8. If conversion fails, surface an actionable error instead of claiming success.

## Web recording pipeline

The Web branch intentionally uses a smaller browser-safe pipeline instead of importing the native services.

1. Request browser microphone permission through `AudioRecorder`.
2. Enumerate browser input devices and optionally select one.
3. Build a PCM16 `RecordConfig` with mono/stereo and browser audio-processing requests.
4. Start `AudioRecorder.startStream()` and collect PCM bytes in memory.
5. Subscribe to amplitude changes for the live meter.
6. Support pause, resume, stop, and cancel through the recorder API.
7. Track the effective recorder configuration through the configuration-change callback.
8. On stop, wrap the PCM16 byte stream in a RIFF/WAVE container using `lib/core/wav_encoder.dart`.
9. Keep the finished WAV in the current in-memory browser session.
10. Play it through a byte-backed `StreamAudioSource` or explicitly share/download it through `share_plus`.

The browser does not automatically upload recording bytes. Refreshing/closing the page discards the in-memory session unless the user has explicitly downloaded/shared the recording.

The pure-Dart WAV encoder rejects invalid sample rates, unsupported channel counts, and incomplete PCM16 samples. `test/wav_encoder_test.dart` verifies RIFF/WAVE structure, byte rate, block alignment, payload placement, and invalid-input behavior.

## Audio import transaction

`AudioImportService` owns per-file managed-copy validation on native platforms. It is deliberately separate from platform picker/UI orchestration so copy/probe/waveform failure behavior can be tested deterministically.

For each selected source:

1. Copy the source into managed SonicNest storage using collision-safe allocation.
2. Infer the managed format from the copied extension.
3. Probe duration using the audio-processing backend.
4. Generate the persisted waveform envelope.
5. Read managed file size and return validated import data to `AppController`.
6. If validation fails after a managed copy was created, remove that copy before surfacing an `AudioImportException`.

`AppController.importAudio()` processes selected files sequentially. An isolated media validation failure is recorded and the next selected file is attempted. A validated import is converted into `RecordingEntry` metadata and persisted immediately. If metadata persistence fails, the controller removes the unregistered in-memory entry, deletes the just-created managed file, and rethrows.

## Editor pipeline

All native editor operations create a new file. The original remains unchanged. FFmpeg commands are generated from internally managed paths and validated numeric parameters.

Generated editor output is registered through the managed Library transaction. Failed registration cleanup is limited to eligible managed regular audio and must not delete an external caller-supplied path.

FFmpeg-backed editing is not part of the current Web branch because the selected audio-focused FFmpeg dependency has no Web implementation. The browser UI does not expose a fake or non-functional editor surface.

## Batch conversion pipeline

`BatchConversionService` owns the sequential native batch execution loop used by `BatchConvertScreen`.

For each selected source it:

1. checks the stop predicate before starting work;
2. transcodes into a managed output using known source technical settings when available and configured recording settings as fallback;
3. registers the output through the ordinary processed-file Library transaction;
4. treats the conversion as successful only after managed registration succeeds;
5. optionally performs an external-folder copy after managed registration;
6. records conversion and external-copy failures separately;
7. reports progress;
8. checks stop state again before allowing another source to begin.

A failed external copy does not invalidate a managed conversion that has already been persisted. A registration failure may clean up a generated managed output but cannot delete a caller-supplied external path.

The UI stop action means “Stop after current file.” It does not forcibly terminate the active FFmpeg write. Disposing the Batch Convert screen also raises the stop predicate so another selected item is not intentionally started after the current item finishes.

See `docs/BATCH_CONVERSION.md` for the exact execution and evidence boundary.

## External export collision safety

`ExternalActions` copies files sequentially on native platforms and allocates collision-safe destination names. Destination occupancy is checked without following links; ordinary files, directories, symbolic links, broken links, and uninspectable paths are treated as occupied. This avoids overwriting or following an unexpected filesystem entity in a user-selected folder.

The Web branch instead uses explicit browser share/download behavior and does not claim native destination-path collision semantics.

## Storage accounting

Native user-visible `Recordings` and Trash counts/bytes use the same definition as recovery: supported top-level regular managed audio. Unsupported files, nested arbitrary files, directories, and links are not counted as Library recordings.

Temporary processing storage is measured separately because backend work files can legitimately use different extensions and directory structures.

The current Web session is memory-backed and does not report itself as equivalent native managed storage.

## Platform strategy

Flutter host scaffolding changes with Flutter/Gradle/Xcode/browser tooling versions. `tool/bootstrap_platforms.sh` and `tool/bootstrap_platforms.ps1` generate all six host projects from the installed Flutter SDK:

```text
android,ios,macos,linux,windows,web
```

The scripts then apply SonicNest-specific native permissions/capabilities and generated branding. Host scaffolding remains reproducible rather than committed as permanent generated source.

`pubspec.yaml` enables generated launcher/icon metadata for Android, iOS, Windows, macOS, and Web plus generated splash assets for Android, iOS, and Web. Linux desktop packaging consumes the deterministic generated SonicNest brand image through the Debian packaging path.

## Build and release evidence strategy

Core CI builds representative Android, Linux, and Web outputs in addition to analyzer/test validation. Dedicated workflows cover Windows and Apple hosts plus Linux packaging.

The manually triggered release-candidate workflow produces separate development-preview artifacts for Android, Linux, Windows, macOS, iOS, and Web. The Web job packages `build/web/` as `sonicnest-web-release.tar.gz` with a SHA-256 record. The unified candidate manifest requires all six platform artifact directories and fails closed if any platform payload is missing, altered, symlinked, or otherwise violates its evidence contract.

Compilation and checksum evidence remain distinct from real-device/browser QA and from production signing/hosting approval.

## Repository automation boundary

Permanent GitHub Actions workflows are explicitly allowlisted by `tool/repository_audit.py`. Maintained workflows must remain read-only (`contents: read`). Temporary/one-shot write-enabled workflow files are not valid permanent repository state and cause the integrity audit to fail if they remain tracked.

This protects the repository from continuation helpers silently becoming long-lived write-capable automation while preserving dedicated permanent workflows for core CI, Windows, Apple, Linux packaging, six-platform release-candidate validation, and repository integrity.

## Distribution boundary

Current distribution policy is platform-specific:

- Android: Google Play is the intended initial public channel, with production signing outside the repository.
- iOS: TestFlight/App Store, with protected Apple signing/provisioning outside the repository.
- macOS: signed/notarized GitHub Releases after external signing/notarization gates.
- Windows: Authenticode-verified portable ZIP through GitHub Releases after real-system gates.
- Linux: verified Debian `.deb` plus SHA-256 through GitHub Releases; no initial custom APT repository.
- Web: repository-controlled static release build is reproducible, but production host selection, TLS, DNS, cache policy, deployment credentials, and representative browser QA remain external release decisions.

See the platform distribution documents, `docs/WEB_SUPPORT.md`, `docs/RELEASE_CANDIDATE_MANIFEST.md`, and `docs/RELEASING.md` for release boundaries.
