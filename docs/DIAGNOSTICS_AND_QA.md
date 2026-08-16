# SonicNest Diagnostics & QA

SonicNest includes an in-app **Diagnostics & QA** surface to make physical-device, desktop, lifecycle, accessibility, storage, and support testing reproducible without collecting recording content.

## Open the diagnostics screen

1. Launch SonicNest.
2. Open **About**.
3. Select **Diagnostics & QA**.
4. Use **Refresh diagnostics** after changing a device, recorder setting, storage state, or test condition.
5. Use **Copy JSON** for machine-readable evidence or **Share report** for a Markdown report.

The report is created only when the user opens or refreshes this screen. SonicNest does not automatically upload diagnostics.

## Privacy contract

The diagnostics report intentionally excludes:

- audio/recording content;
- recording titles;
- recording file paths;
- notes, tags, and bookmarks;
- smart-naming prefix, suffix, category, and filename template text;
- input-device names.

Input enumeration contributes only a device count and whether the selected input is the system default or a custom selection. This keeps routing evidence useful while avoiding unnecessary device-name disclosure.

The JSON report contains an explicit `privacy` object. Every current sensitive-content flag is `false`. Regression tests enforce both that contract and the absence of private smart-naming text from serialized JSON and Markdown.

## Report sections

### App and runtime

- SonicNest version/build;
- operating-system family;
- operating-system version string;
- runtime locale;
- Dart runtime version;
- logical processor count.

### Library snapshot

Only aggregate counts are included:

- saved recordings;
- Trash recordings;
- favorites;
- pinned recordings.

No recording identity or metadata is included.

### Managed storage

The report records aggregate byte/file counts for SonicNest-managed recordings, Trash, and temporary storage. A probe-success flag distinguishes an actual zero value from a failed/unavailable filesystem probe.

### Recorder state

- current recorder state;
- whether input enumeration succeeded;
- detected input-device count when safely available;
- whether the selected input is system-default or custom.

SonicNest intentionally skips input-device enumeration while recording is active so diagnostics do not introduce a new concurrent recorder-backend probe during capture.

### Recording settings

The report includes non-content configuration needed to reproduce behavior:

- output format and quality preset;
- bit rate and sample rate;
- channel count;
- automatic gain;
- echo cancellation;
- noise suppression;
- countdown duration;
- keep-screen-awake preference.

Smart-naming text is intentionally excluded.

### Playback and interface settings

- default playback speed;
- seek/jump interval;
- skip-silence preference;
- theme mode;
- reduced-motion preference;
- permanent-delete confirmation preference.

## Manual QA evidence companion

**About → Manual QA evidence** is the companion surface for recording a tester's observation status against the remaining source-controlled release checks. It stores only fixed check IDs, `notRun`/`passed`/`failed`/`blocked` status values, and timestamps. It does not collect free-form tester notes.

Use Diagnostics for the runtime/app-state snapshot and Manual QA evidence for the observation status. These are deliberately separate evidence types: a diagnostic snapshot cannot prove a physical behavior passed, and a manually selected `Passed` status is not an automated assertion by SonicNest.

After a Diagnostics report is collected, choose **Open QA evidence with this snapshot** to pass that exact in-memory privacy-safe `DiagnosticReport` into the manual evidence screen and its JSON/Markdown bundle. The normal **About → Manual QA evidence** entry remains available without collecting diagnostics first. The manual evidence workflow is documented in `docs/MANUAL_QA_EVIDENCE.md`.

## Using diagnostics during physical QA

Capture a fresh report at the start of a test case and again after a meaningful state change when the comparison matters. Keep the report with the corresponding manual QA evidence rather than treating it as proof that the hardware behavior itself passed.

Recommended examples:

- before and after microphone input switching;
- before a 30-minute or multi-hour recording soak;
- after permission allow/deny/revoke testing;
- before and after background/lock-screen lifecycle testing;
- before low-storage or filesystem-permission recovery testing;
- while verifying reduced-motion and accessibility settings;
- before reproducing a platform-specific support issue.

## What diagnostics do not prove

A generated report does **not** close any physical-device QA gate by itself. It does not prove microphone quality, audio routing, Bluetooth behavior, interruption handling, background execution, accessibility-tool compatibility, low-storage recovery, signed-package behavior, or store readiness. Those items still require the real tests described in `docs/MANUAL_QA_EVIDENCE.md`, `docs/QA_CHECKLIST.md`, `TODO.md`, and the release documentation.

Likewise, a status entered in Manual QA evidence is only a record of the tester's reported observation. Repository release checkboxes and stable-release approval change only after the required evidence has actually been reviewed.

## Support sharing

Review the generated report before sharing it, especially when the operating-system version string could contain environment-specific information on unusual/custom systems. The built-in privacy contract prevents SonicNest library content and file paths from being included, but users remain in control of whether they copy or share a report.

For project support, use the repository's documented support channels. Do not attach recordings unless they are intentionally required for a specific issue and safe to share.
