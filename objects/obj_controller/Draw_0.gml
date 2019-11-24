/// @description Draw the game

// Get camera position
var cam_x = camera_get_view_x(camera);
var cam_y = camera_get_view_y(camera);

// Draw the paused version of the game if the surface is there
if (surface_exists(pause_surface)) {
	draw_surface(pause_surface, cam_x, cam_y);
}

// Only draw the current GUI when there's no surface
else {
	
	// Draw player one's healthbar on the left
	if (player_one != -1) {
		draw_healthbar(
				cam_x + HEALTHBAR_PADDING, 
				cam_y + HEALTHBAR_PADDING, 
				cam_x + camera_width_half - HEALTHBAR_PADDING, 
				cam_y + HEALTHBAR_HEIGHT + HEALTHBAR_PADDING, 
				player_one.current_health, c_maroon, c_green, c_green, 0, true, false);
	}
	
	// Draw player one's healthbar on the left
	if (player_two != -1) {
		draw_healthbar(
				cam_x + camera_width_half + HEALTHBAR_PADDING, 
				cam_y + HEALTHBAR_PADDING, 
				cam_x + (camera_width_half * 2) - HEALTHBAR_PADDING, 
				cam_y + HEALTHBAR_HEIGHT + HEALTHBAR_PADDING, 
				player_two.current_health, c_maroon, c_green, c_green, 1, true, false);
	}
}