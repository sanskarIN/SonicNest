# Metadata Integrity and Recovery

SonicNest stores recording-library metadata locally as JSON under the platform application-support directory. The metadata layer is designed so malformed metadata, interrupted replacement, one bad recording object, or a missing metadata record does not unnecessarily hide the recoverable audio library.

## Storage location

`MetadataStore` resolves the platform application-support directory and stores metadata under:

```text
SonicNest/recordings.json
```

Generated audio files remain separate from this metadata file. The JSON document references managed recording paths and organizer information such as titles, tags, folders, notes, markers, waveform envelopes, favorites, pins, and Trash state.

The storage boundary is intentionally strict: destructive library mutations are accepted only for paths inside SonicNest's managed `Recordings` or `.trash` directories. Metadata that points outside those managed locations is removed during startup reconciliation instead of being trusted as a filesystem instruction.

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

## Managed-path reconciliation

After metadata loading, the application controller reconciles the library against SonicNest-managed storage.

A metadata entry remains active only when:

1. its audio path is inside SonicNest's managed recording or Trash directory; and
2. the referenced file currently exists.

If reconciliation removes stale or out-of-bound metadata, the cleaned library is persisted. The storage service independently guards rename, duplicate, move-to-Trash, restore, and permanent-delete operations, providing a second boundary even if a malformed entry reaches a mutation path.

## Orphaned-audio recovery

SonicNest also performs the inverse reconciliation: supported audio files present in the managed `Recordings` directory but missing from metadata are recovered into the library.

`LibraryRecoveryService`:

1. enumerates supported top-level managed recording files;
2. skips normalized paths already represented by metadata;
3. derives the recording format from the extension;
4. captures filesystem size and modification time;
5. best-effort probes duration and extracts a waveform;
6. still recovers the preserved file if media probing or waveform extraction fails;
7. creates a new unique metadata ID;
8. tags the entry `Recovered` and records why it was reconstructed;
9. persists the reconstructed entries through the normal metadata transaction.

This means a successfully written managed audio file can be surfaced again after a crash or metadata-write interruption instead of becoming a permanently hidden orphan. It also allows recoverable managed audio to reappear after an unrecoverable metadata document has been preserved and reset.

The recovery scanner does not recurse into arbitrary directories and ignores unsupported file extensions.

## Persistence-safe library mutations

Metadata updates are treated as part of the filesystem operation rather than as an unrelated follow-up.

Current safeguards include:

- single-entry metadata edits restore the previous in-memory entry if persistence fails;
- batch metadata edits restore the previous in-memory library and selection if persistence fails;
- processed-output registration removes the failed metadata entry and generated output when registration cannot be persisted;
- rename, move-to-Trash, and restore operations attempt to move the audio file back to its original path when metadata persistence fails;
- permanent deletion removes/persists metadata before deleting managed audio, preferring a harmless orphan over irreversible data loss if a process stops between the two steps;
- when audio deletion itself fails and the file still exists, the metadata entry is restored and persisted again;
- settings state rolls back in memory when its persistence operation fails.

These safeguards reduce split-brain states between the library index and managed audio files. They are not a substitute for a transactional filesystem or database and therefore do not justify claiming perfect crash atomicity.

## Large-library automated coverage

The metadata test suite includes an end-to-end filesystem round-trip of 3,000 `RecordingEntry` objects through the real JSON save/load implementation. The test checks entry count, ordering/identity samples, and cleanup of `.tmp`/`.bak` files after a completed save.

This automated test is a deterministic regression gate. It does not replace real large-library UI profiling, memory profiling, filesystem-performance testing, or long-duration device QA, which remain separate release gates.

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

`test/storage_service_test.dart` verifies managed-path mutation guards, protected external files, collision-safe allocation, and supported-file discovery for recovery.

`test/library_recovery_service_test.dart` verifies orphan discovery, known-entry deduplication, damaged-media best-effort recovery, and recovery coverage for every supported recording format.

## Release boundary

Metadata and managed-storage recovery tests prove deterministic repository behavior only. They do not establish release readiness for real low-storage failures, abrupt device power loss, filesystem permission revocation, malformed real-media corpora, removable-media behavior, or multi-hour/large-library performance on real target systems. Those evidence-dependent checks remain in `TODO.md` and `docs/QA_CHECKLIST.md`.
