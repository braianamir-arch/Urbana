// Terreno de URBANA (etapa 1): mezcla de texturas fotográficas según el mapa "splat"
// (R pasto, G arena, B roca, A tierra), con estación, nieve y anti-repetición.
// Calidad Baja usa terrain_simple.gdshader.
shader_type spatial;

uniform sampler2D splat : filter_linear, repeat_disable;
uniform vec4 hinfo = vec4(1.0, 0.0, 1.0, 0.0);
uniform sampler2D alb_grass : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D alb_dry : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D alb_dirt : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D alb_rock : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D alb_sand : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D alb_snow : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D nrm_grass : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D nrm_dirt : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D nrm_rock : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D nrm_sand : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D dtex : filter_linear_mipmap, repeat_enable;   // ruido grande para variación y anti-repetición
uniform sampler2D ctex : filter_linear, repeat_enable;          // sombras de nubes
uniform float cshadow = 0.0;
uniform float season_dry = 0.0;  // 0 verde, 1 pasto seco
uniform float snow = 0.0;
uniform float tile_rand = 1.0;   // anti-repetición (Alta y Media)
uniform float far = 0.0;         // 1 = anillo lejano del horizonte (sin splat)

varying vec3 wpos;
varying vec3 wnrm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// muestreo sin repetición visible: dos lecturas con desplazamientos elegidos por un ruido grande,
// fundidas suavemente (técnica de Íñigo Quílez)
vec2 offs(float i) { return sin(vec2(3.0, 7.0) * i); }
vec4 norep(sampler2D t, vec2 uv, float k, vec2 dx, vec2 dy) {
	if (tile_rand < 0.5) {
		return textureGrad(t, uv, dx, dy);
	}
	float l = k * 8.0;
	float ia = floor(l);
	float f = fract(l);
	vec4 a = textureGrad(t, uv + offs(ia), dx, dy);
	vec4 b = textureGrad(t, uv + offs(ia + 1.0), dx, dy);
	return mix(a, b, smoothstep(0.2, 0.8, f - 0.1 * dot(a.rgb - b.rgb, vec3(1.0))));
}
// igual que norep, para mapas de normales (Godot pide una función por tipo de textura)
vec4 norep_n(sampler2D t, vec2 uv, float k, vec2 dx, vec2 dy) {
	if (tile_rand < 0.5) {
		return textureGrad(t, uv, dx, dy);
	}
	float l = k * 8.0;
	float ia = floor(l);
	float f = fract(l);
	vec4 a = textureGrad(t, uv + offs(ia), dx, dy);
	vec4 b = textureGrad(t, uv + offs(ia + 1.0), dx, dy);
	return mix(a, b, smoothstep(0.2, 0.8, f - 0.1 * dot(a.rgb - b.rgb, vec3(1.0))));
}
vec3 unpack_n(vec4 t) {
	vec2 xy = t.rg * 2.0 - 1.0;
	return vec3(xy, sqrt(max(1.0 - dot(xy, xy), 0.0)));
}

void fragment() {
	vec2 uv = wpos.xz / 6.0;
	vec2 dx = dFdx(uv);
	vec2 dy = dFdy(uv);
	float k = texture(dtex, wpos.xz * 0.0045).r;

	// pesos del splat (interpolado entre vértices de celda) con bordes irregulares
	vec4 w;
	if (far > 0.5) {
		w = vec4(0.82, 0.0, 0.18 * smoothstep(0.75, 0.55, wnrm.y), 0.0);
	} else {
		vec2 suv = (wpos.xz + hinfo.y) / hinfo.x * hinfo.z + hinfo.w;
		w = texture(splat, suv);
	}
	float wob = (texture(dtex, wpos.xz * 0.07).r - 0.5) * 0.6;
	w = clamp(w + vec4(wob, -wob * 0.5, -wob * 0.3, wob * 0.2) * step(0.02, w) * step(w, vec4(0.98)), 0.0, 1.0);
	// pendiente fuerte: aparece la roca
	w.b = max(w.b, smoothstep(0.82, 0.62, wnrm.y));
	w /= max(w.r + w.g + w.b + w.a, 0.001);

	vec4 col = vec4(0.0);
	vec3 nt = vec3(0.0);
	if (w.r > 0.01) {
		vec4 g = norep(alb_grass, uv, k, dx, dy);
		g.rgb *= vec3(0.92, 1.05, 0.86);
		if (season_dry > 0.01) {
			vec4 d = norep(alb_dry, uv * 0.8, k, dx * 0.8, dy * 0.8);
			d.rgb *= vec3(1.15, 1.02, 0.62);
			g = mix(g, d, season_dry);
		}
		col += g * w.r;
		nt += unpack_n(textureGrad(nrm_grass, uv, dx, dy)) * w.r;
	}
	if (w.g > 0.01) {
		col += norep(alb_sand, uv, k, dx, dy) * w.g;
		nt += unpack_n(textureGrad(nrm_sand, uv, dx, dy)) * w.g;
	}
	if (w.b > 0.01) {
		col += norep(alb_rock, uv * 0.6, k, dx * 0.6, dy * 0.6) * w.b;
		nt += unpack_n(textureGrad(nrm_rock, uv * 0.6, dx * 0.6, dy * 0.6)) * w.b;
	}
	if (w.a > 0.01) {
		col += norep(alb_dirt, uv, k, dx, dy) * w.a;
		nt += unpack_n(textureGrad(nrm_dirt, uv, dx, dy)) * w.a;
	}
	// nieve: primero en lo plano
	float sw = snow * smoothstep(0.72, 0.9, wnrm.y);
	if (sw > 0.01) {
		vec4 s = norep(alb_snow, uv * 0.7, k, dx * 0.7, dy * 0.7);
		col = mix(col, s, sw);
		nt = mix(nt, vec3(0.0, 0.0, 1.0), sw * 0.7);
	}
	// variación grande (manchas de varias cuadras)
	float big = texture(dtex, wpos.xz * 0.0055 + 0.37).r;
	float big2 = texture(dtex, wpos.xz * 0.013 + 0.71).r;
	col.rgb *= mix(vec3(0.80, 0.86, 0.76), vec3(1.10, 1.12, 1.0), big) * mix(0.92, 1.06, big2);
	// zonas no compradas: un poco desaturadas y claras ("campo lejano")
	float owned = COLOR.a;
	float lum = dot(col.rgb, vec3(0.3, 0.59, 0.11));
	col.rgb = mix(mix(vec3(lum), col.rgb, 0.55) * 1.08, col.rgb, owned);
	// orilla bajo el agua más oscura
	float wb = 1.0 - smoothstep(0.0, 0.7, wpos.y + 0.45);
	col.rgb *= 1.0 - 0.35 * wb;
	if (cshadow > 0.0) {
		col.rgb *= 1.0 - cshadow * 0.3 * smoothstep(0.5, 0.7, texture(ctex, wpos.xz * 0.0045 + vec2(TIME * 0.012, TIME * 0.006)).r);
	}

	// normal: mapa en espacio tangente con la tangente = eje X del mundo
	vec3 n = normalize(wnrm);
	vec3 t = normalize(vec3(1.0, 0.0, 0.0) - n * n.x);
	vec3 b = cross(n, t);
	nt = normalize(nt + vec3(0.0, 0.0, 0.001));
	// en los mapas OpenGL el verde apunta "arriba" en la imagen (v decreciente = -Z del mundo = b)
	vec3 nw = normalize(t * nt.x + b * nt.y + n * nt.z);
	NORMAL = normalize((VIEW_MATRIX * vec4(nw, 0.0)).xyz);

	ALBEDO = col.rgb;
	ROUGHNESS = mix(clamp(col.a, 0.4, 1.0), 0.5, wb);
	SPECULAR = 0.25;
}
