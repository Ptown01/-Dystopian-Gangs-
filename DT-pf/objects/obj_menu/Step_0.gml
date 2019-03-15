/// @description Insert description here
// You can write your code in this editor
if triggered = false{
	timer++;
	if timer = 1*room_speed{
		timer = 0;
		triggered = choose(true,false);
	}
}
if triggered = true{
glowX = lerp(glowX,room_width+sprite_get_width(spr_glow)+1,.025);
}
if glowX > room_width+sprite_get_width(spr_glow){
	glowX = -sprite_get_width(spr_glow);
	triggered = false;
}