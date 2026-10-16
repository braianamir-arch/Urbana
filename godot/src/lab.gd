# Sala de computación: mide el juego en el celular y arma pedidos de mejora para Claude Code.
const LAB_PARTS := ["simulación", "autos y gente", "bloques de la ciudad", "cámara y luz", "interfaz"]
const LAB_N := 600
var lab_cur := PackedFloat32Array([0, 0, 0, 0, 0])
var lab_prev := PackedFloat32Array([0, 0, 0, 0, 0])
var lab_hist: Array = []
var lab_frames := PackedFloat32Array()
var lab_k: int = 0
var lab_count: int = 0
var lab_stutters: Array = []
var lab_dc: float = 0.0
var lab_obj: float = 0.0
var lab_prim: float = 0.0
var lab_dc_n: int = 0
var lab_since: float = 0.0
var lab_zoom_prev: float = 0.0
var lab_sum: float = 0.0
var lab_st_total: int = 0
# el aviso de cierre se muestra una sola vez por cierre
var lab_crash_seen: bool = false
func lab_reset() -> void:
	# después de "Medir de nuevo" ya no se repite el aviso del cierre anterior
	lab_crash_seen = lab_count > 0
	lab_hist.clear()
	for p in LAB_PARTS.size():
		var a := PackedFloat32Array()
		a.resize(LAB_N)
		lab_hist.append(a)
	lab_frames.resize(LAB_N)
	lab_frames.fill(0.0)
	lab_sum = 0.0
	lab_k = 0
	lab_count = 0
	lab_stutters.clear()
	lab_st_total = 0
	lab_dc = 0.0
	lab_obj = 0.0
	lab_prim = 0.0
	lab_dc_n = 0
	lab_since = 0.0
# suma el tiempo desde t0 (microsegundos) a una parte del cuadro actual
func lab_add(part: int, t0: int) -> void:
	lab_cur[part] += float(Time.get_ticks_usec() - t0) / 1000.0
# al final de cada cuadro: guarda los tiempos y anota los trabones
func lab_frame(delta: float) -> void:
	if lab_hist.is_empty():
		lab_reset()
	var ms := delta * 1000.0
	lab_since += delta
	var avg := lab_avg_frame()
	# el cuadro largo se nota en el delta del cuadro siguiente: la culpa es del trabajo del cuadro anterior
	if lab_count > 30 and ms > 25.0 and ms > avg * 1.5:
		if lab_stutters.size() >= 200:
			lab_stutters.pop_front()
			lab_st_total += 1
		var worst := 0
		for p in LAB_PARTS.size():
			if lab_prev[p] > lab_prev[worst]:
				worst = p
		var zooming := absf(cam_dist - lab_zoom_prev) > 0.5
		lab_stutters.append({"ms": ms, "part": worst, "part_ms": lab_prev[worst], "zoom": zooming, "move": cam_moving_t > 0.0, "dist": cam_dist})
	for p in LAB_PARTS.size():
		lab_hist[p][lab_k] = lab_cur[p]
	lab_sum += ms - lab_frames[lab_k]
	lab_frames[lab_k] = ms
	lab_k = (lab_k + 1) % LAB_N
	lab_count += 1
	for p in LAB_PARTS.size():
		lab_prev[p] = lab_cur[p]
		lab_cur[p] = 0.0
	lab_zoom_prev = cam_dist
	if Engine.get_process_frames() % 30 == 0:
		lab_dc += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		lab_obj += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		lab_prim += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
		lab_dc_n += 1
func lab_n() -> int:
	return mini(lab_count, LAB_N)
func lab_avg_frame() -> float:
	var n := lab_n()
	if n == 0:
		return 16.7
	return lab_sum / n
func lab_avg(p: int) -> float:
	var n := lab_n()
	if n == 0 or lab_hist.is_empty():
		return 0.0
	var s := 0.0
	for k in n:
		s += lab_hist[p][k]
	return s / n
func lab_max(p: int) -> float:
	var m := 0.0
	if lab_hist.is_empty():
		return 0.0
	for k in lab_n():
		m = maxf(m, lab_hist[p][k])
	return m
# fps del 1 % de cuadros más lentos
func lab_low1() -> float:
	var n := lab_n()
	if n < 10:
		return 0.0
	var a := lab_frames.slice(0, n)
	a.sort()
	return 1000.0 / maxf(a[int(n * 0.99)], 0.1)
func lab_report() -> Dictionary:
	var parts := {}
	var cpu := 0.0
	for p in LAB_PARTS.size():
		parts[LAB_PARTS[p]] = [lab_avg(p), lab_max(p)]
		cpu += lab_avg(p)
	var fr := lab_avg_frame()
	var sz := get_viewport().get_visible_rect().size
	var by_part := {}
	var zoomed := 0
	for s in lab_stutters:
		by_part[s["part"]] = by_part.get(s["part"], 0) + 1
		if s["zoom"]:
			zoomed += 1
	return {
		"frame": fr, "fps": 1000.0 / maxf(fr, 0.1), "low1": lab_low1(), "parts": parts, "cpu": cpu,
		"rest": maxf(fr - cpu, 0.0), "stutters": lab_stutters.size() + lab_st_total, "st_part": by_part, "st_zoom": zoomed,
		"dc": lab_dc / maxi(lab_dc_n, 1), "obj": lab_obj / maxi(lab_dc_n, 1), "prim": lab_prim / maxi(lab_dc_n, 1),
		"vram": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		"mem": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"quality": ["Baja", "Media", "Alta"][int(opts["quality"])], "res": "%dx%d" % [int(sz.x), int(sz.y)],
		"model": OS.get_model_name(), "os": OS.get_name(), "secs": lab_since, "frames": lab_n(),
		"pop": pop, "cars": cars.size(), "peds": peds.size(), "crash": prev_crumb != "" and not prev_crumb.contains("cierre limpio") and not lab_crash_seen,
		"crumb": prev_crumb,
	}
func lab_head(r: Dictionary) -> String:
	return "Proyecto URBANA en Godot 4.7 (carpeta godot/, el código se edita en godot/src/*.gd y se arma con python3 tools/godot_modules.py build). Medido con la Sala de computación en mi celular (%s, %s), calidad %s, pantalla %s, ciudad de %d vecinos, %d autos y %d personas en la calle, durante %d s." % [r["model"], r["os"], r["quality"], r["res"], r["pop"], r["cars"], r["peds"], int(r["secs"])]
func lab_parts_text(r: Dictionary) -> String:
	var t := "Cuadro promedio %.1f ms (%.0f fps, el 1 %% más lento a %.0f fps). Por parte, promedio y peor cuadro:" % [r["frame"], r["fps"], r["low1"]]
	for k in r["parts"]:
		t += "\n- %s: %.2f ms (peor %.1f ms)" % [k, r["parts"][k][0], r["parts"][k][1]]
	t += "\n- resto del cuadro (dibujo y espera de la placa de video): %.1f ms" % r["rest"]
	t += "\nDraw calls %.0f, objetos %.0f, triángulos %.0f, memoria de video %.0f MB." % [r["dc"], r["obj"], r["prim"], r["vram"]]
	return t
const LAB_FUNCS := ["sim_process y run_sim_stage en godot/src/sim.gd", "agents_process y draw_dynamic en godot/src/agents.gd", "update_chunks, build_chunk y cat_warm_step en godot/src/render.gd y godot/src/buildings.gd", "update_camera, update_light y update_fx en godot/src/camera.gd y godot/src/render.gd", "ui_process en godot/src/ui.gd"]
# lista de mejoras: [título, explicación corta, pedido para Claude Code]
func lab_suggestions() -> Array:
	var r := lab_report()
	var head := lab_head(r)
	var out: Array = []
	var worst := 0
	for p in LAB_PARTS.size():
		if lab_avg(p) > lab_avg(worst):
			worst = p
	if r["crash"]:
		out.append(["El juego se cerró solo la vez anterior", "Quedó anotado el último paso antes del cierre: \"%s\"." % r["crumb"],
			head + "\n" + lab_parts_text(r) + "\nLa vez anterior el juego se cerró solo, sin cierre limpio. El último paso anotado (función crumb) fue: \"%s\". Buscá qué puede romperse en ese paso en un celular Android, arreglalo y agregá una prueba que lo cubra." % r["crumb"]])
	if r["frame"] > 18.0:
		if r["rest"] > r["cpu"]:
			out.append(["El dibujo es lo que más pesa", "Del cuadro de %.1f ms, %.1f ms son dibujo (%.0f draw calls)." % [r["frame"], r["rest"], r["dc"]],
				head + "\n" + lab_parts_text(r) + "\nEl cuello de botella es el dibujo (placa de video o driver), no el código. Proponé y aplicá cambios para bajar draw calls y costo de píxel en calidad %s sin perder el aspecto: juntar nodos MultiMesh, revisar sombras, distancias de LOD y shaders. Medí antes y después con BENCH frame_ms." % r["quality"]])
		else:
			out.append(["Lo más pesado: " + LAB_PARTS[worst], "Tarda %.1f ms por cuadro en promedio (el cuadro entero %.1f ms)." % [lab_avg(worst), r["frame"]],
				head + "\n" + lab_parts_text(r) + "\nLa parte que más tarda es \"%s\" (%s). Encontrá qué la hace lenta en este celular y optimizala sin cambiar el resultado de la simulación (el log SIM tiene que dar igual). Medí antes y después." % [LAB_PARTS[worst], LAB_FUNCS[worst]]])
	if r["stutters"] >= 3:
		var sp := 0
		for k in r["st_part"]:
			if r["st_part"][k] > r["st_part"].get(sp, 0):
				sp = k
		var extra := " %d de ellos mientras hacías zoom." % r["st_zoom"] if r["st_zoom"] > 0 else ""
		var lst := ""
		for s in lab_stutters.slice(maxi(lab_stutters.size() - 8, 0)):
			lst += "\n- cuadro de %.0f ms, %s tardó %.1f ms%s (cámara a %.0f m)" % [s["ms"], LAB_PARTS[s["part"]], s["part_ms"], ", con zoom" if s["zoom"] else (", moviendo" if s["move"] else ""), s["dist"]]
		out.append(["Trabones: %d cuadros cortados" % r["stutters"], "La mayoría por %s.%s" % [LAB_PARTS[sp], extra],
			head + "\nHubo %d trabones (cuadros de más de 25 ms y 1,5 veces el normal). La parte culpable más seguida es \"%s\" (%s).%s Los últimos:%s\nRepartí ese trabajo en varios cuadros o hacelo antes de que haga falta, para que no se corte el movimiento." % [r["stutters"], LAB_PARTS[sp], LAB_FUNCS[sp], extra, lst]])
	if r["dc"] > 500.0:
		out.append(["Muchas draw calls", "%.0f por cuadro: en celulares conviene menos de 500." % r["dc"],
			head + "\n" + lab_parts_text(r) + "\nEl juego hace %.0f draw calls por cuadro (%.0f objetos). Revisá cuántos nodos MultiMeshInstance3D hay por bloque (bnodes) y cuáles están vacíos o se pueden juntar, sin cambiar cómo se ve." % [r["dc"], r["obj"]]])
	if r["vram"] > 900.0:
		out.append(["Mucha memoria de video", "%.0f MB en uso." % r["vram"],
			head + "\n" + lab_parts_text(r) + "\nLa memoria de video llega a %.0f MB. Buscá texturas o mallas que se puedan achicar o liberar (por ejemplo en calidad Baja o en el modo seguro)." % r["vram"]])
	if out.is_empty() or r["frame"] <= 18.0:
		out.append(["Todo anda fluido", "Cuadro promedio %.1f ms (%.0f fps). No hace falta optimizar ahora." % [r["frame"], r["fps"]],
			head + "\n" + lab_parts_text(r) + "\nEl juego anda fluido. Usá estos números como referencia para la próxima etapa: cualquier cambio tiene que mantener estos tiempos."])
	out.append(["Informe completo", "Todos los números juntos, para pedir una revisión general.",
		head + "\n" + lab_parts_text(r) + "\nTrabones: %d (%d con zoom).\nRevisá estos números y decime qué mejorarías primero para que el juego ande más fluido en este celular." % [r["stutters"], r["st_zoom"]]])
	return out
func lab_all_text() -> String:
	var t := ""
	for s in lab_suggestions():
		t += "## " + s[0] + "\n" + s[2] + "\n\n"
	return t
func lab_copy(t: String) -> void:
	DisplayServer.clipboard_set(t)
	toast("Copiado: pegalo en Claude Code")
func open_lab() -> void:
	var b := open_sheet("🖥 Sala de computación", "lab")
	var room := LabRoom.new()
	room.custom_minimum_size = Vector2(0, 190)
	b.add_child(room)
	var r := lab_report()
	b.add_child(mk_text("Midiendo hace %d s (%d cuadros): %.0f fps de promedio. Para un buen informe usá la ciudad un minuto: moverte, hacer zoom y acelerar el tiempo." % [int(r["secs"]), r["frames"], r["fps"]]))
	var row := mk_row()
	row.add_child(mk_btn("📋 Copiar todo", func(): lab_copy(lab_all_text())))
	row.add_child(mk_btn("🔄 Medir de nuevo", func():
		lab_reset()
		open_lab()))
	b.add_child(row)
	for s in lab_suggestions():
		var card := mk_panel(0.5)
		var col := VBoxContainer.new()
		col.add_child(mk_label(s[0], 0, COL_ACC))
		col.add_child(mk_text(s[1]))
		var txt: String = s[2]
		col.add_child(mk_btn("📋 Copiar pedido", func(): lab_copy(txt)))
		card.add_child(col)
		b.add_child(card)
# la sala dibujada: tres escritorios con su personita y su tarea
class LabRoom extends Control:
	const TASKS := ["mide la simulación", "busca trabones", "cuenta lo que se dibuja"]
	func _process(_d: float) -> void:
		queue_redraw()
	func _draw() -> void:
		var w := size.x
		var h := size.y
		var t := Time.get_ticks_msec() / 1000.0
		draw_rect(Rect2(0, 0, w, h), Color(0.16, 0.18, 0.24))
		draw_rect(Rect2(0, h * 0.72, w, h * 0.28), Color(0.3, 0.24, 0.2))
		# ventana con el cielo de la ciudad
		draw_rect(Rect2(w * 0.04, h * 0.08, w * 0.16, h * 0.34), Color(0.45, 0.62, 0.85))
		draw_rect(Rect2(w * 0.04, h * 0.08, w * 0.16, h * 0.34), Color(0.1, 0.1, 0.12), false, 3.0)
		for k in 3:
			var cx := w * (0.34 + k * 0.24)
			var by := h * 0.72
			# escritorio
			draw_rect(Rect2(cx - 50, by - 8, 100, 8), Color(0.55, 0.4, 0.26))
			draw_rect(Rect2(cx - 46, by, 6, h * 0.2), Color(0.4, 0.29, 0.18))
			draw_rect(Rect2(cx + 40, by, 6, h * 0.2), Color(0.4, 0.29, 0.18))
			# monitor con un gráfico que se mueve
			var mr := Rect2(cx - 30, by - 58, 60, 40)
			draw_rect(mr, Color(0.05, 0.07, 0.1))
			var pts := PackedVector2Array()
			for j in 12:
				var v := sin(t * (1.5 + k) + j * 0.9 + k) * 0.5 + 0.5
				pts.append(Vector2(mr.position.x + 4 + j * 4.7, mr.end.y - 6 - v * 26))
			draw_polyline(pts, [Color(0.4, 1, 0.5), Color(1, 0.8, 0.3), Color(0.5, 0.8, 1)][k], 2.0)
			draw_rect(Rect2(cx - 4, by - 18, 8, 10), Color(0.2, 0.2, 0.22))
			# personita que teclea
			var bob := sin(t * 6.0 + k * 2.0) * 1.5
			var px := cx + 26
			draw_rect(Rect2(px - 9, by - 34 + bob, 18, 26), [Color(0.2, 0.45, 0.8), Color(0.8, 0.3, 0.3), Color(0.3, 0.65, 0.4)][k])
			draw_circle(Vector2(px, by - 42 + bob), 8, Color(0.9, 0.72, 0.58))
			draw_circle(Vector2(px, by - 46 + bob), 6, [Color(0.15, 0.1, 0.05), Color(0.6, 0.35, 0.15), Color(0.1, 0.1, 0.1)][k])
			var hand := sin(t * 14.0 + k) * 2.0
			draw_line(Vector2(px - 6, by - 26 + bob), Vector2(cx + 6, by - 12 + hand), Color(0.9, 0.72, 0.58), 3.0)
			draw_string(ThemeDB.fallback_font, Vector2(cx - w * 0.115, h * 0.97), TASKS[k], HORIZONTAL_ALIGNMENT_CENTER, w * 0.23, 13, Color(1, 1, 1, 0.85))
