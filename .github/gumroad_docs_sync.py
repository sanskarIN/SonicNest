#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
URL = "https://ramsandesh.gumroad.com"
BADGE = "assets/branding/gumroad_store_badge.svg"


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    if not text.endswith("\n"):
        text += "\n"
    (ROOT / path).write_text(text, encoding="utf-8", newline="\n")


def replace_once(text: str, old: str, new: str, path: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise RuntimeError(f"Marker not found in {path}: {old[:100]!r}")
    return text.replace(old, new, 1)


def commit(path: str, message: str) -> None:
    subprocess.run(["git", "add", "--", path], cwd=ROOT, check=True)
    status = subprocess.run(
        ["git", "diff", "--cached", "--quiet", "--", path], cwd=ROOT
    )
    if status.returncode == 0:
        return
    subprocess.run(["git", "commit", "-m", message], cwd=ROOT, check=True)


def update_readme() -> None:
    path = "README.md"
    text = read(path)
    badge_block = f'''<p align="center">
  <a href="{URL}">
    <img src="{BADGE}" alt="Visit the Ram Sandesh Gumroad storefront" width="720" />
  </a>
</p>

<p align="center"><strong>🛍️ Gumroad Store:</strong> <a href="{URL}">{URL}</a></p>'''
    text = replace_once(
        text,
        '</p>\n\n**SonicNest**',
        f'</p>\n\n{badge_block}\n\n**SonicNest**',
        path,
    )
    support_header = "## Support and links\n\n"
    text = replace_once(
        text,
        support_header,
        support_header + f"- 🛍️ **Gumroad Store:** {URL}\n",
        path,
    )
    write(path, text)
    commit(path, "docs: highlight Gumroad storefront in README")


def update_docs_index() -> None:
    path = "docs/README.md"
    text = read(path)
    intro = "This directory contains the maintained technical, user, QA, branding, packaging, reliability, and release documentation for SonicNest.\n\n"
    callout = f"**🛍️ Gumroad Store:** {URL}\n\n"
    text = replace_once(text, intro, intro + callout, path)
    marker = "## Privacy, security, support, and open source\n\n"
    link = "- [`LINKS_AND_PROMOTION.md`](LINKS_AND_PROMOTION.md) — canonical Gumroad/storefront, support, repository, business, promotion, and external-link behavior.\n"
    text = replace_once(text, marker, marker + link, path)
    write(path, text)
    commit(path, "docs: highlight Gumroad storefront in docs index")


def update_branding() -> None:
    path = "docs/BRANDING.md"
    text = read(path)
    source_marker = "- `tool/generate_brand_assets_v2.dart`: deterministic raster implementation used for native build tooling.\n"
    source_add = source_marker + f"- `{BADGE}`: source-controlled promotional storefront badge for {URL}; separate from SonicNest native launcher/splash identity.\n"
    text = replace_once(text, source_marker, source_add, path)
    validation_marker = "## Validation rule\n"
    section = f'''## Gumroad storefront badge

The repository also includes `{BADGE}` as an original promotional badge highlighting **{URL}**. It is used in public-facing project documentation and complements the compact in-app storefront strip. It is intentionally separate from the SonicNest launcher icon, native splash, and application mark.

The promotional badge must keep the destination readable, remain optional, and must not be presented as an exact copy of Gumroad's official trademark artwork. Opening the storefront remains an explicit user action; the badge itself performs no network request inside SonicNest.

'''
    text = replace_once(text, validation_marker, section + validation_marker, path)
    write(path, text)
    commit(path, "docs: document Gumroad storefront branding")


def update_store_listing() -> None:
    path = "docs/STORE_LISTING.md"
    text = read(path)
    marker = "**Repository:** https://github.com/sanskarIN/SonicNest\n\n"
    text = replace_once(
        text,
        marker,
        f"**Gumroad storefront:** {URL}\n\n" + marker,
        path,
    )
    old = "External links such as repository, support, business contact, or Buy Me a Coffee open only when the user chooses them and are then handled by the destination application/service under its own privacy terms."
    new = f"External links such as the Gumroad storefront ({URL}), repository, support, business contact, or Buy Me a Coffee open only when the user chooses them and are then handled by the destination application/service under its own privacy terms."
    text = replace_once(text, old, new, path)
    old_check = "8. Verify support/business links and email addresses."
    new_check = "8. Verify the highlighted Gumroad storefront, support/business links, and email addresses."
    text = replace_once(text, old_check, new_check, path)
    write(path, text)
    commit(path, "docs: add Gumroad storefront to distribution metadata")


def update_user_guide() -> None:
    path = "docs/USER_GUIDE.md"
    text = read(path)
    marker = "## 18. Getting help\n\n"
    paragraph = f'''## 18. Getting help

The shared SonicNest application shell highlights the optional **Gumroad Store** at {URL} across Home, Recorder, Library, Settings, and About. About also provides a dedicated storefront link, and startup shows the canonical address. Opening it is always an explicit user action and is never required to record, manage, play, edit, export, recover, or share local audio.

'''
    text = replace_once(text, marker, paragraph, path)
    write(path, text)
    commit(path, "docs: add Gumroad storefront to user guide")


def update_todo() -> None:
    path = "TODO.md"
    text = read(path)
    marker = "## Repository hygiene\n\n"
    item = "- [x] Keep the canonical Gumroad storefront (`https://ramsandesh.gumroad.com`) highlighted across the shared app shell, About/startup surfaces, README/support/public docs, and protect the integration with repository regression coverage.\n"
    text = replace_once(text, marker, marker + item, path)
    write(path, text)
    commit(path, "docs: record completed Gumroad integration hygiene")


def update_changelog() -> None:
    path = "CHANGELOG.md"
    text = read(path)
    marker = "### Added\n"
    item = f"- Canonical Gumroad storefront integration at `{URL}` with an app-wide optional storefront strip, dedicated About/startup visibility, a source-controlled promotional SVG badge, public-documentation highlighting, and regression protection.\n"
    text = replace_once(text, marker, marker + item, path)
    write(path, text)
    commit(path, "docs: record Gumroad storefront integration in changelog")


def update_release_notes() -> None:
    path = "RELEASE_NOTES.md"
    text = read(path)
    marker = "### Recorder\n"
    section = f'''### Project links and storefront

- **Gumroad Store:** {URL}
- The storefront is highlighted through a compact optional strip across primary app tabs, a dedicated About entry, the startup address, and public project documentation.
- A source-controlled promotional badge lives at `{BADGE}`. Storefront access is explicit and never required for core recording or local-library functionality.

'''
    text = replace_once(text, marker, section + marker, path)
    write(path, text)
    commit(path, "docs: add Gumroad storefront to release notes")


def update_roadmap() -> None:
    path = "ROADMAP.md"
    text = read(path)
    marker = "Completed in the current codebase:\n"
    item = f"- Canonical Gumroad storefront promotion at `{URL}` across the shared app shell, About/startup surfaces, README/public docs, with a source-controlled badge and automated regression protection.\n"
    text = replace_once(text, marker, marker + item, path)
    write(path, text)
    commit(path, "docs: record completed Gumroad integration in roadmap")


def update_project_state() -> None:
    path = "PROJECT_STATE.md"
    text = read(path)
    repo_marker = "repository: https://github.com/sanskarIN/SonicNest\n"
    public_links = f'''repository: https://github.com/sanskarIN/SonicNest
public_links:
  gumroad_store: {URL}
  buy_me_a_coffee: https://buymeacoffee.com/sanskarIN
  github_profile: https://www.github.com/sanskarIN
  gumroad_badge: {BADGE}
'''
    text = replace_once(text, repo_marker, public_links, path)
    feature_marker = "completed_features:\n"
    feature = "  - canonical Gumroad storefront highlighted in the shared app shell About startup README support and maintained public documentation with regression protection\n"
    text = replace_once(text, feature_marker, feature_marker + feature, path)
    write(path, text)
    commit(path, "docs: synchronize Gumroad integration project state")


def append_what_changed() -> None:
    path = "what_changed.md"
    text = read(path)
    heading = "# Continuation — 2026-08-17 — Gumroad storefront integration"
    if heading in text:
        return
    section = f'''

{heading}

## Objective

Highlight the canonical Ram Sandesh Gumroad storefront `{URL}` throughout SonicNest's public-facing application and documentation surfaces while keeping promotion optional, non-blocking, privacy-safe, and separate from core recorder functionality.

## Implemented

- Added `AppConstants.gumroadStoreUrl` as the single application-source canonical storefront URL.
- Added reusable `GumroadPromoBar` to the shared application shell, making the storefront visible across Home, Recorder, Library, Settings, and About without obscuring primary content.
- Added a dedicated About storefront tile and visible startup storefront address; neither surface auto-opens the destination.
- Added original source-controlled promotional badge `{BADGE}` with the storefront URL clearly rendered.
- Added `docs/LINKS_AND_PROMOTION.md` defining canonical project links, storefront prominence, external-action privacy boundaries, and maintenance expectations.
- Highlighted the storefront in README, support/privacy documentation, documentation index, branding guide, distribution listing draft, user guide, release notes, roadmap, TODO repository-hygiene record, and project state.
- Added Dart regression coverage for the canonical HTTPS storefront URI and Python repository-integration coverage for required app/documentation surfaces and badge presence.

## Privacy and product boundary

The Gumroad storefront is optional. SonicNest does not require a purchase to record, manage, play, edit, recover, export, or share audio. The app never auto-opens Gumroad and never automatically attaches/transmits recordings, Library metadata, diagnostics, or Manual QA evidence to the storefront. External navigation occurs only after explicit user action.

## Validation boundary

Repository and platform validation for the final Gumroad-integrated head is recorded by the permanent CI workflows. This integration does not alter or close any remaining physical-device, accessibility, stress, signing, notarization, store-console, or stable-release approval gate.
'''
    write(path, text.rstrip() + section + "\n")
    commit(path, "docs: append Gumroad storefront continuation history")


def main() -> None:
    update_readme()
    update_docs_index()
    update_branding()
    update_store_listing()
    update_user_guide()
    update_todo()
    update_changelog()
    update_release_notes()
    update_roadmap()
    update_project_state()
    append_what_changed()


if __name__ == "__main__":
    main()
