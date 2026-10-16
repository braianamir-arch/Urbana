# Gente y autos de una sola pieza: antes cada persona eran 8 a 10 piezas y cada auto unas 10, y armarlas
# en cada cuadro era lo que más tardaba en el celular. Ahora es una instancia y el shader pinta y anima.
const CR_PERSON := 0
const CR_CAR := 1   # 1 a 5: un modelo por tipo de auto (sedán, hatch, camioneta, taxi, utilitario)
const CAR_LN := [2.0, 1.9, 2.5, 2.0, 2.4]
const CAR_BH := [0.45, 0.56, 0.7, 0.45, 0.55]
var crowd_mat: ShaderMaterial
var crowd_nodes: Array = []
var crowd_bufs: Array = []
var crowd_n := PackedInt32Array()
func setup_crowd() -> void:
	crowd_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER_CROWD.code
	crowd_mat.shader = sh
	var meshes2: Array = [person_mesh()]
	for k in 5:
		meshes2.append(car_mesh(k))
	crowd_nodes.clear()
	crowd_bufs.clear()
	for m in meshes2:
		crowd_nodes.append(new_mm_node(m, crowd_mat))
		var b := PackedFloat32Array()
		b.resize(2000)
		crowd_bufs.append(b)
	crowd_n.resize(meshes2.size())
	crowd_n.fill(0)
# partes (UV2.x): 0 remera, 1 pantalón, 2 piel, 3 pelo, 4 zapatos, 5 mochila, 11 brazos;
# movimiento (UV2.y): 1 y 2 piernas, 3 y 4 brazos
func person_mesh() -> ArrayMesh:
	mb_begin()
	for sd in [-1.0, 1.0]:
		var leg := 1 if sd < 0.0 else 2
		mb_cyl(Vector3(sd * 0.075, 0.0, 0.0), 0.06, 0.5, 6, 1, leg)
		mb_box(Vector3(sd * 0.075, 0.0, 0.03), Vector3(0.12, 0.07, 0.18), 4, leg)
		mb_cyl(Vector3(sd * 0.2, 0.5, 0.0), 0.04, 0.4, 5, 11, 3 if sd < 0.0 else 4)
	mb_blob(Vector3(0, 0.72, 0), Vector3(0.17, 0.28, 0.11), 8, 5, 0, 0, 0, false)
	mb_blob(Vector3(0, 0.99, 0), Vector3(0.11, 0.13, 0.11), 8, 5, 0, 2, 0, false)
	mb_blob(Vector3(0, 1.065, -0.02), Vector3(0.115, 0.075, 0.115), 8, 4, 0, 3, 0, false)
	mb_box(Vector3(0, 0.55, -0.15), Vector3(0.26, 0.32, 0.12), 5, 0)
	return mb_end()
# partes: 0 carrocería, 4 ruedas, 6 vidrio, 7 techo, 8 faros, 9 luces traseras, 10 cartel de taxi
func car_mesh(kd: int) -> ArrayMesh:
	mb_begin()
	var ln: float = CAR_LN[kd]
	var bh: float = CAR_BH[kd]
	var cl := ln * (0.85 if kd == 2 else 0.5)
	var ch := 0.4 + (0.25 if kd == 2 else 0.0)
	var cby := 0.2 + bh * 0.88
	mb_box(Vector3(0, 0.2, -ln * 0.16), Vector3(0.95, bh, ln * 0.68), 0, 0)
	mb_box(Vector3(0, 0.2, ln * 0.33), Vector3(0.9, bh * 0.72, ln * 0.34), 0, 0)
	mb_blob(Vector3(0, cby + ch * 0.5, -ln * 0.1), Vector3(0.42, ch * 0.5, cl * 0.5), 10, 5, 0, 6, 0, false)
	mb_box(Vector3(0, cby + ch * 0.82, -ln * 0.1), Vector3(0.66, 0.05, cl * 0.7), 7, 0)
	for sg in [-1.0, 1.0]:
		for fz in [-0.32, 0.32]:
			mb_blob(Vector3(sg * 0.4, 0.21, fz * ln), Vector3(0.1, 0.21, 0.21), 8, 4, 0, 4, 0, false)
	var hy := bh * 0.85 + 0.2
	for sg in [-0.28, 0.28]:
		mb_box(Vector3(sg, hy - 0.06, ln * 0.5), Vector3(0.2, 0.12, 0.06), 8, 0)
		mb_box(Vector3(sg, hy - 0.06, -ln * 0.5 - 0.03), Vector3(0.2, 0.12, 0.06), 9, 0)
	if kd == 3:
		mb_box(Vector3(0, cby + ch * 0.9, -ln * 0.1), Vector3(0.32, 0.1, 0.18), 10, 0)
	return mb_end()
func crowd_begin() -> void:
	crowd_n.fill(0)
# una instancia del modelo k, girada rot sobre Y y escalada sc
func ce(k: int, x: float, y: float, z: float, rot: float, sc: float, col: Color, cu: Vector4) -> void:
	var o: int = crowd_n[k] * 20
	var b: PackedFloat32Array = crowd_bufs[k]
	if o + 20 > b.size():
		b.resize(b.size() * 2)
		crowd_bufs[k] = b
	var c := cos(rot) * sc
	var s := sin(rot) * sc
	b[o] = c
	b[o + 1] = 0.0
	b[o + 2] = s
	b[o + 3] = x
	b[o + 4] = 0.0
	b[o + 5] = sc
	b[o + 6] = 0.0
	b[o + 7] = y
	b[o + 8] = -s
	b[o + 9] = 0.0
	b[o + 10] = c
	b[o + 11] = z
	b[o + 12] = col.r
	b[o + 13] = col.g
	b[o + 14] = col.b
	b[o + 15] = col.a
	b[o + 16] = cu.x
	b[o + 17] = cu.y
	b[o + 18] = cu.z
	b[o + 19] = cu.w
	crowd_n[k] += 1
func crowd_flush() -> void:
	crowd_mat.set_shader_parameter("night", night)
	for k in crowd_nodes.size():
		flush_mm(crowd_nodes[k].multimesh, crowd_n[k], crowd_bufs[k])
func pal_idx(c: Color, pal: Array, fallback: int) -> int:
	var i := pal.find(c)
	return i if i >= 0 else fallback
