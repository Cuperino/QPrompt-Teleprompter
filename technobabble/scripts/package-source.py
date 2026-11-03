#!/usr/bin/env python3
"""Create a clean source bundle, excluding private recovery data and build caches."""
import zipfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
FILES=["build.rs","Cargo.toml","Cargo.lock","README.md","LICENSE","THIRD-PARTY.md","VALIDATION.md",".gitignore"]
DIRECTORIES=["docs","assets","src","scripts",".cargo",".github"]

def main():
    destination=ROOT / "dist/technobabble-source.zip"
    destination.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(destination,"w",zipfile.ZIP_DEFLATED) as archive:
        paths=[ROOT / name for name in FILES]
        for directory in DIRECTORIES:
            paths.extend(p for p in (ROOT / directory).rglob("*") if p.is_file() and "__pycache__" not in p.parts)
        paths.extend(p for p in (ROOT / "voice").iterdir() if p.is_file() and p.name != "assets.json")
        for path in paths:
            archive.write(path,Path("technobabble") / path.relative_to(ROOT))
    print(f"Source bundle: {destination}")

if __name__=="__main__":
    main()
