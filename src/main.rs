// WORK_AROUND: Work around for wasm-bindgen failing on:
// error: failed to find intrinsics to enable `clone_ref` function.
#![allow(unused_imports)]
use web_sys::*;

use bevy::{prelude::*, window::Window};

mod debug;
mod dev_tools;
use comfort_3d::AppPlugin;

fn main() {
    let app: &mut App = &mut App::new();

    app.add_plugins((
        // 1. Fits canvas to parent (<body>).
        // 2. Prevents browser hotkeys from escaping.
        DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                fit_canvas_to_parent: true,
                prevent_default_event_handling: false,
                ..default()
            }),
            ..default()
        }),
        AppPlugin,
    ));

    #[cfg(feature = "dev")]
    app.add_plugins((dev_tools::DevToolsPlugin, debug::DebugPlugin));

    app.run();
}
