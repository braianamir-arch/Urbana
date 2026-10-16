# Simulación: redes, servicios, felicidad, crecimiento, economía y días.
const ROAD_UPK := [0.0, 0.03, 0.08, 0.2, 0.5]
const CAP_MJ := [0, 3, 6, 12, 24]
const REQUESTS := [
	["una plaza cerca", CV_PARK], ["más policía", CV_POL], ["una salita", CV_HEALTH],
	["una escuela", CV_EDU1], ["un colectivo", CV_TRANSIT], ["bomberos cerca", CV_FIRE],
]
var trips_total: int = 0
var trips_green: int = 0
var sim_acc: float = 0.0
var sim_cycle: int = 0
var jobs_c: int = 0
var jobs_i: int = 0
var jobs_cap: int = 0
var class_mult: float = 1.0
var epidemic_days: int = 0
func speed_mult() -> float:
	return [0.0, 1.0, 2.0, 4.0][speed]
func sim_process(delta: float) -> void:
	var m := speed_mult()
	if m <= 0.0 or not started:
		return
	day_timer += delta * m
	sim_acc += delta * m
	if sim_stage < 0 and sim_acc >= 1.0:
		sim_acc = 0.0
		sim_stage = 0
	# a la velocidad más rápida van dos pasos por cuadro, así la ciudad crece al mismo ritmo que antes
	for rep_k in (2 if m >= 4.0 else 1):
		if sim_stage < 0:
			break
		lab_step = sim_stage
		run_sim_step(sim_stage)
		sim_stage += 1
		if sim_stage > 21:
			sim_stage = -1
			sim_cycle += 1
	if day_timer >= DAY_SECONDS:
		day_timer -= DAY_SECONDS
		if not day_queue.is_empty():
			# por si el día anterior no terminó (velocidad muy alta): se completa ahora
			for p in day_queue:
				new_day_part(p)
		day_queue = DAY_PARTS.duplicate()
	if not day_queue.is_empty():
		lab_step = 22 + DAY_PARTS.find(day_queue[0])
		new_day_part(day_queue.pop_front())
# en el juego las etapas pesadas se reparten en más cuadros (mismo trabajo, en el mismo orden que
# run_sim_stage, que es lo que usan las pruebas y la carga de partidas)
var net_on: bool = false
var tr_on: bool = false
func run_sim_step(k: int) -> void:
	match k:
		0:
			collect_lists()
			net_on = sim_dirty or sim_cycle % 5 == 0
		1, 2, 3, 4, 5, 6:
			if net_on:
				var ps := (k - 1) / 3
				match (k - 1) % 3:
					0:
						net_a(ps)
					1:
						net_b(ps)
					2:
						net_c(ps)
						if ps == 1:
							net_finish()
		7:
			compute_coverage()
		8:
			env_a()
		9:
			env_b_part(0, 2)
		10:
			env_b_part(1, 2)
		11:
			tr_on = sim_dirty or sim_cycle % 3 == 0
			if tr_on:
				traffic_a()
		12:
			if tr_on:
				tb_start()
		13, 14, 15, 16:
			if tr_on:
				tb_trips(65)
		17:
			if tr_on:
				tb_trips(tb_sample)
				tb_end()
		18:
			compute_happiness()
		19:
			grow_zones()
		20:
			compute_stats()
			fire_tick()
		21:
			sim_dirty = false
			check_progress()
func run_sim_stage(s: int) -> void:
	match s:
		0:
			collect_lists()
			if sim_dirty or sim_cycle % 5 == 0:
				compute_networks()
		1:
			compute_coverage()
		2:
			compute_env()
		3:
			if sim_dirty or sim_cycle % 3 == 0:
				compute_traffic()
		4:
			compute_happiness()
		5:
			grow_zones()
		6:
			compute_stats()
			fire_tick()
		7:
			sim_dirty = false
			check_progress()
func collect_lists() -> void:
	zone_list.clear()
	anchors.clear()
	for i in N * N:
		if zone[i] > 0:
			zone_list.append(i)
		elif bld[i] > 0 and (part[i] < 0 or part[i] == i):
			anchors.append(i)
func def_active(a: int) -> bool:
	var d: Dictionary = DEF[bld[a]]
	if d["c"] == "wonder" and wonder_progress.get(a, 0) < WONDER_STEPS:
		return false
	if burn[a] > 0.0:
		return false
	return road_near(a, d["sz"])
func conducts(i: int, water: bool) -> bool:
	if road[i] > 0 or zone[i] > 0 or bld[i] > 0:
		return true
	return (wire[i] & (W_PIPE if water else W_POWER)) != 0
func compute_networks() -> void:
	for pass_i in 2:
		net_pass(pass_i)
	net_finish()
# una red (0 luz, 1 agua): en el juego cada una va en su propio cuadro para no trabar
func net_pass(pass_i: int) -> void:
	net_a(pass_i)
	net_b(pass_i)
	net_c(pass_i)
var nt_sup: Array = []
var nt_use: Array = []
var nt_ncomp: int = 0
var nt_bcid: Dictionary = {}
var nt_cond := PackedByteArray()
# 1) qué celdas conducen y cómo se agrupan en redes
func net_a(pass_i: int) -> void:
	var water := pass_i == 1
	comp.resize(N * N)
	comp.fill(-1)
	var sup: Array = []
	var use: Array = []
	var ncomp := 0
	var q := PackedInt32Array()
	# conducts() una sola vez por celda (antes se preguntaba hasta 4 veces)
	nt_cond.resize(N * N)
	for i in N * N:
		nt_cond[i] = 1 if conducts(i, water) else 0
	var cond := nt_cond
	for i in N * N:
		if comp[i] >= 0 or cond[i] == 0:
			continue
		var cid := ncomp
		ncomp += 1
		sup.append(0.0)
		use.append(0.0)
		q.clear()
		q.append(i)
		comp[i] = cid
		var head := 0
		while head < q.size():
			var j := q[head]
			head += 1
			var x := cx(j)
			var z := cz(j)
			if x > 0 and comp[j - 1] < 0 and cond[j - 1] == 1:
				comp[j - 1] = cid
				q.append(j - 1)
			if x < N - 1 and comp[j + 1] < 0 and cond[j + 1] == 1:
				comp[j + 1] = cid
				q.append(j + 1)
			if z > 0 and comp[j - N] < 0 and cond[j - N] == 1:
				comp[j - N] = cid
				q.append(j - N)
			if z < N - 1 and comp[j + N] < 0 and cond[j + N] == 1:
				comp[j + N] = cid
				q.append(j + N)
	nt_sup = sup
	nt_use = use
	nt_ncomp = ncomp
# 2) cuánto consume y produce cada red
func net_b(pass_i: int) -> void:
	var water := pass_i == 1
	var sup: Array = nt_sup
	var use: Array = nt_use
	var bcid := {}
	for i in N * N:
		if bld[i] > 0 and (part[i] < 0 or part[i] == i):
			var rc := near_road_cell(i, DEF[bld[i]]["sz"])
			if rc >= 0 and comp[rc] >= 0:
				bcid[i] = comp[rc]
	for i in N * N:
		var cid := comp[i]
		if bld[i] > 0:
			cid = bcid.get(anchor_of(i), cid)
		if cid < 0:
			continue
		if zone[i] > 0:
			var l := float(lvl[i])
			var u := 0.0
			match zone[i]:
				Z_R:
					u = l * (1.0 if not water else 1.2)
				Z_C:
					u = l * (1.5 if not water else 1.0)
				Z_I:
					u = l * (2.5 if not water else 1.8)
				Z_M:
					u = l * 1.2
			use[cid] += u
		elif bld[i] > 0 and (part[i] < 0 or part[i] == i):
			var d: Dictionary = DEF[bld[i]]
			var key := "wt" if water else "pw"
			if d.has(key) and def_active(i):
				var eff := 1.0
				if not water and bld[i] == 44 and night > 0.5:
					eff = 0.3
				sup[cid] += float(d[key]) * eff
			else:
				use[cid] += 3.0 + float(d["upk"]) * 0.05
	nt_bcid = bcid
# 3) a quién le llega
func net_c(pass_i: int) -> void:
	var water := pass_i == 1
	var sup: Array = nt_sup
	var use: Array = nt_use
	var ncomp := nt_ncomp
	var bcid: Dictionary = nt_bcid
	var tot_sup := 0.0
	var tot_use := 0.0
	var frac: Array = []
	for k in ncomp:
		tot_sup += sup[k]
		tot_use += use[k]
		var f: float = 1.0 if use[k] <= sup[k] else (sup[k] / maxf(use[k], 0.01))
		if f < 1.0 and trade_ok and sup[k] > 0.0:
			f = minf(1.0, f + 0.25)
		frac.append(f)
	var arr := watered if water else powered
	var got := 0
	var need := 0
	for i in N * N:
		var cid := comp[i]
		if bld[i] > 0:
			cid = bcid.get(anchor_of(i), cid)
		var v := 0
		if cid >= 0 and sup[cid] > 0.0:
			var f: float = frac[cid]
			v = 1 if f >= 1.0 or hsh(i, day + pass_i) < f else 0
		arr[i] = v
		if zone[i] > 0 and lvl[i] > 0:
			need += 1
			got += v
	if water:
		watered = arr
		water_sup = tot_sup
		water_use = tot_use
		water_frac = float(got) / maxf(need, 1)
	else:
		powered = arr
		power_sup = tot_sup
		power_use = tot_use
		power_frac = float(got) / maxf(need, 1)
func net_finish() -> void:
	var clean := 0.0
	var all := 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if d.has("pw"):
			all += d["pw"]
			if bld[a] in [44, 45, 46]:
				clean += d["pw"]
	green_power = clean / maxf(all, 1.0)
	trade_ok = false
	for k in N:
		for j in [idx(k, 0), idx(k, N - 1), idx(0, k), idx(N - 1, k)]:
			if road[j] == 4:
				trade_ok = true
	for a in anchors:
		if bld[a] == 0:
			continue
		if DEF[bld[a]].get("trade", false) and def_active(a):
			trade_ok = true
func stamp(layer: PackedFloat32Array, cxi: int, czi: int, r: float, amount: float) -> PackedFloat32Array:
	var ri := int(ceil(r))
	for dz in range(-ri, ri + 1):
		var zz := czi + dz
		if zz < 0 or zz >= N:
			continue
		for dx in range(-ri, ri + 1):
			var xx := cxi + dx
			if xx < 0 or xx >= N:
				continue
			var d := sqrt(float(dx * dx + dz * dz))
			if d > r:
				continue
			var j := zz * N + xx
			layer[j] += amount * (1.0 - d / (r + 1.0))
	return layer
func residents_near(cxi: int, czi: int, r: int) -> float:
	var s := 0.0
	for dz in range(-r, r + 1, 2):
		var zz := czi + dz
		if zz < 0 or zz >= N:
			continue
		for dx in range(-r, r + 1, 2):
			var xx := cxi + dx
			if xx < 0 or xx >= N:
				continue
			var j := zz * N + xx
			if zone[j] == Z_R or zone[j] == Z_M:
				s += occ[j]
	return s * 4.0
func compute_coverage() -> void:
	for t in NCV:
		var a: PackedFloat32Array = cov[t]
		a.fill(0.0)
		cov[t] = a
	hp_bonus = 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if not def_active(a):
			continue
		hp_bonus += d.get("hp", 0.0)
		if not d.has("cov"):
			continue
		var sz: int = d["sz"]
		var mx := cx(a) + (sz - 1) / 2
		var mz := cz(a) + (sz - 1) / 2
		var eff := 1.0
		if d.has("dep"):
			eff *= budget[d["dep"]] / 100.0
		if not powered[a]:
			eff *= 0.6
		if d.has("cap"):
			var r0: int = d["cov"].values()[0]
			var served := residents_near(mx, mz, r0)
			eff *= clampf(float(d["cap"]) / maxf(served, 1.0), 0.45, 1.0)
		if d.has("stop"):
			var used := false
			for ln in lines:
				if a in ln["stops"] and ln["pts"].size() > 1:
					used = true
			if not used:
				continue
		for t in d["cov"]:
			var r: float = d["cov"][t]
			cov[t] = stamp(cov[t], mx, mz, r, eff * 1.4)
	for s in stops:
		var used := false
		for ln in lines:
			if s in ln["stops"] and ln["pts"].size() > 1:
				used = true
		if used:
			cov[CV_TRANSIT] = stamp(cov[CV_TRANSIT], cx(s), cz(s), 5.0, 1.2 * budget[5] / 100.0)
	hp_bonus = minf(0.1, hp_bonus / (1.0 + pop / 3000.0))
var env_half: int = 0
func compute_env() -> void:
	env_a()
	env_b()
func env_a() -> void:
	pollution.fill(0.0)
	var green := 0.6 if has_decree("verde") else 1.0
	for i in zone_list:
		if zone[i] == Z_I and lvl[i] > 0:
			pollution = stamp(pollution, cx(i), cz(i), 5.0, lvl[i] * 0.07 * green)
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if d.has("pol") and def_active(a):
			pollution = stamp(pollution, cx(a), cz(a), 7.0, float(d["pol"]) * 0.45)
	for i in N * N:
		if road[i] == 4 and tload[i] > 100.0:
			pollution[i] += 0.15
		if tree[i] > 0:
			pollution[i] -= 0.06
func env_b() -> void:
	env_b_part(0, 2)
	env_b_part(1, 2)
func env_b_part(k: int, parts: int) -> void:
	var pc: PackedFloat32Array = cov[CV_POL]
	var pk: PackedFloat32Array = cov[CV_PARK]
	var hc: PackedFloat32Array = cov[CV_HEALTH]
	var e1: PackedFloat32Array = cov[CV_EDU1]
	var tc: PackedFloat32Array = cov[CV_TRANSIT]
	var crime_mod: float = mods["crime"] - (0.1 if has_decree("patrulla") else 0.0) - (0.08 if has_decree("toque") else 0.0)
	if k == 0:
		env_half = 1 - env_half
	var half := N * N / 2
	var r0 := env_half * half
	var r1 := env_half * half + half + (N * N - 2 * half) * env_half
	var ln := r1 - r0
	for i in range(r0 + ln * k / parts, r0 + ln * (k + 1) / parts):
		var p := clampf(pollution[i], 0.0, 1.5)
		pollution[i] = p
		if terr[i] == T_WATER:
			continue
		var lv := 0.32 + 0.25 * minf(pk[i], 1.2) + 0.08 * minf(hc[i], 1.0) + 0.06 * minf(e1[i], 1.0) + 0.06 * minf(tc[i], 1.0) - 0.5 * p - 0.2 * crime[i]
		if wdist[i] < 5.0:
			lv += 0.16 * (1.0 - wdist[i] / 5.0)
		if hgt[i] > 0.5:
			lv += 0.05
		var r := region_of(i)
		if district[r] == 2:
			lv += 0.05
		landv[i] = clampf(lv, 0.0, 1.0)
		if zone[i] > 0 and lvl[i] > 0:
			var c := 0.12 + unemployment * 0.45 + lvl[i] * 0.04 - minf(pc[i], 1.2) * 0.55 + crime_mod
			if district[r] == 3:
				c -= 0.1
			if district[r] == 4:
				c += 0.05
			crime[i] = clampf(c, 0.0, 1.0)
		else:
			crime[i] = 0.0
var tr_dist := PackedInt32Array()
var tr_nxt := PackedInt32Array()
func compute_traffic() -> void:
	traffic_a()
	traffic_b()
# caminos de las casas a los trabajos: primero la búsqueda (un cuadro) y después los viajes (otro)
func traffic_a() -> void:
	var nn := N * N
	var dist := PackedInt32Array()
	dist.resize(nn)
	dist.fill(-1)
	var nxt := PackedInt32Array()
	nxt.resize(nn)
	nxt.fill(-1)
	var q := PackedInt32Array()
	for i in zone_list:
		if (zone[i] == Z_C or zone[i] == Z_I or zone[i] == Z_M) and lvl[i] > 0:
			for o in [1, -1, N, -N]:
				var j: int = i + o
				if j >= 0 and j < nn and road[j] > 0 and dist[j] < 0:
					dist[j] = 0
					q.append(j)
	for a in anchors:
		if bld[a] == 0:
			continue
		if DEF[bld[a]].get("job", 0) > 0:
			for o in [1, -1, N, -N]:
				var j: int = a + o
				if j >= 0 and j < nn and road[j] > 0 and dist[j] < 0:
					dist[j] = 0
					q.append(j)
	var head := 0
	while head < q.size():
		var j := q[head]
		head += 1
		var x := cx(j)
		var dj := dist[j] + 1
		for o in [1, -1, N, -N]:
			var k: int = j + o
			if k < 0 or k >= nn or road[k] == 0 or dist[k] >= 0:
				continue
			if (o == 1 and x == N - 1) or (o == -1 and x == 0):
				continue
			dist[k] = dj
			nxt[k] = j
			q.append(k)
	tr_dist = dist
	tr_nxt = nxt
func traffic_b() -> void:
	tb_start()
	tb_trips(tb_sample)
	tb_end()
var tb_newload := PackedFloat32Array()
var tb_homes: Array = []
var tb_sample: int = 0
var tb_done: int = 0
var tb_w: float = 0.0
var tb_tot_len: float = 0.0
var tb_trips_n: int = 0
var tb_green: float = 0.0
var tb_lots: Array = []
func tb_start() -> void:
	var nn := N * N
	var newload := PackedFloat32Array()
	newload.resize(nn)
	newload.fill(0.0)
	commute.resize(nn)
	var homes: Array = []
	for i in zone_list:
		if (zone[i] == Z_R or zone[i] == Z_M) and lvl[i] > 0:
			homes.append(i)
	var sample := mini(homes.size(), 260)
	var w := float(pop) / maxf(sample, 1) * 0.35
	var tot_len := 0.0
	var trips := 0
	var green := 0.0
	car_paths.clear()
	var tcov: PackedFloat32Array = cov[CV_TRANSIT]
	var lots: Array = []
	for a in anchors:
		if bld[a] > 0 and DEF[bld[a]].get("park", false):
			lots.append(a)
	tb_newload = newload
	tb_homes = homes
	tb_sample = sample
	tb_done = 0
	tb_w = w
	tb_tot_len = tot_len
	tb_trips_n = trips
	tb_green = green
	tb_lots = lots
# hasta n viajes más (en el juego van en tandas, en el mismo orden)
func tb_trips(n: int) -> void:
	var nn := N * N
	var dist := tr_dist
	var nxt := tr_nxt
	var newload := tb_newload
	var homes: Array = tb_homes
	var w := tb_w
	var tot_len := tb_tot_len
	var trips := tb_trips_n
	var green := tb_green
	var tcov: PackedFloat32Array = cov[CV_TRANSIT]
	var lots: Array = tb_lots
	var end := mini(tb_done + n, tb_sample)
	for s in range(tb_done, end):
		var h: int = homes[randi() % homes.size()]
		var r0 := -1
		for o in [1, -1, N, -N]:
			var j: int = h + o
			if j >= 0 and j < nn and road[j] > 0 and dist[j] >= 0:
				r0 = j
				break
		if r0 < 0:
			commute[h] = 0.6
			continue
		var tshare := clampf(tcov[h] * 0.55 + (0.15 if has_decree("boleto") else 0.0), 0.0, 0.7)
		var bshare := 0.0
		if bike_near(h):
			bshare = 0.12 + (0.06 if has_decree("bici") and is_sunday() else 0.0)
		var car := maxf(0.0, 1.0 - tshare - bshare)
		var path: Array = []
		var j := r0
		var steps := 0
		var cong := 0.0
		while j >= 0 and steps < 400:
			newload[j] += w * car
			path.append(j)
			cong += tload[j] / road_cap(j)
			j = nxt[j]
			steps += 1
		tot_len += steps
		trips += 1
		green += tshare + bshare
		var c := clampf(cong / maxf(steps, 1) - 0.6, 0.0, 1.0)
		for lt in lots:
			if absi(cx(lt) - cx(h)) <= 8 and absi(cz(lt) - cz(h)) <= 8:
				c *= 0.75
				break
		commute[h] = c
		if car_paths.size() < 70 and path.size() > 3:
			car_paths.append(path)
	tb_done = end
	tb_newload = newload
	tb_tot_len = tot_len
	tb_trips_n = trips
	tb_green = green
func tb_end() -> void:
	var nn := N * N
	var newload := tb_newload
	var tot_len := tb_tot_len
	var trips := tb_trips_n
	var green := tb_green
	for i in nn:
		tload[i] = tload[i] * 0.4 + newload[i] * 0.6
	avg_commute = tot_len / maxf(trips, 1)
	if trips > 0:
		trips_total += trips
		trips_green += int(green)
	counters["green_share"] = green / maxf(trips, 1)
func compute_happiness() -> void:
	var hc: PackedFloat32Array = cov[CV_HEALTH]
	var e1: PackedFloat32Array = cov[CV_EDU1]
	var e2: PackedFloat32Array = cov[CV_EDU2]
	var e3: PackedFloat32Array = cov[CV_EDU3]
	var pk: PackedFloat32Array = cov[CV_PARK]
	var pc: PackedFloat32Array = cov[CV_POL]
	var fc: PackedFloat32Array = cov[CV_FIRE]
	var base := 0.5 + float(mods["hp"]) + hp_bonus
	if pop < 300:
		base += 0.1
	elif pop < 700:
		base += 0.05
	if festival_days > 0:
		base += 0.06
	if has_decree("luz"):
		base += 0.04
	if has_decree("alquiler"):
		base += 0.03
	if has_decree("toque"):
		base -= 0.04
	if epidemic_days > 0:
		base -= 0.08
	var tax_pen := maxf(0.0, (tax[0] - 9) * 0.015) - maxf(0.0, (9 - tax[0]) * 0.006)
	var sum_h := 0.0
	var cnt := 0
	classes = [0, 0, 0]
	var cls_tax := 0.0
	var edu_bonus: float = mods["edu"] + (0.3 if has_decree("adultos") else 0.0)
	for i in zone_list:
		if not (zone[i] == Z_R or zone[i] == Z_M) or lvl[i] == 0:
			continue
		var el := 0
		if e1[i] + edu_bonus > 0.25:
			el = 1
		if e2[i] + edu_bonus > 0.25 and el >= 1:
			el = 2
		if e3[i] + edu_bonus * 0.5 > 0.25 and el >= 2:
			el = 3
		edu[i] = el
		var neg := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		var h := base
		if has_decree("fumar"):
			h += 0.02
		h += 0.12 * minf(hc[i], 1.0)
		if hc[i] < 0.1:
			neg[7] = 0.06
		h += 0.06 * minf(e1[i], 1.0)
		if e1[i] < 0.1:
			neg[8] = 0.04
		h += 0.15 * minf(pk[i], 1.0)
		if pk[i] < 0.05:
			neg[11] = 0.03
		h += 0.04 * minf(pc[i], 1.0) + 0.03 * minf(fc[i], 1.0)
		neg[1] = 0.35 * pollution[i]
		neg[2] = 0.25 * crime[i]
		neg[3] = 0.0 if powered[i] else 0.2
		neg[4] = 0.0 if watered[i] else 0.2
		neg[5] = minf(0.18, garbp[i] * 0.06)
		neg[6] = 0.15 * (commute[i] if i < commute.size() else 0.0)
		neg[9] = tax_pen
		neg[10] = unemployment * 0.3
		neg[12] = 0.2 if (flood[i] > 0.0 or burn[i] > 0.0) else 0.0
		var r := region_of(i)
		match district[r]:
			1:
				h -= 0.05
			2:
				h += 0.06
			4:
				h -= 0.03
		var cl := 1
		if el >= 2 and landv[i] > 0.55 and lvl[i] >= 3:
			cl = 2
		elif el == 0 and landv[i] < 0.35:
			cl = 0
		classes[cl] += 1
		if cl == 2:
			h += 0.06 if (pk[i] > 0.3 and crime[i] < 0.2) else -0.06
		elif cl == 0:
			h += 0.03 if hc[i] > 0.3 else -0.03
		cls_tax += [0.7, 1.0, 1.4][cl]
		var worst := 0
		var wv := 0.02
		for k in neg.size():
			h -= neg[k]
			if neg[k] > wv:
				wv = neg[k]
				worst = k
		h = clampf(h, 0.0, 1.0)
		happy[i] = h
		why[i] = worst
		sum_h += h
		cnt += 1
	avg_happy = sum_h / cnt if cnt > 0 else 0.65
	class_mult = cls_tax / cnt if cnt > 0 else 1.0
func grow_zones() -> void:
	if zone_list.is_empty():
		return
	var n := mini(zone_list.size(), 500)
	var pk: PackedFloat32Array = cov[CV_TRANSIT]
	for s in n:
		var i: int = zone_list[randi() % zone_list.size()]
		if part[i] >= 0 and part[i] != i:
			continue
		if burn[i] > 0.0 or flood[i] > 0.0 or anim_cells.has(i):
			continue
		var z: int = zone[i]
		var l: int = lvl[i]
		var access := road_near(i, 2)
		var r := region_of(i)
		var maxl := 4
		if z == Z_I and district[r] == 2:
			maxl = 2
		if stage < 1:
			maxl = mini(maxl, 2)
		elif stage < 3:
			maxl = mini(maxl, 3)
		if district[r] == 1:
			maxl = mini(4, maxl + 1)
		var dmd: float = 0.0
		var des := 0.0
		match z:
			Z_R:
				dmd = demand[0]
				des = 0.45 * happy[i] + 0.4 * landv[i] + 0.3 * dmd - (tax[0] - 9) * 0.02
			Z_C:
				dmd = demand[1]
				des = 0.45 * landv[i] + 0.4 * dmd + 0.1 * minf(pk[i], 1.0) + 0.1 - (tax[1] - 9) * 0.02
				if district[r] == 4:
					des += 0.05
				if district[r] == 3:
					des -= 0.05
				if has_decree("fumar"):
					des -= 0.03
			Z_I:
				dmd = demand[2]
				des = 0.5 * dmd + 0.3 + (0.1 if trade_ok else 0.0) - (tax[2] - 9) * 0.02
			Z_M:
				dmd = (demand[0] + demand[1]) * 0.5
				des = 0.4 * happy[i] + 0.4 * landv[i] + 0.3 * dmd
		var nl := l + 1
		var ok := access and nl <= maxl
		if ok and nl >= 2 and not powered[i]:
			ok = false
		if ok and nl >= 3 and not watered[i]:
			ok = false
		if ok and nl >= 3 and z != Z_I and landv[i] < 0.42:
			ok = false
		if ok and nl >= 4 and (landv[i] < 0.58 or (z != Z_I and edu[i] < 1 and z != Z_C)):
			ok = false
		if ok and z == Z_C and nl >= 4 and pop < 2500:
			ok = false
		if ok and des > 0.42 + l * 0.06 and randf() < 0.3 and dmd > -0.2:
			level_up(i, nl)
		elif l > 0 and (not access or des < 0.16) and randf() < 0.06:
			lvl[i] = l - 1
			if part[i] == i:
				unmerge(i)
			mark_dirty(i)
		var cap := zone_cap(z, lvl[i])
		var fill := clampf(0.55 + dmd * 0.4, 0.2, 1.0)
		if z == Z_R and epidemic_days > 0:
			fill *= 0.95
		occ[i] = lerpf(occ[i], cap * fill, 0.3)
func level_up(i: int, nl: int) -> void:
	if cam != null and cell_pos(i).distance_to(cam_target) < cam_dist * 0.9 + 20.0:
		sfx("hammer")
	lvl[i] = nl
	tree[i] = 0
	vari[i] = randi() % 64
	anim_cells[i] = 1.5
	mark_dirty(i)
	if nl == 4 and (zone[i] == Z_R or zone[i] == Z_C) and cx(i) < N - 1 and cz(i) < N - 1:
		var group := [i, i + 1, i + N, i + N + 1]
		var okm := true
		for j in group:
			if zone[j] != zone[i] or lvl[j] < 3 or part[j] >= 0 or road[j] > 0 or anim_cells.has(j) and j != i:
				okm = false
		if okm and randf() < 0.5:
			for j in group:
				part[j] = i
				lvl[j] = 4
				mark_dirty(j)
func compute_stats() -> void:
	var p := 0.0
	var jc := 0.0
	var ji := 0.0
	var jm := 0.0
	var jd := 0.0
	for i in zone_list:
		match zone[i]:
			Z_R:
				p += occ[i]
			Z_M:
				p += occ[i]
				jm += CAP_MJ[lvl[i]]
			Z_C:
				jc += CAP_C[lvl[i]]
			Z_I:
				ji += CAP_I[lvl[i]]
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if def_active(a):
			p += d.get("res", 0)
			jd += d.get("job", 0)
	pop = int(p)
	jobs_cap = int(jc + ji + jm + jd)
	workers = int(pop * 0.5)
	var employed := mini(workers, jobs_cap)
	unemployment = 1.0 - float(employed) / maxf(workers, 1) if workers > 20 else 0.0
	var fillr := float(employed) / maxf(jobs_cap, 1)
	jobs_c = int(jc * fillr)
	jobs_i = int(ji * fillr)
	jobs = employed
	var dr := (float(jobs_cap) - workers) / maxf(workers, 60.0) * 0.8 + 0.25
	if pop < 200:
		dr = maxf(dr, 0.5)
	dr += 0.1 if avg_happy > 0.65 else (-0.15 if avg_happy < 0.4 else 0.0)
	var dc := (pop * 0.22 + tourists * 0.6 - jc) / maxf(pop * 0.22, 25.0)
	var di := (pop * 0.25 - ji) / maxf(pop * 0.25, 25.0) + (0.25 if trade_ok else 0.0)
	if pop < 60:
		dc = minf(dc, 0.15)
		di = minf(di, 0.2)
	demand = [clampf(dr, -1.0, 1.0), clampf(dc, -1.0, 1.0), clampf(di, -1.0, 1.0)]
	var ns := 0
	for k in STAGES.size():
		if pop >= STAGES[k][1]:
			ns = k
	if ns > max_stage:
		max_stage = ns
		stage_up(ns)
	stage = ns
	for k in [["pop100", 100], ["pop1000", 1000], ["pop10k", 10000], ["pop50k", 50000], ["pop100k", 100000]]:
		if pop >= k[1]:
			unlock_ach(k[0])
func stage_up(ns: int) -> void:
	var unl: Array = []
	for id in DEF:
		if DEF[id]["st"] == ns:
			unl.append(DEF[id]["n"])
	var txt: String = "¡La ciudad ahora es " + STAGES[ns][0] + "!"
	if not unl.is_empty():
		txt += "\nNuevo: " + ", ".join(unl)
	big_card(STAGES[ns][0], txt)
	bocinazo()
	add_news("¡Bocinazos! La ciudad llegó a " + STAGES[ns][0])
func fire_tick() -> void:
	var fc: PackedFloat32Array = cov[CV_FIRE]
	var wet := 0.3 if weather in ["Lluvia", "Tormenta", "Nieve"] else 1.0
	for i in N * N:
		if burn[i] <= 0.0:
			continue
		var c: float = fc[i]
		if c > 0.25 and randf() < 0.25 + c * 0.4:
			burn[i] = 0.0
			mark_dirty(i)
			continue
		burn[i] += 0.06 * (1.0 - minf(c, 0.9)) * wet
		if burn[i] >= 1.0:
			burn[i] = 0.0
			if zone[i] > 0:
				if part[i] >= 0:
					unmerge(anchor_of(i))
				lvl[i] = 0
				occ[i] = 0.0
			mark_dirty(i)
			add_news("Se quemó un edificio en " + DISTRICT_NAMES[region_of(i)])
			continue
		for dz in range(-1, 2):
			for dx in range(-1, 2):
				var x := cx(i) + dx
				var z := cz(i) + dz
				if not inb(x, z) or (dx == 0 and dz == 0):
					continue
				var j := idx(x, z)
				if burn[j] > 0.0 or (zone[j] == 0 and bld[j] == 0) or (zone[j] > 0 and lvl[j] == 0):
					continue
				var wf := 1.0 + Vector2(dx, dz).normalized().dot(wind) * 0.8
				if randf() < 0.012 * wf * (1.0 - 0.9 * minf(fc[j], 1.0)) * wet:
					burn[j] = 0.01
					mark_dirty(j)
func ignite(i: int) -> void:
	if burn[i] > 0.0:
		return
	burn[i] = 0.01
	mark_dirty(i)
	add_news("¡Incendio en " + DISTRICT_NAMES[region_of(i)] + "!")
	toast("¡Incendio! Los bomberos cerca lo apagan más rápido.")
	dispatch_from("fire", 21, i)
	no_fire_days = 0
# el cambio de día: en las pruebas va todo junto; en el juego, una parte por cuadro (antes trababa ~50 ms)
const DAY_PARTS := ["begin", "economy", "production", "garbage", "tourism", "events", "cine", "politics", "season", "history", "save"]
var day_queue: Array = []
var nd_s0: int = 0
func new_day() -> void:
	for p in DAY_PARTS:
		new_day_part(p)
func new_day_part(p: String) -> void:
	match p:
		"begin":
			day += 1
			nd_s0 = season()
		"economy":
			daily_economy()
		"production":
			daily_production()
		"garbage":
			daily_garbage()
		"tourism":
			daily_tourism()
		"events":
			daily_events()
		"cine":
			cine_daily()
		"politics":
			daily_politics()
		"season":
			if season() != built_season:
				built_season = season()
				terrain_dirty = true
				mark_all_dirty()
		"history":
			for k in history:
				var arr: Array = history[k]
				var v := 0.0
				match k:
					"pop":
						v = pop
					"money":
						v = money
					"happy":
						v = avg_happy
					"appr":
						v = approval
				arr.append(v)
				if arr.size() > 120:
					arr.pop_front()
			check_achievements()
			pick_daily_challenge()
			for k in counters.keys():
				if String(k).begins_with("day_"):
					counters[k] = 0.0
			counters["pop_start"] = pop
			counters["money_start"] = money
		"save":
			if day % 2 == 0:
				save_game_bg(slot)
			if nd_s0 != season():
				add_news("Empieza el " + SEASONS[season()].to_lower())
func daily_economy() -> void:
	var b := {}
	var r_tax: float = pop * tax[0] / 100.0 * 0.55 * class_mult
	if has_decree("alquiler"):
		r_tax *= 0.9
	var c_tax: float = jobs_c * tax[1] / 100.0 * 0.7
	var i_tax: float = jobs_i * tax[2] / 100.0 * 0.7
	var tour_inc: float = tourists * 4.0
	var sunday := 0.0
	var upkeep := 0.0
	var scale := 1.0 + pop / 40000.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		var u: float = d["upk"]
		if d.has("dep"):
			u *= budget[d["dep"]] / 100.0
		upkeep += u * scale
		if is_sunday() and d.has("sunday") and def_active(a):
			sunday += d["sunday"]
	if is_sunday() and has_decree("feria"):
		sunday += pop * 0.05
	var roads := 0.0
	for i in N * N:
		if road[i] > 0:
			roads += ROAD_UPK[road[i]]
	var line_cost := 0.0
	var fares := 0.0
	for ln in lines:
		line_cost += {"bus": 20.0, "tram": 40.0, "metro": 120.0, "train": 80.0, "ferry": 40.0}[ln["kind"]] * budget[5] / 100.0
	var riders: float = counters.get("green_share", 0.0) * pop * 0.3
	if not has_decree("boleto"):
		fares = riders * 0.4
	var dec := 0.0
	for d in DECREES:
		if has_decree(d["id"]):
			dec += d["cost"] * (1.0 + pop / 20000.0)
	var loan := 0.0
	if debt > 0.0:
		var interest := debt * 0.004
		var pay := minf(debt + interest, maxf(50.0, debt * 0.03))
		debt = debt + interest - pay
		loan = pay
		if debt < 1.0:
			debt = 0.0
			unlock_ach("nodebt")
			add_news("¡Terminaste de pagar la deuda!")
	var inc := r_tax + c_tax + i_tax + tour_inc + sunday + fares
	var out := upkeep + roads + line_cost + dec + loan
	b = {"Impuesto residencial": r_tax, "Impuesto comercial": c_tax, "Impuesto industrial": i_tax, "Turismo": tour_inc, "Domingo (cancha y asado)": sunday, "Boletos": fares,
		"Servicios": -upkeep, "Calles": -roads, "Transporte": -line_cost, "Decretos": -dec, "Préstamo": -loan}
	last_budget = b
	last_net = inc - out
	if not creative:
		money += last_net
	else:
		money = maxf(money, 999999.0)
	if money < -5000.0 and not game_over_shown:
		game_over_shown = true
		big_card("Números en rojo", "La ciudad debe mucha plata. Pedí un préstamo, subí impuestos o bajá gastos en Presupuesto.")
	if money > 0:
		game_over_shown = false
	if money >= 100000:
		unlock_ach("rich")
func daily_production() -> void:
	var food := 0.0
	var prod := 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if not def_active(a):
			continue
		food += d.get("food", 0)
		if d.has("prod"):
			var use := minf(food_stock + food, 40.0)
			food -= use
			prod += d["prod"]
	for i in zone_list:
		if zone[i] == Z_I and lvl[i] > 0:
			prod += lvl[i] * 1.2 * (0.8 if has_decree("verde") else 1.0)
	food_stock += food - pop * 0.02
	prod_stock += prod - pop * 0.015
	var keep: Array = []
	for c in contracts:
		var key := "food" if c["kind"] == "food" else "prod"
		var stock := food_stock if key == "food" else prod_stock
		if stock >= c["qty"]:
			if key == "food":
				food_stock -= c["qty"]
			else:
				prod_stock -= c["qty"]
			money += c["qty"] * c["price"]
			c["days"] -= 1
			if c["days"] > 0:
				keep.append(c)
			else:
				neighbors[c["nb"]]["rel"] = minf(100.0, neighbors[c["nb"]]["rel"] + 8.0)
				add_news("Se cumplió el contrato con " + neighbors[c["nb"]]["n"])
		else:
			neighbors[c["nb"]]["rel"] = maxf(0.0, neighbors[c["nb"]]["rel"] - 10.0)
			add_news("No pudimos cumplir con " + neighbors[c["nb"]]["n"])
	contracts = keep
	if trade_ok:
		if food_stock > 200.0:
			money += (food_stock - 200.0) * market[0] * 0.5
			food_stock = 200.0
		if prod_stock > 200.0:
			money += (prod_stock - 200.0) * market[1] * 0.5
			prod_stock = 200.0
	if food_stock < 0.0:
		money += food_stock * market[0] * (1.0 if trade_ok else 1.6)
		food_stock = 0.0
	if prod_stock < 0.0:
		money += prod_stock * market[1] * (1.0 if trade_ok else 1.6)
		prod_stock = 0.0
	market[0] = clampf(market[0] * randf_range(0.93, 1.07), 3.0, 12.0)
	market[1] = clampf(market[1] * randf_range(0.93, 1.07), 5.0, 18.0)
func daily_garbage() -> void:
	garb_made = (pop * 0.9 + jobs * 0.4) * (0.7 if has_decree("recicla") else 1.0)
	garb_cap = 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if d.has("gb") and def_active(a):
			garb_cap += float(d["gb"]) * budget[6] / 100.0
	var gc: PackedFloat32Array = cov[CV_GARB]
	var over := maxf(0.0, garb_made - garb_cap)
	for i in zone_list:
		if lvl[i] == 0:
			continue
		if gc[i] > 0.05 and over <= 0.0:
			garbp[i] = maxf(0.0, garbp[i] - 1.5)
		elif gc[i] <= 0.05 or randf() < over / maxf(garb_made, 1.0):
			if pop > 80:
				garbp[i] = minf(4.0, garbp[i] + 0.25)
		if garbp[i] > 0.5 and randf() < 0.05:
			mark_dirty(i)
	if over > 0 and pop > 150 and day % 3 == 0:
		add_news("Se junta la basura: hace falta un relleno o un basurero")
func daily_tourism() -> void:
	var attract: float = mods["tour"]
	var beds := 60.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if not def_active(a):
			continue
		var t: float = d.get("tour", 0)
		if bld[a] == 40:
			t *= [2.5, 0.8, 0.2, 1.2][season()]
		attract += t
		beds += d.get("bed", 0)
	if has_decree("turismo"):
		attract *= 1.3
	if festival_days > 0:
		attract += 10.0
	var t2 := minf(beds, attract * 12.0)
	if not trade_ok:
		t2 *= 0.6
	tourists = int(t2)
	if tourists >= 100:
		unlock_ach("tourist")
func daily_events() -> void:
	if test_city:
		return
	var s := season()
	var r := randf()
	var opt: Array = [["Soleado", 0.45], ["Nublado", 0.25], ["Lluvia", 0.2], ["Tormenta", 0.1]]
	if s == 2:
		opt = [["Soleado", 0.35], ["Nublado", 0.3], ["Lluvia", 0.15], ["Nieve", 0.15], ["Tormenta", 0.05]]
	elif s == 0:
		opt = [["Soleado", 0.5], ["Calor", 0.2], ["Nublado", 0.1], ["Lluvia", 0.1], ["Tormenta", 0.1]]
	var acc := 0.0
	var neww := "Soleado"
	for o in opt:
		acc += o[1]
		if r < acc:
			neww = o[0]
			break
	if (neww == "Nieve") != (weather == "Nieve"):
		terrain_dirty = true
		mark_all_dirty()
	weather = neww
	wind = Vector2.from_angle(randf() * TAU)
	for i in N * N:
		if flood[i] > 0.0:
			flood[i] -= 1.0
			if flood[i] <= 0.0:
				flood[i] = 0.0
				mark_dirty(i)
	if not opts["calm"]:
		if weather == "Tormenta":
			add_news("Tormenta fuerte sobre la ciudad")
			if randf() < 0.5:
				do_flood()
			if not zone_list.is_empty() and randf() < 0.5:
				var i: int = zone_list[randi() % zone_list.size()]
				if lvl[i] > 0:
					ignite(i)
		var fc: PackedFloat32Array = cov[CV_FIRE]
		var dry := 1.6 if (s == 0 and weather in ["Soleado", "Calor"]) else 1.0
		for k in mini(zone_list.size(), 400):
			var i: int = zone_list[randi() % zone_list.size()]
			if lvl[i] == 0:
				continue
			var p := 0.0012 * (1.0 - minf(fc[i], 1.0)) * dry * (2.0 if zone[i] == Z_I else 1.0)
			if randf() < p:
				ignite(i)
		if pop > 300 and not zone_list.is_empty():
			var i: int = zone_list[randi() % zone_list.size()]
			if crime[i] > 0.45 and randf() < 0.5:
				add_news("Robo en " + DISTRICT_NAMES[region_of(i)])
				dispatch_from("police", 20, i)
		if epidemic_days > 0:
			epidemic_days -= 1
			if not zone_list.is_empty():
				dispatch_from("ambulance", 22, zone_list[randi() % zone_list.size()])
		elif pop > 1500 and randf() < 0.04:
			var hc: PackedFloat32Array = cov[CV_HEALTH]
			var avg := 0.0
			for i in zone_list:
				avg += minf(hc[i], 1.0)
			avg /= maxf(zone_list.size(), 1)
			if avg < 0.3:
				epidemic_days = 3
				add_news("Brote de gripe: faltan hospitales y salitas")
				toast("Hay una epidemia. Más salud la frena.")
	no_fire_days += 1
	if no_fire_days >= 30:
		unlock_ach("noFire")
	var d := doy()
	if d == 0 and day > 1:
		add_news("¡Feliz año nuevo!")
		fireworks(cam_target, 40)
		sfx("cheer")
	if d == 4:
		add_news("¡Carnaval! Murgas en todos los barrios")
		mods["hp"] = 0.05
		mods["days"] = 1
		confetti([Color(0.95, 0.2, 0.5), Color(0.2, 0.8, 0.9), Color(0.95, 0.85, 0.2)])
		unlock_ach("carnaval")
	if d == 30:
		add_news("Día de la primavera: los chicos van a las plazas")
		mods["hp"] = 0.03
		mods["days"] = 1
	if d == 26:
		if randf() < 0.62:
			add_news("¡¡ARGENTINA CAMPEÓN DEL MUNDO!! Festejos en toda la ciudad")
			big_card("¡Campeones!", "¡Ganamos la final del Mundial! Banderas, bocinazos y todos a la plaza.")
			confetti([Color(0.45, 0.75, 0.95), Color(1, 1, 1), Color(0.95, 0.85, 0.2)])
			bocinazo()
			mods["hp"] = 0.08
			mods["days"] = 3
			unlock_ach("mundial")
		else:
			add_news("Perdimos la final del Mundial. La ciudad está triste.")
			mods["hp"] = -0.04
			mods["days"] = 2
	if is_sunday():
		add_news("Domingo: asado, fútbol y feria")
	if mods["days"] > 0:
		mods["days"] -= 1
		if mods["days"] <= 0:
			mods["hp"] = 0.0
			mods["crime"] = 0.0
			mods["tour"] = 0.0
	if festival_days > 0:
		festival_days -= 1
	if day % 3 == 0 and offer == null and pop > 100:
		var nb := randi() % neighbors.size()
		var kind := "food" if randf() < 0.5 else "prod"
		offer = {"nb": nb, "kind": kind, "qty": 20 + randi() % 40, "price": snappedf((market[0] if kind == "food" else market[1]) * randf_range(1.0, 1.4), 0.1), "days": 3 + randi() % 4}
		add_news(neighbors[nb]["n"] + " quiere comprarnos " + ("comida" if kind == "food" else "productos"))
func do_flood() -> void:
	if map_kind == 4 and randf() < 0.7:
		return
	var n := 0
	for i in N * N:
		if terr[i] == T_WATER or wdist[i] > 2.0 or hgt[i] > 0.5:
			continue
		var safe := false
		for dz in range(-2, 3):
			for dx in range(-2, 3):
				var x := cx(i) + dx
				var z := cz(i) + dz
				if inb(x, z) and wire[idx(x, z)] & W_LEVEE:
					safe = true
		if safe or randf() > 0.6:
			continue
		flood[i] = 2.0
		n += 1
		if zone[i] > 0 and lvl[i] > 0 and randf() < 0.3:
			lvl[i] -= 1
		mark_dirty(i)
	if n > 0:
		add_news("Inundación en la costa: %d lotes bajo el agua. Los diques protegen." % n)
func daily_politics() -> void:
	var target := 0.3 + avg_happy * 0.6 - unemployment * 0.2
	if money < 0:
		target -= 0.1
	for a in anchors:
		if bld[a] == 0:
			continue
		target += DEF[bld[a]].get("appr", 0.0)
	approval = clampf(lerpf(approval, target, 0.15), 0.0, 1.0)
	if stage >= 2 or day > 60:
		if day == next_election - 3 and promise < 0:
			ask_promise()
		if day >= next_election:
			run_election()
	if day > 5 and day % 3 == 0 and decision == null and max_stage >= 1:
		decision = DECISIONS[randi() % DECISIONS.size()]
		show_decision()
	if request != null:
		var c: int = request["cell"]
		var cvv: PackedFloat32Array = cov[request["cv"]]
		if cvv[c] > 0.25:
			approval = minf(1.0, approval + 0.05)
			money += 500
			add_news("Los vecinos de %s agradecen: ya tienen %s" % [DISTRICT_NAMES[region_of(c)], request["what"]])
			toast("¡Cumpliste el pedido de los vecinos! +$500")
			request = null
		elif day > request["until"]:
			approval = maxf(0.0, approval - 0.03)
			add_news("Los vecinos de %s se quejan: no llegó %s" % [DISTRICT_NAMES[region_of(c)], request["what"]])
			request = null
	elif day > 4 and day % 4 == 0 and pop > 60:
		make_request()
func make_request() -> void:
	var homes: Array = []
	for i in zone_list:
		if zone[i] == Z_R and lvl[i] > 0:
			homes.append(i)
	if homes.is_empty():
		return
	for tries in 10:
		var h: int = homes[randi() % homes.size()]
		var rq: Array = REQUESTS[randi() % REQUESTS.size()]
		var cvv: PackedFloat32Array = cov[rq[1]]
		if cvv[h] < 0.15:
			request = {"cell": h, "cv": rq[1], "what": rq[0], "until": day + 6}
			add_news("Los vecinos de %s piden %s (6 días)" % [DISTRICT_NAMES[region_of(h)], rq[0]])
			toast("Pedido de los vecinos: %s en %s" % [rq[0], DISTRICT_NAMES[region_of(h)]])
			return
func promise_metric(k: String) -> float:
	match k:
		"crime":
			var s := 0.0
			for i in zone_list:
				s += crime[i]
			return -s / maxf(zone_list.size(), 1)
		"park":
			var pk: PackedFloat32Array = cov[CV_PARK]
			var s2 := 0.0
			for i in zone_list:
				s2 += minf(pk[i], 1.0)
			return s2 / maxf(zone_list.size(), 1)
		"power":
			return power_frac
		"traffic":
			return -avg_commute
		"jobs":
			return -unemployment
	return 0.0
func set_promise(k: int) -> void:
	promise = k
	promise_base = promise_metric(PROMISES[k][1])
	add_news("Promesa de campaña: " + PROMISES[k][0])
func run_election() -> void:
	var bonus := 0.0
	if promise >= 0:
		var now := promise_metric(PROMISES[promise][1])
		if now > promise_base + 0.01 or (PROMISES[promise][1] == "power" and now >= 0.99):
			bonus = 0.06
			add_news("Cumpliste tu promesa: " + PROMISES[promise][0])
		else:
			bonus = -0.05
			add_news("No cumpliste tu promesa: " + PROMISES[promise][0])
	var result := clampf(approval + bonus + randf_range(-0.05, 0.05), 0.0, 1.0)
	next_election = day + 15
	promise = -1
	if result >= 0.5:
		unlock_ach("election")
		money += 1000
		big_card("¡Ganaste las elecciones!", "Te votó el %d%% de la gente. Seguís siendo intendente." % int(result * 100))
		bocinazo()
	else:
		big_card("Perdiste las elecciones", "Sacaste %d%%. Te dejan seguir, pero el concejo te recorta la plata y la aprobación arranca de cero." % int(result * 100))
		if money > 0:
			money *= 0.8
		approval = 0.45
func apply_effects(e: Dictionary) -> void:
	if e.has("money"):
		money += e["money"]
	if e.has("appr"):
		approval = clampf(approval + e["appr"], 0.0, 1.0)
	if e.has("hp"):
		mods["hp"] = mods["hp"] + e["hp"]
		mods["days"] = 5
	if e.has("crime"):
		mods["crime"] = mods["crime"] + e["crime"]
		mods["days"] = 5
	if e.has("tour"):
		mods["tour"] = mods["tour"] + e["tour"]
		mods["days"] = 5
	if e.has("edu"):
		mods["edu"] = mods["edu"] + e["edu"]
	if e.has("pol"):
		mods["hp"] = mods["hp"] - e["pol"]
		mods["days"] = 5
func hold_festival() -> void:
	var cost := 800.0 + pop * 0.2
	if not creative and money < cost:
		toast("Un festival cuesta " + fmt_money(cost))
		return
	if not creative:
		money -= cost
	festival_days = 3
	approval = minf(1.0, approval + 0.03)
	add_news("¡Festival en la plaza! Música y comida para todos")
	confetti([Color(0.95, 0.4, 0.2), Color(0.3, 0.8, 0.4), Color(0.95, 0.9, 0.3)])
	fireworks(cam_target, 25)
	sfx("cheer")
	unlock_ach("festival")
func take_loan(amount: float) -> void:
	if debt > 120000:
		toast("El banco no te presta más")
		return
	money += amount
	debt += amount * 1.05
	add_news("Préstamo de " + fmt_money(amount))
	sfx("cash")
func fund_wonder(a: int) -> void:
	if not wonder_progress.has(a):
		return
	if not creative and money < WONDER_FUND:
		toast("Cada aporte cuesta " + fmt_money(WONDER_FUND))
		return
	if not creative:
		money -= WONDER_FUND
	wonder_progress[a] = wonder_progress[a] + 1
	mark_dirty(a)
	sim_dirty = true
	if wonder_progress[a] >= WONDER_STEPS:
		big_card("¡Se inauguró " + DEF[bld[a]]["n"] + "!", "Llegan turistas de todo el país.")
		fireworks(cell_pos(a), 60)
		bocinazo()
		add_news("Gran inauguración: " + DEF[bld[a]]["n"])
		unlock_ach("wonder")
		count_add("wonder")
	else:
		toast("Obra al %d%%" % int(100.0 * wonder_progress[a] / WONDER_STEPS))
func obj_value(k: String) -> float:
	match k:
		"pop":
			return pop
		"roads":
			var n := 0
			for i in N * N:
				if road[i] > 0:
					n += 1
			return n
		"zoneR":
			var n2 := 0
			for i in zone_list:
				if zone[i] == Z_R:
					n2 += 1
			return n2
		"zoneC":
			var n3 := 0
			for i in zone_list:
				if zone[i] == Z_C:
					n3 += 1
			return n3
		"power":
			return 1.0 if power_sup > 0 else 0.0
		"water":
			return 1.0 if water_sup > 0 else 0.0
		"serv":
			var n4 := 0
			for a in anchors:
				if bld[a] == 0:
					continue
				if DEF[bld[a]]["c"] == "serv":
					n4 += 1
			return n4
		"line":
			return lines.size()
		"garb":
			return 1.0 if garb_cap > 0 else 0.0
		"park":
			var n5 := 0
			for a in anchors:
				if bld[a] == 0:
					continue
				if DEF[bld[a]]["c"] == "park":
					n5 += 1
			return n5
		"wonder":
			for a in wonder_progress:
				if wonder_progress[a] >= WONDER_STEPS:
					return 1.0
			return 0.0
	return 0.0
func check_progress() -> void:
	if story and obj_index < OBJECTIVES.size():
		var o: Dictionary = OBJECTIVES[obj_index]
		if obj_value(o["k"]) >= o["v"]:
			money += o["r"]
			obj_index += 1
			sfx("cheer")
			if obj_index < OBJECTIVES.size():
				var nx: Dictionary = OBJECTIVES[obj_index]
				marta("¡Muy bien! Te ganaste %s.\n\n%s" % [fmt_money(o["r"]), nx["m"]])
			else:
				marta("¡Terminaste todos los objetivos! La ciudad es tuya. Seguí creciendo como quieras.")
	if not daily_done and daily_ch >= 0:
		var ch: Array = DAILY_CHALLENGES[daily_ch]
		var v := 0.0
		match ch[1]:
			"net":
				v = money - counters.get("money_start", money)
			"popgain":
				v = pop - counters.get("pop_start", pop)
			_:
				v = counters.get("day_" + ch[1], 0.0)
		if v >= ch[2]:
			daily_done = true
			money += 300
			toast("¡Reto del día cumplido! +$300")
			sfx("cheer")
	check_scenario()
func pick_daily_challenge() -> void:
	daily_ch = randi() % DAILY_CHALLENGES.size()
	daily_done = false
func check_scenario() -> void:
	if scenario == 0 or counters.get("scenario_done", 0.0) > 0.0:
		return
	var win := false
	var lose := false
	match scenario:
		1:
			win = pop >= 2500 and power_frac >= 0.99
			lose = day > 60
		2:
			win = obj_value("wonder") >= 1.0
			lose = day > 80
		3:
			win = counters.get("green_share", 0.0) >= 0.25 and pop > 300
			if win:
				unlock_ach("bike")
			lose = day > 60
		4:
			win = tourists >= 300
			lose = day > 60
		5:
			win = pop >= 5000
			lose = day > 10 and approval < 0.6
	if win:
		counters["scenario_done"] = 1.0
		big_card("¡Ganaste el escenario!", SCENARIOS[scenario]["n"] + ": objetivo cumplido. Podés seguir jugando.")
		fireworks(cam_target, 50)
	elif lose:
		counters["scenario_done"] = 2.0
		big_card("Escenario perdido", SCENARIOS[scenario]["n"] + ": no llegaste a tiempo. Podés seguir jugando libre.")
func check_achievements() -> void:
	var nt := 0
	for i in N * N:
		if tree[i] > 0:
			nt += 1
	if nt >= 50 and counters.get("trees", 0.0) >= 20:
		unlock_ach("trees")
	if avg_happy > 0.8 and pop > 500:
		unlock_ach("happy")
	if green_power >= 0.99 and power_sup > 0:
		unlock_ach("green")
	if counters.get("green_share", 0.0) >= 0.3 and pop > 500:
		unlock_ach("bike")
func unlock_ach(id: String) -> void:
	if achieved.has(id):
		return
	achieved[id] = day
	var nm := id
	for a in ACHIEVEMENTS:
		if a[0] == id:
			nm = a[1]
	notify("LOGRO DESBLOQUEADO", nm, "trophy")
	sfx("cheer")
func advice() -> String:
	if power_sup <= 0 and pop > 0:
		return "Poné una usina y conectala: sin luz los barrios no crecen."
	if water_sup <= 0 and pop > 30:
		return "Falta agua: una torre de agua anda en cualquier lado."
	if power_frac < 0.9:
		return "Hay cortes de luz: hace falta otra usina."
	if water_frac < 0.9:
		return "Falta agua en algunos barrios: más bombas o torres."
	if garb_made > garb_cap and pop > 150:
		return "La basura se junta: poné un relleno sanitario o basureros."
	if demand[0] > 0.5 and zone_count(Z_R) < 30:
		return "La gente quiere vivir acá: marcá más lotes residenciales."
	if demand[1] > 0.5:
		return "Falta comercio: marcá lotes comerciales."
	if demand[2] > 0.5:
		return "Falta industria: marcá lotes industriales lejos de las casas."
	if unemployment > 0.2:
		return "Hay desocupados: más comercio e industria."
	if money < 1000:
		return "Poca plata: subí un poco los impuestos o bajá gastos en Presupuesto."
	var counts := {}
	for i in zone_list:
		if why[i] > 0 and (zone[i] == Z_R or zone[i] == Z_M):
			counts[why[i]] = counts.get(why[i], 0) + 1
	var best := 0
	var bc := 0
	for k in counts:
		if counts[k] > bc:
			bc = counts[k]
			best = k
	if best > 0:
		return "Lo que más molesta a la gente: " + WHY_TEXT[best] + "."
	return "La ciudad anda bien. ¡Seguí creciendo!"
