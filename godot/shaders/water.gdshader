// Agua de URBANA (etapa 1): olas con textura, color por profundidad, transparencia en la orilla,
// reflejo del cielo y brillo del sol (PBR), espuma en la orilla y anillos de lluvia.
shader_type spatial;

uniform float night = 0.0;
uniform vec4 hinfo = vec4(1.0, 0.0, 1.0, 0.0);
uniform sampler2D hmap : filter_linear, repeat_disable;
uniform sampler2D nrm_tex : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D foam_tex : filter_linear_mipmap, repeat_enable;
uniform vec2 wind_dir = vec2(1.0, 0.0);
uniform float rain = 0.0;     // 1 con lluvia o tormenta
uniform float layers = 2.0;   // 2 en Alta, 1 en Media
varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += sin(wpos.x * 0.21 + TIME * 1.1) * 0.06 + cos(wpos.z * 0.17 + TIME * 0.8) * 0.06;
}

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	float gh = texture(hmap, (wpos.xz + hinfo.y) / hinfo.x * hinfo.z + hinfo.w).r;
	float depth = max(-0.45 - gh, 0.0);
	vec2 p = wpos.xz;
	vec2 w = normalize(wind_dir + vec2(0.0001));

	// olas: una o dos capas de normales que se desplazan en direcciones distintas
	vec2 n1 = texture(nrm_tex, p * 0.035 + w * TIME * 0.018).rg * 2.0 - 1.0;
	vec2 nxy = n1;
	if (layers > 1.5) {
		vec2 n2 = texture(nrm_tex, p * 0.083 + vec2(-w.y, w.x) * TIME * 0.025 + 0.5).rg * 2.0 - 1.0;
		nxy = n1 * 0.6 + n2 * 0.5;
	}
	nxy *= 0.55;
	// anillos de lluvia: una gota por celda de 0,9 m que se repite cada ~1 s
	if (rain > 0.5) {
		vec2 cell = floor(p / 0.9);
		vec2 c = (cell + vec2(hash(cell), hash(cell + 7.1)) * 0.6 + 0.2) * 0.9;
		float ph = fract(TIME * 0.9 + hash(cell + 3.3));
		vec2 dv = p - c;
		float r = length(dv);
		float ring = sin((r - ph * 0.45) * 40.0) * smoothstep(0.08, 0.0, abs(r - ph * 0.45)) * (1.0 - ph);
		nxy += normalize(dv + vec2(0.0001)) * ring * 0.35;
	}
	vec3 nw = normalize(vec3(nxy.x, 1.0, nxy.y));
	NORMAL = normalize((VIEW_MATRIX * vec4(nw, 0.0)).xyz);

	// color: turquesa en la orilla, azul verdoso oscuro en lo hondo
	vec3 col = mix(vec3(0.10, 0.33, 0.32), vec3(0.015, 0.09, 0.13), smoothstep(0.0, 2.5, depth));
	col = mix(col, vec3(0.30, 0.34, 0.36), rain * 0.35);
	col = mix(col, vec3(0.01, 0.03, 0.06), night * 0.85);

	// espuma en la orilla (y en los pilares de los puentes, que también son "poco hondo")
	float band = 1.0 - smoothstep(0.0, 0.55, depth);
	float f = texture(foam_tex, p * 0.22 + w * TIME * 0.03).r;
	float pulse = 0.65 + 0.35 * sin(TIME * 1.3 - depth * 10.0 + f * 3.0);
	float foam = band * smoothstep(0.25, 0.65, f + band * 0.45) * pulse;
	foam *= 1.0 - night * 0.6;

	ALBEDO = mix(col, vec3(0.92, 0.95, 0.95), foam);
	ALPHA = max(mix(0.55, 0.97, smoothstep(0.0, 1.5, depth)), foam);
	ROUGHNESS = mix(0.07, 0.4, foam);
	METALLIC = 0.0;
	SPECULAR = 0.35;
}
