# Árboles de la etapa 2c: recetas por especie y ubicación.
# tipo de árbol (tree[i]) -> modelos del catálogo (3 formas por especie). Pisos del modelo: 0 llena, 1 rala.
var tree_models: Dictionary = {}
const TREE_SPECIES := {1: "fresno", 2: "platano", 3: "jacaranda", 4: "pino", 5: "palo_borracho", 6: "palmera", 7: "ombu"}
func tree_register() -> void:
	tree_models.clear()
	for kind in TREE_SPECIES:
		var arr: Array = []
		for v in 3:
			cat_add("%s_%d" % [TREE_SPECIES[kind], v], [], [1], false, {1: [0, 1]}, rc_tree.bind(kind, v), false, "arbol")
			arr.append(cat_models.size() - 1)
		tree_models[kind] = arr
# rama o tronco: cilindro que se afina de a (radio r0) a b (radio r1)
func mb_limb(a: Vector3, b: Vector3, r0: float, r1: float, seg: int) -> void:
	var d := (b - a).normalized()
	var side := Vector3.UP.cross(d)
	if side.length() < 0.01:
		side = Vector3.RIGHT
	side = side.normalized()
	var fw := side.cross(d).normalized()
	for k in seg:
		var a0 := TAU * k / seg
		var a1 := TAU * (k + 1) / seg
		var n0 := side * cos(a0) + fw * sin(a0)
		var n1 := side * cos(a1) + fw * sin(a1)
		mb_quad(a + n1 * r0, a + n0 * r0, b + n0 * r1, b + n1 * r1, BM_BARK, 0)
# bulto de follaje: esfera deformada con normales suaves (se ve como masa de hojas, no como facetas)
func mb_blob(c: Vector3, r: Vector3, seg: int, rings: int, seed: int, mat := BM_LEAF, tm := 1, bumpy := true) -> void:
	var o := mb_v.size()
	var cw := mb_xf * c
	for j in rings + 1:
		var th := PI * j / rings
		for k in seg + 1:
			var ph := TAU * k / seg
			var dir := Vector3(sin(th) * cos(ph), cos(th), sin(th) * sin(ph))
			var bump := 1.0 + ((hsh(seed * 131 + j * 17 + (k % seg), 7) - 0.5) * 0.35 if bumpy else 0.0)
			var p := mb_xf * (c + dir * r * bump)
			var n := (mb_xf.basis * (dir / r)).normalized()
			mb_v.append(p)
			mb_n.append(n)
			var t := Vector3(-sin(ph), 0, cos(ph))
			mb_t.append_array([t.x, t.y, t.z, 1.0])
			mb_uv.append(Vector2(ph * maxf(r.x, r.z), -(p.y - cw.y) - th * r.y))
			mb_uv2.append(Vector2(mat, tm))
	for j in rings:
		for k in seg:
			var a := o + j * (seg + 1) + k
			var b := a + seg + 1
			mb_i.append_array([a, a + 1, b, a + 1, b + 1, b])
# hoja de palmera: cinta que sale del centro y cae, con las dos caras
func mb_frond(base: Vector3, ang: float, L: float, wd: float, droop: float) -> void:
	var dir := Vector3(cos(ang), 0, sin(ang))
	var side := Vector3(-dir.z, 0, dir.x) * wd
	var pts: Array = []
	for s in 4:
		var t := s / 3.0
		pts.append(base + dir * L * t + Vector3(0, 0.25 * t - droop * t * t, 0))
	for s in 3:
		var a: Vector3 = pts[s]
		var b: Vector3 = pts[s + 1]
		var w0 := 1.0 - s / 3.0 * 0.7
		var w1 := 1.0 - (s + 1) / 3.0 * 0.7
		mb_quad(a - side * w0, a + side * w0, b + side * w1, b - side * w1, BM_LEAF, 1)
		mb_quad(a + side * w0, a - side * w0, b - side * w1, b + side * w1, BM_LEAF, 1)
# receta común: kind = especie, v = forma (0..2), f = 0 llena / 1 rala (invierno en las de hoja caduca)
func rc_tree(lod: int, f: int, _w: float, kind: int, v: int) -> void:
	var sd := kind * 10 + v
	var seg: int = [8, 5, 4][lod]
	var bseg: int = [8, 5, 5][lod]
	var brings: int = [6, 3, 3][lod]
	var bare := f == 1 and kind in [1, 2, 3, 7]
	var nb: int = [10, 2, 1][lod]
	var jit := func(k: int, q: int) -> float: return hsh(sd * 7 + k, q) - 0.5
	match kind:
		4:
			# pino: capas de conos verde oscuro
			mb_limb(Vector3.ZERO, Vector3(0, 1.0, 0), 0.16, 0.12, seg)
			var tiers: int = [4, 3, 1][lod]
			for t in tiers:
				var k: float = float(t) / maxf(tiers - 1, 1)
				var y0: float = 0.8 + t * (3.6 / tiers)
				var r: float = lerpf(1.35, 0.45, k) * (1.0 + jit.call(t, 3) * 0.2)
				mb_cone_leaf(Vector3(0, y0, 0), r, 1.9 - k * 0.6, bseg + 2)
			return
		6:
			# palmera: tronco alto con anillos y penacho de hojas
			var h := 4.6 + v * 0.4
			var lean: Vector3 = Vector3(jit.call(1, 1) * 0.6, 0, jit.call(2, 1) * 0.6)
			var rings: int = [6, 3, 1][lod]
			for r in rings:
				var a: Vector3 = lean * (float(r) / rings) + Vector3(0, h * r / rings, 0)
				var b: Vector3 = lean * (float(r + 1) / rings) + Vector3(0, h * (r + 1) / rings, 0)
				mb_limb(a, b, 0.17 - r * 0.008, 0.155 - r * 0.008, seg)
			var top := lean + Vector3(0, h, 0)
			if lod == LOD_FAR:
				mb_blob(top, Vector3(1.2, 0.45, 1.2), bseg, brings, sd)
				return
			var nf: int = [10, 6, 0][lod]
			for k in nf:
				mb_frond(top, TAU * k / nf + jit.call(k, 4), 1.6 + jit.call(k, 5) * 0.4, 0.22, 0.9 + jit.call(k, 6) * 0.4)
			mb_blob(top + Vector3(0, 0.1, 0), Vector3(0.3, 0.25, 0.3), bseg, brings, sd)
			return
	# especies de copa: forma propia (alto del tronco, centro y radios de la copa)
	var th: float = {1: 1.6, 2: 2.0, 3: 1.4, 5: 1.7, 7: 1.0}[kind]
	var cy: float = {1: 2.7, 2: 3.4, 3: 2.6, 5: 3.0, 7: 2.0}[kind]
	var cr: Vector3 = {1: Vector3(1.2, 1.15, 1.2), 2: Vector3(1.4, 1.45, 1.4), 3: Vector3(1.45, 0.85, 1.45), 5: Vector3(1.2, 0.9, 1.2), 7: Vector3(1.45, 1.0, 1.45)}[kind]
	var tr: float = {1: 0.14, 2: 0.17, 3: 0.13, 5: 0.24, 7: 0.32}[kind]
	cr *= 1.0 + v * 0.04
	if kind == 5:
		# palo borracho: tronco panzón
		mb_limb(Vector3.ZERO, Vector3(0, th * 0.45, 0), tr * 1.1, tr * 1.5, seg)
		mb_limb(Vector3(0, th * 0.45, 0), Vector3(0, th, 0), tr * 1.5, tr * 0.6, seg)
	else:
		mb_limb(Vector3.ZERO, Vector3(0, th, 0), tr, tr * 0.75, seg)
	# ramas principales hacia la copa
	var nbr: int = [5, 0, 0][lod]
	for k in nbr:
		var a: float = TAU * k / nbr + jit.call(k, 8)
		var tip: Vector3 = Vector3(cos(a) * cr.x * 0.6, cy + jit.call(k, 9) * 0.4, sin(a) * cr.z * 0.6)
		mb_limb(Vector3(0, th * 0.9, 0), tip, tr * 0.55, tr * 0.2, maxi(seg - 3, 4))
	if bare:
		# invierno: copa rala, pocos bultos chicos (se ven las ramas)
		for k in maxi(nb / 3, 1):
			var a: float = TAU * k / maxf(nb / 3, 1) + jit.call(k, 10)
			mb_blob(Vector3(cos(a) * cr.x * 0.45, cy + 0.2, sin(a) * cr.z * 0.45), cr * 0.28, bseg, brings, sd + k)
		return
	if nb == 1:
		mb_blob(Vector3(0, cy, 0), cr, bseg, brings, sd)
		return
	for k in nb:
		var a: float = TAU * k / nb + jit.call(k, 11)
		var rr: float = 0.35 + 0.35 * hsh(sd + k, 12)
		var p: Vector3 = Vector3(cos(a) * cr.x * rr, cy + jit.call(k, 13) * cr.y * 0.8, sin(a) * cr.z * rr)
		var s: float = 0.55 + 0.2 * hsh(sd + k, 14)
		mb_blob(p, cr * s, bseg, brings, sd + k)
	mb_blob(Vector3(0, cy + cr.y * 0.15, 0), cr * 0.7, bseg, brings, sd + 99)
# capa de pino: cono de follaje con base
func mb_cone_leaf(c: Vector3, r: float, h: float, seg: int) -> void:
	for k in seg:
		var a0 := TAU * k / seg
		var a1 := TAU * (k + 1) / seg
		var p0 := c + Vector3(cos(a0) * r, 0, sin(a0) * r)
		var p1 := c + Vector3(cos(a1) * r, 0, sin(a1) * r)
		mb_tri(p1, p0, c + Vector3(0, h, 0), BM_LEAF, 1)
		mb_tri(c, p0, p1, BM_LEAF, 1)
# 1 a 3 árboles por celda (misma cantidad y lugar que antes), de la especie de la celda, con el color de
# la estación; ralos cuando la estación los deja con poca hoja
func emit_trees(i: int, p: Vector3) -> void:
	var kind: int = tree[i]
	var tc := tree_colors(kind)
	var crown: Color = tc[0]
	var f := 1 if float(tc[1]) < 0.6 else 0
	var models: Array = tree_models.get(kind, tree_models[1])
	var nt := 1 + int(hsh(i, 1) * 2.4)
	for k in nt:
		var x := p.x + (hsh(i, k * 3 + 2) - 0.5) * CELL * 0.6
		var z := p.z + (hsh(i, k * 3 + 3) - 0.5) * CELL * 0.6
		var sc := 0.8 + hsh(i, k * 3 + 4) * 0.4
		var m: int = models[int(hsh(i, k * 3 + 5) * 3.0) % models.size()]
		emit_model(m, f, x, ground_y(x, z) - 0.05, z, hsh(i, k * 3 + 6) * TAU, sc, crown, Vector4(0, 0, hsh(i, k + 20), 0), sc)
