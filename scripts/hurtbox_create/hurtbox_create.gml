_hurtbox = instance_create_depth(x,y, -1, obj_hurtbox);
_hurtbox.owner = id;
_hurtbox.image_xscale = argument0;
_hurtbox.image_yscale = argument1;
_hurtbox.x_offset = argument0 * -0.5 + argument2 * face_dir;
_hurtbox.y_offset = argument3;
return _hurtbox;