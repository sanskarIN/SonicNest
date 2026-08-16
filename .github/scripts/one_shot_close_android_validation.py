from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

replacements = {
    "PROJECT_STATE.md": [
        (
            "    android_debug_apk: pending_same_run_at_ledger_generation",
            "    android_debug_apk: success",
        ),
    ],
    "RELEASE_NOTES.md": [
        (
            "passed committed-source formatting, static analysis, the complete unit suite, and Linux debug compilation; Android debug compilation is recorded separately in the authoritative state once the same run completes.",
            "passed committed-source formatting, static analysis, the complete unit suite, Android debug compilation, and Linux debug compilation.",
        ),
    ],
    "what_changed.md": [
        (
            "committed-source formatting **SUCCESS**, static analysis **SUCCESS**, complete unit suite **SUCCESS**, Linux debug build **SUCCESS**; Android debug build remained in progress at the exact moment this ledger section was generated and is not falsely recorded as complete here.",
            "committed-source formatting **SUCCESS**, static analysis **SUCCESS**, complete unit suite **SUCCESS**, Android debug build **SUCCESS**, and Linux debug build **SUCCESS**. Android completed after the first ledger generation and this line was then corrected to the confirmed final result.",
        ),
    ],
}

for relative, pairs in replacements.items():
    path = ROOT / relative
    text = path.read_text(encoding="utf-8")
    for old, new in pairs:
        if new in text:
            continue
        if old not in text:
            raise RuntimeError(f"Missing expected validation marker in {relative}")
        text = text.replace(old, new, 1)
    path.write_text(text, encoding="utf-8")
