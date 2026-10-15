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
var bnodes: Array = []
var _binst: Dictionary = {}
var bq_last: int = -1
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
func mb_gable(c: Vector3, lx: float, lz: float, h: float, mat: int, tm: int, along_x: bool, wall_mat := -1, wtm := 1) -> void:
	if not along_x:
		var keep := mb_xf
		mb_xf = mb_xf * Transform3D(Basis(Vector3.UP, PI * 0.5), c) * Transform3D(Basis.IDENTITY, -c)
		mb_gable(c, lz, lx, h, mat, tm, true, wall_mat, wtm)
		mb_xf = keep
		return
	var x0 := c.x - lx * 0.5
	var x1 := c.x + lx * 0.5
	var z0 := c.z - lz * 0.5
	var z1 := c.z + lz * 0.5
	var y := c.y
	var yh := c.y + h
	mb_quad(Vector3(x0, y, z1), Vector3(x1, y, z1), Vector3(x1, yh, c.z), Vector3(x0, yh, c.z), mat, tm)
	mb_quad(Vector3(x1, y, z0), Vector3(x0, y, z0), Vector3(x0, yh, c.z), Vector3(x1, yh, c.z), mat, tm)
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
	cat_add("caja", [Z_R, Z_C, Z_M], [1, 2, 3, 4], false, {1: [2], 2: [4], 3: [7], 4: [12]}, rc_caja)
	cat_add("caja_ind", [Z_I], [1, 2, 3, 4], false, {1: [2], 2: [4], 3: [6], 4: [8]}, rc_caja)
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
func building_color(i: int, z: int, v: int, wall: Color) -> Color:
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
		for lod in ([LOD_FAR] if q == 0 else [LOD_NEAR, LOD_MID, LOD_FAR]):
			var nk: int = key * 3 + lod
			var node: MultiMeshInstance3D = nodes.get(nk)
			if node == null:
				node = new_mm_node(cat_mesh(key / 64, key % 64, lod), building_mat)
				nodes[nk] = node
			node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			if q == 0:
				node.visibility_range_begin = 0.0
				node.visibility_range_end = 0.0
			else:
				node.visibility_range_begin = [0.0, 120.0, 340.0][lod]
				node.visibility_range_begin_margin = 0.0 if lod == LOD_NEAR else 20.0
				node.visibility_range_end = [140.0, 380.0, 0.0][lod]
				node.visibility_range_end_margin = 20.0
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if lod != LOD_FAR or q == 2 else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			node.multimesh.instance_count = cnt
			node.multimesh.buffer = buf
		if q == 0:
			for lod in [LOD_NEAR, LOD_MID]:
				if nodes.has(key * 3 + lod):
					nodes[key * 3 + lod].multimesh.instance_count = 0
# --- recetas: (versión, pisos, ancho del lote). Frente hacia +Z, base en y = 0.
func rc_caja(lod: int, f: int, w: float) -> void:
	var s := w * 0.8
	var h := maxf(f, 2) * FLOOR_H
	if lod == LOD_FAR:
		mb_box(Vector3.ZERO, Vector3(s, h, s), BM_PLASTER, 1, 63 - 8)
		return
	mb_box(Vector3.ZERO, Vector3(s, h, s), BM_PLASTER, 1, 63 - 8 - 4)
	mb_gable(Vector3(0, h, 0), s + 0.2, s + 0.2, 1.0, BM_TILES, 0, true, BM_PLASTER, 1)
	mb_box(Vector3(0, 0, s * 0.5), Vector3(0.45, 0.95, 0.04), BM_WOOD, 0)
