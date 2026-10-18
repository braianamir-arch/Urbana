// Gente y autos de una sola pieza (crowd.gd). Cada parte del modelo trae su número en UV2.x y el shader la
// pinta; las piernas y los brazos (UV2.y) se mueven acá, así el procesador arma una sola instancia por persona.
shader_type spatial;
uniform float night = 0.0;

// mismas paletas que PANTS, SKINS y HAIRS en agents.gd (más dos cascos para los de moto)
const vec3 PANTS[5] = vec3[](vec3(0.18, 0.25, 0.42), vec3(0.07, 0.07, 0.08), vec3(0.6, 0.55, 0.42), vec3(0.35, 0.35, 0.37), vec3(0.4, 0.5, 0.65));
const vec3 SKINS[5] = vec3[](vec3(0.95, 0.78, 0.65), vec3(0.87, 0.66, 0.5), vec3(0.72, 0.52, 0.38), vec3(0.55, 0.38, 0.26), vec3(0.38, 0.26, 0.18));
const vec3 HAIRS[8] = vec3[](vec3(0.06, 0.05, 0.05), vec3(0.2, 0.13, 0.08), vec3(0.38, 0.25, 0.15), vec3(0.82, 0.68, 0.42), vec3(0.7, 0.7, 0.7), vec3(0.55, 0.22, 0.1), vec3(0.1, 0.1, 0.12), vec3(0.85, 0.85, 0.88));

varying flat float part;
varying flat vec4 cu;

vec2 swing(vec2 v, float pivot, float a) {
	float dy = v.x - pivot;
	return vec2(pivot + dy * cos(a) - v.y * sin(a), dy * sin(a) + v.y * cos(a));
}

void vertex() {
	part = floor(UV2.x + 0.5);
	cu = INSTANCE_CUSTOM;
	float sw = floor(UV2.y + 0.5);
	if (cu.w < 0.5) {
		// persona: x = pantalón + 8 piel + 64 pelo, y = fase del paso, z = 1 mochila + 2 con los brazos arriba
		float flags = cu.z;
		float bag = mod(flags, 2.0);
		float panic = floor(flags / 2.0);
		if (part > 4.5 && part < 5.5 && bag < 0.5) {
			VERTEX = vec3(0.0, 0.6, 0.0);
		}
		if (sw > 0.5) {
			float s = sin(cu.y);
			if (sw < 2.5) {
				float a = s * 0.45 * (sw < 1.5 ? 1.0 : -1.0);
				vec2 yz = swing(VERTEX.yz, 0.5, a);
				VERTEX.yz = yz;
				NORMAL.yz = swing(NORMAL.yz, 0.0, a);
			} else {
				float a = panic > 0.5 ? (-2.6 + 0.2 * s * (sw < 3.5 ? 1.0 : -1.0)) : (-s * 0.4 * (sw < 3.5 ? 1.0 : -1.0));
				vec2 yz = swing(VERTEX.yz, 0.86, a);
				VERTEX.yz = yz;
				NORMAL.yz = swing(NORMAL.yz, 0.0, a);
			}
		}
	}
}

void fragment() {
	vec3 col = COLOR.rgb;
	float rough = 0.8;
	float metal = 0.0;
	vec3 emit = vec3(0.0);
	if (cu.w < 0.5) {
		float code = cu.x;
		float pi = mod(code, 8.0);
		float si = mod(floor(code / 8.0), 8.0);
		float hi = floor(code / 64.0);
		if (part > 0.5 && part < 1.5) {
			col = PANTS[int(pi)];
		} else if (part > 1.5 && part < 2.5) {
			col = SKINS[int(si)];
			rough = 0.6;
		} else if (part > 2.5 && part < 3.5) {
			col = HAIRS[int(hi)];
		} else if (part > 3.5 && part < 5.5) {
			col = part < 4.5 ? vec3(0.12, 0.1, 0.09) : vec3(0.15, 0.17, 0.2);
		} else if (part > 10.5) {
			col *= 0.88;
		}
	} else {
		// auto: x = techo (0 color del auto, 1 blanco, 2 negro), y = luces delanteras, z = traseras, w = 1 + cartel de taxi
		rough = 0.32;
		metal = 0.25;
		if (part > 3.5 && part < 4.5) {
			col = vec3(0.06, 0.06, 0.07);
			rough = 0.85;
			metal = 0.0;
		} else if (part > 5.5 && part < 6.5) {
			float fr = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
			col = mix(vec3(0.07, 0.09, 0.12), mix(vec3(0.55, 0.65, 0.78), vec3(0.04, 0.05, 0.08), night), 0.25 + 0.6 * fr);
			rough = 0.08;
		} else if (part > 6.5 && part < 7.5) {
			col = cu.x < 0.5 ? COLOR.rgb : (cu.x < 1.5 ? vec3(0.93, 0.93, 0.95) : vec3(0.08, 0.08, 0.1));
		} else if (part > 7.5 && part < 8.5) {
			col = vec3(1.0, 0.95, 0.75);
			emit = col * cu.y;
		} else if (part > 8.5 && part < 9.5) {
			col = vec3(0.9, 0.08, 0.06);
			emit = col * cu.z;
		} else if (part > 9.5 && part < 10.5) {
			col = vec3(1.0, 0.95, 0.7);
			emit = col * (0.5 + night * 2.2) * step(1.5, cu.w);
		}
	}
	ALBEDO = col;
	ROUGHNESS = rough;
	METALLIC = metal;
	EMISSION = emit;
}
