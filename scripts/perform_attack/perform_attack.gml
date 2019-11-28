///perform_attack(atk_spr, state, index_hit, size_x, size_y, offset_x, offset_y, duration, knockback_x, knockback_y, stun_duration, hit_type, index_end, state_new, cooldown)

// Do the given animation
sprite_index = argument0;
image_speed = 1;
		
// When this is a new state, start it from the beginning
if (previous_state != argument1) {
	image_index = 0;
	attack_counter = 0;
}
		
// On given frame, create hitbox
if (image_index >= argument2 and attack_counter == 0) {
	
	// Perform the attack
	hitbox_create(argument3[0], argument3[1], argument3[2], argument3[3], argument3[4], argument3[5], argument3[6], argument3[7], argument3[8], argument3[9], argument3[10], argument3[11]);
	image_index = argument2;
	attack_counter = 1;
	
	// Make the 'swoosh' noise
	audio_play_sound(snd_hit_swing, 0, false);
}
		
// When at the end of the attack, go on given cooldown
else if (image_index >= argument4) {
	state = argument5;
	cooldown_frames = argument6;
}