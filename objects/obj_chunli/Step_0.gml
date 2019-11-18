/// @description Insert description here
// You can write your code in this editor

////////////////////////////////////////////
// Flags and variables
////////////////////////////////////////////

// Whether the character is jumping this frame
var jumping = false;

// Whether the character is crouching this frame
var crouching = false

// Whether direction is dependent on the opponent or not
var facing_opponent = false;

// Whether an animation has been chosen
var lock_animation = false;

// Whether the character is on the ground
var grounded = false;

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

// Jump on up input
if (keyboard_check(ord("W"))) {
	jumping = true;
}

// Crouch on down input
if (keyboard_check(ord("S"))) {
	crouching = true;
}

////////////////////////////////////////////
// Handle air control
////////////////////////////////////////////

// Keep the character above ground level
gravity = 1;
if (y >= ground_level) {
	y = ground_level;	
	grounded = true;
	gravity = 0;
}


////////////////////////////////////////////
// Handle movement 
////////////////////////////////////////////

// Only have control over movement if grounded
if (grounded) {
	
	// Don't move if crouched
	if (crouching) {
		move_dir = 0;	
	}
	
	// Reposition back to the ground if below
	y = ground_level;
	vspeed = 0;
	
	// Face and move in the right direction
	move_dir = clamp(move_dir, -1, 1);
	hspeed = move_dir * MOVE_SPEED;
	image_xscale = face_dir;
	
	// If jumping, create impulse upward and become ungrounded
	if (jumping) {
		vspeed = JUMP_SPEED;
		grounded = false;
		y -= 10;
		gravity = 1;
	}
}

////////////////////////////////////////////
// Handle animations 
////////////////////////////////////////////

// Reset image speed
image_speed = 1;

// Ground animations
if (grounded) {
	
	// Play crouching animation
	if (crouching) {
	
		// Start the crouch animation if not already playing
		if (sprite_index != spr_chunli_crouch) {
			sprite_index = spr_chunli_crouch;
			image_index = 0;
		}
	
		// Stop looping the animation when crouched
		if (image_index >= 1) {
			image_index = 1;
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
}

// Arial animations 
else {
	
	// When starting a jump, reset image index
	if (jumping and sprite_index != spr_chunli_jump) {
		image_index = 0;
	}
	
	// If no other animation, do jumping / falling
	sprite_index = spr_chunli_jump;
	
	// If we're moving upwards, its the jump
	if (vspeed <= 0) {
		
		// Pause animation on 'jump' part
		if (image_index >= 2) {
			image_index = 2;
			image_speed = 0;
		}
	}
	
	// Otherwise, its the fall animation
	if (vspeed > 0) {
		// Pause animation on 'fall' part
		if (image_index >= 3) {
			image_index = 3;
			image_speed = 0;
		}
	}
}