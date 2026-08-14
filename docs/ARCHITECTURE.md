# SonicNest Architecture

## Design goals

Reliability and recording safety take priority over visual polish. The project uses service boundaries so recorder, processing, storage, player, metadata recovery, import validation, and UI logic can be tested and replaced independently.

## Layers

- `lib/models/`: immutable recording and settings data with defensive metadata decoding.
- `lib/services/`: filesystem, metadata, microphone recorder, player, FFmpeg processing, external actions, and isolated audio-import validation.
- `lib/controllers/`: application orchestration and state transitions.
- `lib/screens/`: feature-level presentation.
- `lib/widgets/`: reusable responsive components.
- `lib/core/`: theme, constants, strings, filenames, utility types.

## Storage and metadata recovery

Audio files live in the app documents directory under `SonicNest/Recordings`. Metadata is stored separately as JSON under app support. Trash moves audio to a dedicated local trash directory until permanent deletion.

`MetadataStore` owns the metadata replacement/recovery boundary. A completed save is first written and flushed to `recordings.json.tmp`; an existing primary is moved to `recordings.json.bak`; the completed temp file becomes the new primary; the backup is removed only after replacement succeeds.

Startup treats the primary and backup as recoverable state rather than assuming only the primary can be read:

1. If the primary is valid, load it and remove a stale backup.
2. If the primary is missing but a valid backup exists, restore the backup to the primary path.
3. If the primary is structurally corrupt, preserve a collision-safe timestamped diagnostic copy.
4. If a valid backup exists after primary corruption, restore it and continue with the recovered entries.
5. If an individual object inside an otherwise valid recordings list is malformed, isolate that object while retaining valid neighbors.

Model decoding also type-checks optional fields, filters malformed list members, and skips malformed nested markers instead of allowing unchecked casts to abort startup. See `docs/METADATA_INTEGRITY.md` for the exact recovery contract.

## Recording pipeline

1. Validate microphone permission and recorder state.
2. Resolve requested format/preset and query encoder support.
3. Record directly when the requested encoder is supported.
4. Otherwise use a supported intermediate encoder and transcode after stop.
5. Sample dBFS amplitude for the live waveform and persisted envelope.
6. On successful stop, create metadata and persist it.
7. If conversion fails, surface an actionable error rather than claiming success.

## Audio import transaction

`AudioImportService` owns per-file managed-copy validation. It is deliberately separate from platform picker/UI orchestration so copy/probe/waveform failure behavior can be tested deterministically.

For each selected source:

1. Copy the source into managed SonicNest storage using the collision-safe storage path.
2. Infer the managed format from the copied extension.
3. Probe duration using the audio-processing backend.
4. Generate the persisted waveform envelope.
5. Read managed file size and return the validated import data to `AppController`.
6. If validation fails after a managed copy was created, remove that copy before surfacing an `AudioImportException`.

`AppController.importAudio()` processes selected files sequentially. An isolated `AudioImportException` is recorded and the next selected file is attempted. A validated import is converted into `RecordingEntry` metadata and persisted immediately. If metadata persistence itself fails, the controller removes the unregistered in-memory entry, deletes the just-created managed file, and rethrows instead of continuing with an inconsistent Library state.

This separates two failure classes intentionally: malformed/missing selected media is per-file recoverable; failure to persist a supposedly successful managed Library mutation is fail-fast.

## Editor pipeline

All editor operations create a new file. The original remains unchanged. FFmpeg commands are generated from internally managed paths and validated numeric parameters.

## Platform strategy

Flutter host scaffolding changes with Flutter/Gradle/Xcode versions. `tool/bootstrap_platforms.sh` generates host projects from the installed Flutter SDK, then applies SonicNest-specific platform permissions and capabilities from `tool/platform_overrides/`.

## Repository automation boundary

Permanent GitHub Actions workflows are explicitly allowlisted by `tool/repository_audit.py`. Maintained workflows must remain read-only (`contents: read`). Temporary/one-shot write-enabled workflow files are not valid permanent repository state and cause the integrity audit to fail if they remain tracked.

This protects the repository from continuation helpers silently becoming long-lived write-capable automation while preserving dedicated permanent workflows for core CI, Windows, Apple, Linux packaging, release-candidate validation, and repository integrity.

## External batch export ordering

Batch conversion treats the managed SonicNest output as the primary transaction. The output is transcoded, registered, probed, waveform-indexed, and persisted before an optional external-folder copy is attempted. This prevents a removable/inaccessible destination from invalidating a successful managed recording. Destination copies are collision-safe. Stop requests are consumed between items rather than forcibly terminating the active FFmpeg write.
