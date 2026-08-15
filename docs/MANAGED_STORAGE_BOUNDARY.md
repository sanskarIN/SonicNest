# SonicNest Managed Storage Boundary

SonicNest treats the filesystem path stored in recording metadata as untrusted state until it is checked against the application-managed audio directories.

## Managed audio locations

Library audio is managed only under:

```text
SonicNest/Recordings
SonicNest/.trash
```

Temporary capture/processing files use a separate application temporary directory and are not considered normal Library entries.

## Mutation rules

The storage service applies these rules before path-changing or destructive Library operations:

- Rename requires a regular file inside active `Recordings`.
- Move to Trash requires a regular file inside active `Recordings`.
- Restore requires a regular file inside `.trash`.
- Duplicate requires a regular file inside either managed audio location and creates its copy in active `Recordings`.
- Permanent delete requires a path inside a managed audio location; a missing path is already deleted, while symbolic links and other non-regular entries are refused.
- Generated destination allocation treats any existing filesystem entity, including a broken symbolic link, as occupied and selects another collision-safe filename.

A path whose text is inside a managed directory is not enough to make it trusted audio. Symbolic links are not followed as managed recording files. This prevents a link placed inside managed storage from turning a Library mutation into an operation on an unrelated target outside SonicNest.

## Discovery and recovery rules

Startup recovery scans the top level of active `Recordings` and `.trash` with link following disabled.

Only regular files with represented audio extensions are candidates. Recovery does not:

- follow symbolic links;
- recurse into arbitrary nested directories;
- index unsupported extensions;
- treat an external path referenced only by metadata as managed audio.

An unindexed active managed file is reconstructed as an active `Recovered` entry. An unindexed managed Trash file is reconstructed as a trashed `Recovered` entry so interrupted permanent deletion does not silently promote it back into the active Library.

## Collision safety

Unique-path allocation checks for any filesystem entity at a candidate path rather than only checking whether a regular file exists. This avoids choosing a destination already occupied by a directory, symbolic link, broken symbolic link, or other inspectable entity.

If a candidate cannot be inspected safely, SonicNest treats it as occupied and moves to the next numbered filename instead of risking overwrite.

## Metadata reconciliation

`AppController` accepts an indexed recording at startup only when `StorageService.isManagedAudioPath(...)` confirms that the path currently resolves to a regular file in the permitted managed location. Missing files, symbolic links, non-file entries, and out-of-bound paths are not retained as active Library metadata.

This boundary is designed for local data safety. It does not claim that an application process can defend against an attacker who already has arbitrary code execution with the same operating-system privileges.

## Regression coverage

`test/storage_service_test.dart` covers:

- external-path mutation rejection;
- protected external files;
- active/Trash mutation boundaries;
- collision-safe allocation;
- broken-symbolic-link collision avoidance on supported test hosts;
- symbolic-link mutation rejection on supported test hosts;
- recovery discovery that excludes symbolic links, nested files, and unsupported files;
- active and Trash discovery isolation.

`test/library_recovery_service_test.dart` covers active/Trash orphan reconstruction and deduplication. `test/app_controller_persistence_test.dart` covers persistence rollback behavior. `test/app_controller_output_safety_test.dart` covers failed processed-output cleanup without deleting caller-supplied external files.

## Manual evidence still required

Before stable release, retain the unchecked filesystem and recovery gates in `docs/QA_CHECKLIST.md`, including low-storage behavior, permission revocation, abrupt process/device interruption, real partially written media, and representative platform filesystem behavior. Unit tests are not a substitute for those real-system observations.
