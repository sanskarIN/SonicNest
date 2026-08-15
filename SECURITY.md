# Security Policy

## Reporting a vulnerability

Please do not publish a security-sensitive report before maintainers have a reasonable opportunity to review it. Send a concise report to `supportramsandesh@gmail.com` including affected version, platform, reproduction conditions, impact, and suggested remediation if known.

## Security principles

SonicNest treats audio paths, imported metadata, filenames, temporary files, and share/export destinations as untrusted input. The app sanitizes generated filenames, keeps ordinary managed writes inside controlled directories unless the user explicitly chooses an export destination, uses atomic-style metadata replacement, and avoids custom cryptography.

Destructive and path-changing Library operations apply an additional managed-storage boundary. Rename, duplicate, move-to-Trash, restore, and permanent-delete requests are rejected when their source is outside SonicNest's managed `Recordings`/`.trash` locations, uses an unsupported recording extension, or is not a regular file when inspected without following symbolic links. Startup reconciliation independently drops out-of-bound, missing, unsupported, symbolic-link, and other non-regular metadata references instead of trusting them as filesystem instructions.

Generated managed destinations are collision-safe against more than ordinary files. Any existing filesystem entity, including a directory, symbolic link, or broken symbolic link, occupies a candidate filename. A path that cannot be inspected safely is treated as occupied. User-selected external export folders use the same entity-aware collision principle.

Corrupt metadata is preserved for diagnostics before recovery/reset, malformed records are isolated, duplicate IDs/paths are ignored after the first valid record, and orphaned supported regular audio is recovered only from controlled top-level `Recordings` and `.trash` locations with link following disabled. Active orphans remain active; Trash orphans remain in Trash. Recovery does not recursively import arbitrary filesystem content.

Completed stopped recordings are preserved when metadata persistence fails so startup recovery can reconstruct them. Permanent deletion persists metadata removal before managed-file deletion, preferring a recoverable orphan over irreversible loss if interruption occurs between the steps. Failed processed-output and batch-registration cleanup is limited to eligible managed audio and must not delete a caller-supplied external path.

The native recorder backend is instantiated lazily when recorder-plugin functionality is actually needed. This removes constructor-time method-channel side effects from controller/service construction and deterministic tests; it does not bypass operating-system microphone permissions or production recorder-plugin checks.

These safeguards reduce path-traversal, symbolic-link, tampered-metadata, interrupted-mutation, and accidental-overwrite risk. They do not turn the local filesystem into a hostile-code sandbox and cannot protect against an attacker who already has arbitrary code execution with the same operating-system privileges. Platform permissions, operating-system access controls, dependency security, signing, and real-device validation remain part of the release security boundary.

## Diagnostic privacy

Raw operating-system, plugin, FFmpeg, filesystem, and backend diagnostic details are intentionally retained as technical evidence rather than translated or rewritten automatically. Such details can include user-created filenames, paths, titles, tags, notes, platform information, or codec messages.

Diagnostic data is not a substitute for a localized user-facing explanation and should not be uploaded automatically. Before sharing logs, screenshots, `.corrupt.*` metadata copies, or support bundles, remove private recording names, private audio, secrets, signing material, and unnecessary personal information.

See `docs/LOCALIZATION_POLICY.md` for the diagnostic-text policy and `docs/MANAGED_STORAGE_BOUNDARY.md`, `docs/METADATA_INTEGRITY.md`, and `docs/RECOVERY_TESTING.md` for the local-data safety contract.
