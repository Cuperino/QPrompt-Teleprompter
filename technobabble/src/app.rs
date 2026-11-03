use crate::{
    calibration::{Calibration, Preset, Stage, PASSAGE},
    follower::{FollowSettings, Follower},
    model::{Playback, Settings, WELCOME},
    presentation::{Appearance, PresentationPreset, ScriptFont},
    remote::{Action, Chord, RemoteMap},
    storage,
    tracking::{State, Tracking},
    voice,
};
use eframe::egui::{self, Color32, FontId, Key, Pos2, Rect, RichText, Stroke, Vec2};
use serde::{Deserialize, Serialize};
use std::{
    path::PathBuf,
    sync::{atomic::Ordering, Arc},
    time::{Duration, Instant},
};

const ACCENT: Color32 = Color32::from_rgb(91, 224, 192);
const MUTED: Color32 = Color32::from_rgb(142, 157, 175);
const BG: Color32 = Color32::from_rgb(17, 23, 32);

#[derive(Serialize, Deserialize)]
#[serde(default)]
struct Document {
    script: String,
    settings: Settings,
    follow: FollowSettings,
    path: Option<PathBuf>,
    modified: bool,
    presets: Vec<Preset>,
    aliases: String,
    emphasis: Vec<crate::word::Emphasis>,
    show_emphasis: bool,
    appearance: Appearance,
    presentation_presets: Vec<PresentationPreset>,
    remotes: RemoteMap,
    library: crate::library::Library,
    bookmarks: Vec<crate::library::Bookmark>,
    source_path: Option<PathBuf>,
    planning_wpm: f64,
}
impl Default for Document {
    fn default() -> Self {
        Self {
            script: WELCOME.into(),
            settings: Settings::default(),
            follow: FollowSettings::default(),
            path: None,
            modified: false,
            presets: vec![],
            aliases: String::new(),
            emphasis: vec![],
            show_emphasis: true,
            appearance: Appearance::default(),
            presentation_presets: vec![],
            remotes: RemoteMap::default(),
            library: crate::library::Library::default(),
            bookmarks: vec![],
            source_path: None,
            planning_wpm: 150.,
        }
    }
}
struct Layout {
    appearance: Appearance,
    key: (u64, u32, i32, bool, bool, u32),
    original: Arc<egui::Galley>,
    displayed: Arc<egui::Galley>,
}
#[derive(Clone, Copy, PartialEq)]
enum FileAction {
    QueueAdd,
    Open,
    Save,
}
pub struct Prompter {
    root: PathBuf,
    doc: Document,
    playback: Playback,
    follower: Follower,
    revision: u64,
    layout: Option<Layout>,
    output_layout: Option<Layout>,
    last_frame: Instant,
    last_save: Instant,
    session_dirty: bool,
    status: String,
    error: Option<String>,
    editor: bool,
    settings_open: bool,
    fullscreen: bool,
    output: bool,
    voice_mode: bool,
    voice: Option<voice::Session>,
    epoch: u64,
    voice_state: String,
    transcript: String,
    confidence: f32,
    voice_target: f64,
    speech_ticks: u64,
    last_speech: Instant,
    devices: Vec<String>,
    file_action: Option<FileAction>,
    open_after_save: Option<PathBuf>,
    pending_open: Option<PathBuf>,
    confirm_close: bool,
    allow_close: bool,
    recovery_blocked: bool,
    search: String,
    help: bool,
    calibration: Option<Calibration>,
    preset_name: String,
    presentation_name: String,
    learning: Option<(Action, usize)>,
    screens: Vec<crate::presentation::Screen>,
    screen_error: Option<String>,
    output_placement_frames: u8,
    tracking: Tracking,
    matched_range: Option<std::ops::Range<usize>>,
    voice_ready: bool,
    audible: bool,
    can_follow: bool,
    library_open: bool,
    bookmark_name: String,
    requested_segment: Option<u64>,
    reading: crate::reading::Reading,
}
impl Prompter {
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        let mut fonts = egui::FontDefinitions::default();
        fonts.font_data.insert(
            "script-bold".into(),
            egui::FontData::from_static(include_bytes!("../assets/DejaVuSans-Bold.ttf")).into(),
        );
        let mut bold_fonts = vec!["script-bold".into()];
        bold_fonts.extend(fonts.families[&egui::FontFamily::Proportional].clone());
        fonts
            .families
            .insert(egui::FontFamily::Name("script-bold".into()), bold_fonts);
        cc.egui_ctx.set_fonts(fonts);
        cc.egui_ctx.set_theme(egui::ThemePreference::Dark);
        let mut style = (*cc.egui_ctx.style()).clone();
        style.visuals = egui::Visuals::dark();
        style.visuals.panel_fill = BG;
        style.visuals.window_fill = Color32::from_rgb(23, 31, 43);
        style.visuals.selection.bg_fill = Color32::from_rgb(32, 102, 91);
        style.visuals.widgets.active.bg_fill = Color32::from_rgb(37, 113, 99);
        style.spacing.item_spacing = Vec2::new(10., 9.);
        style.spacing.button_padding = Vec2::new(12., 8.);
        cc.egui_ctx.set_style(style);
        let root = storage::root();
        let mut error = None;
        let mut recovery_blocked = false;
        let mut doc: Document = match std::fs::read(root.join("data/session.json")) {
            Ok(data) => match serde_json::from_slice(&data) {
                Ok(doc) => doc,
                Err(e) => {
                    let stamp = std::time::SystemTime::now()
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_nanos();
                    let backup = root.join(format!("data/session-unreadable-{stamp}.json"));
                    recovery_blocked = storage::atomic_write(&backup, &data).is_err();
                    error = Some(if recovery_blocked {
                        format!("Recovery file could not be read or backed up. Automatic recovery is disabled to preserve it: {e}")
                    } else {
                        format!(
                            "Recovery file could not be read. A copy was preserved at {}: {e}",
                            backup.display()
                        )
                    });
                    Document::default()
                }
            },
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => Document::default(),
            Err(e) => {
                recovery_blocked = true;
                error = Some(format!("Cannot read saved session: {e}"));
                Document::default()
            }
        };
        doc.settings = Settings::parse(&doc.settings.encode());
        doc.follow.sanitize();
        doc.appearance.sanitize();
        doc.remotes.sanitize();
        for preset in &mut doc.presets {
            preset.settings.sanitize();
        }
        doc.planning_wpm = if doc.planning_wpm.is_finite() {
            doc.planning_wpm.clamp(40., 400.)
        } else {
            150.
        };
        if doc.source_path.is_none() {
            doc.source_path = doc.path.clone();
        }
        doc.source_path = doc
            .source_path
            .as_ref()
            .map(|p| crate::library::path_key(p));
        let reading = crate::reading::Reading::new(&doc.script);
        let follower = Follower::with_aliases(&doc.script, &doc.aliases);
        let now = Instant::now();
        let mut result = Self {
            root,
            doc,
            playback: Playback::default(),
            follower,
            revision: 0,
            layout: None,
            output_layout: None,
            last_frame: now,
            last_save: now,
            session_dirty: false,
            status: "Ready · scripts and speech stay on this computer".into(),
            error,
            editor: true,
            settings_open: true,
            fullscreen: false,
            output: false,
            voice_mode: false,
            voice: None,
            epoch: 0,
            voice_state: "Microphone off".into(),
            transcript: String::new(),
            confidence: 0.,
            voice_target: 0.,
            speech_ticks: 0,
            last_speech: now,
            devices: Vec::new(),
            file_action: None,
            open_after_save: None,
            pending_open: None,
            confirm_close: false,
            allow_close: false,
            recovery_blocked,
            search: String::new(),
            help: false,
            calibration: None,
            preset_name: String::new(),
            presentation_name: String::new(),
            learning: None,
            screens: vec![],
            screen_error: None,
            output_placement_frames: 0,
            tracking: Tracking::default(),
            matched_range: None,
            voice_ready: false,
            audible: false,
            can_follow: false,
            library_open: false,
            bookmark_name: String::new(),
            requested_segment: None,
            reading,
        };
        result.refresh_screens();
        if let Some(path) = std::env::args_os()
            .nth(1)
            .filter(|p| !p.to_string_lossy().starts_with("--"))
        {
            result.request_open(path.into());
        }
        result
    }
    fn end(&self) -> f64 {
        self.layout.as_ref().map_or(0., |l| {
            (l.original.size().y - self.doc.settings.font_size as f32).max(0.) as f64
        })
    }
    fn guide_character(&self) -> usize {
        if self.end() > 0. && self.playback.offset >= self.end() {
            return self.doc.script.chars().count();
        }
        self.layout.as_ref().map_or(0, |l| {
            l.original
                .cursor_from_pos(Vec2::new(0., self.playback.offset as f32 + 1.))
                .index
        })
    }
    fn reanchor(&mut self) {
        self.reading.spoken_character = self.guide_character();
        self.reading
            .pace
            .rebase(self.reading.read_words(self.reading.spoken_character));
        self.tracking = Tracking::default();
        self.matched_range = None;
        self.can_follow = false;
        self.last_speech = Instant::now();
        if let Some(l) = &self.layout {
            let c = l
                .original
                .cursor_from_pos(Vec2::new(0., self.playback.offset as f32 + 1.));
            self.follower.reanchor(c.index);
        }
        self.voice_target = self.playback.offset;
        self.confidence = 0.;
        self.transcript.clear();
        if let Some(v) = &self.voice {
            self.epoch = v.reset();
        }
    }
    fn seek(&mut self, pos: f64) {
        self.reading.pace = crate::reading::Pace::default();
        self.playback.seek(pos, self.end());
        self.reanchor();
    }
    fn toggle(&mut self) {
        let previous_offset = self.playback.offset;
        let spoken_character = self.reading.spoken_character;
        self.playback.toggle(
            if self.voice_mode {
                0
            } else {
                self.doc.settings.countdown
            },
            self.end(),
        );
        self.reanchor();
        if self.voice_mode && self.playback.offset == previous_offset {
            self.reading.spoken_character = spoken_character;
            self.reading
                .pace
                .rebase(self.reading.read_words(spoken_character));
        }
        if self.playback.running && self.voice_mode && self.voice.is_none() {
            self.start_voice();
        }
    }
    fn start_voice(&mut self) {
        self.voice_ready = false;
        self.tracking = Tracking::default();
        self.matched_range = None;
        self.voice = Some(voice::Session::start(
            &self.root,
            self.doc.follow.device.clone(),
            self.doc.follow.gain,
            self.doc.follow.noise_gate,
        ));
        self.epoch = 0;
        self.voice_state = "Loading local speech model…".into();
        self.speech_ticks = 0;
        self.last_speech = Instant::now();
        self.voice_target = self.playback.offset;
    }
    fn stop_voice(&mut self) {
        self.voice_ready = false;
        self.can_follow = false;
        self.voice = None;
        self.voice_state = "Microphone off".into();
        self.playback.running = false;
    }
    fn changed(&mut self) {
        self.revision += 1;
        self.doc.modified = true;
        self.session_dirty = true;
        self.follower = Follower::with_aliases(&self.doc.script, &self.doc.aliases);
        self.reading = crate::reading::Reading::new(&self.doc.script);
        self.layout = None;
        self.output_layout = None;
        self.playback = Playback::default();
        self.reanchor();
    }
    fn persist(&mut self) -> bool {
        if self.recovery_blocked {
            return false;
        }
        let result = serde_json::to_vec_pretty(&self.doc)
            .map_err(|e| e.to_string())
            .and_then(|v| {
                storage::atomic_write(&self.root.join("data/session.json"), &v)
                    .map_err(|e| e.to_string())
            });
        self.last_save = Instant::now();
        match result {
            Ok(()) => {
                self.session_dirty = false;
                true
            }
            Err(e) => {
                self.error = Some(format!("Could not save the recovery copy: {e}"));
                false
            }
        }
    }
    fn request_open(&mut self, path: PathBuf) {
        self.requested_segment = None;
        self.request_script(path);
    }
    fn request_script(&mut self, path: PathBuf) {
        self.stop_voice();
        if self.doc.modified {
            self.pending_open = Some(path);
        } else {
            self.open(path);
        }
    }
    fn open(&mut self, path: PathBuf) {
        let path = crate::library::path_key(&path);
        match storage::read_script(&path) {
            Ok(imported) => {
                self.stop_voice();
                let (marks, stale) = self.doc.library.marks(&path, &imported.text);
                self.doc.bookmarks = marks;
                self.doc.source_path = Some(path.clone());
                self.doc.library.remember(path.clone());
                self.doc.library.active = self.requested_segment.take();
                self.doc.script = imported.text;
                self.doc.emphasis = imported.emphasis;
                self.changed();
                let word = crate::word::is_docx(&path);
                self.doc.modified = word;
                self.doc.path = if word { None } else { Some(path) };
                self.status = if stale {"Script opened; old bookmarks were not applied because the file contents changed."} else if word { "Word script imported. Save creates a text copy; emphasis is kept in session recovery." } else { "Script opened" }.into();
            }
            Err(e) => {
                self.requested_segment = None;
                self.error = Some(e);
            }
        }
    }
    fn save_file(&mut self, path: PathBuf) -> bool {
        if !path
            .extension()
            .is_some_and(|e| e.eq_ignore_ascii_case("txt") || e.eq_ignore_ascii_case("md"))
        {
            self.error = Some("Save scripts with a .txt or .md extension. Word import does not overwrite Word documents.".into());
            return false;
        }
        match storage::atomic_write(&path, self.doc.script.as_bytes()) {
            Ok(()) => {
                let path = crate::library::path_key(&path);
                self.doc.library.remember(path.clone());
                self.doc
                    .library
                    .save_marks(path.clone(), &self.doc.script, &self.doc.bookmarks);
                if !self
                    .doc
                    .library
                    .queue
                    .iter()
                    .any(|s| Some(s.id) == self.doc.library.active && s.path == path)
                {
                    self.doc.library.active = None;
                }
                self.doc.source_path = Some(path.clone());
                self.doc.path = Some(path);
                self.doc.modified = false;
                self.session_dirty = true;
                self.status = "Script saved as UTF-8 text".into();
                true
            }
            Err(e) => {
                self.error = Some(format!("Could not save script: {e}"));
                false
            }
        }
    }
    fn file_dialog(&mut self, action: FileAction) {
        self.stop_voice();
        self.file_action = Some(action);
    }
    fn native_file_dialog(&mut self, frame: &eframe::Frame) {
        let Some(action) = self.file_action.take() else {
            return;
        };
        let mut dialog = rfd::FileDialog::new()
            .set_parent(frame)
            .add_filter("Text scripts", &["txt", "md"]);
        if let Some(parent) = self
            .doc
            .path
            .as_ref()
            .and_then(|p| p.parent())
            .filter(|p| p.is_dir())
        {
            dialog = dialog.set_directory(parent);
        }
        match action {
            FileAction::QueueAdd => {
                if let Some(paths) = dialog
                    .set_title("Add scripts to running order")
                    .add_filter("Word documents", &["docx"])
                    .pick_files()
                {
                    for path in paths {
                        self.doc.library.add(crate::library::path_key(&path));
                    }
                    self.session_dirty = true;
                }
            }
            FileAction::Open => {
                if let Some(path) = dialog
                    .set_title("Open script")
                    .add_filter("Word documents", &["docx"])
                    .add_filter("All files", &["*"])
                    .pick_file()
                {
                    self.request_open(path);
                }
            }
            FileAction::Save => {
                let name = self
                    .doc
                    .path
                    .as_ref()
                    .and_then(|p| p.file_name())
                    .map_or_else(
                        || "script.txt".to_owned(),
                        |s| s.to_string_lossy().into_owned(),
                    );
                let next = self.open_after_save.take();
                if let Some(path) = dialog
                    .set_title("Save script as")
                    .set_file_name(name)
                    .save_file()
                {
                    if self.save_file(path) {
                        if let Some(next) = next {
                            self.open(next);
                        }
                    }
                }
                self.requested_segment = None;
            }
        }
        // Browsing time is not playback time. Resume only on explicit Start.
        self.last_frame = Instant::now();
    }
    fn poll_voice(&mut self) {
        let Some(v) = &self.voice else { return };
        v.shared
            .gain
            .store(self.doc.follow.gain.to_bits(), Ordering::Relaxed);
        v.shared
            .gate
            .store(self.doc.follow.noise_gate.to_bits(), Ordering::Relaxed);
        let ticks = v.shared.speech_ticks.load(Ordering::Relaxed);
        self.audible = ticks != self.speech_ticks;
        let audio_tick = v.shared.audio_ticks.load(Ordering::Relaxed);
        if let Some(c) = &mut self.calibration {
            if self.voice_ready && audio_tick != c.audio_tick {
                c.audio_tick = audio_tick;
                let level = f32::from_bits(v.shared.raw_level.load(Ordering::Relaxed));
                match c.stage {
                    Stage::Quiet => {
                        if c.started.elapsed().as_secs_f32() <= 4. && c.quiet.len() < 1200 {
                            c.quiet.push(level);
                        }
                    }
                    Stage::Reading => {
                        if c.speech.len() < 12000 {
                            c.speech.push(level);
                        }
                        c.peak = c
                            .peak
                            .max(f32::from_bits(v.shared.raw_peak.swap(0, Ordering::Relaxed)));
                    }
                    _ => {}
                }
            }
        }
        if ticks != self.speech_ticks {
            self.speech_ticks = ticks;
            self.last_speech = Instant::now();
        }
        let events: Vec<_> = v.events.try_iter().collect();
        for event in events {
            match event {
                voice::Event::Ready(name) => {
                    self.voice_ready = true;
                    self.voice_state = format!("Listening · {name}");
                    if let Some(c) = &mut self.calibration {
                        c.started = Instant::now();
                    }
                }
                voice::Event::Error(error) => {
                    self.error = Some(error);
                    self.stop_voice();
                }
                voice::Event::Transcript(text, epoch) => {
                    if epoch != self.epoch {
                        continue;
                    }
                    if let Some(c) = &mut self.calibration {
                        c.hear(&text);
                        continue;
                    }
                    self.transcript = text.clone();
                    if self.playback.running && self.voice_mode && !text.is_empty() {
                        if let Some(m) = self.follower.accept(&text, &self.doc.follow) {
                            self.tracking.accept();
                            self.reading.spoken_character = m.matched_range.end;
                            self.matched_range = Some(m.matched_range);
                            self.confidence = m.confidence;
                            if let Some(l) = &self.layout {
                                self.voice_target =
                                    l.original
                                        .pos_from_cursor(egui::text::CCursor::new(m.character))
                                        .top() as f64;
                                self.voice_target = self.voice_target.clamp(0., self.end());
                            }
                            self.voice_state = "Following your voice".into();
                        } else {
                            self.tracking.reject();
                            self.confidence = 0.;
                            self.voice_state = "Holding · waiting for a script match".into();
                        }
                    }
                }
            }
        }
    }
    fn shortcuts(&mut self, ctx: &egui::Context) {
        if self.calibration.is_some() {
            return;
        }
        if let Some((action, slot)) = self.learning {
            let events = ctx.input(|i| i.events.clone());
            for event in events {
                if let egui::Event::Key {
                    key,
                    modifiers,
                    pressed: true,
                    repeat: false,
                    ..
                } = event
                {
                    if key == Key::Escape {
                        self.learning = None;
                        self.status = "Shortcut recording cancelled".into();
                    } else {
                        match self
                            .doc
                            .remotes
                            .assign(action, slot, Chord::new(key, modifiers))
                        {
                            Ok(()) => {
                                self.learning = None;
                                self.session_dirty = true;
                                self.status = format!("Updated {} control", action.label());
                            }
                            Err(error) => self.status = error,
                        }
                    }
                    break;
                }
            }
            ctx.input_mut(|i| {
                i.events.retain(|e| {
                    !matches!(
                        e,
                        egui::Event::Key { .. }
                            | egui::Event::Text(_)
                            | egui::Event::Paste(_)
                            | egui::Event::Copy
                            | egui::Event::Cut
                    )
                })
            });
            return;
        }
        // Match the modifiers attached to the key event, not their state at
        // frame end (a fast chord can already have released Ctrl/Cmd).
        let save_as = ctx.input_mut(|i| {
            i.consume_key(egui::Modifiers::COMMAND | egui::Modifiers::SHIFT, Key::S)
        });
        let save = ctx.input_mut(|i| i.consume_key(egui::Modifiers::COMMAND, Key::S));
        if save_as || save {
            if save_as || self.doc.path.is_none() {
                self.file_dialog(FileAction::Save);
            } else {
                self.save_file(self.doc.path.clone().unwrap());
            }
        }
        if ctx.input_mut(|i| i.consume_key(egui::Modifiers::COMMAND, Key::O)) {
            self.file_dialog(FileAction::Open);
        }
        if ctx.input(|i| i.key_pressed(Key::F11)) {
            self.fullscreen = !self.fullscreen;
            ctx.send_viewport_cmd(egui::ViewportCommand::Fullscreen(self.fullscreen));
        }
        if ctx.input(|i| i.key_pressed(Key::Escape)) {
            self.playback.running = false;
            self.fullscreen = false;
            ctx.send_viewport_cmd(egui::ViewportCommand::Fullscreen(false));
        }
        if (ctx.wants_keyboard_input()
            && ctx.memory(|m| m.focused()) != Some(egui::Id::new("prompt_canvas")))
            || self.file_action.is_some()
            || self.pending_open.is_some()
            || self.confirm_close
        {
            return;
        }
        self.remote_actions(ctx);
    }
    fn remote_actions(&mut self, ctx: &egui::Context) {
        if self.library_open
            || self.calibration.is_some()
            || self.learning.is_some()
            || self.file_action.is_some()
            || self.pending_open.is_some()
            || self.confirm_close
            || self.help
            || self.error.is_some()
        {
            return;
        }
        let actions = ctx.input(|i| self.doc.remotes.actions(&i.events));
        for action in actions {
            match action {
                Action::Toggle => self.toggle(),
                Action::Pause => {
                    self.playback.running = false;
                    self.playback.remaining_countdown = 0.;
                    self.reanchor();
                }
                Action::Faster => {
                    self.doc.settings.speed = (self.doc.settings.speed + 5.).min(500.);
                    self.session_dirty = true;
                }
                Action::Slower => {
                    self.doc.settings.speed = (self.doc.settings.speed - 5.).max(5.);
                    self.session_dirty = true;
                }
                Action::PreviousCue => self.marker(false),
                Action::NextCue => self.marker(true),
                Action::Back => self.seek(self.playback.offset - 200.),
                Action::Forward => self.seek(self.playback.offset + 200.),
                Action::Start => self.seek(0.),
                Action::End => self.seek(self.end()),
                Action::Mirror => {
                    self.doc.settings.mirror = !self.doc.settings.mirror;
                    self.session_dirty = true;
                }
                Action::Flip => {
                    self.doc.settings.flip = !self.doc.settings.flip;
                    self.session_dirty = true;
                }
            }
            ctx.request_repaint_of(egui::ViewportId::ROOT);
        }
    }
    fn marker(&mut self, next: bool) {
        let Some(l) = &self.layout else { return };
        let mut character = 0;
        let positions: Vec<f64> = self
            .doc
            .script
            .split_inclusive('\n')
            .filter_map(|line| {
                let p = character;
                character += line.chars().count();
                line.trim_start().starts_with('#').then(|| {
                    l.original
                        .pos_from_cursor(egui::text::CCursor::new(p))
                        .top() as f64
                })
            })
            .collect();
        let target = if next {
            positions
                .into_iter()
                .find(|p| *p > self.playback.offset + 2.)
        } else {
            positions
                .into_iter()
                .rev()
                .find(|p| *p < self.playback.offset - 2.)
        };
        if let Some(pos) = target {
            self.seek(pos);
        }
    }
    fn toolbar(&mut self, ctx: &egui::Context) {
        egui::TopBottomPanel::top("toolbar")
            .frame(egui::Frame::new().fill(BG).inner_margin(14))
            .show(ctx, |ui| {
                ui.horizontal(|ui| {
                    ui.label(
                        RichText::new("TECHNOBABBLE")
                            .strong()
                            .size(20.)
                            .color(ACCENT),
                    );
                    ui.separator();
                    if ui.button("Open").clicked() {
                        self.file_dialog(FileAction::Open);
                    }
                    if ui.button("Save").clicked() {
                        if let Some(p) = self.doc.path.clone() {
                            self.save_file(p);
                        } else {
                            self.file_dialog(FileAction::Save);
                        }
                    }
                    ui.toggle_value(&mut self.editor, "Editor");
                    ui.toggle_value(&mut self.library_open, "Library");
                    ui.toggle_value(&mut self.settings_open, "Controls");
                    ui.toggle_value(&mut self.output, "Output window");
                    if ui.button("Fullscreen").clicked() {
                        self.fullscreen = true;
                        ctx.send_viewport_cmd(egui::ViewportCommand::Fullscreen(true));
                    }
                    if ui.button("?").clicked() {
                        self.help = !self.help;
                    }
                });
                ui.add_space(3.);
                ui.horizontal(|ui| {
                    let title = self
                        .doc
                        .path
                        .as_ref()
                        .and_then(|p| p.file_name())
                        .map_or("Untitled script".into(), |s| s.to_string_lossy());
                    ui.label(
                        RichText::new(format!(
                            "{}{}",
                            title,
                            if self.doc.modified { " •" } else { "" }
                        ))
                        .color(MUTED),
                    );
                    ui.label(
                        RichText::new(format!("{} words", self.reading.ends.len())).color(MUTED),
                    );
                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        ui.label(
                            RichText::new("LOCAL FIRST   /   OFFLINE VOICE")
                                .size(11.)
                                .color(MUTED),
                        );
                    });
                });
            });
        egui::TopBottomPanel::bottom("transport")
            .frame(egui::Frame::new().fill(BG).inner_margin(14))
            .show(ctx, |ui| {
                ui.horizontal_wrapped(|ui| {
                    if ui
                        .add(
                            egui::Button::new(
                                RichText::new(if self.playback.running {
                                    "Pause"
                                } else {
                                    "Start"
                                })
                                .strong()
                                .color(BG),
                            )
                            .fill(ACCENT)
                            .min_size(Vec2::new(88., 36.)),
                        )
                        .clicked()
                    {
                        self.toggle();
                    }
                    if ui.button("Reset").clicked() {
                        self.reading.pace=crate::reading::Pace::default();
                        self.playback = Playback::default();
                        self.reanchor();
                    }
                    if ui.button("Previous cue").clicked() {
                        self.marker(false);
                    }
                    if ui.button("Next cue").clicked() {
                        self.marker(true);
                    }
                    let old = self.voice_mode;
                    ui.selectable_value(&mut self.voice_mode, false, "Timed");
                    ui.selectable_value(&mut self.voice_mode, true, "Voice follow");
                    if old != self.voice_mode {
                        self.reading.pace=crate::reading::Pace::default();
                        self.stop_voice();
                        self.reanchor();
                    }
                    let secs = self.playback.elapsed as u64;
                    ui.label(
                        RichText::new(format!("{:02}:{:02}", secs / 60, secs % 60))
                            .monospace()
                            .size(20.),
                    );
                    ui.label(if self.voice_mode {
                        self.voice_state.clone()
                    } else {
                        format!("{:.0} px/s", self.doc.settings.speed)
                    });
                });
                ui.horizontal_wrapped(|ui|{
                    let character=if self.voice_mode{self.reading.spoken_character}else{self.guide_character()};
                    let remaining=self.reading.remaining(character);
                    let pace=self.reading.pace.wpm.map_or("WPM: measuring…".into(),|wpm|format!("{wpm:.0} WPM"));
                    ui.label(pace).on_hover_text("Recent original-script word progress over up to 20 seconds of active playback. Voice mode uses accepted speech, not reading lead. Pauses and manual seeks are excluded.");
                    let (seconds,planning)=if self.voice_mode {crate::reading::voice_seconds(remaining,self.reading.pace.wpm,self.doc.planning_wpm)} else {((self.end()-self.playback.offset).max(0.)/self.doc.settings.speed+self.playback.remaining_countdown,false)};
                    if self.playback.reverse && !self.voice_mode {ui.label("Remaining: — (reverse)");}
                    else {ui.label(format!("~{} remaining{} · {remaining} words",crate::reading::duration(seconds),if planning{" (planning rate)"}else{""}));}
                    if ui.add_enabled(self.doc.library.next().is_some(),egui::Button::new("Next segment")).clicked(){self.next_segment();}
                });
                let end = self.end();
                let mut value = self.playback.offset;
                if ui
                    .add(
                        egui::Slider::new(&mut value, 0.0..=end.max(1.))
                            .show_value(false)
                            .text("Position"),
                    )
                    .changed()
                {
                    self.seek(value);
                }
                ui.label(RichText::new(&self.status).color(MUTED).size(11.));
            });
    }
    fn controls(&mut self, ctx: &egui::Context) {
        egui::SidePanel::right("controls").default_width(255.).min_width(235.).max_width(360.).resizable(true).show(ctx,|ui|{
            egui::ScrollArea::vertical().show(ui,|ui|{
                ui.add_space(12.);ui.heading("Make it your pace");ui.label(RichText::new("DISPLAY & DELIVERY").size(11.).color(MUTED));ui.add_space(10.);
                self.presentation_controls(ui);
                self.remote_controls(ui);
                let before=self.doc.settings.clone();
                ui.add(egui::Slider::new(&mut self.doc.settings.font_size,20..=120).text("Text size"));
                ui.add(egui::Slider::new(&mut self.doc.settings.width_percent,40..=96).text("Width %"));
                ui.checkbox(&mut self.doc.settings.mirror,"Mirror horizontally");
                ui.checkbox(&mut self.doc.settings.flip,"Flip vertically");
                ui.checkbox(&mut self.doc.settings.guide,"Reading guide");
                if !self.voice_mode {
                    ui.separator();ui.add(egui::Slider::new(&mut self.doc.settings.speed,5.0..=500.0).text("Pixels / sec"));
                    ui.add(egui::Slider::new(&mut self.doc.settings.countdown,0..=10).text("Countdown"));
                    ui.checkbox(&mut self.doc.settings.looping,"Loop script");ui.checkbox(&mut self.playback.reverse,"Reverse direction");
                }
                if before!=self.doc.settings {self.session_dirty=true;}
                ui.separator();ui.heading("Voice follow");
                ui.label(RichText::new("Speech is processed on this device.").small().color(MUTED));
                self.voice_tools(ui);
                if self.devices.is_empty() && ui.button("Find microphones").clicked(){self.devices=voice::devices();}
                let old_device=self.doc.follow.device.clone();
                egui::ComboBox::from_label("Input").selected_text(if self.doc.follow.device.is_empty(){"System default"}else{&self.doc.follow.device}).width(180.).show_ui(ui,|ui|{
                    ui.selectable_value(&mut self.doc.follow.device,String::new(),"System default");
                    for name in &self.devices {ui.selectable_value(&mut self.doc.follow.device,name.clone(),name);}
                });
                if old_device!=self.doc.follow.device {self.stop_voice();self.session_dirty=true;}
                let mut changed=false;
                changed|=ui.add(egui::Slider::new(&mut self.doc.follow.confidence,0.4..=0.95).text("Match threshold")).on_hover_text("Higher values require more of the recognized phrase to match. Lower values tolerate more errors.").changed();
                changed|=ui.add(egui::Slider::new(&mut self.doc.follow.lead_words,0..=20).text("Lead words")).changed();
                changed|=ui.add(egui::Slider::new(&mut self.doc.follow.look_ahead,12..=150).text("Look ahead")).changed();
                changed|=ui.add(egui::Slider::new(&mut self.doc.follow.smoothing,0.05..=1.5).text("Smoothing sec")).changed();
                changed|=ui.add(egui::Slider::new(&mut self.doc.follow.silence_ms,200..=3000).text("Silence ms")).changed();
                changed|=ui.add(egui::Slider::new(&mut self.doc.follow.gain,0.1..=5.0).text("Mic gain")).changed();
                changed|=ui.add(egui::Slider::new(&mut self.doc.follow.noise_gate,0.0..=0.1).fixed_decimals(3).text("Noise floor")).changed();
                changed|=ui.checkbox(&mut self.doc.follow.allow_backtrack,"Allow confident backtracking").changed();
                ui.collapsing("Pronunciation aliases", |ui| {
                    ui.label("One per line: written phrase = spoken phrase");
                    ui.label("Example: Siobhan = shiv on");
                    if ui.add(egui::TextEdit::multiline(&mut self.doc.aliases).desired_rows(4)).changed() {
                        self.follower = Follower::with_aliases(&self.doc.script, &self.doc.aliases);
                        self.reanchor();
                        self.session_dirty = true;
                    }
                });
                self.session_dirty|=changed;
                let level=self.voice.as_ref().map_or(0.,|v|f32::from_bits(v.shared.level.load(Ordering::Relaxed)));
                ui.add(egui::ProgressBar::new((level*5.).min(1.)).text(format!("Microphone {:.0}%",level*100.)));
                ui.label(format!("Match confidence: {:.0}%",self.confidence*100.));
                if let Some(v)=&self.voice {let n=v.shared.dropped.load(Ordering::Relaxed);if n>0 {ui.colored_label(Color32::YELLOW,format!("Audio overload: {n} dropped buffers"));}}
                if self.voice.is_some() {if ui.button("Turn microphone off").clicked(){self.stop_voice();}}
                else if ui.button("Enable microphone").clicked(){self.voice_mode=true;self.start_voice();}
                ui.label(RichText::new(&self.voice_state).color(ACCENT));
                if !self.transcript.is_empty(){ui.label(RichText::new(&self.transcript).italics().color(MUTED));}
                if !voice::library_path(&self.root).exists() || !self.root.join("voice/model/conf").exists(){ui.colored_label(Color32::YELLOW,"Voice assets missing. Run scripts/setup-voice.py for this platform.");}
            });
        });
    }
    fn refresh_screens(&mut self) {
        match crate::presentation::screens() {
            Ok(screens) => {
                self.screens = screens;
                self.screen_error = None;
            }
            Err(error) => {
                self.screens.clear();
                self.screen_error = Some(error);
            }
        }
        if let Some(name) = &self.doc.appearance.output_screen {
            if !self.screens.iter().any(|s| &s.name == name) && self.screen_error.is_none() {
                self.status =
                    "Preferred output screen is unavailable; using the primary screen.".into();
            }
        }
    }
    fn presentation_controls(&mut self, ui: &mut egui::Ui) {
        ui.collapsing("Appearance and presentation presets", |ui| {
            let before = self.doc.appearance.clone();
            egui::ComboBox::from_label("Font")
                .selected_text(self.doc.appearance.font.label())
                .show_ui(ui, |ui| {
                    for font in [ScriptFont::Sans, ScriptFont::Bold, ScriptFont::Monospace] {
                        ui.selectable_value(&mut self.doc.appearance.font, font, font.label());
                    }
                });
            ui.add(
                egui::Slider::new(&mut self.doc.appearance.line_spacing, 1.0..=2.5)
                    .text("Line spacing"),
            );
            ui.add(
                egui::Slider::new(&mut self.doc.appearance.guide_position, 0.1..=0.8)
                    .text("Guide position"),
            );
            ui.horizontal(|ui| {
                ui.label("Text");
                ui.color_edit_button_srgb(&mut self.doc.appearance.text);
            });
            ui.horizontal(|ui| {
                ui.label("Background");
                ui.color_edit_button_srgb(&mut self.doc.appearance.background);
            });
            ui.horizontal(|ui| {
                ui.label("Guide");
                ui.color_edit_button_srgb(&mut self.doc.appearance.guide_color);
            });
            if ui.button("Refresh screens").clicked() {
                self.refresh_screens();
            }
            let selected = self.doc.appearance.output_screen.as_ref().map_or(
                "Manual placement".into(),
                |name| {
                    self.screens
                        .iter()
                        .find(|s| &s.name == name)
                        .map_or(format!("{name} (unavailable)"), |s| s.label.clone())
                },
            );
            egui::ComboBox::from_label("Output screen")
                .width(150.)
                .truncate()
                .selected_text(selected)
                .show_ui(ui, |ui| {
                    ui.selectable_value(
                        &mut self.doc.appearance.output_screen,
                        None,
                        "Manual placement",
                    );
                    for screen in &self.screens {
                        ui.selectable_value(
                            &mut self.doc.appearance.output_screen,
                            Some(screen.name.clone()),
                            &screen.label,
                        );
                    }
                });
            if let Some(error) = &self.screen_error {
                ui.label(error);
            }
            if ui
                .add_enabled(
                    self.doc.appearance.output_screen.is_some() && !self.screens.is_empty(),
                    egui::Button::new("Open / move output to screen"),
                )
                .clicked()
            {
                self.output = true;
                self.output_placement_frames = 3;
            }
            if before != self.doc.appearance {
                self.session_dirty = true;
            }
            ui.separator();
            let mut load = None;
            let mut remove = None;
            for (index, preset) in self.doc.presentation_presets.iter().enumerate() {
                ui.horizontal(|ui| {
                    if ui.button(&preset.name).clicked() {
                        load = Some(index);
                    }
                    if ui.small_button("Delete").clicked() {
                        remove = Some(index);
                    }
                });
            }
            if let Some(index) = load {
                let preset = self.doc.presentation_presets[index].clone();
                preset.apply(&mut self.doc.appearance, &mut self.doc.settings);
                self.presentation_name = preset.name;
                self.playback.running = false;
                self.playback.remaining_countdown = 0.;
                self.reanchor();
                self.refresh_screens();
                if self.output && self.doc.appearance.output_screen.is_some() {
                    self.output_placement_frames = 3;
                }
                self.session_dirty = true;
            }
            if let Some(index) = remove {
                self.doc.presentation_presets.remove(index);
                self.session_dirty = true;
            }
            ui.add(
                egui::TextEdit::singleline(&mut self.presentation_name)
                    .hint_text("Presentation name"),
            );
            if ui
                .add_enabled(
                    !self.presentation_name.trim().is_empty(),
                    egui::Button::new("Save / replace presentation"),
                )
                .clicked()
            {
                let name = self
                    .presentation_name
                    .trim()
                    .chars()
                    .take(80)
                    .collect::<String>();
                let preset = PresentationPreset::capture(
                    name.clone(),
                    &self.doc.appearance,
                    &self.doc.settings,
                );
                if let Some(old) = self
                    .doc
                    .presentation_presets
                    .iter_mut()
                    .find(|p| p.name == name)
                {
                    *old = preset;
                } else {
                    self.doc.presentation_presets.push(preset);
                }
                self.session_dirty = true;
                self.status = format!("Saved presentation: {name}");
            }
            ui.label("Includes text size, width, guide, mirror and flip. Loading pauses playback.");
        });
    }
    fn remote_controls(&mut self, ui: &mut egui::Ui) {
        ui.collapsing("Remote controls and shortcuts",|ui| {
            ui.label("Keyboard-style clickers and pedals. Click a binding, then press the device key. Escape cancels. Use the preview or output window for playback; typing stays protected.");
            for action in Action::ALL {
                ui.label(action.label());
                for slot in 0..2 {
                    let label=self.doc.remotes.bindings.iter().find(|b|b.action==action && b.slot==slot).map_or("Unassigned".into(),|b|b.chord.label());
                    ui.horizontal(|ui| {
                        if ui.button(if self.learning==Some((action,slot)){"Press a key…".into()}else{label}).clicked() {
                            self.playback.running=false;self.playback.remaining_countdown=0.;self.learning=Some((action,slot));
                        }
                        if ui.small_button("Clear").clicked() {self.doc.remotes.bindings.retain(|b|b.action!=action || b.slot!=slot);self.learning=None;self.session_dirty=true;}
                    });
                }
            }
            if self.learning.is_some() && ui.button("Cancel recording").clicked(){self.learning=None;}
            if ui.button("Restore default shortcuts").clicked(){self.doc.remotes=RemoteMap::default();self.learning=None;self.session_dirty=true;}
            ui.label("Escape, F11, Open and Save are reserved. Hold/repeat events are ignored. Controls work while either application window has focus.");
        });
    }
    fn save_preset(&mut self) {
        let name = self.preset_name.trim().chars().take(80).collect::<String>();
        if name.is_empty() {
            return;
        }
        let preset = Preset {
            name: name.clone(),
            settings: self.doc.follow.clone(),
        };
        if let Some(old) = self.doc.presets.iter_mut().find(|p| p.name == name) {
            *old = preset;
        } else {
            self.doc.presets.push(preset);
        }
        self.session_dirty = true;
        self.status = format!("Saved presenter preset: {name}");
        self.persist();
    }
    fn voice_tools(&mut self, ui: &mut egui::Ui) {
        if ui.button("Calibrate voice...").clicked() {
            self.stop_voice();
            self.calibration = Some(Calibration::default());
        }
        ui.collapsing("Presenter presets", |ui| {
            let mut load = None;
            let mut remove = None;
            for (index, p) in self.doc.presets.iter().enumerate() {
                ui.push_id(index, |ui| {
                    ui.horizontal(|ui| {
                        if ui
                            .button(&p.name)
                            .on_hover_text("Load these voice settings; playback will pause")
                            .clicked()
                        {
                            load = Some(index);
                        }
                        if ui.small_button("Delete").clicked() {
                            remove = Some(index);
                        }
                    });
                });
            }
            if let Some(index) = load {
                self.stop_voice();
                self.doc.follow = self.doc.presets[index].settings.clone();
                self.preset_name = self.doc.presets[index].name.clone();
                self.reanchor();
                self.session_dirty = true;
                self.status = format!("Loaded presenter: {}", self.preset_name);
            }
            if let Some(index) = remove {
                self.doc.presets.remove(index);
                self.session_dirty = true;
            }
            ui.label("Presenter name");
            ui.text_edit_singleline(&mut self.preset_name);
            if ui
                .add_enabled(
                    !self.preset_name.trim().is_empty(),
                    egui::Button::new("Save / replace current preset"),
                )
                .clicked()
            {
                self.save_preset();
            }
        });
        if let Some(range) = &self.matched_range {
            let phrase: String = self
                .doc
                .script
                .chars()
                .skip(range.start)
                .take(range.len())
                .collect();
            ui.label(RichText::new(format!("Last matched: {phrase}")).color(ACCENT));
        }
        if ui.button("Resume from here").on_hover_text("Place the desired line at the reading guide first. Discard old recognition and wait for a fresh nearby match.").clicked() {
            self.voice_mode = true;
            self.reanchor();
            self.playback.remaining_countdown = 0.;
            self.playback.running = true;
            if self.voice.is_none() { self.start_voice(); }
            self.voice_state = "Listening - read from the guide".into();
        }
    }
    fn calibration_dialog(&mut self, ctx: &egui::Context) {
        let Some(mut c) = self.calibration.take() else {
            return;
        };
        let mut close = false;
        let mut apply = false;
        let mut save = false;
        egui::Modal::new(egui::Id::new("voice_calibration")).show(ctx, |ui| {
            ui.set_width(520.);
            ui.heading("Voice calibration");
            ui.label("Your script stays unchanged. No audio is saved.");
            ui.separator();
            match c.stage {
                Stage::Intro => {
                    ui.label("1. Stay quiet for four seconds to measure room noise.\n2. Read a short passage at your normal pace.\n3. Review suggestions, then apply or save a presenter preset.");
                    ui.label(format!("Input: {}", if self.doc.follow.device.is_empty() { "System default" } else { &self.doc.follow.device }));
                    ui.label("To change microphones, cancel and choose Input in the voice controls.");
                    if ui.button("Begin room-noise check").clicked() {
                        self.start_voice();
                        c.stage = Stage::Quiet;
                        c.started = Instant::now();
                    }
                }
                Stage::Quiet => {
                    if self.voice_ready {
                        let seconds = c.started.elapsed().as_secs_f32();
                        ui.label("Stay quiet while we measure the room.");
                        ui.add(egui::ProgressBar::new((seconds / 4.).min(1.)).text(format!("{:.0} / 4 seconds", seconds.min(4.))));
                        if ui.add_enabled(seconds >= 4. && c.quiet.len() >= 20, egui::Button::new("Continue to reading")).clicked() {
                            c.stage = Stage::Reading;
                            c.started = Instant::now();
                            if let Some(v) = &self.voice {
                                self.epoch = v.reset();
                                v.shared.raw_peak.store(0, Ordering::Relaxed);
                            }
                        }
                    } else if self.voice.is_some() { ui.label("Loading the offline model..."); }
                    else { ui.colored_label(Color32::YELLOW, "Microphone could not start. Cancel, check the error and input device, then try again."); }
                }
                Stage::Reading => {
                    ui.label("Read aloud at your normal pace. Pause naturally between sentences.");
                    ui.label(RichText::new(PASSAGE).size(21.));
                    ui.label(format!("{} advancing matches - {:.0} seconds", c.matches, c.started.elapsed().as_secs_f32()));
                    if !c.heard.is_empty() { ui.label(format!("Heard: {}", c.heard)); }
                    if !self.voice_ready { ui.colored_label(Color32::YELLOW, "Microphone stopped. Cancel and check the input device before retrying."); }
                    if ui.add_enabled(self.voice_ready, egui::Button::new("Review suggestions")).clicked() {
                        match c.recommend(&self.doc.follow) {
                            Ok(()) => self.stop_voice(),
                            Err(message) => c.message = message,
                        }
                    }
                }
                Stage::Review => {
                    ui.label("Suggested settings - adjust these before applying if needed.");
                    if let Some(s) = &mut c.suggestion {
                        ui.add(egui::Slider::new(&mut s.gain, 0.1..=5.).text("Mic gain"));
                        ui.add(egui::Slider::new(&mut s.noise_gate, 0.0..=0.1).fixed_decimals(3).text("Noise floor"));
                        ui.add(egui::Slider::new(&mut s.lead_words, 0..=20).text("Lead words"));
                        ui.add(egui::Slider::new(&mut s.smoothing, 0.05..=1.5).text("Smoothing sec"));
                    }
                    ui.label("Presenter name (optional)");
                    ui.text_edit_singleline(&mut self.preset_name);
                    if ui.button("Apply settings").clicked() { apply = true; }
                    if ui.add_enabled(!self.preset_name.trim().is_empty(), egui::Button::new("Apply and save / replace preset")).clicked() { apply = true; save = true; }
                }
            }
            if !c.message.is_empty() { ui.label(&c.message); }
            if self.voice_ready {
                let level = self.voice.as_ref().map_or(0., |v| f32::from_bits(v.shared.raw_level.load(Ordering::Relaxed)));
                ui.add(egui::ProgressBar::new((level * 5.).min(1.)).text("Input level"));
            }
            ui.separator();
            ui.horizontal(|ui| {
                if c.stage != Stage::Intro && ui.button("Start again").clicked() {
                    self.stop_voice(); c = Calibration::default();
                }
                if ui.button("Cancel").clicked() { close = true; }
            });
        });
        if apply {
            if let Some(settings) = c.suggestion.take() {
                self.doc.follow = settings;
                self.voice_mode = true;
                self.session_dirty = true;
                if save {
                    self.save_preset();
                }
                self.status = "Calibration applied. Press Start to try your script.".into();
                self.persist();
            }
            close = true;
        }
        if close {
            self.stop_voice();
            self.reanchor();
        } else {
            self.calibration = Some(c);
        }
    }
    fn editor_panel(&mut self, ctx: &egui::Context) {
        egui::SidePanel::left("editor")
            .default_width(330.)
            .min_width(220.)
            .max_width(600.)
            .resizable(true)
            .show(ctx, |ui| {
                ui.add_space(12.);
                ui.heading("Your script");
                ui.label(
                    RichText::new("Drop a text or .docx file here, or start writing.")
                        .small()
                        .color(MUTED),
                );
                ui.horizontal(|ui| {
                    ui.add(
                        egui::TextEdit::singleline(&mut self.search)
                            .hint_text("Find in script")
                            .desired_width(155.),
                    );
                    if ui.button("Find").clicked() && !self.search.is_empty() {
                        if let Some(index) = self.doc.script.find(&self.search) {
                            let character = self.doc.script[..index].chars().count();
                            if let Some(l) = &self.layout {
                                self.seek(
                                    l.original
                                        .pos_from_cursor(egui::text::CCursor::new(character))
                                        .top() as f64,
                                );
                            }
                        } else {
                            self.status = "No matching text found".into();
                        }
                    }
                });
                ui.separator();
                egui::ScrollArea::vertical()
                    .id_salt("script_scroll")
                    .show(ui, |ui| {
                        if !self.doc.emphasis.is_empty()
                            && ui
                                .checkbox(
                                    &mut self.doc.show_emphasis,
                                    "Show imported emphasis in preview / output",
                                )
                                .changed()
                        {
                            self.revision += 1;
                            self.session_dirty = true;
                        }
                        let previous_text =
                            if self.doc.emphasis.is_empty() && self.doc.bookmarks.is_empty() {
                                None
                            } else {
                                Some(self.doc.script.clone())
                            };
                        let response = ui.add(
                            egui::TextEdit::multiline(&mut self.doc.script)
                                .font(FontId::proportional(17.))
                                .desired_width(f32::INFINITY)
                                .desired_rows(30)
                                .frame(false),
                        );
                        if response.changed() {
                            if let Some(old) = previous_text {
                                crate::library::adjust(
                                    &mut self.doc.bookmarks,
                                    &old,
                                    &self.doc.script,
                                );
                                crate::word::adjust(&mut self.doc.emphasis, &old, &self.doc.script);
                            }
                            self.changed();
                        }
                    });
            });
    }
    fn canvas(&mut self, ui: &mut egui::Ui, output: bool) {
        let rect = ui.max_rect();
        let width = (rect.width() * self.doc.settings.width_percent as f32 / 100.).max(80.);
        let cache = if output {
            &mut self.output_layout
        } else {
            &mut self.layout
        };
        let key = (
            self.revision,
            width.to_bits(),
            self.doc.settings.font_size,
            self.doc.settings.mirror,
            self.doc.settings.flip,
            ui.ctx().pixels_per_point().to_bits(),
        );
        if cache
            .as_ref()
            .is_none_or(|l| l.key != key || l.appearance != self.doc.appearance)
        {
            let old_position = cache
                .as_ref()
                .filter(|l| l.key.0 == self.revision)
                .map(|l| {
                    let cursor = l
                        .original
                        .cursor_from_pos(Vec2::new(0., self.playback.offset as f32 + 1.));
                    let row = l.original.pos_from_cursor(cursor);
                    (
                        cursor,
                        (self.playback.offset as f32 - row.top()) / row.height().max(1.),
                    )
                });
            let job = script_layout(
                &self.doc.script,
                &self.doc.emphasis,
                self.doc.show_emphasis,
                self.doc.settings.font_size as f32,
                width,
                &self.doc.appearance,
            );
            let original = ui.fonts_mut(|f| f.layout_job(job));
            if !output {
                if let Some((cursor, fraction)) = old_position {
                    let row = original.pos_from_cursor(cursor);
                    self.playback.offset = (row.top() + fraction * row.height()).max(0.) as f64;
                    self.voice_target = self.playback.offset;
                }
            }
            let displayed =
                reflect_galley(&original, self.doc.settings.mirror, self.doc.settings.flip);
            *cache = Some(Layout {
                appearance: self.doc.appearance.clone(),
                key,
                original,
                displayed,
            });
        }
        let l = if output {
            self.output_layout.as_ref().unwrap()
        } else {
            self.layout.as_ref().unwrap()
        };
        let mut offset = self.playback.offset as f32;
        if output {
            if let Some(main) = &self.layout {
                let c = main.original.cursor_from_pos(Vec2::new(0., offset + 1.));
                let row = main.original.pos_from_cursor(c).top();
                offset = l.original.pos_from_cursor(c).top() + (offset - row);
            }
        }
        let painter = ui.painter_at(rect);
        painter.rect_filled(
            rect,
            0.,
            Color32::from_rgb(
                self.doc.appearance.background[0],
                self.doc.appearance.background[1],
                self.doc.appearance.background[2],
            ),
        );
        let guide = rect.top() + rect.height() * self.doc.appearance.guide_position;
        let x = rect.center().x - l.original.size().x / 2.;
        let y = if self.doc.settings.flip {
            rect.bottom() - (guide - rect.top()) - l.original.size().y + offset
        } else {
            guide - offset
        };
        if self.voice_mode {
            if let Some(range) = &self.matched_range {
                for i in range.clone() {
                    let a = l.original.pos_from_cursor(egui::text::CCursor::new(i));
                    let b = l.original.pos_from_cursor(egui::text::CCursor::new(i + 1));
                    if (a.top() - b.top()).abs() < 1. && b.left() > a.left() {
                        let mut highlight = Rect::from_min_max(
                            Pos2::new(a.left(), a.top()),
                            Pos2::new(b.left(), a.bottom()),
                        );
                        if self.doc.settings.mirror {
                            highlight = Rect::from_min_max(
                                Pos2::new(l.original.size().x - highlight.right(), highlight.top()),
                                Pos2::new(
                                    l.original.size().x - highlight.left(),
                                    highlight.bottom(),
                                ),
                            );
                        }
                        if self.doc.settings.flip {
                            highlight = Rect::from_min_max(
                                Pos2::new(
                                    highlight.left(),
                                    l.original.size().y - highlight.bottom(),
                                ),
                                Pos2::new(highlight.right(), l.original.size().y - highlight.top()),
                            );
                        }
                        painter.rect_filled(
                            highlight.translate(Vec2::new(x, y)),
                            0.,
                            Color32::from_rgba_unmultiplied(91, 224, 192, 48),
                        );
                    }
                }
            }
        }
        painter.galley(Pos2::new(x, y), l.displayed.clone(), Color32::WHITE);
        if self.doc.settings.guide {
            let gy = if self.doc.settings.flip {
                rect.bottom() - (guide - rect.top())
            } else {
                guide
            };
            let direction = if self.doc.settings.flip { -1. } else { 1. };
            painter.line_segment(
                [
                    Pos2::new(rect.left() + 12., gy),
                    Pos2::new(rect.right() - 12., gy),
                ],
                Stroke::new(
                    1_f32,
                    Color32::from_rgb(
                        self.doc.appearance.guide_color[0],
                        self.doc.appearance.guide_color[1],
                        self.doc.appearance.guide_color[2],
                    ),
                ),
            );
            let cy = gy + direction * self.doc.settings.font_size as f32 * 0.6;
            painter.add(egui::Shape::convex_polygon(
                vec![
                    Pos2::new(rect.left() + 8., cy - 8.),
                    Pos2::new(rect.left() + 20., cy),
                    Pos2::new(rect.left() + 8., cy + 8.),
                ],
                Color32::from_rgb(
                    self.doc.appearance.guide_color[0],
                    self.doc.appearance.guide_color[1],
                    self.doc.appearance.guide_color[2],
                ),
                Stroke::NONE,
            ));
        }
        if self.playback.remaining_countdown > 0. {
            painter.rect_filled(rect, 0., Color32::from_black_alpha(180));
            painter.text(
                rect.center(),
                egui::Align2::CENTER_CENTER,
                format!("{}", self.playback.remaining_countdown.ceil() as u32),
                FontId::proportional(110.),
                ACCENT,
            );
        }
        if !output && self.calibration.is_none() {
            let response = ui.interact(
                rect,
                egui::Id::new("prompt_canvas"),
                egui::Sense::click_and_drag(),
            );
            if response.clicked() {
                response.request_focus();
            }
            if response.double_clicked() {
                self.toggle();
            }
            if response.hovered() {
                let delta = ui.input(|i| i.smooth_scroll_delta.y);
                if delta != 0. {
                    self.seek(self.playback.offset - delta as f64);
                }
            }
            if response.dragged() {
                self.seek(self.playback.offset - response.drag_delta().y as f64);
            }
        }
    }
    fn next_segment(&mut self) {
        if let Some(segment) = self.doc.library.next() {
            let path = segment.path.clone();
            self.requested_segment = Some(segment.id);
            self.request_script(path);
        }
    }
    fn bookmark_metadata_changed(&mut self) {
        if let Some(path) = self.doc.source_path.clone() {
            self.doc
                .library
                .save_marks(path, &self.doc.script, &self.doc.bookmarks);
        }
        self.session_dirty = true;
    }
    fn library_window(&mut self, ctx: &egui::Context) {
        if !self.library_open || self.calibration.is_some() {
            return;
        }
        let mut open = true;
        egui::Window::new("Script library and running order").open(&mut open).default_width(610.).vscroll(true).show(ctx,|ui|{
            ui.heading("Recent files");
            let mut selected=None;let mut queued=None;
            for path in &self.doc.library.recent {
                ui.horizontal(|ui|{
                    let label=path.file_name().unwrap_or_default().to_string_lossy();
                    if ui.button(label).on_hover_text(path.display().to_string()).clicked(){selected=Some(path.clone());}
                    if ui.small_button("Queue").clicked(){queued=Some(path.clone());}
                });
            }
            if let Some(path)=queued {self.doc.library.add(path);self.session_dirty=true;}
            if let Some(path)=selected {self.request_open(path);}
            ui.separator();ui.heading("Running order");
            ui.label("Scripts load from disk and start paused. Save edits before switching. Queue order is saved automatically.");
            ui.horizontal(|ui|{
                if ui.button("Add files…").clicked(){self.file_dialog(FileAction::QueueAdd);}
                if ui.add_enabled(self.doc.source_path.is_some(),egui::Button::new("Add source file")).clicked(){if let Some(path)=self.doc.source_path.clone(){self.doc.library.add(path);self.session_dirty=true;}}
                if ui.add_enabled(self.doc.library.next().is_some(),egui::Button::new("Open next segment")).clicked(){self.next_segment();}
            });
            let mut load=None;let mut movement=None;let mut remove=None;
            for (index,segment) in self.doc.library.queue.iter().enumerate(){
                ui.horizontal(|ui|{
                    ui.label(format!("{}{}",index+1,if self.doc.library.active==Some(segment.id){" • current"}else{""}));
                    if ui.button(segment.path.file_name().unwrap_or_default().to_string_lossy()).on_hover_text(segment.path.display().to_string()).clicked(){load=Some((segment.id,segment.path.clone()));}
                    if ui.add_enabled(index>0,egui::Button::new("Up")).clicked(){movement=Some((index,index-1));}
                    if ui.add_enabled(index+1<self.doc.library.queue.len(),egui::Button::new("Down")).clicked(){movement=Some((index,index+1));}
                    if ui.small_button("Remove").clicked(){remove=Some(segment.id);}
                });
            }
            if let Some((a,b))=movement{self.doc.library.queue.swap(a,b);self.session_dirty=true;}
            if let Some(id)=remove{self.doc.library.remove_segment(id);self.session_dirty=true;}
            if let Some((id,path))=load{self.requested_segment=Some(id);self.request_script(path);}
            ui.separator();ui.heading("Bookmarks in this script");
            ui.label("Capture the reading-guide position. Names can be edited; bookmarks follow edits made here. Externally changed files require new bookmarks.");
            ui.horizontal(|ui|{
                ui.add(egui::TextEdit::singleline(&mut self.bookmark_name).hint_text("Bookmark name"));
                if ui.add_enabled(!self.bookmark_name.trim().is_empty(),egui::Button::new("Save / replace bookmark")).clicked(){
                    let name=self.bookmark_name.trim().chars().take(80).collect::<String>();let character=self.guide_character();
                    if let Some(mark)=self.doc.bookmarks.iter_mut().find(|m|m.name==name){mark.character=character;}else{self.doc.bookmarks.push(crate::library::Bookmark{name,character});}
                    self.bookmark_metadata_changed();
                }
            });
            let mut jump=None;let mut remove=None;let mut renamed=false;
            for (index,mark) in self.doc.bookmarks.iter_mut().enumerate(){
                ui.horizontal(|ui|{
                    renamed|=ui.add(egui::TextEdit::singleline(&mut mark.name).char_limit(80)).changed();
                    if ui.button("Go").clicked(){jump=Some(mark.character);}
                    if ui.button("Remove").clicked(){remove=Some(index);}
                });
            }
            if let Some(index)=remove{self.doc.bookmarks.remove(index);renamed=true;}
            if renamed{self.bookmark_metadata_changed();}
            if let Some(character)=jump{if let Some(l)=&self.layout{let pos=l.original.pos_from_cursor(egui::text::CCursor::new(character.min(self.doc.script.chars().count()))).top();self.playback.running=false;self.seek(pos as f64);}}
            ui.separator();
            if ui.add(egui::Slider::new(&mut self.doc.planning_wpm,40.0..=400.0).text("Planning WPM")).changed(){self.session_dirty=true;}
            ui.label("Voice remaining time uses this planning rate until recent speech progress provides a usable pace. Timed mode uses scroll speed and layout.");
        });
        self.library_open = open;
    }
    fn dialogs(&mut self, ctx: &egui::Context) {
        if self.pending_open.is_some() {
            egui::Window::new("Keep your current edits?")
                .collapsible(false)
                .anchor(egui::Align2::CENTER_CENTER, Vec2::ZERO)
                .show(ctx, |ui| {
                    ui.label("Opening another script will replace unsaved edits.");
                    ui.horizontal(|ui| {
                        if ui.button("Save first").clicked() {
                            self.open_after_save = self.pending_open.take();
                            self.file_dialog(FileAction::Save);
                        }
                        if ui.button("Discard and open").clicked() {
                            let p = self.pending_open.take().unwrap();
                            self.open(p);
                        }
                        if ui.button("Cancel").clicked() {
                            self.pending_open = None;
                            self.requested_segment = None;
                        }
                    });
                });
        }
        if self.confirm_close {
            egui::Window::new("Recovery save failed").collapsible(false).anchor(egui::Align2::CENTER_CENTER,Vec2::ZERO).show(ctx,|ui|{
                ui.label("Your latest changes could not be saved. Keep the app open to save them elsewhere.");
                if ui.button("Keep working").clicked(){self.confirm_close=false;}
                if ui.button("Close without recovery").clicked(){self.allow_close=true;ctx.send_viewport_cmd(egui::ViewportCommand::Close);}
            });
        }
        if let Some(error) = self.error.clone() {
            egui::Window::new("Something needs attention")
                .collapsible(false)
                .anchor(egui::Align2::CENTER_CENTER, Vec2::ZERO)
                .show(ctx, |ui| {
                    ui.set_max_width(520.);
                    ui.label(error);
                    if ui.button("OK").clicked() {
                        self.error = None;
                    }
                });
        }
        if self.help {
            egui::Window::new("A quieter way to prompt").open(&mut self.help).show(ctx,|ui|{
                ui.label("Default bindings (customise in Controls):\nSpace: start / pause     Esc: pause and leave fullscreen\nUp / Down: timed speed     Left / Right: seek\nHome / End: script start / end     M: horizontal mirror     F: vertical flip / opposite screen motion\nPage Up / Down: # cue markers     F11: fullscreen\nCtrl or Cmd + O: open     Ctrl or Cmd + S: save\nCtrl or Cmd + Shift + S: save as\n\nClick the prompt preview before using playback shortcuts.\nDouble-click it to start or pause. Scroll or drag to reposition.\n\nVoice: select Voice follow, then Start. Read the script aloud.\nThe prompt holds on silence or unrelated speech. Reposition\nmanually if you skip beyond the look-ahead window.\n\nPresentation presets save appearance and preferred output screen.\nRemote controls: configure keys in Controls; Escape always pauses.\nOutput window: F11 makes it fullscreen.\nAll settings and recovery text live in the application's data folder.");
            });
        }
    }
}

impl eframe::App for Prompter {
    fn update(&mut self, ctx: &egui::Context, frame: &mut eframe::Frame) {
        let output_was_open = self.output;
        let now = Instant::now();
        let dt = now.duration_since(self.last_frame);
        self.last_frame = now;
        self.poll_voice();
        self.shortcuts(ctx);
        self.can_follow = false;
        if self.voice_ready && self.calibration.is_none() {
            if self.playback.running && self.voice_mode {
                let silent =
                    self.last_speech.elapsed().as_millis() >= self.doc.follow.silence_ms as u128;
                let state = self.tracking.tick(dt.as_secs_f32(), self.audible, silent);
                self.can_follow = state == State::Following;
                self.voice_state = match state {
                    State::Silence => "Holding · silence",
                    State::Lost => "Tracking lost · reposition, then Resume from here",
                    State::Searching => "Holding · speech does not match the nearby script",
                    State::Listening => "Listening · waiting for a script match",
                    State::Following => "Following your voice",
                }
                .into();
            } else {
                self.voice_state = "Paused · microphone is on".into();
            }
        }
        if self.voice_mode {
            if self.playback.running {
                self.playback.elapsed += dt.as_secs_f64().min(0.1);
                if self.can_follow && self.confidence > 0. {
                    let alpha =
                        1. - (-dt.as_secs_f64().min(0.1) / self.doc.follow.smoothing as f64).exp();
                    self.playback.offset += (self.voice_target - self.playback.offset) * alpha;
                }
            }
        } else {
            self.playback.tick(
                dt,
                self.doc.settings.speed,
                self.end(),
                self.doc.settings.looping,
            );
        }
        let character = if self.voice_mode {
            self.reading.spoken_character
        } else {
            self.guide_character()
        };
        let words = self.reading.read_words(character);
        self.reading.pace.tick(
            dt.as_secs_f64(),
            words,
            self.playback.running
                && self.playback.remaining_countdown <= 0.
                && self.calibration.is_none()
                && (!self.playback.reverse || self.voice_mode),
        );
        for file in ctx.input(|i| i.raw.dropped_files.clone()) {
            if self.calibration.is_some() {
                break;
            }
            if let Some(path) = file.path {
                self.request_open(path);
                break;
            }
        }
        if !self.fullscreen {
            self.toolbar(ctx);
            if self.settings_open {
                self.controls(ctx);
            }
            if self.editor {
                self.editor_panel(ctx);
            }
        }
        egui::CentralPanel::default()
            .frame(egui::Frame::NONE)
            .show(ctx, |ui| self.canvas(ui, false));
        if self.output && !output_was_open {
            self.refresh_screens();
            if self.doc.appearance.output_screen.is_some() {
                self.output_placement_frames = 3;
            }
        }
        if self.output {
            ctx.show_viewport_immediate(
                egui::ViewportId::from_hash_of("output"),
                egui::ViewportBuilder::default()
                    .with_title("Technobabble — Output")
                    .with_inner_size([960., 640.]),
                |ctx, _class| {
                    if ctx.input(|i| i.viewport().close_requested()) {
                        self.output = false;
                    }
                    if ctx.input(|i| i.key_pressed(Key::F11)) {
                        let full = ctx.input(|i| i.viewport().fullscreen.unwrap_or(false));
                        ctx.send_viewport_cmd(egui::ViewportCommand::Fullscreen(!full));
                    }
                    if ctx.input(|i| i.key_pressed(Key::Escape)) {
                        self.playback.running = false;
                        self.reanchor();
                        ctx.send_viewport_cmd(egui::ViewportCommand::Fullscreen(false));
                    }
                    if self.output_placement_frames > 0 {
                        if let Some(screen) = crate::presentation::select_screen(
                            &self.screens,
                            self.doc.appearance.output_screen.as_deref(),
                        ) {
                            let units = if cfg!(target_os = "macos") {
                                ctx.native_pixels_per_point().unwrap_or(1.)
                            } else {
                                1.
                            };
                            let scale = units / ctx.pixels_per_point();
                            ctx.send_viewport_cmd(egui::ViewportCommand::Fullscreen(false));
                            ctx.send_viewport_cmd(egui::ViewportCommand::OuterPosition(Pos2::new(
                                (screen.x + 30.) * scale,
                                (screen.y + 40.) * scale,
                            )));
                            ctx.send_viewport_cmd(egui::ViewportCommand::InnerSize(Vec2::new(
                                (screen.width - 80.).clamp(100., 960.) * scale,
                                (screen.height - 100.).clamp(100., 640.) * scale,
                            )));
                        }
                        self.output_placement_frames -= 1;
                        ctx.request_repaint_of(egui::ViewportId::ROOT);
                    }
                    self.remote_actions(ctx);
                    egui::CentralPanel::default()
                        .frame(egui::Frame::NONE)
                        .show(ctx, |ui| self.canvas(ui, true));
                },
            );
        }
        self.library_window(ctx);
        self.dialogs(ctx);
        self.calibration_dialog(ctx);
        if self.file_action.is_some() {
            self.native_file_dialog(frame);
            ctx.request_repaint();
        }
        if self.session_dirty && self.last_save.elapsed() > Duration::from_secs(2) {
            self.persist();
        }
        if ctx.input(|i| i.viewport().close_requested()) && !self.allow_close && !self.persist() {
            ctx.send_viewport_cmd(egui::ViewportCommand::CancelClose);
            self.confirm_close = true;
        }
        if self.playback.running {
            ctx.request_repaint_after(Duration::from_millis(16));
        } else if self.voice.is_some() {
            ctx.request_repaint_after(Duration::from_millis(50));
        } else if self.session_dirty {
            ctx.request_repaint_after(Duration::from_secs(2));
        }
    }
    fn on_exit(&mut self, _gl: Option<&eframe::glow::Context>) {
        self.voice = None;
    }
}

/// Reflect glyph geometry once per layout, preserving deferred font-atlas UV
/// normalization and epaint's row culling. No per-frame script tessellation.
fn reflect_galley(original: &Arc<egui::Galley>, mirror: bool, flip: bool) -> Arc<egui::Galley> {
    if !mirror && !flip {
        return original.clone();
    }
    let mut galley = (**original).clone();
    let width = galley.size().x;
    let height = galley.size().y;
    for placed in &mut galley.rows {
        let row = Arc::make_mut(&mut placed.row);
        if mirror {
            placed.pos.x = width - placed.pos.x - row.size.x;
        }
        if flip {
            placed.pos.y = height - placed.pos.y - row.size.y;
        }
        for vertex in &mut row.visuals.mesh.vertices {
            if mirror {
                vertex.pos.x = row.size.x - vertex.pos.x;
            }
            if flip {
                vertex.pos.y = row.size.y - vertex.pos.y;
            }
        }
        let old = row.visuals.mesh_bounds;
        row.visuals.mesh_bounds = Rect::from_min_max(
            Pos2::new(
                if mirror {
                    row.size.x - old.max.x
                } else {
                    old.min.x
                },
                if flip {
                    row.size.y - old.max.y
                } else {
                    old.min.y
                },
            ),
            Pos2::new(
                if mirror {
                    row.size.x - old.min.x
                } else {
                    old.max.x
                },
                if flip {
                    row.size.y - old.min.y
                } else {
                    old.max.y
                },
            ),
        );
        if mirror ^ flip {
            for tri in row.visuals.mesh.indices.as_chunks_mut::<3>().0 {
                tri.swap(1, 2);
            }
        }
    }
    Arc::new(galley)
}

/// Split only at emphasis boundaries; offsets in imported data are Unicode characters.
fn script_layout(
    text: &str,
    spans: &[crate::word::Emphasis],
    enabled: bool,
    size: f32,
    width: f32,
    appearance: &Appearance,
) -> egui::text::LayoutJob {
    let mut job = egui::text::LayoutJob::default();
    job.wrap.max_width = width;
    let offsets: Vec<usize> = text
        .char_indices()
        .map(|(i, _)| i)
        .chain(std::iter::once(text.len()))
        .collect();
    let len = offsets.len() - 1;
    let mut boundaries = vec![0, len];
    let mut styles: Vec<_> = spans
        .iter()
        .filter(|s| enabled && s.start < s.end && s.end <= len)
        .collect();
    styles.sort_unstable_by_key(|s| s.end);
    if enabled {
        for s in &styles {
            boundaries.extend([s.start, s.end]);
        }
    }
    boundaries.sort_unstable();
    boundaries.dedup();
    for pair in boundaries.windows(2) {
        let style = styles
            .get(styles.partition_point(|s| s.end <= pair[0]))
            .filter(|s| s.start <= pair[0] && s.end >= pair[1]);
        let bold = style.is_some_and(|s| s.bold);
        let color = Color32::from_rgb(appearance.text[0], appearance.text[1], appearance.text[2]);
        let format = egui::TextFormat {
            font_id: FontId::new(
                size,
                if bold {
                    egui::FontFamily::Name("script-bold".into())
                } else {
                    appearance.font.family()
                },
            ),
            color,
            italics: style.is_some_and(|s| s.italic),
            underline: if style.is_some_and(|s| s.underline) {
                Stroke::new(1_f32, color)
            } else {
                Stroke::NONE
            },
            line_height: Some(size * appearance.line_spacing),
            ..Default::default()
        };
        job.append(&text[offsets[pair[0]]..offsets[pair[1]]], 0., format);
    }
    job
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn old_sessions_and_presenter_presets_roundtrip() {
        let old: Document =
            serde_json::from_str(r#"{"script":"My own words","modified":true}"#).unwrap();
        assert!(old.presets.is_empty());
        assert!(old.aliases.is_empty());
        assert!(old.emphasis.is_empty());
        assert!(old.show_emphasis);
        assert!(old.presentation_presets.is_empty());
        assert!(old.library.recent.is_empty());
        assert!(old.bookmarks.is_empty());
        assert_eq!(old.planning_wpm, 150.);
        assert_eq!(old.appearance, Appearance::default());
        assert_eq!(
            old.remotes.bindings.len(),
            RemoteMap::default().bindings.len()
        );
        assert_eq!(old.script, "My own words");
        let mut doc = old;
        doc.library.add("segment-one.txt".into());
        doc.bookmarks.push(crate::library::Bookmark {
            name: "Opening".into(),
            character: 3,
        });
        doc.aliases = "Siobhan = shiv on".into();
        doc.emphasis.push(crate::word::Emphasis {
            start: 0,
            end: 2,
            bold: true,
            ..Default::default()
        });
        doc.show_emphasis = false;
        doc.presentation_presets.push(PresentationPreset::capture(
            "Studio".into(),
            &doc.appearance,
            &doc.settings,
        ));
        doc.remotes
            .assign(Action::Pause, 1, Chord::new(Key::B, egui::Modifiers::NONE))
            .unwrap();
        doc.presets.push(Preset {
            name: "Presenter A".into(),
            settings: FollowSettings {
                gain: 2.,
                device: "USB microphone".into(),
                ..Default::default()
            },
        });
        let restored: Document =
            serde_json::from_slice(&serde_json::to_vec(&doc).unwrap()).unwrap();
        assert_eq!(restored.presets[0].settings.gain, 2.);
        assert_eq!(restored.presets[0].settings.device, "USB microphone");
        assert_eq!(restored.script, "My own words");
        assert!(restored.modified);
        assert_eq!(restored.aliases, doc.aliases);
        assert_eq!(restored.emphasis[0].end, 2);
        assert!(restored.emphasis[0].bold);
        assert!(!restored.show_emphasis);
        assert_eq!(restored.presentation_presets[0].name, "Studio");
        assert_eq!(
            restored.library.queue[0].path,
            PathBuf::from("segment-one.txt")
        );
        assert_eq!(restored.bookmarks[0].character, 3);
        assert!(restored
            .remotes
            .bindings
            .iter()
            .any(|b| b.action == Action::Pause && b.chord.key == "B"));
    }
    #[test]
    fn optional_emphasis_preserves_text_and_unicode_boundaries() {
        let spans = vec![crate::word::Emphasis {
            start: 0,
            end: 6,
            bold: true,
            italic: true,
            underline: true,
        }];
        let plain = script_layout(
            "Élodie speaks",
            &spans,
            false,
            40.,
            400.,
            &Appearance::default(),
        );
        let styled = script_layout(
            "Élodie speaks",
            &spans,
            true,
            40.,
            400.,
            &Appearance::default(),
        );
        assert_eq!(plain.text, styled.text);
        assert_eq!(styled.sections[0].byte_range, 0..7);
        assert!(styled.sections[0].format.italics);
        assert_ne!(styled.sections[0].format.underline, Stroke::NONE);
        assert_eq!(
            styled.sections[0].format.font_id.family,
            egui::FontFamily::Name("script-bold".into())
        );
        assert_eq!(plain.sections.len(), 1);
        assert!(!plain.sections[0].format.italics);
    }
    #[test]
    fn presentation_layout_uses_font_colour_and_spacing() {
        let appearance = Appearance {
            font: ScriptFont::Monospace,
            text: [1, 2, 3],
            line_spacing: 2.,
            ..Default::default()
        };
        let job = script_layout("Line one\nLine two", &[], false, 40., 400., &appearance);
        assert_eq!(
            job.sections[0].format.font_id.family,
            egui::FontFamily::Monospace
        );
        assert_eq!(job.sections[0].format.color, Color32::from_rgb(1, 2, 3));
        assert_eq!(job.sections[0].format.line_height, Some(80.));
    }
    #[test]
    fn mirrored_geometry_is_reversible_and_does_not_mutate_source() {
        let ctx = egui::Context::default();
        let _ = ctx.run(egui::RawInput::default(), |ctx| {
            let original = ctx.fonts_mut(|fonts| {
                fonts.layout_no_wrap(
                    "Hello\nworld".into(),
                    FontId::proportional(40.),
                    Color32::WHITE,
                )
            });
            let source_positions: Vec<_> = original
                .rows
                .iter()
                .flat_map(|r| r.visuals.mesh.vertices.iter().map(|v| v.pos))
                .collect();
            let reflected = reflect_galley(&original, true, true);
            let restored = reflect_galley(&reflected, true, true);
            for (a, b) in original.rows.iter().zip(&restored.rows) {
                assert!((a.pos - b.pos).length() < 0.001);
                assert_eq!(a.visuals.mesh.indices, b.visuals.mesh.indices);
                for (a, b) in a.visuals.mesh.vertices.iter().zip(&b.visuals.mesh.vertices) {
                    assert!((a.pos - b.pos).length() < 0.001);
                    assert_eq!(a.uv, b.uv);
                }
            }
            assert_eq!(
                source_positions,
                original
                    .rows
                    .iter()
                    .flat_map(|r| r.visuals.mesh.vertices.iter().map(|v| v.pos))
                    .collect::<Vec<_>>()
            );
        });
    }
}
