//! Tracking health is based on time with audible input, not wall time in silence.
#[derive(Default)]
pub struct Tracking {
    unmatched_seconds: f32,
    pub matched: bool,
    pub confident: bool,
}
#[derive(Debug, PartialEq)]
pub enum State {
    Listening,
    Following,
    Silence,
    Searching,
    Lost,
}
impl Tracking {
    pub fn accept(&mut self) {
        self.unmatched_seconds = 0.;
        self.matched = true;
        self.confident = true;
    }
    pub fn reject(&mut self) {
        self.confident = false;
    }
    pub fn tick(&mut self, seconds: f32, audible: bool, silent: bool) -> State {
        if audible {
            self.unmatched_seconds += seconds.clamp(0., 0.1);
        }
        if silent {
            self.confident = false;
            return State::Silence;
        }
        if self.unmatched_seconds >= 4. {
            return State::Lost;
        }
        if self.confident && self.unmatched_seconds < 2. {
            State::Following
        } else if self.matched {
            State::Searching
        } else {
            State::Listening
        }
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn silence_is_not_lost_and_matching_recovers() {
        let mut t = Tracking::default();
        for _ in 0..1000 {
            assert_eq!(t.tick(0.1, false, true), State::Silence);
        }
        for _ in 0..50 {
            t.tick(0.1, true, false);
        }
        assert_eq!(t.tick(0., false, false), State::Lost);
        assert_eq!(t.tick(0., false, true), State::Silence);
        t.accept();
        assert_eq!(t.tick(0., false, false), State::Following);
        assert_eq!(t.tick(0., false, true), State::Silence);
        assert_eq!(t.tick(0., true, false), State::Searching);
        t.accept();
        t.reject();
        assert_eq!(t.tick(0., false, false), State::Searching);
    }
}
