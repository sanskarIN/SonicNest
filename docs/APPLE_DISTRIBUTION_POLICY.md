# SonicNest Apple Signing and Distribution Policy

## iOS initial channel

The initial repository-supported iOS public distribution channel is the **Apple App Store**, with **TestFlight** used for candidate distribution/testing where appropriate.

A public iOS build must be produced from the exact tested/tagged source revision using maintainer-owned Apple Developer Team signing/provisioning configuration. The repository must not contain private signing certificates, private keys, provisioning profiles, App Store Connect API private keys, or credential secrets.

The existing hosted `--no-codesign` iOS release/debug builds are compilation and packaging evidence only. They are not installable App Store/TestFlight artifacts and must not be represented as such.

## macOS initial channel

The initial repository-supported macOS public distribution channel is **GitHub Releases** with a properly signed and notarized application archive from the exact tested/tagged source revision.

A future Mac App Store channel may be added separately, but it is not currently claimed. Mac App Store sandbox/capability/distribution behavior must not be inferred from the GitHub Releases channel.

## Credential boundary

Keep all Apple private signing and distribution material outside the public repository, including:

- certificate private keys or exported `.p12`/`.pfx` files;
- certificate passwords;
- provisioning profiles used as private release configuration;
- App Store Connect API private keys (`.p8`) and associated secrets;
- Apple ID/app-specific passwords or session credentials;
- notarization credential secrets;
- private CI keychains containing release identities.

The repository may record non-secret evidence such as Team ID, certificate subject, signing status, entitlements reviewed, notarization request/result identifiers, app version/build, and tested OS/device versions.

## iOS protected release flow

Before an iOS candidate can be submitted to TestFlight/App Store:

1. freeze the exact source revision, version, and build number;
2. pass repository preflight and required hosted release-mode validation;
3. inject maintainer-owned Apple signing/provisioning configuration only in the protected release environment;
4. build/archive the iOS application from that exact revision;
5. verify bundle identifier, version/build, entitlements, microphone usage text, and required background modes;
6. verify the actual signing identity/provisioning state;
7. upload to the intended TestFlight/App Store Connect context;
8. test the distributed candidate on physical iPhone/iPad hardware, including microphone permission grant/deny/revoke, routing where available, background/lock-screen behavior, interruptions, playback/media controls, import/export/share, storage/recovery, accessibility, branding, and upgrade behavior;
9. review App Privacy/store metadata against the exact candidate and current Apple definitions;
10. submit/promote only after stable-release gates are complete.

## macOS protected release flow

Before a macOS GitHub Release candidate can be public:

1. freeze the exact source revision and version;
2. build the release application on a supported macOS/Xcode host;
3. sign the application and nested code with the intended maintainer-controlled Developer ID identity;
4. verify code signing and entitlements on the exact built application;
5. submit the final candidate for Apple notarization using protected credentials;
6. confirm successful notarization and staple/verify the notarization result where appropriate for the chosen archive flow;
7. package the exact signed/notarized application bytes intended for publication;
8. generate SHA-256 only after the final public archive bytes are fixed;
9. test the downloaded/extracted artifact on representative macOS systems, including microphone permission, capture, playback/import/export, media controls, accessibility, branding, quarantine/Gatekeeper behavior, and update/replacement behavior;
10. publish only after the release evidence record is complete.

## Entitlement and privacy review

The repository-generated host patch configures microphone usage text and the maintained macOS audio-input entitlement. Hosted compilation confirms those files are structurally accepted by the current toolchain; it does not prove final signed entitlements or App Store policy acceptance.

Before release, inspect the signed product rather than relying only on source configuration. Record:

- actual bundle identifiers;
- microphone usage description visible in the candidate;
- effective entitlements/capabilities;
- background audio behavior tested on physical iOS hardware;
- macOS microphone permission behavior;
- actual signing/notarization status.

## Store/listing boundary

Use `docs/STORE_LISTING.md` as the source-controlled draft. Final App Store/App Privacy answers must be reviewed against:

- the exact signed binary and dependency set;
- user-initiated sharing/export behavior;
- file picker/import behavior;
- current analytics/account/cloud/telemetry behavior;
- Apple's current privacy definitions and required declarations;
- only real screenshots captured from the tested candidate.

## Hosted CI boundary

Current Apple workflows intentionally validate:

- macOS debug compilation with generated branding;
- unsigned/no-codesign iOS debug compilation;
- release-candidate macOS release-mode archive without public signing/notarization;
- release-candidate iOS release-mode application bundle with `--no-codesign`.

These are useful repository engineering gates, not evidence of App Store installability, Developer ID trust, notarization, TestFlight availability, or real-device behavior.

## Remaining maintainer action

The iOS App Store/TestFlight and macOS signed/notarized GitHub Releases policy decisions are complete. Actual Apple Developer/App Store Connect ownership, certificate/provisioning/notarization credential configuration, protected signing, TestFlight/App Store submission, macOS notarization, and public promotion remain maintainer-owned release actions and must stay open until actually completed.
