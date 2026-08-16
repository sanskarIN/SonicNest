from pathlib import Path

REPLACEMENTS = {
    '3d91ace5814e908dbf9c66d556e528042debfa52': '403aee21f783cc78e3c8eaa7a3ca2de0184379c1',
    '80ab45ed55da6a66fc849ac5f1b72ca049634ea2': '417d65463191f5fdd0c6db62ae3a69dfe64de7ba',
    '95d86c2d82beb0a43b6304d1c058c58cbe62f694': '4f147c917542ba734cb9795049dc2b76299eec0f',
    'b510b205dfff59110399b3e60db3c903c7f8669b': 'ef5cdaedb956dd80263d640d9213692a3179e416',
    'b782ca8bf58fe614c8bcc708039c7a4f28457ed8': 'b782689e8d4c6ddade972d08dd74467674980229',
}

MAINTENANCE_MARKER = '### Documentation-ledger maintenance commits for this continuation'
MAINTENANCE_SECTION = '''

### Documentation-ledger maintenance commits for this continuation

The authoritative Git history was re-read after the first ledger append. Five stale intermediate SHA references in the newly appended commit list were corrected to the actual commits shown by GitHub history. No production code, tests, privacy behavior, or validation result changed during this correction.

Documentation/helper commits created after the main diagnostics source validation were:

- `b21e0cfa0202a3689f69ad796585a88fc7fce38e` — staged the first temporary documentation workflow; it was syntactically invalid and executed no jobs or document changes.
- `00c73533b49cfde03d42dfb2d2e6018f8612528d` — added the temporary repository-side ledger updater.
- `073181fbe53c3660d5e9d6b3f82df27daa6f5e3e` — corrected the temporary workflow so the updater could run.
- `4fd9c41e6d6e102b17793c3afd37fe1ffb6739db` — `docs: add diagnostics QA release notes`.
- `af611101792dc3c208b2ce092e34f126f025afe9` — `docs: sync diagnostics project state`.
- `ef24bb09490c47c18cbdf580d4ffee4eac269358` — `docs: record diagnostics and QA continuation`.
- `f8f3769bccb76677a15f4b8dba4018a83b222881` — removed the temporary one-shot documentation workflow.
- `fdb82d78310ec2c61a2d50b18d84dd2e1d28a7f5` — removed the temporary documentation updater.

The cleaned repository must not retain either temporary helper after ledger correction. The permanent Repository Integrity Audit remains the authority for enforcing that cleanup.
'''


def replace_all(path: Path) -> None:
    text = path.read_text(encoding='utf-8')
    changed = False
    for old, new in REPLACEMENTS.items():
        if old in text:
            text = text.replace(old, new)
            changed = True
    if path.name == 'what_changed.md' and MAINTENANCE_MARKER not in text:
        text += MAINTENANCE_SECTION
        changed = True
    if changed:
        path.write_text(text, encoding='utf-8')


def main() -> None:
    replace_all(Path('PROJECT_STATE.md'))
    replace_all(Path('what_changed.md'))


if __name__ == '__main__':
    main()
