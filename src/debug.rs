use avian3d::diagnostics::PhysicsDiagnosticsPlugin;
use avian3d::prelude::*;
use bevy::app::{App, Plugin, Startup};
use bevy::camera_controller::free_camera::FreeCameraPlugin;

pub struct DebugPlugin;

impl Plugin for DebugPlugin {
    fn build(&self, app: &mut App) {
        app.add_plugins(FreeCameraPlugin).add_plugins((
            PhysicsDiagnosticsPlugin,
            PhysicsDiagnosticsUiPlugin,
            PhysicsDebugPlugin,
        ));
    }
}
