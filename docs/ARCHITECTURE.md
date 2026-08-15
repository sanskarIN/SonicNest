# SonicNest Architecture

## Design goals

Reliability and recording safety take priority over visual polish. The project uses service boundaries so recorder, processing, storage, player, metadata recovery, orphan reconstruction, import validation, and UI logic can be tested and replaced independently.

## Layers

- `lib/models/`: immutable recording and settings data with defensive metadata decoding and numeric/waveform normalization.
- `lib/services/`: filesystem, metadata, microphone recorder, player, FFmpeg processing, external actions, isolated audio-import validation, and managed-library orphan recovery.
- `lib/controllers/`: application orchestration, state transitions, persistence rollback, and startup reconciliation.
- `lib/screens/`: feature-level presentation.
- `lib/widgets/`: reusable responsive components.
- `lib/core/`: theme, constants, strings, filenames, utility types.

## Storage and metadata recovery

Audio files live in the app documents directory under `SonicNest/Recordings`. Metadata is stored separately as JSON under app support. Trash moves audio to a dedicated local trash directory until permanent deletion.

`StorageService` owns the managed-audio filesystem boundary. Rename and move-to-Trash require a source inside active managed recordings; restore requires a source inside managed Trash; duplicate and permanent-delete operations reject paths outside SonicNest-managed audio storage. Startup reconciliation independently removes metadata entries that point outside those managed directories or reference missing files.

`MetadataStore` owns the metadata replacement/recovery boundary. A completed save is first written and flushed to `recordings.json.tmp`; an existing primary is moved to `recordings.json.bak`; the completed temp file becomes the new primary; the backup is removed only after replacement succeeds.

Startup treats the primary and backup as recoverable state rather than assuming only the primary can be read:

1. If the primary is valid, load it and remove a stale backup.
2. If the primary is missing but a valid backup exists, restore the backup to the primary path.
3. If the primary is structurally corrupt, preserve a collision-safe timestamped diagnostic copy.
4. If a valid backup exists after primary corruption, restore it and continue with the recovered entries.
5. If neither primary nor backup is valid, preserve the corrupt inputs and write a clean structurally valid empty store instead of leaving a corrupt primary active indefinitely.
6. If an individual object inside an otherwise valid recordings list is malformed, isolate that object while retaining valid neighbors.
7. If duplicate recording IDs or duplicate normalized file paths appear, retain the first valid record and isolate later duplicates.

Model decoding type-checks optional fields, filters malformed list members, skips malformed nested markers, rejects negative/non-finite numeric metadata, preserves zero as the imported-media unknown-channel state, and bounds finite recovered waveform samples to `0.0..1.0` instead of allowing unchecked values to abort or destabilize startup.

## Managed orphan recovery

`LibraryRecoveryService` closes the opposite side of metadata reconciliation: a supported audio file can exist safely inside managed `Recordings` while its metadata record is missing after an interrupted persistence operation.

At startup, after invalid/stale metadata entries have been removed, the recovery service:

1. Enumerates only supported top-level audio files in managed `Recordings`.
2. Normalizes known metadata paths and skips files already represented by the library index.
3. Derives the represented recording format from the extension.
4. Reads filesystem size and modification time.
5. Best-effort probes duration and extracts a waveform envelope.
6. Keeps a damaged/partial preserved file recoverable even if probing or waveform extraction fails.
7. Creates a new unique metadata ID without inventing unknown bitrate/sample-rate/channel properties.
8. Tags the reconstructed entry `Recovered` and records the recovery reason in notes.
9. Persists recovered entries through the ordinary metadata transaction.

This intentionally prefers data preservation. A process interruption after an audio file is created but before its metadata is committed can therefore leave a recoverable orphan rather than an invisible file.

## Library mutation transaction ordering

`AppController` coordinates filesystem and metadata mutations so an operation does not silently leave avoidable split-brain state.

- Metadata-only single and batch updates snapshot the previous in-memory state and restore it if persistence fails.
- Settings restore their prior in-memory snapshot if settings persistence fails.
- Rename, move-to-Trash, and restore move the file first, persist the matching metadata state, and move the file back to its original path if metadata persistence fails.
- Processed-output registration removes the unpersisted in-memory entry and generated output when registration cannot be committed.
- Import registration removes the just-created managed copy if metadata persistence fails.
- Permanent delete removes and persists metadata first, then deletes the managed file. If the process stops between those steps, startup orphan recovery can rediscover the preserved file instead of data being irreversibly lost. If deletion itself fails while the file still exists, metadata is restored and persisted again.

The design provides per-item consistency and recovery behavior. It does not claim multi-file ACID transactions or immunity to hostile filesystem changes.

See `docs/METADATA_INTEGRITY.md` for the exact persistence and recovery contract.

## Recording pipeline

1. Validate microphone permission and recorder state.
2. Resolve requested format/preset and query encoder support.
3. Record directly when the requested encoder is supported.
4. Otherwise use a supported intermediate encoder and transcode after stop.
5. Sample dBFS amplitude for the live waveform and persisted envelope.
6. On successful stop, create metadata and persist it.
7. If conversion fails, surface an actionable error rather than claiming success.

A successfully preserved managed recording that outlives a failed/interrupted metadata write is eligible for startup orphan recovery.

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
