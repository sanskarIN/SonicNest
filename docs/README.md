# SonicNest Documentation

This directory contains the maintained technical, user, QA, branding, packaging, reliability, Web, and release documentation for SonicNest.

**🛍️ Gumroad Store:** https://ramsandesh.gumroad.com

## Start here

- [`../README.md`](../README.md) — project overview, major features, quick start, all six supported targets, and project links.
- [`USER_GUIDE.md`](USER_GUIDE.md) — complete end-user guide for the native managed-library application: recording, Library, resilient import, local metadata recovery, playback, editing, settings, batch conversion/export, privacy, and shortcuts.
- [`WEB_SUPPORT.md`](WEB_SUPPORT.md) — browser entry point, recording/playback/share capabilities, native-only capability boundaries, build/CI/release-candidate behavior, privacy, and production-hosting boundary.
- [`WEB_RELIABILITY_HARDENING_2026-08-23.md`](WEB_RELIABILITY_HARDENING_2026-08-23.md) — focused source-level hardening record for unexpected capture-stream completion, recorder-transition input locking, and in-session playback recovery, with its real-browser evidence boundary.
- [`WEB_QA_CHECKLIST.md`](WEB_QA_CHECKLIST.md) — real-browser release checks for permissions, microphones, PCM/WAV integrity, playback/share, accessibility, responsive layout, PWA behavior, privacy, and production hosting.
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — diagnosis/recovery guidance for recorder, codec, routing, import, metadata recovery, playback, export, editor, storage, branding, packaging, and build issues.
- [`FINAL_REPOSITORY_AUDIT_2026-08-19.md`](FINAL_REPOSITORY_AUDIT_2026-08-19.md) — historical repository-owned continuation audit covering release-readiness, dependency-state, critical-surface, provenance, and PR #18 integration hardening before the 2026-08-20 Web expansion.
- [`FINAL_REPOSITORY_AUDIT_2026-08-18.md`](FINAL_REPOSITORY_AUDIT_2026-08-18.md) — earlier fully green repository-owned source/tooling/open-source/documentation audit and its exact validated source revision.

## Architecture and implementation

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — six-target conditional bootstrap, native storage/recovery model, native and Web recording pipelines, audio-import/editor/batch boundaries, workflow integrity, and platform-host strategy.
- [`CODECS.md`](CODECS.md) — native format/container/encoder behavior plus the explicit Web PCM16-to-WAV capability matrix and browser constraint boundary.
- [`BUILDING.md`](BUILDING.md) — prerequisites, six-platform bootstrap, conditional shared entry point, native/Web branding, focused reliability tests, Web build/run commands, package builds, and CI/release-candidate coverage.
- [`METADATA_INTEGRITY.md`](METADATA_INTEGRITY.md) — native managed-library defensive metadata decoding, corrupt-document preservation, interrupted `.bak` recovery, per-record isolation, deterministic large-library persistence coverage, and manual evidence boundaries.
- [`DEPENDENCY_STATE.md`](DEPENDENCY_STATE.md) — canonical dependency-state source, protected `PROJECT_STATE.md` stack relationships, verifier command, current compatibility line, and validation boundary.
- [`BRANDING.md`](BRANDING.md) — deterministic SonicNest brand source and generated Android/iOS/macOS/Windows/Web plus Linux-package asset integration, with native/Web visual-QA boundaries.
- [`LINUX_PACKAGING.md`](LINUX_PACKAGING.md) — Debian `.deb` package layout, deterministic build/verification commands, desktop icon integration, hosted-runner install/startup/uninstall smoke, representative-system installation testing, and release boundaries.

## Quality assurance

- [`DIAGNOSTICS_AND_QA.md`](DIAGNOSTICS_AND_QA.md) — user-initiated privacy-safe native runtime/storage/recorder/settings diagnostics and the boundary between diagnostic context and real-device proof.
- [`MANUAL_QA_EVIDENCE.md`](MANUAL_QA_EVIDENCE.md) — local fixed-ID native manual-test status sessions, privacy contract, persistence, JSON/Markdown export, and release-evidence usage without automatic gate closure.
- [`MANUAL_QA_REVIEW_TOOLING.md`](MANUAL_QA_REVIEW_TOOLING.md) — offline structural verification of exported native manual-QA JSON, candidate/version/freshness policy options, exit codes, and explicit limits of automated evidence review.
- [`QA_CHECKLIST.md`](QA_CHECKLIST.md) — native evidence-based automated/manual QA matrix, including metadata/import automation evidence and intentionally unchecked real malformed-media, storage, performance, accessibility, hardware, and release gates.
- [`WEB_QA_CHECKLIST.md`](WEB_QA_CHECKLIST.md) — dedicated browser QA matrix for Chromium, Firefox, Safari/WebKit, microphone permissions/devices, recording lifecycle, WAV integrity, playback/share, session memory, responsive/accessibility checks, PWA behavior, HTTPS/cache/security review, and privacy.
- [`RELEASE_EVIDENCE_TEMPLATE.md`](RELEASE_EVIDENCE_TEMPLATE.md) — six-platform evidence record covering exact source/workflow/artifact provenance, native device/system observations, Web browser matrices, browser recording/WAV/share evidence, Web/PWA accessibility and branding, and production HTTPS/cache/security/rollback/deployment review.
- [`AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md`](AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md) — exact historical five-platform hosted release-candidate run, per-platform artifact checksums/digests, Android Debug-certificate classification, Windows portable startup-smoke evidence, repository-audit evidence, and the explicit boundary between automation and stable-release approval. It predates Web support.
- [`RELEASE_CANDIDATE_MANIFEST.md`](RELEASE_CANDIDATE_MANIFEST.md) — current six-platform machine-readable candidate provenance contract, per-platform checksum re-verification, source/run binding, Android non-production signing-state enforcement, Web static-bundle classification, normalized checksum identity and symlink-safe evidence rules, regression coverage, and historical five-platform evidence boundary.
- Repository issue form **Device / Release QA report** — structured GitHub report for real-device or release-candidate observations.

## Release preparation

- [`RELEASING.md`](RELEASING.md) — six-platform stable-release procedure, source preparation, branding, automated/manual native and Web gates, manual-QA JSON review, candidate provenance, signing/hosting boundaries, production Web deployment review, visual review, tagging, and publication rules.
- [`RELEASE_READINESS_REPORT.md`](RELEASE_READINESS_REPORT.md) — deterministic `TODO.md` checklist parsing, JSON/Markdown readiness snapshots, independent verification, stable-approval rules, and CI usage.
- [`UNSIGNED_ARTIFACTS.md`](UNSIGNED_ARTIFACTS.md) — purpose and limitations of non-production native artifacts plus the checksummed static Web release-candidate artifact and six-platform provenance boundary.
- [`../RELEASE_NOTES.md`](../RELEASE_NOTES.md) — development-preview release notes including metadata/import reliability and package validation boundaries.
- [`../CHANGELOG.md`](../CHANGELOG.md) — chronological project changes and exact validation evidence.
- [`../ROADMAP.md`](../ROADMAP.md) — implemented stages and remaining evidence-dependent work.
- [`../TODO.md`](../TODO.md) — only unfinished/manual/credential/hosting-dependent gates, including fresh six-platform hosted validation and real-browser release evidence.

## Privacy, security, support, and open source

- [`OPEN_SOURCE_MAINTENANCE.md`](OPEN_SOURCE_MAINTENANCE.md) — code ownership, issue routing, Dependabot, funding, contribution quality gates, and release-boundary maintenance rules.
- [`LINKS_AND_PROMOTION.md`](LINKS_AND_PROMOTION.md) — canonical Gumroad/storefront, support, repository, business, promotion, and external-link behavior.
- [`../PRIVACY.md`](../PRIVACY.md) — local-first recording/data expectations plus diagnostics/manual-evidence storage and explicit external-action boundaries. Web recording privacy/session behavior is also documented in `WEB_SUPPORT.md`.
- [`../SECURITY.md`](../SECURITY.md) — security reporting and project security expectations.
- [`../SUPPORT.md`](../SUPPORT.md) — support/contact guidance.
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — contribution workflow, focused metadata/import regression requirements, packaging validation, and quality expectations.
- [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) — community conduct policy.
- [`../LICENSE`](../LICENSE) and [`../NOTICE`](../NOTICE) — Apache License 2.0 project licensing and notices.

## Continuation/state files

- [`../PROJECT_STATE.md`](../PROJECT_STATE.md) — authoritative machine-readable/current project state, all six supported targets, historical-versus-current validation relationship, and remaining release boundaries.
- [`../what_changed.md`](../what_changed.md) — long-form additive continuation history. Do not truncate or replace prior sections; each development continuation appends its exact implementation/validation state.
- [`CONTINUATION_2026-08-19_RELEASE_READINESS.md`](CONTINUATION_2026-08-19_RELEASE_READINESS.md) — historical pre-Web checkpoint for release-readiness, dependency-state, critical-surface, symlink/checksum provenance, ambiguity/empty-evidence hardening, PR #18 integration, and the external-evidence boundary.

## Documentation rule

Documentation must distinguish these states clearly:

1. **Implemented** — present in repository source.
2. **Automated validation passed** — exercised by a recorded workflow/test/build on an exact source revision.
3. **Manually validated** — observed on specified real hardware/OS/browser/artifact with evidence.
4. **Release approved** — all required gates for the exact signed/tagged/hosted artifact are complete.

Do not use automated compilation, a checksum/provenance manifest, a diagnostic snapshot, a structurally valid manual-QA export, or a manually selected in-app status alone to claim microphone, routing, browser permission/device behavior, malformed-real-media compatibility, low-storage recovery, large-library/Web-session memory performance, background behavior, accessibility, visual branding/PWA presentation, signing, hosting, store, or stable-release success.
