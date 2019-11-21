/// @description Get references to both characters and initialise

// Get references to players
player_one = instance_find(obj_chunli, 0);
player_two = instance_find(obj_chunli, 1);

// Get reference to the camera
camera = view_camera[0];
camera_width_half = camera_get_view_width(camera) * 0.5;
camera_height_half = camera_get_view_height(camera) * 0.5;

// Allow player one to use keyboard for debugging
// Also give the camera so they can stay on-screen
if (player_one) {
	player_one.camera = camera;
	player_one.is_using_keyboard = true;
}

// Give player two the camera also
if (player_two) {
	player_two.camera = camera;	
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
