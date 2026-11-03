use crate::follower::{FollowSettings, Follower};
use serde::{Deserialize, Serialize};
use std::time::Instant;

pub const PASSAGE: &str = "Today I am speaking at a comfortable pace. My voice is clear and relaxed. I pause between sentences and let the words flow naturally. This short reading helps the prompter follow my rhythm. When I finish, I will take a breath and review my settings.";

#[derive(Clone, Serialize, Deserialize)]
pub struct Preset {
    pub name: String,
    pub settings: FollowSettings,
}

#[derive(PartialEq)]
pub enum Stage {
    Intro,
    Quiet,
    Reading,
    Review,
}

pub struct Calibration {
    pub stage: Stage,
    pub started: Instant,
    pub quiet: Vec<f32>,
    pub speech: Vec<f32>,
    pub peak: f32,
    pub audio_tick: u64,
    pub follower: Follower,
    pub first_match: Option<(usize, f32)>,
    pub last_match: Option<(usize, f32)>,
    pub matches: usize,
    pub suggestion: Option<FollowSettings>,
    pub message: String,
    pub heard: String,
}
impl Default for Calibration {
    fn default() -> Self {
        Self {
            stage: Stage::Intro,
            started: Instant::now(),
            quiet: vec![],
            speech: vec![],
            peak: 0.,
            audio_tick: 0,
            follower: Follower::new(PASSAGE),
            first_match: None,
            last_match: None,
            matches: 0,
            suggestion: None,
            message: String::new(),
            heard: String::new(),
        }
    }
}
impl Calibration {
    pub fn hear(&mut self, text: &str) {
        if self.stage != Stage::Reading {
            return;
        }
        self.heard = text.to_owned();
        if self
            .follower
            .accept(text, &FollowSettings::default())
            .is_some()
        {
            let sample = (self.follower.anchor, self.started.elapsed().as_secs_f32());
            if self.last_match.is_none_or(|last| sample.0 > last.0) {
                self.first_match.get_or_insert(sample);
                self.last_match = Some(sample);
                self.matches += 1;
            }
        }
    }
    pub fn recommend(&mut self, base: &FollowSettings) -> Result<(), String> {
        let noise = percentile(&self.quiet, 0.9);
        let voiced: Vec<_> = self
            .speech
            .iter()
            .copied()
            .filter(|v| *v > (noise * 2.).max(0.002))
            .collect();
        if self.quiet.len() < 20 || voiced.len() < 20 || self.matches < 3 {
            return Err("Not enough clear speech matched. Check the microphone, then repeat the passage at your normal pace.".into());
        }
        if self.peak >= 0.98 {
            return Err("The microphone input is clipping. Lower its input volume or move farther away, then retry.".into());
        }
        let (first, last) = self
            .first_match
            .zip(self.last_match)
            .ok_or("Read more of the passage before reviewing.")?;
        if last.0.saturating_sub(first.0) < 8 || last.1 - first.1 < 3. {
            return Err(
                "Read at least another sentence so your reading pace can be estimated.".into(),
            );
        }
        let level = percentile(&voiced, 0.5);
        if level < noise * 3. {
            return Err("The room noise is too close to your speaking level. Move closer to the microphone or reduce background noise and retry.".into());
        }
        let mut s = base.clone();
        s.gain = (0.12 / level)
            .min(0.85 / self.peak.max(0.001))
            .clamp(0.1, 5.);
        s.noise_gate = (noise * s.gain * 2.5)
            .max(0.002)
            .min(level * s.gain * 0.45)
            .clamp(0.0001, 0.1);
        let rate = (last.0 - first.0) as f32 / (last.1 - first.1);
        s.lead_words = (rate * 0.8).round().clamp(1., 8.) as usize;
        s.smoothing = (0.8 / rate.max(0.5)).clamp(0.15, 0.65);
        self.message = format!("Estimated pace: {:.0} words/min. Lead and smoothing are starting suggestions, not a measurement of recognition latency. Fine-tune them after trying your own script.", rate * 60.);
        self.suggestion = Some(s);
        self.stage = Stage::Review;
        Ok(())
    }
}
fn percentile(values: &[f32], fraction: f32) -> f32 {
    let mut sorted: Vec<_> = values
        .iter()
        .copied()
        .filter(|v| v.is_finite() && *v >= 0.)
        .collect();
    sorted.sort_by(f32::total_cmp);
    if sorted.is_empty() {
        0.
    } else {
        sorted[((sorted.len() - 1) as f32 * fraction) as usize]
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    fn sample() -> Calibration {
        Calibration {
            quiet: vec![0.002; 80],
            speech: vec![0.04; 200],
            peak: 0.2,
            matches: 8,
            first_match: Some((2, 1.)),
            last_match: Some((32, 16.)),
            ..Default::default()
        }
    }
    #[test]
    fn recommendations_are_bounded_and_preserve_other_controls() {
        let mut c = sample();
        let base = FollowSettings {
            confidence: 0.8,
            device: "Studio mic".into(),
            ..Default::default()
        };
        c.recommend(&base).unwrap();
        let s = c.suggestion.unwrap();
        assert_eq!(s.gain, 3.);
        assert_eq!(s.lead_words, 2);
        assert!(s.noise_gate > 0.002 * s.gain && s.noise_gate < 0.04 * s.gain);
        assert_eq!(s.confidence, 0.8);
        assert_eq!(s.device, "Studio mic");
    }
    #[test]
    fn rejects_silence_clipping_and_insufficient_matches() {
        let mut c = sample();
        c.peak = 1.;
        assert!(c.recommend(&FollowSettings::default()).is_err());
        let mut c = sample();
        c.speech = vec![0.; 200];
        assert!(c.recommend(&FollowSettings::default()).is_err());
        let mut c = sample();
        c.matches = 1;
        assert!(c.recommend(&FollowSettings::default()).is_err());
    }
}
