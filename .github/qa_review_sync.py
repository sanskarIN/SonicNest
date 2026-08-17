#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"Expected synchronization marker missing in {path}: {old[:120]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def append_once(path: Path, marker: str, addition: str) -> None:
    text = path.read_text(encoding="utf-8")
    if marker in text:
        return
    if not text.endswith("\n"):
        text += "\n"
    path.write_text(text + addition, encoding="utf-8")


def sync_project_state() -> None:
    path = ROOT / "PROJECT_STATE.md"
    replace_once(
        path,
        "  - regression coverage enforcing diagnostics serialization privacy unavailable-probe behavior and localization labels\n",
        "  - regression coverage enforcing diagnostics serialization privacy unavailable-probe behavior and localization labels\n"
        "  - About-accessible Manual QA evidence sessions with fixed source-controlled check IDs versioned local persistence deterministic JSON/Markdown export and optional privacy-safe diagnostics attachment\n"
        "  - offline manual-QA JSON structural verifier that binds evidence to the current QA catalog and checks schema timestamps privacy flags summary consistency optional exact version diagnostics freshness and all-pass review policy\n"
        "  - unit and CLI regression coverage for manual-QA evidence verification executed by the permanent Repository Integrity Audit\n",
    )
    replace_once(
        path,
        "  release_gate_effect: supporting_evidence_only_no_manual_gate_closed\n  documentation: docs/MANUAL_QA_EVIDENCE.md\nplatform_bootstrap_integrity:\n",
        "  release_gate_effect: supporting_evidence_only_no_manual_gate_closed\n"
        "  documentation: docs/MANUAL_QA_EVIDENCE.md\n"
        "manual_qa_review_tooling:\n"
        "  verifier_source_commit: b40af1c6996da2809f25ed6300b6abbdb2f84220\n"
        "  regression_source_commit: c65f01e62dcca9c250e6b304fcc137e9a78c8b84\n"
        "  verifier: tool/verify_manual_qa_evidence.py\n"
        "  documentation: docs/MANUAL_QA_REVIEW_TOOLING.md\n"
        "  current_catalog_source: lib/models/qa_check_catalog.dart\n"
        "  checks:\n"
        "    - bundle and session schema versions\n"
        "    - timezone-aware generation and session timestamp ordering\n"
        "    - sensitive-data privacy flags remain false\n"
        "    - exact current catalog membership with no missing unknown or duplicate IDs\n"
        "    - status and assessed/notRun timestamp rules\n"
        "    - recomputed summary consistency\n"
        "    - optional exact application version\n"
        "    - optional diagnostics runtime platform\n"
        "    - optional evidence freshness\n"
        "    - optional all-current-checks-passed policy\n"
        "  release_gate_effect: structural_supporting_evidence_only_no_manual_gate_closed\n"
        "  repository_integrity_run_id: 32016347023\n"
        "  repository_integrity_result: success\n"
        "platform_bootstrap_integrity:\n",
    )
    replace_once(
        path,
        "    python_release_tool_tests: 10_of_10_passed\n  validation_relationship:\n",
        "    python_release_tool_tests: 10_of_10_passed\n"
        "    manual_qa_verifier_run_id: 32016347023\n"
        "    manual_qa_verifier_source_commit: c65f01e62dcca9c250e6b304fcc137e9a78c8b84\n"
        "    manual_qa_verifier_result: success\n"
        "  validation_relationship:\n",
    )
    replace_once(
        path,
        "    - stable release still requires the unchecked real-system and maintainer-credential gates\nknown_limitations:\n",
        "    - manual-QA verifier revision c65f01e62dcca9c250e6b304fcc137e9a78c8b84 passed permanent Repository Integrity Audit run 32016347023 including Python compilation and tool regression discovery\n"
        "    - stable release still requires the unchecked real-system and maintainer-credential gates\nknown_limitations:\n",
    )
    replace_once(
        path,
        "  - unified provenance manifest proves hosted artifact checksum/source/run consistency only and does not convert validation artifacts into stable signed distributables\n",
        "  - unified provenance manifest proves hosted artifact checksum/source/run consistency only and does not convert validation artifacts into stable signed distributables\n"
        "  - manual-QA structural verification proves export/catalog/privacy/summary consistency only and does not authenticate the tester or reproduce the physical accessibility stress filesystem branding signing or distribution observation\n",
    )


def sync_changelog() -> None:
    path = ROOT / "CHANGELOG.md"
    replace_once(
        path,
        "### Added\n",
        "### Added\n"
        "- Offline `tool/verify_manual_qa_evidence.py` structural review for exported Manual QA JSON, including current-catalog membership, timestamp/status rules, privacy flags, recomputed summaries, optional exact-version/diagnostics/freshness policy, and optional all-pass enforcement without claiming the represented physical tests occurred.\n"
        "- Python unit and CLI regressions for Manual QA evidence verification plus `docs/MANUAL_QA_REVIEW_TOOLING.md` and release-evidence template fields for reproducible human review.\n",
    )
    replace_once(
        path,
        "### Changed\n",
        "### Changed\n"
        "- Release guidance now requires accepted Manual QA JSON to pass the repository structural verifier under the candidate-specific version/diagnostics/freshness policy while preserving the distinction between internally consistent evidence and an actually performed manual observation.\n",
    )


def sync_release_notes() -> None:
    path = ROOT / "RELEASE_NOTES.md"
    replace_once(
        path,
        "### Project quality\n\n",
        "### Project quality\n\n"
        "- Manual QA JSON can now be reviewed offline with `tool/verify_manual_qa_evidence.py`, which verifies the current source-controlled QA catalog, schema/timestamps, privacy contract, recomputed summary counts, and optional candidate-version/diagnostics/freshness/all-pass policy without treating the ledger as proof of a physical test.\n"
        "- Manual-QA verifier unit and CLI tests are included in the permanent Python tooling regression discovery; Repository Integrity Audit run `32016347023` passed on verifier/test revision `c65f01e62dcca9c250e6b304fcc137e9a78c8b84`.\n"
        "- `docs/MANUAL_QA_REVIEW_TOOLING.md`, `docs/RELEASING.md`, `CONTRIBUTING.md`, and the release evidence template now share the same structural-review and non-overclaiming contract.\n",
    )


def sync_roadmap() -> None:
    path = ROOT / "ROADMAP.md"
    replace_once(
        path,
        "- Manual QA evidence JSON/Markdown exports include explicit privacy flags, complete current-catalog status coverage, progress counts, and stale-check filtering without converting manual observations into automated assertions.\n",
        "- Manual QA evidence JSON/Markdown exports include explicit privacy flags, complete current-catalog status coverage, progress counts, and stale-check filtering without converting manual observations into automated assertions.\n"
        "- Offline Manual QA JSON structural review is implemented with source-controlled catalog membership, schema/timestamp/privacy/summary checks, optional exact-version/diagnostics/freshness/all-pass policy, and permanent Python regression coverage.\n",
    )
    replace_once(
        path,
        "- Detailed manual QA checklist, release procedure, preview release notes, release evidence template, and evidence-based remaining-work file.\n",
        "- Detailed manual QA checklist, release procedure, preview release notes, release evidence template, evidence-based remaining-work file, and offline structural verification of exported manual-QA JSON before release evidence acceptance.\n",
    )


def sync_ledger() -> None:
    path = ROOT / "what_changed.md"
    marker = "# Continuation — 2026-08-17 — Offline manual QA evidence verification"
    recent = subprocess.check_output(
        ["git", "log", "-4", "--format=- `%H` — `%s`"],
        cwd=ROOT,
        text=True,
    ).strip()
    addition = f"""

{marker}

## Continuation objective

The remaining unchecked SonicNest release work is dominated by real-device microphone/routing/lifecycle behavior, accessibility tooling, long-duration and low-storage stress, representative package behavior, protected signing/notarization/store-console work, and final release approval. The in-app Manual QA evidence ledger already made those observations exportable, but the repository had no strict offline reviewer that could detect a malformed, stale-catalog, privacy-regressed, summary-inconsistent, or wrong-candidate JSON export before it was accepted into release evidence.

This continuation closes that repository-side evidence-review gap without marking any physical/manual release gate complete.

## Offline Manual QA evidence verifier

Added `tool/verify_manual_qa_evidence.py`, a Python-standard-library-only structural verifier for JSON exported from **About → Manual QA evidence**.

The verifier checks:

- bundle and session schema versions;
- timezone-aware generation/session timestamps and ordering;
- the explicit privacy flags for recording content, titles, file paths, notes/tags/bookmarks, input-device names, and free-form tester notes all remain `false`;
- canonical SonicNest app identity plus optional exact application-version binding;
- every current source-controlled `QaCheckCatalog` check appears exactly once;
- no unknown or removed check ID is accepted;
- status values remain `notRun`, `passed`, `failed`, or `blocked`;
- `notRun` versus assessed timestamp rules;
- boolean physical-target/external-tooling metadata;
- summary totals recomputed from the check list;
- optional Diagnostics attachment and runtime platform;
- optional maximum evidence age;
- optional strict all-current-checks-passed policy.

The current QA check identifiers are parsed from `lib/models/qa_check_catalog.dart`, so an older export cannot silently appear complete after the source-controlled catalog grows.

CLI exit behavior is deterministic: `0` for valid evidence under the requested policy, `1` for invalid evidence, and `2` for command/catalog usage failure.

## Regression coverage

Added unit-level and CLI-level Python coverage for:

- a consistent current-catalog evidence bundle;
- summary drift;
- missing and unknown catalog checks;
- strict all-pass policy behavior;
- stale evidence rejection;
- privacy-contract regression;
- exact application-version mismatch;
- required Diagnostics policy;
- nonpositive freshness-policy usage errors;
- QA catalog ID extraction.

The existing permanent Repository Integrity Audit automatically compiles Python under `tool/` and discovers every `tool/tests/test_*.py` regression. Run `32016347023` completed **SUCCESS** on source `c65f01e62dcca9c250e6b304fcc137e9a78c8b84`, confirming the new verifier/test path passes the maintained repository-owned audit.

The Flutter, Windows, and Apple workflows triggered for the same test revision were still running when this ledger synchronization was generated, so no unconfirmed platform result is pre-claimed here. The verifier itself does not change Flutter runtime application code.

## Release and contribution integration

Documentation now requires structural review of accepted Manual QA JSON while preserving the real-world evidence boundary:

- `docs/MANUAL_QA_REVIEW_TOOLING.md` documents basic, candidate-bound, freshness, diagnostics-required, all-pass, and multi-export review commands plus exit codes and limitations;
- `docs/MANUAL_QA_EVIDENCE.md` connects exported evidence to the offline verifier;
- `docs/RELEASING.md` requires candidate-appropriate structural verification before a Manual QA JSON ledger is accepted into release evidence;
- `docs/RELEASE_EVIDENCE_TEMPLATE.md` records the exact verifier command/policy, version/freshness requirements, pass/fail/blocked/not-run counts, human reviewer, and archived evidence identity;
- `CONTRIBUTING.md` requires verifier/catalog changes to preserve the privacy/evidence contract and forbids weakening the verifier merely to accept stale or malformed exports;
- `docs/README.md` indexes the new review tooling;
- `TODO.md` marks only the repository-side verifier gap complete while every physical-device, accessibility, stress, branding-visual, signing, store-console, and stable-release gate remains unchanged and unchecked.

## Focused commits created before state synchronization

- `b40af1c6996da2809f25ed6300b6abbdb2f84220` — `feat: add manual QA evidence verifier`
- `b69b78658d0b2f0e5967bd4ac2eb95db33a01305` — `test: cover manual QA evidence verifier`
- `6d8cf4f9d7d9c134fe693e4758a8c8b74304c696` — `docs: add manual QA evidence review guide`
- `0def2b43004dce3e58f0483fbfb77d1fc63e2315` — `docs: document offline QA evidence verification`
- `6e592a37cbea988a2d187ac99a106b5070807604` — `docs: close manual QA verifier repository gap`
- `3092241b910ffdfd6fc5565c5dffefd1650dc6ef` — `docs: require structural review of QA evidence`
- `c65f01e62dcca9c250e6b304fcc137e9a78c8b84` — `test: cover manual QA verifier CLI policy`
- `ff0d6b5da09ad8053729142e58d2d0c89bf68043` — `docs: index manual QA review tooling`
- `2c1c291defddb1f61e4e14c0c39be2e64a04ae17` — `docs: add QA evidence verifier contribution contract`
- `698f6bb1c31900131be29922401b8a5304eb5696` — `docs: add manual QA verifier evidence fields`

State-synchronization commits immediately preceding this ledger append:

{recent}

## Completion boundary

The offline verifier proves only that an exported ledger is internally consistent with the current source-controlled review contract and any explicit candidate policy supplied to the command. It does not authenticate who performed a check, reproduce an observation, validate microphone quality/routing, execute accessibility tooling, create storage failures, perform soak tests, inspect native visual surfaces, sign/notarize an artifact, interact with store consoles, or approve a stable release.

SonicNest therefore remains a **development preview**. The remaining unchecked items in `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md` still require real systems, sustained workloads, representative media, assistive technologies, protected maintainer credentials, or final release approval.
"""
    append_once(path, marker, addition)


MODES = {
    "project_state": sync_project_state,
    "changelog": sync_changelog,
    "release_notes": sync_release_notes,
    "roadmap": sync_roadmap,
    "ledger": sync_ledger,
}

if len(sys.argv) != 2 or sys.argv[1] not in MODES:
    raise SystemExit(f"usage: {Path(sys.argv[0]).name} <{'|'.join(MODES)}>")
MODES[sys.argv[1]]()
