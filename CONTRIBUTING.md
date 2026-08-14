# Contributing to SonicNest

Thank you for helping improve SonicNest.

## Development workflow

1. Fork or branch from `main`.
2. Run `bash tool/bootstrap_platforms.sh` after cloning or changing Flutter SDK versions.
3. Run `flutter pub get`.
4. Keep changes focused and add tests for behavior changes.
5. Run formatting, analysis, and tests before opening a pull request.
6. Use Conventional Commit-style messages when practical.

## Required checks

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Do not commit secrets, signing keys, personal recordings, build outputs, or local environment files.

## Audio changes

Audio code must preserve originals unless the user explicitly chooses destructive deletion. New codecs must have a documented platform support and licensing review in `docs/CODECS.md`.

## Commit identity

Maintainers using local Git may configure:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```
