# Edificios de la etapa 2: constructor de mallas, recetas y catálogo.
# Materiales (UV2.x del vértice). 0-9 son capas del arreglo de texturas; el resto los dibuja el shader.
const BM_PLAIN := 0
const BM_BRICK := 1
const BM_PLASTER := 2
const BM_CONCRETE := 3
const BM_TILES := 4
const BM_SHEET := 5
const BM_WOOD := 6
const BM_PAINTED := 7
const BM_ASPHALT := 8
const BM_SIDEWALK := 9
const BM_GLASS := 10
const BM_MIRROR := 11
const BM_DARK := 12
const BM_FARWIN := 13
const LOD_NEAR := 0
const LOD_MID := 1
const LOD_FAR := 2
const FLOOR_H := 1.3
# las caras con normal.y mayor que esto se cubren de nieve (mismo valor en building.gdshaderinc)
const SNOW_NY := 0.5
# arreglos de la malla que se está armando
var mb_v := PackedVector3Array()
var mb_n := PackedVector3Array()
var mb_t := PackedFloat32Array()
var mb_uv := PackedVector2Array()
var mb_uv2 := PackedVector2Array()
var mb_i := PackedInt32Array()
# transformación aplicada a todo lo que se agrega (para piezas giradas)
var mb_xf := Transform3D.IDENTITY
# catálogo: lista de modelos y mallas ya armadas
var cat_models: Array = []
var cat_cache: Dictionary = {}
# modelos por zona, nivel y tamaño: clave zona * 10 + nivel * 2 + (1 si es 2×2)
var bset: Dictionary = {}
# dibujo: por bloque, clave (modelo * 64 + pisos) * 3 + versión -> MultiMeshInstance3D
var building_mat: ShaderMaterial
var building_lite_mat: ShaderMaterial
# el mismo parámetro en las dos variantes del shader de edificios
func bmat_param(n: String, v: Variant) -> void:
	building_mat.set_shader_parameter(n, v)
	building_lite_mat.set_shader_parameter(n, v)
var bnodes: Array = []
var _binst: Dictionary = {}
var bq_last: int = -1
var b_near_on: bool = false
# prueba: celda -> {m, n, dark} (lo llena emit_building cuando bcheck_on)
var bcheck_on: bool = false
var bcheck_log: Dictionary = {}
func mb_begin() -> void:
	mb_v = PackedVector3Array()
	mb_n = PackedVector3Array()
	mb_t = PackedFloat32Array()
	mb_uv = PackedVector2Array()
	mb_uv2 = PackedVector2Array()
	mb_i = PackedInt32Array()
	mb_xf = Transform3D.IDENTITY
# UV en metros a partir de la posición final: en paredes u = a lo largo de la pared, v = -altura;
# en techos y pisos (x, z). Así las texturas siguen sin cortes de una pieza a la otra.
func mb_vert(p: Vector3, n: Vector3, mat: int, tm: int, uv: Vector2, auto_uv: bool) -> void:
	var t := Vector3(1, 0, 0)
	if absf(n.y) < 0.7:
		var h := Vector2(n.z, -n.x).normalized()
		t = Vector3(h.x, 0.0, h.y)
		if auto_uv:
			uv = Vector2(p.x * h.x + p.z * h.y, -p.y)
	elif auto_uv:
		uv = Vector2(p.x, p.z)
	mb_v.append(p)
	mb_n.append(n)
	mb_t.append_array([t.x, t.y, t.z, 1.0])
	mb_uv.append(uv)
	mb_uv2.append(Vector2(mat, tm))
# cuadrilátero a→b→c→d antihorario visto de frente (a abajo a la izquierda, d arriba a la izquierda).
# Si uva != uvc el UV va de uva (en a) a uvc (en c); si no, se calcula en metros.
func mb_quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3, mat: int, tm: int, uva := Vector2.ZERO, uvc := Vector2.ZERO) -> void:
	a = mb_xf * a
	b = mb_xf * b
	c = mb_xf * c
	d = mb_xf * d
	var n := (b - a).cross(d - a).normalized()
	var auto := uva == uvc
	var o := mb_v.size()
	mb_vert(a, n, mat, tm, uva, auto)
	mb_vert(b, n, mat, tm, Vector2(uvc.x, uva.y), auto)
	mb_vert(c, n, mat, tm, uvc, auto)
	mb_vert(d, n, mat, tm, Vector2(uva.x, uvc.y), auto)
	# Godot toma como frente los triángulos en sentido horario
	mb_i.append_array([o, o + 2, o + 1, o, o + 3, o + 2])
# triángulo a→b→c antihorario visto de frente
func mb_tri(a: Vector3, b: Vector3, c: Vector3, mat: int, tm: int) -> void:
	a = mb_xf * a
	b = mb_xf * b
	c = mb_xf * c
	var n := (b - a).cross(c - a).normalized()
	var o := mb_v.size()
	mb_vert(a, n, mat, tm, Vector2.ZERO, true)
	mb_vert(b, n, mat, tm, Vector2.ZERO, true)
	mb_vert(c, n, mat, tm, Vector2.ZERO, true)
	mb_i.append_array([o, o + 2, o + 1])
# caja con la base centrada en c; faces: bits +X −X +Y −Y +Z −Z (63 = todas)
func mb_box(c: Vector3, s: Vector3, mat: int, tm: int, faces := 63) -> void:
	var x0 := c.x - s.x * 0.5
	var x1 := c.x + s.x * 0.5
	var z0 := c.z - s.z * 0.5
	var z1 := c.z + s.z * 0.5
	var y0 := c.y
	var y1 := c.y + s.y
	if faces & 1:
		mb_quad(Vector3(x1, y0, z1), Vector3(x1, y0, z0), Vector3(x1, y1, z0), Vector3(x1, y1, z1), mat, tm)
	if faces & 2:
		mb_quad(Vector3(x0, y0, z0), Vector3(x0, y0, z1), Vector3(x0, y1, z1), Vector3(x0, y1, z0), mat, tm)
	if faces & 4:
		mb_quad(Vector3(x0, y1, z1), Vector3(x1, y1, z1), Vector3(x1, y1, z0), Vector3(x0, y1, z0), mat, tm)
	if faces & 8:
		mb_quad(Vector3(x0, y0, z0), Vector3(x1, y0, z0), Vector3(x1, y0, z1), Vector3(x0, y0, z1), mat, tm)
	if faces & 16:
		mb_quad(Vector3(x0, y0, z1), Vector3(x1, y0, z1), Vector3(x1, y1, z1), Vector3(x0, y1, z1), mat, tm)
	if faces & 32:
		mb_quad(Vector3(x1, y0, z0), Vector3(x0, y0, z0), Vector3(x0, y1, z0), Vector3(x1, y1, z0), mat, tm)
# techo a dos aguas sobre el rectángulo lx × lz con base en c; cumbrera a lo largo de X si along_x.
# Las puntas triangulares usan wall_mat (si es -1, el mismo material del techo).
# ov = alero (el techo sobresale; las puntas quedan en el plano de la pared)
func mb_gable(c: Vector3, lx: float, lz: float, h: float, mat: int, tm: int, along_x: bool, wall_mat := -1, wtm := 1, ov := 0.0) -> void:
	if not along_x:
		var keep := mb_xf
		mb_xf = mb_xf * Transform3D(Basis(Vector3.UP, PI * 0.5), c) * Transform3D(Basis.IDENTITY, -c)
		mb_gable(c, lz, lx, h, mat, tm, true, wall_mat, wtm, ov)
		mb_xf = keep
		return
	var x0 := c.x - lx * 0.5
	var x1 := c.x + lx * 0.5
	var z0 := c.z - lz * 0.5
	var z1 := c.z + lz * 0.5
	var y := c.y
	var yh := c.y + h
	var ye := y - ov * h / (lz * 0.5)
	mb_quad(Vector3(x0 - ov, ye, z1 + ov), Vector3(x1 + ov, ye, z1 + ov), Vector3(x1 + ov, yh, c.z), Vector3(x0 - ov, yh, c.z), mat, tm)
	mb_quad(Vector3(x1 + ov, ye, z0 - ov), Vector3(x0 - ov, ye, z0 - ov), Vector3(x0 - ov, yh, c.z), Vector3(x1 + ov, yh, c.z), mat, tm)
	if ov > 0.0:
		# cara de abajo del alero
		mb_quad(Vector3(x1 + ov, ye, z1 + ov), Vector3(x0 - ov, ye, z1 + ov), Vector3(x0 - ov, yh, c.z), Vector3(x1 + ov, yh, c.z), mat, tm)
		mb_quad(Vector3(x0 - ov, ye, z0 - ov), Vector3(x1 + ov, ye, z0 - ov), Vector3(x1 + ov, yh, c.z), Vector3(x0 - ov, yh, c.z), mat, tm)
	var wm := mat if wall_mat < 0 else wall_mat
	var wt := tm if wall_mat < 0 else wtm
	mb_tri(Vector3(x1, y, z1), Vector3(x1, y, z0), Vector3(x1, yh, c.z), wm, wt)
	mb_tri(Vector3(x0, y, z0), Vector3(x0, y, z1), Vector3(x0, yh, c.z), wm, wt)
# cilindro vertical con tapa arriba
func mb_cyl(c: Vector3, r: float, h: float, seg: int, mat: int, tm: int) -> void:
	for k in seg:
		var a0 := TAU * k / seg
		var a1 := TAU * (k + 1) / seg
		var p0 := Vector3(c.x + cos(a0) * r, c.y, c.z + sin(a0) * r)
		var p1 := Vector3(c.x + cos(a1) * r, c.y, c.z + sin(a1) * r)
		var up := Vector3(0, h, 0)
		mb_quad(p1, p0, p0 + up, p1 + up, mat, tm)
		mb_tri(c + up, p1 + up, p0 + up, mat, tm)
func mb_end() -> ArrayMesh:
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = mb_v
	arr[Mesh.ARRAY_NORMAL] = mb_n
	arr[Mesh.ARRAY_TANGENT] = mb_t
	arr[Mesh.ARRAY_TEX_UV] = mb_uv
	arr[Mesh.ARRAY_TEX_UV2] = mb_uv2
	arr[Mesh.ARRAY_INDEX] = mb_i
	var m := ArrayMesh.new()
	if not mb_v.is_empty():
		m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return m
# --- catálogo
func cat_add(id: String, zones: Array, levels: Array, big: bool, floors: Dictionary, recipe: Callable) -> void:
	cat_models.append({"id": id, "zones": zones, "levels": levels, "big": big, "floors": floors, "recipe": recipe})
func cat_register() -> void:
	cat_models.clear()
	cat_cache.clear()
	for id in ["chorizo", "chalet", "casa_rejas", "ladrillo_terraza", "ph", "moderna", "galeria", "esquina_ochava", "chorizo_b", "chalet_b"]:
		cat_add(id, [Z_R], [1], false, {}, Callable(self, "rc_" + id))
	for k in range(1, 9):
		cat_add("depto_%d" % k, [Z_R], [2, 3], false, {2: [3, 4, 5], 3: [6, 7, 8]}, Callable(self, "rc_depto_%d" % k))
	for id in ["torre_cortina", "torre_franjas", "torre_escalonada", "torre_cilindro"]:
		cat_add(id, [Z_R], [4], false, {4: [12, 16, 20]}, Callable(self, "rc_" + id))
	for id in ["torre_grande_a", "torre_grande_b"]:
		cat_add(id, [Z_R], [3, 4], true, {3: [6, 8], 4: [12, 16, 20]}, Callable(self, "rc_" + id))
	# comercio y mixta (la mixta es comercio abajo y viviendas arriba)
	cat_add("almacen", [Z_C, Z_M], [1], false, {}, rc_almacen)
	cat_add("kiosco", [Z_C], [1], false, {}, rc_kiosco)
	cat_add("locales_a", [Z_C, Z_M], [2, 3], false, {2: [3, 4], 3: [6, 8]}, rc_locales_a)
	cat_add("locales_b", [Z_C, Z_M], [2, 3], false, {2: [3, 4], 3: [6, 8]}, rc_locales_b)
	cat_add("oficinas_a", [Z_C], [3], false, {3: [6, 8, 10]}, rc_oficinas_a)
	cat_add("oficinas_b", [Z_C], [3], false, {3: [6, 8, 10]}, rc_oficinas_b)
	cat_add("torre_oficinas", [Z_C, Z_M], [4], false, {4: [12, 16, 20]}, rc_torre_oficinas)
	cat_add("torre_oficinas_grande", [Z_C, Z_M], [3, 4], true, {3: [6, 8], 4: [12, 16, 20]}, rc_torre_oficinas_grande)
	# industria
	cat_add("galpon_chapa", [Z_I], [1], false, {}, rc_galpon_chapa)
	cat_add("fabrica_ladrillo", [Z_I], [2], false, {}, rc_fabrica_ladrillo)
	cat_add("planta_silos", [Z_I], [3], false, {}, rc_planta_silos)
	cat_add("fabrica_grande", [Z_I], [3, 4], false, {}, rc_fabrica_grande)
	cat_add("complejo", [Z_I], [4], false, {}, rc_complejo)
	cat_add("complejo_grande", [Z_I], [3, 4], true, {}, rc_complejo_grande)
	bset.clear()
	for m in cat_models.size():
		var md: Dictionary = cat_models[m]
		for z in md["zones"]:
			for l in md["levels"]:
				var k: int = z * 10 + l * 2 + (1 if md["big"] else 0)
				if not bset.has(k):
					bset[k] = []
				bset[k].append(m)
# modelo y pisos para la celda i: (modelo, pisos) o (-1, 0). Si no hay modelo 2×2 para esa zona y
# nivel, se usa uno normal (emit_building lo agranda).
func pick_model(i: int) -> Vector2i:
	var z: int = zone[i]
	var l: int = lvl[i]
	var big := part[i] == i
	var cands: Array = bset.get(z * 10 + l * 2 + (1 if big else 0), [])
	if cands.is_empty() and big:
		cands = bset.get(z * 10 + l * 2, [])
	if cands.is_empty():
		return Vector2i(-1, 0)
	var m: int = cands[(vari[i] + int(hsh(i, 41) * 7.0)) % cands.size()]
	var fl: Array = cat_models[m]["floors"].get(l, [0])
	return Vector2i(m, fl[int(hsh(i, 43) * fl.size()) % fl.size()])
func cat_mesh(m: int, floors: int, lod: int) -> ArrayMesh:
	var key := (m * 64 + floors) * 3 + lod
	if cat_cache.has(key):
		return cat_cache[key]
	var md: Dictionary = cat_models[m]
	mb_begin()
	md["recipe"].call(lod, floors, CELL * (1.85 if md["big"] else 0.82))
	var mesh := mb_end()
	cat_cache[key] = mesh
	return mesh
# --- dibujo por bloque
# torres: paleta propia (vidrios y marcos azulados, verdosos, arena, pizarra) para que el centro no sea
# todo del mismo gris
const TOWER_PAL := [Color(0.45, 0.62, 0.78), Color(0.35, 0.58, 0.55), Color(0.72, 0.64, 0.5), Color(0.3, 0.34, 0.42), Color(0.8, 0.76, 0.68), Color(0.5, 0.52, 0.72), Color(0.72, 0.5, 0.42)]
func building_color(i: int, z: int, v: int, wall: Color) -> Color:
	if lvl[i] >= 4 or (z == Z_C and lvl[i] >= 3):
		return tint(TOWER_PAL[(v / 3 + i) % TOWER_PAL.size()], i)
	match z:
		Z_C:
			return tint(res_wall(v + 3), i)
		Z_I:
			return tint(Color(0.66, 0.64, 0.6) if v % 2 == 0 else Color(0.6, 0.62, 0.64), i)
	return wall
func emit_building(i: int, x: float, y: float, z: float, rot: float, wall: Color, dark: bool) -> void:
	var pk := pick_model(i)
	if pk.x < 0:
		return
	var md: Dictionary = cat_models[pk.x]
	var sc := 1.85 / 0.82 if part[i] == i and not md["big"] else 1.0
	var key := pk.x * 64 + pk.y
	if not _binst.has(key):
		_binst[key] = PackedFloat32Array()
	var b: PackedFloat32Array = _binst[key]
	var c := cos(rot) * sc
	var s := sin(rot) * sc
	var col := building_color(i, zone[i], vari[i], wall)
	b.append_array([c, 0.0, s, x, 0.0, 1.0, 0.0, y, -s, 0.0, c, z, col.r, col.g, col.b, 1.0, 1.0 if dark else 0.0, float(int(hsh(i, 44) * 8.0)) / 8.0, hsh(i, 42), 0.0])
	_binst[key] = b
	if bcheck_on:
		if bcheck_log.has(i):
			bcheck_log[i]["n"] += 1
		else:
			bcheck_log[i] = {"m": pk.x, "n": 1, "dark": dark}
# vuelca las instancias juntadas por build_chunk en los nodos del bloque (uno por modelo y versión)
func flush_buildings(ch: int) -> void:
	var q: int = opts["quality"]
	var nodes: Dictionary = bnodes[ch]
	for k in nodes:
		if not _binst.has(k / 3):
			nodes[k].multimesh.instance_count = 0
	for key in _binst:
		var buf: PackedFloat32Array = _binst[key]
		var cnt := buf.size() / 20
		# la versión cerca se arma recién cuando la cámara se acerca (armarla cuesta y no se ve)
		for lod in ([LOD_FAR] if q == 0 else ([LOD_NEAR, LOD_MID, LOD_FAR] if b_near_on else [LOD_MID, LOD_FAR])):
			var nk: int = key * 3 + lod
			var node: MultiMeshInstance3D = nodes.get(nk)
			if node == null:
				node = new_mm_node(cat_mesh(key / 64, key % 64, lod), building_mat if lod == LOD_NEAR else building_lite_mat)
				nodes[nk] = node
			lod_ranges(node, lod, q)
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if lod != LOD_FAR or q == 2 else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			node.multimesh.instance_count = cnt
			node.multimesh.buffer = buf
		if q == 0:
			for lod in [LOD_NEAR, LOD_MID]:
				if nodes.has(key * 3 + lod):
					nodes[key * 3 + lod].multimesh.instance_count = 0
# Distancias de cada versión (medidas desde el centro del bloque). La versión cerca solo se usa con la
# cámara acercada: a la distancia normal sus detalles no se ven y costaban un 30 % más por cuadro.
func lod_ranges(node: GeometryInstance3D, lod: int, q: int) -> void:
	# sin fundido: Godot lo hace con un tramado de puntos que, a escala de bloque, se veía como granulado
	node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	node.visible = lod != LOD_NEAR or (b_near_on and q > 0)
	if q == 0:
		node.visibility_range_begin = 0.0
		node.visibility_range_end = 0.0
		return
	# cortes exactos: dos versiones a la vez se pisan (caras en el mismo lugar)
	node.visibility_range_begin = [0.0, 130.0 if b_near_on else 0.0, 200.0][lod]
	node.visibility_range_begin_margin = 0.0
	node.visibility_range_end = [130.0, 200.0, 0.0][lod]
	node.visibility_range_end_margin = 0.0
func update_building_lod() -> void:
	var want := cam_dist < (75.0 if b_near_on else 65.0)
	if want == b_near_on:
		return
	b_near_on = want
	var q: int = opts["quality"]
	if want and q > 0:
		# los bloques se rehacen de a uno por cuadro y ahí se arman las versiones cerca
		mark_all_dirty()
	for nodes in bnodes:
		for k in nodes:
			lod_ranges(nodes[k], k % 3, q)
# --- recetas: (versión, pisos, ancho del lote). Frente hacia +Z, base en y = 0.
# --- piezas
# Cara plana con huecos rectangulares (en el marco local de la pared: x a lo largo, y arriba, z hacia
# afuera). holes: [x0, x1, y0, y1] ordenados por x. Arma bandas arriba y abajo de cada hueco y pilares.
func mb_wall_holes(L: float, yb: float, yt: float, holes: Array, mat: int, tm: int) -> void:
	var x := 0.0
	for h in holes:
		if h[0] > x + 0.001:
			mb_quad(Vector3(x, yb, 0), Vector3(h[0], yb, 0), Vector3(h[0], yt, 0), Vector3(x, yt, 0), mat, tm)
		if h[2] > yb + 0.001:
			mb_quad(Vector3(h[0], yb, 0), Vector3(h[1], yb, 0), Vector3(h[1], h[2], 0), Vector3(h[0], h[2], 0), mat, tm)
		if h[3] < yt - 0.001:
			mb_quad(Vector3(h[0], h[3], 0), Vector3(h[1], h[3], 0), Vector3(h[1], yt, 0), Vector3(h[0], yt, 0), mat, tm)
		x = h[1]
	if x < L - 0.001:
		mb_quad(Vector3(x, yb, 0), Vector3(L, yb, 0), Vector3(L, yt, 0), Vector3(x, yt, 0), mat, tm)
# hueco hundido: cuatro caras de jamba (del material de la pared) y el relleno al fondo
func mb_recess(x0: float, x1: float, y0: float, y1: float, dd: float, mat: int, tm: int, fill: int, ftm: int, uva: Vector2, uvc: Vector2) -> void:
	mb_quad(Vector3(x0, y0, 0), Vector3(x0, y0, -dd), Vector3(x0, y1, -dd), Vector3(x0, y1, 0), mat, tm)
	mb_quad(Vector3(x1, y0, -dd), Vector3(x1, y0, 0), Vector3(x1, y1, 0), Vector3(x1, y1, -dd), mat, tm)
	mb_quad(Vector3(x0, y1, -dd), Vector3(x1, y1, -dd), Vector3(x1, y1, 0), Vector3(x0, y1, 0), mat, tm)
	mb_quad(Vector3(x0, y0, 0), Vector3(x1, y0, 0), Vector3(x1, y0, -dd), Vector3(x0, y0, -dd), mat, tm)
	mb_quad(Vector3(x0, y0, -dd), Vector3(x1, y0, -dd), Vector3(x1, y1, -dd), Vector3(x0, y1, -dd), fill, ftm, uva, uvc)
# Pared de p0 a p1 (alturas desde y0) con pisos y ventanas. La cara mira a la derecha del recorrido
# (recorriendo el contorno en sentido antihorario visto desde arriba, mira hacia afuera).
# Opciones (o): gf alto de planta baja · ww, wh, sill ventana · door columna de la puerta (planta baja)
# · shop planta baja vidriera · balc "hierro" | "vidrio" | "corrido" | "frances" (pisos altos)
# · shutters persianas · bars rejas en planta baja · cornice cornisa arriba · bands losas marcadas
# · curtain muro cortina · glass material del vidrio · uofs desplazamiento del número de ventana
func mb_wall_win(p0: Vector3, p1: Vector3, y0: float, floors: int, cols: int, lod: int, mat: int, tm: int, o: Dictionary) -> float:
	var d := Vector3(p1.x - p0.x, 0, p1.z - p0.z)
	var L := d.length()
	var gf: float = o.get("gf", FLOOR_H)
	var top := gf + (floors - 1) * FLOOR_H
	if L < 0.01:
		return y0 + top
	var dir := d / L
	var keep := mb_xf
	mb_xf = keep * Transform3D(Basis(dir, Vector3.UP, dir.cross(Vector3.UP)), Vector3(p0.x, y0, p0.z))
	var curtain: bool = o.get("curtain", false)
	var gl: int = o.get("glass", BM_GLASS)
	var uo: float = o.get("uofs", 0.0)
	if cols <= 0 or floors <= 0:
		mb_quad(Vector3(0, 0, 0), Vector3(L, 0, 0), Vector3(L, top, 0), Vector3(0, top, 0), mat, tm)
		mb_xf = keep
		return y0 + top
	var pitch := L / cols
	if lod != LOD_NEAR:
		# media y lejana: fachada entera con las ventanas dibujadas por el shader. En la máscara de tinte
		# van además dos marcas: +4 persianas, +8 planta baja vidriera
		var fm: int = gl if curtain else BM_FARWIN + mat
		var ftm := tm + (4 if o.get("shutters", false) and not curtain else 0)
		var gtm := ftm + (8 if o.get("shop", false) and not curtain else 0)
		mb_quad(Vector3(0, 0, 0), Vector3(L, 0, 0), Vector3(L, gf, 0), Vector3(0, gf, 0), fm, gtm, Vector2(uo, 0), Vector2(uo + cols, 1))
		if floors > 1:
			mb_quad(Vector3(0, gf, 0), Vector3(L, gf, 0), Vector3(L, top, 0), Vector3(0, top, 0), fm, ftm, Vector2(uo, 1), Vector2(uo + cols, floors))
		if lod == LOD_MID:
			if o.get("bands", false):
				for r in range(1, floors):
					mb_box(Vector3(L * 0.5, gf + (r - 1) * FLOOR_H - 0.06, 0.0), Vector3(L + 0.04, 0.12, 0.06), BM_CONCRETE, 0, 63 - 32 - 8)
			if o.get("cornice", false):
				mb_box(Vector3(L * 0.5, top - 0.16, 0.0), Vector3(L + 0.2, 0.16, 0.14), BM_CONCRETE, 0, 63 - 32)
		mb_xf = keep
		return y0 + top
	var balc: String = o.get("balc", "")
	for r in floors:
		var yb := 0.0 if r == 0 else gf + (r - 1) * FLOOR_H
		var fh := gf if r == 0 else FLOOR_H
		var holes: Array = []
		for k in cols:
			var xc := (k + 0.5) * pitch
			var ww: float = o.get("ww", minf(0.62, pitch * 0.55))
			var y0w: float = yb + o.get("sill", 0.34)
			var y1w: float = y0w + o.get("wh", 0.74)
			var fill := gl
			var ftm := 0
			if curtain:
				ww = pitch - 0.07
				y0w = yb + 0.08
				y1w = yb + fh - 0.1
			elif r == 0 and o.get("shop", false):
				ww = pitch * 0.84
				y0w = yb + 0.12
				y1w = yb + fh - 0.36
			elif r > 0 and balc != "":
				y0w = yb + 0.04
				y1w = minf(yb + fh - 0.16, y0w + 1.0)
			if r == 0 and k == o.get("door", -1):
				ww = minf(0.6, pitch * 0.75)
				y0w = yb
				y1w = minf(yb + fh - 0.25, 1.05)
				if not o.get("shop", false):
					fill = BM_WOOD
					ftm = 2
			y1w = minf(y1w, yb + fh - 0.06)
			holes.append([xc - ww * 0.5, xc + ww * 0.5, y0w, y1w, fill, ftm, Vector2(uo + k, r)])
		if lod == LOD_MID:
			# pared entera y el vidrio apenas adelante (3 cm, para que de lejos no se pisen)
			mb_quad(Vector3(0, yb, 0), Vector3(L, yb, 0), Vector3(L, yb + fh, 0), Vector3(0, yb + fh, 0), mat, tm)
			for h in holes:
				var uv: Vector2 = h[6]
				var uva := uv if h[4] == gl else Vector2.ZERO
				var uvc := uv + Vector2.ONE if h[4] == gl else Vector2.ZERO
				mb_quad(Vector3(h[0], h[2], 0.03), Vector3(h[1], h[2], 0.03), Vector3(h[1], h[3], 0.03), Vector3(h[0], h[3], 0.03), h[4], h[5], uva, uvc)
		else:
			mb_wall_holes(L, yb, yb + fh, holes, mat, tm)
			for h in holes:
				var uv: Vector2 = h[6]
				var isg: bool = h[4] == gl
				mb_recess(h[0], h[1], h[2], h[3], 0.05 if curtain else 0.1, mat, tm, h[4], h[5], uv if isg else Vector2.ZERO, uv + Vector2.ONE if isg else Vector2.ZERO)
				var xc: float = (h[0] + h[1]) * 0.5
				var ww: float = h[1] - h[0]
				var wh: float = h[3] - h[2]
				if isg and not curtain and h[2] > yb + 0.2 and not (r == 0 and o.get("shop", false)):
					mb_box(Vector3(xc, h[2] - 0.05, 0.02), Vector3(ww + 0.12, 0.05, 0.1), BM_CONCRETE, 0, 63 - 8 - 32)
				if r == 0 and o.get("bars", false) and isg and h[2] > yb + 0.1:
					for b in 5:
						mb_box(Vector3(h[0] + ww * (b + 0.5) / 5.0, h[2], 0.06), Vector3(0.025, wh, 0.025), BM_PAINTED, 0, 1 + 2 + 16 + 32)
					mb_box(Vector3(xc, h[3] - 0.03, 0.06), Vector3(ww, 0.03, 0.03), BM_PAINTED, 0, 63 - 8)
				if r > 0 and balc != "" and balc != "corrido" and isg:
					mb_balcony(xc, yb, ww, balc, lod)
			if r > 0 and balc == "corrido":
				mb_box(Vector3(L * 0.5, yb - 0.07, 0.21), Vector3(L, 0.07, 0.42), BM_CONCRETE, 0, 63 - 32)
				mb_rail(0.0, L, yb, 0.4, 0.5, "vidrio")
		if o.get("shutters", false) and not curtain:
			for h in holes:
				if h[4] == gl and not (r == 0 and o.get("shop", false)):
					var sw: float = (h[1] - h[0]) * 0.5
					for sx in [h[0] - sw * 0.5 - 0.02, h[1] + sw * 0.5 + 0.02]:
						mb_box(Vector3(sx, h[2], 0.0), Vector3(sw, h[3] - h[2], 0.035), BM_WOOD, 2, 63 - 8 - 32)
		if o.get("bands", false) and r > 0:
			mb_box(Vector3(L * 0.5, yb - 0.06, 0.0), Vector3(L + 0.04, 0.12, 0.06), BM_CONCRETE, 0, 63 - 32)
	if o.get("cornice", false):
		mb_box(Vector3(L * 0.5, top - 0.16, 0.0), Vector3(L + 0.2, 0.16, 0.14), BM_CONCRETE, 0, 63 - 32)
	mb_xf = keep
	return y0 + top
# balcón delante de una ventana-puerta (marco local de la pared)
func mb_balcony(xc: float, yb: float, ww: float, kind: String, lod: int) -> void:
	if lod != LOD_NEAR:
		return
	var bw := ww + 0.36
	var bd := 0.42
	if kind == "frances":
		mb_box(Vector3(xc, yb, 0.04), Vector3(ww + 0.08, 0.04, 0.08), BM_CONCRETE, 0)
		mb_rail(xc - ww * 0.5 - 0.04, xc + ww * 0.5 + 0.04, yb + 0.04, 0.1, 0.42, "hierro")
		return
	mb_box(Vector3(xc, yb - 0.07, bd * 0.5), Vector3(bw, 0.07, bd), BM_CONCRETE, 0, 63 - 32)
	var k := "vidrio" if kind == "vidrio" or kind == "corrido" else "hierro"
	mb_rail(xc - bw * 0.5, xc + bw * 0.5, yb, bd - 0.02, 0.5, k)
	var keep := mb_xf
	# costados
	mb_xf = keep * Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(xc - bw * 0.5 + 0.02, 0, 0))
	mb_rail(-bd + 0.02, 0.0, yb, 0.0, 0.5, k)
	mb_xf = keep * Transform3D(Basis(Vector3.UP, -PI * 0.5), Vector3(xc + bw * 0.5 - 0.02, 0, 0))
	mb_rail(0.0, bd - 0.02, yb, 0.0, 0.5, k)
	mb_xf = keep
# baranda de x0 a x1 a la distancia z de la pared: hierro (pasamanos y barrotes) o vidrio
func mb_rail(x0: float, x1: float, y: float, z: float, h: float, kind: String) -> void:
	var L := x1 - x0
	mb_box(Vector3((x0 + x1) * 0.5, y + h - 0.035, z), Vector3(L, 0.035, 0.04), BM_PAINTED, 0)
	if kind == "vidrio":
		mb_quad(Vector3(x0, y, z + 0.01), Vector3(x1, y, z + 0.01), Vector3(x1, y + h - 0.035, z + 0.01), Vector3(x0, y + h - 0.035, z + 0.01), BM_MIRROR, 0)
		mb_quad(Vector3(x1, y, z - 0.01), Vector3(x0, y, z - 0.01), Vector3(x0, y + h - 0.035, z - 0.01), Vector3(x1, y + h - 0.035, z - 0.01), BM_MIRROR, 0)
		return
	var nb := maxi(2, int(L / 0.11))
	for b in nb + 1:
		mb_box(Vector3(x0 + L * b / nb, y, z), Vector3(0.018, h - 0.035, 0.018), BM_PAINTED, 0, 1 + 2 + 16 + 32)
# contorno: lista de puntos (y = 0) en sentido antihorario visto desde arriba
func rect_pts(x0: float, z0: float, x1: float, z1: float) -> Array:
	return [Vector3(x0, 0, z1), Vector3(x1, 0, z1), Vector3(x1, 0, z0), Vector3(x0, 0, z0)]
# paredes con ventanas alrededor del contorno; el lado 0 es el frente (puerta, vidriera, balcones)
func mb_walls(pts: Array, y0: float, floors: int, lod: int, mat: int, tm: int, o: Dictionary, pitch := 1.0) -> float:
	var top := y0
	var side := o.duplicate()
	for key in ["door", "shop", "balc"]:
		side.erase(key)
	if o.get("balc_all", false) and o.has("balc"):
		side["balc"] = o["balc"]
	for k in pts.size():
		var a: Vector3 = pts[k]
		var b: Vector3 = pts[(k + 1) % pts.size()]
		var L := Vector2(b.x - a.x, b.z - a.z).length()
		var oo: Dictionary = o.duplicate() if k == 0 else side.duplicate()
		oo["uofs"] = k * 16.0
		var cols := int(L / pitch + 0.3)
		if L < 0.5:
			cols = 0
		top = mb_wall_win(a, b, y0, floors, cols, lod, mat, tm, oo)
	return top
# techo plano (abanico desde el primer punto)
func mb_flat(pts: Array, y: float, mat: int, tm: int) -> void:
	for k in range(1, pts.size() - 1):
		var a: Vector3 = pts[0]
		var b: Vector3 = pts[k]
		var c: Vector3 = pts[k + 1]
		mb_tri(Vector3(a.x, y, a.z), Vector3(b.x, y, b.z), Vector3(c.x, y, c.z), mat, tm)
# muro bajo alrededor del techo (por dentro del contorno)
func mb_parapet(pts: Array, y: float, h: float, t: float, mat: int, tm: int) -> void:
	var keep := mb_xf
	for k in pts.size():
		var a: Vector3 = pts[k]
		var b: Vector3 = pts[(k + 1) % pts.size()]
		var d := Vector3(b.x - a.x, 0, b.z - a.z)
		var L := d.length()
		var dir := d / L
		mb_xf = keep * Transform3D(Basis(dir, Vector3.UP, dir.cross(Vector3.UP)), Vector3(a.x, y, a.z))
		mb_box(Vector3(L * 0.5, 0, -t * 0.5), Vector3(L, h, t), mat, tm, 63 - 8)
	mb_xf = keep
# tanque de agua y antenas sobre la terraza
func mb_tank(c: Vector3, s: float) -> void:
	mb_box(c, Vector3(0.9 * s, 0.25, 0.7 * s), BM_CONCRETE, 0, 63 - 8)
	mb_box(c + Vector3(0, 0.25, 0), Vector3(0.8 * s, 0.6 * s, 0.6 * s), BM_CONCRETE, 1, 63 - 8)
func mb_antenna(c: Vector3, h: float) -> void:
	mb_box(c, Vector3(0.04, h, 0.04), BM_PAINTED, 0, 63 - 8)
	mb_box(c + Vector3(0, h * 0.7, 0), Vector3(0.5, 0.025, 0.025), BM_PAINTED, 0)
# toldo inclinado sobre el frente (marco del modelo: frente +Z)
func mb_awning(x0: float, x1: float, y: float, z: float, depth: float) -> void:
	mb_quad(Vector3(x0, y - 0.3, z + depth), Vector3(x1, y - 0.3, z + depth), Vector3(x1, y, z), Vector3(x0, y, z), BM_PLAIN, 2)
	mb_quad(Vector3(x1, y - 0.3, z + depth), Vector3(x0, y - 0.3, z + depth), Vector3(x0, y, z), Vector3(x1, y, z), BM_PLAIN, 2)
	mb_quad(Vector3(x0, y - 0.42, z + depth), Vector3(x1, y - 0.42, z + depth), Vector3(x1, y - 0.3, z + depth), Vector3(x0, y - 0.3, z + depth), BM_PLAIN, 2)

# --- recetas residenciales
# terraza: baldosas coloradas en las casas (pocos pisos) y membrana/hormigón en los edificios
func roof_extras(pts: Array, top: float, lod: int, tank: bool, par := 0.3) -> float:
	mb_flat(pts, top, BM_TILES if top < 4.0 else BM_CONCRETE, 0)
	if par > 0.0:
		mb_parapet(pts, top, par, 0.1, BM_PLASTER, 1)
	if lod == LOD_FAR or not tank:
		return top + par
	mb_tank(Vector3(0.45, top, -0.55), 1.0)
	return top + 0.85
func chorizo(lod: int, w: float, mat: int, tm: int, two: bool) -> void:
	var hw := w * 0.5 - 0.12
	var main := rect_pts(-hw, -hw, 0.2, hw)
	var o := {"gf": 1.8, "shutters": tm == 1, "bars": true, "cornice": lod != LOD_FAR, "sill": 0.45, "wh": 0.95}
	var top := mb_walls(main, 0.0, 2 if two else 1, lod, mat, tm, o, 0.85)
	roof_extras(main, top, lod, false, 0.32)
	# zaguán: pared del frente sobre el patio, con la puerta
	mb_box(Vector3((0.2 + hw) * 0.5, 0, hw - 0.06), Vector3(hw - 0.2, 1.8, 0.12), mat, tm, 63 - 8)
	if lod != LOD_FAR:
		mb_quad(Vector3(0.55, 0, hw + 0.04), Vector3(1.15, 0, hw + 0.04), Vector3(1.15, 1.3, hw + 0.04), Vector3(0.55, 1.3, hw + 0.04), BM_WOOD, 2)
		# patio con baldosas y medianera de ladrillo
		mb_quad(Vector3(0.2, 0.03, hw - 0.12), Vector3(hw, 0.03, hw - 0.12), Vector3(hw, 0.03, -hw), Vector3(0.2, 0.03, -hw), BM_SIDEWALK, 0)
		mb_box(Vector3(hw - 0.05, 0, -0.06), Vector3(0.1, 1.3, 2.0 * hw - 0.12), BM_BRICK, 0, 63 - 8)
func rc_chorizo(lod: int, _f: int, w: float) -> void:
	chorizo(lod, w, BM_PLASTER, 1, false)
func rc_chorizo_b(lod: int, _f: int, w: float) -> void:
	chorizo(lod, w, BM_BRICK, 0, true)
func rc_chalet(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.25, -1.1, 1.25, 1.0)
	var top := mb_walls(pts, 0.0, 1, lod, BM_PLASTER, 1, {"gf": 1.5, "shutters": true, "door": 1}, 1.0)
	mb_gable(Vector3(0, top, -0.05), 2.5, 2.1, 1.1, BM_TILES, 0, true, BM_PLASTER, 1, 0.0 if lod == LOD_FAR else 0.2)
	mb_box(Vector3(0.6, top + 0.3, -0.45), Vector3(0.28, 1.15, 0.28), BM_BRICK, 0, 63 - 8)
	if lod == LOD_NEAR:
		mb_box(Vector3(0.62, 0, 1.15), Vector3(0.8, 0.12, 0.3), BM_CONCRETE, 0, 63 - 8)
func rc_chalet_b(lod: int, _f: int, _w: float) -> void:
	var a := rect_pts(-1.45, -1.35, 0.25, 1.3)
	var t1 := mb_walls(a, 0.0, 1, lod, BM_WOOD, 0, {"gf": 1.5, "door": 0}, 0.9)
	mb_gable(Vector3(-0.6, t1, -0.025), 1.7, 2.65, 1.0, BM_TILES, 0, false, BM_WOOD, 0, 0.0 if lod == LOD_FAR else 0.18)
	var b := rect_pts(0.25, -1.35, 1.45, 0.15)
	var t2 := mb_walls(b, 0.0, 1, lod, BM_PLASTER, 1, {"gf": 1.4, "shutters": true}, 0.9)
	mb_gable(Vector3(0.85, t2, -0.6), 1.2, 1.5, 0.8, BM_TILES, 0, true, BM_PLASTER, 1, 0.0 if lod == LOD_FAR else 0.15)
func rc_casa_rejas(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.5, -1.3, 1.5, 1.3)
	var top := mb_walls(pts, 0.0, 1, lod, BM_PLASTER, 1, {"gf": 1.9, "door": 1, "bars": true, "shutters": true, "cornice": lod != LOD_FAR, "sill": 0.45, "wh": 0.95}, 0.95)
	roof_extras(pts, top, lod, false, 0.35)
func rc_ladrillo_terraza(lod: int, _f: int, _w: float) -> void:
	var low := rect_pts(-1.45, -1.3, 1.45, 1.25)
	var t1 := mb_walls(low, 0.0, 1, lod, BM_BRICK, 0, {"gf": 1.5, "door": 1}, 0.95)
	mb_flat(low, t1, BM_CONCRETE, 0)
	mb_parapet(low, t1, 0.14, 0.08, BM_CONCRETE, 0)
	if lod == LOD_NEAR:
		mb_rail(-1.4, 1.4, t1 + 0.14, 1.21, 0.36, "hierro")
	var up := rect_pts(-1.45, -1.3, 0.35, 0.35)
	var t2 := mb_walls(up, t1, 1, lod, BM_BRICK, 0, {"door": 0, "ww": 0.7}, 0.9)
	roof_extras(up, t2, lod, false, 0.2)
func rc_ph(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.4, -1.3, 1.4, 1.1)
	var top := mb_walls(pts, 0.0, 2, lod, BM_PLASTER, 1, {"gf": 1.6, "door": 0, "balc": "frances", "shutters": true, "cornice": lod != LOD_FAR}, 0.95)
	roof_extras(pts, top, lod, true, 0.3)
func rc_moderna(lod: int, _f: int, _w: float) -> void:
	var a := rect_pts(-1.5, -1.3, 0.4, 0.9)
	var t1 := mb_walls(a, 0.0, 2, lod, BM_CONCRETE, 0, {"gf": 1.35, "ww": 0.85, "wh": 0.9, "sill": 0.2}, 1.1)
	mb_box(Vector3(-0.55, t1, -0.2), Vector3(2.1, 0.12, 2.4), BM_CONCRETE, 0)
	var b := rect_pts(0.4, -0.6, 1.5, 1.4)
	var t2 := mb_walls(b, 0.0, 1, lod, BM_WOOD, 0, {"gf": 1.35, "door": 0, "ww": 0.5, "wh": 0.95, "sill": 0.0}, 1.0)
	mb_flat(b, t2, BM_CONCRETE, 0)
	mb_box(Vector3(0.95, t2, 0.4), Vector3(1.25, 0.1, 2.1), BM_PAINTED, 1)
func rc_galeria(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.4, -1.4, 1.4, 0.55)
	var top := mb_walls(pts, 0.0, 1, lod, BM_PLASTER, 1, {"gf": 1.6, "door": 1, "shutters": true}, 0.95)
	mb_gable(Vector3(0, top, -0.425), 2.8, 1.95, 0.9, BM_TILES, 0, true, BM_PLASTER, 1, 0.0 if lod == LOD_FAR else 0.15)
	# galería: techo de tejas inclinado sobre columnas
	mb_quad(Vector3(-1.5, 1.3, 1.45), Vector3(1.5, 1.3, 1.45), Vector3(1.5, 1.55, 0.55), Vector3(-1.5, 1.55, 0.55), BM_TILES, 0)
	mb_quad(Vector3(1.5, 1.3, 1.45), Vector3(-1.5, 1.3, 1.45), Vector3(-1.5, 1.55, 0.55), Vector3(1.5, 1.55, 0.55), BM_TILES, 0)
	if lod != LOD_FAR:
		for x in [-1.35, -0.45, 0.45, 1.35]:
			mb_box(Vector3(x, 0, 1.35), Vector3(0.1, 1.33, 0.1), BM_PAINTED, 1, 63 - 8 - 4)
		mb_box(Vector3(0, 0, 1.0), Vector3(2.9, 0.08, 0.9), BM_SIDEWALK, 0, 63 - 8)
func rc_esquina_ochava(lod: int, _f: int, _w: float) -> void:
	var pts := [Vector3(0.85, 0, 1.4), Vector3(1.45, 0, 0.8), Vector3(1.45, 0, -1.4), Vector3(-1.45, 0, -1.4), Vector3(-1.45, 0, 1.4)]
	var top := mb_walls(pts, 0.0, 2, lod, BM_PLASTER, 1, {"gf": 1.7, "door": 0, "shutters": true, "cornice": lod != LOD_FAR, "balc": "frances", "balc_all": true}, 0.9)
	roof_extras(pts, top, lod, false, 0.32)
# departamentos: planta baja con entrada o local, pisos con balcones, terraza con tanque
const DEPTO_F := [Vector3(-1.4, 0, 1.15), Vector3(1.4, 0, 1.15), Vector3(1.4, 0, -1.35), Vector3(-1.4, 0, -1.35)]
func depto(lod: int, f: int, mat: int, tm: int, o: Dictionary, pitch := 0.95) -> float:
	o["gf"] = 1.6
	if not o.has("door"):
		o["door"] = 1
	var top := mb_walls(DEPTO_F, 0.0, f, lod, mat, tm, o, pitch)
	if lod != LOD_FAR and f >= 3:
		mb_antenna(Vector3(-0.9, top, -0.9), 0.9)
	return top
func rc_depto_1(lod: int, f: int, _w: float) -> void:
	roof_extras(DEPTO_F, depto(lod, f, BM_PLASTER, 1, {"balc": "hierro", "cornice": lod != LOD_FAR}), lod, true)
func rc_depto_2(lod: int, f: int, _w: float) -> void:
	roof_extras(DEPTO_F, depto(lod, f, BM_BRICK, 0, {"balc": "vidrio", "shop": true, "bands": true}), lod, true)
func rc_depto_3(lod: int, f: int, _w: float) -> void:
	roof_extras(DEPTO_F, depto(lod, f, BM_PLASTER, 1, {"balc": "corrido", "bands": true}), lod, true)
func rc_depto_4(lod: int, f: int, _w: float) -> void:
	roof_extras(DEPTO_F, depto(lod, f, BM_CONCRETE, 0, {"bands": true, "shop": true, "ww": 0.85, "wh": 0.85, "sill": 0.25}, 1.1), lod, true)
func rc_depto_5(lod: int, f: int, _w: float) -> void:
	var top := depto(lod, f - 1, BM_PLASTER, 1, {"balc": "frances", "cornice": true, "shutters": true})
	mb_flat(DEPTO_F, top, BM_CONCRETE, 0)
	# mansarda de chapa con un piso adentro
	var inset := 0.35
	var hh := 1.15
	var p := DEPTO_F
	for k in 4:
		var a: Vector3 = p[k]
		var b: Vector3 = p[(k + 1) % 4]
		var ai := Vector3(a.x - signf(a.x) * inset, 0, a.z - signf(a.z + 0.1) * inset)
		var bi := Vector3(b.x - signf(b.x) * inset, 0, b.z - signf(b.z + 0.1) * inset)
		mb_quad(Vector3(a.x, top, a.z), Vector3(b.x, top, b.z), Vector3(bi.x, top + hh, bi.z), Vector3(ai.x, top + hh, ai.z), BM_SHEET, 0)
	var q: Array = []
	for a in p:
		q.append(Vector3(a.x - signf(a.x) * inset, 0, a.z - signf(a.z + 0.1) * inset))
	mb_flat(q, top + hh, BM_CONCRETE, 0)
	if lod == LOD_NEAR:
		for x in [-0.8, 0.0, 0.8]:
			mb_box(Vector3(x, top + 0.2, 1.0), Vector3(0.42, 0.62, 0.3), BM_PLASTER, 1, 63 - 8 - 32)
			mb_gable(Vector3(x, top + 0.82, 1.0), 0.42, 0.3, 0.2, BM_SHEET, 0, false)
			mb_quad(Vector3(x - 0.14, top + 0.3, 1.152), Vector3(x + 0.14, top + 0.3, 1.152), Vector3(x + 0.14, top + 0.72, 1.152), Vector3(x - 0.14, top + 0.72, 1.152), BM_GLASS, 0, Vector2(40 + x * 2, f), Vector2(41 + x * 2, f + 1))
func rc_depto_6(lod: int, f: int, _w: float) -> void:
	roof_extras(DEPTO_F, depto(lod, f, BM_BRICK, 0, {"shutters": true, "cornice": lod != LOD_FAR}), lod, true)
func rc_depto_7(lod: int, f: int, _w: float) -> void:
	var top := depto(lod, f, BM_PLASTER, 1, {"cornice": lod != LOD_FAR}, 0.95)
	roof_extras(DEPTO_F, top, lod, true)
	# bow-windows salientes en los pisos altos
	if f > 1:
		for x in [-0.75, 0.75]:
			var bay := rect_pts(x - 0.42, 1.0, x + 0.42, 1.45)
			var bt2 := mb_walls(bay, 1.6, f - 1, lod, BM_PLASTER, 1, {"ww": 0.55}, 0.8)
			mb_flat(bay, bt2, BM_CONCRETE, 0)
			mb_quad(Vector3(x - 0.42, 1.6, 1.45), Vector3(x - 0.42, 1.6, 1.0), Vector3(x + 0.42, 1.6, 1.0), Vector3(x + 0.42, 1.6, 1.45), BM_CONCRETE, 0)
func rc_depto_8(lod: int, f: int, _w: float) -> void:
	var top := depto(lod, f - 1, BM_PLASTER, 1, {"balc": "vidrio", "shop": true})
	mb_flat(DEPTO_F, top, BM_CONCRETE, 0)
	mb_parapet(DEPTO_F, top, 0.12, 0.08, BM_CONCRETE, 0)
	if lod == LOD_NEAR:
		mb_rail(-1.35, 1.35, top + 0.12, 1.11, 0.4, "vidrio")
	var up := rect_pts(-1.4, -1.35, 1.4, 0.45)
	roof_extras(up, mb_walls(up, top, 1, lod, BM_PLASTER, 1, {"ww": 0.8, "wh": 0.95, "sill": 0.1}, 0.95), lod, true)
# torres
func crown(c: Vector3, top: float, f: int, lod: int, s: float) -> void:
	if lod == LOD_FAR:
		return
	mb_box(Vector3(c.x, top, c.z), Vector3(1.3 * s, 0.8, 1.1 * s), BM_CONCRETE, 0, 63 - 8)
	if f >= 12:
		mb_antenna(Vector3(c.x + 0.3, top + 0.8, c.z), 2.0)
func rc_torre_cortina(lod: int, f: int, _w: float) -> void:
	var base := rect_pts(-1.5, -1.5, 1.5, 1.5)
	var t0 := mb_walls(base, 0.0, 2, lod, BM_CONCRETE, 0, {"gf": 1.8, "shop": true, "door": 1}, 1.0)
	mb_flat(base, t0, BM_CONCRETE, 0)
	var t := rect_pts(-1.25, -1.25, 1.25, 1.25)
	var top := mb_walls(t, t0, f - 2, lod, BM_PAINTED, 1, {"curtain": true, "glass": BM_MIRROR}, 0.62)
	mb_flat(t, top, BM_CONCRETE, 0)
	mb_parapet(t, top, 0.3, 0.08, BM_PAINTED, 1)
	crown(Vector3.ZERO, top, f, lod, 1.0)
func rc_torre_franjas(lod: int, f: int, _w: float) -> void:
	var t := rect_pts(-1.35, -1.35, 1.35, 1.35)
	var top := mb_walls(t, 0.0, f, lod, BM_CONCRETE, 0, {"gf": 1.8, "door": 1, "shop": true, "bands": true, "ww": 0.86, "wh": 0.82, "sill": 0.24}, 1.0)
	mb_flat(t, top, BM_CONCRETE, 0)
	mb_parapet(t, top, 0.3, 0.1, BM_CONCRETE, 0)
	crown(Vector3(0, 0, -0.2), top, f, lod, 1.0)
func rc_torre_escalonada(lod: int, f: int, _w: float) -> void:
	var f1 := int(f * 0.5)
	var f2 := int(f * 0.3)
	var f3 := f - f1 - f2
	var r1 := rect_pts(-1.45, -1.45, 1.45, 1.45)
	var y := mb_walls(r1, 0.0, f1, lod, BM_CONCRETE, 1, {"gf": 1.8, "door": 1, "cornice": lod != LOD_FAR}, 0.97)
	mb_flat(r1, y, BM_CONCRETE, 0)
	var r2 := rect_pts(-1.15, -1.15, 1.15, 1.15)
	y = mb_walls(r2, y, f2, lod, BM_CONCRETE, 1, {"cornice": lod != LOD_FAR}, 0.77)
	mb_flat(r2, y, BM_CONCRETE, 0)
	var r3 := rect_pts(-0.85, -0.85, 0.85, 0.85)
	y = mb_walls(r3, y, f3, lod, BM_CONCRETE, 1, {"cornice": lod != LOD_FAR}, 0.85)
	mb_flat(r3, y, BM_CONCRETE, 0)
	crown(Vector3.ZERO, y, f, lod, 0.6)
func rc_torre_cilindro(lod: int, f: int, _w: float) -> void:
	var n := 14
	var pts: Array = []
	for k in n:
		var a := PI * 0.5 + PI / n - TAU * k / n
		pts.append(Vector3(cos(a) * 1.4, 0, sin(a) * 1.4))
	var top := mb_walls(pts, 0.0, f, lod, BM_PAINTED, 1, {"gf": 1.8, "door": 0, "curtain": true, "glass": BM_MIRROR}, 0.6)
	mb_flat(pts, top, BM_CONCRETE, 0)
	mb_parapet(pts, top, 0.35, 0.08, BM_PAINTED, 1)
	crown(Vector3.ZERO, top, f, lod, 0.7)
func rc_torre_grande_a(lod: int, f: int, _w: float) -> void:
	var pod := rect_pts(-3.5, -3.5, 3.5, 3.5)
	var t0 := mb_walls(pod, 0.0, 3, lod, BM_CONCRETE, 0, {"gf": 1.8, "shop": true, "door": 2, "bands": true}, 1.2)
	mb_flat(pod, t0, BM_CONCRETE, 0)
	mb_parapet(pod, t0, 0.35, 0.1, BM_CONCRETE, 0)
	var t := rect_pts(-2.2, -2.2, 2.2, 2.2)
	var top := mb_walls(t, t0, f - 3, lod, BM_PAINTED, 1, {"curtain": true, "glass": BM_MIRROR}, 0.7)
	mb_flat(t, top, BM_CONCRETE, 0)
	mb_parapet(t, top, 0.35, 0.1, BM_PAINTED, 1)
	crown(Vector3(0.5, 0, 0), top, f, lod, 1.4)
func rc_torre_grande_b(lod: int, f: int, _w: float) -> void:
	var pod := rect_pts(-3.5, -3.5, 3.5, 3.5)
	var t0 := mb_walls(pod, 0.0, 2, lod, BM_CONCRETE, 0, {"gf": 1.8, "shop": true, "door": 3}, 1.2)
	mb_flat(pod, t0, BM_CONCRETE, 0)
	mb_parapet(pod, t0, 0.35, 0.1, BM_CONCRETE, 0)
	for x in [-1.8, 1.8]:
		var t := rect_pts(x - 1.2, -2.4, x + 1.2, 2.4)
		var top := mb_walls(t, t0, f - 2, lod, BM_CONCRETE, 1, {"bands": true, "balc": "corrido", "balc_all": false, "ww": 0.8, "wh": 0.85, "sill": 0.2}, 1.0)
		mb_flat(t, top, BM_CONCRETE, 0)
		mb_parapet(t, top, 0.3, 0.1, BM_CONCRETE, 1)
		crown(Vector3(x, 0, 0), top, f, lod, 0.9)
# --- comercio
func mb_cone(c: Vector3, r: float, h: float, seg: int, mat: int, tm: int) -> void:
	for k in seg:
		var a0 := TAU * k / seg
		var a1 := TAU * (k + 1) / seg
		mb_tri(Vector3(c.x + cos(a1) * r, c.y, c.z + sin(a1) * r), Vector3(c.x + cos(a0) * r, c.y, c.z + sin(a0) * r), c + Vector3(0, h, 0), mat, tm)
# cartel sobre el frente (segundo color) con el borde claro
func mb_sign(x: float, y: float, z: float, wd: float, h: float) -> void:
	mb_box(Vector3(x, y, z), Vector3(wd, h, 0.08), BM_PLAIN, 2, 63 - 32)
	mb_box(Vector3(x, y - 0.03, z + 0.02), Vector3(wd + 0.06, 0.03, 0.1), BM_PAINTED, 0)
func rc_almacen(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.45, -1.3, 1.45, 1.15)
	var top := mb_walls(pts, 0.0, 1, lod, BM_PLASTER, 1, {"gf": 2.0, "shop": true, "door": 1, "cornice": lod != LOD_FAR}, 0.95)
	roof_extras(pts, top, lod, false, 0.3)
	mb_sign(0, 1.66, 1.17, 2.7, 0.3)
	if lod != LOD_FAR:
		mb_awning(-1.45, 1.45, 1.6, 1.17, 0.45)
func rc_kiosco(lod: int, _f: int, _w: float) -> void:
	var back := rect_pts(-1.45, -1.4, 1.45, 0.3)
	var top := mb_walls(back, 0.0, 1, lod, BM_PLASTER, 1, {"gf": 2.2, "shutters": true, "sill": 0.5, "wh": 1.0}, 0.95)
	roof_extras(back, top, lod, false, 0.25)
	# kiosco de vidrio adelante, con techito y cartel
	var k := rect_pts(-0.75, 0.3, 0.75, 1.2)
	var kt := mb_walls(k, 0.0, 1, lod, BM_PAINTED, 2, {"gf": 1.35, "shop": true, "door": 0}, 0.5)
	mb_box(Vector3(0, kt, 0.75), Vector3(1.75, 0.12, 1.15), BM_PAINTED, 2)
	mb_sign(0, kt + 0.12, 1.15, 1.4, 0.32)
func locales(lod: int, f: int, mat: int, tm: int, balc: String) -> void:
	var pts := DEPTO_F
	var top := mb_walls(pts, 0.0, f, lod, mat, tm, {"gf": 1.8, "shop": true, "door": 0, "balc": balc, "cornice": lod != LOD_FAR, "shutters": balc == "frances"}, 0.95)
	roof_extras(pts, top, lod, true)
	if lod != LOD_FAR:
		mb_awning(-1.4, 1.4, 1.62, 1.17, 0.42)
	mb_sign(0.2, 1.7, 1.17, 2.0, 0.22)
func rc_locales_a(lod: int, f: int, _w: float) -> void:
	locales(lod, f, BM_PLASTER, 1, "frances")
func rc_locales_b(lod: int, f: int, _w: float) -> void:
	locales(lod, f, BM_BRICK, 0, "hierro")
func rc_oficinas_a(lod: int, f: int, _w: float) -> void:
	var pts := rect_pts(-1.45, -1.4, 1.45, 1.3)
	var top := mb_walls(pts, 0.0, f, lod, BM_CONCRETE, 0, {"gf": 1.8, "shop": true, "door": 1, "bands": true, "ww": 0.88, "wh": 0.8, "sill": 0.26}, 1.0)
	roof_extras(pts, top, lod, false, 0.35)
	crown(Vector3(0, 0, -0.3), top, f, lod, 0.9)
func rc_oficinas_b(lod: int, f: int, _w: float) -> void:
	var base := rect_pts(-1.5, -1.45, 1.5, 1.35)
	var t0 := mb_walls(base, 0.0, 1, lod, BM_CONCRETE, 0, {"gf": 2.0, "shop": true, "door": 1}, 1.0)
	mb_flat(base, t0, BM_CONCRETE, 0)
	var t := rect_pts(-1.35, -1.35, 1.35, 1.25)
	var top := mb_walls(t, t0, f - 1, lod, BM_DARK, 0, {"curtain": true, "glass": BM_GLASS}, 0.68)
	mb_flat(t, top, BM_CONCRETE, 0)
	mb_parapet(t, top, 0.3, 0.08, BM_DARK, 0)
	crown(Vector3(0, 0, -0.2), top, f, lod, 0.8)
func spire(c: Vector3, top: float, lod: int, s: float) -> void:
	# remate: piso técnico más chico y aguja
	var r := rect_pts(c.x - 0.75 * s, c.z - 0.75 * s, c.x + 0.75 * s, c.z + 0.75 * s)
	var t2 := mb_walls(r, top, 1, LOD_FAR, BM_PAINTED, 1, {"curtain": true, "glass": BM_MIRROR}, 0.6)
	mb_flat(r, t2, BM_PAINTED, 1)
	if lod != LOD_FAR:
		mb_cone(Vector3(c.x, t2, c.z), 0.35 * s, 2.6 * s, 8, BM_PAINTED, 0)
func rc_torre_oficinas(lod: int, f: int, _w: float) -> void:
	var base := rect_pts(-1.55, -1.55, 1.55, 1.55)
	var t0 := mb_walls(base, 0.0, 2, lod, BM_CONCRETE, 0, {"gf": 2.0, "shop": true, "door": 1, "bands": true}, 1.0)
	mb_flat(base, t0, BM_CONCRETE, 0)
	var t := rect_pts(-1.3, -1.3, 1.3, 1.3)
	var top := mb_walls(t, t0, f - 2, lod, BM_PAINTED, 1, {"curtain": true, "glass": BM_MIRROR}, 0.65)
	mb_flat(t, top, BM_CONCRETE, 0)
	spire(Vector3.ZERO, top, lod, 1.0)
func rc_torre_oficinas_grande(lod: int, f: int, _w: float) -> void:
	var pod := rect_pts(-3.55, -3.55, 3.55, 3.55)
	var t0 := mb_walls(pod, 0.0, 3, lod, BM_CONCRETE, 0, {"gf": 2.0, "shop": true, "door": 2, "bands": true}, 1.2)
	mb_flat(pod, t0, BM_CONCRETE, 0)
	mb_parapet(pod, t0, 0.35, 0.1, BM_CONCRETE, 0)
	var t := rect_pts(-2.3, -2.3, 2.3, 2.3)
	var top := mb_walls(t, t0, f - 3, lod, BM_DARK, 0, {"curtain": true, "glass": BM_GLASS}, 0.72)
	mb_flat(t, top, BM_CONCRETE, 0)
	if f >= 12:
		spire(Vector3.ZERO, top, lod, 1.6)
	else:
		crown(Vector3.ZERO, top, f, lod, 1.4)
# --- industria
# portón de chapa hundido (marco del modelo, frente +Z)
func mb_gate(x: float, z: float, wd: float, h: float) -> void:
	mb_quad(Vector3(x - wd * 0.5, 0, z + 0.04), Vector3(x + wd * 0.5, 0, z + 0.04), Vector3(x + wd * 0.5, h, z + 0.04), Vector3(x - wd * 0.5, h, z + 0.04), BM_SHEET, 2)
# techo de dientes de sierra: cada diente tiene una cara inclinada de chapa y una vertical vidriada
func mb_sawtooth(x0: float, x1: float, z0: float, z1: float, y: float, n: int, h: float) -> void:
	var dz := (z1 - z0) / n
	for k in n:
		var a := z0 + dz * k
		var b := a + dz
		mb_quad(Vector3(x0, y, b), Vector3(x1, y, b), Vector3(x1, y + h, a), Vector3(x0, y + h, a), BM_SHEET, 0)
		mb_quad(Vector3(x1, y, a), Vector3(x0, y, a), Vector3(x0, y + h, a), Vector3(x1, y + h, a), BM_GLASS, 0, Vector2(k, 30), Vector2(k + 3, 31))
		mb_tri(Vector3(x1, y, b), Vector3(x1, y, a), Vector3(x1, y + h, a), BM_BRICK, 0)
		mb_tri(Vector3(x0, y, a), Vector3(x0, y, b), Vector3(x0, y + h, a), BM_BRICK, 0)
func mb_chimney(c: Vector3, h: float, r: float) -> void:
	mb_cyl(c, r, h, 10, BM_BRICK, 0)
	mb_cyl(c + Vector3(0, h - 0.4, 0), r + 0.05, 0.25, 10, BM_CONCRETE, 0)
func rc_galpon_chapa(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.5, -1.45, 1.5, 1.35)
	var top := mb_walls(pts, 0.0, 1, lod, BM_SHEET, 1, {"gf": 2.2, "sill": 1.45, "wh": 0.45, "ww": 0.8}, 1.0)
	mb_gable(Vector3(0, top, -0.05), 3.0, 2.8, 0.75, BM_SHEET, 0, false, BM_SHEET, 1, 0.0 if lod == LOD_FAR else 0.12)
	mb_gate(0.2, 1.35, 1.4, 1.5)
	if lod == LOD_NEAR:
		mb_box(Vector3(-1.05, 0, 1.38), Vector3(0.45, 0.95, 0.05), BM_PAINTED, 2)
func rc_fabrica_ladrillo(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.5, -1.5, 1.5, 1.35)
	var top := mb_walls(pts, 0.0, 1, lod, BM_BRICK, 0, {"gf": 3.0, "door": 0, "sill": 0.9, "wh": 1.5, "ww": 0.55}, 0.8)
	mb_flat(pts, top, BM_CONCRETE, 0)
	if lod == LOD_FAR:
		mb_box(Vector3(0, top, -0.08), Vector3(2.9, 0.5, 2.7), BM_SHEET, 0, 63 - 8)
	else:
		mb_sawtooth(-1.45, 1.45, -1.45, 1.3, top, 3, 0.9)
	mb_gate(0.7, 1.35, 1.1, 1.8)
func rc_planta_silos(lod: int, _f: int, _w: float) -> void:
	var b := rect_pts(-1.5, -0.2, 1.5, 1.4)
	var top := mb_walls(b, 0.0, 1, lod, BM_CONCRETE, 1, {"gf": 2.6, "door": 2, "sill": 1.6, "wh": 0.6}, 0.9)
	mb_flat(b, top, BM_CONCRETE, 0)
	if lod != LOD_FAR:
		mb_parapet(b, top, 0.2, 0.08, BM_CONCRETE, 0)
	var seg := 8 if lod == LOD_FAR else 14
	for x in [-0.95, 0.15]:
		mb_cyl(Vector3(x, 0, -0.85), 0.55, 6.0, seg, BM_PAINTED, 1)
		mb_cone(Vector3(x, 6.0, -0.85), 0.58, 0.6, seg, BM_SHEET, 0)
	mb_chimney(Vector3(1.05, 0, -0.95), 9.0 if lod != LOD_FAR else 9.0, 0.28)
	if lod == LOD_NEAR:
		mb_box(Vector3(-0.4, 5.4, -0.85), Vector3(1.6, 0.25, 0.3), BM_PAINTED, 0)
		mb_gate(-0.6, 1.4, 1.0, 1.6)
func rc_fabrica_grande(lod: int, _f: int, _w: float) -> void:
	var pts := rect_pts(-1.55, -1.55, 1.55, 1.4)
	var top := mb_walls(pts, 0.0, 2, lod, BM_BRICK, 0, {"gf": 2.4, "door": 0, "bands": true, "ww": 0.7, "wh": 0.95}, 0.85)
	mb_flat(pts, top, BM_CONCRETE, 0)
	mb_parapet(pts, top, 0.3, 0.1, BM_BRICK, 0)
	mb_chimney(Vector3(1.0, top, -1.0), 5.5, 0.25)
	mb_gate(0.6, 1.4, 1.2, 1.9)
	if lod != LOD_FAR:
		mb_box(Vector3(-0.6, top, -0.4), Vector3(1.0, 0.7, 1.0), BM_SHEET, 0, 63 - 8)
func rc_complejo(lod: int, _f: int, _w: float) -> void:
	var a := rect_pts(-1.55, -1.55, 0.3, 1.4)
	var t1 := mb_walls(a, 0.0, 1, lod, BM_CONCRETE, 1, {"gf": 5.5, "door": 0, "sill": 3.6, "wh": 1.2, "ww": 0.9}, 1.0)
	mb_flat(a, t1, BM_SHEET, 0)
	var b := rect_pts(0.3, -1.55, 1.55, 1.4)
	var t2 := mb_walls(b, 0.0, 1, lod, BM_SHEET, 1, {"gf": 3.0, "sill": 1.8, "wh": 0.6}, 1.0)
	mb_gable(Vector3(0.925, t2, -0.075), 1.25, 2.95, 0.6, BM_SHEET, 0, false, BM_SHEET, 1)
	mb_chimney(Vector3(-1.1, t1, -1.1), 6.5, 0.26)
	mb_chimney(Vector3(-0.4, t1, -1.1), 5.0, 0.2)
	mb_gate(0.92, 1.4, 1.0, 2.0)
	if lod == LOD_NEAR:
		for k in 3:
			mb_cyl(Vector3(-1.15 + k * 0.6, t1, 0.4), 0.22, 0.9, 10, BM_PAINTED, 0)
func rc_complejo_grande(lod: int, _f: int, _w: float) -> void:
	var a := rect_pts(-3.5, -3.5, 1.0, 3.3)
	var t1 := mb_walls(a, 0.0, 1, lod, BM_BRICK, 0, {"gf": 3.4, "door": 1, "sill": 1.0, "wh": 1.7, "ww": 0.6}, 0.9)
	mb_flat(a, t1, BM_CONCRETE, 0)
	if lod == LOD_FAR:
		mb_box(Vector3(-1.25, t1, -0.1), Vector3(4.4, 0.6, 6.7), BM_SHEET, 0, 63 - 8)
	else:
		mb_sawtooth(-3.45, 0.95, -3.45, 3.25, t1, 6, 0.9)
	var seg := 8 if lod == LOD_FAR else 14
	for z in [-2.6, -1.2, 0.2]:
		mb_cyl(Vector3(2.3, 0, z), 0.62, 7.5, seg, BM_PAINTED, 1)
		mb_cone(Vector3(2.3, 7.5, z), 0.65, 0.6, seg, BM_SHEET, 0)
	var b := rect_pts(1.4, 1.2, 3.5, 3.4)
	var t2 := mb_walls(b, 0.0, 2, lod, BM_CONCRETE, 1, {"gf": 1.8, "door": 0}, 0.9)
	mb_flat(b, t2, BM_CONCRETE, 0)
	mb_chimney(Vector3(3.1, 0, -3.1), 11.0, 0.32)
	mb_gate(-2.0, 3.3, 1.6, 2.4)
	mb_gate(-0.2, 3.3, 1.6, 2.4)
