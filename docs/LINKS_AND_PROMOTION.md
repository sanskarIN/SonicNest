# SonicNest Links and Promotion

This file defines the public project/contact links that SonicNest surfaces in its application and maintained public-facing documentation.

## Canonical links

- **Gumroad storefront:** https://ramsandesh.gumroad.com
- **Buy Me a Coffee:** https://buymeacoffee.com/sanskarIN
- **GitHub profile:** https://www.github.com/sanskarIN
- **Repository:** https://github.com/sanskarIN/SonicNest
- **Primary business email:** sanskarin@outlook.in
- **Secondary business email:** sanskarin.business@gmail.com
- **Support email:** supportramsandesh@gmail.com

## Gumroad prominence contract

The Gumroad storefront is intentionally highlighted in these public surfaces:

1. the shared in-app shell used by Home, Recorder, Library, Settings, and About;
2. the About screen as a dedicated storefront link;
3. the Flutter startup screen as a visible storefront address;
4. the repository README with the source-controlled storefront badge;
5. the documentation index, support guide, user guide, store-listing draft, and branding guide;
6. release/project state records describing the current public-link configuration.

The storefront promotion must remain compact enough that recording, playback, editing, Library management, diagnostics, QA evidence, and accessibility controls remain usable. It must never block core recorder functionality, require a purchase, collect microphone/library data, or auto-open an external site.

## External-link behavior

Gumroad, Buy Me a Coffee, GitHub, business contact, and support destinations are opened only after an explicit user action. SonicNest does not automatically transmit recording content, Library metadata, diagnostics, or manual-QA evidence to those destinations.

The destination service/application applies its own privacy terms after the user chooses to open it.

## Storefront badge

The project-controlled promotional badge is:

- `assets/branding/gumroad_store_badge.svg`

It is an original SonicNest/Ram Sandesh storefront badge and is not presented as an exact copy of Gumroad's official trademark artwork. The visible destination printed in the badge must remain `https://ramsandesh.gumroad.com`.

## Maintenance rule

If a canonical link changes, update `lib/core/constants.dart` first, then update the public documentation and corresponding repository regression checks in the same change. The repository audit should fail when the Gumroad integration contract or its source-controlled badge is removed unintentionally.
