/// @description Initialise variables and macros

// Constants
#macro MOVE_SPEED 6
#macro JUMP_SPEED -28
#macro CLOSE_RANGE 120

// Which way to face
enum Direction {
	Left = -1,
	Right = 1
}

// State of the character
enum Character_State {
	Idle,
	Walking,
	Crouching,
	Jumping,
	InAir,
	Hit,
	PunchLow,
	PunchMiddle,
	PunchHigh,
	KickLow,	
	KickMiddle,
	KickHigh,
	ForwardLowPunch,
	ForwardHighKick,
	ForwardMiddleKick,
	CrouchPunch,
	CrouchLowKick,
	CrouchMiddleKick,
	CrouchHighKick
}

// Which gamepad to use
gamepad_device = -1;

// Whether this character should receive keyboard inputs
is_using_keyboard = false;

// Reference to controller
controller = -1;

// What line is the 'ground' - use starting position
ground_level = y;

// Which way the character is currently facing
face_dir = Direction.Right;

// Whether direction is dependent on the opponent or not
is_facing_opponent = false;

// The oppponent to face
opponent = -1;

// Which way the character is moving
move_dir = 0;

// Record the direction set when the state changed
// Eg: You can't turn mid jump
state_move_dir = 0;

// What is the initial state of the character
state = Character_State.Idle;
previous_state = -1;

// Prevent switching states when enabled
is_state_locked = false

// Cooldown frames until state auto-unlocks
cooldown_frames = 0;

// Initialise hurtbox and hitbox
hurtbox = -1;
hitbox = -1;

// Knockback directions
knockback_x = 0;
knockback_y = 0;

// What kind of attack was used to hit this character
hit_by_type = -1;

// Attack counter for multi-hit moves
attack_counter = 0;

// Used to store velocities during collisions
momentum = 0;