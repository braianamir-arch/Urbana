# Edificios especiales de la etapa 2e: una receta por cada uno.
# id de DEF -> modelo del catálogo
var special_model: Dictionary = {}
# prueba: ancla -> [modelos emitidos]
var scheck_log: Dictionary = {}
# árboles de cada especial: [x, z, tipo, escala] en el marco del lote (frente +Z, centro en 0)
var special_trees: Dictionary = {}
# segundo color de cada especial (índice de la paleta del shader)
const SPECIAL_ACCENT := {20: 3, 21: 2, 22: 2, 23: 2, 24: 7, 25: 7, 30: 0, 33: 1, 34: 2, 40: 6, 41: 0, 66: 2, 51: 6, 53: 3, 55: 2, 56: 3, 59: 6, 60: 6, 61: 2, 62: 0, 63: 2, 64: 3, 65: 0, 70: 3, 72: 3}
func special_register() -> void:
	special_model.clear()
	special_trees.clear()
	for id in DEF:
		var fn := "rc_sp_%d" % id
		if has_method(fn):
			var sz: int = DEF[id]["sz"]
			cat_add("esp_%d" % id, [], [1], false, {}, Callable(self, fn), false, "especial")
			cat_models[cat_models.size() - 1]["w"] = sz * CELL
			special_model[id] = cat_models.size() - 1
	special_trees[30] = [[-1.2, -1.2, 3, 0.7], [1.2, -1.2, 1, 0.7], [-1.2, 1.2, 1, 0.7], [1.2, 1.2, 3, 0.7]]
	special_trees[31] = [[-2.8, -2.6, 2, 0.9], [-0.8, -3.0, 1, 0.8], [2.6, -2.4, 3, 0.9], [-2.9, 0.5, 4, 0.8], [2.9, 1.0, 2, 0.9], [-2.4, 2.8, 3, 0.8], [1.0, 2.9, 1, 0.8], [2.7, 2.9, 5, 0.8]]
	special_trees[26] = [[-4.8, 4.6, 2, 0.8], [-1.8, 4.8, 1, 0.8], [1.8, 4.8, 1, 0.8], [4.8, 4.6, 2, 0.8], [0, 1.6, 3, 0.9]]
	special_trees[33] = [[1.4, -1.3, 7, 0.6]]
	special_trees[41] = [[-1.5, 1.5, 1, 0.55]]
	special_trees[24] = [[1.5, 1.4, 3, 0.55]]
	special_trees[62] = [[-3.0, 3.0, 1, 0.6], [3.0, 3.0, 3, 0.6], [-3.0, -3.0, 2, 0.6], [3.0, -3.0, 4, 0.6]]
	special_trees[63] = [[3.2, 3.0, 7, 0.8], [2.6, -3.0, 4, 0.7]]
	special_trees[71] = [[-5.0, -4.6, 2, 0.9], [-2.6, -5.0, 1, 0.9], [4.8, -4.8, 3, 0.9], [-5.0, -1.0, 4, 0.9], [5.0, 1.4, 2, 0.9], [-4.4, 4.6, 3, 0.9], [-1.6, 5.0, 1, 0.8], [1.6, 5.0, 5, 0.8], [4.6, 4.8, 3, 0.9], [-2.0, 1.6, 7, 1.0], [2.2, -1.8, 1, 0.8]]
# una instancia del especial en su lote (centrada como antes), con sus árboles
func emit_special(i: int, p: Vector3) -> bool:
	var id: int = bld[i]
	if not special_model.has(id):
		return false
	var d: Dictionary = DEF[id]
	if d["c"] == "wonder" and wonder_progress.get(i, 0) < WONDER_STEPS:
		return false
	var sz: int = d["sz"]
	var x := p.x + (sz - 1) * CELL * 0.5
	var z := p.z + (sz - 1) * CELL * 0.5
	var rot := face_rot(i)
	var m: int = special_model[id]
	var dark := burn[i] > 0.0
	emit_model(m, 0, x, p.y + 0.02, z, rot, 1.0, d["col"], Vector4(1.0 if dark else 0.0, float(SPECIAL_ACCENT.get(id, 5)) / 8.0, hsh(i, 42), float(special_use(id))))
	if bcheck_on:
		if not scheck_log.has(i):
			scheck_log[i] = []
		scheck_log[i].append(m)
	var c := cos(rot)
	var s := sin(rot)
	for t in special_trees.get(id, []):
		var kind: int = t[2]
		var tc := tree_colors(kind)
		var tx: float = x + c * t[0] + s * t[1]
		var tz: float = z - s * t[0] + c * t[1]
		emit_model(tree_models[kind][int(hsh(i, int(t[0] * 10.0)) * 3.0) % 3], 1 if float(tc[1]) < 0.6 else 0, tx, ground_y(tx, tz) - 0.05, tz, hsh(i, int(t[1] * 10.0)) * TAU, t[3], tc[0], Vector4(0, 0, hsh(i, 50), 0), t[3])
	return true
# --- piezas comunes de los especiales
func sp_ground(w: float, mat: int) -> void:
	mb_box(Vector3.ZERO, Vector3(w * 0.97, 0.08, w * 0.97), mat, 0, 63 - 8)
# pieza de otro modelo dentro de éste (bancos, autos, árboles chicos): misma versión, con transformación
func sp_embed(rc: Callable, lod: int, pos: Vector3, rot := 0.0, sc := 1.0) -> void:
	var keep := mb_xf
	mb_xf = keep * Transform3D(Basis(Vector3.UP, rot).scaled(Vector3(sc, sc, sc)), pos)
	rc.call(lod, 0, 0.0)
	mb_xf = keep
func sp_flag(x: float, z: float, h: float) -> void:
	mb_cyl(Vector3(x, 0, z), 0.03, h, 5, BM_PAINTED, 0)
	# bandera celeste y blanca (celeste = segundo color)
	for k in 3:
		mb_box(Vector3(x + 0.3, h - 0.12 - k * 0.12, z), Vector3(0.6, 0.12, 0.01), BM_PLAIN if k == 1 else BM_PAINTED, 0 if k == 1 else 2)
func sp_columns(x0: float, x1: float, z: float, h: float, n: int, r: float) -> void:
	for k in n:
		var x := lerpf(x0, x1, float(k) / maxf(n - 1, 1))
		mb_cyl(Vector3(x, 0, z), r, h, 8, BM_CONCRETE, 0)
func sp_cross(x: float, y: float, z: float, s: float) -> void:
	mb_box(Vector3(x, y, z), Vector3(s * 0.32, s, 0.04), BM_PAINTED, 2)
	mb_box(Vector3(x, y + s * 0.34, z), Vector3(s, s * 0.32, 0.04), BM_PAINTED, 2)
func sp_sign(x: float, y: float, z: float, wd: float, h: float) -> void:
	mb_box(Vector3(x, y, z), Vector3(wd, h, 0.06), BM_PAINTED, 2, 63 - 32)
func sp_block(x0: float, z0: float, x1: float, z1: float, y0: float, floors: int, lod: int, mat: int, tm: int, o: Dictionary, pitch := 1.0, par := 0.3) -> float:
	var pts := rect_pts(x0, z0, x1, z1)
	var top := mb_walls(pts, y0, floors, lod, mat, tm, o, pitch)
	mb_flat(pts, top, BM_CONCRETE, 0)
	if par > 0.0 and lod != LOD_FAR:
		mb_parapet(pts, top, par, 0.08, mat, tm)
	return top
# --- servicios
func rc_sp_20(lod: int, _f: int, w: float) -> void:
	# comisaría: edificio blanco con franja azul, cartel y patrullero
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-1.6, -1.6, 1.6, 0.6, 0.08, 2, lod, BM_PLASTER, 0, {"gf": 1.7, "door": 1, "bars": true}, 1.0)
	mb_box(Vector3(0, 1.62, 0.62), Vector3(3.2, 0.22, 0.04), BM_PAINTED, 2)
	sp_sign(0, top + 0.05, 0.55, 1.6, 0.3)
	if lod != LOD_FAR:
		sp_embed(rc_sedan, lod, Vector3(0.6, 0.08, 1.3))
		mb_box(Vector3(0.6, 0.62, 1.3), Vector3(0.12, 0.05, 0.5), BM_EMIT, 0)
func rc_sp_21(lod: int, _f: int, w: float) -> void:
	# bomberos: ladrillo con dos portones rojos y torre de mangueras
	sp_ground(w, BM_CONCRETE)
	sp_block(-1.7, -1.7, 1.0, 1.2, 0.08, 2, lod, BM_BRICK, 0, {"gf": 2.2, "ww": 0.5}, 1.0)
	for x in [-1.05, 0.35]:
		mb_quad(Vector3(x - 0.55, 0.08, 1.24), Vector3(x + 0.55, 0.08, 1.24), Vector3(x + 0.55, 1.9, 1.24), Vector3(x - 0.55, 1.9, 1.24), BM_PAINTED, 1)
	var t := sp_block(1.05, -1.7, 1.75, -0.9, 0.08, 5, lod, BM_BRICK, 0, {"gf": 1.4, "ww": 0.25}, 0.7, 0.2)
	mb_box(Vector3(1.4, t, -1.3), Vector3(0.8, 0.1, 0.9), BM_PAINTED, 1)
func rc_sp_22(lod: int, _f: int, w: float) -> void:
	# salita: centro de salud blanco, una planta, cruz roja y alero
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-1.6, -1.5, 1.6, 0.9, 0.08, 1, lod, BM_PLASTER, 1, {"gf": 2.0, "door": 1, "ww": 0.8}, 1.0)
	mb_box(Vector3(0, 1.75, 1.2), Vector3(1.6, 0.08, 0.7), BM_CONCRETE, 0)
	sp_cross(1.0, top - 0.2, 0.95, 0.6)
func rc_sp_23(lod: int, _f: int, w: float) -> void:
	# hospital: bloque de 5 pisos, ala baja con guardia y ambulancias, helipuerto
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-3.4, -3.4, 1.4, 0.6, 0.08, 6, lod, BM_PLASTER, 1, {"gf": 1.8, "bands": true, "ww": 0.85}, 1.0)
	sp_block(-3.4, 0.6, 3.4, 3.0, 0.08, 2, lod, BM_PLASTER, 1, {"gf": 1.8, "door": 2, "shop": true}, 1.0)
	mb_box(Vector3(2.4, 1.9, 3.3), Vector3(1.8, 0.1, 0.8), BM_CONCRETE, 0)
	sp_sign(-1.0, 2.5, 3.02, 2.4, 0.4)
	sp_cross(-1.0, top + 0.4, -0.5, 1.4)
	mb_box(Vector3(-1.0, top, -1.4), Vector3(2.6, 0.06, 2.6), BM_DARK, 0, 4)
	if lod != LOD_FAR:
		mb_cyl(Vector3(-1.0, top + 0.06, -1.4), 1.0, 0.01, 16, BM_PLAIN, 0)
		mb_cyl(Vector3(-1.0, top + 0.07, -1.4), 0.85, 0.01, 16, BM_DARK, 0)
		for k in 2:
			sp_embed(rc_utilitario, lod, Vector3(1.2 + k * 1.95, 0.08, 3.1), 0.0)
# --- educación
func rc_sp_24(lod: int, _f: int, w: float) -> void:
	# escuela: dos plantas, patio con mástil y bandera
	sp_ground(w, BM_SIDEWALK)
	sp_block(-1.7, -1.7, 1.7, -0.3, 0.08, 2, lod, BM_PLASTER, 1, {"gf": 1.6, "door": 1, "ww": 0.7}, 0.9)
	mb_box(Vector3(0, 0.08, 0.7), Vector3(3.3, 0.02, 1.8), BM_CONCRETE, 0, 4)
	sp_flag(-1.4, 1.3, 3.2)
	if lod != LOD_FAR:
		mb_box(Vector3(0, 0.08, 1.75), Vector3(3.4, 0.9, 0.05), BM_PAINTED, 0)
func rc_sp_25(lod: int, _f: int, w: float) -> void:
	# secundaria: en L de tres plantas, patio, mástil y cancha de básquet
	sp_ground(w, BM_SIDEWALK)
	sp_block(-3.5, -3.5, 3.5, -1.5, 0.08, 3, lod, BM_BRICK, 0, {"gf": 1.6, "ww": 0.7}, 0.95)
	sp_block(-3.5, -1.5, -1.5, 2.5, 0.08, 3, lod, BM_BRICK, 0, {"gf": 1.6, "door": 1, "ww": 0.7}, 0.95)
	mb_box(Vector3(1.0, 0.08, 1.0), Vector3(4.2, 0.02, 4.0), BM_CONCRETE, 0, 4)
	if lod != LOD_FAR:
		for k in 2:
			var z := -0.6 + k * 3.2
			mb_box(Vector3(1.0, 0.08, z), Vector3(0.06, 2.0, 0.06), BM_PAINTED, 0, 63 - 8)
			mb_box(Vector3(1.0, 1.9, z + (0.1 if k == 0 else -0.1)), Vector3(0.6, 0.4, 0.04), BM_PLAIN, 0)
	sp_flag(-0.8, 3.3, 3.6)
func rc_sp_26(lod: int, _f: int, w: float) -> void:
	# universidad: edificio central con pórtico y cúpula, dos alas y parque
	sp_ground(w, BM_TURF)
	mb_box(Vector3(0, 0.08, 3.5), Vector3(1.2, 0.02, 5.0), BM_SIDEWALK, 0, 4)
	var top := sp_block(-3.0, -5.6, 3.0, -2.0, 0.08, 3, lod, BM_PLASTER, 1, {"gf": 1.8, "door": 2, "cornice": true}, 1.0, 0.4)
	sp_columns(-1.6, 1.6, -1.7, top - 0.08, 6, 0.14)
	mb_box(Vector3(0, top, -1.85), Vector3(3.6, 0.3, 0.5), BM_CONCRETE, 0)
	mb_cyl(Vector3(0, top, -3.8), 1.2, 0.8, 16, BM_CONCRETE, 0)
	mb_blob(Vector3(0, top + 0.8, -3.8), Vector3(1.2, 1.0, 1.2), [12, 8, 6][lod], [6, 4, 3][lod], 26, BM_SHEET, 0, false)
	sp_block(-5.8, -4.0, -3.6, 3.5, 0.08, 2, lod, BM_PLASTER, 1, {"gf": 1.6}, 1.0)
	sp_block(3.6, -4.0, 5.8, 3.5, 0.08, 2, lod, BM_PLASTER, 1, {"gf": 1.6}, 1.0)
func rc_sp_27(lod: int, _f: int, w: float) -> void:
	# biblioteca: frente neoclásico con columnas, frontón y escalinata
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-1.6, -1.7, 1.6, 0.5, 0.4, 1, lod, BM_PLASTER, 1, {"gf": 2.4, "door": 1, "ww": 0.5, "wh": 1.4}, 1.0, 0.0)
	mb_box(Vector3(0, 0.08, 0.8), Vector3(3.4, 0.32, 1.2), BM_CONCRETE, 0, 63 - 8)
	sp_columns(-1.4, 1.4, 1.1, top - 0.4, 6, 0.11)
	mb_box(Vector3(0, top, -0.5), Vector3(3.4, 0.25, 3.3), BM_CONCRETE, 0)
	mb_gable(Vector3(0, top + 0.25, -0.5), 3.4, 3.3, 0.7, BM_CONCRETE, 0, false)
# --- gobierno
func rc_sp_28(lod: int, _f: int, w: float) -> void:
	# municipalidad: tres plantas con torre central del reloj
	sp_ground(w, BM_SIDEWALK)
	sp_block(-3.4, -3.0, 3.4, 1.4, 0.08, 3, lod, BM_PLASTER, 1, {"gf": 2.0, "door": 3, "cornice": true, "balc": "frances"}, 1.0, 0.4)
	var t := sp_block(-0.8, 0.4, 0.8, 2.0, 0.08, 6, lod, BM_PLASTER, 1, {"gf": 2.0, "door": 0, "cornice": true}, 0.8, 0.0)
	mb_cyl(Vector3(0, t, 1.2), 0.6, 0.02, 12, BM_DARK, 0)
	mb_box(Vector3(0, t - 1.0, 2.02), Vector3(0.8, 0.8, 0.02), BM_PLAIN, 0)
	mb_cone(Vector3(0, t, 1.2), 1.0, 1.6, 8, BM_SHEET, 0)
	sp_flag(2.6, 2.6, 4.0)
func rc_sp_29(lod: int, _f: int, w: float) -> void:
	# casa de gobierno: cabildo de dos plantas con arcadas, techo de tejas y torre
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-3.5, -2.6, 3.5, 0.6, 0.08, 2, lod, BM_PLASTER, 1, {"gf": 2.0, "balc": "frances", "shutters": true}, 1.0, 0.0)
	mb_gable(Vector3(0, top, -1.0), 7.2, 3.4, 1.1, BM_TILES, 0, true, BM_PLASTER, 1, 0.15)
	# galería de arcos al frente
	sp_columns(-3.3, 3.3, 1.2, 2.0, 8, 0.15)
	mb_box(Vector3(0, 2.0, 0.9), Vector3(7.0, 0.3, 0.8), BM_PLASTER, 1)
	var t := sp_block(-0.8, -0.2, 0.8, 1.4, 0.08, 6, lod, BM_PLASTER, 1, {"gf": 2.0, "cornice": true}, 0.8, 0.0)
	mb_cone(Vector3(0, t, 0.6), 0.95, 1.4, 8, BM_TILES, 0)
	sp_flag(3.0, 2.8, 4.5)
# --- ocio y verde
func rc_sp_30(lod: int, _f: int, w: float) -> void:
	# plaza: pasto, senderos en cruz, fuente y bancos (los árboles van aparte)
	sp_ground(w, BM_TURF)
	mb_box(Vector3(0, 0.08, 0), Vector3(w * 0.95, 0.02, 0.7), BM_SIDEWALK, 0, 4)
	mb_box(Vector3(0, 0.08, 0), Vector3(0.7, 0.02, w * 0.95), BM_SIDEWALK, 0, 4)
	mb_cyl(Vector3(0, 0.08, 0), 0.6, 0.3, 12, BM_CONCRETE, 0)
	mb_cyl(Vector3(0, 0.38, 0), 0.5, 0.005, 12, BM_MIRROR, 3)
	mb_cyl(Vector3(0, 0.38, 0), 0.08, 0.6, 6, BM_CONCRETE, 0)
	if lod == LOD_NEAR:
		for k in 4:
			var a := k * PI * 0.5
			sp_embed(rc_banco, lod, Vector3(cos(a) * 1.0, 0.08, sin(a) * 1.0), -a - PI * 0.5)
func rc_sp_31(lod: int, _f: int, w: float) -> void:
	# parque: pasto, sendero, laguna y bancos
	sp_ground(w, BM_TURF)
	mb_box(Vector3(0, 0.08, 0.5), Vector3(w * 0.95, 0.02, 0.6), BM_SIDEWALK, 0, 4)
	mb_box(Vector3(-0.5, 0.08, 0), Vector3(0.6, 0.02, w * 0.95), BM_SIDEWALK, 0, 4)
	mb_cyl(Vector3(1.8, 0.07, -1.6), 1.4, 0.03, 16, BM_MIRROR, 3)
	if lod == LOD_NEAR:
		for k in 3:
			sp_embed(rc_banco, lod, Vector3(-2.0 + k * 1.8, 0.08, 1.1), PI)
func rc_sp_32(lod: int, _f: int, w: float) -> void:
	# cancha de fútbol: césped con líneas, arcos y una tribunita
	sp_ground(w, BM_TURF)
	var L := w * 0.42
	var Wd := w * 0.3
	if lod != LOD_FAR:
		for q in [[0, -Wd, 2 * L, 0.06], [0, Wd, 2 * L, 0.06], [-L, 0, 0.06, 2 * Wd], [L, 0, 0.06, 2 * Wd], [0, 0, 0.06, 2 * Wd]]:
			mb_box(Vector3(q[0], 0.08, q[1]), Vector3(q[2], 0.01, q[3]), BM_PLAIN, 0, 4)
		mb_cyl(Vector3(0, 0.08, 0), 0.7, 0.01, 16, BM_PLAIN, 0)
	for sx in [-1.0, 1.0]:
		mb_box(Vector3(sx * L, 0.08, -0.6), Vector3(0.06, 0.8, 0.06), BM_PLAIN, 0, 63 - 8)
		mb_box(Vector3(sx * L, 0.08, 0.6), Vector3(0.06, 0.8, 0.06), BM_PLAIN, 0, 63 - 8)
		mb_box(Vector3(sx * L, 0.85, 0), Vector3(0.06, 0.06, 1.26), BM_PLAIN, 0)
	for k in 3:
		mb_box(Vector3(0, 0.08 + k * 0.3, -Wd - 0.5 - k * 0.3), Vector3(2 * L * 0.7, 0.3, 0.3), BM_CONCRETE, 0, 63 - 8)
func rc_sp_33(lod: int, _f: int, w: float) -> void:
	# parrilla: quincho con techo de tejas, parrilla de ladrillo con chimenea y mesas
	sp_ground(w, BM_SIDEWALK)
	for p in [Vector3(-1.4, 0, -1.4), Vector3(1.4, 0, -1.4), Vector3(-1.4, 0, 0.6), Vector3(1.4, 0, 0.6)]:
		mb_box(p + Vector3(0, 0.08, 0), Vector3(0.14, 2.0, 0.14), BM_WOOD, 0, 63 - 8)
	mb_gable(Vector3(0, 2.08, -0.4), 3.2, 2.4, 0.8, BM_TILES, 0, true, BM_WOOD, 0, 0.15 if lod != LOD_FAR else 0.0)
	mb_box(Vector3(0, 0.08, -1.4), Vector3(1.4, 1.0, 0.5), BM_BRICK, 0, 63 - 8)
	mb_box(Vector3(0, 1.08, -1.5), Vector3(0.4, 1.9, 0.3), BM_BRICK, 0, 63 - 8)
	if lod != LOD_FAR:
		for x in [-0.7, 0.7]:
			mb_box(Vector3(x, 0.08, 0.0), Vector3(1.0, 0.7, 0.6), BM_WOOD, 0, 63 - 8)
func rc_sp_34(lod: int, _f: int, w: float) -> void:
	# calesita: plataforma redonda, poste central, techo cónico a rayas y caballitos
	sp_ground(w, BM_SIDEWALK)
	var seg := 16 if lod == LOD_NEAR else 10
	mb_cyl(Vector3(0, 0.33, 0), 0.12, 2.0, 8, BM_PAINTED, 2)
	# plataforma, techo y caballitos giran alrededor del poste (etapa 5)
	mb_rot = 3
	mb_cyl(Vector3(0, 0.08, 0), 1.6, 0.25, seg, BM_WOOD, 0)
	mb_cone(Vector3(0, 2.3, 0), 1.75, 0.9, seg, BM_PAINTED, 2)
	mb_cyl(Vector3(0, 2.1, 0), 1.75, 0.2, seg, BM_PLAIN, 0)
	if lod != LOD_FAR:
		for k in 8:
			var a := TAU * k / 8.0
			var p := Vector3(cos(a) * 1.2, 0.33, sin(a) * 1.2)
			mb_cyl(p, 0.025, 1.8, 4, BM_PAINTED, 0)
			mb_box(p + Vector3(0, 0.45, 0), Vector3(0.5, 0.25, 0.14), BM_PLAIN, 0)
	mb_rot = 0
func rc_sp_35(lod: int, _f: int, w: float) -> void:
	# estadio: cancha, tribunas en escalones alrededor y cuatro torres de luz
	sp_ground(w, BM_CONCRETE)
	mb_box(Vector3(0, 0.08, 0), Vector3(6.4, 0.02, 4.0), BM_TURF, 0, 4)
	var rows: int = [5, 3, 2][lod]
	for r in rows:
		var y: float = 0.08 + r * 0.55
		var dx: float = 3.4 + r * 0.45
		var dz: float = 2.2 + r * 0.45
		for side in [[0, dz, 2 * dx, 0.45], [0, -dz, 2 * dx, 0.45], [dx, 0, 0.45, 2 * dz], [-dx, 0, 0.45, 2 * dz]]:
			mb_box(Vector3(side[0], y, side[1]), Vector3(side[2], 0.55, side[3]), BM_CONCRETE, 1, 63 - 8)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			mb_box(Vector3(sx * 5.6, 0.08, sz * 4.4), Vector3(0.18, 7.0, 0.18), BM_PAINTED, 0, 63 - 8)
			mb_box(Vector3(sx * 5.6, 7.0, sz * 4.4), Vector3(1.0, 0.6, 0.2), BM_EMIT, 0)
func rc_sp_36(lod: int, _f: int, w: float) -> void:
	# vuelta al mundo: base, dos patas en A y rueda con cabinas
	sp_ground(w, BM_SIDEWALK)
	var r := 3.2
	var cy := r + 0.6
	for sz in [-0.5, 0.5]:
		mb_limb(Vector3(-1.6, 0.08, sz), Vector3(0, cy, sz), 0.08, 0.06, 6)
		mb_limb(Vector3(1.6, 0.08, sz), Vector3(0, cy, sz), 0.08, 0.06, 6)
	var n: int = [16, 12, 8][lod]
	# la rueda gira despacio (etapa 5)
	mb_rot = 2
	mb_piv = Vector2(cy, 0.0)
	for k in n:
		var a0: float = TAU * k / n
		var a1: float = TAU * (k + 1) / n
		for sz in [-0.4, 0.4]:
			mb_limb(Vector3(cos(a0) * r, cy + sin(a0) * r, sz), Vector3(cos(a1) * r, cy + sin(a1) * r, sz), 0.05, 0.05, 4)
		if lod != LOD_FAR:
			mb_limb(Vector3(0, cy, 0), Vector3(cos(a0) * r, cy + sin(a0) * r, 0), 0.025, 0.025, 4)
			mb_box(Vector3(cos(a0) * r, cy + sin(a0) * r - 0.45, 0), Vector3(0.4, 0.35, 0.4), BM_PAINTED, 1)
	mb_rot = 0
func rc_sp_37(lod: int, _f: int, w: float) -> void:
	# catedral: nave con techo a dos aguas, fachada con dos torres, rosetón y cúpula atrás
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-1.6, -3.2, 1.6, 2.4, 0.08, 1, lod, BM_PLASTER, 1, {"gf": 4.0, "door": 1, "sill": 1.4, "wh": 2.0, "ww": 0.5}, 1.1, 0.0)
	mb_gable(Vector3(0, top, -0.4), 3.2, 5.6, 1.6, BM_SHEET, 0, false, BM_PLASTER, 1)
	for sx in [-1.0, 1.0]:
		var t := sp_block(sx * 2.4 - 0.7, 1.6, sx * 2.4 + 0.7, 3.0, 0.08, 1, lod, BM_PLASTER, 1, {"gf": 6.5, "sill": 4.5, "wh": 1.2, "ww": 0.4}, 1.4, 0.0)
		mb_cone(Vector3(sx * 2.4, t, 2.3), 0.85, 2.4, 8, BM_SHEET, 0)
	mb_box(Vector3(0, 0.08, 2.5), Vector3(3.4, 4.6, 0.3), BM_PLASTER, 1, 63 - 8)
	mb_gable(Vector3(0, 4.68, 2.5), 3.4, 0.3, 1.3, BM_PLASTER, 1, true)
	mb_cyl(Vector3(0, 3.4, 2.66), 0.6, 0.02, 12, BM_GLASS, 3)
	mb_cyl(Vector3(0, top, -2.5), 1.1, 1.0, 12, BM_PLASTER, 1)
	mb_blob(Vector3(0, top + 1.0, -2.5), Vector3(1.1, 1.0, 1.1), [10, 8, 6][lod], [5, 4, 3][lod], 37, BM_SHEET, 0, false)
func rc_sp_38(lod: int, _f: int, w: float) -> void:
	# faro: torre que se afina con franjas, galería y linterna que brilla
	sp_ground(w, BM_CONCRETE)
	var n := 6
	for k in n:
		var y0 := 0.08 + k * 1.6
		mb_limb(Vector3(0, y0, 0), Vector3(0, y0 + 1.6, 0), 1.0 - k * 0.09, 1.0 - (k + 1) * 0.09, [12, 10, 6][lod])
		# franjas rojas: cilindro apenas más grande del segundo color
		if k % 2 == 1:
			mb_cyl(Vector3(0, y0 + 0.4, 0), 1.0 - k * 0.09 + 0.02, 0.8, [12, 10, 6][lod], BM_PAINTED, 2)
	var t: float = 0.08 + n * 1.6
	mb_cyl(Vector3(0, t, 0), 0.75, 0.12, 12, BM_PAINTED, 0)
	mb_cyl(Vector3(0, t + 0.12, 0), 0.4, 0.8, 10, BM_EMIT, 0)
	mb_cone(Vector3(0, t + 0.92, 0), 0.5, 0.5, 10, BM_PAINTED, 2)
func rc_sp_39(lod: int, _f: int, w: float) -> void:
	# torre del reloj: ladrillo, cuatro relojes y aguja
	sp_ground(w, BM_SIDEWALK)
	var t := sp_block(-0.9, -0.9, 0.9, 0.9, 0.08, 1, lod, BM_BRICK, 0, {"gf": 9.0, "sill": 7.0, "wh": 1.0, "ww": 0.4}, 1.0, 0.0)
	mb_box(Vector3(0, t, 0), Vector3(2.1, 0.3, 2.1), BM_CONCRETE, 0)
	for k in 4:
		var keep := mb_xf
		mb_xf = keep * Transform3D(Basis(Vector3.UP, k * PI * 0.5), Vector3.ZERO)
		mb_xf = mb_xf * Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3(0, t - 1.4, 0.91))
		mb_cyl(Vector3.ZERO, 0.6, 0.03, 16, BM_PLAIN, 0)
		mb_xf = keep
	var t2 := sp_block(-0.6, -0.6, 0.6, 0.6, t + 0.3, 1, lod, BM_BRICK, 0, {"gf": 1.6, "ww": 0.5}, 1.0, 0.0)
	mb_cone(Vector3(0, t2, 0), 0.75, 2.4, 8, BM_SHEET, 0)
func rc_sp_40(lod: int, _f: int, w: float) -> void:
	# playa: arena, sombrillas de colores y reposeras
	sp_ground(w, BM_PLAIN)
	for k in [[-1.0, -0.8], [0.9, -1.1], [-0.4, 1.0], [1.3, 0.8]]:
		mb_cyl(Vector3(k[0], 0.08, k[1]), 0.025, 1.3, 4, BM_PAINTED, 0)
		mb_cone(Vector3(k[0], 1.2, k[1]), 0.7, 0.35, 8 if lod != LOD_FAR else 5, BM_PAINTED, 2)
		if lod == LOD_NEAR:
			mb_box(Vector3(k[0] + 0.4, 0.08, k[1] + 0.2), Vector3(0.7, 0.12, 0.3), BM_PLAIN, 0)
func rc_sp_41(lod: int, _f: int, w: float) -> void:
	# club de barrio: salón de ladrillo con cartel y canchita de baby
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-1.7, -1.7, 1.7, -0.2, 0.08, 1, lod, BM_BRICK, 0, {"gf": 2.6, "door": 1, "sill": 1.6, "wh": 0.7}, 1.0)
	sp_sign(0, top - 0.6, -0.15, 2.4, 0.45)
	mb_box(Vector3(0.6, 0.08, 1.0), Vector3(2.4, 0.02, 1.3), BM_TURF, 0, 4)
	if lod != LOD_FAR:
		mb_box(Vector3(0.6, 0.08, 1.7), Vector3(2.6, 1.2, 0.03), BM_PAINTED, 0)
func rc_sp_66(lod: int, _f: int, w: float) -> void:
	# cine: sala alta sin ventanas, marquesina que brilla, carteleras y entrada vidriada
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-1.7, -1.8, 1.7, 1.0, 0.08, 1, lod, BM_PLASTER, 1, {"gf": 5.0, "shop": true, "door": 1, "ww": 0.9}, 1.1, 0.25)
	mb_box(Vector3(0, 2.2, 1.35), Vector3(3.6, 0.6, 0.7), BM_EMIT, 0)
	mb_box(Vector3(0, 2.8, 1.05), Vector3(3.4, 0.9, 0.1), BM_PAINTED, 2)
	for x in [-1.2, 1.2]:
		mb_box(Vector3(x, 0.5, 1.04), Vector3(0.6, 1.1, 0.04), BM_PAINTED, 2)
	mb_box(Vector3(1.4, 3.0, 1.1), Vector3(0.25, 2.2, 0.5), BM_EMIT, 0)

# --- energía y servicios públicos
func rc_sp_42(lod: int, _f: int, w: float) -> void:
	# usina a carbón: sala de turbinas, caldera alta, dos chimeneas, montaña de carbón y cinta
	sp_ground(w, BM_CONCRETE)
	sp_block(-3.5, -1.0, 1.0, 3.2, 0.08, 1, lod, BM_BRICK, 0, {"gf": 4.0, "sill": 2.0, "wh": 1.4, "ww": 0.6}, 1.0, 0.3)
	sp_block(-3.5, -3.6, -0.5, -1.0, 0.08, 1, lod, BM_SHEET, 1, {"gf": 7.0, "sill": 5.0, "wh": 1.0}, 1.0, 0.2)
	mb_chimney(Vector3(0.4, 0.08, -2.6), 15.0, 0.5)
	mb_chimney(Vector3(1.8, 0.08, -2.6), 15.0, 0.5)
	mb_blob(Vector3(2.4, 0.9, 1.8), Vector3(1.3, 0.9, 1.3), [10, 6, 5][lod], [4, 3, 2][lod], 42, BM_DARK, 0, true)
	if lod != LOD_FAR:
		mb_limb(Vector3(2.0, 0.5, 1.0), Vector3(-0.5, 3.6, -1.6), 0.18, 0.18, 4)
func rc_sp_43(lod: int, _f: int, w: float) -> void:
	# central de gas: tres tanques esféricos sobre patas, cañerías, sala de control y antorcha
	sp_ground(w, BM_CONCRETE)
	var seg: int = [12, 8, 6][lod]
	for c in [Vector3(-2.0, 0, -1.8), Vector3(1.4, 0, -1.8), Vector3(-0.3, 0, 1.6)]:
		mb_blob(c + Vector3(0, 2.6, 0), Vector3(1.4, 1.4, 1.4), seg, seg / 2, 43, BM_PAINTED, 0, false)
		if lod != LOD_FAR:
			for k in 4:
				var a := TAU * k / 4.0 + 0.4
				mb_cyl(c + Vector3(cos(a) * 1.0, 0.08, sin(a) * 1.0), 0.08, 2.0, 6, BM_PAINTED, 0)
	sp_block(1.8, 1.2, 3.6, 3.4, 0.08, 1, lod, BM_PLASTER, 1, {"gf": 2.0, "door": 0}, 1.0)
	mb_cyl(Vector3(3.3, 0.08, -3.3), 0.15, 8.0, 6, BM_PAINTED, 2)
	if lod != LOD_FAR:
		mb_limb(Vector3(-2.0, 1.0, -1.8), Vector3(1.4, 1.0, -1.8), 0.12, 0.12, 6)
		mb_limb(Vector3(-0.3, 1.0, -1.8), Vector3(-0.3, 1.0, 1.6), 0.12, 0.12, 6)
func rc_sp_44(lod: int, _f: int, w: float) -> void:
	# parque solar: filas de paneles inclinados sobre postes y una casilla
	sp_ground(w, BM_TURF)
	var rows := 6
	for r in rows:
		var z := -3.2 + r * 1.2
		mb_quad(Vector3(-3.4, 0.5, z + 0.4), Vector3(3.0, 0.5, z + 0.4), Vector3(3.0, 1.1, z - 0.3), Vector3(-3.4, 1.1, z - 0.3), BM_GLASS, 3, Vector2(r, 70), Vector2(r + 1, 71))
		if lod != LOD_FAR:
			mb_quad(Vector3(3.0, 0.5, z + 0.4), Vector3(-3.4, 0.5, z + 0.4), Vector3(-3.4, 1.1, z - 0.3), Vector3(3.0, 1.1, z - 0.3), BM_PAINTED, 0)
		if lod == LOD_NEAR:
			for x in [-3.0, -1.0, 1.0, 2.8]:
				mb_box(Vector3(x, 0.08, z), Vector3(0.05, 0.75, 0.05), BM_PAINTED, 0, 63 - 8)
	sp_block(3.3, 2.4, 3.8, 3.8, 0.08, 1, lod, BM_PAINTED, 1, {"gf": 1.4}, 1.0, 0.0)
func rc_sp_45(lod: int, _f: int, w: float) -> void:
	# molino eólico: torre que se afina, góndola y tres aspas
	sp_ground(w * 0.5, BM_CONCRETE)
	var h := 10.0
	mb_limb(Vector3(0, 0.08, 0), Vector3(0, h, 0), 0.24, 0.12, [10, 8, 6][lod])
	mb_box(Vector3(0, h - 0.2, -0.3), Vector3(0.5, 0.55, 1.4), BM_PAINTED, 0)
	var hub := Vector3(0, h + 0.05, 0.45)
	# aspas y cubo giran (etapa 5)
	mb_rot = 1
	mb_piv = Vector2(hub.y, 0.0)
	mb_blob(hub, Vector3(0.22, 0.22, 0.3), 8, 4, 45, BM_PAINTED, 0, false)
	for k in 3:
		var a := TAU * k / 3.0 + 0.3
		var tip := hub + Vector3(cos(a) * 2.1, sin(a) * 2.1, 0)
		var side := Vector3(-sin(a), cos(a), 0) * 0.14
		mb_quad(hub - side + Vector3(0, 0, 0.02), hub + side + Vector3(0, 0, 0.02), tip + side * 0.3, tip - side * 0.3, BM_PAINTED, 0)
		mb_quad(hub + side, hub - side, tip - side * 0.3, tip + side * 0.3, BM_PAINTED, 0)
	mb_rot = 0
func rc_sp_46(lod: int, _f: int, w: float) -> void:
	# represa: muro de hormigón con escalones del vertedero, lago detrás y casa de máquinas abajo
	sp_ground(w, BM_CONCRETE)
	mb_box(Vector3(0, 0.08, -1.8), Vector3(7.6, 0.05, 4.0), BM_MIRROR, 3, 4)
	mb_box(Vector3(0, -0.2, -2.0), Vector3(7.6, 3.0, 3.6), BM_DARK, 0, 4)
	mb_box(Vector3(0, 0.08, 0.6), Vector3(7.6, 3.2, 1.0), BM_CONCRETE, 0, 63 - 8)
	for k in 4:
		mb_box(Vector3(0, 0.08, 1.1 + k * 0.45), Vector3(2.4, 2.6 - k * 0.6, 0.45), BM_CONCRETE, 0, 63 - 8)
	sp_block(1.8, 1.4, 3.6, 3.4, 0.08, 1, lod, BM_CONCRETE, 1, {"gf": 2.4, "door": 0}, 1.0)
	if lod != LOD_FAR:
		mb_box(Vector3(0, 3.28, 0.6), Vector3(7.6, 0.4, 0.05), BM_PAINTED, 0)
func rc_sp_47(lod: int, _f: int, w: float) -> void:
	# bomba de agua: casilla de ladrillo, caños y tanque chico
	sp_ground(w, BM_CONCRETE)
	sp_block(-1.6, -1.6, 0.6, 0.6, 0.08, 1, lod, BM_BRICK, 0, {"gf": 2.4, "door": 0}, 1.0)
	mb_cyl(Vector3(1.0, 0.08, -0.8), 0.7, 1.8, [12, 8, 6][lod], BM_PAINTED, 1)
	if lod != LOD_FAR:
		mb_limb(Vector3(0.6, 0.5, 0.2), Vector3(1.7, 0.5, 1.6), 0.12, 0.12, 6)
		mb_limb(Vector3(-1.6, 0.5, -0.3), Vector3(-1.9, 0.5, 1.8), 0.12, 0.12, 6)
func rc_sp_48(lod: int, _f: int, w: float) -> void:
	# torre de agua: tanque cilíndrico con techo cónico sobre cuatro patas arriostradas
	sp_ground(w * 0.6, BM_CONCRETE)
	var h := 7.0
	for k in 4:
		var a := TAU * k / 4.0 + PI * 0.25
		mb_limb(Vector3(cos(a) * 1.3, 0.08, sin(a) * 1.3), Vector3(cos(a) * 0.9, h, sin(a) * 0.9), 0.1, 0.08, 6)
	if lod != LOD_FAR:
		for k in 4:
			var a0: float = TAU * k / 4.0 + PI * 0.25
			var a1: float = a0 + PI * 0.5
			mb_limb(Vector3(cos(a0) * 1.15, 2.5, sin(a0) * 1.15), Vector3(cos(a1) * 1.0, 5.0, sin(a1) * 1.0), 0.03, 0.03, 4)
	mb_cyl(Vector3(0, h, 0), 1.5, 2.2, [16, 10, 8][lod], BM_PAINTED, 1)
	mb_cone(Vector3(0, h + 2.2, 0), 1.6, 0.8, [16, 10, 8][lod], BM_PAINTED, 0)
func rc_sp_49(lod: int, _f: int, w: float) -> void:
	# potabilizadora: piletas redondas con agua, filtros rectangulares y edificio
	sp_ground(w, BM_CONCRETE)
	var seg: int = [16, 10, 8][lod]
	for c in [Vector3(-2.2, 0, -2.2), Vector3(0.8, 0, -2.2)]:
		mb_cyl(c + Vector3(0, 0.08, 0), 1.3, 0.5, seg, BM_CONCRETE, 0)
		mb_cyl(c + Vector3(0, 0.56, 0), 1.2, 0.01, seg, BM_MIRROR, 3)
	for k in 3:
		mb_box(Vector3(-2.6 + k * 1.3, 0.08, 1.2), Vector3(1.1, 0.4, 1.8), BM_CONCRETE, 0, 63 - 8 - 4)
		mb_box(Vector3(-2.6 + k * 1.3, 0.4, 1.2), Vector3(1.0, 0.02, 1.7), BM_MIRROR, 3, 4)
	sp_block(1.6, 0.0, 3.6, 3.4, 0.08, 2, lod, BM_PLASTER, 1, {"gf": 1.6, "door": 0}, 1.0)
func rc_sp_50(lod: int, _f: int, w: float) -> void:
	# relleno sanitario: lomas de tierra, montones de basura, topadora y cerco
	sp_ground(w, BM_PLAIN)
	mb_blob(Vector3(-0.8, 1.4, -0.8), Vector3(2.6, 1.4, 2.4), [12, 8, 6][lod], [5, 4, 3][lod], 50, BM_PLAIN, 1, true)
	if lod != LOD_FAR:
		for k in 5:
			var p := Vector3(-2.5 + k * 1.3, 0.08, 2.4 + hsh(k, 50) * 0.6)
			mb_blob(p, Vector3(0.5, 0.35, 0.5), 6, 3, 51 + k, BM_PAINTED, 2, true)
		mb_box(Vector3(2.6, 0.08, -2.4), Vector3(1.0, 0.6, 0.6), BM_PAINTED, 2)
		mb_box(Vector3(2.6, 0.68, -2.5), Vector3(0.5, 0.4, 0.4), BM_GLASS, 3)
		mb_box(Vector3(0, 0.08, 3.85), Vector3(7.6, 1.0, 0.04), BM_PAINTED, 0)
func rc_sp_51(lod: int, _f: int, w: float) -> void:
	# planta de reciclaje: galpón de chapa, fardos de colores y cinta transportadora
	sp_ground(w, BM_CONCRETE)
	var top := sp_block(-3.4, -3.4, 1.6, 1.0, 0.08, 1, lod, BM_SHEET, 1, {"gf": 3.4, "sill": 2.4, "wh": 0.6}, 1.0, 0.0)
	mb_gable(Vector3(-0.9, top, -1.2), 5.0, 4.4, 1.0, BM_SHEET, 0, true, BM_SHEET, 1)
	mb_gate(-0.9, 1.0, 2.0, 2.6)
	for k in 6:
		var x := -3.0 + (k % 3) * 1.0
		var z := 2.0 + (k / 3) * 0.9
		mb_box(Vector3(x, 0.08, z), Vector3(0.8, 0.7, 0.7), BM_PAINTED if k % 2 == 0 else BM_PLAIN, 2 if k % 2 == 0 else 1)
	if lod != LOD_FAR:
		mb_limb(Vector3(1.6, 2.4, -1.0), Vector3(3.4, 0.6, -1.0), 0.25, 0.25, 4)
func rc_sp_52(lod: int, _f: int, w: float) -> void:
	# incinerador: edificio, horno cilíndrico y chimenea muy alta
	sp_ground(w, BM_CONCRETE)
	sp_block(-3.4, -1.0, 1.4, 3.2, 0.08, 2, lod, BM_CONCRETE, 1, {"gf": 2.4, "door": 1, "ww": 0.5}, 1.0)
	mb_cyl(Vector3(2.4, 0.08, 1.0), 1.3, 5.0, [14, 10, 8][lod], BM_PAINTED, 1)
	mb_chimney(Vector3(-1.4, 0.08, -2.6), 18.0, 0.55)
func rc_sp_65(lod: int, _f: int, w: float) -> void:
	# basurero: playón con contenedores, galpón chico y camiones recolectores
	sp_ground(w, BM_CONCRETE)
	sp_block(-1.8, -1.8, 0.4, -0.2, 0.08, 1, lod, BM_SHEET, 1, {"gf": 2.4, "door": 1}, 1.0)
	for k in 3:
		mb_box(Vector3(1.2, 0.08, -1.4 + k * 0.9), Vector3(1.0, 0.6, 0.7), BM_PAINTED, 2)
	if lod != LOD_FAR:
		sp_embed(rc_utilitario, lod, Vector3(-0.8, 0.08, 1.0))
		sp_embed(rc_utilitario, lod, Vector3(0.8, 0.08, 1.4))
# --- transporte
func rc_sp_53(lod: int, _f: int, w: float) -> void:
	# estación de subte: plaza seca, boca con escalera que baja, baranda y poste con la S
	sp_ground(w, BM_SIDEWALK)
	mb_box(Vector3(0, 0.08, 0), Vector3(1.4, 0.02, 2.2), BM_DARK, 0, 4)
	if lod != LOD_FAR:
		for k in 6:
			mb_box(Vector3(0, 0.08 - k * 0.0, -0.9 + k * 0.35), Vector3(1.2, 0.03, 0.3), BM_CONCRETE, 0, 4)
		for sx in [-0.72, 0.72]:
			mb_box(Vector3(sx, 0.08, 0), Vector3(0.05, 0.9, 2.2), BM_PAINTED, 1)
	mb_box(Vector3(-1.4, 0.08, 1.4), Vector3(0.08, 2.6, 0.08), BM_PAINTED, 0, 63 - 8)
	mb_box(Vector3(-1.4, 2.4, 1.4), Vector3(0.5, 0.5, 0.1), BM_EMIT, 0)
	mb_box(Vector3(-1.4, 2.4, 1.46), Vector3(0.42, 0.42, 0.02), BM_PAINTED, 2)
func rc_sp_54(lod: int, _f: int, w: float) -> void:
	# estación de tren: edificio con reloj, dos andenes con techo sobre columnas y vías
	sp_ground(w, BM_CONCRETE)
	var top := sp_block(-3.4, 1.4, 3.4, 3.6, 0.08, 2, lod, BM_BRICK, 0, {"gf": 2.2, "door": 3, "shutters": true, "cornice": true}, 1.0, 0.4)
	mb_cyl(Vector3(0, top - 0.5, 3.62), 0.35, 0.02, 12, BM_PLAIN, 0) if lod == LOD_FAR else null
	for z in [-2.6, -0.2]:
		mb_box(Vector3(0, 0.08, z), Vector3(7.4, 0.35, 1.0), BM_CONCRETE, 0, 63 - 8)
		mb_box(Vector3(0, 2.4, z), Vector3(7.4, 0.08, 1.4), BM_SHEET, 0)
		if lod != LOD_FAR:
			for k in 5:
				mb_box(Vector3(-3.2 + k * 1.6, 0.43, z), Vector3(0.08, 2.0, 0.08), BM_PAINTED, 1, 63 - 8)
	for z in [-3.4, -1.4, 0.8]:
		mb_box(Vector3(0, 0.08, z), Vector3(7.6, 0.03, 0.5), BM_DARK, 0, 4)
func rc_sp_55(lod: int, _f: int, w: float) -> void:
	# puerto: muelle, dos grúas pórtico, pilas de contenedores y depósito
	sp_ground(w, BM_CONCRETE)
	for k in 2:
		var x := -2.0 + k * 3.0
		for sx in [-0.7, 0.7]:
			mb_box(Vector3(x + sx, 0.08, 2.4), Vector3(0.18, 6.0, 0.18), BM_PAINTED, 2, 63 - 8)
			mb_box(Vector3(x + sx, 0.08, 0.8), Vector3(0.18, 6.0, 0.18), BM_PAINTED, 2, 63 - 8)
		mb_box(Vector3(x, 6.0, 1.6), Vector3(1.6, 0.4, 4.4), BM_PAINTED, 2)
	for k in 9:
		var x := -3.0 + (k % 3) * 1.3
		var z := -3.0 + (k / 3) * 0.8
		var hgt := 1 + int(hsh(k, 55) * 3.0)
		for h in hgt:
			mb_box(Vector3(x, 0.08 + h * 0.6, z), Vector3(1.2, 0.6, 0.6), BM_PAINTED if (k + h) % 2 == 0 else BM_SHEET, 2 if (k + h) % 3 == 0 else 1)
	sp_block(1.2, -3.6, 3.6, -0.8, 0.08, 1, lod, BM_SHEET, 1, {"gf": 3.0, "door": 0}, 1.0, 0.0)
func rc_sp_56(lod: int, _f: int, w: float) -> void:
	# aeropuerto: terminal vidriada, torre de control, pista con marcas y un avión
	sp_ground(w, BM_TURF)
	mb_box(Vector3(0, 0.08, -3.4), Vector3(11.6, 0.02, 2.2), BM_ASPHALT, 0, 4)
	if lod != LOD_FAR:
		for k in 8:
			mb_box(Vector3(-5.0 + k * 1.4, 0.1, -3.4), Vector3(0.7, 0.01, 0.12), BM_PLAIN, 0, 4)
	mb_box(Vector3(0, 0.08, 0.6), Vector3(8.0, 0.02, 3.6), BM_ASPHALT, 0, 4)
	var top := sp_block(-4.6, 2.6, 4.6, 5.6, 0.08, 2, lod, BM_PAINTED, 1, {"gf": 2.0, "curtain": true, "glass": BM_MIRROR}, 0.8, 0.2)
	mb_box(Vector3(0, top, 4.1), Vector3(9.4, 0.15, 3.2), BM_PAINTED, 0)
	mb_limb(Vector3(5.0, 0.08, 4.6), Vector3(5.0, 9.0, 4.6), 0.4, 0.35, [10, 8, 6][lod])
	mb_cyl(Vector3(5.0, 9.0, 4.6), 0.9, 1.0, [12, 8, 6][lod], BM_GLASS, 3)
	mb_cyl(Vector3(5.0, 10.0, 4.6), 1.0, 0.2, [12, 8, 6][lod], BM_PAINTED, 0)
	# avión: fuselaje, alas y cola
	var keep := mb_xf
	mb_xf = keep * Transform3D(Basis(Vector3.FORWARD, PI * 0.5), Vector3(-0.5, 0.75, 0.6))
	mb_cyl(Vector3(0, -2.4, 0), 0.38, 4.8, [10, 8, 6][lod], BM_PAINTED, 0)
	mb_xf = keep
	mb_box(Vector3(-0.3, 0.6, 0.6), Vector3(1.2, 0.08, 5.4), BM_PAINTED, 0)
	mb_box(Vector3(-2.6, 0.75, 0.6), Vector3(0.7, 1.2, 0.08), BM_PAINTED, 2)
	mb_box(Vector3(-2.6, 0.9, 0.6), Vector3(0.5, 0.06, 1.8), BM_PAINTED, 0)
func rc_sp_57(lod: int, _f: int, w: float) -> void:
	# muelle de ferry: plataforma sobre pilotes, rampa, bolardos y casilla
	sp_ground(w * 0.5, BM_CONCRETE)
	mb_box(Vector3(0, 0.3, 0.5), Vector3(2.4, 0.15, 2.9), BM_WOOD, 0)
	if lod != LOD_FAR:
		for x in [-1.0, 1.0]:
			for z in [-0.6, 0.6, 1.7]:
				mb_cyl(Vector3(x, -0.45, z), 0.1, 0.75, 6, BM_WOOD, 0)
		for x in [-1.0, 1.0]:
			mb_cyl(Vector3(x, 0.45, 1.8), 0.08, 0.25, 6, BM_DARK, 0)
	sp_block(-0.6, -1.6, 0.6, -0.4, 0.08, 1, lod, BM_PAINTED, 1, {"gf": 1.6, "door": 0}, 1.0, 0.0)
func rc_sp_58(lod: int, _f: int, w: float) -> void:
	# estacionamiento: asfalto con líneas, autos en dos filas y cabina
	sp_ground(w, BM_ASPHALT)
	if lod != LOD_FAR:
		for k in 5:
			for z in [-1.0, 1.0]:
				mb_box(Vector3(-1.6 + k * 0.85, 0.09, z), Vector3(0.04, 0.01, 1.2), BM_PLAIN, 0, 4)
	var rc := [rc_sedan, rc_hatch, rc_camioneta, rc_sedan]
	for k in 4:
		for z in [-1.0, 1.0]:
			if hsh(k + int(z * 3.0), 58) < 0.75:
				sp_embed(rc[k], lod, Vector3(-1.2 + k * 0.85, 0.08, z), PI * 0.5)
	sp_block(1.5, 1.2, 1.9, 1.8, 0.08, 1, lod, BM_PAINTED, 2, {"gf": 1.4}, 1.0, 0.0)
# --- turismo y otros
func rc_sp_59(lod: int, _f: int, w: float) -> void:
	# hotel: torre de ocho pisos con balcones, marquesina y cartel arriba
	sp_ground(w, BM_SIDEWALK)
	var top := sp_block(-1.5, -1.6, 1.5, 1.0, 0.08, 8, lod, BM_PLASTER, 1, {"gf": 1.8, "door": 1, "shop": true, "balc": "vidrio"}, 1.0)
	mb_box(Vector3(0, 1.6, 1.4), Vector3(1.8, 0.1, 0.9), BM_PAINTED, 2)
	sp_sign(0, top + 0.3, -0.3, 2.2, 0.8)
func rc_sp_60(lod: int, _f: int, w: float) -> void:
	# gran hotel: basamento con pileta en la terraza y torre de lujo
	sp_ground(w, BM_SIDEWALK)
	var t0 := sp_block(-3.6, -3.6, 3.6, 3.0, 0.08, 2, lod, BM_CONCRETE, 1, {"gf": 2.2, "door": 3, "shop": true}, 1.2)
	mb_box(Vector3(1.8, t0, 1.2), Vector3(2.8, 0.05, 1.6), BM_MIRROR, 3, 4)
	var top := sp_block(-3.2, -3.2, 0.4, 0.4, t0, 14, lod, BM_PAINTED, 1, {"curtain": true, "glass": BM_MIRROR}, 0.7, 0.3)
	sp_sign(-1.4, top + 0.3, 0.3, 2.8, 0.7)
	mb_box(Vector3(0, 1.8, 3.4), Vector3(3.0, 0.1, 0.9), BM_PAINTED, 2)
func rc_sp_61(lod: int, _f: int, w: float) -> void:
	# shopping: caja grande de dos plantas, atrio vidriado, carteles y estacionamiento
	sp_ground(w, BM_ASPHALT)
	var top := sp_block(-3.6, -3.6, 3.6, 0.8, 0.08, 2, lod, BM_PLASTER, 1, {"gf": 2.6, "sill": 1.6, "wh": 0.6, "ww": 0.3}, 1.6, 0.3)
	sp_block(-1.0, 0.8, 1.0, 1.8, 0.08, 1, lod, BM_PAINTED, 1, {"gf": 4.4, "curtain": true, "glass": BM_GLASS}, 0.7, 0.0)
	sp_sign(0, top - 1.2, 0.84, 3.6, 0.8)
	if lod != LOD_FAR:
		for k in 5:
			sp_embed(rc_sedan if k % 2 == 0 else rc_hatch, lod, Vector3(-3.2 + k * 1.6, 0.08, 3.0), PI * 0.5)
func rc_sp_62(lod: int, _f: int, w: float) -> void:
	# barrio cerrado: muro, portón con garita, cuatro casas con pileta y pasto
	sp_ground(w, BM_TURF)
	mb_box(Vector3(0, 0.08, 0), Vector3(1.0, 0.02, w * 0.95), BM_ASPHALT, 0, 4)
	for c in [Vector3(-2.0, 0, -2.0), Vector3(2.0, 0, -2.0), Vector3(-2.0, 0, 2.0), Vector3(2.0, 0, 2.0)]:
		sp_embed(rc_chalet, lod, c + Vector3(0, 0.08, 0), (PI * 0.5 if c.x < 0 else -PI * 0.5), 0.55)
		mb_box(Vector3(c.x * 1.55, 0.09, c.z), Vector3(0.6, 0.02, 0.9), BM_MIRROR, 3, 4)
	if lod != LOD_FAR:
		for side in [[0, -3.85, 7.6, 0.1], [3.85, 0, 0.1, 7.6], [-3.85, 0, 0.1, 7.6], [-2.3, 3.85, 3.0, 0.1], [2.3, 3.85, 3.0, 0.1]]:
			mb_box(Vector3(side[0], 0.08, side[1]), Vector3(side[2], 1.0, side[3]), BM_PLASTER, 1)
	mb_box(Vector3(1.2, 0.08, 3.6), Vector3(0.6, 1.2, 0.5), BM_PLASTER, 1)
func rc_sp_63(lod: int, _f: int, w: float) -> void:
	# chacra: granero rojo, silo, casa, surcos y molino de la pampa
	sp_ground(w, BM_TURF)
	if lod != LOD_FAR:
		for k in 7:
			mb_box(Vector3(-1.0, 0.09, -3.4 + k * 0.5), Vector3(5.0, 0.04, 0.22), BM_PLAIN, 1, 4)
	var top := sp_block(1.2, 0.6, 3.6, 3.4, 0.08, 1, lod, BM_PAINTED, 2, {"gf": 2.0, "door": 0, "ww": 0.4}, 1.0, 0.0)
	mb_gable(Vector3(2.4, top, 2.0), 2.4, 2.8, 1.2, BM_SHEET, 0, false, BM_PAINTED, 2)
	mb_cyl(Vector3(0.3, 0.08, 2.6), 0.6, 4.0, [12, 8, 6][lod], BM_SHEET, 0)
	mb_cone(Vector3(0.3, 4.08, 2.6), 0.65, 0.6, [12, 8, 6][lod], BM_SHEET, 0)
	sp_embed(rc_chalet, lod, Vector3(-2.4, 0.08, 2.2), 0.0, 0.6)
	mb_limb(Vector3(-3.4, 0.08, -0.4), Vector3(-3.4, 4.0, -0.4), 0.12, 0.06, 4)
	if lod != LOD_FAR:
		for k in 8:
			var a := TAU * k / 8.0
			mb_box(Vector3(-3.4 + cos(a) * 0.4, 4.0 + sin(a) * 0.4, -0.3), Vector3(0.35, 0.1, 0.02), BM_PAINTED, 0)
func rc_sp_64(lod: int, _f: int, w: float) -> void:
	# frigorífico: cámaras frías, andenes de carga con camiones y chimenea
	sp_ground(w, BM_CONCRETE)
	sp_block(-3.6, -3.6, 3.0, 0.6, 0.08, 2, lod, BM_PAINTED, 1, {"gf": 2.6, "sill": 2.0, "wh": 0.5}, 1.2, 0.3)
	for k in 4:
		mb_quad(Vector3(-3.0 + k * 1.6, 0.4, 0.62), Vector3(-2.0 + k * 1.6, 0.4, 0.62), Vector3(-2.0 + k * 1.6, 1.9, 0.62), Vector3(-3.0 + k * 1.6, 1.9, 0.62), BM_SHEET, 2)
	mb_box(Vector3(-0.3, 0.08, 1.0), Vector3(6.6, 0.4, 0.8), BM_CONCRETE, 0, 63 - 8)
	mb_chimney(Vector3(3.4, 0.08, -3.2), 10.0, 0.3)
	if lod != LOD_FAR:
		for k in 2:
			sp_embed(rc_utilitario, lod, Vector3(-2.2 + k * 3.2, 0.08, 2.4), PI * 0.5)
# --- maravillas (terminadas; en obra las dibuja emit_def)
func rc_sp_70(lod: int, _f: int, w: float) -> void:
	# torre mirador: fuste alto y fino, mirador vidriado arriba y antena
	sp_ground(w, BM_SIDEWALK)
	sp_block(-2.4, -2.4, 2.4, 2.4, 0.08, 1, lod, BM_PAINTED, 1, {"gf": 2.4, "shop": true, "door": 2}, 1.2, 0.0)
	mb_limb(Vector3(0, 2.4, 0), Vector3(0, 32.0, 0), 1.3, 0.9, [12, 10, 8][lod])
	mb_cyl(Vector3(0, 32.0, 0), 2.4, 2.4, [16, 12, 8][lod], BM_MIRROR, 3)
	mb_cyl(Vector3(0, 34.4, 0), 2.6, 0.3, [16, 12, 8][lod], BM_PAINTED, 1)
	mb_limb(Vector3(0, 34.7, 0), Vector3(0, 42.0, 0), 0.2, 0.05, 6)
func rc_sp_71(lod: int, _f: int, w: float) -> void:
	# gran parque: pasto, lago grande, senderos y obelisco (los árboles van aparte)
	sp_ground(w, BM_TURF)
	mb_box(Vector3(0, 0.08, 0), Vector3(w * 0.95, 0.02, 0.8), BM_SIDEWALK, 0, 4)
	mb_box(Vector3(0, 0.08, 0), Vector3(0.8, 0.02, w * 0.95), BM_SIDEWALK, 0, 4)
	mb_cyl(Vector3(3.0, 0.07, 2.8), 2.4, 0.03, [20, 14, 10][lod], BM_MIRROR, 3)
	mb_box(Vector3(0, 0.08, 0), Vector3(1.6, 0.4, 1.6), BM_CONCRETE, 0, 63 - 8)
	mb_limb(Vector3(0, 0.48, 0), Vector3(0, 9.0, 0), 0.5, 0.35, 4)
	mb_cone(Vector3(0, 9.0, 0), 0.5, 0.8, 4, BM_CONCRETE, 0)
	if lod == LOD_NEAR:
		for k in 6:
			var a := TAU * k / 6.0
			sp_embed(rc_banco, lod, Vector3(cos(a) * 2.2, 0.08, sin(a) * 2.2), -a - PI * 0.5)
func rc_sp_72(lod: int, _f: int, w: float) -> void:
	# estadio monumental: cancha, tribunas ovaladas en anillos, techo perimetral y torres de luz
	sp_ground(w, BM_CONCRETE)
	mb_box(Vector3(0, 0.08, 0), Vector3(6.0, 0.02, 4.0), BM_TURF, 0, 4)
	var n: int = [32, 20, 12][lod]
	var rings: int = [6, 4, 2][lod]
	for r in rings:
		var rx: float = 3.8 + r * 0.32
		var rz: float = 2.8 + r * 0.32
		var y: float = 0.08 + r * 0.6
		for k in n:
			var a0: float = TAU * k / n
			var a1: float = TAU * (k + 1) / n
			var p0 := Vector3(cos(a0) * rx, y, sin(a0) * rz)
			var p1 := Vector3(cos(a1) * rx, y, sin(a1) * rz)
			var q0 := Vector3(cos(a0) * (rx + 0.32), y + 0.6, sin(a0) * (rz + 0.32))
			var q1 := Vector3(cos(a1) * (rx + 0.32), y + 0.6, sin(a1) * (rz + 0.32))
			mb_quad(p1, p0, q0, q1, BM_CONCRETE, 1)
	var ry: float = 0.08 + rings * 0.6
	var ro: float = 3.8 + rings * 0.32
	for k in n:
		var a0: float = TAU * k / n
		var a1: float = TAU * (k + 1) / n
		var p0 := Vector3(cos(a0) * ro, ry, sin(a0) * (ro - 1.0))
		var p1 := Vector3(cos(a1) * ro, ry, sin(a1) * (ro - 1.0))
		mb_quad(p0, p1, Vector3(p1.x, 0.08, p1.z), Vector3(p0.x, 0.08, p0.z), BM_CONCRETE, 1)
		mb_quad(Vector3(p1.x * 0.8, ry + 0.8, p1.z * 0.8), Vector3(p0.x * 0.8, ry + 0.8, p0.z * 0.8), p0 + Vector3(0, 0.5, 0), p1 + Vector3(0, 0.5, 0), BM_PAINTED, 2)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			mb_box(Vector3(sx * 5.4, 0.08, sz * 4.4), Vector3(0.2, 9.0, 0.2), BM_PAINTED, 0, 63 - 8)
			mb_box(Vector3(sx * 5.4, 9.0, sz * 4.4), Vector3(1.0, 0.6, 0.2), BM_EMIT, 0)
func rc_sp_73(lod: int, _f: int, w: float) -> void:
	# palacio: frente neoclásico con columnas, alas, cúpula central sobre tambor y jardín
	sp_ground(w, BM_TURF)
	mb_box(Vector3(0, 0.08, 4.0), Vector3(1.6, 0.02, 3.6), BM_SIDEWALK, 0, 4)
	var top := sp_block(-5.4, -4.8, 5.4, 1.2, 0.08, 3, lod, BM_PLASTER, 1, {"gf": 2.2, "door": 5, "cornice": true, "balc": "frances", "balc_all": true}, 1.0, 0.5)
	sp_columns(-2.0, 2.0, 1.6, top - 0.08, 8, 0.18)
	mb_box(Vector3(0, top, 1.3), Vector3(4.6, 0.4, 0.8), BM_CONCRETE, 0)
	mb_gable(Vector3(0, top + 0.4, 1.3), 4.6, 0.8, 1.0, BM_CONCRETE, 0, true)
	mb_cyl(Vector3(0, top, -1.8), 2.0, 2.0, [16, 12, 8][lod], BM_PLASTER, 1)
	mb_blob(Vector3(0, top + 2.0, -1.8), Vector3(2.0, 2.2, 2.0), [14, 10, 6][lod], [7, 5, 3][lod], 73, BM_SHEET, 0, false)
	mb_limb(Vector3(0, top + 4.0, -1.8), Vector3(0, top + 6.0, -1.8), 0.25, 0.1, 6)
