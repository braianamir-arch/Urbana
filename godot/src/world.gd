# El mapa: celdas, terreno, generación y utilidades.
const DAYS_PER_SEASON := 10
const YEAR_DAYS := 40
const RCAP := [0, 60, 170, 400, 850]
const ROUND_CAP := 520
const CAP_R := [0, 6, 14, 30, 64]
const CAP_MR := [0, 4, 10, 22, 48]
const FIRST_NAMES := ["Marta", "Juan", "Lucía", "Diego", "Sofía", "Carlos", "Valentina", "Martín", "Camila", "Jorge", "Florencia", "Pablo", "Rocío", "Nicolás", "Julieta", "Lionel", "Ana", "Gustavo", "Belén", "Facundo"]
const LAST_NAMES := ["González", "Rodríguez", "Gómez", "Fernández", "López", "Díaz", "Martínez", "Pérez", "Romero", "Sosa", "Álvarez", "Torres", "Ruiz", "Ramírez", "Flores", "Benítez", "Acosta", "Medina"]
const STREET_NAMES := ["San Martín", "Belgrano", "Rivadavia", "Sarmiento", "Mitre", "Moreno", "Alvear", "Güemes", "Lavalle", "Pueyrredón", "Corrientes", "Mendoza", "Tucumán", "Córdoba", "Entre Ríos", "Santa Fe", "Las Heras", "Urquiza", "Alberdi", "Brown", "Dorrego", "Castelli", "Paso", "French"]
const NEIGHBOR_CITIES := ["San Ramón", "Villa Esperanza", "Puerto Grande"]
func idx(x: int, z: int) -> int:
	return z * N + x
func inb(x: int, z: int) -> bool:
	return x >= 0 and z >= 0 and x < N and z < N
func cx(i: int) -> int:
	return i % N
func cz(i: int) -> int:
	return i / N
func cell_pos(i: int) -> Vector3:
	return Vector3((cx(i) + 0.5) * CELL - N * CELL * 0.5, hgt[i], (cz(i) + 0.5) * CELL - N * CELL * 0.5)
func world_to_cell(p: Vector3) -> Vector2i:
	return Vector2i(floori((p.x + N * CELL * 0.5) / CELL), floori((p.z + N * CELL * 0.5) / CELL))
func region_of(i: int) -> int:
	return (cz(i) / REG) * NREG + (cx(i) / REG)
func is_owned(i: int) -> bool:
	return creative or owned[region_of(i)] == 1
func season() -> int:
	return ((day - 1) / DAYS_PER_SEASON) % 4
func doy() -> int:
	return (day - 1) % YEAR_DAYS
func year() -> int:
	return (day - 1) / YEAR_DAYS + 1
func is_sunday() -> bool:
	return day % 7 == 0
func has_decree(id: String) -> bool:
	return decrees.get(id, false)
func buildable(i: int) -> bool:
	return terr[i] != T_WATER and flood[i] <= 0.0
func empty_cell(i: int) -> bool:
	return road[i] == 0 and zone[i] == 0 and bld[i] == 0
func anchor_of(i: int) -> int:
	return part[i] if part[i] >= 0 else i
func def_of(i: int) -> Dictionary:
	if bld[i] == 0:
		return {}
	return DEF[bld[i]]
func road_near(i: int, r: int) -> bool:
	var x := cx(i)
	var z := cz(i)
	for dz in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if abs(dx) + abs(dz) > r:
				continue
			var xx := x + dx
			var zz := z + dz
			if inb(xx, zz) and road[idx(xx, zz)] > 0:
				return true
	return false
func near_water(i: int, r: int) -> bool:
	var x := cx(i)
	var z := cz(i)
	for dz in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var xx := x + dx
			var zz := z + dz
			if inb(xx, zz) and terr[idx(xx, zz)] == T_WATER:
				return true
	return false
func fmt_money(v: float) -> String:
	var neg := v < 0
	var s := str(int(absf(v)))
	var out := ""
	var c := 0
	for k in range(s.length() - 1, -1, -1):
		out = s[k] + out
		c += 1
		if c % 3 == 0 and k > 0:
			out = "." + out
	return ("-$" if neg else "$") + out
func fmt_int(v: int) -> String:
	return fmt_money(float(v)).substr(1)
func rand_name() -> String:
	return FIRST_NAMES[randi() % FIRST_NAMES.size()] + " " + LAST_NAMES[randi() % LAST_NAMES.size()]
func street_name(i: int) -> String:
	if i < 0:
		return ""
	var x := cx(i)
	var z := cz(i)
	var horiz := (x > 0 and road[i - 1] > 0) or (x < N - 1 and road[i + 1] > 0)
	var prefix := "Av. " if road[i] >= 3 else "Calle "
	if road[i] == 4:
		prefix = "Autopista "
	if horiz:
		return prefix + STREET_NAMES[z % STREET_NAMES.size()]
	return prefix + STREET_NAMES[(x * 7 + 3) % STREET_NAMES.size()]
func count_add(k: String, v: float = 1.0) -> void:
	counters[k] = counters.get(k, 0.0) + v
	counters["day_" + k] = counters.get("day_" + k, 0.0) + v
func alloc_arrays() -> void:
	var nn := N * N
	terr.resize(nn); terr.fill(0)
	hgt.resize(nn); hgt.fill(0.0)
	road.resize(nn); road.fill(0)
	zone.resize(nn); zone.fill(0)
	bld.resize(nn); bld.fill(0)
	lvl.resize(nn); lvl.fill(0)
	part.resize(nn); part.fill(-1)
	occ.resize(nn); occ.fill(0.0)
	vari.resize(nn); vari.fill(0)
	tree.resize(nn); tree.fill(0)
	wire.resize(nn); wire.fill(0)
	burn.resize(nn); burn.fill(0.0)
	garbp.resize(nn); garbp.fill(0.0)
	flood.resize(nn); flood.fill(0.0)
	wdist.resize(nn); wdist.fill(99.0)
	powered.resize(nn); powered.fill(0)
	watered.resize(nn); watered.fill(0)
	pollution.resize(nn); pollution.fill(0.0)
	landv.resize(nn); landv.fill(0.3)
	crime.resize(nn); crime.fill(0.0)
	happy.resize(nn); happy.fill(0.6)
	tload.resize(nn); tload.fill(0.0)
	edu.resize(nn); edu.fill(0)
	why.resize(nn); why.fill(0)
	owned.resize(NREG * NREG); owned.fill(0)
	district.resize(NREG * NREG); district.fill(0)
	cov.clear()
	for k in NCV:
		var a := PackedFloat32Array()
		a.resize(nn)
		a.fill(0.0)
		cov.append(a)
func gen_map(kind: int, seed_v: int) -> void:
	map_kind = kind
	map_seed = seed_v
	alloc_arrays()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var nz := FastNoiseLite.new()
	nz.seed = seed_v
	nz.frequency = 0.035
	var nz2 := FastNoiseLite.new()
	nz2.seed = seed_v + 77
	nz2.frequency = 0.08
	var c := N * 0.5
	for z in N:
		for x in N:
			var i := idx(x, z)
			var n1 := nz.get_noise_2d(x, z)
			var n2 := nz2.get_noise_2d(x, z)
			var water := false
			match kind:
				0:
					var rx := c + sin(z * 0.06 + seed_v) * 14.0 + n1 * 8.0
					water = absf(x - rx) < 3.2 + n2 * 1.2
				1:
					var lx := c + 26.0
					var lz := c - 22.0
					water = Vector2(x - lx, z - lz).length() < 17.0 + n1 * 7.0
				2:
					water = x > N * 0.74 + n1 * 9.0
				3:
					var d := Vector2(x - c, z - c).length()
					water = d > 50.0 + n1 * 12.0 or (n2 > 0.55 and d > 20.0)
				4:
					water = Vector2(x - (c - 30), z - (c + 28)).length() < 6.0 + n1 * 3.0
			if water:
				terr[i] = T_WATER
				hgt[i] = -1.6
			else:
				var edge := clampf((Vector2(x - c, z - c).length() - 30.0) / 30.0, 0.0, 1.0)
				var h := maxf(0.0, (n1 + 0.15) * 9.0) * edge
				if kind == 4:
					h *= 0.4
				h = snappedf(h, 0.5)
				hgt[i] = h
				if h >= 3.0:
					terr[i] = T_ROCK
	for i in N * N:
		if terr[i] == T_WATER:
			continue
		if near_water(i, 1) and hgt[i] < 1.5:
			terr[i] = T_SAND
			hgt[i] = 0.0
	compute_wdist()
	for z in N:
		for x in N:
			var i := idx(x, z)
			if terr[i] == T_WATER or terr[i] == T_ROCK:
				continue
			var f := nz2.get_noise_2d(x * 1.7 + 50, z * 1.7)
			var dc := Vector2(x - c, z - c).length()
			if (f > 0.35 and dc > 12.0) or rng.randf() < 0.012:
				tree[i] = pick_tree_kind(i, rng)
	for r in [5, 6, 9, 10]:
		owned[r] = 1
	var hz := N / 2
	for x in range(0, N / 2 - 6):
		var i := idx(x, hz)
		road[i] = 4
		tree[i] = 0
		if terr[i] == T_ROCK:
			terr[i] = T_LAND
			hgt[i] = 0.0
	for z in range(int(c) - 20, int(c) + 20):
		for x in range(int(c) - 20, int(c) + 20):
			var i := idx(x, z)
			if terr[i] != T_WATER and terr[i] != T_SAND:
				hgt[i] = minf(hgt[i], 0.0)
				if terr[i] == T_ROCK:
					terr[i] = T_LAND
	init_neighbors()
func pick_tree_kind(i: int, rng: RandomNumberGenerator) -> int:
	if terr[i] == T_SAND:
		return 6
	if wdist[i] <= 2.0:
		return 7
	var r := rng.randi() % 10
	if r < 3:
		return 1
	if r < 5:
		return 2
	if r < 6:
		return 3
	if r < 8:
		return 4
	return 5
func compute_wdist() -> void:
	var q: Array = []
	for i in N * N:
		if terr[i] == T_WATER:
			wdist[i] = 0.0
			q.append(i)
		else:
			wdist[i] = 99.0
	var head := 0
	while head < q.size():
		var i: int = q[head]
		head += 1
		var d: float = wdist[i]
		if d >= 20.0:
			continue
		var x := cx(i)
		var z := cz(i)
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var xx: int = x + o.x
			var zz: int = z + o.y
			if not inb(xx, zz):
				continue
			var j := idx(xx, zz)
			if wdist[j] > d + 1.0:
				wdist[j] = d + 1.0
				q.append(j)
func init_neighbors() -> void:
	neighbors.clear()
	for n in NEIGHBOR_CITIES:
		neighbors.append({"n": n, "rel": 50.0})
func hsh(i: int, k: int) -> float:
	var v := (i * 73856093) ^ (k * 19349663)
	v = (v ^ (v >> 13)) * 1274126177
	return float(v & 0xffff) / 65535.0
func road_n(i: int) -> Array:
	var x := cx(i)
	var z := cz(i)
	return [x < N - 1 and road[i + 1] > 0, x > 0 and road[i - 1] > 0, z < N - 1 and road[i + N] > 0, z > 0 and road[i - N] > 0]
func vert_h(x: int, z: int) -> float:
	var hs := 0.0
	var cnt := 0
	for o in [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]:
		var xx: int = x + o.x
		var zz: int = z + o.y
		if inb(xx, zz):
			hs += hgt[idx(xx, zz)]
			cnt += 1
	return hs / maxf(cnt, 1)
func ground_y(wx: float, wz: float) -> float:
	var half := N * CELL * 0.5
	var fx := (wx + half) / CELL
	var fz := (wz + half) / CELL
	var x0 := clampi(int(floor(fx)), 0, N - 1)
	var z0 := clampi(int(floor(fz)), 0, N - 1)
	var u := clampf(fx - x0, 0.0, 1.0)
	var v := clampf(fz - z0, 0.0, 1.0)
	var ha := vert_h(x0, z0)
	var hb := vert_h(x0 + 1, z0)
	var hc := vert_h(x0, z0 + 1)
	var hd := vert_h(x0 + 1, z0 + 1)
	if u >= v:
		return ha + (hb - ha) * u + (hd - hb) * v
	return ha + (hc - ha) * v + (hd - hc) * u
func face_rot(i: int) -> float:
	var nb := road_n(i)
	if nb[2]:
		return 0.0
	if nb[3]:
		return PI
	if nb[0]:
		return PI * 0.5
	if nb[1]:
		return -PI * 0.5
	return 0.0
func road_cap(i: int) -> float:
	if wire[i] & W_ROUND:
		return float(ROUND_CAP)
	var c: float = RCAP[road[i]]
	if weather == "Nieve":
		c *= 0.7
	return maxf(c, 1.0)
func def_cells(a: int, sz: int) -> Array:
	var out: Array = []
	if a < 0:
		return out
	var x0 := cx(a) - (sz - 1) / 2
	var z0 := cz(a) - (sz - 1) / 2
	for dz in sz:
		for dx in sz:
			if inb(x0 + dx, z0 + dz):
				out.append(idx(x0 + dx, z0 + dz))
	return out
func near_road_cell(a: int, r: int) -> int:
	var x := cx(a)
	var z := cz(a)
	for dz in range(-r, r + 2):
		for dx in range(-r, r + 2):
			if inb(x + dx, z + dz) and road[idx(x + dx, z + dz)] > 0:
				return idx(x + dx, z + dz)
	return -1
func bike_near(i: int) -> bool:
	for dz in range(-3, 4):
		for dx in range(-3, 4):
			var x := cx(i) + dx
			var z := cz(i) + dz
			if inb(x, z) and wire[idx(x, z)] & W_BIKE:
				return true
	return false
func zone_cap(z: int, l: int) -> int:
	match z:
		Z_R:
			return CAP_R[l]
		Z_C:
			return CAP_C[l]
		Z_I:
			return CAP_I[l]
		Z_M:
			return CAP_MR[l]
	return 0
func zone_count(z: int) -> int:
	var n := 0
	for i in zone_list:
		if zone[i] == z:
			n += 1
	return n
func def_center(a: int) -> Vector3:
	var p := cell_pos(a)
	if bld[a] > 0:
		var sz: int = DEF[bld[a]]["sz"]
		p.x += (sz - 1) * CELL * 0.5
		p.z += (sz - 1) * CELL * 0.5
	return p
func place_plaza() -> void:
	var c := N / 2
	for z in range(c - 2, c + 2):
		for x in range(c - 2, c + 2):
			var i := idx(x, z)
			if terr[i] == T_WATER:
				return
	for z in range(c - 2, c + 2):
		for x in range(c - 2, c + 2):
			var i := idx(x, z)
			if x == c - 2 or x == c + 1 or z == c - 2 or z == c + 1:
				road[i] = 2
			tree[i] = 0
			terr[i] = T_LAND if terr[i] == T_ROCK else terr[i]
			hgt[i] = 0.0
	var a := idx(c - 1, c - 1)
	for dz in 2:
		for dx in 2:
			var j := a + dz * N + dx
			bld[j] = 31
			part[j] = a
	for x in range(N / 2 - 6, c - 2):
		var i := idx(x, c - 1)
		if terr[i] != T_WATER:
			road[i] = maxi(road[i], 3)
			tree[i] = 0
