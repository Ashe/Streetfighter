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
	
	draw_sprite_stretched(spr_chunli_face, 0, cam_x, cam_y, 72, 93);
	
	// Draw player one's healthbar on the left
	if (player_one != -1) {
		draw_sprite_ext(spr_chunli_face, 0, cam_x, cam_y, 
				1, 1, 0, c_white, 1);
		draw_healthbar(
				cam_x + HEALTHBAR_PADDING_X, 
				cam_y + HEALTHBAR_PADDING_Y + SHADOW_OFFSET, 
				cam_x + camera_width_half - HEALTHBAR_SEPARATION, 
				cam_y + HEALTHBAR_HEIGHT + HEALTHBAR_PADDING_Y + SHADOW_OFFSET, 
				player_one.current_health, shadow_bg_colour, shadow_colour, shadow_colour, 0, true, false);
		draw_healthbar(
				cam_x + HEALTHBAR_PADDING_X, 
				cam_y + HEALTHBAR_PADDING_Y, 
				cam_x + camera_width_half - HEALTHBAR_SEPARATION, 
				cam_y + HEALTHBAR_HEIGHT + HEALTHBAR_PADDING_Y, 
				player_one.current_health, c_maroon, c_green, c_green, 0, true, false);
	}
	
	// Draw player one's healthbar on the left
	if (player_two != -1) {
		draw_sprite_ext(spr_chunli_face, 0, cam_x + camera_width_half * 2, cam_y, 
				-1, 1, 0, make_color_rgb(100, 255, 100), 1);
		draw_healthbar(
				cam_x + camera_width_half + HEALTHBAR_SEPARATION, 
				cam_y + HEALTHBAR_PADDING_Y + SHADOW_OFFSET, 
				cam_x + (camera_width_half * 2) - HEALTHBAR_PADDING_X, 
				cam_y + HEALTHBAR_HEIGHT + HEALTHBAR_PADDING_Y + SHADOW_OFFSET, 
				player_two.current_health, shadow_bg_colour, shadow_colour, shadow_colour, 1, true, false);
		draw_healthbar(
				cam_x + camera_width_half + HEALTHBAR_SEPARATION, 
				cam_y + HEALTHBAR_PADDING_Y, 
				cam_x + (camera_width_half * 2) - HEALTHBAR_PADDING_X, 
				cam_y + HEALTHBAR_HEIGHT + HEALTHBAR_PADDING_Y, 
				player_two.current_health, c_maroon, c_green, c_green, 1, true, false);
	}
}