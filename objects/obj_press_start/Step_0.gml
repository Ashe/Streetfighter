/// @description Insert description here
// You can write your code in this editor

// When there's a player attached
if (paired_player != -1) {
	
	// Follow the player
	x = paired_player.x + OFFSET_X;
	y = paired_player.y + OFFSET_Y;
	
	// If the player has a gamepad, destroy self
	if (paired_player.gamepad_device != -1) {
		instance_destroy();	
	}
}