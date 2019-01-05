/// @description Insert description here
// You can write your code in this editor
var _x = room_width/2;
var _y = room_height/2;

draw_rectangle(_x-64,_y-64,_x+64,_y,true);
draw_rectangle(_x-64,_y,_x+64,_y+64,true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_x,_y-32,string_copy(user, string_length(user)-8, string_length(user)));
draw_text(_x,_y+32,string_repeat("*",string_length(string_copy(pass, 0, 8))));
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if point_in_rectangle(mouse_x,mouse_y,_x-64,_y-64,_x+64,_y) && mouse_check_button_pressed(mb_left){
	write = true;
	keyboard_string = "";
}else if mouse_check_button_pressed(mb_left){
	write = false;
}

if point_in_rectangle(mouse_x,mouse_y,_x-64,_y,_x+64,_y+64) && mouse_check_button_pressed(mb_left){
	write1 = true;
	keyboard_string = "";
}else if mouse_check_button_pressed(mb_left){
	write1 = false;
}

if write = true{
user = keyboard_string;
}
if write1 = true{
pass = keyboard_string;
}
