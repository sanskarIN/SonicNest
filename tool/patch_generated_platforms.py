#!/usr/bin/env python3
"""Idempotent patches for Flutter-generated host projects."""
from pathlib import Path
import plistlib

ROOT = Path(__file__).resolve().parents[1]


def patch_plist(path: Path, values: dict) -> None:
    if not path.exists():
        return
    with path.open("rb") as handle:
        data = plistlib.load(handle)
    changed = False
    for key, value in values.items():
        if data.get(key) != value:
            data[key] = value
            changed = True
    if changed:
        with path.open("wb") as handle:
            plistlib.dump(data, handle, sort_keys=False)


def patch_entitlements(path: Path) -> None:
    if not path.exists():
        return
    with path.open("rb") as handle:
        data = plistlib.load(handle)
    data["com.apple.security.device.audio-input"] = True
    with path.open("wb") as handle:
        plistlib.dump(data, handle, sort_keys=False)


patch_plist(
    ROOT / "ios" / "Runner" / "Info.plist",
    {
        "CFBundleDisplayName": "SonicNest",
        "NSMicrophoneUsageDescription": "SonicNest needs microphone access only when you choose to record voice or sound.",
        "UIBackgroundModes": ["audio"],
    },
)
patch_plist(
    ROOT / "macos" / "Runner" / "Info.plist",
    {
        "NSMicrophoneUsageDescription": "SonicNest needs microphone access only when you choose to record voice or sound.",
    },
)
patch_entitlements(ROOT / "macos" / "Runner" / "DebugProfile.entitlements")
patch_entitlements(ROOT / "macos" / "Runner" / "Release.entitlements")

for path in [
    ROOT / "windows" / "runner" / "main.cpp",
    ROOT / "linux" / "my_application.cc",
]:
    if not path.exists():
        continue
    text = path.read_text(encoding="utf-8")
    text = text.replace("sonic_nest", "SonicNest")
    text = text.replace("sonic nest", "SonicNest")
    path.write_text(text, encoding="utf-8")
