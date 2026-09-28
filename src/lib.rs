use avian3d::prelude::*;
use bevy::prelude::*;

// mod camera;
// mod debug;
// mod dev_tools;
// mod game;
// mod input;
// mod physics;
// mod utils;
// mod window;

pub struct GamePlugin;

impl Plugin for GamePlugin {
    fn build(&self, app: &mut App) {
        app.add_plugins(PhysicsPlugins::default()); // Avian3D
    }
}
