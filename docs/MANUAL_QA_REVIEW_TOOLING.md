# Manual QA Evidence Review Tooling

SonicNest includes `tool/verify_manual_qa_evidence.py` for offline review of JSON exported from **About → Manual QA evidence**.

The verifier protects the review process from malformed exports, stale catalog shapes, inconsistent summary counts, privacy-contract regressions, mismatched app versions, and optionally stale evidence. It is deliberately a **structural verifier only**: a successful result does not prove that a microphone, accessibility, stress, packaging, signing, or distribution test was actually performed correctly.

## Basic verification

From the repository root:

```bash
python3 tool/verify_manual_qa_evidence.py path/to/evidence.json
```

A valid current-catalog bundle exits successfully. The tool prints the platform when a Diagnostics snapshot is attached, plus pass/fail/blocked/not-run totals.

## Candidate-bound review

For evidence expected to come from a specific app version and include runtime diagnostics:

```bash
python3 tool/verify_manual_qa_evidence.py \
  --expected-version 0.1.0+1 \
  --require-diagnostics \
  path/to/evidence.json
```

Replace `0.1.0+1` with the exact candidate version being reviewed.

## Freshness policy

A release reviewer can reject old evidence with `--max-age-hours`:

```bash
python3 tool/verify_manual_qa_evidence.py \
  --max-age-hours 72 \
  path/to/evidence.json
```

The repository does not impose one universal freshness window because different manual checks have different practical lifetimes. The release owner must choose and document an appropriate window for the candidate.

## Strict all-pass mode

When a release procedure specifically requires every current catalog item to be marked passed:

```bash
python3 tool/verify_manual_qa_evidence.py \
  --require-all-passed \
  path/to/evidence.json
```

This option checks only what the exported ledger says. It does not independently authenticate the tester or reproduce the underlying observations. Release approval must still follow `docs/QA_CHECKLIST.md`, `docs/RELEASING.md`, and the platform distribution policies.

## Reviewing several exports

Multiple JSON files may be supplied in one invocation:

```bash
python3 tool/verify_manual_qa_evidence.py \
  android-evidence.json \
  windows-evidence.json \
  linux-evidence.json
```

Each file is validated independently. The verifier intentionally does not merge separate sessions or infer that several partial sessions collectively satisfy a release gate.

## What is verified

The verifier checks:

- bundle schema version,
- parseable timezone-aware generation/session timestamps and timestamp ordering,
- required privacy flags remaining `false`,
- SonicNest app identity and optional exact version binding,
- every current source-controlled QA check appearing exactly once,
- no unknown/stale check IDs,
- valid `notRun`, `passed`, `failed`, or `blocked` status values,
- timestamp presence rules for assessed versus `notRun` checks,
- boolean physical-target/external-tooling markers,
- summary counts recomputed from the check list,
- optional Diagnostics presence and runtime platform field,
- optional evidence freshness,
- optional all-checks-passed state.

Current check IDs are read from `lib/models/qa_check_catalog.dart`, so an old evidence bundle cannot silently look complete after the catalog grows.

## What is not verified

The tool does not verify:

- microphone quality or routing,
- device/OEM lifecycle behavior,
- accessibility behavior with TalkBack, VoiceOver, Narrator, or Linux assistive tooling,
- long-duration or low-storage behavior,
- correctness of human observations,
- screenshots or other external attachments,
- code signing, notarization, store-console state, or release approval,
- identity of the tester,
- whether multiple partial reports together cover a release matrix.

Those remain real QA/release responsibilities.

## Exit codes

- `0`: every supplied evidence file passed the requested structural checks.
- `1`: one or more evidence files are invalid for the requested review policy.
- `2`: command usage or repository/catalog loading failed.

## Repository validation

The verifier and its unit/CLI regression path were exercised by permanent **Repository Integrity Audit** run `32016347023` on source revision `c65f01e62dcca9c250e6b304fcc137e9a78c8b84`, which completed successfully. Later documentation/state synchronization does not change the verifier implementation represented by that validated source revision.

## Privacy note

The verifier fails if the manual-QA privacy flags no longer state that recording content, recording titles, file paths, notes/tags/bookmarks, input-device names, and free-form tester notes are excluded. It does not inspect arbitrary external attachments; reviewers must apply the same privacy discipline to any files stored beside the exported evidence.
