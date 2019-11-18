/// @description Insert description here
// You can write your code in this editor

#macro MOVE_SPEED 3

////////////////////////////////////////////
// Flags and variables
////////////////////////////////////////////

// Whether the character has crouch input held
var crouching = false

// Whether direction is dependent on the opponent or not
var facing_opponent = false;

// Whether an animation has been chosen
var lock_animation = false;

////////////////////////////////////////////
// @TODO: Face opponent
////////////////////////////////////////////


////////////////////////////////////////////
// Handle input
////////////////////////////////////////////

// Set move_dir to the accumulation of left and right input
var move_dir = 0;
if (keyboard_check(ord("D"))) {
	move_dir += 1;
	if (not facing_opponent) {
		face_dir = 1;
	}
}
if (keyboard_check(ord("A"))) {
	move_dir -= 1;
	if (not facing_opponent) {
		face_dir = -1;
	}
}

// Crouch on down input
if (keyboard_check(ord("S"))) {
	crouching = true;
}

////////////////////////////////////////////
// Handle movement 
////////////////////////////////////////////

// Don't move if crouched
if (crouching) {
	move_dir = 0;	
}

// Face and move in the right direction
move_dir = clamp(move_dir, -1, 1);
hspeed = move_dir * MOVE_SPEED;
image_xscale = face_dir;

////////////////////////////////////////////
// Handle animations 
////////////////////////////////////////////

// Reset image speed
image_speed = 1;

// Play crouching animation
if (crouching) {
	
	// Start the crouch animation if not already playing
	if (sprite_index != spr_chunli_crouch) {
		sprite_index = spr_chunli_crouch;
		image_index = 0;
	}
	
	// Stop looping the animation when crouched
	if (image_index == 1) {
		image_speed = 0;	
	}
}

// Play standard walking / idle animations
else {

	// Change walking animation depending on movement
	if ((move_dir > 0 and face_dir > 0) 
			or (move_dir < 0 and face_dir < 0)) {
		sprite_index = spr_chunli_walking;
	}
	else if ((move_dir > 0 and face_dir < 0) 
			or (move_dir < 0 and face_dir > 0)) {
		image_speed = -1;
		sprite_index = spr_chunli_walking;
	}

	// Standing still
	else {
		sprite_index = spr_chunli_idle;
	}
}