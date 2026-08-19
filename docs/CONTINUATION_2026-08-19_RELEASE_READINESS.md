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
- duplicate pending-item identities;
- pending items incorrectly marked complete;
- zero-item reports that could otherwise look structurally valid.

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

The maintained workflow retains read-only repository permissions. Temporary synchronization helpers explored during this continuation are not part of the permanent workflow set and were removed before final validation.

### Regression coverage

Added and expanded:

- `tool/tests/test_build_release_readiness_report.py`;
- `tool/tests/test_release_readiness_cli.py`;
- `tool/tests/test_verify_release_readiness_report.py`;
- `tool/tests/test_verify_project_state_dependencies.py`.

Coverage includes parsing, state preservation, malformed syntax, orphaned checklist entries, conservative stable-release approval, canonical gate uniqueness, Markdown rendering, CLI output generation, missing-gate CLI failure, schema validation, summary reconciliation, duplicate sections, duplicate checklist identities, approval/pending contradictions, section-count drift, duplicate pending-item identities, zero-item report rejection, pending-item integrity, dependency-summary drift, malformed dependency declarations, and dependency-verifier CLI behavior.

### Documentation

Added and expanded:

- `docs/RELEASE_READINESS_REPORT.md` with generation, verification, limitations, CI behavior, and regression-coverage instructions;
- `docs/DEPENDENCY_STATE.md` with project-state dependency-integrity rules;
- `docs/README.md`, `CHANGELOG.md`, `TODO.md`, and `PROJECT_STATE.md` to reflect the completed repository-side guards without changing external evidence gates.

## Deep repository-integrity hardening pass

A later pass in the same continuation found additional deterministic repository concerns and closed them without changing runtime behavior or external release gates.

### Critical surface retention

The repository audit already executed release/readiness and provenance tooling, but not every supporting document, helper, and regression file was protected by `REQUIRED_FILES`. A future deletion could therefore reduce coverage while leaving the generic Python test-discovery command structurally present.

Added `tool/tests/test_repository_required_surfaces.py` and expanded `tool/repository_audit.py` so the maintained release/readiness, manual-QA, provenance, open-source-maintenance, dependency, continuation, and regression surfaces are explicitly required. The regression also enforces uniqueness of `REQUIRED_FILES` entries and existence of every required path.

The repository audit now additionally locks the actual release-readiness generation/verification commands and the unified release-candidate provenance workflow commands, including artifact download, manifest builder invocation, manifest filename, and manifest artifact publication. This prevents a future edit from leaving the supporting files present while silently removing their CI integration.

Focused commits:

- `9ece0635b59d6270fcbb09cbe1ee22950e00de20` — `test: define critical repository required surfaces`;
- `a317fa3f10a2ec7b819ffb12a2b2363f196bd699` — `test: protect critical release and maintenance surfaces`;
- `af98a6029b739d73707030ca098b12b0d0d2e39a` — `test: lock release readiness and provenance workflow commands`.

### Symlink-safe provenance evidence

The release-candidate provenance builder previously treated `Path.is_file()` as sufficient evidence ownership. That API follows symbolic links, so a locally supplied candidate directory could make a checksummed path resolve to bytes outside the candidate tree.

`tool/build_release_candidate_manifest.py` now rejects a platform artifact directory that is itself a symbolic link and rejects any symbolic link anywhere inside a platform artifact tree before required metadata is read or payloads are hashed.

`tool/tests/test_release_candidate_manifest.py` now covers both a symlinked payload whose external target has a matching checksum and symlinked required Android signing metadata. The tests skip only on environments where symbolic-link creation itself is unavailable.

`docs/RELEASE_CANDIDATE_MANIFEST.md` documents the ordinary-file/directory evidence boundary and explicitly separates prior historical validation from the need to validate newer source revisions.

Focused commits:

- `4733c0304e15f31524266caf5995e6f89d5cebc1` — `test: reject symlinked release candidate evidence`;
- `cdabda1f2c20eba6a610ddbfb71816cb2e9123e3` — `fix: reject symlinked release candidate evidence`;
- `37a7717953ed239eb33979dcaa11cf2afb95a9b3` — `docs: document symlink-safe release provenance`.

### Canonical checksum identity enforcement

A checksum record can represent the same artifact path through syntactic aliases such as `payload.zip`, `./payload.zip`, or Windows-style separator variants. Treating those strings as distinct identities would make provenance evidence ambiguous even when both ultimately reference the same payload.

`tool/build_release_candidate_manifest.py` now normalizes checksum identities before verification and rejects a second entry that collapses to an already-seen artifact-relative path. The manifest records the normalized path identity in `verifiedChecksums`.

`tool/tests/test_release_candidate_manifest.py` covers both dot-path aliases and cross-separator aliases, and `docs/RELEASE_CANDIDATE_MANIFEST.md` documents the normalized-identity rule.

Focused commits:

- `e28a6b2f7e3c0dccdf8c33fd1072c2d81f1bb9ef` — `test: reject duplicate normalized provenance checksums`;
- `b1f9e19e3d878bf901a0cd21dab42cbda87c3b5c` — `fix: normalize provenance checksum identities`;
- `8b6c6c69a7c05c55687b6c1ee69be9e9bf383b87` — `docs: document normalized provenance checksums`.

### Ambiguous and empty readiness evidence rejection

The readiness parser and verifier were hardened so structurally ambiguous evidence cannot be accepted merely because aggregate counts reconcile.

`tool/build_release_readiness_report.py` now rejects repeated level-two section headings and duplicate checklist identities within a section. Identical checklist wording remains valid when it appears in different sections.

`tool/verify_release_readiness_report.py` now rejects duplicate pending-item `(section, label)` identities and rejects a report whose summary contains zero checklist items. These checks keep a future malformed or accidentally emptied readiness source from degenerating into apparently valid release evidence.

Focused commits:

- `0666772b03e02e395def334eff41a166d13dfd66` — `test: reject ambiguous readiness checklist identities`;
- `fab856ebd67195ae0676d71fb9403dd780b36014` — `fix: reject ambiguous readiness checklist identities`;
- `dd0b2206dda0e9aa7f808e0d0b71c6f613f7cf9b` — `test: reject empty and duplicate readiness evidence`;
- `4866ea893497b4ddebaed567fcb3cc59606e8fb1` — `fix: fail closed on empty readiness evidence`.

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

## Integration status

Pull request `#18` (`docs: validate deep repository integrity hardening`) collected the final eight deep-hardening commits on head `4866ea893497b4ddebaed567fcb3cc59606e8fb1` and was merged into `main` on 2026-08-19 with merge commit `429cf74863a7dfff052fba965f0066b9f25561b5`.

At the point of integration, the PR's Windows Build, Repository Integrity Audit, Flutter CI, and Apple Builds were still reported by GitHub as **queued**, not failed. This checkpoint therefore does not claim a new hosted green result for `4866ea893497b4ddebaed567fcb3cc59606e8fb1` or the merge commit. Earlier recorded green validation remains historical evidence only for its exact source revisions.

The current source remains explicitly pre-stable-release. None of the physical-device, accessibility, signing, store-console, real-filesystem, sustained-workload, translation-review, or other externally evidenced tasks in `TODO.md` were marked complete by this continuation.

## Canonical ledger boundary

`what_changed.md` remains intact and unmodified by this checkpoint. The GitHub connector available to this continuation supports complete-file replacement but not an atomic append/patch operation. Replacing the large canonical ledger from partial/truncated content would risk deleting historical project state, so this dated checkpoint remains the additive continuation record for 2026-08-19 until a local Git or other safe append-capable environment can merge it into `what_changed.md` without altering any prior section.

This limitation is documentation-transport-only: the release-readiness tooling, dependency-state verifier, critical-surface retention, symlink-safe provenance hardening, normalized checksum identity enforcement, ambiguity/empty-readiness rejection, tests, CI guards, `PROJECT_STATE.md`, `TODO.md`, and `CHANGELOG.md` updates described above are already present in repository source. No stable-release evidence gate is inferred from the missing canonical-ledger append.
