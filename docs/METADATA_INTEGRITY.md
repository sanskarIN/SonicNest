# Metadata Integrity and Recovery

SonicNest stores recording-library metadata locally as JSON under the platform application-support directory. The metadata layer is designed so malformed metadata, an interrupted replacement, or one bad recording object does not unnecessarily hide the rest of the recoverable library.

## Storage location

`MetadataStore` resolves the platform application-support directory and stores metadata under:

```text
SonicNest/recordings.json
```

Generated audio files remain separate from this metadata file. The JSON document references managed recording paths and organizer information such as titles, tags, folders, notes, markers, waveform envelopes, favorites, pins, and Trash state.

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

Startup now checks `recordings.json.bak` as a recovery source.

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

## Corrupt metadata preservation

Structurally invalid metadata is preserved before SonicNest falls back to an empty library or a valid backup. Corrupt copies use names such as:

```text
recordings.json.corrupt.<millisecondsSinceEpoch>
```

If that name already exists, a numeric suffix is added instead of overwriting the previous diagnostic copy.

A document is considered structurally invalid when, for example:

- the JSON syntax cannot be decoded;
- the root value is not an object/map;
- the root cannot be converted to string-keyed metadata;
- the `recordings` field exists but is not a list.

An absent `recordings` field is treated as an empty but structurally valid library.

## Per-record isolation

One malformed object inside an otherwise valid `recordings` list does not invalidate the entire metadata document.

The loader:

- ignores non-map list items;
- safely decodes known fields using type-checked fallbacks;
- ignores malformed nested markers rather than rejecting the parent recording;
- filters invalid tag and waveform list members;
- accepts only entries with non-empty recording IDs and file paths.

Unexpected optional-field types fall back to safe defaults. This allows valid entries before and after a damaged record to remain available.

## Large-library automated coverage

The metadata test suite includes an end-to-end filesystem round-trip of 3,000 `RecordingEntry` objects through the real JSON save/load implementation. The test checks entry count, ordering/identity samples, and cleanup of `.tmp`/`.bak` files after a completed save.

This automated test is a deterministic regression gate. It does not replace real large-library UI profiling, memory profiling, filesystem-performance testing, or long-duration device QA, which remain separate release gates.

## Regression coverage

`test/metadata_store_test.dart` covers:

- syntactically invalid JSON backup behavior;
- structurally invalid `recordings` payload backup behavior;
- isolation of malformed entries while valid entries survive;
- recovery when an interrupted replacement leaves only `.bak`;
- recovery from a corrupt primary when a valid `.bak` exists;
- 3,000-entry save/load round-trip behavior.

`test/recording_entry_test.dart` also verifies tolerant decoding of malformed optional fields and nested metadata.

## Release boundary

Metadata recovery tests prove deterministic repository behavior only. They do not establish release readiness for low-storage failures, abrupt device power loss, filesystem permission revocation, removable-media behavior, or multi-hour/large-library performance on real target systems. Those evidence-dependent checks remain in `TODO.md` and `docs/QA_CHECKLIST.md`.
