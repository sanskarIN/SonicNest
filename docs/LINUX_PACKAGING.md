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
  desktop-file-utils appstream xvfb
```

A working Flutter stable installation must be on `PATH`. `xvfb` is only required for the automated installed-package GUI startup smoke test; it is not required to build the package itself.

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

## Automated install/startup/uninstall smoke test

The dedicated Linux package workflow performs a second validation layer after structural package verification:

1. Installs the generated `.deb` with `apt-get` so declared package dependencies are resolved through the normal package manager.
2. Confirms `dpkg-query` reports SonicNest as installed.
3. Runs `tool/smoke_test_installed_linux_deb.sh` against the installed filesystem rather than the staging directory.
4. Re-validates the installed executable, desktop entry, AppStream metadata, icon, LICENSE, and NOTICE.
5. Starts `/opt/sonicnest/sonic_nest` under `xvfb-run` with software rendering for a bounded startup smoke window and rejects runtime-loader/segmentation-fault signals.
6. Removes the package with `apt-get remove`.
7. Confirms the package-owned application payload, desktop entry, icon, and AppStream metadata are gone after removal.

Equivalent disposable-host commands after building the `.deb` are:

```bash
PACKAGE="$(find build/linux-package -maxdepth 1 -type f -name 'sonicnest_*.deb' -print -quit)"
sudo apt-get install -y "./$PACKAGE"
bash tool/smoke_test_installed_linux_deb.sh
sudo apt-get remove -y sonicnest
```

This CI smoke test strengthens packaging confidence, but it is still an automated virtual-display test on a hosted Ubuntu runner. It does **not** validate microphone routing, real desktop-shell behavior, actual user audio files, accessibility tools, hardware acceleration, long-running recording, low-storage recovery, upgrades on maintained user systems, or every Debian/Ubuntu release.

## Optional overrides

The builder supports narrowly scoped environment overrides for controlled release engineering:

```bash
SONICNEST_VERSION=0.1.0 \
SONICNEST_DEB_ARCH=amd64 \
SONICNEST_DEB_OUT_DIR=build/custom-linux-package \
  bash tool/build_linux_deb.sh release
```

Do not use an override to misrepresent the actual build architecture or release version.

## Installation testing on representative systems

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
- Upgrade from a prior compatible candidate behaves correctly.
- Uninstalling removes the application payload and desktop integration cleanly without silently deleting user recording-library data.

Record the exact distribution version, desktop environment, architecture, package filename, SHA-256, and observations in `docs/RELEASE_EVIDENCE_TEMPLATE.md`.

## Evidence levels

Linux package evidence is intentionally separated into three levels:

1. **Structural package verification** — proves the `.deb` contains the expected repository-owned package metadata, executable, icon, licensing files, and checksum.
2. **Hosted-runner install/startup/uninstall smoke** — proves the generated package can be installed through the package manager, its installed payload can pass metadata checks, the GUI can enter a bounded virtual-display startup window without obvious loader/crash signals, and package-owned integration files are removed by uninstall on the CI runner.
3. **Representative real-system QA** — proves microphone/routing behavior, actual desktop integration, accessibility, real workloads, upgrade behavior, visual quality, low-storage/long-duration behavior, and release suitability on specifically recorded systems.

Only the third level can satisfy the corresponding physical-system release gates.

## Release status

Repository automation can build, structurally verify, and hosted-runner smoke-test an unsigned `.deb`, but that is not equivalent to a stable Linux release. Real-machine audio validation, accessibility review, long-duration testing, low-storage testing, final icon review, representative upgrade testing, and final distribution/signing policy remain release gates tracked in `TODO.md`, `docs/QA_CHECKLIST.md`, and `docs/RELEASING.md`.

The initial selected Linux package target is Debian `.deb`. Other formats such as Flatpak or AppImage may be evaluated later only when there is a concrete distribution need and a maintained release path.
