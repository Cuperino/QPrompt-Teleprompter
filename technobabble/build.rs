fn main() {
    println!("cargo:rerun-if-changed=assets/technobabble.ico");
    println!("cargo:rerun-if-changed=assets/technobabble.rc");
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() != Ok("windows") {
        return;
    }
    let sdk = std::path::PathBuf::from(
        std::env::var_os("ProgramFiles(x86)").expect("Windows SDK requires ProgramFiles(x86)"),
    )
    .join("Windows Kits/10/bin");
    let mut versions: Vec<_> = std::fs::read_dir(sdk)
        .expect("Install the Windows SDK")
        .filter_map(Result::ok)
        .map(|e| e.path())
        .collect();
    versions.sort();
    let compiler = versions
        .into_iter()
        .rev()
        .map(|p| p.join("x64/rc.exe"))
        .find(|p| p.is_file())
        .expect("Windows SDK resource compiler is missing");
    let output =
        std::path::PathBuf::from(std::env::var_os("OUT_DIR").unwrap()).join("technobabble.res");
    let status = std::process::Command::new(compiler)
        .args(["/nologo", "/fo"])
        .arg(&output)
        .arg("assets/technobabble.rc")
        .status()
        .expect("Run Windows resource compiler");
    assert!(status.success(), "Windows icon compilation failed");
    println!("cargo:rustc-link-arg={}", output.display());
}
