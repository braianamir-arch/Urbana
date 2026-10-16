# Sonidos y música generados.
const SR := 22050
var sfx_players: Array = []
var sfx_next: int = 0
var sfx_last := {}
var music_players: Array = []
var music_ready: bool = false
func setup_audio() -> void:
	for k in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	if not opts["g_audio"]:
		return
	var lp := [0.0]
	var soft := func(k: float) -> float:
		lp[0] = lp[0] + (randf_range(-1.0, 1.0) - lp[0]) * k
		return lp[0]
	sounds["click"] = make_sound(0.09, func(t: float) -> float:
		return sin(TAU * 520.0 * t) * (1.0 - exp(-t * 900.0)) * exp(-t * 55.0) * 0.45)
	sounds["build"] = make_sound(0.3, func(t: float) -> float:
		return (sin(TAU * 170.0 * t) * 0.5 + soft.call(0.12) * 0.5) * (1.0 - exp(-t * 400.0)) * exp(-t * 14.0) * 0.55)
	sounds["demolish"] = make_sound(0.7, func(t: float) -> float:
		return (soft.call(0.05) * 0.8 + sin(TAU * 62.0 * t) * 0.3) * (1.0 - exp(-t * 60.0)) * exp(-t * 5.0) * 0.5)
	sounds["cash"] = make_sound(0.55, func(t: float) -> float:
		var f := 880.0 if t < 0.12 else 1320.0
		var lt := t if t < 0.12 else t - 0.12
		return sin(TAU * f * t) * (1.0 - exp(-lt * 500.0)) * exp(-lt * 9.0) * 0.3)
	sounds["error"] = make_sound(0.28, func(t: float) -> float:
		return sin(TAU * (210.0 - 60.0 * t) * t) * (1.0 - exp(-t * 300.0)) * exp(-t * 9.0) * 0.35)
	sounds["pop"] = make_sound(0.3, func(t: float) -> float:
		return sin(TAU * (300.0 + 700.0 * t) * t) * (1.0 - exp(-t * 400.0)) * exp(-t * 14.0) * 0.4)
	sounds["hammer"] = make_sound(0.14, func(t: float) -> float:
		return sin(TAU * 300.0 * t) * (1.0 - exp(-t * 800.0)) * exp(-t * 38.0) * 0.4)
	sounds["siren"] = make_sound(1.6, func(t: float) -> float:
		var f := 520.0 + 120.0 * sin(TAU * 0.9 * t)
		return sin(TAU * f * t) * 0.12 * minf(1.0, minf(t * 4.0, (1.6 - t) * 3.0)))
	sounds["horns"] = make_sound(1.4, func(t: float) -> float:
		var v := 0.0
		for k in 3:
			var st := k * 0.35
			if t > st and t < st + 0.28:
				var lt := t - st
				var e := minf(lt * 25.0, 1.0) * minf((0.28 - lt) * 25.0, 1.0)
				v += (sin(TAU * (330.0 + k * 50.0) * t) + sin(TAU * (415.0 + k * 50.0) * t)) * 0.07 * e
		return v)
	# trueno: ruido grave que retumba y se apaga
	sounds["thunder"] = make_sound(2.6, func(t: float) -> float:
		var e := minf(t * 30.0, 1.0) * exp(-t * 1.6) * (0.7 + 0.3 * sin(TAU * 3.0 * t))
		return soft.call(0.03) * e * 2.2)
	sounds["cheer"] = make_sound(1.5, func(t: float) -> float:
		var env2 := sin(PI * t / 1.5)
		return soft.call(0.22) * env2 * 0.5 * (0.75 + 0.25 * sin(TAU * 5.0 * t)))
	apply_volumes()
func make_sound(dur: float, f: Callable) -> Dictionary:
	return {"d": dur, "f": f}
func build_sound(dur: float, f: Callable) -> AudioStreamWAV:
	var n := int(dur * SR)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var v: float = f.call(float(i) / SR)
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 30000.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = SR
	s.stereo = false
	s.data = data
	return s
func sfx(nm: String) -> void:
	if not sounds.has(nm) or opts["sfx"] <= 0.01:
		return
	var now := Time.get_ticks_msec()
	if now - sfx_last.get(nm, -1000) < 120:
		return
	sfx_last[nm] = now
	var p: AudioStreamPlayer = sfx_players[sfx_next]
	sfx_next = (sfx_next + 1) % sfx_players.size()
	if sounds[nm] is Dictionary:
		sounds[nm] = build_sound(sounds[nm]["d"], sounds[nm]["f"])
	p.stream = sounds[nm]
	p.volume_db = linear_to_db(opts["sfx"]) - (8.0 if nm == "click" else 0.0)
	p.play()
const SRM := 11025
func start_music() -> void:
	if not opts["g_audio"] or not opts["g_music"]:
		return
	if not music_ready:
		music_ready = true
		build_music()
	apply_volumes()
func music_layer(dur: float, f: Callable) -> AudioStreamWAV:
	var n := int(dur * SRM)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var v: float = f.call(float(i) / SRM)
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 28000.0))
		if i % 6000 == 5999:
			await get_tree().process_frame
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = SRM
	s.stereo = false
	s.data = data
	s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	s.loop_begin = 0
	s.loop_end = n
	return s
func build_music() -> void:
	var chords := [[220.0, 277.18, 329.63], [196.0, 246.94, 293.66], [174.61, 220.0, 261.63], [196.0, 246.94, 329.63]]
	var bar := 2.0
	var dur := bar * 4.0
	var layers: Array = []
	layers.append(await music_layer(dur, func(t: float) -> float:
		var c: Array = chords[int(t / bar) % 4]
		var lt := fmod(t, bar)
		var e := minf(lt * 3.0, 1.0) * minf((bar - lt) * 3.0, 1.0)
		var v := 0.0
		for f in c:
			v += sin(TAU * f * t) * 0.14
		return v * e))
	layers.append(await music_layer(dur, func(t: float) -> float:
		var c: Array = chords[int(t / bar) % 4]
		var lt := fmod(t, 0.5)
		return sin(TAU * c[0] * 0.5 * t) * 0.35 * exp(-lt * 4.0)))
	layers.append(await music_layer(dur, func(t: float) -> float:
		var lt := fmod(t, 0.5)
		var lt2 := fmod(t + 0.25, 0.5)
		return sin(TAU * 60.0 * lt) * exp(-lt * 25.0) * 0.5 + sin(TAU * 3100.0 * t) * exp(-lt2 * 60.0) * 0.1))
	for s in layers:
		var p := AudioStreamPlayer.new()
		p.stream = s
		add_child(p)
		music_players.append(p)
	apply_volumes()
	for p in music_players:
		p.play()
func apply_volumes() -> void:
	var m: float = opts["music"]
	for k in music_players.size():
		var p: AudioStreamPlayer = music_players[k]
		var on := m > 0.01 and (k == 0 or (k == 1 and max_stage >= 2) or (k == 2 and max_stage >= 4))
		p.volume_db = linear_to_db(maxf(m * 0.55, 0.0001)) if on else -80.0
