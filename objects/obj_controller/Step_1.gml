/// @description Handle pausing

//////////////////////////////////////////////////////
// Handle Pause-time
// - When a hit is registered everything pauses
// - Everything resumes momentarily after
//////////////////////////////////////////////////////

// Countdown paused frames (-1 = indefinite)
if (pause_duration > 0) {
	pause_duration -= 1;	
}

// Deactivate all objects on a hit
if (register_hit) {
	
	// Start the countdown until play is resumed
	pause_duration = HIT_PAUSE_DURATION;
	register_hit = false;
	
	// Create a surface to render while objects are inactive
	if (not surface_exists(pause_surface)) {
		// Surface for rendering frozen frames
		pause_surface = surface_create(
				surface_get_width(application_surface),
				surface_get_height(application_surface));
		surface_copy(pause_surface, 0, 0, application_surface);
	}
}

// Pause if there's no duration to pause for
if (pause_duration == 0) {
	
	// Free the memory that the pause surface used
	if (surface_exists(pause_surface)) {
		surface_free(pause_surface);
	}
	
	// Reactivate all instances
	instance_activate_all();
	
	// Check to see if anyone has died
	end_game = false;
	if (player_one != -1 and player_one.current_health <= 0) {
		end_game = true;	
	}
	if (player_two != -1 and player_two.current_health <= 0) {
		end_game = true;	
	}
	
	// If the game is to end, start the ending countdown
	if (end_game and room_restart_duration < 0) {
		
		// Start the countdown
		room_restart_duration = DELAY_BEFORE_RESTART;
		
		// Play the 'end round' sound
		audio_play_sound(snd_round_end, 100, false);
	}
}

// Deactivate otherwise
else {
	instance_deactivate_all(self);
}

//////////////////////////////////////////////////////
// Handle match delay
// - Wait when a match ends until the next 
//////////////////////////////////////////////////////

// Count down until next match
if (room_restart_duration > 0) {
	room_restart_duration -= 1;	
}

// Restart the room when 0 is reached
else if (room_restart_duration == 0) {
	room_restart();
}