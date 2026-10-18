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
# tipo de auto en movimiento (0 sedán, 1 hatch, 2 camioneta, 3 taxi, 4 utilitario) → modelo del catálogo
const MOVING_CARS := ["sedan", "hatch", "camioneta", "taxi", "utilitario"]
var car_near_nodes: Array = []
var car_mid_nodes: Array = []
func setup_crowd() -> void:
	crowd_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER_CROWD.code
	crowd_mat.shader = sh
	crowd_nodes.clear()
	crowd_bufs.clear()
	car_near_nodes.clear()
	car_mid_nodes.clear()
	crowd_nodes.append(new_mm_node(person_mesh(), crowd_mat))
	# autos: los mismos modelos detallados que los estacionados (etapa 2), versión cerca y media
	for k in 5:
		var id: int = prop_ids[MOVING_CARS[k]]
		var nn := new_mm_node(cat_mesh(id, 0, LOD_NEAR), building_mat)
		nn.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		car_near_nodes.append(nn)
		car_mid_nodes.append(new_mm_node(cat_mesh(id, 0, LOD_MID), building_lite_mat))
		crowd_nodes.append(nn)
	for k in 6:
		var b := PackedFloat32Array()
		b.resize(2000)
		crowd_bufs.append(b)
	crowd_n.resize(6)
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
	flush_mm(crowd_nodes[CR_PERSON].multimesh, crowd_n[CR_PERSON], crowd_bufs[CR_PERSON])
	# los autos: versión cerca cuando la cámara está acercada (con ruedas, faros y sombra)
	var near := b_near_on and int(opts["quality"]) > 0
	for k in 5:
		var on: MultiMeshInstance3D = car_near_nodes[k] if near else car_mid_nodes[k]
		var off: MultiMeshInstance3D = car_mid_nodes[k] if near else car_near_nodes[k]
		flush_mm(on.multimesh, crowd_n[CR_CAR + k], crowd_bufs[CR_CAR + k])
		off.multimesh.visible_instance_count = 0
func pal_idx(c: Color, pal: Array, fallback: int) -> int:
	var i := pal.find(c)
	return i if i >= 0 else fallback
# Precalentado: en Android cada efecto (shader) se arma la primera vez que aparece en pantalla y eso
# cortaba el movimiento (cuadros de 60 a 120 ms). Al arrancar la ciudad se dibuja durante unos cuadros un
# pedacito de cada material frente a la cámara (de 1 píxel, no se nota) para que ya estén armados.
var warm_node: Node3D = null
var warm_frames: int = 0
var warm_done: bool = false
func warm_add_mm(mesh: Mesh, mat: Material, k: int) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = 1
	mm.set_instance_transform(0, Transform3D(Basis().scaled(Vector3.ONE * 0.004), Vector3((k - 4) * 0.01, 0, 0)))
	mm.set_instance_color(0, Color(0.5, 0.5, 0.5))
	mm.set_instance_custom_data(0, Color(0, 0, 0, 0))
	var n := MultiMeshInstance3D.new()
	n.multimesh = mm
	if mat != null:
		n.material_override = mat
	warm_node.add_child(n)
func warm_shaders() -> void:
	if warm_node != null or cam == null:
		return
	warm_node = Node3D.new()
	cam.add_child(warm_node)
	warm_node.position = Vector3(0, 0, -2.0)
	var k := 0
	# edificios: versión cerca (con todos sus detalles) y media/lejana, con un modelo de verdad
	for m in mini(cat_models.size(), 3):
		warm_add_mm(cat_mesh(m, cat_models[m]["floors"].get(cat_models[m]["levels"][0], [0])[0], LOD_NEAR), building_mat, k)
		warm_add_mm(cat_mesh(m, 0, LOD_MID), building_lite_mat, k + 1)
		k += 2
	warm_add_mm(meshes[M_BOX], city_mat, k)
	warm_add_mm(meshes[M_SPH], null, k + 1)
	warm_add_mm(crowd_nodes[CR_PERSON].multimesh.mesh, crowd_mat, k + 2)
	warm_add_mm(crowd_nodes[CR_CAR].multimesh.mesh, building_mat, k + 3)
	warm_add_mm(glow_node.multimesh.mesh, glow_node.material_override, k + 4)
	for mt in [terrain_mat, terrain_simple_mat, water_mat]:
		var mi := MeshInstance3D.new()
		mi.mesh = meshes[M_BOX]
		mi.material_override = mt
		mi.scale = Vector3.ONE * 0.004
		mi.position = Vector3((k + 5) * 0.01, 0.01, 0)
		warm_node.add_child(mi)
		k += 1
	# lluvia y nieve: sus partículas se armaban recién con la primera tormenta (un corte de casi medio segundo)
	if opts["g_rain"] and int(opts["quality"]) >= 1:
		if wfx == null:
			make_wfx()
		config_wfx("rain")
		wfx.global_position = cam.global_position - cam.global_transform.basis.z * 20.0
		wfx.emitting = true
		warm_rain = true
	warm_frames = 6
var warm_rain: bool = false
func warm_step() -> void:
	if warm_node == null:
		if started and not warm_done and not first_chunks:
			warm_done = true
			warm_shaders()
		return
	warm_frames -= 1
	if warm_rain and warm_frames == 3:
		config_wfx("snow")
		wfx.emitting = true
	if warm_frames <= 0:
		warm_node.queue_free()
		warm_node = null
		if warm_rain:
			warm_rain = false
			wfx.emitting = wfx_kind != ""
			if wfx_kind != "":
				config_wfx(wfx_kind)
