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
	InAir,
}

// What line is the 'ground' - use starting position
ground_level = y;

// Which way the character is facing
face_dir = Direction.Right;

// What is the initial state of the character
state = Character_State.Idle;

// What was the previous state of the character
previous_state = -1;

// Is the character ready to move onto a new state?
is_state_locked = false

// Initialise hurtbox and hitbox
hurtbox = -1;
hitbox = -1;

// Which gamepad to use
gamepad_device = -1;
