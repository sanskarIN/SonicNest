from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tool" / "build_release_readiness_report.py"
TAG_GATE = "Tag `v1.0.0` only after all required stable-release gates are complete."


class ReleaseReadinessCliTest(unittest.TestCase):
    def test_cli_writes_json_and_markdown_outputs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            source = temp / "TODO.md"
            output = temp / "readiness.json"
            markdown = temp / "readiness.md"
            source.write_text(
                "# Remaining work\n\n"
                "## Hardware\n\n"
                "- [ ] Verify a physical device.\n\n"
                "## Signing and distribution\n\n"
                f"- [ ] {TAG_GATE}\n",
                encoding="utf-8",
            )

            result = subprocess.run(
                [
                    sys.executable,
                    str(SCRIPT),
                    "--source",
                    str(source),
                    "--output",
                    str(output),
                    "--markdown-output",
                    str(markdown),
                    "--assert-not-ready",
                ],
                cwd=ROOT,
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(0, result.returncode, result.stderr)
            report = json.loads(output.read_text(encoding="utf-8"))
            self.assertEqual(1, report["schemaVersion"])
            self.assertFalse(report["stableReleaseApproved"])
            self.assertEqual(2, report["summary"]["pending"])
            self.assertIn(
                "Stable release approved: **no**",
                markdown.read_text(encoding="utf-8"),
            )

    def test_cli_rejects_missing_canonical_tag_gate(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            source = temp / "TODO.md"
            output = temp / "readiness.json"
            source.write_text(
                "# Remaining work\n\n## Hardware\n\n- [ ] Verify a physical device.\n",
                encoding="utf-8",
            )

            result = subprocess.run(
                [
                    sys.executable,
                    str(SCRIPT),
                    "--source",
                    str(source),
                    "--output",
                    str(output),
                ],
                cwd=ROOT,
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertNotEqual(0, result.returncode)
            self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
