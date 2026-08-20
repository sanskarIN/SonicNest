# SonicNest Branding Pipeline

SonicNest keeps its approved brand geometry in source control and generates native and Web raster assets deterministically during development and CI. This avoids maintaining many manually edited PNG copies that can drift away from the project mark.

## Source of truth

- `assets/logo/sonicnest_mark.svg`: human-readable vector mark.
- `assets/logo/sonicnest_logo.svg`: wider repository/application logo.
- `tool/generate_brand_assets_v2.dart`: deterministic raster implementation used for cross-platform build tooling.
- `assets/branding/gumroad_store_badge.svg`: source-controlled promotional storefront badge for https://ramsandesh.gumroad.com; separate from SonicNest launcher/splash identity.

The raster generator reproduces the SonicNest gradient, microphone mark, stand, and surrounding sound bars. It writes:

- `assets/generated/sonicnest_icon.png`
- `assets/generated/sonicnest_icon_foreground.png`
- `assets/generated/sonicnest_splash.png`

These PNGs are generated outputs and are intentionally ignored by Git.

## Apply branding

Bash-capable environments:

```bash
flutter pub get
bash tool/apply_branding.sh
```

Windows PowerShell:

```powershell
flutter pub get
./tool/apply_branding.ps1
```

The branding helpers require the generated Android, iOS, macOS, Windows, and Web hosts and then:

1. Run the deterministic Dart raster generator.
2. Generate Android, iOS, macOS, Windows, and Web launcher/application icon resources from the project configuration in `pubspec.yaml`.
3. Generate Android, iOS, and Web splash resources, including Android 12+ launch-screen resources.

## Android

The launcher configuration uses a SonicNest blue background plus a transparent foreground mark for adaptive icons. A monochrome foreground is also generated for launchers that support themed icons. The complete square icon remains available for legacy launcher sizes.

## iOS

The generated full icon is used for the iOS application icon set. Alpha is removed for the final iOS icon output. Native launch-screen resources use the generated splash mark.

## macOS

The generated full icon is used to populate the macOS application icon set. Final release candidates still require visual inspection at multiple dock/icon sizes on real macOS hardware.

## Windows

The generated full icon is converted into the Windows application icon resources by the launcher tooling. Final signed/package formats still require visual inspection in Explorer, taskbar, Start, shortcuts, and installer surfaces.

## Web / PWA host

`pubspec.yaml` enables Web generation in `flutter_launcher_icons` with the SonicNest icon plus the project blue theme/background color. `flutter_native_splash` also enables Web output.

Because the `web/` host is generated reproducibly by `tool/bootstrap_platforms.sh` or `tool/bootstrap_platforms.ps1`, browser manifest/icon/splash resources are regenerated after host bootstrap instead of being maintained as a separate hand-edited asset tree.

The Web release still requires visual checks for:

- tab/app icon rendering at browser-selected sizes;
- light/dark startup transitions;
- installed-PWA icon and launch treatment where supported;
- mobile home-screen icon treatment where supported;
- browser cache/update behavior after branding changes;
- high-DPI and narrow/wide layout appearance.

A successful Web branding generation or build does not prove how every browser/OS launcher crops or caches the generated assets.

## Linux

Debian `.deb` is the initial repository-supported Linux installation format. `tool/build_linux_deb.sh` consumes `assets/generated/sonicnest_icon.png` and installs it as `/usr/share/icons/hicolor/512x512/apps/sonicnest.png`. The package also installs `packaging/linux/debian/sonicnest.desktop`, which references the icon by the freedesktop name `sonicnest`, and AppStream metadata under `/usr/share/metainfo/`.

`tool/verify_linux_deb.sh` checks that the icon, executable, desktop entry, AppStream metadata, package control data, and checksum are present and structurally valid. `desktop-file-validate` and `appstreamcli` are used when available. See `docs/LINUX_PACKAGING.md` for package construction and installation testing.

The packaged icon still requires visual review on representative Linux desktop environments. Structural CI validation is not a substitute for installing the `.deb` and inspecting launcher, menu, task-switcher, scaling, and uninstall behavior on real systems.

## Platform splash versus Flutter startup UI

Native/Web splash resources cover the time before Flutter paints its first application frame. After Flutter starts, the native application uses `SplashScreen` for its branded in-app startup/loading and recoverable failure experience, while the browser-safe application enters its dedicated recorder surface. Generated host splash resources intentionally use the same SonicNest visual identity.

## Gumroad storefront badge

The repository also includes `assets/branding/gumroad_store_badge.svg` as an original promotional badge highlighting **https://ramsandesh.gumroad.com**. It is used in public-facing project documentation and complements the compact in-app storefront strip. It is intentionally separate from the SonicNest launcher icon, splash resources, and application mark.

The promotional badge must keep the destination readable, remain optional, and must not be presented as an exact copy of Gumroad's official trademark artwork. Opening the storefront remains an explicit user action; the badge itself performs no network request inside SonicNest.

## Validation rule

Successful generation, compilation, and package-structure verification prove that the resource pipeline is structurally valid. They do not prove that every icon crop, launcher mask, dark-mode splash, Web/PWA icon, store preview, package installation surface, browser cache state, or OS-specific rendering is visually correct. Real release-candidate inspection remains required and is tracked in `docs/QA_CHECKLIST.md`, `docs/WEB_SUPPORT.md`, and `TODO.md`.
