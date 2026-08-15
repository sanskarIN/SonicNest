#!/usr/bin/env python3
"""One-shot additive documentation synchronizer for the provenance continuation.

This temporary script is removed by its runner after it appends/updates the large
historical documentation files. It never truncates an existing ledger.
"""

from pathlib import Path


def append_once(path: str, marker: str, section: str) -> None:
    target = Path(path)
    text = target.read_text(encoding="utf-8")
    if marker not in text:
        target.write_text(text + section, encoding="utf-8")


def insert_after_once(path: str, anchor: str, marker: str, addition: str) -> None:
    target = Path(path)
    text = target.read_text(encoding="utf-8")
    if marker in text:
        return
    if anchor not in text:
        raise RuntimeError(f"Missing anchor {anchor!r} in {path}")
    target.write_text(text.replace(anchor, anchor + addition, 1), encoding="utf-8")


insert_after_once(
    "CHANGELOG.md",
    "### Added\n",
    "Unified machine-readable release-candidate provenance manifest builder",
    "- Unified machine-readable release-candidate provenance manifest builder and final hosted aggregation job that re-verifies all five platform payload checksum records and binds them to the exact source SHA, application version, workflow run, and attempt.\n"
    "- Python regression coverage for release provenance tooling plus permanent repository-audit execution of the Python release-tool suite.\n",
)
insert_after_once(
    "CHANGELOG.md",
    "### Changed\n",
    "Release-candidate validation now publishes a checksummed `sonicnest-release-candidate-manifest`",
    "- Release-candidate validation now publishes a checksummed `sonicnest-release-candidate-manifest` artifact only after Android, Linux, Windows, macOS, and iOS candidate jobs succeed.\n"
    "- Release evidence now preserves unified manifest/payload hashes, workflow artifact digests, platform signing classifications, and an explicit `stableReleaseApproved: false` boundary.\n",
)
insert_after_once(
    "CHANGELOG.md",
    "### Validation\n",
    "Provenance source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c`",
    "- Provenance source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c` passed Release Candidate Validation run `31876035202`, including the final unified provenance job.\n"
    "- `RELEASE_CANDIDATE_MANIFEST.json` SHA-256 `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e` was independently recomputed after artifact download and matched exactly; manifest workflow artifact digest: `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`.\n"
    "- Repository Integrity Audit run `31876149473` passed Python compilation, repository invariants, all 10 Python release-tool tests, Bash syntax, and PowerShell syntax.\n",
)

append_once(
    "RELEASE_NOTES.md",
    "## 2026-08-15 — Unified hosted release-candidate provenance",
    """

## 2026-08-15 — Unified hosted release-candidate provenance

SonicNest now produces a machine-readable provenance record after all five hosted release-mode platform jobs succeed. `tool/build_release_candidate_manifest.py` re-verifies each platform candidate's checksum evidence, requires Android's explicit Debug-certificate / NON-PRODUCTION classification, records evidence-file SHA-256 values and sizes, and binds the result to the exact full Git source SHA, application version, GitHub Actions run, and run attempt.

The permanent Repository Integrity Audit compiles Python release helpers and runs the release-tool regression suite. Run `31876149473` passed all **10/10** Python tests together with repository invariants and Bash/PowerShell helper parsing.

Hosted Release Candidate Validation run `31876035202` on source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c` passed Source preflight, Android, Linux, Windows, macOS, iOS, and the final **Unified candidate provenance manifest** job.

The generated `RELEASE_CANDIDATE_MANIFEST.json` records application version `0.1.0+1`, release classification `development-preview`, and `stableReleaseApproved: false`. Its SHA-256 is `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`; an independent post-download recomputation matched exactly. The manifest workflow artifact digest is `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`.

This evidence proves hosted checksum/source/run consistency only. It does not complete physical microphone/routing/interruption/background validation, real storage/process-failure testing, accessibility, sustained performance/soak tests, real visual review/screenshots, representative-system package QA, protected production signing/notarization, store acceptance, or final `v1.0.0` approval. SonicNest remains a **development preview**.
""",
)

append_once(
    "docs/QA_CHECKLIST.md",
    "## Unified release-candidate provenance automation",
    """

## Unified release-candidate provenance automation

Repository implementation/automation evidence:

- [x] `tool/build_release_candidate_manifest.py` requires Android, Linux, Windows, macOS, and iOS candidate evidence directories.
- [x] The manifest builder re-verifies release payloads against each platform artifact's `SHA256SUMS.txt` and rejects malformed, missing, mismatched, path-escaping, or unchecksummed payload evidence.
- [x] Android provenance requires expected package identity and explicit Android Debug certificate / NON-PRODUCTION signing-state markers.
- [x] The manifest binds evidence to a full source Git SHA, application version, workflow run ID, and run attempt.
- [x] Hosted development-preview provenance explicitly records `stableReleaseApproved: false` and preserves platform signing classifications.
- [x] Repository Integrity Audit run `31876149473` passed Python compilation, repository invariants, **10/10** Python release-tool tests, Bash parsing, and PowerShell parsing.
- [x] Release Candidate Validation run `31876035202` on source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c` passed all five platform jobs plus the final unified provenance job.
- [x] `RELEASE_CANDIDATE_MANIFEST.json` SHA-256 `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e` was independently recomputed after artifact download and matched the workflow checksum record.
- [x] Manifest workflow artifact digest is `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`.
- [x] The narrow push trigger used solely for hosted provenance validation was removed; the maintained release-candidate workflow is manual `workflow_dispatch` only.

These automated checks do **not** complete any physical-device, representative real-system, accessibility, long-duration/performance, visual-branding, private-signing/notarization, store-dashboard, or stable-release checkbox elsewhere in this document.
""",
)

append_once(
    "ROADMAP.md",
    "## Unified release-candidate provenance milestone — completed 2026-08-15",
    """

## Unified release-candidate provenance milestone — completed 2026-08-15

- [x] Add a standard-library Python builder for one machine-readable release-candidate provenance manifest.
- [x] Require and re-verify checksummed Android, Linux, Windows, macOS, and iOS hosted candidate evidence.
- [x] Bind the manifest to exact source SHA, application version, workflow run, and run attempt.
- [x] Preserve platform signing classifications and explicitly keep hosted candidates at `stableReleaseApproved: false`.
- [x] Add direct builder regression tests and repository/workflow integration tests.
- [x] Run Python release-tool regressions in the permanent Repository Integrity Audit.
- [x] Validate the complete provenance path in hosted run `31876035202`, including the final aggregation job.
- [x] Preserve exact manifest/payload hashes in source-controlled release evidence.
- [x] Return the maintained release-candidate workflow to manual dispatch after the controlled validation trigger.

No further repository-only release-automation milestone is currently identified. Next milestones remain evidence-driven: physical-device audio/lifecycle QA, real filesystem/storage recovery, accessibility, sustained performance/soak testing, representative desktop/package QA, protected production signing/notarization, store review, and final stable-release approval.
""",
)

append_once(
    "what_changed.md",
    "## 2026-08-15 — Unified release-candidate provenance manifest continuation",
    """


## 2026-08-15 — Unified release-candidate provenance manifest continuation

This section is additive. All earlier SonicNest continuation history above remains preserved unchanged. This continuation did not alter recorder/runtime application behavior; it hardened repository-owned release evidence so a hosted cross-platform candidate can be tied to one exact source revision and its downloaded platform artifact bytes without overstating stable-release readiness.

### Machine-readable provenance builder

Added `tool/build_release_candidate_manifest.py` as a Python-standard-library-only release evidence tool. It requires Android, Linux, Windows, macOS, and iOS candidate artifact directories, verifies each platform `SHA256SUMS.txt`, requires Android `ANDROID_SIGNING_STATE.txt`, prevents absolute/parent-traversal checksum references, rejects missing/mismatched or unchecksummed release payloads, validates a full 40-character source SHA plus positive run ID/attempt, reads the application version from `pubspec.yaml`, and records every evidence file's SHA-256/size/role.

Hosted manifest output explicitly records `releaseClassification: development-preview`, preserves platform signing classifications, and sets `stableReleaseApproved: false`.

Focused commit:

- `86e0bbab9b8e31c81c57814277f8f3ef41d34399` — `feat: add release candidate provenance manifest builder`.

### Regression coverage and permanent audit integration

Added `tool/tests/test_release_candidate_manifest.py` covering complete construction, tampering, missing checksum coverage, checksum path traversal, Android signing-state markers, missing platforms, and full-SHA enforcement.

Added `tool/tests/test_release_candidate_integration.py` locking the final workflow aggregation job, all five platform inputs, source/run binding, manifest publication, and permanent Python tooling test execution.

Focused commits:

- `252c71dc6c8a1b566ad544601ede954b7a35f365` — `test: cover release candidate manifest verification`;
- `3d4787afb00a3729f09dcfd2ad07189752dc5f88` — `test: lock release candidate manifest workflow integration`;
- `a970bf6c9100b5bfd00821a002b682473b0c1e59` — `ci: validate Python release tooling in repository audit`.

Repository Integrity Audit run `31876149473` completed successfully with Python helper compilation, repository invariants, **10/10** Python release-tool tests, Bash helper parsing, and PowerShell helper parsing all green.

### Unified release-candidate workflow job

Commit `e6182098ce205ef9f6008c5bd1418055c12377c3` added **Unified candidate provenance manifest** to `.github/workflows/release-candidate.yml` with `needs: [android, linux, windows, macos, ios]`.

After all five platform jobs succeed, the job downloads those exact artifact sets through `actions/download-artifact@v4`, invokes the manifest builder using `${GITHUB_SHA}`, `${GITHUB_RUN_ID}`, and `${GITHUB_RUN_ATTEMPT}`, writes `RELEASE_CANDIDATE_MANIFEST.json`, writes its own checksum and development-preview warning, and uploads `sonicnest-release-candidate-manifest`.

### Documentation and contribution contract

Added and synchronized:

- `docs/RELEASE_CANDIDATE_MANIFEST.md`;
- `docs/README.md` index;
- `CONTRIBUTING.md` provenance requirements;
- `docs/UNSIGNED_ARTIFACTS.md` unified artifact behavior;
- `docs/RELEASE_EVIDENCE_TEMPLATE.md` manifest evidence fields;
- `docs/AUTOMATED_RELEASE_EVIDENCE_2026-08-15.md` exact hosted provenance record;
- `TODO.md` repository-automation completion state;
- `PROJECT_STATE.md` exact provenance validation relationship.

Focused commits include:

- `0aca44f9e35aca9c4b2c4da927935785413d2ca0` — `docs: document unified release candidate provenance manifest`;
- `e087cf82a023de62d021e029cc67785f8c67fa9e` — `docs: index release candidate provenance manifest`;
- `eac04f1dfe2959342556cd72764bc40720a52f09` — `docs: add release provenance contribution checks`;
- `bd5fe0b6820f41e3105e179c6a644080258157b9` — `docs: document unified candidate provenance artifact`;
- `77b80c290c4a47d16884c944fee4accfed54525a` — `docs: add unified provenance manifest evidence fields`;
- `0af3a861d8161d05b7c9ac084731c0d5b0b41433` — `docs: close hosted provenance manifest validation`;
- `23658ef6a152b37d9a2b960c62b8c3d2e05477a2` — `docs: record unified hosted provenance validation`;
- `f345d6e8bd2e0a523c44a6f849b5c98e56fe0b03` — `docs: synchronize project state with provenance validation`.

### Controlled hosted validation and cleanup

The connector available for this continuation did not expose workflow dispatch. The maintained release-candidate workflow therefore temporarily received a narrow push trigger limited to `docs/RELEASE_CANDIDATE_MANIFEST.md` solely to obtain hosted evidence.

- `61186265e6eafeafadd2c51354dc0485f971f64d` — `ci: add one-time manifest validation trigger path`;
- `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c` — `docs: trigger hosted provenance manifest validation`.

After validation, the temporary trigger was removed:

- `79b5195e7f207ebc1076e38faecb5c4c9c2447e7` — `ci: restore manual release candidate trigger`.

The maintained release-candidate workflow is again manual `workflow_dispatch` only.

### Exact hosted provenance validation

Release Candidate Validation run `31876035202` on source `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c`, attempt `1`, completed **SUCCESS**.

Successful jobs:

- Source preflight;
- Android release-mode non-production artifacts;
- Linux release-mode artifacts;
- Windows release-mode artifact including portable build/verify/extracted startup smoke;
- macOS release-mode artifact;
- iOS no-codesign release-mode artifact;
- Unified candidate provenance manifest.

The generated manifest records application version `0.1.0+1`, source SHA `b95d77c4b69c9798f1ecb48d5f69583c4e08de5c`, run `31876035202`, attempt `1`, release classification `development-preview`, and `stableReleaseApproved: false`.

Manifest JSON SHA-256 recorded by the workflow and independently recomputed after downloading the artifact:

- `8a49759555cad26a60858025d82953ad0e3c3b429aa8138d67f7ef4f86d99b7e`

Manifest workflow artifact digest:

- `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`

Platform payload SHA-256 values re-verified by the unified manifest:

- Android APK: `1457f53822af974de18905ba4d103b3c9a8fe2f66080848a48cd591f6287f9b8`
- Android AAB: `029571a665ec3359cdee5cb2b5c8357c8b3c450ef3fcb1f63d8f808eb635e99a`
- Linux raw release bundle: `fbecb458fec864d451f0ba67e0b70f58f34710de883d5d4c8c86e32ab3238bd6`
- Linux Debian `.deb`: `eee447e80713f8c4102c200349cfae0873da1948dc0e2740f1b7d058a07d26e1`
- Windows portable ZIP: `c0cbc9ef7d00481e9f39fc058d5747779372dd61454a542eb5ce487d2da68ff3`
- macOS release archive: `0a4b2ac2c097e0f53eabbf84909ddc8f28bd28bd8bc37a0ea189b4ebc810733a`
- iOS no-codesign archive: `a6b77c3d3a5badc305c7d7ebfc3a5a646197b48f09c1000854980fcffaaf17a7`

Workflow artifact digests from the same run:

- Android: `sha256:9a123c791ca5fce6391be017f0873ffa770f317f7c8fc75d975c38731820d0d6`
- Linux: `sha256:5a80aeb576c5cfea3d9c58f65a29e4e8aadb306d6bc59d0c71beafc5ee7e36ed`
- Windows: `sha256:1ad4aee180fcb114d5f7b8a40d9e458dd0e7e8abcdbc661e7bfad3dbbc4489b3`
- macOS: `sha256:e578be6e601502c25169399d650e245013852f26799bcf599a893d6d001efb99`
- iOS: `sha256:ee6d63de19d362efc400df6beec326c8a04019bfab093d23b76af8ffa12a571d`
- Unified manifest: `sha256:5fa654434ba304e7b67945250f7c8f4bec14eacbc87effefa5cd2d620885baa3`

### Current completion boundary

No additional repository-only release-automation gap is currently identified. Remaining work requires physical/representative systems, sustained workloads, assistive technologies, real media/filesystem failures, protected maintainer credentials, store dashboards, or final release approval.

Still intentionally open are microphone permission/capture/routing, wired/USB/Bluetooth/external-interface behavior, interruption/background/lock-screen/media buttons, low-storage/permission/process/power-loss recovery, real damaged/malformed media, long-duration/stress/performance profiling, desktop interaction/accessibility audits, native visual review and real screenshots, representative Linux/Windows package QA, Android Play production signing, Apple provisioning/signing/notarization/TestFlight/App Store, Windows Authenticode, final release checklist approval, and `v1.0.0` tagging.

SonicNest therefore remains a **development preview**. The provenance manifest proves hosted artifact checksum/source/run consistency; it does not replace those real-world or protected-signing gates.
""",
)
