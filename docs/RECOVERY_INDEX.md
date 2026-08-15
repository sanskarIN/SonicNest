# SonicNest Recovery Documentation Index

Use this index when working on metadata integrity, managed-storage safety, interrupted operations, or recovered recordings.

- `METADATA_INTEGRITY.md` — persistence format, backup/reset rules, record isolation, managed-path reconciliation, and orphan-recovery contract.
- `RECOVERY_TESTING.md` — deterministic and real-system recovery scenarios, including stopped-recording persistence failure and interrupted permanent deletion.
- `ARCHITECTURE.md` — service/controller boundaries and transaction ordering.
- `TROUBLESHOOTING.md` — user/developer diagnosis for corrupt metadata, recovered recordings, and stale/out-of-bound metadata.
- `USER_GUIDE.md` — user-facing local metadata and recovery behavior.
- `QA_CHECKLIST.md` — automated evidence plus manual low-storage, permission, process/power-interruption, malformed-media, and large-library gates.
- `RELEASE_EVIDENCE_TEMPLATE.md` — fields for recording candidate-specific recovery observations.
- `SECURITY.md` — managed-path safety boundary and privacy-sensitive diagnostic-file guidance.
- `TODO.md` — evidence-dependent recovery work that cannot be truthfully closed through repository-only automation.

Recovery changes must preserve audio before index convenience, must never broaden destructive operations beyond SonicNest-managed audio storage, and must keep hardware/filesystem evidence gates separate from synthetic regression coverage.
