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
	if test_mode == "sim":
		run_sim()
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
	print("SIM OK")
	get_tree().quit()
