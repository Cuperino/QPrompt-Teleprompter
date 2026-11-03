use std::time::Duration;

pub const WELCOME: &str = "Welcome to Technobabble\n\nYour words. Your pace.\n\nPaste or type your script in the editor, then choose Start.\n\nSpace pauses and resumes. Up and Down adjust the speed. Left and Right move through the script.\n\nPress F11 for a distraction-free fullscreen view. Press M to mirror the text for a teleprompter glass. Press F to flip vertically and scroll in the opposite direction on screen.\n\n# A new section\n\nLines beginning with # are cue markers. Use Page Up and Page Down to jump between them.\n\nTake a breath. Look at the lens. You are ready.";

#[derive(Clone, Debug, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct Settings {
    pub speed: f64,
    pub font_size: i32,
    pub width_percent: i32,
    pub countdown: u32,
    pub mirror: bool,
    pub flip: bool,
    pub guide: bool,
    pub looping: bool,
}
impl Default for Settings {
    fn default() -> Self {
        Self {
            speed: 55.0,
            font_size: 48,
            width_percent: 82,
            countdown: 3,
            mirror: false,
            flip: false,
            guide: true,
            looping: false,
        }
    }
}
impl Settings {
    pub fn parse(text: &str) -> Self {
        let mut s = Self::default();
        for (k, v) in text.lines().filter_map(|l| l.split_once('=')) {
            match k {
                "speed" => {
                    if let Ok(n) = v.parse::<f64>() {
                        if n.is_finite() {
                            s.speed = n.clamp(5., 500.);
                        }
                    }
                }
                "font_size" => {
                    if let Ok(n) = v.parse::<i32>() {
                        s.font_size = n.clamp(20, 120);
                    }
                }
                "width_percent" => {
                    if let Ok(n) = v.parse::<i32>() {
                        s.width_percent = n.clamp(40, 96);
                    }
                }
                "countdown" => {
                    if let Ok(n) = v.parse::<u32>() {
                        s.countdown = n.min(10);
                    }
                }
                "mirror" => s.mirror = v == "true",
                "flip" => s.flip = v == "true",
                "guide" => s.guide = v == "true",
                "looping" => s.looping = v == "true",
                _ => {}
            }
        }
        s
    }
    pub fn encode(&self) -> String {
        format!("speed={}\nfont_size={}\nwidth_percent={}\ncountdown={}\nmirror={}\nflip={}\nguide={}\nlooping={}\n",
            self.speed, self.font_size, self.width_percent, self.countdown, self.mirror, self.flip, self.guide, self.looping)
    }
}

#[derive(Default)]
pub struct Playback {
    pub offset: f64,
    pub running: bool,
    pub remaining_countdown: f64,
    pub elapsed: f64,
    pub reverse: bool,
}
impl Playback {
    pub fn toggle(&mut self, countdown: u32, end: f64) {
        if self.running {
            self.running = false;
            self.remaining_countdown = 0.;
        } else {
            if self.offset >= end && !self.reverse {
                self.offset = 0.;
            }
            self.remaining_countdown = if self.offset == 0. {
                countdown as f64
            } else {
                0.
            };
            self.running = true;
        }
    }
    pub fn tick(&mut self, dt: Duration, speed: f64, end: f64, looping: bool) {
        if !self.running {
            return;
        }
        // Never leap through a script after a suspended PC or a stalled UI.
        let mut seconds = dt.as_secs_f64().min(0.1);
        if self.remaining_countdown > 0. {
            let used = seconds.min(self.remaining_countdown);
            self.remaining_countdown -= used;
            seconds -= used;
        }
        self.elapsed += seconds;
        let direction = if self.reverse { -1. } else { 1. };
        self.offset += direction * speed * seconds;
        if self.offset > end || self.offset < 0. {
            if looping && end > 0. {
                self.offset = if self.reverse { end } else { 0. };
            } else {
                self.offset = self.offset.clamp(0., end.max(0.));
                self.running = false;
            }
        }
    }
    pub fn seek(&mut self, position: f64, end: f64) {
        self.offset = position.clamp(0., end.max(0.));
        self.remaining_countdown = 0.;
    }
}

pub fn decode_text(bytes: &[u8]) -> Result<String, String> {
    if bytes.len() > 8 * 1024 * 1024 {
        return Err("Scripts must be smaller than 8 MiB.".into());
    }
    let text = if bytes.starts_with(&[0xff, 0xfe]) || bytes.starts_with(&[0xfe, 0xff]) {
        if !bytes.len().is_multiple_of(2) {
            return Err("Truncated UTF-16 document.".into());
        }
        let le = bytes[0] == 0xff;
        let units: Vec<u16> = bytes[2..]
            .as_chunks::<2>()
            .0
            .iter()
            .map(|c| {
                if le {
                    u16::from_le_bytes([c[0], c[1]])
                } else {
                    u16::from_be_bytes([c[0], c[1]])
                }
            })
            .collect();
        String::from_utf16(&units).map_err(|_| "Invalid UTF-16 text.".to_string())?
    } else {
        String::from_utf8(
            bytes
                .strip_prefix(&[0xef, 0xbb, 0xbf])
                .unwrap_or(bytes)
                .to_vec(),
        )
        .map_err(|_| {
            "This is not UTF-8 or UTF-16 text. Export the document as plain text first.".to_string()
        })?
    };
    if text.contains('\0') {
        return Err("Binary documents are not supported. Export as plain text first.".into());
    }
    Ok(text.replace("\r\n", "\n").replace('\r', "\n"))
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn settings_roundtrip_and_invalid_input() {
        let s = Settings::default();
        assert_eq!(Settings::parse(&s.encode()), s);
        let s = Settings::parse("speed=NaN\nfont_size=-9\ncountdown=999\nwidth_percent=0");
        assert_eq!(s.speed, 55.);
        assert_eq!(s.font_size, 20);
        assert_eq!(s.countdown, 10);
        assert_eq!(s.width_percent, 40);
    }
    #[test]
    fn countdown_does_not_scroll() {
        let mut p = Playback::default();
        p.toggle(3, 1000.);
        for _ in 0..20 {
            p.tick(Duration::from_millis(100), 50., 1000., false);
        }
        assert_eq!(p.offset, 0.);
        assert!(p.remaining_countdown > 0.9);
        for _ in 0..20 {
            p.tick(Duration::from_millis(100), 50., 1000., false);
        }
        assert!((p.offset - 50.).abs() < 0.001);
    }
    #[test]
    fn stop_loop_reverse_and_stall() {
        let mut p = Playback {
            running: true,
            offset: 99.,
            ..Default::default()
        };
        p.tick(Duration::from_secs(20), 50., 100., false);
        assert_eq!(p.offset, 100.);
        assert!(!p.running);
        p.running = true;
        p.tick(Duration::from_millis(100), 50., 100., true);
        assert_eq!(p.offset, 0.);
        p.reverse = true;
        p.tick(Duration::from_millis(100), 50., 100., true);
        assert_eq!(p.offset, 100.);
        p.seek(-20., 100.);
        assert_eq!(p.offset, 0.);
    }
    #[test]
    fn encoding_and_binary_rejection() {
        assert_eq!(
            decode_text(b"\xef\xbb\xbfhi\r\nthere").unwrap(),
            "hi\nthere"
        );
        assert_eq!(decode_text(&[255, 254, 65, 0]).unwrap(), "A");
        assert_eq!(decode_text(&[254, 255, 0, 65]).unwrap(), "A");
        assert!(decode_text(&[255, 254, 65]).is_err());
        assert!(decode_text(b"a\0b").is_err());
        assert!(decode_text(&[0xff]).is_err());
    }
}
