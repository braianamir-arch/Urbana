shader_type spatial;
uniform sampler2D dtex : filter_linear_mipmap, repeat_enable;
uniform sampler2D ctex : filter_linear, repeat_enable;
uniform float det = 1.0;
uniform float cshadow = 0.0;
varying vec3 wpos;
varying vec3 wnrm;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}
void fragment() {
	vec3 col = COLOR.rgb;
	float rough = 0.95;
	if (det > 0.0) {
		float n1 = texture(dtex, wpos.xz * 0.31).r;
		float n2 = texture(dtex, wpos.xz * 0.043).r;
		col *= (0.78 + 0.44 * n1) * (0.88 + 0.24 * n2);
		float slope = smoothstep(0.86, 0.7, wnrm.y);
		col = mix(col, vec3(0.42, 0.39, 0.35) * (0.8 + 0.4 * n1), slope * 0.8);
		float wb = 1.0 - smoothstep(0.0, 0.7, wpos.y + 0.45);
		col *= 1.0 - 0.35 * wb;
		rough = mix(rough, 0.5, wb);
	}
	if (cshadow > 0.0) {
		col *= 1.0 - cshadow * 0.3 * smoothstep(0.5, 0.7, texture(ctex, wpos.xz * 0.0045 + vec2(TIME * 0.012, TIME * 0.006)).r);
	}
	ALBEDO = col;
	ROUGHNESS = rough;
	SPECULAR = 0.1;
}
