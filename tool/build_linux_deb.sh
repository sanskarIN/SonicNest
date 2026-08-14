#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BUILD_MODE="${1:-release}"
case "$BUILD_MODE" in
  debug|profile|release) ;;
  *)
    echo "Usage: $0 [debug|profile|release]" >&2
    exit 64
    ;;
esac

if ! command -v dpkg-deb >/dev/null 2>&1; then
  echo "dpkg-deb is required to build the Debian package." >&2
  exit 127
fi

if [[ ! -f assets/generated/sonicnest_icon.png ]]; then
  echo "Generated branding is missing. Run: dart tool/generate_brand_assets_v2.dart" >&2
  exit 2
fi

mapfile -t BUNDLES < <(find build/linux -mindepth 4 -maxdepth 4 -type d -path "*/${BUILD_MODE}/bundle" -print 2>/dev/null | sort)
if [[ ${#BUNDLES[@]} -ne 1 ]]; then
  echo "Expected exactly one Linux ${BUILD_MODE} bundle under build/linux/*/${BUILD_MODE}/bundle; found ${#BUNDLES[@]}." >&2
  exit 2
fi
BUNDLE="${BUNDLES[0]}"

if [[ ! -x "$BUNDLE/sonic_nest" ]]; then
  echo "Expected executable is missing: $BUNDLE/sonic_nest" >&2
  exit 2
fi

PUBSPEC_VERSION="$(awk '/^version:[[:space:]]*/ { print $2; exit }' pubspec.yaml)"
if [[ -z "$PUBSPEC_VERSION" ]]; then
  echo "Unable to read version from pubspec.yaml." >&2
  exit 2
fi
VERSION="${SONICNEST_VERSION:-${PUBSPEC_VERSION%%+*}}"
if [[ ! "$VERSION" =~ ^[0-9][0-9A-Za-z.+:~_-]*$ ]]; then
  echo "Invalid Debian package version: $VERSION" >&2
  exit 2
fi

ARCH="${SONICNEST_DEB_ARCH:-$(dpkg --print-architecture)}"
if [[ -z "$ARCH" ]]; then
  echo "Unable to determine Debian package architecture." >&2
  exit 2
fi

OUT_DIR="${SONICNEST_DEB_OUT_DIR:-build/linux-package}"
PACKAGE_BASENAME="sonicnest_${VERSION}_${ARCH}"
STAGE="$OUT_DIR/staging/$PACKAGE_BASENAME"
PACKAGE_PATH="$OUT_DIR/$PACKAGE_BASENAME.deb"

rm -rf "$STAGE"
mkdir -p \
  "$STAGE/DEBIAN" \
  "$STAGE/opt/sonicnest" \
  "$STAGE/usr/share/applications" \
  "$STAGE/usr/share/icons/hicolor/512x512/apps" \
  "$STAGE/usr/share/metainfo" \
  "$STAGE/usr/share/doc/sonicnest"

cp -a "$BUNDLE/." "$STAGE/opt/sonicnest/"
install -m 0644 packaging/linux/debian/sonicnest.desktop \
  "$STAGE/usr/share/applications/sonicnest.desktop"
install -m 0644 packaging/linux/debian/io.github.sanskarIN.SonicNest.metainfo.xml \
  "$STAGE/usr/share/metainfo/io.github.sanskarIN.SonicNest.metainfo.xml"
install -m 0644 assets/generated/sonicnest_icon.png \
  "$STAGE/usr/share/icons/hicolor/512x512/apps/sonicnest.png"
install -m 0644 LICENSE "$STAGE/usr/share/doc/sonicnest/LICENSE"
install -m 0644 NOTICE "$STAGE/usr/share/doc/sonicnest/NOTICE"

INSTALLED_SIZE_KIB="$(du -sk "$STAGE" | awk '{print $1}')"
cat > "$STAGE/DEBIAN/control" <<EOF
Package: sonicnest
Version: $VERSION
Section: sound
Priority: optional
Architecture: $ARCH
Maintainer: Sanskar <sanskarin@outlook.in>
Homepage: https://github.com/sanskarIN/SonicNest
Installed-Size: $INSTALLED_SIZE_KIB
Depends: libc6, libgtk-3-0, libstdc++6, libjson-glib-1.0-0, ffmpeg, pulseaudio-utils
Description: Privacy-first cross-platform sound and voice recorder
 SonicNest is a local-first recorder with recording, playback, organization,
 conversion, and non-destructive audio editing tools.
EOF

mkdir -p "$OUT_DIR"
rm -f "$PACKAGE_PATH"
dpkg-deb --root-owner-group --build "$STAGE" "$PACKAGE_PATH"
sha256sum "$PACKAGE_PATH" > "$PACKAGE_PATH.sha256"

echo "Built Debian package: $PACKAGE_PATH"
echo "Checksum: $PACKAGE_PATH.sha256"
