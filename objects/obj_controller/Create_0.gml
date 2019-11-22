/// @description Get references to both characters and initialise

// Get references to players
player_one = instance_find(obj_chunli, 0);
player_two = instance_find(obj_chunli, 1);

// Get reference to the camera
camera = view_camera[0];
camera_width_half = camera_get_view_width(camera) * 0.5;
camera_height_half = camera_get_view_height(camera) * 0.5;

// Whether a hit has been registered
register_hit = false;

// How long to wait until disabling the hit
pause_duration = 0;

// Surface for rendering frozen frames
pause_surface = -1;

// Give player_one reference to this controller
if (player_one) {
	player_one.controller = self;
}

// Give player_two reference to this controller
// Also give player_two a different colour and the keyboard controls
if (player_two) {
	player_two.controller = self;
	player_two.is_using_keyboard = true;
	player_two.image_blend = make_color_rgb(100, 255, 100);
}

// If both have been found
if (player_one and player_two) {
	
	// Make the players opponents of each other
	player_one.opponent = player_two;
	player_two.opponent = player_one;
	
	// Allow them to track and face each other
	player_one.is_facing_opponent = true;
	player_two.is_facing_opponent = true;
}
