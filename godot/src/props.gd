# Objetos de calle de la etapa 2d: faroles, semáforos, autos, mobiliario, postes y carteles.
var prop_ids: Dictionary = {}
const CAR_MODELS := ["sedan", "hatch", "camioneta", "utilitario", "taxi"]
func prop_register() -> void:
	prop_ids.clear()
	for id in ["farol", "semaforo"] + CAR_MODELS:
		cat_add(id, [], [1], false, {}, Callable(self, "rc_" + id), false, "objeto")
		prop_ids[id] = cat_models.size() - 1
# farol: columna, brazo hacia +X y farola que brilla de noche (la cabeza queda en x = 0,8, y = 2,8)
func rc_farol(lod: int, _f: int, _w: float) -> void:
	if lod == LOD_FAR:
		mb_box(Vector3.ZERO, Vector3(0.1, 2.9, 0.1), BM_PAINTED, 0, 63 - 8)
		return
	mb_cyl(Vector3.ZERO, 0.09, 0.35, 6, BM_PAINTED, 0)
	mb_cyl(Vector3.ZERO, 0.05, 2.9, 6 if lod == LOD_NEAR else 4, BM_PAINTED, 0)
	mb_box(Vector3(0.4, 2.82, 0), Vector3(0.8, 0.05, 0.05), BM_PAINTED, 0)
	mb_box(Vector3(0.8, 2.7, 0), Vector3(0.34, 0.1, 0.22), BM_PAINTED, 0, 63 - 8)
	mb_box(Vector3(0.8, 2.66, 0), Vector3(0.3, 0.04, 0.18), BM_EMIT, 0, 8)
# semáforo: poste y caja con tres luces mirando a +Z (rojo arriba, amarillo, verde abajo)
func rc_semaforo(lod: int, _f: int, _w: float) -> void:
	mb_box(Vector3.ZERO, Vector3(0.08, 2.6, 0.08), BM_PAINTED, 0, 63 - 8)
	mb_box(Vector3(0, 2.0, 0), Vector3(0.24, 0.72, 0.18), BM_DARK, 0, 63 - 8)
	if lod == LOD_FAR:
		return
	for k in 3:
		var y := 2.55 - k * 0.22
		mb_quad(Vector3(-0.07, y, 0.095), Vector3(0.07, y, 0.095), Vector3(0.07, y + 0.14, 0.095), Vector3(-0.07, y + 0.14, 0.095), BM_SIGNAL, 0, Vector2(k + 0.01, 0), Vector2(k + 0.99, 1))
		if lod == LOD_NEAR:
			mb_box(Vector3(0, y + 0.14, 0.13), Vector3(0.18, 0.025, 0.08), BM_DARK, 0, 63 - 8)
# autos: largo a lo largo de X (1,6 m), carrocería con el color de la instancia, vidrios y ruedas
func car_body(lod: int, L: float, W: float, h0: float, h1: float, cab0: float, cab1: float, hc: float, roof_tm: int) -> void:
	if lod == LOD_FAR:
		mb_box(Vector3(0, 0.1, 0), Vector3(L, h0 + hc * 0.6, W), BM_PAINTED, 1, 63 - 8)
		return
	mb_box(Vector3(0, 0.12, 0), Vector3(L, h0, W), BM_PAINTED, 1, 63 - 8)
	# cabina: vidrios a los costados, adelante y atrás, techo del color del auto (o del segundo color)
	var y0 := 0.12 + h0
	var x0 := cab0 * L - L * 0.5
	var x1 := cab1 * L - L * 0.5
	var w2 := W * 0.46
	var ins := 0.12
	mb_quad(Vector3(x0, y0, w2), Vector3(x1, y0, w2), Vector3(x1 - ins, y0 + hc, w2 - 0.04), Vector3(x0 + ins, y0 + hc, w2 - 0.04), BM_GLASS, 0, Vector2(0, 50), Vector2(1, 51))
	mb_quad(Vector3(x1, y0, -w2), Vector3(x0, y0, -w2), Vector3(x0 + ins, y0 + hc, -w2 + 0.04), Vector3(x1 - ins, y0 + hc, -w2 + 0.04), BM_GLASS, 0, Vector2(1, 50), Vector2(2, 51))
	mb_quad(Vector3(x1, y0, w2), Vector3(x1, y0, -w2), Vector3(x1 - ins, y0 + hc, -w2 + 0.04), Vector3(x1 - ins, y0 + hc, w2 - 0.04), BM_GLASS, 0, Vector2(2, 50), Vector2(3, 51))
	mb_quad(Vector3(x0, y0, -w2), Vector3(x0, y0, w2), Vector3(x0 + ins, y0 + hc, w2 - 0.04), Vector3(x0 + ins, y0 + hc, -w2 + 0.04), BM_GLASS, 0, Vector2(3, 50), Vector2(4, 51))
	mb_quad(Vector3(x0 + ins, y0 + hc, w2 - 0.04), Vector3(x1 - ins, y0 + hc, w2 - 0.04), Vector3(x1 - ins, y0 + hc, -w2 + 0.04), Vector3(x0 + ins, y0 + hc, -w2 + 0.04), BM_PAINTED if roof_tm == 1 else BM_PLAIN, roof_tm)
	if lod == LOD_NEAR:
		# ruedas
		var keep := mb_xf
		for sx in [-0.32, 0.32]:
			for sz in [-1.0, 1.0]:
				mb_xf = keep * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3(sx * L, 0.13, sz * (W * 0.5 - 0.02)))
				mb_cyl(Vector3(0, -0.06, 0), 0.13, 0.12, 8, BM_DARK, 0)
		mb_xf = keep
		# luces
		mb_box(Vector3(L * 0.5 + 0.005, 0.28, W * 0.32), Vector3(0.02, 0.06, 0.12), BM_EMIT, 0, 16 + 1)
		mb_box(Vector3(L * 0.5 + 0.005, 0.28, -W * 0.32), Vector3(0.02, 0.06, 0.12), BM_EMIT, 0, 16 + 1)
func rc_sedan(lod: int, _f: int, _w: float) -> void:
	car_body(lod, 1.7, 0.74, 0.22, 0.0, 0.3, 0.75, 0.2, 1)
func rc_hatch(lod: int, _f: int, _w: float) -> void:
	car_body(lod, 1.45, 0.72, 0.22, 0.0, 0.32, 0.92, 0.22, 1)
func rc_camioneta(lod: int, _f: int, _w: float) -> void:
	car_body(lod, 1.85, 0.8, 0.28, 0.0, 0.42, 0.95, 0.24, 1)
	if lod != LOD_FAR:
		# caja de carga
		mb_box(Vector3(-0.55, 0.4, 0), Vector3(0.7, 0.1, 0.76), BM_PAINTED, 1, 63 - 8)
func rc_utilitario(lod: int, _f: int, _w: float) -> void:
	car_body(lod, 1.8, 0.8, 0.5, 0.0, 0.05, 0.95, 0.12, 1)
func rc_taxi(lod: int, _f: int, _w: float) -> void:
	# negro con techo amarillo (el amarillo es el segundo color de la instancia)
	car_body(lod, 1.7, 0.74, 0.22, 0.0, 0.3, 0.75, 0.2, 2)
# --- ubicación (la llama emit_road)
# farol en la vereda (x, z) con el brazo hacia (dx, dz)
func emit_farol(x: float, y: float, z: float, dx: float, dz: float) -> void:
	emit_model(prop_ids["farol"], 0, x, y, z, atan2(-dz, dx), 1.0, Color(0.25, 0.26, 0.28), Vector4(0, 0, 0, 0))
# semáforos en las cuatro esquinas de un cruce con avenida, cada uno mirando al tránsito que llega
func emit_semaforos(i: int, p: Vector3, y: float) -> void:
	var seed := hsh(i, 90)
	for k in 4:
		var sx := 1.0 if k == 0 or k == 3 else -1.0
		var sz := 1.0 if k < 2 else -1.0
		var x := p.x + sx * CELL * 0.44
		var z := p.z + sz * CELL * 0.44
		# mira hacia afuera por el eje que le toca (0: X, 1: Z)
		var axis := k % 2
		var rot := (0.0 if sz > 0 else PI) if axis == 1 else (PI * 0.5 if sx > 0 else -PI * 0.5)
		emit_model(prop_ids["semaforo"], 0, x, y, z, rot, 1.0, Color(0.2, 0.2, 0.22), Vector4(0, 0, seed, axis))
func emit_car(k: int, x: float, y: float, z: float, rot: float) -> void:
	var m: int = prop_ids[CAR_MODELS[int(hsh(k, 91) * 5.0) % 5]]
	var taxi: bool = m == prop_ids["taxi"]
	var col: Color = Color(0.06, 0.06, 0.07) if taxi else car_color(k)
	emit_model(m, 0, x, y, z, rot, 1.0, col, Vector4(0, 6.0 / 8.0, hsh(k, 92), 0))
