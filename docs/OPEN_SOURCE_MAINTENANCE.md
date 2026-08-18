# SonicNest Open-Source Maintenance Guide

SonicNest is maintained as a public Apache-2.0 open-source project. This guide defines the repository-side maintenance surfaces that contributors and maintainers should use so project changes remain reviewable, testable, and aligned with the development-preview release boundary.

## Repository ownership

`.github/CODEOWNERS` assigns the default repository review owner to `@sanskarIN`. Code ownership is a review-routing mechanism; it does not replace CI, security review, release evidence, or protected signing approval.

## Issues

Use the structured issue forms under `.github/ISSUE_TEMPLATE/`:

- **Bug report** for reproducible software defects.
- **Feature request** for product or engineering proposals.
- **Device / Release QA report** for real-device, accessibility, package, or release-candidate observations.

Blank issues are disabled through `.github/ISSUE_TEMPLATE/config.yml` so reports are routed through the appropriate evidence fields. Security and support contact links are provided separately so sensitive vulnerabilities are not encouraged into ordinary public bug reports.

## Pull requests

Use `.github/pull_request_template.md` and keep changes focused. A pull request should:

1. explain the problem and the chosen boundary;
2. include or update deterministic regression coverage when behavior changes;
3. preserve the non-mutating formatter gate;
4. preserve repository workflow read-only permissions unless a separately reviewed release process explicitly requires otherwise;
5. distinguish code/build evidence from physical-device or protected-release evidence;
6. update user/developer documentation when behavior or supported workflows change.

## Dependency maintenance

`.github/dependabot.yml` performs weekly version-update checks for:

- Dart/Flutter packages from the root `pubspec.yaml` / lockfile; and
- GitHub Actions referenced by maintained workflows.

Dependabot pull requests are proposals, not automatic approval. Dependency updates must still pass SonicNest formatter, analyzer, unit, repository-integrity, platform-build, package, and any affected manual QA gates before they are accepted.

Pinned compatibility dependencies should not be widened only to make an update bot quiet. If an update is intentionally deferred, document the compatibility reason in the pull request or relevant project documentation.

## Funding and storefront links

`.github/FUNDING.yml` exposes the project’s optional support destinations:

- Gumroad: `https://ramsandesh.gumroad.com`
- Buy Me a Coffee: `https://buymeacoffee.com/sanskarIN`

Funding is optional and is never required to use SonicNest’s recorder, Library, playback, editing, recovery, export, diagnostics, QA evidence, or open-source code.

## Security

Follow `../SECURITY.md` for vulnerability reporting and disclosure expectations. Do not include credentials, signing keys, tokens, private certificates, private user data, recording content, or other sensitive material in issues, pull requests, logs, diagnostics, or test fixtures.

Permanent repository workflows must remain within the workflow allowlist and read-only permission policy enforced by `tool/repository_audit.py`.

## Quality gates

Repository-owned changes should preserve these automated gates where applicable:

- committed Dart formatting;
- Flutter static analysis;
- Flutter unit/regression tests;
- Repository Integrity Audit and Python tooling tests;
- Android and Linux core builds;
- Windows build/package checks;
- macOS and unsigned iOS build checks;
- Linux Debian package build/verification;
- release-candidate provenance tooling when the release workflow itself changes.

A green hosted build does not by itself prove microphone routing, background/lifecycle behavior, real low-storage recovery, accessibility, long-duration stability, native visual correctness, protected signing, notarization, store-console acceptance, or stable-release approval.

## Documentation map

Use `docs/README.md` as the maintained documentation index. Important maintenance references include:

- `../CONTRIBUTING.md`
- `../SECURITY.md`
- `../SUPPORT.md`
- `BUILDING.md`
- `QA_CHECKLIST.md`
- `RELEASING.md`
- `RELEASE_EVIDENCE_TEMPLATE.md`
- `MANUAL_QA_EVIDENCE.md`
- `MANUAL_QA_REVIEW_TOOLING.md`
- `RELIABILITY_HARDENING_2026-08-18.md`

## Release boundary

SonicNest remains a **development preview** until the unchecked evidence/credential gates in `../TODO.md`, `QA_CHECKLIST.md`, and `RELEASING.md` are completed for the exact candidate being approved. Open-source maintenance automation should reduce repository risk without converting those real-world gates into synthetic checkmarks.
