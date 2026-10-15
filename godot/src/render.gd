# Cómo se dibuja la ciudad: mallas, chunks, terreno, agua, luz y clima.
const CH := 32
const M_CORNER := 5
const M_GRASS := 6
const M_GABLE := 7
const M_HIP := 8
const MESH_CENTERED := [true, true, true, true, true, false, true, false, false]
var city_mat: ShaderMaterial
var water_mat: ShaderMaterial
var overlay_mat: ShaderMaterial
var terrain_mat: ShaderMaterial
var dtex: ImageTexture
var ctex: ImageTexture
var terrain_node: MeshInstance3D
var water_node: MeshInstance3D
var chunk_nodes: Array = []
var overlay_node: MultiMeshInstance3D
var moon: DirectionalLight3D
var env: Environment
var sky_mat: ShaderMaterial
var cloud_drift := Vector2.ZERO
const SHADER_CITY := preload("res://shaders/city.gdshader")
const SHADER_WATER := preload("res://shaders/water.gdshader")
const SHADER_TERRAIN := preload("res://shaders/terrain.gdshader")
const SHADER_SKY := preload("res://shaders/sky.gdshader")
const SHADER_GLOW := preload("res://shaders/glow.gdshader")
const SHADER_OVERLAY := preload("res://shaders/overlay.gdshader")
func setup_render() -> void:
	meshes.clear()
	var box := BoxMesh.new()
	meshes.append(box)
	var roof := PrismMesh.new()
	meshes.append(roof)
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.5
	cyl.bottom_radius = 0.5
	cyl.height = 1.0
	cyl.radial_segments = 12
	cyl.rings = 1
	meshes.append(cyl)
	var sph := SphereMesh.new()
	sph.radius = 0.5
	sph.height = 1.0
	sph.radial_segments = 10
	sph.rings = 6
	meshes.append(sph)
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.5
	cone.height = 1.0
	cone.radial_segments = 8
	cone.rings = 1
	meshes.append(cone)
	meshes.append(make_corner_mesh())
	var gcone := CylinderMesh.new()
	gcone.top_radius = 0.0
	gcone.bottom_radius = 0.5
	gcone.height = 1.0
	gcone.radial_segments = 5
	gcone.rings = 1
	meshes.append(gcone)
	meshes.append(make_gable_mesh())
	meshes.append(make_hip_mesh())
	city_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER_CITY.code
	city_mat.shader = sh
	for m in meshes:
		m.surface_set_material(0, city_mat)
	water_mat = ShaderMaterial.new()
	var sw := Shader.new()
	sw.code = SHADER_WATER.code
	water_mat.shader = sw
	overlay_mat = ShaderMaterial.new()
	var so := Shader.new()
	so.code = SHADER_OVERLAY.code
	overlay_mat.shader = so
	dtex = make_noise_tex(0.045, 11, 4)
	ctex = make_noise_tex(0.02, 29, 5)
	terrain_mat = ShaderMaterial.new()
	var st2 := Shader.new()
	st2.code = SHADER_TERRAIN.code
	terrain_mat.shader = st2
	for m in [city_mat, terrain_mat]:
		m.set_shader_parameter("dtex", dtex)
		m.set_shader_parameter("ctex", ctex)
	env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky_mat = ShaderMaterial.new()
	sky_mat.shader = SHADER_SKY
	sky_mat.set_shader_parameter("cloud_tex", ctex)
	sky.sky_material = sky_mat
	sky.process_mode = Sky.PROCESS_MODE_INCREMENTAL
	sky.radiance_size = Sky.RADIANCE_SIZE_128
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.0
	env.ambient_light_sky_contribution = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = 1.0
	env.glow_hdr_threshold = 1.3
	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.78, 0.9)
	env.fog_density = 0.0007
	env.fog_sky_affect = 0.3
	env.fog_aerial_perspective = 0.45
	env.fog_height = 8.0
	env.fog_height_density = 0.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.shadow_enabled = true
	sun.shadow_blur = 1.6
	sun.light_specular = 0.35
	sun.directional_shadow_max_distance = 170.0
	add_child(sun)
	moon = DirectionalLight3D.new()
	moon.light_color = Color(0.55, 0.65, 1.0)
	moon.light_energy = 0.0
	moon.rotation_degrees = Vector3(-60, 140, 0)
	add_child(moon)
	terrain_node = MeshInstance3D.new()
	terrain_node.material_override = terrain_mat
	add_child(terrain_node)
	water_node = MeshInstance3D.new()
	var wp := PlaneMesh.new()
	wp.size = Vector2(N * CELL * 5.0, N * CELL * 5.0)
	wp.subdivide_width = 90
	wp.subdivide_depth = 90
	water_node.mesh = wp
	water_node.material_override = water_mat
	water_node.position = Vector3(0, WATER_Y, 0)
	add_child(water_node)
	overlay_node = new_mm_node(meshes[M_BOX], overlay_mat)
	preview_node = new_mm_node(meshes[M_BOX], overlay_mat)
	chunk_nodes.clear()
	chunk_dirty.resize(NCH * NCH)
	chunk_dirty.fill(1)
	for c in NCH * NCH:
		var arr: Array = []
		for m in NMESH:
			var node := new_mm_node(meshes[m], null)
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if m != M_GRASS else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			arr.append(node)
		chunk_nodes.append(arr)
	apply_quality()
func new_mm_node(mesh: Mesh, mat: Material) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = 0
	var node := MultiMeshInstance3D.new()
	node.multimesh = mm
	if mat != null:
		node.material_override = mat
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return node
func make_corner_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 8
	for k in seg:
		var a0 := k * PI * 0.5 / seg
		var a1 := (k + 1) * PI * 0.5 / seg
		var p0 := Vector3(cos(a0), 1, sin(a0))
		var p1 := Vector3(cos(a1), 1, sin(a1))
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(0, 1, 0))
		st.add_vertex(p0)
		st.add_vertex(p1)
		var n := Vector3(cos((a0 + a1) * 0.5), 0, sin((a0 + a1) * 0.5))
		st.set_normal(n)
		st.add_vertex(Vector3(p0.x, 0, p0.z))
		st.add_vertex(p1)
		st.add_vertex(p0)
		st.add_vertex(Vector3(p0.x, 0, p0.z))
		st.add_vertex(Vector3(p1.x, 0, p1.z))
		st.add_vertex(p1)
	return st.commit()
func make_noise_tex(freq: float, sd: int, oct: int) -> ImageTexture:
	var fn := FastNoiseLite.new()
	fn.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fn.fractal_type = FastNoiseLite.FRACTAL_FBM
	fn.fractal_octaves = oct
	fn.frequency = freq
	fn.seed = sd
	var im := fn.get_seamless_image(256, 256)
	im.generate_mipmaps()
	return ImageTexture.create_from_image(im)
var water_simple_mat: StandardMaterial3D
func apply_quality() -> void:
	var q: int = opts["quality"]
	RenderingServer.directional_shadow_atlas_set_size(2048 if q < 2 else 4096, true)
	if sun:
		sun.shadow_enabled = q >= 1 and opts["g_shadow"]
	if env:
		env.fog_enabled = opts["g_fog"]
	if water_node:
		if opts["g_water"]:
			water_node.material_override = water_mat
		else:
			if water_simple_mat == null:
				water_simple_mat = StandardMaterial3D.new()
				water_simple_mat.albedo_color = Color(0.12, 0.38, 0.52)
				water_simple_mat.roughness = 0.2
			water_node.material_override = water_simple_mat
	for nd in dyn_nodes:
		nd.visible = opts["g_dyn"]
	if sun:
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL if q < 2 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	if env:
		env.glow_enabled = q >= 2
		env.glow_intensity = 0.6
		env.glow_bloom = 0.05
	var vp := get_viewport()
	if vp:
		vp.scaling_3d_scale = [0.8, 1.0, 1.0][q]
		vp.msaa_3d = Viewport.MSAA_2X if q >= 2 else Viewport.MSAA_DISABLED
	apply_fx()
var wfx: GPUParticles3D
var wfx_kind: String = ""
var wfx_r: float = 0.0
var vig_layer: CanvasLayer
var cloud_cover: float = -1.0
func apply_fx() -> void:
	if city_mat == null:
		return
	city_mat.set_shader_parameter("wind", 1.0 if opts["g_wind"] else 0.0)
	city_mat.set_shader_parameter("ao_on", 1.0 if opts["g_ao"] else 0.0)
	var dt: float = 1.0 if opts["g_detail"] else 0.0
	city_mat.set_shader_parameter("det", dt)
	terrain_mat.set_shader_parameter("det", dt)
	sky_mat.set_shader_parameter("clouds_on", 1.0 if opts["g_clouds"] else 0.0)
	cloud_cover = -1.0
	env.adjustment_enabled = opts["g_grade"]
	env.adjustment_saturation = 1.12
	env.adjustment_contrast = 1.12
	if vig_layer == null:
		vig_layer = CanvasLayer.new()
		vig_layer.layer = 2
		var gt := GradientTexture2D.new()
		var gr := Gradient.new()
		gr.offsets = PackedFloat32Array([0.5, 0.7, 0.85, 1.0])
		gr.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0.03, 0.02, 0.05, 0.02), Color(0.03, 0.02, 0.05, 0.08), Color(0.03, 0.02, 0.05, 0.2)])
		gt.gradient = gr
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.5)
		gt.fill_to = Vector2(1.0, 0.5)
		gt.width = 128
		gt.height = 128
		var tr := TextureRect.new()
		tr.texture = gt
		tr.set_anchors_preset(Control.PRESET_FULL_RECT)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vig_layer.add_child(tr)
		add_child(vig_layer)
	vig_layer.visible = opts["g_grade"]
func make_wfx() -> void:
	wfx = GPUParticles3D.new()
	wfx.visibility_aabb = AABB(Vector3(-140, -50, -140), Vector3(280, 80, 280))
	wfx.local_coords = false
	wfx.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(wfx)
func config_wfx(kind: String) -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(60, 1, 60)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if kind == "rain":
		pm.direction = Vector3(0.12, -1.0, 0.05)
		pm.spread = 1.5
		pm.initial_velocity_min = 34.0
		pm.initial_velocity_max = 40.0
		pm.gravity = Vector3.ZERO
		var bm := BoxMesh.new()
		bm.size = Vector3(0.025, 1.2, 0.025)
		mat.albedo_color = Color(0.82, 0.88, 1.0, 0.4)
		bm.material = mat
		wfx.draw_pass_1 = bm
		wfx.amount = 1800
		wfx.lifetime = 1.0
	else:
		pm.direction = Vector3(0.1, -1.0, 0.0)
		pm.spread = 28.0
		pm.initial_velocity_min = 2.5
		pm.initial_velocity_max = 4.5
		pm.gravity = Vector3.ZERO
		pm.scale_min = 0.6
		pm.scale_max = 1.4
		var sm := SphereMesh.new()
		sm.radius = 0.09
		sm.height = 0.18
		sm.radial_segments = 6
		sm.rings = 3
		mat.albedo_color = Color(1, 1, 1, 0.9)
		sm.material = mat
		wfx.draw_pass_1 = sm
		wfx.amount = 1500
		wfx.lifetime = 9.0
	wfx.process_material = pm
	wfx.preprocess = wfx.lifetime
	wfx_r = 0.0
func update_fx() -> void:
	if opts["g_clouds"]:
		cloud_drift += wind * get_process_delta_time() * 0.0035
		sky_mat.set_shader_parameter("cloud_off", cloud_drift)
		var cv := 0.45
		if weather == "Nublado":
			cv = 0.85
		elif weather == "Lluvia" or weather == "Tormenta" or weather == "Nieve":
			cv = 0.95
		if cv != cloud_cover:
			cloud_cover = cv
			sky_mat.set_shader_parameter("cover", cv)
			sky_mat.set_shader_parameter("storm", 1.0 if weather in ["Lluvia", "Tormenta", "Nieve"] else 0.0)
			city_mat.set_shader_parameter("cshadow", cv)
			terrain_mat.set_shader_parameter("cshadow", cv)
	elif cloud_cover != 0.0:
		cloud_cover = 0.0
		city_mat.set_shader_parameter("cshadow", 0.0)
		terrain_mat.set_shader_parameter("cshadow", 0.0)
	var want := ""
	if opts["g_rain"] and opts["quality"] >= 1 and started:
		if weather == "Lluvia" or weather == "Tormenta":
			want = "rain"
		elif weather == "Nieve":
			want = "snow"
	if want != wfx_kind:
		wfx_kind = want
		if want != "":
			if wfx == null:
				make_wfx()
			config_wfx(want)
		if wfx:
			wfx.emitting = want != ""
	if wfx and wfx.emitting:
		wfx.global_position = Vector3(cam_target.x, 32.0, cam_target.z)
		var r := clampf(cam_dist * 0.9, 30.0, 110.0)
		if absf(r - wfx_r) > 5.0:
			wfx_r = r
			(wfx.process_material as ParticleProcessMaterial).emission_box_extents = Vector3(r, 1, r)
func build_terrain() -> void:
	terrain_dirty = false
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var s := season()
	var grass: Color = [Color(0.42, 0.62, 0.28), Color(0.58, 0.55, 0.28), Color(0.62, 0.66, 0.6), Color(0.45, 0.68, 0.32)][s]
	if weather == "Nieve":
		grass = Color(0.9, 0.92, 0.95)
	var half := N * CELL * 0.5
	var vh := PackedFloat32Array()
	vh.resize((N + 1) * (N + 1))
	var vc := PackedColorArray()
	vc.resize((N + 1) * (N + 1))
	for z in N + 1:
		for x in N + 1:
			var hs := 0.0
			var cnt := 0
			var col := Color(0, 0, 0)
			for o in [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]:
				var xx: int = x + o.x
				var zz: int = z + o.y
				if inb(xx, zz):
					var i := idx(xx, zz)
					hs += hgt[i]
					cnt += 1
					col += terrain_color(i, grass)
			vh[z * (N + 1) + x] = hs / maxf(cnt, 1)
			vc[z * (N + 1) + x] = col / maxf(cnt, 1)
	for z in N:
		for x in N:
			var a := z * (N + 1) + x
			var b := a + 1
			var c := a + N + 1
			var d := c + 1
			var pa := Vector3(x * CELL - half, vh[a], z * CELL - half)
			var pb := Vector3((x + 1) * CELL - half, vh[b], z * CELL - half)
			var pc := Vector3(x * CELL - half, vh[c], (z + 1) * CELL - half)
			var pd := Vector3((x + 1) * CELL - half, vh[d], (z + 1) * CELL - half)
			st.set_color(vc[a]); st.add_vertex(pa)
			st.set_color(vc[b]); st.add_vertex(pb)
			st.set_color(vc[d]); st.add_vertex(pd)
			st.set_color(vc[a]); st.add_vertex(pa)
			st.set_color(vc[d]); st.add_vertex(pd)
			st.set_color(vc[c]); st.add_vertex(pc)
	var himg := Image.create(N + 1, N + 1, false, Image.FORMAT_RH)
	for z in N + 1:
		for x in N + 1:
			himg.set_pixel(x, z, Color(vh[z * (N + 1) + x], 0.0, 0.0))
	var htex := ImageTexture.create_from_image(himg)
	city_mat.set_shader_parameter("hmap", htex)
	water_mat.set_shader_parameter("hmap", htex)
	water_mat.set_shader_parameter("hinfo", Vector4(N * CELL, half, float(N) / float(N + 1), 0.5 / float(N + 1)))
	city_mat.set_shader_parameter("hinfo", Vector4(N * CELL, half, float(N) / float(N + 1), 0.5 / float(N + 1)))
	st.generate_normals()
	terrain_node.mesh = st.commit()
	build_outer(grass)
func terrain_color(i: int, grass: Color) -> Color:
	var c: Color
	match terr[i]:
		T_WATER:
			c = Color(0.55, 0.5, 0.38)
		T_SAND:
			c = Color(0.86, 0.78, 0.55)
		T_ROCK:
			c = Color(0.5, 0.48, 0.44)
		_:
			var v := float((cx(i) * 13 + cz(i) * 7) % 5) * 0.012
			c = grass + Color(v, v, -v)
	if not is_owned(i):
		c = c.darkened(0.28)
	return c
var outer_nodes: Array = []
func build_outer(grass: Color) -> void:
	for n in outer_nodes:
		n.queue_free()
	outer_nodes.clear()
	var size := N * CELL
	var sides := [[Vector2i(-1, 0), 0], [Vector2i(1, 0), 0], [Vector2i(0, -1), 0], [Vector2i(0, 1), 0]]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = grass.darkened(0.12)
	mat.roughness = 1.0
	for sd in sides:
		var dir: Vector2i = sd[0]
		var water := 0
		for k in N:
			var x := 0
			var z := 0
			if dir.x != 0:
				x = 0 if dir.x < 0 else N - 1
				z = k
			else:
				z = 0 if dir.y < 0 else N - 1
				x = k
			if terr[idx(x, z)] == T_WATER:
				water += 1
		if water > N / 3:
			continue
		var m := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(size * 2.0, size * 2.0) if dir.x != 0 else Vector2(size, size * 2.0)
		m.mesh = pm
		m.material_override = mat
		m.position = Vector3(dir.x * size * 1.5, -0.05, dir.y * size * 1.5)
		if dir.y != 0:
			pm.size = Vector2(size * 4.0, size * 2.0)
		add_child(m)
		outer_nodes.append(m)
		for h in 4:
			var hill := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 1.0
			sm.height = 2.0
			hill.mesh = sm
			var hm := StandardMaterial3D.new()
			hm.albedo_color = grass.darkened(0.25).lerp(Color(0.5, 0.6, 0.7), 0.3)
			hill.material_override = hm
			var off := (h - 1.5) * size * 0.55
			var p := Vector3(dir.x * size * 1.4, -6.0, dir.y * size * 1.4)
			if dir.x != 0:
				p.z = off
			else:
				p.x = off
			hill.position = p
			hill.scale = Vector3(size * 0.35, 30.0 + h * 6.0, size * 0.3)
			add_child(hill)
			outer_nodes.append(hill)
func mark_dirty(i: int) -> void:
	var x := cx(i)
	var z := cz(i)
	for o in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var xx: int = clampi(x + o.x * 2, 0, N - 1)
		var zz: int = clampi(z + o.y * 2, 0, N - 1)
		chunk_dirty[(zz / CH) * NCH + xx / CH] = 1
func mark_all_dirty() -> void:
	chunk_dirty.fill(1)
func update_chunks(max_n: int) -> void:
	var done := 0
	for c in NCH * NCH:
		if chunk_dirty[c] == 1:
			chunk_dirty[c] = 0
			build_chunk(c)
			done += 1
			if done >= max_n:
				return
func build_chunk(c: int) -> void:
	begin_buf()
	var x0 := (c % NCH) * CH
	var z0 := (c / NCH) * CH
	for z in range(z0, z0 + CH):
		for x in range(x0, x0 + CH):
			emit_cell(idx(x, z))
	var nodes: Array = chunk_nodes[c]
	for m in NMESH:
		var node: MultiMeshInstance3D = nodes[m]
		var mm := node.multimesh
		mm.instance_count = _counts[m]
		if _counts[m] > 0:
			mm.buffer = _bufs[m].slice(0, _counts[m] * 20)
func begin_buf() -> void:
	_counts.resize(NMESH)
	_counts.fill(0)
	while _bufs.size() < NMESH:
		var pb := PackedFloat32Array()
		pb.resize(2000)
		_bufs.append(pb)
func em(m: int, x: float, y: float, z: float, sx: float, sy: float, sz: float, rot: float, col: Color, c0: float = 0.0, c1: float = 0.0, c2: float = 0.0, c3: float = 0.0) -> void:
	var c := cos(rot)
	var s := sin(rot)
	var oy := y + (sy * 0.5 if MESH_CENTERED[m] else 0.0)
	var o: int = _counts[m] * 20
	var b: PackedFloat32Array = _bufs[m]
	if o + 20 > b.size():
		b.resize(maxi(b.size() * 2, 2000))
		_bufs[m] = b
	b[o] = c * sx
	b[o + 2] = s * sz
	b[o + 3] = x
	b[o + 5] = sy
	b[o + 7] = oy
	b[o + 8] = -s * sx
	b[o + 10] = c * sz
	b[o + 11] = z
	b[o + 12] = col.r
	b[o + 13] = col.g
	b[o + 14] = col.b
	b[o + 15] = col.a
	b[o + 16] = c0
	b[o + 17] = c1
	b[o + 18] = c2
	b[o + 19] = c3
	b[o + 1] = 0.0
	b[o + 4] = 0.0
	b[o + 6] = 0.0
	b[o + 9] = 0.0
	_counts[m] += 1
func emit_cell(i: int) -> void:
	var p := cell_pos(i)
	lamps.erase(i)
	if road[i] > 0:
		emit_road(i, p)
	elif bld[i] > 0:
		if part[i] < 0 or part[i] == i:
			emit_def(i, p)
	elif zone[i] > 0:
		if part[i] >= 0 and part[i] != i:
			pass
		elif anim_cells.has(i):
			emit_lot(i, p)
		else:
			emit_zone(i, p)
	elif tree[i] > 0:
		emit_trees(i, p)
	elif terr[i] == T_LAND and opts["g_grass"] and weather != "Nieve":
		emit_grass(i, p)
	if wire[i] & W_POWER and road[i] == 0 and bld[i] == 0 and zone[i] == 0:
		emit_cable(i, p)
	if wire[i] & W_LEVEE:
		em(M_BOX, p.x, p.y, p.z, CELL, 1.4, CELL, 0.0, Color(0.55, 0.55, 0.52))
	if flood[i] > 0.0:
		em(M_BOX, p.x, p.y, p.z, CELL, 0.25, CELL, 0.0, Color(0.2, 0.4, 0.55), 0, 0, 0.1, 1)
	if garbp[i] > 0.5 and road[i] == 0:
		for k in mini(3, int(garbp[i])):
			em(M_SPH, p.x + (hsh(i, k) - 0.5) * 2.2, p.y, p.z + (hsh(i, k + 5) - 0.5) * 2.2, 0.9, 0.6, 0.9, 0.0, Color(0.35, 0.3, 0.2))
	if burn[i] > 0.99:
		em(M_BOX, p.x, p.y, p.z, CELL * 0.8, 0.4, CELL * 0.8, 0.0, Color(0.12, 0.1, 0.1))
func emit_road(i: int, p: Vector3) -> void:
	var t: int = road[i]
	var col: Color = [Color(), Color(0.55, 0.45, 0.32), Color(0.25, 0.25, 0.27), Color(0.21, 0.21, 0.23), Color(0.19, 0.19, 0.21)][t]
	var nb := road_n(i)
	var e: bool = nb[0]
	var w: bool = nb[1]
	var s: bool = nb[2]
	var n: bool = nb[3]
	var cnt := int(e) + int(w) + int(s) + int(n)
	var y := p.y
	var bridge := terr[i] == T_WATER
	if bridge:
		y = 0.6
		em(M_BOX, p.x, WATER_Y - 1.0, p.z, 0.8, 1.6 + y, 0.8, 0.0, Color(0.5, 0.5, 0.5))
	var sidewalk := Color(0.62, 0.6, 0.56)
	var corner := cnt == 2 and ((e and s) or (e and n) or (w and s) or (w and n)) and not bridge
	if corner:
		var cxo := 1.0 if e else -1.0
		var czo := 1.0 if s else -1.0
		var rot := 0.0
		if cxo > 0 and czo > 0:
			rot = PI
		elif cxo < 0 and czo > 0:
			rot = -PI * 0.5
		elif cxo > 0 and czo < 0:
			rot = PI * 0.5
		em(M_CORNER, p.x + cxo * CELL * 0.5, y, p.z + czo * CELL * 0.5, CELL * 1.02, 0.17, CELL * 1.02, rot, sidewalk)
		em(M_CORNER, p.x + cxo * CELL * 0.5, y, p.z + czo * CELL * 0.5, CELL * 0.86, 0.2, CELL * 0.86, rot, col)
		return
	em(M_BOX, p.x, y, p.z, CELL, 0.2, CELL, 0.0, col)
	var horiz := (e or w) and not (s or n)
	var vert := (s or n) and not (e or w)
	if t >= 2 and not bridge:
		if not n and (horiz or cnt <= 1):
			em(M_BOX, p.x, y, p.z - CELL * 0.44, CELL, 0.26, CELL * 0.12, 0.0, sidewalk)
		if not s and (horiz or cnt <= 1):
			em(M_BOX, p.x, y, p.z + CELL * 0.44, CELL, 0.26, CELL * 0.12, 0.0, sidewalk)
		if not e and (vert or cnt <= 1):
			em(M_BOX, p.x + CELL * 0.44, y, p.z, CELL * 0.12, 0.26, CELL, 0.0, sidewalk)
		if not w and (vert or cnt <= 1):
			em(M_BOX, p.x - CELL * 0.44, y, p.z, CELL * 0.12, 0.26, CELL, 0.0, sidewalk)
	if wire[i] & W_ROUND:
		em(M_CYL, p.x, y, p.z, CELL * 0.45, 0.35, CELL * 0.45, 0.0, Color(0.3, 0.6, 0.3))
		em(M_SPH, p.x, y + 0.3, p.z, 1.0, 1.4, 1.0, 0.0, Color(0.25, 0.5, 0.25))
		return
	var rot := 0.0 if horiz else PI * 0.5
	if horiz or vert:
		match t:
			2:
				if (cx(i) + cz(i)) % 2 == 0:
					em(M_BOX, p.x, y, p.z, CELL * 0.45, 0.22, 0.12, rot, Color(0.9, 0.85, 0.6))
			3:
				em(M_BOX, p.x, y, p.z, CELL, 0.32, 0.5, rot, Color(0.35, 0.55, 0.3))
				if hsh(i, 3) < 0.4:
					em(M_SPH, p.x, y + 0.3, p.z, 0.9, 1.4, 0.9, 0.0, Color(0.28, 0.5, 0.25))
			4:
				em(M_BOX, p.x, y, p.z, CELL, 0.25, 0.25, rot, Color(0.85, 0.75, 0.2))
				em(M_BOX, p.x, y, p.z, CELL, 0.45, 0.15, rot, Color(0.7, 0.7, 0.7))
		if wire[i] & W_BIKE:
			var off := Vector2(0, CELL * 0.33) if horiz else Vector2(CELL * 0.33, 0)
			em(M_BOX, p.x + off.x, y, p.z + off.y, CELL if horiz else 0.6, 0.23, 0.6 if horiz else CELL, 0.0, Color(0.25, 0.6, 0.35))
		if wire[i] & W_TRAM:
			for sgn in [-0.12, 0.12]:
				var o2 := Vector2(0, CELL * sgn) if horiz else Vector2(CELL * sgn, 0)
				em(M_BOX, p.x + o2.x, y, p.z + o2.y, CELL if horiz else 0.1, 0.25, 0.1 if horiz else CELL, 0.0, Color(0.6, 0.6, 0.62))
		if t >= 2 and (cx(i) + cz(i) * 3) % 3 == 0 and not bridge:
			var lo := Vector2(0, -CELL * 0.45) if horiz else Vector2(-CELL * 0.45, 0)
			var ao := Vector2(0, 0.8) if horiz else Vector2(0.8, 0)
			em(M_BOX, p.x + lo.x, y, p.z + lo.y, 0.12, 2.9, 0.12, 0.0, Color(0.3, 0.3, 0.32))
			em(M_BOX, p.x + lo.x + ao.x * 0.5, y + 2.85, p.z + lo.y + ao.y * 0.5, 0.09 if horiz else 0.8, 0.09, 0.8 if horiz else 0.09, 0.0, Color(0.3, 0.3, 0.32))
			em(M_BOX, p.x + lo.x + ao.x, y + 2.78, p.z + lo.y + ao.y, 0.34, 0.1, 0.34, 0.0, Color(1.0, 0.85, 0.55), 0, 1.0)
			lamps[i] = Vector3(p.x + lo.x + ao.x, y, p.z + lo.y + ao.y)
		if t == 2 and opts["quality"] >= 1:
			for side in [-1, 1]:
				var j: int = i + (N * side if horiz else side)
				if j >= 0 and j < N * N and zone[j] > 0 and lvl[j] >= 1 and hsh(i, side + 7) < 0.45:
					var po := Vector2(0, side * CELL * 0.3) if horiz else Vector2(side * CELL * 0.3, 0)
					em(M_BOX, p.x + po.x, y + 0.15, p.z + po.y, 1.6, 0.6, 0.8, rot, car_color(i * 3 + side))
func car_color(k: int) -> Color:
	var pal := [Color(0.85, 0.85, 0.87), Color(0.15, 0.15, 0.17), Color(0.7, 0.12, 0.1), Color(0.2, 0.3, 0.6), Color(0.55, 0.57, 0.6), Color(0.9, 0.75, 0.2), Color(0.25, 0.45, 0.3)]
	return pal[absi(k) % pal.size()]
func emit_cable(i: int, p: Vector3) -> void:
	em(M_BOX, p.x, p.y, p.z, 0.2, 4.0, 0.2, 0.0, Color(0.45, 0.35, 0.25))
	em(M_BOX, p.x, p.y + 3.6, p.z, 1.6, 0.12, 0.12, 0.0, Color(0.45, 0.35, 0.25))
	var x := cx(i)
	var z := cz(i)
	if x < N - 1 and wire[i + 1] & W_POWER:
		em(M_BOX, p.x + CELL * 0.5, p.y + 3.6, p.z, CELL, 0.05, 0.05, 0.0, Color(0.1, 0.1, 0.1))
	if z < N - 1 and wire[i + N] & W_POWER:
		em(M_BOX, p.x, p.y + 3.6, p.z + CELL * 0.5, 0.05, 0.05, CELL, 0.0, Color(0.1, 0.1, 0.1))
func tree_colors(kind: int) -> Array:
	var s := season()
	var snowy := weather == "Nieve"
	match kind:
		1, 2:
			if s == 1:
				return [Color(0.8, 0.5, 0.15) if kind == 2 else Color(0.75, 0.45, 0.2), 1.0]
			if s == 2:
				return [Color(0.45, 0.35, 0.25), 0.45]
			return [Color(0.3, 0.55, 0.22) if kind == 1 else Color(0.38, 0.58, 0.25), 1.0]
		3:
			if s == 3:
				return [Color(0.58, 0.42, 0.85), 1.0]
			if s == 2:
				return [Color(0.42, 0.38, 0.3), 0.5]
			return [Color(0.32, 0.55, 0.3), 1.0]
		4:
			return [Color(0.9, 0.92, 0.95) if snowy else Color(0.15, 0.38, 0.2), 1.0]
		5:
			if s == 0 or s == 3:
				return [Color(0.92, 0.5, 0.7), 1.0]
			return [Color(0.35, 0.55, 0.28), 0.9]
		6:
			return [Color(0.3, 0.6, 0.25), 1.0]
		7:
			return [Color(0.55, 0.7, 0.3) if s != 2 else Color(0.5, 0.5, 0.35), 1.0]
	return [Color(0.3, 0.55, 0.25), 1.0]
func emit_trees(i: int, p: Vector3) -> void:
	var kind: int = tree[i]
	var tc := tree_colors(kind)
	var crown: Color = tc[0]
	var full: float = tc[1]
	var nt := 1 + int(hsh(i, 1) * 2.4)
	for k in nt:
		var ox := (hsh(i, k * 3 + 2) - 0.5) * CELL * 0.6
		var oz := (hsh(i, k * 3 + 3) - 0.5) * CELL * 0.6
		var sc := 0.8 + hsh(i, k * 3 + 4) * 0.6
		var x := p.x + ox
		var z := p.z + oz
		var gy := ground_y(x, z) - 0.12
		match kind:
			4:
				em(M_BOX, x, gy, z, 0.25 * sc, 0.8 * sc, 0.25 * sc, 0.0, Color(0.35, 0.25, 0.15))
				em(M_CONE, x, gy + 0.6 * sc, z, 1.7 * sc, 3.2 * sc, 1.7 * sc, 0.0, crown, 0.0, 0.0, 0.0, 2.08)
			5:
				em(M_CYL, x, gy, z, 0.6 * sc, 1.6 * sc, 0.6 * sc, 0.0, Color(0.45, 0.5, 0.35))
				em(M_SPH, x, gy + 1.4 * sc, z, 2.2 * sc * full, 1.6 * sc * full, 2.2 * sc * full, 0.0, crown, 0.0, 0.0, 0.0, 2.15)
			6:
				em(M_BOX, x, gy, z, 0.22 * sc, 3.2 * sc, 0.22 * sc, 0.3, Color(0.5, 0.4, 0.25))
				em(M_SPH, x, gy + 3.0 * sc, z, 2.2 * sc, 0.6 * sc, 2.2 * sc, 0.0, crown, 0.0, 0.0, 0.0, 2.3)
			7:
				em(M_BOX, x, gy, z, 0.3 * sc, 1.2 * sc, 0.3 * sc, 0.0, Color(0.35, 0.28, 0.2))
				em(M_SPH, x, gy + 0.6 * sc, z, 2.6 * sc, 2.2 * sc, 2.6 * sc, 0.0, crown, 0.0, 0.0, 0.0, 2.18)
			_:
				em(M_BOX, x, gy, z, 0.25 * sc, 1.1 * sc, 0.25 * sc, 0.0, Color(0.35, 0.25, 0.15))
				em(M_SPH, x, gy + 0.9 * sc, z, 1.9 * sc * full, 1.8 * sc * full, 1.9 * sc * full, 0.0, crown, 0.0, 0.0, 0.0, 2.16)
func emit_grass(i: int, p: Vector3) -> void:
	var h := hsh(i, 40)
	if h > 0.17:
		return
	var gc: Color = [Color(0.3, 0.52, 0.2), Color(0.5, 0.46, 0.2), Color(0.5, 0.56, 0.5), Color(0.33, 0.56, 0.22)][season()]
	for k in 2:
		var x := p.x + (hsh(i, 41 + k) - 0.5) * CELL * 0.8
		var z := p.z + (hsh(i, 44 + k) - 0.5) * CELL * 0.8
		var hh := 0.35 + hsh(i, 47 + k) * 0.4
		var v := 0.85 + hsh(i, 50 + k) * 0.35
		em(M_GRASS, x, ground_y(x, z) - 0.04, z, 0.18, hh, 0.18, hsh(i, 53 + k) * 3.0, gc * v * 1.3, 0.0, 0.0, 0.0, 2.1)
	if h < 0.03:
		var fc: Color = [Color(0.95, 0.85, 0.25), Color(0.95, 0.95, 0.92), Color(0.9, 0.45, 0.6), Color(0.7, 0.5, 0.9)][int(hsh(i, 60) * 4.0) % 4]
		var fx := p.x + (hsh(i, 61) - 0.5) * CELL * 0.6
		var fz := p.z + (hsh(i, 62) - 0.5) * CELL * 0.6
		em(M_GRASS, fx, ground_y(fx, fz) + 0.26, fz, 0.2, 0.16, 0.2, 0.0, fc, 0.0, 0.0, 0.0, 2.1)
func zone_color(z: int) -> Color:
	if opts["colorblind"]:
		return [Color(), Color(0.95, 0.75, 0.2), Color(0.2, 0.5, 0.95), Color(0.6, 0.6, 0.6), Color(0.9, 0.5, 0.9)][z]
	return [Color(), Color(0.45, 0.8, 0.4), Color(0.35, 0.55, 0.95), Color(0.95, 0.8, 0.3), Color(0.75, 0.55, 0.9)][z]
func emit_lot(i: int, p: Vector3) -> void:
	em(M_BOX, p.x, p.y, p.z, CELL * 0.92, 0.08, CELL * 0.92, 0.0, zone_color(zone[i]).darkened(0.35))
func emit_zone(i: int, p: Vector3) -> void:
	var z: int = zone[i]
	var l: int = lvl[i]
	if l == 0:
		emit_lot(i, p)
		return
	var v: int = vari[i]
	var rot := face_rot(i)
	var dark := burn[i] > 0.0
	var big := part[i] == i
	var w := CELL * (1.85 if big else 0.82)
	var bx := p.x
	var bz := p.z
	if big:
		bx += CELL * 0.5
		bz += CELL * 0.5
	em(M_BOX, bx, p.y, bz, w + CELL * 0.1, 0.12, w + CELL * 0.1, 0.0, (Color(0.36, 0.5, 0.28) if l == 1 else Color(0.5, 0.52, 0.45)) if z == Z_R else Color(0.55, 0.55, 0.55))
	var y := p.y + 0.1
	var wall := tint(res_wall(v), i)
	if dark:
		wall = wall.darkened(0.6)
	match z:
		Z_R:
			emit_res(i, bx, y, bz, w, l, v, rot, wall, big)
		Z_C:
			emit_com(i, bx, y, bz, w, l, v, rot, dark, big)
		Z_I:
			emit_ind(i, bx, y, bz, w, l, v, rot, dark)
		Z_M:
			emit_com(i, bx, y, bz, w, mini(l, 2), v, rot, dark, false)
			if l >= 2:
				var h := 2.0 + l * 2.5
				em(M_BOX, bx, y + 3.0, bz, w * 0.8, h, w * 0.8, rot, wall, 1.0)
func tint(c: Color, i: int) -> Color:
	var hh := fposmod(c.h + (hsh(i, 77) - 0.5) * 0.07, 1.0)
	return Color.from_hsv(hh, clampf(c.s * (0.75 + hsh(i, 78) * 0.6), 0.0, 1.0), clampf(c.v * (0.86 + hsh(i, 79) * 0.2), 0.0, 1.0))
func tower_col(v: int, i: int) -> Color:
	var gp := [Color(0.45, 0.62, 0.78), Color(0.35, 0.58, 0.55), Color(0.66, 0.6, 0.5), Color(0.3, 0.34, 0.42), Color(0.78, 0.74, 0.68), Color(0.5, 0.52, 0.72), Color(0.72, 0.5, 0.42)]
	return tint(gp[(v / 3 + i) % gp.size()], i)
func res_wall(v: int) -> Color:
	var pal := [Color(0.92, 0.88, 0.8), Color(0.85, 0.72, 0.6), Color(0.95, 0.93, 0.88), Color(0.78, 0.55, 0.45), Color(0.88, 0.82, 0.65), Color(0.7, 0.75, 0.78), Color(0.95, 0.85, 0.75), Color(0.65, 0.6, 0.55)]
	return pal[v % pal.size()]
func emit_ind(i: int, x: float, y: float, z: float, w: float, l: int, v: int, rot: float, dark: bool) -> void:
	var c := tint(COL_BRICK if v % 2 == 0 else Color(0.55, 0.6, 0.62), i)
	var im := -1.0 if v % 2 == 0 else -5.0
	if dark:
		c = c.darkened(0.6)
	match l:
		1:
			em(M_BOX, x, y, z, w * 0.9, 2.6, w * 0.8, rot, c, 0, 0, 0, im)
			em(M_ROOF, x, y + 2.6, z, w * 0.9, 0.8, w * 0.8, rot, Color(0.45, 0.47, 0.5), 0, 0, 0, -5)
		2:
			em(M_BOX, x, y, z, w * 0.9, 3.4, w * 0.9, rot, c, 0.4, 0, 0, im)
			em(M_CYL, x + w * 0.3, y, z + w * 0.3, 0.8, 5.0, 0.8, 0.0, Color(0.42, 0.38, 0.36))
		3:
			em(M_BOX, x - w * 0.15, y, z, w * 0.6, 4.0, w * 0.9, rot, c, 0.4, 0, 0, im)
			em(M_CYL, x + w * 0.3, y, z - w * 0.2, 1.4, 3.5, 1.4, 0.0, Color(0.8, 0.8, 0.82))
			em(M_CYL, x + w * 0.3, y, z + w * 0.25, 1.4, 3.5, 1.4, 0.0, Color(0.8, 0.8, 0.82))
			em(M_CYL, x - w * 0.3, y, z - w * 0.3, 0.8, 6.5, 0.8, 0.0, Color(0.42, 0.38, 0.36))
		4:
			em(M_BOX, x, y, z, w * 0.95, 6.0, w * 0.95, rot, c, 0.5, 0, 0, im)
			em(M_CYL, x - w * 0.3, y, z - w * 0.3, 1.0, 8.5, 1.0, 0.0, Color(0.42, 0.38, 0.36))
			em(M_CYL, x + w * 0.3, y, z - w * 0.3, 1.0, 7.5, 1.0, 0.0, Color(0.42, 0.38, 0.36))
			em(M_BOX, x, y + 6.0, z, w * 0.5, 1.5, w * 0.4, rot, c.darkened(0.2))
func emit_def(i: int, p: Vector3) -> void:
	var d: Dictionary = DEF[bld[i]]
	var sz: int = d["sz"]
	var w := sz * CELL
	var x := p.x + (sz - 1) * CELL * 0.5
	var z := p.z + (sz - 1) * CELL * 0.5
	var y := p.y
	var col: Color = d["col"]
	if burn[i] > 0.0:
		col = col.darkened(0.6)
	var sh: String = d["sh"]
	var rot := face_rot(i)
	if d["c"] == "wonder":
		var prog: int = wonder_progress.get(i, 0)
		if prog < WONDER_STEPS:
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.6, 0.55, 0.45))
			var h := 2.0 + prog * 3.0
			em(M_BOX, x, y, z, w * 0.6, h, w * 0.6, 0.0, col.darkened(0.3))
			for k in 4:
				var a := k * PI * 0.5 + 0.785
				em(M_BOX, x + cos(a) * w * 0.38, y, z + sin(a) * w * 0.38, 0.2, h + 1.0, 0.2, 0.0, Color(0.85, 0.6, 0.2))
			em(M_BOX, x + w * 0.3, y, z - w * 0.3, 0.3, h + 8.0, 0.3, 0.0, Color(0.95, 0.75, 0.1))
			em(M_BOX, x + w * 0.1, y + h + 7.6, z - w * 0.3, w * 0.5, 0.3, 0.3, 0.0, Color(0.95, 0.75, 0.1))
			return
	var ground := Color(0.55, 0.55, 0.52)
	match sh:
		"cinema":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			bx(x, y, z, rot, 0, -0.05 * w, 0, w * 0.86, 5.2, w * 0.78, col)
			bx(x, y, z, rot, 0, -0.05 * w, 5.2, w * 0.9, 0.3, w * 0.82, Color(0.12, 0.12, 0.13))
			bx(x, y, z, rot, 0, 0.42 * w, 2.6, w * 0.92, 0.7, 0.55, Color(0.95, 0.85, 0.45), 0, 0.9)
			bx(x, y, z, rot, 0, 0.43 * w, 2.45, w * 0.88, 0.12, 0.5, Color(1.0, 0.92, 0.65), 0, 0, 2.2)
			bx(x, y, z, rot, 0.36 * w, 0.39 * w, 3.3, 0.25, 2.8, 0.55, Color(1.0, 0.25, 0.2), 0, 0, 1.6)
			bx(x, y, z, rot, -0.27 * w, 0.351 * w, 0.5, 0.65, 1.3, 0.04, Color(0.2, 0.25, 0.55), 0, 0.5)
			bx(x, y, z, rot, 0.27 * w, 0.351 * w, 0.5, 0.65, 1.3, 0.04, Color(0.65, 0.15, 0.1), 0, 0.5)
			bx(x, y, z, rot, 0, 0.351 * w, 0.05, 1.0, 2.0, 0.03, COL_GLASS, 0, 0, 0, -8)
		"civic":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x, y, z, w * 0.8, 3.2, w * 0.7, rot, col, 0.8)
			em(M_BOX, x, y + 3.2, z, w * 0.84, 0.3, w * 0.74, rot, col.darkened(0.25))
			em(M_BOX, x + w * 0.38, y, z + w * 0.38, 0.1, 4.5, 0.1, 0.0, Color(0.8, 0.8, 0.8))
			em(M_BOX, x + w * 0.38 + 0.45, y + 3.9, z + w * 0.38, 0.9, 0.5, 0.05, 0.0, Color(0.45, 0.7, 0.95))
		"tower":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x, y, z, w * 0.75, 4.0 + sz * 5.0, w * 0.55, rot, col, 1.0)
			em(M_BOX, x, y, z, w * 0.4, 7.0 + sz * 6.0, w * 0.4, rot, col.darkened(0.08), 1.0)
		"campus":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.4, 0.62, 0.32))
			em(M_BOX, x, y, z - w * 0.25, w * 0.7, 6.0, w * 0.25, 0.0, col, 1.0)
			em(M_BOX, x - w * 0.3, y, z + w * 0.15, w * 0.2, 4.5, w * 0.45, 0.0, col, 1.0)
			em(M_BOX, x + w * 0.3, y, z + w * 0.15, w * 0.2, 4.5, w * 0.45, 0.0, col, 1.0)
			em(M_BOX, x, y + 6.0, z - w * 0.25, 2.0, 4.0, 2.0, 0.0, col.lightened(0.1))
		"cabildo":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.66, 0.6))
			em(M_BOX, x, y, z, w * 0.8, 5.0, w * 0.45, rot, col, 0.9)
			em(M_ROOF, x, y + 5.0, z, w * 0.8, 1.2, w * 0.45, rot, Color(0.6, 0.3, 0.2))
			em(M_BOX, x, y, z, 2.2, 10.0, 2.2, rot, col)
			em(M_CONE, x, y + 10.0, z, 2.4, 2.5, 2.4, 0.0, Color(0.55, 0.3, 0.2))
		"park":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, col)
			em(M_BOX, x, y, z, w * 0.9, 0.17, 0.8, 0.0, Color(0.8, 0.75, 0.6))
			em(M_BOX, x, y, z, 0.8, 0.17, w * 0.9, 0.0, Color(0.8, 0.75, 0.6))
			for k in sz * 3:
				var ax := x + (hsh(i, k) - 0.5) * w * 0.8
				var az := z + (hsh(i, k + 9) - 0.5) * w * 0.8
				em(M_BOX, ax, y, az, 0.25, 1.0, 0.25, 0.0, Color(0.35, 0.25, 0.15))
				em(M_SPH, ax, y + 0.8, az, 2.0, 2.0, 2.0, 0.0, tree_colors(1 + k % 3)[0])
			if sz >= 2:
				em(M_CYL, x, y, z, 2.0, 0.6, 2.0, 0.0, Color(0.7, 0.7, 0.72))
				em(M_CYL, x, y + 0.6, z, 0.5, 1.4, 0.5, 0.0, Color(0.6, 0.75, 0.95), 0, 0, 0.2)
		"pitch":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, Color(0.25, 0.58, 0.28))
			em(M_BOX, x, y, z, w * 0.75, 0.16, w * 0.55, rot, Color(0.3, 0.7, 0.32))
			em(M_BOX, x, y, z, 0.12, 0.17, w * 0.55, rot, Color(0.95, 0.95, 0.95))
			for sgn in [-1, 1]:
				em(M_BOX, x + sgn * w * 0.36 * cos(rot), y, z - sgn * w * 0.36 * sin(rot), 0.2, 1.0, 1.8, rot, Color(0.95, 0.95, 0.95))
		"parrilla":
			em(M_BOX, x, y, z, w * 0.9, 0.15, w * 0.9, 0.0, Color(0.7, 0.65, 0.55))
			em(M_BOX, x, y, z, 2.2, 1.3, 1.2, rot, Color(0.65, 0.32, 0.2))
			em(M_BOX, x, y + 1.3, z, 0.6, 1.6, 0.6, rot, Color(0.55, 0.28, 0.18))
			em(M_BOX, x + 1.0, y, z + 1.2, 1.6, 0.8, 0.8, 0.0, Color(0.5, 0.35, 0.2))
		"calesita":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.66, 0.58))
			em(M_CYL, x, y, z, 3.2, 0.4, 3.2, 0.0, Color(0.95, 0.9, 0.7))
			em(M_CYL, x, y + 0.4, z, 0.3, 2.2, 0.3, 0.0, Color(0.9, 0.85, 0.3))
			em(M_CONE, x, y + 2.6, z, 3.6, 1.6, 3.6, 0.0, col, 0, 0.5)
		"stadium":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, ground)
			em(M_CYL, x, y, z, w * 0.92, 5.5, w * 0.8, 0.0, col, 0.3)
			em(M_CYL, x, y + 5.5, z, w * 0.7, 0.2, w * 0.58, 0.0, Color(0.3, 0.65, 0.3))
			for k in 4:
				var a := k * PI * 0.5 + 0.785
				em(M_BOX, x + cos(a) * w * 0.45, y, z + sin(a) * w * 0.4, 0.4, 12.0, 0.4, 0.0, Color(0.7, 0.7, 0.72))
				em(M_BOX, x + cos(a) * w * 0.45, y + 12.0, z + sin(a) * w * 0.4, 2.0, 1.0, 0.4, a, Color(1, 1, 0.9), 0, 1.5)
		"wheel":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x - 1.5, y, z, 0.4, 8.0, 0.4, 0.3, Color(0.8, 0.8, 0.82))
			em(M_BOX, x + 1.5, y, z, 0.4, 8.0, 0.4, -0.3, Color(0.8, 0.8, 0.82))
			for k in 12:
				var a := k * TAU / 12.0
				em(M_BOX, x + cos(a) * 6.0, y + 8.0 + sin(a) * 6.0, z, 0.9, 0.9, 0.9, 0.0, [col, Color(0.95, 0.85, 0.2), Color(0.3, 0.6, 0.95)][k % 3], 0, 0.6)
		"cathedral":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.68, 0.62))
			em(M_BOX, x, y, z, w * 0.4, 7.0, w * 0.75, rot, col, 0.5)
			em(M_ROOF, x, y + 7.0, z, w * 0.4, 2.5, w * 0.75, rot, Color(0.4, 0.4, 0.45))
			for sgn in [-1, 1]:
				var tx: float = x + sgn * w * 0.18
				em(M_BOX, tx, y, z + w * 0.35, 2.0, 11.0, 2.0, 0.0, col)
				em(M_CONE, tx, y + 11.0, z + w * 0.35, 2.2, 4.0, 2.2, 0.0, Color(0.35, 0.4, 0.45))
		"lighthouse":
			em(M_CYL, x, y, z, 2.4, 0.5, 2.4, 0.0, Color(0.5, 0.5, 0.5))
			for k in 5:
				em(M_CYL, x, y + 0.5 + k * 2.2, z, 1.6 - k * 0.1, 2.2, 1.6 - k * 0.1, 0.0, Color(0.95, 0.95, 0.95) if k % 2 == 0 else Color(0.8, 0.15, 0.15))
			em(M_CYL, x, y + 11.5, z, 1.2, 1.2, 1.2, 0.0, Color(1, 0.95, 0.7), 0, 2.0)
		"clock":
			em(M_BOX, x, y, z, w * 0.9, 0.15, w * 0.9, 0.0, Color(0.7, 0.68, 0.6))
			em(M_BOX, x, y, z, 1.6, 9.0, 1.6, rot, col)
			em(M_BOX, x, y + 7.2, z, 1.75, 1.2, 1.75, rot, Color(0.95, 0.95, 0.9), 0, 0.8)
			em(M_CONE, x, y + 9.0, z, 2.0, 1.8, 2.0, 0.0, Color(0.3, 0.35, 0.3))
		"beach":
			em(M_BOX, x, y, z, w, 0.12, w, 0.0, Color(0.92, 0.85, 0.6))
			for k in 3:
				var ax := x + (hsh(i, k) - 0.5) * w * 0.7
				var az := z + (hsh(i, k + 4) - 0.5) * w * 0.7
				em(M_BOX, ax, y, az, 0.08, 1.6, 0.08, 0.0, Color(0.9, 0.9, 0.9))
				em(M_CONE, ax, y + 1.4, az, 1.8, 0.5, 1.8, 0.0, [Color(0.9, 0.3, 0.3), Color(0.2, 0.5, 0.9), Color(0.95, 0.8, 0.2)][k])
		"plant":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x - w * 0.12, y, z, w * 0.55, 5.0, w * 0.7, rot, col, 0.3)
			em(M_CYL, x + w * 0.28, y, z - w * 0.25, 1.3, 12.0, 1.3, 0.0, col.darkened(0.2))
			em(M_CYL, x + w * 0.28, y, z + w * 0.15, 1.3, 10.0, 1.3, 0.0, col.darkened(0.2))
		"solar":
			em(M_BOX, x, y, z, w * 0.98, 0.12, w * 0.98, 0.0, Color(0.45, 0.55, 0.35))
			for k in 4:
				em(M_BOX, x, y + 0.6, z - w * 0.36 + k * w * 0.24, w * 0.85, 0.12, w * 0.16, 0.0, col, 0, 0, 0.05)
		"windmill":
			em(M_CYL, x, y, z, 0.6, 11.0, 0.6, 0.0, col)
			em(M_BOX, x, y + 11.0, z + 0.4, 0.4, 7.0, 0.15, 0.0, col)
			em(M_BOX, x, y + 13.5, z + 0.4, 6.0, 0.4, 0.15, 0.7, col)
		"dam":
			em(M_BOX, x, y - 2.0, z, w, 6.0, w * 0.35, rot, col)
			em(M_BOX, x, y, z + w * 0.3, w * 0.5, 3.0, w * 0.3, rot, col.darkened(0.15), 0.4)
		"pump":
			em(M_BOX, x, y, z, w * 0.7, 2.2, w * 0.7, 0.0, col, 0.3)
			em(M_CYL, x + 1.0, y, z + 1.0, 0.7, 3.0, 0.7, 0.0, Color(0.6, 0.6, 0.65))
		"watertower":
			for k in 4:
				var a := k * PI * 0.5 + 0.785
				em(M_BOX, x + cos(a) * 1.0, y, z + sin(a) * 1.0, 0.2, 6.0, 0.2, 0.0, Color(0.5, 0.5, 0.52))
			em(M_SPH, x, y + 5.5, z, 3.2, 3.0, 3.2, 0.0, col)
		"landfill":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, Color(0.45, 0.4, 0.3))
			for k in 4:
				em(M_SPH, x + (hsh(i, k) - 0.5) * w * 0.6, y, z + (hsh(i, k + 3) - 0.5) * w * 0.6, 4.0, 1.8, 3.5, 0.0, Color(0.42, 0.36, 0.28))
		"metro":
			em(M_BOX, x, y, z, w * 0.9, 0.15, w * 0.9, 0.0, ground)
			em(M_BOX, x, y, z, 2.4, 1.6, 2.4, rot, Color(0.85, 0.85, 0.85), 0.5)
			em(M_BOX, x, y + 1.6, z, 1.0, 1.0, 0.2, rot, col, 0, 0, 0.6)
		"station":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x, y, z, w * 0.8, 4.0, w * 0.4, rot, col, 0.6)
			em(M_ROOF, x, y + 4.0, z, w * 0.85, 1.6, w * 0.45, rot, Color(0.4, 0.4, 0.42))
			em(M_BOX, x, y + 5.2, z, 1.0, 1.0, 0.3, rot, Color(0.95, 0.95, 0.9), 0, 0.6)
		"port":
			em(M_BOX, x, y, z, w, 0.4, w, 0.0, Color(0.5, 0.48, 0.45))
			em(M_BOX, x - w * 0.25, y, z, w * 0.35, 3.0, w * 0.6, 0.0, col)
			for k in 3:
				em(M_BOX, x + w * 0.2, y + 0.4 + k * 1.0, z - w * 0.2 + k * 0.2, 2.5, 1.0, 1.0, 0.0, [Color(0.8, 0.3, 0.2), Color(0.2, 0.4, 0.8), Color(0.2, 0.6, 0.3)][k])
			em(M_BOX, x + w * 0.35, y, z + w * 0.3, 0.5, 10.0, 0.5, 0.0, Color(0.95, 0.7, 0.1))
			em(M_BOX, x + w * 0.35 - 2.0, y + 10.0, z + w * 0.3, 5.0, 0.4, 0.4, 0.0, Color(0.95, 0.7, 0.1))
		"airport":
			em(M_BOX, x, y, z, w, 0.12, w, 0.0, Color(0.45, 0.5, 0.4))
			em(M_BOX, x, y, z + w * 0.15, w * 0.95, 0.16, w * 0.22, 0.0, Color(0.25, 0.25, 0.27))
			em(M_BOX, x, y, z + w * 0.15, w * 0.9, 0.17, 0.25, 0.0, Color(0.95, 0.95, 0.95))
			em(M_BOX, x - w * 0.15, y, z - w * 0.28, w * 0.5, 3.5, w * 0.25, 0.0, col, 1.0)
			em(M_CYL, x + w * 0.3, y, z - w * 0.3, 1.2, 9.0, 1.2, 0.0, Color(0.8, 0.8, 0.82))
			em(M_CYL, x + w * 0.3, y + 9.0, z - w * 0.3, 2.2, 1.6, 2.2, 0.0, Color(0.4, 0.55, 0.65), 0, 0.6)
		"pier":
			em(M_BOX, x, 0.2, z, w * 0.4, 0.3, w * 1.2, rot, col)
			em(M_BOX, x, 0.5, z, 1.4, 2.0, 1.4, rot, Color(0.8, 0.75, 0.6))
		"parking":
			em(M_BOX, x, y, z, w * 0.95, 0.16, w * 0.95, 0.0, col)
			for k in 4:
				em(M_BOX, x - 1.0 + (k % 2) * 2.0, y + 0.16, z - 0.8 + (k / 2) * 1.6, 1.5, 0.6, 0.75, 0.0, car_color(i + k))
		"mall":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, Color(0.3, 0.3, 0.32))
			em(M_BOX, x, y, z, w * 0.8, 6.0, w * 0.7, rot, col, 0.6)
			em(M_BOX, x, y + 6.0, z, w * 0.5, 0.8, 0.3, rot, Color(0.95, 0.3, 0.4), 0, 1.2)
		"gated":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, Color(0.4, 0.62, 0.32))
			for sgn in [-1, 1]:
				em(M_BOX, x + sgn * w * 0.48, y, z, 0.25, 1.4, w * 0.96, 0.0, Color(0.85, 0.82, 0.75))
				em(M_BOX, x, y, z + sgn * w * 0.48, w * 0.96, 1.4, 0.25, 0.0, Color(0.85, 0.82, 0.75))
			for k in 4:
				var hx := x + (k % 2 - 0.5) * w * 0.45
				var hz := z + (k / 2 - 0.5) * w * 0.45
				em(M_BOX, hx, y, hz, 2.6, 2.0, 2.2, 0.0, col, 0.6)
				em(M_ROOF, hx, y + 2.0, hz, 2.8, 1.0, 2.3, 0.0, Color(0.6, 0.3, 0.2))
			em(M_BOX, x + 1.5, y, z + 1.0, 2.0, 0.12, 1.2, 0.0, Color(0.3, 0.65, 0.9), 0, 0, 0.15)
		"farm":
			for k in 4:
				em(M_BOX, x, y, z - w * 0.36 + k * w * 0.24, w * 0.95, 0.2, w * 0.22, 0.0, [Color(0.75, 0.65, 0.3), Color(0.45, 0.6, 0.25)][k % 2])
			em(M_BOX, x + w * 0.3, y, z + w * 0.3, 2.4, 2.4, 2.0, 0.0, Color(0.7, 0.2, 0.15))
			em(M_ROOF, x + w * 0.3, y + 2.4, z + w * 0.3, 2.6, 1.2, 2.1, 0.0, Color(0.4, 0.35, 0.3))
		"w_tower":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.7, 0.72))
			em(M_CYL, x, y, z, 3.0, 30.0, 3.0, 0.0, col, 0.8)
			em(M_CYL, x, y + 30.0, z, 5.0, 3.0, 5.0, 0.0, Color(0.5, 0.6, 0.75), 1.2)
			em(M_CONE, x, y + 33.0, z, 1.2, 10.0, 1.2, 0.0, Color(0.85, 0.85, 0.9), 0, 0.8)
		"w_park":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, Color(0.3, 0.6, 0.28))
			em(M_CYL, x, y, z, w * 0.4, 0.2, w * 0.4, 0.0, Color(0.2, 0.45, 0.65), 0, 0, 0.1)
			for k in 14:
				var a := k * TAU / 14.0
				var ax := x + cos(a) * w * 0.38
				var az := z + sin(a) * w * 0.38
				em(M_BOX, ax, y, az, 0.3, 1.2, 0.3, 0.0, Color(0.35, 0.25, 0.15))
				em(M_SPH, ax, y + 1.0, az, 2.4, 2.4, 2.4, 0.0, tree_colors(3 if k % 3 == 0 else 1)[0])
			em(M_BOX, x, y, z, 1.0, 6.0, 1.0, 0.0, Color(0.95, 0.95, 0.95))
		"w_stadium":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, ground)
			em(M_CYL, x, y, z, w * 0.95, 9.0, w * 0.85, 0.0, col, 0.4)
			em(M_CYL, x, y + 9.0, z, w * 0.72, 0.2, w * 0.62, 0.0, Color(0.3, 0.65, 0.3))
			em(M_CYL, x, y + 9.0, z, w * 0.98, 0.6, w * 0.88, 0.0, Color(0.45, 0.65, 0.95))
		"w_palace":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, Color(0.75, 0.72, 0.65))
			em(M_BOX, x, y, z, w * 0.85, 8.0, w * 0.5, rot, col, 0.9)
			em(M_SPH, x, y + 8.0, z, 7.0, 8.0, 7.0, 0.0, Color(0.55, 0.7, 0.65))
			em(M_CONE, x, y + 15.0, z, 1.0, 4.0, 1.0, 0.0, Color(0.9, 0.8, 0.3))
			for sgn in [-1, 1]:
				em(M_BOX, x + sgn * w * 0.38, y, z, 3.0, 11.0, 3.0, 0.0, col)
		_:
			em(M_BOX, x, y, z, w * 0.8, 3.0, w * 0.8, 0.0, col)
func build_overlay() -> void:
	var mm := overlay_node.multimesh
	if view_mode == "":
		mm.instance_count = 0
		return
	begin_buf()
	for i in N * N:
		var c := overlay_color(i)
		if c.a <= 0.0:
			continue
		var p := cell_pos(i)
		em(M_BOX, p.x, maxf(p.y, 0.0) + 0.5, p.z, CELL * 0.96, 0.1, CELL * 0.96, 0.0, c)
	mm.instance_count = _counts[M_BOX]
	if _counts[M_BOX] > 0:
		mm.buffer = _bufs[M_BOX].slice(0, _counts[M_BOX] * 20)
func heat(v: float, a: float = 0.55) -> Color:
	v = clampf(v, 0.0, 1.0)
	if opts["colorblind"]:
		return Color(0.15 + v * 0.8, 0.45 + v * 0.1, 0.95 - v * 0.85, a)
	return Color(minf(1.0, v * 2.0), minf(1.0, (1.0 - v) * 2.0), 0.15, a)
func overlay_color(i: int) -> Color:
	var built := zone[i] > 0 or bld[i] > 0
	match view_mode:
		"power":
			if built:
				return Color(1, 0.9, 0.2, 0.55) if powered[i] else Color(0.9, 0.15, 0.1, 0.6)
			if wire[i] & W_POWER:
				return Color(1, 0.8, 0.2, 0.4)
		"water":
			if built:
				return Color(0.2, 0.6, 1.0, 0.55) if watered[i] else Color(0.9, 0.15, 0.1, 0.6)
			if wire[i] & W_PIPE:
				return Color(0.3, 0.7, 1.0, 0.5)
		"pollution":
			if pollution[i] > 0.05:
				return Color(0.45, 0.3, 0.1, clampf(pollution[i], 0.0, 0.8))
		"crime":
			if built and zone[i] > 0:
				return heat(crime[i])
		"land":
			if terr[i] != T_WATER:
				var v := landv[i]
				return Color(0.2, 0.4 + v * 0.6, 0.2, 0.45)
		"traffic":
			if road[i] > 0:
				return heat(tload[i] / road_cap(i), 0.75)
		"happy":
			if zone[i] == Z_R or zone[i] == Z_M:
				return heat(1.0 - happy[i])
		"fire":
			return Color(0.95, 0.3, 0.1, clampf(cov[CV_FIRE][i], 0.0, 1.0) * 0.6) if cov[CV_FIRE][i] > 0.02 else Color(0, 0, 0, 0)
		"police":
			return Color(0.2, 0.3, 0.95, clampf(cov[CV_POL][i], 0.0, 1.0) * 0.6) if cov[CV_POL][i] > 0.02 else Color(0, 0, 0, 0)
		"health":
			return Color(0.95, 0.95, 0.95, clampf(cov[CV_HEALTH][i], 0.0, 1.0) * 0.6) if cov[CV_HEALTH][i] > 0.02 else Color(0, 0, 0, 0)
		"edu":
			var e := maxf(cov[CV_EDU1][i], maxf(cov[CV_EDU2][i], cov[CV_EDU3][i]))
			return Color(0.95, 0.8, 0.2, clampf(e, 0.0, 1.0) * 0.6) if e > 0.02 else Color(0, 0, 0, 0)
		"transit":
			return Color(0.3, 0.8, 0.9, clampf(cov[CV_TRANSIT][i], 0.0, 1.0) * 0.6) if cov[CV_TRANSIT][i] > 0.02 else Color(0, 0, 0, 0)
		"garbage":
			if garbp[i] > 0.1:
				return Color(0.5, 0.35, 0.1, 0.7)
			if built and cov[CV_GARB][i] > 0.02:
				return Color(0.3, 0.7, 0.3, 0.35)
		"districts":
			var r := region_of(i)
			if not is_owned(i):
				return Color(0, 0, 0, 0.35)
			var dc: Color = [Color(0, 0, 0, 0), Color(0.9, 0.5, 0.2, 0.35), Color(0.2, 0.8, 0.3, 0.35), Color(0.3, 0.5, 0.95, 0.35), Color(0.9, 0.2, 0.7, 0.35)][district[r]]
			if (cx(i) % REG == 0 or cz(i) % REG == 0):
				return Color(1, 1, 1, 0.6)
			return dc
	return Color(0, 0, 0, 0)
var sun_rot := Vector3(999, 0, 0)
func update_light() -> void:
	hour = fmod(6.0 + day_timer / DAY_SECONDS * 24.0, 24.0)
	var sunrise := 6.25
	var sunset := 20.0
	var up := 0.0
	if hour > sunrise and hour < sunset:
		up = sin((hour - sunrise) / (sunset - sunrise) * PI)
	var nf := 1.0 - clampf(up * 4.0, 0.0, 1.0)
	night = nf
	var az := lerpf(-70.0, 250.0, clampf((hour - sunrise) / (sunset - sunrise), 0.0, 1.0))
	var srot := Vector3(-maxf(up * 62.0, 4.0), az, 0.0)
	if srot.distance_to(sun_rot) > 0.8:
		sun_rot = srot
		sun.rotation_degrees = srot
	# dirección real del sol para el cielo (de noche baja del horizonte)
	var elev := up * 62.0
	if hour <= sunrise or hour >= sunset:
		var nh := fmod(hour - sunset + 24.0, 24.0) / (24.0 - (sunset - sunrise))
		elev = -sin(nh * PI) * 25.0
	var sky_az := az if (hour > sunrise and hour < sunset) else lerpf(250.0, 290.0, fmod(hour - sunset + 24.0, 24.0) / (24.0 - (sunset - sunrise)))
	var sdir := Basis.from_euler(Vector3(deg_to_rad(-elev), deg_to_rad(sky_az), 0.0)).z
	sky_mat.set_shader_parameter("sun_dir", sdir)
	sky_mat.set_shader_parameter("moon_dir", moon.global_transform.basis.z)
	var se := sdir.y
	sun.light_color = sun_color_at(se)
	var cloudy := 0.0
	if weather == "Lluvia" or weather == "Tormenta" or weather == "Nieve":
		cloudy = 0.55
	elif weather == "Nublado":
		cloudy = 0.3
	var day_k := smoothstep(-0.02, 0.12, se)
	sun.light_energy = 1.6 * day_k * (1.0 - cloudy * 0.6)
	env.tonemap_exposure = lerpf(1.0, 1.35, nf)
	sun.visible = se > -0.02
	moon.light_energy = 0.28 * nf
	var hor := sky_horizon(se, cloudy)
	# la luz ambiente sigue al cielo real (no al factor de noche de las ventanas): cálida con el sol bajo
	var sky_day := smoothstep(-0.16, 0.10, se)
	var low_sun := 1.0 - smoothstep(0.0, 0.35, se)
	env.ambient_light_color = Color(0.62, 0.6, 0.56).lerp(hor, 0.35 + 0.35 * low_sun).lerp(Color(0.06, 0.07, 0.12), 1.0 - sky_day)
	env.ambient_light_energy = lerpf(0.45, 0.5, sky_day)
	env.ambient_light_sky_contribution = lerpf(0.55, 0.2, low_sun * sky_day)
	env.fog_light_color = hor
	env.fog_density = 0.0005 + cloudy * 0.0012 + (0.0005 if hour > 5.5 and hour < 8.0 else 0.0)
	city_mat.set_shader_parameter("night", nf)
	city_mat.set_shader_parameter("snow", 0.8 if weather == "Nieve" else 0.0)
	water_mat.set_shader_parameter("night", nf)
	city_mat.set_shader_parameter("wet", 1.0 if (weather == "Lluvia" or weather == "Tormenta") else 0.0)
	env.glow_intensity = lerpf(0.22, 0.9, nf)
# color del sol según la altura (seno de la elevación): blanco cálido arriba, dorado cerca del horizonte
func sun_color_at(se: float) -> Color:
	var t := clampf(se / 0.35, 0.0, 1.0)
	return Color(1.0, 0.5, 0.22).lerp(Color(1.0, 0.96, 0.9), t)
# color del horizonte (para la bruma), igual que en sky.gdshader
func sky_horizon(se: float, cloudy: float) -> Color:
	var day := smoothstep(-0.16, 0.10, se)
	var low := 1.0 - smoothstep(-0.05, 0.38, se)
	var c := Color(0.62, 0.75, 0.93).lerp(Color(0.95, 0.55, 0.35), low * 0.8)
	c = c.lerp(Color(0.6, 0.62, 0.65), cloudy)
	return Color(0.03, 0.045, 0.095).lerp(c, day)
const COL_WHITE := Color(0.93, 0.92, 0.88)
const COL_CREAM := Color(0.9, 0.83, 0.68)
const COL_BRICK := Color(0.68, 0.35, 0.26)
const COL_WOOD := Color(0.66, 0.43, 0.25)
const COL_CONC := Color(0.64, 0.64, 0.62)
const COL_BLACK := Color(0.13, 0.13, 0.14)
const COL_GLASS := Color(0.2, 0.25, 0.3)
const COL_STONE := Color(0.82, 0.76, 0.64)
func make_faces_mesh(faces: Array) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for f in faces:
		var hint: Vector3 = f[0]
		var pts: Array = f[1]
		var p0: Vector3 = pts[0]
		var p1: Vector3 = pts[1]
		var p2: Vector3 = pts[2]
		var n := (p1 - p0).cross(p2 - p0).normalized()
		if n.dot(hint) < 0.0:
			n = -n
		for k in range(1, pts.size() - 1):
			var b: Vector3 = pts[k]
			var c: Vector3 = pts[k + 1]
			if (b - p0).cross(c - p0).dot(n) > 0.0:
				var tmp := b
				b = c
				c = tmp
			st.set_normal(n)
			st.add_vertex(p0)
			st.set_normal(n)
			st.add_vertex(b)
			st.set_normal(n)
			st.add_vertex(c)
	return st.commit()
func make_gable_mesh() -> ArrayMesh:
	var t := 0.08
	var f: Array = []
	for sg in [-1.0, 1.0]:
		var s: float = sg
		f.append([Vector3(s, 0.5, 0), [Vector3(s * 0.5, 0, -0.5), Vector3(0, 1, -0.5), Vector3(0, 1, 0.5), Vector3(s * 0.5, 0, 0.5)]])
		f.append([Vector3(-s, -0.5, 0), [Vector3(s * 0.5, -t, -0.5), Vector3(0, 1 - t, -0.5), Vector3(0, 1 - t, 0.5), Vector3(s * 0.5, -t, 0.5)]])
		f.append([Vector3(s, 0, 0), [Vector3(s * 0.5, 0, -0.5), Vector3(s * 0.5, 0, 0.5), Vector3(s * 0.5, -t, 0.5), Vector3(s * 0.5, -t, -0.5)]])
		for zg in [-0.5, 0.5]:
			var zz: float = zg
			f.append([Vector3(0, 0, zz), [Vector3(s * 0.5, 0, zz), Vector3(0, 1, zz), Vector3(0, 1 - t, zz), Vector3(s * 0.5, -t, zz)]])
	return make_faces_mesh(f)
func make_hip_mesh() -> ArrayMesh:
	var r := 0.22
	var f: Array = []
	for sg in [-1.0, 1.0]:
		var s: float = sg
		f.append([Vector3(s, 0.6, 0), [Vector3(s * 0.5, 0, -0.5), Vector3(s * 0.5, 0, 0.5), Vector3(0, 1, r), Vector3(0, 1, -r)]])
		f.append([Vector3(0, 0.6, s), [Vector3(-0.5, 0, s * 0.5), Vector3(0.5, 0, s * 0.5), Vector3(0, 1, s * r)]])
	f.append([Vector3(0, -1, 0), [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(0.5, 0, 0.5), Vector3(-0.5, 0, 0.5)]])
	return make_faces_mesh(f)
func lp(x: float, z: float, rot: float, a: float, b: float) -> Vector2:
	var c := cos(rot)
	var s := sin(rot)
	return Vector2(x + a * c + b * s, z - a * s + b * c)
func bx(x: float, y: float, z: float, rot: float, a: float, b: float, yb: float, sx: float, sy: float, sz: float, col: Color, c0: float = 0.0, c1: float = 0.0, c2: float = 0.0, c3: float = 0.0) -> void:
	var q := lp(x, z, rot, a, b)
	em(M_BOX, q.x, y + yb, q.y, sx, sy, sz, rot, col, c0, c1, c2, c3)
func gable(x: float, y: float, z: float, rot: float, a: float, b: float, lx: float, lz: float, h: float, wallc: Color, roofc: Color, along_x: bool, rm: float = -4.0, wm: float = 0.0) -> void:
	var q := lp(x, z, rot, a, b)
	var r := rot + (PI * 0.5 if along_x else 0.0)
	var wx := lz if along_x else lx
	var wz := lx if along_x else lz
	em(M_ROOF, q.x, y, q.y, wx * 0.98, h, wz * 0.98, r, wallc, 0, 0, 0, wm)
	em(M_GABLE, q.x, y + 0.02, q.y, wx * 1.16, h * 1.12, wz * 1.08, r, roofc, 0, 0, 0, rm)
func hip(x: float, y: float, z: float, rot: float, a: float, b: float, lx: float, lz: float, h: float, roofc: Color) -> void:
	var q := lp(x, z, rot, a, b)
	if lx > lz:
		em(M_HIP, q.x, y, q.y, lz, h, lx, rot + PI * 0.5, roofc, 0, 0, 0, -4.0)
	else:
		em(M_HIP, q.x, y, q.y, lx, h, lz, rot, roofc, 0, 0, 0, -4.0)
func bush(x: float, y: float, z: float, r: float, i: int, k: int) -> void:
	var g := Color(0.2, 0.42, 0.18).lerp(Color(0.32, 0.5, 0.2), hsh(i, k))
	em(M_SPH, x, y, z, r, r * 0.8, r, 0.0, g, 0, 0, 0, 2.04)
func pine(x: float, y: float, z: float, h: float, i: int) -> void:
	em(M_BOX, x, y, z, 0.12, h * 0.25, 0.12, 0.0, Color(0.35, 0.24, 0.16))
	em(M_CONE, x, y + h * 0.2, z, h * 0.38, h * 0.8, h * 0.38, 0.0, Color(0.16, 0.34, 0.2).lerp(Color(0.25, 0.42, 0.2), hsh(i, 9)), 0, 0, 0, 2.03)
func parked_car(x: float, y: float, z: float, rot: float, a: float, b: float, i: int) -> void:
	var q := lp(x, z, rot, a, b)
	var cc: Color = [Color(0.92, 0.92, 0.93), Color(0.1, 0.1, 0.12), Color(0.55, 0.57, 0.6), Color(0.6, 0.1, 0.1)][int(hsh(i, 31) * 4.0) % 4]
	em(M_BOX, q.x, y + 0.15, q.y, 0.9, 0.42, 1.95, rot, cc, 0, 0, 0, 1.5)
	em(M_SPH, q.x, y + 0.5, q.y, 0.8, 0.42, 1.05, rot, Color(0.07, 0.09, 0.12), 0, 0, 0, 1.5)
func garden(i: int, x: float, y: float, z: float, rot: float, s: float) -> void:
	var q := lp(x, z, rot, -0.42 * s, 0.38 * s)
	bush(q.x, y, q.y, 0.6 + hsh(i, 3) * 0.3, i, 3)
	q = lp(x, z, rot, 0.42 * s, -0.4 * s)
	if hsh(i, 4) < 0.5:
		pine(q.x, y, q.y, 2.2 + hsh(i, 5) * 1.2, i)
	else:
		bush(q.x, y, q.y, 0.7, i, 6)
func emit_house(i: int, x: float, y: float, z: float, s: float, v: int, rot: float, wall: Color) -> void:
	var hd: bool = opts["quality"] >= 1
	var tile: Color = [Color(0.62, 0.27, 0.18), Color(0.45, 0.25, 0.18), Color(0.28, 0.22, 0.2), Color(0.72, 0.36, 0.2)][int(hsh(i, 11) * 4.0) % 4]
	var white := tint(COL_WHITE if hsh(i, 12) < 0.6 else COL_CREAM, i)
	var k := (v + int(hsh(i, 13) * 8.0)) % 8
	match k:
		0:
			bx(x, y, z, rot, -0.12 * s, -0.08 * s, 0, 0.62 * s, 3.4, 0.5 * s, white, 0.6)
			gable(x, y + 3.4, z, rot, -0.12 * s, -0.08 * s, 0.62 * s, 0.5 * s, 1.5, white, tile, true)
			bx(x, y, z, rot, 0.2 * s, 0.1 * s, 0, 0.34 * s, 3.4, 0.5 * s, white, 0.6)
			gable(x, y + 3.4, z, rot, 0.2 * s, 0.1 * s, 0.34 * s, 0.5 * s, 1.7, white, tile, false)
			bx(x, y, z, rot, 0.2 * s, 0.35 * s, 0, 0.32, 0.95, 0.05, Color(0.3, 0.2, 0.14), 0, 0, 0, -2)
			bx(x, y, z, rot, -0.14 * s, 0.24 * s, 1.75, 0.46 * s, 0.1, 0.2 * s, tile, 0, 0, 0, -4)
			if hd:
				for pa in [-0.34, -0.14, 0.06]:
					var pf: float = pa
					bx(x, y, z, rot, pf * s, 0.32 * s, 0, 0.1, 1.75, 0.1, Color(0.4, 0.26, 0.18))
				bx(x, y, z, rot, -0.14 * s, 0.33 * s, 0, 0.42 * s, 0.45, 0.05, COL_WHITE)
				bx(x, y, z, rot, 0.2 * s, 0.42 * s, 0, 0.6, 0.14, 0.25, COL_CONC)
			bx(x, y, z, rot, -0.34 * s, -0.12 * s, 3.4, 0.32, 2.3, 0.32, COL_BRICK, 0, 0, 0, -1)
		1:
			bx(x, y, z, rot, 0, -0.06 * s, 0, 0.7 * s, 2.2, 0.48 * s, white, 0.55)
			gable(x, y + 2.2, z, rot, 0, -0.06 * s, 0.7 * s, 0.48 * s, 1.6, white, tile, true)
			bx(x, y, z, rot, 0.17 * s, 0.22 * s, 0, 0.22 * s, 1.9, 0.1 * s, white)
			gable(x, y + 1.9, z, rot, 0.17 * s, 0.22 * s, 0.22 * s, 0.12 * s, 0.6, white, tile, false)
			bx(x, y, z, rot, 0.17 * s, 0.275 * s, 0, 0.3, 0.9, 0.04, Color(0.55, 0.3, 0.16), 0, 0, 0, -2)
			bx(x, y, z, rot, -0.2 * s, 0.24 * s, 1.6, 0.3 * s, 0.08, 0.16 * s, tile, 0, 0, 0, -4)
			if hd:
				bx(x, y, z, rot, -0.33 * s, 0.31 * s, 0, 0.08, 1.6, 0.08, COL_WHITE)
				bx(x, y, z, rot, -0.07 * s, 0.31 * s, 0, 0.08, 1.6, 0.08, COL_WHITE)
				bx(x, y, z, rot, -0.2 * s, 0.32 * s, 0, 0.3 * s, 0.42, 0.04, COL_WHITE)
				bx(x, y, z, rot, 0.27 * s, 0.28 * s, 1.25, 0.1, 0.16, 0.08, Color(1.0, 0.82, 0.5), 0, 1.0)
			bx(x, y, z, rot, 0.22 * s, -0.12 * s, 2.2, 0.3, 2.0, 0.3, COL_BRICK, 0, 0, 0, -1)
		2:
			bx(x, y, z, rot, 0, 0, 0, 0.78 * s, 2.2, 0.6 * s, white, 0.55)
			hip(x, y + 2.2, z, rot, 0, 0, 0.9 * s, 0.72 * s, 0.85, tile)
			bx(x, y, z, rot, 0.1 * s, -0.08 * s, 2.2, 0.48 * s, 2.1, 0.4 * s, white, 0.55)
			hip(x, y + 4.3, z, rot, 0.1 * s, -0.08 * s, 0.6 * s, 0.52 * s, 1.2, tile)
			bx(x, y, z, rot, -0.15 * s, 0.301 * s, 0, 0.3, 0.95, 0.04, Color(0.5, 0.3, 0.17), 0, 0, 0, -2)
			if hd:
				bx(x, y, z, rot, -0.15 * s, 0.4 * s, 0, 0.9, 0.06, 0.6, COL_CONC)
		3:
			bx(x, y, z, rot, -0.12 * s, -0.08 * s, 0, 0.52 * s, 2.4, 0.5 * s, COL_CONC, 0, 0, 0, -3)
			bx(x, y, z, rot, -0.12 * s, 0.171 * s, 0.15, 0.46 * s, 2.0, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.24 * s, -0.08 * s, 0, 0.3 * s, 2.4, 0.5 * s, white)
			bx(x, y, z, rot, 0.24 * s, 0.171 * s, 0, 0.26 * s, 1.9, 0.03, COL_WOOD, 0, 0, 0, -2)
			bx(x, y, z, rot, 0.04 * s, 0.02 * s, 2.4, 0.84 * s, 2.2, 0.62 * s, white)
			bx(x, y, z, rot, -0.12 * s, 0.331 * s, 2.6, 0.44 * s, 1.75, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.27 * s, 0.332 * s, 2.5, 0.26 * s, 2.0, 0.04, COL_WOOD, 0, 0, 0, -2)
			bx(x, y, z, rot, 0.04 * s, 0.02 * s, 4.6, 0.86 * s, 0.14, 0.64 * s, white.darkened(0.06))
			if hd:
				bx(x, y, z, rot, 0.24 * s, 0.4 * s, 0, 0.28 * s, 0.04, 0.16 * s, Color(0.78, 0.77, 0.74))
				parked_car(x, y, z, rot, 0.24 * s, 0.44 * s, i)
		4:
			bx(x, y, z, rot, 0.08 * s, -0.02 * s, 0, 0.62 * s, 2.3, 0.56 * s, tint(COL_BRICK, i), 0.4, 0, 0, -1)
			bx(x, y, z, rot, 0.08 * s, -0.06 * s, 2.3, 0.56 * s, 2.0, 0.44 * s, COL_BLACK, 0, 0, 0, -5)
			bx(x, y, z, rot, 0.08 * s, 0.161 * s, 2.45, 0.5 * s, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.08 * s, -0.04 * s, 4.3, 0.74 * s, 0.16, 0.6 * s, Color(0.1, 0.1, 0.11))
			bx(x, y, z, rot, -0.38 * s, 0.14 * s, 2.0, 0.26 * s, 0.08, 0.5 * s, Color(0.1, 0.1, 0.11))
			if hd:
				bx(x, y, z, rot, -0.48 * s, 0.37 * s, 0, 0.08, 2.0, 0.08, Color(0.1, 0.1, 0.11))
				bx(x, y, z, rot, -0.48 * s, -0.08 * s, 0, 0.08, 2.0, 0.08, Color(0.1, 0.1, 0.11))
				parked_car(x, y, z, rot, -0.37 * s, 0.14 * s, i)
				for la in [-0.1, 0.12, 0.32]:
					var lf: float = la
					bx(x, y, z, rot, lf * s, 0.272 * s, 0, 0.12, 0.08, 0.06, Color(1.0, 0.8, 0.5), 0, 1.0)
		5:
			bx(x, y, z, rot, 0.05 * s, 0, 0, 0.7 * s, 2.3, 0.56 * s, white)
			bx(x, y, z, rot, 0.05 * s, 0.281 * s, 0.1, 0.4 * s, 1.9, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, -0.34 * s, -0.04 * s, 0, 0.22 * s, 5.4, 0.36 * s, Color(0.27, 0.24, 0.23), 0, 0, 0, -1)
			bx(x, y, z, rot, 0.12 * s, -0.02 * s, 2.3, 0.44 * s, 1.5, 0.52 * s, COL_BLACK, 0, 0, 0, -5)
			gable(x, y + 3.8, z, rot, 0.12 * s, -0.02 * s, 0.44 * s, 0.52 * s, 1.8, COL_BLACK, COL_BLACK, false, -5.0, -5.0)
			var q := lp(x, z, rot, 0.12 * s, 0.245 * s)
			em(M_BOX, q.x, y + 2.45, q.y, 0.36 * s, 1.3, 0.04, rot, COL_GLASS, 0, 0, 0, -8)
			em(M_ROOF, q.x, y + 3.8, q.y, 0.36 * s, 1.55, 0.04, rot, COL_GLASS, 0, 0, 0, -8)
			if hd:
				bx(x, y, z, rot, -0.05 * s, 0.4 * s, 0, 0.6 * s, 0.1, 0.2 * s, Color(0.55, 0.38, 0.24), 0, 0, 0, -2)
		6:
			bx(x, y, z, rot, -0.08 * s, -0.12 * s, 0, 0.66 * s, 2.4, 0.44 * s, COL_STONE, 0, 0, 0, -7)
			bx(x, y, z, rot, -0.08 * s, 0.101 * s, 0.1, 0.5 * s, 2.0, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.02 * s, -0.06 * s, 2.4, 0.7 * s, 2.0, 0.5 * s, white)
			bx(x, y, z, rot, -0.24 * s, -0.06 * s, 2.4, 0.22 * s, 2.0, 0.52 * s, COL_WOOD, 0, 0, 0, -2)
			bx(x, y, z, rot, 0.1 * s, 0.191 * s, 2.55, 0.42 * s, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.02 * s, 0.0, 4.4, 0.78 * s, 0.25, 0.62 * s, white)
			bx(x, y, z, rot, 0.24 * s, 0.33 * s, 0, 0.42 * s, 0.1, 0.24 * s, Color(0.72, 0.58, 0.42), 0, 0, 0, -2)
			bx(x, y, z, rot, 0.24 * s, 0.33 * s, 0, 0.34 * s, 0.14, 0.17 * s, Color(0.22, 0.72, 0.8), 0, 0, 0.25)
		_:
			bx(x, y, z, rot, 0, -0.06 * s, 0, 0.86 * s, 2.2, 0.46 * s, white, 0.5)
			hip(x, y + 2.2, z, rot, 0, -0.06 * s, 0.98 * s, 0.6 * s, 1.1, tile)
			bx(x, y, z, rot, -0.2 * s, 0.181 * s, 0.05, 0.22 * s, 1.8, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.22 * s, 0.24 * s, 1.75, 0.24 * s, 0.06, 0.14 * s, COL_WHITE)
			if hd:
				for la in [-0.36, -0.02, 0.36]:
					var lf: float = la
					bx(x, y, z, rot, lf * s, 0.18 * s, 1.5, 0.1, 0.16, 0.08, Color(1.0, 0.8, 0.5), 0, 1.0)
	if hd:
		garden(i, x, y, z, rot, s)
func emit_res(i: int, x: float, y: float, z: float, w: float, l: int, v: int, rot: float, wall: Color, big: bool) -> void:
	var gc := tower_col(v, i)
	var hd: bool = opts["quality"] >= 1
	var vk := (v + int(hsh(i, 21) * 4.0)) % 4
	match l:
		1:
			emit_house(i, x, y, z, w, v, rot, wall)
		2, 3:
			var h := (4.5 + (v % 3)) if l == 2 else (8.0 + (v % 4) * 1.3)
			if vk == 0:
				var bc := tint(COL_BRICK, i)
				bx(x, y, z, rot, 0, 0, 0, w * 0.84, h, w * 0.84, bc, 1.0, 0, 0, -1)
				bx(x, y, z, rot, 0, 0, 0, w * 0.86, 1.1, w * 0.86, Color(0.15, 0.19, 0.23), 0, 0.55)
				var k := 2.5
				while k < h - 0.3:
					bx(x, y, z, rot, 0, 0, k, w * 0.86, 0.16, w * 0.86, COL_WHITE)
					k += 2.5
				bx(x, y, z, rot, 0, 0, h, w * 0.9, 0.3, w * 0.9, COL_WHITE)
				if l == 3 or v % 2 == 0:
					var q := lp(x, z, rot, w * 0.2, -w * 0.15)
					if hd:
						for lg in 4:
							em(M_BOX, q.x + (0.5 if lg % 2 == 0 else -0.5), y + h, q.y + (0.5 if lg < 2 else -0.5), 0.1, 1.2, 0.1, 0.0, Color(0.25, 0.22, 0.2))
					em(M_CYL, q.x, y + h + 1.2, q.y, 1.5, 1.4, 1.5, 0.0, Color(0.48, 0.36, 0.26), 0, 0, 0, -2)
					em(M_CONE, q.x, y + h + 2.6, q.y, 1.6, 0.6, 1.6, 0.0, Color(0.25, 0.22, 0.2))
			elif vk == 1:
				bx(x, y, z, rot, 0, 0, 0, w * 0.76, h, w * 0.76, COL_BLACK, 1.0, 0, 0, -5)
				var k := 0.0
				while k < h + 0.1:
					bx(x, y, z, rot, 0, 0.02 * w, k, w * 0.94, 0.26, w * 0.9, COL_WHITE.darkened(0.04), 0, 0, 0, -3)
					if hd and k > 0.1:
						bx(x, y, z, rot, 0, 0.44 * w, k + 0.26, w * 0.9, 0.22, 0.25, Color(0.3, 0.48, 0.22), 0, 0, 0, 2.02)
					k += 2.5
				if hd:
					for pk in 5:
						bx(x, y, z, rot, (pk - 2) * w * 0.15, -w * 0.1, h + 1.6, 0.1, 0.1, w * 0.5, COL_BLACK)
					bx(x, y, z, rot, -w * 0.3, -w * 0.1, h, 0.12, 1.6, 0.12, COL_BLACK)
					bx(x, y, z, rot, w * 0.3, -w * 0.1, h, 0.12, 1.6, 0.12, COL_BLACK)
			elif vk == 2:
				bx(x, y, z, rot, 0, 0, 0, w * 0.86, 1.8, w * 0.86, COL_STONE, 0, 0, 0, -7)
				bx(x, y, z, rot, 0.12 * w, 0.431 * w, 0.05, w * 0.5, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
				bx(x, y, z, rot, 0, 0, 1.8, w * 0.84, h - 1.8, w * 0.84, tint(Color(0.74, 0.4, 0.24), i), 0, 0, 0, -6)
				bx(x, y, z, rot, 0, 0, h, w * 0.87, 0.25, w * 0.87, COL_STONE)
			else:
				bx(x, y, z, rot, 0, 0, 0, w * 0.82, h, w * 0.82, wall, 1.0)
				bx(x, y, z, rot, 0, 0, 0, w * 0.84, 1.1, w * 0.84, Color(0.15, 0.19, 0.23), 0, 0.55)
				var k := 2.6
				while k < h - 0.5:
					bx(x, y, z, rot, 0, 0, k, w * 0.86, 0.12, w * 0.86, wall.darkened(0.15))
					bx(x, y, z, rot, 0, w * 0.45, k + 0.12, w * 0.5, 0.28, 0.5, wall.lightened(0.1))
					k += 2.5
				bx(x, y, z, rot, 0, 0, h, w * 0.88, 0.25, w * 0.88, wall.darkened(0.2))
				if hd:
					bx(x, y, z, rot, -w * 0.2, w * 0.18, h + 0.25, 0.9, 0.35, 0.5, Color(0.3, 0.55, 0.28), 0, 0, 0, 2.02)
					bx(x, y, z, rot, w * 0.15, -w * 0.1, h + 0.25, 0.8, 0.5, 0.8, Color(0.55, 0.57, 0.6))
		4:
			var kind := v % 4
			if kind == 0:
				var h := 16.0 + (v % 5) * 2.0
				em(M_BOX, x, y, z, w * 0.75, h, w * 0.75, rot, wall, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h, z, w * 0.5, 2.0, w * 0.5, rot, wall.darkened(0.1), 0.8, 0, 0, -7)
				em(M_BOX, x, y, z, w * 0.78, 1.4, w * 0.78, rot, Color(0.14, 0.18, 0.22), 0, 0.55)
				em(M_BOX, x, y + h - 0.3, z, w * 0.8, 0.4, w * 0.8, rot, wall.lightened(0.12))
				em(M_CYL, x, y + h + 2.0, z, 1.2, 1.5, 1.2, 0.0, Color(0.4, 0.4, 0.42))
			elif kind == 1:
				var h := 22.0 + (v % 3) * 3.0
				var sc := tint(Color(0.8, 0.7, 0.54), i)
				em(M_BOX, x, y, z, w * 0.8, h * 0.5, w * 0.8, rot, sc, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h * 0.5, z, w * 0.84, 0.35, w * 0.84, rot, sc.lightened(0.15))
				em(M_BOX, x, y + h * 0.5, z, w * 0.62, h * 0.3, w * 0.62, rot, sc, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h * 0.8, z, w * 0.66, 0.3, w * 0.66, rot, sc.lightened(0.15))
				em(M_BOX, x, y + h * 0.8, z, w * 0.44, h * 0.2, w * 0.44, rot, sc, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h, z, w * 0.3, 1.4, w * 0.3, rot, Color(1.0, 0.85, 0.6), 0, 0.7)
				em(M_CONE, x, y + h + 1.4, z, w * 0.2, h * 0.22, w * 0.2, rot, Color(0.75, 0.75, 0.78), 0, 0, 0, 1.5)
			elif kind == 2:
				var h := 22.0 + (v % 3) * 2.5
				em(M_CYL, x, y, z, w * 0.7, h, w * 0.7, 0.0, gc, 1.3)
				em(M_CYL, x, y + h, z, w * 0.74, 0.4, w * 0.74, 0.0, Color(0.8, 0.82, 0.85))
			else:
				var h := 18.0
				bx(x, y, z, rot, -w * 0.22, 0, 0, w * 0.36, h, w * 0.5, gc, 1.3)
				bx(x, y, z, rot, w * 0.22, 0, 0, w * 0.36, h + 3.0, w * 0.5, gc, 1.3)
				em(M_BOX, x, y + h * 0.6, z, w * 0.2, 1.2, w * 0.3, rot, Color(0.5, 0.6, 0.7), 1.3)
func emit_com(i: int, x: float, y: float, z: float, w: float, l: int, v: int, rot: float, dark: bool, big: bool) -> void:
	var wallc: Color = tint([Color(0.85, 0.85, 0.9), Color(0.9, 0.8, 0.7), Color(0.7, 0.75, 0.85), Color(0.95, 0.9, 0.85)][v % 4], i)
	var gcm := tower_col(v + 2, i)
	if dark:
		wallc = wallc.darkened(0.6)
	var awn: Color = [Color(0.8, 0.2, 0.2), Color(0.2, 0.5, 0.8), Color(0.2, 0.6, 0.3), Color(0.9, 0.6, 0.1)][v % 4]
	var fx := sin(rot) * w * 0.45
	var fz := cos(rot) * w * 0.45
	match l:
		1:
			em(M_BOX, x, y, z, w * 0.85, 2.4, w * 0.85, rot, wallc, 0.7, 0, 0, -1.0 if v % 3 == 0 else 0.0)
			bx(x, y, z, rot, 0, w * 0.426, 0.1, w * 0.7, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			em(M_BOX, x + fx, y + 1.9, z + fz, w * 0.85, 0.12, 0.9, rot, awn)
			if v % 2 == 0:
				for k in 2:
					em(M_CYL, x + fx * 1.25 + (k - 0.5) * 1.2 * cos(rot), y, z + fz * 1.25 - (k - 0.5) * 1.2 * sin(rot), 0.5, 0.6, 0.5, 0.0, Color(0.9, 0.9, 0.9))
		2:
			var bm := -1.0 if v % 2 == 0 else -7.0
			em(M_BOX, x, y, z, w * 0.88, 5.0, w * 0.88, rot, tint(COL_BRICK, i) if v % 2 == 0 else wallc, 1.0, 0, 0, bm)
			bx(x, y, z, rot, 0, w * 0.441, 0.05, w * 0.8, 1.8, 0.03, COL_GLASS, 0, 0, 0, -8)
			em(M_BOX, x + fx, y + 2.0, z + fz, w * 0.88, 0.12, 1.0, rot, awn)
			em(M_BOX, x, y + 5.0, z, w * 0.92, 0.3, w * 0.92, rot, COL_WHITE)
			em(M_BOX, x, y + 5.3, z, w * 0.6, 0.8, w * 0.2, rot, awn, 0, 0.6)
		3:
			var h := 12.0 + (v % 3) * 2.0
			em(M_BOX, x, y, z, w * 0.88, 3.0, w * 0.88, rot, COL_STONE, 0, 0, 0, -7)
			bx(x, y, z, rot, 0, w * 0.441, 0.1, w * 0.78, 2.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			em(M_BOX, x, y + 3.0, z, w * 0.82, h - 3.0, w * 0.82, rot, gcm, 1.4)
			em(M_BOX, x, y + h, z, w * 0.6, 1.0, w * 0.6, rot, Color(0.4, 0.4, 0.45))
		4:
			var h := 28.0 + (v % 4) * 4.0
			if big:
				h += 10.0
			em(M_BOX, x, y, z, w * 0.88, 4.0, w * 0.88, rot, COL_STONE, 0.8, 0, 0, -7)
			em(M_BOX, x, y + 4.0, z, w * 0.75, h * 0.72 - 4.0, w * 0.75, rot, gcm.darkened(0.15), 1.5)
			em(M_BOX, x, y + h * 0.72, z, w * 0.79, 0.4, w * 0.79, rot, Color(0.75, 0.77, 0.8))
			em(M_BOX, x, y + h * 0.72, z, w * 0.58, h * 0.28, w * 0.58, rot, gcm.darkened(0.1), 1.5)
			if v % 2 == 0:
				em(M_BOX, x, y + h, z, w * 0.4, 2.5, w * 0.4, rot, Color(0.8, 0.82, 0.85), 0, 0.5)
				em(M_CONE, x, y + h + 2.5, z, w * 0.3, 6.0, w * 0.3, rot, Color(0.78, 0.8, 0.84), 0, 0, 0, 1.5)
				em(M_BOX, x, y + h + 8.0, z, 0.2, 4.0, 0.2, 0.0, Color(0.9, 0.2, 0.2), 0, 0, 1.0)
			else:
				em(M_BOX, x, y + h, z, w * 0.5, 3.0, w * 0.5, rot, Color(0.35, 0.45, 0.55), 1.2)
				em(M_BOX, x, y + h + 3.0, z, 0.25, 5.0, 0.25, 0.0, Color(0.9, 0.2, 0.2), 0, 0, 1.0)
func clear_preview() -> void:
	preview_node.multimesh.instance_count = 0
	set_cost_hint("")
func show_preview() -> void:
	begin_buf()
	var cost := 0.0
	var cells: Array = []
	if tool["k"] == "def":
		var d: Dictionary = DEF[tool["id"]]
		cells = def_cells(drag_a, d["sz"])
		var ok := can_place_def(drag_a, tool["id"]) == ""
		for c in cells:
			var p := cell_pos(c)
			em(M_BOX, p.x, maxf(p.y, 0.0) + 0.2, p.z, CELL * 0.95, 0.6, CELL * 0.95, 0.0, Color(0.2, 0.9, 0.3, 0.45) if ok else Color(0.95, 0.2, 0.15, 0.45))
		cost = d["cost"]
	else:
		cells = drag_cells()
		for c in cells:
			var cc := cell_cost(c)
			var p := cell_pos(c)
			em(M_BOX, p.x, maxf(p.y, 0.0) + 0.3, p.z, CELL * 0.95, 0.4, CELL * 0.95, 0.0, Color(0.2, 0.9, 0.3, 0.45) if cc >= 0.0 else Color(0.95, 0.2, 0.15, 0.4))
			if cc > 0.0:
				cost += cc
	var mm := preview_node.multimesh
	mm.instance_count = _counts[M_BOX]
	if _counts[M_BOX] > 0:
		mm.buffer = _bufs[M_BOX].slice(0, _counts[M_BOX] * 20)
	set_cost_hint(("Costo: " + fmt_money(cost)) if cost > 0 else "")
func flush_mm(mm: MultiMesh, count: int, buf: PackedFloat32Array) -> void:
	if count > mm.instance_count:
		var cap := 256
		while cap < count * 3 / 2:
			cap *= 2
		mm.instance_count = cap
	if count > 0:
		var pb := buf.slice(0, count * 20)
		pb.resize(mm.instance_count * 20)
		mm.buffer = pb
	mm.visible_instance_count = count
