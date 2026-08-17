from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE_PATH = ROOT / "tool/source_line_audit.py"
SPEC = importlib.util.spec_from_file_location("source_line_audit", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
source_line_audit = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(source_line_audit)


class SourceLineAuditTest(unittest.TestCase):
    def test_clean_source_passes(self) -> None:
        self.assertEqual(
            source_line_audit.inspect_text("lib/example.dart", b"void main() {}\n"),
            [],
        )

    def test_trailing_whitespace_is_reported_for_source(self) -> None:
        errors = source_line_audit.inspect_text(
            "lib/example.dart", b"void main() {} \n"
        )
        self.assertTrue(any("trailing whitespace" in error for error in errors))

    def test_missing_final_newline_is_reported_for_source(self) -> None:
        errors = source_line_audit.inspect_text("tool/example.py", b"print('ok')")
        self.assertTrue(any("missing final newline" in error for error in errors))

    def test_merge_conflict_marker_is_reported_in_documentation(self) -> None:
        errors = source_line_audit.inspect_text(
            "README.md", b"before\n<<<<<<< HEAD\nafter\n"
        )
        self.assertTrue(any("merge-conflict marker" in error for error in errors))

    def test_binary_file_is_skipped(self) -> None:
        self.assertEqual(
            source_line_audit.inspect_text("asset.bin", b"\x89PNG\x00data"),
            [],
        )

    def test_invalid_utf8_text_candidate_is_reported(self) -> None:
        errors = source_line_audit.inspect_text("tool/example.sh", b"echo \xff\n")
        self.assertTrue(any("invalid UTF-8" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
