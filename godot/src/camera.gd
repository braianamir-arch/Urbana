# Cámara, intro y gestos táctiles, mouse y teclado.
var intro_full: bool = false
var gesture: String = ""
var press_pos := Vector2.ZERO
var press_time: float = 0.0
var hover_cell: int = -1
var multi_d0: float = 0.0
var multi_a0: float = 0.0
var multi_mid0 := Vector2.ZERO
var mouse_btn: int = 0
var last_mouse := Vector2.ZERO
const DRAG_TOOLS := ["road", "zone", "dezone", "demolish", "cable", "pipe", "bike", "tram", "levee", "trees"]
func setup_camera() -> void:
	cam = Camera3D.new()
	cam.far = 3000.0
	cam.fov = 55.0
	add_child(cam)
	cam.current = true
func update_camera(delta: float) -> void:
	if intro_t >= 0.0:
		update_intro(delta)
		return
	if cam_follow != null:
		var fp = cam_follow.call()
		if fp == null:
			cam_follow = null
		else:
			cam_goal = fp
	var half := N * CELL * 0.55
	cam_goal.x = clampf(cam_goal.x, -half, half)
	cam_goal.z = clampf(cam_goal.z, -half, half)
	cam_dist_goal = clampf(cam_dist_goal, 8.0 if drive != null else 14.0, 480.0)
	cam_pitch = clampf(cam_pitch, 0.22, 1.32)
	var k := 1.0 - exp(-delta * 12.0)
	cam_target = cam_target.lerp(cam_goal, k)
	cam_dist = lerpf(cam_dist, cam_dist_goal, k)
	place_camera()
func place_camera() -> void:
	var off := Vector3(sin(cam_yaw) * cos(cam_pitch), sin(cam_pitch), cos(cam_yaw) * cos(cam_pitch)) * cam_dist
	cam.position = cam_target + off
	cam.look_at(cam_target, Vector3.UP)
	if sun and not OS.has_feature("android"):
		sun.directional_shadow_max_distance = clampf(cam_dist * 2.2, 80.0, 420.0)
func start_intro(full: bool) -> void:
	intro_full = full
	intro_t = 0.0
func update_intro(delta: float) -> void:
	intro_t += delta
	var dur := 9.0 if intro_full else 3.5
	var t := clampf(intro_t / dur, 0.0, 1.0)
	var e := t * t * (3.0 - 2.0 * t)
	var a := cam_yaw + (1.0 - e) * (2.4 if intro_full else 0.8)
	var d := lerpf(420.0 if intro_full else 300.0, cam_dist_goal, e)
	var pt := lerpf(1.1, cam_pitch, e)
	var off := Vector3(sin(a) * cos(pt), sin(pt), cos(a) * cos(pt)) * d
	cam.position = cam_goal + off
	cam.look_at(cam_goal, Vector3.UP)
	cam_target = cam_goal
	cam_dist = cam_dist_goal
	if t >= 1.0:
		intro_t = -1.0
		if not card_queue.is_empty() and not card_panel.visible:
			next_card()
func skip_intro() -> void:
	if intro_t >= 0.0:
		intro_t = 999.0
func screen_ground(pos: Vector2) -> Vector3:
	var o := cam.project_ray_origin(pos)
	var d := cam.project_ray_normal(pos)
	if absf(d.y) < 0.0001:
		return Vector3(INF, 0, INF)
	var y := 0.0
	var p := Vector3.ZERO
	for it in 2:
		var t := (y - o.y) / d.y
		if t < 0:
			return Vector3(INF, 0, INF)
		p = o + d * t
		var c := world_to_cell(p)
		if inb(c.x, c.y):
			y = maxf(hgt[idx(c.x, c.y)], 0.0)
	return p
func screen_cell(pos: Vector2) -> int:
	var p := screen_ground(pos)
	if p.x == INF:
		return -1
	var c := world_to_cell(p)
	if not inb(c.x, c.y):
		return -1
	return idx(c.x, c.y)
var ui_touch := {}
func on_touch(index: int, pos: Vector2, pressed: bool) -> void:
	if pressed:
		if over_ui(pos):
			ui_touch[index] = true
			return
		ui_touch.erase(index)
	elif ui_touch.has(index):
		ui_touch.erase(index)
		return
	elif not touches.has(index):
		return
	if pressed:
		touches[index] = pos
		if touches.size() == 1:
			gesture = ""
			press_pos = pos
			press_time = Time.get_ticks_msec() / 1000.0
			drag_a = screen_cell(pos)
			drag_b = drag_a
		elif touches.size() == 2:
			if gesture == "draw":
				clear_preview()
			gesture = "multi"
			var ps: Array = touches.values()
			multi_d0 = (ps[0] - ps[1]).length()
			multi_a0 = (ps[1] - ps[0]).angle()
			multi_mid0 = (ps[0] + ps[1]) * 0.5
	else:
		touches.erase(index)
		if touches.is_empty():
			if gesture == "":
				tap_at(pos)
			elif gesture == "draw":
				commit_drag()
			gesture = ""
		elif gesture == "multi":
			gesture = "done"
func on_drag(index: int, pos: Vector2) -> void:
	if ui_touch.has(index) or not touches.has(index):
		return
	var prev: Vector2 = touches[index]
	touches[index] = pos
	cam_moving_t = 0.4
	if touches.size() == 1:
		if gesture == "":
			if (pos - press_pos).length() > 14.0:
				if tool["k"] in DRAG_TOOLS:
					gesture = "draw"
				else:
					gesture = "pan"
		if gesture == "draw":
			var c := screen_cell(pos)
			if c >= 0 and c != drag_b:
				drag_b = c
				show_preview()
		elif gesture == "pan":
			pan_screen(prev, pos)
	elif touches.size() == 2 and gesture == "multi":
		var ps: Array = touches.values()
		var d: float = (ps[0] - ps[1]).length()
		var a: float = (ps[1] - ps[0]).angle()
		var mid: Vector2 = (ps[0] + ps[1]) * 0.5
		if multi_d0 > 10.0:
			cam_dist_goal *= multi_d0 / maxf(d, 1.0)
			cam_dist = cam_dist_goal
		crumb("dos dedos (zoom %d)" % int(cam_dist_goal))
		var da := wrapf(a - multi_a0, -PI, PI)
		cam_yaw += da
		var dm := mid - multi_mid0
		if absf(dm.y) > absf(dm.x) * 1.5 and absf(d - multi_d0) < 12.0:
			cam_pitch += dm.y * 0.004
		else:
			pan_screen(multi_mid0, mid)
		multi_d0 = d
		multi_a0 = a
		multi_mid0 = mid
func pan_screen(from: Vector2, to: Vector2) -> void:
	var a := screen_ground(from)
	var b := screen_ground(to)
	if a.x == INF or b.x == INF:
		return
	var d := a - b
	d.y = 0
	cam_goal += d
	cam_target += d
	cam_follow = null
func on_mouse_button(ev: InputEventMouseButton) -> void:
	if ev.button_index == MOUSE_BUTTON_WHEEL_UP and ev.pressed:
		if ev.shift_pressed:
			cam_pitch += 0.06
		else:
			cam_dist_goal *= 0.88
		return
	if ev.button_index == MOUSE_BUTTON_WHEEL_DOWN and ev.pressed:
		if ev.shift_pressed:
			cam_pitch -= 0.06
		else:
			cam_dist_goal *= 1.13
		return
	if ev.pressed:
		mouse_btn = ev.button_index
		last_mouse = ev.position
		if ev.button_index == MOUSE_BUTTON_LEFT:
			on_touch(0, ev.position, true)
	else:
		if ev.button_index == MOUSE_BUTTON_LEFT and touches.has(0):
			on_touch(0, ev.position, false)
		mouse_btn = 0
func on_mouse_motion(ev: InputEventMouseMotion) -> void:
	if mouse_btn == MOUSE_BUTTON_LEFT:
		on_drag(0, ev.position)
	elif mouse_btn == MOUSE_BUTTON_RIGHT:
		pan_screen(last_mouse, ev.position)
	elif mouse_btn == MOUSE_BUTTON_MIDDLE:
		cam_yaw -= (ev.position.x - last_mouse.x) * 0.006
		cam_pitch += (ev.position.y - last_mouse.y) * 0.005
	else:
		var c := screen_cell(ev.position)
		if c != hover_cell:
			hover_cell = c
			if tool["k"] == "def":
				drag_a = c
				drag_b = c
				show_preview()
	last_mouse = ev.position
func on_key(ev: InputEventKey) -> void:
	var step := cam_dist * 0.08
	var fw := Vector3(-sin(cam_yaw), 0, -cos(cam_yaw))
	var rt := Vector3(cos(cam_yaw), 0, -sin(cam_yaw))
	match ev.keycode:
		KEY_W, KEY_UP:
			cam_goal += fw * step
		KEY_S, KEY_DOWN:
			cam_goal -= fw * step
		KEY_A, KEY_LEFT:
			cam_goal -= rt * step
		KEY_D, KEY_RIGHT:
			cam_goal += rt * step
		KEY_Q:
			cam_yaw += 0.15
		KEY_E:
			cam_yaw -= 0.15
		KEY_R:
			cam_pitch += 0.08
		KEY_F:
			cam_pitch -= 0.08
		KEY_EQUAL, KEY_KP_ADD:
			cam_dist_goal *= 0.85
		KEY_MINUS, KEY_KP_SUBTRACT:
			cam_dist_goal *= 1.15
		KEY_SPACE:
			set_speed(0 if speed > 0 else 1)
		KEY_1:
			set_speed(1)
		KEY_2:
			set_speed(2)
		KEY_3:
			set_speed(3)
		KEY_ESCAPE:
			set_tool({"k": "look"})
func tap_at(pos: Vector2) -> void:
	var c := screen_cell(pos)
	var k: String = tool["k"]
	if k in DRAG_TOOLS:
		if c >= 0:
			apply_cells([c])
		return
	match k:
		"look":
			var pk := pick_ped(pos)
			if not pk.is_empty():
				follow_citizen(pk)
			elif c >= 0:
				show_info(c)
		"def":
			if hover_cell != c or not preview_node.multimesh.instance_count:
				pass
			place_def(c, tool["id"])
			clear_preview()
		"round":
			toggle_round(c)
		"stop":
			place_stop(c, tool["kind"])
		"line":
			pick_line_stop(c)
		"buy":
			ask_buy_region(c)
		"district":
			if c >= 0:
				open_district(region_of(c))
		"follow":
			pass
