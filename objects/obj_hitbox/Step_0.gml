/// @description Drain duration each frame

// Destroy hitbox when no duration left
duration --;
if (is_disabled or duration <= 0) {
	instance_destroy();	
}