//! Reading estimates use original-script words, never normalization expansions.
use std::collections::VecDeque;
#[derive(Default)]
pub struct Reading {
    pub ends: Vec<usize>,
    pub pace: Pace,
    pub spoken_character: usize,
}
impl Reading {
    pub fn new(text: &str) -> Self {
        Self {
            ends: crate::follower::tokenize(text)
                .iter()
                .map(|t| t.end)
                .collect(),
            ..Default::default()
        }
    }
    pub fn read_words(&self, character: usize) -> usize {
        self.ends.partition_point(|end| *end <= character)
    }
    pub fn remaining(&self, character: usize) -> usize {
        self.ends.len() - self.read_words(character)
    }
}
#[derive(Default)]
pub struct Pace {
    clock: f64,
    samples: VecDeque<(f64, usize)>,
    pub wpm: Option<f64>,
}
impl Pace {
    pub fn rebase(&mut self, word: usize) {
        self.clock = 0.;
        self.samples.clear();
        self.samples.push_back((0., word));
    }
    pub fn tick(&mut self, seconds: f64, word: usize, active: bool) {
        if !active || !seconds.is_finite() || seconds <= 0. {
            return;
        }
        if self.samples.back().is_some_and(|(_, last)| word < *last) {
            self.wpm = None;
            self.rebase(word);
            return;
        }
        self.clock += seconds.min(0.1);
        if self.samples.is_empty() {
            self.samples.push_back((self.clock, word));
        }
        self.samples.push_back((self.clock, word));
        while self.samples.len() > 2 && self.samples[1].0 < self.clock - 20. {
            self.samples.pop_front();
        }
        let (start, first) = self.samples[0];
        let duration = self.clock - start;
        if duration >= 3. {
            self.wpm = Some((word - first) as f64 * 60. / duration);
        }
    }
}
pub fn voice_seconds(words: usize, wpm: Option<f64>, planning: f64) -> (f64, bool) {
    if words == 0 {
        return (0., false);
    }
    match wpm.filter(|v| v.is_finite() && *v >= 1.) {
        Some(wpm) => (words as f64 * 60. / wpm, false),
        None => (words as f64 * 60. / planning.clamp(40., 400.), true),
    }
}
pub fn duration(seconds: f64) -> String {
    let s = seconds.max(0.).ceil() as u64;
    format!("{}:{:02}", s / 60, s % 60)
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn pace_excludes_pauses_and_rebases_seeks() {
        let mut p = Pace::default();
        p.rebase(0);
        for n in 1..=100 {
            p.tick(0.1, n / 5, true);
        }
        assert!((p.wpm.unwrap() - 120.).abs() < 0.01);
        let rate = p.wpm;
        p.tick(60., 20, false);
        assert_eq!(p.wpm, rate);
        p.rebase(200);
        p.tick(0.1, 200, true);
        assert_eq!(p.wpm, rate);
        for _ in 0..250 {
            p.tick(0.1, 200, true);
        }
        assert_eq!(p.wpm, Some(0.));
    }
    #[test]
    fn words_and_estimates() {
        let r = Reading::new("Élodie pays £25 today");
        assert_eq!(r.ends.len(), 4);
        assert_eq!(r.remaining(6), 3);
        assert_eq!(voice_seconds(150, None, 150.), (60., true));
        assert_eq!(voice_seconds(150, Some(120.), 150.), (75., false));
        assert_eq!(duration(60.1), "1:01");
    }
}
