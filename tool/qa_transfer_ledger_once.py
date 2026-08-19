#!/usr/bin/env python3
"""One-shot 2026-08-19 QA-transfer ledger synchronizer."""

from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8", newline="\n")


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    if new in text:
        return
    if old not in text:
        raise RuntimeError(f"{path}: replacement anchor drifted: {old!r}")
    write(path, text.replace(old, new, 1))


def insert_after(path: str, anchor: str, addition: str, marker: str) -> None:
    text = read(path)
    if marker in text:
        return
    if anchor not in text:
        raise RuntimeError(f"{path}: insertion anchor drifted: {anchor!r}")
    write(path, text.replace(anchor, anchor + addition, 1))


def append_once(path: str, block: str, marker: str) -> None:
    text = read(path)
    if marker in text:
        return
    write(path, text.rstrip() + "\n\n" + block.rstrip() + "\n")


def project_state() -> None:
    replace_once(
        "PROJECT_STATE.md",
        "  import_export: file_picker 10.3.10 + share_plus 12.0.2\n"
        "  screen_wake: wakelock_plus 1.4.0",
        "  import_export: file_picker 12.0.0-beta.7 + share_plus 13.3.0\n"
        "  screen_wake: wakelock_plus 1.7.0",
    )
    insert_after(
        "PROJECT_STATE.md",
        "  - About-accessible Manual QA evidence sessions with fixed source-controlled check IDs versioned local persistence deterministic JSON/Markdown export and optional privacy-safe diagnostics attachment\n",
        "  - same-version Manual QA JSON sharing and strict non-destructive import/merge with complete-catalog privacy timeline summary and redundant-session consistency validation explicit confirmation and a 2 MiB input bound\n"
        "  - QA evidence session timestamps are monotonic locally and malformed persisted result timestamps outside the declared session timeline are rejected or dropped\n",
        "same-version Manual QA JSON sharing",
    )
    insert_after(
        "PROJECT_STATE.md",
        "  stale_check_ids_dropped: true\n",
        "  persisted_timeline_validation: true\n"
        "  monotonic_local_status_clock: true\n"
        "  redundant_session_check_consistency_validation: true\n"
        "  latest_transfer_ui_commit: ca7841fca0f0edaea275802c2d88777cae4f547f\n"
        "  latest_transfer_integrity_commit: ecd49d33a4d923b0719c2a1a967f7291c9871e4d\n"
        "  latest_transfer_format_commit: 856617aa08235e424a629c9c9c999d2bbc8a2f2e\n",
        "latest_transfer_ui_commit:",
    )
    replace_once(
        "PROJECT_STATE.md",
        "  exports:\n"
        "    - deterministic JSON clipboard copy\n"
        "    - privacy-safe Markdown share file\n"
        "  release_gate_effect: supporting_evidence_only_no_manual_gate_closed\n"
        "  documentation: docs/MANUAL_QA_EVIDENCE.md",
        "  exports:\n"
        "    - deterministic JSON clipboard copy\n"
        "    - privacy-safe JSON share file\n"
        "    - privacy-safe Markdown share file\n"
        "  imports:\n"
        "    - exact-current-version JSON evidence bundle selection\n"
        "    - strict schema app identity privacy catalog metadata timeline summary and redundant session/check consistency validation\n"
        "    - newest-assessed-result-only non-destructive merge after explicit confirmation\n"
        "  import_file_limit_mib: 2\n"
        "  imported_not_run_clears_local_assessed_state: false\n"
        "  imported_diagnostics_adopted_as_session_state: false\n"
        "  release_gate_effect: supporting_evidence_only_no_manual_gate_closed\n"
        "  documentation: docs/MANUAL_QA_EVIDENCE.md",
    )
    insert_after(
        "PROJECT_STATE.md",
        "  - English is the only shipped locale; diagnostic-text policy is decided, while additional locales still require translation review, text-expansion testing, and accessibility QA\n",
        "  - imported Manual QA JSON consolidates fixed same-version status evidence only; it does not authenticate the tester prove the observation or adopt another device's diagnostics as local runtime state\n",
        "imported Manual QA JSON consolidates fixed same-version status evidence only",
    )
    insert_after(
        "PROJECT_STATE.md",
        "  - manual-QA structural verification proves export/catalog/privacy/summary consistency only and does not authenticate the tester or reproduce the physical accessibility stress filesystem branding signing or distribution observation\n",
        "  - same-version Manual QA import validates and merges structured status evidence only and likewise cannot prove the underlying manual observation or close physical/accessibility/stress/signing/store gates\n",
        "same-version Manual QA import validates and merges structured status evidence only",
    )


def changelog() -> None:
    insert_after(
        "CHANGELOG.md",
        "### Added\n",
        "- Same-version Manual QA evidence JSON sharing and strict import/merge for consolidating assessed release checks across test targets, with complete-catalog/privacy/timeline/summary/redundant-session validation, an explicit merge preview, and a 2 MiB input limit.\n"
        "- Regression coverage for evidence timeline bounds, monotonic local status timestamps, newest-result merge semantics, incompatible/tampered import rejection, transfer localization, and screen/picker integration.\n",
        "Same-version Manual QA evidence JSON sharing",
    )
    insert_after(
        "CHANGELOG.md",
        "### Changed\n",
        "- Manual QA status timestamps now remain monotonic when a device clock moves backward, and imported assessed evidence replaces local evidence only when its per-check timestamp is strictly newer.\n"
        "- Current dependency state records `file_picker 12.0.0-beta.7`, `share_plus 13.3.0`, and `wakelock_plus 1.7.0`.\n",
        "Manual QA status timestamps now remain monotonic",
    )
    insert_after(
        "CHANGELOG.md",
        "### Fixed\n",
        "- Malformed persisted QA sessions can no longer retain backward session timelines or assessed result timestamps outside their declared session interval.\n"
        "- Imported `notRun`, older, or equal-timestamp QA entries cannot clear or overwrite newer locally assessed evidence.\n"
        "- Contradictory `session.results` and normalized check-list evidence is rejected instead of being silently ignored during import.\n",
        "Contradictory `session.results`",
    )


def release_notes() -> None:
    insert_after(
        "RELEASE_NOTES.md",
        "### Project quality\n",
        "- Manual QA evidence can now be explicitly shared as structured JSON and imported on another target running the exact same SonicNest app version/build, enabling conservative multi-device evidence consolidation without automatic upload.\n"
        "- Import validates the current bundle/session schema, SonicNest identity/version, fixed privacy contract, complete QA catalog and metadata, chronological timestamps, recomputed summary, and agreement between redundant session results and the normalized check list before showing add/update/ignored counts for confirmation. Imported `notRun`, older, and equal-timestamp results never destructively clear newer local assessed evidence.\n"
        "- Local QA evidence timestamps remain monotonic across backward device-clock changes, and malformed persisted result timestamps outside the session timeline are discarded before re-export.\n",
        "Manual QA evidence can now be explicitly shared as structured JSON",
    )


def roadmap() -> None:
    insert_after(
        "ROADMAP.md",
        "- Offline Manual QA JSON structural review is implemented with source-controlled catalog membership, schema/timestamp/privacy/summary checks, optional exact-version/diagnostics/freshness/all-pass policy, and permanent Python regression coverage.\n",
        "- Same-version Manual QA JSON transfer is implemented with explicit JSON sharing, strict import validation including redundant session/check consistency, newest-assessed-result-only merge semantics, a 2 MiB file bound, and user confirmation before persistence.\n"
        "- QA evidence persistence now enforces chronological session/result bounds and monotonic local status timestamps so a clock rollback cannot corrupt the ledger timeline.\n",
        "Same-version Manual QA JSON transfer is implemented",
    )
    insert_after(
        "ROADMAP.md",
        "Implemented: an About-accessible manual evidence ledger backed by a source-controlled release-check catalog; local versioned persistence; `notRun`, `passed`, `failed`, and `blocked` states; serialized status writes; reset handling; complete-catalog progress counts; deterministic JSON/Markdown export; fixed privacy flags; stale-check removal; and regression coverage for the model, persistence, catalog, localization, and export privacy boundary.",
        " The ledger now also supports explicit JSON file sharing and exact-current-version JSON import with strict catalog/privacy/timeline/summary/redundant-session validation, a bounded 2 MiB input, merge-count confirmation, and non-destructive newest-assessed-result-only consolidation.",
        "bounded 2 MiB input, merge-count confirmation",
    )


def todo() -> None:
    insert_after(
        "TODO.md",
        "- [x] Publish `docs/FINAL_REPOSITORY_AUDIT_2026-08-18.md` and keep repository-complete work distinct from still-open physical/accessibility/signing/store/stable-release evidence.\n",
        "- [x] Add explicit Manual QA JSON sharing plus exact-current-version strict import/merge with complete-catalog/privacy/timeline/summary/redundant-session validation, a 2 MiB input bound, monotonic timestamps, merge preview, and newest-assessed-result-only persistence.\n",
        "Add explicit Manual QA JSON sharing plus exact-current-version strict import/merge",
    )
    replace_once(
        "TODO.md",
        "Use it to make real-device/system testing reproducible and exportable. JSON exports can be reviewed offline with `tool/verify_manual_qa_evidence.py`; structural verification is supporting evidence only.",
        "Use it to make real-device/system testing reproducible and exportable. JSON evidence can also be explicitly shared and conservatively merged on another target running the exact same SonicNest version/build; only strictly newer assessed results are adopted and imported `Not run` never clears local assessed evidence. JSON exports can be reviewed offline with `tool/verify_manual_qa_evidence.py`; structural verification and in-app merge are supporting evidence only.",
    )


def what_changed() -> None:
    append_once(
        "what_changed.md",
        """## 2026-08-19 — Manual QA evidence transfer and timeline hardening

### Implemented

- Added strict same-version Manual QA evidence JSON import for consolidating fixed release-check status evidence across test targets.
- Added explicit JSON evidence file sharing alongside the existing clipboard JSON and Markdown share paths.
- Added complete current-catalog validation with unknown/missing/duplicate-ID rejection and exact category/physical-target/external-tooling metadata checks.
- Added exact SonicNest app-version matching, fixed privacy-contract validation, chronological bundle/session/result validation, recomputed summary consistency, and cross-checking between redundant `session.results` and normalized check-list evidence before any merge is offered.
- Added a 2 MiB import-file bound before reading selected evidence JSON.
- Added a confirmation dialog that reports assessed, added, updated, and ignored evidence counts before persistence.
- Added a non-destructive merge rule: only a strictly newer assessed per-check result can replace local evidence; imported `Not run`, older, or equal-timestamp values never clear or overwrite newer local assessed state.
- Imported diagnostics are intentionally not adopted as local runtime/session state; a fresh local diagnostic snapshot remains an explicit separate action.
- Hardened persisted QA session decoding so backward session timelines are rejected and assessed results outside the declared session interval are discarded.
- Hardened local QA status updates so backward device-clock changes cannot move the session timestamp backward.
- Added focused model, import-service, validation, localization, source-integration, malformed-JSON, timestamp, catalog-tamper, timestamped-`Not run`, and redundant-session consistency regressions for the transfer path.
- Updated Manual QA evidence documentation with the transfer workflow and explicit manual-gate boundary.
- Synchronized `PROJECT_STATE.md` dependency versions with the current `pubspec.yaml` declarations.

### Source hygiene and validation boundary

- Canonical Dart formatting was applied by GitHub Actions in commit `856617aa08235e424a629c9c9c999d2bbc8a2f2e`, including the remaining QA transfer formatting and final-newline fix in `qa_evidence_screen.dart`.
- No new analyzer/test/build run is claimed here unless its exact workflow run is separately observed and recorded. Existing historical green validation entries remain tied to their exact source revisions.
- The permanent workflow set is restored to the maintained six workflows after the ledger sync cleanup; temporary one-shot workflow/helper files are not part of the intended final tree.
- No physical-device, accessibility, stress/soak, signing, notarization, store-console, or stable-release evidence gate is marked complete by this work.

### Key implementation commits

- `1d6809112ff39200e2749379bd92be84b3bcd983` — persisted QA timeline invariants and newest-result merge primitive.
- `381b6ebf2ce9718491c9575f8ad3e7799d924ef3` and `e64600b143305b607bdd907cf3f91720e31078cc` — strict evidence import service and status-count correction.
- `67bbd5294cae595a8cc7c3c2074aa75043b80a00` — JSON evidence file picker.
- `ca7841fca0f0edaea275802c2d88777cae4f547f` — JSON share/import user flow and confirmation UI.
- `1797555cc5771916d6e34ae49689f6bd76441dbe` — monotonic local QA status timestamps.
- `ecd49d33a4d923b0719c2a1a967f7291c9871e4d` — redundant session/check evidence cross-validation.
- `4370a817c2b59d83020c5081731d77cf5baea659`, `ed4f0c51bc85e486cbfc1e810fd1ceecb5477de8`, `9b6933e1c43ec6d69bcce0452adfee121ac9a3a0`, `cf28fdced27b0c0e6d38b5d7f38af5b557ca6c82`, `29688d02d925976b99b721e8111586d727607881`, `dbc8fb6461dc0159004aee595ad6decb58384398`, `1e5ff095fba929dd99cac935f9de14f48fed1416`, `0677d9ad6da1ee23cd7b83e603c40f6679609534`, `6121f2af986814bbde4641f6026b3809d6098bcd`, and `9e99caf5b1319f7038bf2a02ecab1e034192b836` — focused regression coverage.
- `856617aa08235e424a629c9c9c999d2bbc8a2f2e` — canonical Dart formatting for the transfer source present at that revision.

### Release status

SonicNest remains a development preview. The unchecked `TODO.md` items still require the real devices/systems, sustained workloads, representative media, accessibility tooling, maintainer-owned signing credentials, distribution-console access, translation review, or final release approval described there.
""",
        "## 2026-08-19 — Manual QA evidence transfer and timeline hardening",
    )


def main() -> None:
    project_state()
    changelog()
    release_notes()
    roadmap()
    todo()
    what_changed()


if __name__ == "__main__":
    main()
