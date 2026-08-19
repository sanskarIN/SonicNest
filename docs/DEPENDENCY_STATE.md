# Dependency State Integrity

SonicNest keeps runtime dependency constraints in `pubspec.yaml`. Human-readable project status in `PROJECT_STATE.md` also names a small set of dependency versions because those versions materially describe the current recorder, player, processing, import/export, and screen-wake stack.

Those two surfaces must not silently drift.

## Canonical source

`pubspec.yaml` is the dependency-constraint source of truth. `PROJECT_STATE.md` is a maintained status summary, not a second package manifest.

The dependency-state verifier is:

```text
tool/verify_project_state_dependencies.py
```

Run it from the repository root:

```bash
python3 tool/verify_project_state_dependencies.py
```

The checker uses only the Python standard library. It reads the direct runtime constraints required by the project-state stack and compares them with the canonical `stack:` block in `PROJECT_STATE.md`.

## Protected dependency summary

The verifier currently protects these project-state relationships:

- `record` -> recorder stack;
- `just_audio`, `just_audio_background`, and `just_audio_media_kit` -> player stack;
- `ffmpeg_kit_flutter_new_audio` -> processing stack;
- `file_picker` and `share_plus` -> import/export stack;
- `wakelock_plus` -> screen-wake stack.

Caret constraints such as `^7.1.1` are summarized as their declared lower-bound version token (`7.1.1`). The processing summary intentionally uses the maintained `major.minor.x` notation when the direct FFmpeg package constraint is a conventional semantic-version token.

The checker deliberately rejects compound ranges, missing required dependency declarations, nested/path declarations for protected dependencies, missing canonical stack entries, and mismatched version summaries. Conservative failure is preferable to silently publishing a misleading project-state document.

## Current compatibility line

At this checkpoint, the maintained direct dependency summary is:

- `record 7.1.1`;
- `just_audio 0.10.6`;
- `just_audio_background 0.0.1-beta.17`;
- `just_audio_media_kit 2.1.0`;
- `ffmpeg_kit_flutter_new_audio 2.5.x` (from the `^2.5.0` constraint);
- `file_picker 12.0.0-beta.7`;
- `share_plus 13.3.0`;
- `wakelock_plus 1.7.0`.

The `file_picker` prerelease is intentional in the current repository history: the dependency line was moved to the v12 prerelease while preserving Android/AGP compatibility, then import/export call sites and their regression coverage were migrated to that API. `share_plus 13.3.0` and `wakelock_plus 1.7.0` are part of the compatible Windows `win32` 6 dependency graph selected during the final dependency-hardening pass.

Do not replace these constraints merely to make a newer number appear in the project. A dependency change should be validated through the relevant Flutter analysis/tests and platform builds, and the project-state summary must be updated in the same development sequence.

## CI contract

The permanent Repository Integrity Audit runs the dependency-state verifier after the state file is synchronized. Its unit tests cover matching state, stale import/export versions, stale screen-wake versions, malformed/missing protected dependencies, unsupported compound constraints, missing stack structure, and CLI success/failure behavior.

This check protects repository documentation integrity only. It does not prove runtime plugin compatibility by itself and does not replace Flutter dependency resolution, analyzer/tests, platform builds, or physical-device validation.
