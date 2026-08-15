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
- Linux Debian package workflow run:
- Windows debug/package workflow run:
- Windows portable package verification result:
- Windows portable startup-smoke result:
- macOS build workflow run:
- iOS no-codesign build workflow run:
- Repository integrity workflow run:
- Release-candidate artifact workflow run:
- Unified release-candidate manifest job result:
- Unified manifest artifact name:
- Unified manifest artifact workflow digest:
- `RELEASE_CANDIDATE_MANIFEST.json` SHA-256:
- Manifest `sourceSha` equals exact candidate commit: Yes / No
- Manifest `applicationVersion` equals `pubspec.yaml`: Yes / No
- Manifest workflow run ID/attempt matches candidate run: Yes / No
- Manifest contains Android/Linux/Windows/macOS/iOS entries: Yes / No
- Manifest `stableReleaseApproved` is `false` for hosted development-preview evidence: Yes / No
- Platform payload checksums re-verified by manifest builder: Yes / No
- Android hosted candidate package ID:
- Android hosted candidate signing classification:
- Android hosted candidate certificate SHA-256 fingerprint:
- Android hosted `ANDROID_SIGNING_STATE.txt` reviewed: Yes / No
- Android APK artifact SHA-256:
- Android AAB artifact SHA-256:
- Linux raw-bundle artifact SHA-256:
- Linux Debian `.deb` artifact SHA-256:
- Linux package structural verification result:
- Windows portable artifact filename:
- Windows portable artifact SHA-256:
- macOS artifact SHA-256:
- iOS validation artifact SHA-256:

The unified hosted provenance manifest is an additional consistency/evidence layer. It does not replace per-platform signing verification, real-system QA, protected production signing, notarization, or store validation.

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

## Metadata, managed-storage, and recovery evidence

Use privacy-safe controlled data. Record the exact platform, filesystem conditions, candidate SHA/artifact, observation, and whether the recovered file was independently playable.

- Existing valid metadata startup result:
- Missing primary + valid `.bak` recovery result:
- Corrupt primary + valid `.bak` recovery result:
- Corrupt primary + corrupt backup preservation/reset result:
- Repeated restart after corrupt-store reset creates no repeated active-corrupt loop:
- Malformed individual metadata record isolation result:
- Duplicate recording ID isolation result:
- Duplicate normalized file-path isolation result:
- Negative/non-finite metadata normalization result:
- Out-of-managed-storage metadata path rejection result:
- Missing managed-file metadata reconciliation result:
- External file confirmed untouched by managed mutation guard:
- Rename metadata-persistence rollback result:
- Move-to-Trash metadata-persistence rollback result:
- Restore metadata-persistence rollback result:
- Permanent-delete managed-file failure metadata restoration result:
- Process interruption after managed file creation/before metadata registration:
- Recovered valid orphan visible exactly once after restart:
- Recovered valid orphan playback/export result:
- Recovered partially written/damaged orphan result:
- Unsupported/nested file excluded from orphan reconstruction:
- Low-storage recovery result:
- Filesystem permission revocation/recovery result:
- Abrupt process termination recovery result:
- Abrupt device/power interruption recovery result where safely testable:

Exact test paths/data descriptions or evidence links:

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
- Windows extracted portable-package icon surfaces:
- Linux Debian desktop-entry icon:
- Linux launcher/menu/task-switcher icon behavior:
- Real screenshots captured from this exact candidate:

Screenshot/evidence links:

## Android hosted candidate signing evidence

Record this for repository-hosted release-mode validation separately from actual Google Play production signing.

- Exact candidate SHA:
- Exact APK filename:
- Exact AAB filename:
- Package ID equals `io.github.sanskarin.sonic_nest`: Yes / No
- Application label equals `SonicNest`: Yes / No
- `tool/verify_android_nonproduction_candidate.sh` result:
- Hosted APK signer DN:
- Hosted AAB signer owner/issuer:
- Hosted certificate SHA-256 fingerprint:
- Classification recorded as Android Debug / NON-PRODUCTION: Yes / No
- APK SHA-256:
- AAB SHA-256:
- `ANDROID_SIGNING_STATE.txt` preserved with candidate artifact: Yes / No
- Confirm no Play upload key/private production signing material was present: Yes / No

A pass here does not satisfy Google Play signing or physical-device QA. The protected Play candidate must be recorded separately below.

## Windows portable package evidence

Record this separately from hosted build/package CI. A CI-created portable archive is not considered real-system validated until these observations exist on representative Windows systems.

- Windows edition/version/build:
- System architecture:
- Exact portable ZIP filename:
- SHA-256 matches candidate evidence:
- `tool/verify_windows_portable.ps1` result:
- Hosted `tool/smoke_test_windows_portable.ps1` result:
- Archive extracted completely before launch: Yes / No
- `sonic_nest.exe` launch result:
- Microphone permission/capture result:
- Built-in/USB/Bluetooth routing result where available:
- Playback/import/export result:
- Batch conversion/export result:
- Managed metadata/orphan recovery controlled test result:
- Explorer/taskbar/Start/search branding result:
- Narrator/keyboard accessibility result:
- Portable folder removal/cleanup result after closing SonicNest:
- Confirm no installer/registry/shortcut behavior was claimed by the portable channel:
- Authenticode verification required for this candidate: Yes / No
- `tool/verify_windows_portable.ps1 -RequireSignature` result, if required:
- Signer certificate subject/issuer or secure signing identity metadata, if applicable:
- Signing timestamp result, if applicable:

Notes / evidence links:

## Linux Debian installation evidence

Record this separately from CI structural verification. A CI-created `.deb` is not considered installation-tested until these observations exist on representative systems.

- Distribution and version:
- Desktop environment:
- Package architecture:
- Exact `.deb` filename:
- SHA-256 matches candidate evidence:
- Fresh install result:
- Application-menu launcher result:
- Direct `/opt/sonicnest/sonic_nest` launch result:
- Microphone permission/capture result:
- Playback/import/export result:
- Managed metadata/orphan recovery controlled test result:
- AppStream visibility/result where applicable:
- Upgrade from prior candidate result:
- Uninstall result:
- Residual application payload check:
- Existing user recording/library data preserved after package removal:

Notes / evidence links:

## Performance and stress evidence

- Library size tested:
- Managed recording-file count tested during startup orphan scan:
- Longest recording tested:
- Largest imported file tested:
- Largest batch conversion tested:
- Largest direct-export batch tested:
- Peak memory observations:
- CPU/thermal observations:
- Storage growth observations:
- Startup/orphan-scan timing observations:
- Crash/hang observations:

## Privacy/security review

- No unintended analytics/telemetry introduced:
- No automatic recording upload introduced:
- Permissions match documented need:
- Managed-path guards reviewed against the candidate source:
- Corrupt/recovery diagnostic files handled as privacy-sensitive local data:
- Privacy document matches behavior:
- Security document reviewed:
- Dependency/license notices reviewed:
- No secrets/signing material committed:

## Signing and distribution evidence

Leave credential-dependent results blank until performed in the maintainer's secure environment.

- Android selected public channel: Google Play
- Android Play App Signing enrollment/result:
- Android upload-key public certificate fingerprint:
- Android protected upload AAB SHA-256:
- Android Play testing-track upload result:
- Android Play-distributed physical-device result:
- iOS selected public channel: TestFlight / App Store
- Apple signing identity/team:
- iOS provisioning/archive result:
- TestFlight upload/distribution result:
- iOS App Store submission result:
- macOS selected public channel: signed/notarized GitHub Releases
- macOS Developer ID signing result:
- macOS notarization/stapling/verification result:
- Windows selected public channel: GitHub Releases portable ZIP
- Windows portable package Authenticode verification:
- Windows signing identity/result:
- Linux selected public channel: GitHub Releases Debian `.deb`
- Linux package/repository signing identity/result, if adopted:
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
