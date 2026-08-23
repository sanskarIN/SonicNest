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
            "_cancelCaptureSubscriptions",
            "_captureGeneration",
            "generation != _captureGeneration",
            "cancelOnError: true",
            "onDone: () {",
            "_canChangeInputSettings",
            "StreamAudioSource",
            "SharePlus.instance.share",
            "downloadFallbackEnabled: true",
        )
        for marker in required:
            with self.subTest(marker=marker):
                self.assertIn(marker, web)

    def test_web_capture_controls_fail_closed(self) -> None:
        web = self._text("lib/main_web.dart")

        self.assertGreaterEqual(
            web.count("final generation = ++_captureGeneration;"),
            3,
            "start, stop, and cancel must each establish a new capture generation",
        )
        for marker in (
            "Could not change recording state. The incomplete capture was discarded",
            "Could not finish recording. The incomplete capture was discarded",
            "The recording was discarded locally, but the browser could not confirm microphone shutdown",
            "await _cancelCaptureSubscriptions();",
            "_captureGeneration++;\n    _timer?.cancel();",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, web)

    def test_web_capture_stream_completion_is_fail_closed(self) -> None:
        web = self._text("lib/main_web.dart")

        for marker in (
            "onDone: () {",
            "Browser audio capture ended unexpectedly. You can start a new recording.",
            "generation: generation",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, web)

        self.assertGreaterEqual(
            web.count("_recoverFromCaptureFailure("),
            6,
            "startup, stream error, stream completion, pause/resume, and stop paths must recover through the shared fail-closed handler",
        )

    def test_web_input_settings_lock_during_capture_transitions(self) -> None:
        web = self._text("lib/main_web.dart")

        self.assertIn(
            "bool get _canChangeInputSettings => !_busy && !_hasActiveCapture;",
            web,
        )
        self.assertGreaterEqual(
            web.count("_canChangeInputSettings"),
            7,
            "refresh, device, channel, and audio-processing controls must share the same transition lock",
        )

    def test_web_microphone_picker_follows_selected_device_state(self) -> None:
        web = self._text("lib/main_web.dart")

        self.assertIn(
            "key: ValueKey<String?>(_selectedDevice?.id),\n                        initialValue: _selectedDevice?.id,",
            web,
            "the stateful form field must remount when browser device refresh changes the selected microphone",
        )
        self.assertIn(
            "!devices.any((device) => device.id == _selectedDevice!.id)",
            web,
        )
        self.assertIn("_selectedDevice = null;", web)

    def test_web_playback_resumes_without_reloading_source(self) -> None:
        web = self._text("lib/main_web.dart")

        for marker in (
            "if (_playingId == recording.id) {",
            "await _player.pause();",
            "await _player.play();",
            "if (mounted && _playingId == recording.id)",
            "setState(() => _playingId = null);",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, web)

        self.assertGreaterEqual(web.count("await _player.play();"), 2)
        self.assertNotIn("unawaited(_player.play());", web)

    def test_web_playback_observes_async_player_errors(self) -> None:
        web = self._text("lib/main_web.dart")

        for marker in (
            "StreamSubscription<PlayerException>? _playerErrorSubscription;",
            "_player.errorStream.listen((error) {",
            "_lastPlayerErrorRecordingId = failedRecordingId;",
            "Could not continue playback:",
            "unawaited(_playerErrorSubscription?.cancel());",
            "final errorAlreadyReported = _lastPlayerErrorRecordingId == recording.id;",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, web)

        self.assertIn(
            "if (mounted && _playingId != null) {\n        setState(() => _playingId = null);\n      }\n      await _player.setAudioSource",
            web,
            "switching sources must clear the previous row before a new source can fail to load",
        )

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
