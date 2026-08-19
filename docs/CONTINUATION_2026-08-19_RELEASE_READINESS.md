# SonicNest continuation checkpoint — 2026-08-19

This checkpoint records the repository work completed after the final repository audit had already classified the remaining unchecked `TODO.md` items as physical-device, accessibility, signing, distribution-console, sustained-workload, translation-review, or other externally evidenced tasks.

## Scope completed in this continuation

Added deterministic release-readiness bookkeeping that keeps those external gates visible without claiming they were performed, then hardened the project-state dependency summary so current dependency documentation cannot silently drift from `pubspec.yaml`.

### Release-readiness builder

Added `tool/build_release_readiness_report.py`.

The helper:

- parses the canonical level-two sections and checklist items in `TODO.md`;
- preserves checklist order;
- emits deterministic JSON with schema version, source, summary counts, per-section counts, and pending items;
- can emit a concise Markdown companion summary;
- reports `stableReleaseApproved: true` only when every parsed checklist item is complete and the canonical `v1.0.0` tag gate is checked;
- rejects a missing or duplicated canonical stable-tag gate;
- rejects malformed checklist syntax instead of silently skipping ambiguous evidence;
- rejects checklist entries that appear outside a level-two section;
- supports `--assert-not-ready` for intentionally pre-release review environments.

### Independent report verifier

Added `tool/verify_release_readiness_report.py`.

The verifier independently rejects:

- unsupported schema versions;
- missing/empty source identifiers;
- non-boolean approval state;
- negative, boolean, or otherwise invalid numeric counts;
- summary totals that do not reconcile;
- approval claims while pending work remains;
- duplicate sections;
- section totals that do not reconcile with summary totals;
- pending-item count drift;
- pending items assigned to unknown sections;
- empty pending-item labels/sections;
- pending items incorrectly marked complete.

### Dependency-state integrity

A follow-up audit found that the current `PROJECT_STATE.md` stack still described the superseded import/export and screen-wake dependency versions even though `pubspec.yaml` had already moved to the validated compatibility line.

The current project-state stack is now synchronized to:

- `file_picker 12.0.0-beta.7`;
- `share_plus 13.3.0`;
- `wakelock_plus 1.7.0`.

Added `tool/verify_project_state_dependencies.py` to compare the protected human-readable stack in `PROJECT_STATE.md` with direct runtime constraints in `pubspec.yaml`. The verifier is standard-library-only and intentionally rejects ambiguous/nested/compound protected dependency declarations rather than silently guessing.

Added `tool/tests/test_verify_project_state_dependencies.py` covering matching state, stale summaries, caret normalization, malformed protected dependency declarations, missing canonical stack structure, and CLI behavior.

Added `docs/DEPENDENCY_STATE.md` describing the canonical source, protected stack relationships, compatibility line, command usage, and the boundary between documentation integrity and real plugin/runtime validation.

The permanent repository audit requires the verifier, its tests, its documentation, and its CI invocation so the guard cannot be removed silently together with the enforcement surface.

### Permanent CI integration

The read-only `Repository Integrity Audit` workflow now:

1. compiles all Python helpers;
2. runs the repository audit;
3. verifies the `PROJECT_STATE.md` dependency summary against `pubspec.yaml`;
4. audits tracked source/text lines;
5. runs all Python tool regressions;
6. builds a temporary JSON and Markdown release-readiness snapshot from the real `TODO.md`;
7. independently verifies the generated JSON;
8. continues existing Bash and PowerShell syntax validation.

The maintained workflow retains read-only repository permissions. Temporary synchronization helpers used solely to append the large additive ledger are not part of the permanent workflow set and are removed before final validation.

### Regression coverage

Added and expanded:

- `tool/tests/test_build_release_readiness_report.py`;
- `tool/tests/test_release_readiness_cli.py`;
- `tool/tests/test_verify_release_readiness_report.py`;
- `tool/tests/test_verify_project_state_dependencies.py`.

Coverage includes parsing, state preservation, malformed syntax, orphaned checklist entries, conservative stable-release approval, canonical gate uniqueness, Markdown rendering, CLI output generation, missing-gate CLI failure, schema validation, summary reconciliation, duplicate sections, approval/pending contradictions, section-count drift, pending-item integrity, dependency-summary drift, malformed dependency declarations, and dependency-verifier CLI behavior.

### Documentation

Added and expanded:

- `docs/RELEASE_READINESS_REPORT.md` with generation, verification, limitations, CI behavior, and regression-coverage instructions;
- `docs/DEPENDENCY_STATE.md` with project-state dependency-integrity rules;
- `docs/README.md`, `CHANGELOG.md`, `TODO.md`, and `PROJECT_STATE.md` to reflect the completed repository-side guards without changing external evidence gates.

## Focused commits

Release-readiness commits:

- `047d213c0419ce0fecf734d0fde4bf8ebb839e1b` — `feat: add deterministic release readiness report builder`
- `6fccd28b67d5758adc23909df62ac978bbd1408c` — `test: cover release readiness report parsing and gates`
- `7fa2a7e870e92db50ebd65d519929046d11f4747` — `docs: document machine-readable release readiness snapshots`
- `352ece77512cb16e57dcb925787713f3f182572f` — `fix: load release readiness helper safely in tests`
- `8719fbd7f3ee1e58b6712bdeb957789246d7857c` — `ci: generate release readiness snapshot during integrity audit`
- `28913099167da50629efb5284dacd8d01eead9d9` — `test: cover release readiness CLI end to end`
- `d82fa593d2c39f5caad3347ec38c4ad2377ca970` — `fix: reject malformed release checklist entries`
- `8e2b2cc502c018c7fd5f849a62a45ac16687e168` — `test: reject malformed release checklist syntax`
- `dabf7621934d633a694bb69a09b58eda26342325` — `feat: add independent release readiness report verifier`
- `fd90389d96ccbc47402d2329ce4069c7eb277e8d` — `test: cover release readiness report verification`
- `731815cc2749b8b6191f6104081c264f3e3c25b5` — `ci: verify generated release readiness snapshot`
- `dd77a61c1f3b8d93e72bece635a92f96b05e0cd3` — `docs: document release readiness verification workflow`
- `1ebd1fb3813ee3f056941a9891b1f611a5cdf3c0` — `docs: record release readiness continuation checkpoint`

Dependency-state commits:

- `35f88e5ce0add5f567469c748b7e4962d246988d` — `feat: add project state dependency verifier`
- `fbc7960702f8a9c157c68525ac6e996cd2c3fb93` — `test: cover project state dependency drift`
- `34fea28e7367bec600475119238a4691988a9905` — `docs: document dependency state integrity`
- `1a7b47f0ffc23f910955fb18b0bf04c053e7d482` — `docs: index dependency state integrity guide`
- `abe0c3d5d2edc16de67282f95ab57f350c5bc5ef` — `docs: sync project state dependency versions`
- `eb96937fda5f80b611f4c4a98a93ec23150e2858` — `ci: verify project state dependency summary`
- `f74ce445661bb61b50afe043a50071e1a3a91e93` — `test: lock dependency state integrity surfaces`
- `f7e2b89d52c389ca455169a535eec4bf800ce1d5` — `docs: close dependency state hygiene gap`
- `c5613f3f139d9ad8618285d6428769356759913e` — `docs: record dependency state and readiness tooling`

## Validation status

The repository-side guards are wired into the permanent read-only Repository Integrity Audit. Final hosted validation for the clean post-ledger tree must be taken from the exact pull-request head after all temporary synchronization helpers are removed; this document does not pre-claim that final run before it exists.

The current source remains explicitly pre-stable-release. None of the physical-device, accessibility, signing, store-console, real-filesystem, sustained-workload, translation-review, or other externally evidenced tasks in `TODO.md` were marked complete by this continuation.

## Ledger note

The previous version of this checkpoint explained that the canonical `what_changed.md` could not safely be replaced from truncated connector output. This continuation now performs the update through an append-only branch operation against the complete checked-out ledger, preserving every prior historical section. Final review must confirm that the pull-request diff contains only the additive continuation block plus intentional checkpoint synchronization before merge.
