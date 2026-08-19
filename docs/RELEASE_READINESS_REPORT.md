# Release readiness report

SonicNest keeps repository-complete work separate from physical-device, accessibility, signing, distribution-console, and other external release evidence. `tool/build_release_readiness_report.py` converts the canonical checklist in `TODO.md` into a deterministic JSON snapshot so automated or human review can see exactly how much unchecked work remains without implying that external tests were performed.

## Generate the report

From the repository root:

```bash
python3 tool/build_release_readiness_report.py
```

The default output is `build/release-readiness.json`. The `build/` directory is intentionally untracked.

To also create a concise Markdown summary:

```bash
python3 tool/build_release_readiness_report.py \
  --markdown-output build/release-readiness.md
```

The JSON report contains:

- `schemaVersion` for future format evolution;
- the source checklist path;
- a conservative `stableReleaseApproved` boolean;
- total, pending, and completed checklist counts;
- per-section pending/completed counts;
- every pending checklist item with its section and label.

## Stable-release safety rule

The tool recognizes the canonical `v1.0.0` tag gate in `TODO.md`. A stable release can only be reported as approved when:

1. that exact tag gate is checked; and
2. every checklist item parsed from `TODO.md` is complete.

If the canonical tag gate is missing or duplicated, report generation fails. Checklist entries with unsupported states, broken spacing, or no level-two section also fail instead of being silently ignored.

The optional safety assertion below is useful while SonicNest is intentionally not release-approved:

```bash
python3 tool/build_release_readiness_report.py --assert-not-ready
```

That command succeeds while the report remains not ready and fails if the checklist unexpectedly claims that all stable-release work is complete.

## Verify a generated report

The independent verifier checks the generated JSON without depending on the builder implementation:

```bash
python3 tool/verify_release_readiness_report.py build/release-readiness.json
```

It rejects unsupported schema versions, invalid or negative counts, inconsistent totals, duplicate sections, pending-item count drift, pending items tied to unknown sections, pending items incorrectly marked complete, and any report that claims stable approval while pending work remains.

The permanent Repository Integrity Audit builds a temporary readiness snapshot and immediately verifies it. This gives CI both producer-side and consumer-side coverage without adding workflow write permissions or storing generated evidence in the repository.

## Important limitation

This report is bookkeeping evidence only. It does **not** run microphone tests, accessibility audits, long-duration stress tests, filesystem-failure tests, signing operations, store-console submissions, translation review, or any other external/manual validation. A generated report must never be used as a substitute for the underlying evidence required by `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md`.

## Regression coverage

- `tool/tests/test_build_release_readiness_report.py` protects checklist parsing, malformed-input rejection, conservative approval behavior, canonical tag-gate uniqueness, and Markdown rendering.
- `tool/tests/test_release_readiness_cli.py` covers end-to-end JSON/Markdown generation and canonical-gate failure behavior.
- `tool/tests/test_verify_release_readiness_report.py` protects the independent JSON contract verifier.

The permanent Repository Integrity Audit compiles all Python helpers and automatically discovers all `tool/tests/test_*.py` regressions.
