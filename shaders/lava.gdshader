shader_type canvas_item;
render_mode unshaded;

uniform float time_mul = 0.5;
uniform vec2 dist_dir;
uniform float dist_n = 0.01;
uniform float time_mul_n = 0.5;
uniform vec2 dist_n_dir;
uniform vec4 rounds_color : hint_color;
uniform sampler2D lava_mask;
uniform sampler2D lava_uv_mask;

void fragment() {
	vec2 uv_n = UV + texture(lava_uv_mask, UV + TIME * time_mul_n * dist_n_dir).rg * dist_n;
	vec4 base = texture(TEXTURE, uv_n);
	vec4 rounds = texture(lava_mask, uv_n + TIME * time_mul * dist_dir);
	rounds = vec4(1, 1, 1, rounds.r);
	COLOR = mix(base, rounds.r * rounds_color, rounds.a * base.a);
}