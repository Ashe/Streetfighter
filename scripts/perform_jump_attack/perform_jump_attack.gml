///perform_jump_attack(atk_spr, state, index_hit, [size_x, size_y, offset_x, offset_y, duration, knockback_x, knockback_y, stun_duration, hit_type], grounded, index_end, state_new, cooldown)

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
	hitbox_create(argument3[0], argument3[1], argument3[2], argument3[3], argument3[4], argument3[5], argument3[6], argument3[7], argument3[8], argument3[9], argument3[10]);
	attack_counter = 1;
	image_index = argument2;
}
		
// If the character is grounded, end the move
if (argument4) {
	state = argument6;
	attack_counter = 0;
	cooldown_frames = argument7;
}
		
// Freeze animation on the last frame until landing
else if (image_index >= argument5) {
	image_index = argument5;
	image_speed = 0;
}