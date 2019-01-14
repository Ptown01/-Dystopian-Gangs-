/// @description Insert description here
// You can write your code in this editor
draw_set_halign(fa_center);
draw_set_font(fnt_menu);
for (i = 0; i < max_buttons; i++){
	var str = get_3d_grid(current_page, i, 1, max_buttons, menu);
	if str != 0{
		var offset_ = 0;
		var _x1 = room_width/2-string_width(str)/2;
		var _y1 = yy+i*string_height(str)*1.5;
		var _x2 = room_width/2+string_width(str)/2;
		var _y2 = yy+i*string_height(str)*1.5+string_height(str);
		
		if point_in_rectangle(mouse_x,mouse_y,_x1,_y1,_x2,_y2){
			if mouse_check_button_pressed(mb_left){
				script_execute(get_3d_grid(current_page, i, 2, max_buttons, menu));
			}
			offset_ = wave(-10,10,1,5);
			pressed[i] = true;
			if hovered = false{
				hovered = true;
				recY1 = yy+i*string_height(str)*1.5+string_height(str)/2;	
				recY2 = recY1;
				recY1_ = _y1;
				recY2_ = _y2;
				show_debug_message("mouse on button")
				audio_play_sound(snd_hover,0,false);
			}
			recY1 = lerp(recY1,recY1_,.25);
			recY2 = lerp(recY2,recY2_,.25);
			draw_set_alpha(.2);
			draw_rectangle(0,recY1,room_width,recY2,false);
			draw_set_alpha(1);
		}else if !in_array(pressed,true) && alarm[0] = -1{
			hovered = false;
			pressed[alarmID] = false;
		}else{
			offset_ = 0;
			pressed[i] = false;
		}
		draw_text_color(room_width/2+offset_,yy+i*string_height(str)*1.5+2,str,c_black,c_black,c_black,c_black,1);
		draw_text(room_width/2+offset_,yy+i*string_height(str)*1.5,str);
	}
}
draw_set_halign(fa_left);