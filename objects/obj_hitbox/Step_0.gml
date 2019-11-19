/// @description Drain duration each frame

// Destroy hitbox when no duration left
duration --;
if (duration <= 0) {
	instance_destroy();	
}