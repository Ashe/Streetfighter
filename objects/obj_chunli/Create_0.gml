/// @description Initialise variables and macros

// Movement speeds
#macro MOVE_SPEED 5
#macro JUMP_SPEED -25

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
}

// What line is the 'ground' - use starting position
ground_level = y;

// Which way the character is facing
face_dir = Direction.Right;

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

// Initialise hurtbox and hitbox
hurtbox = -1;
hitbox = -1;

// Which gamepad to use
gamepad_device = -1;