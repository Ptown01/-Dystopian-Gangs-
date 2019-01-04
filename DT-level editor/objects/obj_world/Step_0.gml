/// @description Insert description here
// You can write your code in this editor
if pressed = true && add = false{
	if coord[0,0] != noone && coord[1,0] != noone && sqID != noone{ // if pressed move the corner
	square[# coord[0,0],sqID] = mouse_x div TILES;
	square[# coord[1,0],sqID] = mouse_y div TILES;
	
	if keyboard_check_pressed(vk_backspace){
		square[# 4,sqID] = 5;
		ds_grid_sort(square,4,true);
		ds_grid_resize(square,6,ds_grid_height(square)-1);
		pressed = false;
	}
	if coord[0,0] = 2 && coord[1,0] = 3 && pressed = true{
	square[# 2,sqID] = clamp(square[# 2,sqID],square[# 0,sqID],ds_grid_width(wGrid)-1);
	square[# 3,sqID] = clamp(square[# 3,sqID],square[# 1,sqID],ds_grid_height(wGrid)-1);
	}else if pressed = true{
	square[# 0,sqID] = clamp(square[# 0,sqID],0,square[# 2,sqID]);
	square[# 1,sqID] = clamp(square[# 1,sqID],0,square[# 3,sqID]);
	}
	}
	if mouse_check_button_released(mb_left) && pressed = true{ //if released go reset the temp coords
		square[# 4,sqID] = prevClass;
		pressed = false;
		coord[1,0] = noone;
		coord[1,0] = noone;
		sqID = noone;
	}
	}else if add = true{ //if adding a new square
		if mouse_check_button_pressed(mb_left){ //set first corner
			var dh = ds_grid_height(square);
			ds_grid_resize(square,6,dh+1)
			square[# 5,dh] = spr_ground;//sprite
			square[# 4,dh] = class.ground;//class
			
			square[# 0,dh] = mouse_x div TILES;
			square[# 1,dh] = mouse_y div TILES;
			square[# 2,dh] = mouse_x div TILES;
			square[# 3,dh] = mouse_y div TILES;
			
			square[# 0,dh] = clamp(square[# 0,dh],0,ds_grid_width(wGrid)-1);
			square[# 1,dh] = clamp(square[# 1,dh],0,ds_grid_height(wGrid)-1);
			square[# 2,dh] = clamp(square[# 2,dh],square[# 0,dh],ds_grid_width(wGrid)-1);
			square[# 3,dh] = clamp(square[# 3,dh],square[# 1,dh],ds_grid_height(wGrid)-1);
			
		}else if mouse_check_button(mb_left){ //set 2nd corner
			var dh = ds_grid_height(square);
			square[# 2,dh-1] = mouse_x div TILES;
			square[# 3,dh-1] = mouse_y div TILES;
			
			square[# 2,dh-1] = clamp(square[# 2,dh-1],square[# 0,dh-1],ds_grid_width(wGrid)-1);
			square[# 3,dh-1] = clamp(square[# 3,dh-1],square[# 1,dh-1],ds_grid_height(wGrid)-1);
			}else if mouse_check_button_released(mb_left){ //stop 
					add = false;
					ds_grid_sort(square,4,true);
				}
		}

if keyboard_check_pressed(ord("A")){ //add a new square
	add = !add;
}
if keyboard_check_pressed(ord("Z")){
	render_ = !render_;
}
if keyboard_check_pressed(ord("G")){
	grid = !grid;
}
if keyboard_check_pressed(ord("V")){
	outlines = !outlines;
}