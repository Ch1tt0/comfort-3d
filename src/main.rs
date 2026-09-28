// WORK_AROUND: Work around for wasm-bindgen failing on:
// error: failed to find intrinsics to enable `clone_ref` function.
#![allow(unused_imports)]
use web_sys::*;

use bevy::{prelude::*, window::Window};
use comfort_3d::GamePlugin;

fn main() {
    // Rust compiler for some reason complains if I don't do this.
    let mut app_binding = App::new();

    let app = app_binding.add_plugins((
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
        GamePlugin,
    ));

    app.add_systems(Startup, scene.spawn());

    app.run();
}

fn scene() -> impl SceneList {
    bsn_list! [
        (
            #CircularBase
            Mesh3d(asset_value(Circle::new(4.0)))
            MeshMaterial3d::<StandardMaterial>(asset_value(Color::WHITE))
            Transform::from_rotation(Quat::from_rotation_x(-std::f32::consts::FRAC_PI_2))
        ),
        (
            #Cube
            Mesh3d(asset_value(Cuboid::new(1.0, 1.0, 1.0)))
            MeshMaterial3d::<StandardMaterial>(asset_value(Color::srgb_u8(124, 144, 255)))
            Transform::from_xyz(0.0, 0.5, 0.0)
        ),
        (
            PointLight {
                shadow_maps_enabled: true,
            }
            Transform::from_xyz(4.0, 8.0, 4.0)
        ),
        (
            Camera3d
            template_value(Transform::from_xyz(-2.5, 4.5, 9.0).looking_at(Vec3::ZERO, Vec3::Y))
        )
    ]
}
