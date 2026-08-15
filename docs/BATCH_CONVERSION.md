# SonicNest Batch Conversion Execution Contract

Batch conversion is non-destructive: source recordings remain unchanged while each successful conversion becomes a new managed SonicNest recording. Optional external-folder copies are secondary to the managed Library transaction.

## Execution order

For each selected source, `BatchConversionService` performs this sequence:

1. Check whether a stop has already been requested.
2. Choose source technical metadata when it is known; otherwise use the current recording settings as fallback bitrate/sample-rate/channel values.
3. Transcode into a collision-safe managed SonicNest output path.
4. Register the output through the ordinary processed-file Library transaction, including media probing, waveform extraction, metadata persistence, and source markers.
5. Count the conversion as successful only after managed registration succeeds.
6. If an external destination was selected, copy the already-registered managed output to that directory using collision-safe naming.
7. Record external-copy failure separately from conversion failure.
8. Report progress after the current source has finished or failed.
9. If Stop was requested while the source was running, do not start another source.

## Failure isolation

A transcode/registration failure affects the current source only. The next source is attempted unless a stop request is active.

If a generated output exists but registration fails, cleanup is allowed only when `StorageService` confirms the output is a supported regular file in active managed recording storage. An external caller-supplied path is never deleted merely because registration fails.

An external-folder copy is deliberately secondary. Failure to copy to a removable, unavailable, permission-restricted, or otherwise failing external destination does not invalidate a conversion already committed to the managed Library.

## Stop behavior

The stop control is “Stop after current file”, not force-terminate-FFmpeg.

The service checks the stop predicate before starting each source and again after finishing the current source. This avoids intentionally killing an active encoder while it may be writing container metadata.

`BatchConvertScreen.dispose()` also raises the stop flag. If the user leaves the screen during an active conversion, the current conversion is allowed to finish and the service will not intentionally start another selected item afterward.

This source-level behavior is deterministic. Real long-running codec, navigation, OS lifecycle, and destination-loss behavior still requires representative platform validation.

## External original export

Direct original-file multi-export remains a separate operation. `ExternalActions.copyFilesToDirectoryCollisionSafe()` copies sources sequentially and preserves successful copies when another source disappears or fails.

External destination allocation treats any existing filesystem entity as occupied. Ordinary files, directories, symbolic links, and broken symbolic links therefore force a numbered alternative rather than being overwritten or followed.

## Regression coverage

`test/batch_conversion_service_test.dart` covers:

- per-file transcode failure isolation;
- generated managed-output cleanup after registration failure;
- protection of external outputs from cleanup;
- external-copy failure isolation after successful registration;
- stop-after-current behavior;
- pre-existing stop behavior;
- preference for known source bitrate/sample-rate/channel metadata over fallback settings.

`test/external_actions_test.dart` covers:

- direct copy preserving the source;
- ordinary collision-safe numbering;
- directory collisions;
- broken-symbolic-link collisions on supported hosts;
- unavailable source and destination errors;
- batch mixed-success behavior;
- independent collision-safe naming for duplicate basenames.

## Manual evidence boundary

Do not mark the real-platform batch/export gates complete from these tests alone. `TODO.md` and `docs/QA_CHECKLIST.md` still require representative evidence for:

- directory-picker behavior on every maintained platform;
- real user-folder permissions;
- destination disappearance/revocation;
- low-storage behavior;
- large and mixed-format batches;
- long conversion stop timing;
- navigation/lifecycle during processing;
- representative malformed media and actual codec failures.
