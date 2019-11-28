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
if (gamepad_button_check_pressed(gamepad_device, gp_shoulderl)
		or gamepad_button_check_pressed(gamepad_device, gp_shoulderlb)){
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
if (gamepad_button_check_pressed(gamepad_device, gp_shoulderr)
		or gamepad_button_check_pressed(gamepad_device, gp_shoulderrb)){
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
	
	// Manage a flag when character has been knocked over
	if (not has_been_knocked_to_floor 
			and previous_state == Character_State.Hit
			and (current_health <= 0 or
					hit_by_type = Hit_Type.Knockdown)) {
		
		// Play the 'knockdown' sound only once per knockdown
		has_been_knocked_to_floor = true;
		audio_play_sound(snd_floor_knockdown, 20, false);
		
		// Bounce dead players
		if (vspeed > 0 and current_health <= 0) {
			knockback_y = vspeed * -0.25;
			knockback_x = hspeed * 0.25;
		}
	}
	
	else if (state == Character_State.Recovery) {
		has_been_knocked_to_floor = false;	
	}
	
	// Keep character at correct vertical position
	y = ground_level;
	is_grounded = true;
	gravity = 0;
}

// When knocked upwards, uncheck the flag
else {
	has_been_knocked_to_floor = false;	
}

//////////////////////////////////////////////////////
// Face opponent
// - Ensures that the sprite is facing the opponent
// - Only functional when is_facing_opponent is true
// - Typically only allowed when on ground
//////////////////////////////////////////////////////

// Only change the direction when allowed
if (not is_face_dir_locked) {
	
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
	
	// Reset 'is_attacking' each state change
	is_attacking = false;
	
	// Remember direction at state change (when grounded)
	if (is_grounded) {
		state_move_dir = move_dir;
	}

	// Should the state lock upon changing?
	var trigger_lock = false;
	
	// If was hit by a knockdown attack, go into recovery
	if (previous_state == Character_State.Hit and
			hit_by_type == Hit_Type.Knockdown) {
		hit_by_type = -1;
		state = Character_State.Recovery;
		trigger_lock = true;
	}
	
	// Ground states
	else if (is_grounded) {
		
		// Allow the character to face the opponent now grounded
		is_face_dir_locked = false;
		
		// Is the player already crouching?
		if (previous_state == Character_State.Crouching or
				previous_state == Character_State.BlockingCrouching) {
			
			// Any punch button triggers 'crouch_punch"
			if (try_punch_low or try_punch_middle or try_punch_high) {
				state = Character_State.CrouchPunch;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to perform crouch kick (low)?
			else if (try_kick_low) {
				state = Character_State.CrouchLowKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to perform crouch kick (middle)?
			else if (try_kick_middle) {
				state = Character_State.CrouchMiddleKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to perform crouch kick (high)?
			else if (try_kick_high) {
				state = Character_State.CrouchHighKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to block while crouched?
			else if (is_same_direction(move_dir, face_dir * -1)
					and opponent != -1
					and abs(opponent.x - x) < CLOSE_RANGE * 2
					and opponent.is_attacking) {
				state = Character_State.BlockingCrouching;
			}
			
			// Either hold the crouch or undo it
			else {
				state = Character_State.Crouching;
				image_speed = try_crouch ? 1 : -1;
				trigger_lock = true;
			}
		}
		
		// Is the player trying to crouch from standing position
		else if (try_crouch) {
			state = Character_State.Crouching;
			image_speed = 1;
			trigger_lock = true;
		}
		
		// Is the player trying to jump?
		else if (try_jump) {
			state = Character_State.Jumping;
		}
		
		// Is the character trying to punch (low)?
		else if (try_punch_low) {
			if (is_same_direction(move_dir, face_dir)
					and opponent != -1
					and abs(opponent.x - x) < CLOSE_RANGE) {
				state = Character_State.ForwardLowPunch;
				is_attacking = true;
			}
			else {
				state = Character_State.PunchLow;
				is_attacking = true;
			}
			trigger_lock = true;
		}
		
		// Is the character trying to punch (middle)?
		else if(try_punch_middle) {
			state = Character_State.PunchMiddle;
			is_attacking = true;
			trigger_lock = true;
		}
		
		// Is the character trying to punch (high)?
		else if (try_punch_high) {
			state = Character_State.PunchHigh;
			is_attacking = true;
			trigger_lock = true;
		}
		
		// Is the character trying to kick (low)?
		else if (try_kick_low) {
			state = Character_State.KickLow;
			is_attacking = true;
			trigger_lock = true;
		}
				
		// Is the character trying to kick (middle) or flip kick?
		else if (try_kick_middle) {
			if (is_same_direction(move_dir, face_dir)
					and opponent != -1
					and abs(opponent.x - x) < CLOSE_RANGE) {
				state = Character_State.ForwardMiddleKick;
				is_attacking = true;
			}
			else {
				state = Character_State.KickMiddle;
				is_attacking = true;
			}
			trigger_lock = true;
		}
		
		// Is the character trying to kick (high)?
		else if (try_kick_high) {
			if (is_same_direction(move_dir, face_dir)
					and opponent != -1
					and abs(opponent.x - x) < CLOSE_RANGE) {
				state = Character_State.ForwardHighKick;
				is_attacking = true;
			}
			else {
				state = Character_State.KickHigh;
				is_attacking = true;
			}
			trigger_lock = true;
		}
		
		// Is the character trying to block an enemy attack?
		else if (is_same_direction(move_dir, face_dir * -1)
				and opponent != -1
				and abs(opponent.x - x) < CLOSE_RANGE * 2
				and opponent.is_attacking) {
			state = Character_State.BlockingStanding;
		}

		// Is the character trying to move in a direction
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
		
		// Ensure that the character can't change direction
		is_face_dir_locked = true;
		
		// Prepare to do checks for wall jump
		var check_wall_point = x + (move_dir * - 0.5 * (hurtbox.image_xscale + 2));
		var boundry_left = 0;
		var boundry_right = room_width;
		if (controller != -1 and controller.camera != -1) {
			boundry_left = camera_get_view_x(controller.camera);
			boundry_right = boundry_left + camera_get_view_width(controller.camera);
		}
		
		// Check to see if the character wants to wall jump
		if (try_jump and move_dir != 0 and (check_wall_point <= boundry_left
				or check_wall_point >= boundry_right)) {
					
			// Force-face the direction of the jump
			state_move_dir = move_dir;
			face_dir = state_move_dir;
			image_xscale = face_dir;
			
			// Switch to walljump state
			state = Character_State.WallJump;
			trigger_lock = true;
		}
		
		// Is the character trying to perform a forward jump move?
		else if (is_same_direction(state_move_dir, face_dir)) {
			
			// Is the character trying to use the forward jump punch?
			if (try_punch_low or try_punch_middle or try_punch_high) {
				state = Character_State.ForwardJumpPunch;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to do a stomp kick?
			if (try_crouch and try_kick_middle) {
				state = Character_State.ForwardJumpStompKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to do the forward-jump-low-middle kick?
			else if (try_kick_low or try_kick_middle) {
				state = Character_State.ForwardJumpLMKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to do the forward-jump-high kick?
			else if (try_kick_high) {
				state = Character_State.ForwardJumpHighKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Otherwise just use the standard falling state
			else {
				state = Character_State.InAir;
			}
		}
		
		// Is the character trying to perform a standard jump move?
		else {
			
			// Is the character trying to use the jump punch?
			if (try_punch_low or try_punch_middle or try_punch_high) {
				state = Character_State.JumpPunch;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to do the jump-low-middle kick?
			else if (try_kick_low or try_kick_middle) {
				state = Character_State.JumpLowMiddleKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Is the character trying to do the jump-high kick?
			else if (try_kick_high) {
				state = Character_State.JumpHighKick;
				is_attacking = true;
				trigger_lock = true;
			}
			
			// Otherwise just use the standard falling state
			else {
				state = Character_State.InAir;
			}
		}
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
		image_speed = is_same_direction(move_dir, face_dir) ? 1 : -1;
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
			if (image_index >= 1) {
				is_state_locked = false;
				image_index = 1;
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
			// Reverse animation if moving away from opponent
			image_speed = is_same_direction(move_dir, face_dir) ? 1 : -1;
		}
		
		// When jumping from ground, restart animation
		if (previous_state != Character_State.Jumping 
				and is_grounded) {
			image_index = 0;
			vspeed = JUMP_SPEED;
			hspeed = MOVE_SPEED * state_move_dir;
			gravity = 1;
			
			// Do the 'whoosh' noise as the jump starts
			audio_play_sound(snd_hit_swing, 0, false);
		}
		
		// Allows the character to change into an attack
		if (image_index >= 1) {
			is_state_locked = false;
		}
		
		break;
		
	// Latch onto the wall and then do a forward jump
	case Character_State.WallJump:
	
		// Change to wall jump animation
		sprite_index = spr_chunli_wall_jump;
		image_speed = 0;
		image_index = 0;
		gravity = 0;
		
		if (previous_state != Character_State.WallJump) {
			attack_counter = 0;
		}
		else {
			attack_counter += 1;	
		}

		// If this is the second frame of the walljump, jump
		if (attack_counter >= 8) {
			
			// Switch to the flip animation and state
			state = Character_State.InAir;
			sprite_index = spr_chunli_forward_jump;
			image_index = 1;
			
			// Apply impulse to jump
			vspeed = JUMP_SPEED * 0.8;
			hspeed = MOVE_SPEED * state_move_dir;
			gravity = 1;
			
			// Play the jump sound
			audio_play_sound(snd_hit_swing, 0, false);
		}
		
		break;
	
	// Jumping / falling animation depending on vspeed
	case Character_State.InAir:
	
		// Ensure state is unlocked so that attacks can occur
		is_state_locked = false;
		
		// Ensure animation is played normally
		image_speed = 1;
		
		// If its the flip, ensure we're flipping the right way
		if (sprite_index == spr_chunli_forward_jump) {
			image_speed = is_same_direction(state_move_dir, face_dir) ? 1 : -1;
		}
	
		// Only the 'upward jump' changes based on vspeed
		else {
			
			// If its anything other than the forward jump, it must change to jump animation
			sprite_index = spr_chunli_jump;
	
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
	
		// If there's no health left, play the knockdown animation
		if (current_health <= 0) {
			
			// Restart knockdown animation and perform knockback
			if (sprite_index != spr_chunli_knockdown) {
				
				// Start animation from the beginning
				sprite_index = spr_chunli_knockdown;
				image_index = 0;
				
				// Knockback away from opponent
				var dir = opponent.x > x ? Direction.Left : Direction.Right;
				knockback_x = 6 * dir;
				knockback_y = -10;
			}
			
			// Ensure that the character is locked into this state
			is_face_dir_locked = true;
			is_state_locked = true;
			
			// Ensure the knockdown is indeed selected
			sprite_index = spr_chunli_knockdown;
			
			// Play the animation slowly
			image_speed = 0.25;
			
			// Fall slower too
			gravity = 0.3;
			
			// Freeze the animation on last frame
			if (image_index >= 2) {
				image_index = 2;
				image_speed = 0;	
			}
		}
		
		// Otherwise, change animation depending on hit type
		else {
	
			// Play a different animation depending on the type of hit
			var animation = spr_chunli_hit;
			switch (hit_by_type) {
				case Hit_Type.Body: 
					animation = spr_chunli_hit; 
					break;
				case Hit_Type.Face: 
					animation = spr_chunli_hit_face; 
					break;
				case Hit_Type.Knockdown: 
					animation = spr_chunli_knockdown; 
					break;
			}
		
			// Play animation from the beginning if necessary
			if (sprite_index != animation) {
				sprite_index = animation;
				image_index = 0;
			}
		
			// Play at regular speed
			image_speed = 1;
	
			// Ensure that the state can change after cooldown is lifted
			is_state_locked = false;
		
			// Don't loop animation
			var last_frame = sprite_index == spr_chunli_knockdown ? 2 : 1;
			if (image_index >= last_frame) {
				image_index = last_frame;
				image_speed = 0;
			}
		}
	
		break;
		
	// Block an incoming attack
	case Character_State.BlockingStanding:
	
		// Play blocking animation
		sprite_index = spr_chunli_blocking;
		image_index = 0;
		image_speed = 0;
	
		break;
		
	// Block an incoming attack while crouched
	case Character_State.BlockingCrouching:
	
		// Play blocking animation
		sprite_index = spr_chunli_blocking_crouching;
		image_index = 0;
		image_speed = 0;
		break;
		
	// Recover from a knockdown attack
	case Character_State.Recovery:
	
		// Play recovery animation
		sprite_index = spr_chunli_recovery;
		image_speed = 1;
	
		// Lock the state until recovered
		is_state_locked = true;
		
		// Restart animation if needed
		if (previous_state != Character_State.Recovery) {
			image_index = 0;	
		}
		
		// When the animation finishes, recover
		if (image_index >= 1) {
			image_index = 1;
			image_speed = 0;
			is_state_locked = false;
		}
	
		break;
		
	// Punching (l) spawns a hitbox and plays standard animation
	case Character_State.PunchLow:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_low_punch, Character_State.PunchLow, 1, 
				[85, 30, 65, -185, 4, 
						5, -2, 3, 5, Hit_Type.Face, Blocked_By.AnyBlock, snd_punch_light],
				2, Character_State.Idle, 2);	
		break;
			
	// Punching (m) spawns a hitbox and plays standard animation
	case Character_State.PunchMiddle:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_middle_punch, Character_State.PunchMiddle, 1, 
				[120, 30, 80, -165, 4, 
						10, -2, 11, 10, Hit_Type.Face, Blocked_By.AnyBlock, snd_punch],
				2, Character_State.Idle, 7);
		break;
		
	// Punching (h) spawns a hitbox and plays standard animation
	case Character_State.PunchHigh:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_high_punch, Character_State.PunchHigh, 1, 
				[120, 45, 80, -185, 4, 
						15, -2, 12, 12, Hit_Type.Face, Blocked_By.AnyBlock, snd_face_hit],
				2, Character_State.Idle, 10);
		break;
		
	// Punching (fl) spawns a hitbox and plays standard animation
	case Character_State.ForwardLowPunch:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_forward_low_punch, Character_State.ForwardLowPunch, 1, 
				[85, 30, 65, -185, 4, 
						10, -2, 9, 5, Hit_Type.Face, Blocked_By.AnyBlock, snd_punch_light],
				2, Character_State.Idle, 2);
		break;
		
	// Kicking (l) spawns a hitbox and plays standard animation
	case Character_State.KickLow:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_low_kick, Character_State.KickLow, 2, 
				[80, 40, 95, -170, 4, 
						15, -1, 10, 10, Hit_Type.Body, Blocked_By.AnyBlock, snd_body_hit],
				4, Character_State.Idle, 4);
		break;
		
	// Kicking (m) spawns a hitbox and plays standard animation
	case Character_State.KickMiddle:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_middle_kick, Character_State.KickMiddle, 2, 
				[80, 40, 95, -200, 4, 
						18, -1, 13, 12, Hit_Type.Face, Blocked_By.AnyBlock, snd_body_hit],
				4, Character_State.Idle, 5);
		break;
		
	// Kicking (h) spawns a hitbox and plays standard animation
	case Character_State.KickHigh:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_high_kick, Character_State.KickHigh, 1, 
				[100, 35, 100, -240, 4, 
						18, -2, 15, 15, Hit_Type.Face, Blocked_By.AnyBlock, snd_big_hit],
				3, Character_State.Idle, 10);
		break;
		
	// Kicking (fm) spawns two hitboxes and animates standardly
	case Character_State.ForwardMiddleKick:
	
		// Set animation to the flip kick
		sprite_index = spr_chunli_forward_middle_kick;
		image_speed = 1;
		
		// When this is a new kick, start it from the beginning
		if (previous_state != Character_State.ForwardMiddleKick) {
			image_index = 0;
			attack_counter = 0;
			
			// Do the 'whoosh' noise as the flip starts
			audio_play_sound(snd_hit_swing, 0, false);
		}
		
		// On second frame, create hitbox
		if (image_index >= 1 and hitbox == -1 and attack_counter == 0) {
			hitbox_create(80, 40, 95, -150, 4, 
					10, -1, 10, 12, Hit_Type.Body, Blocked_By.AnyBlock, snd_body_hit);
			attack_counter = 1;
		}
		
		// On third frame, create another hitbox
		else if (image_index == 2 and hitbox == -1 and attack_counter == 1) {
			hitbox_create(100, 40, 95, -200, 4, 
					6, -18, 15, 75, Hit_Type.Knockdown, Blocked_By.AnyBlock, snd_face_hit);
			attack_counter = 2;
		}
		
		// When at the end of the kick, go on cooldown
		else if (image_index < 1 and attack_counter == 2) {
			state = Character_State.Idle;
			attack_counter = 0;
			cooldown_frames = 10;
		}
		break;
		
	// Kicking (fh) jumps into the air and spawns hitbox on the final frame
	case Character_State.ForwardHighKick:
	
		// Set animation to the flip kick
		sprite_index = spr_chunli_forward_high_kick;
		image_speed = 1;
		
		// Don't change direction midway through animation
		is_face_dir_locked = true;
		
		// When this is a new kick, start it from the beginning
		if (previous_state != Character_State.ForwardHighKick) {
			image_index = 0;
			vspeed = JUMP_SPEED * 0.9;
			hspeed = MOVE_SPEED * face_dir * 0.45;
			attack_counter = 0;
			
			// Do the 'whoosh' noise as the flip starts
			audio_play_sound(snd_hit_swing, 0, false);
		}
		
		// Freeze animation on final move
		else if (image_index >= 5) {
			image_index = 5;
			image_speed = 0;
			
			// When at the end of the flip, spawn hitbox that lasts until grounded
			if (attack_counter == 0) {
				hitbox_create(60, 40, -45, -180, -1, 
						-7, -18, 11, 80, Hit_Type.Knockdown, Blocked_By.StandingBlock, snd_face_hit);
				attack_counter = 1;
			}
			
			// When grounded and have made an attack, end the move
			else if (attack_counter >= 1) {
				if (is_grounded) {
					if (hitbox != -1) {
						hitbox.is_disabled = true;
					}
					
					// Return the character to standing state
					state = Character_State.Idle;
					attack_counter = 0;
					cooldown_frames = 10;
					
					// Unlock the face direction
					is_face_dir_locked = false;
				}
			}
		}
	
		break;
		
	// Crouch punch attacks standardly
	case Character_State.CrouchPunch:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_crouch_punch, Character_State.CrouchPunch, 1, 
				[110, 30, 110, -130, 4, 
						15, -2, 2, 5, Hit_Type.Body, Blocked_By.CrouchedBlock, snd_punch],
				2, Character_State.Crouching, 2);	
		break;
		
	// Crouch kick (L) attacks standardly
	case Character_State.CrouchLowKick:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_crouch_low_kick, Character_State.CrouchLowKick, 1, 
				[110, 50, 110, -50, 4, 
						15, -2, 7, 5, Hit_Type.Body, Blocked_By.CrouchedBlock, snd_punch],
				2, Character_State.Crouching, 4);	
		break;
		
	// Crouch kick (M) attacks standardly
	case Character_State.CrouchMiddleKick:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_crouch_middle_kick, Character_State.CrouchMiddleKick, 1, 
				[110, 50, 110, -70, 4, 
						15, -2, 9, 5, Hit_Type.Body, Blocked_By.CrouchedBlock, snd_body_hit],
				2, Character_State.Crouching, 4);	
		break;
		
	// Crouch kick (H) attacks standardly
	case Character_State.CrouchHighKick:
	
		// Use the standard script for attacks
		perform_attack(spr_chunli_crouch_high_kick, Character_State.CrouchHighKick, 1, 
				[120, 50, 125, -170, 4, 
						8, -13, 12, 75, Hit_Type.Knockdown, Blocked_By.CrouchedBlock, snd_big_hit],
				2, Character_State.Crouching, 4);	
		break;
		
	// Jump punch attack ends when grounded
	case Character_State.JumpPunch:
	
		// Use plunging jump attack script to end move on grounding
		perform_plunge_jump_attack(spr_chunli_jump_punch, Character_State.JumpPunch, 2,
				[70, 70, 60, -180, -1, 
						10, -2, 10, 15, Hit_Type.Face, Blocked_By.StandingBlock, snd_punch_light],
				is_grounded, 4, Character_State.Idle, 5);
		break;
		
	// Jump kick (lm) attack ends after animation
	case Character_State.JumpLowMiddleKick:
	
		// Use the standard jump attack script
		perform_jump_attack(spr_chunli_jump_lm_kick, Character_State.JumpLowMiddleKick, 2,
				[70, 70, 60, -180, 10, 
						10, -2, 12, 15, Hit_Type.Face, Blocked_By.StandingBlock, snd_face_hit],
				is_grounded, 4, Character_State.Idle, 10);
		break;
		
	// Jump kick (h) attack ends after animation
	case Character_State.JumpHighKick:
	
		// Use the standard jump attack script
		perform_jump_attack(spr_chunli_jump_high_kick, Character_State.JumpHighKick, 1,
				[80, 45, 95, -165, 6, 
						6, -18, 14, 70, Hit_Type.Knockdown, Blocked_By.StandingBlock, snd_face_hit],
				is_grounded, 5, Character_State.Idle, 10);
		break;
		
	// Forward jump punch attack ends when grounded
	case Character_State.ForwardJumpPunch:
	
		// Use plunging jump attack script to end move on grounding
		perform_plunge_jump_attack(spr_chunli_forward_jump_punch, Character_State.ForwardJumpPunch, 1,
				[70, 70, 60, -180, -1, 
						10, -2, 8, 15, Hit_Type.Face, Blocked_By.StandingBlock, snd_punch_light],
				is_grounded, 2, Character_State.Idle, 5);
		break;
		
	// Forward jump kick (lm) attack ends after animation
	case Character_State.ForwardJumpLMKick:
	
		// Use the standard jump attack script
		perform_jump_attack(spr_chunli_forward_jump_lm_kick, Character_State.ForwardJumpLMKick, 1,
				[70, 70, 60, -180, 30, 
						10, -2, 11, 15, Hit_Type.Face, Blocked_By.StandingBlock, snd_face_hit],
				is_grounded, 4, Character_State.Idle, 10);
		break;
		
	// Forward jump kick (h) attack ends after animation
	case Character_State.ForwardJumpHighKick:
	
		// Use the standard jump attack script
		perform_jump_attack(spr_chunli_forward_jump_high_kick, Character_State.ForwardJumpHighKick, 2,
				[70, 70, 60, -180, 16, 
						10, -2, 12, 15, Hit_Type.Face, Blocked_By.StandingBlock, snd_face_hit],
				is_grounded, 5, Character_State.Idle, 10);
		break;
		
	// Stomp kicking allows Chun Li to jump off of the opponent
	case Character_State.ForwardJumpStompKick:
	
		// Set animation
		sprite_index = spr_chunli_stomp_kick;
		image_speed = 1;
		
		// Start animation from beginning if this is a new stomp kick
		if (previous_state != Character_State.ForwardJumpStompKick) {
			image_index = 0;
			attack_counter = 0;
		}
		
		// Spawn hitbox on second frame
		if (image_index >= 1 and attack_counter == 0) {
			hitbox_create(30, 100, 20, -70, 6,
					5, -1, 11, 6, Hit_Type.Face, Blocked_By.StandingBlock,
							snd_body_hit);
			attack_counter = 1;
			image_index = 1;
		}
		
		// Slow down the 'kick' part of the animation
		if (image_index >= 1 and image_index < 2) {
			image_speed = 0.5;	
		}
		
		// If the attack has landed, perform another jump
		if (attack_counter == 1 and has_hitbox_connected) {
			hspeed = MOVE_SPEED * face_dir;
			vspeed = JUMP_SPEED * 0.8;
			attack_counter = 2;
		}
		
		// End the move when grounded
		if (is_grounded) {
			state = Character_State.Idle;
			cooldown_frames = 4;
			attack_counter = 0;
		}
		
		// Otherwise, transition to the jump animation
		else if (image_index >= 2) {
			state = Character_State.InAir;
			sprite_index = spr_chunli_jump;
			cooldown_frames = 4;
			attack_counter = 0;
		}
	
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

// Reset flag for whether the hitbox has struck the enemy
has_hitbox_connected = false;

// (Re)Create hurtbox if necessary
if (state != previous_state or hurtbox == -1) {
	
	// Change hurtbox depending on state
	switch (state) {
		
		// 'Stood up' states have same hurtbox
		case Character_State.Idle:		
		case Character_State.Walking:
		case Character_State.BlockingStanding:
			hurtbox_create(50, 180, 0, -220);
			break;
			
		// 'Crouching' states have a smaller hurtbox
		case Character_State.Crouching:
		case Character_State.BlockingCrouching:
		case Character_State.Jumping:
			hurtbox_create(50, 130, 0, -150);
			break;
			
		// When hit or recovering from knockdown, delete hurtbox
		case Character_State.Hit:
		case Character_State.Recovery:
		
			// If killed or knocked down, delete hurtbox
			if (current_health <= 0 or hit_by_type == Hit_Type.Knockdown) {
				
				// Delete the hurtbox if it exists
				if (hurtbox != -1) {
					instance_destroy(hurtbox);
					hurtbox = -1;
				}
			}
		
			// Standard hurtbox for 'idle' if not knocked down
			else {
				hurtbox_create(50, 180, 0, -220);
			}
			
			break;
			
		// States in mid-air share the same hurtbox
		case Character_State.InAir:
		case Character_State.WallJump:
		case Character_State.ForwardHighKick:
		case Character_State.JumpPunch:
		case Character_State.JumpLowMiddleKick:
		case Character_State.JumpHighKick:
		case Character_State.ForwardJumpPunch:
		case Character_State.ForwardJumpLMKick:
		case Character_State.ForwardJumpHighKick:
		case Character_State.ForwardJumpStompKick:
			hurtbox_create(50, 150, 0, -250);
			break;
			
		// Punching moves hurtbox forwards a bit
		case Character_State.PunchLow:
		case Character_State.PunchMiddle:
		case Character_State.PunchHigh:
		case Character_State.ForwardLowPunch:
			hurtbox_create(30, 180, 15, -220);
			break;
			
		// Kicking moves brings it forward a lot
		case Character_State.KickLow:
		case Character_State.KickMiddle:
		case Character_State.KickHigh:
		case Character_State.ForwardMiddleKick:
			hurtbox_create(65, 180, 20, -220);
			break;
			
		// Crouching attacks move the hurtbox forwards
		case Character_State.CrouchPunch:
		case Character_State.CrouchLowKick:
		case Character_State.CrouchMiddleKick:
		case Character_State.CrouchHighKick:
			hurtbox_create(35, 130, 50, -150);
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
					
			// The hitbox has connected
			has_hitbox_connected = true;
				
			// Only hit the opponent if they don't block it
			if (not is_blocked(hitbox, opponent)) {
			
				// Hit the character and force a cooldown
				opponent.state = Character_State.Hit;
				opponent.cooldown_frames = hitbox.hit_stun;
				opponent.knockback_x = hitbox.knockback_x_hit;
				opponent.knockback_y = hitbox.knockback_y_hit;
				opponent.current_health -= hitbox.hit_damage;
				opponent.hit_by_type = hitbox.hit_type;
			
				// Play the sound associated with the hit
				if (hitbox.hit_sound != -1) {
					audio_play_sound(hitbox.hit_sound, 0, false);
				}
			
				// Delete the opponent's hurtbox so that it can reset
				if (opponent.hurtbox != -1) {
					instance_destroy(opponent.hurtbox);
					opponent.hurtbox = -1;
				}
			
				// Disable the hitbox to stop it from hitting twice
				hitbox.is_disabled = true;
			
				// Notify controller of a hit
				if (controller != -1) {
					controller.register_hit = true;
				}
			}
			
			// Otherwise, the oppoennt blocks the attack
			else {
				
				// Create a 'block stun'
				opponent.cooldown_frames = 6;
				
				// Play the block sound
				audio_play_sound(snd_hit_blocked, 0, false);
				
				// Disarm the attack as it has been blocked
				hitbox.is_disabled = true;
			}
		}
	}
}

//////////////////////////////////////////////////////
// Collide with other player
// - Stop characters walking through each other
// - You cannot land on top of the opponent
//////////////////////////////////////////////////////

// Only do these checks if there is an opponent
if (hurtbox != -1 and opponent != -1 and opponent.hurtbox != -1) {
	if (hurtbox.x + hspeed < opponent.hurtbox.x + opponent.hurtbox.image_xscale 
			and hurtbox.x + hspeed + hurtbox.image_xscale > opponent.hurtbox.x
			and hurtbox.y + vspeed < opponent.hurtbox.y + opponent.hurtbox.image_yscale
			and hurtbox.y + vspeed + hurtbox.image_yscale > opponent.hurtbox.y) {
		
		// Move the character out of the opponent's hurtbox
		if (hspeed != 0 or vspeed != 0) {
			
			// Store the speed and stop the player from moving
			momentum = hspeed;
			hspeed = 0;
			
			// Positions the character right next to opponent's box
			x = opponent.x + opponent.hurtbox.image_xscale
					* (opponent.x > x ? Direction.Left : Direction.Right);
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
