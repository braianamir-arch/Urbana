// Edificios de URBANA (etapa 2): color por material (UV2.x), tinte por instancia según la máscara
// (UV2.y: 0 sin tinte, 1 color del edificio, 2 segundo color) y quemado (INSTANCE_CUSTOM.x).
shader_type spatial;

uniform float night = 0.0;
varying float vmat;
varying float vtm;
varying vec4 cust;

// colores lisos por material (calidad Baja o sin texturas)
const vec3 BASE[14] = vec3[](
	vec3(0.80), vec3(0.62, 0.33, 0.24), vec3(0.88, 0.86, 0.82), vec3(0.62, 0.62, 0.6),
	vec3(0.62, 0.3, 0.2), vec3(0.62, 0.64, 0.66), vec3(0.5, 0.34, 0.22), vec3(0.3, 0.31, 0.33),
	vec3(0.22, 0.22, 0.24), vec3(0.62, 0.6, 0.56), vec3(0.12, 0.16, 0.2), vec3(0.3, 0.38, 0.46),
	vec3(0.1), vec3(0.8));
// segundo color (persianas, toldos, carteles)
const vec3 ACCENT[8] = vec3[](
	vec3(0.18, 0.36, 0.24), vec3(0.45, 0.28, 0.16), vec3(0.62, 0.16, 0.14), vec3(0.16, 0.28, 0.5),
	vec3(0.85, 0.82, 0.74), vec3(0.2, 0.22, 0.24), vec3(0.75, 0.55, 0.15), vec3(0.32, 0.46, 0.5));

void vertex() {
	vmat = UV2.x;
	vtm = UV2.y;
	cust = INSTANCE_CUSTOM;
}

void fragment() {
	int m = int(vmat + 0.5);
	vec3 col = BASE[clamp(m, 0, 13)];
	if (vtm > 0.5 && vtm < 1.5) {
		col *= COLOR.rgb * 1.15;
	} else if (vtm > 1.5) {
		col = ACCENT[int(cust.y * 8.0 + 0.5) % 8];
	}
	float rough = 0.85;
	if (m == 10 || m == 11) {
		rough = 0.1;
	}
	if (cust.x > 0.5) {
		col *= 0.4;
	}
	ALBEDO = col;
	ROUGHNESS = rough;
	SPECULAR = rough < 0.45 ? 0.5 : 0.12;
}
