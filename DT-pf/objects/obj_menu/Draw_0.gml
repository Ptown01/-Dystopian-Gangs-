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
				var scr = script_execute(get_3d_grid(current_page, i, 2, max_buttons, menu));
				if scr{
				hovered = false;
				pressed[i] = false;
				exit;
				}
			}
			offset_ = wave(-10,10,1,5);
			pressed[i] = true;
			if hovered = false{
				hovered = true;
				recY1 = yy+i*string_height(str)*1.5+string_height(str)/2;	
				recY2 = recY1;
				recY1_ = _y1;
				recY2_ = _y2;
				audio_play_sound(snd_hover,0,false);
			}
			recY1 = lerp(recY1,recY1_,.25);
			recY2 = lerp(recY2,recY2_,.25);
			
			surface_set_target(gradSurf);
			draw_clear_alpha(c_black,0);
			
			shader_set(sha_fade);
			
			draw_rectangle(0,recY1,room_width,recY2,false);
			shader_reset();
			gpu_set_blendmode_ext(bm_dest_alpha,bm_inv_dest_alpha);
			gpu_set_alphatestenable(true);
			draw_sprite_ext(spr_glow,0,glowX,recY1+(recY2-recY1)/2,1,1,0,c_white,.3);
			gpu_set_alphatestenable(false);
			gpu_set_blendmode(bm_normal);
			surface_reset_target();
			
			draw_surface(gradSurf,0,0);
			
		}else if !in_array(pressed,true){
			hovered = false;
			pressed[i] = false;
		}else{
			offset_ = 0;
			pressed[i] = false;
		}
		draw_text_color(room_width/2+offset_,yy+i*string_height(str)*1.5+2,str,c_black,c_black,c_black,c_black,1);
		draw_text(room_width/2+offset_,yy+i*string_height(str)*1.5,str);
		
		if get_3d_grid(current_page,i,3,max_buttons,menu) = 1{
			draw_rectangle(room_width/2+offset_+string_width(str)/2+5,yy+i*string_height(str)*1.5-5+string_height(str)/2,room_width/2+offset_+string_width(str)/2+15,yy+i*string_height(str)*1.5+5+string_height(str)/2,!get_3d_grid(current_page,i,0,max_buttons,menu));
		}
	}
}
draw_set_halign(fa_left);