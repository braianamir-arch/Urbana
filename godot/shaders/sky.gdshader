// Cielo de URBANA (etapa 1): atmósfera aproximada (Rayleigh + Mie), nubes que se mueven,
// estrellas y luna. Lo maneja update_light() desde render.gd.
shader_type sky;

uniform vec3 sun_dir = vec3(0.0, 1.0, 0.0);   // hacia el sol (puede estar bajo el horizonte de noche)
uniform vec3 moon_dir = vec3(0.0, 0.6, 0.8);
uniform float cover = 0.45;                    // cobertura de nubes 0..1
uniform float storm = 0.0;                     // 0..1: nubes grises de lluvia
uniform float clouds_on = 1.0;
uniform vec2 cloud_off = vec2(0.0);            // desplazamiento por el viento
uniform sampler2D cloud_tex : filter_linear_mipmap, repeat_enable;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

// color del cielo despejado en la dirección d
vec3 clear_sky(vec3 d, vec3 s) {
	float h = clamp(d.y, 0.0, 1.0);
	float sy = s.y;
	float mu = dot(d, s);
	// cuánto de "día" hay: se apaga cuando el sol baja del horizonte
	float day = smoothstep(-0.16, 0.10, sy);
	// Rayleigh: azul profundo arriba, lechoso abajo; el cielo se oscurece y entibia con el sol bajo
	vec3 zen = vec3(0.07, 0.26, 0.78);
	vec3 hor = vec3(0.60, 0.74, 0.93);
	vec3 col = mix(hor, zen, pow(h, 0.35)) * 1.15;
	// atardecer y amanecer: banda cálida en el horizonte, más fuerte del lado del sol
	float low = 1.0 - smoothstep(-0.05, 0.38, sy);
	float side = pow(clamp(mu * 0.5 + 0.5, 0.0, 1.0), 3.0);
	vec3 warm = mix(vec3(0.62, 0.38, 0.48), vec3(0.95, 0.42, 0.10), side);
	float band = (1.0 - smoothstep(0.0, 0.45, h)) * low;
	col = mix(col, warm, band * 0.92);
	col *= mix(0.75, 1.0, smoothstep(0.0, 0.25, sy)); // el cénit se apaga un poco al atardecer
	// Mie: resplandor alrededor del sol
	float mie = pow(clamp(mu, 0.0, 1.0), 64.0) * 1.2 + pow(clamp(mu, 0.0, 1.0), 8.0) * 0.18;
	col += mix(vec3(1.0, 0.85, 0.65), vec3(1.0, 0.45, 0.12), low) * mie * day;
	// noche: azul muy oscuro, un poco más claro en el horizonte
	vec3 night = mix(vec3(0.030, 0.045, 0.095), vec3(0.008, 0.012, 0.035), pow(h, 0.5));
	return mix(night, col, day);
}

void sky() {
	vec3 d = EYEDIR;
	vec3 s = normalize(sun_dir);
	vec3 col = clear_sky(d, s);
	float day = smoothstep(-0.16, 0.10, s.y);
	float h = clamp(d.y, 0.0, 1.0);

	if (!AT_CUBEMAP_PASS) {
		// disco del sol
		float mu = dot(d, s);
		col += vec3(1.0, 0.9, 0.75) * smoothstep(0.9993, 0.9997, mu) * 6.0 * day;
		// estrellas y luna de noche
		if (day < 0.9) {
			vec2 g = floor(vec2(atan(d.z, d.x) * 300.0, d.y * 300.0));
			float st = step(0.9975, hash(g)) * smoothstep(0.05, 0.3, d.y);
			col += vec3(0.9, 0.92, 1.0) * st * (1.0 - day) * 0.9;
			float md = dot(d, normalize(moon_dir));
			col += vec3(0.85, 0.88, 0.95) * smoothstep(0.9990, 0.9994, md) * (1.0 - day) * 1.5;
			col += vec3(0.25, 0.30, 0.45) * pow(clamp(md, 0.0, 1.0), 60.0) * (1.0 - day) * 0.3;
		}
	}

	// nubes: capa plana proyectada en la cúpula, se desvanece cerca del horizonte
	if (clouds_on > 0.5 && d.y > 0.0) {
		vec2 uv = d.xz / (d.y + 0.12) * 0.22 + cloud_off;
		float n = texture(cloud_tex, uv).r * 0.65 + texture(cloud_tex, uv * 2.7 + 0.3).r * 0.35;
		float dens = smoothstep(1.0 - cover, 1.0 - cover + 0.28, n);
		dens *= smoothstep(0.0, 0.18, d.y);
		// luz de la nube: blanca de día, cálida al atardecer, gris con tormenta, oscura de noche
		float low = 1.0 - smoothstep(-0.05, 0.38, s.y);
		vec3 lit = mix(vec3(1.0, 0.98, 0.95), vec3(1.0, 0.62, 0.42), low);
		lit = mix(lit, vec3(0.55, 0.58, 0.62), storm);
		float shade = mix(1.0, 0.72, smoothstep(0.55, 1.0, n));
		vec3 ccol = lit * shade * mix(0.035, 1.0, day);
		col = mix(col, ccol, dens * mix(0.9, 1.0, storm));
	}
	// bajo el horizonte (lo tapan el terreno y la bruma): color del horizonte un poco más oscuro
	if (d.y < 0.0) {
		col = clear_sky(vec3(d.x, 0.0, d.z), s) * 0.75;
	}
	COLOR = col;
}
