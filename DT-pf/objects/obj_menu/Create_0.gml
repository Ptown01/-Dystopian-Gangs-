/// @description Init menu
pages = 2;
max_buttons = 4;
functions = 3;

current_page = 0;

menu = create_3d_grid(pages,max_buttons,functions);

set_3d_grid(0,0,1,max_buttons,menu,"PLAY");
set_3d_grid(0,0,2,max_buttons,menu,scr_play);
set_3d_grid(0,1,1,max_buttons,menu,"SETTINGS");
set_3d_grid(0,1,2,max_buttons,menu,scr_null);
set_3d_grid(0,2,1,max_buttons,menu,"QUIT");
set_3d_grid(0,2,2,max_buttons,menu,scr_quit);

buttons = 3;

yy = room_height/2-buttons*font_get_size(fnt_menu)/2;

hovered = false;

recY1 = 0;
recY2 = 0;
recY1_ = 0;
recY2_ = 0;

alarmID = 0;

for(i = 0; i < max_buttons;i++){
	pressed[i] = false;
}

audio_play_sound(snd_menu,0,true);