# Technobabble

Portable Rust teleprompter with adjustable offline voice following.

- [Project documentation](technobabble/README.md)
- [Windows application](technobabble/dist/technobabble-windows-amd64/technobabble.exe)
- [Windows download](technobabble/dist/technobabble-windows-amd64.zip)
- [Apple Silicon Mac download](technobabble/dist/technobabble-darwin-arm64.zip)
- [Linux download](technobabble/dist/technobabble-linux-x86_64.zip)
- [Source download](technobabble/dist/technobabble-source.zip)

Source, assets, scripts, offline voice engine and model are contained in `technobabble/`. Build from that directory with `cargo build --release --locked`.

The former C++ project and disposable build/download artifacts were moved to `C:/Dev/teleprompter-retired-20261103/`. Git history is retained. Current app data is preserved; the previous Rust Prompter session is saved in `technobabble/data/recovered-rust-prompter-session.json`.
