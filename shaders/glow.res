RSRC                    Shader                                                                       resource_local_to_scene    resource_name    code    custom_defines    script           res://shaders/glow.res �          Shader            shader_type canvas_item;

uniform vec4 glow_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float power : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	COLOR.rgb = mix(color, glow_color, power).rgb;
	COLOR.a = color.a;
} RSRC