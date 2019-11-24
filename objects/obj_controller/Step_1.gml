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
}

// Deactivate otherwise
else {
	instance_deactivate_all(self);
}