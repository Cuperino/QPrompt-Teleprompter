#!/usr/bin/env python3
"""Verify a Mac package signature, offline speech, and native window creation."""
import argparse
import ctypes
import json
import plistlib
import re
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def windows():
    cg = ctypes.CDLL("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics")
    cf = ctypes.CDLL("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
    cg.CGWindowListCopyWindowInfo.argtypes = [ctypes.c_uint32, ctypes.c_uint32]
    cg.CGWindowListCopyWindowInfo.restype = ctypes.c_void_p
    cf.CFPropertyListCreateData.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_long, ctypes.c_ulong, ctypes.c_void_p]
    cf.CFPropertyListCreateData.restype = ctypes.c_void_p
    cf.CFDataGetLength.argtypes = [ctypes.c_void_p]
    cf.CFDataGetLength.restype = ctypes.c_long
    cf.CFDataGetBytePtr.argtypes = [ctypes.c_void_p]
    cf.CFDataGetBytePtr.restype = ctypes.c_void_p
    cf.CFRelease.argtypes = [ctypes.c_void_p]
    array = cg.CGWindowListCopyWindowInfo(0, 0)
    if not array:
        return []
    data = None
    try:
        data = cf.CFPropertyListCreateData(None, array, 100, 0, None)
        if not data:
            return []
        return plistlib.loads(ctypes.string_at(cf.CFDataGetBytePtr(data), cf.CFDataGetLength(data)))
    finally:
        if data:
            cf.CFRelease(data)
        cf.CFRelease(array)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    folder = parser.parse_args().folder.resolve()
    app = folder / "Technobabble.app"
    binary = app / "Contents/MacOS/technobabble"
    subprocess.run(["codesign", "--verify", "--deep", "--strict", str(app)], check=True)
    with (app / "Contents/Info.plist").open("rb") as source:
        info = plistlib.load(source)
    if not info.get("NSMicrophoneUsageDescription"):
        raise RuntimeError("Microphone usage description missing")
    # Keep the small fixture available for repeatable local diagnostics.
    shutil.copy2(ROOT / "voice/test.wav", folder / "voice/test.wav")
    result = subprocess.run([str(binary), "--voice-smoke"], text=True, capture_output=True, check=True)
    print(result.stdout.splitlines()[:4])
    subprocess.run(["open", "-n", str(app)], check=True)
    deadline = time.monotonic() + 20
    while time.monotonic() < deadline:
        processes = subprocess.run(["pgrep", "-f", "^" + re.escape(str(binary)) + "$"], text=True, capture_output=True)
        pids = {int(value) for value in processes.stdout.split()}
        owned = [w for w in windows() if w.get("kCGWindowOwnerPID") in pids
                 and w.get("kCGWindowLayer") == 0
                 and w.get("kCGWindowBounds", {}).get("Width", 0) >= 100
                 and w.get("kCGWindowBounds", {}).get("Height", 0) >= 100]
        if owned:
            report = {"signature": "valid", "offline_speech": "passed", "native_window": "created",
                "windows": [{"pid": w.get("kCGWindowOwnerPID"), "window_id": w.get("kCGWindowNumber"), "bounds": w.get("kCGWindowBounds")} for w in owned]}
            (folder / "data/mac-package-check.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
            print(json.dumps(report, indent=2))
            return
        time.sleep(0.25)
    raise RuntimeError("No native application window appeared within 20 seconds")

if __name__ == "__main__":
    main()
