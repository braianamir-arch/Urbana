# Interfaz: HUD, abanico, bandejas, hojas, tarjetas, tutorial e íconos.
const ROAD_NAMES := ["", "Tierra", "Calle", "Avenida", "Autopista"]
const ZONE_NAMES := ["", "Residencial", "Comercial", "Industrial", "Mixta"]
const DEPTS := ["Policía", "Bomberos", "Salud", "Educación", "Parques", "Transporte", "Basura"]
const DISTRICT_RULES := ["Sin regla", "Densa", "Verde", "Tranquila", "24 horas"]
const MAP_KINDS := ["Río", "Lago", "Costa", "Islas", "Llanura"]
var scrolls: Array = []
var scroll_act: ScrollContainer = null
var scroll_coast: ScrollContainer = null
var scroll_vel: float = 0.0
func scroll_at(p: Vector2) -> ScrollContainer:
	for s in scrolls:
		var sc: ScrollContainer = s
		if sc.is_visible_in_tree():
			var r := sc.get_global_rect()
			if Rect2(r.position * ui_scale, r.size * ui_scale).has_point(p):
				return sc
	return null
func slider_under(n: Node, p: Vector2) -> bool:
	for c in n.get_children():
		if c is Slider:
			var r: Rect2 = c.get_global_rect()
			if Rect2(r.position * ui_scale, r.size * ui_scale).has_point(p):
				return true
		if slider_under(c, p):
			return true
	return false
func scroll_input(ev: InputEvent) -> void:
	if ev is InputEventScreenTouch:
		if ev.pressed:
			scroll_act = scroll_at(ev.position)
			scroll_coast = null
			if scroll_act != null and slider_under(scroll_act, ev.position):
				scroll_act = null
		else:
			scroll_coast = scroll_act
			scroll_act = null
	elif ev is InputEventScreenDrag and scroll_act != null and drag_acc > 14.0 * ui_scale:
		var d: Vector2 = ev.relative / ui_scale
		var horiz: bool = scroll_act.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
		var amt: float = d.x if horiz else d.y
		scroll_move(scroll_act, horiz, -amt)
		scroll_vel = lerpf(scroll_vel, -amt / maxf(get_process_delta_time(), 0.004), 0.5)
func scroll_move(sc: ScrollContainer, horiz: bool, amt: float) -> void:
	if horiz:
		sc.scroll_horizontal += roundi(amt)
	else:
		sc.scroll_vertical += roundi(amt)
func scroll_coast_step(delta: float) -> void:
	if scroll_coast == null:
		return
	if absf(scroll_vel) < 30.0 or not scroll_coast.is_visible_in_tree():
		scroll_coast = null
		scroll_vel = 0.0
		return
	scroll_move(scroll_coast, scroll_coast.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED, scroll_vel * delta)
	scroll_vel *= pow(0.04, delta)
func over_ui(pos: Vector2) -> bool:
	for fb in fan_btns:
		if fb.visible and fb.modulate.a > 0.05:
			var fr: Rect2 = fb.get_global_rect()
			if Rect2(fr.position * ui_scale, fr.size * ui_scale).has_point(pos):
				return true
	for c in [hud_col, hud_right, build_btn, bottom_box, side_box, sheet, info_panel, mode_bar, drive_bar, follow_panel, tut_panel, card_panel, start_panel]:
		var cc: Control = c
		if cc.visible:
			var r := cc.get_global_rect()
			var rr := Rect2(r.position * ui_scale, r.size * ui_scale)
			if rr.has_point(pos):
				return true
	return false
var ui_layer: CanvasLayer
var ui_root: Control
var ui_theme: Theme
var top_bar: PanelContainer
var hud_col: VBoxContainer
var hud_detail: VBoxContainer
var hud_right: HBoxContainer
var hud_chev: Button
var hud_open: bool = false
var hud_state: int = 0
var ui_built: bool = false
var notif_title: Label
var notif_text: Label
var notif_icon: TextureRect
var notif_q: Array = []
var menu_card: PanelContainer
var menu_scroll: ScrollContainer
var city_card: PanelContainer
var obj_card: PanelContainer
var obj_head: Label
var obj_text: Label
var obj_bar: ProgressBar
var obj_rew: Label
var top_rate: Label
var top_clock: Label
var top_stage: Label
var top_stage_bar: ProgressBar
var fan_final: Array = []
var fan_was_open: bool = false
var fan_hold_t: float = 0.0
var fan_dwell: float = 0.0
var fan_c: Vector2 = Vector2.ZERO
var top_pop: Label
var top_date: Label
var top_weather: Label
var top_appr: Label
var rci_bars: Array = []
var speed_btns: Array = []
var news_label: Label
var hint_label: Label
var toast_label: Label
var toast_t: float = 0.0
var cost_label: Label
var bottom_box: VBoxContainer
var cat_btns := {}
var side_box: GridContainer
var sheet_title: Label
var info_body: VBoxContainer
var info_cell: int = -1
var mode_label: Label
var mode_btns: HBoxContainer
var drive_bar: PanelContainer
var drive_label: Label
var follow_panel: PanelContainer
var follow_label: Label
var start_panel: PanelContainer
var start_body: VBoxContainer
var fps_label: Label
var photo_btn: Button
var photo_extra: Array = []
var ui_timer: float = 0.0
var overlay_timer: float = 0.0
var tut_on: bool = false
var tut_step: int = 0
var tut_panel: PanelContainer
var tut_label: Label
const TUT_STEPS := [
	["Tocá Construir, elegí Calles y después Calle.", "cat_roads"],
	["Arrastrá el dedo sobre el pasto para hacer una calle larga.", "roads5"],
	["Ahora tocá Construir, Zonas y elegí Residencial.", "tool_zone"],
	["Tocá un lote al lado de la calle, o arrastrá para marcar varios.", "zoneR"],
	["Tocá Construir, Infra y poné una usina a carbón cerca de la calle.", "power"],
	["Poné una torre de agua. La luz y el agua viajan por las calles.", "water"],
	["Marcá unos lotes comerciales para que la gente trabaje.", "zoneC"],
	["Apretá ▶▶ arriba para que el tiempo pase más rápido. ¡Listo!", "speed"],
]
class Chart extends Control:
	var data: Array = []
	var col := Color(0.4, 0.8, 1.0)
	var title := ""
	var money := false
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.25))
		var font := get_theme_default_font()
		var fs := get_theme_default_font_size()
		draw_string(font, Vector2(10, fs + 4), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 1, 1, 0.85))
		if data.size() < 2:
			draw_string(font, Vector2(10, size.y - 12), "Faltan datos: esperá unos días", HORIZONTAL_ALIGNMENT_LEFT, -1, fs - 4, Color(1, 1, 1, 0.5))
			return
		var lo: float = data[0]
		var hi: float = data[0]
		for v in data:
			lo = minf(lo, v)
			hi = maxf(hi, v)
		if hi - lo < 0.0001:
			hi = lo + 1.0
		var pts := PackedVector2Array()
		var top := fs + 14.0
		var h := size.y - top - 8.0
		for k in data.size():
			var x := 8.0 + (size.x - 16.0) * k / float(data.size() - 1)
			var y := top + h * (1.0 - (float(data[k]) - lo) / (hi - lo))
			pts.append(Vector2(x, y))
		draw_polyline(pts, col, 3.0, true)
		var last: float = data[data.size() - 1]
		var txt := str(snappedf(last, 0.01))
		if money:
			txt = str(int(last))
		draw_string(font, Vector2(size.x - 160, fs + 4), txt, HORIZONTAL_ALIGNMENT_RIGHT, 150, fs, col)
# paleta: vidrio oscuro grafito, bordes finos y un solo color de acento (ámbar)
const COL_BG := Color(0.075, 0.09, 0.115, 0.86)
const COL_BTN := Color(0.17, 0.2, 0.25, 0.94)
const COL_ACC := Color(1.0, 0.76, 0.27)
const COL_ACC_DK := Color(0.16, 0.11, 0.03)
const COL_LINE := Color(1, 1, 1, 0.1)
const COL_SUB := Color(0.72, 0.78, 0.86)
var font_bold: Font = null
func sbox(col: Color, radius: int = 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.set_corner_radius_all(radius)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s
func sbtn(col: Color, border: Color = COL_LINE) -> StyleBoxFlat:
	var s := sbox(col, 14)
	s.set_border_width_all(1)
	s.border_color = border
	s.shadow_color = Color(0, 0, 0, 0.28)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 2)
	s.anti_aliasing_size = 0.8
	return s
func ssel(col: Color = COL_ACC, radius: int = 14) -> StyleBoxFlat:
	var s := sbtn(col, Color(1, 1, 1, 0.35))
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(1.0, 0.76, 0.27, 0.3)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 0)
	return s
# títulos y números importantes en negrita
func bold(c: Control) -> void:
	if font_bold != null:
		c.add_theme_font_override("font", font_bold)
func make_knob(r: int, col: Color) -> ImageTexture:
	var img := Image.create(r * 2, r * 2, false, Image.FORMAT_RGBA8)
	for y in r * 2:
		for x in r * 2:
			var d := Vector2(x + 0.5 - r, y + 0.5 - r).length()
			var a := clampf(r - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(col.r, col.g, col.b, a))
	return ImageTexture.create_from_image(img)
func make_theme() -> void:
	var t := ui_theme
	# letra Inter (licencia OFL); los emojis y símbolos salen de la letra de respaldo
	var fr: Font = load("res://assets/fonts/Inter-Medium.ttf") if ResourceLoader.exists("res://assets/fonts/Inter-Medium.ttf") else null
	var fb: Font = load("res://assets/fonts/Inter-Bold.ttf") if ResourceLoader.exists("res://assets/fonts/Inter-Bold.ttf") else null
	if fr is FontFile:
		(fr as FontFile).fallbacks = [ThemeDB.fallback_font]
		t.default_font = fr
	if fb is FontFile:
		(fb as FontFile).fallbacks = [ThemeDB.fallback_font]
		font_bold = fb
	t.set_stylebox("normal", "Button", sbtn(COL_BTN))
	t.set_stylebox("hover", "Button", sbtn(COL_BTN))
	t.set_stylebox("pressed", "Button", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	t.set_stylebox("hover_pressed", "Button", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	t.set_stylebox("disabled", "Button", sbtn(Color(0.14, 0.16, 0.2, 0.6)))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", Color(0.95, 0.96, 0.98))
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", COL_ACC_DK)
	t.set_color("font_hover_pressed_color", "Button", COL_ACC_DK)
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.4))
	t.set_stylebox("panel", "PanelContainer", sbox(COL_BG, 16))
	t.set_stylebox("normal", "TextEdit", sbox(Color(0.04, 0.05, 0.07, 0.9), 10))
	t.set_stylebox("focus", "TextEdit", sbox(Color(0.04, 0.05, 0.07, 0.9), 10))
	t.set_color("font_color", "Label", Color(0.95, 0.96, 0.98))
	t.set_stylebox("slider", "HSlider", sbox(Color(1, 1, 1, 0.16), 6))
	var fill := sbox(COL_ACC, 6)
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	for st in ["slider", "grabber_area", "grabber_area_highlight"]:
		var sb: StyleBoxFlat = t.get_stylebox(st, "HSlider")
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
	var kn := make_knob(22, Color(0.96, 0.97, 1.0))
	t.set_icon("grabber", "HSlider", kn)
	t.set_icon("grabber_highlight", "HSlider", kn)
	t.set_icon("grabber_disabled", "HSlider", kn)
	t.set_constant("separation", "HSeparator", 14)
	t.set_stylebox("separator", "HSeparator", sbox(Color(1, 1, 1, 0.12), 2))
	for sbn in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", sbn, sbox(Color(1, 1, 1, 0.05), 6))
		t.set_stylebox("grabber", sbn, sbox(Color(1, 1, 1, 0.25), 6))
		t.set_stylebox("grabber_highlight", sbn, sbox(Color(1, 1, 1, 0.4), 6))
		t.set_stylebox("grabber_pressed", sbn, sbox(Color(1, 1, 1, 0.5), 6))
func top_style() -> StyleBoxFlat:
	var s := sbox(Color(COL_BG.r, COL_BG.g, COL_BG.b, 0.84), 22)
	s.set_border_width_all(1)
	s.border_color = Color(1, 1, 1, 0.14)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 3)
	s.corner_radius_top_left = 0
	s.corner_radius_top_right = 0
	return s
func mk_panel(alpha: float = 0.82) -> PanelContainer:
	var p := PanelContainer.new()
	var s := sbox(Color(COL_BG.r, COL_BG.g, COL_BG.b, alpha), 16)
	s.set_border_width_all(1)
	s.border_color = COL_LINE
	s.shadow_color = Color(0, 0, 0, 0.3)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 3)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	return p
func chip(l: Label) -> PanelContainer:
	var p := PanelContainer.new()
	var s := sbox(Color(1, 1, 1, 0.06), 12)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return p
func mk_label(t: String, fs: int = 0, col: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = t
	if fs > 0:
		l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
func mk_text(t: String) -> Label:
	var l := mk_label(t)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(300, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l
func mk_btn(t: String, cb: Callable, minw: int = 0) -> Button:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = Vector2(minw, 56)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func():
		if drag_acc > 14.0 * ui_scale:
			return
		crumb("botón " + t.replace("\n", " "))
		sfx("click")
		cb.call())
	press_fx(b)
	return b
func reg_scroll(sc: ScrollContainer) -> void:
	scrolls.append(sc)
	sc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for sb in [sc.get_v_scroll_bar(), sc.get_h_scroll_bar()]:
		var bar: ScrollBar = sb
		bar.modulate.a = 0.0
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.custom_minimum_size.x = 8
		bar.value_changed.connect(func(_v: float):
			bar.modulate.a = 1.0
			if bar.has_meta("tw"):
				bar.get_meta("tw").kill()
			var tw := bar.create_tween()
			tw.tween_interval(0.7)
			tw.tween_property(bar, "modulate:a", 0.0, 0.4)
			bar.set_meta("tw", tw))
func press_fx(b: Button) -> void:
	b.resized.connect(func(): b.pivot_offset = b.size * 0.5)
	b.button_down.connect(func():
		var tw := b.create_tween()
		tw.tween_property(b, "scale", Vector2(0.93, 0.93), 0.07))
	b.button_up.connect(func():
		var tw := b.create_tween()
		tw.set_trans(Tween.TRANS_BACK)
		tw.set_ease(Tween.EASE_OUT)
		tw.tween_property(b, "scale", Vector2.ONE, 0.22))
func pop_in(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	c.modulate.a = 0.0
	c.scale = Vector2(0.95, 0.95)
	var tw := c.create_tween()
	tw.set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, 0.16)
	tw.tween_property(c, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
func mk_round(t: String, cb: Callable) -> Button:
	var b := mk_btn("" if t.begins_with("@") else t, cb, 84)
	if t.begins_with("@"):
		add_btn_icon(b, t.substr(1), 62)
	b.custom_minimum_size = Vector2(84, 84)
	b.set_meta("round", true)
	b.add_theme_font_size_override("font_size", 34)
	for st in ["normal", "hover"]:
		var n := sbtn(COL_BTN)
		n.set_corner_radius_all(42)
		b.add_theme_stylebox_override(st, n)
	for st in ["pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(st, ssel(COL_ACC, 42))
	return b
func mk_ibtn(icon: String, lab: String, cb: Callable, w: int, h: int, isz: int = 34) -> Button:
	var b := mk_btn("", func():
		crumb("botón " + lab)
		cb.call(), w)
	b.custom_minimum_size = Vector2(w, h)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", -2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var li: Control = mk_ico(icon.substr(1), int(isz * 1.6)) if icon.begins_with("@") else mk_label(icon, isz)
	if li is Label:
		li.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var lt := mk_label(lab, maxi(int(opts["text"]) - 5, 13))
	lt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(li)
	v.add_child(lt)
	b.add_child(v)
	b.set_meta("lbls", [li, lt])
	return b
func mk_main(t: String, cb: Callable) -> Button:
	var b := mk_btn(t, cb, 0)
	b.custom_minimum_size = Vector2(0, 76)
	b.add_theme_font_size_override("font_size", int(opts["text"]) + 6)
	b.add_theme_stylebox_override("normal", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	b.add_theme_stylebox_override("hover", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	b.add_theme_stylebox_override("pressed", sbtn(Color(0.85, 0.62, 0.2), Color(1, 1, 1, 0.5)))
	b.add_theme_color_override("font_color", COL_ACC_DK)
	b.add_theme_color_override("font_hover_color", COL_ACC_DK)
	b.add_theme_color_override("font_pressed_color", COL_ACC_DK)
	return b
func mark_sel(b: Button, on: bool) -> void:
	if b.has_meta("lbls"):
		for l in b.get_meta("lbls"):
			l.add_theme_color_override("font_color", COL_ACC_DK if on else Color.WHITE)
	var rr := 42 if b.has_meta("round") else 18
	if on:
		b.add_theme_stylebox_override("normal", ssel(COL_ACC, rr))
		b.add_theme_stylebox_override("hover", ssel(COL_ACC, rr))
		b.add_theme_color_override("font_color", COL_ACC_DK)
		b.add_theme_color_override("font_hover_color", COL_ACC_DK)
	else:
		b.remove_theme_stylebox_override("normal")
		b.remove_theme_stylebox_override("hover")
		b.remove_theme_color_override("font_color")
		b.remove_theme_color_override("font_hover_color")
func mk_row() -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 8)
	return r
func mk_slider(lo: float, hi: float, stp: float, val: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = stp
	s.value = val
	s.custom_minimum_size = Vector2(260, 52)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.value_changed.connect(cb)
	return s
func mk_check(t: String, on: bool, cb: Callable) -> Button:
	var c := Button.new()
	c.toggle_mode = true
	c.alignment = HORIZONTAL_ALIGNMENT_LEFT
	c.focus_mode = Control.FOCUS_NONE
	c.custom_minimum_size = Vector2(0, 58)
	c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c.set_pressed_no_signal(on)
	c.text = ("✔  " if on else "▢  ") + t
	c.toggled.connect(func(v: bool):
		c.text = ("✔  " if v else "▢  ") + t
		sfx("click")
		cb.call(v))
	return c
func mk_choice(items: Array, sel: int, cb: Callable) -> HBoxContainer:
	var r := mk_row()
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cur := [clampi(sel, 0, items.size() - 1)]
	var lab := mk_label(str(items[cur[0]]), 0, COL_ACC)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var step := func(d: int):
		cur[0] = (cur[0] + d + items.size()) % items.size()
		lab.text = str(items[cur[0]])
		cb.call(cur[0])
	r.add_child(mk_btn("◀", func(): step.call(-1), 64))
	r.add_child(lab)
	r.add_child(mk_btn("▶", func(): step.call(1), 64))
	return r
func clear_box(b: Node) -> void:
	for ch in b.get_children():
		b.remove_child(ch)
		ch.queue_free()
var crumb_last: String = ""
var crumb_f: FileAccess = null
# anota el último paso para saber dónde se cerró el juego. Se escribe como mucho cada 0,1 s (antes eran
# varias escrituras por cuadro y en el celular eso pesaba); "cierre limpio" se escribe siempre.
var crumb_t: int = -1000
func crumb(t: String) -> void:
	if t == crumb_last:
		return
	crumb_last = t
	var now := Time.get_ticks_msec()
	if now - crumb_t < 100 and not t.contains("cierre limpio"):
		return
	crumb_t = now
	if crumb_f == null:
		crumb_f = FileAccess.open("user://ultimo_paso.txt", FileAccess.WRITE)
		if crumb_f == null:
			return
	crumb_f.seek(0)
	var mem := "%dMB mem, %dMB video, %ds, cuadro %d" % [OS.get_static_memory_usage() / 1048576, int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / 1048576, Time.get_ticks_msec() / 1000, Engine.get_process_frames()]
	crumb_f.store_string(("día %d: %s [%s]" % [day, t, mem]).rpad(200))
	crumb_f.flush()
func build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 5
	add_child(ui_layer)
	ui_root = Control.new()
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(ui_root)
	ui_theme = Theme.new()
	ui_root.theme = ui_theme
	make_theme()
	apply_text_size()
	hud_col = VBoxContainer.new()
	hud_col.add_theme_constant_override("separation", 10)
	hud_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(hud_col)
	top_bar = mk_panel(0.86)
	hud_col.add_child(top_bar)
	var mcol := VBoxContainer.new()
	mcol.add_theme_constant_override("separation", 8)
	top_bar.add_child(mcol)
	var mr := mk_row()
	top_money = mk_label("$0", int(opts["text"]) + 12)
	bold(top_money)
	top_rate = mk_label("", int(opts["text"]) - 3, Color(0.55, 0.9, 0.55))
	top_rate.size_flags_vertical = Control.SIZE_SHRINK_END
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_chev = mk_btn("", func(): toggle_hud(), 64)
	hud_chev.custom_minimum_size = Vector2(64, 56)
	add_btn_icon(hud_chev, "chev_dn", 44)
	mr.add_child(top_money)
	mr.add_child(top_rate)
	mr.add_child(sp)
	mr.add_child(hud_chev)
	mcol.add_child(mr)
	hud_detail = VBoxContainer.new()
	hud_detail.add_theme_constant_override("separation", 8)
	mcol.add_child(hud_detail)
	top_pop = mk_label("0")
	top_appr = mk_label("0%")
	top_clock = mk_label("00:00")
	var dr := HFlowContainer.new()
	dr.add_theme_constant_override("h_separation", 14)
	dr.add_theme_constant_override("v_separation", 4)
	var dic := ["people", "happy", "clock"]
	var dl := [top_pop, top_appr, top_clock]
	for k in 3:
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 6)
		hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hb.add_child(mk_ico(dic[k], 34))
		hb.add_child(dl[k])
		dr.add_child(hb)
	hud_detail.add_child(dr)
	var rci := HBoxContainer.new()
	rci.add_theme_constant_override("separation", 6)
	rci.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rcol := [Color(0.35, 0.8, 0.35), Color(0.35, 0.6, 0.95), Color(0.95, 0.75, 0.25)]
	for k in 3:
		var pb := ProgressBar.new()
		pb.min_value = -100
		pb.max_value = 100
		pb.custom_minimum_size = Vector2(96, 30)
		pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pb.show_percentage = false
		pb.add_theme_stylebox_override("fill", sbox(rcol[k], 8))
		pb.add_theme_stylebox_override("background", sbox(Color(1, 1, 1, 0.12), 8))
		pb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pl := mk_label("", 15)
		pl.set_anchors_preset(Control.PRESET_FULL_RECT)
		pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		pl.add_theme_constant_override("outline_size", 5)
		pb.add_child(pl)
		rci.add_child(pb)
		rci_bars.append([pb, pl])
	hud_detail.add_child(rci)
	city_card = mk_panel(0.86)
	hud_col.add_child(city_card)
	var cv2 := VBoxContainer.new()
	cv2.add_theme_constant_override("separation", 6)
	city_card.add_child(cv2)
	top_stage = mk_label("")
	var shb := HBoxContainer.new()
	shb.add_theme_constant_override("separation", 8)
	shb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shb.add_child(mk_ico("city", 36))
	shb.add_child(top_stage)
	cv2.add_child(shb)
	top_stage_bar = ProgressBar.new()
	top_stage_bar.show_percentage = false
	top_stage_bar.min_value = 0
	top_stage_bar.max_value = 1
	top_stage_bar.custom_minimum_size = Vector2(0, 12)
	top_stage_bar.add_theme_stylebox_override("fill", sbox(COL_ACC, 6))
	top_stage_bar.add_theme_stylebox_override("background", sbox(Color(1, 1, 1, 0.12), 6))
	top_stage_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv2.add_child(top_stage_bar)
	top_date = mk_label("Día 1", int(opts["text"]) - 1, COL_SUB)
	cv2.add_child(top_date)
	top_weather = mk_label("☀")
	cv2.add_child(top_weather)
	obj_card = mk_panel(0.88)
	hud_col.add_child(obj_card)
	var ov := VBoxContainer.new()
	ov.add_theme_constant_override("separation", 4)
	obj_card.add_child(ov)
	obj_head = mk_label("", int(opts["text"]) - 5, COL_SUB)
	obj_text = mk_label("", 0, Color.WHITE)
	obj_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	obj_text.custom_minimum_size = Vector2(300, 0)
	obj_bar = ProgressBar.new()
	obj_bar.show_percentage = false
	obj_bar.custom_minimum_size = Vector2(0, 10)
	obj_bar.add_theme_stylebox_override("fill", sbox(Color(0.45, 0.85, 0.5), 5))
	obj_bar.add_theme_stylebox_override("background", sbox(Color(1, 1, 1, 0.12), 5))
	obj_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	obj_rew = mk_label("", int(opts["text"]) - 3, COL_SUB)
	ov.add_child(obj_head)
	ov.add_child(obj_text)
	ov.add_child(obj_bar)
	ov.add_child(obj_rew)
	top_weather.add_theme_font_size_override("font_size", int(opts["text"]) - 1)
	menu_card = mk_panel(0.9)
	hud_col.add_child(menu_card)
	menu_scroll = ScrollContainer.new()
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(menu_scroll)
	menu_card.add_child(menu_scroll)
	var mg := GridContainer.new()
	mg.columns = 2
	mg.add_theme_constant_override("h_separation", 8)
	mg.add_theme_constant_override("v_separation", 8)
	mg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_scroll.add_child(mg)
	for it in menu_items():
		var cb: Callable = it[1]
		var txt: String = it[0]
		var bt := mk_btn(txt.substr(txt.find(" ") + 1), func():
			set_hud_state(0)
			cb.call(), 0)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bt.custom_minimum_size = Vector2(0, 72)
		bt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		mg.add_child(bt)
	set_hud_state(0)
	hud_right = HBoxContainer.new()
	hud_right.add_theme_constant_override("separation", 10)
	hud_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(hud_right)
	hud_right.add_child(mk_round("@undo", func(): do_undo()))
	var sbt := mk_round("@play", func(): set_speed((speed + 1) % 4))
	speed_btns.append(sbt)
	hud_right.add_child(sbt)
	news_label = mk_label("", 0, Color(1, 1, 1, 0.92))
	news_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	news_label.add_theme_constant_override("outline_size", 6)
	ui_root.add_child(news_label)
	hint_label = mk_label("", 0, Color(1, 0.95, 0.7))
	hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hint_label.add_theme_constant_override("outline_size", 6)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_root.add_child(hint_label)
	toast_label = mk_label("", 17, Color(1, 1, 1))
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_stylebox_override("normal", sbox(Color(0.05, 0.05, 0.08, 0.85), 18))
	toast_label.visible = false
	ui_root.add_child(toast_label)
	fps_label = mk_label("", 18, Color(0.7, 1, 0.7))
	ui_root.add_child(fps_label)
	notif_panel = mk_panel(0.95)
	notif_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_panel.visible = false
	var nh := HBoxContainer.new()
	nh.add_theme_constant_override("separation", 14)
	nh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_icon = mk_ico("trophy", 40) as TextureRect
	var nv := VBoxContainer.new()
	nv.add_theme_constant_override("separation", 0)
	nv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notif_title = mk_label("", int(opts["text"]) - 7, COL_ACC)
	bold(notif_title)
	notif_text = mk_label("", int(opts["text"]) - 3, Color.WHITE)
	notif_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notif_text.custom_minimum_size = Vector2(220, 0)
	nv.add_child(notif_title)
	nv.add_child(notif_text)
	nh.add_child(notif_icon)
	nh.add_child(nv)
	notif_panel.add_child(nh)
	ui_root.add_child(notif_panel)
	bottom_box = VBoxContainer.new()
	bottom_box.add_theme_constant_override("separation", 6)
	bottom_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(bottom_box)
	cost_label = mk_label("", 0, Color(1, 0.95, 0.6))
	cost_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	cost_label.add_theme_constant_override("outline_size", 6)
	bottom_box.add_child(cost_label)
	var tray_panel := mk_panel(0.82)
	var tsc := ScrollContainer.new()
	tsc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tsc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	tsc.custom_minimum_size = Vector2(0, 100)
	tray_sc = tsc
	reg_scroll(tsc)
	tray = mk_row()
	tsc.add_child(tray)
	tray_panel.add_child(tsc)
	tray_panel.visible = false
	bottom_box.add_child(tray_panel)
	var icons := {"roads": "@roads", "zones": "@zones", "serv": "@serv", "infra": "@infra", "work": "@work", "fun": "@fun", "quit": "@quit"}
	for c in CATS:
		var key: String = c[0]
		var fb := mk_ibtn(icons[key], c[1], func(): pick_cat(key), 90, 90, 32)
		fb.visible = false
		ui_root.add_child(fb)
		fan_btns.append(fb)
		cat_btns[key] = fb
	build_btn = Button.new()
	build_btn.focus_mode = Control.FOCUS_NONE
	build_btn.custom_minimum_size = Vector2(240, 96)
	var bs := sbtn(COL_ACC, Color(1, 1, 1, 0.45))
	bs.set_corner_radius_all(48)
	bs.shadow_color = Color(0, 0, 0, 0.35)
	bs.shadow_size = 12
	bs.shadow_offset = Vector2(0, 4)
	var bp := sbtn(Color(0.88, 0.63, 0.18), Color(1, 1, 1, 0.45))
	bp.set_corner_radius_all(48)
	for st in ["normal", "hover"]:
		build_btn.add_theme_stylebox_override(st, bs)
	for st in ["pressed", "hover_pressed"]:
		build_btn.add_theme_stylebox_override(st, bp)
	var bh := HBoxContainer.new()
	bh.set_anchors_preset(Control.PRESET_FULL_RECT)
	bh.alignment = BoxContainer.ALIGNMENT_CENTER
	bh.add_theme_constant_override("separation", 10)
	bh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bi := mk_ico("crane", 62)
	var bl := mk_label("CONSTRUIR", int(opts["text"]) + 2, COL_ACC_DK)
	bold(bl)
	bh.add_child(bi)
	bh.add_child(bl)
	build_btn.add_child(bh)
	press_fx(build_btn)
	build_btn.button_down.connect(func(): fan_down())
	build_btn.button_up.connect(func(): fan_up())
	ui_root.add_child(build_btn)
	side_box = GridContainer.new()
	side_box.columns = 1
	side_box.add_theme_constant_override("h_separation", 10)
	side_box.add_theme_constant_override("v_separation", 10)
	ui_root.add_child(side_box)
	side_box.add_child(mk_ibtn("@rotate", "Girar", func(): cam_yaw -= 0.45, 92, 92))
	side_box.add_child(mk_ibtn("@tilt", "Inclinar", func():
		cam_pitch = 0.5 if cam_pitch > 1.0 else (cam_pitch + 0.4 if cam_pitch < 0.9 else 1.25), 92, 92))
	side_box.add_child(mk_ibtn("@zoomin", "Acercar", func(): cam_dist_goal *= 0.75, 92, 92))
	side_box.add_child(mk_ibtn("@zoomout", "Alejar", func(): cam_dist_goal *= 1.33, 92, 92))
	side_box.add_child(mk_ibtn("@eye", "Vistas", func(): show_tray("views"), 92, 92))
	sheet = mk_panel(0.9)
	sheet.visible = false
	ui_root.add_child(sheet)
	var sv2 := VBoxContainer.new()
	sheet.add_child(sv2)
	var sh_head := mk_row()
	sheet_title = mk_label("", 0)
	sheet_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sheet_title.add_theme_font_size_override("font_size", int(opts["text"]) + 6)
	bold(sheet_title)
	sh_head.add_child(sheet_title)
	sh_head.add_child(mk_btn("✕", func(): close_sheet(), 64))
	sv2.add_child(sh_head)
	var ssc := ScrollContainer.new()
	ssc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(ssc)
	ssc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sv2.add_child(ssc)
	sheet_body = VBoxContainer.new()
	sheet_body.add_theme_constant_override("separation", 10)
	sheet_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ssc.add_child(sheet_body)
	info_panel = mk_panel(0.9)
	info_panel.visible = false
	ui_root.add_child(info_panel)
	var isc := ScrollContainer.new()
	isc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(isc)
	info_panel.add_child(isc)
	info_body = VBoxContainer.new()
	info_body.add_theme_constant_override("separation", 6)
	info_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	isc.add_child(info_body)
	mode_bar = mk_panel(0.9)
	mode_bar.visible = false
	ui_root.add_child(mode_bar)
	var mv := mk_row()
	mode_bar.add_child(mv)
	mode_label = mk_label("")
	mv.add_child(mode_label)
	mode_btns = mk_row()
	mv.add_child(mode_btns)
	drive_bar = mk_panel(0.85)
	drive_bar.visible = false
	ui_root.add_child(drive_bar)
	var dv := mk_row()
	drive_bar.add_child(dv)
	drive_label = mk_label("")
	drive_label.custom_minimum_size = Vector2(260, 0)
	dv.add_child(drive_label)
	dv.add_child(mk_btn("◀ Doblar", func(): drive_turn = -1, 130))
	dv.add_child(mk_btn("Doblar ▶", func(): drive_turn = 1, 130))
	dv.add_child(mk_btn("Más rápido", func():
		if drive != null:
			drive["spd"] = minf(drive["spd"] + 1.0, 7.0), 140))
	dv.add_child(mk_btn("Más lento", func():
		if drive != null:
			drive["spd"] = maxf(drive["spd"] - 1.0, 1.0), 140))
	dv.add_child(mk_btn("Salir", func(): stop_drive(), 100))
	follow_panel = mk_panel(0.88)
	follow_panel.visible = false
	ui_root.add_child(follow_panel)
	var fv := VBoxContainer.new()
	follow_panel.add_child(fv)
	follow_label = mk_text("")
	fv.add_child(follow_label)
	var fr := mk_row()
	fr.add_child(mk_btn("🏠 Su casa", func():
		if follow_ped != null and follow_ped["home"] >= 0:
			cam_follow = null
			cam_goal = cell_pos(follow_ped["home"])
			cam_dist_goal = 40.0, 0))
	fr.add_child(mk_btn("🏢 Su trabajo", func():
		if follow_ped != null and follow_ped["job"] >= 0:
			cam_follow = null
			cam_goal = cell_pos(follow_ped["job"])
			cam_dist_goal = 40.0, 0))
	for fb in fr.get_children():
		fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fv.add_child(fr)
	fv.add_child(mk_btn("Dejar de seguir", func():
		follow_ped = null
		cam_follow = null
		hide_follow_card(), 0))
	tut_panel = mk_panel(0.92)
	tut_panel.add_theme_stylebox_override("panel", sbox(Color(0.1, 0.24, 0.45, 0.94), 16))
	tut_panel.visible = false
	ui_root.add_child(tut_panel)
	var tv := mk_row()
	tut_panel.add_child(tv)
	tut_label = mk_text("")
	tut_label.custom_minimum_size = Vector2(420, 0)
	tv.add_child(tut_label)
	tv.add_child(mk_btn("Saltar", func(): end_tutorial(), 100))
	card_panel = mk_panel(0.95)
	card_panel.visible = false
	ui_root.add_child(card_panel)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 10)
	card_panel.add_child(cv)
	card_title = mk_label("", 0, COL_ACC)
	card_title.add_theme_font_size_override("font_size", int(opts["text"]) + 4)
	bold(card_title)
	card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cv.add_child(card_title)
	card_text = mk_text("")
	card_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_text.custom_minimum_size = Vector2(400, 0)
	card_text.add_theme_font_size_override("font_size", int(opts["text"]) - 2)
	card_text.add_theme_color_override("font_color", Color(0.86, 0.89, 0.94))
	cv.add_child(card_text)
	card_btns = mk_row()
	card_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	cv.add_child(card_btns)
	photo_btn = Button.new()
	photo_btn.text = "Salir del modo foto"
	photo_btn.custom_minimum_size = Vector2(240, 56)
	photo_btn.modulate = Color(1, 1, 1, 0.6)
	photo_btn.visible = false
	photo_btn.pressed.connect(func(): set_photo_mode(false))
	photo_btn.modulate = Color(1, 1, 1, 0.75)
	var shoot := mk_btn("📸 Sacar foto", func(): take_photo(), 240)
	var hour_b := mk_btn("🌅 Cambiar la hora", func(): day_timer = fmod(day_timer + DAY_SECONDS / 6.0, DAY_SECONDS * 0.995), 240)
	photo_extra = [shoot, hour_b]
	var pl2 := CanvasLayer.new()
	pl2.layer = 6
	add_child(pl2)
	pl2.add_child(photo_btn)
	for pe in photo_extra:
		pe.visible = false
		pl2.add_child(pe)
	start_panel = mk_panel(0.88)
	start_panel.visible = false
	ui_root.add_child(start_panel)
	var stsc := ScrollContainer.new()
	stsc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(stsc)
	start_panel.add_child(stsc)
	start_body = VBoxContainer.new()
	start_body.add_theme_constant_override("separation", 12)
	start_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stsc.add_child(start_body)
	ui_root.move_child(build_btn, -1)
	for fb in fan_btns:
		ui_root.move_child(fb, -1)
	ui_root.move_child(card_panel, -1)
	ui_root.move_child(toast_label, -1)
	get_viewport().size_changed.connect(layout_ui)
	ui_built = true
	layout_ui()
	refresh_speed_buttons()
func toggle_hud() -> void:
	set_hud_state((hud_state + 1) % 3)
func set_hud_state(n: int) -> void:
	hud_state = n
	hud_open = n == 1
	set_btn_icon(hud_chev, ["chev_dn", "more", "chev_up"][n])
	hud_detail.visible = n == 1
	city_card.visible = n == 1
	obj_card.visible = n == 1 and story and obj_index < OBJECTIVES.size()
	menu_card.visible = n == 2
	if ui_built:
		hud_col.reset_size()
		layout_ui()
func show_hud(on: bool) -> void:
	hud_col.visible = on
	hud_right.visible = on
	bottom_box.visible = on
	side_box.visible = on
	build_btn.visible = on
	if not on:
		close_fan()
func fan_layout() -> void:
	var lefty: bool = opts["lefty"]
	fan_c = build_btn.position + build_btn.size * 0.5
	fan_final.clear()
	var n := fan_btns.size()
	var rad := 330.0
	for k in n:
		var ang := deg_to_rad(lerpf(186.0, 282.0, float(k) / float(n - 1)))
		if lefty:
			ang = PI - ang
		var bsz: Vector2 = fan_btns[k].size
		fan_final.append(fan_c + Vector2(cos(ang), sin(ang)) * rad - bsz * 0.5)
func open_fan() -> void:
	if fan_open:
		return
	fan_open = true
	fan_layout()
	create_tween().tween_property(side_box, "modulate:a", 0.0, 0.15)
	side_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crumb("abanico abierto")
	for k in fan_btns.size():
		var b: Button = fan_btns[k]
		b.visible = true
		b.pivot_offset = b.size * 0.5
		b.position = fan_c - b.size * 0.5
		b.scale = Vector2(0.3, 0.3)
		b.modulate.a = 0.0
		if b.has_meta("tw"):
			b.get_meta("tw").kill()
		var tw := b.create_tween()
		tw.set_parallel(true)
		tw.tween_property(b, "position", fan_final[k], 0.3).set_delay(k * 0.025).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(b, "scale", Vector2.ONE, 0.3).set_delay(k * 0.025).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(b, "modulate:a", 1.0, 0.15).set_delay(k * 0.025)
		b.set_meta("tw", tw)
func close_fan() -> void:
	if not fan_open:
		return
	fan_open = false
	fan_hover = ""
	create_tween().tween_property(side_box, "modulate:a", 1.0, 0.2)
	for k in fan_btns.size():
		var b: Button = fan_btns[k]
		if b.has_meta("tw"):
			b.get_meta("tw").kill()
		var tw := b.create_tween()
		tw.set_parallel(true)
		tw.tween_property(b, "position", fan_c - b.size * 0.5, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_property(b, "scale", Vector2(0.3, 0.3), 0.18)
		tw.tween_property(b, "modulate:a", 0.0, 0.16)
		tw.chain().tween_callback(func(): b.visible = fan_open)
		b.set_meta("tw", tw)
	for k in cat_btns:
		if k != cur_cat:
			mark_sel(cat_btns[k], false)
func fan_down() -> void:
	fan_hold = true
	fan_hold_t = 0.0
	fan_was_open = fan_open
	fan_dwell = 0.0
func fan_up() -> void:
	if not fan_hold:
		return
	fan_hold = false
	if fan_hover != "":
		var k := fan_hover
		fan_hover = ""
		pick_cat(k)
		return
	if fan_hold_t < 0.25:
		if fan_was_open:
			close_fan()
		else:
			open_fan()
	elif fan_open and not fan_was_open:
		close_fan()
func fan_process(delta: float) -> void:
	if not fan_hold:
		return
	fan_hold_t += delta
	if not fan_open and fan_hold_t > 0.25:
		open_fan()
	if not fan_open:
		return
	var mp := finger_pos / ui_scale
	var hov := ""
	for k in fan_btns.size():
		if fan_btns[k].get_global_rect().grow(10.0).has_point(mp):
			hov = CATS[k][0]
	if hov != fan_hover:
		fan_hover = hov
		fan_dwell = 0.0
		for k in cat_btns:
			mark_sel(cat_btns[k], k == hov or (hov == "" and k == cur_cat))
		if hov != "":
			sfx("click")
	elif hov != "":
		fan_dwell += delta
		if fan_dwell > 0.5:
			fan_hold = false
			fan_hover = ""
			pick_cat(hov)
func pick_cat(key: String) -> void:
	fan_hover = ""
	close_fan()
	toggle_cat(key)
func apply_text_size() -> void:
	ui_theme.default_font_size = int(opts["text"])
var sheet_avail: float = 600.0
func fit_sheet() -> void:
	if not sheet.visible:
		return
	var hh := minf(sheet_avail, sheet_body.get_combined_minimum_size().y + 110.0)
	if absf(sheet.size.y - hh) > 2.0:
		sheet.size = Vector2(sheet.size.x, hh)
# en el celular la interfaz sigue al tamaño real de la pantalla (en pulgadas), no solo a los píxeles:
# así no queda gigante en una tablet ni diminuta en un teléfono chico. Calibrado para que un teléfono
# común (lado corto de ~2,8") quede como antes.
func phys_factor() -> float:
	if not OS.has_feature("mobile"):
		return 1.0
	var dpi := float(DisplayServer.screen_get_dpi())
	var ss := Vector2(DisplayServer.screen_get_size())
	if dpi < 60.0 or ss.x <= 0.0:
		return 1.0
	var short_in := minf(ss.x, ss.y) / dpi
	return clampf(2.8 / short_in, 0.55, 1.2)
func layout_ui() -> void:
	var vs := get_viewport().get_visible_rect().size
	ui_scale = clampf(minf(vs.x, vs.y) / 1000.0 * phys_factor() * [1.0, 1.25, 1.5][clampi(int(opts["ui_size"]), 0, 2)], 0.45, 2.8)
	ui_layer.scale = Vector2(ui_scale, ui_scale)
	var w := vs.x / ui_scale
	var h := vs.y / ui_scale
	ui_root.position = Vector2.ZERO
	ui_root.size = Vector2(w, h)
	var lefty: bool = opts["lefty"]
	var hw := minf(450.0, w * 0.56)
	hud_col.custom_minimum_size = Vector2(hw, 0)
	hud_col.size = Vector2(hw, 0)
	menu_scroll.custom_minimum_size = Vector2(0, clampf(h - 300.0, 220.0, 620.0))
	hud_col.reset_size()
	var hm := hud_col.get_combined_minimum_size()
	hud_col.size = Vector2(hw, hm.y)
	hud_col.position = Vector2(w - hw - 14 if lefty else 14, 14)
	hud_right.reset_size()
	var rm := hud_right.get_combined_minimum_size()
	hud_right.position = Vector2(14 if lefty else w - rm.x - 14, 14)
	var tb_h := 14.0 + 84.0 + 10.0
	news_label.position = Vector2(14 if not lefty else 14 + 0.0, 14 + hm.y + 6)
	news_label.size = Vector2(minf(hw + 80, w - 120), 30)
	hint_label.position = Vector2(14, 14 + hm.y + 40)
	hint_label.size = Vector2(minf(hw + 80, w - 120), 30)
	fps_label.position = Vector2(w * 0.5 - 40, 6)
	var bw := 240.0
	build_btn.position = Vector2(14 if lefty else w - bw - 14, h - 96 - 14)
	build_btn.size = Vector2(bw, 96)
	var bm := bottom_box.get_combined_minimum_size()
	bottom_box.position = Vector2(bw + 28 if lefty else 0, h - bm.y)
	bottom_box.size = Vector2(w - bw - 28, bm.y)
	layout_side()
	var sbm := side_box.get_combined_minimum_size()
	var sw := minf(640.0, w - 20.0)
	var avail := h - 14.0 - bm.y - 20
	sheet.position = Vector2(w - sw - 10 if lefty else 10, 14)
	sheet_avail = avail
	sheet.size = Vector2(sw, avail)
	if not started:
		sheet.position = Vector2((w - sw) * 0.5, 14)
		sheet.size = Vector2(sw, h - 28.0)
	sheet_body.custom_minimum_size = Vector2(sw - 50, 0)
	var iw := minf(400.0, w - 110.0)
	info_panel.position = Vector2(sbm.x + 24 if lefty else w - iw - sbm.x - 24, tb_h + 10)
	info_body.custom_minimum_size = Vector2(iw - 50, 0)
	var ih := info_body.get_combined_minimum_size().y + 40.0
	info_panel.size = Vector2(iw, clampf(ih, 120.0, minf(avail - 100.0, 640.0)))
	info_body.custom_minimum_size = Vector2(iw - 50, 0)
	var cw := minf(470.0, w - 30.0)
	card_text.custom_minimum_size = Vector2(cw - 40, 0)
	card_panel.size = Vector2(cw, 0)
	card_panel.reset_size()
	var cs := card_panel.get_combined_minimum_size()
	card_panel.size = Vector2(cw, cs.y)
	card_panel.position = Vector2((w - cw) * 0.5, maxf(tb_h + 20, (h - cs.y) * 0.45))
	var mm2 := mode_bar.get_combined_minimum_size()
	mode_bar.position = Vector2((w - mm2.x) * 0.5, tb_h + 74)
	var dm := drive_bar.get_combined_minimum_size()
	drive_bar.position = Vector2((w - dm.x) * 0.5, h - dm.y - 20)
	var fw := minf(460.0, w - 110.0)
	follow_panel.size = Vector2(fw, 0)
	follow_panel.position = Vector2(sbm.x + 24 if lefty else w - fw - sbm.x - 24, tb_h + 10)
	var tm := tut_panel.get_combined_minimum_size()
	tut_panel.position = Vector2((w - tm.x) * 0.5, tb_h + 74)
	var stw := minf(720.0, w - 20.0)
	start_body.custom_minimum_size = Vector2(stw - 50, 0)
	var sh := minf(h - 40.0, start_body.get_combined_minimum_size().y + 36.0)
	start_panel.position = Vector2((w - stw) * 0.5, maxf(20.0, (h - sh) * 0.4))
	start_panel.size = Vector2(stw, sh)
	photo_btn.position = Vector2(vs.x - 260 * ui_scale, 20 * ui_scale)
	photo_btn.scale = Vector2(ui_scale, ui_scale)
	for k in photo_extra.size():
		var pe: Button = photo_extra[k]
		pe.position = Vector2(vs.x - 260 * ui_scale, (90 + 70 * k) * ui_scale)
		pe.scale = Vector2(ui_scale, ui_scale)
func notify(title: String, text: String, icon: String = "trophy") -> void:
	notif_q.append([title, text, icon])
	if not notif_busy:
		notify_next()
func notify_next() -> void:
	if notif_q.is_empty():
		notif_busy = false
		return
	notif_busy = true
	var it: Array = notif_q.pop_front()
	notif_title.text = it[0]
	notif_text.text = it[1]
	if notif_icon != null and ico(it[2]) != null:
		notif_icon.texture = ico(it[2])
	# entre el panel del costado y los botones de arriba; si no entra, abajo de los botones
	var w := ui_root.size.x
	var lefty: bool = opts["lefty"]
	var left := (hud_right.position.x + hud_right.size.x if lefty else hud_col.position.x + hud_col.size.x) + 12.0
	var right := (hud_col.position.x if lefty else hud_right.position.x) - 12.0
	var nw := minf(420.0, right - left)
	var x := left + (right - left - nw) * 0.5
	var ny := 14.0
	if nw < 280.0:
		nw = minf(400.0, w * 0.42)
		x = 14.0 if lefty else w - nw - 14.0
		ny = hud_right.position.y + hud_right.size.y + 10.0
	notif_text.custom_minimum_size = Vector2(nw - 100.0, 0)
	notif_panel.size = Vector2(nw, 0)
	notif_panel.reset_size()
	notif_panel.size.x = nw
	notif_panel.pivot_offset = notif_panel.size * 0.5
	notif_panel.position = Vector2(x, -notif_panel.size.y - 20.0)
	notif_panel.modulate.a = 1.0
	notif_panel.visible = true
	ui_root.move_child(notif_panel, -1)
	var tw := notif_panel.create_tween()
	tw.tween_property(notif_panel, "position:y", ny, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(3.2)
	tw.tween_property(notif_panel, "position:y", -notif_panel.size.y - 20.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		notif_panel.visible = false
		notify_next())
func toast(t: String) -> void:
	toast_label.text = t
	toast_label.visible = true
	toast_label.modulate = Color(1, 1, 1, 1)
	toast_t = 3.2
	# aviso chico, del ancho del texto (como mucho 460): antes era una franja de 700 con letra grande
	var w := ui_root.size.x
	var fnt := toast_label.get_theme_font("font")
	var tw := fnt.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, toast_label.get_theme_font_size("font_size")).x if fnt else 400.0
	var fw := minf(minf(460.0, w - 40.0), tw + 44.0)
	toast_label.size = Vector2(fw, 0)
	toast_label.reset_size()
	toast_label.size.x = fw
	toast_label.position = Vector2((w - fw) * 0.5, ui_root.size.y * 0.7)
func set_cost_hint(t: String) -> void:
	cost_label.text = t
	layout_bottom()
func layout_bottom() -> void:
	var w := ui_root.size.x
	var bw := 240.0
	var lefty: bool = opts["lefty"]
	var bm := bottom_box.get_combined_minimum_size()
	bottom_box.position = Vector2(bw + 28 if lefty else 0, ui_root.size.y - bm.y)
	bottom_box.size = Vector2(w - bw - 28, bm.y)
	layout_side()
	sheet_avail = ui_root.size.y - 14.0 - bm.y - 20.0
	if sheet.visible:
		sheet.size = Vector2(sheet.size.x, minf(sheet.size.y, sheet_avail))
func layout_side() -> void:
	var w := ui_root.size.x
	var h := ui_root.size.y
	var top_y := 14.0 + 84.0 + 18.0
	var avail := h - maxf(bottom_box.get_combined_minimum_size().y, 124.0) - top_y - 10.0
	var n := side_box.get_child_count()
	var rows := maxi(1, int(avail / 102.0))
	side_box.columns = clampi(ceili(float(n) / rows), 1, 3)
	side_box.reset_size()
	var sbm := side_box.get_combined_minimum_size()
	var lefty: bool = opts["lefty"]
	side_box.position = Vector2(12 if lefty else w - sbm.x - 12, top_y)
func add_news(t: String) -> void:
	news.push_front("Día %d: %s" % [day, t])
	if news.size() > 60:
		news.pop_back()
	news_label.text = "📰 " + t
func big_card(title: String, text: String) -> void:
	queue_card({"title": title, "text": text, "btns": [["Bárbaro", Callable()]]})
func marta(text: String) -> void:
	queue_card({"title": "👩‍💼 Marta, tu secretaria", "text": text, "btns": [["Dale", Callable()]]})
func confirm(text: String, yes: Callable) -> void:
	queue_card({"title": "¿Seguro?", "text": text, "btns": [["Sí", yes], ["No", Callable()]]})
func queue_card(c: Dictionary) -> void:
	card_queue.append(c)
	if intro_t >= 0.0:
		return
	if not card_panel.visible:
		next_card()
var card_cur: Dictionary = {}
var card_busy: bool = false
func next_card() -> void:
	card_busy = false
	if card_queue.is_empty():
		card_cur = {}
		card_panel.visible = false
		return
	card_cur = card_queue.pop_front()
	card_title.text = card_cur["title"]
	card_text.text = card_cur["text"]
	clear_box(card_btns)
	var n: int = card_cur["btns"].size()
	for k in n:
		var kk := k
		var cbtn := mk_btn(card_cur["btns"][k][0], func():
			if card_busy:
				return
			card_busy = true
			call_deferred("card_pick", kk), 150)
		cbtn.custom_minimum_size = Vector2(130, 52)
		cbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if k == 0:
			mark_sel(cbtn, true)
		card_btns.add_child(cbtn)
	var was_card := card_panel.visible
	card_panel.visible = true
	layout_ui()
	if not was_card:
		pop_in(card_panel)
func card_pick(k: int) -> void:
	var cb: Callable = Callable()
	if not card_cur.is_empty() and k < card_cur["btns"].size():
		cb = card_cur["btns"][k][1]
	if cb.is_valid():
		cb.call()
	next_card()
func show_decision() -> void:
	if decision == null:
		return
	var d: Array = decision
	var a: Array = d[1]
	var b: Array = d[2]
	queue_card({"title": "🏛 Decisión del intendente", "text": d[0] + "\n\n" + a[0] + ": " + effects_text(a[1]) + "\n" + b[0] + ": " + effects_text(b[1]),
		"btns": [[a[0], func():
			apply_effects(a[1])
			add_news("El intendente decidió: " + a[0])
			decision = null], [b[0], func():
			apply_effects(b[1])
			add_news("El intendente decidió: " + b[0])
			decision = null]]})
func effects_text(e: Dictionary) -> String:
	var parts2: Array = []
	if e.has("money"):
		parts2.append(("+" if e["money"] > 0 else "") + fmt_money(e["money"]))
	if e.has("appr"):
		parts2.append(("más" if e["appr"] > 0 else "menos") + " aprobación")
	if e.has("hp"):
		parts2.append("gente más contenta")
	if e.has("crime"):
		parts2.append("menos crimen")
	if e.has("tour"):
		parts2.append("más turistas")
	if e.has("edu"):
		parts2.append("más educación")
	if e.has("pol"):
		parts2.append("más contaminación")
	if parts2.is_empty():
		return "nada cambia"
	return ", ".join(parts2)
func ask_promise() -> void:
	var btns: Array = []
	for k in PROMISES.size():
		var kk := k
		btns.append([PROMISES[k][0], func(): set_promise(kk)])
	queue_card({"title": "🗳 Se vienen las elecciones", "text": "En 3 días se vota. Elegí una promesa de campaña: si la cumplís, ganás votos. Si no, perdés.", "btns": btns})
func toggle_cat(key: String) -> void:
	if key == "quit":
		show_tray("")
		set_tool({"k": "demolish"})
		return
	if cur_cat == key:
		show_tray("")
	else:
		show_tray(key)
	if tut_on and key == "roads" and tut_step == 0:
		tut_next()
func show_tray(key: String) -> void:
	if key == "quit":
		key = ""
	cur_cat = key
	for k in cat_btns:
		mark_sel(cat_btns[k], k == key)
	clear_box(tray)
	var tp: Control = tray.get_parent().get_parent()
	var was_open := tp.visible
	tp.visible = key != ""
	if key == "":
		layout_bottom()
		return
	var look_b := mk_btn("👆\nMirar", func():
		set_tool({"k": "look"})
		show_tray(""), 96)
	look_b.custom_minimum_size = Vector2(100, 84)
	tray.add_child(look_b)
	var groups: Array = []
	match key:
		"roads":
			for t in range(1, 5):
				var tt := t
				tray.add_child(tool_btn(ROAD_NAMES[t] + "\n" + fmt_money(ROAD_COST[t]), {"k": "road", "t": tt}))
			tray.add_child(tool_btn("Rotonda\n$150", {"k": "round"}))
		"zones":
			for z in range(1, 5):
				var zz := z
				if z == Z_M and not creative and max_stage < 2:
					tray.add_child(lock_btn("Mixta", 2))
					continue
				tray.add_child(tool_btn(ZONE_NAMES[z] + "\n$%d" % ZONE_COST, {"k": "zone", "z": zz}))
			tray.add_child(tool_btn("Quitar zona", {"k": "dezone"}))
		"serv":
			groups = ["serv"]
		"infra":
			tray.add_child(tool_btn("Cables\n$3", {"k": "cable"}))
			tray.add_child(tool_btn("Caños\n$3", {"k": "pipe"}))
			groups = ["util"]
		"work":
			groups = ["tour"]
		"fun":
			tray.add_child(tool_btn("Árboles\n$6", {"k": "trees"}))
			groups = ["park", "wonder"]
		"views":
			var vv := [["", "Normal"], ["power", "Luz"], ["water", "Agua"], ["traffic", "Tránsito"], ["happy", "Felicidad"], ["pollution", "Contaminación"], ["crime", "Crimen"], ["land", "Valor del suelo"], ["fire", "Bomberos"], ["police", "Policía"], ["health", "Salud"], ["edu", "Educación"], ["transit", "Transporte"], ["garbage", "Basura"], ["districts", "Distritos"]]
			for v in vv:
				var vk: String = v[0]
				var b := mk_btn(v[1], func(): set_view(vk), 120)
				b.custom_minimum_size = Vector2(120, 84)
				mark_sel(b, view_mode == vk)
				tray.add_child(b)
	var ids: Array = DEF.keys()
	ids.sort()
	for gname in groups:
		for id in ids:
			var d: Dictionary = DEF[id]
			if d["c"] != gname:
				continue
			if not creative and d["st"] > max_stage:
				tray.add_child(lock_btn(d["n"], d["st"]))
			else:
				tray.add_child(tool_btn(d["n"] + "\n" + fmt_money(d["cost"]), {"k": "def", "id": id}))
	if key == "infra":
		tray.add_child(tool_btn("Bicisenda\n$6", {"k": "bike"}))
		tray.add_child(tool_btn("Vías de tranvía\n$25", {"k": "tram"}))
		tray.add_child(tool_btn("Parada de colectivo\n$60", {"k": "stop", "kind": "bus"}))
		tray.add_child(tool_btn("Parada de tranvía\n$60", {"k": "stop", "kind": "tram"}))
		var lb := mk_btn("🚌\nLíneas", func(): open_transport(), 110)
		lb.custom_minimum_size = Vector2(110, 84)
		tray.add_child(lb)
		for id in ids:
			var d2: Dictionary = DEF[id]
			if d2["c"] != "trans":
				continue
			if not creative and d2["st"] > max_stage:
				tray.add_child(lock_btn(d2["n"], d2["st"]))
			else:
				tray.add_child(tool_btn(d2["n"] + "\n" + fmt_money(d2["cost"]), {"k": "def", "id": id}))
		tray.add_child(tool_btn("Dique\n$40", {"k": "levee"}))
		tray.add_child(tool_btn("Comprar zona\n" + fmt_money(region_price()), {"k": "buy"}))
		tray.add_child(tool_btn("Distritos", {"k": "district"}))
	layout_bottom()
	if not was_open:
		pop_in(tp)
func tool_btn(t: String, tl: Dictionary) -> Button:
	var b := mk_btn(t, func(): set_tool(tl), 120)
	b.custom_minimum_size = Vector2(130, 84)
	mark_sel(b, tool.get("k", "") == tl["k"] and tool.get("id", -1) == tl.get("id", -1) and tool.get("t", -1) == tl.get("t", -1) and tool.get("z", -1) == tl.get("z", -1))
	return b
func lock_btn(n: String, st: int) -> Button:
	var b := mk_btn("🔒 " + n + "\n" + STAGES[st][0], func(): toast(n + " se desbloquea cuando la ciudad sea " + STAGES[st][0] + " (%s vecinos)" % fmt_int(STAGES[st][1])), 120)
	b.custom_minimum_size = Vector2(130, 84)
	b.modulate = Color(1, 1, 1, 0.55)
	return b
func set_tool(t: Dictionary) -> void:
	tool = t
	clear_preview()
	var k: String = t["k"]
	if k != "line" and not line_edit.is_empty():
		line_edit = {}
		mode_bar.visible = false
	var hint := ""
	match k:
		"road":
			hint = "Arrastrá para hacer " + ROAD_NAMES[t["t"]].to_lower() + ". En diagonal también se puede."
		"zone":
			hint = "Tocá una manzana para marcarla entera, o arrastrá un rectángulo."
		"dezone":
			hint = "Arrastrá para quitar zonas."
		"demolish":
			hint = "Arrastrá sobre lo que quieras demoler. Sobre un cerro lo aplana."
		"cable", "pipe", "bike", "tram", "levee":
			hint = "Arrastrá en línea."
		"trees":
			hint = "Arrastrá para plantar árboles."
		"def":
			var d: Dictionary = DEF[t["id"]]
			hint = d["n"] + ": tocá donde lo quieras poner."
			if d.has("need"):
				hint += " Va en la " + ("costa" if d["need"] == "shore" else "arena") + "."
		"round":
			hint = "Tocá un cruce de calles para poner o sacar una rotonda."
		"stop":
			hint = "Tocá una calle para poner la parada."
		"buy":
			hint = "Tocá una zona oscura pegada a la tuya para comprarla."
			view_mode = "districts"
			build_overlay()
		"district":
			hint = "Tocá un barrio para elegir su regla."
			view_mode = "districts"
			build_overlay()
		"look":
			hint = ""
	if k != "buy" and k != "district" and view_mode == "districts" and cur_cat != "views":
		view_mode = ""
		build_overlay()
	hint_label.text = hint
	if cur_cat != "" and cur_cat != "views":
		show_tray(cur_cat)
	if tut_on:
		if tut_step == 2 and k == "zone" and t.get("z", 0) == Z_R:
			tut_next()
func set_view(v: String) -> void:
	view_mode = v
	build_overlay()
	show_tray("views")
func refresh_speed_buttons() -> void:
	var names := ["pause", "play", "play2", "play3"]
	for b in speed_btns:
		set_btn_icon(b, names[clampi(speed, 0, 3)])
		mark_sel(b, speed == 0)
	if tut_on and tut_step == 7 and speed >= 2:
		tut_next()
func take_photo() -> void:
	photo_btn.visible = false
	for pe in photo_extra:
		pe.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	photo_btn.visible = photo_mode
	for pe in photo_extra:
		pe.visible = photo_mode
	var dir := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	var path := "user://foto_%d.png" % Time.get_unix_time_from_system()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir + "/URBANA")
		path = dir + "/URBANA/foto_%d.png" % Time.get_unix_time_from_system()
	var err := img.save_png(path)
	if err != OK and path.begins_with("user://") == false:
		path = "user://foto_%d.png" % Time.get_unix_time_from_system()
		err = img.save_png(path)
	if err == OK:
		sfx("cash")
		toast("Foto guardada: " + path.get_file())
		photo_extra[0].text = "✔ Guardada"
	else:
		toast("No se pudo guardar la foto")
		photo_extra[0].text = "No se pudo"
	await get_tree().create_timer(1.6).timeout
	photo_extra[0].text = "📸 Sacar foto"
func set_photo_mode(on: bool) -> void:
	photo_mode = on
	ui_layer.visible = not on
	photo_btn.visible = on
	for pe in photo_extra:
		pe.visible = on
	for ll in line_labels:
		ll.visible = false
	if on:
		toast("Modo foto: mové la cámara y sacá una captura")
func open_sheet(title: String, key: String) -> VBoxContainer:
	if not started:
		start_panel.visible = false
	info_panel.visible = false
	sheet_name = key
	sheet_title.text = title
	clear_box(sheet_body)
	var was_vis := sheet.visible
	sheet.visible = true
	layout_ui()
	if not was_vis:
		pop_in(sheet)
	return sheet_body
func close_sheet() -> void:
	sheet.visible = false
	sheet_name = ""
	if not started and not start_panel.visible:
		show_start()
func open_menu() -> void:
	var b := open_sheet(city_name, "menu")
	var items := menu_items()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for it in items:
		var bt := mk_btn(it[0], it[1], 0)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(bt)
	b.add_child(grid)
func open_stats() -> void:
	var b := open_sheet("Estadísticas", "stats")
	b.add_child(mk_text("Etapa: %s · Vecinos: %s · Trabajos: %s · Desocupación: %d%%" % [STAGES[stage][0], fmt_int(pop), fmt_int(jobs), int(unemployment * 100)]))
	b.add_child(mk_text("Felicidad: %d%% · Aprobación: %d%% · Turistas por día: %d" % [int(avg_happy * 100), int(approval * 100), tourists]))
	b.add_child(mk_text("Luz: %s de %s (%d%% limpia) · Agua: %s de %s" % [fmt_int(int(power_use)), fmt_int(int(power_sup)), int(green_power * 100), fmt_int(int(water_use)), fmt_int(int(water_sup))]))
	b.add_child(mk_text("Basura: %s por día, se levantan %s" % [fmt_int(int(garb_made)), fmt_int(int(garb_cap))]))
	b.add_child(mk_text("Viaje promedio al trabajo: %.1f cuadras · En bici o transporte: %d%%" % [avg_commute, int(counters.get("green_share", 0.0) * 100)]))
	b.add_child(mk_text("Clases: %d bajas, %d medias, %d altas" % [classes[0], classes[1], classes[2]]))
	var specs := [["pop", "Vecinos", Color(0.4, 0.85, 0.5), true], ["money", "Plata", Color(1.0, 0.85, 0.3), true], ["happy", "Felicidad", Color(0.95, 0.5, 0.7), false], ["appr", "Aprobación", Color(0.45, 0.7, 1.0), false]]
	for s in specs:
		var ch := Chart.new()
		ch.data = history[s[0]]
		ch.title = s[1]
		ch.col = s[2]
		ch.money = s[3]
		ch.custom_minimum_size = Vector2(0, 170)
		b.add_child(ch)
func open_budget() -> void:
	var b := open_sheet("Presupuesto", "budget")
	b.add_child(mk_text("Plata: %s · Deuda: %s · Balance de ayer: %s" % [fmt_money(money), fmt_money(debt), fmt_money(last_net)]))
	var names := ["Residencial", "Comercial", "Industrial"]
	for k in 3:
		var kk := k
		var lab := mk_label("Impuesto %s: %d%%" % [names[k], tax[k]])
		b.add_child(lab)
		b.add_child(mk_slider(0, 25, 1, tax[k], func(v: float):
			tax[kk] = int(v)
			lab.text = "Impuesto %s: %d%%" % [names[kk], int(v)]))
	b.add_child(mk_text("Los impuestos altos ponen triste a la gente. Entre 7% y 11% anda bien."))
	b.add_child(HSeparator.new())
	for k in DEPTS.size():
		var kk := k
		var lab2 := mk_label("%s: %d%%" % [DEPTS[k], budget[k]])
		b.add_child(lab2)
		b.add_child(mk_slider(50, 150, 5, budget[k], func(v: float):
			budget[kk] = int(v)
			lab2.text = "%s: %d%%" % [DEPTS[kk], int(v)]
			sim_dirty = true))
	b.add_child(HSeparator.new())
	b.add_child(mk_label("Cuentas de ayer"))
	for k in last_budget:
		var v: float = last_budget[k]
		if absf(v) < 0.5:
			continue
		b.add_child(mk_label("%s: %s" % [k, fmt_money(v)], 0, Color(0.6, 1, 0.6) if v > 0 else Color(1, 0.6, 0.55)))
	b.add_child(HSeparator.new())
	var r := mk_row()
	r.add_child(mk_btn("Préstamo $5.000", func():
		take_loan(5000)
		open_budget(), 0))
	r.add_child(mk_btn("Préstamo $20.000", func():
		take_loan(20000)
		open_budget(), 0))
	b.add_child(r)
	if debt > 0:
		b.add_child(mk_btn("Pagar $5.000 de deuda", func():
			if money >= 5000:
				money -= 5000
				debt = maxf(0.0, debt - 5000)
				if debt <= 0.0:
					unlock_ach("nodebt")
				open_budget()
			else:
				toast("No alcanza la plata"), 0))
func open_decrees() -> void:
	var b := open_sheet("Decretos", "decrees")
	b.add_child(mk_text("Cada decreto cuesta plata por día y cambia cómo vive la gente."))
	for d in DECREES:
		var id: String = d["id"]
		b.add_child(mk_check("%s (%s/día)" % [d["n"], fmt_money(d["cost"])], has_decree(id), func(on: bool):
			decrees[id] = on
			sim_dirty = true
			if on:
				add_news("Nuevo decreto: " + d["n"])))
		b.add_child(mk_label("   " + d["d"], int(opts["text"]) - 4, Color(1, 1, 1, 0.7)))
func open_mayor() -> void:
	var b := open_sheet("Intendente", "mayor")
	b.add_child(mk_text("Aprobación: %d%%" % int(approval * 100)))
	var pb := ProgressBar.new()
	pb.value = approval * 100
	pb.custom_minimum_size = Vector2(0, 30)
	b.add_child(pb)
	b.add_child(mk_text("Próximas elecciones: día %d" % next_election if (stage >= 2 or day > 60) else "Las elecciones empiezan cuando la ciudad sea Ciudad chica."))
	if promise >= 0:
		b.add_child(mk_text("Tu promesa: " + PROMISES[promise][0]))
	if request != null:
		b.add_child(mk_text("Pedido de los vecinos: %s en %s (hasta el día %d)" % [request["what"], DISTRICT_NAMES[region_of(request["cell"])], request["until"]]))
		b.add_child(mk_btn("Ir a ver", func():
			cam_goal = cell_pos(request["cell"])
			cam_dist_goal = 70.0
			close_sheet(), 0))
	if decision != null:
		b.add_child(mk_btn("Hay una decisión pendiente", func(): show_decision(), 0))
	b.add_child(HSeparator.new())
	b.add_child(mk_text("La aprobación sube con gente feliz, trabajo y plata en caja. La municipalidad y la casa de gobierno también ayudan."))
	b.add_child(mk_btn("🎉 Hacer un festival (" + fmt_money(800.0 + pop * 0.2) + ")", func(): hold_festival(), 0))
func open_trade() -> void:
	var b := open_sheet("Comercio", "trade")
	b.add_child(mk_text("Comida guardada: %d · Productos: %d" % [int(food_stock), int(prod_stock)]))
	b.add_child(mk_text("Precio de la comida: %s · Productos: %s" % [fmt_money(market[0]), fmt_money(market[1])]))
	b.add_child(mk_text("Comercio con el país: " + ("sí (tenés tren, puerto, aeropuerto o autopista)" if trade_ok else "no. Con estación de tren, puerto o aeropuerto vendés lo que sobra.")))
	b.add_child(HSeparator.new())
	for k in neighbors.size():
		var nb: Dictionary = neighbors[k]
		b.add_child(mk_label("%s · relación %d%%" % [nb["n"], int(nb["rel"])]))
	if offer != null:
		var o: Dictionary = offer
		b.add_child(HSeparator.new())
		b.add_child(mk_text("Oferta: %s quiere %d de %s por día durante %d días, a %s cada uno." % [neighbors[o["nb"]]["n"], o["qty"], "comida" if o["kind"] == "food" else "productos", o["days"], fmt_money(o["price"])]))
		var r := mk_row()
		r.add_child(mk_btn("Aceptar", func():
			contracts.append(offer)
			add_news("Firmamos un contrato con " + neighbors[offer["nb"]]["n"])
			offer = null
			sfx("cash")
			open_trade(), 0))
		r.add_child(mk_btn("Rechazar", func():
			offer = null
			open_trade(), 0))
		b.add_child(r)
	if not contracts.is_empty():
		b.add_child(HSeparator.new())
		b.add_child(mk_label("Contratos"))
		for c in contracts:
			var cc: Dictionary = c
			b.add_child(mk_text("%s: %d de %s, quedan %d días" % [neighbors[c["nb"]]["n"], c["qty"], "comida" if c["kind"] == "food" else "productos", c["days"]]))
			b.add_child(mk_btn("Cancelar este contrato", func():
				confirm("Si lo cancelás, %s se enoja un poco. ¿Seguro?" % neighbors[cc["nb"]]["n"], func():
					contracts.erase(cc)
					neighbors[cc["nb"]]["rel"] = maxf(0.0, neighbors[cc["nb"]]["rel"] - 8.0)
					open_trade()), 0))
	b.add_child(mk_text("Las chacras hacen comida y el frigorífico la convierte en productos. La industria también produce."))
func open_transport() -> void:
	var b := open_sheet("Transporte", "transport")
	b.add_child(mk_text("Para una línea: poné paradas (o estaciones), tocá Nueva línea y después tocá las paradas en orden."))
	var r := HFlowContainer.new()
	for k in ["bus", "tram", "metro", "train", "ferry"]:
		var kk: String = k
		r.add_child(mk_btn("Nueva línea de " + LINE_NAMES[k] + " (" + fmt_money(LINE_COST[k]) + ")", func(): start_line(kk), 0))
	b.add_child(r)
	b.add_child(HSeparator.new())
	if lines.is_empty():
		b.add_child(mk_label("Todavía no hay líneas"))
	for ln in lines:
		var row := mk_row()
		var l := mk_label("Línea %d · %s · %d paradas%s" % [ln["num"], LINE_NAMES[ln["kind"]], ln["stops"].size(), " · ¡cortada!" if ln.get("broken", false) else ""], 0, ln["col"].lightened(0.3))
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var lref: Dictionary = ln
		row.add_child(mk_btn("Ver", func():
			if lref["pts"].size() > 0:
				cam_goal = lref["pts"][0]
			close_sheet(), 80))
		row.add_child(mk_btn("Quitar", func():
			lines.erase(lref)
			rebuild_rails()
			sim_dirty = true
			open_transport(), 100))
		b.add_child(row)
func start_line(kind: String) -> void:
	close_sheet()
	line_edit = {"kind": kind, "stops": []}
	tool = {"k": "line"}
	mode_label.text = "Línea de " + LINE_NAMES[kind] + ": tocá las paradas en orden"
	clear_box(mode_btns)
	mode_btns.add_child(mk_btn("Terminar", func():
		finish_line()
		if line_edit.is_empty():
			mode_bar.visible = false, 120))
	mode_btns.add_child(mk_btn("Cancelar", func():
		line_edit = {}
		mode_bar.visible = false
		set_tool({"k": "look"}), 120))
	mode_bar.visible = true
	layout_ui()
func open_districts() -> void:
	var b := open_sheet("Distritos", "districts")
	b.add_child(mk_text("Cada zona del mapa es un barrio. Elegí una regla: Densa (edificios un piso más alto, vecinos algo menos contentos), Verde (industria chica, vecinos más contentos, suelo más caro), Tranquila (menos crimen, menos comercio), 24 horas (más comercio, más crimen, vecinos algo menos contentos)."))
	for r in NREG * NREG:
		if owned[r] == 0 and not creative:
			continue
		var rr := r
		b.add_child(mk_label(DISTRICT_NAMES[r], 0, COL_ACC))
		b.add_child(mk_choice(DISTRICT_RULES, district[r], func(v: int):
			district[rr] = v
			sim_dirty = true
			if view_mode == "districts":
				build_overlay()))
func open_district(r: int) -> void:
	if owned[r] == 0 and not creative:
		toast("Ese barrio todavía no es tuyo")
		return
	var b := open_sheet(DISTRICT_NAMES[r], "district")
	b.add_child(mk_text("Regla del barrio:"))
	for k in DISTRICT_RULES.size():
		var kk := k
		var bt := mk_btn(DISTRICT_RULES[k], func():
			district[r] = kk
			sim_dirty = true
			build_overlay()
			open_district(r), 0)
		if district[r] == k:
			mark_sel(bt, true)
		b.add_child(bt)
func open_goals() -> void:
	var b := open_sheet("Logros y retos", "goals")
	if story and obj_index < OBJECTIVES.size():
		var o: Dictionary = OBJECTIVES[obj_index]
		b.add_child(mk_label("Objetivo de Marta (%d de %d)" % [obj_index + 1, OBJECTIVES.size()], 0, Color(1, 0.9, 0.5)))
		b.add_child(mk_text("%s: %d de %d · premio %s" % [o["t"], int(obj_value(o["k"])), o["v"], fmt_money(o["r"])]))
	if scenario > 0:
		b.add_child(mk_label("Escenario: " + SCENARIOS[scenario]["n"], 0, Color(1, 0.9, 0.5)))
		b.add_child(mk_text(SCENARIOS[scenario]["d"]))
	if daily_ch >= 0:
		var ch: Array = DAILY_CHALLENGES[daily_ch]
		b.add_child(mk_label("Reto del día" + (" ✔" if daily_done else ""), 0, Color(1, 0.9, 0.5)))
		b.add_child(mk_text(ch[0] + " · premio $300"))
	b.add_child(HSeparator.new())
	b.add_child(mk_label("Logros: %d de %d" % [achieved.size(), ACHIEVEMENTS.size()]))
	var grid := GridContainer.new()
	grid.columns = 2
	for a in ACHIEVEMENTS:
		var got := achieved.has(a[0])
		grid.add_child(mk_label(("🏆 " if got else "🔒 ") + a[1], int(opts["text"]) - 2, Color.WHITE if got else Color(1, 1, 1, 0.45)))
	b.add_child(grid)
func open_news() -> void:
	var b := open_sheet("📰 El Diario de " + DISTRICT_NAMES[10], "news")
	if news.is_empty():
		b.add_child(mk_label("Todavía no pasó nada"))
	for n in news:
		b.add_child(mk_text(n))
func open_advisors() -> void:
	var b := open_sheet("Asesores", "advisors")
	b.add_child(mk_text("🧑‍💼 Jefe de gabinete: " + advice()))
	var tips: Array = []
	tips.append("⚡ Energía: " + ("todo bien" if power_frac >= 0.99 else "faltan %d%% de luz" % int((1.0 - power_frac) * 100)))
	tips.append("💧 Agua: " + ("todo bien" if water_frac >= 0.99 else "faltan %d%% de agua" % int((1.0 - water_frac) * 100)))
	tips.append("🚗 Tránsito: " + ("fluido" if avg_commute < 12 else "hay embotellamientos: avenidas, rotondas y transporte ayudan"))
	tips.append("🗑 Basura: " + ("al día" if garb_made <= garb_cap else "se acumula, poné más basureros o un relleno"))
	tips.append("💰 Plata: balance de ayer " + fmt_money(last_net))
	tips.append("🏭 Demanda: casas %d%%, comercio %d%%, industria %d%%" % [int(demand[0] * 100), int(demand[1] * 100), int(demand[2] * 100)])
	for t in tips:
		b.add_child(mk_text(t))
func open_saves() -> void:
	var b := open_sheet("Guardar y cargar", "saves")
	for s in range(1, 4):
		var ss := s
		var inf := save_info(s)
		var row := mk_row()
		var l := mk_label("Partida %d: %s" % [s, inf], 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(l)
		row.add_child(mk_btn("Guardar", func():
			slot = ss
			save_game(ss)
			toast("Guardado en la partida %d" % ss)
			open_saves(), 110))
		if inf != "vacía":
			row.add_child(mk_btn("Cargar", func():
				confirm("¿Cargar la partida %d? Lo que no guardaste se pierde." % ss, func():
					if load_game(ss):
						close_sheet()
						toast("Partida %d cargada" % ss)), 100))
		b.add_child(row)
		if FileAccess.file_exists(slot_path(s, true)):
			b.add_child(mk_btn("   Recuperar la copia de respaldo de la partida %d" % s, func():
				confirm("¿Volver a la copia anterior de la partida %d?" % ss, func():
					if load_game(ss, true):
						close_sheet()
						toast("Copia de respaldo cargada")), 0))
	b.add_child(HSeparator.new())
	b.add_child(mk_text("Código de la ciudad: copialo para pasárselo a alguien o guardarlo."))
	var box := TextEdit.new()
	box.custom_minimum_size = Vector2(0, 120)
	box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	b.add_child(box)
	var r := mk_row()
	r.add_child(mk_btn("Exportar y copiar", func():
		box.text = export_code()
		DisplayServer.clipboard_set(box.text)
		toast("Código copiado"), 0))
	r.add_child(mk_btn("Importar", func():
		var t := box.text.strip_edges()
		if t == "":
			t = DisplayServer.clipboard_get().strip_edges()
		if import_code(t):
			close_sheet()
			toast("Ciudad cargada")
		else:
			toast("Ese código no sirve"), 0))
	b.add_child(r)
func open_options() -> void:
	var b := open_sheet("Opciones", "options")
	b.add_child(mk_label("Gráficos"))
	b.add_child(mk_choice(["Baja (más rápido)", "Media", "Alta"], opts["quality"], func(v: int):
		opts["quality"] = v
		apply_quality()
		save_opts()))
	b.add_child(mk_label("Tamaño de los botones"))
	b.add_child(mk_choice(["Normal", "Grande", "Enorme"], opts["ui_size"], func(v: int):
		opts["ui_size"] = v
		layout_ui()
		save_opts()))
	b.add_child(mk_label("Si el juego se cierra solo, probá apagar estas cosas:"))
	b.add_child(mk_check("Dibujo compatible (OpenGL, para celulares que se cierran; se aplica al reiniciar)", draw_compat() if draw_cfg_kind() != "prueba" else false, func(on: bool):
		if on:
			draw_cfg_write("elegido")
			draw_guard_on = false
		else:
			draw_cfg_remove()))
	b.add_child(mk_check("Sombras", opts["g_shadow"], func(on: bool):
		opts["g_shadow"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_check("Agua con ondas y brillo", opts["g_water"], func(on: bool):
		opts["g_water"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_check("Niebla", opts["g_fog"], func(on: bool):
		opts["g_fog"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_check("Autos y gente", opts["g_dyn"], func(on: bool):
		opts["g_dyn"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_label("Realismo extra (probá cuál anda bien en tu celu):"))
	b.add_child(mk_check("Viento en los árboles", opts["g_wind"], func(on: bool):
		opts["g_wind"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Lluvia y nieve con muchas gotas", opts["g_rain"], func(on: bool):
		opts["g_rain"] = on
		save_opts()))
	b.add_child(mk_check("Sombras de contacto en paredes", opts["g_ao"], func(on: bool):
		opts["g_ao"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Texturas en suelo y paredes", opts["g_detail"], func(on: bool):
		opts["g_detail"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Nubes y sombras de nubes", opts["g_clouds"], func(on: bool):
		opts["g_clouds"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Pasto y flores", opts["g_grass"], func(on: bool):
		opts["g_grass"] = on
		mark_all_dirty()
		save_opts()))
	b.add_child(mk_check("Color de cine y bordes oscuros", opts["g_grade"], func(on: bool):
		opts["g_grade"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Sonido (se aplica al reiniciar)", opts["g_audio"], func(on: bool):
		opts["g_audio"] = on
		save_opts()))
	b.add_child(mk_check("Música (puede cerrar el juego en algunos celulares)", opts["g_music"], func(on: bool):
		opts["g_music"] = on
		if on:
			start_music()
		save_opts()))
	b.add_child(mk_btn("🛟 Modo seguro (apaga todo eso y pone gráficos bajos)", func():
		opts["g_shadow"] = false
		opts["g_water"] = false
		opts["g_fog"] = false
		opts["g_dyn"] = false
		opts["g_rain"] = false
		opts["g_grade"] = false
		opts["g_detail"] = false
		opts["g_clouds"] = false
		opts["g_grass"] = false
		mark_all_dirty()
		opts["g_audio"] = false
		opts["quality"] = 0
		apply_quality()
		save_opts()
		open_options(), 0))
	b.add_child(mk_check("Mostrar FPS", opts["fps"], func(on: bool):
		opts["fps"] = on
		fps_label.visible = on
		save_opts()))
	b.add_child(mk_check("Ahorrar batería (30 FPS cuando no tocás nada)", opts["idle30"], func(on: bool):
		opts["idle30"] = on
		save_opts()))
	b.add_child(mk_label("Música"))
	b.add_child(mk_slider(0, 1, 0.05, opts["music"], func(v: float):
		opts["music"] = v
		apply_volumes()
		save_opts()))
	b.add_child(mk_label("Sonidos"))
	b.add_child(mk_slider(0, 1, 0.05, opts["sfx"], func(v: float):
		opts["sfx"] = v
		apply_volumes()
		save_opts()))
	b.add_child(mk_label("Accesibilidad"))
	var tl := mk_label("Tamaño del texto: %d" % opts["text"])
	b.add_child(tl)
	b.add_child(mk_slider(14, 30, 1, opts["text"], func(v: float):
		opts["text"] = int(v)
		tl.text = "Tamaño del texto: %d" % int(v)
		apply_text_size()
		layout_ui()
		save_opts()))
	b.add_child(mk_check("Colores para daltonismo", opts["colorblind"], func(on: bool):
		opts["colorblind"] = on
		build_overlay()
		save_opts()))
	b.add_child(mk_check("Modo zurdo (botones a la izquierda)", opts["lefty"], func(on: bool):
		opts["lefty"] = on
		layout_ui()
		save_opts()))
	b.add_child(mk_check("Vuelo de cámara al empezar", opts["intro"], func(on: bool):
		opts["intro"] = on
		save_opts()))
	b.add_child(mk_check("Rotondas automáticas en cruces de avenidas", opts["autoround"], func(on: bool):
		opts["autoround"] = on
		save_opts()))
	b.add_child(mk_check("Vibrar al construir", opts["vibrate"], func(on: bool):
		opts["vibrate"] = on
		save_opts()))
	b.add_child(mk_check("Modo tranquilo (sin incendios ni tormentas)", opts["calm"], func(on: bool):
		opts["calm"] = on
		save_opts()))
	b.add_child(mk_btn("Hacer el tutorial paso a paso", func():
		close_sheet()
		start_tutorial(), 0))
	b.add_child(mk_text("Controles: un dedo mueve o dibuja, dos dedos acercan y giran, dos dedos para arriba o abajo inclinan. En la PC: rueda acerca, botón derecho mueve, botón del medio gira, WASD y QE."))
var info_more: bool = false
func show_info(c: int) -> void:
	if c != info_cell:
		info_more = false
	info_cell = c
	close_sheet()
	clear_box(info_body)
	var head := mk_row()
	var title := ""
	var lines_txt: Array = []
	var a := anchor_of(c)
	if bld[c] > 0:
		var d: Dictionary = DEF[bld[c]]
		title = d["n"]
		var act := def_active(a)
		lines_txt.append("Funciona" if act else "No funciona: " + def_problem(a))
		lines_txt.append("Mantenimiento: %s por día" % fmt_money(d["upk"]))
		if d.has("cap"):
			lines_txt.append("Atiende hasta %s personas" % fmt_int(d["cap"]))
		if d.has("pw"):
			lines_txt.append("Energía: %s" % fmt_int(d["pw"]))
		if d.has("wt"):
			lines_txt.append("Agua: %s" % fmt_int(d["wt"]))
		if d.has("gb"):
			lines_txt.append("Levanta %s de basura" % fmt_int(d["gb"]))
		if d.has("job"):
			lines_txt.append("Empleos: %d" % d["job"])
		if d.has("tour"):
			lines_txt.append("Atrae turistas")
		if d.has("dep"):
			lines_txt.append("Presupuesto de %s: %d%%" % [DEPTS[d["dep"]], budget[d["dep"]]])
	elif zone[c] > 0:
		title = ZONE_NAMES[zone[c]] + (" nivel %d" % lvl[c] if lvl[c] > 0 else " (lote vacío)")
		if zone[c] == Z_R or zone[c] == Z_M:
			lines_txt.append("Viven %d personas" % int(occ[anchor_of(c)] if part[c] >= 0 else occ[c]))
			lines_txt.append("Felicidad: %d%%" % int(happy[c] * 100))
			if why[c] > 0:
				lines_txt.append("Lo que más les molesta: " + WHY_TEXT[why[c]])
			lines_txt.append("Educación: " + ["sin estudios", "primaria", "secundaria", "universidad"][clampi(edu[c], 0, 3)])
		else:
			lines_txt.append("Trabajan hasta %d personas" % zone_cap(zone[c], lvl[c]))
		lines_txt.append("Luz: " + ("sí" if powered[c] else "no") + " · Agua: " + ("sí" if watered[c] else "no"))
		lines_txt.append("Valor del suelo: %d%% · Crimen: %d%% · Contaminación: %d%%" % [int(landv[c] * 100), int(crime[c] * 100), int(pollution[c] * 100)])
		if not road_near(c, 2):
			lines_txt.append("⚠ Necesita una calle cerca para crecer")
		if garbp[c] > 0.5:
			lines_txt.append("⚠ Hay basura acumulada")
	elif road[c] > 0:
		title = street_name(c)
		lines_txt.append(ROAD_NAMES[road[c]] + ((" con rotonda") if wire[c] & W_ROUND else ""))
		lines_txt.append("Tránsito: %d%% de lo que aguanta" % int(tload[c] / road_cap(c) * 100))
		if wire[c] & W_BIKE:
			lines_txt.append("Tiene bicisenda")
		if wire[c] & W_TRAM:
			lines_txt.append("Tiene vías de tranvía")
		if stops.has(c):
			lines_txt.append("Parada de " + LINE_NAMES[stops[c]])
	else:
		title = ["Pasto", "Agua", "Arena", "Cerro"][terr[c]]
		if tree[c] > 0:
			lines_txt.append("Árbol: " + ["", "redondo", "plátano", "jacarandá", "pino", "palo borracho", "palmera", "sauce"][tree[c]])
		lines_txt.append("Valor del suelo: %d%%" % int(landv[c] * 100))
		if terr[c] == T_ROCK:
			lines_txt.append("Es un cerro: no se construye encima hasta aplanarlo.")
	lines_txt.append("Barrio: " + DISTRICT_NAMES[region_of(c)] + ("" if is_owned(c) else " (no es tuyo)"))
	if burn[c] > 0.0:
		lines_txt.append("🔥 ¡Se está quemando!")
	var tl := mk_label(title, int(opts["text"]) + 4, Color(1, 0.9, 0.5))
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.add_child(tl)
	head.add_child(mk_btn("✕", func(): info_panel.visible = false, 64))
	info_body.add_child(head)
	var nshow := lines_txt.size() if info_more else mini(lines_txt.size(), 3)
	for k in nshow:
		var tx := mk_label(lines_txt[k], int(opts["text"]) - 2)
		tx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_body.add_child(tx)
	if nshow < lines_txt.size():
		info_body.add_child(mk_btn("Ver más ▾", func():
			info_more = true
			show_info(c), 0))
	if bld[c] > 0 and wonder_progress.has(a):
		var pr: int = wonder_progress[a]
		if pr < WONDER_STEPS:
			info_body.add_child(mk_text("Obra: %d de %d aportes" % [pr, WONDER_STEPS]))
			info_body.add_child(mk_btn("Aportar " + fmt_money(WONDER_FUND), func():
				fund_wonder(a)
				show_info(c), 0))
		else:
			info_body.add_child(mk_text("¡Inaugurada!"))
	var r := mk_row()
	if stops.has(c):
		r.add_child(mk_btn("Quitar parada", func():
			stops.erase(c)
			mark_dirty(c)
			for ln in lines:
				ln["stops"] = ln["stops"].filter(func(s): return s != c)
				route_line(ln)
			sim_dirty = true
			info_panel.visible = false, 0))
	if terr[c] == T_ROCK and is_owned(c):
		r.add_child(mk_btn("Aplanar ($25)", func():
			if money < 25.0 and not creative:
				toast("No alcanza la plata")
				return
			if not creative:
				money -= 25.0
			flatten_cell(c)
			sim_dirty = true
			sfx("demolish")
			info_panel.visible = false, 0))
	if bld[c] > 0 or zone[c] > 0 or road[c] > 0:
		r.add_child(mk_btn("Demoler", func():
			confirm("¿Demoler esto?", func():
				demolish_cell(c)
				mark_dirty(c)
				sim_dirty = true
				sfx("demolish")
				info_panel.visible = false), 0))
	info_body.add_child(r)
	info_panel.visible = true
	layout_ui()
	call_deferred("layout_ui")
func def_problem(a: int) -> String:
	var d: Dictionary = DEF[bld[a]]
	if not road_near(a, d["sz"]):
		return "le falta una calle cerca"
	if wonder_progress.has(a) and wonder_progress[a] < WONDER_STEPS:
		return "la obra no terminó"
	if not powered[a] and not d.has("pw"):
		return "no tiene luz"
	return "revisá luz, agua y calle"
func show_drive_ui(on: bool) -> void:
	drive_bar.visible = on
	show_hud(not on)
	close_sheet()
	info_panel.visible = false
	layout_ui()
func set_drive_street(s: String) -> void:
	drive_label.text = "🚗 " + s
func show_follow_card(pd: Dictionary) -> void:
	var t: String = pd["name"] + ", %d años" % pd["age"]
	if pd["kind"] == 1:
		t = pd["name"] + ", %d años" % (6 + int(pd["age"]) % 10)
	if pd["home"] >= 0:
		t += "\nVive en " + DISTRICT_NAMES[region_of(pd["home"])]
		t += "\nFelicidad: %d%%" % int(happy[pd["home"]] * 100)
		if why[pd["home"]] > 0:
			t += "\nLe molesta: " + WHY_TEXT[why[pd["home"]]]
	if pd["job"] >= 0:
		t += "\nTrabaja en " + ZONE_NAMES[zone[pd["job"]]].to_lower() + " de " + DISTRICT_NAMES[region_of(pd["job"])]
	elif pd["kind"] == 1:
		t += "\nVa a la escuela"
	follow_label.text = "🚶 " + t
	follow_panel.visible = true
	layout_ui()
func hide_follow_card() -> void:
	follow_panel.visible = false
func start_tutorial() -> void:
	tut_on = true
	tut_step = 0
	show_tut()
func show_tut() -> void:
	if tut_step >= TUT_STEPS.size():
		end_tutorial()
		marta("¡Terminaste el tutorial! Ahora la ciudad es tuya.")
		return
	tut_label.text = "Paso %d de %d: %s" % [tut_step + 1, TUT_STEPS.size(), TUT_STEPS[tut_step][0]]
	tut_panel.visible = true
	layout_ui()
func tut_next() -> void:
	tut_step += 1
	sfx("cash")
	show_tut()
func end_tutorial() -> void:
	tut_on = false
	tut_panel.visible = false
	opts["tutorial_done"] = true
	save_opts()
func tut_check() -> void:
	if not tut_on or tut_step >= TUT_STEPS.size():
		return
	var k: String = TUT_STEPS[tut_step][1]
	var ok := false
	match k:
		"roads5":
			ok = obj_value("roads") >= 5
		"zoneR":
			ok = zone_count(Z_R) >= 4
		"power":
			ok = counters.get("power", 0.0) >= 1.0
		"water":
			ok = counters.get("water", 0.0) >= 1.0
		"zoneC":
			ok = zone_count(Z_C) >= 3
	if ok:
		tut_next()
func start_reset(back: bool) -> void:
	started = false
	speed = 1
	clear_box(start_body)
	show_hud(false)
	info_panel.visible = false
	sheet.visible = false
	tut_panel.visible = false
	start_panel.visible = true
	if back:
		var bk := mk_btn("←  Volver", func(): show_start(), 0)
		bk.alignment = HORIZONTAL_ALIGNMENT_LEFT
		start_body.add_child(bk)
func show_start() -> void:
	start_reset(false)
	var t := mk_label("URBANA", 72, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	var st := mk_label("Construí tu ciudad", 0, Color(1, 1, 1, 0.8))
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(st)
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 16)
	start_body.add_child(sp)
	var ls := latest_slot()
	if ls > 0:
		start_body.add_child(mk_main("▶  Continuar\n" + save_info(ls), func():
			if load_game(ls):
				enter_game(false)))
	start_body.add_child(mk_main("✚  Nueva ciudad", func(): show_new_game()))
	start_body.add_child(mk_btn("🧪 Ciudad de prueba (para ver autos, gente y luces)", func():
		new_test_city()
		enter_game(false), 0))
	var r := mk_row()
	var b1 := mk_btn("📂 Mis partidas", func(): show_slots(), 0)
	b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b2 := mk_btn("🔑 Código", func(): show_code(), 0)
	b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b3 := mk_btn("⚙ Opciones", func(): open_options(), 0)
	b3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_child(b1)
	r.add_child(b2)
	r.add_child(b3)
	start_body.add_child(r)
	if draw_note != "":
		var dn := mk_text(draw_note)
		dn.modulate = Color(0.75, 0.9, 1.0)
		start_body.add_child(dn)
	elif prev_crumb != "" and not prev_crumb.contains("cierre limpio"):
		var cl := mk_text("La vez anterior el juego se cerró solo. Último paso anotado:\n" + prev_crumb)
		cl.modulate = Color(1, 0.8, 0.5)
		start_body.add_child(cl)
	layout_ui()
func show_new_game() -> void:
	start_reset(true)
	var t := mk_label("Nueva ciudad", 44, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	start_body.add_child(mk_label("Nombre de tu ciudad"))
	var nm := LineEdit.new()
	nm.text = new_opts["name"]
	nm.max_length = 24
	nm.custom_minimum_size = Vector2(0, 60)
	nm.text_changed.connect(func(t: String): new_opts["name"] = t)
	start_body.add_child(nm)
	start_body.add_child(mk_label("Mapa"))
	start_body.add_child(mk_choice(MAP_KINDS, new_opts["map"], func(v: int): new_opts["map"] = v))
	var names: Array = []
	for s2 in SCENARIOS:
		names.append(s2["n"])
	start_body.add_child(mk_label("Cómo arrancás"))
	var dl := mk_text(SCENARIOS[new_opts["scen"]]["d"])
	dl.modulate = Color(1, 1, 1, 0.75)
	start_body.add_child(mk_choice(names, new_opts["scen"], func(v: int):
		new_opts["scen"] = v
		dl.text = SCENARIOS[v]["d"]))
	start_body.add_child(dl)
	start_body.add_child(mk_check("Modo creativo (plata infinita y todo desbloqueado)", new_opts["creative"], func(on: bool): new_opts["creative"] = on))
	start_body.add_child(mk_check("Marta te va guiando (modo historia)", new_opts["story"], func(on: bool): new_opts["story"] = on))
	start_body.add_child(mk_check("Tutorial paso a paso", new_opts["tut"], func(on: bool): new_opts["tut"] = on))
	start_body.add_child(mk_main("🏙  ¡Empezar!", func():
		var ss := free_slot()
		var go := func():
			new_game(new_opts["map"], new_opts["scen"], new_opts["creative"], new_opts["story"], ss)
			enter_game(true)
			if new_opts["tut"]:
				start_tutorial()
		if FileAccess.file_exists(slot_path(ss)):
			confirm("Tenés las 3 partidas ocupadas. Se reemplaza la más vieja (%s). ¿Seguimos?" % save_info(ss), go)
		else:
			go.call()))
	layout_ui()
func show_slots() -> void:
	start_reset(true)
	var t := mk_label("Mis partidas", 44, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	var any := false
	for s in range(1, 4):
		var ss := s
		var inf := save_info(s)
		if inf == "vacía":
			continue
		any = true
		var row := mk_row()
		var bt := mk_btn("Partida %d\n%s" % [s, inf], func():
			if load_game(ss):
				enter_game(false), 0)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bt.custom_minimum_size = Vector2(0, 76)
		row.add_child(bt)
		row.add_child(mk_btn("🗑", func():
			confirm("¿Borrar la partida %d para siempre?" % ss, func():
				DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(ss)))
				DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(ss, true)))
				show_slots()), 76))
		start_body.add_child(row)
	if not any:
		start_body.add_child(mk_text("Todavía no guardaste ninguna ciudad."))
	layout_ui()
func show_code() -> void:
	start_reset(true)
	var t := mk_label("Cargar con un código", 40, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	start_body.add_child(mk_text("Pegá acá el código de una ciudad que te pasaron."))
	var box := TextEdit.new()
	box.custom_minimum_size = Vector2(0, 160)
	box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	start_body.add_child(box)
	start_body.add_child(mk_btn("📋 Pegar lo copiado", func(): box.text = DisplayServer.clipboard_get().strip_edges(), 0))
	start_body.add_child(mk_main("Cargar la ciudad", func():
		var tx := box.text.strip_edges()
		if tx == "":
			tx = DisplayServer.clipboard_get().strip_edges()
		if import_code(tx):
			enter_game(false)
		else:
			toast("Ese código no sirve")))
	layout_ui()
func enter_game(fresh: bool) -> void:
	start_panel.visible = false
	show_hud(true)
	started = true
	show_tray("")
	set_tool({"k": "look"})
	fps_label.visible = opts["fps"]
	layout_ui()
	if opts["intro"]:
		start_intro(fresh)
	start_music()
	if fresh and story:
		marta(OBJECTIVES[0]["m"])
	refresh_speed_buttons()
var last_tb: float = 0.0
func ui_process(delta: float) -> void:
	fit_sheet()
	fan_process(delta)
	var tbh := hud_col.get_combined_minimum_size().y
	if absf(tbh - last_tb) > 1.0:
		last_tb = tbh
		layout_ui()
	hud_col.visible = started and not photo_mode and not sheet.visible
	if toast_t > 0.0:
		toast_t -= delta
		if toast_t < 0.6:
			toast_label.modulate = Color(1, 1, 1, maxf(toast_t / 0.6, 0.0))
		if toast_t <= 0.0:
			toast_label.visible = false
	if opts["fps"]:
		fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	ui_timer -= delta
	if ui_timer > 0.0 or not started:
		return
	ui_timer = 0.25
	top_money.text = fmt_money(money) + (" (debe " + fmt_money(debt) + ")" if debt > 0 else "")
	top_money.add_theme_color_override("font_color", Color(1, 0.55, 0.5) if money < 0 else Color.WHITE)
	top_rate.text = ("+" if last_net >= 0.0 else "-") + fmt_money(absf(last_net)) + "/min"
	top_rate.add_theme_color_override("font_color", Color(0.55, 0.9, 0.55) if last_net >= 0.0 else Color(1, 0.55, 0.5))
	top_pop.text = fmt_int(pop)
	var hh := int(hour)
	var mi := int((hour - hh) * 60.0) / 10 * 10
	top_clock.text = "%02d:%02d" % [hh, mi]
	top_date.text = "Día %d · %s año %d%s" % [day, SEASONS[season()], year(), " · domingo" if is_sunday() else ""]
	var nxt: int = STAGES[mini(stage + 1, STAGES.size() - 1)][1]
	top_stage.text = "%s · %s / %s hab." % [STAGES[stage][0], fmt_int(pop), fmt_int(nxt)]
	top_stage_bar.value = clampf(float(pop) / maxf(float(nxt), 1.0), 0.0, 1.0)
	top_weather.text = weather + " · Aprobación %d%%" % int(approval * 100)
	top_appr.text = "%d%%" % int(avg_happy * 100)
	var showobj := hud_open and story and obj_index < OBJECTIVES.size()
	obj_card.visible = showobj
	if showobj:
		var oo: Dictionary = OBJECTIVES[obj_index]
		var ov := minf(obj_value(oo["k"]), float(oo["v"]))
		obj_head.text = "OBJETIVO %d/%d" % [obj_index + 1, OBJECTIVES.size()]
		obj_text.text = oo["t"]
		obj_bar.max_value = oo["v"]
		obj_bar.value = ov
		obj_rew.text = "%d / %d    (+%s)" % [int(ov), int(oo["v"]), fmt_money(oo["r"])]
	var letters := ["R", "C", "I"]
	for k in 3:
		var pb: ProgressBar = rci_bars[k][0]
		var pl: Label = rci_bars[k][1]
		pb.value = demand[k] * 100.0
		pl.text = "%s %d%%" % [letters[k], int(demand[k] * 100)]
	if hint_label.text == "" or hint_label.text.begins_with("Tip:"):
		hint_label.text = "Tip: poné calles y después casas pegadas a ellas." if day <= 2 and tool["k"] == "look" else ""
	if tut_on:
		tut_check()
	if not line_edit.is_empty():
		mode_label.text = "Línea de %s: %d paradas" % [LINE_NAMES[line_edit["kind"]], line_edit["stops"].size()]
	overlay_timer -= 0.25
	if view_mode != "" and overlay_timer <= 0.0:
		overlay_timer = 2.0
		build_overlay()
var _ico_cache: Dictionary = {}
var _ico_src: Dictionary = {}
func lf(x: float, y: float, r: float, s: float = 1.0) -> String:
	return '<g transform="translate(%s %s) rotate(%s) scale(%s)"><path d="M0 0C3-8 13-8 15 0C13 8 3 8 0 0Z" fill="#86a95a" stroke="#4d6b34" stroke-width="1.8"/><path d="M2 0H12" stroke="#4d6b34" stroke-width="1.2" fill="none"/></g>' % [x, y, r, s]
func build_ico_src() -> void:
	var G := '<g stroke="#12171d" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round">'
	_ico_src = {
		"roads": '<path d="M19 52L27 12H37L45 52Z" fill="#8f8b86"/><path d="M32 17V23M32 29V35M32 41V47" stroke="#f0c04a" stroke-width="3.2" fill="none"/>' + lf(46, 46, -35) + lf(18, 40, 215, 0.8),
		"zones": '<path d="M10 32L32 13L54 32Z" fill="#c9573f"/><rect x="15" y="32" width="34" height="21" fill="#f0c9a0"/><rect x="28" y="40" width="9" height="13" fill="#9b6a45"/><rect x="19" y="36" width="7" height="7" fill="#9fcbe0"/>' + lf(50, 30, -50, 0.9),
		"serv": '<rect x="7" y="26" width="35" height="19" rx="3" fill="#c9573f"/><path d="M42 30H51L57 38V45H42Z" fill="#e0715a"/><path d="M11 22H36" fill="none"/><circle cx="19" cy="47" r="5.5" fill="#5a3d28"/><circle cx="47" cy="47" r="5.5" fill="#5a3d28"/>' + lf(10, 20, 200, 0.8),
		"infra": '<path d="M37 7L17 36H30L25 57L47 26H34Z" fill="#f0c04a"/>' + lf(46, 50, 35, 0.9),
		"work": '<rect x="9" y="22" width="46" height="30" rx="5" fill="#9b6a45"/><path d="M24 22V15H40V22" fill="none"/><path d="M9 35H55" fill="none"/><rect x="28" y="32" width="8" height="7" rx="2" fill="#f0c04a"/>' + lf(50, 20, -40, 0.8),
		"fun": '<rect x="29" y="36" width="6" height="19" fill="#9b6a45"/><circle cx="32" cy="25" r="17" fill="#86a95a"/><circle cx="25" cy="30" r="3" fill="#e9a1a1" stroke="none"/><circle cx="38" cy="22" r="3" fill="#e9a1a1" stroke="none"/><circle cx="33" cy="32" r="2.4" fill="#f0c04a" stroke="none"/>',
		"quit": '<path d="M17 23H47L44 55H20Z" fill="#a8a39a"/><rect x="13" y="16" width="38" height="7" rx="3" fill="#c9c4ba"/><path d="M27 11H37V16H27Z" fill="#a8a39a"/><path d="M26 29V49M32 29V49M38 29V49" fill="none"/>' + lf(48, 52, -30, 0.8),
		"rotate": '<path d="M46 22A18 18 0 1 0 50 36" fill="none" stroke-width="7"/><path d="M46 22A18 18 0 1 0 50 36" fill="none" stroke="#6fa3c9" stroke-width="3.4"/><path d="M38 12L54 22L40 32Z" fill="#6fa3c9"/>',
		"tilt": '<path d="M13 52V12L52 52Z" fill="#f0c04a"/><path d="M22 43V29L36 43Z" fill="#1f252d"/>' + lf(46, 50, -20, 0.8),
		"zoomin": '<circle cx="27" cy="27" r="16" fill="#cfe6f0"/><path d="M39 39L54 54" stroke-width="7" fill="none"/><path d="M19 27H35M27 19V35" stroke="#56763a" stroke-width="3.6" fill="none"/>',
		"zoomout": '<circle cx="27" cy="27" r="16" fill="#cfe6f0"/><path d="M39 39L54 54" stroke-width="7" fill="none"/><path d="M19 27H35" stroke="#c9573f" stroke-width="3.6" fill="none"/>',
		"eye": '<path d="M5 32C15 15 49 15 59 32C49 49 15 49 5 32Z" fill="#f7f1e2"/><circle cx="32" cy="32" r="10.5" fill="#6fa3c9"/><circle cx="32" cy="32" r="4.5" fill="#5a3d28"/>' + lf(52, 18, -50, 0.8),
		"undo": '<path d="M24 25H39A12 12 0 0 1 39 50H24" fill="none" stroke-width="7"/><path d="M24 25H39A12 12 0 0 1 39 50H24" fill="none" stroke="#e9a1a1" stroke-width="3.4"/><path d="M26 11L10 25L26 39Z" fill="#e9a1a1"/>',
		"pause": '<rect x="16" y="14" width="12" height="36" rx="3" fill="#e9a1a1"/><rect x="36" y="14" width="12" height="36" rx="3" fill="#e9a1a1"/>',
		"play": '<path d="M20 12L54 32L20 52Z" fill="#86a95a"/>',
		"play2": '<path d="M8 14L34 32L8 50Z" fill="#86a95a"/><path d="M30 14L56 32L30 50Z" fill="#86a95a"/>',
		"play3": '<path d="M4 16L23 32L4 48Z" fill="#86a95a"/><path d="M22 16L41 32L22 48Z" fill="#86a95a"/><path d="M40 16L59 32L40 48Z" fill="#86a95a"/>',
		"more": '<circle cx="14" cy="32" r="6" fill="#9b6a45"/><circle cx="32" cy="32" r="6" fill="#9b6a45"/><circle cx="50" cy="32" r="6" fill="#9b6a45"/>',
		"chev_dn": '<path d="M14 24L32 42L50 24" fill="none" stroke-width="8"/><path d="M14 24L32 42L50 24" fill="none" stroke="#86a95a" stroke-width="4"/>',
		"chev_up": '<path d="M14 42L32 24L50 42" fill="none" stroke-width="8"/><path d="M14 42L32 24L50 42" fill="none" stroke="#86a95a" stroke-width="4"/>',
		"people": '<circle cx="32" cy="22" r="10" fill="#e9b88f"/><path d="M12 56C12 36 52 36 52 56Z" fill="#6fa3c9"/>',
		"happy": '<circle cx="32" cy="32" r="22" fill="#f0c04a"/><circle cx="24" cy="26" r="2.6" fill="#5a3d28"/><circle cx="40" cy="26" r="2.6" fill="#5a3d28"/><path d="M21 37C26 47 38 47 43 37" fill="none"/>',
		"clock": '<circle cx="32" cy="32" r="22" fill="#f7f1e2"/><path d="M32 18V32L42 38" fill="none"/>' + lf(48, 12, -60, 0.7),
		"city": '<rect x="8" y="28" width="17" height="27" fill="#cfd8dc"/><rect x="27" y="12" width="17" height="43" fill="#e9b88f"/><rect x="46" y="32" width="11" height="23" fill="#cfd8dc"/><path d="M13 34H20M13 41H20M32 20H39M32 28H39M32 36H39" stroke-width="2.2" fill="none"/>',
		"trophy": '<path d="M20 10H44V26C44 36 38 40 32 40C26 40 20 36 20 26Z" fill="#f0c04a"/><path d="M20 14H10C10 26 14 30 21 30M44 14H54C54 26 50 30 43 30" fill="none"/><path d="M32 40V50M22 54H42" fill="none"/><rect x="24" y="48" width="16" height="6" rx="2" fill="#9b6a45"/>' + lf(46, 46, -30, 0.7),
		"star": '<path d="M32 8L39 25L57 26L43 38L48 56L32 46L16 56L21 38L7 26L25 25Z" fill="#f0c04a"/>',
		"crane": '<rect x="12" y="14" width="9" height="42" fill="#f0c04a"/><path d="M12 14H56V22H12Z" fill="#f0c04a"/><path d="M49 22V37" fill="none"/><rect x="44" y="37" width="10" height="9" fill="#c9573f"/>' + lf(24, 52, -20, 0.8),
	}
	for k in _ico_src:
		_ico_src[k] = G + _ico_src[k] + "</g>"
func ico(n: String) -> ImageTexture:
	if _ico_cache.has(n):
		return _ico_cache[n]
	if _ico_src.is_empty():
		build_ico_src()
	var tex: ImageTexture = null
	if _ico_src.has(n):
		var svg: String = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">' + _ico_src[n] + "</svg>"
		var img := Image.new()
		if img.load_svg_from_string(svg, 2.0) == OK:
			img.generate_mipmaps()
			tex = ImageTexture.create_from_image(img)
	_ico_cache[n] = tex
	return tex
func mk_ico(n: String, s: int) -> Control:
	var tex := ico(n)
	if tex == null:
		return mk_label("•", s)
	var r := TextureRect.new()
	r.texture = tex
	r.custom_minimum_size = Vector2(s, s)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
func set_btn_icon(b: Control, n: String) -> void:
	if b.has_meta("ico"):
		var r = b.get_meta("ico")
		if r is TextureRect:
			r.texture = ico(n)
func add_btn_icon(b: Button, n: String, s: int) -> void:
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var r := mk_ico(n, s)
	cc.add_child(r)
	b.add_child(cc)
	b.set_meta("ico", r)
func menu_items() -> Array:
	return [
		["📊 Estadísticas", func(): open_stats()], ["💰 Presupuesto e impuestos", func(): open_budget()],
		["🏛 Intendente", func(): open_mayor()], ["📜 Decretos", func(): open_decrees()],
		["🤝 Comercio con vecinos", func(): open_trade()], ["🚌 Transporte", func(): open_transport()],
		["🗺 Distritos", func(): open_districts()], ["🏆 Logros y retos", func(): open_goals()],
		["📰 Diario", func(): open_news()], ["💡 Asesores", func(): open_advisors()],
		["🖥 Sala de computación", func(): open_lab()],
		["🎉 Hacer un festival", func(): hold_festival()], ["🚗 Manejar por la ciudad", func():
			close_sheet()
			start_drive()],
		["🚶 Seguir a un vecino", func():
			close_sheet()
			follow_citizen()], ["🎬 Vuelta de cine", func():
			close_sheet()
			start_intro(true)],
		["📷 Modo foto", func():
			close_sheet()
			set_photo_mode(true)], ["💾 Guardar y cargar", func(): open_saves()],
		["⚙ Opciones", func(): open_options()], ["🏠 Volver al inicio", func():
			save_game(slot)
			close_sheet()
			show_start()],
	]
