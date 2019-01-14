/// @description Insert description here
// You can write your code in this editor
if point_distance(mouse_x,mouse_y,x,y) < 12{
	if !part_emitter_exists(partSys,partEmit){
		partEmit = part_emitter_create(partSys)
		part_emitter_region(partSys,partEmit,x,x,y,y,ps_shape_rectangle,ps_distr_linear);
		part_emitter_stream(partSys,partEmit,partType,1);
	}
}else{
	if part_emitter_exists(partSys,partEmit){
		part_emitter_destroy(partSys,partEmit);
	}
}