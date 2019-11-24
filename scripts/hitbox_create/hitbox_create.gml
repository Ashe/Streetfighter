///hitbox_create(size_x, size_y, offset_x, offset_y, duration, knockback_x, knockback_y, damage, stun_duration, hit_type, sound)

// Create a hitbox
_hitbox = instance_create_depth(x, y, -1, obj_hitbox);
_hitbox.owner = id;
_hitbox.image_xscale = argument0;
_hitbox.image_yscale = argument1;
_hitbox.x_offset = argument0 * -0.5 + argument2 * face_dir;
_hitbox.y_offset = argument3;
_hitbox.duration = argument4;
_hitbox.knockback_x_hit = argument5 * face_dir;
_hitbox.knockback_y_hit = argument6;
_hitbox.hit_damage = argument7
_hitbox.hit_stun = argument8;
_hitbox.hit_type = argument9;
_hitbox.hit_sound = argument10;

// Delete the previous hitbox
if (hitbox != -1) {
	instance_destroy(hitbox);
	hitbox = -1;
}

// Replace previous hitbox
hitbox = _hitbox;