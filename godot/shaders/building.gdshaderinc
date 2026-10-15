// Cuerpo común de building.gdshader (versión cerca) y building_lite.gdshader (media y lejana, con LITE).
uniform float night = 0.0;
uniform float late = 0.0;       // 1 de madrugada: menos ventanas encendidas
uniform float snow = 0.0;
uniform float wet = 0.0;
uniform float cshadow = 0.0;
uniform float ao_on = 0.0;
uniform float tex_on = 0.0;
uniform float wind = 0.0;       // 1 con viento (g_wind): mueve el follaje     // 0 en calidad Baja: colores lisos
uniform vec4 hinfo = vec4(1.0, 0.0, 1.0, 0.0);
uniform sampler2D hmap : filter_linear, repeat_disable;
uniform sampler2D ctex : filter_linear, repeat_enable;
uniform sampler2DArray alb_arr : filter_linear_mipmap, repeat_enable;
uniform sampler2DArray nrm_arr : hint_normal, filter_linear_mipmap, repeat_enable;

varying vec3 wpos;
varying vec3 wnrm;
// planas: interpoladas cambiaban en los últimos decimales de un píxel a otro y el azar de las
// ventanas se volvía granulado
varying flat float vmat;
varying flat float vtm;
varying flat vec4 cust;

// color medio de cada capa (sirve sin texturas y en las fachadas lejanas, para que no cambie el tono)
const vec3 BASE[13] = vec3[](
	vec3(0.776), vec3(0.583, 0.457, 0.387), vec3(0.798), vec3(0.388, 0.377, 0.357),
	vec3(0.459, 0.270, 0.177), vec3(0.799), vec3(0.309, 0.210, 0.189), vec3(0.799),
	vec3(0.166, 0.168, 0.156), vec3(0.624, 0.605, 0.552), vec3(0.474, 0.399, 0.313), vec3(0.795),
	vec3(0.396, 0.516, 0.168));
const float ROUGH[13] = float[](0.8, 0.58, 0.79, 0.69, 0.7, 0.41, 0.73, 0.65, 0.44, 0.53, 0.62, 0.54, 0.7);
// tamaño en metros de una repetición de la textura
const float SCALE[13] = float[](2.0, 0.85, 1.5, 1.6, 0.9, 1.0, 1.1, 1.0, 3.0, 1.2, 1.0, 1.2, 2.0);
// ganancia por capa (el hormigón de la foto es oscuro; chapa y metal se ven muy claros)
const float GAIN[13] = float[](1.0, 1.0, 1.0, 1.25, 1.0, 0.68, 1.0, 0.85, 1.0, 1.0, 1.0, 1.0, 1.0);
// segundo color (persianas, toldos, carteles, portones)
const vec3 ACCENT[8] = vec3[](
	vec3(0.18, 0.36, 0.24), vec3(0.45, 0.28, 0.16), vec3(0.62, 0.16, 0.14), vec3(0.16, 0.28, 0.5),
	vec3(0.85, 0.82, 0.74), vec3(0.2, 0.22, 0.24), vec3(0.75, 0.55, 0.15), vec3(0.32, 0.46, 0.5));

void vertex() {
	// follaje: se mece con el viento (más arriba, más), cada árbol con su fase
	if (wind > 0.0 && int(UV2.x + 0.5) == 11) {
		float ph = MODEL_MATRIX[3].x * 0.35 + MODEL_MATRIX[3].z * 0.27;
		float a = max(VERTEX.y - 0.8, 0.0) * wind;
		VERTEX.x += sin(TIME * 1.7 + ph) * 0.05 * a;
		VERTEX.z += cos(TIME * 1.3 + ph) * 0.035 * a;
	}
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	vmat = UV2.x;
	vtm = UV2.y;
	cust = INSTANCE_CUSTOM;
}

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

// reflejo aproximado: cielo arriba, otros edificios cerca del horizonte
vec3 mirror(vec3 wp, vec3 n, vec3 cp, float nt) {
	vec3 r = reflect(normalize(wp - cp), n);
	vec3 sky = mix(vec3(0.78, 0.84, 0.9), vec3(0.36, 0.52, 0.78), clamp(r.y * 1.6, 0.0, 1.0));
	sky = mix(sky, vec3(0.03, 0.04, 0.08), nt);
	float a = atan(r.z, r.x) * 9.0;
	float hb = 0.04 + 0.3 * hash(vec2(floor(a), 5.0));
	vec3 bc = mix(vec3(0.42, 0.42, 0.44), vec3(0.03, 0.035, 0.05), nt);
	return mix(sky, bc, step(r.y, hb));
}

void fragment() {
	int m = int(vmat + 0.5);
	vec3 col;
	float rough;
	float metal = 0.0;
	vec3 emit = vec3(0.0);
	bool glass = m == 20 || m == 21;
	bool up = wnrm.y > 0.7;
	vec2 wid = vec2(0.0);
	vec2 wf = vec2(0.5);
	int tmi = int(vtm + 0.5);
	bool shutpx = false;
	if (m >= 30) {
		// fachada media/lejana: ventanas dibujadas sobre una grilla (columna, piso)
		int b = clamp(m - 30, 0, 12);
		if (tex_on > 0.5) {
			vec2 hh = normalize(vec2(wnrm.z, -wnrm.x) + vec2(0.0001));
			vec2 uvm = abs(wnrm.y) < 0.7 ? vec2(dot(wpos.xz, hh), -wpos.y) : wpos.xz;
			vec4 t = texture(alb_arr, vec3(uvm / SCALE[b], float(b)));
			col = t.rgb * GAIN[b];
			rough = t.a;
		} else {
			col = BASE[b] * GAIN[b];
			rough = ROUGH[b];
		}
		wid = floor(UV);
		wf = fract(UV);
		bool shop = (tmi & 8) != 0 && wid.y < 0.5;
		vec4 wr = shop ? vec4(0.08, 0.92, 0.1, 0.74) : vec4(0.27, 0.73, 0.26, 0.84);
		if (wf.x > wr.x && wf.x < wr.y && wf.y > wr.z && wf.y < wr.w) {
			glass = true;
			wf = vec2((wf.x - wr.x) / (wr.y - wr.x), (wf.y - wr.z) / (wr.w - wr.z));
		} else if ((tmi & 4) != 0 && !shop && wf.y > 0.26 && wf.y < 0.84 && ((wf.x > 0.1 && wf.x < 0.27) || (wf.x > 0.73 && wf.x < 0.9))) {
			shutpx = true;
		}
		tmi = tmi & 3;
		m = b;
	} else if (glass) {
		wid = floor(UV);
		wf = fract(UV);
	} else if (m >= 22) {
		// 22 oscuro, 23 brillo de noche (faroles), 24 luz de semáforo
		col = vec3(0.07, 0.075, 0.08);
		rough = 0.5;
		if (m == 23) {
			col = vec3(0.92, 0.88, 0.76);
			emit += vec3(1.0, 0.82, 0.55) * night * 2.2;
		}
	} else {
		if (tex_on > 0.5) {
			vec3 uvw = vec3(UV / SCALE[m], float(m));
			vec4 t = texture(alb_arr, uvw);
			col = t.rgb * GAIN[m];
			rough = t.a;
#ifndef LITE
			NORMAL_MAP = texture(nrm_arr, uvw).rgb;
			NORMAL_MAP_DEPTH = 0.8;
#endif
		} else {
			col = BASE[m] * GAIN[m];
			rough = ROUGH[m];
		}
	}
	if (!glass && m < 22) {
		if (shutpx) {
			col = ACCENT[int(cust.y * 8.0 + 0.5) % 8] * 0.8;
		} else if (tmi == 1) {
			col *= COLOR.rgb * 1.15;
		} else if (tmi == 2) {
			col *= ACCENT[int(cust.y * 8.0 + 0.5) % 8] * 1.25;
		}
		if (m == 7) {
			metal = 0.3;
		}
	}
	if (glass) {
		// vidrio: interior oscuro con cortinas, reflejo del cielo (más en los espejados) y de noche luz
		vec2 id = wid + floor(vec2(cust.z * 97.0, cust.z * 31.0));
		float fr = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
		vec3 inside = vec3(0.07, 0.075, 0.08);
		float h = hash(id + 3.7);
		if (h > 0.55 && wf.y > 0.5 - 0.3 * hash(id + 9.1)) {
			inside = mix(inside, vec3(0.72, 0.68, 0.6), 0.6);
		}
		inside *= 1.0 - night * 0.6;
#ifdef LITE
		vec3 refl = mix(vec3(0.62, 0.7, 0.8), vec3(0.03, 0.04, 0.08), night);
#else
		vec3 refl = mirror(wpos, wnrm, CAMERA_POSITION_WORLD, night);
#endif
		float k = vmat > 20.5 && vmat < 21.5 ? 0.82 : 0.25 + 0.6 * fr;
		// el vidrio toma un poco el color del edificio (espejados azulados, verdosos, dorados)
		refl *= mix(vec3(1.0), COLOR.rgb * 1.4, 0.4);
		col = mix(inside, refl, k);
		rough = 0.06;
		float litp = 0.55 * (1.0 - 0.45 * late);
		float lit = step(hash(id + 1.3), litp);
		if (h > 0.55 && wf.y > 0.5) {
			lit *= 0.5;
		}
		vec3 wc = mix(vec3(1.0, 0.76, 0.42), vec3(0.72, 0.86, 1.0), step(0.8, hash(id + 7.3)));
		emit += wc * lit * night * 1.2 * (1.0 - cust.x);
	}
	// nieve también en techos a dos aguas (hasta ~60°); SNOW_NY en buildings.gd
	if (snow > 0.0 && wnrm.y > 0.5 && !glass) {
		col = mix(col, vec3(0.94, 0.95, 1.0), snow);
		rough = 0.8;
	}
	if (wet > 0.0 && !glass) {
		float wk = up ? 1.0 : 0.6;
		col *= 1.0 - 0.35 * wet * wk;
		rough = mix(rough, 0.15, wet * 0.8 * wk);
	}
	if (cust.x > 0.5) {
		col *= 0.4;
		emit *= 0.0;
	}
	if (cshadow > 0.0 && wnrm.y > -0.3) {
		col *= 1.0 - cshadow * 0.3 * smoothstep(0.5, 0.7, texture(ctex, wpos.xz * 0.0045 + vec2(TIME * 0.012, TIME * 0.006)).r);
	}
	if (ao_on > 0.0 && abs(wnrm.y) < 0.6) {
		float g = texture(hmap, (wpos.xz + hinfo.y) / hinfo.x * hinfo.z + hinfo.w).r;
		col *= mix(0.6, 1.0, smoothstep(0.0, 1.6, wpos.y - g));
	}
	ALBEDO = col;
	ROUGHNESS = rough;
	METALLIC = metal;
	SPECULAR = rough < 0.45 ? 0.5 : 0.2;
	EMISSION = emit;
}
