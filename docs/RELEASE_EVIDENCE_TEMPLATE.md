# SonicNest Release Evidence Record

Use one copy of this template for each release candidate that is being considered for public distribution or production Web deployment. Do not mark an item passed without recording the exact device/browser/OS, build/artifact, and actual observation.

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
- Intended release targets: Android / iOS / macOS / Windows / Linux / Web
- Web production domain/host, if Web is in scope:

## Automated validation evidence

- Core analyzer/test workflow run:
- Android build workflow run:
- Linux build workflow run:
- Web release build workflow/job result:
- Linux Debian package workflow run:
- Windows debug/package workflow run:
- Windows portable package verification result:
- Windows portable startup-smoke result:
- macOS build workflow run:
- iOS no-codesign build workflow run:
- Repository integrity workflow run:
- Release-candidate artifact workflow run:
- Release-candidate run attempt:
- Unified release-candidate manifest job result:
- Unified manifest artifact name:
- Unified manifest artifact workflow digest:
- `RELEASE_CANDIDATE_MANIFEST.json` SHA-256:
- Manifest `sourceSha` equals exact candidate commit: Yes / No
- Manifest `applicationVersion` equals `pubspec.yaml`: Yes / No
- Manifest workflow run ID/attempt matches candidate run: Yes / No
- Manifest contains Android/Linux/Windows/macOS/iOS/Web entries: Yes / No
- Manifest Web classification says static-bundle binary signing is not applicable: Yes / No
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
- Web release-candidate archive filename:
- Web release-candidate archive SHA-256:
- Web `SHA256SUMS.txt` independently verified after download: Yes / No

The unified hosted provenance manifest is an additional consistency/evidence layer. It does not replace per-platform signing verification, real-system/browser QA, protected production signing/notarization, store validation, or production Web hosting review.

Historical five-platform manifests that predate Web support must not be recorded as evidence that the current six-platform candidate passed Web validation.

## Native manual-QA ledger review evidence

Create a fresh **About → Manual QA evidence** session for the exact native candidate/target being tested. Where runtime context is relevant, attach a fresh **Diagnostics & QA** snapshot before export.

- Manual-QA JSON evidence filename:
- Evidence collected from candidate version:
- Evidence target platform/device/OS:
- Diagnostics attached: Yes / No
- `tool/verify_manual_qa_evidence.py` structural result: Pass / Fail
- Exact verifier command/policy used:
- `--expected-version` value, if required:
- `--max-age-hours` value, if required:
- `--require-diagnostics` used: Yes / No
- `--require-all-passed` used: Yes / No
- Verifier-reported passed count:
- Verifier-reported failed count:
- Verifier-reported blocked count:
- Verifier-reported not-run count:
- Evidence JSON SHA-256, if archived:
- Human reviewer:
- Review date/time and timezone:
- Underlying manual observations/evidence reviewed separately: Yes / No

A passing structural verifier result means the exported ledger matches the current source-controlled schema/catalog and the selected review policy. It does **not** prove that any represented microphone, accessibility, stress, filesystem, branding, package, signing, or distribution test was actually performed correctly.

Web-specific manual evidence is recorded in the browser/hosting sections below and against `docs/WEB_QA_CHECKLIST.md`; the native in-app ledger must not be used as a substitute for actual browser observations.

## Native device matrix

Add a row for every tested native target. Never reuse a pass from an older source revision.

| Platform | Device / model | OS version | Input/output hardware | Build/artifact | Tester | Date | Result |
|---|---|---|---|---|---|---|---|
| Android |  |  |  |  |  |  |  |
| iOS |  |  |  |  |  |  |  |
| macOS |  |  |  |  |  |  |  |
| Windows |  |  |  |  |  |  |  |
| Linux |  |  |  |  |  |  |  |

## Web browser matrix

Record every representative browser/OS combination used to validate the exact Web candidate/deployment.

| Browser family/version | OS/device | Form factor | Candidate URL/artifact | Microphone/input | WAV playback/share | Accessibility/layout | Tester | Date | Result |
|---|---|---|---|---|---|---|---|---|---|
| Chromium |  |  |  |  |  |  |  |  |  |
| Firefox |  |  |  |  |  |  |  |  |  |
| Safari/WebKit |  |  |  |  |  |  |  |  |  |

## Native recorder lifecycle evidence

For each tested native platform record Pass / Fail / Not applicable plus notes.

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

## Native input routing evidence

Record the actual hardware used.

- Built-in microphone:
- Wired headset microphone:
- USB microphone/interface:
- Bluetooth microphone:
- Route disconnect during recording:
- Route reconnect before next recording:

Notes / evidence links:

## Native codec/output evidence

For every supported native target format tested, record platform, actual file properties, playback result inside SonicNest, and at least one external playback result.

| Format | Platform | Direct/fallback path | Actual codec/container | Duration correct | SonicNest playback | External playback | Result |
|---|---|---|---|---|---|---|---|
| M4A/AAC |  |  |  |  |  |  |  |
| WAV |  |  |  |  |  |  |  |
| FLAC |  |  |  |  |  |  |  |
| Opus |  |  |  |  |  |  |  |
| MP3 |  |  |  |  |  |  |  |
| OGG/Vorbis |  |  |  |  |  |  |  |
| AAC |  |  |  |  |  |  |  |

## Web recording and WAV evidence

Complete this section against the exact static candidate/deployment. Use `docs/WEB_QA_CHECKLIST.md` as the detailed test source.

### Permission and input

- Page load does not request microphone automatically: Pass / Fail
- First explicit recording action permission allow path:
- Permission deny path:
- Permission revoke + retry path:
- Browser default microphone:
- Input-device enumeration after permission where exposed:
- Alternate microphone selection where supported:
- Device disconnect/removal handling:

### Capture lifecycle

- Record -> Stop:
- Record -> Pause -> Resume -> Stop:
- Cancel discards unfinished capture:
- Rapid/repeated captures:
- Recorder error returns UI to usable state:
- Amplitude meter responds and remains finite/bounded:
- Timer advances only during active recording:
- Mono request result:
- Stereo request result where supported:
- Automatic gain request result where supported:
- Echo cancellation request result where supported:
- Noise suppression request result where supported:
- Effective sample rate recorded for WAV header:
- Effective channel count recorded for WAV header:

### WAV and playback

- SonicNest in-memory WAV playback:
- Playback completion returns UI to non-playing state:
- Replay same recording:
- Switch to another recording:
- Delete currently playing recording safely stops playback:
- Downloaded/shared WAV SHA-256, if archived:
- Independent external player used:
- Independent playback result:
- Observed duration vs capture duration:
- Channel/sample metadata inspected:

### Share/download

- Web Share with files result where supported:
- Download fallback result where Web Share with files is unavailable:
- Generated filename result:
- User cancellation behavior:
- Repeated share/download leaves source recording unchanged:

### Session-memory boundary

- UI explains current-session retention: Yes / No
- Refresh/close does not claim durable save: Yes / No
- Multiple-recording memory observation:
- Longest browser recording tested:
- Lower-memory mobile browser observation:
- Network inspection confirms no automatic recording upload: Yes / No

Evidence links / notes:

## Native Library, Trash, and export evidence

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

The current Web target intentionally does not claim durable native managed Library/Trash/recovery/FFmpeg batch/export behavior. Record Web share/download in the Web section rather than marking native filesystem features passed in a browser.

## Native metadata, managed-storage, and recovery evidence

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

## Native playback/media-session evidence

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

## Native editor listening evidence

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

The current Web build does not expose the native FFmpeg editor and must not be marked as having passed these native editor operations.

## Accessibility evidence

### Native

- Android TalkBack:
- iOS VoiceOver:
- macOS VoiceOver:
- Windows Narrator:
- Linux accessibility tooling:
- Keyboard-only desktop navigation:
- Large text/font scaling:
- Reduced-motion preference:
- Focus order and visible focus:

### Web

- Chromium keyboard-only navigation:
- Firefox keyboard-only navigation:
- Safari/WebKit keyboard-only navigation:
- Browser screen-reader/tool used:
- Recorder controls expose understandable labels:
- Recording row actions expose understandable labels:
- Visible focus:
- 200% browser zoom:
- Narrow mobile layout:
- Wide desktop layout:
- Light/dark/system theme:

Notes / evidence links:

## Branding evidence

### Native

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

### Web / PWA

- Browser favicon/app icon:
- Startup background/splash transition:
- High-DPI icon/rendering:
- Installed-PWA icon/launch treatment where supported:
- Mobile home-screen icon treatment where supported:
- Branding update/cache refresh result:

- Real screenshots captured from this exact candidate: Yes / No
- Screenshot/evidence links:

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

## Web production hosting evidence

Complete only when Web is in release scope. Do not record repository build success as hosting approval.

### Deployment identity

- Production domain/URL:
- Hosting provider/service:
- Deployed source commit SHA:
- Deployed version/tag:
- Exact `sonicnest-web-release.tar.gz` or deployable bundle SHA-256:
- Exact unified manifest SHA-256:
- Deployment date/time and timezone:
- Deployer/reviewer:

### Transport and delivery

- HTTPS valid on production URL: Yes / No
- HTTP -> HTTPS behavior reviewed: Yes / No / N/A
- DNS target reviewed: Yes / No
- TLS certificate/issuer/expiry reviewed without recording private material: Yes / No
- JavaScript/Wasm/static MIME types correct: Yes / No
- Compression/content delivery result:
- `index.html` cache policy reviewed: Yes / No
- Fingerprinted/static-asset cache policy reviewed: Yes / No
- Service-worker/cache update behavior tested: Yes / No
- Controlled newer deployment reaches existing clients: Yes / No
- Rollback to known-good bundle tested: Yes / No
- Security headers reviewed for compatibility and security: Yes / No

### Privacy/security

- Static bundle inspected for deployment/signing credentials: Pass / Fail
- Production network capture shows no automatic audio upload: Pass / Fail
- Production network capture shows no hidden analytics: Pass / Fail
- Microphone begins only through intended explicit user flow: Pass / Fail
- Share/download remains explicit user action: Pass / Fail
- Public source-map/debug-output policy reviewed: Yes / No
- Third-party Web dependency notices reviewed: Yes / No

### Production browser retest

- Chromium-family result:
- Firefox result:
- Safari/WebKit result:
- Mobile browser result(s):
- Production microphone permission/capture result:
- Production alternate-input result where supported:
- Production WAV playback/share/download result:
- Production responsive/accessibility result:
- Production PWA/install result where supported:

Notes / evidence links:

## Performance and stress evidence

### Native

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

### Web

- Longest browser recording tested:
- Largest in-session WAV tested:
- Maximum simultaneous in-session recordings tested:
- Browser/device memory observations:
- CPU/thermal observations on mobile browser:
- Repeated start/stop session count tested:
- Page reload/close behavior during idle capture states:
- Browser crash/hang observations:

## Privacy/security review

- No unintended analytics/telemetry introduced:
- No automatic recording upload introduced:
- Permissions match documented need:
- Native managed-path guards reviewed against the candidate source:
- Native corrupt/recovery diagnostic files handled as privacy-sensitive local data:
- Native Manual-QA evidence privacy flags structurally verified: Yes / No / N/A
- Web session-memory boundary matches `docs/WEB_SUPPORT.md`: Yes / No / N/A
- Web production network behavior reviewed: Yes / No / N/A
- Privacy document matches behavior:
- Security document reviewed:
- Dependency/license notices reviewed:
- No secrets/signing/deployment material committed or embedded in public artifacts:

## Signing, distribution, and hosting evidence

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
- Web selected production host/domain:
- Web deployment credential environment reviewed: Yes / No
- Web production HTTPS/browser/hosting approval result:
- Native store metadata/privacy declarations reviewed:
- Web public privacy/capability copy reviewed:

## Defects and disposition

List every reproducible defect found during this candidate's testing.

| ID/link | Severity | Platform/browser | Reproduction | Fixed in SHA | Retested | Disposition |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

## Final decision

- Stable-release gates complete: Yes / No
- Native release targets approved:
- Web production deployment approved: Yes / No / Not in scope
- Known critical/high-priority reproducible defects: None / List
- Exact signed/distributable/deployed source SHA:
- Exact release tag:
- Final approver:
- Approval date:

A `Yes` stable decision is valid only when the required native items in `docs/QA_CHECKLIST.md`, Web items in `docs/WEB_QA_CHECKLIST.md` where Web is in scope, and the release procedure in `docs/RELEASING.md` are complete for the same source revision and exact artifacts/deployment recorded above.
