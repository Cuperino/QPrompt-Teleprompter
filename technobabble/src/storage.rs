use std::{
    fs,
    io::{self, Write},
    path::{Path, PathBuf},
};

pub fn root() -> PathBuf {
    if let Some(root) =
        std::env::var_os("TECHNOBABBLE_HOME").or_else(|| std::env::var_os("RUST_PROMPTER_HOME"))
    {
        return root.into();
    }
    let exe = std::env::current_exe().unwrap_or_else(|_| PathBuf::from("technobabble"));
    let parent = exe.parent().unwrap_or(Path::new("."));
    // Cargo builds keep all data within this standalone project.
    if parent
        .file_name()
        .is_some_and(|n| n == "debug" || n == "release")
        && parent.parent().is_some_and(|p| p.ends_with("target"))
    {
        return parent.parent().unwrap().parent().unwrap().to_owned();
    }
    // A macOS .app keeps portable writable data beside the bundle.
    if parent.ends_with("Contents/MacOS") {
        return parent
            .parent()
            .unwrap()
            .parent()
            .unwrap()
            .parent()
            .unwrap()
            .to_owned();
    }
    parent.to_owned()
}

/// Flush then atomically replace; a failed save never removes the previous file.
pub fn atomic_write(path: &Path, bytes: &[u8]) -> io::Result<()> {
    if let Some(parent) = path.parent().filter(|p| !p.as_os_str().is_empty()) {
        fs::create_dir_all(parent)?;
    }
    let tmp = path.with_extension(format!("{}.tmp", std::process::id()));
    let mut f = fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .open(&tmp)?;
    let result = (|| {
        f.write_all(bytes)?;
        f.sync_all()?;
        drop(f);
        replace(&tmp, path)
    })();
    if result.is_err() {
        let _ = fs::remove_file(&tmp);
    }
    result
}
#[cfg(not(windows))]
fn replace(from: &Path, to: &Path) -> io::Result<()> {
    fs::rename(from, to)
}
#[cfg(windows)]
fn replace(from: &Path, to: &Path) -> io::Result<()> {
    use std::os::windows::ffi::OsStrExt;
    #[link(name = "kernel32")]
    unsafe extern "system" {
        fn MoveFileExW(from: *const u16, to: *const u16, flags: u32) -> i32;
    }
    let from: Vec<u16> = from.as_os_str().encode_wide().chain(Some(0)).collect();
    let to: Vec<u16> = to.as_os_str().encode_wide().chain(Some(0)).collect();
    // SAFETY: NUL-terminated path buffers live through the call; no retained pointers.
    if unsafe { MoveFileExW(from.as_ptr(), to.as_ptr(), 9) } == 0 {
        Err(io::Error::last_os_error())
    } else {
        Ok(())
    }
}

pub fn read_script(path: &Path) -> Result<crate::word::Imported, String> {
    let metadata = fs::metadata(path).map_err(|e| e.to_string())?;
    let limit = if crate::word::is_docx(path) { 32 } else { 8 };
    if metadata.len() > limit * 1024 * 1024 {
        return Err(format!("Scripts must be smaller than {limit} MiB."));
    }
    use std::io::Read;
    let mut bytes = Vec::new();
    fs::File::open(path)
        .map_err(|e| e.to_string())?
        .take(limit * 1024 * 1024 + 1)
        .read_to_end(&mut bytes)
        .map_err(|e| e.to_string())?;
    if crate::word::is_docx(path) {
        crate::word::read(&bytes)
    } else {
        Ok(crate::word::Imported {
            text: crate::model::decode_text(&bytes)?,
            emphasis: vec![],
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn replaces_existing_without_truncating() {
        let path =
            std::env::temp_dir().join(format!("technobabble-test-{}.txt", std::process::id()));
        atomic_write(&path, b"first").unwrap();
        atomic_write(&path, b"second").unwrap();
        assert_eq!(fs::read(&path).unwrap(), b"second");
        fs::remove_file(path).unwrap();
    }
}
