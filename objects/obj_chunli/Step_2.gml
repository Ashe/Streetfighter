/// @description Post-movement logic

//////////////////////////////////////////////////////
// Clamp position
// - Called after all movement is processed
// - Ensures that character's position is valid
// - Agnostic of current animation or hurtbox
//////////////////////////////////////////////////////

// After switching animations etc, ensure position is valid
var half_width = hurtbox.sprite_width / 2;
x = clamp(x, half_width, room_width - half_width);
y = clamp(y, 0, ground_level);