# SonicNest Linux Distribution Policy

## Initial public channel

The first repository-supported public Linux distribution channel is **GitHub Releases** using the deterministic Debian `.deb` package produced by the existing SonicNest Linux package workflow.

SonicNest does not initially operate a custom APT repository. This keeps the first Linux distribution path aligned with the package format, CI verification, checksums, release notes, and source revision already managed in this repository without introducing an unmaintained package-index service.

## Published Linux artifacts

A publishable Linux release should include, for the exact tagged revision:

- the verified SonicNest `.deb` artifact;
- SHA-256 checksum data generated for that artifact;
- release notes identifying supported/tested Debian/Ubuntu-family environments;
- the source tag/commit used to build the package;
- installation and uninstall guidance;
- any known platform limitations discovered during real-system QA.

The package must be built and verified by the maintained repository tooling before publication.

## Signing policy

There is no APT repository in the initial channel, so repository-index signing is not applicable.

The committed repository must never contain private signing keys. Development-preview and hosted CI packages can remain unsigned and must be labeled accordingly.

For a stable public release:

- the release source must be an annotated semantic-version tag;
- the package/checksum relationship must be reproducible and documented;
- any detached artifact signature or signed-tag policy adopted by the maintainer must use credentials stored outside the repository;
- a signature must never be claimed unless the published artifact was actually signed and the verification method is documented.

A future move to a maintained APT repository requires a separate explicit decision covering repository ownership, update cadence, metadata generation, signing-key custody/rotation, revocation, mirrors/CDN behavior, and upgrade testing. That future possibility does not block the initial GitHub Releases channel.

## Release classification

GitHub Releases is the selected distribution location, but SonicNest remains a development preview until the manual release gates in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` are completed. Selecting a channel does not convert CI artifacts into stable releases.
