# SonicNest Release Notes

## v0.1.0 — Development Preview

SonicNest is an offline-first cross-platform sound and voice recorder built with Flutter. This development preview establishes the recorder, recording library, playback, editing, native branding, Linux packaging, metadata recovery, managed-audio orphan reconstruction, resilient import, platform bootstrap, CI, privacy, and open-source foundations required for later stable releases.

### Recorder

- Start, configurable/cancellable countdown, pause, resume, stop, save, and discard recordings.
- Runtime encoder capability checks with native capture when available and safe post-recording conversion fallback when needed.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and AAC format paths.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom presets.
- Bitrate, sample-rate, channel, automatic-gain, echo-cancellation, and noise-suppression preferences.
- Input-device enumeration and selection where the recorder backend exposes devices.
- Recording timer, waveform/amplitude display, clipping warning, and bookmarks.
- Smart recording-name templates with date, time, sequence, category, prefix, and suffix tokens.
- Optional keep-screen-awake behavior during active recording with lifecycle cleanup.
- Android foreground recording-service integration through reproducible platform overrides.

### Library and storage

- Search recording titles, folders, tags, notes, and bookmark text.
- Sort by date, title, duration, and file size.
- Filter by scope, format, folder, exact tag, and date range.
- Favorites, pins, folders, tags, notes, multi-select, and bulk actions.
- Trash, restore, permanent deletion, and empty-Trash workflow.
- Import, duplicate, export copy, and system sharing.
- Multi-file import validates selections independently and cleans copied managed files when copy/probe/waveform processing fails, allowing later valid selections to continue.
- Recording metadata tolerates malformed optional fields and malformed individual records instead of allowing one damaged object to block Library startup.
- Unsafe negative/non-finite numeric metadata is normalized, malformed waveform members are filtered, and recovered waveform samples are bounded.
- Structurally corrupt metadata is preserved to timestamped diagnostic copies, valid `.bak` metadata can recover an interrupted replacement or a corrupt primary, and an unrecoverable store is reset to a clean valid document after diagnostics are preserved.
- Duplicate recording IDs and duplicate normalized file paths are isolated after the first valid entry.
- Startup reconciliation rejects metadata entries outside SonicNest-managed recording/Trash paths or entries referencing missing files.
- Managed-storage mutation guards prevent rename, duplicate, Trash, restore, and permanent-delete operations from acting on unrelated external paths.
- Startup orphan recovery reconstructs metadata for supported audio that still exists in the managed `Recordings` directory but is missing from the JSON index, including best-effort recovery for damaged/partial media when probing or waveform extraction fails.
- Library mutation persistence is rollback-aware: metadata-only updates restore prior state on save failure, file moves are rolled back when their metadata update fails, and permanent deletion persists metadata first so an interruption prefers a recoverable orphan over irreversible data loss.
- Multi-recording batch format conversion with target-format selection, progress, per-file failure isolation, retained source recordings, and successful-output registration in the managed library.
- Direct multi-file original export to a user-selected folder without transcoding, with collision-safe destination naming and per-file failure isolation.
- Desktop secondary/right-click access to recording actions while preserving touch and explicit menu interactions.
- Managed storage accounting for recordings, Trash, and temporary processing files.

### Playback

- Play, pause, stop, seek, jump, volume, speed, repeat-one, and optional silence skipping.
- Previous/next recording navigation.
- A–B selection looping.
- Bookmark seeking.
- Media-session metadata/background playback integration on supported mobile/Apple targets.

### Non-destructive editor

- Keep/trim selection, cut selection, split, and merge.
- Format conversion.
- Normalization, fade in/out, and silence removal.
- Gain-adjusted copies and silence insertion.
- Basic FFT noise cleanup.
- High-pass and low-pass filters.
- Compressor and limiter processing.
- Undo/redo/reset for editor selection changes.
- Original recordings are not overwritten by editor operations.

### Experience

- Material 3 responsive phone/tablet/desktop layouts.
- Light, dark, and system themes.
- Reduced-motion preference and semantic labels.
- Keyboard navigation and recorder/player desktop shortcuts.
- Branded Flutter startup screen with error recovery.
- Primary Flutter presentation centralized in the localization catalog; English is currently shipped.
- Deterministic native launcher/application branding for Android, iOS, macOS, and Windows from repository-controlled SonicNest mark geometry.
- Reproducible native Android/iOS splash resources, including Android 12+ launch configuration and light/dark launch colors.
- Debian `.deb` package integration for Linux with a desktop launcher, AppStream metadata, deterministic SonicNest icon installation, licensing notices, and checksum generation.
- About, privacy, support, GitHub, and Buy Me a Coffee integration.

### Project quality

- Reproducible host-project bootstrap for Android, iOS, macOS, Windows, and Linux.
- Reproducible native-brand generation via Bash and PowerShell helpers.
- GitHub Actions for analyzer/unit tests plus representative platform debug builds that apply native branding before Android, Windows, macOS, and iOS compilation.
- Dedicated Linux package CI builds a release-mode Flutter bundle, creates and structurally verifies the Debian package, installs it through the package manager, verifies installed metadata/payload, smoke-starts the packaged GUI under a bounded virtual display, removes the package, verifies package-owned integration cleanup, and publishes a short-retention validation artifact.
- Manual release-candidate automation includes Android release-mode non-production APK/AAB, Linux release bundle and `.deb`, Windows release portable ZIP, macOS release archive, and iOS no-codesign release archive without treating any hosted artifact as public-release approval.
- Android hosted release candidates are package/signature-verified and explicitly classified as **NON-PRODUCTION** because Flutter's generated release build uses the Android Debug certificate until protected maintainer signing is configured.
- Windows portable-package automation builds from the complete release runner bundle, structurally verifies the archive, performs a bounded extracted-package startup smoke, and records checksum/package metadata.
- Exact hosted candidate hashes, workflow artifact digests, and Android certificate fingerprints are source-controlled in `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md`.
- Metadata regression tests cover invalid JSON, invalid document structure, malformed-record isolation, corrupt numeric/waveform normalization, duplicate ID/path isolation, interrupted backup recovery, corrupt-primary fallback, clean reset when no valid store remains, and a deterministic 3,000-entry filesystem round-trip.
- Managed-storage tests cover protected external paths, collision-safe path allocation, and supported managed-file discovery.
- Orphan-recovery tests cover known-entry deduplication, damaged-media best-effort reconstruction, and every represented recording format.
- Import regression tests cover successful managed import plus cleanup after selected-source copy, media-probe, and waveform-extraction failures.
- Repository integrity rejects unapproved temporary/one-shot workflow files under both `.yml` and `.yaml`, rejects permanent workflow write scopes including `permissions: write-all`, and requires the maintained release-evidence/policy documents.
- Native-branding source revision `40c4a758debef136c2d8c977c321446cca2697cd` passed deterministic branding generation, analyzer/unit tests, Android and Linux core builds in run `31776174696`, Windows debug build in run `31776174725`, and macOS/unsigned-iOS debug builds in run `31776174715`.
- Linux Debian package source revision `a07468b4b7c14a76b9bce537bbe0455e4539e6bf` passed release Linux compilation, Debian package construction, structural verification, desktop/AppStream validation, checksum verification, package inspection, package-manager installation, installed-payload validation, virtual-display startup smoke, package-manager removal, uninstall cleanup verification, and artifact upload in run `31785105648`.
- Metadata/import reliability revision `a88aeadadda017b0aced4dbc25c8426a27364b77` passed formatting, analyzer, unit tests, Android debug APK, and Linux debug build in core run `31807193932`; the cross-platform controller revision `3bf63e69186a7a538f7d0587f3d361e00c2e29e9` also passed Windows run `31807141053` and Apple run `31807141166` for Windows, macOS, and unsigned-iOS debug builds.
- Managed-storage/orphan-recovery source revision `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` passed formatting, static analysis, the complete unit-test suite, Android debug APK, and Linux debug build in core run `31867130926`; Windows run `31867130920` passed; Apple run `31867130998` passed for macOS and unsigned iOS; Linux Package CI run `31867130938` passed the release build, Debian verification/install/startup/uninstall path and artifact upload.
- Formatter-clean source revision `4e0fbf16534a60e2d3209c5ec5f54d4982903f8c` passed core run `31870933447`, Windows run `31870933908`, Apple run `31870933903`, and Linux Package CI run `31870933982`.
- Final hosted release-candidate source revision `048870ec8dc26a16e2451310460d3e03c9084dc7` passed Release Candidate Validation run `31873121457` across source preflight and all five release-mode platform artifact jobs.
- Permanent Windows Build run `31872928500` independently passed Windows debug plus release portable build, verification, extracted startup smoke, and artifact publication.
- Clean candidate Repository Integrity Audit run `31873122160` passed on `048870ec8dc26a16e2451310460d3e03c9084dc7`; strengthened audit run `31874506476` passed after `.yaml` and write-all/write-scope hardening.
- Apache-2.0 license, contribution/security/privacy/support documentation, architecture/build/branding/codec/Linux-packaging/metadata-integrity/QA documentation, distribution policies, and release procedure.

## Before v1.0.0

This preview must not be treated as a stable public recorder release until the physical-device, interruption, background, low-storage, abrupt-process/power-loss recovery, real damaged/partial-media recovery, long-recording, malformed-real-media corpus, large-library performance, batch-performance, accessibility, native-brand visual-inspection, representative Linux/Windows package testing, protected Android/Apple/Windows signing/notarization, store/release, and final approval gates in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` have been completed with real evidence.

### Batch export destination update

- Batch Convert can optionally copy successful converted files into a user-selected folder.
- Selected original recordings can also be copied directly to a user-selected folder without transcoding.
- Existing destination files are protected with collision-safe numbered names.
- External-copy failures are reported independently from managed conversion failures.
- Long conversion batches can stop safely after the current file instead of intentionally interrupting an in-progress output write.

### Native branding update

- SonicNest native launcher/splash raster sources are generated deterministically from project-controlled mark geometry rather than maintained as drifting binary source files.
- Android adaptive/full/monochrome launcher inputs, iOS icons, macOS icons, Windows icons, and Android/iOS native splash resources are generated reproducibly.
- Generated branding compiled successfully in representative Android, Windows, macOS, and unsigned-iOS debug builds.
- Final visual approval remains a real release-candidate QA task, especially for launcher masks/crops, Windows shell surfaces, Apple small icon sizes, dark-mode launch screens, Linux desktop icon surfaces, and final signed packages.

### Linux Debian packaging update

- Debian `.deb` is the initial repository-supported Linux installation format.
- The package installs the complete Flutter bundle under `/opt/sonicnest`, a freedesktop desktop entry, the generated SonicNest icon in the hicolor icon hierarchy, AppStream metadata, LICENSE, and NOTICE.
- Package construction derives the release version from `pubspec.yaml`, preserves architecture metadata, and writes a SHA-256 checksum beside the `.deb`.
- A dedicated verifier checks package control metadata, executable permissions, desktop launcher identity, AppStream identity, icon presence, and checksum integrity, with `desktop-file-validate` and `appstreamcli` validation when available.
- Linux Package CI additionally installs the generated package through `apt-get`, validates the installed payload, starts the packaged application under a bounded Xvfb display, removes the package, and verifies package-owned application/desktop/icon/AppStream cleanup.
- Recovery-hardening source `f48fb1a11bc449bdcb6864e2bbae9fa86ab17abe` passed the complete current Linux package workflow in run `31867130938`.
- Stable Linux release approval still requires representative real-system installation, launch, microphone/routing, accessibility, long-duration/low-storage, icon visual, upgrade/uninstall, and distribution/signing-policy evidence.

### Metadata integrity, managed recovery, and resilient import update

- Recording metadata deserialization type-checks optional fields, filters malformed collection members, isolates malformed nested markers and recording objects, and normalizes unsafe numeric/waveform values.
- Structurally corrupt metadata documents are preserved with timestamped diagnostic copies instead of being silently discarded.
- Interrupted metadata replacement can recover a valid `recordings.json.bak`; a corrupt primary can also fall back to a valid backup after preserving the corrupt primary.
- When no valid primary/backup remains, SonicNest preserves diagnostics and writes a clean empty metadata store so the same corrupt primary does not repeatedly re-trigger recovery on every startup.
- Duplicate recording IDs and normalized file paths are isolated, and startup removes stale/out-of-bound metadata before managed orphan scanning.
- The metadata regression suite exercises a real filesystem save/load path with 3,000 entries while checking ordering/identity samples and temporary/backup cleanup.
- Audio import validation has a dedicated service that owns managed-copy validation and cleanup after probe/waveform failures.
- Multi-file import continues after isolated missing/corrupt selections and reports partial success while keeping metadata persistence failures fail-fast and transactional for the just-created managed copy.
- Managed-path mutation guards prevent metadata from directing destructive library operations at unrelated external paths.
- Rename/Trash/restore and metadata-only updates roll back their in-memory/filesystem changes when metadata persistence fails; permanent delete uses metadata-first ordering so an interrupted operation leaves an orphan that can be rediscovered rather than silently destroying unindexed audio.
- `LibraryRecoveryService` reconstructs missing metadata for supported managed recordings at startup and keeps damaged/partial preserved files visible even when duration/waveform probing cannot succeed.
- Real malformed-media corpora, abrupt-power/process-kill, low-storage/filesystem-permission recovery, real damaged/partial orphan media, and real large-library UI/memory profiling remain manual release gates rather than being inferred from synthetic tests.

## 2026-08-15 — Managed storage, recovery, batch, and release-policy hardening

This development-preview continuation tightens the local-data boundary and makes the tested batch path the production batch path. Managed recording authority now requires a supported regular audio file in SonicNest-managed active/Trash storage; symbolic links, directories, unsupported regular files, missing paths, and external paths are not trusted as recording instructions. Startup reconciliation and orphan recovery preserve active-versus-Trash state, and recording/Trash accounting follows the same supported top-level regular-audio definition.

External copy allocation is now entity-aware, so directories and broken symbolic links occupy names just like existing files. `BatchConversionService` owns sequential conversion, managed registration, optional external copy, failure isolation, generated-output cleanup, progress, and stop-after-current semantics; `BatchConvertScreen` uses that service directly. Leaving the screen requests stop after the current item instead of intentionally starting another selected conversion.

`RecorderService` now lazily creates the native `AudioRecorder` backend. Controller/service construction no longer touches the native method channel until recorder functionality is requested, which removes a unit-test/native-channel coupling without bypassing microphone permission or production recorder checks.

The project also now has explicit policy decisions for future localization and Linux distribution. Product-facing text is localized while raw OS/plugin/FFmpeg/filesystem diagnostics remain technical evidence. The initial public Linux channel is GitHub Releases with the verified Debian `.deb` and SHA-256 checksum; SonicNest does not initially operate a custom APT repository and does not claim signing that has not actually been performed with maintainer-owned credentials.

Validation evidence: core run `31870224720` is green on revision `e47b290a7255f126cfcf1436444a90cc32d10823` for static analysis, all 87 unit tests, Android debug, and Linux debug. Windows run `31870087266`, Apple run `31870087249`, and Linux Package CI run `31870087317` are green on application-code revision `72797fa477b9d88e2138b7ddf1d0f845cdd549ca`; the later `e47b290...` change corrects only a persistence test fixture.

The earlier formatter-hygiene warning exposed by that run is now historical: canonical formatter output was later committed and CI was converted to a non-mutating enforcement gate. Physical-device, filesystem-failure, accessibility, long-duration, representative-package, signing, and stable-release evidence remains intentionally incomplete.

## 2026-08-15 — Formatter-clean source and distribution policy completion

The earlier formatting-hygiene warning is now resolved. Canonical stable-toolchain Dart formatter output was committed in `22c1d46e077625d6e1964d56716700727d1800dc`, and core CI was changed in `704b0f60aae8f179f4f41875c336d2052b45391e` to verify formatting without rewriting the checkout.

Formatter-clean source revision `4e0fbf16534a60e2d3209c5ec5f54d4982903f8c` passed the complete maintained automated matrix used in this continuation: core run `31870933447` passed the non-mutating format gate, static analysis, full unit suite, Android debug, and Linux debug; Windows run `31870933908` passed; Apple run `31870933903` passed macOS debug and unsigned-iOS debug; Linux Package CI run `31870933982` passed release-bundle creation, Debian package build/verification, installation, installed-app smoke, uninstall, and artifact publication.

The repository also now contains `docs/STORE_LISTING.md` with cross-platform listing/privacy copy and `docs/WINDOWS_SIGNING_POLICY.md` defining Authenticode signing as the policy for stable public Windows distributables. Actual store-console submission, private signing credentials, final public packages, and signed release candidates remain maintainer/release-candidate work.

This does not change the release classification: SonicNest remains a development preview until the unchecked physical-device, real-filesystem, accessibility, long-duration/performance, visual-branding, representative-package, signing/notarization, and final stable-release gates are completed with evidence.

## 2026-08-15 — Final hosted cross-platform release-candidate evidence

A clean release-candidate source revision `048870ec8dc26a16e2451310460d3e03c9084dc7` completed Release Candidate Validation run `31873121457` successfully across all maintained hosted jobs: source preflight, Android release-mode non-production APK/AAB, Linux release bundle and Debian package, Windows release portable ZIP with structural verification and extracted startup smoke, macOS release archive, and iOS release no-codesign archive.

The Android signing state is now recorded accurately rather than described as unsigned. Hosted APK/AAB validation confirmed package `io.github.sanskarin.sonic_nest`, label `SonicNest`, and Android Debug certificate `C=US, O=Android, CN=Android Debug`; the certificate SHA-256 is `ccbfe6b04e1859cf9064c9e5a2c8f9fe1d73be92e6ef1454142b9d2fbfff89e1`. The APK SHA-256 is `1fe7ea48d771209f4bfea097fc7d9e723cff00411b2541ee848e7ec20d6c271e` and the AAB SHA-256 is `ecaf9842980b17af06f3b3f90898d286a3b38ebf0b15259271af2f07dab72f4f`. These are explicitly **NON-PRODUCTION** candidates and do not replace Play App Signing/upload-key work.

The same candidate produced Linux bundle SHA-256 `a5fe64b440bf19b1b8a74e5a5ff875e645c2da7661bd8492e1a910160de179f8`, Debian package SHA-256 `414f11ad877c7c51861a14817cd3900d2bb77d3b49ea949d601e3686d5346498`, Windows portable ZIP SHA-256 `60f5680548b0352d5230b6d40acc17a8b8b12d075b2ce1fd08c6209f565e3eb1`, macOS archive SHA-256 `364c0d8f84c2779c45a36e13fd59d6bbcceebe03f62662a41dc4e2f9178d4af3`, and iOS no-codesign archive SHA-256 `8d1209b94aa1aaff4369dff041ace9698bf4dcd5e0e6363a0fd470c50ee2e54d`.

Permanent Windows Build run `31872928500` independently passed the release portable build, verification, extracted startup smoke, and artifact publication path. Repository Integrity Audit run `31873122160` passed on the clean candidate SHA. A later hardening commit `64c121fa0e5c81531a3710b1d67b88fb3dfc93db` broadened workflow discovery to `.yaml` as well as `.yml` and rejects `permissions: write-all` plus permanent write scopes; audit run `31874506476` passed that strengthened policy.

Exact workflow artifact digests and the full automated/manual boundary are preserved in `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md`. This evidence closes the currently identified repository-owned release-automation work; it does **not** close physical-device, real-system package, accessibility, sustained recording/performance, protected signing/notarization, store-console, or stable-release approval gates.

## 2026-08-15 — Unified hosted release-candidate provenance

SonicNest now produces a machine-readable provenance record after all five hosted release-mode platform jobs succeed. `tool/build_release_candidate_manifest.py` re-verifies each platform candidate's checksum evidence, requires Android's explicit Debug-certificate / NON-PRODUCTION classification, records evidence-file SHA-256 values and sizes, and binds the result to the exact full Git source SHA, application version, GitHub Actions run, and run attempt.

The permanent Repository Integrity Audit compiles Python release helpers and runs the release-tool regression suite. Run `31876149473` passed all **10/10** Python tests together with repository invariants and Bash/PowerShell helper parsing.

Hosted Release Candidate Validation run `31876035202` on source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c` passed Source preflight, Android, Linux, Windows, macOS, iOS, and the final **Unified candidate provenance manifest** job.

The generated `RELEASE_CANDIDATE_MANIFEST.json` records application version `0.1.0+1`, release classification `development-preview`, and `stableReleaseApproved: false`. Its SHA-256 is `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`; an independent post-download recomputation matched exactly. The manifest workflow artifact digest is `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`.

This evidence proves hosted checksum/source/run consistency only. It does not complete physical microphone/routing/interruption/background validation, real storage/process-failure testing, accessibility, sustained performance/soak tests, real visual review/screenshots, representative-system package QA, protected production signing/notarization, store acceptance, or final `v1.0.0` approval. SonicNest remains a **development preview**.


## 2026-08-16 — Privacy-safe Diagnostics & QA evidence

SonicNest now includes an About-accessible **Diagnostics & QA** screen for reproducible physical-device, support, storage, lifecycle, and accessibility evidence. Diagnostics are generated only when the user opens or refreshes the screen. SonicNest does not automatically upload a report.

The report can be copied as deterministic JSON or shared as Markdown. It records the SonicNest version/build, platform/runtime information, aggregate Library counts, managed-storage totals and probe status, recorder state, input-device count when safely available, default-versus-custom input selection, and non-content recording/playback/interface preferences needed to reproduce behavior.

The privacy contract intentionally excludes recording/audio content, recording titles, file paths, notes, tags, bookmarks, smart-naming prefix/template/suffix/category text, and input-device names. Input enumeration contributes only a count and selected-input class, and SonicNest skips that probe while recording is active so opening diagnostics does not introduce another recorder-backend enumeration during capture.

App version metadata is centralized in `AppConstants`, and About plus diagnostics now consume the same canonical version/build source. `docs/DIAGNOSTICS_AND_QA.md`, `README.md`, `TODO.md`, and `ROADMAP.md` document the evidence workflow and clearly state that a generated report does not close microphone, routing, interruption, background, low-storage/filesystem, performance, accessibility, signing, package, store, or other real-target release gates.

Regression coverage injects private smart-naming sentinel text and verifies that neither JSON nor Markdown can serialize it; verifies the exact explicit privacy flags; verifies deterministic report sections; verifies unavailable probe behavior without invented values; and covers the diagnostics localization catalog.

Hosted validation for source `00e78d27ebc68f9aa743d8fab5f2ef11f3ee6910` is Flutter CI run `31932491771`: the non-mutating Dart formatter gate passed with **59 files / 0 changed**, static analysis reported **No issues found**, the complete unit suite passed **94/94 tests**, the Linux debug build passed, and the Android debug APK build passed.

The 2026-08-15 five-platform release-candidate/provenance artifacts predate this diagnostics feature. Their hashes and signing classifications remain valid evidence for their exact historical source revisions, but they are not presented as release artifacts containing the 2026-08-16 diagnostics implementation. Stable-release approval remains blocked on the existing real-device, sustained-workload, accessibility, protected-signing, distribution-console, and final-approval gates.

## 2026-08-16 — Manual QA evidence sessions

SonicNest now includes an About-accessible **Manual QA evidence** workflow for the remaining real-device/system release checks. The source-controlled catalog groups microphone/lifecycle, reliability/stress, desktop interaction, accessibility/UX, branding/package, and external-export evidence. Each check is recorded as `notRun`, `passed`, `failed`, or `blocked` with a UTC timestamp.

The versioned local session uses `sonicnest.qaEvidenceSession.v1`. Unknown/stale check IDs are discarded during load/save, the current catalog ID set is immutable at runtime, malformed/unsupported persisted sessions fall back to a fresh session, reset clears recorded statuses, and UI status writes are serialized so two selections cannot overwrite one another from the same previous state.

Evidence exports are deterministic JSON or user-shared Markdown. The bundle contains fixed check IDs/status/timestamps and explicit privacy flags; it does not collect free-form tester notes, recording content, recording titles, file paths, notes/tags/bookmarks, smart-naming text, or input-device names. **Diagnostics & QA → Open QA evidence with this snapshot** passes the current privacy-safe diagnostic report into the manual evidence bundle; **About → Manual QA evidence** remains usable without diagnostics. No evidence is automatically uploaded.

Validation of this milestone also exposed and fixed a repository bootstrap/CI invariant: `flutter create .` could rewrite tracked `analysis_options.yaml` before the permanent formatting gate, which changed Dart formatter behavior for unrelated tracked files. Bash and PowerShell bootstrap now preserve the tracked analyzer configuration, core CI validates committed formatting before generated host state, and regression tests lock both contracts.

Automated evidence: core Flutter CI run `31934843541` on source `0eb56abad482c8c296d9f80ef060ebddbba95e7b` passed committed-source formatting, static analysis, the complete unit suite, Android debug compilation, and Linux debug compilation. Production UI revision `87c91697c9b11358e03334b3e642cbcb3959dc1c` passed Apple run `31934094160` (macOS and no-codesign iOS), Windows run `31934094196` (debug plus release portable package build/verify/startup smoke), and Linux Package CI run `31934094139` (release bundle, Debian package build/verify/install/startup smoke/uninstall).

These tools improve evidence quality; they do **not** close microphone/routing, interruption/background, low-storage/filesystem, sustained-performance, accessibility, representative package, signing/notarization, store-console, or stable-release gates by themselves.
