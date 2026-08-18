from __future__ import annotations

import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))

import repository_audit  # noqa: E402


class RepositoryAuditWorkflowRegressionTest(unittest.TestCase):
    def test_tracked_workflow_set_matches_permanent_allowlist(self) -> None:
        tracked_workflows = {
            relative
            for relative in repository_audit.tracked_files()
            if relative.startswith(".github/workflows/")
            and relative.casefold().endswith(repository_audit.WORKFLOW_SUFFIXES)
        }

        self.assertEqual(tracked_workflows, repository_audit.ALLOWED_WORKFLOW_FILES)

    def test_permanent_workflows_remain_read_only(self) -> None:
        for relative in sorted(repository_audit.ALLOWED_WORKFLOW_FILES):
            text = (ROOT / relative).read_text(
                encoding="utf-8", errors="strict"
            ).casefold()
            self.assertIsNone(
                re.search(
                    r"(?m)^\s*permissions\s*:\s*write-all\s*(?:#.*)?$",
                    text,
                ),
                relative,
            )
            for scope in repository_audit.FORBIDDEN_PERMANENT_WORKFLOW_WRITE_SCOPES:
                self.assertIsNone(
                    re.search(
                        rf"(?<![\w-]){re.escape(scope)}\s*:\s*write(?![\w-])",
                        text,
                    ),
                    f"{relative}: {scope}",
                )


if __name__ == "__main__":
    unittest.main()
