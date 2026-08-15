# SonicNest Android Signing and Distribution Policy

## Initial public channel

The initial repository-supported Android public distribution channel is **Google Play**, using an Android App Bundle (`.aab`) produced from the exact tested/tagged source revision.

SonicNest should use **Play App Signing** for the production app-signing key and a separate maintainer-controlled **upload key** for Play uploads. The upload key, its password, any Play service-account credential, and any private signing material must remain outside this public repository.

A separately distributed signed APK can be considered later as an additional channel, but GitHub APK distribution is not currently declared as the primary Android release path and must not be implied by hosted unsigned/non-production candidate artifacts.

## Repository boundary

The repository may contain:

- application ID/package configuration;
- permission/service declarations;
- deterministic branding resources and generators;
- unsigned or non-production release-mode build validation;
- public signing/distribution policy;
- release evidence fields;
- scripts that consume externally provided secure signing configuration without embedding secrets.

The repository must not contain:

- `.jks` or `.keystore` private key files;
- signing passwords;
- `key.properties` with secrets;
- Google Play service-account JSON credentials;
- Play Console API tokens;
- copied production certificates containing private keys;
- screenshots/logs that expose secret values.

Public certificate fingerprints, package identity, version, signing status, and non-secret Play release metadata can be recorded in release evidence.

## Hosted CI artifacts

The manual release-candidate workflow builds release-mode Android APK/AAB artifacts only as **engineering validation outputs**. They are not production Play artifacts merely because release-mode compilation succeeds.

The exact generated Android signing state can vary with generated Flutter host defaults and protected build configuration. Therefore hosted candidate output must be described as **non-production-signed / not approved for Play production** unless a protected signing environment has explicitly supplied and verified the intended upload/release identity. Do not infer production signing from `--release` alone.

## Protected production build

For a Play production/internal-testing candidate:

1. freeze the exact source revision and version;
2. complete repository preflight and required cross-platform/release-mode automation;
3. inject the maintainer-owned Android upload-key configuration only in the protected release environment;
4. build the release AAB from that exact revision;
5. verify package/application ID and version information;
6. verify the signing certificate/upload identity using Android tooling appropriate to the artifact;
7. record the non-secret certificate fingerprint/identity in the release evidence record;
8. upload first to an appropriate Play testing track when required by the release process;
9. perform real-device microphone, background/foreground-service, routing, codec, storage, accessibility, branding, and upgrade testing against the actual distributed candidate;
10. complete the Play Data safety/store-listing review against the exact built artifact and current Play definitions;
11. promote to production only after the stable-release checklist is complete.

## Versioning

The Android package version must remain derived consistently from the repository release version/build number. Never reuse a Play version code that has already been uploaded. Version changes for a release candidate must be committed before the candidate is built so evidence refers to immutable source.

## Permissions and foreground service

The Play listing and policy declarations must match the exact generated Android manifest. Microphone access exists for explicit user-started recording. Any foreground recording service exists to support an ongoing user-started recording and must remain visible/declared according to the Android version and Play policy applicable to the release.

Do not claim universal background behavior from hosted compilation. Test current Android/OEM lifecycle and foreground-service behavior on representative physical devices.

## Play listing/privacy boundary

`docs/STORE_LISTING.md` is the source-controlled draft, not a substitute for the current Play Console questionnaire. Before submission, review:

- microphone and foreground-service declarations;
- imported/exported user-selected files;
- user-initiated sharing;
- absence/presence of analytics, advertising, account, cloud, or telemetry SDKs in the exact artifact;
- Data safety definitions current at submission time;
- target SDK/permission policy requirements current at submission time;
- real screenshots from the tested candidate.

## Future non-Play channel

If SonicNest later publishes a signed APK through GitHub Releases, F-Droid, another store, or direct download, that channel needs its own signing/update/trust model, checksum policy, install/upgrade evidence, and listing/privacy review. It must not silently reuse Play-only assumptions.

## Remaining maintainer action

The policy decision is complete. Actual Play Console ownership, Play App Signing enrollment, upload-key generation/storage, protected signing configuration, testing-track upload, review, and production promotion remain maintainer-owned release actions and must stay unchecked until actually completed.
