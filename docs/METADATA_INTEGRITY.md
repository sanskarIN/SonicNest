# Metadata Integrity and Recovery

SonicNest stores recording-library metadata locally as JSON under the platform application-support directory. The metadata layer is designed so malformed metadata, interrupted replacement, one bad recording object, a missing metadata record, or an interrupted managed-file mutation does not unnecessarily hide recoverable audio.

## Storage location

`MetadataStore` resolves the platform application-support directory and stores metadata under:

```text
SonicNest/recordings.json
```

Generated audio files remain separate from this metadata file. The JSON document references managed recording paths and organizer information such as titles, tags, folders, notes, markers, waveform envelopes, favorites, pins, and Trash state.

The storage boundary is intentionally strict: destructive library mutations are accepted only for supported regular audio files inside SonicNest's managed `Recordings` or `.trash` directories. Metadata that points outside those locations, points to a missing file, uses an unsupported extension, or resolves to a symbolic link/non-regular filesystem entry is removed during startup reconciliation instead of being trusted as a filesystem instruction.

## Atomic-style save sequence

A save uses three paths:

```text
recordings.json
recordings.json.tmp
recordings.json.bak
```

The replacement sequence is:

1. Serialize the complete new metadata document to `recordings.json.tmp` and flush it.
2. Remove a stale `.bak` from a previous completed cycle if one remains.
3. Rename the current `recordings.json` to `recordings.json.bak` when a primary exists.
4. Rename the completed temporary file to `recordings.json`.
5. Remove the backup only after the new primary is in place.
6. If the final rename fails, delete an incomplete primary if necessary and restore the backup.

This is not a database transaction, but it narrows the replacement window and provides a recoverable prior copy.

## Interrupted replacement recovery

Startup checks `recordings.json.bak` as a recovery source.

If the primary metadata file is missing but a valid backup remains, SonicNest:

1. decodes and validates the backup;
2. restores it to `recordings.json`;
3. removes the recovered `.bak`;
4. returns the recovered recording entries.

If the primary exists but is structurally corrupt and a valid backup exists, SonicNest:

1. preserves a timestamped copy of the corrupt primary;
2. validates the backup;
3. restores the valid backup to the primary path;
4. removes the consumed `.bak`;
5. continues startup with the recovered entries.

If no valid primary or backup can be recovered, the corrupt document or documents are preserved and SonicNest writes a fresh, structurally valid empty metadata document. This prevents the same corrupt primary from being copied repeatedly on every launch while retaining timestamped diagnostic evidence.

## Corrupt metadata preservation

Structurally invalid metadata is preserved before SonicNest falls back to an empty store or a valid backup. Corrupt copies use names such as:

```text
recordings.json.corrupt.<millisecondsSinceEpoch>
recordings.json.bak.corrupt.<millisecondsSinceEpoch>
```

If a target corrupt-copy name already exists, a numeric suffix is added instead of overwriting the previous diagnostic copy.

A document is considered structurally invalid when, for example:

- the JSON syntax cannot be decoded;
- the root value is not an object/map;
- the root cannot be converted to string-keyed metadata;
- the `recordings` field exists but is not a list.

An absent `recordings` field is treated as an empty but structurally valid library.

Diagnostic copies can contain user-created titles, tags, notes, folders, and file paths. They should be treated as privacy-sensitive local data when collecting troubleshooting evidence.

## Per-record isolation and normalization

One malformed object inside an otherwise valid `recordings` list does not invalidate the entire metadata document.

The loader:

- ignores non-map list items;
- safely decodes known fields using type-checked fallbacks;
- rejects negative or non-finite duration, size, bitrate, sample-rate, and marker-position values by replacing them with safe defaults;
- preserves `channels: 0` as the supported "unknown imported channel count" state while rejecting negative/non-finite values;
- ignores malformed nested markers rather than rejecting the parent recording;
- filters invalid tag members;
- filters non-finite waveform members and bounds recovered waveform samples to `0.0..1.0`;
- accepts only entries with non-empty recording IDs and file paths;
- keeps the first record when duplicate IDs or duplicate normalized file paths appear and isolates later duplicates.

Unexpected optional-field types fall back to safe defaults. This allows valid entries before and after a damaged record to remain available.

## Managed-path and regular-file reconciliation

After metadata loading, the application controller reconciles the library against SonicNest-managed storage.

A metadata entry remains represented only when its path:

1. is inside the correct SonicNest managed `Recordings` or `.trash` location;
2. has a supported recording extension;
3. exists as a regular file when inspected without following symbolic links.

This rejects:

- paths outside managed audio storage;
- missing files;
- unsupported regular files;
- directories and other non-file entries;
- symbolic links, even when the link itself is located inside a managed directory.

If reconciliation removes stale or unsafe metadata, the cleaned library is persisted. `StorageService` independently guards rename, duplicate, move-to-Trash, restore, and permanent-delete operations, providing a second boundary even if malformed state reaches a mutation path.

Destination allocation also checks filesystem entities without following links. A directory, regular file, symbolic link, or broken symbolic link occupying a candidate name forces allocation of the next collision-safe filename. A path that cannot be inspected safely is treated as occupied rather than selected as a write destination.

See `docs/MANAGED_STORAGE_BOUNDARY.md` for the focused filesystem contract.

## Orphaned managed-audio recovery

SonicNest also performs the inverse reconciliation: supported regular audio files present in managed storage but missing from metadata are recovered into the library.

`LibraryRecoveryService` scans two controlled top-level locations with link following disabled:

```text
SonicNest/Recordings
SonicNest/.trash
```

It does not recurse into arbitrary directories.

For each eligible file the recovery service:

1. skips normalized paths already represented by metadata;
2. derives the recording format from the extension;
3. captures filesystem size and modification time;
4. best-effort probes duration and extracts a waveform;
5. still recovers the preserved file if media probing or waveform extraction fails;
6. creates a new unique metadata ID;
7. tags the entry `Recovered` and records why it was reconstructed;
8. preserves unknown bitrate/sample-rate/channel data as unknown rather than inventing values;
9. persists the reconstructed entries through the normal metadata transaction.

An orphan from active `Recordings` is reconstructed as an active entry. An orphan from `.trash` is reconstructed with Trash state restored so an interrupted permanent deletion does not silently promote a preserved Trash file into the active Library.

This means a successfully written managed recording can be surfaced again after a crash or metadata-write interruption instead of becoming a permanently hidden orphan. It also allows recoverable managed audio to reappear after an unrecoverable metadata document has been preserved and reset.

The recovery scanner ignores unsupported file extensions, symbolic links, nested arbitrary files, and non-file entries.

## Persistence-safe library mutations

Metadata updates are treated as part of the filesystem operation rather than as an unrelated follow-up.

Current safeguards include:

- a stopped recording whose metadata persistence fails is removed from the unsaved in-memory index while its completed managed audio file is preserved for startup orphan recovery;
- single-entry metadata edits restore the previous in-memory entry if persistence fails;
- batch metadata edits restore the previous in-memory library and selection if persistence fails;
- settings restore the previous in-memory snapshot when settings persistence fails;
- processed-output registration removes the failed metadata entry and generated managed output when registration cannot be persisted;
- failed processed-output cleanup refuses to delete a caller-supplied external path merely because probing/registration failed;
- rename, move-to-Trash, and restore operations attempt to move the audio file back to its original path when metadata persistence fails;
- import registration removes the just-created managed copy if metadata persistence fails;
- permanent deletion removes and persists metadata before deleting managed audio, preferring a recoverable orphan over irreversible data loss if a process stops between the two steps;
- if interrupted permanent deletion leaves the file in `.trash`, startup recovery reconstructs it as a Trash entry;
- when managed audio deletion itself fails and the file still exists, the metadata entry is restored and persisted again.

These safeguards reduce split-brain states between the library index and managed audio files. They are not a substitute for a transactional filesystem or database and therefore do not justify claiming perfect crash atomicity.

## Managed storage accounting

User-visible recording and Trash storage totals use the same definition as recovery and mutation safety: top-level supported regular managed audio files. Unsupported files, nested arbitrary files, directories, and symbolic links are not counted as Library recordings merely because they are located under `Recordings` or `.trash`.

Temporary processing storage remains separately measured because temporary work products can use non-audio extensions and nested backend artifacts.

The automatic recording sequence likewise counts managed active/Trash audio rather than unrelated filesystem entries. Collision-safe allocation remains the final guard against a pre-existing destination name.

## Large-library automated coverage

The metadata test suite includes an end-to-end filesystem round-trip of 3,000 `RecordingEntry` objects through the real JSON save/load implementation. The test checks entry count, ordering/identity samples, and cleanup of `.tmp`/`.bak` files after a completed save.

This automated test is a deterministic regression gate. It does not replace real large-library UI profiling, memory profiling, filesystem-performance testing, orphan-scan timing, or long-duration device QA, which remain separate release gates.

## Regression coverage

`test/metadata_store_test.dart` covers:

- syntactically invalid JSON preservation and clean reset behavior;
- prevention of repeated corrupt-primary copies after a successful reset;
- structurally invalid `recordings` payload preservation/reset behavior;
- isolation of malformed entries while valid entries survive;
- duplicate-ID and duplicate-file-path isolation;
- recovery when an interrupted replacement leaves only `.bak`;
- recovery from a corrupt primary when a valid `.bak` exists;
- preservation of both corrupt primary and corrupt backup before reset;
- 3,000-entry save/load round-trip behavior.

`test/recording_entry_test.dart` verifies tolerant decoding, non-negative numeric normalization, bounded finite waveform recovery, and preservation of the zero/unknown imported channel-count state.

`test/storage_service_test.dart` verifies managed-path mutation guards, protected external files, collision-safe allocation, active/Trash discovery, and symbolic-link/non-regular-path refusal on supported test hosts.

`test/storage_service_non_file_test.dart` verifies unsupported regular-file protection, non-file collisions, and managed-audio-only storage accounting/sequence behavior.

`test/library_recovery_service_test.dart` verifies active/Trash orphan discovery, known-entry deduplication, damaged-media best-effort recovery, and recovery coverage for every supported recording format.

`test/app_controller_recovery_test.dart` verifies controller startup reconciliation, active/Trash orphan reconstruction, unsafe metadata removal, and no duplicate reconstruction across restart.

`test/app_controller_persistence_test.dart` verifies controller-level rollback/data-preservation behavior for metadata edits and managed-file mutations.

`test/app_controller_output_safety_test.dart` verifies failed processed-output registration cleanup without deleting caller-supplied external files.

`test/audio_import_service_test.dart` verifies managed-copy cleanup after copy/probe/waveform failures.

## Release boundary

Metadata, managed-storage, recovery, and rollback tests prove deterministic repository behavior only. They do not establish release readiness for real low-storage failures, abrupt process/device power loss, filesystem permission revocation, malformed/partially written real-media corpora, removable-media behavior, or multi-hour/large-library performance on real target systems. Those evidence-dependent checks remain in `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RECOVERY_TESTING.md`.
