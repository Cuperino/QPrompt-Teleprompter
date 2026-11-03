//! DOCX body import. No files are extracted and external relationships are never followed.
use serde::{Deserialize, Serialize};
use std::io::{Cursor, Read};

const LIMIT: u64 = 8 * 1024 * 1024;
const W: &str = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
const STRICT_W: &str = "http://purl.oclc.org/ooxml/wordprocessingml/main";
#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct Emphasis {
    pub start: usize,
    pub end: usize,
    pub bold: bool,
    pub italic: bool,
    pub underline: bool,
}
#[derive(Default)]
pub struct Imported {
    pub text: String,
    pub emphasis: Vec<Emphasis>,
}
pub fn is_docx(path: &std::path::Path) -> bool {
    path.extension()
        .is_some_and(|e| e.eq_ignore_ascii_case("docx"))
}
pub fn read(bytes: &[u8]) -> Result<Imported, String> {
    if bytes.len() as u64 > 32 * 1024 * 1024 {
        return Err("Word documents must be smaller than 32 MiB.".into());
    }
    let mut archive = zip::ZipArchive::new(Cursor::new(bytes))
        .map_err(|e| format!("Cannot open Word document: {e}"))?;
    let file = archive
        .by_name("word/document.xml")
        .map_err(|_| "This file has no Word document body. Use an unencrypted .docx file.")?;
    if file.size() > LIMIT {
        return Err("Word document body exceeds 8 MiB.".into());
    }
    let mut xml = Vec::new();
    file.take(LIMIT + 1)
        .read_to_end(&mut xml)
        .map_err(|e| format!("Cannot read Word document: {e}"))?;
    if xml.len() as u64 > LIMIT {
        return Err("Word document body exceeds 8 MiB.".into());
    }
    parse(&crate::model::decode_text(&xml)?)
}
fn named(n: roxmltree::Node<'_, '_>, name: &str) -> bool {
    n.is_element()
        && n.tag_name().name() == name
        && matches!(n.tag_name().namespace(), Some(W | STRICT_W))
}
fn enabled(n: roxmltree::Node<'_, '_>) -> bool {
    !matches!(
        n.attribute((W, "val"))
            .or_else(|| n.attribute((STRICT_W, "val"))),
        Some("0" | "false" | "off" | "none")
    )
}
fn hidden(n: roxmltree::Node<'_, '_>) -> bool {
    n.ancestors()
        .any(|a| named(a, "del") || named(a, "moveFrom") || named(a, "txbxContent"))
}
fn parse(xml: &str) -> Result<Imported, String> {
    let doc = roxmltree::Document::parse(xml).map_err(|e| format!("Invalid Word XML: {e}"))?;
    let body = doc
        .root_element()
        .children()
        .find(|n| named(*n, "body"))
        .ok_or("This file has no Word document body.")?;
    let mut result = Imported::default();
    let mut position = 0;
    for (p_index, p) in body
        .descendants()
        .filter(|n| named(*n, "p") && !hidden(*n))
        .enumerate()
    {
        if p_index > 0 {
            result.text.push_str("\n\n");
            position += 2;
        }
        for run in p.descendants().filter(|n| named(*n, "r") && !hidden(*n)) {
            let props = run.children().find(|n| named(*n, "rPr"));
            if props.is_some_and(|p| p.children().any(|n| named(n, "vanish") && enabled(n))) {
                continue;
            }
            let mut style = Emphasis {
                start: position,
                ..Default::default()
            };
            if let Some(props) = props {
                style.bold = props.children().any(|n| named(n, "b") && enabled(n));
                style.italic = props.children().any(|n| named(n, "i") && enabled(n));
                style.underline = props.children().any(|n| named(n, "u") && enabled(n));
            }
            for n in run.children() {
                let content = if named(n, "t") {
                    n.text().unwrap_or("")
                } else if named(n, "tab") {
                    "\t"
                } else if named(n, "br") || named(n, "cr") {
                    "\n"
                } else {
                    ""
                };
                result.text.push_str(content);
                position += content.chars().count();
            }
            style.end = position;
            if style.end > style.start && (style.bold || style.italic || style.underline) {
                result.emphasis.push(style);
            }
        }
    }
    if result.text.trim().is_empty() {
        return Err("The Word document contains no readable body text.".into());
    }
    Ok(result)
}
/// Retain unaffected emphasis after an editor replacement; new/changed text is plain.
pub fn adjust(spans: &mut Vec<Emphasis>, old: &str, new: &str) {
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
    spans.retain_mut(|s| {
        if s.end <= prefix {
            true
        } else if s.start >= old_end {
            s.start = new_end + s.start - old_end;
            s.end = new_end + s.end - old_end;
            true
        } else {
            false
        }
    });
}
#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    fn package(xml: &str) -> Vec<u8> {
        let mut zip = zip::ZipWriter::new(Cursor::new(Vec::new()));
        zip.start_file(
            "word/document.xml",
            zip::write::SimpleFileOptions::default()
                .compression_method(zip::CompressionMethod::Deflated),
        )
        .unwrap();
        zip.write_all(xml.as_bytes()).unwrap();
        zip.finish().unwrap().into_inner()
    }
    #[test]
    fn paragraphs_runs_tables_entities_and_emphasis() {
        let xml = format!(
            r#"<w:document xmlns:w="{W}"><w:body><w:p><w:r><w:rPr><w:b/><w:i/><w:u w:val="single"/></w:rPr><w:t>Élodie &amp; friends</w:t></w:r><w:r><w:tab/><w:t>hello</w:t><w:br/><w:t>world</w:t></w:r><w:del><w:r><w:delText>deleted</w:delText></w:r></w:del></w:p><w:p/><w:tbl><w:tr><w:tc><w:p><w:r><w:rPr><w:b w:val="0"/></w:rPr><w:t>Cell</w:t></w:r></w:p></w:tc></w:tr></w:tbl></w:body></w:document>"#
        );
        let result = read(&package(&xml)).unwrap();
        assert_eq!(result.text, "Élodie & friends\thello\nworld\n\n\n\nCell");
        assert_eq!(result.emphasis.len(), 1);
        let s = &result.emphasis[0];
        assert_eq!((s.start, s.end), (0, 16));
        assert!(s.bold && s.italic && s.underline);
    }
    #[test]
    fn rejects_bad_archives_xml_and_oversize_body() {
        assert!(read(b"not a zip").is_err());
        assert!(read(&package("<broken>")).is_err());
        assert!(read(&package("<!DOCTYPE x [<!ENTITY a 'test'>]><x>&a;</x>")).is_err());
        assert!(read(&package(&"x".repeat(LIMIT as usize + 1))).is_err());
    }
    #[test]
    fn emphasis_tracks_unicode_edits() {
        let mut spans = vec![Emphasis {
            start: 2,
            end: 5,
            bold: true,
            ..Default::default()
        }];
        adjust(&mut spans, "é hello", "é Xhello");
        assert_eq!((spans[0].start, spans[0].end), (3, 6));
        adjust(&mut spans, "é Xhello", "é Xhallo");
        assert!(spans.is_empty());
    }
}
