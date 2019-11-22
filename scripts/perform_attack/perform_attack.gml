///perform_attack(atk_spr, state, index_hit, size_x, size_y, offset_x, offset_y, duration, knockback_x, knockback_y, stun_duration, hit_type, index_end, state_new, cooldown)

// Do the punch animation
sprite_index = argument0;
image_speed = 1;
		
// When this is a new punch, start it from the beginning
if (previous_state != argument1) {
	image_index = 0;
}
		
// On second frame, create hitbox
if (image_index == argument2 and hitbox == -1) {
	hitbox_create(argument3, argument4, argument5, argument6, argument7, argument8, argument9, argument10, argument11);
}
		
// When at the end of the punch, go on cooldown
else if (image_index >= argument12) {
	state = argument13;
	cooldown_frames = argument14;
}