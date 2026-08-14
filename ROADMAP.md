# SonicNest Roadmap

## v0.1.x — Foundation and recorder

Completed in the current codebase:
- Cross-platform capture architecture and runtime codec fallback matrix.
- Recording lifecycle guards, foreground-service bridge, local metadata safety, import/export, and processing pipeline.
- Configurable/cancellable recording countdown.
- Smart recording-name templates with safe date/time/sequence/category/prefix/suffix tokens.
- Optional active-recording screen-wake handling with lifecycle cleanup.
- Recorder/player desktop shortcuts in addition to navigation shortcuts.
- Automated analyzer/unit-test coverage plus representative platform debug-build workflows.

Still required before leaving the foundation stage:
- Exercise permission-denied, interruption, low-storage, device-routing, screen-wake, and repeated pause/resume paths on physical devices.
- Run 30-minute and multi-hour recording soak tests on representative hardware.

## v0.2.x — Library and playback polish

Completed:
- Persist generated waveform envelopes for imported and processed media.
- Add multi-selection bulk favorite, pin, share, Trash, restore, and permanent-delete operations.
- Add format, folder, exact-tag, and date-range filtering.
- Add managed recording/Trash/temporary storage accounting and guarded temporary cleanup.
- Add desktop keyboard navigation shortcuts.
- Add desktop secondary/right-click access to each recording's complete action surface while preserving touch and long-press behavior.
- Add previous/next recording navigation.
- Add A-B selection looping alongside repeat-one.
- Integrate Android, iOS, and macOS media-session metadata and notification/lock-screen playback controls through `just_audio_background` and tagged `MediaItem` audio sources.

Remaining:
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

Remaining:
- Evaluate direct multi-file export to a user-selected external destination after real-world batch conversion and storage testing.
- Tune advanced processing presets against representative voice/music recordings instead of changing filter defaults without listening tests.

## v0.4.x — Accessibility, localization, and performance

Completed/in progress:
- Responsive Material 3 layouts, semantics, reduced-motion preference, and keyboard navigation are implemented.
- Branded Flutter startup experience and recoverable startup state are implemented.
- Localization-ready application delegate/layer is established with English as the currently supported locale.

Remaining:
- Migrate remaining hard-coded presentation strings before introducing additional languages.
- Complete screen-reader audits with VoiceOver, TalkBack, Narrator, and desktop accessibility tooling.
- Profile multi-hour recordings and libraries with thousands of entries.
- Measure memory/CPU/storage behavior on low-resource devices.
- Profile large batch conversions for throughput, storage pressure, cancellation expectations, and recovery behavior.
- Validate text expansion and large-font layouts before adding translated locales.

## v0.5.x — Cross-platform release hardening

Completed/in progress:
- Reproducible Bash and PowerShell platform bootstrapping.
- Android/Linux/Windows/macOS/unsigned-iOS automated build workflows.
- Detailed manual QA checklist, release procedure, preview release notes, and evidence-based remaining-work file.
- Current batch-conversion/right-click source revision validated by analyzer/tests plus Android, Linux, Windows, macOS, and unsigned iOS debug builds.

Remaining:
- Keep Android/Linux/Windows/macOS/iOS build workflows green for the final source revision.
- Validate microphone input switching and codec availability on each supported OS.
- Verify background/lock-screen/interruption behavior against each platform's current policies.
- Validate countdown, screen-wake, A-B loop, media buttons, batch conversion, desktop secondary-click interaction, and advanced editor outputs on physical target hardware.
- Prepare reproducible release-build checks before signing is introduced.
- Keep dependency/API compatibility pinned and documented when upstream plugins introduce breaking API or native-registration changes.
- Capture real screenshots and review final native icon/launch assets from tested release candidates.

## v1.0.0 — Stable release

- Zero known critical/high-priority reproducible bugs.
- Manual QA checklist complete on Android, iOS, macOS, Windows, and Linux.
- Privacy/security/release documentation reviewed against the shipping build.
- Final store/release assets and signed packages prepared by the maintainer.
- Release notes and checksums published for distributable artifacts where applicable.
- Stable tag created only from the exact tested and signed source revision.


## External batch export status

Implemented: optional user-selected destination-folder copies, collision-safe destination names, independent external-copy failure reporting, and stop-after-current cancellation between files. Remaining work is physical/per-platform validation, low-storage/large-batch testing, and deciding whether any richer destination/export workflow is justified by real use.


## Localization migration status

Primary Flutter presentation surfaces are centralized in the localization catalog and English remains the baseline locale. Remaining localization work is translation introduction, text-expansion testing, translation QA, and deciding how much backend diagnostic text should be localized versus retained as technical detail.
