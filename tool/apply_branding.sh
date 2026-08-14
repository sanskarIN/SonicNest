#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v dart >/dev/null 2>&1; then
  echo "Dart is required. Install Flutter and place its bin directory on PATH." >&2
  exit 127
fi

if [[ ! -d android || ! -d ios || ! -d macos || ! -d windows ]]; then
  echo "Platform hosts are missing. Run tool/bootstrap_platforms.sh first." >&2
  exit 2
fi

dart tool/generate_brand_assets_v2.dart

dart run flutter_launcher_icons
dart run flutter_native_splash:create

echo "SonicNest native launcher icons and splash assets are applied."
