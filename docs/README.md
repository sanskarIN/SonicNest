# SonicNest Documentation

This directory contains the maintained technical, user, QA, branding, packaging, and release documentation for SonicNest.

## Start here

- [`../README.md`](../README.md) — project overview, major features, quick start, supported platforms, and project links.
- [`USER_GUIDE.md`](USER_GUIDE.md) — complete end-user guide for recording, Library, playback, editing, settings, batch conversion/export, privacy, and shortcuts.
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — diagnosis/recovery guidance for recorder, codec, routing, playback, export, editor, storage, branding, and build issues.

## Architecture and implementation

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — application layers, storage model, recording pipeline, editor pipeline, and platform-host strategy.
- [`CODECS.md`](CODECS.md) — format/container/encoder behavior, native capability checks, fallback/transcoding rules, and codec limitations.
- [`BUILDING.md`](BUILDING.md) — development prerequisites, platform bootstrap, native-brand generation, verification commands, and platform build commands.
- [`BRANDING.md`](BRANDING.md) — deterministic SonicNest brand source and generated native asset integration.
- [`LINUX_PACKAGING.md`](LINUX_PACKAGING.md) — Debian `.deb` package layout, deterministic build/verification commands, desktop icon integration, installation testing, and release boundaries.

## Quality assurance

- [`QA_CHECKLIST.md`](QA_CHECKLIST.md) — complete evidence-based automated/manual QA matrix. Hardware-required boxes remain unchecked until tested on real targets.
- [`RELEASE_EVIDENCE_TEMPLATE.md`](RELEASE_EVIDENCE_TEMPLATE.md) — structured record for exact commit, workflow, artifact, device, OS, microphone, routing, codec, accessibility, branding, performance, signing, and final-release evidence.
- Repository issue form **Device / Release QA report** — structured GitHub report for real-device or release-candidate observations.

## Release preparation

- [`RELEASING.md`](RELEASING.md) — stable-release procedure, source preparation, branding, automated/manual gates, signing boundaries, candidate builds, visual review, tagging, and publication rules.
- [`UNSIGNED_ARTIFACTS.md`](UNSIGNED_ARTIFACTS.md) — purpose and limitations of the manual unsigned release-candidate workflow and its checksummed validation artifacts.
- [`../RELEASE_NOTES.md`](../RELEASE_NOTES.md) — development-preview release notes.
- [`../CHANGELOG.md`](../CHANGELOG.md) — chronological project changes.
- [`../ROADMAP.md`](../ROADMAP.md) — implemented stages and remaining evidence-dependent work.
- [`../TODO.md`](../TODO.md) — only unfinished/manual/credential-dependent gates.

## Privacy, security, support, and open source

- [`../PRIVACY.md`](../PRIVACY.md) — local-first recording/data expectations and explicit external-action boundaries.
- [`../SECURITY.md`](../SECURITY.md) — security reporting and project security expectations.
- [`../SUPPORT.md`](../SUPPORT.md) — support/contact guidance.
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — contribution workflow and quality expectations.
- [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) — community conduct policy.
- [`../LICENSE`](../LICENSE) and [`../NOTICE`](../NOTICE) — Apache License 2.0 project licensing and notices.

## Continuation/state files

- [`../PROJECT_STATE.md`](../PROJECT_STATE.md) — compact machine-readable/current project state and validation boundaries.
- [`../what_changed.md`](../what_changed.md) — long-form additive continuation history. Do not truncate or replace prior sections.

## Documentation rule

Documentation must distinguish these states clearly:

1. **Implemented** — present in repository source.
2. **Automated validation passed** — exercised by a recorded workflow/test/build on an exact source revision.
3. **Manually validated** — observed on specified real hardware/OS/artifact with evidence.
4. **Release approved** — all required gates for the exact signed/tagged artifact are complete.

Do not use automated compilation alone to claim microphone, routing, background, accessibility, visual-branding, signing, store, or stable-release success.
