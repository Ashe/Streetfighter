/// @description Insert description here
// You can write your code in this editor

#macro MOVE_SPEED 3

// Handle direction
var facing_opponent = false;
// @TODO: Face opponent

// Handle input
var move_dir = 0;
if (keyboard_check(vk_right)) {
	move_dir += 1;
	if (not facing_opponent) {
		face_dir = 1;
	}
}
if (keyboard_check(vk_left)) {
	move_dir -= 1;
	if (not facing_opponent) {
		face_dir = -1;
	}
}

// Calculate movement
move_dir = clamp(move_dir, -1, 1);
hspeed = move_dir * MOVE_SPEED;
image_xscale = face_dir;
if ((move_dir > 0 and face_dir > 0) 
		or (move_dir < 0 and face_dir < 0)) {
	sprite_index = spr_chunli_standing_forwards;
}
else if ((move_dir > 0 and face_dir < 0) 
		or (move_dir < 0 and face_dir > 0)) {
	sprite_index = spr_chunli_standing_backwards;
}

// Standing still
else {
	sprite_index = spr_chunli_standing_neutral;
}