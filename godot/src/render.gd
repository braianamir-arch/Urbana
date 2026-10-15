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
var terrain_simple_mat: ShaderMaterial
var terrain_tex_loaded: bool = false
var terrain_hsub := PackedFloat32Array()
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
const SHADER_BUILDING := preload("res://shaders/building.gdshader")
const SHADER_BUILDING_LITE := preload("res://shaders/building_lite.gdshader")
const SHADER_WATER := preload("res://shaders/water.gdshader")
const SHADER_TERRAIN := preload("res://shaders/terrain_simple.gdshader")
const SHADER_TERRAIN_TEX := preload("res://shaders/terrain.gdshader")
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
	cat_register()
	building_mat = ShaderMaterial.new()
	building_mat.shader = SHADER_BUILDING
	building_lite_mat = ShaderMaterial.new()
	building_lite_mat.shader = SHADER_BUILDING_LITE
	water_mat = ShaderMaterial.new()
	var sw := Shader.new()
	sw.code = SHADER_WATER.code
	water_mat.shader = sw
	water_mat.set_shader_parameter("nrm_tex", load("res://assets/water/water_nrm.webp"))
	water_mat.set_shader_parameter("foam_tex", load("res://assets/water/foam.webp"))
	overlay_mat = ShaderMaterial.new()
	var so := Shader.new()
	so.code = SHADER_OVERLAY.code
	overlay_mat.shader = so
	dtex = make_noise_tex(0.045, 11, 4)
	ctex = make_noise_tex(0.02, 29, 5)
	terrain_simple_mat = ShaderMaterial.new()
	var st2 := Shader.new()
	st2.code = SHADER_TERRAIN.code
	terrain_simple_mat.shader = st2
	terrain_mat = ShaderMaterial.new()
	terrain_mat.shader = SHADER_TERRAIN_TEX
	for m in [city_mat, terrain_mat, terrain_simple_mat]:
		m.set_shader_parameter("dtex", dtex)
		m.set_shader_parameter("ctex", ctex)
	bmat_param("ctex", ctex)
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
	wp.size = Vector2(N * CELL * 10.0, N * CELL * 10.0)
	wp.subdivide_width = 90
	wp.subdivide_depth = 90
	water_node.mesh = wp
	water_node.material_override = water_mat
	water_node.position = Vector3(0, WATER_Y, 0)
	add_child(water_node)
	overlay_node = new_mm_node(meshes[M_BOX], overlay_mat)
	preview_node = new_mm_node(meshes[M_BOX], overlay_mat)
	chunk_nodes.clear()
	bnodes.clear()
	for c in NCH * NCH:
		bnodes.append({})
	bnear_ok.resize(NCH * NCH)
	bnear_ok.fill(0)
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
	# calidad Baja usa solo la versión lejana de los edificios: hay que rehacer los bloques
	if bq_last >= 0 and (bq_last == 0) != (q == 0):
		mark_all_dirty()
	bq_last = q
	RenderingServer.directional_shadow_atlas_set_size(2048 if q < 2 else 4096, true)
	if sun:
		sun.shadow_enabled = q >= 1 and opts["g_shadow"]
	if env:
		env.fog_enabled = opts["g_fog"]
	if water_node:
		# calidad Baja: agua simple; Media: una capa de olas y sin anillos de lluvia; Alta: todo
		if opts["g_water"] and q >= 1:
			water_mat.set_shader_parameter("layers", 2.0 if q >= 2 else 1.0)
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
	bmat_param("ao_on", 1.0 if opts["g_ao"] else 0.0)
	bmat_param("wind", 1.0 if opts["g_wind"] else 0.0)
	set_city_tex(use_tex_terrain())
	var dt: float = 1.0 if opts["g_detail"] else 0.0
	city_mat.set_shader_parameter("det", dt)
	terrain_simple_mat.set_shader_parameter("det", dt)
	terrain_dirty = true
	# calidad Baja: cielo nuevo pero sin nubes
	sky_mat.set_shader_parameter("clouds_on", 1.0 if (opts["g_clouds"] and int(opts["quality"]) >= 1) else 0.0)
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
	if opts["g_clouds"] and int(opts["quality"]) >= 1:
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
			bmat_param("cshadow", cv)
			terrain_mat.set_shader_parameter("cshadow", cv)
			terrain_simple_mat.set_shader_parameter("cshadow", cv)
	elif cloud_cover != 0.0:
		cloud_cover = 0.0
		city_mat.set_shader_parameter("cshadow", 0.0)
		bmat_param("cshadow", 0.0)
		terrain_mat.set_shader_parameter("cshadow", 0.0)
		terrain_simple_mat.set_shader_parameter("cshadow", 0.0)
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
# texturas de fachadas y calles: se cargan recién cuando hacen falta (nunca en calidad Baja)
var city_tex_loaded: bool = false
func set_city_tex(on: bool) -> void:
	if on and not city_tex_loaded:
		var a: Resource = load("res://assets/city/city_alb.webp")
		var n: Resource = load("res://assets/city/city_nrm.webp")
		for m in [building_mat, building_lite_mat, city_mat]:
			m.set_shader_parameter("alb_arr", a)
			m.set_shader_parameter("nrm_arr", n)
		city_tex_loaded = true
	for m in [building_mat, building_lite_mat, city_mat]:
		m.set_shader_parameter("tex_on", 1.0 if on else 0.0)
func use_tex_terrain() -> bool:
	return int(opts["quality"]) >= 1 and bool(opts["g_detail"])
func build_terrain() -> void:
	terrain_dirty = false
	if use_tex_terrain():
		build_terrain_tex()
		return
	terrain_node.material_override = terrain_simple_mat
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
	set_hmap(himg)
	st.generate_normals()
	terrain_node.mesh = st.commit()
	build_outer(grass)
func set_hmap(himg: Image) -> void:
	var half := N * CELL * 0.5
	var htex := ImageTexture.create_from_image(himg)
	var hi := Vector4(N * CELL, half, float(N) / float(N + 1), 0.5 / float(N + 1))
	for m in [city_mat, water_mat, terrain_mat, building_mat, building_lite_mat]:
		m.set_shader_parameter("hmap", htex)
		m.set_shader_parameter("hinfo", hi)
func load_terrain_tex() -> void:
	if terrain_tex_loaded:
		return
	terrain_tex_loaded = true
	for mat in ["grass", "dry", "dirt", "rock", "sand", "snow"]:
		terrain_mat.set_shader_parameter("alb_" + mat, load("res://assets/terrain/%s_alb.webp" % mat))
	for mat in ["grass", "dirt", "rock", "sand"]:
		terrain_mat.set_shader_parameter("nrm_" + mat, load("res://assets/terrain/%s_nrm.webp" % mat))
# celda "ocupada": su suelo no se suaviza (calles, zonas, edificios, diques y árboles se quedan como hoy)
func terrain_busy(x: int, z: int) -> bool:
	if not inb(x, z):
		return false
	var i := idx(x, z)
	return road[i] > 0 or zone[i] > 0 or bld[i] > 0 or tree[i] > 0 or (wire[i] & W_LEVEE) != 0
# Catmull-Rom en el punto medio
func cr_mid(p0: float, p1: float, p2: float, p3: float) -> float:
	return (-p0 + 9.0 * p1 + 9.0 * p2 - p3) / 16.0
# pesos del splat de una celda: pasto, arena, roca, tierra
func cell_splat(i: int) -> Color:
	match terr[i]:
		T_SAND:
			return Color(0, 1, 0, 0)
		T_ROCK:
			return Color(0, 0, 1, 0)
		T_WATER:
			return Color(0, 0.35, 0, 0.65)
	var x := cx(i)
	var z := cz(i)
	var sl := 0.0
	for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if inb(x + o.x, z + o.y):
			sl = maxf(sl, absf(hgt[idx(x + o.x, z + o.y)] - hgt[i]))
	var rock := clampf((sl - 0.6) / 0.8, 0.0, 1.0)
	var dirt := 0.6 if (wdist[i] <= 1.0 and hgt[i] < 0.5) else 0.0
	var g := maxf(0.0, 1.0 - rock - dirt)
	return Color(g, 0, rock, dirt)
# Terreno con texturas (Media y Alta): malla de 2×2 por celda. Las esquinas de celda quedan a la
# altura de hoy; los puntos nuevos se suavizan, salvo junto a celdas ocupadas, donde caen sobre los
# mismos triángulos de antes (diagonal a-d), así nada queda flotando ni enterrado.
func build_terrain_tex() -> void:
	load_terrain_tex()
	terrain_node.material_override = terrain_mat
	var s := season()
	var half := N * CELL * 0.5
	var N1 := N + 1
	# datos por celda, una sola vez
	var csp := PackedColorArray()
	csp.resize(N * N)
	var cown := PackedFloat32Array()
	cown.resize(N * N)
	var busy := PackedByteArray()
	busy.resize(N * N)
	for i in N * N:
		csp[i] = cell_splat(i)
		cown[i] = 1.0 if is_owned(i) else 0.0
		busy[i] = 1 if (road[i] > 0 or zone[i] > 0 or bld[i] > 0 or tree[i] > 0 or (wire[i] & W_LEVEE) != 0) else 0
	var vh := PackedFloat32Array()
	vh.resize(N1 * N1)
	var own := PackedFloat32Array()
	own.resize(N1 * N1)
	var sp := PackedByteArray()
	sp.resize(N1 * N1 * 4)
	for z in N1:
		for x in N1:
			var hs := 0.0
			var cnt := 0
			var ow := 0.0
			var c := Color(0, 0, 0, 0)
			for zz in range(z - 1, z + 1):
				if zz < 0 or zz >= N:
					continue
				for xx in range(x - 1, x + 1):
					if xx < 0 or xx >= N:
						continue
					var i := zz * N + xx
					hs += hgt[i]
					cnt += 1
					ow += cown[i]
					c += csp[i]
			var k := z * N1 + x
			var fc := 1.0 / maxf(cnt, 1)
			vh[k] = hs * fc
			own[k] = ow * fc
			sp[k * 4] = int(c.r * fc * 255.0)
			sp[k * 4 + 1] = int(c.g * fc * 255.0)
			sp[k * 4 + 2] = int(c.b * fc * 255.0)
			sp[k * 4 + 3] = int(c.a * fc * 255.0)
	set_hmap(Image.create_from_data(N1, N1, false, Image.FORMAT_RF, vh.to_byte_array()))
	terrain_mat.set_shader_parameter("splat", ImageTexture.create_from_image(Image.create_from_data(N1, N1, false, Image.FORMAT_RGBA8, sp)))
	terrain_mat.set_shader_parameter("season_dry", [0.08, 0.85, 0.55, 0.0][s] + (0.2 if weather == "Calor" else 0.0))
	# malla fina: (2N+1)² vértices
	var M := 2 * N + 1
	var hsub := PackedFloat32Array()
	hsub.resize(M * M)
	for v in M:
		for u in M:
			var h := 0.0
			var x0 := u >> 1
			var z0 := v >> 1
			if (u & 1) == 0 and (v & 1) == 0:
				h = vh[z0 * N1 + x0]
			elif (u & 1) == 1 and (v & 1) == 0:
				# borde horizontal entre esquinas x0 y x0+1; lo tocan las celdas (x0, z0-1) y (x0, z0)
				if (z0 > 0 and x0 < N and busy[(z0 - 1) * N + x0] == 1) or (z0 < N and x0 < N and busy[z0 * N + x0] == 1):
					h = (vh[z0 * N1 + x0] + vh[z0 * N1 + x0 + 1]) * 0.5
				else:
					h = cr_mid(vh[z0 * N1 + maxi(x0 - 1, 0)], vh[z0 * N1 + x0], vh[z0 * N1 + x0 + 1], vh[z0 * N1 + mini(x0 + 2, N)])
			elif (u & 1) == 0 and (v & 1) == 1:
				if (x0 > 0 and z0 < N and busy[z0 * N + x0 - 1] == 1) or (x0 < N and z0 < N and busy[z0 * N + x0] == 1):
					h = (vh[z0 * N1 + x0] + vh[(z0 + 1) * N1 + x0]) * 0.5
				else:
					h = cr_mid(vh[maxi(z0 - 1, 0) * N1 + x0], vh[z0 * N1 + x0], vh[(z0 + 1) * N1 + x0], vh[mini(z0 + 2, N) * N1 + x0])
			else:
				# centro de la celda (x0, z0)
				if busy[z0 * N + x0] == 1:
					h = (vh[z0 * N1 + x0] + vh[(z0 + 1) * N1 + x0 + 1]) * 0.5
				else:
					var xa := maxi(x0 - 1, 0)
					var xd := mini(x0 + 2, N)
					var r0 := maxi(z0 - 1, 0) * N1
					var r1 := z0 * N1
					var r2 := (z0 + 1) * N1
					var r3 := mini(z0 + 2, N) * N1
					h = cr_mid(cr_mid(vh[r0 + xa], vh[r0 + x0], vh[r0 + x0 + 1], vh[r0 + xd]),
						cr_mid(vh[r1 + xa], vh[r1 + x0], vh[r1 + x0 + 1], vh[r1 + xd]),
						cr_mid(vh[r2 + xa], vh[r2 + x0], vh[r2 + x0 + 1], vh[r2 + xd]),
						cr_mid(vh[r3 + xa], vh[r3 + x0], vh[r3 + x0 + 1], vh[r3 + xd]))
			hsub[v * M + u] = h
	terrain_hsub = hsub
	var verts := PackedVector3Array()
	verts.resize(M * M)
	var nrms := PackedVector3Array()
	nrms.resize(M * M)
	var cols := PackedColorArray()
	cols.resize(M * M)
	var step := CELL * 0.5
	for v in M:
		for u in M:
			var k := v * M + u
			verts[k] = Vector3(u * step - half, hsub[k], v * step - half)
			var hl := hsub[v * M + maxi(u - 1, 0)]
			var hr := hsub[v * M + mini(u + 1, M - 1)]
			var hd := hsub[maxi(v - 1, 0) * M + u]
			var hu := hsub[mini(v + 1, M - 1) * M + u]
			nrms[k] = Vector3(hl - hr, 2.0 * step, hd - hu).normalized()
			var ow := own[(v >> 1) * N1 + (u >> 1)]
			if (u & 1) == 1 or (v & 1) == 1:
				ow = (ow + own[mini((v + 1) >> 1, N) * N1 + mini((u + 1) >> 1, N)]) * 0.5
			cols[k] = Color(1, 1, 1, ow)
	var ids := PackedInt32Array()
	ids.resize((M - 1) * (M - 1) * 6)
	var n := 0
	for v in M - 1:
		for u in M - 1:
			var a := v * M + u
			# misma diagonal que el terreno de hoy (a-d)
			ids[n] = a
			ids[n + 1] = a + 1
			ids[n + 2] = a + M + 1
			ids[n + 3] = a
			ids[n + 4] = a + M + 1
			ids[n + 5] = a + M
			n += 6
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = nrms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_INDEX] = ids
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	terrain_node.mesh = am
	var grass: Color = [Color(0.42, 0.62, 0.28), Color(0.58, 0.55, 0.28), Color(0.62, 0.66, 0.6), Color(0.45, 0.68, 0.32)][s]
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
var far_mat: ShaderMaterial
# Horizonte: un anillo de terreno alrededor del mapa (hasta 5 veces su tamaño) con lomas suaves que se
# pierden en la bruma. Junto al borde copia la altura del mapa (sin escalón); donde el borde es agua,
# baja bajo el nivel del agua para que el agua siga hasta el horizonte.
func build_outer(grass: Color) -> void:
	for n in outer_nodes:
		n.queue_free()
	outer_nodes.clear()
	var size := N * CELL
	var half := size * 0.5
	var stp := size / 16.0
	var R := 80
	var G := 2 * R + 1
	var nz := FastNoiseLite.new()
	nz.seed = map_seed + 991
	nz.frequency = 0.0016
	nz.fractal_octaves = 4
	# alturas reales del borde del terreno ya armado (para empalmar sin rendijas)
	var edge := {}
	if terrain_node.mesh != null:
		var tv: PackedVector3Array = terrain_node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		for v in tv:
			if absf(absf(v.x) - half) < 0.01 or absf(absf(v.z) - half) < 0.01:
				edge[Vector2i(roundi(v.x * 10.0), roundi(v.z * 10.0))] = v.y
	var hv := PackedFloat32Array()
	hv.resize(G * G)
	for j in G:
		for i in G:
			var wx := (i - R) * stp
			var wz := (j - R) * stp
			# distancia al cuadrado del mapa (0 adentro y en el borde)
			var dxo := maxf(absf(wx) - half, 0.0)
			var dzo := maxf(absf(wz) - half, 0.0)
			var dist := sqrt(dxo * dxo + dzo * dzo)
			var bx := clampi(int((clampf(wx, -half, half - 0.01) + half) / CELL), 0, N - 1)
			var bz := clampi(int((clampf(wz, -half, half - 0.01) + half) / CELL), 0, N - 1)
			var bi := idx(bx, bz)
			var base: float = WATER_Y - 2.5 if terr[bi] == T_WATER else hgt[bi]
			var t := smoothstep(0.0, size * 1.2, dist)
			var hills := (nz.get_noise_2d(wx, wz) * 0.5 + 0.5) * 70.0 * smoothstep(0.0, size * 0.6, dist)
			if terr[bi] == T_WATER:
				hills *= 0.15
			hv[j * G + i] = lerpf(base, base + hills, t) if terr[bi] != T_WATER else base - 1.0 * t
			var ek := Vector2i(roundi(wx * 10.0), roundi(wz * 10.0))
			if edge.has(ek):
				hv[j * G + i] = edge[ek]
	var verts := PackedVector3Array()
	var nrms := PackedVector3Array()
	var cols := PackedColorArray()
	verts.resize(G * G)
	nrms.resize(G * G)
	cols.resize(G * G)
	for j in G:
		for i in G:
			var k := j * G + i
			verts[k] = Vector3((i - R) * stp, hv[k], (j - R) * stp)
			var hl := hv[j * G + maxi(i - 1, 0)]
			var hr := hv[j * G + mini(i + 1, G - 1)]
			var hd := hv[maxi(j - 1, 0) * G + i]
			var hu := hv[mini(j + 1, G - 1) * G + i]
			nrms[k] = Vector3(hl - hr, 2.0 * stp, hd - hu).normalized()
			cols[k] = Color(1, 1, 1, 0)  # el campo lejano se ve como zona no comprada
	var ids := PackedInt32Array()
	for j in G - 1:
		for i in G - 1:
			# se saltean los cuadros que están adentro del mapa
			var cxw := (i - R + 0.5) * stp
			var czw := (j - R + 0.5) * stp
			if absf(cxw) < half and absf(czw) < half:
				continue
			if (absf(cxw) < half and absf(czw) < half + stp) or (absf(czw) < half and absf(cxw) < half + stp):
				continue
			var a := j * G + i
			ids.append_array(PackedInt32Array([a, a + 1, a + G + 1, a, a + G + 1, a + G]))
	# altura del anillo sobre la línea a un paso del mapa (lineal entre sus vértices, igual que sus triángulos)
	var ring_h := func(x: float, z: float) -> float:
		var fi := x / stp + R
		var fj := z / stp + R
		var i0 := clampi(int(floor(fi)), 0, G - 2)
		var j0 := clampi(int(floor(fj)), 0, G - 2)
		var u := clampf(fi - i0, 0.0, 1.0)
		var w := clampf(fj - j0, 0.0, 1.0)
		if absf(u) < 0.0001 or absf(u - 1.0) < 0.0001:
			var ii := i0 + roundi(u)
			return lerpf(hv[j0 * G + ii], hv[(j0 + 1) * G + ii], w)
		var jj := j0 + roundi(w)
		return lerpf(hv[jj * G + i0], hv[jj * G + i0 + 1], u)
	for side in 4:
		# puntos del borde de este lado, ordenados
		var pts := []
		for k in edge:
			var x: float = k.x / 10.0
			var z: float = k.y / 10.0
			var on := false
			match side:
				0:
					on = absf(x - half) < 0.01
				1:
					on = absf(x + half) < 0.01
				2:
					on = absf(z - half) < 0.01
				3:
					on = absf(z + half) < 0.01
			if on:
				pts.append(z if side < 2 else x)
		pts.sort()
		for q in range(pts.size() - 1):
			var a0: float = pts[q]
			var a1: float = pts[q + 1]
			# cuatro esquinas con x y z crecientes (mismo orden de triángulos que el anillo)
			var p := []
			for c in [[0, 0], [1, 0], [0, 1], [1, 1]]:
				var along: float = a0 if c[1] == 0 else a1
				var outside: bool = c[0] == 1
				var px: float
				var pz: float
				match side:
					0:
						px = half + (stp if outside else 0.0)
						pz = along
					1:
						px = -half - (stp if not outside else 0.0)
						pz = along
					2:
						px = along
						pz = half + (stp if outside else 0.0)
					3:
						px = along
						pz = -half - (stp if not outside else 0.0)
				var inner: bool = (absf(absf(px) - half) < 0.01 and side < 2) or (absf(absf(pz) - half) < 0.01 and side >= 2)
				var py: float = edge[Vector2i(roundi(px * 10.0), roundi(pz * 10.0))] if inner else ring_h.call(px, pz)
				p.append(Vector3(px, py, pz))
			# ordenar como grilla: [x0z0, x1z0, x0z1, x1z1]
			p.sort_custom(func(A, B): return A.z < B.z - 0.001 or (absf(A.z - B.z) <= 0.001 and A.x < B.x))
			var base := verts.size()
			for v in p:
				verts.append(v)
				nrms.append(Vector3.UP)
				cols.append(Color(1, 1, 1, 0))
			ids.append_array(PackedInt32Array([base, base + 1, base + 3, base, base + 3, base + 2]))
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = nrms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_INDEX] = ids
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var m := MeshInstance3D.new()
	m.mesh = am
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if use_tex_terrain():
		if far_mat == null:
			far_mat = terrain_mat.duplicate()
		far_mat.set_shader_parameter("far", 1.0)
		far_mat.set_shader_parameter("season_dry", terrain_mat.get_shader_parameter("season_dry"))
		far_mat.set_shader_parameter("snow", terrain_mat.get_shader_parameter("snow"))
		m.material_override = far_mat
	else:
		var sm := StandardMaterial3D.new()
		sm.albedo_color = grass.darkened(0.12)
		sm.roughness = 1.0
		m.material_override = sm
	add_child(m)
	outer_nodes.append(m)
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
	_binst.clear()
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
	flush_buildings(c)
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
			if not emit_special(i, p):
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
	var am := -20.0 if t >= 2 else 0.0
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
		em(M_CORNER, p.x + cxo * CELL * 0.5, y, p.z + czo * CELL * 0.5, CELL * 1.02, 0.17, CELL * 1.02, rot, sidewalk, 0, 0, 0, -21)
		em(M_CORNER, p.x + cxo * CELL * 0.5, y, p.z + czo * CELL * 0.5, CELL * 0.86, 0.2, CELL * 0.86, rot, col, 0, 0, 0, am)
		return
	em(M_BOX, p.x, y, p.z, CELL, 0.2, CELL, 0.0, col, 0, 0, 0, am)
	# semáforos en los cruces donde llega una avenida
	if cnt >= 3 and not bridge:
		var av: bool = t >= 3
		for o in [1, -1, N, -N]:
			var j: int = i + o
			if j >= 0 and j < N * N and road[j] >= 3:
				av = true
		if av:
			emit_semaforos(i, p, y + 0.2)
		emit_corner_props(i, p, y + 0.26, av)
	var horiz := (e or w) and not (s or n)
	var vert := (s or n) and not (e or w)
	if t >= 2 and not bridge:
		if not n and (horiz or cnt <= 1):
			em(M_BOX, p.x, y, p.z - CELL * 0.44, CELL, 0.26, CELL * 0.12, 0.0, sidewalk, 0, 0, 0, -21)
		if not s and (horiz or cnt <= 1):
			em(M_BOX, p.x, y, p.z + CELL * 0.44, CELL, 0.26, CELL * 0.12, 0.0, sidewalk, 0, 0, 0, -21)
		if not e and (vert or cnt <= 1):
			em(M_BOX, p.x + CELL * 0.44, y, p.z, CELL * 0.12, 0.26, CELL, 0.0, sidewalk, 0, 0, 0, -21)
		if not w and (vert or cnt <= 1):
			em(M_BOX, p.x - CELL * 0.44, y, p.z, CELL * 0.12, 0.26, CELL, 0.0, sidewalk, 0, 0, 0, -21)
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
			emit_farol(p.x + lo.x, y + 0.26, p.z + lo.y, ao.x, ao.y)
			lamps[i] = Vector3(p.x + lo.x + ao.x, y, p.z + lo.y + ao.y)
		if t >= 2 and not bridge:
			emit_street_furniture(i, p, y + 0.26, t, horiz)
		if t == 2 and opts["quality"] >= 1:
			for side in [-1, 1]:
				var j: int = i + (N * side if horiz else side)
				if j >= 0 and j < N * N and zone[j] > 0 and lvl[j] >= 1 and hsh(i, side + 7) < (0.7 if zone[j] == Z_C else 0.45):
					var po := Vector2(0, side * CELL * 0.3) if horiz else Vector2(side * CELL * 0.3, 0)
					emit_car(i * 3 + side, p.x + po.x, y + 0.2, p.z + po.y, rot)
func car_color(k: int) -> Color:
	var pal := [Color(0.85, 0.85, 0.87), Color(0.15, 0.15, 0.17), Color(0.7, 0.12, 0.1), Color(0.2, 0.3, 0.6), Color(0.55, 0.57, 0.6), Color(0.9, 0.75, 0.2), Color(0.25, 0.45, 0.3)]
	return pal[absi(k) % pal.size()]
func emit_cable(i: int, p: Vector3) -> void:
	emit_power(i, p)
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
			# la nieve la pone el shader arriba de cada capa
			return [Color(0.15, 0.38, 0.2), 1.0]
		5:
			if s == 0 or s == 3:
				return [Color(0.92, 0.5, 0.7), 1.0]
			return [Color(0.35, 0.55, 0.28), 0.9]
		6:
			return [Color(0.3, 0.6, 0.25), 1.0]
		7:
			return [Color(0.55, 0.7, 0.3) if s != 2 else Color(0.5, 0.5, 0.35), 1.0]
	return [Color(0.3, 0.55, 0.25), 1.0]
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
	emit_building(i, bx, p.y + 0.1, bz, rot, tint(res_wall(v), i), dark)
func tint(c: Color, i: int) -> Color:
	var hh := fposmod(c.h + (hsh(i, 77) - 0.5) * 0.07, 1.0)
	return Color.from_hsv(hh, clampf(c.s * (0.75 + hsh(i, 78) * 0.6), 0.0, 1.0), clampf(c.v * (0.86 + hsh(i, 79) * 0.2), 0.0, 1.0))
func res_wall(v: int) -> Color:
	var pal := [Color(0.92, 0.88, 0.8), Color(0.85, 0.72, 0.6), Color(0.95, 0.93, 0.88), Color(0.78, 0.55, 0.45), Color(0.88, 0.82, 0.65), Color(0.7, 0.75, 0.78), Color(0.95, 0.85, 0.75), Color(0.65, 0.6, 0.55)]
	return pal[v % pal.size()]
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
	# los especiales terminados los dibuja emit_special; acá queda solo la maravilla en obra
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
	bmat_param("night", nf)
	bmat_param("late", 1.0 if hour >= 1.0 and hour < 6.0 else 0.0)
	bmat_param("snow", 0.8 if weather == "Nieve" else 0.0)
	bmat_param("wet", 1.0 if (weather == "Lluvia" or weather == "Tormenta") else 0.0)
	terrain_mat.set_shader_parameter("snow", 1.0 if weather == "Nieve" else 0.0)
	if far_mat != null:
		far_mat.set_shader_parameter("snow", 1.0 if weather == "Nieve" else 0.0)
	water_mat.set_shader_parameter("night", nf)
	water_mat.set_shader_parameter("wind_dir", wind)
	water_mat.set_shader_parameter("rain", 1.0 if (weather == "Lluvia" or weather == "Tormenta") and int(opts["quality"]) >= 2 else 0.0)
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
