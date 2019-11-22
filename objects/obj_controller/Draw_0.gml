/// @description Draw the game

if (surface_exists(pause_surface)) {
	draw_surface(pause_surface, camera_get_view_x(camera), camera_get_view_y(camera));
}