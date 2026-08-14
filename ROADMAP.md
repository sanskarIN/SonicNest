# SonicNest Roadmap

## v0.1.x — Foundation and recorder

Completed in the current codebase:
- Cross-platform capture architecture and runtime codec fallback matrix.
- Recording lifecycle guards, foreground-service bridge, local metadata safety, import/export, and processing pipeline.
- Automated analyzer/unit-test coverage plus Android and Linux debug-build validation.

Still required before leaving the foundation stage:
- Exercise permission-denied, interruption, low-storage, device-routing, and repeated pause/resume paths on physical devices.
- Run 30-minute and multi-hour recording soak tests on representative hardware.

## v0.2.x — Library and playback polish

Completed:
- Persist generated waveform envelopes for imported and processed media.
- Add multi-selection bulk favorite, pin, share, trash, restore, and permanent-delete operations.
- Add desktop keyboard navigation shortcuts.
- Integrate Android, iOS, and macOS media-session metadata and notification/lock-screen playback controls through `just_audio_background` and tagged `MediaItem` audio sources.

Remaining:
- Verify Android, iOS, and macOS media-session behavior on physical devices, including pause/resume, lock-screen transport controls, interruptions, and metadata refresh.
- Evaluate dedicated Windows and Linux system media-session integration where maintained platform support is available and useful.
- Add richer desktop right-click/context-menu affordances where they improve native ergonomics.

## v0.3.x — Editor expansion

Completed:
- Add selection handles directly on the waveform.
- Add selection undo/redo/reset history UI.
- Add format export presets and keep all edits non-destructive.

Remaining:
- Evaluate true multi-file batch conversion/export after real-world library testing.

## v0.4.x — Accessibility/performance

In progress:
- Responsive Material 3 layouts, semantics, reduced-motion preference, and keyboard navigation are implemented.

Remaining:
- Complete screen-reader audits with VoiceOver, TalkBack, Narrator, and desktop accessibility tooling.
- Profile multi-hour recordings and libraries with thousands of entries.
- Measure memory/CPU/storage behavior on low-resource devices.

## v0.5.x — Cross-platform release hardening

- Keep Android/Linux/Windows/macOS/iOS build workflows green.
- Validate microphone input switching and codec availability on each supported OS.
- Verify background/lock-screen/interruption behavior against each platform's current policies.
- Prepare reproducible unsigned release-build checks before signing is introduced.
- Keep dependency/API compatibility pinned and documented when upstream plugins introduce breaking API or native-registration changes.

## v1.0.0 — Stable release

- Zero known critical/high-priority reproducible bugs.
- Manual QA checklist complete on Android, iOS, macOS, Windows, and Linux.
- Privacy/security/release documentation reviewed against the shipping build.
- Final store/release assets and signed packages prepared by the maintainer.
- Release notes and checksums published for distributable artifacts where applicable.
