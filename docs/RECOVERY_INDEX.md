# SonicNest Recovery Documentation Index

Use this index when working on metadata integrity, managed-storage safety, interrupted operations, or recovered recordings.

- `METADATA_INTEGRITY.md` — persistence format, backup/reset rules, malformed-record isolation, managed-path reconciliation, active/Trash orphan recovery, rollback, and managed-audio accounting.
- `MANAGED_STORAGE_BOUNDARY.md` — supported regular-file rules, symbolic-link refusal, collision safety, managed mutation guards, recovery discovery, and external-copy destination safety.
- `RECOVERY_TESTING.md` — deterministic and real-system recovery scenarios, including stopped-recording persistence failure and interrupted permanent deletion.
- `ARCHITECTURE.md` — service/controller boundaries, lazy native-recorder construction, transaction ordering, orphan recovery, and batch execution structure.
- `BATCH_CONVERSION.md` — managed-registration-first conversion ordering, per-file failure isolation, protected output cleanup, and stop-after-current behavior.
- `TROUBLESHOOTING.md` — user/developer diagnosis for corrupt metadata, recovered recordings, and stale/out-of-bound metadata.
- `USER_GUIDE.md` — user-facing local metadata and recovery behavior.
- `QA_CHECKLIST.md` — automated evidence plus manual low-storage, permission, process/power-interruption, malformed-media, large-library, batch, and platform gates.
- `RELEASE_EVIDENCE_TEMPLATE.md` — fields for recording candidate-specific real-system observations.
- `../SECURITY.md` — managed-path/symlink safety, diagnostic privacy, and security-boundary guidance.
- `LOCALIZATION_POLICY.md` — localized user-facing summaries versus intentionally raw technical diagnostic evidence.
- `../TODO.md` — evidence-dependent recovery work that cannot be truthfully closed through repository-only automation.
- `../what_changed.md` — additive continuation ledger and exact project hand-off record.

Recovery changes must preserve audio before index convenience, must never broaden destructive operations beyond supported regular SonicNest-managed audio, must not follow symbolic links as recording authority, and must keep hardware/filesystem evidence gates separate from synthetic regression coverage.
