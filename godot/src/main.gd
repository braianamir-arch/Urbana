# Arranque y bucle principal de Godot.
func _unhandled_input(event: InputEvent) -> void:
	if intro_t >= 0.0:
		if event is InputEventScreenTouch or (event is InputEventMouseButton and event.pressed):
			skip_intro()
		return
	if photo_mode and event is InputEventScreenTouch and event.pressed and touches.is_empty():
		pass
	if event is InputEventScreenTouch:
		on_touch(event.index, event.position, event.pressed)
	elif event is InputEventScreenDrag:
		on_drag(event.index, event.position)
	elif event is InputEventMouseButton:
		if event.device == -1:
			return
		on_mouse_button(event)
	elif event is InputEventMouseMotion:
		if event.device == -1:
			return
		on_mouse_motion(event)
	elif event is InputEventKey and event.pressed:
		on_key(event)
var idle_t: float = 0.0
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		if started:
			save_game(slot)
		crumb("cierre limpio")
var first_chunks: bool = true
func _ready() -> void:
	if FileAccess.file_exists("user://ultimo_paso.txt"):
		prev_crumb = FileAccess.get_file_as_string("user://ultimo_paso.txt").strip_edges()
	crumb("arranque")
	randomize()
	load_opts()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--test"):
			test_mode = a.substr(7) if a.length() > 7 else "run"
	if test_mode != "":
		seed(20261012)
	setup_render()
	setup_camera()
	setup_agents()
	apply_quality()
	setup_audio()
	build_ui()
	migrate_old_file()
	reset_state()
	gen_map(randi() % 5, randi() % 100000 + 1)
	place_plaza()
	after_load()
	cam_yaw = 0.6
	cam_dist_goal = 260.0
	show_start()
	if test_mode != "":
		print("TEST ", test_mode)
func _process(delta: float) -> void:
	scroll_coast_step(delta)
	crumb("terreno")
	if terrain_dirty:
		build_terrain()
	crumb("chunks")
	var lt := Time.get_ticks_usec()
	update_chunks(4 if first_chunks or not started else 1)
	if first_chunks and not chunk_dirty.has(1):
		first_chunks = false
	# versiones cerca de los edificios: una cada 3 cuadros, cuando la ciudad ya está dibujada
	if not first_chunks and int(opts["quality"]) >= 1 and Engine.get_process_frames() % 3 == 0:
		cat_warm_step()
	lab_add(2, lt)
	if started:
		crumb("simulación etapa %d" % sim_stage)
		lt = Time.get_ticks_usec()
		sim_process(delta)
		lab_add(0, lt)
		crumb("agentes (intro %s, zoom %d)" % [str(intro_t >= 0.0), int(cam_dist)])
		lt = Time.get_ticks_usec()
		agents_process(delta)
		lab_add(1, lt)
	else:
		cam_yaw += delta * 0.05
	warm_step()
	crumb("luz")
	lt = Time.get_ticks_usec()
	update_light()
	crumb("cámara (intro %s, zoom %d)" % [str(intro_t >= 0.0), int(cam_dist)])
	update_camera(delta)
	update_fx()
	lab_add(3, lt)
	crumb("interfaz")
	lt = Time.get_ticks_usec()
	ui_process(delta)
	lab_add(4, lt)
	lab_frame(delta)
	crumb("dibujando el cuadro")
	if opts["idle30"] and not OS.has_feature("android"):
		idle_t += delta
		if not touches.is_empty() or cam_moving_t > 0.0 or intro_t >= 0.0 or drive != null:
			idle_t = 0.0
		Engine.max_fps = 30 if idle_t > 4.0 else 0
	else:
		Engine.max_fps = 0
	cam_moving_t = maxf(0.0, cam_moving_t - delta)
	if test_mode != "":
		run_test()
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		finger_pos = event.position
		scroll_input(event)
		if event is InputEventScreenDrag:
			drag_acc += event.relative.length()
		elif event.pressed:
			drag_acc = 0.0
	if event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventKey:
		idle_t = 0.0
