/// @description Frame-by-frame logic

//////////////////////////////////////////////////////
// Flags and variables
// - Used to determine the player's intentions
//////////////////////////////////////////////////////

// Whether the character is jumping this frame
var try_jump = false;

// Whether the character is crouching this frame
var try_crouch = false

// Whether direction is dependent on the opponent or not
var is_facing_opponent = false;

// Whether the character is on the ground
var is_grounded = false;

//////////////////////////////////////////////////////
// Handle input
// - Set flags using controller input
// - These flags will then be interpreted later
//////////////////////////////////////////////////////

// Find a controller if this object has not got one
if (gamepad_device == -1) {
	for (var i = 0; i < gamepad_get_device_count(); i++) {
	    if (gamepad_button_check(i, gp_start)) {
			gamepad_device = i;
			show_debug_message("Device selected: Gamepad " + string(i));
		}
	}
}

// Prepare to get the direction to move int
move_dir = 0;

// Check the left stick for directional input
var horz_input = 0;
var vert_input = 0;
if (gamepad_is_connected(gamepad_device)) {
	horz_input = gamepad_axis_value(gamepad_device, gp_axislh);
	vert_input = gamepad_axis_value(gamepad_device, gp_axislv);
}

// Set move_dir to the accumulation of left and right input
if (keyboard_check(ord("D")) or horz_input > 0.3 
		or gamepad_button_check(gamepad_device, gp_padr)) {
	move_dir += Direction.Right;
}
if (keyboard_check(ord("A")) or horz_input < - 0.3
		or gamepad_button_check(gamepad_device, gp_padl)) {
	move_dir += Direction.Left;
}

// Jump on 'Up' input
if (keyboard_check(ord("W")) or vert_input < - 0.5
		or gamepad_button_check(gamepad_device, gp_padu)) {
	try_jump = true;
}

// Crouch on 'Down' input
if (keyboard_check(ord("S")) or vert_input > 0.5
		or gamepad_button_check(gamepad_device, gp_padd)) {
	try_crouch = true;
}

//////////////////////////////////////////////////////
// On-ground checks
// - Checks to see if the character is on the ground
// - Character can only perform movement if grounded
// - This also allows for arial moves to be executed
//////////////////////////////////////////////////////

// Keep the character above ground level
gravity = 1;
if (y >= ground_level) {
	y = ground_level;
	is_grounded = true;
	gravity = 0;
}

//////////////////////////////////////////////////////
// @TODO: Face opponent
// - Ensures that the sprite is facing the opponent
// - Only functional when is_facing_opponent is true
// - Must be on the ground to change direction
//////////////////////////////////////////////////////

// Only change the direction when grounded
if (is_grounded) {
	
	// Face the direction of the opponent
	if (is_facing_opponent) {
		// @TODO: Implement this
	}

	// Face in the direction of travel
	else {
		if (state_move_dir != 0) {
			face_dir = clamp(state_move_dir, 
					Direction.Left, Direction.Right);
		}
	}
}

//////////////////////////////////////////////////////
// State management
// - Uses flags to determine current character state
// - Also keeps track of previous state
// - Used to control attacks, animations and boxes
// - Only changes if the current state isn't locked
// - State locking occurs when attacking or stunned
//////////////////////////////////////////////////////

// Record the previous state
previous_state = state;

// Only change state if we aren't locked
if (not is_state_locked) {
	
	// Remember direction at state change
	state_move_dir = move_dir;

	// Should the state lock upon changing?
	var trigger_lock = false;
	
	// Ground states
	if (is_grounded) {
		
		// Is the player trying to crouch
		if (try_crouch) {
			state = Character_State.Crouching;
			trigger_lock = true;
		}
		
		// Is the player trying to jump?
		else if (try_jump) {
			state = Character_State.Jumping;
			trigger_lock = true;
		}
		
		// Is the player trying to move in a direction
		else if (move_dir != 0) {
			state = Character_State.Walking;
		}

		// Idle if nothing else
		else {
			state = Character_State.Idle;
		}
	}

	// Arial states 
	else {
		state = Character_State.InAir;
		is_face_dir_locked = true;
	}
	
				
	// Lock the player into the current state
	if (trigger_lock and previous_state != state) {
		is_state_locked = true;
	}
}

//////////////////////////////////////////////////////
// Handle movement 
// - Checks input and flags to find direction to move
// - Can only move if grounded and not crouched
//////////////////////////////////////////////////////

// Only have control over movement if grounded
if (is_grounded) {
	
	// Reposition back to the ground if below
	y = ground_level;
	
	// Reset speed for non-walking states
	vspeed = 0;
	hspeed = 0;
	
	// Face and move in the right direction
	move_dir = clamp(move_dir, Direction.Left, Direction.Right);
	image_xscale = face_dir;
	
	// Only move if walking
	if (state == Character_State.Walking) {
		hspeed = move_dir * MOVE_SPEED;
	}
}

//////////////////////////////////////////////////////
// Handle animation-based logic 
// - Ensures that animations are correct
// - Ensures starting and stopping on correct frames
//////////////////////////////////////////////////////

// Change animation depending on state
switch (state) {
	
	// Play idle animation normall
	case Character_State.Idle:
		sprite_index = spr_chunli_idle;
		image_speed = 1;
		break;
		
	// Play walking animation, reverse if going backwards
	case Character_State.Walking:
		sprite_index = spr_chunli_walking;
		
		// Walk forwards if moving towards the opponent
		if ((move_dir >= Direction.Right 
					and face_dir >= Direction.Right) 
				or (move_dir <= Direction.Left 
					and face_dir <= Direction.Left)) {
			image_speed = 1;

		}
		// Reverse animation if moving away from opponent
		else {
			image_speed = -1;
		}
		break;
	
	// Play the crouching animation from beginning each time
	case Character_State.Crouching:
	
		// Set crouch animation
		sprite_index = spr_chunli_crouch;
		image_speed = 1;
	
		// Restart from the beginning if this animation is new
		if (previous_state != Character_State.Crouching) {
			image_index = 0;
		}
	
		// Stop looping the animation when crouched
		// Also 'unlock' the state
		if (image_index >= 1) {
			is_state_locked = false;
			image_index = 1;
			image_speed = 0;
		}
		break;
	
	// When the character is winding up a jump
	case Character_State.Jumping:
	
		// Set jump animation
		sprite_index = spr_chunli_jump
		image_speed = 1;
		
		// Lock the way the character is facing
		is_face_dir_locked = true;
		
		// When jumping from ground, restart animation
		if (previous_state != Character_State.Jumping 
				and is_grounded) {
			image_index = 0;
		}
		
		// When windup is over, perform jump and unlock state
		if (image_index >= 1) {
			vspeed = JUMP_SPEED;
			hspeed = MOVE_SPEED * state_move_dir;
			gravity = 1;
			is_state_locked = false;
		}
		break;
	
	// Jumping / falling animation depending on vspeed
	case Character_State.InAir:
	
		// Set jump animation
		sprite_index = spr_chunli_jump
		image_speed = 1;
	
		// If we're moving upwards, its the jump
		if (vspeed <= - 15) {
			if (image_index >= 1) {
				image_index = 1;
				image_speed = 0;
			}
		}
		
		// If at the apex at the jump, different pose
		else if (vspeed < 5) {
			if (image_index >= 2) {
				image_index = 2;
				image_speed = 0;
			}
		}
	
		// Otherwise, its the fall animation
		else {
			if (image_index >= 3) {
				image_index = 3;
				image_speed = 0;
			}
		}
		break;	
}

//////////////////////////////////////////////////////
// Handle hitbox / hurtbox
// - Create initial hurtbox based on initial state
// - Recreate hurtbox if state changes
// - Keeps boxes positioned correctly
//////////////////////////////////////////////////////

// Create hurtbox if necessary
if (state != previous_state or hurtbox == -1) {
	
	// Delete old hurtbox
	if (hurtbox != -1) {
		instance_destroy(hurtbox);
		hurtbox = -1;
	}
	
	// Change hurtbox depending on state
	switch (state) {
		
		// 'Stood up' states have same hurtbox
		case Character_State.Idle:		
		case Character_State.Walking:
			hurtbox = hurtbox_create(60, 180, -30, -220);
			break;
			
		// 'Crouching' states have a smaller hitbox
		case Character_State.Crouching:
		case Character_State.Jumping:
			hurtbox = hurtbox_create(50, 130, -25, -150);
			break;
			
		// Jumping state
		case Character_State.InAir:
			hurtbox = hurtbox_create(50, 150, -25, -250);
			break;
	}
}

// Reposition hurtbox
if (hurtbox != -1) {
	hurtbox.x = x + hurtbox.x_offset;
	hurtbox.y = y + hurtbox.y_offset;
}

// Reposition hitbox
if (hitbox != -1) {
	hitbox.x = x + hitbox.x_offset;
	hitbox.y = y + hitbox.y_offset;
}