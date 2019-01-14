/// @description Insert description here
// You can write your code in this editor

//part sys
partSys = part_system_create();

//part
partType = part_type_create();
part_type_shape(partType,spr_part);
part_type_alpha2(partType,0,1);
part_type_life(partType,room_speed*5, room_speed*10);
part_type_gravity(partType,.005,180);
part_type_direction(partType,-100,100,0,true);
part_type_color2(partType,c_aqua,c_black);
part_type_size(partType,.2,.1,-.001,0)
//emit
partEmit = part_emitter_create(partSys)
part_emitter_region(partSys,partEmit,x,x,y,y,ps_shape_rectangle,ps_distr_linear);
part_emitter_stream(partSys,partEmit,partType,1);
part_emitter_clear(partSys,partEmit);