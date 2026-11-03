//! Microphone capture and Vosk live on a worker. Bounded queues prevent latency
//! and memory growth if recognition cannot keep up. Nothing leaves the computer.
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use libloading::Library;
use std::{
    ffi::{c_char, c_int, c_void, CStr, CString},
    path::{Path, PathBuf},
    sync::{
        atomic::{AtomicBool, AtomicU32, AtomicU64, Ordering},
        mpsc::{self, Receiver, SyncSender},
        Arc,
    },
    thread,
    time::Duration,
};

type ModelNew = unsafe extern "C" fn(*const c_char) -> *mut c_void;
type Free = unsafe extern "C" fn(*mut c_void);
type RecNew = unsafe extern "C" fn(*mut c_void, f32) -> *mut c_void;
type Accept = unsafe extern "C" fn(*mut c_void, *const i16, c_int) -> c_int;
type ResultFn = unsafe extern "C" fn(*mut c_void) -> *const c_char;

struct Engine {
    model: *mut c_void,
    recognizer: *mut c_void,
    model_free: Free,
    rec_free: Free,
    reset: Free,
    accept: Accept,
    partial: ResultFn,
    result: ResultFn,
    final_result: ResultFn,
    _library: Library,
}
impl Engine {
    fn new(library: &Path, model: &Path, rate: f32) -> Result<Self, String> {
        if !model.join("conf").is_dir() {
            return Err(format!("Speech model missing: {}", model.display()));
        }
        let path = CString::new(model.to_string_lossy().as_bytes()).map_err(|e| e.to_string())?;
        // SAFETY: load a user-selected local Vosk library; signatures match vosk_api.h.
        // Function pointers never outlive the owned library. Model and recognizer
        // remain confined to this thread, and are freed in dependency order.
        unsafe {
            #[cfg(windows)]
            let lib: Library =
                libloading::os::windows::Library::load_with_flags(library, 0x100 | 0x1000)
                    .map_err(|e| format!("Cannot load {}: {e}", library.display()))?
                    .into();
            #[cfg(not(windows))]
            let lib = Library::new(library)
                .map_err(|e| format!("Cannot load {}: {e}", library.display()))?;
            let model_new: ModelNew = *lib.get(b"vosk_model_new\0").map_err(|e| e.to_string())?;
            let model_free: Free = *lib.get(b"vosk_model_free\0").map_err(|e| e.to_string())?;
            let rec_new: RecNew = *lib
                .get(b"vosk_recognizer_new\0")
                .map_err(|e| e.to_string())?;
            let rec_free: Free = *lib
                .get(b"vosk_recognizer_free\0")
                .map_err(|e| e.to_string())?;
            let reset: Free = *lib
                .get(b"vosk_recognizer_reset\0")
                .map_err(|e| e.to_string())?;
            let accept: Accept = *lib
                .get(b"vosk_recognizer_accept_waveform_s\0")
                .map_err(|e| e.to_string())?;
            let partial: ResultFn = *lib
                .get(b"vosk_recognizer_partial_result\0")
                .map_err(|e| e.to_string())?;
            let result: ResultFn = *lib
                .get(b"vosk_recognizer_result\0")
                .map_err(|e| e.to_string())?;
            let final_result: ResultFn = *lib
                .get(b"vosk_recognizer_final_result\0")
                .map_err(|e| e.to_string())?;
            let log: unsafe extern "C" fn(c_int) = *lib
                .get(b"vosk_set_log_level\0")
                .map_err(|e| e.to_string())?;
            log(-1);
            let model = model_new(path.as_ptr());
            if model.is_null() {
                return Err("Vosk could not load this model. Check its files and language.".into());
            }
            let recognizer = rec_new(model, rate);
            if recognizer.is_null() {
                model_free(model);
                return Err("Vosk could not create a recognizer.".into());
            }
            Ok(Self {
                model,
                recognizer,
                model_free,
                rec_free,
                reset,
                accept,
                partial,
                result,
                final_result,
                _library: lib,
            })
        }
    }
    fn feed(&mut self, audio: &[i16]) -> Result<String, String> {
        // SAFETY: owned live recognizer; input slice is valid for this synchronous call.
        unsafe {
            let result = (self.accept)(self.recognizer, audio.as_ptr(), audio.len() as c_int);
            if result < 0 {
                return Err("Speech engine rejected the audio stream.".into());
            }
            let ptr = if result == 1 {
                (self.result)(self.recognizer)
            } else {
                (self.partial)(self.recognizer)
            };
            parse_result(ptr)
        }
    }
    fn reset(&mut self) {
        unsafe { (self.reset)(self.recognizer) };
    }
    fn finish(&mut self) -> Result<String, String> {
        unsafe { parse_result((self.final_result)(self.recognizer)) }
    }
}
unsafe fn parse_result(ptr: *const c_char) -> Result<String, String> {
    if ptr.is_null() {
        return Err("Speech engine returned no result.".into());
    }
    let json: serde_json::Value =
        serde_json::from_slice(CStr::from_ptr(ptr).to_bytes()).map_err(|e| e.to_string())?;
    Ok(json
        .get("text")
        .or_else(|| json.get("partial"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_owned())
}
impl Drop for Engine {
    fn drop(&mut self) {
        unsafe {
            (self.rec_free)(self.recognizer);
            (self.model_free)(self.model);
        }
    }
}

pub fn library_path(root: &Path) -> PathBuf {
    root.join("voice/runtime").join(if cfg!(windows) {
        "libvosk.dll"
    } else if cfg!(target_os = "macos") {
        "libvosk.dylib"
    } else {
        "libvosk.so"
    })
}
pub fn devices() -> Vec<String> {
    cpal::default_host()
        .input_devices()
        .map(|d| d.filter_map(|d| d.name().ok()).collect())
        .unwrap_or_default()
}
pub enum Event {
    Ready(String),
    Transcript(String, u64),
    Error(String),
}
pub struct Shared {
    stop: AtomicBool,
    epoch: AtomicU64,
    pub gain: AtomicU32,
    pub gate: AtomicU32,
    pub level: AtomicU32,
    pub raw_level: AtomicU32,
    pub raw_peak: AtomicU32,
    pub audio_ticks: AtomicU64,
    pub speech_ticks: AtomicU64,
    pub dropped: AtomicU64,
}
pub struct Session {
    pub events: Receiver<Event>,
    pub shared: Arc<Shared>,
}
impl Session {
    pub fn start(root: &Path, device: String, gain: f32, gate: f32) -> Self {
        let shared = Arc::new(Shared {
            stop: AtomicBool::new(false),
            epoch: AtomicU64::new(0),
            gain: AtomicU32::new(gain.to_bits()),
            gate: AtomicU32::new(gate.to_bits()),
            level: AtomicU32::new(0),
            raw_level: AtomicU32::new(0),
            raw_peak: AtomicU32::new(0),
            audio_ticks: AtomicU64::new(0),
            speech_ticks: AtomicU64::new(0),
            dropped: AtomicU64::new(0),
        });
        let (tx, rx) = mpsc::sync_channel(32);
        let state = shared.clone();
        let root = root.to_owned();
        thread::spawn(move || {
            if let Err(error) = capture(&root, &device, state.clone(), &tx) {
                let _ = tx.send(Event::Error(error));
            }
        });
        Self { events: rx, shared }
    }
    pub fn reset(&self) -> u64 {
        self.shared.epoch.fetch_add(1, Ordering::Relaxed) + 1
    }
}
impl Drop for Session {
    fn drop(&mut self) {
        self.shared.stop.store(true, Ordering::Relaxed);
    }
}

fn stream<T>(
    device: &cpal::Device,
    config: &cpal::StreamConfig,
    tx: SyncSender<Vec<i16>>,
    errors: SyncSender<String>,
    shared: Arc<Shared>,
) -> Result<cpal::Stream, String>
where
    T: cpal::SizedSample,
    f32: cpal::FromSample<T>,
{
    let channels = config.channels as usize;
    let chunk_size = (config.sample_rate.0 / 25).max(1) as usize;
    let mut pending = Vec::with_capacity(chunk_size);
    device
        .build_input_stream(
            config,
            move |data: &[T], _: &cpal::InputCallbackInfo| {
                let gain = f32::from_bits(shared.gain.load(Ordering::Relaxed));
                let mut power = 0.;
                let mut raw_power = 0.;
                let mut raw_peak = 0_f32;
                for frame in data.chunks_exact(channels) {
                    let value = frame
                        .iter()
                        .map(|v| <f32 as cpal::FromSample<T>>::from_sample_(*v))
                        .sum::<f32>()
                        / channels as f32;
                    let raw = if value.is_finite() { value } else { 0. };
                    raw_power += raw * raw;
                    raw_peak = raw_peak.max(raw.abs());
                    let value = raw * gain;
                    let value = if value.is_finite() {
                        value.clamp(-1., 1.)
                    } else {
                        0.
                    };
                    power += value * value;
                    pending.push((value * 32767.) as i16);
                    if pending.len() == chunk_size {
                        let pcm = std::mem::replace(&mut pending, Vec::with_capacity(chunk_size));
                        if tx.try_send(pcm).is_err() {
                            shared.dropped.fetch_add(1, Ordering::Relaxed);
                        }
                    }
                }
                let rms = (power / (data.len() / channels).max(1) as f32).sqrt();
                shared.level.store(rms.to_bits(), Ordering::Relaxed);
                shared.raw_level.store(
                    (raw_power / (data.len() / channels).max(1) as f32)
                        .sqrt()
                        .to_bits(),
                    Ordering::Relaxed,
                );
                shared
                    .raw_peak
                    .fetch_max(raw_peak.to_bits(), Ordering::Relaxed);
                shared.audio_ticks.fetch_add(1, Ordering::Relaxed);
                if rms > f32::from_bits(shared.gate.load(Ordering::Relaxed)) {
                    shared.speech_ticks.fetch_add(1, Ordering::Relaxed);
                }
            },
            move |e| {
                let _ = errors.try_send(e.to_string());
            },
            None,
        )
        .map_err(|e| e.to_string())
}
fn capture(
    root: &Path,
    name: &str,
    state: Arc<Shared>,
    events: &SyncSender<Event>,
) -> Result<(), String> {
    let host = cpal::default_host();
    let device = if name.is_empty() {
        host.default_input_device()
    } else {
        host.input_devices()
            .map_err(|e| e.to_string())?
            .find(|d| d.name().is_ok_and(|n| n == name))
    }
    .ok_or("No selected microphone is available. Check system microphone permissions.")?;
    let config = device.default_input_config().map_err(|e| e.to_string())?;
    let mut engine = Engine::new(
        &library_path(root),
        &root.join("voice/model"),
        config.sample_rate().0 as f32,
    )?;
    if state.stop.load(Ordering::Relaxed) {
        return Ok(());
    }
    let (tx, rx) = mpsc::sync_channel(16);
    let (err_tx, err_rx) = mpsc::sync_channel(2);
    let stream_config = config.config();
    let stream = match config.sample_format() {
        cpal::SampleFormat::F32 => {
            stream::<f32>(&device, &stream_config, tx, err_tx, state.clone())
        }
        cpal::SampleFormat::I16 => {
            stream::<i16>(&device, &stream_config, tx, err_tx, state.clone())
        }
        cpal::SampleFormat::U16 => {
            stream::<u16>(&device, &stream_config, tx, err_tx, state.clone())
        }
        cpal::SampleFormat::I32 => {
            stream::<i32>(&device, &stream_config, tx, err_tx, state.clone())
        }
        cpal::SampleFormat::F64 => {
            stream::<f64>(&device, &stream_config, tx, err_tx, state.clone())
        }
        other => Err(format!(
            "Microphone format {other} is unsupported. Select a 16-bit or float input."
        )),
    }?;
    stream.play().map_err(|e| e.to_string())?;
    let _ = events.try_send(Event::Ready(
        device.name().unwrap_or_else(|_| "Microphone".into()),
    ));
    let mut epoch = state.epoch.load(Ordering::Relaxed);
    let mut previous = String::new();
    while !state.stop.load(Ordering::Relaxed) {
        if let Ok(error) = err_rx.try_recv() {
            return Err(format!("Microphone disconnected: {error}"));
        }
        let next_epoch = state.epoch.load(Ordering::Relaxed);
        if next_epoch != epoch {
            engine.reset();
            previous.clear();
            epoch = next_epoch;
            while rx.try_recv().is_ok() {}
        }
        match rx.recv_timeout(Duration::from_millis(50)) {
            Ok(audio) => {
                let text = engine.feed(&audio)?;
                if text != previous {
                    previous = text.clone();
                    let _ = events.try_send(Event::Transcript(text, epoch));
                }
            }
            Err(mpsc::RecvTimeoutError::Timeout) => {}
            Err(_) => return Err("Microphone stream stopped.".into()),
        }
    }
    drop(stream);
    Ok(())
}

/// Real-engine integration check, deliberately separate from microphone capture.
pub fn smoke_test() -> Result<(), String> {
    let root = crate::storage::root();
    let bytes = std::fs::read(root.join("voice/test.wav")).map_err(|e| e.to_string())?;
    let (rate, audio) = wav_pcm(&bytes)?;
    let start = std::time::Instant::now();
    let mut engine = Engine::new(&library_path(&root), &root.join("voice/model"), rate as f32)?;
    let loaded = start.elapsed();
    let mut texts = Vec::new();
    for chunk in audio.chunks(4000) {
        let text = engine.feed(chunk)?;
        if !text.is_empty() {
            texts.push(text);
        }
    }
    texts.push(engine.finish()?);
    let joined = texts.join("\n");
    if !joined.contains("one") || !joined.contains("zero") {
        return Err(format!("Unexpected recognition: {joined}"));
    }
    let mut follower = crate::follower::Follower::new(
        "one zero zero zero one nine oh two one oh zero one eight zero three",
    );
    let settings = crate::follower::FollowSettings::default();
    let matches = texts
        .iter()
        .filter(|t| follower.accept(t, &settings).is_some())
        .count();
    if matches == 0 {
        return Err("Recognition succeeded but script following did not.".into());
    }
    let report = format!("PASS: real Vosk engine + recorded PCM + script follower\nModel load: {loaded:?}\nTotal: {:?}\nStable matches: {matches}\n{joined}\n",start.elapsed());
    crate::storage::atomic_write(&root.join("data/voice-smoke.txt"), report.as_bytes())
        .map_err(|e| e.to_string())?;
    println!("{report}");
    Ok(())
}
fn wav_pcm(bytes: &[u8]) -> Result<(u32, Vec<i16>), String> {
    if bytes.get(..4) != Some(b"RIFF") || bytes.get(8..12) != Some(b"WAVE") {
        return Err("Expected a PCM WAV fixture.".into());
    }
    let mut offset = 12;
    let mut rate = 0;
    let mut pcm = None;
    while offset + 8 <= bytes.len() {
        let size = u32::from_le_bytes(bytes[offset + 4..offset + 8].try_into().unwrap()) as usize;
        let data = bytes
            .get(offset + 8..offset + 8 + size)
            .ok_or("Truncated WAV chunk")?;
        match &bytes[offset..offset + 4] {
            b"fmt " => {
                if data.len() < 16
                    || data[0..2] != [1, 0]
                    || data[2..4] != [1, 0]
                    || data[14..16] != [16, 0]
                {
                    return Err("Fixture must be mono 16-bit PCM.".into());
                }
                rate = u32::from_le_bytes(data[4..8].try_into().unwrap());
            }
            b"data" => {
                pcm = Some(
                    data.as_chunks::<2>()
                        .0
                        .iter()
                        .map(|c| i16::from_le_bytes([c[0], c[1]]))
                        .collect(),
                )
            }
            _ => {}
        }
        offset += 8 + size + (size % 2);
    }
    if rate == 0 {
        return Err("Missing WAV format.".into());
    }
    Ok((rate, pcm.ok_or("Missing WAV audio")?))
}
