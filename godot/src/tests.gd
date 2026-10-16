# Modos de prueba (--test=...).
var test_frame: int = 0
func shot(nm: String) -> void:
	if test_mode == "run":
		return
	var img := get_viewport().get_texture().get_image()
	img.save_png(test_mode + "/" + nm + ".png")
	print("captura ", nm)
var tap_pending: Vector2 = Vector2.ZERO
var tap_phase: int = 0
func tap_ctrl(c: Control) -> void:
	tap_pending = c.get_global_rect().get_center() * ui_scale
	tap_phase = 1
func tap_step() -> void:
	if tap_phase == 1:
		var ev := InputEventScreenTouch.new()
		ev.index = 0
		ev.position = tap_pending
		ev.pressed = true
		Input.parse_input_event(ev)
		tap_phase = 2
	elif tap_phase == 2:
		var ev2 := InputEventScreenTouch.new()
		ev2.index = 0
		ev2.position = tap_pending
		ev2.pressed = false
		Input.parse_input_event(ev2)
		tap_phase = 0
func run_ui(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		save_game(2)
		show_start()
	elif f == 20:
		shot_to(dir, "u1_inicio")
		show_new_game()
	elif f == 30:
		shot_to(dir, "u2_nueva")
		show_slots()
	elif f == 40:
		shot_to(dir, "u3_partidas")
		show_code()
	elif f == 50:
		shot_to(dir, "u4_codigo")
		show_start()
		open_options()
	elif f == 60:
		shot_to(dir, "u5_opciones")
		close_sheet()
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 70:
		shot_to(dir, "u6_marta")
	elif f == 75:
		card_pick(0)
		test_build()
		show_tray("serv")
	elif f == 90:
		for k in 6:
			for s2 in 8:
				run_sim_stage(s2)
		card_queue.clear()
		card_panel.visible = false
		cam_dist_goal = 100.0
	elif f == 140:
		shot_to(dir, "u7_juego")
		open_fan()
	elif f == 146:
		shot_to(dir, "u7b_abanico")
		pick_cat("infra")
	elif f == 148:
		open_menu()
	elif f == 150:
		shot_to(dir, "u8_menu")
		open_districts()
	elif f == 160:
		shot_to(dir, "u9_distritos")
		close_sheet()
		show_tray("views")
	elif f == 170:
		shot_to(dir, "u10_vistas")
		close_fan()
		show_tray("none")
		set_hud_state(1)
	elif f == 176:
		shot_to(dir, "u11_panel1")
		set_hud_state(2)
	elif f == 182:
		shot_to(dir, "u12_panel2")
		print("UI OK")
		get_tree().quit()
func shot_to(dir: String, nm: String) -> void:
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/" + nm + ".png")
func run_test() -> void:
	if test_mode.begins_with("album="):
		run_album(test_mode.substr(6))
		return
	if test_mode in ["compat_save", "compat_load", "fresh", "pause", "seam"]:
		run_extra()
		return
	if test_mode == "sim":
		run_sim()
		return
	if test_mode == "buildings":
		run_buildings()
		return
	if test_mode.begins_with("ui="):
		run_ui(test_mode.substr(3))
		return
	if test_mode == "dale":
		run_dale()
		return
	if test_mode.begins_with("city="):
		run_city(test_mode.substr(5))
		return
	if test_mode.begins_with("roads="):
		run_roads(test_mode.substr(6))
		return
	if test_mode.begins_with("fx="):
		run_fx(test_mode.substr(3))
		return
	if test_mode.begins_with("vida="):
		run_vida(test_mode.substr(5))
		return
	if test_mode == "scroll":
		run_scroll()
		return
	if test_mode.begins_with("fan="):
		run_fan(test_mode.substr(4))
		return
	if test_mode.begins_with("menu="):
		run_menu(test_mode.substr(5))
		return
	test_frame += 1
	var f := test_frame
	if f == 20:
		shot("01_inicio")
	elif f == 25:
		seed(777)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 30:
		next_card()
		test_build()
	elif f == 60:
		for k in 8:
			for s in 8:
				run_sim_stage(s)
			new_day()
		print("pop=", pop, " money=", int(money), " jobs=", jobs, " power=", power_sup, "/", power_use, " water=", water_sup, " cars=", car_paths.size())
	elif f == 70:
		for k in 30:
			for s in 8:
				run_sim_stage(s)
			if k % 3 == 0:
				new_day()
		print("pop=", pop, " money=", int(money), " stage=", stage, " happy=", avg_happy, " lines=", lines.size())
		var hist := {}
		var sp := 0.0
		var scr := 0.0
		var scm := 0.0
		var nw := 0
		var n := 0
		for i in zone_list:
			if zone[i] == Z_R and lvl[i] > 0:
				hist[WHY_TEXT[why[i]]] = hist.get(WHY_TEXT[why[i]], 0) + 1
				sp += pollution[i]
				scr += crime[i]
				scm += commute[i]
				nw += 1 if watered[i] else 0
				n += 1
		print("motivos ", hist, " contam ", sp / maxf(n, 1), " crimen ", scr / maxf(n, 1), " viaje ", scm / maxf(n, 1), " con agua ", nw, "/", n, " desocup ", unemployment, " impuestos ", tax)
		card_queue.clear()
		card_panel.visible = false
		set_speed(2)
	elif f == 130:
		cam_goal = Vector3(0, 0, 0)
		cam_dist_goal = 110.0
		cam_pitch = 0.75
	elif f == 200:
		shot("02_ciudad")
		diag()
	elif f == 205:
		day_timer = DAY_SECONDS * 0.62
	elif f == 230:
		shot("03_noche")
		day_timer = DAY_SECONDS * 0.2
	elif f == 235:
		show_tray("roads")
		set_tool({"k": "road", "t": 3})
	elif f == 240:
		shot("04_bandeja")
	elif f == 245:
		test_panels()
	elif f == 250:
		open_stats()
	elif f == 255:
		shot("05_estadisticas")
		close_sheet()
		show_info(zone_list[0] if not zone_list.is_empty() else idx(N / 2, N / 2))
	elif f == 260:
		shot("06_info")
		info_panel.visible = false
		start_drive()
	elif f == 300:
		shot("07_manejar")
		stop_drive()
		set_view("traffic")
	elif f == 310:
		shot("08_vista")
		set_view("")
		test_save()
	elif f == 320:
		print("TEST OK")
		get_tree().quit()
func test_build() -> void:
	var c := N / 2
	money = 200000
	set_tool({"k": "road", "t": 2})
	for k in range(-3, 4):
		apply_cells(line_cells(idx(c - 14, c + k * 5 - 2), idx(c + 14, c + k * 5 - 2)))
		apply_cells(line_cells(idx(c + k * 5 - 2, c - 14), idx(c + k * 5 - 2, c + 14)))
	set_tool({"k": "road", "t": 3})
	apply_cells(line_cells(idx(c - 14, c + 3), idx(c + 14, c + 3)))
	for z in range(c - 14, c + 14):
		for x in range(c - 14, c + 14):
			var i := idx(x, z)
			if road[i] > 0 or bld[i] > 0:
				continue
			if x > c + 8:
				zone[i] = Z_I
			elif z < c - 6:
				zone[i] = Z_C
			else:
				zone[i] = Z_R
			vari[i] = randi() % 64
			mark_dirty(i)
	var spots := [[42, c + 15, c - 12], [48, c - 15, c - 12], [48, c - 15, c - 7], [65, c + 15, c + 3], [65, c - 12, c - 15], [24, c - 15, c - 2], [20, c - 15, c + 3], [21, c - 15, c + 8], [22, c + 15, c + 8], [22, c - 2, c + 15], [24, c + 8, c + 15], [33, c - 7, c - 15], [34, c + 3, c - 15], [30, c - 2, c - 15], [30, c - 12, c + 15], [41, c + 8, c - 15]]
	for s in spots:
		var a := idx(s[1], s[2])
		set_tool({"k": "def", "id": s[0]})
		var ok := place_def(a, s[0])
		if not ok:
			print("no se pudo poner ", DEF[s[0]]["n"], ": ", can_place_def(a, s[0]))
	set_tool({"k": "stop", "kind": "bus"})
	place_stop(idx(c - 12, c - 2), "bus")
	place_stop(idx(c + 12, c - 2), "bus")
	place_stop(idx(c + 3, c + 13), "bus")
	start_line("bus")
	pick_line_stop(idx(c - 12, c - 2))
	pick_line_stop(idx(c + 12, c - 2))
	pick_line_stop(idx(c + 3, c + 13))
	finish_line()
	mode_bar.visible = false
	sim_dirty = true
func test_panels() -> void:
	open_menu()
	for fn in [open_stats, open_budget, open_decrees, open_mayor, open_trade, open_transport, open_districts, open_goals, open_news, open_advisors, open_saves, open_options]:
		fn.call()
	open_district(5)
	for k in CATS:
		show_tray(k[0])
	for v in ["power", "water", "pollution", "crime", "land", "traffic", "happy", "fire", "police", "health", "edu", "transit", "garbage", "districts", ""]:
		set_view(v)
	for i in [idx(N / 2, N / 2), idx(N / 2 - 12, N / 2 - 2), idx(3, 3), zone_list[0] if not zone_list.is_empty() else 0]:
		show_info(i)
	decision = DECISIONS[0]
	show_decision()
	ask_promise()
	big_card("Prueba", "Texto de prueba")
	marta("Hola")
	while card_panel.visible:
		card_pick(0)
	follow_citizen()
	hide_follow_card()
	follow_ped = null
	cam_follow = null
	hold_festival()
	confetti([Color.RED])
	fireworks(Vector3.ZERO, 20)
	fund_wonder(-1)
	take_loan(5000)
	start_tutorial()
	tut_check()
	end_tutorial()
	set_photo_mode(true)
	set_photo_mode(false)
	for nm in sounds:
		sfx(nm)
	close_sheet()
	show_tray("")
	set_tool({"k": "look"})
	print("paneles ok")
func test_save() -> void:
	var p0 := pop
	var r0 := 0
	for i in N * N:
		if road[i] > 0:
			r0 += 1
	save_game(3)
	if not load_game(3):
		print("ERROR al cargar")
	var r1 := 0
	for i in N * N:
		if road[i] > 0:
			r1 += 1
	print("guardar/cargar calles ", r0, " -> ", r1, " pop ", p0, " -> ", pop, " lineas ", lines.size())
	var code := export_code()
	print("código de ", code.length(), " letras")
	if not import_code(code):
		print("ERROR al importar")
	var od := {"day": 12, "pop": 40, "money": 800, "debt": 100, "tax": 9, "cells": [[18, 18, 1], [19, 18, 1], [20, 18, 1], [21, 18, 1], [19, 19, 2], [20, 19, 3], [21, 19, 4], [18, 19, 5], [22, 18, 9], [17, 18, 9], [16, 19, 10], [15, 19, 13]], "stops": [[22, 18], [17, 18]], "lines": [[[22, 18], [17, 18]]]}
	var old_code := Marshalls.utf8_to_base64(JSON.stringify(od))
	if import_code(old_code):
		print("partida vieja pasada: calles ", obj_value("roads"), " zonas ", zone_list.size(), " líneas ", lines.size())
	else:
		print("ERROR partida vieja")
	load_game(3)
func diag() -> void:
	var keys := ["hc", "e1", "pk", "pol", "crime", "power", "water", "garb", "commute", "landv", "happy"]
	var sums := {}
	for k in keys:
		sums[k] = 0.0
	var n := 0
	for i in zone_list:
		if zone[i] != Z_R or lvl[i] == 0:
			continue
		n += 1
		sums["hc"] += minf(cov[CV_HEALTH][i], 1.0)
		sums["e1"] += minf(cov[CV_EDU1][i], 1.0)
		sums["pk"] += minf(cov[CV_PARK][i], 1.0)
		sums["pol"] += pollution[i]
		sums["crime"] += crime[i]
		sums["power"] += powered[i]
		sums["water"] += watered[i]
		sums["garb"] += garbp[i]
		sums["commute"] += commute[i]
		sums["landv"] += landv[i]
		sums["happy"] += happy[i]
	var out := ""
	for k in keys:
		out += "%s=%.2f " % [k, sums[k] / maxf(n, 1)]
	print("DIAG n=", n, " ", out, " mods=", mods, " hp_bonus=", hp_bonus, " unemp=", unemployment, " pop=", pop, " garb ", garb_made, "/", garb_cap)
func run_dale() -> void:
	tap_step()
	test_frame += 1
	var f := test_frame
	if f == 10:
		new_game(4, 0, false, true, 2)
		enter_game(true)
	elif f == 100:
		print("card visible ", card_panel.visible, " btns ", card_btns.get_child_count(), " title ", card_title.text, " rect ", card_btns.get_child(0).get_global_rect(), " scale ", ui_scale, " vp ", get_viewport().get_visible_rect().size)
		if card_btns.get_child_count() > 0:
			tap_ctrl(card_btns.get_child(0))
	elif f == 110:
		print("card visible after ", card_panel.visible, " intro_t ", intro_t, " title ", card_title.text, " queue ", card_queue.size(), " text ", card_text.text.substr(0, 40), " obj ", obj_index)
	elif f == 400:
		print("DALE OK day ", day)
		get_tree().quit()
func find_btn(n: Node, t: String) -> Button:
	if n is Button and n.text.contains(t):
		return n
	for ch in n.get_children():
		var r := find_btn(ch, t)
		if r != null:
			return r
	return null
func run_menu(dir: String) -> void:
	test_frame += 1
	tap_step()
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		set_tool({"k": "look"})
		open_menu()
	elif f == 50:
		var b := find_btn(sheet_body, "Opciones")
		print("opciones rect ", b.get_global_rect(), " sheet ", sheet.get_global_rect(), " scale ", ui_scale)
		tap_ctrl(b)
	elif f == 70:
		print("RESULT sheet=", sheet_name, " info=", info_panel.visible)
		shot_to(dir, "m1")
		get_tree().quit()
func touch_at(p: Vector2, pressed: bool) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.position = p
	ev.pressed = pressed
	Input.parse_input_event(ev)
func drag_to(p: Vector2) -> void:
	var ev := InputEventScreenDrag.new()
	ev.index = 0
	ev.position = p
	Input.parse_input_event(ev)
var fan_t0: int = 0
var scroll0: int = 0
func run_scroll() -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		show_tray("fun")
	elif f == 60:
		scroll0 = tray_sc.scroll_horizontal
		var r: Rect2 = tray.get_child(2).get_global_rect()
		touch_at(r.get_center() * ui_scale, true)
	elif f > 60 and f < 80:
		var r2: Rect2 = tray.get_child(2).get_global_rect()
		drag_to(r2.get_center() * ui_scale + Vector2(-(f - 60) * 24.0, 0))
		var ev := InputEventScreenDrag.new()
		ev.index = 0
		ev.position = r2.get_center() * ui_scale + Vector2(-(f - 60) * 24.0, 0)
		ev.relative = Vector2(-24, 0)
		Input.parse_input_event(ev)
	elif f == 80:
		touch_at(tray.get_child(2).get_global_rect().get_center() * ui_scale + Vector2(-480, 0), false)
	elif f == 90:
		print("SCROLL moved=", tray_sc.scroll_horizontal - scroll0, " tool=", tool["k"], " acc=", drag_acc)
		get_tree().quit()
func run_fx(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		cam_dist_goal = 45.0
		weather = "Soleado"
		notify("LOGRO DESBLOQUEADO", "Mil vecinos en la ciudad")
	elif f == 46:
		print("NOTIF vis=", notif_panel.visible, " pos=", notif_panel.position, " size=", notif_panel.size, " busy=", notif_busy, " mod=", notif_panel.modulate.a)
		shot_to(dir, "x0_notif")
	elif f == 60:
		show_hud(false)
		weather = "Lluvia"
	elif f == 120:
		shot_to(dir, "x1_lluvia")
		weather = "Nieve"
		terrain_dirty = true
	elif f == 220:
		shot_to(dir, "x2_nieve")
		weather = "Soleado"
		terrain_dirty = true
	elif f == 260:
		shot_to(dir, "x3_sol_ao")
		opts["g_ao"] = false
		opts["g_grade"] = false
		apply_fx()
	elif f == 300:
		shot_to(dir, "x4_sin_ao_tilt")
		print("FX OK")
		get_tree().quit()
func run_city(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f > 12:
		card_queue.clear()
		card_panel.visible = false
	if f == 10:
		new_test_city()
		enter_game(false)
		skip_intro()
		var hc := test_house_cell()
		var near: Array = []
		for i in zone_list:
			if zone[i] == Z_R and part[i] < 0:
				near.append([cell_pos(i).distance_to(cell_pos(hc)), i])
		near.sort()
		for k in mini(14, near.size()):
			var ci: int = near[k][1]
			lvl[ci] = 1
			vari[ci] = k
			anim_cells.erase(ci)
		mark_all_dirty()
		print("CITY pop=", pop, " zonas=", zone_list.size(), " lamps=", lamps.size(), " lineas=", lines.size())
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		show_hud(false)
		speed = 0
		weather = "Soleado"
		start_movie(6, test_house_cell())
		card_queue.clear()
		day_timer = DAY_SECONDS * 0.25
		cam_target = Vector3(0, 0, 0)
		cam_dist_goal = 70.0
		cam_pitch = 0.9
		cam_yaw = 0.5
	elif f == 200:
		print("CITY cars=", cars.size(), " peds=", peds.size())
		shot_to(dir, "c1_dia")
		cam_dist_goal = 30.0
		cam_pitch = 0.5
	elif f == 260:
		shot_to(dir, "c2_dia_cerca")
		var hc := test_house_cell()
		cam_target = cell_pos(hc)
		cam_goal = cam_target
		cam_dist_goal = 15.0
		cam_pitch = 0.6
	elif f == 280 and not stars.is_empty():
		cam_target = stars[0]["pos"]
		cam_goal = cam_target
	elif f == 300:
		shot_to(dir, "c5_avengers")
		day_timer = DAY_SECONDS * 0.7
		cam_target = Vector3(0, 0, 0)
		cam_goal = cam_target
		cam_dist_goal = 70.0
		cam_pitch = 0.9
	elif f == 370:
		shot_to(dir, "c3_noche")
		cam_dist_goal = 11.0
		cam_pitch = 1.0
	elif f > 370 and f < 460 and not cars.is_empty():
		var cp: Array = path_pos_s(cars[0]["p"], cars[0]["k"], CELL * 0.18)
		cam_goal = cp[0]
		cam_target = cp[0]
	elif f == 460:
		shot_to(dir, "c4_noche_cerca")
		start_movie(0, test_house_cell())
		card_queue.clear()
		cam_target = cell_pos(test_house_cell())
		cam_goal = cam_target
		cam_dist_goal = 15.0
		cam_pitch = 0.6
	elif f == 510:
		shot_to(dir, "c6_casas_noche")
		if not stars.is_empty():
			cam_target = stars[0]["pos"]
			cam_goal = cam_target
		cam_dist_goal = 12.0
		day_timer = DAY_SECONDS * 0.4
	elif f > 510 and f < 560 and not stars.is_empty():
		cam_goal = stars[0]["pos"]
		cam_target = cam_goal
	elif f == 560:
		shot_to(dir, "c7_scream")
		print("CITY OK stars=", stars.size(), " caidos=", downs.size())
		get_tree().quit()
func test_house_cell() -> int:
	var best := 0
	var bn := -1.0
	var c := 0
	for i in zone_list:
		if zone[i] == Z_R and lvl[i] == 1:
			c += 1
			var d := cell_pos(i).length()
			if d > bn:
				bn = d
				best = i
	print("CASAS ", c, " elegida ", cell_pos(best))
	return best
func run_roads(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		show_hud(false)
		money = 999999.0
		set_tool({"k": "road", "t": 2})
		var c0 := idx(N / 2, N / 2)
		var cells: Array = []
		for k in 7:
			cells.append(idx(N / 2 + k, N / 2))
		for k in 1:
			pass
		for k in range(1, 6):
			cells.append(idx(N / 2 + 6, N / 2 + k))
		for k in range(1, 4):
			cells.append(idx(N / 2 + 3, N / 2 - k))
		for k in range(1, 4):
			cells.append(idx(N / 2 - k, N / 2 + 3))
		apply_cells(cells)
		cam_target = Vector3(0, 0, 0)
		cam_dist_goal = 55.0
		cam_pitch = 1.2
		cam_yaw = 0.3
	elif f == 160:
		shot_to(dir, "r1_top")
		cam_pitch = 0.6
	elif f == 220:
		shot_to(dir, "r2_low")
		print("ROADS OK")
		get_tree().quit()
func run_fan(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	var now := Time.get_ticks_msec()
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		set_tool({"k": "look"})
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, true)
		fan_t0 = now
	elif f > 40 and f < 400 and fan_hold and fan_open and fan_t0 > 0 and now - fan_t0 > 900:
		var tgt: Vector2 = fan_btns[3].get_global_rect().get_center() * ui_scale
		drag_to(tgt)
		print("FAN open, hover=", fan_hover)
		fan_t0 = -1
		test_frame = 400
	elif f == 450:
		print("FAN dwell hover=", fan_hover, " cur_cat=", cur_cat, " open=", fan_open)
		shot_to(dir, "f1")
		touch_at(Vector2(10, 10), false)
	elif f == 470:
		print("RESULT cur_cat=", cur_cat, " fan_open=", fan_open, " tray=", tray.get_child_count())
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, true)
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, false)
	elif f == 500:
		print("TAP1 open=", fan_open)
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, true)
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, false)
	elif f == 540:
		print("TAP2 open=", fan_open)
		get_tree().quit()
func run_sim() -> void:
	test_frame += 1
	if test_frame != 5:
		return
	seed(20261012)
	new_game(4, 0, false, true, 3)
	enter_game(true)
	skip_intro()
	card_queue.clear()
	test_build()
	var t0 := Time.get_ticks_usec()
	for k in 30:
		for s in 8:
			run_sim_stage(s)
		new_day()
		print("SIM día=%d pop=%d money=%d jobs=%d happy=%.4f power=%.1f/%.1f water=%.1f/%.1f lines=%d stage=%d" % [day, pop, int(money), jobs, avg_happy, power_sup, power_use, water_sup, water_use, lines.size(), stage])
	print("BENCH sim_ms=%d" % ((Time.get_ticks_usec() - t0) / 1000))
	t0 = Time.get_ticks_usec()
	for k in 5:
		mark_all_dirty()
		update_chunks(NCH * NCH)
	print("BENCH chunks_ms=%d" % ((Time.get_ticks_usec() - t0) / 1000))
	speed = 1
	for k in 600:
		agents_process(1.0 / 60.0)
	t0 = Time.get_ticks_usec()
	for k in 300:
		agents_process(1.0 / 60.0)
	print("BENCH agents_ms=%d cars=%d peds=%d" % [(Time.get_ticks_usec() - t0) / 1000, cars.size(), peds.size()])
	t0 = Time.get_ticks_usec()
	for k in 3:
		build_terrain()
	print("BENCH terrain_ms=%d" % ((Time.get_ticks_usec() - t0) / 1000))
	print("SIM OK")
	get_tree().quit()
# --- pruebas de compatibilidad y casos de borde (etapa 0)
func compat_line() -> String:
	var roads := 0
	for i in N * N:
		if road[i] > 0:
			roads += 1
	return "COMPAT money=%d day=%d roads=%d lines=%d pop=%d" % [int(money), day, roads, lines.size(), pop]
func run_extra() -> void:
	test_frame += 1
	var f := test_frame
	match test_mode:
		"compat_save":
			if f == 5:
				seed(20261012)
				new_game(4, 0, false, true, 1)
				enter_game(true)
				skip_intro()
				card_queue.clear()
				test_build()
				for k in 10:
					for s in 8:
						run_sim_stage(s)
					new_day()
				save_game(1)
				print(compat_line())
				var fc := FileAccess.open("user://compat_code.txt", FileAccess.WRITE)
				fc.store_string(export_code())
				fc.close()
				print("COMPAT_SAVE OK")
				get_tree().quit()
		"compat_load":
			if f == 5:
				if not load_game(1):
					print("COMPAT ERROR no se pudo cargar la partida 1")
				else:
					print(compat_line())
				var code := FileAccess.get_file_as_string("user://compat_code.txt")
				if not import_code(code):
					print("COMPAT ERROR no se pudo importar el código")
				else:
					print(compat_line())
				print("COMPAT_LOAD OK")
				get_tree().quit()
		"fresh":
			if f == 30:
				var clean := not FileAccess.file_exists("user://opciones.json") and latest_slot() == 0
				print("FRESH OK" if clean and start_panel.visible and not started else "FRESH FALLA")
				get_tree().quit()
		"seam":
			# mapas con bordes con lomas: el horizonte tiene que empalmar con el terreno en cada vértice del borde
			if f == 5:
				var res := []
				for kind in [1, 4, 0]:
					seed(20261012 + kind)
					new_game(kind, 0, true, false, 3)
					build_terrain()
					res.append(seam_check())
					opts["quality"] = 0
					build_terrain()
					res.append(seam_check())
					opts["quality"] = 1
				print("SEAM_CHECK ok" if res.min() == 0 else "SEAM_CHECK FALLA %s" % [res])
				get_tree().quit()
		"pause":
			if f == 5:
				new_game(4, 0, false, true, 2)
				enter_game(true)
				skip_intro()
				DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(2)))
			elif f == 20:
				notification(NOTIFICATION_APPLICATION_PAUSED)
				var saved := FileAccess.file_exists(slot_path(2))
				var clean := FileAccess.get_file_as_string("user://ultimo_paso.txt").contains("cierre limpio")
				print("PAUSE OK" if saved and clean else "PAUSE FALLA guardada=%s limpio=%s" % [saved, clean])
				get_tree().quit()
# --- álbum de capturas (etapa 1): se corre con el renderer Mobile (tools/album.sh)
var album_shots: Array = []
var album_k: int = -1
var album_wait: int = 0
var album_t: int = 0
var album_frames: Array = []
func album_hour(h: float) -> void:
	day_timer = (h - 6.0) / 24.0 * DAY_SECONDS
	speed = 0
func album_city(h: float, w: String, d: int) -> void:
	if album_k == 0 or test_city == false:
		new_test_city()
		enter_game(false)
		skip_intro()
	day = d
	weather = w
	album_hour(h)
	terrain_dirty = true
	mark_all_dirty()
	cam_goal = Vector3.ZERO
	cam_target = cam_goal
	cam_dist_goal = 110.0
	cam_dist = 110.0
	cam_pitch = 0.75
	cam_yaw = 0.5
# agua "abierta": casi todo alrededor es agua (para no apuntar a un charco)
func album_open_water(i: int) -> bool:
	var n := 0
	var w := 0
	for dz in range(-6, 7, 2):
		for dx in range(-6, 7, 2):
			if inb(cx(i) + dx, cz(i) + dz):
				n += 1
				if terr[idx(cx(i) + dx, cz(i) + dz)] == T_WATER:
					w += 1
	return w >= n * 0.8
func album_map(kind: int, want: int) -> void:
	new_game(kind, 0, true, false, 3)
	enter_game(false)
	skip_intro()
	weather = "Soleado"
	album_hour(13.0)
	var best := -1
	var bd := 1e9
	for i in N * N:
		if terr[i] == want and (want != T_WATER or album_open_water(i)):
			var dd := Vector2(cx(i) - N / 2, cz(i) - N / 2).length()
			if dd < bd:
				bd = dd
				best = i
	if best >= 0:
		cam_goal = cell_pos(best)
	cam_target = cam_goal
	cam_dist_goal = 120.0
	cam_dist = 120.0
	cam_pitch = 0.7
	cam_yaw = 0.5
# calidad Baja (la última toma: cambia las opciones)
func album_low() -> void:
	opts["quality"] = 0
	apply_quality()
	apply_fx()
	album_city(13.0, "Soleado", 3)
func album_horizon(h: float) -> void:
	album_city(h, "Soleado", 3)
	update_light()
	# mirar hacia el sol: la luz apunta a -Z, así que el sol está en +Z de su base
	var to_sun: Vector3 = sun.global_transform.basis.z
	cam_yaw = atan2(-to_sun.x, -to_sun.z)
	cam_pitch = 0.22
	cam_dist_goal = 170.0
	cam_dist = 170.0
var album_dir: String = ""
func run_album(dir: String) -> void:
	test_frame += 1
	if test_frame < 5:
		return
	if album_dir != "":
		dir = album_dir
	if album_k < 0:
		DirAccess.make_dir_recursive_absolute(dir.get_slice(":", 0))
		album_shots = [
			["amanecer", func(): album_city(6.8, "Soleado", 3)],
			["mediodia", func(): album_city(13.0, "Soleado", 3)],
			["atardecer", func(): album_city(19.5, "Soleado", 3)],
			["noche", func(): album_city(23.0, "Soleado", 3)],
			["lluvia", func(): album_city(13.0, "Lluvia", 3)],
			["nieve", func(): album_city(13.0, "Nieve", 23)],
			["otono", func(): album_city(13.0, "Soleado", 13)],
			["rio", func(): album_map(0, T_WATER)],
			["costa", func(): album_map(2, T_WATER)],
			["islas", func(): album_map(3, T_WATER)],
			["cerros", func(): album_map(1, T_ROCK)],
			["horizonte_dia", func(): album_horizon(13.0)],
			["horizonte_tarde", func(): album_horizon(19.5)],
			["cerca_casas", func(): album_close(Z_R, [1], 13.0, "Soleado", 3)],
			["cerca_deptos", func(): album_close(Z_R, [2, 3], 13.0, "Soleado", 3)],
			["cerca_torres", func(): album_close(Z_R, [4], 13.0, "Soleado", 3)],
			["cerca_comercio", func(): album_close(Z_C, [1, 2, 3], 13.0, "Soleado", 3)],
			["cerca_industria", func(): album_close(Z_I, [1, 2, 3, 4], 13.0, "Soleado", 3)],
			["cerca_noche", func(): album_close(Z_R, [2, 3], 23.0, "Soleado", 3)],
			["cerca_lluvia", func(): album_close(Z_R, [1], 13.0, "Lluvia", 3)],
			["cerca_nieve", func(): album_close(Z_R, [1], 13.0, "Nieve", 23)],
			["arboles_primavera", func(): album_trees(1 + DAYS_PER_SEASON * 3, "Soleado")],
			["arboles_otono", func(): album_trees(1 + DAYS_PER_SEASON, "Soleado")],
			["arboles_invierno", func(): album_trees(1 + DAYS_PER_SEASON * 2, "Nieve")],
			["catalogo_arboles", func(): album_catalog(-2)],
			["calle_dia", func(): album_street(13.0)],
			["calle_noche", func(): album_street(22.5)],
			["catalogo_especiales_a", func(): album_catalog(-3)],
			["catalogo_especiales_b", func(): album_catalog(-4)],
			["catalogo", func(): album_catalog(-1)],
			["catalogo_casas", func(): album_catalog(0)],
			["catalogo_deptos", func(): album_catalog(1)],
			["catalogo_comercio", func(): album_catalog(3)],
			["catalogo_industria", func(): album_catalog(4)],
			["baja", func(): album_low()],
		]
		# --test=album=<carpeta>:toma1,toma2 saca solo esas tomas
		if dir.contains(":"):
			var only := dir.get_slice(":", 1).split(",")
			dir = dir.get_slice(":", 0)
			album_shots = album_shots.filter(func(sh): return sh[0] in only)
		album_dir = dir
		album_k = 0
		album_wait = 0
	if album_k >= album_shots.size():
		print("ALBUM OK")
		get_tree().quit()
		return
	card_queue.clear()
	card_panel.visible = false
	ui_layer.visible = false
	if album_wait == 0:
		album_shots[album_k][1].call()
		card_queue.clear()
	album_wait += 1
	# en el mediodía se mide el tiempo por cuadro (cuadros 60 a 180)
	var bench_shot: bool = album_shots[album_k][0] in ["mediodia", "baja"]
	if bench_shot and album_wait == 1:
		album_frames.clear()
	if bench_shot and album_wait >= 60:
		var now := Time.get_ticks_usec()
		if album_wait > 60:
			album_frames.append(now - album_t)
		album_t = now
		if album_wait == 180:
			var tot := 0.0
			for v in album_frames:
				tot += v
			print("BENCH frame_ms%s=%.2f" % ["_baja" if album_shots[album_k][0] == "baja" else "", tot / maxf(album_frames.size(), 1) / 1000.0])
	var need := 180 if bench_shot else 90
	if album_wait == need and album_shots[album_k][0] in ["mediodia", "cerros"]:
		terrain_check()
	if album_wait >= need:
		get_viewport().get_texture().get_image().save_png(dir + "/" + album_shots[album_k][0] + ".png")
		print("captura ", album_shots[album_k][0])
		album_k += 1
		album_wait = 0
# el terreno suavizado no puede mover el suelo de las celdas ocupadas: en ellas los puntos nuevos de
# la malla fina tienen que caer sobre los triángulos de antes (bordes = promedio, centro = diagonal a-d)
func terrain_check() -> void:
	if not use_tex_terrain() or terrain_hsub.is_empty():
		print("TERRAIN_CHECK sin malla fina")
		return
	var M := 2 * N + 1
	var bad := 0
	var cells := 0
	for z in N:
		for x in N:
			if not terrain_busy(x, z):
				continue
			cells += 1
			var a := terrain_hsub[(2 * z) * M + 2 * x]
			var b := terrain_hsub[(2 * z) * M + 2 * x + 2]
			var c := terrain_hsub[(2 * z + 2) * M + 2 * x]
			var d := terrain_hsub[(2 * z + 2) * M + 2 * x + 2]
			var want := [[2 * x + 1, 2 * z, (a + b) * 0.5], [2 * x + 1, 2 * z + 2, (c + d) * 0.5], [2 * x, 2 * z + 1, (a + c) * 0.5], [2 * x + 2, 2 * z + 1, (b + d) * 0.5], [2 * x + 1, 2 * z + 1, (a + d) * 0.5]]
			for w in want:
				if absf(terrain_hsub[int(w[1]) * M + int(w[0])] - float(w[2])) > 0.001:
					bad += 1
	print("TERRAIN_CHECK ok (%d celdas ocupadas)" % cells if bad == 0 else "TERRAIN_CHECK FALLA %d puntos" % bad)
# Cuenta los vértices del borde del terreno que no tienen un vértice del horizonte en el mismo lugar y a la
# misma altura (cada uno es una posible rendija). 0 = empalme perfecto.
func seam_check() -> int:
	var half := N * CELL * 0.5
	var outer := {}
	for nd in outer_nodes:
		var m: Mesh = nd.mesh
		var arr := m.surface_get_arrays(0)
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		for v in vs:
			if absf(absf(v.x) - half) < 0.01 or absf(absf(v.z) - half) < 0.01:
				outer[Vector2i(roundi(v.x * 10.0), roundi(v.z * 10.0))] = v.y
	var tm: Mesh = terrain_node.mesh
	var tv: PackedVector3Array = tm.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var bad := 0
	for v in tv:
		if absf(absf(v.x) - half) < 0.01 or absf(absf(v.z) - half) < 0.01:
			var k := Vector2i(roundi(v.x * 10.0), roundi(v.z * 10.0))
			if not outer.has(k) or absf(float(outer[k]) - v.y) > 0.001:
				bad += 1
	return bad
# --- etapa 2: catálogo de edificios
var bt_fail: int = 0
func bt(ok: bool, msg: String) -> void:
	if not ok:
		bt_fail += 1
	print(msg)
# alturas permitidas por zona y nivel (techo y tanque incluidos); Mixta usa las de comercio
const CAT_H := {
	Z_R: [[2.0, 7.0], [3.5, 9.0], [7.0, 13.0], [14.0, 40.0]],
	Z_C: [[2.0, 7.0], [3.5, 9.0], [7.0, 20.0], [14.0, 45.0]],
	Z_I: [[2.0, 7.0], [3.0, 9.0], [3.0, 12.0], [5.0, 14.0]],
}
func run_buildings() -> void:
	test_frame += 1
	if test_frame != 5:
		return
	catalog_check()
	new_test_city()
	enter_game(false)
	skip_intro()
	building_check("ciudad")
	tree_check()
	prop_check()
	# quemar uno, subir de nivel otro y borrar la zona de un tercero
	var ks: Array = []
	for i in N * N:
		if bcheck_log.has(i) and part[i] < 0 and lvl[i] == 1:
			ks.append(i)
		if ks.size() == 3:
			break
	burn[ks[0]] = 0.5
	lvl[ks[1]] = 2
	zone[ks[2]] = 0
	building_check("cambios")
	bt(bool(bcheck_log[ks[0]]["dark"]), "BUILDING_CHECK quemado oscuro " + ("ok" if bcheck_log[ks[0]]["dark"] else "FALLA"))
	# acercar la cámara solo rehace los bloques cercanos (no los 16)
	b_near_on = false
	chunk_dirty.fill(0)
	cam_target = Vector3(-N * CELL * 0.5 + 20.0, 0, -N * CELL * 0.5 + 20.0)
	cam_dist = 30.0
	update_building_lod()
	var nd := 0
	for c in NCH * NCH:
		nd += chunk_dirty[c]
	bt(nd <= 4, "BUILDING_CHECK zoom rehace pocos bloques " + ("ok (%d)" % nd if nd <= 4 else "FALLA rehace %d" % nd))
	update_chunks(NCH * NCH)
	cam_dist = 110.0
	update_building_lod()
	# las versiones cerca se preparan de a poco antes de hacer falta
	for ck in cat_cache.keys():
		if ck % 3 == LOD_NEAR:
			cat_cache.erase(ck)
	var steps := 0
	while cat_warm_step() and steps < 10000:
		steps += 1
	var miss := 0
	for i in N * N:
		if zone[i] > 0 and lvl[i] >= 1 and road[i] == 0 and (part[i] < 0 or part[i] == i):
			var pk := pick_model(i)
			if pk.x >= 0 and not cat_cache.has((pk.x * 64 + pk.y) * 3 + LOD_NEAR):
				miss += 1
	bt(miss == 0, "BUILDING_CHECK versiones cerca preparadas " + ("ok (%d pasos)" % steps if miss == 0 else "FALLA faltan %d" % miss))
	var near_nodes := 0
	for c in bnodes:
		for k in c:
			if k % 3 == LOD_NEAR and c[k].visible:
				near_nodes += 1
	bt(b_near_on or near_nodes == 0, "BUILDING_CHECK sin versiones cerca lejos del zoom " + ("ok" if (b_near_on or near_nodes == 0) else "FALLA %d nodos" % near_nodes))
	special_check(DEF.keys())
	var nn := [0, 0, 0]
	for c in bnodes:
		for k in c:
			if c[k].multimesh.instance_count > 0:
				nn[k % 3] += 1
	print("BENCH nodos_edificios cerca=%d media=%d lejos=%d" % nn)
	print("BUILDINGS OK" if bt_fail == 0 else "BUILDINGS FALLA")
	get_tree().quit()
# cada modelo arma sus 3 versiones, entra en su lote y tiene la altura de su nivel
func catalog_check() -> void:
	cat_models.clear()
	cat_register()
	cat_cache.clear()
	var t0 := Time.get_ticks_usec()
	for m in cat_models.size():
		var md: Dictionary = cat_models[m]
		var w: float = md.get("w", CELL * (1.85 if md["big"] else 0.82))
		for l in md["levels"]:
			var fl: Array = md["floors"].get(l, [0])
			for f in fl:
				var nv: Array = []
				for lod in 3:
					var tag := "CATALOG_CHECK %s f=%d lod=%d " % [md["id"], f, lod]
					if md["near_only"] and lod != LOD_NEAR:
						nv.append(0)
						continue
					var mesh: ArrayMesh = cat_mesh(m, f, lod)
					if mesh == null or mesh.get_surface_count() != 1:
						bt(false, tag + "FALLA sin malla")
						nv.append(0)
						continue
					var vs: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
					nv.append(vs.size())
					if vs.is_empty():
						bt(false, tag + "FALLA sin vértices")
						continue
					var ab := mesh.get_aabb()
					var lim := w * 0.5 + 0.2
					if md["fam"] == "arbol":
						lim = 2.4
					elif md["id"] == "cable":
						lim = CELL + 0.2
					var why := ""
					if ab.position.x < -lim or ab.position.z < -lim or ab.end.x > lim or ab.end.z > lim:
						why += " huella %s > %.2f" % [str(ab), lim]
					if ab.position.y < -0.5:
						why += " se hunde %.2f" % ab.position.y
					if md["fam"] == "especial" and (ab.end.y < 0.05 or ab.end.y > 45.0):
						why += " altura de especial %.1f fuera de [0, 45]" % ab.end.y
					if md["fam"] == "arbol" and (ab.end.y < 2.0 or ab.end.y > 9.0):
						why += " altura de árbol %.1f fuera de [2, 9]" % ab.end.y
					for z in md["zones"]:
						var r: Array = CAT_H[Z_C if z == Z_M else z][l - 1]
						if ab.end.y < r[0] or ab.end.y > r[1]:
							why += " altura %.1f fuera de %s (zona %d nivel %d)" % [ab.end.y, str(r), z, l]
					var ns: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
					var u2: PackedVector2Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_TEX_UV2]
					for vi in ns.size():
						var mt := int(u2[vi].x + 0.5)
						if (mt == BM_TILES or mt == BM_SHEET) and ns[vi].y > 0.52 and ns[vi].y < SNOW_NY:
							why += " techo sin nieve (normal.y %.2f < %.2f)" % [ns[vi].y, SNOW_NY]
							break
					# vidrios que no son ventanas (autos, refugios) y agua (vidrio/espejo horizontal): sin luces de noche (máscara 3)
					for vi in u2.size():
						var mt2 := int(u2[vi].x + 0.5)
						if (mt2 == BM_GLASS or mt2 == BM_MIRROR) and int(u2[vi].y + 0.5) != 3 and (md["fam"] == "objeto" or ns[vi].y > 0.9):
							why += " vidrio que se prendería de noche (normal.y %.2f)" % ns[vi].y
							break
					# el farol tiene su luz en las tres versiones
					if md["id"] == "farol":
						var has_emit := false
						for vi in u2.size():
							if int(u2[vi].x + 0.5) == BM_EMIT:
								has_emit = true
						if not has_emit:
							why += " farol sin luz"
					if lod == 2 and nv[0] > 0 and vs.size() >= nv[0] and not md["near_only"]:
						why += " la versión lejos no es más liviana (%d >= %d)" % [vs.size(), nv[0]]
					bt(why == "", tag + ("ok" if why == "" else "FALLA" + why))
	print("BENCH catalog_ms=%d" % ((Time.get_ticks_usec() - t0) / 1000))
	# etapa 2c-e: arreglos de texturas con 13 capas y modelos "solo cerca"
	var ta: Resource = load("res://assets/city/city_alb.webp")
	var tn: Resource = load("res://assets/city/city_nrm.webp")
	var nl: int = ta.get_layers() if ta is TextureLayered else 0
	var nn2: int = tn.get_layers() if tn is TextureLayered else 0
	bt(nl == 13 and nn2 == 13, "TEXTURE_CHECK capas %d y %d " % [nl, nn2] + ("ok" if nl == 13 and nn2 == 13 else "FALLA (se esperaban 13)"))
	cat_add("prueba_cerca", [], [], false, {}, rc_test_box, true)
	var pm := cat_models.size() - 1
	var mid_empty := cat_mesh(pm, 0, LOD_MID).get_surface_count() == 0 and cat_mesh(pm, 0, LOD_FAR).get_surface_count() == 0
	var near_full := cat_mesh(pm, 0, LOD_NEAR).get_surface_count() == 1
	bt(mid_empty and near_full, "CATALOG_CHECK solo cerca " + ("ok" if mid_empty and near_full else "FALLA"))
	cat_models.pop_back()
# cada lote construido tiene exactamente un modelo de su zona, nivel y tamaño, y nada más
func building_check(tag: String) -> void:
	bcheck_on = true
	bcheck_log.clear()
	mark_all_dirty()
	update_chunks(NCH * NCH)
	bcheck_on = false
	var why := ""
	var n := 0
	for i in N * N:
		var want := zone[i] > 0 and lvl[i] >= 1 and road[i] == 0 and bld[i] == 0 and not anim_cells.has(i) and (part[i] < 0 or part[i] == i)
		if not bcheck_log.has(i):
			if want and why.length() < 300:
				why += " falta en %d (zona %d nivel %d)" % [i, zone[i], lvl[i]]
			continue
		n += 1
		var e: Dictionary = bcheck_log[i]
		if not want:
			why += " sobra en %d" % i
			continue
		if e["n"] != 1:
			why += " %d instancias en %d" % [e["n"], i]
		var md: Dictionary = cat_models[e["m"]]
		var big := part[i] == i
		var has_big := false
		for o in cat_models:
			if o["big"] and zone[i] in o["zones"] and lvl[i] in o["levels"]:
				has_big = true
		if not (zone[i] in md["zones"]) or not (lvl[i] in md["levels"]) or md["big"] != (big and has_big):
			why += " modelo %s no sirve para %d (zona %d nivel %d grande %s)" % [md["id"], i, zone[i], lvl[i], big]
	var tot := 0
	for c in bnodes:
		for k in c:
			if k % 3 == LOD_FAR and cat_models[k / 192]["fam"] == "edificio":
				tot += c[k].multimesh.instance_count
	if tot != n:
		why += " instancias lejos %d != lotes %d" % [tot, n]
	if n == 0:
		why += " ningún edificio"
	bt(why == "", "BUILDING_CHECK %s (%d lotes) " % [tag, n] + ("ok" if why == "" else "FALLA" + why))
# hoja del catálogo: todos los modelos (versión cerca) en filas sobre una losa, encima de la ciudad
var cat_root: Node3D
func album_catalog(focus_row: int) -> void:
	album_city(13.0, "Soleado", 3)
	if cat_root:
		cat_root.queue_free()
	var root := Node3D.new()
	cat_root = root
	add_child(root)
	var y0 := 60.0
	var x := 0.0
	var z := 0.0
	var row := 0
	var cols := 9
	var pos: Array = []
	var fam := "arbol" if focus_row == -2 else ("especial" if focus_row <= -3 else "edificio")
	if fam == "especial":
		cols = 5
	var mlist: Array = []
	for m in cat_models.size():
		if cat_models[m]["fam"] == fam:
			mlist.append(m)
	if fam == "especial":
		# -3: primera mitad de los especiales, -4: segunda mitad
		var half := mlist.size() / 2
		mlist = mlist.slice(0, half) if focus_row == -3 else mlist.slice(half)
	if focus_row <= -2:
		focus_row = -1
	for mi in mlist.size():
		var m: int = mlist[mi]
		var md: Dictionary = cat_models[m]
		var sp: float = (10.0 if md["big"] else 5.5) if not md.has("w") else md["w"] + 2.5
		if mi > 0 and mi % cols == 0:
			z -= 15.0 if fam == "especial" else 12.0
			x = 0.0
		pos.append(Vector3(x + sp * 0.5, y0, z))
		x += sp
	var cen := Vector3.ZERO
	for p in pos:
		cen += p
	cen /= maxf(pos.size(), 1)
	var slab := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(70, 0.4, -z + 16)
	slab.mesh = bm
	slab.position = Vector3(cen.x, y0 - 0.2, cen.z)
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.5, 0.52, 0.5)
	slab.material_override = sm
	root.add_child(slab)
	for mi in mlist.size():
		var m: int = mlist[mi]
		if focus_row >= 0 and mi / cols != focus_row:
			continue
		var md: Dictionary = cat_models[m]
		var l: int = md["levels"][md["levels"].size() - 1]
		var fl: Array = md["floors"].get(l, [0])
		var node := new_mm_node(cat_mesh(m, fl[fl.size() / 2] if fam == "edificio" else 0, LOD_NEAR), building_mat)
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		remove_child(node)
		root.add_child(node)
		var mm := node.multimesh
		mm.instance_count = 1
		var p: Vector3 = pos[mi]
		var col: Color = tint(res_wall(m), m)
		if fam == "arbol":
			col = tree_colors(TREE_SPECIES.keys()[mi / 3])[0]
		elif fam == "especial":
			var sid := int(String(md["id"]).substr(4))
			col = DEF[sid]["col"]
		var acc := float(m % 8) / 8.0
		if fam == "especial":
			acc = float(SPECIAL_ACCENT.get(int(String(md["id"]).substr(4)), 5)) / 8.0
		mm.buffer = PackedFloat32Array([1, 0, 0, p.x, 0, 1, 0, p.y, 0, 0, 1, p.z, col.r, col.g, col.b, 1, 0, acc, hsh(m, 42), 0])
	if focus_row >= 0:
		var rx := 0.0
		var rn := 0
		for m in pos.size():
			if m / cols == focus_row:
				rx += pos[m].x
				rn += 1
		cen = Vector3(rx / maxf(rn, 1), y0 + 2.0, -12.0 * focus_row)
	var dd: float = ({"edificio": 62.0, "arbol": 26.0, "especial": 58.0}[fam]) if focus_row < 0 else 24.0
	cam_goal = cen
	cam_target = cen
	cam_dist_goal = dd
	cam_dist = dd
	cam_pitch = 0.42 if focus_row < 0 else 0.3
	cam_yaw = 0.25 if focus_row < 0 else 0.15
# toma de cerca sobre el lote de esa zona y nivel más cercano al centro de la ciudad de prueba
func album_close(z: int, lvls: Array, h: float, w: String, d: int) -> void:
	album_city(h, w, d)
	if cat_root:
		cat_root.queue_free()
		cat_root = null
	var best := -1
	var bd := 1e9
	for i in N * N:
		if zone[i] == z and lvl[i] in lvls and road[i] == 0 and (part[i] < 0 or part[i] == i):
			var dd := Vector2(cx(i) - N / 2, cz(i) - N / 2).length()
			if dd < bd:
				bd = dd
				best = i
	if best >= 0:
		cam_goal = cell_pos(best)
	cam_target = cam_goal
	cam_dist_goal = 30.0
	cam_dist = 30.0
	cam_pitch = 0.42
	cam_yaw = 0.5 + face_rot(maxi(best, 0))
func rc_test_box(_lod: int, _f: int, _w: float) -> void:
	mb_box(Vector3.ZERO, Vector3(0.5, 0.5, 0.5), BM_PLAIN, 0)
# cada celda con árbol tiene árboles de su especie; no hay árboles sobre lotes ni en el campo vacío
func tree_check() -> void:
	var fam_of := {}
	for kind in tree_models:
		for m in tree_models[kind]:
			fam_of[m] = kind
	bcheck_on = true
	mcheck_log.clear()
	mark_all_dirty()
	update_chunks(NCH * NCH)
	bcheck_on = false
	var got := {}
	for e in mcheck_log:
		if fam_of.has(e[1]):
			var c: Vector2i = e[0]
			if inb(c.x, c.y):
				var ci := idx(c.x, c.y)
				if not got.has(ci):
					got[ci] = []
				got[ci].append(fam_of[e[1]])
	var why := ""
	var n := 0
	for i in N * N:
		var want: bool = tree[i] > 0 and road[i] == 0 and zone[i] == 0 and bld[i] == 0
		if want:
			n += 1
			if not got.has(i) or not (tree[i] in got[i]):
				if why.length() < 300:
					why += " falta árbol tipo %d en %d" % [tree[i], i]
		elif got.has(i) and road[i] == 0 and bld[i] == 0:
			if why.length() < 300:
				why += " árbol de más en %d" % i
	if n == 0:
		why += " no hay celdas con árbol"
	# los árboles se escalan parejo (alto y ancho), no solo en planta
	for cn in bnodes:
		for k in cn:
			if cat_models[k / 192]["fam"] == "arbol" and cn[k].multimesh.instance_count > 0:
				var b: PackedFloat32Array = cn[k].multimesh.buffer
				var sxz := Vector2(b[0], b[2]).length()
				if absf(b[5] - sxz) > 0.01:
					why += " árbol deformado (alto %.2f, ancho %.2f)" % [b[5], sxz]
					break
	bt(why == "", "TREE_CHECK (%d celdas) " % n + ("ok" if why == "" else "FALLA" + why))
# toma de cerca sobre la celda con árbol más cercana al centro, en un día dado (estación) y clima
func album_trees(d: int, w: String) -> void:
	album_city(13.0, w, d)
	if cat_root:
		cat_root.queue_free()
		cat_root = null
	var best := -1
	var bd := 1e9
	for i in N * N:
		if tree[i] == 3 and road[i] == 0 and zone[i] == 0 and bld[i] == 0:
			var dd := Vector2(cx(i) - N / 2, cz(i) - N / 2).length()
			if dd < bd:
				bd = dd
				best = i
	if best >= 0:
		cam_goal = cell_pos(best)
	cam_target = cam_goal
	cam_dist_goal = 24.0
	cam_dist = 24.0
	cam_pitch = 0.35
	cam_yaw = 0.5
# objetos de calle: faroles donde están los charcos de luz; semáforos solo en cruces con avenida; autos y
# mobiliario solo en calle o vereda (nunca sobre agua ni sobre un lote construido)
func prop_check() -> void:
	var ids := {}
	for m in cat_models.size():
		ids[cat_models[m]["id"]] = m
	# tendido de prueba: tres postes seguidos en campo libre (la ciudad de prueba no tiene)
	var pw := 0
	for i in N * N:
		if wire[i] & W_POWER and road[i] == 0 and bld[i] == 0 and zone[i] == 0:
			pw += 1
	if pw == 0:
		for i in range(N * 10 + 5, N * N - 3):
			var free := true
			for k in 3:
				if road[i + k] > 0 or bld[i + k] > 0 or zone[i + k] > 0 or terr[i + k] == T_WATER:
					free = false
			if free:
				for k in 3:
					wire[i + k] |= W_POWER
				break
	bcheck_on = true
	mcheck_log.clear()
	lamps.clear()
	mark_all_dirty()
	update_chunks(NCH * NCH)
	bcheck_on = false
	var why := ""
	var nf := 0
	var ns := 0
	var nc := 0
	var cars := ["sedan", "hatch", "camioneta", "utilitario", "taxi"]
	for e in mcheck_log:
		var c: Vector2i = e[0]
		var id: String = cat_models[e[1]]["id"]
		if not inb(c.x, c.y):
			why += " %s fuera del mapa" % id
			continue
		var i := idx(c.x, c.y)
		if id == "farol":
			nf += 1
		elif id == "semaforo":
			ns += 1
			var av := false
			for o in [0, 1, -1, N, -N]:
				var j: int = i + o
				if j >= 0 and j < N * N and road[j] >= 3:
					av = true
			if road[i] == 0 or not av:
				why += " semáforo sin avenida en %d" % i
		elif id in cars:
			nc += 1
			if road[i] == 0 or terr[i] == T_WATER:
				why += " auto fuera de la calle en %d" % i
	if nf != lamps.size():
		why += " faroles %d != luces %d" % [nf, lamps.size()]
	# parte 2: mobiliario y carteles solo en calles (o vereda); postes y cables solo donde hay tendido
	var furn := ["banco", "tacho", "bolardo", "cantero", "parada", "cartel_calle", "pare"]
	var nm := 0
	var np := 0
	var nv := 0
	for e in mcheck_log:
		var c: Vector2i = e[0]
		if not inb(c.x, c.y):
			continue
		var i := idx(c.x, c.y)
		var id: String = cat_models[e[1]]["id"]
		if id in furn:
			nm += 1
			if road[i] == 0 or terr[i] == T_WATER:
				why += " %s fuera de la calle en %d" % [id, i]
		elif id == "poste" or id == "cable":
			np += 1
			if not (wire[i] & W_POWER):
				why += " %s sin tendido en %d" % [id, i]
		elif cat_models[e[1]]["fam"] == "arbol" and road[i] > 0:
			nv += 1
	if nm == 0 or np == 0 or nv == 0:
		why += " sin mobiliario (%d), postes (%d) o árboles de vereda (%d)" % [nm, np, nv]
	if ns == 0 or nc == 0:
		why += " sin semáforos (%d) o sin autos (%d)" % [ns, nc]
	# con la cámara lejos no hay nodos visibles de objetos "solo cerca"
	var vis := 0
	if not b_near_on:
		for cn in bnodes:
			for k in cn:
				if cat_models[k / 192]["near_only"] and cn[k].visible and cn[k].multimesh.instance_count > 0:
					vis += 1
	if vis > 0:
		why += " %d nodos de objetos chicos visibles lejos" % vis
	bt(why == "", "PROP_CHECK faroles %d semáforos %d autos %d " % [nf, ns, nc] + ("ok" if why == "" else "FALLA" + why.substr(0, 400)))
# toma de cerca sobre el cruce con avenida más cercano al centro (semáforos, faroles, autos)
func album_street(h: float) -> void:
	album_city(h, "Soleado", 3)
	if cat_root:
		cat_root.queue_free()
		cat_root = null
	var best := -1
	var bd := 1e9
	for i in N * N:
		if road[i] >= 2 and terr[i] != T_WATER:
			var nb := road_n(i)
			var cnt := int(nb[0]) + int(nb[1]) + int(nb[2]) + int(nb[3])
			var av: bool = road[i] >= 3
			for o in [1, -1, N, -N]:
				var j: int = i + o
				if j >= 0 and j < N * N and road[j] >= 3:
					av = true
			if cnt >= 3 and av:
				var dd := Vector2(cx(i) - N / 2, cz(i) - N / 2).length()
				if dd < bd:
					bd = dd
					best = i
	if best >= 0:
		cam_goal = cell_pos(best)
	cam_target = cam_goal
	# la cámara se pone sobre la avenida, mirando a lo largo de ella
	var along_x := best >= 0 and ((cx(best) < N - 1 and road[best + 1] >= 2) or (cx(best) > 0 and road[best - 1] >= 2))
	cam_dist_goal = 26.0
	cam_dist = 26.0
	cam_pitch = 0.5
	cam_yaw = (PI * 0.5 if along_x else 0.0) + 0.25
# cada edificio especial tiene exactamente una instancia de su propio modelo (en el ancla) y nada más.
# Se arma en un mapa vacío: borra la ciudad de prueba (va al final de las pruebas de dibujo)
func special_check(ids: Array) -> void:
	for i in N * N:
		road[i] = 0
		zone[i] = 0
		bld[i] = 0
		part[i] = -1
		tree[i] = 0
		wire[i] = 0
		lvl[i] = 0
		terr[i] = T_LAND
	anim_cells.clear()
	wonder_progress.clear()
	var anchors := {}
	var k := 0
	for id in ids:
		var sz: int = DEF[id]["sz"]
		var a := idx(8 + (k % 12) * 9, 8 + (k / 12) * 9)
		var cells := def_cells(a, sz)
		for c in cells:
			bld[c] = id
			part[c] = cells[0] if sz > 1 else -1
		anchors[cells[0]] = id
		if DEF[id]["c"] == "wonder":
			wonder_progress[cells[0]] = WONDER_STEPS
		k += 1
	bcheck_on = true
	scheck_log.clear()
	mark_all_dirty()
	update_chunks(NCH * NCH)
	bcheck_on = false
	var why := ""
	for a in anchors:
		var id: int = anchors[a]
		if not special_model.has(id):
			why += " sin receta %d (%s)" % [id, DEF[id]["n"]]
			continue
		var e: Array = scheck_log.get(a, [])
		if e.size() != 1 or e[0] != special_model[id]:
			why += " %s: %d instancias" % [DEF[id]["n"], e.size()]
	for c in scheck_log:
		if not anchors.has(c):
			why += " instancia de más en %d" % c
	bt(why == "", "SPECIAL_CHECK (%d) " % ids.size() + ("ok" if why == "" else "FALLA" + why.substr(0, 500)))
# sala de computación y etapas 3 a 5 (--test=vida=<carpeta>)
func run_vida(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f == 5:
		new_test_city()
		enter_game(false)
		skip_intro()
		card_queue.clear()
		card_panel.visible = false
		set_speed(1)
		cam_dist_goal = 120.0
	elif f == 200:
		lab_check(dir)
	elif f == 210:
		shot_to(dir, "sala_computacion")
		close_sheet()
		road_check()
		# de cerca sobre un cruce, de día
		rebuild_road_list()
		var c: int = tl_cells[tl_cells.size() / 2]
		cam_target = cell_pos(c)
		cam_goal = cam_target
		cam_dist = 22.0
		cam_dist_goal = 22.0
		cam_pitch = 0.9
		day_timer = DAY_SECONDS * 0.25
		weather = "Soleado"
	elif f == 258:
		card_queue.clear()
		card_panel.visible = false
	elif f == 260:
		shot_to(dir, "calle_marcas")
		print("VIDA OK" if bt_fail == 0 else "VIDA FALLA")
		get_tree().quit()
# cada calle lleva sus vecinas y los cruces a los que llega; las rectas que llegan a un cruce tienen senda
func road_check() -> void:
	var straight := 0
	var with_x := 0
	var bad := 0
	for i in N * N:
		if road[i] < 2:
			continue
		var code := road_marks(i)
		var nb := road_n(i)
		for d in 4:
			if bool(code & (1 << d)) != bool(nb[d]):
				bad += 1
			if code & (16 << d) and not nb[d]:
				bad += 1
		var cnt := int(nb[0]) + int(nb[1]) + int(nb[2]) + int(nb[3])
		if cnt == 2 and ((nb[0] and nb[1]) or (nb[2] and nb[3])):
			straight += 1
			if code >= 16:
				with_x += 1
	bt(bad == 0 and straight > 20 and with_x > 4, "ROAD_CHECK marcas de calles " + ("ok (%d rectas, %d llegan a un cruce)" % [straight, with_x] if bad == 0 and with_x > 4 else "FALLA bad=%d rectas=%d cruce=%d" % [bad, straight, with_x]))
func lab_check(dir: String) -> void:
	bt(lab_n() >= 150, "LAB_CHECK mide los cuadros " + ("ok (%d)" % lab_n() if lab_n() >= 150 else "FALLA %d" % lab_n()))
	var r := lab_report()
	var parts_ok: bool = r["parts"].size() == LAB_PARTS.size() and r["frame"] > 0.0 and r["parts"]["simulación"][0] > 0.0
	bt(parts_ok, "LAB_CHECK tiempos por parte " + ("ok" if parts_ok else "FALLA %s" % str(r["parts"])))
	var sg := lab_suggestions()
	var all_ok: bool = sg.size() >= 1 and sg[sg.size() - 1][0] == "Informe completo"
	for s in sg:
		if not (s[2].contains("URBANA") and s[2].contains(" ms")):
			all_ok = false
			print("  sin contexto o números: ", s[0])
	bt(all_ok, "LAB_CHECK pedidos con contexto y números " + ("ok (%d)" % sg.size() if all_ok else "FALLA"))
	# un trabón a mano: un cuadro de 60 ms después de que los bloques tardaron 40 ms
	var n0 := lab_stutters.size()
	lab_cur.fill(0.0)
	lab_cur[2] = 40.0
	lab_frame(0.016)
	lab_frame(0.06)
	var st_ok: bool = lab_stutters.size() == n0 + 1 and lab_stutters[n0]["part"] == 2
	bt(st_ok, "LAB_CHECK anota el trabón y la parte culpable " + ("ok" if st_ok else "FALLA"))
	var txt := lab_all_text()
	bt(txt.length() > 300 and txt.contains("bloques de la ciudad"), "LAB_CHECK copiar todo " + ("ok (%d letras)" % txt.length() if txt.length() > 300 else "FALLA"))
	open_lab()
	bt(sheet.visible and sheet_name == "lab", "LAB_CHECK panel abierto " + ("ok" if sheet.visible else "FALLA"))
