# SonicNest Windows Signing Policy

## Decision

Public stable Windows distributables should be **Authenticode-signed** with a maintainer-controlled code-signing identity whose private key is never committed to this repository.

Unsigned Windows debug and hosted validation builds remain acceptable for development and CI evidence, but they must be labeled as unsigned development/release-candidate artifacts and must not be represented as a final trusted public Windows release.

## Credential boundary

Private keys, certificate passwords, hardware-token credentials, cloud-signing credentials, account tokens, and exported PFX/PKCS#12 files are maintainer-owned secrets.

They must not be:

- committed to Git;
- embedded in Dart/Flutter source;
- written into checked-in workflow YAML;
- attached to issues or release notes;
- included in public CI artifacts;
- copied into `what_changed.md`, logs, screenshots, or support bundles.

If CI-based signing is adopted, use a dedicated secure signing service or protected secret/identity mechanism that does not expose the private key to untrusted pull-request jobs.

## Artifact rule

The exact Windows artifact intended for public distribution must be signed after deterministic build inputs are fixed and before its final checksum/evidence record is published.

A public Windows release record should identify:

- SonicNest version and Git tag;
- exact source commit;
- artifact filename and architecture;
- SHA-256 checksum of the distributed signed artifact;
- signing-certificate subject/issuer or other non-secret identity information needed for verification;
- signing timestamp information when available;
- Windows versions/architectures actually tested;
- installer/package format actually distributed.

Do not reuse a checksum from an unsigned pre-sign artifact after signing changes its bytes.

## Verification rule

Before publication, validate the final signed artifact on representative Windows systems and confirm:

- the signature is reported as valid by Windows tooling/shell properties;
- the publisher identity shown to users matches the intended maintainer identity;
- the signature remains valid after downloading the exact release artifact;
- install/launch/uninstall behavior matches the intended package/installer;
- Explorer, taskbar, Start/search, shortcut, and installer branding remains correct;
- microphone capture/routing and core SonicNest behavior still work in the signed package;
- accessibility and update behavior are tested for the chosen distribution path.

## Timestamping

When the selected signing provider/certificate supports trusted timestamping, the public signing process should use it. The exact timestamp service and command must be documented only after the maintainer selects/provisions the signing identity; the repository should not invent provider-specific values before that decision exists.

## CI boundary

Current repository Windows CI is a compilation/branding validation path, not a production-signing environment. It intentionally does not require private signing credentials.

A future signing workflow may be added only after the maintainer has selected and provisioned the certificate/signing service. It should be restricted to protected release contexts and should never expose secrets to forks or ordinary pull requests.

## Remaining maintainer action

This policy decision is complete. Actual signing configuration remains intentionally open because it requires maintainer-owned certificate/signing-service credentials and a final Windows distribution package/installer decision. See `TODO.md` and `docs/RELEASING.md`.
