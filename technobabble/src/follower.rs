//! Bounded local alignment. Recognizer hypotheses are untrusted hints, not commands.
use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct FollowSettings {
    pub confidence: f32,
    pub lead_words: usize,
    pub look_ahead: usize,
    pub smoothing: f32,
    pub silence_ms: u64,
    pub gain: f32,
    pub noise_gate: f32,
    pub allow_backtrack: bool,
    pub device: String,
}
impl Default for FollowSettings {
    fn default() -> Self {
        Self {
            confidence: 0.65,
            lead_words: 3,
            look_ahead: 60,
            smoothing: 0.3,
            silence_ms: 900,
            gain: 1.,
            noise_gate: 0.008,
            allow_backtrack: false,
            device: String::new(),
        }
    }
}
impl FollowSettings {
    pub fn sanitize(&mut self) {
        fn finite(v: f32, default: f32, min: f32, max: f32) -> f32 {
            if v.is_finite() {
                v.clamp(min, max)
            } else {
                default
            }
        }
        self.confidence = finite(self.confidence, 0.65, 0.4, 0.95);
        self.smoothing = finite(self.smoothing, 0.3, 0.05, 1.5);
        self.gain = finite(self.gain, 1., 0.1, 5.);
        self.noise_gate = finite(self.noise_gate, 0.008, 0., 0.1);
        self.lead_words = self.lead_words.min(20);
        self.look_ahead = self.look_ahead.clamp(12, 150);
        self.silence_ms = self.silence_ms.clamp(200, 3000);
    }
}
#[derive(Clone, Debug)]
pub struct Token {
    pub text: String,
    pub character: usize,
    pub end: usize,
}
pub fn tokenize(text: &str) -> Vec<Token> {
    let mut result = Vec::new();
    let mut word = String::new();
    let mut start = 0;
    for (i, ch) in text.chars().chain(std::iter::once(' ')).enumerate() {
        if ch.is_alphanumeric() || ((ch == '\'' || ch == '’') && !word.is_empty()) {
            if word.is_empty() {
                start = i;
            }
            if ch != '\'' && ch != '’' {
                word.extend(ch.to_lowercase());
            }
        } else if !word.is_empty() {
            result.push(Token {
                text: std::mem::take(&mut word),
                character: start,
                end: i,
            });
        }
    }
    result
}
#[derive(Default)]
pub struct Follower {
    pub tokens: Vec<Token>,
    pub anchor: usize,
}
#[derive(Debug)]
pub struct Match {
    pub character: usize,
    pub confidence: f32,
    pub matched_range: std::ops::Range<usize>,
}
#[derive(Clone, Copy, Default)]
struct Cell {
    first: Option<usize>,
    score: i32,
    matches: usize,
    evidence: usize,
}
impl Follower {
    pub fn new(script: &str) -> Self {
        Self::with_aliases(script, "")
    }
    pub fn with_aliases(script: &str, aliases: &str) -> Self {
        Self {
            tokens: crate::speech_text::tokens(script, aliases),
            anchor: 0,
        }
    }
    pub fn reanchor(&mut self, character: usize) {
        self.anchor = self
            .tokens
            .partition_point(|t| t.character < character)
            .min(self.tokens.len().saturating_sub(1));
    }
    pub fn accept(&mut self, transcript: &str, settings: &FollowSettings) -> Option<Match> {
        let heard = crate::speech_text::tokens(transcript, "");
        let heard = &heard[heard.len().saturating_sub(18)..];
        if heard.len() < 2 || self.tokens.is_empty() {
            return None;
        }
        let start = self.anchor.saturating_sub(18);
        let end = (self.anchor + settings.look_ahead).min(self.tokens.len());
        let script = &self.tokens[start..end];
        let mut previous = vec![Cell::default(); script.len() + 1];
        let mut best = Cell::default();
        let mut best_index = self.anchor;
        for (hi, h) in heard.iter().enumerate() {
            let mut current = vec![Cell::default(); script.len() + 1];
            for (j, s) in script.iter().enumerate() {
                let group_start = self.tokens[..start + j]
                    .iter()
                    .rposition(|t| t.character != s.character || t.end != s.end)
                    .map_or(0, |i| i + 1);
                let group_end = start
                    + j
                    + self.tokens[start + j..]
                        .iter()
                        .take_while(|t| t.character == s.character && t.end == s.end)
                        .count();
                let offset = start + j - group_start;
                // An expanded amount/name is atomic: a partial matching suffix must
                // not turn "twenty six pounds" into a match for £25.
                let same = h.text == s.text
                    && hi.checked_sub(offset).is_some_and(|begin| {
                        heard
                            .get(begin..begin + group_end - group_start)
                            .is_some_and(|phrase| {
                                phrase
                                    .iter()
                                    .zip(&self.tokens[group_start..group_end])
                                    .all(|(a, b)| a.text == b.text)
                            })
                    });
                let weight = if s.text.len() <= 3 { 2 } else { 4 };
                let mut diagonal = previous[j];
                diagonal.score += if same { weight } else { -3 };
                if same {
                    diagonal.first.get_or_insert(start + j);
                    diagonal.matches += 1;
                    diagonal.evidence += weight as usize;
                }
                let mut skipped_script = current[j];
                skipped_script.score -= 2;
                let mut skipped_heard = previous[j + 1];
                skipped_heard.score -= 2;
                let cell = [Cell::default(), diagonal, skipped_script, skipped_heard]
                    .into_iter()
                    .max_by_key(|c| c.score)
                    .unwrap();
                current[j + 1] = cell;
                // Require a match at the hypothesis end; stale prefixes must not move the script.
                if hi + 1 == heard.len()
                    && same
                    && (settings.allow_backtrack || start + j >= self.anchor)
                    && (cell.score > best.score
                        || (cell.score == best.score
                            && (start + j).abs_diff(self.anchor)
                                < best_index.abs_diff(self.anchor)))
                {
                    best = cell;
                    best_index = start + j;
                }
            }
            previous = current;
        }
        let confidence = best.matches as f32 / heard.len() as f32;
        if best.matches < 2 || best.evidence < 6 || confidence < settings.confidence {
            return None;
        }
        if best_index < self.anchor
            && (!settings.allow_backtrack || best.matches < 4 || confidence < 0.8)
        {
            return None;
        }
        self.anchor = best_index;
        let mut target = best_index;
        for _ in 0..settings.lead_words {
            let end = self.tokens[target].end;
            target = self.tokens[target..]
                .iter()
                .position(|t| t.character >= end)
                .map_or(self.tokens.len() - 1, |i| target + i);
        }
        Some(Match {
            character: self.tokens[target].character,
            matched_range: self.tokens[best.first.unwrap_or(best_index)].character
                ..self.tokens[best_index].end,
            confidence,
        })
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn expanded_readings_match_original_ranges_and_reject_wrong_amounts() {
        let settings = FollowSettings {
            lead_words: 0,
            ..Default::default()
        };
        for (script, spoken) in [
            ("£25", "twenty five pounds"),
            ("03/11/2026", "the third of november twenty twenty six"),
            ("BBC", "b b c"),
        ] {
            let mut f = Follower::new(script);
            let matched = f.accept(spoken, &settings).unwrap();
            assert_eq!(matched.matched_range, 0..script.chars().count());
            assert_eq!(matched.character, 0);
        }
        let mut f = Follower::new("£25");
        assert!(f.accept("twenty six pounds", &settings).is_none());
        assert!(f.accept("five pounds", &settings).is_none());
        let mut f = Follower::with_aliases("Élodie greets Siobhan today", "Siobhan = shiv on");
        let matched = f.accept("greets shiv on", &settings).unwrap();
        assert_eq!(matched.matched_range, 7..21);
        assert!(f.accept("unrelated spoken words", &settings).is_none());
    }
    #[test]
    fn matches_speech_and_holds_unrelated_words() {
        let mut f =
            Follower::new("Welcome to our wonderful garden. Today we plant purple flowers.");
        let s = FollowSettings {
            lead_words: 0,
            ..Default::default()
        };
        assert!(f.accept("our wonderful garden", &s).is_some());
        let anchor = f.anchor;
        assert!(f.accept("a completely unrelated sentence", &s).is_none());
        assert_eq!(f.anchor, anchor);
        assert!(f.accept("garden", &s).is_none());
        assert!(f.accept("today we plant purple flowers", &s).is_some());
    }
    #[test]
    fn repeated_phrases_choose_near_anchor() {
        let mut f = Follower::new("hello lovely world and hello lovely world");
        let s = FollowSettings {
            lead_words: 0,
            ..Default::default()
        };
        assert_eq!(f.accept("hello lovely world", &s).unwrap().character, 13);
        f.reanchor(23);
        assert_eq!(f.accept("hello lovely world", &s).unwrap().character, 36);
    }
    #[test]
    fn unicode_punctuation_and_lead() {
        let mut f = Follower::new("Élodie’s beautiful garden grows today");
        let s = FollowSettings {
            lead_words: 1,
            ..Default::default()
        };
        let m = f.accept("élodie's beautiful", &s).unwrap();
        assert_eq!(m.character, 19);
        assert_eq!(
            "Élodie’s beautiful garden grows today"
                .chars()
                .skip(m.matched_range.start)
                .take(m.matched_range.len())
                .collect::<String>(),
            "Élodie’s beautiful"
        );
    }
    #[test]
    fn no_unrequested_backtracking() {
        let mut f =
            Follower::new("wonderful flowers bloom here and purple blossoms flourish there");
        f.reanchor(50);
        let anchor = f.anchor;
        assert!(f
            .accept("wonderful flowers bloom here", &FollowSettings::default())
            .is_none());
        assert_eq!(f.anchor, anchor);
    }
}
