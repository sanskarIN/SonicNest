# SonicNest Roadmap

## v0.1.x — Foundation and recorder

Completed in the current codebase:
- Cross-platform capture architecture and runtime codec fallback matrix.
- Recording lifecycle guards, foreground-service bridge, local metadata safety, import/export, and processing pipeline.
- Defensive recording-metadata decoding with malformed-record isolation.
- Structural metadata corruption preservation, interrupted `.bak` replacement recovery, valid-backup fallback, and clean-store reset when no valid metadata source remains.
- Corrupt numeric/waveform normalization plus duplicate ID/path isolation.
- Managed storage path guards and persistence rollback for library mutations.
- Startup orphan reconstruction for supported managed audio missing from metadata.
- Configurable/cancellable recording countdown.
- Smart recording-name templates with safe date/time/sequence/category/prefix/suffix tokens.
- Optional active-recording screen-wake handling with lifecycle cleanup.
- Recorder/player desktop shortcuts in addition to navigation shortcuts.
- Automated analyzer/unit-test coverage plus representative platform debug-build workflows.

Still required before leaving the foundation stage:
- Exercise permission-denied, interruption, low-storage, device-routing, screen-wake, and repeated pause/resume paths on physical devices.
- Run 30-minute and multi-hour recording soak tests on representative hardware.
- Exercise abrupt process/power interruption and filesystem-permission failures on real target systems even though deterministic metadata backup, rollback, and orphan recovery are implemented.
- Verify orphan reconstruction with real playable, partially written, and damaged managed audio on every maintained OS.

## v0.2.x — Library and playback polish

Completed:
- Persist generated waveform envelopes for imported, processed, and recovered managed media.
- Add multi-selection bulk favorite, pin, share, Trash, restore, and permanent-delete operations.
- Add format, folder, exact-tag, and date-range filtering.
- Add managed recording/Trash/temporary storage accounting and guarded temporary cleanup.
- Add failure-isolated multi-file import so missing/corrupt selections can fail independently without blocking later valid files.
- Add managed-copy cleanup after import copy/probe/waveform failures.
- Add deterministic metadata persistence coverage with a 3,000-entry filesystem save/load round-trip.
- Add managed-path mutation guards for rename, duplicate, Trash, restore, and permanent deletion.
- Add duplicate metadata ID/file-path isolation and unsafe numeric/waveform normalization.
- Add startup reconciliation that drops stale or out-of-bound metadata.
- Add managed orphan-audio reconstruction after metadata loss/interruption.
- Add persistence rollback for metadata-only and file-moving library operations.
- Add desktop keyboard navigation shortcuts.
- Add desktop secondary/right-click access to each recording's complete action surface while preserving touch and long-press behavior.
- Add previous/next recording navigation.
- Add A-B selection looping alongside repeat-one.
- Integrate Android, iOS, and macOS media-session metadata and notification/lock-screen playback controls through `just_audio_background` and tagged `MediaItem` audio sources.

Remaining:
- Run a privacy-safe malformed/corrupt audio corpus through import on each maintained OS, including mixed valid/invalid selections.
- Verify recovered managed-orphan behavior with real partial/damaged media and abrupt process interruption.
- Profile real Library startup/search/filter/scroll/memory behavior with thousands of entries; the 3,000-entry metadata round-trip is persistence evidence, not UI performance approval.
- Verify Android, iOS, and macOS media-session behavior on physical devices, including pause/resume, lock-screen transport controls, interruptions, and metadata refresh.
- Evaluate dedicated Windows and Linux system media-session integration where maintained platform support is available and useful.
- Evaluate a cursor-anchored platform-native desktop context menu only if physical desktop usability testing shows a meaningful advantage over the implemented secondary-click action surface.

## v0.3.x — Editor expansion

Completed:
- Selection handles directly on the waveform.
- Selection undo/redo/reset history UI.
- Format export presets with non-destructive output behavior.
- Keep-selection and cut-selection output copies.
- Split and merge.
- Normalization, fades, silence removal, and format conversion.
- Gain-adjusted copies and silence insertion.
- Basic FFT noise cleanup.
- Compressor and limiter processing.
- High-pass and low-pass filters.
- Bookmark-position adjustment for cut and inserted-silence copies.
- Multi-recording batch format conversion with per-file progress/failure handling and preserved source recordings.
- Direct multi-file original export to a user-selected destination with collision-safe naming and per-file failure isolation.
- Batch execution moved behind a deterministic service with per-file conversion/registration/external-copy isolation and stop-after-current semantics shared by tests and production UI.

Remaining:
- Profile multi-file conversion and direct export with large real-world libraries, low-storage conditions, permission loss, and destination disappearance.
- Tune advanced processing presets against representative voice/music recordings instead of changing filter defaults without listening tests.

## v0.4.x — Accessibility, localization, and performance

Completed/in progress:
- Responsive Material 3 layouts, semantics, reduced-motion preference, and keyboard navigation are implemented.
- Branded Flutter startup experience and recoverable startup state are implemented.
- Primary Flutter presentation surfaces are centralized in the localization catalog; English is the currently supported locale.
- Backend diagnostic/error localization policy is explicitly decided: product-facing summaries are localized while raw backend diagnostics remain technical evidence.
- Deterministic metadata stress coverage exercises 3,000 entries through the real JSON persistence path.
- User-initiated Diagnostics & QA reports provide privacy-safe runtime, aggregate library/storage, recorder-state, and settings evidence without recording content, titles, paths, notes, tags, bookmarks, smart-naming text, or input-device names.

Remaining:
- Add additional locales only with translation review, text-expansion testing, and translation QA.
- Complete screen-reader audits with VoiceOver, TalkBack, Narrator, and desktop accessibility tooling.
- Profile multi-hour recordings and real Library UI behavior with thousands of entries.
- Measure memory/CPU/storage behavior on low-resource devices.
- Profile large batch conversions and exports for throughput, storage pressure, cancellation expectations, and recovery behavior.

## v0.5.x — Cross-platform release hardening

Completed/in progress:
- Reproducible Bash and PowerShell platform bootstrapping.
- Android/Linux/Windows/macOS/iOS no-codesign automated build workflows.
- Detailed manual QA checklist, release procedure, preview release notes, release evidence template, and evidence-based remaining-work file.
- Deterministic native brand raster generation from repository-controlled SonicNest geometry.
- Reproducible Android/iOS native splash resources and Android/iOS/macOS/Windows launcher/application icon generation.
- Permanent Android/Windows/Apple workflows apply generated native branding before compiling representative builds.
- Debian `.deb` selected as the initial repository-supported Linux installation package.
- Linux desktop entry, deterministic icon installation, AppStream metadata, package builder, structural verifier, checksum generation, dedicated package CI, and release-candidate `.deb` output implemented.
- Hosted-runner Debian installation, installed-payload/startup smoke, package removal, and uninstall cleanup validation implemented.
- Initial Linux public channel selected: GitHub Releases with the verified `.deb` and SHA-256 checksum; no initial custom APT repository.
- Versioned x64 portable ZIP selected as the initial repository-supported Windows package format.
- Windows portable package builder/verifier implemented with complete Flutter bundle checks, sensitive/signing-material rejection, SHA-256/package-info output, and optional final Authenticode verification.
- Bounded extracted-Windows-package startup smoke implemented for hosted validation without claiming microphone/device quality.
- Permanent Windows CI validates debug compilation plus a release-mode unsigned portable package, structural verification, startup smoke, warning, and short-retention artifact.
- Initial Windows public channel selected: GitHub Releases with the final Authenticode-verified portable ZIP and post-signing SHA-256; Microsoft Store/MSIX/MSI/installer channels are future separate work.
- Hosted Android release candidates are explicitly inspected with `aapt`, `apksigner`, `keytool`, `jarsigner`, archive checks, and SHA-256 output; generated Android Debug-certificate artifacts are classified **NON-PRODUCTION** rather than incorrectly called unsigned.
- Initial Android public channel selected: Google Play with Play App Signing and a separate maintainer-controlled upload key; production keys/credentials remain outside the repository.
- Initial iOS public channel selected: TestFlight/App Store with maintainer-owned Apple signing/provisioning.
- Initial macOS public channel selected: signed/notarized GitHub Releases; Mac App Store is a future separate channel.
- Store/distribution listing and privacy-declaration copy is source-controlled for exact-candidate review.
- Permanent workflow allowlist/read-only integrity checks reject write scopes, require release policy/package documents, verify package/candidate markers, and parse every tracked top-level Bash/PowerShell helper.
- Canonical Dart formatting is tracked and core CI enforces formatting without mutating its checkout.
- Managed-storage/orphan-recovery source revision `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` validated by core run `31867130926`, Windows run `31867130920`, Apple run `31867130998`, and Linux Package CI run `31867130938`.
- Formatter-clean application revision `4e0fbf16534a60e2d3209c5ec5f54d4982903f8c` validated by core run `31870933447`, Windows run `31870933908`, Apple run `31870933903`, and Linux Package CI run `31870933982`.
- Windows portable package path validated by Windows run `31872155143`: debug build, release build, portable ZIP construction, package verification, checksum/package-info generation, explicit unsigned warning, and artifact upload all succeeded.
- First complete release-candidate matrix run `31872389283` passed preflight, Android, Linux, Windows, macOS, and iOS release-mode validation on source `8096d45bb0ea09cf3107e8fd80e05bf6844baf9b`; inspection of its Android artifact exposed the inaccurate historical `unsigned` label and directly led to the non-production certificate-verification correction.
- Clean repository audit run `31873122160` passed on final-validation candidate SHA `048870ec8dc26a16e2451310460d3e03c9084dc7`, including all repository invariants and top-level Bash/PowerShell helper parsing.
- Privacy-safe in-app diagnostics are documented in `docs/DIAGNOSTICS_AND_QA.md` and are intended to accompany real-device/support evidence without replacing the manual release gates.

Remaining:
- Keep Android/Linux/Windows/macOS/iOS build and release-candidate workflows green for future source revisions.
- Keep Linux Debian and Windows portable package validation green for future source revisions.
- Validate microphone input switching and codec availability on each supported OS.
- Verify background/lock-screen/interruption behavior against each platform's current policies.
- Validate countdown, screen-wake, A-B loop, media buttons, batch conversion/export, desktop secondary-click interaction, and advanced editor outputs on physical target hardware.
- Complete malformed-real-media corpus testing and real low-storage/filesystem-permission/interruption recovery evidence.
- Verify real abrupt-process/power-loss and partially written managed-audio recovery behavior instead of inferring it from deterministic regression tests.
- Visually inspect generated Android/iOS/macOS/Windows native icons and Android/iOS launch/splash resources on real release candidates.
- Install and visually inspect the generated Linux `.deb` on representative Debian/Ubuntu-family systems, including microphone/audio-stack behavior, launcher/menu/task-switcher icon surfaces, upgrade, and uninstall behavior.
- Extract and test the generated Windows portable ZIP on representative Windows systems, including microphone/routing, playback/import/export, accessibility, branding, cleanup, and final Authenticode verification.
- Provision maintainer-owned Android Play App Signing/upload-key configuration, Apple signing/provisioning/notarization configuration, and Windows Authenticode credentials/services outside the repository.
- Produce protected signed/upload candidates only in secure release environments and record exact artifact checksums after signing.
- Complete TestFlight/App Store/Google Play/store-console review using exact candidate privacy/listing data.
- Keep dependency/API compatibility pinned and documented when upstream plugins introduce breaking API or native-registration changes.
- Capture real screenshots from tested release candidates.

## v1.0.0 — Stable release

- Zero known critical/high-priority reproducible bugs.
- Manual QA checklist complete on Android, iOS, macOS, Windows, and Linux.
- Privacy/security/release documentation reviewed against the shipping build.
- Final store/release assets and signed packages prepared by the maintainer where signing is required.
- Release notes and checksums published for distributable artifacts where applicable.
- Stable tag created only from the exact tested and signed source revision.

## External batch export status

Implemented: optional user-selected destination-folder copies, collision-safe destination names, independent external-copy failure reporting, stop-after-current cancellation between converted files, and direct original-file multi-export without transcoding. Remaining work is physical/per-platform validation, low-storage/large-batch testing, and destination-permission/revocation testing.

## Localization migration status

Primary Flutter presentation surfaces are centralized in the localization catalog and English remains the baseline locale. The diagnostic policy is closed: user-facing summaries belong in localization while raw backend diagnostics stay technical evidence. Remaining localization work is deliberate translation introduction, text-expansion testing, and translation QA.

## Metadata integrity, managed recovery, and resilient import status

Implemented: defensive model decoding, unsafe numeric/waveform normalization, structurally corrupt metadata preservation, per-record and duplicate ID/path isolation, valid-backup recovery after interrupted/corrupt primary replacement, clean-store reset when no valid metadata source remains, a deterministic 3,000-entry metadata round-trip, supported-regular-audio managed-path mutation guards, controller persistence rollback, active/Trash supported-file discovery, startup orphan reconstruction, dedicated per-file import validation/cleanup, and controller-level continuation after isolated malformed/missing selections. Remaining work is real malformed/partially written media testing, abrupt-process/power-loss recovery evidence, real large-library UI/memory profiling, low-storage and filesystem-permission recovery, and representative target-system validation.

## Native branding and packaging status

Implemented: deterministic brand source generation, Android adaptive/monochrome/full launcher inputs, Android/iOS native splash resources, Android/iOS/macOS/Windows icon generation integrated into build workflows, Debian `.deb` packaging with desktop/AppStream integration and hosted install/smoke/uninstall validation, Windows versioned portable ZIP packaging with release-mode hosted build/verify/startup-smoke validation, and Android hosted release-mode package/signing-state inspection. Selected initial public channels are Google Play for Android (Play App Signing + protected upload key), TestFlight/App Store for iOS, signed/notarized GitHub Releases for macOS, GitHub Releases for Linux (`.deb` + SHA-256), and GitHub Releases for Windows (final Authenticode-verified portable ZIP + post-signing SHA-256). Remaining work is real OS-level visual/audio/accessibility inspection, representative package/install/device evidence, private signing/provisioning/notarization configuration, store submissions, real screenshots, and stable-release approval.

## Diagnostics and QA evidence status

Implemented: an About-accessible, user-initiated diagnostics screen; deterministic JSON and Markdown report serialization; explicit privacy flags; aggregate library/storage evidence; recorder-state and input-count evidence without device names; non-content recording/playback/interface settings; copy/share actions; and regression tests that inject private smart-naming text and verify it cannot appear in exported diagnostics. The report is supporting evidence only. Physical microphone/routing, interruption, background, filesystem, performance, accessibility, package, signing, and store gates remain manual or credential-dependent.

## Unified release-candidate provenance milestone — completed 2026-08-15

- [x] Add a standard-library Python builder for one machine-readable release-candidate provenance manifest.
- [x] Require and re-verify checksummed Android, Linux, Windows, macOS, and iOS hosted candidate evidence.
- [x] Bind the manifest to exact source SHA, application version, workflow run, and run attempt.
- [x] Preserve platform signing classifications and explicitly keep hosted candidates at `stableReleaseApproved: false`.
- [x] Add direct builder regression tests and repository/workflow integration tests.
- [x] Run Python release-tool regressions in the permanent Repository Integrity Audit.
- [x] Validate the complete provenance path in hosted run `31876035202`, including the final aggregation job.
- [x] Preserve exact manifest/payload hashes in source-controlled release evidence.
- [x] Return the maintained release-candidate workflow to manual dispatch after the controlled validation trigger.

No further repository-only release-automation milestone is currently identified. Next milestones remain evidence-driven: physical-device audio/lifecycle QA, real filesystem/storage recovery, accessibility, sustained performance/soak testing, representative desktop/package QA, protected production signing/notarization, store review, and final stable-release approval.
