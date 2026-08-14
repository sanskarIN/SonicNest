#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for command in flutter dart python3; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "$command is required for SonicNest release preflight." >&2
    exit 127
  fi
done

bash tool/bootstrap_platforms.sh
flutter pub get
bash tool/apply_branding.sh

dart format --output=none --set-exit-if-changed \
  lib \
  test \
  tool/generate_brand_assets_v2.dart
flutter analyze --no-fatal-infos
flutter test

echo "SonicNest release-candidate source preflight passed."
