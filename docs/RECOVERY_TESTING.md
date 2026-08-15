# SonicNest Managed Recovery Validation Guide

This guide defines reproducible validation scenarios for SonicNest metadata recovery, managed-path protection, persistence rollback, and orphan-audio reconstruction. It complements `docs/METADATA_INTEGRITY.md` and `docs/QA_CHECKLIST.md`.

Do not use personal recordings for destructive or malformed-media testing. Use privacy-safe disposable fixtures and record the exact source revision, platform, filesystem conditions, and observed result.

## Recovery invariants

SonicNest is designed around these data-preservation rules:

1. A malformed optional metadata field must not hide otherwise valid recordings.
2. A malformed individual recording record must not invalidate valid neighboring records.
3. A structurally corrupt metadata document must be preserved before fallback or reset.
4. A valid metadata backup must be recoverable after an interrupted primary replacement.
5. Duplicate recording IDs or normalized file paths must not create duplicate active library records.
6. Destructive file operations must remain inside SonicNest-managed recording or Trash storage.
7. A metadata persistence failure must roll back the corresponding in-memory mutation where possible.
8. Rename, move-to-Trash, and restore must move the audio file back when their matching metadata write fails.
9. A stopped recording whose metadata write fails must remain on disk even though its unsaved in-memory entry is removed.
10. Supported managed audio missing from metadata must be reconstructed at startup rather than remaining hidden.
11. A managed Trash file missing from metadata must be reconstructed as a Trash entry, not silently promoted to the active library.
12. Permanent deletion persists metadata removal before managed-file deletion so interruption prefers a recoverable orphan over irreversible data loss.
13. If managed-file deletion fails while the file still exists, the removed metadata entry must be restored.
14. Recovery must not recursively index arbitrary nested files or unsupported extensions.

## Automated regression suite

The repository test suite covers deterministic versions of the invariants above.

Relevant tests include:

- `test/recording_entry_test.dart`
- `test/metadata_store_test.dart`
- `test/storage_service_test.dart`
- `test/library_recovery_service_test.dart`
- `test/app_controller_persistence_test.dart`
- `test/audio_import_service_test.dart`

Run:

```bash
flutter test
```

For focused debugging:

```bash
flutter test test/recording_entry_test.dart
flutter test test/metadata_store_test.dart
flutter test test/storage_service_test.dart
flutter test test/library_recovery_service_test.dart
flutter test test/app_controller_persistence_test.dart
flutter test test/audio_import_service_test.dart
```

Also run static analysis after changing recovery or transaction code:

```bash
flutter analyze --no-fatal-infos
```

## Scenario A — interrupted metadata replacement

Goal: verify a valid `.bak` survives an interrupted primary replacement.

1. Start with a disposable library containing at least two known recordings.
2. Preserve the exact `recordings.json` and candidate SHA in the evidence record.
3. In a controlled test environment, reproduce a state where the primary is absent while `recordings.json.bak` contains the valid prior metadata document.
4. Start SonicNest.
5. Verify the backup is restored to the primary path.
6. Verify the known recordings remain present.
7. Verify the consumed backup is removed after successful recovery.
8. Restart again and verify the same recovery is not repeated unnecessarily.

Expected result: the valid backup becomes the active metadata source without deleting the audio files.

## Scenario B — corrupt primary with valid backup

Goal: verify diagnostic preservation plus backup recovery.

1. Use a disposable test library.
2. Preserve a valid `recordings.json.bak`.
3. Replace the primary with a deliberately invalid JSON document in the controlled test fixture.
4. Start SonicNest.
5. Verify a timestamped corrupt-primary diagnostic copy is preserved.
6. Verify the valid backup becomes the active primary.
7. Verify valid library entries remain available.
8. Restart and verify normal startup from the recovered primary.

Expected result: corrupt input is preserved for diagnosis while the valid backup restores the library.

## Scenario C — no valid metadata source

Goal: verify clean reset does not repeatedly reactivate the same corrupt primary.

1. Use only disposable metadata and audio fixtures.
2. Make both primary and backup structurally invalid.
3. Start SonicNest.
4. Verify both corrupt inputs are preserved as diagnostic copies.
5. Verify a structurally valid empty metadata document becomes the new primary.
6. Verify supported managed audio is reconstructed by orphan recovery.
7. Restart SonicNest.
8. Verify the old corrupt primary is not copied again as though it were still active.

Expected result: diagnostics remain available, the metadata store becomes valid, and recoverable managed audio is indexed again.

## Scenario D — stopped recording metadata failure

Goal: verify a completed audio file is not destroyed because library metadata cannot be persisted.

1. Use a controlled test build or injected persistence failure.
2. Complete a disposable recording so the managed audio file exists.
3. Cause metadata persistence to fail during `stopRecording()`.
4. Verify the operation reports failure.
5. Verify the unsaved entry is not retained in the current in-memory library.
6. Verify the managed audio file still exists.
7. Restore metadata persistence and restart SonicNest.
8. Verify the preserved file is reconstructed once as a `Recovered` active recording.

Expected result: audio preservation wins over immediate index visibility.

## Scenario E — rename persistence rollback

1. Create a disposable managed recording.
2. Inject metadata persistence failure after the filesystem rename.
3. Attempt Rename.
4. Verify the operation reports failure.
5. Verify the file returns to its original path.
6. Verify the library entry retains the original title/path.
7. Restart and verify no duplicate orphan is created.

Expected result: failed metadata persistence does not leave the file and index describing different paths.

## Scenario F — move-to-Trash persistence rollback

1. Create a disposable active recording.
2. Inject metadata persistence failure after the file moves to managed Trash.
3. Attempt Move to Trash.
4. Verify the file returns to active managed storage.
5. Verify the entry is not marked trashed.
6. Restart and verify no duplicate is reconstructed.

Expected result: the failed operation leaves the item active in both filesystem and metadata state.

## Scenario G — restore persistence rollback

1. Place a disposable recording in SonicNest Trash through normal application behavior.
2. Inject metadata persistence failure after the restore file move.
3. Attempt Restore.
4. Verify the file returns to managed Trash.
5. Verify the metadata entry remains trashed.
6. Restart and verify the item still appears once in Trash.

Expected result: failed restore does not silently promote the file without matching metadata.

## Scenario H — interrupted permanent delete from Trash

Goal: verify the metadata-first deletion ordering remains recoverable.

1. Move a disposable recording to Trash.
2. In a controlled test build, interrupt the process after metadata removal is safely persisted but before the managed Trash file is deleted.
3. Restart SonicNest.
4. Verify the remaining supported managed Trash file is discovered.
5. Verify it is reconstructed with the `Recovered` tag.
6. Verify it remains in Trash (`trashedAt` is restored) rather than appearing as an active recording.
7. Restore it and verify playback/export where the fixture is a valid audio file.
8. Restart again and verify no duplicate recovered entry appears.

Expected result: interruption during permanent deletion leaves a recoverable Trash orphan rather than an invisible or automatically active file.

## Scenario I — managed-file deletion failure

1. Place a disposable item in a state eligible for permanent deletion.
2. Force managed-file deletion to fail while the file still exists.
3. Verify SonicNest restores the removed metadata entry.
4. Verify that restored metadata is persisted.
5. Verify the file remains present.
6. Restart and verify exactly one library/Trash record represents the file.

Expected result: a failed physical delete does not leave an unindexed file during normal error handling.

## Scenario J — out-of-bound metadata path

Goal: prove metadata cannot direct destructive operations at unrelated files.

1. Create a disposable file outside SonicNest managed audio storage.
2. In a controlled metadata fixture, reference that path from a recording-shaped object.
3. Start SonicNest.
4. Verify startup reconciliation removes the unsafe metadata entry.
5. Verify the external file remains untouched.
6. Independently exercise guarded rename/duplicate/Trash/restore/delete service methods with the external path in automated tests.

Expected result: out-of-bound metadata is not trusted as a filesystem instruction.

## Scenario K — active orphan recovery

1. Place a privacy-safe supported audio file at the top level of SonicNest managed `Recordings` without a metadata entry.
2. Start SonicNest.
3. Verify exactly one new entry appears with the `Recovered` tag.
4. Verify filename-derived title, file size, and filesystem timestamp are sensible.
5. For valid media, verify best-effort duration/waveform reconstruction and normal playback/export.
6. Restart and verify no duplicate entry appears.

Expected result: the preserved managed file becomes visible again.

## Scenario L — damaged active or Trash orphan

1. Use a privacy-safe disposable supported-extension file that is intentionally incomplete or malformed.
2. Place it at the top level of managed `Recordings` or `.trash` without metadata.
3. Start SonicNest.
4. Verify recovery does not crash startup merely because duration/waveform probing fails.
5. Verify the file remains represented with unknown technical metadata where probing failed.
6. Verify an active orphan stays active and a Trash orphan stays in Trash.
7. Verify the user can intentionally export/restore/delete the preserved file as appropriate.

Expected result: media-probe failure does not convert a preserved managed file into a hidden orphan.

## Scenario M — unsupported and nested files

1. Put a non-audio/unsupported-extension file at the top level of managed `Recordings` and `.trash`.
2. Put a supported-extension file inside an arbitrary nested subdirectory.
3. Start SonicNest.
4. Verify none of those files is automatically indexed by orphan recovery.

Expected result: the recovery scanner remains narrow and does not become a general recursive filesystem importer.

## Low-storage, permission, and power-interruption evidence

Automated tests cannot truthfully establish operating-system filesystem behavior under every real failure mode. Before stable release, execute the related unchecked items in `docs/QA_CHECKLIST.md` on representative platforms:

- low-storage recording and metadata updates;
- permission/access revocation;
- abrupt process termination;
- abrupt device/power interruption where safe and practical;
- partially written real managed audio;
- large real libraries and orphan-scan timing;
- representative Debian/Ubuntu installed-package recovery behavior.

Do not convert these manual gates to checked status based only on unit tests or hosted compilation.

## Evidence to record

For every real-system recovery test, record:

- exact Git commit SHA;
- exact artifact/package and checksum where applicable;
- platform, OS version, architecture, and filesystem context;
- whether the fixture was active or in Trash;
- original file path and extension without exposing private user data;
- exact failure/interruption point;
- diagnostic metadata files produced;
- startup result;
- recovered entry state and whether it appeared exactly once;
- playback/export/restore result for valid audio;
- whether unrelated external files remained untouched;
- logs/screenshots that do not contain secrets or private recordings.

Use `docs/RELEASE_EVIDENCE_TEMPLATE.md` to attach the observations to the candidate under test.
