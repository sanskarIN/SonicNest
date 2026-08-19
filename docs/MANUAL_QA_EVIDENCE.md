# Manual QA Evidence

SonicNest includes a local **Manual QA evidence** workflow under **About**. It exists to make the remaining real-device, real-filesystem, accessibility, desktop, packaging, and external-export validation work reproducible without pretending those gates can be automated by the application itself.

## Evidence boundary

The workflow records only:

- a fixed source-controlled QA check ID,
- one status: `notRun`, `passed`, `failed`, or `blocked`,
- the UTC timestamp of the latest non-`notRun` status change,
- the QA session start/update timestamps,
- fixed catalog metadata describing whether a check requires a physical target or external tooling,
- optionally, a separately collected privacy-safe Diagnostics & QA snapshot when a future caller supplies one.

The workflow intentionally does **not** collect free-form tester notes. It does not serialize recording content, recording titles, file paths, notes, tags, bookmarks, smart-naming text, or input-device names. This keeps the evidence bundle suitable for issue/release review without creating a second path for sensitive recording metadata.

## Local persistence

The current session is stored locally through `shared_preferences` under the versioned key:

```text
sonicnest.qaEvidenceSession.v1
```

Only check IDs that still exist in the source-controlled `QaCheckCatalog` survive load/save. Unknown or removed IDs are dropped so stale evidence cannot silently masquerade as a current release gate. Malformed or unsupported stored sessions fall back to a new empty session.

Persisted session timestamps are also bounded: a session whose update time predates its start is rejected, and individual results outside the declared session timeline are discarded. This prevents malformed local state from being re-exported as apparently valid release evidence.

Selecting **Reset session** removes the persisted evidence and creates a new session with every check in `Not run` state.

## Status meanings

### Not run

No evidence has been recorded for the check in the current local session. `Not run` is not stored as an explicit per-check record; absence means not run.

### Passed

A tester manually performed the check against the intended target/environment and judged the result acceptable. SonicNest does not independently verify that the procedure was performed.

### Failed

A tester performed the check and observed behavior that does not meet the release expectation. A failed check remains a release blocker until investigated and retested.

### Blocked

The check could not be completed because required hardware, permissions, media, tooling, credentials, distribution access, time, or another prerequisite was unavailable. `Blocked` is not equivalent to `Passed`.

## Catalog scope

The catalog mirrors the open evidence areas in `TODO.md`:

- microphone permissions, routing, interruptions, background/device-lock behavior, and Bluetooth reconnects,
- low-storage/filesystem/recovery conditions and recording stress/soak work,
- large-library, long-audio, malformed-media, and batch profiling,
- desktop secondary-click interaction behavior,
- TalkBack, VoiceOver, Narrator, Linux accessibility tooling, large text, keyboard-only use, and reduced motion,
- native icon/splash review and representative Linux/Windows package validation,
- direct external export, directory pickers, destination loss/permission revocation, low storage, stop-after-current, navigation-away behavior, and large mixed batches.

Signing/notarization/store-console approval remains governed by the distribution policies and `docs/RELEASING.md`. Those protected-environment tasks are not presented as in-app checks merely to increase a completion percentage.

## Export formats

### JSON

**Copy evidence JSON** produces deterministic structured output containing:

- bundle schema version,
- generation timestamp,
- explicit privacy flags,
- app name/version,
- total/assessed/pass/fail/blocked/not-run counts,
- QA session timestamps,
- every current catalog check and status,
- optional attached privacy-safe diagnostic data when supplied by the caller.

**Share evidence JSON** writes the same structured bundle to a bounded temporary JSON file and invokes the existing explicit operating-system share surface. This is the preferred format when evidence will later be merged on another SonicNest test target.

The JSON deliberately includes every current catalog check, including `notRun`, so reviewers can distinguish an incomplete session from a smaller historical catalog.

### Markdown

**Share evidence** creates a temporary Markdown file with the same summary and grouped checks. Status markers are explicit:

```text
[PASS]
[FAIL]
[BLOCKED]
[NOT RUN]
```

The Markdown file is created only after a user action and handed to SonicNest's existing explicit share surface. There is no automatic upload.

## JSON transfer and non-destructive merge

**Import evidence JSON** allows evidence collected on another test target to be consolidated into the current local QA session. Import is intentionally strict and conservative.

Before a merge can be offered, SonicNest requires:

- the current evidence bundle schema,
- the exact current SonicNest app version/build,
- the complete current QA catalog with no unknown, missing, or duplicate check IDs,
- unchanged category and physical/external-tooling metadata for every check,
- all privacy flags to remain explicitly `false`,
- valid timezone-aware timestamps in chronological order,
- assessed result timestamps inside the declared session timeline,
- the serialized `session.results` map to agree exactly with every assessed status/timestamp in the normalized check list,
- a summary that exactly matches the check list,
- a selected JSON file no larger than 2 MiB.

The `session.results` cross-check is deliberate. The export schema carries assessed evidence both in the persisted-session representation and in the normalized all-checks list; import rejects missing, extra, or contradictory redundant evidence instead of silently trusting one representation and ignoring the other.

The merge policy is per check:

1. An imported assessed result is added when no local assessed result exists.
2. An imported assessed result replaces local evidence only when its result timestamp is strictly newer.
3. Older or equal imported results are ignored.
4. Imported `notRun` values never clear a local `passed`, `failed`, or `blocked` result.
5. A confirmation dialog shows the add/update/ignored counts before persistence.
6. If no newer assessed result exists, the local session is left untouched.

Only fixed QA state is persisted from the imported bundle. Any optional diagnostics object present in the selected export is not adopted as imported session state. The user may still collect a fresh privacy-safe diagnostic snapshot explicitly when appropriate.

This merge workflow improves multi-device evidence handling; it does **not** authenticate a tester or prove that a manual observation happened.

## Offline structural review

Repository reviewers can validate exported JSON with:

```bash
python3 tool/verify_manual_qa_evidence.py path/to/evidence.json
```

The verifier checks the current source-controlled catalog, timestamps, privacy flags, app identity, status values, summary consistency, and optional diagnostics/version/freshness requirements. It can also enforce an all-pass ledger when a particular release policy calls for that state.

See `docs/MANUAL_QA_REVIEW_TOOLING.md` for the complete command and review contract. A successful verifier result means the evidence file is internally consistent with the requested policy; it does **not** prove that the underlying physical/manual checks were actually performed correctly.

## Using the evidence during release QA

1. Build or install the exact candidate being tested.
2. Open **About → Diagnostics & QA** and create a fresh diagnostic snapshot when runtime/storage/recorder/settings context is relevant.
3. Open **About → Manual QA evidence**.
4. Perform only the checks that match the current target/environment.
5. Mark each performed check `Passed`, `Failed`, or `Blocked` immediately after the observation.
6. Use **Share evidence JSON** before moving to another test target when the results need to be consolidated later.
7. On another target running the exact same SonicNest app version/build, use **Import evidence JSON**, review the merge counts, and confirm only when the selected source is expected.
8. Export the consolidated JSON or Markdown evidence before resetting the session.
9. For JSON evidence, run `tool/verify_manual_qa_evidence.py` with the version/diagnostic/freshness requirements appropriate to the release review.
10. Store evidence with the release/issue record and identify the exact source/build separately where required by `docs/QA_CHECKLIST.md` and `docs/RELEASING.md`.
11. Do not mark a repository task complete merely because the in-app status says `Passed`, an import succeeds, or the structural verifier succeeds; the project release ledger is updated only after the required evidence has actually been reviewed.

## Relationship to Diagnostics & QA

`docs/DIAGNOSTICS_AND_QA.md` covers automatically collected privacy-safe runtime evidence. This file covers **manual observation status**. They serve different purposes:

- Diagnostics answers: "What app/runtime/storage/recorder/settings state was visible when evidence was collected?"
- Manual QA evidence answers: "Which source-controlled release checks did a tester report as passed, failed, blocked, or not run?"

Neither feature can prove microphone quality, accessibility behavior, hardware routing, OS-level interruption handling, long-duration stability, filesystem failure behavior, package trust, signing, notarization, or store approval by itself.

## Regression coverage

Repository tests enforce:

- session JSON round-tripping and malformed-session fallback,
- rejection of backward persisted session timelines and removal of out-of-range result timestamps,
- explicit removal of `notRun` records,
- current-catalog-only persistence,
- reset behavior,
- unique category/check IDs and valid category references,
- localization coverage for every category/check ID,
- deterministic summary counts,
- stale-ID removal from exported bundles,
- explicit privacy flags including `containsFreeFormTesterNotes: false`,
- preservation of the existing Diagnostics privacy contract when a diagnostic snapshot is attached,
- newest-result-only non-destructive in-app evidence merging,
- rejection of malformed JSON, wrong-version, weakened-privacy, duplicate/incomplete-catalog, inconsistent-summary, generated-before-session, timestamped-`notRun`, catalog-metadata-tamper, and out-of-timeline imports,
- rejection of missing or contradictory redundant `session.results` evidence,
- source integration of the bounded JSON picker/share/import/persist workflow,
- offline verifier rejection of catalog drift, summary drift, stale evidence, privacy-contract regressions, and incomplete all-pass requirements.

These tests protect the evidence mechanism. They do not replace the manual checks represented by the catalog.
