# Linux Packaging

SonicNest uses a Debian `.deb` package as its first repository-supported Linux installation format. The package is intended for Debian-family systems and is produced from the Flutter Linux bundle without committing generated platform hosts or binary release output.

## Package layout

The generated package installs:

- `/opt/sonicnest/` — the complete Flutter Linux bundle.
- `/usr/share/applications/sonicnest.desktop` — desktop launcher entry.
- `/usr/share/icons/hicolor/512x512/apps/sonicnest.png` — deterministic SonicNest application icon.
- `/usr/share/metainfo/io.github.sanskarIN.SonicNest.metainfo.xml` — AppStream metadata.
- `/usr/share/doc/sonicnest/LICENSE` and `/usr/share/doc/sonicnest/NOTICE` — licensing notices.

The desktop launcher runs `/opt/sonicnest/sonic_nest` and resolves its icon through the freedesktop icon name `sonicnest`.

## Build prerequisites

Install the normal Flutter Linux desktop toolchain plus Debian packaging utilities. On Ubuntu/Debian CI-compatible hosts:

```bash
sudo apt-get update
sudo apt-get install -y \
  clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
  libjson-glib-dev ffmpeg pulseaudio-utils \
  desktop-file-utils appstream
```

A working Flutter stable installation must be on `PATH`.

## Build a release package

From the repository root:

```bash
flutter config --enable-linux-desktop
bash tool/bootstrap_platforms.sh
flutter pub get
dart tool/generate_brand_assets_v2.dart
flutter build linux --release
bash tool/build_linux_deb.sh release
bash tool/verify_linux_deb.sh
```

The package and SHA-256 checksum are written to `build/linux-package/`.

The package version defaults to the semantic version before the Flutter build metadata suffix in `pubspec.yaml`. For example, `0.1.0+1` becomes Debian package version `0.1.0`.

## Debug packaging validation

CI can package the existing debug bundle without claiming it is a distributable release:

```bash
flutter build linux --debug
bash tool/build_linux_deb.sh debug
bash tool/verify_linux_deb.sh
```

This validates package structure, metadata, executable permissions, icon presence, desktop integration metadata, AppStream metadata, and package checksum.

## Optional overrides

The builder supports narrowly scoped environment overrides for controlled release engineering:

```bash
SONICNEST_VERSION=0.1.0 \
SONICNEST_DEB_ARCH=amd64 \
SONICNEST_DEB_OUT_DIR=build/custom-linux-package \
  bash tool/build_linux_deb.sh release
```

Do not use an override to misrepresent the actual build architecture or release version.

## Installation testing

On a disposable Debian/Ubuntu test environment, install a generated package with the normal package manager so declared dependencies are resolved:

```bash
sudo apt install ./build/linux-package/sonicnest_0.1.0_amd64.deb
```

Then verify all of the following before public distribution:

- SonicNest appears in the desktop application launcher with the correct icon.
- The app starts from both the launcher and `/opt/sonicnest/sonic_nest`.
- Microphone permission and recording work with the target audio stack.
- Recording, playback, import/export, conversion, and editor operations work with real files.
- The icon looks correct at small and large desktop-shell sizes.
- Uninstalling removes the application payload and desktop integration cleanly.

## Release status

Repository automation can build and structurally verify an unsigned `.deb`, but that is not equivalent to a stable Linux release. Real-machine audio validation, accessibility review, long-duration testing, low-storage testing, final icon review, and final distribution/signing policy remain release gates tracked in `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md`.

The initial selected Linux package target is Debian `.deb`. Other formats such as Flatpak or AppImage may be evaluated later only when there is a concrete distribution need and a maintained release path.
