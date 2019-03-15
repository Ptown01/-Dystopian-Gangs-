//
// horizontal alpha gradient fade shader aligned to middle
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;


void main()
{
	float alpha = (abs(0.5-v_vTexcoord.x)-1.0)*-1.0/2.0;
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord);
	gl_FragColor.a = alpha;
}
