/// @description Initialise variables

// Make it transparent
image_alpha = debug_mode ? 0.5 : 0;

// Which character this hitbox belongs to
owner = -1;

// Positioning in relation to owner
x_offset = 0;
y_offset = 0;

// How long this hitbox is live for
duration = 0