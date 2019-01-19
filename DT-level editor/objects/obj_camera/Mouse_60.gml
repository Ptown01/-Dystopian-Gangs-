/// @description Insert description here
// You can write your code in this editor
zoomX -= 16;
zoomY -= 9;

if zoomX < 368{ zoomX = 368;}
if zoomY < 207{ zoomY = 207;}
var pm = matrix_build_projection_ortho(zoomX,zoomY,1,10000);
camera_set_proj_mat(camera,pm);