/// @description The controller also acts as a camera

// Prepare to track players
var destination_x = 0;
var destination_y = 0;

// Take player one into account
if (player_one) {
	destination_x += player_one.x;
	destination_y += player_one.y
}

// Take player two into account
if (player_two) {
	destination_x += player_two.x;
	destination_y += player_two.y;
}

// Halve x and y to average
if (player_one and player_two) {
	destination_x /= 2;
	destination_y /= 2;
}

// Ensure the camera stays within the room
destination_x = clamp(
		destination_x, 
		camera_width_half, 
		room_width - camera_width_half)
destination_y = clamp(
		destination_y, 
		camera_height_half, 
		room_height - camera_height_half)

// Lerp camera towards destination
x = lerp(x, destination_x, 0.1);
y = lerp(y, destination_y, 0.1);

// Make camera follow the controller
camera_set_view_pos(
		camera, 
		x - camera_width_half, 
		y - camera_height_half);
