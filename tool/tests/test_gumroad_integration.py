from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GUMROAD_URL = "https://ramsandesh.gumroad.com"


class GumroadIntegrationTest(unittest.TestCase):
    def test_source_controlled_badge_and_policy_are_present(self) -> None:
        self.assertTrue((ROOT / "assets/branding/gumroad_store_badge.svg").is_file())
        self.assertTrue((ROOT / "docs/LINKS_AND_PROMOTION.md").is_file())

        badge = (ROOT / "assets/branding/gumroad_store_badge.svg").read_text(
            encoding="utf-8"
        )
        policy = (ROOT / "docs/LINKS_AND_PROMOTION.md").read_text(
            encoding="utf-8"
        )
        self.assertIn(GUMROAD_URL, badge)
        self.assertIn(GUMROAD_URL, policy)
        self.assertIn("assets/branding/gumroad_store_badge.svg", policy)

    def test_primary_app_surfaces_keep_storefront_visible(self) -> None:
        constants = (ROOT / "lib/core/constants.dart").read_text(encoding="utf-8")
        shell = (ROOT / "lib/widgets/app_shell.dart").read_text(encoding="utf-8")
        promo = (ROOT / "lib/widgets/gumroad_promo_bar.dart").read_text(
            encoding="utf-8"
        )
        about = (ROOT / "lib/screens/about_screen.dart").read_text(encoding="utf-8")
        splash = (ROOT / "lib/screens/splash_screen.dart").read_text(encoding="utf-8")

        self.assertIn(f"gumroadStoreUrl = '{GUMROAD_URL}'", constants)
        self.assertIn("GumroadPromoBar(controller: controller)", shell)
        self.assertIn("AppConstants.gumroadStoreUrl", promo)
        self.assertIn("AppConstants.gumroadStoreUrl", about)
        self.assertIn("AppConstants.gumroadStoreUrl", splash)

    def test_public_documentation_highlights_storefront(self) -> None:
        required_paths = (
            "README.md",
            "SUPPORT.md",
            "PRIVACY.md",
            "docs/README.md",
            "docs/BRANDING.md",
            "docs/STORE_LISTING.md",
            "docs/USER_GUIDE.md",
            "docs/LINKS_AND_PROMOTION.md",
        )
        for relative in required_paths:
            with self.subTest(path=relative):
                text = (ROOT / relative).read_text(encoding="utf-8")
                self.assertIn(GUMROAD_URL, text)

        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        self.assertIn("assets/branding/gumroad_store_badge.svg", readme)


if __name__ == "__main__":
    unittest.main()
