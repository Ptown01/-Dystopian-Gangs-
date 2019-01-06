/// @description Insert description here
// You can write your code in this editor
if ds_exists(list,ds_type_list){
	for(i = 0; i < rows;i++){
		draw_text(x,y+i*32,list[| ds_list_size(list)-1-i]);
	}
}