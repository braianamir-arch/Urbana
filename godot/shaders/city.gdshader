shader_type spatial;
uniform float night = 0.0;
uniform float snow = 0.0;
uniform float wet = 0.0;
uniform float wind = 0.0;
uniform float ao_on = 0.0;
uniform vec4 hinfo = vec4(1.0, 0.0, 1.0, 0.0);
uniform sampler2D hmap : filter_linear, repeat_disable;
uniform sampler2D dtex : filter_linear_mipmap, repeat_enable;
uniform sampler2D ctex : filter_linear, repeat_enable;
uniform float det = 0.0;
uniform float cshadow = 0.0;
// etapa 2: asfalto (cust.w = -20) y vereda (-21) con las texturas de la ciudad
uniform float tex_on = 0.0;
uniform sampler2DArray alb_arr : filter_linear_mipmap, repeat_enable;
uniform sampler2DArray nrm_arr : hint_normal, filter_linear_mipmap, repeat_enable;
varying vec3 wpos;
varying vec3 wnrm;
varying vec4 cust;
// posición dentro de la celda (las calles van sin rotar): para pintar las marcas del asfalto
varying vec2 rloc;
void vertex() {
	if (INSTANCE_CUSTOM.w >= 2.0 && wind > 0.0) {
		vec3 org = MODEL_MATRIX[3].xyz;
		float sc = max(length(MODEL_MATRIX[0].xyz), 0.001);
		float amp = (INSTANCE_CUSTOM.w - 2.0) * wind;
		float k = clamp(VERTEX.y + 0.5, 0.0, 1.0);
		float t = TIME * 1.7 + org.x * 0.35 + org.z * 0.27;
		VERTEX.x += sin(t) * amp * k / sc;
		VERTEX.z += cos(t * 0.83) * amp * 0.7 * k / sc;
	}
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	cust = INSTANCE_CUSTOM;
	rloc = wpos.xz - MODEL_MATRIX[3].xz;
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
// banda suave de medio ancho hw alrededor de c
float band(float x, float c, float hw) {
	float aa = fwidth(x) + 0.002;
	return 1.0 - smoothstep(hw - aa, hw + aa, abs(x - c));
}
// etapa 3: marcas del asfalto. code = calles vecinas (bits 0-3: E O S N) + cruces vecinos (bits 4-7);
// rt = tipo de calle (2 común, 3 avenida, 4 autopista). La celda mide 4 m; la calzada va de -1,52 a 1,52.
vec3 road_marks(vec3 col, vec2 p, vec3 org, int code, int rt) {
	int m = code & 15;
	int xm = (code >> 4) & 15;
	bool horiz = (m & 3) != 0 && (m & 12) == 0;
	bool vert = (m & 12) != 0 && (m & 3) == 0;
	// parches y una tapa de alcantarilla en algunas celdas
	float hp = hash(floor((org.xz + p) / 1.7) + org.xz * 0.013);
	col *= hp > 0.86 ? 0.88 : 1.0;
	if (hash(org.xz * 0.37 + 1.3) < 0.22) {
		vec2 mc = vec2(hash(org.xz + 4.1) - 0.5, hash(org.xz + 7.7) - 0.5) * 1.6;
		float r = length(p - mc);
		col = mix(col, vec3(0.13, 0.13, 0.14), band(r, 0.0, 0.3));
		col *= 1.0 - 0.35 * band(r, 0.3, 0.025);
	}
	if (!horiz && !vert) {
		return col;
	}
	float a = horiz ? p.x : p.y;
	float b = horiz ? p.y : p.x;
	// manchas de aceite y huella de las ruedas en el medio de cada carril
	col *= 1.0 - 0.07 * band(abs(b), 0.78, 0.2);
	float paint = 0.0;
	vec3 pc = vec3(0.88, 0.88, 0.84);
	float near_x = 0.0;
	for (int d = 0; d < 4; d++) {
		if ((xm & (1 << d)) == 0) {
			continue;
		}
		vec2 dv = d == 0 ? vec2(1.0, 0.0) : d == 1 ? vec2(-1.0, 0.0) : d == 2 ? vec2(0.0, 1.0) : vec2(0.0, -1.0);
		float s = dot(p, dv);
		float bb = dot(p, vec2(-dv.y, dv.x));
		near_x = max(near_x, step(0.55, s));
		// senda peatonal (barras paralelas al tránsito) y línea de pare del lado derecho
		float zeb = step(0.9, s) * step(s, 1.85) * step(abs(bb), 1.42) * step(fract(bb / 0.5 + 0.25), 0.5);
		float stop = band(s, 0.68, 0.08) * step(0.0, bb) * step(bb, 1.42);
		paint = max(paint, max(zeb, stop));
	}
	if (rt == 2) {
		paint = max(paint, band(b, 0.0, 0.055) * step(fract(a / 2.0 + 0.25), 0.5) * (1.0 - near_x));
	} else if (rt >= 3) {
		paint = max(paint, band(abs(b), 1.4, 0.045) * (1.0 - near_x));
	}
	paint *= 0.78 + 0.22 * hash(floor((org.xz + p) * 7.0));
	return mix(col, pc, paint * 0.85);
}
vec3 mirror(vec3 wp, vec3 n, vec3 cp, float nt) {
	vec3 r = reflect(normalize(wp - cp), n);
	vec3 sky = mix(vec3(0.82, 0.88, 0.95), vec3(0.32, 0.52, 0.85), clamp(r.y * 1.6, 0.0, 1.0));
	sky = mix(sky, vec3(0.04, 0.06, 0.12), nt);
	float a = atan(r.z, r.x) * 9.0;
	float hb = 0.04 + 0.32 * hash(vec2(floor(a), 5.0));
	vec3 bc = mix(vec3(0.42, 0.44, 0.48), vec3(0.03, 0.035, 0.05), nt);
	bc += vec3(1.0, 0.8, 0.5) * nt * step(0.6, hash(floor(vec2(fract(a) * 6.0, r.y * 60.0)))) * 0.6;
	return mix(sky, bc, step(r.y, hb));
}
void fragment() {
	vec3 col = COLOR.rgb;
	float rough = 0.85;
	vec3 emit = vec3(0.0);
	float metal0 = 0.0;
	if (cust.w < -0.5) {
		int mi = int(-cust.w + 0.5);
		vec2 tt = length(wnrm.xz) > 0.15 ? normalize(vec2(-wnrm.z, wnrm.x)) : vec2(1.0, 0.0);
		bool side = abs(wnrm.y) < 0.75;
		vec2 mu = (side || mi == 4) ? vec2(dot(wpos.xz, tt), wpos.y) : wpos.xz;
		float fw = clamp(1.0 - max(fwidth(mu.x), fwidth(mu.y)) * 3.0, 0.0, 1.0);
		if (mi == 1) {
			if (side) {
				float row = floor(mu.y / 0.17);
				float bxp = (mu.x + mod(row, 2.0) * 0.21) / 0.42;
				vec2 bf = vec2(fract(bxp), fract(mu.y / 0.17));
				col *= 0.8 + 0.34 * hash(vec2(floor(bxp), row)) * fw + 0.17 * (1.0 - fw);
				col = mix(col, vec3(0.7, 0.66, 0.6), max(step(bf.x, 0.07), step(bf.y, 0.15)) * 0.7 * fw);
			}
			rough = 0.95;
		} else if (mi == 2) {
			float sl = mu.x / 0.15;
			col *= (0.8 + 0.32 * hash(vec2(floor(sl), 1.0))) * (0.93 + 0.07 * sin(mu.y * 11.0 + floor(sl) * 3.0));
			col *= 1.0 - step(0.86, fract(sl)) * 0.6 * fw;
			rough = 0.7;
		} else if (mi == 3) {
			vec2 pc = mu / vec2(1.6, 0.9);
			vec2 pf = fract(pc);
			col *= 0.9 + 0.12 * hash(floor(pc));
			col *= 1.0 - max(step(pf.x, 0.02), step(pf.y, 0.035)) * 0.28 * fw;
			rough = 0.92;
		} else if (mi == 4) {
			vec2 tc = mu / vec2(0.32, 0.2);
			vec2 tf = fract(tc);
			float tl = (0.72 + 0.38 * sin(tf.x * 3.14159)) * (0.78 + 0.22 * tf.y) * (0.9 + 0.2 * hash(floor(tc)));
			col *= mix(0.92, tl, fw);
			rough = 0.8;
		} else if (mi == 5) {
			col *= 1.0 - step(0.5, fract(mu.x / 0.16)) * 0.3 * fw;
			rough = 0.62;
			metal0 = 0.12;
		} else if (mi == 6 || mi == 8) {
			if (side) {
				float fin;
				vec3 fincol;
				if (mi == 6) {
					float fl = fract(mu.x / 0.24);
					fin = step(fl, 0.68);
					fincol = col * (0.8 + 0.4 * sin(fl / 0.68 * 3.14159));
				} else {
					vec2 mf = fract(mu / vec2(1.2, 2.6));
					fin = max(step(mf.x, 0.04), step(mf.y, 0.03));
					fincol = vec3(0.06);
				}
				fin = mix(0.55, fin, fw);
				vec3 glass = mi == 8 ? mirror(wpos, wnrm, CAMERA_POSITION_WORLD, night) * 0.85 : vec3(0.1, 0.085, 0.075);
				float litw = step(0.4, hash(floor(mu / vec2(1.2, 1.3)) + floor(wpos.xz * 0.07)));
				col = mix(glass, fincol, fin);
				emit += vec3(1.0, 0.75, 0.45) * litw * night * (1.0 - fin) * (mi == 8 ? 1.1 : 0.8);
				rough = mix(0.08, 0.7, fin);
			}
		} else if (mi == 20 || mi == 21) {
			// calle: la foto, con el tono de cada tipo de calle (el color de la instancia relativo al de base)
			if (tex_on > 0.5) {
				bool asph = mi == 20;
				vec3 uvw = vec3(wpos.xz / (asph ? 3.0 : 1.2), asph ? 8.0 : 9.0);
				vec4 t = texture(alb_arr, uvw);
				col = t.rgb * COLOR.rgb / (asph ? vec3(0.23) : vec3(0.62, 0.6, 0.56)) * (asph ? 1.25 : 1.0);
				rough = t.a;
				// mojado: más oscuro (el brillo lo pone la rugosidad más abajo)
				col *= 1.0 - (asph ? 0.3 : 0.38) * wet;
			}
			if (mi == 20 && cust.y < -0.5 && wnrm.y > 0.7) {
				col = road_marks(col, rloc, vec3(wpos.x - rloc.x, 0.0, wpos.z - rloc.y), int(-cust.y + 0.5) - 1, int(-cust.z + 0.5));
			}
		} else if (mi == 7) {
			vec2 sc = vec2(mu.x / 1.1 + mod(floor(mu.y / 0.55), 2.0) * 0.5, mu.y / 0.55);
			vec2 sf = fract(sc);
			col *= 0.92 + 0.12 * hash(floor(sc));
			col *= 1.0 - max(step(sf.x, 0.02), step(sf.y, 0.04)) * 0.2 * fw;
			rough = 0.75;
		}
	}
	if (cust.x > 0.0 && abs(wnrm.y) < 0.3) {
		vec2 t = normalize(vec2(-wnrm.z, wnrm.x));
		vec2 uv = vec2(dot(wpos.xz, t), wpos.y);
		vec2 cell = vec2(uv.x / 1.15, (uv.y - 0.3) / 1.25);
		vec2 f = fract(cell);
		float outer = step(0.1, f.x) * step(f.x, 0.9) * step(0.12, f.y) * step(f.y, 0.88);
		float wm = cust.x >= 1.25 ? 0.06 : 0.18;
		float wv = cust.x >= 1.25 ? 0.1 : 0.22;
		float win = step(wm, f.x) * step(f.x, 1.0 - wm) * step(wv, f.y) * step(f.y, 1.0 - wv);
		if (win > 0.5) {
			float gk = smoothstep(0.0, 1.0, f.y);
			vec3 glass = mix(vec3(0.13, 0.2, 0.3), vec3(0.5, 0.64, 0.78), gk * gk) * (1.0 - night * 0.75);
			glass += vec3(0.16) * smoothstep(0.16, 0.0, abs(f.x - f.y * 0.7 - 0.12)) * (1.0 - night);
			if (cust.x >= 1.25) { glass = mix(glass, mirror(wpos, wnrm, CAMERA_POSITION_WORLD, night) * mix(vec3(1.0), COLOR.rgb * 1.5, 0.35), 0.75); }
			float bl = hash(floor(cell) + 3.7);
			if (bl > 0.72 && f.y > 0.5 - 0.3 * hash(floor(cell) + 9.1)) { glass = mix(glass, vec3(0.78, 0.74, 0.66) * (1.0 - night * 0.7), 0.75); }
			col = mix(col, glass, 0.88 * min(cust.x, 1.0));
			rough = 0.18;
			float lit = step(0.5, hash(floor(cell) + floor(wpos.xz * 0.11)));
			if (bl > 0.72 && f.y > 0.55) { lit *= 0.45; }
			vec3 wc = mix(vec3(1.0, 0.78, 0.45), vec3(0.72, 0.86, 1.0), step(0.82, hash(floor(cell) + 7.3)));
			emit += wc * lit * night * 1.15;
		} else if (outer > 0.5) {
			col *= f.y < 0.22 ? 1.1 : 0.72;
		} else if (f.y > 0.93 || f.y < 0.05) {
			col *= 0.86;
		}
	}
	if (cust.y > 0.0) { emit += COLOR.rgb * cust.y * (0.15 + night * 2.0); }
	if (cust.z > 0.0) { emit += COLOR.rgb * cust.z; }
	if (det > 0.0 && cust.y <= 0.0 && cust.z <= 0.0 && cust.w > -0.5) {
		vec2 uvd = abs(wnrm.y) > 0.5 ? wpos.xz * 0.8 : vec2(wpos.x + wpos.z, wpos.y) * 0.8;
		float gr = texture(dtex, uvd).r;
		col *= 0.93 + 0.14 * gr;
		if (abs(wnrm.y) > 0.5) { col *= 0.93 + 0.14 * gr; }
		rough = clamp(rough + (gr - 0.5) * 0.25, 0.3, 1.0);
	}
	if (abs(wnrm.y) < 0.5 && cust.x > 0.0) {
		col *= mix(0.86, 1.05, clamp(wpos.y / 22.0, 0.0, 1.0));
	}
	if (snow > 0.0 && wnrm.y > 0.7 && (cust.w < 0.5 || cust.w >= 2.0)) { col = mix(col, vec3(0.94, 0.95, 1.0), snow); }
	if (wnrm.y > 0.7) {
		float lum = dot(col, vec3(0.33, 0.33, 0.33));
		if (lum < 0.3 && cust.x <= 0.0) {
			// asfalto: algo de brillo, más con lluvia
			rough = mix(0.82, 0.14, wet);
			col *= 1.0 - 0.25 * wet;
		} else if (cust.x <= 0.0) {
			rough = mix(0.9, 0.5, wet);
		}
	}
	if (cshadow > 0.0 && wnrm.y > 0.3) {
		col *= 1.0 - cshadow * 0.3 * smoothstep(0.5, 0.7, texture(ctex, wpos.xz * 0.0045 + vec2(TIME * 0.012, TIME * 0.006)).r);
	}
	if (ao_on > 0.0 && abs(wnrm.y) < 0.6) {
		float g = texture(hmap, (wpos.xz + hinfo.y) / hinfo.x * hinfo.z + hinfo.w).r;
		col *= mix(0.58, 1.0, smoothstep(0.0, 1.8, wpos.y - g));
	}
	float metal = metal0;
	if (cust.w > 1.2 && cust.w < 1.8) {
		rough = mix(0.22, 0.12, wet);
		metal = 0.35;
		float fr = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
		col += vec3(0.5, 0.62, 0.8) * fr * 0.4 * (1.0 - night);
		col += vec3(0.6) * step(0.965, hash(floor(wpos.xz * 22.0 + wpos.y * 11.0))) * wet * 0.5;
	}
	ALBEDO = col;
	ROUGHNESS = rough;
	METALLIC = metal;
	SPECULAR = rough < 0.45 ? 0.5 : 0.12;
	EMISSION = emit;
}
