/// @description Drain duration each frame

// Reduce duration
if (duration > 0) {
	duration -= 1;
}

// Destroy hitbox when disabled no duration left
if (is_disabled or duration == 0) {
	instance_destroy();	
}