# SonicNest Windows Packaging

## Initial package decision

The initial repository-supported Windows distribution artifact is a **versioned x64 portable ZIP** containing the complete Flutter Windows release bundle.

This decision keeps packaging reproducible and reviewable without introducing installer-specific registry, elevation, auto-update, or machine-wide mutation behavior before those behaviors have been selected and tested. A future installer or Microsoft Store package can be added as a separate channel without changing the portable package contract.

The portable package decision does **not** weaken the signing policy. Public stable Windows artifacts remain subject to `docs/WINDOWS_SIGNING_POLICY.md`: the final public executable/package must use the maintainer-controlled Authenticode process selected for release. Hosted CI artifacts are unsigned validation outputs unless a protected signing environment is explicitly configured later.

## Build

On a Windows build host with Flutter and Visual Studio desktop prerequisites:

```powershell
flutter config --enable-windows-desktop
./tool/bootstrap_platforms.ps1
flutter pub get
./tool/apply_branding.ps1
flutter build windows --release
./tool/build_windows_portable.ps1 -Configuration release -ArtifactSuffix unsigned
```

The package builder:

- requires the complete Flutter Windows release bundle;
- reads the public version from `pubspec.yaml`;
- packages the entire runner directory rather than copying only the executable;
- produces a versioned x64 ZIP under `build\windows-package` by default;
- produces `SHA256SUMS.txt` for the exact ZIP bytes;
- produces `PACKAGE_INFO.txt` describing the version, architecture, build configuration, artifact name, checksum, and signing boundary;
- never creates or imports signing credentials.

For development-only validation, the default artifact suffix is `unsigned`. A protected release process may use a different label only after the exact packaged binaries have actually been signed and verified.

## Verify

Run:

```powershell
./tool/verify_windows_portable.ps1
```

The verifier extracts the archive into an isolated temporary directory and checks that:

- `sonic_nest.exe` exists and is non-empty;
- `flutter_windows.dll` is present;
- ICU data is present;
- Flutter assets are present;
- common private/signing credential file types are absent;
- a sibling `SHA256SUMS.txt`, when present, matches the exact archive bytes.

For a final signed candidate, require Authenticode validation of the packaged SonicNest executable:

```powershell
./tool/verify_windows_portable.ps1 -ArchivePath '<path-to-final-archive.zip>' -RequireSignature
```

`-RequireSignature` is intentionally not used for ordinary public CI because the repository does not contain or provision the maintainer's private signing identity.

## Portable use

Users must extract the complete ZIP before launching `sonic_nest.exe`. Running only the executable without its adjacent Flutter runtime, plugins, and `data` directory is unsupported.

The portable channel does not create Start-menu shortcuts, registry entries, file associations, services, scheduled tasks, or machine-wide installation state by itself.

## Public stable release boundary

Before a Windows portable ZIP can be called a stable public release:

1. freeze the exact source revision;
2. build the release bundle from that revision;
3. apply the maintainer-selected Authenticode process to the binaries that require signing;
4. package the signed bytes;
5. run `tool/verify_windows_portable.ps1 -RequireSignature` on the final archive;
6. regenerate and publish the checksum **after** signing/package bytes are final;
7. test extraction, launch, microphone capture/routing, playback, export, accessibility, branding, and cleanup on representative Windows systems;
8. record the tested Windows versions/architectures and signature identity in release evidence;
9. do not reuse an unsigned validation checksum for a signed artifact.

## Future installer/store channels

An installer, MSIX, Microsoft Store package, or managed update channel may be added later. Such a channel must have its own install/upgrade/uninstall tests, permission behavior, signing rules, and evidence. It must not silently replace the portable contract or be claimed as supported before those tests exist.
