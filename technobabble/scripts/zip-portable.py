#!/usr/bin/env python3
"""Zip a built portable folder, excluding saved scripts and personal recovery data."""
import argparse
import zipfile
from pathlib import Path

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder",type=Path)
    folder=parser.parse_args().folder.resolve()
    if not folder.is_dir() or not (folder / "voice/model/conf").is_dir():
        raise RuntimeError("Expected a built portable application folder")
    destination=folder.with_suffix(".zip")
    temporary=destination.with_suffix(".zip.partial")
    with zipfile.ZipFile(temporary,"w",zipfile.ZIP_DEFLATED,compresslevel=6,strict_timestamps=False) as archive:
        for path in folder.rglob("*"):
            relative=path.relative_to(folder)
            if path.is_file() and relative.parts[0] not in ("data","scripts"):
                archive.write(path,Path(folder.name)/relative)
    temporary.replace(destination)
    print(f"Portable archive: {destination}")

if __name__=="__main__":
    main()
