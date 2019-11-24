/// @description Assign controllers

// Prepare to assign controllers
var player_to_assign = -1;

// If player one exists without a controller
if (player_one != -1 and player_one.gamepad_device == -1) {
	player_to_assign = player_one;
}

else if (player_two != -1 and player_two.gamepad_device == -1) {
	player_to_assign = player_two;
}

// Find a controller if this object has not got one
if (player_to_assign != -1) {
	for (var i = 0; i < gamepad_get_device_count(); i++) {
	    if (player_to_assign.gamepad_device == -1
				and gamepad_button_check(i, gp_start)) {
				
			// Check that this gamepad is unique
			if (player_to_assign.opponent != -1
					and player_to_assign.opponent.gamepad_device != i) {
						
				// Give the player a gamepad
				player_to_assign.gamepad_device = i;
				
				// Play the 'controller connected' sound
				audio_play_sound(snd_controller_connected, 100, false);
			}
		}
	}
}