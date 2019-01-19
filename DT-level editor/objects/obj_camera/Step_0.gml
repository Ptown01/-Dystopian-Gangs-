/// @description Insert description here
// You can write your code in this editor
	if mouse_check_button_pressed(mb_left){
		xTo = mouse_x;
		yTo = mouse_y;
	}
if mouse_check_button(mb_left) && keyboard_check(vk_space){
	x = x+lengthdir_x(point_distance(xTo,yTo,mouse_x,mouse_y),point_direction(xTo,yTo,mouse_x,mouse_y)-180);
	y = y+lengthdir_y(point_distance(xTo,yTo,mouse_x,mouse_y),point_direction(xTo,yTo,mouse_x,mouse_y)-180);
}

var vm = matrix_build_lookat(x,y,-10,x,y,0,0,1,0);
camera_set_view_mat(camera,vm);