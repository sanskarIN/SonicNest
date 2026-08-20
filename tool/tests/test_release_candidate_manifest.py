from __future__ import annotations

import hashlib
import importlib.util
import tempfile
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / "build_release_candidate_manifest.py"
SPEC = importlib.util.spec_from_file_location("release_candidate_manifest", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
manifest_module = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(manifest_module)

ManifestError = manifest_module.ManifestError
build_manifest = manifest_module.build_manifest
EXPECTED_PLATFORMS = manifest_module.EXPECTED_PLATFORMS


class ReleaseCandidateManifestTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.pubspec = self.root / "pubspec.yaml"
        self.pubspec.write_text(
            "name: sonic_nest\nversion: 0.1.0+1\n",
            encoding="utf-8",
        )
        self.artifact_dirs = self._make_candidate()

    def tearDown(self) -> None:
        self.temp.cleanup()

    def _write_payload(self, directory: Path, name: str, data: bytes) -> str:
        path = directory / name
        path.write_bytes(data)
        return hashlib.sha256(data).hexdigest()

    def _make_candidate(self) -> dict[str, Path]:
        payload_names = {
            "android": (
                "sonicnest-android-release-nonproduction.apk",
                "sonicnest-android-release-nonproduction.aab",
            ),
            "linux": (
                "sonicnest-linux-release-unsigned.tar.gz",
                "sonicnest_0.1.0_amd64.deb",
            ),
            "windows": ("sonicnest-windows-x64-v0.1.0-portable-unsigned.zip",),
            "macos": ("sonicnest-macos-release-unsigned.zip",),
            "ios": ("sonicnest-ios-release-unsigned.zip",),
            "web": ("sonicnest-web-release.tar.gz",),
        }
        result: dict[str, Path] = {}
        for platform in EXPECTED_PLATFORMS:
            directory = self.root / platform
            directory.mkdir()
            result[platform] = directory
            (directory / "RELEASE_CANDIDATE_WARNING.txt").write_text(
                f"{platform} development-preview warning\n",
                encoding="utf-8",
            )
            checksum_lines = []
            for index, name in enumerate(payload_names[platform], start=1):
                payload = f"{platform}-payload-{index}".encode()
                digest = self._write_payload(directory, name, payload)
                checksum_lines.append(f"{digest}  {name}")
            (directory / "SHA256SUMS.txt").write_text(
                "\n".join(checksum_lines) + "\n",
                encoding="utf-8",
            )

        (result["android"] / "ANDROID_SIGNING_STATE.txt").write_text(
            "SonicNest Android hosted release-candidate signing state\n"
            "Package: io.github.sanskarin.sonic_nest\n"
            "Classification: Android Debug certificate / NON-PRODUCTION\n",
            encoding="utf-8",
        )
        return result

    def _build(self):
        return build_manifest(
            artifact_dirs=self.artifact_dirs,
            source_sha="a" * 40,
            workflow_run_id="123456",
            workflow_run_attempt="2",
            pubspec=self.pubspec,
        )

    def test_builds_manifest_for_all_platforms(self) -> None:
        manifest = self._build()

        self.assertEqual(manifest["applicationVersion"], "0.1.0+1")
        self.assertEqual(manifest["sourceSha"], "a" * 40)
        self.assertEqual(manifest["workflow"]["runId"], 123456)
        self.assertEqual(manifest["workflow"]["runAttempt"], 2)
        self.assertFalse(manifest["stableReleaseApproved"])
        self.assertEqual(
            [entry["platform"] for entry in manifest["platforms"]],
            list(EXPECTED_PLATFORMS),
        )
        web = next(
            entry for entry in manifest["platforms"] if entry["platform"] == "web"
        )
        self.assertEqual(web["build"], "release")
        self.assertEqual(web["signing"], "not applicable to static web bundle")

    def test_rejects_tampered_payload(self) -> None:
        target = self.artifact_dirs["ios"] / "sonicnest-ios-release-unsigned.zip"
        target.write_bytes(b"tampered")

        with self.assertRaisesRegex(ManifestError, "checksum mismatch"):
            self._build()

    def test_rejects_web_payload_tampering(self) -> None:
        target = self.artifact_dirs["web"] / "sonicnest-web-release.tar.gz"
        target.write_bytes(b"tampered-web")

        with self.assertRaisesRegex(ManifestError, "checksum mismatch"):
            self._build()

    def test_rejects_payload_missing_from_checksum_file(self) -> None:
        directory = self.artifact_dirs["windows"]
        extra = directory / "extra-release.zip"
        extra.write_bytes(b"not-checksummed")

        with self.assertRaisesRegex(ManifestError, "missing from SHA256SUMS"):
            self._build()

    def test_rejects_checksum_path_traversal(self) -> None:
        directory = self.artifact_dirs["macos"]
        checksum_file = directory / "SHA256SUMS.txt"
        digest = hashlib.sha256(b"outside").hexdigest()
        checksum_file.write_text(
            checksum_file.read_text(encoding="utf-8")
            + f"{digest}  ../outside.zip\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(ManifestError, "escapes its artifact directory"):
            self._build()

    def test_rejects_duplicate_normalized_checksum_path(self) -> None:
        directory = self.artifact_dirs["macos"]
        payload = directory / "sonicnest-macos-release-unsigned.zip"
        digest = hashlib.sha256(payload.read_bytes()).hexdigest()
        checksum_file = directory / "SHA256SUMS.txt"
        checksum_file.write_text(
            checksum_file.read_text(encoding="utf-8")
            + f"{digest}  ./sonicnest-macos-release-unsigned.zip\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(ManifestError, "Duplicate normalized SHA-256 path"):
            self._build()

    def test_rejects_cross_separator_duplicate_checksum_path(self) -> None:
        directory = self.artifact_dirs["windows"]
        payload = directory / "sonicnest-windows-x64-v0.1.0-portable-unsigned.zip"
        digest = hashlib.sha256(payload.read_bytes()).hexdigest()
        checksum_file = directory / "SHA256SUMS.txt"
        checksum_file.write_text(
            checksum_file.read_text(encoding="utf-8")
            + f"{digest}  .\\sonicnest-windows-x64-v0.1.0-portable-unsigned.zip\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(ManifestError, "Duplicate normalized SHA-256 path"):
            self._build()

    def test_rejects_symlinked_payload_even_when_checksum_matches(self) -> None:
        directory = self.artifact_dirs["macos"]
        outside = self.root / "outside-release.zip"
        outside.write_bytes(b"outside-release-payload")
        linked = directory / "linked-release.zip"
        try:
            linked.symlink_to(outside)
        except (OSError, NotImplementedError) as exc:
            self.skipTest(f"symbolic links unavailable in this test environment: {exc}")

        digest = hashlib.sha256(outside.read_bytes()).hexdigest()
        checksum_file = directory / "SHA256SUMS.txt"
        checksum_file.write_text(
            checksum_file.read_text(encoding="utf-8")
            + f"{digest}  {linked.name}\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(ManifestError, "symbolic link"):
            self._build()

    def test_rejects_symlinked_required_metadata(self) -> None:
        directory = self.artifact_dirs["android"]
        signing = directory / "ANDROID_SIGNING_STATE.txt"
        signing.unlink()
        outside = self.root / "outside-signing-state.txt"
        outside.write_text(
            "Package: io.github.sanskarin.sonic_nest\n"
            "Classification: Android Debug certificate / NON-PRODUCTION\n",
            encoding="utf-8",
        )
        try:
            signing.symlink_to(outside)
        except (OSError, NotImplementedError) as exc:
            self.skipTest(f"symbolic links unavailable in this test environment: {exc}")

        with self.assertRaisesRegex(ManifestError, "symbolic link"):
            self._build()

    def test_requires_android_nonproduction_signing_markers(self) -> None:
        report = self.artifact_dirs["android"] / "ANDROID_SIGNING_STATE.txt"
        report.write_text("unexpected signing report\n", encoding="utf-8")

        with self.assertRaisesRegex(ManifestError, "missing required marker"):
            self._build()

    def test_requires_every_platform(self) -> None:
        del self.artifact_dirs["linux"]

        with self.assertRaisesRegex(ManifestError, "Missing platform artifact directories"):
            self._build()

    def test_requires_full_commit_sha(self) -> None:
        with self.assertRaisesRegex(ManifestError, "40-character"):
            build_manifest(
                artifact_dirs=self.artifact_dirs,
                source_sha="deadbeef",
                workflow_run_id="123456",
                workflow_run_attempt="1",
                pubspec=self.pubspec,
            )


if __name__ == "__main__":
    unittest.main()
