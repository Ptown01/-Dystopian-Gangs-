/// @description Insert description here
// You can write your code in this editor
macros();
world_ini();

square = ds_grid_create(6,0);

enum class{
	ground,
	building,
	selected
}
color[class.ground] = c_yellow;
color[class.building] = c_aqua;
color[class.selected] = c_lime;
prevClass = noone;

render_ = false;
grid = true;
outlines = true;
pressed = false;
add = false;

coord[0,0] = noone;
coord[0,1] = noone;
sqID = noone;