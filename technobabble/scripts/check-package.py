#!/usr/bin/env python3
"""Check packaged offline speech; optionally check a Linux X11 window under Xvfb."""
import argparse
import os
import platform
import shutil
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('folder', type=Path)
    parser.add_argument('--linux-window', action='store_true')
    args = parser.parse_args()
    folder = args.folder.resolve()
    system = platform.system()
    binary = folder / ('Technobabble.app/Contents/MacOS/technobabble' if system == 'Darwin' else 'technobabble.exe' if system == 'Windows' else 'technobabble')
    if not binary.is_file():
        raise RuntimeError(f'Packaged executable missing: {binary}')
    shutil.copy2(ROOT / 'voice/test.wav', folder / 'voice/test.wav')
    # Explicitly select this package's assets, even if the caller set an override.
    env = dict(os.environ, TECHNOBABBLE_HOME=str(folder))
    subprocess.run([str(binary), '--voice-smoke'], env=env, check=True, timeout=60)
    report = (folder / 'data/voice-smoke.txt').read_text(encoding='utf-8')
    if not report.startswith('PASS:'):
        raise RuntimeError('Packaged speech check did not pass')
    print('\n'.join(report.splitlines()[:4]))
    if args.linux_window:
        if system != 'Linux':
            raise RuntimeError('--linux-window requires Linux and an X11 display (or xvfb-run)')
        # Never open or update the presenter's normal recovery file.
        with tempfile.TemporaryDirectory(prefix='technobabble-ui-') as scratch:
            ui_env = dict(env, TECHNOBABBLE_HOME=scratch, WINIT_UNIX_BACKEND='x11')
            ui_env.pop('WAYLAND_DISPLAY', None)
            with (Path(scratch) / 'ui.log').open('w+', encoding='utf-8') as log:
                process = subprocess.Popen([str(binary)], env=ui_env, stdout=log, stderr=log)
                try:
                    deadline = time.monotonic() + 30
                    while time.monotonic() < deadline:
                        if process.poll() is not None:
                            log.seek(0)
                            raise RuntimeError('UI exited before creating a window: ' + log.read())
                        tree = subprocess.run(['xwininfo', '-root', '-tree'], env=ui_env, capture_output=True, text=True, check=True).stdout
                        if '"Technobabble"' in tree:
                            print('PASS: native Linux X11 window created')
                            break
                        time.sleep(0.25)
                    else:
                        raise RuntimeError('No Technobabble window appeared within 30 seconds')
                finally:
                    if process.poll() is None:
                        process.terminate()
                        try:
                            process.wait(timeout=10)
                        except subprocess.TimeoutExpired:
                            process.kill()
                            process.wait()

if __name__ == '__main__':
    main()
