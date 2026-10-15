# Herramientas de construir, demoler, rotondas, paradas y líneas.
const LINE_TOOLS := ["road", "cable", "pipe", "bike", "tram", "levee"]
func line_cells(a: int, b: int) -> Array:
	var out: Array = []
	if a < 0 or b < 0:
		return out
	var x0 := cx(a)
	var z0 := cz(a)
	var x1 := cx(b)
	var z1 := cz(b)
	var dx := x1 - x0
	var dz := z1 - z0
	var adx := absi(dx)
	var adz := absi(dz)
	var diag := adx >= 2 and adz >= 2 and maxf(adx, adz) / maxf(minf(adx, adz), 1.0) <= 2.2
	if not diag:
		if adx >= adz:
			z1 = z0
		else:
			x1 = x0
		var sx := signi(x1 - x0)
		var sz := signi(z1 - z0)
		var x := x0
		var z := z0
		out.append(idx(x, z))
		while x != x1 or z != z1:
			x += sx
			z += sz
			out.append(idx(x, z))
		return out
	var sx2 := signi(dx)
	var sz2 := signi(dz)
	var x := x0
	var z := z0
	out.append(idx(x, z))
	var steps := adx + adz
	for k in steps:
		var fx := float(absi(x - x0) + 1) / float(adx) if adx > 0 else 99.0
		var fz := float(absi(z - z0) + 1) / float(adz) if adz > 0 else 99.0
		if x != x1 and (fx <= fz or z == z1):
			x += sx2
		elif z != z1:
			z += sz2
		out.append(idx(x, z))
	return out
func rect_cells(a: int, b: int) -> Array:
	var out: Array = []
	if a < 0 or b < 0:
		return out
	for z in range(mini(cz(a), cz(b)), maxi(cz(a), cz(b)) + 1):
		for x in range(mini(cx(a), cx(b)), maxi(cx(a), cx(b)) + 1):
			out.append(idx(x, z))
	return out
func drag_cells() -> Array:
	if tool["k"] in LINE_TOOLS:
		return line_cells(drag_a, drag_b)
	return rect_cells(drag_a, drag_b)
func cell_cost(i: int) -> float:
	if i < 0:
		return -1.0
	if not is_owned(i):
		return -1.0
	var k: String = tool["k"]
	match k:
		"road":
			var t: int = tool["t"]
			if bld[i] > 0 or (zone[i] > 0 and lvl[i] > 0):
				return -1.0
			if road[i] >= t:
				return 0.0
			if terr[i] == T_WATER:
				if t == 1:
					return -1.0
				return ROAD_COST[t] * 3.0
			var c: float = ROAD_COST[t] - ROAD_COST[road[i]]
			if terr[i] == T_ROCK:
				c *= 2.0
			return c
		"zone":
			if road[i] > 0 or bld[i] > 0 or terr[i] == T_WATER or terr[i] == T_ROCK:
				return -1.0
			if zone[i] == tool["z"]:
				return 0.0
			return float(ZONE_COST)
		"dezone":
			return 0.0 if zone[i] > 0 else -1.0
		"demolish":
			if terr[i] == T_ROCK:
				return 25.0
			if road[i] > 0 or bld[i] > 0 or zone[i] > 0 or tree[i] > 0 or wire[i] > 0:
				return 2.0
			return -1.0
		"cable":
			if terr[i] == T_WATER:
				return -1.0
			return 0.0 if wire[i] & W_POWER else 3.0
		"pipe":
			if terr[i] == T_WATER:
				return -1.0
			return 0.0 if wire[i] & W_PIPE else 3.0
		"bike":
			if road[i] < 2 or road[i] == 4:
				return -1.0
			return 0.0 if wire[i] & W_BIKE else 6.0
		"tram":
			if road[i] < 3 or road[i] == 4:
				return -1.0
			return 0.0 if wire[i] & W_TRAM else 25.0
		"levee":
			if terr[i] == T_WATER or road[i] > 0 or bld[i] > 0 or zone[i] > 0:
				return -1.0
			return 0.0 if wire[i] & W_LEVEE else 40.0
		"trees":
			if road[i] > 0 or bld[i] > 0 or zone[i] > 0 or terr[i] == T_WATER or tree[i] > 0:
				return -1.0
			return 6.0
	return -1.0
func commit_drag() -> void:
	clear_preview()
	var cells := drag_cells()
	apply_cells(cells)
var undo_rec: Dictionary = {}
func do_undo() -> void:
	if undo_rec.is_empty():
		toast("No hay nada para deshacer")
		return
	if undo_rec.has("def"):
		var a: int = undo_rec["def"]
		if bld[a] > 0:
			remove_def(a)
	else:
		for r in undo_rec["cells"]:
			var c: int = r[0]
			road[c] = r[1]
			zone[c] = r[2]
			lvl[c] = r[3]
			wire[c] = r[4]
			tree[c] = r[5]
			part[c] = r[6]
			occ[c] = r[7]
			vari[c] = r[8]
			mark_dirty(c)
	if not creative:
		money += float(undo_rec["money"])
	undo_rec = {}
	sim_dirty = true
	sfx("demolish")
	toast("Deshecho")
func apply_cells(cells: Array) -> void:
	var total := 0.0
	for c in cells:
		var cc := cell_cost(c)
		if cc > 0.0:
			total += cc
	if not creative and total > money:
		toast("No alcanza la plata: necesitás " + fmt_money(total))
		sfx("error")
		return
	var k: String = tool["k"]
	var changed := 0
	var rec: Array = []
	for c in cells:
		if cell_cost(c) >= 0.0:
			rec.append([c, road[c], zone[c], lvl[c], wire[c], tree[c], part[c], occ[c], vari[c]])
	for c in cells:
		var cc := cell_cost(c)
		if cc < 0.0:
			continue
		match k:
			"road":
				if road[c] < tool["t"]:
					road[c] = tool["t"]
					tree[c] = 0
					if zone[c] > 0:
						zone[c] = 0
						lvl[c] = 0
					count_add("roads")
					changed += 1
			"zone":
				if zone[c] != tool["z"]:
					zone[c] = tool["z"]
					lvl[c] = 0
					occ[c] = 0.0
					part[c] = -1
					vari[c] = randi() % 64
					count_add("zones")
					if tool["z"] == Z_R:
						count_add("zoneR")
					if tool["z"] == Z_C:
						count_add("zoneC")
					changed += 1
			"dezone":
				clear_zone(c)
				changed += 1
			"demolish":
				demolish_cell(c)
				flatten_cell(c)
				changed += 1
			"cable":
				wire[c] |= W_POWER
				changed += 1
			"pipe":
				wire[c] |= W_PIPE
				changed += 1
			"bike":
				wire[c] |= W_BIKE
				changed += 1
			"tram":
				wire[c] |= W_TRAM
				changed += 1
			"levee":
				wire[c] |= W_LEVEE
				tree[c] = 0
				changed += 1
			"trees":
				tree[c] = pick_tree_kind(c, RandomNumberGenerator.new())
				count_add("trees")
				changed += 1
		mark_dirty(c)
	if changed > 0:
		if not creative:
			money -= total
		sim_dirty = true
		undo_rec = {} if k == "demolish" else {"cells": rec, "money": total}
		sfx("build" if k != "demolish" else "demolish")
		vibrate()
		if k == "road":
			unlock_ach("first_road")
			if opts["autoround"]:
				auto_rounds(cells)
func clear_zone(c: int) -> void:
	var a := anchor_of(c)
	if zone[c] > 0 and part[c] >= 0:
		unmerge(a)
	zone[c] = 0
	lvl[c] = 0
	occ[c] = 0.0
	part[c] = -1
	anim_cells.erase(c)
func unmerge(a: int) -> void:
	for dz in 2:
		for dx in 2:
			var j := a + dz * N + dx
			if j < N * N and part[j] == a:
				part[j] = -1
				lvl[j] = mini(lvl[j], 3)
				mark_dirty(j)
func flatten_cell(c: int) -> void:
	if terr[c] == T_ROCK:
		terr[c] = T_LAND
		hgt[c] = 0.0
		terrain_dirty = true
		mark_dirty(c)
func demolish_cell(c: int) -> void:
	if bld[c] > 0:
		remove_def(anchor_of(c))
	clear_zone(c)
	if road[c] > 0:
		road[c] = 0
		stops.erase(c)
		mark_dirty(c)
		wire[c] &= ~(W_BIKE | W_TRAM | W_ROUND)
	tree[c] = 0
	wire[c] = 0
	burn[c] = 0.0
	garbp[c] = 0.0
func remove_def(a: int) -> void:
	var d: Dictionary = DEF[bld[a]]
	var sz: int = d["sz"]
	for dz in sz:
		for dx in sz:
			var j := a + dz * N + dx
			if j < N * N and anchor_of(j) == a:
				bld[j] = 0
				part[j] = -1
				burn[j] = 0.0
				mark_dirty(j)
	wonder_progress.erase(a)
	for ln in lines:
		ln["stops"] = ln["stops"].filter(func(s): return s != a)
	sim_dirty = true
func can_place_def(a: int, id: int) -> String:
	if a < 0:
		return "Fuera del mapa"
	var d: Dictionary = DEF[id]
	var sz: int = d["sz"]
	var cells := def_cells(a, sz)
	if cells.size() < sz * sz:
		return "No entra"
	if not creative and d["st"] > max_stage:
		return "Se desbloquea en etapa " + STAGES[d["st"]][0]
	if d.get("unique", false):
		for i in N * N:
			if bld[i] == id:
				return "Ya tenés uno"
	if scenario == 1 and id == 42:
		return "En este escenario no hay carbón"
	var need: String = d.get("need", "")
	var has_shore := false
	var has_sand := false
	for c in cells:
		if not is_owned(c):
			return "Esa zona no es tuya. Comprala en Herramientas."
		if road[c] > 0 or bld[c] > 0 or (zone[c] > 0 and lvl[c] > 0):
			return "Está ocupado"
		if terr[c] == T_WATER and need != "shore":
			return "Es agua"
		if terr[c] == T_ROCK:
			return "Es un cerro"
		if flood[c] > 0.0:
			return "Está inundado, esperá que baje el agua"
		if near_water(c, 1):
			has_shore = true
		if terr[c] == T_SAND:
			has_sand = true
	if need == "shore" and not has_shore:
		return "Tiene que ir en la costa"
	if need == "sand" and not has_sand:
		return "Tiene que ir en la arena"
	if not creative and money < d["cost"]:
		return "No alcanza la plata"
	return ""
func place_def(a: int, id: int) -> bool:
	var err := can_place_def(a, id)
	if err != "":
		toast(err)
		sfx("error")
		return false
	var d: Dictionary = DEF[id]
	var sz: int = d["sz"]
	var cells := def_cells(a, sz)
	var anchor: int = cells[0]
	for c in cells:
		clear_zone(c)
		bld[c] = id
		part[c] = anchor if sz > 1 else -1
		tree[c] = 0
		mark_dirty(c)
	vari[anchor] = randi() % 64
	if id == 66 and not cine_told:
		cine_told = true
		queue_card({"title": "🎬 ¡Abrió el cine!", "text": "Cada pocos días se estrena una película (Scream, Chucky, It, Avengers, Star Wars y muchas más). Durante 24 horas sus protagonistas salen a las calles haciendo lo que hacen en la película.", "btns": [["¡Genial!", Callable()]]})
	if d["c"] == "wonder":
		wonder_progress[anchor] = 0
	if not creative:
		money -= d["cost"]
	count_add("builds")
	undo_rec = {"def": anchor, "money": 0.0 if creative else float(d["cost"])}
	match d["c"]:
		"serv":
			count_add("serv")
		"park":
			count_add("park")
	if d.has("pw"):
		count_add("power")
	if d.has("wt"):
		count_add("water")
	if d.has("gb"):
		count_add("garb")
	if id == 53:
		unlock_ach("metro")
	if id == 56:
		unlock_ach("airport")
	if id == 55:
		unlock_ach("port")
	if id == 35:
		unlock_ach("stadium")
	if not road_near(anchor, sz):
		toast(d["n"] + " necesita una calle cerca para funcionar")
	sim_dirty = true
	sfx("build")
	vibrate()
	anim_cells[anchor] = 1.2
	return true
func block_fill(c: int) -> Array:
	if c < 0:
		return []
	var ok := func(j: int) -> bool:
		return road[j] == 0 and bld[j] == 0 and terr[j] != T_WATER and terr[j] != T_ROCK and is_owned(j)
	if not ok.call(c):
		return [c]
	var seen := {c: true}
	var q: Array = [c]
	var head := 0
	while head < q.size():
		var j: int = q[head]
		head += 1
		if q.size() > 90:
			break
		for o in [1, -1, N, -N]:
			var k: int = j + o
			if k < 0 or k >= N * N:
				continue
			if (o == 1 or o == -1) and cz(k) != cz(j):
				continue
			if seen.has(k) or not ok.call(k):
				continue
			seen[k] = true
			q.append(k)
	if q.size() > 90:
		var out: Array = []
		for dz in range(-1, 2):
			for dx in range(-1, 2):
				if inb(cx(c) + dx, cz(c) + dz):
					out.append(idx(cx(c) + dx, cz(c) + dz))
		return out
	return q
func auto_rounds(cells: Array) -> void:
	for c in cells:
		if road[c] != 3 or (wire[c] & W_ROUND):
			continue
		var nb := road_n(c)
		if not (nb[0] and nb[1] and nb[2] and nb[3]):
			continue
		var near := false
		for dz in range(-2, 3):
			for dx in range(-2, 3):
				var x := cx(c) + dx
				var z := cz(c) + dz
				if inb(x, z) and (wire[idx(x, z)] & W_ROUND):
					near = true
		if not near:
			wire[c] |= W_ROUND
			mark_dirty(c)
func toggle_round(c: int) -> void:
	if c < 0 or road[c] < 2:
		toast("La rotonda va en un cruce de calles")
		return
	var nb := road_n(c)
	var cnt := int(nb[0]) + int(nb[1]) + int(nb[2]) + int(nb[3])
	if cnt < 3:
		toast("La rotonda va en un cruce de 3 o 4 calles")
		return
	if not creative and money < 150:
		toast("No alcanza la plata")
		return
	wire[c] ^= W_ROUND
	if not creative:
		money -= 150
	mark_dirty(c)
	sim_dirty = true
	sfx("build")
func place_stop(c: int, kind: String) -> void:
	if c < 0 or road[c] == 0:
		toast("La parada va sobre una calle")
		return
	if kind == "tram" and not (wire[c] & W_TRAM):
		toast("La parada de tranvía va sobre vías de tranvía")
		return
	if stops.has(c):
		toast("Ya hay una parada")
		return
	if not creative and money < 60:
		toast("No alcanza la plata")
		return
	stops[c] = kind
	mark_dirty(c)
	if not creative:
		money -= 60
	sim_dirty = true
	sfx("build")
	toast("Parada puesta. Para armar la línea tocá Transporte > Nueva línea.")
func stop_kind_at(c: int) -> String:
	if stops.has(c):
		return stops[c]
	if bld[c] > 0:
		var d: Dictionary = DEF[bld[c]]
		return d.get("stop", "")
	return ""
func pick_line_stop(c: int) -> void:
	if c < 0:
		return
	var kind: String = line_edit.get("kind", "bus")
	var found := -1
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			var x := cx(c) + dx
			var z := cz(c) + dz
			if not inb(x, z):
				continue
			var j := idx(x, z)
			if stop_kind_at(j) == kind:
				found = anchor_of(j)
				break
		if found >= 0:
			break
	if found < 0:
		toast("Tocá una parada de " + LINE_NAMES[kind])
		return
	line_edit["stops"].append(found)
	toast("Paradas en la línea: %d" % line_edit["stops"].size())
	sfx("click")
func ask_buy_region(c: int) -> void:
	if c < 0:
		return
	var r := region_of(c)
	if owned[r] == 1:
		toast("Esta zona ya es tuya")
		return
	var rx := r % NREG
	var rz := r / NREG
	var adj := false
	for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var xx: int = rx + o.x
		var zz: int = rz + o.y
		if xx >= 0 and zz >= 0 and xx < NREG and zz < NREG and owned[zz * NREG + xx] == 1:
			adj = true
	if not adj:
		toast("Solo podés comprar zonas pegadas a las tuyas")
		return
	var cost := region_price()
	confirm("¿Comprar %s por %s?" % [DISTRICT_NAMES[r], fmt_money(cost)], func():
		if money < cost and not creative:
			toast("No alcanza la plata")
			return
		if not creative:
			money -= cost
		owned[r] = 1
		terrain_dirty = true
		mark_all_dirty()
		sfx("cheer")
		toast("¡Compraste " + DISTRICT_NAMES[r] + "!")
		var all := true
		for k in NREG * NREG:
			if owned[k] == 0:
				all = false
		if all:
			unlock_ach("regions"))
func region_price() -> float:
	var n := 0
	for k in NREG * NREG:
		n += owned[k]
	return 4000.0 * pow(float(n - 3), 1.25)
func finish_line() -> void:
	var kind: String = line_edit.get("kind", "bus")
	var st: Array = line_edit.get("stops", [])
	if st.size() < 2:
		toast("La línea necesita al menos 2 paradas")
		return
	var cost: int = LINE_COST[kind]
	if not creative and money < cost:
		toast("No alcanza la plata")
		return
	if not creative:
		money -= cost
	var num := 1
	for ln in lines:
		num = maxi(num, ln["num"] + 1)
	var ln := {"kind": kind, "stops": st.duplicate(), "pts": [], "t": 0.0, "num": num, "col": Color.from_hsv(fmod(num * 0.17, 1.0), 0.75, 0.9)}
	lines.append(ln)
	route_line(ln)
	line_edit = {}
	set_tool({"k": "look"})
	count_add("line")
	sim_dirty = true
	sfx("cheer")
	toast("¡Línea %d de %s en marcha!" % [num, LINE_NAMES[kind]])
	add_news("Se inauguró la línea %d de %s" % [num, LINE_NAMES[kind]])
	if lines.size() >= 3:
		unlock_ach("lines3")
func set_speed(s: int) -> void:
	speed = s
	refresh_speed_buttons()
func vibrate() -> void:
	if opts["vibrate"]:
		Input.vibrate_handheld(18)
func road_next_to(i: int, tram: bool) -> int:
	if road[i] > 0 and (not tram or wire[i] & W_TRAM):
		return i
	for r in range(1, 3):
		for dz in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var x := cx(i) + dx
				var z := cz(i) + dz
				if inb(x, z):
					var j := idx(x, z)
					if road[j] > 0 and (not tram or wire[j] & W_TRAM):
						return j
	return -1
func road_path(from: int, to: int, tram: bool) -> Array:
	var a := road_next_to(from, tram)
	var b := road_next_to(to, tram)
	if a < 0 or b < 0:
		return []
	if a == b:
		return [a]
	var prev := {a: a}
	var q: Array = [a]
	var head := 0
	while head < q.size() and head < 20000:
		var c: int = q[head]
		head += 1
		if c == b:
			break
		for o in [1, -1, N, -N]:
			var j: int = c + o
			if j < 0 or j >= N * N or prev.has(j) or road[j] == 0:
				continue
			if (o == 1 or o == -1) and cz(j) != cz(c):
				continue
			if tram and not (wire[j] & W_TRAM):
				continue
			prev[j] = c
			q.append(j)
	if not prev.has(b):
		return []
	var path: Array = [b]
	var c2: int = b
	while c2 != a:
		c2 = prev[c2]
		path.push_front(c2)
	return path
func route_line(ln: Dictionary) -> void:
	var pts: Array = []
	var stop_k: Array = []
	var st: Array = ln["stops"]
	var kind: String = ln["kind"]
	var n := st.size()
	if n < 2:
		ln["pts"] = []
		return
	for s in n:
		var a: int = st[s]
		var b: int = st[(s + 1) % n]
		stop_k.append(pts.size())
		if kind == "bus" or kind == "tram":
			var path := road_path(a, b, kind == "tram")
			if path.is_empty():
				ln["pts"] = []
				ln["broken"] = true
				return
			for c in path:
				var pp := cell_pos(c)
				if terr[c] == T_WATER:
					pp.y = 0.6
				pts.append(pp)
		else:
			var pa := def_center(a)
			var pb := def_center(b)
			var y := -4.0
			if kind == "train":
				y = 7.0
			elif kind == "ferry":
				y = WATER_Y
			pa.y = y
			pb.y = y
			var steps := maxi(2, int(pa.distance_to(pb) / CELL))
			for k in steps:
				pts.append(pa.lerp(pb, float(k) / steps))
	ln["pts"] = pts
	ln["stopk"] = stop_k
	ln["broken"] = false
	ln["dwell"] = 0.0
	rebuild_rails()
func reroute_all() -> void:
	for ln in lines:
		route_line(ln)
var cine_told: bool = false
