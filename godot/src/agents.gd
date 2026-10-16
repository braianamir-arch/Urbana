# Autos, gente, transporte, barcos, aviones, cine, partículas y choques.
var glow_node: MultiMeshInstance3D
var glow_buf := PackedFloat32Array()
var glow_n: int = 0
var dyn_close: bool = false
var rails_node: MultiMeshInstance3D
var tl_cells: Array = []
var road_list := PackedInt32Array()
var anim_time: float = 0.0
var plane_t: float = 0.0
var ship_t: float = 0.0
var garbage_t: float = 0.0
var flag_days: int = 0
# etapa 5: humo de chimeneas, agua de las fuentes y rayos con tormenta
var smoke_t: float = 0.0
var smoke_n: int = 0
var flash_t: float = 0.0
var bolt_p := Vector3.ZERO
var bolt_seed: int = 0
var thunder_job: int = -1
var thunder_wav: AudioStreamWAV = null
var dyn_skip: int = 0
func setup_agents() -> void:
	dyn_nodes.clear()
	for m in NMESH:
		var node := new_mm_node(meshes[m], null)
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		dyn_nodes.append(node)
	rails_node = new_mm_node(meshes[M_BOX], null)
	var gm := ShaderMaterial.new()
	var gsh := Shader.new()
	gsh.code = SHADER_GLOW.code
	gm.shader = gsh
	var gq := PlaneMesh.new()
	gq.size = Vector2(1, 1)
	glow_node = new_mm_node(gq, gm)
	glow_buf.resize(4000)
	dyn_nodes.append(glow_node)
func gl(kind: float, x: float, y: float, z: float, sx: float, sz: float, rot: float, col: Color, sz2: float = 0.0) -> void:
	var c := cos(rot)
	var s := sin(rot)
	var o := glow_n * 20
	if o + 20 > glow_buf.size():
		glow_buf.resize(glow_buf.size() * 2)
	glow_buf[o] = c * sx
	glow_buf[o + 1] = 0.0
	glow_buf[o + 2] = s * sz
	glow_buf[o + 3] = x
	glow_buf[o + 4] = 0.0
	glow_buf[o + 5] = 1.0
	glow_buf[o + 6] = 0.0
	glow_buf[o + 7] = y
	glow_buf[o + 8] = -s * sx
	glow_buf[o + 9] = 0.0
	glow_buf[o + 10] = c * sz
	glow_buf[o + 11] = z
	glow_buf[o + 12] = col.r
	glow_buf[o + 13] = col.g
	glow_buf[o + 14] = col.b
	glow_buf[o + 15] = col.a
	glow_buf[o + 16] = kind
	glow_buf[o + 17] = sz2
	glow_buf[o + 18] = 0.0
	glow_buf[o + 19] = 0.0
	glow_n += 1
func veh_lights(p: Vector3, r: float, ln: float, hw: float, hy: float, nf: float, lit: bool, wheels: bool, beam: float) -> void:
	var sr := sin(r)
	var cr := cos(r)
	if wheels:
		for sg in [-1.0, 1.0]:
			for fz in [-0.32, 0.32]:
				em(M_SPH, p.x + cr * sg * hw + sr * fz * ln, p.y, p.z - sr * sg * hw + cr * fz * ln, 0.2, 0.42, 0.42, r, Color(0.06, 0.06, 0.07))
	if wheels or lit:
		var hl := 0.5 + nf * 3.0
		var tl := 0.5 + nf * 1.8
		for sg in [-0.7, 0.7]:
			var rx: float = cr * sg * hw
			var rz: float = -sr * sg * hw
			em(M_BOX, p.x + rx + sr * ln * 0.5, p.y + hy, p.z + rz + cr * ln * 0.5, 0.2, 0.12, 0.06, r, Color(1.0, 0.95, 0.75), 0, 0, hl)
			em(M_BOX, p.x + rx - sr * ln * 0.5, p.y + hy, p.z + rz - cr * ln * 0.5, 0.2, 0.12, 0.06, r, Color(0.9, 0.08, 0.06), 0, 0, tl)
	if lit:
		var halo_k := 1.5 if weather == "Lluvia" or weather == "Tormenta" else 1.0
		var k := ln * 0.5 + beam * 0.5
		gl(0.0, p.x + sr * k, p.y + 0.32, p.z + cr * k, 2.6 + hw, beam, r, Color(1.0, 0.92, 0.7, 0.55))
		gl(1.0, p.x - sr * ln * 0.55, p.y + 0.32, p.z - cr * ln * 0.55, 1.5, 1.5, 0.0, Color(1.0, 0.1, 0.05, 0.3))
		if weather == "Lluvia" or weather == "Tormenta":
			gl(0.0, p.x - sr * (ln * 0.5 + 2.0), p.y + 0.33, p.z - cr * (ln * 0.5 + 2.0), 1.4, 4.0, r + PI, Color(1.0, 0.1, 0.05, 0.55))
			gl(0.0, p.x + sr * (ln * 0.5 + 5.5), p.y + 0.33, p.z + cr * (ln * 0.5 + 5.5), 1.0, 7.0, r, Color(0.9, 0.95, 1.0, 0.35))
		for sg in [-0.7, 0.7]:
			var hx: float = p.x + cr * sg * hw + sr * ln * 0.52
			var hz: float = p.z - sr * sg * hw + cr * ln * 0.52
			gl(2.0, hx, p.y + hy, hz, 1.0, 1.0, 0.0, Color(1.0, 0.93, 0.75, 0.9), 0.95 * halo_k)
			var tx: float = p.x + cr * sg * hw - sr * ln * 0.52
			var tz: float = p.z - sr * sg * hw - cr * ln * 0.52
			gl(2.0, tx, p.y + hy, tz, 1.0, 1.0, 0.0, Color(1.0, 0.1, 0.05, 0.8), 0.5 * halo_k)
func max_cars() -> int:
	return [35, 75, 120][opts["quality"]]
func max_peds() -> int:
	return [40, 90, 150][opts["quality"]]
func agents_process(delta: float) -> void:
	anim_time += delta
	var m := minf(speed_mult(), 2.0)
	if speed == 0:
		m = 0.0
	var dt := delta * m
	if sim_dirty or road_list.is_empty():
		rebuild_road_list()
	for c in anim_cells.keys():
		anim_cells[c] = anim_cells[c] - dt
		if anim_cells[c] <= 0.0:
			anim_cells.erase(c)
			mark_dirty(c)
	spawn_agents(dt)
	move_cars(dt)
	move_peds(dt)
	move_svc(dt)
	move_lines(dt)
	move_boats(dt)
	move_stars(dt)
	move_parts(delta)
	if drive != null:
		move_drive(delta)
	dyn_skip += 1
	if opts["quality"] == 0 and dyn_skip % 2 == 1:
		return
	draw_dynamic()
func rebuild_road_list() -> void:
	road_list.clear()
	tl_cells.clear()
	for i in N * N:
		if road[i] > 0:
			road_list.append(i)
			if road[i] >= 2 and not (wire[i] & W_ROUND):
				var nb := road_n(i)
				if int(nb[0]) + int(nb[1]) + int(nb[2]) + int(nb[3]) >= 3:
					tl_cells.append(i)
func spawn_agents(dt: float) -> void:
	if dt <= 0.0:
		return
	# el horario de la ciudad: hora pico llena, de madrugada casi nadie
	var street := life_street(hour, life_weekend())
	var want_c := int(mini(max_cars(), pop / 10) * street)
	if cars.size() < want_c and not car_paths.is_empty() and randf() < 0.5:
		var p: Array = car_paths[randi() % car_paths.size()]
		if randf() < 0.5:
			p = p.duplicate()
			p.reverse()
		var ckind := randi() % 3
		var car_col := car_color(randi())
		var rr := randf()
		if rr < 0.12:
			ckind = 3
			car_col = Color(0.95, 0.75, 0.08)
		elif rr < 0.22:
			ckind = 4
		elif rr < 0.34:
			ckind = 5
		var car_roof := car_col
		if ckind != 3 and randf() < 0.3:
			car_roof = Color(0.93, 0.93, 0.95) if randf() < 0.5 else Color(0.08, 0.08, 0.1)
		var cd := {"p": p, "k": 0.0, "spd": randf_range(0.9, 1.5), "col": car_col, "kind": ckind, "roof": car_roof}
		if ckind == 5:
			cd["spd"] = randf_range(1.2, 1.7)
			cd["deli"] = randf() < 0.55
			cd["box"] = [Color(0.95, 0.35, 0.1), Color(0.95, 0.8, 0.1), Color(0.85, 0.1, 0.15), Color(0.1, 0.65, 0.4)][randi() % 4]
			cd["look"] = rand_look()
			cd["col"] = Color(0.1, 0.1, 0.12) if randf() < 0.5 else car_col
		cars.append(cd)
	var want_p := int(mini(max_peds(), pop / 5 + 6 if pop > 0 else 0) * street)
	if peds.size() < want_p and road_list.size() > 4:
		var c: int = road_list[randi() % road_list.size()]
		if road[c] >= 2:
			var kind := 0
			var r := randf()
			if r < 0.15:
				kind = 1
			elif r < 0.25:
				kind = 2
			elif r < 0.45 and wire[c] & W_BIKE or r < 0.33:
				kind = 3
			var np := new_ped(c, kind)
			# a la hora de la escuela: chicos con mochila que van o vuelven con un grande
			if kind == 0 and life_school_rush(hour, life_weekend()) and randf() < 0.6:
				var kid := rand_look()
				kid["off"] = 0.42
				kid["s"] = 0.62
				kid["bag"] = true
				kid["hand"] = true
				kid["school"] = true
				np["comp"] = [kid]
			peds.append(np)
	garbage_t += dt
	if garbage_t > 6.0:
		garbage_t = 0.0
		if garb_cap > 0 and not zone_list.is_empty() and svc.size() < 8:
			dispatch_from("garbage", -1, zone_list[randi() % zone_list.size()])
	plane_t += dt
	if plane_t > 14.0:
		plane_t = 0.0
		for a in anchors:
			if bld[a] == 0:
				continue
			if bld[a] == 56 and def_active(a):
				var p0 := cell_pos(a) + Vector3(CELL * 1.5, 0.5, CELL * 1.6)
				planes.append({"p": p0, "v": Vector3(cos(cam_yaw * 0.0 + randf()), 0, sin(randf())).normalized() * 18.0, "t": 0.0})
				break
	ship_t += dt
	if ship_t > 10.0:
		ship_t = 0.0
		for a in anchors:
			if bld[a] == 0:
				continue
			if bld[a] == 55 and def_active(a) and boats.size() < 6:
				var p1 := cell_pos(a)
				var dir := water_dir(a)
				if dir != Vector3.ZERO:
					boats.append({"p": Vector3(p1.x, WATER_Y, p1.z) + dir * CELL * 2.0, "v": dir * 3.5, "kind": 0, "t": 0.0})
				break
		if boats.size() < 4 and (map_kind <= 3) and randf() < 0.6:
			for tries in 20:
				var i := randi() % (N * N)
				if terr[i] == T_WATER and wdist[i] == 0.0:
					var pp := cell_pos(i)
					boats.append({"p": Vector3(pp.x, WATER_Y, pp.z), "v": Vector3(cos(randf() * TAU), 0, sin(randf() * TAU)) * 1.5, "kind": 1, "t": 0.0})
					break
func water_dir(a: int) -> Vector3:
	var best := Vector3.ZERO
	for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var x: int = cx(a) + o.x * 3
		var z: int = cz(a) + o.y * 3
		if inb(x, z) and terr[idx(x, z)] == T_WATER:
			best = Vector3(o.x, 0, o.y)
	return best
func path_pos(p: Array, k: float, lane: float) -> Array:
	var n := p.size()
	var i0 := clampi(int(k), 0, n - 1)
	var i1 := mini(i0 + 1, n - 1)
	var a := cell_pos(p[i0])
	var b := cell_pos(p[i1])
	if terr[p[i0]] == T_WATER:
		a.y = 0.6
	if terr[p[i1]] == T_WATER:
		b.y = 0.6
	var f := k - i0
	var pos := a.lerp(b, f)
	var d := b - a
	if d.length() < 0.01:
		d = Vector3(1, 0, 0)
	d = d.normalized()
	var side := Vector3(-d.z, 0, d.x)
	pos += side * lane
	return [pos, atan2(d.x, d.z)]
func curve_at(pm: Vector3, p0: Vector3, pn: Vector3, f: float) -> Array:
	var m0 := (pm + p0) * 0.5
	var m1 := (p0 + pn) * 0.5
	var u := 1.0 - f
	var pos := m0 * (u * u) + p0 * (2.0 * u * f) + m1 * (f * f)
	var tg := (p0 - m0) * (2.0 * u) + (m1 - p0) * (2.0 * f)
	return [pos, tg]
func cell_y(i: int) -> Vector3:
	var v := cell_pos(i)
	if terr[i] == T_WATER:
		v.y = 0.6
	return v
func path_pos_s(p: Array, k: float, lane: float) -> Array:
	var n := p.size()
	var t := k + 0.5
	var si := clampi(int(t), 0, n - 1)
	var f := clampf(t - si, 0.0, 1.0)
	var c := curve_at(cell_y(p[maxi(si - 1, 0)]), cell_y(p[si]), cell_y(p[mini(si + 1, n - 1)]), f)
	var tg: Vector3 = c[1]
	tg.y = 0.0
	if tg.length() < 0.001:
		tg = Vector3(1, 0, 0)
	tg = tg.normalized()
	var pos: Vector3 = c[0] + Vector3(-tg.z, 0, tg.x) * lane
	return [pos, atan2(tg.x, tg.z)]
func move_cars(dt: float) -> void:
	var lanes := {}
	for c in cars:
		var p: Array = c["p"]
		var i: int = clampi(int(c["k"]), 0, p.size() - 1)
		var j: int = mini(i + 1, p.size() - 1)
		var key: int = int(p[i]) * 65536 + int(p[j])
		c["_f"] = c["k"] - i
		if lanes.has(key):
			lanes[key].append(c)
		else:
			lanes[key] = [c]
	var keep: Array = []
	for c in cars:
		var p: Array = c["p"]
		var i: int = clampi(int(c["k"]), 0, p.size() - 1)
		var cr: float = c.get("crash", 0.0)
		if cr > 0.0:
			c["crash"] = cr - dt
			keep.append(c)
			continue
		var j: int = mini(i + 1, p.size() - 1)
		var cong := tload[p[i]] / road_cap(p[i])
		var want: float = dt * c["spd"] / (1.0 + cong * 1.5)
		var f: float = c["_f"]
		var gap := 9.0
		for o in lanes[int(p[i]) * 65536 + int(p[j])]:
			if o != c:
				var d: float = o["_f"] - f
				if d > 0.0 and d < gap:
					gap = d
		if gap > 1.0 and i + 2 < p.size():
			var key2: int = int(p[i + 1]) * 65536 + int(p[i + 2])
			if lanes.has(key2):
				for o in lanes[key2]:
					var d2: float = 1.0 - f + o["_f"]
					if d2 < gap:
						gap = d2
		var mg := 0.42 if c["kind"] == 5 else 0.62
		c["k"] = c["k"] + minf(want, maxf(gap - mg, 0.0))
		if c["k"] < p.size() - 1:
			keep.append(c)
	cars = keep
	check_crash(dt)
func move_peds(dt: float) -> void:
	var keep: Array = []
	for pd in peds:
		var spd := 0.45 if pd["kind"] != 3 else 1.6
		if pd.get("panic", 0.0) > 0.0:
			spd = 1.5
		pd["t"] = pd["t"] + dt * spd
		if pd["t"] >= 1.0:
			pd["t"] = 0.0
			pd["c"] = pd["n"]
			var c: int = pd["c"]
			if road[c] == 0:
				continue
			var opts2: Array = []
			for o in [1, -1, N, -N]:
				var j: int = c + o
				if j >= 0 and j < N * N and road[j] >= 2 and terr[j] != T_WATER:
					if (o == 1 or o == -1) and cz(j) != cz(c):
						continue
					opts2.append(j)
			if opts2.is_empty():
				continue
			pd["n"] = opts2[randi() % opts2.size()]
			if randf() < 0.01 and pd != follow_ped:
				continue
		keep.append(pd)
	peds = keep
func dispatch_from(kind: String, def_id: int, target: int) -> void:
	var best := -1
	var bd := 1e9
	for a in anchors:
		if bld[a] == 0:
			continue
		var ok := false
		if def_id >= 0:
			ok = bld[a] == def_id or (kind == "ambulance" and bld[a] == 23)
		else:
			ok = DEF[bld[a]].has("gb")
		if ok and def_active(a):
			var d := Vector2(cx(a) - cx(target), cz(a) - cz(target)).length()
			if d < bd:
				bd = d
				best = a
	if best < 0:
		return
	var path := road_path(best, target, false)
	if path.size() < 2:
		return
	svc.append({"p": path, "k": 0.0, "kind": kind, "back": false})
	if kind != "garbage" and cam_dist < 160.0 and Vector2(cam_target.x - cell_pos(target).x, cam_target.z - cell_pos(target).z).length() < 120.0:
		sfx("siren")
func move_svc(dt: float) -> void:
	var keep: Array = []
	for v in svc:
		v["k"] = v["k"] + dt * 3.4
		var p: Array = v["p"]
		if v["k"] >= p.size() - 1:
			if v["back"]:
				continue
			v["back"] = true
			p.reverse()
			v["k"] = 0.0
			if v["kind"] == "fire":
				var t: int = p[0]
				for dz in range(-2, 3):
					for dx in range(-2, 3):
						var x := cx(t) + dx
						var z := cz(t) + dz
						if inb(x, z) and burn[idx(x, z)] > 0.0 and randf() < 0.6:
							burn[idx(x, z)] = 0.0
							mark_dirty(idx(x, z))
			if v["kind"] == "garbage":
				var t2: int = p[0]
				for dz in range(-3, 4):
					for dx in range(-3, 4):
						var x2 := cx(t2) + dx
						var z2 := cz(t2) + dz
						if inb(x2, z2) and garbp[idx(x2, z2)] > 0.0:
							garbp[idx(x2, z2)] = maxf(0.0, garbp[idx(x2, z2)] - 1.0)
							mark_dirty(idx(x2, z2))
		keep.append(v)
	svc = keep
func rebuild_rails() -> void:
	begin_buf()
	for ln in lines:
		if ln["kind"] != "train":
			continue
		var pts: Array = ln["pts"]
		for k in pts.size():
			var a: Vector3 = pts[k]
			var b: Vector3 = pts[(k + 1) % pts.size()]
			var mid := (a + b) * 0.5
			var d := b - a
			var rot := atan2(d.x, d.z)
			em(M_BOX, mid.x, mid.y - 0.3, mid.z, 2.2, 0.4, d.length() + 0.1, rot, Color(0.45, 0.45, 0.47))
			if k % 3 == 0:
				var gy := 0.0
				var c := world_to_cell(a)
				if inb(c.x, c.y):
					gy = maxf(hgt[idx(c.x, c.y)], WATER_Y)
				em(M_BOX, a.x, gy, a.z, 0.7, a.y - gy - 0.3, 0.7, 0.0, Color(0.6, 0.6, 0.62))
	var mm := rails_node.multimesh
	mm.instance_count = _counts[M_BOX]
	if _counts[M_BOX] > 0:
		mm.buffer = _bufs[M_BOX].slice(0, _counts[M_BOX] * 20)
func move_lines(dt: float) -> void:
	for ln in lines:
		var pts: Array = ln["pts"]
		if pts.size() < 2:
			continue
		if ln.get("dwell", 0.0) > 0.0:
			ln["dwell"] = ln["dwell"] - dt
			continue
		var spd: float = {"bus": 1.4, "tram": 1.3, "metro": 3.0, "train": 2.8, "ferry": 1.0}[ln["kind"]] * budget[5] / 100.0
		var old: float = ln["t"]
		var nt: float = fmod(old + dt * spd, float(pts.size()))
		for sk in ln.get("stopk", []):
			if old < sk and nt >= sk:
				ln["dwell"] = 1.2
		ln["t"] = nt
func move_boats(dt: float) -> void:
	var keep: Array = []
	for b in boats:
		b["p"] = b["p"] + b["v"] * dt
		b["t"] = b["t"] + dt
		var c := world_to_cell(b["p"])
		var half := N * CELL * 0.5
		if absf(b["p"].x) > half * 2.0 or absf(b["p"].z) > half * 2.0 or b["t"] > 120.0:
			continue
		if inb(c.x, c.y) and terr[idx(c.x, c.y)] != T_WATER:
			if b["kind"] == 1:
				b["v"] = -b["v"].rotated(Vector3.UP, randf_range(-0.8, 0.8))
				b["p"] = b["p"] + b["v"] * dt * 2.0
			else:
				continue
		keep.append(b)
	boats = keep
	var kp: Array = []
	for pl in planes:
		pl["t"] = pl["t"] + dt
		pl["p"] = pl["p"] + pl["v"] * dt + Vector3(0, minf(pl["t"] * 2.0, 8.0) * dt, 0)
		if pl["t"] < 40.0:
			kp.append(pl)
	planes = kp
func emit_flames(pf: Vector3, i: int) -> void:
	for k in 4:
		var ph := hsh(i, k) * TAU
		var ox := (hsh(i, k + 10) - 0.5) * 2.6
		var oz := (hsh(i, k + 20) - 0.5) * 2.6
		var h := 2.4 + 1.8 * hsh(i, k + 30)
		var fl := 0.78 + 0.22 * sin(anim_time * 7.0 + ph) * sin(anim_time * 3.1 + ph * 1.7) + 0.12 * sin(anim_time * 13.0 + ph)
		for j in 3:
			var f := float(j) / 3.0
			var swx := sin(anim_time * 2.3 + ph + f * 2.0) * 0.45 * f + wind.x * f * 0.7
			var swz := cos(anim_time * 1.9 + ph + f * 2.0) * 0.45 * f + wind.y * f * 0.7
			var sc := (1.0 - f * 0.5) * 1.25
			em(M_SPH, pf.x + ox + swx, pf.y + 0.8 + f * h * fl, pf.z + oz + swz, sc, sc * 1.7 * fl, sc, 0.0, Color(1.0, 0.22 + f * 0.55, 0.04 + f * 0.12), 0, 0, 1.8 + f)
func move_parts(dt: float) -> void:
	var keep: Array = []
	for p in parts:
		p["t"] = p["t"] - dt
		if p["t"] <= 0.0:
			if p.has("smoke"):
				smoke_n -= 1
			continue
		if p.has("grow"):
			p["s"] = p["s"] + p["grow"] * dt
		p["v"] = p["v"] + Vector3(0, p.get("g", -6.0), 0) * dt
		if p.has("fade"):
			p["s"] = maxf(p["s"] * (1.0 - dt * 1.2), 0.02)
		p["p"] = p["p"] + p["v"] * dt
		keep.append(p)
	parts = keep
	smoke_fx(dt)
	if randf() < 0.6:
		for k in 3:
			var i := randi() % (N * N)
			if burn[i] > 0.0:
				parts.append({"p": cell_pos(i) + Vector3(randf_range(-1, 1), 3, randf_range(-1, 1)), "v": Vector3(wind.x, 2.5, wind.y), "t": 3.0, "g": 0.3, "col": Color(0.3, 0.3, 0.3), "s": 1.5})
				parts.append({"p": cell_pos(i) + Vector3(randf_range(-1, 1), 2, randf_range(-1, 1)), "v": Vector3(wind.x + randf_range(-0.8, 0.8), 3.5, wind.y + randf_range(-0.8, 0.8)), "t": 1.3, "g": 0.4, "col": Color(1.0, 0.6, 0.15), "s": 0.22, "glow": 3.0, "fade": true})
	if is_sunday() and hour > 11.0 and hour < 15.0 and randf() < 0.4:
		for a in anchors:
			if bld[a] == 0:
				continue
			if bld[a] == 33 and randf() < 0.3:
				parts.append({"p": cell_pos(a) + Vector3(0, 3, 0), "v": Vector3(wind.x * 0.5, 1.5, wind.y * 0.5), "t": 3.0, "g": 0.1, "col": Color(0.75, 0.75, 0.75), "s": 1.0})
func smoke_fx(dt: float) -> void:
	smoke_t += dt
	if smoke_t < 0.2 or int(opts["quality"]) < 1 or cam_dist > 260.0 or not opts["g_dyn"]:
		return
	smoke_t = 0.0
	for c in smoke_pts:
		var cc := cell_pos(idx((c % NCH) * CH + CH / 2, (c / NCH) * CH + CH / 2))
		if Vector2(cc.x - cam_target.x, cc.z - cam_target.z).length() > 260.0:
			continue
		for q in smoke_pts[c]:
			if smoke_n >= 90 or randf() > 0.35:
				continue
			var top: Vector3 = q
			var gray := randf_range(0.5, 0.68)
			parts.append({"p": top + Vector3(randf_range(-0.1, 0.1), 0.1, randf_range(-0.1, 0.1)), "v": Vector3(wind.x * 0.5 + randf_range(-0.2, 0.2), 1.3, wind.y * 0.5 + randf_range(-0.2, 0.2)), "t": 5.0, "g": 0.04, "col": Color(gray, gray, gray * 0.98), "s": 0.45, "grow": 0.32, "smoke": true})
			smoke_n += 1
	# fuentes de las plazas: chorritos de agua
	if weather != "Nieve":
		for a in anchors:
			if bld[a] != 30 or burn[a] > 0.0 or parts.size() > 400:
				continue
			var fp := cell_pos(a) + Vector3(CELL * 0.5, 0.0, CELL * 0.5) * (DEF[30]["sz"] - 1)
			if Vector2(fp.x - cam_target.x, fp.z - cam_target.z).length() > 150.0:
				continue
			for k in 3:
				var an := randf() * TAU
				parts.append({"p": fp + Vector3(0, 0.95, 0), "v": Vector3(cos(an) * 0.5, 2.6, sin(an) * 0.5), "t": 0.6, "g": -9.0, "col": Color(0.72, 0.86, 1.0), "s": 0.09})
# tormenta: de vez en cuando un rayo que ilumina todo y un trueno
func storm_fx(delta: float) -> float:
	if weather != "Tormenta" or not started:
		flash_t = 0.0
		return 0.0
	# el trueno se arma en otro hilo antes del primer rayo (armarlo tarda y trabaría el juego)
	if sounds.get("thunder") is Dictionary:
		if thunder_job < 0:
			var sd: Dictionary = sounds["thunder"]
			thunder_job = WorkerThreadPool.add_task(func(): thunder_wav = build_sound(sd["d"], sd["f"]))
		if not WorkerThreadPool.is_task_completed(thunder_job):
			return 0.0
		WorkerThreadPool.wait_for_task_completion(thunder_job)
		sounds["thunder"] = thunder_wav
	if flash_t <= 0.0 and randf() < delta * 0.1:
		flash_t = 0.4
		bolt_seed = randi()
		bolt_p = cam_target + Vector3(randf_range(-90, 90), 0, randf_range(-90, 90))
		sfx("thunder")
	if flash_t <= 0.0:
		return 0.0
	flash_t -= delta
	# dos destellos seguidos
	return maxf(flash_t, 0.0) / 0.4 * (1.0 if fmod(flash_t, 0.16) > 0.06 else 0.25)
func confetti(cols: Array) -> void:
	for k in 140:
		var p := cam_target + Vector3(randf_range(-60, 60), randf_range(20, 45), randf_range(-60, 60))
		parts.append({"p": p, "v": Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)), "t": 6.0, "g": -1.5, "col": cols[k % cols.size()], "s": 0.5, "glow": 0.3})
	flag_days = 3
func fireworks(at: Vector3, n: int) -> void:
	for b in maxi(1, n / 12):
		var c := at + Vector3(randf_range(-50, 50), randf_range(30, 55), randf_range(-50, 50))
		var col := Color.from_hsv(randf(), 0.8, 1.0)
		for k in 14:
			var v := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(6, 10)
			parts.append({"p": c, "v": v, "t": 2.2, "g": -3.0, "col": col, "s": 0.6, "glow": 2.0})
	sfx("pop")
func bocinazo() -> void:
	sfx("horns")
	var tw := create_tween()
	if top_money:
		tw.tween_property(top_money, "modulate", Color(1.0, 0.85, 0.3), 0.2)
		tw.tween_property(top_money, "modulate", Color.WHITE, 0.8)
func start_drive() -> void:
	if road_list.is_empty():
		toast("Primero hacé calles")
		return
	var c: int = road_list[randi() % road_list.size()]
	drive = {"c": c, "n": c, "t": 0.0, "dir": Vector2i(1, 0), "spd": 3.0}
	pick_drive_next()
	cam_pitch = 0.3
	cam_dist_goal = 10.0
	cam_follow = func():
		if drive == null:
			return null
		var pp := path_pos([drive["c"], drive["n"]], drive["t"], CELL * 0.18)
		cam_yaw = lerp_angle(cam_yaw, pp[1] + PI, 0.08)
		cam_dist_goal = 10.0
		return pp[0] + Vector3(0, 1.5, 0)
	show_drive_ui(true)
func stop_drive() -> void:
	drive = null
	cam_follow = null
	cam_pitch = 0.85
	cam_dist_goal = 120.0
	show_drive_ui(false)
func pick_drive_next() -> void:
	var c: int = drive["c"]
	var d: Vector2i = drive["dir"]
	var cands: Array = []
	var dirs := [d, Vector2i(-d.y, d.x), Vector2i(d.y, -d.x)]
	var order: Array = []
	if drive_turn == -1:
		order = [dirs[2], dirs[0], dirs[1]]
	elif drive_turn == 1:
		order = [dirs[1], dirs[0], dirs[2]]
	else:
		order = [dirs[0], dirs[1], dirs[2]]
	for o in order:
		var x: int = cx(c) + o.x
		var z: int = cz(c) + o.y
		if inb(x, z) and road[idx(x, z)] > 0:
			cands.append(o)
	if cands.is_empty():
		cands = [-d]
	var nd: Vector2i = cands[0]
	drive["dir"] = nd
	drive["n"] = idx(cx(c) + nd.x, cz(c) + nd.y) if inb(cx(c) + nd.x, cz(c) + nd.y) else c
	drive_turn = 0
func move_drive(dt: float) -> void:
	drive["t"] = drive["t"] + dt * drive["spd"]
	if drive["t"] >= 1.0:
		drive["t"] = 0.0
		drive["c"] = drive["n"]
		pick_drive_next()
		set_drive_street(street_name(drive["c"]))
func pick_ped(pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var bd := get_viewport().get_visible_rect().size.y * 0.045
	for pd in peds:
		if pd["kind"] == 2:
			continue
		var pp := path_pos([pd["c"], pd["n"]], pd["t"], CELL * 0.42 * pd["side"])
		var wp: Vector3 = pp[0]
		if cam.is_position_behind(wp):
			continue
		var d := cam.unproject_position(wp + Vector3(0, 1.0, 0)).distance_to(pos)
		if d < bd:
			bd = d
			best = pd
	return best
func follow_citizen(chosen: Dictionary = {}) -> void:
	if peds.is_empty():
		toast("Todavía no hay gente en la calle")
		return
	var pd: Dictionary = chosen
	if pd.is_empty():
		pd = peds[randi() % peds.size()]
		if pd["kind"] == 2:
			pd = peds[0]
	follow_ped = pd
	var homes: Array = []
	var work: Array = []
	for i in zone_list:
		if lvl[i] > 0:
			if zone[i] == Z_R:
				homes.append(i)
			elif zone[i] == Z_C or zone[i] == Z_I:
				work.append(i)
	pd["home"] = homes[randi() % homes.size()] if not homes.is_empty() else -1
	pd["job"] = work[randi() % work.size()] if not work.is_empty() else -1
	cam_dist_goal = 30.0
	cam_follow = func():
		if follow_ped == null or not (follow_ped in peds):
			follow_ped = null
			hide_follow_card()
			return null
		var pp := path_pos([follow_ped["c"], follow_ped["n"]], follow_ped["t"], CELL * 0.42 * follow_ped["side"])
		return pp[0]
	show_follow_card(pd)
func draw_dynamic() -> void:
	if not opts["g_dyn"]:
		return
	crumb("móviles: armando (zoom %d)" % int(cam_dist))
	begin_buf()
	var nf := night
	var near := cam_dist < 220.0
	if (cam_dist < 260.0) != dyn_close:
		dyn_close = cam_dist < 260.0
		crumb("zoom %s a %d" % ["cerca" if dyn_close else "lejos", int(cam_dist)])
	var near2 := cam_dist < 90.0
	var wet_now := weather == "Lluvia" or weather == "Tormenta"
	var lit: bool = nf > 0.25 and near and opts["quality"] >= 1
	glow_n = 0
	for c in cars:
		var pr := path_pos_s(c["p"], c["k"], CELL * 0.18)
		var p: Vector3 = pr[0]
		var r: float = pr[1]
		var col: Color = c["col"]
		var fade := clampf(minf(c["k"], c["p"].size() - 1.0 - c["k"]) * 1.2, 0.0, 1.0)
		if fade < 0.05:
			continue
		var kd: int = c["kind"]
		if kd == 5:
			draw_moto(p, r, c, nf, lit and fade > 0.9, near2)
			continue
		if c.get("crash", 0.0) > 0.0:
			draw_crash(c, p, r, near2)
		var ln: float = [2.0, 1.9, 2.5, 2.0, 2.4][kd]
		var bh: float = [0.45, 0.56, 0.7, 0.45, 0.55][kd]
		var roofc: Color = c["roof"]
		var sr := sin(r)
		var cr := cos(r)
		var fw := fade
		em(M_BOX, p.x - sr * ln * 0.16, p.y + 0.2, p.z - cr * ln * 0.16, 0.95 * fw, bh * fw, ln * 0.68, r, col, 0, 0, 0, 1.5)
		em(M_BOX, p.x + sr * ln * 0.33, p.y + 0.2, p.z + cr * ln * 0.33, 0.9 * fw, bh * 0.72 * fw, ln * 0.34, r, col, 0, 0, 0, 1.5)
		var cl := ln * (0.85 if kd == 2 else 0.5)
		var ch := 0.4 + (0.25 if kd == 2 else 0.0)
		var cby := p.y + 0.2 + bh * 0.88
		em(M_SPH, p.x - sr * ln * 0.1, cby, p.z - cr * ln * 0.1, 0.84 * fw, ch * fw, cl, r, Color(0.07, 0.09, 0.12), 0, 0, 0, 1.5)
		em(M_BOX, p.x - sr * ln * 0.1, cby + ch * 0.82, p.z - cr * ln * 0.1, 0.66 * fw, 0.05 * fw, cl * 0.7, r, roofc, 0, 0, 0, 1.5)
		if near2:
			for sg in [-1.0, 1.0]:
				em(M_BOX, p.x + cr * sg * 0.52 + sr * ln * 0.12, p.y + 0.2 + bh * 0.95, p.z - sr * sg * 0.52 + cr * ln * 0.12, 0.1, 0.07, 0.12, r, roofc if kd != 3 else col, 0, 0, 0, 1.5)
			if kd == 3:
				em(M_BOX, p.x - sr * ln * 0.1, cby + ch * 0.9, p.z - cr * ln * 0.1, 0.32, 0.1, 0.18, r, Color(1.0, 0.95, 0.7), 0, 0, 0.5 + nf * 2.2)
		veh_lights(p, r, ln, 0.4, bh * 0.85 + 0.2, nf, lit and fade > 0.9, near2, 5.0)
	if drive != null:
		var pr2 := path_pos([drive["c"], drive["n"]], drive["t"], CELL * 0.18)
		var p2: Vector3 = pr2[0]
		em(M_BOX, p2.x, p2.y + 0.2, p2.z, 1.0, 0.6, 2.2, pr2[1], Color(0.95, 0.85, 0.1))
		em(M_BOX, p2.x, p2.y + 0.8, p2.z, 0.9, 0.45, 1.2, pr2[1], Color(0.2, 0.2, 0.25), 0.6)
	for v in svc:
		var pr3 := path_pos_s(v["p"], v["k"], CELL * 0.18)
		var p3: Vector3 = pr3[0]
		var r3: float = pr3[1]
		var body: Color = {"police": Color(0.95, 0.95, 0.97), "ambulance": Color(0.97, 0.97, 0.97), "fire": Color(0.85, 0.12, 0.1), "garbage": Color(0.3, 0.55, 0.3)}[v["kind"]]
		var ln3 := 3.0 if v["kind"] == "fire" or v["kind"] == "garbage" else 2.2
		em(M_BOX, p3.x, p3.y + 0.2, p3.z, 1.05, 1.0 if ln3 > 2.5 else 0.7, ln3, r3, body)
		if v["kind"] != "garbage":
			var on := int(anim_time * 6.0) % 2 == 0
			var lc := Color(0.2, 0.3, 1.0) if on else Color(1.0, 0.15, 0.1)
			if v["kind"] == "fire" or v["kind"] == "ambulance":
				lc = Color(1.0, 0.15, 0.1) if on else Color(1, 1, 1)
			em(M_BOX, p3.x, p3.y + 1.2, p3.z, 0.8, 0.2, 0.3, r3, lc, 0, 0, 3.0)
	if cam_dist < 260.0:
		var pclose := cam_dist < 70.0
		for pd in peds:
			var pr4 := path_pos([pd["c"], pd["n"]], pd["t"], CELL * 0.42 * pd["side"])
			var p4: Vector3 = pr4[0]
			var rp: float = pr4[1]
			var ph: float = anim_time * (8.0 if pd.get("panic", 0.0) <= 0.0 else 16.0) + pd["side"] * 3.0
			match pd["kind"]:
				2:
					em(M_BOX, p4.x, p4.y + 0.3, p4.z, 0.25, 0.3, 0.6, rp, Color(0.55, 0.35, 0.2))
					em(M_SPH, p4.x + sin(rp) * 0.35, p4.y + 0.55, p4.z + cos(rp) * 0.35, 0.22, 0.22, 0.28, rp, Color(0.55, 0.35, 0.2))
				3:
					draw_bike(p4, rp, pd, pclose)
				_:
					var s := 0.72 if pd["kind"] == 1 else 1.0
					var ex := 1 if pd["bag"] else 0
					if wet_now and hsh(int(pd["age"]) + int(pd["c"]), 5) < 0.7:
						ex |= 2
					if pd.get("panic", 0.0) > 0.0:
						ex |= 4
					draw_person(p4.x, p4.y, p4.z, rp, s, pd["col"], pd["pant"], pd["skin"], pd["hair"], ph, pclose, ex, pd["umb"])
					var rx4 := cos(rp)
					var rz4 := -sin(rp)
					for f in pd["comp"]:
						var off: float = f["off"]
						var fs: float = f["s"]
						var ex2 := 1 if f["bag"] else 0
						if ex & 2 and not f.has("hand"):
							ex2 |= 2
						if ex & 4:
							ex2 |= 4
						draw_person(p4.x + rx4 * off * pd["side"], p4.y, p4.z + rz4 * off * pd["side"], rp, fs, f["col"], f["pant"], f["skin"], f["hair"], ph + 1.3, pclose, ex2, f["umb"])
		for ln in lines:
			if ln["pts"].size() < 2 or not (ln["kind"] in ["bus", "tram"]):
				continue
			for s in ln["stops"]:
				var sp := cell_pos(s)
				for k in 2:
					draw_person(sp.x + CELL * 0.42, sp.y, sp.z + (k - 0.5) * 0.7, -PI * 0.5, 1.0, SHIRTS[int(hsh(s, k) * 12.0) % 12], PANTS[k % 5], SKINS[int(hsh(s, k + 3) * 5.0) % 5], HAIRS[k * 2 % 6], 0.0, cam_dist < 70.0, 0)
	for s in stops:
		var sp2 := cell_pos(s)
		em(M_BOX, sp2.x + CELL * 0.45, sp2.y, sp2.z, 0.12, 2.4, 0.12, 0.0, Color(0.95, 0.85, 0.2))
		em(M_BOX, sp2.x + CELL * 0.45, sp2.y + 2.2, sp2.z, 0.1, 0.5, 0.6, 0.0, Color(0.95, 0.85, 0.2) if stops[s] == "bus" else Color(0.9, 0.4, 0.2), 0, 0.6)
	var li := 0
	for ln in lines:
		var pts: Array = ln["pts"]
		if pts.size() < 2:
			li += 1
			continue
		var t: float = ln["t"] + 0.5
		var np := pts.size()
		var si := int(t) % np
		var bc := curve_at(pts[(si - 1 + np) % np], pts[si], pts[(si + 1) % np], t - floor(t))
		var tg5: Vector3 = bc[1]
		tg5.y = 0.0
		if tg5.length() < 0.001:
			tg5 = Vector3(1, 0, 0)
		tg5 = tg5.normalized()
		var p5: Vector3 = bc[0] + Vector3(-tg5.z, 0, tg5.x) * CELL * 0.18
		var r5 := atan2(tg5.x, tg5.z)
		var col5: Color = ln["col"]
		match ln["kind"]:
			"bus":
				var sb := sin(r5)
				var cb := cos(r5)
				em(M_BOX, p5.x, p5.y + 0.25, p5.z, 1.2, 0.75, 4.3, r5, col5, 0, 0, 0, 1.5)
				em(M_BOX, p5.x, p5.y + 1.0, p5.z, 1.18, 0.7, 4.2, r5, Color(0.93, 0.93, 0.95), 0, 0, 0, 1.5)
				em(M_BOX, p5.x, p5.y + 1.7, p5.z, 1.1, 0.12, 4.0, r5, Color(0.9, 0.9, 0.92))
				var wcol := Color(0.1, 0.14, 0.2).lerp(Color(1.0, 0.85, 0.55), nf)
				for sg in [-1.0, 1.0]:
					em(M_BOX, p5.x + cb * sg * 0.595, p5.y + 1.06, p5.z - sb * sg * 0.595, 0.04, 0.52, 3.9, r5, wcol, 0, 0, nf * 0.9)
					if near2:
						for pz in [-1.5, -0.5, 0.5, 1.5]:
							em(M_BOX, p5.x + cb * sg * 0.6 + sb * pz, p5.y + 1.0, p5.z - sb * sg * 0.6 + cb * pz, 0.05, 0.7, 0.07, r5, Color(0.93, 0.93, 0.95))
				em(M_BOX, p5.x + sb * 2.16, p5.y + 1.0, p5.z + cb * 2.16, 1.05, 0.6, 0.04, r5, Color(0.08, 0.11, 0.15).lerp(Color(1.0, 0.9, 0.65), nf * 0.7), 0, 0, nf * 0.6)
				em(M_BOX, p5.x + sb * 2.17, p5.y + 1.55, p5.z + cb * 2.17, 0.95, 0.2, 0.05, r5, Color(0.03, 0.03, 0.03), 0, 0, 0.0)
				em(M_BOX, p5.x + sb * 2.18, p5.y + 1.55, p5.z + cb * 2.18, 0.8, 0.12, 0.04, r5, Color(1.0, 0.55, 0.05), 0, 0, 1.8)
				if near2:
					em(M_BOX, p5.x - sb * 0.8, p5.y + 1.82, p5.z - cb * 0.8, 0.7, 0.15, 1.0, r5, Color(0.75, 0.75, 0.78))
				veh_lights(p5, r5, 4.2, 0.45, 0.5, nf, lit, near2, 8.0)
			"tram":
				em(M_BOX, p5.x, p5.y + 0.25, p5.z, 1.3, 1.7, 5.0, r5, col5, 0.6)
				em(M_BOX, p5.x, p5.y + 1.95, p5.z, 0.1, 0.8, 0.1, 0.0, Color(0.2, 0.2, 0.2))
			"train":
				for k in 3:
					var o := -Vector3(sin(r5), 0, cos(r5)) * k * 4.4
					em(M_BOX, p5.x + o.x, p5.y, p5.z + o.z, 1.6, 1.8, 4.2, r5, col5 if k == 0 else Color(0.85, 0.85, 0.88), 0.6)
			"ferry":
				em(M_BOX, p5.x, WATER_Y - 0.3, p5.z, 2.6, 1.0, 6.0, r5, Color(0.95, 0.95, 0.95))
				em(M_BOX, p5.x, WATER_Y + 0.7, p5.z, 2.0, 1.2, 3.0, r5, col5, 0.5)
			"metro":
				pass
		if li < line_labels.size():
			var lab: Label3D = line_labels[li]
			lab.visible = ln["kind"] == "bus" and cam_dist < 110.0
			lab.position = p5 + Vector3(sin(r5) * 2.21, 1.55, cos(r5) * 2.21)
			lab.rotation = Vector3(0, r5, 0)
			lab.text = str(ln["num"])
		li += 1
	while line_labels.size() < lines.size():
		var lab2 := Label3D.new()
		lab2.font_size = 64
		lab2.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		lab2.pixel_size = 0.0075
		lab2.outline_size = 0
		lab2.shaded = false
		lab2.double_sided = false
		lab2.modulate = Color(1.0, 0.22, 0.15)
		add_child(lab2)
		line_labels.append(lab2)
	for k in range(lines.size(), line_labels.size()):
		line_labels[k].visible = false
	for bt in boats:
		var p6: Vector3 = bt["p"]
		var r6 := atan2(bt["v"].x, bt["v"].z)
		if bt["kind"] == 0:
			em(M_BOX, p6.x, p6.y - 0.6, p6.z, 4.0, 2.0, 14.0, r6, Color(0.6, 0.15, 0.12))
			for k in 3:
				em(M_BOX, p6.x - sin(r6) * (k - 1) * 3.5, p6.y + 1.4, p6.z - cos(r6) * (k - 1) * 3.5, 3.2, 1.6, 3.0, r6, [Color(0.2, 0.4, 0.8), Color(0.85, 0.5, 0.15), Color(0.3, 0.6, 0.3)][k])
		else:
			em(M_BOX, p6.x, p6.y - 0.2, p6.z, 1.0, 0.6, 3.0, r6, Color(0.95, 0.95, 0.95))
			em(M_ROOF, p6.x, p6.y + 0.4, p6.z, 0.1, 3.0, 1.8, r6, Color(0.98, 0.98, 0.98))
	for pl in planes:
		var p7: Vector3 = pl["p"]
		var r7 := atan2(pl["v"].x, pl["v"].z)
		em(M_BOX, p7.x, p7.y, p7.z, 1.2, 1.2, 8.0, r7, Color(0.95, 0.95, 0.97))
		em(M_BOX, p7.x, p7.y + 0.3, p7.z, 9.0, 0.2, 1.8, r7, Color(0.85, 0.85, 0.9))
		em(M_BOX, p7.x - sin(r7) * 3.5, p7.y + 0.6, p7.z - cos(r7) * 3.5, 0.2, 1.8, 1.2, r7, Color(0.2, 0.4, 0.8))
	if cam_dist < 200.0:
		var ph := fmod(anim_time, 9.0)
		for c6 in tl_cells:
			var p8 := cell_pos(c6)
			var ns := ph < 4.0
			var yel := (ph > 4.0 and ph < 4.5) or ph > 8.5
			var lc2 := Color(1.0, 0.8, 0.1) if yel else (Color(0.2, 1.0, 0.3) if ns else Color(1.0, 0.15, 0.1))
			em(M_BOX, p8.x + CELL * 0.45, p8.y, p8.z + CELL * 0.45, 0.12, 2.8, 0.12, 0.0, Color(0.2, 0.2, 0.2))
			em(M_BOX, p8.x + CELL * 0.45, p8.y + 2.6, p8.z + CELL * 0.45, 0.3, 0.3, 0.3, 0.0, lc2, 0, 0, 2.0)
	for a in anchors:
		if bld[a] == 0:
			continue
		if bld[a] == 34:
			var pc := cell_pos(a)
			for k in 6:
				var ang := anim_time * 0.8 + k * TAU / 6.0
				em(M_BOX, pc.x + cos(ang) * 1.2, pc.y + 0.6 + sin(anim_time * 3.0 + k) * 0.15, pc.z + sin(ang) * 1.2, 0.3, 0.6, 0.7, -ang, Color.from_hsv(k / 6.0, 0.6, 0.95))
		elif bld[a] == 45:
			var pw := cell_pos(a)
			for k in 3:
				var ang2 := anim_time * 1.5 + k * TAU / 3.0
				em(M_BOX, pw.x + cos(ang2) * 2.2, pw.y + 11.0 + sin(ang2) * 2.2, pw.z + 0.7, 4.4, 0.35, 0.1, 0.0, Color(0.95, 0.95, 0.95))
	for c7 in anim_cells:
		var p9 := cell_pos(c7)
		var big: bool = part[c7] == c7
		var w := CELL * (1.8 if big else 0.8)
		var t2: float = anim_cells[c7]
		var target := 2.0 + lvl[c7] * 3.0 if zone[c7] > 0 else 4.0
		var h := target * clampf(1.0 - t2 / 1.5, 0.1, 1.0)
		var bx := p9.x + (CELL * 0.5 if big else 0.0)
		var bz := p9.z + (CELL * 0.5 if big else 0.0)
		em(M_BOX, bx, p9.y, bz, w * 0.8, h, w * 0.8, 0.0, Color(0.75, 0.72, 0.68))
		for k in 4:
			var ang3 := k * PI * 0.5 + 0.785
			em(M_BOX, bx + cos(ang3) * w * 0.48, p9.y, bz + sin(ang3) * w * 0.48, 0.1, h + 0.8, 0.1, 0.0, Color(0.9, 0.6, 0.2))
		if target > 6.0:
			em(M_BOX, bx + w * 0.6, p9.y, bz, 0.25, target + 4.0, 0.25, 0.0, Color(0.95, 0.75, 0.1))
			em(M_BOX, bx + w * 0.6 - 2.0, p9.y + target + 3.8, bz, 6.0, 0.25, 0.25, 0.0, Color(0.95, 0.75, 0.1))
		if randf() < 0.05:
			parts.append({"p": Vector3(bx, p9.y + 0.5, bz), "v": Vector3(randf_range(-1, 1), 1.0, randf_range(-1, 1)), "t": 1.2, "g": 0.0, "col": Color(0.8, 0.75, 0.65), "s": 0.9})
	for i in N * N:
		if burn[i] > 0.0:
			emit_flames(cell_pos(i), i)
	if flag_days > 0 and cam_dist < 250.0:
		var nflag := 0
		for i in zone_list:
			if lvl[i] >= 2 and hsh(i, 99) < 0.12:
				var fr := face_rot(i)
				var pfl := cell_pos(i) + Vector3(sin(fr) * CELL * 0.44 + cos(fr) * CELL * 0.4, 0.1, cos(fr) * CELL * 0.44 - sin(fr) * CELL * 0.4)
				var hh := 0.0
				var wv := sin(anim_time * 4.0 + i) * 0.2
				em(M_BOX, pfl.x, pfl.y, pfl.z, 0.08, 4.6, 0.08, 0.0, Color(0.8, 0.8, 0.8))
				em(M_BOX, pfl.x + 0.6, pfl.y + hh + 4.2, pfl.z, 1.2, 0.25, 0.05, wv, Color(0.45, 0.75, 0.95))
				em(M_BOX, pfl.x + 0.6, pfl.y + hh + 3.95, pfl.z, 1.2, 0.25, 0.05, wv, Color(1, 1, 1))
				em(M_BOX, pfl.x + 0.6, pfl.y + hh + 3.7, pfl.z, 1.2, 0.25, 0.05, wv, Color(0.45, 0.75, 0.95))
				nflag += 1
				if nflag > 60:
					break
	draw_stars(nf)
	if flash_t > 0.0:
		# el rayo: tramos en zigzag del cielo al suelo
		var a := bolt_p + Vector3(0, 70, 0)
		var bc := Color(0.85, 0.9, 1.0)
		for k in 9:
			var b := a + Vector3((hsh(bolt_seed % 9973, k) - 0.5) * 6.0, -70.0 / 9.0, (hsh(bolt_seed % 9973, k + 20) - 0.5) * 6.0)
			if k == 8:
				b.y = bolt_p.y
			# tramo que baja y quiebre hacia el costado
			em(M_BOX, a.x, b.y, a.z, 0.55, a.y - b.y, 0.55, 0.0, bc, 0, 0, 8.0)
			var hz := Vector2(b.x - a.x, b.z - a.z)
			em(M_BOX, (a.x + b.x) * 0.5, b.y, (a.z + b.z) * 0.5, 0.55, 0.55, hz.length() + 0.55, atan2(hz.x, hz.y), bc, 0, 0, 8.0)
			a = b
	for p in parts:
		var pp: Vector3 = p["p"]
		var s2: float = p["s"]
		em(M_BOX if p.has("glow") else M_SPH, pp.x, pp.y, pp.z, s2, s2, s2, p["t"] * 3.0, p["col"], 0, 0, p.get("glow", 0.0))
	if weather in ["Lluvia", "Tormenta", "Nieve"] and opts["quality"] >= 1 and not opts["g_rain"]:
		var snow := weather == "Nieve"
		for k in 160:
			var rx := cam_target.x + (hsh(k, 1) - 0.5) * cam_dist * 1.4
			var rz := cam_target.z + (hsh(k, 2) - 0.5) * cam_dist * 1.4
			var fall := 30.0 if not snow else 5.0
			var ry := 40.0 - fmod(anim_time * fall + hsh(k, 3) * 40.0, 40.0)
			if snow:
				em(M_SPH, rx + sin(anim_time + k) * 0.5, ry, rz, 0.35, 0.35, 0.35, 0.0, Color(1, 1, 1))
			else:
				em(M_BOX, rx, ry, rz, 0.05, 1.6, 0.05, 0.0, Color(0.7, 0.75, 0.85))
	crumb("móviles: subiendo a la placa (%d autos, %d vecinos)" % [cars.size(), peds.size()])
	if nf > 0.3 and cam_dist < 240.0 and opts["quality"] >= 1:
		var rr := cam_dist * 1.2 + 30.0
		var inten := clampf((nf - 0.3) * 1.6, 0.0, 1.0)
		var shown := 0
		for k in lamps:
			var lp: Vector3 = lamps[k]
			if absf(lp.x - cam_target.x) > rr or absf(lp.z - cam_target.z) > rr:
				continue
			gl(1.0, lp.x, lp.y + 0.34, lp.z, 7.5 + (3.0 if wet_now else 0.0), 7.5 + (3.0 if wet_now else 0.0), 0.0, Color(1.0, 0.8, 0.45, (0.5 + (0.25 if wet_now else 0.0)) * inten))
			shown += 1
			if shown > 260:
				break
	flush_mm(glow_node.multimesh, glow_n, glow_buf)
	for m in NMESH:
		var node: MultiMeshInstance3D = dyn_nodes[m]
		flush_mm(node.multimesh, _counts[m], _bufs[m])
const SHIRTS := [Color(0.12, 0.16, 0.3), Color(0.08, 0.08, 0.09), Color(0.9, 0.9, 0.88), Color(0.5, 0.5, 0.52), Color(0.76, 0.68, 0.55), Color(0.65, 0.12, 0.12), Color(0.36, 0.38, 0.22), Color(0.78, 0.6, 0.18), Color(0.3, 0.42, 0.6), Color(0.85, 0.55, 0.6), Color(0.2, 0.45, 0.3), Color(0.42, 0.28, 0.18)]
const PANTS := [Color(0.18, 0.25, 0.42), Color(0.07, 0.07, 0.08), Color(0.6, 0.55, 0.42), Color(0.35, 0.35, 0.37), Color(0.4, 0.5, 0.65)]
const SKINS := [Color(0.95, 0.78, 0.65), Color(0.87, 0.66, 0.5), Color(0.72, 0.52, 0.38), Color(0.55, 0.38, 0.26), Color(0.38, 0.26, 0.18)]
const HAIRS := [Color(0.06, 0.05, 0.05), Color(0.2, 0.13, 0.08), Color(0.38, 0.25, 0.15), Color(0.82, 0.68, 0.42), Color(0.7, 0.7, 0.7), Color(0.55, 0.22, 0.1)]
const UMBS := [Color(0.1, 0.1, 0.12), Color(0.75, 0.1, 0.12), Color(0.15, 0.3, 0.7), Color(0.95, 0.75, 0.1), Color(0.2, 0.55, 0.35), Color(0.85, 0.4, 0.6)]
func rand_look() -> Dictionary:
	return {"col": SHIRTS[randi() % SHIRTS.size()], "pant": PANTS[randi() % PANTS.size()], "skin": SKINS[randi() % SKINS.size()], "hair": HAIRS[randi() % HAIRS.size()], "bag": randf() < 0.3, "umb": UMBS[randi() % UMBS.size()]}
func new_ped(c: int, kind: int) -> Dictionary:
	var pd := rand_look()
	pd.merge({"c": c, "n": c, "t": 0.0, "kind": kind, "side": 1.0 if randf() < 0.5 else -1.0, "name": rand_name(), "age": 8 + randi() % 70, "home": -1, "job": -1, "panic": 0.0})
	var comp: Array = []
	if kind == 0:
		var r := randf()
		if r < 0.22:
			var f := rand_look()
			f["off"] = 0.55
			f["s"] = 0.92 + randf() * 0.12
			comp.append(f)
			if randf() < 0.3:
				var f2 := rand_look()
				f2["off"] = -0.55
				f2["s"] = 0.95
				comp.append(f2)
		elif r < 0.32:
			var k := rand_look()
			k["off"] = 0.42
			k["s"] = 0.62
			k["bag"] = false
			k["hand"] = true
			comp.append(k)
	pd["comp"] = comp
	return pd
func draw_person(x: float, y: float, z: float, rp: float, s: float, shirt: Color, pant: Color, skin: Color, hair: Color, ph: float, close: bool, extra: int, umb: Color = Color.BLACK) -> void:
	var fx := sin(rp)
	var fz := cos(rp)
	var rx := cos(rp)
	var rz := -sin(rp)
	if close:
		var sw := sin(ph) * 0.13 * s
		for sg in [-1.0, 1.0]:
			var g: float = sg
			em(M_CYL, x + rx * g * 0.075 * s + fx * sw * g, y, z + rz * g * 0.075 * s + fz * sw * g, 0.12 * s, 0.5 * s, 0.12 * s, 0.0, pant)
			em(M_SPH, x + rx * g * 0.075 * s + fx * (sw * g + 0.03 * s), y, z + rz * g * 0.075 * s + fz * (sw * g + 0.03 * s), 0.12 * s, 0.07 * s, 0.18 * s, rp, Color(0.12, 0.1, 0.09))
			var ay := 0.5 * s if extra & 4 == 0 else 0.78 * s
			var asw := -sw * g if extra & 4 == 0 else sin(ph * 2.0 + g) * 0.05 * s
			em(M_CYL, x + rx * g * 0.2 * s + fx * asw, y + ay, z + rz * g * 0.2 * s + fz * asw, 0.08 * s, 0.4 * s, 0.08 * s, 0.0, shirt.darkened(0.1))
		em(M_SPH, x, y + 0.44 * s, z, 0.34 * s, 0.56 * s, 0.22 * s, rp, shirt)
		em(M_SPH, x, y + 0.86 * s, z, 0.22 * s, 0.26 * s, 0.22 * s, rp, skin)
		em(M_SPH, x - fx * 0.02 * s, y + 0.99 * s, z - fz * 0.02 * s, 0.23 * s, 0.15 * s, 0.23 * s, rp, hair)
		if extra & 1:
			em(M_BOX, x - fx * 0.15 * s, y + 0.55 * s, z - fz * 0.15 * s, 0.26 * s, 0.32 * s, 0.12 * s, rp, Color(0.15, 0.17, 0.2))
	else:
		em(M_CYL, x, y, z, 0.24 * s, 0.5 * s, 0.24 * s, 0.0, pant)
		em(M_SPH, x, y + 0.44 * s, z, 0.34 * s, 0.56 * s, 0.24 * s, rp, shirt)
		em(M_SPH, x, y + 0.88 * s, z, 0.24 * s, 0.28 * s, 0.24 * s, 0.0, skin.lerp(hair, 0.4))
	if extra & 2:
		em(M_BOX, x + rx * 0.18 * s, y + 0.75 * s, z + rz * 0.18 * s, 0.03, 0.8 * s, 0.03, 0.0, Color(0.2, 0.2, 0.2))
		em(M_SPH, x + rx * 0.1 * s, y + 1.45 * s, z + rz * 0.1 * s, 1.0 * s, 0.28 * s, 1.0 * s, 0.0, umb)
func draw_bike(p: Vector3, rp: float, pd: Dictionary, close: bool) -> void:
	var fx := sin(rp)
	var fz := cos(rp)
	var fc := Color(0.75, 0.12, 0.1) if hsh(int(pd["age"]), 3) < 0.5 else Color(0.15, 0.4, 0.7)
	for sg in [-0.42, 0.42]:
		var g: float = sg
		em(M_SPH, p.x + fx * g, p.y, p.z + fz * g, 0.06, 0.62, 0.62, rp, Color(0.08, 0.08, 0.08))
	em(M_BOX, p.x, p.y + 0.3, p.z, 0.06, 0.06, 0.84, rp, fc)
	em(M_BOX, p.x - fx * 0.12, p.y + 0.3, p.z - fz * 0.12, 0.06, 0.4, 0.06, rp, fc)
	draw_person(p.x - fx * 0.1, p.y + 0.35, p.z - fz * 0.1, rp, 0.9, pd["col"], pd["pant"], pd["skin"], pd["hair"], anim_time * 9.0, close, 1 if pd["bag"] else 0)
func draw_moto(p: Vector3, r: float, c: Dictionary, nf: float, lit: bool, close: bool) -> void:
	var fx := sin(r)
	var fz := cos(r)
	for sg in [-0.62, 0.6]:
		var g: float = sg
		em(M_SPH, p.x + fx * g, p.y + 0.02, p.z + fz * g, 0.14, 0.6, 0.6, r, Color(0.06, 0.06, 0.06))
	em(M_BOX, p.x, p.y + 0.35, p.z, 0.32, 0.35, 1.2, r, c["col"], 0, 0, 0, 1.5)
	em(M_BOX, p.x + fx * 0.5, p.y + 0.6, p.z + fz * 0.5, 0.5, 0.06, 0.06, r, Color(0.1, 0.1, 0.1))
	var look: Dictionary = c["look"]
	draw_person(p.x - fx * 0.05, p.y + 0.45, p.z - fz * 0.05, r, 0.9, look["col"], look["pant"], look["skin"], Color(0.1, 0.1, 0.12) if c["deli"] else Color(0.85, 0.85, 0.88), 0.0, close, 0)
	if c["deli"]:
		em(M_BOX, p.x - fx * 0.55, p.y + 0.7, p.z - fz * 0.55, 0.5, 0.5, 0.5, r, c["box"])
	if lit:
		em(M_BOX, p.x + fx * 0.62, p.y + 0.55, p.z + fz * 0.62, 0.12, 0.12, 0.05, r, Color(1.0, 0.95, 0.8), 0, 0, 3.0)
		gl(2.0, p.x + fx * 0.66, p.y + 0.55, p.z + fz * 0.66, 1.0, 1.0, 0.0, Color(1.0, 0.93, 0.75, 0.8), 0.6)
		gl(0.0, p.x + fx * 3.2, p.y + 0.33, p.z + fz * 3.2, 1.2, 5.0, r, Color(1.0, 0.9, 0.7, 0.35))
var crash_cool: float = 20.0
func check_crash(dt: float) -> void:
	crash_cool -= dt
	if crash_cool > 0.0 or cars.size() < 6:
		return
	crash_cool = 4.0
	if randf() > 0.25:
		return
	var by_cell := {}
	for c in cars:
		if c.get("crash", 0.0) > 0.0:
			return
		var p: Array = c["p"]
		var i: int = clampi(int(c["k"]), 0, p.size() - 1)
		var j: int = mini(i + 1, p.size() - 1)
		var cell: int = p[i]
		if by_cell.has(cell):
			var o: Dictionary = by_cell[cell]
			var op: Array = o["p"]
			var oi: int = clampi(int(o["k"]), 0, op.size() - 1)
			var oj: int = mini(oi + 1, op.size() - 1)
			if op[oj] != p[j] and road[cell] >= 2:
				c["crash"] = 26.0
				o["crash"] = 26.0
				c["argue"] = rand_look()
				o["argue"] = rand_look()
				crash_cool = 90.0
				var cp := cell_pos(cell)
				for k in 6:
					parts.append({"p": cp + Vector3(randf_range(-0.6, 0.6), 0.8, randf_range(-0.6, 0.6)), "v": Vector3(randf_range(-1, 1), 2.0, randf_range(-1, 1)), "t": 1.5, "g": 0.2, "col": Color(0.75, 0.75, 0.75), "s": 0.7})
				if Vector2(cam_target.x - cp.x, cam_target.z - cp.z).length() < 150.0:
					toast("💥 Choque en " + street_name(cell) + ": los conductores se bajaron a discutir")
					sfx("horn")
				return
		else:
			by_cell[cell] = c
func draw_crash(c: Dictionary, p: Vector3, r: float, close: bool) -> void:
	var on := int(anim_time * 3.0) % 2 == 0
	if on:
		for sg in [-1.0, 1.0]:
			var g: float = sg
			for fb in [-1.0, 1.0]:
				var b: float = fb
				gl(2.0, p.x + cos(r) * g * 0.45 + sin(r) * b * 1.0, p.y + 0.55, p.z - sin(r) * g * 0.45 + cos(r) * b * 1.0, 1.0, 1.0, 0.0, Color(1.0, 0.6, 0.1, 0.9), 0.5)
	if close:
		var lk: Dictionary = c["argue"]
		var ax := p.x + cos(r) * 1.4
		var az := p.z - sin(r) * 1.4
		draw_person(ax, p.y, az, r + PI * 0.5 + sin(anim_time * 2.0) * 0.4, 1.0, lk["col"], lk["pant"], lk["skin"], lk["hair"], anim_time * 6.0, true, 4)
const MOVIES := [
	{"t": "Scream", "cast": ["ghostface"], "h": true, "d": "Ghostface va a andar suelto persiguiendo vecinos"},
	{"t": "Chucky: el muñeco diabólico", "cast": ["chucky"], "h": true, "d": "Chucky se escapó de la caja y anda por las veredas"},
	{"t": "It", "cast": ["pennywise"], "h": true, "d": "Pennywise reparte globos rojos... y sustos"},
	{"t": "Viernes 13", "cast": ["jason"], "h": true, "d": "Jason Voorhees salió del lago con su machete"},
	{"t": "Halloween", "cast": ["michael"], "h": true, "d": "Michael Myers camina despacio detrás de la gente"},
	{"t": "Terminator", "cast": ["t800"], "h": true, "d": "Un T-800 busca a alguien llamado Sarah Connor"},
	{"t": "Avengers", "cast": ["hulk", "ironman", "cap", "thor"], "h": false, "d": "Los Vengadores recorren la ciudad saludando a todos"},
	{"t": "Cazafantasmas", "cast": ["buster", "buster", "buster", "ghost", "ghost"], "h": false, "d": "Los Cazafantasmas persiguen fantasmas por las calles"},
	{"t": "Star Wars", "cast": ["vader", "trooper", "trooper", "trooper", "trooper"], "h": false, "d": "Darth Vader desfila con sus soldados imperiales"},
	{"t": "Jurassic Park", "cast": ["trex"], "h": false, "d": "Un T-Rex se escapó: la gente corre a esconderse"},
	{"t": "Spider-Man", "cast": ["spidey"], "h": false, "d": "Spider-Man salta de techo en techo"},
	{"t": "Mi villano favorito", "cast": ["minion", "minion", "minion", "minion", "minion", "minion"], "h": false, "d": "Los Minions invaden las veredas"},
	{"t": "Shrek", "cast": ["shrek", "burro"], "h": false, "d": "Shrek y Burro pasean por el barrio"},
	{"t": "Godzilla", "cast": ["godzilla"], "h": false, "d": "Godzilla cruza la ciudad: todos corren"},
]
const SCARY := ["ghostface", "chucky", "pennywise", "jason", "michael", "t800", "trex", "godzilla"]
const KILLERS := ["ghostface", "chucky", "pennywise", "jason", "michael", "t800"]
var movie_end_day: int = 0
var cine_last: int = -1
var movie_scared: int = 0
func cinema_cell() -> int:
	for a in anchors:
		if bld[a] == 66 and def_active(a):
			return a
	return -1
func cine_daily() -> void:
	if movie_on >= 0 and day >= movie_end_day:
		var m: Dictionary = MOVIES[movie_on]
		if m["h"] and movie_scared > 0:
			toast("🎬 Terminó \"%s\": %d vecinos se desmayaron del susto" % [m["t"], movie_scared])
		stars.clear()
		movie_on = -1
	var cc := cinema_cell()
	if cc < 0 or movie_on >= 0:
		return
	if cine_next_day == 0:
		cine_next_day = day + 1
	if day >= cine_next_day:
		var k := randi() % MOVIES.size()
		if k == cine_last:
			k = (k + 1) % MOVIES.size()
		start_movie(k, cc)
		cine_next_day = day + 3 + randi() % 3
func start_movie(k: int, origin: int) -> void:
	movie_on = k
	cine_last = k
	movie_end_day = day + 1
	movie_scared = 0
	stars.clear()
	var m: Dictionary = MOVIES[k]
	var roads_near: Array = []
	for i in road_list:
		if road[i] >= 2 and terr[i] != T_WATER and absi(cx(i) - cx(origin)) < 8 and absi(cz(i) - cz(origin)) < 8:
			roads_near.append(i)
	if roads_near.is_empty():
		roads_near = road_list.duplicate()
	if roads_near.is_empty():
		return
	for who in m["cast"]:
		var c: int = roads_near[randi() % roads_near.size()]
		stars.append({"who": who, "c": c, "n": c, "t": 0.0, "side": 1.0 if randf() < 0.5 else -1.0, "cool": 3.0, "jump": 0.0, "pos": cell_pos(c), "r": 0.0, "fly": Vector3.ZERO})
	queue_card({"title": "🎬 Estreno en el cine", "text": "Hoy se estrena \"%s\". Durante 24 horas: %s." % [m["t"], m["d"]], "btns": [["¡A verlo!", func(): look_star()], ["Dale", Callable()]]})
func look_star() -> void:
	if stars.is_empty():
		return
	var p: Vector3 = stars[0]["pos"]
	cam_goal = p
	cam_dist_goal = 22.0
func star_step(st: Dictionary, to: int) -> void:
	var c: int = st["c"]
	var opts2: Array = []
	for o in [1, -1, N, -N]:
		var j: int = c + o
		if j >= 0 and j < N * N and road[j] >= 2 and terr[j] != T_WATER:
			if (o == 1 or o == -1) and cz(j) != cz(c):
				continue
			opts2.append(j)
	if opts2.is_empty():
		st["n"] = c
		return
	if to >= 0 and randf() < 0.85:
		var best: int = opts2[0]
		var bd := 1e9
		for j in opts2:
			var d := Vector2(cx(j) - cx(to), cz(j) - cz(to)).length()
			if d < bd:
				bd = d
				best = j
		st["n"] = best
	else:
		st["n"] = opts2[randi() % opts2.size()]
func ped_pos(pd: Dictionary) -> Vector3:
	var pr := path_pos([pd["c"], pd["n"]], pd["t"], CELL * 0.42 * pd["side"])
	return pr[0]
func move_stars(dt: float) -> void:
	if stars.is_empty():
		var keep0: Array = []
		for dn in downs:
			dn["t"] = dn["t"] - dt
			if dn["t"] > 0.0:
				keep0.append(dn)
		downs = keep0
		return
	for st in stars:
		var who: String = st["who"]
		var spd := 0.7
		if who == "godzilla":
			spd = 0.25
		elif who == "trex":
			spd = 0.6
		elif who == "michael":
			spd = 0.35
		elif who == "minion":
			spd = 0.55
		st["cool"] = st["cool"] - dt
		st["jump"] = maxf(st["jump"] - dt, 0.0)
		var target := -1
		var killer: bool = who in KILLERS
		var tp := Vector3.ZERO
		var victim = null
		if killer and not peds.is_empty():
			var bd := 400.0
			var sp: Vector3 = st["pos"]
			for pd in peds:
				if pd == follow_ped or pd["kind"] == 2:
					continue
				var pp := ped_pos(pd)
				var d := pp.distance_squared_to(sp)
				if d < bd:
					bd = d
					victim = pd
					tp = pp
			if victim != null:
				target = victim["c"]
				if bd < 1.4 and st["cool"] <= 0.0:
					peds.erase(victim)
					downs.append({"p": tp, "r": randf() * TAU, "col": victim["col"], "skin": victim["skin"], "t": 14.0})
					movie_scared += 1
					st["cool"] = 7.0
					if movie_scared % 3 == 1:
						dispatch_from("ambulance", 22, int(victim["c"]))
		if who == "ironman":
			var fl: Vector3 = st["fly"]
			var sp2: Vector3 = st["pos"]
			if fl == Vector3.ZERO or sp2.distance_to(fl) < 3.0:
				var rc: int = road_list[randi() % road_list.size()] if not road_list.is_empty() else 0
				st["fly"] = cell_pos(rc) + Vector3(0, 9.0, 0)
				fl = st["fly"]
			var dv := (fl - sp2)
			if dv.length() > 0.01:
				st["r"] = atan2(dv.x, dv.z)
				st["pos"] = sp2 + dv.normalized() * minf(dt * 9.0, dv.length())
			continue
		st["t"] = st["t"] + dt * spd * (1.6 if killer and victim != null else 1.0)
		if st["t"] >= 1.0:
			st["t"] = 0.0
			st["c"] = st["n"]
			star_step(st, target)
			if (who == "spidey" or who == "hulk") and randf() < 0.35:
				st["jump"] = 1.4
		var pr := path_pos([st["c"], st["n"]], st["t"], CELL * 0.3 * st["side"])
		st["pos"] = pr[0]
		st["r"] = pr[1]
	if movie_on >= 0 and MOVIES[movie_on]["cast"][0] in SCARY:
		for pd in peds:
			if pd["panic"] > 0.0:
				pd["panic"] = pd["panic"] - dt
		for st in stars:
			if not (st["who"] in SCARY):
				continue
			var sp3: Vector3 = st["pos"]
			var rr := 64.0 if st["who"] != "godzilla" else 400.0
			for pd in peds:
				if ped_pos(pd).distance_squared_to(sp3) < rr:
					pd["panic"] = 3.0
	var keep: Array = []
	for dn in downs:
		dn["t"] = dn["t"] - dt
		if dn["t"] > 0.0:
			keep.append(dn)
	downs = keep
func hum(p: Vector3, r: float, s: float, body: Color, legs: Color, head: Color, arms: Color, ph: float) -> void:
	var fx := sin(r)
	var fz := cos(r)
	var rx := cos(r)
	var rz := -sin(r)
	var sw := sin(ph) * 0.13 * s
	for sg in [-1.0, 1.0]:
		var g: float = sg
		em(M_CYL, p.x + rx * g * 0.09 * s + fx * sw * g, p.y, p.z + rz * g * 0.09 * s + fz * sw * g, 0.15 * s, 0.52 * s, 0.15 * s, 0.0, legs)
		em(M_CYL, p.x + rx * g * 0.24 * s - fx * sw * g, p.y + 0.5 * s, p.z + rz * g * 0.24 * s - fz * sw * g, 0.11 * s, 0.44 * s, 0.11 * s, 0.0, arms)
	em(M_SPH, p.x, p.y + 0.45 * s, p.z, 0.42 * s, 0.58 * s, 0.28 * s, r, body)
	em(M_SPH, p.x, p.y + 0.9 * s, p.z, 0.26 * s, 0.3 * s, 0.26 * s, r, head)
func draw_stars(nf: float) -> void:
	var close := cam_dist < 110.0
	for dn in downs:
		var dp: Vector3 = dn["p"]
		var dr: float = dn["r"]
		em(M_SPH, dp.x, dp.y + 0.02, dp.z, 0.34, 0.24, 0.9, dr, dn["col"])
		em(M_SPH, dp.x + sin(dr) * 0.55, dp.y + 0.02, dp.z + cos(dr) * 0.55, 0.24, 0.22, 0.24, 0.0, dn["skin"])
	for st in stars:
		var p: Vector3 = st["pos"]
		var r: float = st["r"]
		var who: String = st["who"]
		var ph := anim_time * 8.0 + float(st["side"])
		var fx := sin(r)
		var fz := cos(r)
		var rx := cos(r)
		var rz := -sin(r)
		var jy: float = st["jump"]
		if jy > 0.0:
			p.y += sin(jy / 1.4 * PI) * (9.0 if who == "spidey" else 4.0)
		match who:
			"ghostface":
				em(M_CONE, p.x, p.y, p.z, 0.7, 1.1, 0.7, 0.0, Color(0.04, 0.04, 0.05))
				em(M_SPH, p.x, p.y + 0.62, p.z, 0.45, 0.6, 0.3, r, Color(0.04, 0.04, 0.05))
				em(M_SPH, p.x + fx * 0.04, p.y + 1.0, p.z + fz * 0.04, 0.24, 0.36, 0.24, r, Color(0.95, 0.95, 0.93))
				em(M_SPH, p.x + fx * 0.14 + rx * 0.07, p.y + 1.18, p.z + fz * 0.14 + rz * 0.07, 0.06, 0.1, 0.04, r, Color(0.02, 0.02, 0.02))
				em(M_SPH, p.x + fx * 0.14 - rx * 0.07, p.y + 1.18, p.z + fz * 0.14 - rz * 0.07, 0.06, 0.1, 0.04, r, Color(0.02, 0.02, 0.02))
				em(M_BOX, p.x + rx * 0.3 + fx * 0.15, p.y + 0.85 + sin(ph * 0.5) * 0.15, p.z + rz * 0.3 + fz * 0.15, 0.04, 0.38, 0.08, r, Color(0.8, 0.82, 0.85), 0, 0, 0, 1.5)
				em(M_SPH, p.x + rx * 0.3, p.y + 0.72, p.z + rz * 0.3, 0.12, 0.12, 0.12, 0.0, Color(0.04, 0.04, 0.05))
			"chucky":
				hum(p, r, 0.55, Color(0.25, 0.4, 0.75), Color(0.25, 0.4, 0.75), Color(0.95, 0.78, 0.65), Color(0.85, 0.15, 0.15), ph * 1.5)
				em(M_SPH, p.x - fx * 0.03, p.y + 0.62, p.z - fz * 0.03, 0.17, 0.12, 0.17, r, Color(0.9, 0.4, 0.1))
				em(M_BOX, p.x + rx * 0.16, p.y + 0.42, p.z + rz * 0.16, 0.03, 0.25, 0.05, r, Color(0.8, 0.82, 0.85), 0, 0, 0, 1.5)
			"pennywise":
				hum(p, r, 1.05, Color(0.92, 0.92, 0.88), Color(0.92, 0.92, 0.88), Color(0.97, 0.97, 0.96), Color(0.92, 0.92, 0.88), ph)
				for k in 3:
					em(M_SPH, p.x + fx * 0.15, p.y + 0.4 + k * 0.17, p.z + fz * 0.15, 0.08, 0.08, 0.08, 0.0, Color(0.95, 0.45, 0.1))
				em(M_SPH, p.x + rx * 0.15, p.y + 1.05, p.z + rz * 0.15, 0.14, 0.14, 0.14, 0.0, Color(0.85, 0.25, 0.1))
				em(M_SPH, p.x - rx * 0.15, p.y + 1.05, p.z - rz * 0.15, 0.14, 0.14, 0.14, 0.0, Color(0.85, 0.25, 0.1))
				em(M_BOX, p.x + rx * 0.3, p.y + 0.9, p.z + rz * 0.3, 0.02, 1.3, 0.02, 0.0, Color(0.9, 0.9, 0.9))
				em(M_SPH, p.x + rx * 0.3, p.y + 2.2 + sin(anim_time * 2.0) * 0.08, p.z + rz * 0.3, 0.42, 0.5, 0.42, 0.0, Color(0.85, 0.05, 0.05), 0, 0, 0.0, 1.5)
			"jason":
				hum(p, r, 1.15, Color(0.22, 0.26, 0.2), Color(0.18, 0.18, 0.2), Color(0.88, 0.86, 0.8), Color(0.22, 0.26, 0.2), ph * 0.8)
				em(M_BOX, p.x + rx * 0.32 + fx * 0.25, p.y + 0.65, p.z + rz * 0.32 + fz * 0.25, 0.05, 0.08, 0.6, r, Color(0.75, 0.77, 0.8), 0, 0, 0, 1.5)
				em(M_SPH, p.x + fx * 0.12 + rx * 0.06, p.y + 1.18, p.z + fz * 0.12 + rz * 0.06, 0.03, 0.03, 0.03, 0.0, Color(0.7, 0.1, 0.1))
				em(M_SPH, p.x + fx * 0.12 - rx * 0.06, p.y + 1.18, p.z + fz * 0.12 - rz * 0.06, 0.03, 0.03, 0.03, 0.0, Color(0.7, 0.1, 0.1))
			"michael":
				hum(p, r, 1.15, Color(0.15, 0.2, 0.3), Color(0.15, 0.2, 0.3), Color(0.93, 0.93, 0.9), Color(0.15, 0.2, 0.3), ph * 0.5)
				em(M_SPH, p.x - fx * 0.03, p.y + 1.2, p.z - fz * 0.03, 0.28, 0.14, 0.28, r, Color(0.2, 0.15, 0.1))
				em(M_BOX, p.x + rx * 0.3, p.y + 0.55, p.z + rz * 0.3, 0.03, 0.36, 0.06, r, Color(0.8, 0.82, 0.85), 0, 0, 0, 1.5)
			"t800":
				hum(p, r, 1.15, Color(0.05, 0.05, 0.06), Color(0.08, 0.08, 0.1), Color(0.8, 0.62, 0.5), Color(0.05, 0.05, 0.06), ph * 0.8)
				em(M_BOX, p.x + fx * 0.14, p.y + 1.1, p.z + fz * 0.14, 0.26, 0.06, 0.04, r, Color(0.02, 0.02, 0.02))
				em(M_SPH, p.x + fx * 0.16 + rx * 0.06, p.y + 1.11, p.z + fz * 0.16 + rz * 0.06, 0.04, 0.04, 0.03, 0.0, Color(1.0, 0.1, 0.05), 0, 0, 3.0)
			"hulk":
				hum(p, r, 1.9, Color(0.3, 0.6, 0.22), Color(0.4, 0.2, 0.5), Color(0.3, 0.6, 0.22), Color(0.3, 0.6, 0.22), ph * 0.7)
				em(M_SPH, p.x - fx * 0.03, p.y + 1.9, p.z - fz * 0.03, 0.5, 0.2, 0.5, r, Color(0.06, 0.06, 0.06))
			"ironman":
				hum(p, r, 1.1, Color(0.75, 0.1, 0.08), Color(0.75, 0.1, 0.08), Color(0.85, 0.7, 0.2), Color(0.85, 0.7, 0.2), 0.0)
				em(M_SPH, p.x + fx * 0.15, p.y + 0.6, p.z + fz * 0.15, 0.12, 0.12, 0.05, 0.0, Color(0.6, 0.9, 1.0), 0, 0, 3.0)
				gl(2.0, p.x, p.y - 0.1, p.z, 1.0, 1.0, 0.0, Color(0.7, 0.9, 1.0, 0.9), 0.9)
			"cap":
				hum(p, r, 1.15, Color(0.15, 0.25, 0.6), Color(0.15, 0.25, 0.6), Color(0.15, 0.25, 0.6), Color(0.15, 0.25, 0.6), ph)
				em(M_CYL, p.x + rx * 0.38, p.y + 0.5, p.z + rz * 0.38, 0.62, 0.06, 0.62, 0.0, Color(0.8, 0.1, 0.1))
				em(M_CYL, p.x + rx * 0.38, p.y + 0.52, p.z + rz * 0.38, 0.42, 0.06, 0.42, 0.0, Color(0.95, 0.95, 0.95))
				em(M_CYL, p.x + rx * 0.38, p.y + 0.54, p.z + rz * 0.38, 0.24, 0.06, 0.24, 0.0, Color(0.15, 0.25, 0.7))
				em(M_SPH, p.x + fx * 0.05, p.y + 0.78, p.z + fz * 0.05, 0.12, 0.12, 0.05, r, Color(0.95, 0.95, 0.95))
			"thor":
				hum(p, r, 1.2, Color(0.35, 0.37, 0.42), Color(0.15, 0.15, 0.18), Color(0.95, 0.78, 0.65), Color(0.35, 0.37, 0.42), ph)
				em(M_BOX, p.x - fx * 0.2, p.y + 0.2, p.z - fz * 0.2, 0.55, 0.85, 0.05, r, Color(0.7, 0.08, 0.08))
				em(M_SPH, p.x - fx * 0.05, p.y + 1.15, p.z - fz * 0.05, 0.36, 0.3, 0.36, r, Color(0.85, 0.7, 0.35))
				em(M_BOX, p.x + rx * 0.35, p.y + 0.6, p.z + rz * 0.35, 0.2, 0.15, 0.32, r, Color(0.55, 0.57, 0.6), 0, 0, 0, 1.5)
				if fmod(anim_time + float(st["side"]), 6.0) < 0.25:
					gl(2.0, p.x + rx * 0.35, p.y + 3.0, p.z + rz * 0.35, 1.0, 1.0, 0.0, Color(0.7, 0.85, 1.0, 1.0), 6.0)
					em(M_BOX, p.x + rx * 0.35, p.y + 0.7, p.z + rz * 0.35, 0.08, 9.0, 0.08, 0.3, Color(0.8, 0.9, 1.0), 0, 0, 4.0)
			"buster":
				hum(p, r, 1.05, Color(0.6, 0.55, 0.42), Color(0.6, 0.55, 0.42), Color(0.87, 0.66, 0.5), Color(0.6, 0.55, 0.42), ph)
				em(M_BOX, p.x - fx * 0.2, p.y + 0.5, p.z - fz * 0.2, 0.36, 0.55, 0.22, r, Color(0.12, 0.12, 0.13))
				if fmod(anim_time + float(st["side"]) * 2.0, 4.0) < 1.2:
					em(M_BOX, p.x + fx * 1.6 + rx * 0.2, p.y + 0.9, p.z + fz * 1.6 + rz * 0.2, 0.05, 0.05, 3.0, r, Color(1.0, 0.55, 0.2), 0, 0, 3.0)
			"ghost":
				var gy := p.y + 2.2 + sin(anim_time * 2.0 + float(st["side"])) * 0.5
				em(M_SPH, p.x, gy, p.z, 1.1, 1.2, 1.0, r, Color(0.45, 0.9, 0.3), 0, 0, 0.8)
				em(M_SPH, p.x + fx * 0.45, gy + 0.5, p.z + fz * 0.45, 0.35, 0.3, 0.1, r, Color(0.15, 0.3, 0.1))
			"vader":
				hum(p, r, 1.25, Color(0.03, 0.03, 0.04), Color(0.03, 0.03, 0.04), Color(0.05, 0.05, 0.06), Color(0.03, 0.03, 0.04), ph * 0.6)
				em(M_CONE, p.x - fx * 0.1, p.y, p.z - fz * 0.1, 0.9, 1.3, 0.9, 0.0, Color(0.02, 0.02, 0.03))
				em(M_SPH, p.x, p.y + 1.15, p.z, 0.4, 0.32, 0.4, r, Color(0.03, 0.03, 0.04), 0, 0, 0, 1.5)
				em(M_BOX, p.x + rx * 0.35 + fx * 0.3, p.y + 0.75, p.z + rz * 0.35 + fz * 0.3, 0.06, 0.06, 1.0, r, Color(1.0, 0.1, 0.08), 0, 0, 4.0)
			"trooper":
				hum(p, r, 1.1, Color(0.93, 0.93, 0.93), Color(0.93, 0.93, 0.93), Color(0.95, 0.95, 0.95), Color(0.93, 0.93, 0.93), ph)
				em(M_BOX, p.x + fx * 0.13, p.y + 1.0, p.z + fz * 0.13, 0.2, 0.05, 0.04, r, Color(0.05, 0.05, 0.05))
			"spidey":
				hum(p, r, 1.05, Color(0.8, 0.1, 0.1), Color(0.12, 0.2, 0.6), Color(0.8, 0.1, 0.1), Color(0.8, 0.1, 0.1), ph * 1.3)
				em(M_SPH, p.x + fx * 0.1 + rx * 0.07, p.y + 1.0, p.z + fz * 0.1 + rz * 0.07, 0.08, 0.06, 0.04, r, Color(0.95, 0.95, 0.95))
				em(M_SPH, p.x + fx * 0.1 - rx * 0.07, p.y + 1.0, p.z + fz * 0.1 - rz * 0.07, 0.08, 0.06, 0.04, r, Color(0.95, 0.95, 0.95))
				if jy > 0.0:
					em(M_BOX, p.x, p.y + 1.0, p.z, 0.02, 8.0, 0.02, 0.0, Color(0.95, 0.95, 0.95))
			"minion":
				em(M_CYL, p.x, p.y + 0.1, p.z, 0.4, 0.55, 0.4, 0.0, Color(0.98, 0.85, 0.15))
				em(M_SPH, p.x, p.y + 0.55, p.z, 0.4, 0.3, 0.4, 0.0, Color(0.98, 0.85, 0.15))
				em(M_CYL, p.x, p.y, p.z, 0.42, 0.28, 0.42, 0.0, Color(0.15, 0.3, 0.65))
				em(M_SPH, p.x + fx * 0.18, p.y + 0.55, p.z + fz * 0.18, 0.18, 0.18, 0.08, r, Color(0.7, 0.72, 0.75), 0, 0, 0, 1.5)
				em(M_BOX, p.x, p.y + 0.12 + absf(sin(ph)) * 0.08, p.z, 0.08, 0.12, 0.08, 0.0, Color(0.08, 0.08, 0.08))
			"shrek":
				hum(p, r, 1.6, Color(0.92, 0.88, 0.75), Color(0.45, 0.3, 0.18), Color(0.5, 0.65, 0.2), Color(0.5, 0.65, 0.2), ph * 0.7)
				em(M_BOX, p.x - fx * 0.05, p.y + 0.8, p.z - fz * 0.05, 0.6, 0.6, 0.42, r, Color(0.35, 0.22, 0.12))
				em(M_CYL, p.x + rx * 0.2, p.y + 1.85, p.z + rz * 0.2, 0.08, 0.15, 0.08, 0.0, Color(0.5, 0.65, 0.2))
				em(M_CYL, p.x - rx * 0.2, p.y + 1.85, p.z - rz * 0.2, 0.08, 0.15, 0.08, 0.0, Color(0.5, 0.65, 0.2))
			"burro":
				em(M_BOX, p.x, p.y + 0.4, p.z, 0.4, 0.5, 1.0, r, Color(0.5, 0.5, 0.52))
				em(M_BOX, p.x + fx * 0.6, p.y + 0.8, p.z + fz * 0.6, 0.3, 0.35, 0.5, r, Color(0.5, 0.5, 0.52))
				em(M_BOX, p.x + fx * 0.5, p.y + 1.15, p.z + fz * 0.5, 0.06, 0.4, 0.06, r, Color(0.4, 0.4, 0.42))
				for k in 4:
					em(M_BOX, p.x + rx * (0.14 if k % 2 == 0 else -0.14) + fx * (0.35 if k < 2 else -0.35), p.y, p.z + rz * (0.14 if k % 2 == 0 else -0.14) + fz * (0.35 if k < 2 else -0.35), 0.1, 0.45, 0.1, r, Color(0.4, 0.4, 0.42))
			"trex", "godzilla":
				var s := 3.2 if who == "trex" else 9.0
				var bc := Color(0.4, 0.42, 0.25) if who == "trex" else Color(0.18, 0.22, 0.2)
				var stp := sin(ph * 0.35) * 0.25 * s
				for sg in [-1.0, 1.0]:
					var g: float = sg
					em(M_BOX, p.x + rx * g * 0.3 * s + fx * stp * g, p.y, p.z + rz * g * 0.3 * s + fz * stp * g, 0.3 * s, 0.8 * s, 0.4 * s, r, bc.darkened(0.15))
				if who == "trex":
					em(M_SPH, p.x, p.y + 0.7 * s, p.z, 0.8 * s, 0.8 * s, 1.6 * s, r, bc)
					em(M_BOX, p.x + fx * 1.0 * s, p.y + 1.15 * s, p.z + fz * 1.0 * s, 0.5 * s, 0.45 * s, 0.8 * s, r, bc)
					em(M_BOX, p.x + fx * 1.05 * s, p.y + 1.0 * s, p.z + fz * 1.05 * s, 0.42 * s, 0.12 * s, 0.75 * s, r, Color(0.85, 0.2, 0.15))
					em(M_BOX, p.x - fx * 1.4 * s, p.y + 0.8 * s, p.z - fz * 1.4 * s, 0.3 * s, 0.3 * s, 1.4 * s, r + sin(ph * 0.3) * 0.2, bc)
				else:
					em(M_SPH, p.x, p.y + 0.6 * s, p.z, 1.0 * s, 1.5 * s, 0.9 * s, r, bc)
					em(M_SPH, p.x + fx * 0.2 * s, p.y + 1.9 * s, p.z + fz * 0.2 * s, 0.45 * s, 0.4 * s, 0.55 * s, r, bc)
					em(M_BOX, p.x - fx * 1.2 * s, p.y + 0.3 * s, p.z - fz * 1.2 * s, 0.4 * s, 0.35 * s, 1.6 * s, r, bc)
					for k in 4:
						em(M_CONE, p.x - fx * (0.45 + k * 0.12) * s, p.y + (1.75 - k * 0.3) * s, p.z - fz * (0.45 + k * 0.12) * s, 0.22 * s, 0.4 * s, 0.22 * s, 0.0, Color(0.6, 0.75, 0.8).lerp(bc, 0.5), 0, 0, nf * 1.5)
					if fmod(anim_time, 9.0) < 1.5:
						em(M_BOX, p.x + fx * 4.5 * s, p.y + 1.9 * s, p.z + fz * 4.5 * s, 0.3 * s, 0.3 * s, 8.0 * s, r, Color(0.4, 0.75, 1.0), 0, 0, 4.0)
		if close and who in KILLERS and nf > 0.4:
			gl(2.0, p.x, p.y + 1.2, p.z, 1.0, 1.0, 0.0, Color(1.0, 0.1, 0.05, 0.5), 1.2)
