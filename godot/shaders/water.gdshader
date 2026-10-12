shader_type spatial;
uniform float night = 0.0;
uniform vec4 hinfo = vec4(1.0, 0.0, 1.0, 0.0);
uniform sampler2D hmap : filter_linear, repeat_disable;
varying vec3 wpos;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += sin(wpos.x * 0.21 + TIME * 1.1) * 0.06 + cos(wpos.z * 0.17 + TIME * 0.8) * 0.06;
}
void fragment() {
	float gh = texture(hmap, (wpos.xz + hinfo.y) / hinfo.x * hinfo.z + hinfo.w).r;
	float depth = max(-0.45 - gh, 0.0);
	vec3 day = mix(vec3(0.2, 0.52, 0.55), vec3(0.07, 0.27, 0.45), smoothstep(0.0, 2.5, depth));
	vec3 dark = vec3(0.02, 0.06, 0.13);
	float foam = (1.0 - smoothstep(0.0, 0.55, depth)) * (0.55 + 0.45 * sin(TIME * 1.5 + wpos.x * 2.1 + wpos.z * 1.7));
	ALBEDO = mix(day, dark, night) + vec3(foam) * 0.55 * (1.0 - night * 0.7);
	// olas: dos capas de ondas que se cruzan y mueven la normal (sin tocar la malla)
	vec2 p = wpos.xz;
	float a1 = p.x * 0.55 + p.y * 0.31 + TIME * 0.9;
	float a2 = p.x * -0.27 + p.y * 0.62 - TIME * 0.7;
	float a3 = p.x * 1.3 - p.y * 1.1 + TIME * 1.6;
	vec2 g = vec2(cos(a1) * 0.55 - cos(a2) * 0.27 + cos(a3) * 0.5, cos(a1) * 0.31 + cos(a2) * 0.62 - cos(a3) * 0.4);
	NORMAL = normalize(NORMAL + vec3(g.x, 0.0, g.y) * 0.1);
	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
	ALBEDO = mix(ALBEDO, ALBEDO * 1.25 + vec3(0.03, 0.06, 0.08), fres * (1.0 - night));
	ROUGHNESS = 0.12;
	SPECULAR = 0.5;
	METALLIC = 0.1;
}
