# SonicNest Store and Distribution Listing Copy

This document is the source-controlled draft for public distribution metadata. It must be reviewed against the exact release candidate and the current requirements of each selected distribution channel before submission.

SonicNest is still a development preview. Do not publish this copy as a stable-release claim until `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` are satisfied.

## Product identity

**Name:** SonicNest

**Developer credit:** Made by the Sanskar

**Repository:** https://github.com/sanskarIN/SonicNest

**Support:** supportramsandesh@gmail.com

**Business:** sanskarin@outlook.in

**Secondary business:** sanskarin.business@gmail.com

**License:** Apache License 2.0

## Short description

Privacy-first sound and voice recorder with local library, playback, editing, format conversion, bookmarks, batch tools, and cross-platform support.

## Compact description

Record, organize, play, edit, convert, and export audio while keeping your recordings local by default.

## Long description

SonicNest is an offline-first sound and voice recorder designed around local ownership of your audio.

Record voice, meetings, lectures, interviews, podcasts, music, and general sound with configurable quality settings. Organize recordings with search, favorites, pins, tags, folders, notes, bookmarks, filters, and Trash. Play audio with seek, speed, volume, repeat, A–B looping, previous/next navigation, bookmarks, and platform media controls where supported.

Non-destructive audio tools create new copies instead of overwriting the source. Available processing includes trimming/keeping selections, cutting selections, splitting, merging, normalization, fades, silence operations, gain adjustment, compressor, limiter, filters, basic noise cleanup, and format conversion through the bundled processing backend.

Batch tools can convert multiple saved recordings or export original copies to a selected folder with collision-safe filenames. Conversion failures are isolated per item, and optional external-copy failures do not invalidate an already saved managed conversion.

SonicNest keeps its recording library on your device by default. It does not require an account, hidden cloud upload, advertising identifier, or analytics service for core recording and library use. Sharing or exporting audio occurs only through an explicit user action.

Supported capabilities vary by operating system, hardware, recorder backend, available codecs, and distribution package. See the project documentation for exact tested-platform evidence before relying on a particular device/codec combination.

## Feature bullets

- Start, pause, resume, stop, cancel, and optional recording countdown.
- M4A/AAC, WAV, FLAC, Opus, MP3, OGG/Vorbis, and AAC target paths where supported.
- Speech, meeting, lecture, interview, podcast, music, high-quality, lossless, small-file, and custom recording presets.
- Live level/waveform feedback, clipping indicator, elapsed timer, and recording bookmarks.
- Searchable local Library with favorites, pins, tags, folders, notes, filtering, sorting, and Trash/restore.
- Multi-file import with per-file failure isolation.
- Playback speed, volume, seek/jump, repeat-one, A–B loop, bookmarks, previous/next, and optional silence skipping.
- Non-destructive editing and audio processing.
- Sequential batch format conversion with stop-after-current behavior.
- Direct multi-file original export and collision-safe external copies.
- Light, dark, and system themes plus reduced-motion preference.
- Keyboard shortcuts and desktop secondary-click actions.
- Local metadata recovery and managed-audio orphan reconstruction after recoverable interrupted persistence states.
- Open-source Apache-2.0 project.

## Privacy summary for listings

Use this only after verifying the exact candidate contains no newly added network/analytics SDK or behavior.

### Core privacy statement

SonicNest stores recordings and its Library metadata locally by default. The core application does not require an account and does not intentionally upload microphone audio, recordings, Library metadata, or usage analytics to a SonicNest server. Audio leaves local managed storage only through an explicit user-directed action such as sharing or exporting, or through normal operating-system/platform behavior initiated by that action.

### Microphone

**Purpose:** Record audio requested by the user.

Microphone access is required only for recording features. Permission is requested/handled through the operating system. Denying microphone access prevents recording but does not require deletion of existing local recordings.

### Files and user-selected content

**Purpose:** Import audio selected by the user and export/share audio to a destination selected by the user.

SonicNest can read user-selected audio files during import and can write copies to destinations chosen through platform pickers/export surfaces. Imported content is copied into SonicNest-managed local storage before it is registered in the Library.

### Local application data

SonicNest stores local recording metadata such as title, tags, folder, notes, bookmarks, waveform envelope, technical media properties, favorites/pins, timestamps, and Trash state. Recovery diagnostics can contain some of the same local metadata and file paths.

### Network and analytics

The core repository does not intentionally include a SonicNest analytics, advertising, tracking, telemetry, account, or cloud-sync service. External links such as repository, support, business contact, or Buy Me a Coffee open only when the user chooses them and are then handled by the destination application/service under its own privacy terms.

### Sharing

When the user explicitly invokes Share, SonicNest passes the selected file(s) to the operating-system share surface. The destination selected by the user is outside SonicNest's control and can have its own data practices.

### Data sale and advertising

SonicNest does not intentionally sell user recording data and does not include advertising in the core project.

### Data deletion

Users can move recordings to SonicNest Trash, restore them, or permanently delete them. Permanent deletion is irreversible after the managed audio is actually removed. The app can preserve/reconstruct managed audio in limited interrupted-operation recovery cases; see the recovery documentation for exact behavior.

Uninstall behavior depends on the operating system and package manager. Do not promise that every OS removes every user-created/exported file, backup, diagnostic copy, or externally shared copy when SonicNest is uninstalled.

## Android / Google Play draft

### Suggested title

SonicNest – Sound & Voice Recorder

### Suggested short description

Private local audio recorder with library, playback, editing, conversion and batch export.

### Microphone permission explanation

SonicNest uses microphone access only when you start an audio recording. Recorded audio is stored locally in app-managed storage by default.

### Foreground service explanation

Where the Android foreground recording service is active, it exists to support an ongoing user-started microphone recording and expose the platform-required foreground indication. Actual background/lock-screen behavior remains subject to Android/OEM policy and must be validated on the release candidate.

### Data-safety declaration draft

For the current core repository behavior, the intended declaration is that SonicNest does not intentionally collect user audio, Library metadata, identifiers, analytics, or advertising data for transmission to a SonicNest backend. User-initiated share/export actions can transmit content to a destination chosen by the user; store-console wording must be reviewed against Google's then-current definitions before submission.

## Apple App Store draft

### Subtitle

Private sound and voice recorder

### Promotional text

Capture, organize, play, edit, convert, and export audio with an offline-first local Library.

### Microphone usage explanation

SonicNest needs microphone access to record sound and voice when you start a recording.

### Privacy-label draft

The current core project is designed without a SonicNest account, analytics, advertising, or cloud-upload service. User-created recordings and Library metadata are local by default. User-initiated sharing/export can pass selected content to another application or service. Final App Privacy answers must be reviewed against the exact signed binary, third-party SDK versions, Apple definitions, and distribution configuration.

### Background audio note

Do not claim universal background recording reliability in listing copy until the physical-device iOS lifecycle/background QA gate is complete.

## macOS distribution draft

Use the same privacy-first core description as the Apple listing. Microphone permission is required for recording. Before public distribution, complete macOS microphone/entitlement hardware verification, native icon review, accessibility checks, signing, and notarization.

## Windows distribution draft

### Suggested description

SonicNest is a local-first desktop sound and voice recorder with a searchable audio Library, playback, non-destructive processing, format conversion, batch tools, keyboard navigation, and export/share workflows.

The initial repository-supported Windows artifact is the versioned x64 portable ZIP documented in `docs/WINDOWS_PACKAGING.md`. A Microsoft Store package is not currently the selected Windows distribution channel and must not be claimed as available unless a separate store package has actually been built, reviewed, signed, and submitted.

Before public distribution, verify Windows microphone capture/routing, shell branding, accessibility, portable-package behavior, and the chosen Authenticode/public-signing policy. Do not describe an unsigned development build as a signed release.

## Linux / GitHub Releases draft

The initial public Linux channel selected by the repository is GitHub Releases using the verified Debian `.deb` plus SHA-256 checksum.

Suggested release text:

> SonicNest for Debian/Ubuntu-family Linux is provided as a repository-built Debian package. Verify the accompanying SHA-256 checksum before installation. Consult the release notes for the distributions, desktop environments, architectures, and microphone/audio-stack configurations actually tested for this release.

Do not claim an APT repository. SonicNest does not initially operate one.

Do not claim representative Linux microphone/desktop/accessibility compatibility until the corresponding candidate has been installed and tested on the environments named in the release notes.

## Screenshot and media requirements

Only use screenshots captured from the exact or materially identical tested release candidate. Do not use fabricated app screenshots as release evidence.

Before publishing screenshots:

- remove private recording names, notes, tags, paths, contacts, notifications, and personal content;
- verify all visible capabilities are actually present in the candidate;
- capture appropriate phone/tablet/desktop aspect ratios required by the channel;
- capture light/dark mode only when both have been reviewed;
- ensure native icon/splash visuals match the candidate;
- do not show signing/store approval badges that have not been earned.

## Submission review checklist

Before copying this material into any distribution console:

1. Confirm the exact tagged source revision.
2. Confirm the exact signed/unsigned status and do not overstate it.
3. Re-run dependency/privacy review against the lockfile and built artifact.
4. Re-check microphone, file picker, sharing, background-service, and media-session permissions against the candidate.
5. Re-check the channel's current privacy/data definitions; store questionnaires change over time.
6. Replace generic tested-platform language with the exact devices/OS versions recorded in release evidence.
7. Attach only real candidate screenshots.
8. Verify support/business links and email addresses.
9. Verify the Privacy Policy, Security Policy, license, notices, release notes, and checksums match the published artifact.
10. Keep any submission credentials, certificates, signing keys, API keys, or private store-console data outside this repository.
