#!/bin/sh
# Use an isolated project-local Rust toolchain when one has been installed.
set -eu
PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ -x "$PROJECT_ROOT/.toolchain/cargo/bin/cargo" ]; then
    export CARGO_HOME="$PROJECT_ROOT/.toolchain/cargo"
    export RUSTUP_HOME="$PROJECT_ROOT/.toolchain/rustup"
    export PATH="$CARGO_HOME/bin:$PATH"
fi
cd "$PROJECT_ROOT"
exec "$@"
