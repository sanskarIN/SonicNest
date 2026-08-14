#!/usr/bin/env bash
set -euo pipefail

APP="/opt/sonicnest/sonic_nest"
DESKTOP="/usr/share/applications/sonicnest.desktop"
ICON="/usr/share/icons/hicolor/512x512/apps/sonicnest.png"
METAINFO="/usr/share/metainfo/io.github.sanskarIN.SonicNest.metainfo.xml"
LICENSE_FILE="/usr/share/doc/sonicnest/LICENSE"
NOTICE_FILE="/usr/share/doc/sonicnest/NOTICE"

if ! dpkg-query -W -f='${Status}\n' sonicnest 2>/dev/null | grep -Fxq 'install ok installed'; then
  echo "SonicNest Debian package is not installed." >&2
  exit 2
fi

for required in "$APP" "$DESKTOP" "$ICON" "$METAINFO" "$LICENSE_FILE" "$NOTICE_FILE"; do
  if [[ ! -e "$required" ]]; then
    echo "Installed package payload is missing: $required" >&2
    exit 3
  fi
done

if [[ ! -x "$APP" ]]; then
  echo "Installed SonicNest executable is not executable: $APP" >&2
  exit 3
fi
if [[ ! -s "$ICON" ]]; then
  echo "Installed SonicNest icon is empty: $ICON" >&2
  exit 3
fi

grep -Fxq 'Exec=/opt/sonicnest/sonic_nest' "$DESKTOP"
grep -Fxq 'Icon=sonicnest' "$DESKTOP"
grep -Fq '<id>io.github.sanskarIN.SonicNest</id>' "$METAINFO"
grep -Fq '<developer id="io.github.sanskarin">' "$METAINFO"

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$DESKTOP"
fi
if command -v appstreamcli >/dev/null 2>&1; then
  appstreamcli validate --no-net "$METAINFO"
fi

if ! command -v xvfb-run >/dev/null 2>&1; then
  echo "xvfb-run is required for the installed-package startup smoke test." >&2
  exit 127
fi

LOG="${TMPDIR:-/tmp}/sonicnest-installed-smoke.log"
rm -f "$LOG"
set +e
LIBGL_ALWAYS_SOFTWARE=1 timeout 8s xvfb-run -a "$APP" >"$LOG" 2>&1
STATUS=$?
set -e

if [[ $STATUS -eq 124 ]]; then
  echo "SonicNest remained running for the startup smoke-test window."
elif [[ $STATUS -eq 0 ]]; then
  echo "SonicNest exited cleanly before the startup smoke-test window ended."
else
  echo "Installed SonicNest failed its virtual-display startup smoke test (exit $STATUS)." >&2
  cat "$LOG" >&2 || true
  exit "$STATUS"
fi

if grep -Eqi '(segmentation fault|symbol lookup error|error while loading shared libraries)' "$LOG"; then
  echo "Installed SonicNest startup log contains a fatal runtime-loader signal." >&2
  cat "$LOG" >&2
  exit 4
fi

echo "Installed Debian package smoke test passed."
