# Partidas: nueva, guardar, cargar, códigos y migración.
const SAVE_VERSION := 1
func latest_slot() -> int:
	var best := 0
	var bt := 0
	for s in range(1, 4):
		var p := slot_path(s)
		if FileAccess.file_exists(p):
			var t := int(FileAccess.get_modified_time(p))
			if best == 0 or t > bt:
				best = s
				bt = t
	return best
func free_slot() -> int:
	var oldest := 1
	var ot := 0
	for s in range(1, 4):
		var p := slot_path(s)
		if not FileAccess.file_exists(p):
			return s
		var t := int(FileAccess.get_modified_time(p))
		if ot == 0 or t < ot:
			oldest = s
			ot = t
	return oldest
func reset_state() -> void:
	test_city = false
	money = 30000.0
	debt = 0.0
	day = 1
	day_timer = 0.0
	speed = 1
	pop = 0
	jobs = 0
	workers = 0
	tourists = 0
	stage = 0
	max_stage = 0
	approval = 0.7
	tax = [9, 9, 9]
	budget = [100, 100, 100, 100, 100, 100, 100]
	decrees = {}
	demand = [0.5, 0.3, 0.3]
	food_stock = 0.0
	prod_stock = 0.0
	market = [6.0, 9.0]
	contracts = []
	offer = null
	lines = []
	history = {"pop": [], "money": [], "happy": [], "appr": []}
	news = []
	achieved = {}
	obj_index = 0
	counters = {}
	daily_ch = 0
	daily_done = false
	promise = -1
	next_election = 15
	decision = null
	request = null
	festival_days = 0
	weather = "Soleado"
	wind = Vector2(1, 0)
	mods = {"hp": 0.0, "crime": 0.0, "pol": 0.0, "edu": 0.0, "tour": 0.0, "days": 0}
	no_fire_days = 0
	avg_happy = 0.6
	last_net = 0.0
	wonder_progress = {}
	game_over_shown = false
	stops = {}
	line_edit = {}
	cars = []
	peds = []
	stars = []
	downs = []
	movie_on = -1
	cine_next_day = 0
	svc = []
	boats = []
	planes = []
	parts = []
	smoke_n = 0
	smoke_pts.clear()
	anim_cells = {}
	car_paths = []
	drive = null
	follow_ped = null
	cam_follow = null
	sim_stage = -1
	sim_dirty = true
	built_season = -1
	terrain_dirty = true
	view_mode = ""
func new_test_city() -> void:
	reset_state()
	scenario = 0
	creative = true
	story = false
	slot = 3
	city_name = "Ciudad de prueba"
	gen_map(4, 4242)
	place_plaza()
	money = 999999.0
	for r in NREG * NREG:
		owned[r] = 1
	after_load()
	test_build()
	for k in 5:
		for s2 in 8:
			run_sim_stage(s2)
		new_day()
	for i in zone_list:
		if zone[i] > 0 and part[i] < 0:
			lvl[i] = 1 + int(pow(hsh(i, 5), 2.4) * 4.0) % 4
			tree[i] = 0
			vari[i] = int(hsh(i, 6) * 64.0)
	for k in 2:
		for s3 in 8:
			run_sim_stage(s3)
	anim_cells.clear()
	mark_all_dirty()
	test_city = true
	day_timer = DAY_SECONDS * 0.55
	speed = 1
	add_news("Ciudad de prueba: mirá cada cosa de cerca")
func new_game(kind: int, scen: int, crea: bool, hist: bool, s: int) -> void:
	reset_state()
	if scen == 4:
		kind = 2
	scenario = scen
	creative = crea
	story = hist and not crea
	slot = s
	city_name = str(new_opts["name"]).strip_edges() if str(new_opts["name"]).strip_edges() != "" else "Mi ciudad"
	gen_map(kind, randi() % 100000 + 1)
	place_plaza()
	pick_daily_challenge()
	if creative:
		money = 999999.0
		for r in NREG * NREG:
			owned[r] = 1
	after_load()
	add_news("Se fundó la ciudad. ¡Bienvenidos!")
	save_game(slot)
func after_load() -> void:
	compute_wdist()
	terrain_dirty = true
	built_season = season()
	mark_all_dirty()
	sim_dirty = true
	collect_lists()
	compute_networks()
	compute_coverage()
	compute_env()
	compute_env()
	compute_traffic()
	compute_happiness()
	compute_stats()
	reroute_all()
	rebuild_road_list()
	cam_goal = Vector3.ZERO
	cam_target = Vector3.ZERO
	cam_dist_goal = 150.0
	cam_dist = 150.0
	apply_volumes()
func slot_path(s: int, backup: bool = false) -> String:
	return "user://urbana_%d%s.json" % [s, ".bak" if backup else ""]
func b64(a) -> String:
	if a is PackedByteArray:
		return Marshalls.raw_to_base64(a)
	return Marshalls.raw_to_base64(a.to_byte_array())
func snapshot() -> Dictionary:
	var ln_list: Array = []
	for ln in lines:
		ln_list.append({"kind": ln["kind"], "stops": ln["stops"], "num": ln["num"], "col": ln["col"].to_html(), "t": ln["t"]})
	var st: Array = []
	for c in stops:
		st.append([c, stops[c]])
	var wp: Array = []
	for a in wonder_progress:
		wp.append([a, wonder_progress[a]])
	var dec_idx := -1
	if decision != null:
		dec_idx = DECISIONS.find(decision)
	return {
		"v": SAVE_VERSION, "n": N, "map_kind": map_kind, "map_seed": map_seed, "scenario": scenario, "creative": creative, "story": story, "city": city_name,
		"money": money, "debt": debt, "day": day, "day_timer": day_timer, "pop": pop, "stage": stage, "max_stage": max_stage,
		"approval": approval, "tax": tax, "budget": budget, "decrees": decrees, "food": food_stock, "prod": prod_stock, "market": market,
		"neighbors": neighbors, "contracts": contracts, "offer": offer, "lines": ln_list, "stops": st, "history": history, "news": news,
		"achieved": achieved, "obj": obj_index, "counters": counters, "daily_ch": daily_ch, "daily_done": daily_done,
		"promise": promise, "promise_base": promise_base, "next_election": next_election, "decision": dec_idx, "request": request,
		"festival": festival_days, "weather": weather, "mods": mods, "no_fire": no_fire_days, "wonders": wp, "avg_happy": avg_happy,
		"cam": [cam_goal.x, cam_goal.z, cam_yaw, cam_pitch, cam_dist_goal],
		"terr": b64(terr), "hgt": b64(hgt), "road": b64(road), "zone": b64(zone), "bld": b64(bld), "lvl": b64(lvl), "part": b64(part),
		"occ": b64(occ), "vari": b64(vari), "tree": b64(tree), "wire": b64(wire), "garbp": b64(garbp), "owned": b64(owned), "district": b64(district),
	}
func save_game(s: int) -> void:
	if test_city:
		return
	var path := slot_path(s)
	if FileAccess.file_exists(path):
		var old := FileAccess.get_file_as_string(path)
		if old.length() > 100:
			var fb := FileAccess.open(slot_path(s, true), FileAccess.WRITE)
			if fb:
				fb.store_string(old)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(snapshot()))
func save_info(s: int) -> String:
	var path := slot_path(s)
	if not FileAccess.file_exists(path):
		return "vacía"
	var d = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(d) != TYPE_DICTIONARY:
		return "dañada"
	return "%s · día %d, %s vecinos" % [str(d.get("city", "Mi ciudad")), int(d.get("day", 1)), fmt_int(int(d.get("pop", 0)))]
func load_game(s: int, backup: bool = false) -> bool:
	var path := slot_path(s, backup)
	if not FileAccess.file_exists(path):
		return false
	var d = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(d) != TYPE_DICTIONARY:
		toast("La partida está dañada. Probá con la copia de respaldo.")
		return false
	if not apply_snapshot(d):
		return false
	slot = s
	return true
func unb(s: String) -> PackedByteArray:
	return Marshalls.base64_to_raw(s)
func apply_snapshot(d: Dictionary) -> bool:
	if int(d.get("n", 0)) != N:
		return false
	reset_state()
	alloc_arrays()
	map_kind = int(d.get("map_kind", 0))
	map_seed = int(d.get("map_seed", 1))
	scenario = int(d.get("scenario", 0))
	creative = bool(d.get("creative", false))
	story = bool(d.get("story", true))
	city_name = str(d.get("city", "Mi ciudad"))
	money = float(d.get("money", 30000))
	debt = float(d.get("debt", 0))
	day = int(d.get("day", 1))
	day_timer = float(d.get("day_timer", 0))
	pop = int(d.get("pop", 0))
	stage = int(d.get("stage", 0))
	max_stage = int(d.get("max_stage", 0))
	approval = float(d.get("approval", 0.7))
	tax = []
	for v in d.get("tax", [9, 9, 9]):
		tax.append(int(v))
	budget = []
	for v in d.get("budget", [100, 100, 100, 100, 100, 100, 100]):
		budget.append(int(v))
	decrees = d.get("decrees", {})
	food_stock = float(d.get("food", 0))
	prod_stock = float(d.get("prod", 0))
	market = d.get("market", [6.0, 9.0])
	neighbors = d.get("neighbors", [])
	if neighbors.is_empty():
		init_neighbors()
	contracts = []
	for c in d.get("contracts", []):
		contracts.append({"nb": int(c["nb"]), "kind": c["kind"], "qty": int(c["qty"]), "price": float(c["price"]), "days": int(c["days"])})
	var of = d.get("offer", null)
	if of != null:
		offer = {"nb": int(of["nb"]), "kind": of["kind"], "qty": int(of["qty"]), "price": float(of["price"]), "days": int(of["days"])}
	history = d.get("history", history)
	news = d.get("news", [])
	achieved = d.get("achieved", {})
	obj_index = int(d.get("obj", 0))
	counters = d.get("counters", {})
	daily_ch = int(d.get("daily_ch", 0))
	daily_done = bool(d.get("daily_done", false))
	promise = int(d.get("promise", -1))
	promise_base = float(d.get("promise_base", 0))
	next_election = int(d.get("next_election", 15))
	var di := int(d.get("decision", -1))
	decision = DECISIONS[di] if di >= 0 and di < DECISIONS.size() else null
	var rq = d.get("request", null)
	if rq != null:
		request = {"cell": int(rq["cell"]), "cv": int(rq["cv"]), "what": rq["what"], "until": int(rq["until"])}
	festival_days = int(d.get("festival", 0))
	weather = d.get("weather", "Soleado")
	var md: Dictionary = d.get("mods", {})
	for k in md:
		mods[k] = md[k]
	no_fire_days = int(d.get("no_fire", 0))
	avg_happy = float(d.get("avg_happy", 0.6))
	terr = unb(d["terr"])
	hgt = unb(d["hgt"]).to_float32_array()
	road = unb(d["road"])
	zone = unb(d["zone"])
	bld = unb(d["bld"]).to_int32_array()
	lvl = unb(d["lvl"])
	part = unb(d["part"]).to_int32_array()
	occ = unb(d["occ"]).to_float32_array()
	vari = unb(d["vari"])
	tree = unb(d["tree"])
	wire = unb(d["wire"])
	garbp = unb(d["garbp"]).to_float32_array()
	owned = unb(d["owned"])
	district = unb(d["district"]).to_int32_array()
	if terr.size() != N * N or bld.size() != N * N or hgt.size() != N * N:
		return false
	for s in d.get("stops", []):
		stops[int(s[0])] = s[1]
	for w in d.get("wonders", []):
		wonder_progress[int(w[0])] = int(w[1])
	for l in d.get("lines", []):
		var st: Array = []
		for s in l["stops"]:
			st.append(int(s))
		lines.append({"kind": l["kind"], "stops": st, "pts": [], "t": float(l.get("t", 0)), "num": int(l["num"]), "col": Color.html(l["col"])})
	after_load()
	var cm: Array = d.get("cam", [])
	if cm.size() == 5:
		cam_goal = Vector3(cm[0], 0, cm[1])
		cam_target = cam_goal
		cam_yaw = cm[2]
		cam_pitch = cm[3]
		cam_dist_goal = cm[4]
		cam_dist = cm[4]
	return true
func export_code() -> String:
	var raw := JSON.stringify(snapshot()).to_utf8_buffer()
	var comp := raw.compress(FileAccess.COMPRESSION_GZIP)
	return "URB1:" + str(raw.size()) + ":" + Marshalls.raw_to_base64(comp)
func import_code(t: String) -> bool:
	t = t.strip_edges().replace("\n", "").replace(" ", "")
	if t == "":
		return false
	if t.begins_with("URB1:"):
		var p := t.split(":", false, 2)
		if p.size() < 3:
			return false
		var comp := Marshalls.base64_to_raw(p[2])
		var raw := comp.decompress(int(p[1]), FileAccess.COMPRESSION_GZIP)
		var d = JSON.parse_string(raw.get_string_from_utf8())
		if typeof(d) != TYPE_DICTIONARY:
			return false
		if not apply_snapshot(d):
			return false
		save_game(slot)
		return true
	var txt := Marshalls.base64_to_utf8(t)
	var od = JSON.parse_string(txt)
	if typeof(od) != TYPE_DICTIONARY or not od.has("cells"):
		return false
	migrate_old(od)
	save_game(slot)
	return true
const OLD_OFF := 44
const OLD_DEFS := {5: 24, 6: 22, 7: 20, 8: 21, 10: 32, 11: 33, 12: 34, 13: 65}
func migrate_old(od: Dictionary) -> void:
	reset_state()
	scenario = 0
	creative = false
	story = true
	gen_map(4, 4242)
	for z in range(OLD_OFF - 2, OLD_OFF + 42):
		for x in range(OLD_OFF - 2, OLD_OFF + 42):
			var i := idx(x, z)
			terr[i] = T_LAND
			hgt[i] = 0.0
			tree[i] = 0
			road[i] = 0
	for r in [5, 6, 9, 10]:
		owned[r] = 1
	var defs: Array = []
	for c in od.get("cells", []):
		var x := int(c[0]) + OLD_OFF
		var z := int(c[1]) + OLD_OFF
		var k := int(c[2])
		if not inb(x, z):
			continue
		var i := idx(x, z)
		match k:
			1:
				road[i] = 2
			2, 3, 4:
				zone[i] = [0, 0, Z_R, Z_C, Z_I][k]
				lvl[i] = 1
				vari[i] = randi() % 64
			9:
				road[i] = 2
				stops[i] = "bus"
			_:
				if OLD_DEFS.has(k):
					defs.append([i, OLD_DEFS[k]])
	for s in od.get("stops", []):
		var x2 := int(s[0]) + OLD_OFF
		var z2 := int(s[1]) + OLD_OFF
		if inb(x2, z2):
			var i2 := idx(x2, z2)
			road[i2] = maxi(road[i2], 2)
			stops[i2] = "bus"
	for dd in defs:
		var i3: int = dd[0]
		var id: int = dd[1]
		var sz: int = DEF[id]["sz"]
		if sz == 1:
			bld[i3] = id
		elif can_place_old(i3, sz):
			for dz in sz:
				for dx in sz:
					var j := i3 + dz * N + dx
					zone[j] = 0
					bld[j] = id
					part[j] = i3
		else:
			bld[i3] = 30
	var num := 1
	for arr in od.get("lines", []):
		var st: Array = []
		for p in arr:
			var x3 := int(p[0]) + OLD_OFF
			var z3 := int(p[1]) + OLD_OFF
			if inb(x3, z3):
				st.append(idx(x3, z3))
		if st.size() >= 2:
			lines.append({"kind": "bus", "stops": st, "pts": [], "t": 0.0, "num": num, "col": Color.from_hsv(fmod(num * 0.17, 1.0), 0.75, 0.9)})
			num += 1
	day = int(od.get("day", 1))
	money = maxf(float(od.get("money", 0)), 30000.0)
	debt = 0.0
	pick_daily_challenge()
	after_load()
	cam_goal = cell_pos(idx(OLD_OFF + 20, OLD_OFF + 20))
	cam_target = cam_goal
	add_news("Tu ciudad de antes se mudó a este mapa nuevo")
func can_place_old(a: int, sz: int) -> bool:
	for dz in sz:
		for dx in sz:
			var x := cx(a) + dx
			var z := cz(a) + dz
			if not inb(x, z):
				return false
			var j := idx(x, z)
			if road[j] > 0 or bld[j] > 0:
				return false
	return true
func migrate_old_file() -> void:
	var old := "user://partida.json"
	if not FileAccess.file_exists(old) or FileAccess.file_exists(slot_path(1)):
		return
	var od = JSON.parse_string(FileAccess.get_file_as_string(old))
	if typeof(od) != TYPE_DICTIONARY or not od.has("cells"):
		return
	slot = 1
	migrate_old(od)
	save_game(1)
	DirAccess.rename_absolute(old, "user://partida_vieja.json")
func save_opts() -> void:
	var f := FileAccess.open("user://opciones.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(opts))
func load_opts() -> void:
	if not FileAccess.file_exists("user://opciones.json"):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string("user://opciones.json"))
	if typeof(d) != TYPE_DICTIONARY:
		return
	for k in d:
		if opts.has(k):
			opts[k] = d[k]
	for k in ["quality", "text", "ui_size"]:
		opts[k] = int(opts[k])
