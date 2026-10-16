# Objetos de calle de la etapa 2d: faroles, semáforos, autos, mobiliario, postes y carteles.
var prop_ids: Dictionary = {}
const CAR_MODELS := ["sedan", "hatch", "camioneta", "utilitario", "taxi"]
func prop_register() -> void:
	prop_ids.clear()
	for id in ["farol", "semaforo"] + CAR_MODELS:
		cat_add(id, [], [1], false, {}, Callable(self, "rc_" + id), false, "objeto")
		prop_ids[id] = cat_models.size() - 1
	# objetos chicos: solo versión cerca (con la cámara acercada)
	for id in ["banco", "tacho", "bolardo", "cantero", "parada", "cartel_calle", "pare", "cable"]:
		cat_add(id, [], [1], false, {}, Callable(self, "rc_" + id), true, "objeto")
		prop_ids[id] = cat_models.size() - 1
	cat_add("poste", [], [1], false, {}, rc_poste, false, "objeto")
	prop_ids["poste"] = cat_models.size() - 1
# farol: columna, brazo hacia +X y farola que brilla de noche (la cabeza queda en x = 0,8, y = 2,8)
func rc_farol(lod: int, _f: int, _w: float) -> void:
	if lod == LOD_FAR:
		mb_box(Vector3.ZERO, Vector3(0.1, 2.9, 0.1), BM_PAINTED, 0, 63 - 8)
		# la luz se ve de lejos y en calidad Baja
		mb_box(Vector3(0.6, 2.6, 0), Vector3(0.5, 0.18, 0.3), BM_EMIT, 0)
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
	mb_quad(Vector3(x0, y0, w2), Vector3(x1, y0, w2), Vector3(x1 - ins, y0 + hc, w2 - 0.04), Vector3(x0 + ins, y0 + hc, w2 - 0.04), BM_GLASS, 3, Vector2(0, 50), Vector2(1, 51))
	mb_quad(Vector3(x1, y0, -w2), Vector3(x0, y0, -w2), Vector3(x0 + ins, y0 + hc, -w2 + 0.04), Vector3(x1 - ins, y0 + hc, -w2 + 0.04), BM_GLASS, 3, Vector2(1, 50), Vector2(2, 51))
	mb_quad(Vector3(x1, y0, w2), Vector3(x1, y0, -w2), Vector3(x1 - ins, y0 + hc, -w2 + 0.04), Vector3(x1 - ins, y0 + hc, w2 - 0.04), BM_GLASS, 3, Vector2(2, 50), Vector2(3, 51))
	mb_quad(Vector3(x0, y0, -w2), Vector3(x0, y0, w2), Vector3(x0 + ins, y0 + hc, w2 - 0.04), Vector3(x0 + ins, y0 + hc, -w2 + 0.04), BM_GLASS, 3, Vector2(3, 50), Vector2(4, 51))
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

# --- mobiliario (marco del objeto: el frente mira a +Z, que es la calle)
func rc_banco(_lod: int, _f: int, _w: float) -> void:
	mb_box(Vector3(0, 0.22, 0), Vector3(0.9, 0.05, 0.3), BM_WOOD, 0)
	mb_box(Vector3(0, 0.3, -0.13), Vector3(0.9, 0.25, 0.04), BM_WOOD, 0)
	for x in [-0.38, 0.38]:
		mb_box(Vector3(x, 0, 0), Vector3(0.05, 0.22, 0.28), BM_PAINTED, 0, 63 - 8)
func rc_tacho(_lod: int, _f: int, _w: float) -> void:
	mb_cyl(Vector3.ZERO, 0.13, 0.45, 8, BM_PAINTED, 2)
	mb_box(Vector3(0, 0, 0.0), Vector3(0.04, 0.55, 0.04), BM_PAINTED, 0, 63 - 8)
func rc_bolardo(_lod: int, _f: int, _w: float) -> void:
	mb_cyl(Vector3.ZERO, 0.06, 0.4, 6, BM_CONCRETE, 0)
func rc_cantero(_lod: int, _f: int, _w: float) -> void:
	mb_box(Vector3.ZERO, Vector3(0.9, 0.3, 0.4), BM_CONCRETE, 0, 63 - 8 - 4)
	mb_quad(Vector3(-0.42, 0.26, 0.17), Vector3(0.42, 0.26, 0.17), Vector3(0.42, 0.26, -0.17), Vector3(-0.42, 0.26, -0.17), BM_TURF, 0)
	for x in [-0.25, 0.05, 0.3]:
		mb_blob(Vector3(x, 0.38, 0), Vector3(0.16, 0.14, 0.14), 5, 3, int(x * 100.0) + 7)
func rc_parada(_lod: int, _f: int, _w: float) -> void:
	# refugio de colectivo: techito, vidrio atrás y banco
	mb_box(Vector3(0, 1.15, 0), Vector3(1.4, 0.05, 0.6), BM_PAINTED, 2)
	for x in [-0.66, 0.66]:
		mb_box(Vector3(x, 0, -0.25), Vector3(0.05, 1.15, 0.05), BM_PAINTED, 0, 63 - 8)
	mb_quad(Vector3(0.66, 0.15, -0.27), Vector3(-0.66, 0.15, -0.27), Vector3(-0.66, 1.1, -0.27), Vector3(0.66, 1.1, -0.27), BM_GLASS, 3, Vector2(0, 60), Vector2(1, 61))
	mb_quad(Vector3(-0.66, 0.15, -0.27), Vector3(0.66, 0.15, -0.27), Vector3(0.66, 1.1, -0.27), Vector3(-0.66, 1.1, -0.27), BM_GLASS, 3, Vector2(0, 60), Vector2(1, 61))
	mb_box(Vector3(0, 0.25, -0.15), Vector3(1.0, 0.05, 0.22), BM_WOOD, 0)
func rc_cartel_calle(_lod: int, _f: int, _w: float) -> void:
	mb_box(Vector3.ZERO, Vector3(0.05, 1.9, 0.05), BM_PAINTED, 0, 63 - 8)
	mb_box(Vector3(0.2, 1.8, 0), Vector3(0.5, 0.12, 0.02), BM_PLAIN, 2)
	mb_box(Vector3(0, 1.62, 0.2), Vector3(0.02, 0.12, 0.5), BM_PLAIN, 2)
func rc_pare(_lod: int, _f: int, _w: float) -> void:
	mb_box(Vector3.ZERO, Vector3(0.05, 1.5, 0.05), BM_PAINTED, 0, 63 - 8)
	mb_cyl(Vector3(0, 1.45, 0.03), 0.17, 0.02, 8, BM_PLAIN, 2)
# poste de madera con cruceta (los cables los pone otro objeto)
func rc_poste(lod: int, _f: int, _w: float) -> void:
	if lod == LOD_FAR:
		mb_box(Vector3.ZERO, Vector3(0.14, 4.0, 0.14), BM_WOOD, 0, 63 - 8)
		return
	mb_cyl(Vector3.ZERO, 0.08, 4.0, 6, BM_WOOD, 0)
	mb_box(Vector3(0, 3.55, 0), Vector3(1.4, 0.08, 0.08), BM_WOOD, 0)
	if lod == LOD_NEAR:
		for x in [-0.6, 0.0, 0.6]:
			mb_cyl(Vector3(x, 3.63, 0), 0.025, 0.07, 5, BM_PLAIN, 0)
# cable entre dos postes (una celda a lo largo de +X), con comba: tres hilos en 4 tramos
func rc_cable(_lod: int, _f: int, _w: float) -> void:
	for x in [-0.6, 0.0, 0.6]:
		var pts: Array = []
		for k in 5:
			var t := k / 4.0
			pts.append(Vector3(t * CELL, 3.66 - 0.35 * 4.0 * t * (1.0 - t), x))
		for k in 4:
			var a: Vector3 = pts[k]
			var b: Vector3 = pts[k + 1]
			mb_quad(Vector3(a.x, a.y - 0.012, a.z), Vector3(b.x, b.y - 0.012, b.z), Vector3(b.x, b.y + 0.012, b.z), Vector3(a.x, a.y + 0.012, a.z), BM_DARK, 0)
			mb_quad(Vector3(b.x, b.y - 0.012, b.z), Vector3(a.x, a.y - 0.012, a.z), Vector3(a.x, a.y + 0.012, a.z), Vector3(b.x, b.y + 0.012, b.z), BM_DARK, 0)
# --- ubicación del mobiliario en una cuadra recta (la llama emit_road). horiz: la calle va a lo largo de X
func emit_street_furniture(i: int, p: Vector3, y: float, t: int, horiz: bool) -> void:
	for side in [-1, 1]:
		var j: int = i + (N * side if horiz else side)
		if j < 0 or j >= N * N:
			continue
		# vereda de este lado: a 0,44 celdas del centro; "fw" apunta a la calle
		var off := Vector2(0, side * CELL * 0.44) if horiz else Vector2(side * CELL * 0.44, 0)
		var along := Vector2(1, 0) if horiz else Vector2(0, 1)
		var rot := (PI if side > 0 else 0.0) if horiz else (-PI * 0.5 if side > 0 else PI * 0.5)
		var bx := p.x + off.x
		var bz := p.z + off.y
		# del lado del farol (mitad de la celda) el mobiliario se corre para no atravesarlo
		if side == -1 and t >= 2 and (cx(i) + cz(i) * 3) % 3 == 0:
			bx += along.x * 1.3
			bz += along.y * 1.3
		if zone[j] == Z_R and lvl[j] >= 1 and t == 2 and hsh(i, side + 30) < 0.35:
			# árbol de vereda (chico)
			var kind: int = [1, 2, 3, 1][int(hsh(i, side + 31) * 4.0) % 4]
			var tm: Array = tree_models[kind]
			var tc := tree_colors(kind)
			var x := bx + along.x * CELL * 0.22
			var z := bz + along.y * CELL * 0.22
			emit_model(tm[int(hsh(i, side + 32) * 3.0) % 3], 1 if float(tc[1]) < 0.6 else 0, x, y, z, hsh(i, side + 33) * TAU, 0.6, tc[0], Vector4(0, 0, hsh(i, side + 34), 0), 0.6)
		if zone[j] == Z_C and lvl[j] >= 1:
			var h := hsh(i, side + 35)
			if h < 0.25:
				emit_model(prop_ids["banco"], 0, bx - along.x * 0.6, y, bz - along.y * 0.6, rot, 1.0, Color(1, 1, 1), Vector4(0, 0, h, 0))
				emit_model(prop_ids["tacho"], 0, bx + along.x * 0.5, y, bz + along.y * 0.5, rot, 1.0, Color(1, 1, 1), Vector4(0, 0.0, h, 0))
			elif h < 0.35:
				emit_model(prop_ids["cantero"], 0, bx, y, bz, rot, 1.0, Color(1, 1, 1), Vector4(0, 0, h, 0))
		if side == -1 and stops.has(i):
			emit_model(prop_ids["parada"], 0, bx, y, bz, rot, 1.0, Color(1, 1, 1), Vector4(0, 3.0 / 8.0, 0.5, 0))
# esquinas de un cruce: cartel con nombre de calle, PARE si no hay semáforo, bolardos si hay avenida
func emit_corner_props(i: int, p: Vector3, y: float, av: bool) -> void:
	var c := CELL * 0.44
	emit_model(prop_ids["cartel_calle"], 0, p.x + c, y, p.z + c, 0.0, 1.0, Color(1, 1, 1), Vector4(0, 3.0 / 8.0, 0.3, 0))
	if not av and hsh(i, 95) < 0.3:
		emit_model(prop_ids["pare"], 0, p.x - c, y, p.z - c, PI * 0.25, 1.0, Color(1, 1, 1), Vector4(0, 2.0 / 8.0, 0.3, 0))
	if av:
		for k in 4:
			var sx := 1.0 if k == 0 or k == 3 else -1.0
			var sz := 1.0 if k < 2 else -1.0
			emit_model(prop_ids["bolardo"], 0, p.x + sx * CELL * 0.36, y, p.z + sz * CELL * 0.47, 0.0, 1.0, Color(1, 1, 1), Vector4.ZERO)
# tendido eléctrico: poste en la celda y cable hacia los vecinos de +X y +Z que también tienen tendido
func emit_power(i: int, p: Vector3) -> void:
	var y := ground_y(p.x, p.z) - 0.05
	emit_model(prop_ids["poste"], 0, p.x, y, p.z, 0.0, 1.0, Color(1, 1, 1), Vector4.ZERO)
	if cx(i) < N - 1 and wire[i + 1] & W_POWER:
		emit_model(prop_ids["cable"], 0, p.x, y, p.z, 0.0, 1.0, Color(1, 1, 1), Vector4.ZERO)
	if cz(i) < N - 1 and wire[i + N] & W_POWER:
		emit_model(prop_ids["cable"], 0, p.x, y, p.z, -PI * 0.5, 1.0, Color(1, 1, 1), Vector4.ZERO)
