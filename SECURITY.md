# Security Policy

## Reporting a vulnerability

Please do not publish a security-sensitive report before maintainers have a reasonable opportunity to review it. Send a concise report to `supportramsandesh@gmail.com` including affected version, platform, reproduction conditions, impact, and suggested remediation if known.

## Security principles

SonicNest treats audio paths, imported metadata, filenames, temporary files, and share/export destinations as untrusted input. The app sanitizes generated filenames, keeps writes inside controlled directories unless the user explicitly chooses an export destination, uses atomic-style metadata replacement, and avoids custom cryptography.

Destructive and path-changing library operations apply an additional managed-storage boundary. Rename, duplicate, move-to-Trash, restore, and permanent-delete requests are rejected when their source path is outside SonicNest's managed `Recordings`/`.trash` locations. Startup reconciliation also drops out-of-bound metadata references instead of trusting them as filesystem instructions.

Corrupt metadata is preserved for diagnostics before recovery/reset, malformed records are isolated, duplicate IDs/paths are ignored after the first valid record, and orphaned supported audio is recovered only from the controlled top-level `Recordings` directory. Recovery does not recursively import arbitrary filesystem content.

These checks reduce path-traversal and tampered-metadata risk but do not make the local filesystem a hostile-code sandbox. Platform permissions, operating-system access controls, dependency security, signing, and real-device validation remain part of the release security boundary.

Never include real secrets or private recordings in issue reports.
