/// @description Initialise variables

// What kind of hit this represents
enum Hit_Type {
	Body,
	Face,
	Knockdown
}

// Make it transparent
image_alpha = debug_mode ? 0.7 : 0;

// Which character this hitbox belongs to
owner = -1;

// Positioning in relation to owner
x_offset = 0;
y_offset = 0;

// How long this hitbox is live for (-1 = indefinite)
duration = 0

// Knockback values
knockback_x_hit = 0;
knockback_y_hit = 0;

// How long we stun the character per hit
hit_stun = 0;

// Whether the attack was aimed at the face or body
hit_type = Hit_Type.Body;

// Prevent a character getting multiple times
is_disabled = false;