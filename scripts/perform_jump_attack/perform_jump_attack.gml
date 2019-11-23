///perform_attack(atk_spr, state, index_hit, size_x, size_y, offset_x, offset_y, duration, knockback_x, knockback_y, stun_duration, hit_type, grounded, index_end, state_new, cooldown)

// Set animation to the given attack
sprite_index = argument0;
image_speed = 1;
		
// When this is a new move, start it from the beginning
if (previous_state != argument1) {
	image_index = 0;
	attack_counter = 0;
}
		
// Perform attack on the given frame
else if (image_index >= argument2 and attack_counter == 0) {
	hitbox_create(70, 70, 60, -180, -1, 20, -2, 15, Hit_Type.Face);
	hitbox_create(argument3, argument4, argument5, argument6, argument7, argument8, argument9, argument10, argument11);
	attack_counter = 1;
	image_index = argument2;
}
		
// If the character is grounded, end the move
if (argument12) {
	state = argument14;
	attack_counter = 0;
	cooldown_frames = argument15;
	if (hitbox) {
		hitbox.is_disabled = true;
	}
}
		
// Freeze the animation on the attack if not yet landed
else if (attack_counter == 1 and hitbox != -1) {
	image_index = argument2;
	image_speed = 0;
}
		
// Freeze animation on the last frame until landing
else if (image_index >= argument13) {
	image_index = argument13;
	image_speed = 0;
}