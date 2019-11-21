/// @description Post-movement logic

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
		x -= hspeed;
		x = opponent.x + opponent.hurtbox.image_xscale
				* (opponent.x > x ? -1 : 1);
	}
}

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