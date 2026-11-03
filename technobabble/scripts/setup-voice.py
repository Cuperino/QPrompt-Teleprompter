#!/usr/bin/env python3
"""Stage pinned offline speech assets. Python is a build tool, not a runtime dependency."""
import argparse
import hashlib
import json
import platform
import shutil
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODEL_URL = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip"
MODEL_SHA = "30f26242c4eb449f948e42cb302dd7a686cb29a3423a8367f99ff41780942498"
TEST_URL = "https://raw.githubusercontent.com/alphacep/vosk-api/v0.3.45/python/example/test.wav"
TEST_SHA = "dcfea5712c43a43ba7ae8083afb39d36993e5a69c46e88b68aaa72b65cb615bb"
RUNTIMES = {
    "windows-x86_64": ("0.3.45", "win_amd64", "6994ddc68556c7e5730c3b6f6bad13320e3519b13ce3ed2aa25a86724e7c10ac"),
    "linux-x86_64": ("0.3.45", "manylinux_2_12_x86_64.manylinux2010_x86_64", "25e025093c4399d7278f543568ed8cc5460ac3a4bf48c23673ace1e25d26619f"),
    "linux-aarch64": ("0.3.45", "manylinux2014_aarch64", "54efb47dd890e544e9e20f0316413acec7f8680d04ec095c6140ab4e70262704"),
    "macos-universal2": ("0.3.42", "macosx_10_6_universal2", "631b9ff6515945f92078c546a60deab2eeb4f63489a24526cc90e3164e415ff7"),
}

def host_platform():
    system = platform.system()
    machine = platform.machine().lower()
    if system == "Darwin":
        return "macos-universal2"
    if machine not in ("arm64", "aarch64", "amd64", "x86_64"):
        raise RuntimeError(f"Unsupported processor architecture: {machine}")
    arch = "aarch64" if machine in ("arm64", "aarch64") else "x86_64"
    return f"{system.lower()}-{arch}"

def download(url, path, expected=None):
    if not path.exists():
        print(f"Downloading {url}", flush=True)
        path.parent.mkdir(parents=True, exist_ok=True)
        part = path.with_suffix(path.suffix + ".partial")
        with urllib.request.urlopen(url, timeout=120) as response, part.open("wb") as out:
            shutil.copyfileobj(response, out)
        part.replace(path)
    checksum = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            checksum.update(block)
    digest = checksum.hexdigest()
    if expected and digest != expected:
        raise RuntimeError(f"SHA-256 mismatch: {path}. Remove the damaged download and retry.")
    return path

def setup(destination, target):
    if target not in RUNTIMES:
        raise RuntimeError(f"No bundled runtime for {target}; build Vosk for this architecture.")
    destination.mkdir(parents=True, exist_ok=True)
    download(TEST_URL, destination / "test.wav", TEST_SHA)
    cache = ROOT / "downloads"
    version, tag, digest = RUNTIMES[target]
    with urllib.request.urlopen(f"https://pypi.org/pypi/vosk/{version}/json", timeout=60) as response:
        metadata = json.load(response)
    wheel = next(u for u in metadata["urls"] if u["filename"] == f"vosk-{version}-py3-none-{tag}.whl")
    archive = download(wheel["url"], cache / wheel["filename"], digest)
    runtime = destination / "runtime"
    runtime.mkdir(exist_ok=True)
    with zipfile.ZipFile(archive) as z:
        for name in z.namelist():
            # Only native libraries, never import or install Python code.
            if name.endswith((".dll", ".so", ".dylib", ".dyld")):
                filename = Path(name).name
                # Upstream's universal2 wheel uses the unusual .dyld suffix.
                if filename == "libvosk.dyld":
                    filename = "libvosk.dylib"
                with z.open(name) as src, (runtime / filename).open("wb") as out:
                    shutil.copyfileobj(src, out)
            if name.endswith("/LICENSE") or name.endswith("/COPYING"):
                (destination / "VOSK-LICENSE").write_bytes(z.read(name))
    library = "libvosk.dll" if target.startswith("windows-") else "libvosk.dylib" if target.startswith("macos-") else "libvosk.so"
    if not (runtime / library).is_file():
        raise RuntimeError(f"The downloaded runtime did not contain {library}")
    model_zip = download(MODEL_URL, cache / "vosk-model-small-en-us-0.15.zip", MODEL_SHA)
    model = destination / "model"
    if not (model / "conf" / "model.conf").exists():
        with zipfile.ZipFile(model_zip) as z:
            for item in z.infolist():
                relative = Path(*Path(item.filename).parts[1:])
                if not relative.parts:
                    continue
                path = (model / relative).resolve()
                if not path.is_relative_to(model.resolve()):
                    raise RuntimeError("Unsafe model archive path")
                if item.is_dir():
                    path.mkdir(parents=True, exist_ok=True)
                else:
                    path.parent.mkdir(parents=True, exist_ok=True)
                    with z.open(item) as src, path.open("wb") as out:
                        shutil.copyfileobj(src, out)
    (destination / "assets.json").write_text(json.dumps({"platform":target,"vosk":version,"runtime_sha256":digest,
        "model":"vosk-model-small-en-us-0.15","model_sha256":MODEL_SHA,"model_license":"Apache-2.0"}, indent=2), encoding="utf-8")
    print(f"Offline voice assets ready: {destination}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", default=host_platform(), choices=RUNTIMES)
    parser.add_argument("--destination", type=Path, default=ROOT / "voice")
    args = parser.parse_args()
    setup(args.destination.resolve(), args.platform)
