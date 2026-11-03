use serde::{Deserialize, Serialize};
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum ScriptFont {
    #[default]
    Sans,
    Bold,
    Monospace,
}
impl ScriptFont {
    pub fn label(self) -> &'static str {
        match self {
            Self::Sans => "Sans serif",
            Self::Bold => "Bold sans serif",
            Self::Monospace => "Monospace",
        }
    }
    pub fn family(self) -> eframe::egui::FontFamily {
        match self {
            Self::Sans => eframe::egui::FontFamily::Proportional,
            Self::Bold => eframe::egui::FontFamily::Name("script-bold".into()),
            Self::Monospace => eframe::egui::FontFamily::Monospace,
        }
    }
}
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(default)]
pub struct Appearance {
    pub font: ScriptFont,
    pub line_spacing: f32,
    pub text: [u8; 3],
    pub background: [u8; 3],
    pub guide_color: [u8; 3],
    pub guide_position: f32,
    pub output_screen: Option<String>,
}
impl Default for Appearance {
    fn default() -> Self {
        Self {
            font: ScriptFont::Sans,
            line_spacing: 1.45,
            text: [239, 243, 247],
            background: [8, 12, 18],
            guide_color: [91, 224, 192],
            guide_position: 0.32,
            output_screen: None,
        }
    }
}
impl Appearance {
    pub fn sanitize(&mut self) {
        self.line_spacing = if self.line_spacing.is_finite() {
            self.line_spacing.clamp(1., 2.5)
        } else {
            1.45
        };
        self.guide_position = if self.guide_position.is_finite() {
            self.guide_position.clamp(0.1, 0.8)
        } else {
            0.32
        };
    }
}
#[derive(Clone, Serialize, Deserialize)]
pub struct PresentationPreset {
    pub name: String,
    pub appearance: Appearance,
    pub font_size: i32,
    pub width_percent: i32,
    pub guide: bool,
    pub mirror: bool,
    pub flip: bool,
}
impl PresentationPreset {
    pub fn capture(
        name: String,
        appearance: &Appearance,
        settings: &crate::model::Settings,
    ) -> Self {
        Self {
            name,
            appearance: appearance.clone(),
            font_size: settings.font_size,
            width_percent: settings.width_percent,
            guide: settings.guide,
            mirror: settings.mirror,
            flip: settings.flip,
        }
    }
    pub fn apply(&self, appearance: &mut Appearance, settings: &mut crate::model::Settings) {
        *appearance = self.appearance.clone();
        appearance.sanitize();
        settings.font_size = self.font_size.clamp(20, 120);
        settings.width_percent = self.width_percent.clamp(40, 96);
        settings.guide = self.guide;
        settings.mirror = self.mirror;
        settings.flip = self.flip;
    }
}
#[derive(Clone, Debug)]
pub struct Screen {
    pub name: String,
    pub label: String,
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
    pub primary: bool,
}
pub fn screens() -> Result<Vec<Screen>, String> {
    // Wayland deliberately leaves top-level window placement to its compositor.
    if cfg!(target_os = "linux") && std::env::var_os("WAYLAND_DISPLAY").is_some() {
        return Err(
            "On Wayland, move the output window with your desktop's window controls.".into(),
        );
    }
    display_info::DisplayInfo::all()
        .map_err(|e| e.to_string())
        .map(|all| {
            all.into_iter()
                .map(|s| Screen {
                    name: s.name.clone(),
                    label: format!(
                        "{} · {} × {}",
                        if s.friendly_name.is_empty() {
                            s.name
                        } else {
                            s.friendly_name
                        },
                        s.width,
                        s.height
                    ),
                    x: s.x as f32,
                    y: s.y as f32,
                    width: s.width as f32,
                    height: s.height as f32,
                    primary: s.is_primary,
                })
                .collect()
        })
}
pub fn select_screen<'a>(screens: &'a [Screen], preferred: Option<&str>) -> Option<&'a Screen> {
    preferred
        .and_then(|name| screens.iter().find(|s| s.name == name))
        .or_else(|| screens.iter().find(|s| s.primary))
        .or_else(|| screens.first())
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn preset_roundtrip_and_clamping_leave_playback_settings_alone() {
        let mut settings = crate::model::Settings {
            font_size: 60,
            mirror: true,
            ..Default::default()
        };
        let mut appearance = Appearance {
            line_spacing: 2.,
            guide_position: 0.6,
            output_screen: Some("screen-two".into()),
            ..Default::default()
        };
        let preset = PresentationPreset::capture("Studio".into(), &appearance, &settings);
        let restored: PresentationPreset =
            serde_json::from_str(&serde_json::to_string(&preset).unwrap()).unwrap();
        settings.speed = 123.;
        appearance = Appearance::default();
        restored.apply(&mut appearance, &mut settings);
        assert_eq!(settings.speed, 123.);
        assert!(settings.mirror);
        assert_eq!(appearance.output_screen.as_deref(), Some("screen-two"));
        appearance.line_spacing = f32::NAN;
        appearance.guide_position = 5.;
        appearance.sanitize();
        assert_eq!(appearance.line_spacing, 1.45);
        assert_eq!(appearance.guide_position, 0.8);
    }
    #[test]
    fn disconnected_screen_falls_back_to_primary() {
        let all = vec![Screen {
            name: "primary".into(),
            label: String::new(),
            x: 0.,
            y: 0.,
            width: 1920.,
            height: 1080.,
            primary: true,
        }];
        assert_eq!(
            select_screen(&all, Some("removed")).unwrap().name,
            "primary"
        );
        assert!(select_screen(&[], None).is_none());
    }
}
