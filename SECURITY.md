# Security Policy

## Reporting a vulnerability

Please do not publish a security-sensitive report before maintainers have a reasonable opportunity to review it. Send a concise report to `supportramsandesh@gmail.com` including affected version, platform, reproduction conditions, impact, and suggested remediation if known.

## Security principles

SonicNest treats audio paths, imported metadata, filenames, temporary files, and share/export destinations as untrusted input. The app sanitizes generated filenames, keeps writes inside controlled directories unless the user explicitly chooses an export destination, uses atomic metadata replacement, and avoids custom cryptography.

Never include real secrets or private recordings in issue reports.
