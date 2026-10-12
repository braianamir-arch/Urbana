shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix, fog_disabled;
uniform sampler2D ctex : filter_linear_mipmap, repeat_enable;
uniform float cover = 0.5;
uniform float night = 0.0;
varying vec3 wpos;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	float n = texture(ctex, wpos.xz * 0.0016 + vec2(TIME * 0.004, TIME * 0.0015)).r;
	float d = n;
	float a = smoothstep(1.0 - cover, 1.0 - cover + 0.22, d);
	float dist = length(wpos.xz - CAMERA_POSITION_WORLD.xz);
	a *= 1.0 - smoothstep(350.0, 800.0, dist);
	ALBEDO = mix(vec3(1.0, 1.0, 1.0) * (1.0 - cover * 0.25), vec3(0.08, 0.1, 0.17), night);
	ALPHA = a * 0.85;
}
