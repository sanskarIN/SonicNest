#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PACKAGE_PATH="${1:-}"
if [[ -z "$PACKAGE_PATH" ]]; then
  mapfile -t PACKAGES < <(find build/linux-package -maxdepth 1 -type f -name 'sonicnest_*.deb' -print 2>/dev/null | sort)
  if [[ ${#PACKAGES[@]} -ne 1 ]]; then
    echo "Usage: $0 <path-to-sonicnest.deb>" >&2
    echo "Without an argument, exactly one package must exist in build/linux-package." >&2
    exit 64
  fi
  PACKAGE_PATH="${PACKAGES[0]}"
fi

if [[ ! -f "$PACKAGE_PATH" ]]; then
  echo "Debian package not found: $PACKAGE_PATH" >&2
  exit 2
fi
if ! command -v dpkg-deb >/dev/null 2>&1; then
  echo "dpkg-deb is required to verify the Debian package." >&2
  exit 127
fi

WORK="build/linux-package/verify"
rm -rf "$WORK"
mkdir -p "$WORK/root" "$WORK/control"
dpkg-deb --extract "$PACKAGE_PATH" "$WORK/root"
dpkg-deb --control "$PACKAGE_PATH" "$WORK/control"

CONTROL="$WORK/control/control"
DESKTOP="$WORK/root/usr/share/applications/sonicnest.desktop"
METAINFO="$WORK/root/usr/share/metainfo/io.github.sanskarIN.SonicNest.metainfo.xml"
ICON="$WORK/root/usr/share/icons/hicolor/512x512/apps/sonicnest.png"
EXECUTABLE="$WORK/root/opt/sonicnest/sonic_nest"

for required in "$CONTROL" "$DESKTOP" "$METAINFO" "$ICON" "$EXECUTABLE"; do
  if [[ ! -e "$required" ]]; then
    echo "Required package payload is missing: $required" >&2
    exit 3
  fi
done

if [[ ! -x "$EXECUTABLE" ]]; then
  echo "Packaged SonicNest executable is not executable." >&2
  exit 3
fi
if [[ ! -s "$ICON" ]]; then
  echo "Packaged SonicNest icon is empty." >&2
  exit 3
fi

grep -Fxq 'Package: sonicnest' "$CONTROL"
grep -Eq '^Version: [0-9]' "$CONTROL"
grep -Eq '^Architecture: [A-Za-z0-9][A-Za-z0-9_-]*$' "$CONTROL"
grep -Fxq 'Exec=/opt/sonicnest/sonic_nest' "$DESKTOP"
grep -Fxq 'Icon=sonicnest' "$DESKTOP"
grep -Fq '<id>io.github.sanskarIN.SonicNest</id>' "$METAINFO"
grep -Fq '<launchable type="desktop-id">sonicnest.desktop</launchable>' "$METAINFO"

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$DESKTOP"
fi
if command -v appstreamcli >/dev/null 2>&1; then
  appstreamcli validate --no-net "$METAINFO"
fi

CHECKSUM_PATH="$PACKAGE_PATH.sha256"
if [[ -f "$CHECKSUM_PATH" ]]; then
  EXPECTED_CHECKSUM="$(awk 'NR == 1 { print $1 }' "$CHECKSUM_PATH")"
  ACTUAL_CHECKSUM="$(sha256sum "$PACKAGE_PATH" | awk '{ print $1 }')"
  if [[ -z "$EXPECTED_CHECKSUM" || "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]]; then
    echo "Debian package checksum verification failed for: $PACKAGE_PATH" >&2
    exit 3
  fi
  echo "$ACTUAL_CHECKSUM  $PACKAGE_PATH"
fi

echo "Verified Debian package: $PACKAGE_PATH"
