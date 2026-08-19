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

If the canonical tag gate is missing or duplicated, report generation fails. This makes accidental checklist drift visible instead of silently weakening release review.

The optional safety assertion below is useful while SonicNest is intentionally not release-approved:

```bash
python3 tool/build_release_readiness_report.py --assert-not-ready
```

That command succeeds while the report remains not ready and fails if the checklist unexpectedly claims that all stable-release work is complete.

## Important limitation

This report is bookkeeping evidence only. It does **not** run microphone tests, accessibility audits, long-duration stress tests, filesystem-failure tests, signing operations, store-console submissions, translation review, or any other external/manual validation. A generated report must never be used as a substitute for the underlying evidence required by `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md`.

## Regression coverage

`tool/tests/test_build_release_readiness_report.py` protects checklist parsing, conservative approval behavior, canonical tag-gate uniqueness, and Markdown rendering. The permanent Repository Integrity Audit automatically compiles the helper and discovers the regression tests.
