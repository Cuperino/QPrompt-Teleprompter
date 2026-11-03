#!/usr/bin/env python3
"""Collect Cargo dependency notices without installing any extra tools."""
import json
import shutil
import subprocess
from pathlib import Path

def collect(root, destination):
    metadata=json.loads(subprocess.check_output(["cargo","metadata","--locked","--format-version=1"],cwd=root,text=True))
    destination.mkdir(parents=True,exist_ok=True)
    inventory=[]
    for package in metadata["packages"]:
        if package["source"] is None:
            continue
        source=Path(package["manifest_path"]).parent
        target=destination / f'{package["name"]}-{package["version"]}'
        notices=[]
        for path in source.iterdir():
            if path.is_file() and path.name.upper().startswith(("LICENSE","LICENCE","COPYING","NOTICE","AUTHORS")):
                target.mkdir(exist_ok=True)
                shutil.copy2(path,target / path.name)
                notices.append(path.name)
        inventory.append({"name":package["name"],"version":package["version"],"license":package["license"],"repository":package["repository"],"notices":notices})
    (destination / "inventory.json").write_text(json.dumps(inventory,indent=2),encoding="utf-8")

if __name__=="__main__":
    root=Path(__file__).resolve().parents[1]
    collect(root,root / "third-party-licenses")
