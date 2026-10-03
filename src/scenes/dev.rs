use avian3d::prelude::*;
use bevy::camera_controller::free_camera::FreeCamera;
// use bevy::math::DVec3;
use bevy::prelude::*;

pub fn scene() -> impl SceneList {
    bsn_list! [
        (
            #CircularBase
            Mesh3d(asset_value(Cylinder::new(25.0, 1.0)))

            template_value(RigidBody::Static)
            Collider::cylinder(25.0, 1.0)

            MeshMaterial3d::<StandardMaterial>(asset_value(Color::WHITE))

        ),
        // (
        //   #Voxels
        //   template_value(RigidBody::Static)
        //   Collider::voxels(DVec3::new(0.5, 0.5, 0.5), &[IVec3::new(0, 0, 0), IVec3::new(1, 1, 1)])
        // ),
        (
            #Cube
            Mesh3d(asset_value(Cuboid::new(1.0, 1.0, 1.0)))

            template_value(RigidBody::Dynamic)
            Collider::cuboid(1.0, 1.0, 1.0)

            MeshMaterial3d::<StandardMaterial>(asset_value(Color::srgb_u8(124, 144, 255)))

            Transform::from_xyz(0.0, 10.0, 0.0)
        ),
        (
            PointLight {
                shadow_maps_enabled: true,
            }
            Transform::from_xyz(4.0, 8.0, 4.0)
        ),
        (
            Camera3d
            FreeCamera
            template_value(Transform::from_xyz(-2.5, 4.5, 9.0).looking_at(Vec3::ZERO, Vec3::Y))
        )
    ]
}
