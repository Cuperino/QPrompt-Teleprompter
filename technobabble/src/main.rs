#![cfg_attr(windows, windows_subsystem = "windows")]

mod app;
mod calibration;
mod follower;
mod library;
mod model;
mod presentation;
mod reading;
mod remote;
mod speech_text;
mod storage;
mod tracking;
mod voice;
mod word;

fn main() -> eframe::Result {
    if std::env::args().any(|a| a == "--voice-smoke") {
        if let Err(error) = voice::smoke_test() {
            eprintln!("{error}");
            std::process::exit(1);
        }
        return Ok(());
    }
    let options = eframe::NativeOptions {
        viewport: eframe::egui::ViewportBuilder::default()
            .with_icon(eframe::egui::IconData {
                rgba: include_bytes!("../assets/technobabble.rgba").to_vec(),
                width: 256,
                height: 256,
            })
            .with_inner_size([1280., 820.])
            .with_min_inner_size([880., 600.]),
        ..Default::default()
    };
    eframe::run_native(
        "Technobabble",
        options,
        Box::new(|cc| Ok(Box::new(app::Prompter::new(cc)))),
    )
}
