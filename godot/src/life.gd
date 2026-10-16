# Etapa 4: horario de la ciudad (casa, trabajo, escuela, calle) y uso de cada edificio para las ventanas.
# Parte de la gente en cada lugar, hora por hora (0 a 23). Lo que falta para 1 está en la calle.
# Sale de una sola tabla, así nadie está en dos lugares a la vez.
const LIFE_WD := [
	[0.96, 0.04, 0.0], [0.97, 0.03, 0.0], [0.97, 0.03, 0.0], [0.97, 0.03, 0.0], [0.96, 0.04, 0.0], [0.93, 0.05, 0.0],
	[0.85, 0.08, 0.0], [0.62, 0.15, 0.06], [0.38, 0.36, 0.2], [0.3, 0.43, 0.21], [0.29, 0.44, 0.21], [0.29, 0.44, 0.2],
	[0.3, 0.38, 0.16], [0.31, 0.4, 0.19], [0.3, 0.44, 0.2], [0.3, 0.44, 0.14], [0.34, 0.4, 0.05], [0.45, 0.28, 0.01],
	[0.58, 0.18, 0.0], [0.72, 0.1, 0.0], [0.82, 0.08, 0.0], [0.88, 0.06, 0.0], [0.92, 0.05, 0.0], [0.95, 0.04, 0.0]]
const LIFE_WE := [
	[0.9, 0.05, 0.0], [0.93, 0.04, 0.0], [0.95, 0.04, 0.0], [0.96, 0.04, 0.0], [0.96, 0.04, 0.0], [0.96, 0.04, 0.0],
	[0.95, 0.05, 0.0], [0.92, 0.06, 0.0], [0.85, 0.08, 0.0], [0.72, 0.1, 0.0], [0.6, 0.12, 0.0], [0.55, 0.12, 0.0],
	[0.55, 0.12, 0.0], [0.55, 0.12, 0.0], [0.55, 0.12, 0.0], [0.55, 0.12, 0.0], [0.58, 0.12, 0.0], [0.62, 0.11, 0.0],
	[0.66, 0.1, 0.0], [0.68, 0.09, 0.0], [0.7, 0.08, 0.0], [0.74, 0.07, 0.0], [0.8, 0.06, 0.0], [0.86, 0.05, 0.0]]
# de los que están en casa, cuántos están despiertos (con la luz prendida)
const LIFE_AWAKE := [0.35, 0.18, 0.08, 0.05, 0.05, 0.1, 0.45, 0.85, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.92, 0.95, 0.97, 0.95, 0.85, 0.7, 0.5]
# usos de los edificios (dato del modelo, cust.w): 1 casa, 2 negocio, 3 fábrica, 4 mixto (negocio abajo,
# casas arriba), 5 oficina, 6 escuela, 7 hospital, 8 hotel
const USE_SPECIAL := {22: 7, 23: 7, 24: 6, 25: 6, 26: 6, 59: 8, 60: 8, 61: 2, 62: 1, 42: 3, 43: 3, 49: 3, 51: 3, 52: 3, 64: 3}
func life_weekend() -> bool:
	return day % 7 == 0 or day % 7 == 6
# (casa, trabajo, escuela, calle) a la hora h, entre una hora y la siguiente
func life_mix(h: float, weekend: bool) -> Vector4:
	var t: Array = LIFE_WE if weekend else LIFE_WD
	var h0 := int(floorf(h)) % 24
	var h1 := (h0 + 1) % 24
	var k := h - floorf(h)
	var a: Array = t[h0]
	var b: Array = t[h1]
	var home := lerpf(a[0], b[0], k)
	var work := lerpf(a[1], b[1], k)
	var school := lerpf(a[2], b[2], k)
	return Vector4(home, work, school, maxf(1.0 - home - work - school, 0.0))
func life_awake(h: float) -> float:
	var h0 := int(floorf(h)) % 24
	return lerpf(LIFE_AWAKE[h0], LIFE_AWAKE[(h0 + 1) % 24], h - floorf(h))
func life_shop(h: float, weekend: bool) -> float:
	var op := 10.0 if weekend else 9.0
	return 0.9 if h >= op and h < 20.5 else 0.04
# presencia relativa a la capacidad de cada lugar, para el shader: (casas, trabajos, escuelas, negocios)
func life_presence(h: float, weekend: bool) -> Vector4:
	var m := life_mix(h, weekend)
	return Vector4(clampf(m.x / 0.97, 0.0, 1.0), clampf(m.y / 0.44, 0.0, 1.0), clampf(m.z / 0.21, 0.0, 1.0), life_shop(h, weekend))
# cuánto tránsito y gente hay en la calle comparado con la hora pico
func life_street(h: float, weekend: bool) -> float:
	return clampf(life_mix(h, weekend).w / 0.25, 0.12, 1.0)
func life_update() -> void:
	var we := life_weekend()
	bmat_param("pres", life_presence(hour, we))
	bmat_param("awake", life_awake(hour))
	bmat_param("hourf", hour)
func building_use(i: int) -> int:
	match zone[i]:
		Z_R:
			return 1
		Z_C:
			return 5 if lvl[i] >= 3 else 2
		Z_I:
			return 3
		Z_M:
			return 4
	return 0
func special_use(id: int) -> int:
	return USE_SPECIAL.get(id, 5)
# hora de ir o volver de la escuela (para los chicos con mochila)
func life_school_rush(h: float, weekend: bool) -> bool:
	return not weekend and ((h >= 7.0 and h < 8.3) or (h >= 12.0 and h < 13.3) or (h >= 16.8 and h < 17.8))
