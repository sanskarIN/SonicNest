#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is required. Install the stable Flutter SDK and place flutter on PATH." >&2
  exit 127
fi

if [[ ! -d android || ! -d ios || ! -d macos || ! -d linux || ! -d windows ]]; then
  flutter create . \
    --project-name sonic_nest \
    --org in.sanskar \
    --platforms=android,ios,macos,linux,windows \
    --no-pub
fi

# Flutter creates a starter widget test for new hosts; SonicNest ships its own
# test suite and removes the template so it cannot reference the generated demo app.
rm -f test/widget_test.dart

cp tool/platform_overrides/android/app/src/main/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
mkdir -p android/app/src/main/kotlin/in/sanskar/sonic_nest
cp tool/platform_overrides/android/app/src/main/kotlin/in/sanskar/sonic_nest/MainActivity.kt \
  android/app/src/main/kotlin/in/sanskar/sonic_nest/MainActivity.kt
cp tool/platform_overrides/android/app/src/main/kotlin/in/sanskar/sonic_nest/RecordingForegroundService.kt \
  android/app/src/main/kotlin/in/sanskar/sonic_nest/RecordingForegroundService.kt

python3 tool/patch_generated_platforms.py

echo "SonicNest platform scaffolding is ready."
