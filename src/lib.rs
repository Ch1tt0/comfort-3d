use avian3d::prelude::*;
use bevy::prelude::*;

mod scenes;
// mod camera;
// mod debug;
// mod dev_tools;
// mod game;
// mod input;
// mod physics;
// mod utils;
// mod window;

pub struct AppPlugin;

impl Plugin for AppPlugin {
    fn build(&self, app: &mut App) {
        app.add_plugins(PhysicsPlugins::default()) // Avian3D
            .add_systems(Startup, scenes::dev::scene.spawn());
    }
}

#[cfg(test)]
mod tests {
    use bevy::prelude::*;

    fn _setup() -> App {
        let mut app = App::new();
        app.add_plugins((MinimalPlugins, crate::AppPlugin));
        app.update();
        app
    }

    // Tests here...
}
