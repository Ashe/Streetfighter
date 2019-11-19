/// @description Initialise variables

// Make it transparent
image_alpha = 0.5;

// Which character this hitbox belongs to
owner = -1;

// Positioning in relation to owner
x_offset = 0;
y_offset = 0;

// How long this hitbox is live for
duration = 0

// Knockback values
knockback_x_hit = 0;
knockback_y_hit = 0;

// How long we stun the character per hit
hit_stun = 0;

// Prevent a character getting multiple times
ignore = false;
ignore_list = ds_list_create();