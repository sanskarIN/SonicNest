# SonicNest Release Evidence Record

Use one copy of this template for each release candidate that is being considered for public distribution. Do not mark an item passed without recording the device, OS, build, and actual observation.

## Candidate identity

- Candidate version:
- Git commit SHA:
- Git tag, if any:
- Build date/time and timezone:
- Flutter version:
- Dart version:
- Dependency lock/source state reviewed: Yes / No
- `what_changed.md` reviewed against this commit: Yes / No
- `PROJECT_STATE.md` reviewed against this commit: Yes / No

## Automated validation evidence

- Core analyzer/test workflow run:
- Android build workflow run:
- Linux build workflow run:
- Windows build workflow run:
- macOS build workflow run:
- unsigned iOS build workflow run:
- Release-candidate artifact workflow run:
- Android artifact SHA-256:
- Linux artifact SHA-256:
- Windows artifact SHA-256:
- macOS artifact SHA-256:
- iOS validation artifact SHA-256:

## Device matrix

Add a row for every tested target. Never reuse a pass from an older source revision.

| Platform | Device / model | OS version | Input/output hardware | Build/artifact | Tester | Date | Result |
|---|---|---|---|---|---|---|---|
| Android |  |  |  |  |  |  |  |
| iOS |  |  |  |  |  |  |  |
| macOS |  |  |  |  |  |  |  |
| Windows |  |  |  |  |  |  |  |
| Linux |  |  |  |  |  |  |  |

## Recorder lifecycle evidence

For each tested platform record Pass / Fail / Not applicable plus notes.

- First microphone permission grant:
- Permission denied:
- Permission revoked after prior grant:
- Start -> Stop:
- Start -> Pause -> Resume -> Stop:
- Countdown start:
- Countdown cancel:
- Discard/cancel active capture:
- Rapid repeated start/stop:
- Rapid repeated pause/resume:
- Screen lock while recording:
- Background/foreground transition:
- Incoming call/alarm/audio-focus interruption:
- Low-storage recording failure/recovery:
- 30-minute recording:
- Multi-hour recording:

Notes / evidence links:

## Input routing evidence

Record the actual hardware used.

- Built-in microphone:
- Wired headset microphone:
- USB microphone/interface:
- Bluetooth microphone:
- Route disconnect during recording:
- Route reconnect before next recording:

Notes / evidence links:

## Codec/output evidence

For every supported target format tested, record platform, actual file properties, playback result inside SonicNest, and at least one external playback result.

| Format | Platform | Direct/fallback path | Actual codec/container | Duration correct | SonicNest playback | External playback | Result |
|---|---|---|---|---|---|---|---|
| M4A/AAC |  |  |  |  |  |  |  |
| WAV |  |  |  |  |  |  |  |
| FLAC |  |  |  |  |  |  |  |
| Opus |  |  |  |  |  |  |  |
| MP3 |  |  |  |  |  |  |  |
| OGG/Vorbis |  |  |  |  |  |  |  |
| AAC |  |  |  |  |  |  |  |

## Library, Trash, and export evidence

- Search/sort/filter behavior:
- Exact tag/date filters:
- Favorites/pins/folders/tags/notes:
- Rename/duplicate:
- Import valid media:
- Reject malformed/unsupported media:
- Trash/restore:
- Permanent delete:
- Bulk actions:
- Direct multi-file original export:
- Collision-safe external naming:
- Mixed-success external export:
- Batch conversion:
- Stop-after-current batch behavior:
- Low-storage batch/export behavior:

Notes / evidence links:

## Playback/media-session evidence

- Play/pause/seek:
- Speed/volume:
- Previous/next:
- Repeat-one:
- A-B loop:
- Skip silence where supported:
- Bookmarks:
- Android lock-screen/notification controls:
- iOS lock-screen/Control Center controls:
- macOS media controls:
- Headphone/Bluetooth media buttons:
- Disconnect/reconnect behavior:

Notes / evidence links:

## Editor listening evidence

Use representative voice and music recordings. Record actual source files or reproducible descriptions where privacy permits.

- Keep selection:
- Cut selection:
- Split:
- Merge:
- Normalize:
- Fade:
- Remove silence:
- Insert silence:
- Gain decrease/increase:
- Noise cleanup:
- Compressor:
- Limiter:
- High-pass:
- Low-pass:
- Format conversion:
- Original file confirmed unchanged:

Listening notes / artifacts:

## Accessibility evidence

- Android TalkBack:
- iOS VoiceOver:
- macOS VoiceOver:
- Windows Narrator:
- Linux accessibility tooling:
- Keyboard-only desktop navigation:
- Large text/font scaling:
- Reduced-motion preference:
- Focus order and visible focus:

Notes / evidence links:

## Native branding evidence

- Android legacy icon:
- Android adaptive masks:
- Android themed/monochrome icon:
- Android pre-12 launch screen:
- Android 12+ launch screen:
- Android light/dark launch appearance:
- iOS icon at home-screen and smaller system sizes:
- iOS light/dark launch screen:
- macOS Finder/Dock/Spotlight/app switcher:
- Windows Explorer/taskbar/Start/shortcut:
- Linux package/desktop-entry icon:
- Real screenshots captured from this exact candidate:

Screenshot/evidence links:

## Performance and stress evidence

- Library size tested:
- Longest recording tested:
- Largest imported file tested:
- Largest batch conversion tested:
- Largest direct-export batch tested:
- Peak memory observations:
- CPU/thermal observations:
- Storage growth observations:
- Crash/hang observations:

## Privacy/security review

- No unintended analytics/telemetry introduced:
- No automatic recording upload introduced:
- Permissions match documented need:
- Privacy document matches behavior:
- Security document reviewed:
- Dependency/license notices reviewed:
- No secrets/signing material committed:

## Signing and distribution evidence

Leave blank until performed in the maintainer's secure environment.

- Android signing identity/fingerprint:
- Android Play upload/internal-test result:
- Apple signing identity/team:
- iOS provisioning result:
- macOS notarization result:
- Windows signing identity/result:
- Linux package/signing target/result:
- Store metadata/privacy declarations reviewed:

## Defects and disposition

List every reproducible defect found during this candidate's testing.

| ID/link | Severity | Platform | Reproduction | Fixed in SHA | Retested | Disposition |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

## Final decision

- Stable-release gates complete: Yes / No
- Known critical/high-priority reproducible defects: None / List
- Exact signed/distributable source SHA:
- Exact release tag:
- Final approver:
- Approval date:

A `Yes` decision is valid only when the required items in `docs/QA_CHECKLIST.md` and `docs/RELEASING.md` are complete for the same source revision and artifacts recorded above.
