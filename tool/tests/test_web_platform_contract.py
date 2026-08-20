from __future__ import annotations

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class WebPlatformContractTest(unittest.TestCase):
    def _text(self, relative: str) -> str:
        return (ROOT / relative).read_text(encoding="utf-8")

    def test_cross_platform_entry_point_is_conditionally_isolated(self) -> None:
        main = self._text("lib/main.dart")
        bootstrap = self._text("lib/bootstrap/bootstrap.dart")
        web_bootstrap = self._text("lib/bootstrap/bootstrap_web.dart")
        native_bootstrap = self._text("lib/bootstrap/bootstrap_native.dart")

        self.assertIn("bootstrapSonicNest()", main)
        self.assertIn("dart.library.io", bootstrap)
        self.assertIn("dart.library.js_interop", bootstrap)
        self.assertIn("bootstrap_native.dart", bootstrap)
        self.assertIn("bootstrap_web.dart", bootstrap)
        self.assertIn("main_web.dart", web_bootstrap)
        self.assertIn("dart:io", native_bootstrap)

    def test_web_entry_point_does_not_import_native_only_surfaces(self) -> None:
        web = self._text("lib/main_web.dart")

        forbidden = (
            "dart:io",
            "ffmpeg_kit_flutter",
            "path_provider",
            "just_audio_background",
            "storage_service.dart",
            "audio_processor.dart",
        )
        for marker in forbidden:
            with self.subTest(marker=marker):
                self.assertNotIn(marker, web)

        required = (
            "AudioRecorder",
            "startStream",
            "pcm16ToWav",
            "pcm16Duration",
            "_recoverFromCaptureFailure",
            "_captureGeneration",
            "generation != _captureGeneration",
            "cancelOnError: true",
            "StreamAudioSource",
            "SharePlus.instance.share",
            "downloadFallbackEnabled: true",
        )
        for marker in required:
            with self.subTest(marker=marker):
                self.assertIn(marker, web)

    def test_all_bootstrap_helpers_generate_web_host(self) -> None:
        bash = self._text("tool/bootstrap_platforms.sh")
        powershell = self._text("tool/bootstrap_platforms.ps1")
        expected = "android,ios,macos,linux,windows,web"

        self.assertIn(f"--platforms={expected}", bash)
        self.assertIn(f"--platforms={expected}", powershell)
        self.assertIn("! -d web", bash)
        self.assertIn("'web'", powershell)

    def test_branding_configuration_includes_web(self) -> None:
        pubspec = self._text("pubspec.yaml")
        bash = self._text("tool/apply_branding.sh")
        powershell = self._text("tool/apply_branding.ps1")

        self.assertIn("web:\n    generate: true", pubspec)
        self.assertIn("web: true", pubspec)
        self.assertIn("! -d web", bash)
        self.assertIn("'web'", powershell)

    def test_core_ci_builds_web_release(self) -> None:
        workflow = self._text(".github/workflows/ci.yml")

        self.assertIn("name: Web release build", workflow)
        self.assertIn("flutter config --enable-web", workflow)
        self.assertIn("flutter build web --release", workflow)
        self.assertNotIn("--target lib/main_web.dart", workflow)

    def test_release_candidate_requires_web_payload(self) -> None:
        workflow = self._text(".github/workflows/release-candidate.yml")
        manifest = self._text("tool/build_release_candidate_manifest.py")

        required_workflow_markers = (
            "name: Web release-mode artifact",
            "sonicnest-web-release.tar.gz",
            "sonicnest-web-release-candidate",
            "needs: [android, linux, windows, macos, ios, web]",
            "--artifact web=",
        )
        for marker in required_workflow_markers:
            with self.subTest(marker=marker):
                self.assertIn(marker, workflow)

        self.assertIn('"web"', manifest)
        self.assertIn("not applicable to static web bundle", manifest)

    def test_web_documentation_and_qa_are_present(self) -> None:
        web_support = self._text("docs/WEB_SUPPORT.md")
        web_qa = self._text("docs/WEB_QA_CHECKLIST.md")

        for marker in (
            "Android, iOS, macOS, Windows, and Linux",
            "flutter build web --release",
            "Release-candidate evidence",
            "Native-only capability boundary",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, web_support)

        for marker in (
            "Chromium-family",
            "Firefox",
            "Safari",
            "Microphone permission",
            "Hosting and cache policy",
            "Privacy and security review",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, web_qa)


if __name__ == "__main__":
    unittest.main()
