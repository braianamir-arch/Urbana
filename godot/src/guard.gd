# Dibujo compatible automático: algunos celulares (por ejemplo un Galaxy S25) cierran el juego dentro del
# driver de Vulkan apenas empieza a dibujar. Al arrancar con Vulkan se deja escrito un archivo que hace que
# el próximo arranque use el dibujo compatible (OpenGL); si el juego anda un minuto o se cierra bien, se
# borra. Así, si el driver lo cierra, la vez siguiente ya arranca con el otro dibujo, sin hacer nada.
# Godot lee el archivo al arrancar (application/config/project_settings_override en project.godot).
const DRAW_CFG := "user://dibujo.cfg"
var draw_guard_on: bool = false
var draw_guard_t: float = 0.0
var draw_note: String = ""
func draw_compat() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"
func draw_cfg_kind() -> String:
	if not FileAccess.file_exists(DRAW_CFG):
		return ""
	var t := FileAccess.get_file_as_string(DRAW_CFG)
	for k in ["prueba", "automatico", "elegido"]:
		if t.contains("; " + k):
			return k
	return "elegido"
func draw_cfg_write(kind: String) -> void:
	var f := FileAccess.open(DRAW_CFG, FileAccess.WRITE)
	if f == null:
		return
	f.store_string("; %s\n[rendering]\n\nrenderer/rendering_method=\"gl_compatibility\"\nrenderer/rendering_method.mobile=\"gl_compatibility\"\n" % kind)
	f.close()
func draw_cfg_remove() -> void:
	if FileAccess.file_exists(DRAW_CFG):
		DirAccess.remove_absolute(DRAW_CFG)
# al arrancar (después de leer el último paso anotado)
func draw_guard_start() -> void:
	if test_mode != "" or not OS.has_feature("android"):
		return
	var crashed := prev_crumb != "" and not prev_crumb.contains("cierre limpio")
	var kind := draw_cfg_kind()
	if draw_compat():
		if kind == "prueba":
			# la vez anterior Vulkan cerró el juego antes del minuto: queda el dibujo compatible
			draw_cfg_write("automatico")
			draw_note = "La vez anterior el juego se cerró mientras dibujaba. Ahora usa el dibujo compatible, que anda en más celulares. Si querés volver al otro: Opciones → Dibujo compatible."
		elif crashed:
			# también se cerró con el dibujo compatible: se apagan las gotas de lluvia (partículas)
			opts["g_rain"] = false
			save_opts()
		return
	if kind != "":
		return
	draw_cfg_write("prueba")
	draw_guard_on = true
	draw_guard_t = 0.0
# cada cuadro: después de un minuto dibujando sin problemas, se borra la prueba
func draw_guard_step(delta: float) -> void:
	if not draw_guard_on:
		return
	draw_guard_t += delta
	if draw_guard_t > 60.0:
		draw_guard_end()
func draw_guard_end() -> void:
	if draw_guard_on and draw_cfg_kind() == "prueba":
		draw_cfg_remove()
	draw_guard_on = false
