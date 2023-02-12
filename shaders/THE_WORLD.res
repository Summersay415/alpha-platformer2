RSRC                    Shader                                                                       resource_local_to_scene    resource_name    code    custom_defines    script           res://shaders/THE_WORLD.res �          Shader          �  shader_type canvas_item;

render_mode unshaded;

uniform sampler2D distortion;
uniform float dist_power = 0.1;

void fragment() {
	vec2 scr_uv = SCREEN_UV + texture(distortion, UV).b * dist_power;
	vec4 scr_clr = vec4(1.0) - textureLod(SCREEN_TEXTURE, scr_uv, 0.0);
	scr_clr = mix(scr_clr, vec4(1), (abs(UV.x - 0.5) + abs(UV.y - 0.5)) * 2.0);
	COLOR.rgb = scr_clr.rgb;
	COLOR.a = texture(TEXTURE, UV).a;
} RSRC