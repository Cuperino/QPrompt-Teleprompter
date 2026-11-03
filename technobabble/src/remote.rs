use eframe::egui::{Event, Key, Modifiers};
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum Action {
    Toggle,
    Pause,
    Faster,
    Slower,
    PreviousCue,
    NextCue,
    Back,
    Forward,
    Start,
    End,
    Mirror,
    Flip,
}
impl Action {
    pub const ALL: [Self; 12] = [
        Self::Toggle,
        Self::Pause,
        Self::Faster,
        Self::Slower,
        Self::PreviousCue,
        Self::NextCue,
        Self::Back,
        Self::Forward,
        Self::Start,
        Self::End,
        Self::Mirror,
        Self::Flip,
    ];
    pub fn label(self) -> &'static str {
        match self {
            Self::Toggle => "Start / pause",
            Self::Pause => "Pause only",
            Self::Faster => "Faster",
            Self::Slower => "Slower",
            Self::PreviousCue => "Previous cue",
            Self::NextCue => "Next cue",
            Self::Back => "Seek back",
            Self::Forward => "Seek forward",
            Self::Start => "Script start",
            Self::End => "Script end",
            Self::Mirror => "Mirror",
            Self::Flip => "Flip",
        }
    }
}
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Chord {
    pub key: String,
    pub command: bool,
    pub ctrl: bool,
    pub alt: bool,
    pub shift: bool,
}
impl Chord {
    pub fn new(key: Key, m: Modifiers) -> Self {
        Self {
            key: key.name().into(),
            command: m.command,
            ctrl: m.ctrl && (!m.command || m.mac_cmd),
            alt: m.alt,
            shift: m.shift,
        }
    }
    pub fn label(&self) -> String {
        format!(
            "{}{}{}{}{}",
            if self.command { "Cmd/Ctrl+" } else { "" },
            if self.ctrl { "Ctrl+" } else { "" },
            if self.alt { "Alt+" } else { "" },
            if self.shift { "Shift+" } else { "" },
            self.key
        )
    }
    pub fn reserved(&self) -> bool {
        matches!(
            Key::from_name(&self.key),
            None | Some(Key::Escape | Key::F11)
        ) || (self.command
            && matches!(
                Key::from_name(&self.key),
                Some(Key::O | Key::S | Key::Q | Key::W)
            ))
            || (self.alt && self.key == "F4")
    }
}
#[derive(Clone, Serialize, Deserialize)]
pub struct Binding {
    pub action: Action,
    pub slot: usize,
    pub chord: Chord,
}
#[derive(Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct RemoteMap {
    pub bindings: Vec<Binding>,
}
impl Default for RemoteMap {
    fn default() -> Self {
        Self {
            bindings: [
                (Action::Toggle, Key::Space),
                (Action::Faster, Key::ArrowUp),
                (Action::Slower, Key::ArrowDown),
                (Action::PreviousCue, Key::PageUp),
                (Action::NextCue, Key::PageDown),
                (Action::Back, Key::ArrowLeft),
                (Action::Forward, Key::ArrowRight),
                (Action::Start, Key::Home),
                (Action::End, Key::End),
                (Action::Mirror, Key::M),
                (Action::Flip, Key::F),
            ]
            .into_iter()
            .map(|(action, key)| Binding {
                action,
                slot: 0,
                chord: Chord::new(key, Modifiers::NONE),
            })
            .collect(),
        }
    }
}
impl RemoteMap {
    pub fn assign(&mut self, action: Action, slot: usize, chord: Chord) -> Result<(), String> {
        if chord.reserved() {
            return Err("That key is reserved for application or window commands.".into());
        }
        if let Some(other) = self
            .bindings
            .iter()
            .find(|b| b.chord == chord && (b.action != action || b.slot != slot))
        {
            return Err(format!(
                "{} is already assigned to {}. Clear that binding first.",
                chord.label(),
                other.action.label()
            ));
        }
        self.bindings
            .retain(|b| b.action != action || b.slot != slot);
        self.bindings.push(Binding {
            action,
            slot,
            chord,
        });
        Ok(())
    }
    pub fn sanitize(&mut self) {
        let old = std::mem::take(&mut self.bindings);
        for b in old {
            if b.slot < 2 {
                let _ = self.assign(b.action, b.slot, b.chord);
            }
        }
    }
    pub fn actions(&self, events: &[Event]) -> Vec<Action> {
        events
            .iter()
            .filter_map(|e| {
                if let Event::Key {
                    key,
                    modifiers,
                    pressed: true,
                    repeat: false,
                    ..
                } = e
                {
                    let chord = Chord::new(*key, *modifiers);
                    self.bindings
                        .iter()
                        .find(|b| b.chord == chord)
                        .map(|b| b.action)
                } else {
                    None
                }
            })
            .collect()
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    fn event(key: Key, modifiers: Modifiers, repeat: bool) -> Event {
        Event::Key {
            key,
            physical_key: None,
            pressed: true,
            repeat,
            modifiers,
        }
    }
    #[test]
    fn exact_modifiers_repeats_and_conflicts() {
        let windows_command = Chord::new(
            Key::B,
            Modifiers {
                ctrl: true,
                command: true,
                ..Modifiers::NONE
            },
        );
        let mac_command = Chord::new(
            Key::B,
            Modifiers {
                mac_cmd: true,
                command: true,
                ..Modifiers::NONE
            },
        );
        let mac_control_command = Chord::new(
            Key::B,
            Modifiers {
                ctrl: true,
                mac_cmd: true,
                command: true,
                ..Modifiers::NONE
            },
        );
        assert_eq!(windows_command, mac_command);
        assert_ne!(mac_command, mac_control_command);
        let mut map = RemoteMap::default();
        assert_eq!(
            map.actions(&[event(Key::Space, Modifiers::NONE, false)]),
            vec![Action::Toggle]
        );
        assert!(map
            .actions(&[
                event(Key::Space, Modifiers::SHIFT, false),
                event(Key::Space, Modifiers::NONE, true)
            ])
            .is_empty());
        assert!(map
            .assign(Action::Pause, 1, Chord::new(Key::PageDown, Modifiers::NONE))
            .is_err());
        assert!(map
            .assign(Action::Pause, 1, Chord::new(Key::S, Modifiers::COMMAND))
            .is_err());
        map.assign(Action::Pause, 1, Chord::new(Key::B, Modifiers::NONE))
            .unwrap();
        let restored: RemoteMap =
            serde_json::from_str(&serde_json::to_string(&map).unwrap()).unwrap();
        assert_eq!(
            restored.actions(&[event(Key::B, Modifiers::NONE, false)]),
            vec![Action::Pause]
        );
    }
}
