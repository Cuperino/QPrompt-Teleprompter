#!/usr/bin/env python3
"""Build on the target OS and produce a portable folder, including offline voice."""
import argparse
import importlib.util
import json
import platform
import plistlib
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--skip-download", action="store_true", help="Require already staged voice assets")
    args = parser.parse_args()
    if not args.skip_build:
        subprocess.run(["cargo", "build", "--release", "--locked"], cwd=ROOT, check=True)
    if not args.skip_download:
        subprocess.run([sys.executable, str(ROOT / "scripts/setup-voice.py")], check=True)
    system = platform.system()
    name = "technobabble.exe" if system == "Windows" else "technobabble"
    library = "libvosk.dll" if system=="Windows" else "libvosk.dylib" if system=="Darwin" else "libvosk.so"
    if not (ROOT / "voice/runtime" / library).is_file() or not (ROOT / "voice/model/conf/model.conf").is_file():
        raise RuntimeError("Voice assets for this OS are missing. Run setup-voice.py first.")
    dist = ROOT / "dist" / f"technobabble-{system.lower()}-{platform.machine().lower()}"
    dist.mkdir(parents=True, exist_ok=True)
    if system == "Darwin":
        bundle = dist / "Technobabble.app" / "Contents"
        (bundle / "MacOS").mkdir(parents=True, exist_ok=True)
        binary = bundle / "MacOS" / name
        (bundle / "Resources").mkdir(exist_ok=True)
        shutil.copy2(ROOT / "assets/technobabble.icns", bundle / "Resources/Technobabble.icns")
        with (bundle / "Info.plist").open("wb") as out:
            plistlib.dump({"CFBundleName":"Technobabble", "CFBundleDisplayName":"Technobabble", "CFBundleIdentifier":"local.technobabble.app",
                "CFBundleIconFile":"Technobabble.icns", "CFBundleExecutable":name, "CFBundlePackageType":"APPL", "CFBundleShortVersionString":"0.2.0", "CFBundleVersion":"4",
                "NSHighResolutionCapable":True, "NSMicrophoneUsageDescription":"Technobabble uses your microphone for offline script following. Audio stays on this Mac.",
                "LSMinimumSystemVersion":"11.0"},out)
    else:
        binary = dist / name
    # Replace the executable atomically: a running Unix app keeps its old inode
    # until it exits, rather than having its mapped executable rewritten in place.
    replacement = binary.with_name(binary.name + ".new")
    metadata = json.loads(subprocess.check_output(["cargo", "metadata", "--locked", "--no-deps", "--format-version=1"], cwd=ROOT, text=True))
    shutil.copy2(Path(metadata["target_directory"]) / "release" / name, replacement)
    replacement.replace(binary)
    (dist / "voice/runtime").mkdir(parents=True, exist_ok=True)
    for path in (ROOT / "voice/runtime").iterdir():
        if path.suffix in (".dll", ".so", ".dylib"):
            shutil.copy2(path,dist / "voice/runtime" / path.name)
    shutil.copytree(ROOT / "voice/model", dist / "voice/model", dirs_exist_ok=True)
    for path in (ROOT / "voice").iterdir():
        if path.is_file() and path.suffix != ".wav":
            shutil.copy2(path, dist / "voice" / path.name)
    for filename in ("README.md", "LICENSE", "THIRD-PARTY.md", "VALIDATION.md"):
        shutil.copy2(ROOT / filename, dist / filename)
    spec = importlib.util.spec_from_file_location("collect_licenses",ROOT / "scripts/collect-licenses.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    module.collect(ROOT, dist / "third-party-licenses")
    shutil.copy2(ROOT / "assets/DejaVu-LICENSE.txt", dist / "third-party-licenses/DejaVu-LICENSE.txt")
    (dist / "data").mkdir(exist_ok=True)
    (dist / "scripts").mkdir(exist_ok=True)
    if system == "Darwin":
        # Local ad-hoc signing; public distribution still needs Developer ID/notarization.
        subprocess.run(["codesign","--force","--deep","--sign","-",str(dist / "Technobabble.app")],check=True)
    print(f"Portable application: {dist}")

if __name__ == "__main__":
    main()
