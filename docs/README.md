# SonicNest Documentation

This directory contains the maintained technical, user, QA, branding, packaging, reliability, and release documentation for SonicNest.

**🛍️ Gumroad Store:** https://ramsandesh.gumroad.com

## Start here

- [`../README.md`](../README.md) — project overview, major features, quick start, supported platforms, and project links.
- [`USER_GUIDE.md`](USER_GUIDE.md) — complete end-user guide for recording, Library, resilient import, local metadata recovery, playback, editing, settings, batch conversion/export, privacy, and shortcuts.
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — diagnosis/recovery guidance for recorder, codec, routing, import, metadata recovery, playback, export, editor, storage, branding, packaging, and build issues.
- [`FINAL_REPOSITORY_AUDIT_2026-08-18.md`](FINAL_REPOSITORY_AUDIT_2026-08-18.md) — final repository-owned source/tooling/open-source/documentation audit and the remaining manual/credential-dependent release boundary.

## Architecture and implementation

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — application layers, storage/recovery model, recording pipeline, audio-import transaction, editor pipeline, workflow-integrity boundary, and platform-host strategy.
- [`CODECS.md`](CODECS.md) — format/container/encoder behavior, native capability checks, fallback/transcoding rules, and codec limitations.
- [`BUILDING.md`](BUILDING.md) — development prerequisites, platform bootstrap, native-brand generation, focused reliability tests, verification commands, and platform build commands.
- [`METADATA_INTEGRITY.md`](METADATA_INTEGRITY.md) — defensive metadata decoding, corrupt-document preservation, interrupted `.bak` recovery, per-record isolation, deterministic large-library persistence coverage, and manual evidence boundaries.
- [`DEPENDENCY_STATE.md`](DEPENDENCY_STATE.md) — canonical dependency-state source, protected `PROJECT_STATE.md` stack relationships, verifier command, current compatibility line, and validation boundary.
- [`BRANDING.md`](BRANDING.md) — deterministic SonicNest brand source and generated native asset integration.
- [`LINUX_PACKAGING.md`](LINUX_PACKAGING.md) — Debian `.deb` package layout, deterministic build/verification commands, desktop icon integration, hosted-runner install/startup/uninstall smoke, representative-system installation testing, and release boundaries.

## Quality assurance

- [`DIAGNOSTICS_AND_QA.md`](DIAGNOSTICS_AND_QA.md) — user-initiated privacy-safe runtime/storage/recorder/settings diagnostics and the boundary between diagnostic context and real-device proof.
- [`MANUAL_QA_EVIDENCE.md`](MANUAL_QA_EVIDENCE.md) — local fixed-ID manual-test status sessions, privacy contract, persistence, JSON/Markdown export, and release-evidence usage without automatic gate closure.
- [`MANUAL_QA_REVIEW_TOOLING.md`](MANUAL_QA_REVIEW_TOOLING.md) — offline structural verification of exported manual-QA JSON, candidate/version/freshness policy options, exit codes, and explicit limits of automated evidence review.
- [`QA_CHECKLIST.md`](QA_CHECKLIST.md) — complete evidence-based automated/manual QA matrix, including metadata/import automation evidence and intentionally unchecked real malformed-media, storage, performance, accessibility, hardware, and release gates.
- [`RELEASE_EVIDENCE_TEMPLATE.md`](RELEASE_EVIDENCE_TEMPLATE.md) — structured record for exact commit, workflow, artifact, device, OS, microphone, routing, codec, accessibility, branding, performance, signing, and final-release evidence.
- [`AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md`](AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md) — exact hosted release-candidate run, per-platform artifact checksums/digests, Android Debug-certificate classification, Windows portable startup-smoke evidence, repository-audit evidence, and the explicit boundary between automation and stable-release approval.
- [`RELEASE_CANDIDATE_MANIFEST.md`](RELEASE_CANDIDATE_MANIFEST.md) — machine-readable candidate provenance design, per-platform checksum re-verification, source/run binding, Android non-production signing-state enforcement, regression coverage, and the stable-release evidence boundary.
- Repository issue form **Device / Release QA report** — structured GitHub report for real-device or release-candidate observations.

## Release preparation

- [`RELEASING.md`](RELEASING.md) — stable-release procedure, source preparation, branding, automated/manual gates, manual-QA JSON structural review, signing boundaries, candidate builds, visual review, tagging, and publication rules.
- [`UNSIGNED_ARTIFACTS.md`](UNSIGNED_ARTIFACTS.md) — purpose and limitations of the manual unsigned/non-production release-candidate workflow and its checksummed validation artifacts.
- [`../RELEASE_NOTES.md`](../RELEASE_NOTES.md) — development-preview release notes including metadata/import reliability and package validation boundaries.
- [`../CHANGELOG.md`](../CHANGELOG.md) — chronological project changes and exact validation evidence.
- [`../ROADMAP.md`](../ROADMAP.md) — implemented stages and remaining evidence-dependent work.
- [`../TODO.md`](../TODO.md) — only unfinished/manual/credential-dependent gates, with deterministic reliability baselines separated from real-system validation.

## Privacy, security, support, and open source

- [`OPEN_SOURCE_MAINTENANCE.md`](OPEN_SOURCE_MAINTENANCE.md) — code ownership, issue routing, Dependabot, funding, contribution quality gates, and release-boundary maintenance rules.
- [`LINKS_AND_PROMOTION.md`](LINKS_AND_PROMOTION.md) — canonical Gumroad/storefront, support, repository, business, promotion, and external-link behavior.
- [`../PRIVACY.md`](../PRIVACY.md) — local-first recording/data expectations plus diagnostics/manual-evidence storage and explicit external-action boundaries.
- [`../SECURITY.md`](../SECURITY.md) — security reporting and project security expectations.
- [`../SUPPORT.md`](../SUPPORT.md) — support/contact guidance.
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — contribution workflow, focused metadata/import regression requirements, packaging validation, and quality expectations.
- [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) — community conduct policy.
- [`../LICENSE`](../LICENSE) and [`../NOTICE`](../NOTICE) — Apache License 2.0 project licensing and notices.

## Continuation/state files

- [`../PROJECT_STATE.md`](../PROJECT_STATE.md) — compact machine-readable/current project state and validation boundaries.
- [`../what_changed.md`](../what_changed.md) — long-form additive continuation history. Do not truncate or replace prior sections; each development continuation appends its exact implementation/validation state.

## Documentation rule

Documentation must distinguish these states clearly:

1. **Implemented** — present in repository source.
2. **Automated validation passed** — exercised by a recorded workflow/test/build on an exact source revision.
3. **Manually validated** — observed on specified real hardware/OS/artifact with evidence.
4. **Release approved** — all required gates for the exact signed/tagged artifact are complete.

Do not use automated compilation, a diagnostic snapshot, a structurally valid manual-QA export, or a manually selected in-app status alone to claim microphone, routing, malformed-real-media compatibility, low-storage recovery, large-library UI performance, background behavior, accessibility, visual-branding, signing, store, or stable-release success.
