/// @description Insert description here
// You can write your code in this editor

//draw grid
if grid = true{
for(_xx = 0; _xx < ds_grid_width(wGrid); _xx++){for (_yy = 0; _yy < ds_grid_height(wGrid); _yy++){
	draw_rectangle(_xx*TILES,_yy*TILES,_xx*TILES+TILES,_yy*TILES+TILES,true);
}}}
//draw squares

for(i = 0; i < ds_grid_height(square); i++){ //draw_sprites
	if square[# 5,i] != undefined && render_ = true{
		for (k = 0; k < square[# 2,i]-square[# 0,i]+1; k++){
			for (l = 0; l < square[# 3,i]-square[# 1,i]+1; l++){
				draw_sprite(square[# 5,i],0,square[# 0,i]*TILES+k*TILES,square[# 1,i]*TILES+l*TILES)
			}			
		}

	}
	
}
if outlines = true{
for(i = 0; i < ds_grid_height(square); i++){ //draw_sprites
	draw_rectangle_color(square[# 0,i]*TILES,square[# 1,i]*TILES,square[# 2,i]*TILES+TILES,square[# 3,i]*TILES+TILES,color[square[# 4,i]],color[square[# 4,i]],color[square[# 4,i]],color[square[# 4,i]],true);
	draw_rectangle_color(square[# 0,i]*TILES-1,square[# 1,i]*TILES-1,square[# 2,i]*TILES+TILES+1,square[# 3,i]*TILES+TILES+1,color[square[# 4,i]],color[square[# 4,i]],color[square[# 4,i]],color[square[# 4,i]],true);
	draw_rectangle_color(square[# 0,i]*TILES+1,square[# 1,i]*TILES+1,square[# 2,i]*TILES+TILES-1,square[# 3,i]*TILES+TILES-1,color[square[# 4,i]],color[square[# 4,i]],color[square[# 4,i]],color[square[# 4,i]],true); 
}}

	for(i = 0; i < ds_grid_height(square); i++){ // get input to corners of squares
		for(j = 0; j < 2; j++){        
					if j = 0{ // check for top left corner
						if point_distance(mouse_x,mouse_y,square[# 0+j*2,i]*TILES,square[# 1+j*2,i]*TILES) < (obj_camera.zoomY)/18{
							draw_rectangle_color(square[# 0+j*2,i]*TILES-3,square[# 1+j*2,i]*TILES-3,square[# 0+j*2,i]*TILES+3,square[# 1+j*2,i]*TILES+3,c_green,c_green,c_green,c_green,false);
							if mouse_check_button_pressed(mb_left) && pressed = false && !keyboard_check(vk_space){//change square
								coord[0,0] = j*2;
								coord[1,0] = 1+j*2;
								sqID = i;
								prevClass = square[# 4,i];
								square[# 4,i] = class.selected;
								pressed = true;
							}
							
							if keyboard_check_pressed(ord("C")){//edit square
								if square[# 4,i] = class.ground{
									square[# 4,i] = class.building;
									square[# 5,i] = spr_ground1;
								}else{
									square[# 4,i] = class.ground;
									square[# 5,i] = spr_ground;
								}
								alarm[0] = 1;
							}
								
						}
					}else{ //check for bottom right corner
						if point_distance(mouse_x,mouse_y,square[# 0+j*2,i]*TILES+TILES,square[# 1+j*2,i]*TILES+TILES) < (obj_camera.zoomY)/18{
							draw_rectangle_color(square[# 0+j*2,i]*TILES+TILES-3,square[# 1+j*2,i]*TILES+TILES-3,square[# 0+j*2,i]*TILES+TILES+3,square[# 1+j*2,i]*TILES+TILES+3,c_green,c_green,c_green,c_green,false);
							if mouse_check_button_pressed(mb_left) && pressed = false && !keyboard_check(vk_space){
								sqID = i;
								coord[0,0] = j*2;
								coord[1,0] = 1+j*2;
								prevClass = square[# 4,i];
								square[# 4,i] = class.selected;
								pressed = true;
							}
							
							if keyboard_check_pressed(ord("C")){//edit square
								if square[# 4,i] = class.ground{
									square[# 4,i] = class.building;
									square[# 5,i] = spr_ground1;
								}else{
									square[# 4,i] = class.ground;
									square[# 5,i] = spr_ground;
								}
								alarm[0] = 1;
							}
						}
				}
		}
	} 