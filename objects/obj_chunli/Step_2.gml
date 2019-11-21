/// @description Post-movement logic

//////////////////////////////////////////////////////
// Clamp position
// - Called after all movement is processed
// - Ensures that character's position is valid
// - Agnostic of current animation or hurtbox
//////////////////////////////////////////////////////

// Prepare to clamp the player on-screen
var boundry_left = 0;
var boundry_right = room_width;

// Change boundries from room to camera
if (camera != -1) {
	boundry_left = camera_get_view_x(camera);
	boundry_right = boundry_left + camera_get_view_width(camera);
}

// After switching animations etc, ensure position is valid
var half_width = hurtbox.sprite_width * 0.5;
x = clamp(x, boundry_left + half_width, boundry_right - half_width);
y = clamp(y, 0, ground_level);