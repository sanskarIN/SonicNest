#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"
AAB="${2:-build/app/outputs/bundle/release/app-release.aab}"
REPORT="${3:-build/release-candidate/android/ANDROID_SIGNING_STATE.txt}"
EXPECTED_PACKAGE="io.github.sanskarin.sonic_nest"

for command in keytool jarsigner unzip sha256sum; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "$command is required to verify Android release-candidate artifacts." >&2
    exit 127
  fi
done

if [[ ! -f "$APK" ]]; then
  echo "Android release APK was not found: $APK" >&2
  exit 1
fi
if [[ ! -f "$AAB" ]]; then
  echo "Android release AAB was not found: $AAB" >&2
  exit 1
fi

ANDROID_SDK_ROOT_RESOLVED="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$ANDROID_SDK_ROOT_RESOLVED" || ! -d "$ANDROID_SDK_ROOT_RESOLVED/build-tools" ]]; then
  echo "ANDROID_SDK_ROOT or ANDROID_HOME must point to an Android SDK with build-tools." >&2
  exit 1
fi

latest_tool() {
  local name="$1"
  find "$ANDROID_SDK_ROOT_RESOLVED/build-tools" -maxdepth 2 -type f -name "$name" -print \
    | sort -V \
    | tail -n 1
}

AAPT="$(latest_tool aapt)"
APKSIGNER="$(latest_tool apksigner)"
if [[ -z "$AAPT" || ! -x "$AAPT" ]]; then
  echo "Could not find executable aapt in Android SDK build-tools." >&2
  exit 1
fi
if [[ -z "$APKSIGNER" || ! -x "$APKSIGNER" ]]; then
  echo "Could not find executable apksigner in Android SDK build-tools." >&2
  exit 1
fi

BADGING="$($AAPT dump badging "$APK")"
if ! grep -Fq "package: name='$EXPECTED_PACKAGE'" <<<"$BADGING"; then
  echo "APK package identity does not match $EXPECTED_PACKAGE." >&2
  printf '%s\n' "$BADGING" >&2
  exit 1
fi
if ! grep -Fq "application-label:'SonicNest'" <<<"$BADGING"; then
  echo "APK application label is not SonicNest." >&2
  printf '%s\n' "$BADGING" >&2
  exit 1
fi

APK_CERT="$($APKSIGNER verify --verbose --print-certs "$APK" 2>&1)"
if ! grep -Fq 'CN=Android Debug' <<<"$APK_CERT"; then
  echo "Hosted Android release APK is not signed by the expected Android Debug certificate." >&2
  printf '%s\n' "$APK_CERT" >&2
  exit 1
fi

AAB_CERT="$(keytool -printcert -jarfile "$AAB" 2>&1)"
if ! grep -Fq 'CN=Android Debug' <<<"$AAB_CERT"; then
  echo "Hosted Android release AAB is not signed by the expected Android Debug certificate." >&2
  printf '%s\n' "$AAB_CERT" >&2
  exit 1
fi
jarsigner -verify "$AAB" >/dev/null
unzip -tq "$APK" >/dev/null
unzip -tq "$AAB" >/dev/null

mkdir -p "$(dirname "$REPORT")"
{
  echo "SonicNest Android hosted release-candidate signing state"
  echo "Package: $EXPECTED_PACKAGE"
  echo "Application label: SonicNest"
  echo "Classification: Android Debug certificate / NON-PRODUCTION"
  echo
  echo "APK certificate inspection:"
  printf '%s\n' "$APK_CERT" | grep -E 'Signer #|certificate DN:|certificate SHA-256 digest:|certificate SHA-1 digest:' || true
  echo
  echo "AAB certificate inspection:"
  printf '%s\n' "$AAB_CERT" | grep -E 'Owner:|Issuer:|SHA1:|SHA256:|Signature algorithm name:' || true
  echo
  echo "APK SHA-256: $(sha256sum "$APK" | awk '{print $1}')"
  echo "AAB SHA-256: $(sha256sum "$AAB" | awk '{print $1}')"
  echo
  echo "This report proves only the hosted candidate's package identity, archive integrity, and non-production debug signing state."
  echo "It is not a Google Play production-signing or physical-device release approval."
} > "$REPORT"

cat "$REPORT"
