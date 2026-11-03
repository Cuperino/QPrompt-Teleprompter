//! Portable script metadata. Files remain in their original locations.
use serde::{Deserialize, Serialize};
use std::path::{Path, PathBuf};
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Bookmark {
    pub name: String,
    pub character: usize,
}
#[derive(Clone, Serialize, Deserialize)]
pub struct Bookmarks {
    pub path: PathBuf,
    pub fingerprint: u64,
    pub marks: Vec<Bookmark>,
}
#[derive(Clone, Serialize, Deserialize)]
pub struct Segment {
    pub id: u64,
    pub path: PathBuf,
}
#[derive(Default, Serialize, Deserialize)]
#[serde(default)]
pub struct Library {
    pub recent: Vec<PathBuf>,
    pub queue: Vec<Segment>,
    pub active: Option<u64>,
    pub bookmarks: Vec<Bookmarks>,
    next_id: u64,
}
pub fn path_key(path: &Path) -> PathBuf {
    std::fs::canonicalize(path).unwrap_or_else(|_| {
        if path.is_absolute() {
            path.to_owned()
        } else {
            std::env::current_dir().unwrap_or_default().join(path)
        }
    })
}
fn fingerprint(text: &str) -> u64 {
    text.bytes().fold(0xcbf29ce484222325, |h, b| {
        (h ^ u64::from(b)).wrapping_mul(0x100000001b3)
    })
}
impl Library {
    pub fn remember(&mut self, path: PathBuf) {
        self.recent.retain(|p| p != &path);
        self.recent.insert(0, path);
        self.recent.truncate(20);
    }
    pub fn add(&mut self, path: PathBuf) {
        self.next_id = self
            .next_id
            .max(self.queue.iter().map(|s| s.id).max().unwrap_or(0))
            .saturating_add(1);
        self.queue.push(Segment {
            id: self.next_id,
            path,
        });
    }
    pub fn next(&self) -> Option<&Segment> {
        let index = self
            .active
            .and_then(|id| self.queue.iter().position(|s| s.id == id))
            .map_or(0, |i| i + 1);
        self.queue.get(index)
    }
    pub fn save_marks(&mut self, path: PathBuf, text: &str, marks: &[Bookmark]) {
        let record = Bookmarks {
            path: path.clone(),
            fingerprint: fingerprint(text),
            marks: marks.to_vec(),
        };
        if let Some(old) = self
            .bookmarks
            .iter_mut()
            .find(|b| b.path == path && b.fingerprint == record.fingerprint)
        {
            *old = record;
        } else {
            self.bookmarks.push(record);
        }
    }
    pub fn marks(&self, path: &Path, text: &str) -> (Vec<Bookmark>, bool) {
        match self
            .bookmarks
            .iter()
            .find(|b| b.path == path && b.fingerprint == fingerprint(text))
        {
            Some(b) => (b.marks.clone(), false),
            None => (
                vec![],
                self.bookmarks
                    .iter()
                    .any(|b| b.path == path && !b.marks.is_empty()),
            ),
        }
    }
    pub fn remove_segment(&mut self, id: u64) {
        self.queue.retain(|s| s.id != id);
        if self.active == Some(id) {
            self.active = None;
        }
    }
}
pub fn adjust(marks: &mut [Bookmark], old: &str, new: &str) {
    let a: Vec<_> = old.chars().collect();
    let b: Vec<_> = new.chars().collect();
    let prefix = a.iter().zip(&b).take_while(|(a, b)| a == b).count();
    let suffix = a[prefix..]
        .iter()
        .rev()
        .zip(b[prefix..].iter().rev())
        .take_while(|(a, b)| a == b)
        .count();
    let old_end = a.len() - suffix;
    let new_end = b.len() - suffix;
    for mark in marks {
        mark.character = if mark.character <= prefix {
            mark.character
        } else if mark.character >= old_end {
            new_end + mark.character.saturating_sub(old_end)
        } else {
            prefix
        };
        mark.character = mark.character.min(b.len());
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn queue_identity_recent_and_roundtrip() {
        let mut l = Library::default();
        l.add("a.txt".into());
        l.add("b.txt".into());
        l.add("a.txt".into());
        l.active = Some(l.queue[0].id);
        l.queue.swap(0, 1);
        assert_eq!(l.next().unwrap().path, Path::new("a.txt"));
        l.remember("a.txt".into());
        l.remember("b.txt".into());
        l.remember("a.txt".into());
        assert_eq!(l.recent.len(), 2);
        let restored: Library = serde_json::from_str(&serde_json::to_string(&l).unwrap()).unwrap();
        assert_eq!(restored.next().unwrap().id, l.queue[2].id);
        l.remove_segment(l.active.unwrap());
        assert!(l.active.is_none());
    }
    #[test]
    fn unicode_marks_and_external_changes() {
        let mut marks = vec![Bookmark {
            name: "Opening".into(),
            character: 2,
        }];
        adjust(&mut marks, "é hello", "é Xhello");
        assert_eq!(marks[0].character, 2);
        marks[0].character = 5;
        adjust(&mut marks, "é Xhello", "é Xh");
        assert_eq!(marks[0].character, 4);
        let mut l = Library::default();
        l.save_marks("a".into(), "é Xh", &marks);
        assert_eq!(l.marks(Path::new("a"), "é Xh").0.len(), 1);
        assert!(l.marks(Path::new("a"), "changed").1);
        l.save_marks("a".into(), "changed", &[]);
        assert_eq!(l.marks(Path::new("a"), "é Xh").0.len(), 1);
    }
}
