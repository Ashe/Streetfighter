/// @description Frame-by-frame logic

//////////////////////////////////////////////////////
// Flags and variables
// - Used to determine the player's intentions
//////////////////////////////////////////////////////

// Whether the character is jumping this frame
var try_jump = false;

// Whether the character is crouching this frame
var try_crouch = false

// Whether the character is punching this frame
var try_punch_low = false;
var try_punch_middle = false;
var try_punch_high = false;

// Whether the character is kicking this frame
var try_kick_low = false;
var try_kick_middle = false;
var try_kick_high = false;

// Whether the character is on the ground
var is_grounded = false;

//////////////////////////////////////////////////////
// Handle input
// - Set flags using controller input
// - These flags will then be interpreted later
//////////////////////////////////////////////////////

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
if ((is_using_keyboard and (keyboard_check(ord("D"))
			or keyboard_check(vk_right)))
		or horz_input > 0.3 
		or gamepad_button_check(gamepad_device, gp_padr)) {
	move_dir += Direction.Right;
}
if ((is_using_keyboard and (keyboard_check(ord("A"))
			or keyboard_check(vk_left)))
		or horz_input < - 0.3
		or gamepad_button_check(gamepad_device, gp_padl)) {
	move_dir += Direction.Left;
}

// Jump on 'Up' input
if ((is_using_keyboard and (keyboard_check(ord("W"))
			or keyboard_check(vk_up)))
		or vert_input < - 0.5
		or gamepad_button_check(gamepad_device, gp_padu)) {
	try_jump = true;
}

// Crouch on 'Down' input
if ((is_using_keyboard and (keyboard_check(ord("S"))
			or keyboard_check(vk_down)))
		or vert_input > 0.5
		or gamepad_button_check(gamepad_device, gp_padd)) {
	try_crouch = true;
}

// Middle punch on "X (Xbox)" or "Square"
if (gamepad_button_check_pressed(gamepad_device, gp_face3)) {
	try_punch_low = true;
}

// Middle punch on "Y" or "Triangle"
if (gamepad_button_check_pressed(gamepad_device, gp_face4)) {
	try_punch_middle = true;
}

// High punch on left-shoulder
if (gamepad_button_check_pressed(gamepad_device, gp_shoulderl)) {
	try_punch_high = true;
}

// Low kick on "A" or "X (PlayStation)"
if (gamepad_button_check_pressed(gamepad_device, gp_face1)) {
	try_kick_low = true;
}

// Middle kick on "B" or "Circle"
if (gamepad_button_check_pressed(gamepad_device, gp_face2)) {
	try_kick_middle = true;
}

// High kick on right-shoulder
if (gamepad_button_check_pressed(gamepad_device, gp_shoulderr)) {
	try_kick_high = true;
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
// Face opponent
// - Ensures that the sprite is facing the opponent
// - Only functional when is_facing_opponent is true
// - Must be on the ground to change direction
//////////////////////////////////////////////////////

// Only change the direction when grounded
if (is_grounded) {
	
	// Face the direction of the opponent
	if (is_facing_opponent) {
		
		// If the opponent is set
		if (opponent != -1) {
			
			// Find displacement between characters
			var disp = opponent.x - x;
			
			// Face the opponent
			if (disp != 0) {
				face_dir = disp < 0 ? 
						Direction.Left : Direction.Right;
			}
		}
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
// - State will also not change while cooling down
//////////////////////////////////////////////////////

// Decrement cooldown
if (cooldown_frames > 0) {
	cooldown_frames -= 1;
}

// Record the previous state
previous_state = state;

// Only change state if we aren't locked
if (not is_state_locked and cooldown_frames <= 0) {
	
	// Remember direction at state change
	state_move_dir = move_dir;

	// Should the state lock upon changing?
	var trigger_lock = false;
	
	// Ground states
	if (is_grounded) {
		
		// Is the player trying to crouch
		if (try_crouch) {
			state = Character_State.Crouching;
			image_speed = 1;
			trigger_lock = true;
		}
		
		// Is the player trying stand back up
		else if (previous_state == Character_State.Crouching) {
			state = Character_State.Crouching;
			image_speed = -1;
			trigger_lock = true;
		}
		
		// Is the player trying to jump?
		else if (try_jump) {
			state = Character_State.Jumping;
		}
		
		// Is the character trying to punch (low)?
		else if (try_punch_low) {
			state = Character_State.PunchLow;
			trigger_lock = true;
		}
		
		// Is the character trying to punch (middle)?
		else if(try_punch_middle) {
			state = Character_State.PunchMiddle;
			trigger_lock = true;
		}
		
		// Is the character trying to punch (high)?
		else if (try_punch_high) {
			state = Character_State.PunchHigh;
			trigger_lock = true;
		}
		
		// Is the character trying to kick (low)?
		else if (try_kick_low) {
			state = Character_State.KickLow;
			trigger_lock = true;
		}
				
		// Is the character trying to kick (middle)?
		else if (try_kick_middle) {
			state = Character_State.KickMiddle;
			trigger_lock = true;
		}
		
		// Is the character trying to kick (high)?
		else if (try_kick_high) {
			state = Character_State.KickHigh;
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
	
	// Play idle animation normal
	case Character_State.Idle:
		sprite_index = spr_chunli_idle;
		image_speed = 1;
		is_state_locked = false;
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
		
		// Restart from the beginning if this animation is new
		if (previous_state != Character_State.Crouching) {
			image_index = 0;
		}
		
		// Stop looping the animation when crouched
		if (image_speed >= 1) {
			if (image_index >= 2) {
				is_state_locked = false;
				image_index = 2;
				image_speed = 0;
			}
		}
		
		// Stand up when not trying to crouch
		else if (image_speed <= -1) {
			if (image_index <= 0.5) {
				is_state_locked = false;
				state = Character_State.Idle;
				cooldown_frames = 5;
				image_index = 0;
				image_speed = 0;
			}
		}
		
		break;
	
	// When the character is jumping forwards or upwards
	case Character_State.Jumping:
			
		// Lock the way the character is facing
		is_face_dir_locked = true;
	
		// Jump upwards if no direction input
		if (state_move_dir == 0) {
			
			// Do the standard animation normally
			sprite_index = spr_chunli_jump
			image_speed = 1;
		}
		
		// If a direction has been input, flip in the right direction
		else {
			
			// Do the flip animation
			sprite_index = spr_chunli_forward_jump;
			
			// Flip forwards if moving towards the opponent
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
		}
		
		// When jumping from ground, restart animation
		if (previous_state != Character_State.Jumping 
				and is_grounded) {
			image_index = 0;
			vspeed = JUMP_SPEED;
			hspeed = MOVE_SPEED * state_move_dir;
			gravity = 1;
		}
		
		// Allows the character to change into an attack
		if (image_index >= 1) {
			is_state_locked = false;
		}
		
		break;
	
	// Jumping / falling animation depending on vspeed
	case Character_State.InAir:
	
		// Only the 'upward jump' changes based on vspeed
		if (sprite_index == spr_chunli_jump) {
	
			// If we're moving upwards, its the jump
			if (vspeed <= - 8) {
				if (image_index >= 1) {
					image_index = 1;
				}
			}
		
			// If at the apex at the jump, different pose
			else if (vspeed < 7) {
				if (image_index >= 2) {
					image_index = 2;
				}
			}
	
			// Otherwise, its the fall animation
			else {
				if (image_index >= 3) {
					image_index = 3;
				}
			}
		}
		break;
		
	// When the character has been hit by the opponent
	case Character_State.Hit:
	
		// Play animation from the beginning if necessary
		if (sprite_index != spr_chunli_hit 
				or previous_state != Character_State.Hit) {
			image_index = 0;
		}
	
		// Play a different animation depending on the type of hit
		switch (hit_by_type) {
			case Hit_Type.Body: sprite_index = spr_chunli_hit; break;
			case Hit_Type.Face: sprite_index = spr_chunli_hit_face; break;
		}
		
		// Play at regular speed
		image_speed = 1;
	
		// Ensure that the state can change after cooldown is lifted
		is_state_locked = false;
		
		// Don't loop animation
		if (image_index >= 1) {
			image_index = 1;
			image_speed = 0;
		}
	
		break;
		
	// Punching (l) spawns a hitbox and plays standard animation
	case Character_State.PunchLow:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_low_punch, Character_State.PunchLow, 1, 
				75, 30, 55, -185, 4, 5, -2, 5, Hit_Type.Face,
				2, Character_State.Idle, 2);	
		break;
			
	// Punching (m) spawns a hitbox and plays standard animation
	case Character_State.PunchMiddle:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_middle_punch, Character_State.PunchMiddle, 1, 
				120, 30, 80, -165, 4, 10, -2, 10, Hit_Type.Face,
				2, Character_State.Idle, 7);
		break;
		
	// Punching (h) spawns a hitbox and plays standard animation
	case Character_State.PunchHigh:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_high_punch, Character_State.PunchHigh, 1, 
				120, 45, 80, -185, 4, 15, -2, 12, Hit_Type.Face,
				2, Character_State.Idle, 15);
		break;
		
	// Kicking (l) spawns a hitbox and plays standard animation
	case Character_State.KickLow:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_low_kick, Character_State.KickLow, 2, 
				80, 40, 95, -170, 4, 15, -1, 12, Hit_Type.Body,
				4, Character_State.Idle, 4);
		break;
		
	// Kicking (m) spawns a hitbox and plays standard animation
	case Character_State.KickMiddle:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_middle_kick, Character_State.KickMiddle, 2, 
				80, 40, 95, -200, 4, 18, -1, 12, Hit_Type.Body,
				4, Character_State.Idle, 5);
		break;
		
	// Kicking (h) spawns a hitbox and plays standard animation
	case Character_State.KickHigh:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_high_kick, Character_State.KickHigh, 1, 
				100, 35, 100, -240, 4, 18, -2, 12, Hit_Type.Face,
				3, Character_State.Idle, 15);
		break;
}

//////////////////////////////////////////////////////
// Handle hitbox / hurtbox
// - Create initial hurtbox based on initial state
// - Recreate hurtbox if state changes
// - Check if hitbox has made contact with opponent
// - Deal damage / apply effects of hitbox
// - Keeps boxes positioned correctly
//////////////////////////////////////////////////////

// (Re)Create hurtbox if necessary
if (state != previous_state or hurtbox == -1) {
	
	// Change hurtbox depending on state
	switch (state) {
		
		// 'Stood up' states have same hurtbox
		case Character_State.Idle:		
		case Character_State.Walking:
			hurtbox_create(50, 180, 0, -220);
			break;
			
		// 'Crouching' states have a smaller hitbox
		case Character_State.Crouching:
		case Character_State.Jumping:
			hurtbox_create(50, 130, 0, -150);
			break;
			
		// Jumping state
		case Character_State.InAir:
			hurtbox_create(50, 150, 0, -250);
			break;
			
		// Punching moves hitbox forwards a bit
		case Character_State.PunchLow:
		case Character_State.PunchMiddle:
		case Character_State.PunchHigh:
			hurtbox_create(30, 180, 15, -220);
			break;
			
		// Kicking brings it forward a lot
		case Character_State.KickLow:
		case Character_State.KickMiddle:
		case Character_State.KickHigh:
			hurtbox_create(65, 180, 20, -220);
			break;

	}
}

// Reposition hurtbox
if (hurtbox != -1) {
	hurtbox.x = x + hurtbox.x_offset;
	hurtbox.y = y + hurtbox.y_offset;
}

// If a hitbox is currently in play
if (hitbox != -1 and not hitbox.is_disabled) {
	
	// Reposition hitbox
	hitbox.x = x + hitbox.x_offset;
	hitbox.y = y + hitbox.y_offset;
	
	// If the opponent has a hurtbox, check for collision
	if (opponent.hurtbox != -1) {
		if (hitbox.x < opponent.hurtbox.x + opponent.hurtbox.image_xscale 
			and hitbox.x + hitbox.image_xscale > opponent.hurtbox.x
			and hitbox.y < opponent.hurtbox.y + opponent.hurtbox.image_yscale
			and hitbox.y + hitbox.image_yscale > opponent.hurtbox.y) {
			
			// Hit the character and force a cooldown
			opponent.state = Character_State.Hit;
			opponent.cooldown_frames = hitbox.hit_stun;
			opponent.knockback_x = hitbox.knockback_x_hit;
			opponent.knockback_y = hitbox.knockback_y_hit;
			opponent.hit_by_type = hitbox.hit_type;
			
			// Disable the hitbox to stop it from hitting twice
			hitbox.is_disabled = true;
			
			// Notify controller of a hit
			if (controller != -1) {
				controller.register_hit = true;
			}
		}
	}
}

//////////////////////////////////////////////////////
// Handle knockback
// - Happens after being hit during step
// - Modifies velocity with knockback in mind
// - Removes knockback
//////////////////////////////////////////////////////

// Initial movement
x += knockback_x;
y += knockback_y;

// Only apply to velocity if there's anything to apply
if (knockback_x != 0 or knockback_y != 0) {
	hspeed = knockback_x;
	vspeed = knockback_y;
}

// Reset knockback
knockback_x = 0;
knockback_y = 0;
