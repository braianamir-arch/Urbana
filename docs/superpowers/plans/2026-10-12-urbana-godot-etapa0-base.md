# URBANA Godot — Etapa 0: base del proyecto · Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Llevar el script único de URBANA Godot a `godot/` en este repo, separado en módulos, sin cambiar cómo se ve ni cómo se juega, con pruebas que lo demuestren.

**Architecture:** Primero se guarda el script tal cual y se graban capturas y números de referencia. Después se separa en pasos: cada tarea mueve un grupo de funciones a su módulo, deja el juego andando y repite las pruebas contra la referencia. El estado compartido vive en un autoload `G`; los módulos se llaman entre sí por `G.<módulo>`.

**Tech Stack:** Godot 4.7 estable (GDScript), Xvfb + Mesa (OpenGL por software) para correrlo acá, Python 3 + Pillow para comparar capturas.

**Spec:** `docs/superpowers/specs/2026-10-12-urbana-godot-etapa0-base-design.md`

## Global Constraints

- Godot **4.7 estable**; `project.godot` con `config/features=PackedStringArray("4.7", "Mobile")` y `rendering/renderer/rendering_method="mobile"`.
- **Solo se mueve código**: ninguna lógica cambia. Únicos cambios permitidos: calificar nombres (`money` → `G.money`, `toast(...)` → `G.ui.toast(...)`), extraer shaders a archivos, y agregar el modo `--test=sim` y la semilla fija en modo prueba.
- Formato de partidas sin cambios: `SAVE_VERSION = 1`, archivos `user://urbana_N.json`, `user://urbana_N.json.bak`, `user://opciones.json`, `user://ultimo_paso.txt`, `user://partida.json` (vieja).
- No se suben claves de firma ni contraseñas (`export_presets.cfg` sin keystore).
- Textos del juego en español rioplatense, como están.
- El binario de Godot y las capturas de cada corrida **no** se suben al repo; sí se suben las capturas y números de **referencia**.

## Review Focus

1. **Partida guardada por el APK actual del autor** → se carga igual con la versión separada (mismo dinero, día, calles, líneas). Prueba en la Task 7.
2. **Código `URB1:` exportado antes de separar** → se importa después y da los mismos números. Prueba en la Task 7.
3. **Primer arranque sin `opciones.json` ni partidas** → muestra la pantalla de inicio sin errores. Prueba en la Task 7.
4. **Partida vieja `user://partida.json`** (formato con `cells`) → se migra al slot 1 como antes. Cubierto por `test_save()` (parte "partida vieja") en `--test=run`, que corre en la Task 7.
5. **La app pasa a segundo plano** (`NOTIFICATION_APPLICATION_PAUSED`) → se guarda la partida y queda "cierre limpio" en `ultimo_paso.txt`. Prueba en la Task 7.

---

## Archivos

| Archivo | Responsabilidad |
|---|---|
| `tools/get_godot.sh` | Baja Godot 4.7 a `tools/.godot/` (ignorado por git) |
| `tools/run_tests.sh` | Corre todos los modos de prueba y guarda la salida en una carpeta |
| `tools/compare.py` | Compara una corrida contra la referencia (números exactos, capturas con tolerancia) |
| `godot/project.godot`, `main.tscn`, `icon.png`, `export_presets.cfg` | Proyecto |
| `godot/scripts/state.gd` | Autoload `G`: estado compartido y referencias a los módulos |
| `godot/scripts/data.gd` | `class_name Data`: constantes |
| `godot/scripts/{world,sim,build,render,agents,camera,ui,audio,save,tests}.gd` | Módulos (ver spec) |
| `godot/scripts/main.gd` | Arranque, `_process`, `_input`, `_unhandled_input`, `_notification` |
| `godot/shaders/*.gdshader` | Los 6 shaders |
| `godot/tests/reference/` | Capturas y números de referencia |
| `godot/LEEME.md` | Cómo abrir y exportar |

---

### Task 1: Herramientas para correr Godot acá

**Files:**
- Create: `tools/get_godot.sh`, `tools/run_tests.sh`, `tools/compare.py`, `.gitignore`

**Interfaces:**
- Produces:
  - `tools/get_godot.sh` → deja el ejecutable en `tools/.godot/godot` (descarga `https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_linux.x86_64.zip`).
  - `tools/run_tests.sh <salida>` → corre, en orden, `--test=sim`, `--test=run`, `--test=ui=<salida>`, `--test=city=<salida>`, `--test=fx=<salida>`, `--test=roads=<salida>` con:
    `xvfb-run -a -s "-screen 0 1280x720x24" tools/.godot/godot --path godot --rendering-method gl_compatibility --rendering-driver opengl3 --fixed-fps 60 --resolution 1280x720 -- --test=<modo>`;
    guarda cada stdout en `<salida>/<modo>.log`. Si `godot/` todavía no existe, termina con error claro.
  - `tools/compare.py <referencia> <corrida>` → sale con código 0 si: `sim.log` tiene las mismas líneas que empiezan con `SIM ` (idénticas), y cada `.png` de la referencia existe en la corrida con **≤ 1,5 %** de píxeles distintos (diferencia por canal > 24). Imprime una línea por captura con el porcentaje. Si falla, guarda `diff_<nombre>.png` en la corrida.
  - `.gitignore`: `tools/.godot/`, `godot/.godot/`, `out/`.

- [ ] **Step 1:** Escribir los tres scripts y el `.gitignore`.
- [ ] **Step 2:** Correr `tools/get_godot.sh` y `tools/.godot/godot --version`. Esperado: empieza con `4.7.stable`.
- [ ] **Step 3:** Probar `compare.py` con dos carpetas armadas a mano: dos PNG iguales → código 0; uno con un rectángulo de 200×200 pintado → código 1 y aparece `diff_*.png`.
- [ ] **Step 4:** Commit: `Herramientas para correr y comparar URBANA Godot`.

### Task 2: Línea de base

**Files:**
- Create: `godot/project.godot`, `godot/main.tscn`, `godot/icon.png` (copia de `icon-512.png`), `godot/scripts/main.gd`, `godot/tests/reference/*`

**Interfaces:**
- Produces: `godot/scripts/main.gd` = el script que pegó el autor, **sin cambios**, más:
  - en `run_test()`, antes de despachar: si es el primer cuadro de prueba, `seed(20261012)`;
  - modo `--test=sim`: `seed(20261012)`, `new_game(4, 0, false, true, 3)`, `enter_game(true)`, `skip_intro()`, `card_queue.clear()`, `test_build()`, después 30 veces (`for s in 8: run_sim_stage(s)` + `new_day()`), e imprime **una línea por día**: `SIM día=%d pop=%d money=%d jobs=%d happy=%.4f power=%.1f/%.1f water=%.1f/%.1f lines=%d stage=%d`, y al final `SIM OK` y `get_tree().quit()`.
  - Nada más cambia. Las pruebas guardan partidas en el `user://` de esta máquina, como ya lo hacían.

- [ ] **Step 1:** Crear `project.godot` (nombre `URBANA`, `run/main_scene="res://main.tscn"`, ícono, orientación `sensor`, renderer `mobile`, `config/features` de Global Constraints) y `main.tscn` con un `Node3D` raíz que usa `res://scripts/main.gd`.
- [ ] **Step 2:** Guardar el script del autor en `godot/scripts/main.gd` y agregar la semilla y el modo `sim`.
- [ ] **Step 3:** Abrir el proyecto una vez para importar: `tools/.godot/godot --headless --path godot --import`. Esperado: termina sin `SCRIPT ERROR`.
- [ ] **Step 4:** `tools/run_tests.sh out/base1` y `tools/run_tests.sh out/base2`. Esperado: cada log termina con su línea de OK (`SIM OK`, `TEST OK`, `UI OK`, `CITY OK`, `FX OK`, `ROADS OK`) y sin `SCRIPT ERROR`.
- [ ] **Step 5:** `python3 tools/compare.py out/base1 out/base2`. Esperado: código 0 (la línea de base es repetible). Si no lo es, ajustar solo la semilla/`--fixed-fps` hasta que lo sea; si una captura sigue variando por algo aleatorio que no depende de la semilla, documentarlo en `godot/tests/reference/NOTAS.md` y subir su tolerancia en `compare.py` solo para ella.
- [ ] **Step 6:** Copiar `out/base1/*.png` y `out/base1/sim.log` a `godot/tests/reference/`.
- [ ] **Step 7:** Commit: `URBANA Godot: script original y referencia de pruebas`.

### Task 3: Estado compartido `G`, constantes y shaders

**Files:**
- Create: `godot/scripts/state.gd`, `godot/scripts/data.gd`, `godot/shaders/{city,water,terrain,cloud,glow,overlay}.gdshader`
- Modify: `godot/project.godot` (autoload `G="*res://scripts/state.gd"`), `godot/scripts/main.gd`

**Interfaces:**
- Produces:
  - `G` (autoload, `extends Node`): **todas** las `var` de estado de juego y mundo del script (desde `terr` hasta `opts`, y `stops`, `lines`, `wonder_progress`, `anchors`, `zone_list`, etc.; todo lo que `snapshot()`/`apply_snapshot()`/`reset_state()` lee o escribe, más los resultados de simulación como `cov`, `powered`, `tload`, `happy`). Más las referencias `var main, world, sim, build, render, agents, camera, ui, audio, save, tests` (null hasta que existan).
  - `Data` (`class_name Data`, `extends RefCounted`): todas las `const` que no son de un solo módulo: `N, CELL, CH, NCH, REG, NREG, WATER_Y, DAY_SECONDS, …, DEF, STAGES, DECREES, DECISIONS, PROMISES, REQUESTS, OBJECTIVES, ACHIEVEMENTS, DAILY_CHALLENGES, MOVIES, SCARY, KILLERS, SHIRTS, PANTS, SKINS, HAIRS, UMBS, COL_*, nombres`.
  - Shaders: el texto de cada `SHADER_*` sin cambios, en su archivo; el código carga con `load("res://shaders/city.gdshader")`.
- Las variables locales de un solo módulo (por ejemplo `_bufs`, `fan_open`, `cars`) se quedan en `main.gd` por ahora; se mueven con su módulo.

- [ ] **Step 1:** Crear `state.gd` y `data.gd`, registrar el autoload y reemplazar en `main.gd` cada uso por `G.x` / `Data.X`.
- [ ] **Step 2:** Pasar los shaders a archivos.
- [ ] **Step 3:** `tools/run_tests.sh out/t3 && python3 tools/compare.py godot/tests/reference out/t3`. Esperado: código 0 y todos los logs con su OK.
- [ ] **Step 4:** Commit: `Estado compartido G, constantes y shaders en archivos`.

### Task 4: Mundo, simulación y construcción

**Files:**
- Create: `godot/scripts/world.gd`, `godot/scripts/sim.gd`, `godot/scripts/build.gd`
- Modify: `godot/scripts/main.gd`

**Interfaces:**
- Consumes: `G`, `Data` (Task 3).
- Produces (cada módulo `extends Node`, lo crea `main.gd` en `_ready` antes que todo y lo guarda en `G.world` / `G.sim` / `G.build`):
  - `world.gd`: `idx, inb, cx, cz, cell_pos, world_to_cell, region_of, is_owned, season, doy, year, is_sunday, has_decree, buildable, empty_cell, anchor_of, def_of, road_near, near_water, fmt_money, fmt_int, rand_name, street_name, count_add, alloc_arrays, gen_map, pick_tree_kind, compute_wdist, init_neighbors, hsh, road_n, vert_h, ground_y, face_rot, zone_cap, road_cap, def_cells, def_center, near_road_cell, bike_near, zone_count, place_plaza`.
  - `sim.gd`: de `speed_mult` a `zone_count` exclusive del script original (`sim_process, run_sim_stage, collect_lists, def_active, conducts, compute_networks, stamp, residents_near, compute_coverage, compute_env, compute_traffic, compute_happiness, grow_zones, level_up, compute_stats, stage_up, fire_tick, ignite, new_day, daily_*, do_flood, make_request, promise_metric, set_promise, run_election, apply_effects, hold_festival, take_loan, fund_wonder, obj_value, check_progress, pick_daily_challenge, check_scenario, check_achievements, unlock_ach, advice`), con sus variables propias (`sim_acc, sim_stage, sim_cycle, comp, env_half, …`).
  - `build.gd`: `line_cells, rect_cells, drag_cells, cell_cost, apply_cells, do_undo, clear_zone, unmerge, flatten_cell, demolish_cell, remove_def, can_place_def, place_def, block_fill, auto_rounds, toggle_round, place_stop, stop_kind_at, pick_line_stop, ask_buy_region, region_price, finish_line, set_speed, vibrate, route_line, reroute_all, road_next_to, road_path` y `undo_rec`.
- Lo que estas funciones llaman y sigue en `main.gd` se llama como `G.main.<función>()`.

- [ ] **Step 1:** Mover las funciones y reemplazar las llamadas en ambos sentidos.
- [ ] **Step 2:** `tools/run_tests.sh out/t4 && python3 tools/compare.py godot/tests/reference out/t4`. Esperado: código 0.
- [ ] **Step 3:** Commit: `Separar mundo, simulación y construcción`.

### Task 5: Render, agentes y cámara

**Files:**
- Create: `godot/scripts/render.gd`, `godot/scripts/agents.gd`, `godot/scripts/camera.gd`
- Modify: `godot/scripts/main.gd`, `world.gd`, `sim.gd`, `build.gd` (cambiar `G.main.x` por el módulo nuevo)

**Interfaces:**
- Consumes: Tasks 3–4.
- Produces (`extends Node3D`, hijos de `main`, creados en el mismo orden que hoy: render → cámara → agentes):
  - `render.gd`: `setup_render` y todo lo que dibuja el mundo: mallas, materiales, `apply_quality, apply_fx, make_wfx, config_wfx, update_fx, build_terrain, terrain_color, build_outer, mark_dirty, mark_all_dirty, update_chunks, build_chunk, begin_buf, em, bx, gable, hip, bush, pine, parked_car, garden, emit_*`, `car_color, tree_colors, zone_color, tint, tower_col, res_wall, build_overlay, heat, overlay_color, update_light, make_*_mesh, make_noise_tex, flush_mm, clear_preview, show_preview`; y `lamps`, `chunk_*`, `_bufs`, `_counts`, nodos de luz y entorno.
  - `agents.gd`: de `setup_agents` a `draw_stars` del original (autos, peatones, servicios, líneas, barcos, aviones, partículas, cine, choques, `draw_*`, `gl`, `veh_lights`, `rebuild_rails`, `rebuild_road_list`, `start_drive/stop_drive/pick_drive_next/move_drive`, `pick_ped`, `follow_citizen`, `confetti`, `fireworks`, `bocinazo`, `dispatch_from`), con sus variables.
  - `camera.gd`: `setup_camera, update_camera, place_camera, start_intro, update_intro, skip_intro, screen_ground, screen_cell, pan_screen, on_touch, on_drag, on_mouse_button, on_mouse_motion, on_key, tap_at` y las variables de cámara y gestos (`cam`, `cam_*`, `touches`, `gesture`, `drag_a/b`, `hover_cell`, `tool`…). `tool` pasa a `G.tool` porque lo usan build, ui y camera.
  - `main.gd` sigue recibiendo `_unhandled_input` y lo reenvía a `G.camera`.

- [ ] **Step 1:** Mover las funciones y reemplazar las llamadas.
- [ ] **Step 2:** `tools/run_tests.sh out/t5 && python3 tools/compare.py godot/tests/reference out/t5`. Esperado: código 0.
- [ ] **Step 3:** Commit: `Separar render, agentes y cámara`.

### Task 6: Interfaz, audio, guardado y pruebas

**Files:**
- Create: `godot/scripts/ui.gd`, `audio.gd`, `save.gd`, `tests.gd`
- Modify: `godot/scripts/main.gd` y los módulos anteriores (cambiar `G.main.x` por el módulo correcto)

**Interfaces:**
- Consumes: Tasks 3–5.
- Produces:
  - `ui.gd` (`extends Node`): desde `Chart` (clase interna) y `COL_BG` hasta `menu_items`, incluidos los íconos SVG (`ico`, `mk_ico`, …), la pantalla de inicio (`show_start`, `show_new_game`, `show_slots`, `show_code`, `enter_game`), el tutorial, `crumb` y `ui_process`.
  - `audio.gd`: de `setup_audio` a `apply_volumes`.
  - `save.gd`: `reset_state, new_test_city, new_game, after_load, slot_path, b64, unb, snapshot, save_game, save_info, load_game, apply_snapshot, export_code, import_code, migrate_old, can_place_old, migrate_old_file, save_opts, load_opts, latest_slot, free_slot`.
  - `tests.gd`: todo lo de `run_test` en adelante (incluido el modo `sim` de la Task 2), `test_build`, `test_panels`, `test_save`, `diag`, `test_house_cell`, `shot`, `shot_to`, `tap_*`, `touch_at`, `drag_to`, `find_btn`.
  - `main.gd` final: `_ready` (crea los módulos en el mismo orden que el original y hace lo mismo que el `_ready` original), `_process`, `_input`, `_unhandled_input`, `_notification`. Ningún módulo usa `G.main` al terminar esta tarea: `grep -n "G.main" godot/scripts/*.gd` no encuentra nada.

- [ ] **Step 1:** Mover las funciones y reemplazar las llamadas.
- [ ] **Step 2:** `grep -n "G\.main" godot/scripts/*.gd`. Esperado: sin resultados.
- [ ] **Step 3:** `tools/run_tests.sh out/t6 && python3 tools/compare.py godot/tests/reference out/t6`. Esperado: código 0.
- [ ] **Step 4:** Commit: `Separar interfaz, audio, guardado y pruebas`.

### Task 7: Compatibilidad, exportación e instrucciones

**Files:**
- Create: `godot/export_presets.cfg`, `godot/LEEME.md`, `tools/compat_test.sh`
- Modify: `godot/scripts/tests.gd` (modos nuevos `compat_save`, `compat_load`, `fresh`, `pause`)

**Interfaces:**
- Consumes: todo lo anterior y el commit de la Task 2 (script original).
- Produces:
  - `--test=compat_save`: con la semilla fija arma la ciudad como `sim`, simula 10 días, `save_game(1)`, imprime `COMPAT money=%d day=%d roads=%d lines=%d pop=%d`, y escribe `export_code()` en `user://compat_code.txt`.
  - `--test=compat_load`: `load_game(1)` e imprime la misma línea `COMPAT …`; después `import_code(<contenido de compat_code.txt>)` e imprime otra línea `COMPAT …`.
  - `--test=fresh`: con `user://` vacío, llega a `show_start()` e imprime `FRESH OK` si `start_panel.visible`.
  - `--test=pause`: arranca una partida, envía `NOTIFICATION_APPLICATION_PAUSED` a `main`, e imprime `PAUSE OK` si `user://urbana_<slot>.json` existe y `user://ultimo_paso.txt` contiene `cierre limpio`.
  - `tools/compat_test.sh`: hace `git worktree` del commit de la Task 2 en `out/orig`, le agrega solo los modos `compat_save` (la versión original no tiene `tests.gd`: se agrega en su `main.gd`), lo corre con un `user://` propio (`XDG_DATA_HOME=out/compat_home`), y después corre `compat_load` de la versión nueva con el mismo `XDG_DATA_HOME`. Termina con código 0 si las tres líneas `COMPAT` son iguales.
  - `export_presets.cfg`: preset `Android`, `runnable=true`, `package/unique_name="ar.urbana.citybuilder"`, `package/name="URBANA"`, arquitectura `arm64-v8a`, renderer Mobile, sin keystore (vacío: el autor usa su debug keystore local).
  - `godot/LEEME.md`: cómo bajar `godot/` (Code → Download ZIP), importar `project.godot` en Godot 4.7, exportar a Android, y que las partidas del APK anterior se mantienen porque `package/unique_name` tiene que ser el mismo que usaba antes (si era otro, cambiarlo en Proyecto → Exportar antes de exportar).

- [ ] **Step 1:** Agregar los cuatro modos en `tests.gd`.
- [ ] **Step 2:** Correr `--test=fresh` y `--test=pause` con `XDG_DATA_HOME` vacío. Esperado: `FRESH OK` y `PAUSE OK`.
- [ ] **Step 3:** Escribir y correr `tools/compat_test.sh`. Esperado: código 0 y tres líneas `COMPAT` iguales.
- [ ] **Step 4:** Escribir `export_presets.cfg` y `LEEME.md`; `tools/.godot/godot --headless --path godot --export-pack Android out/urbana.pck`. Esperado: se genera `out/urbana.pck` sin errores de script (la exportación completa a APK necesita el SDK de Android y queda para el autor).
- [ ] **Step 5:** Última corrida completa: `tools/run_tests.sh out/final && python3 tools/compare.py godot/tests/reference out/final`. Esperado: código 0.
- [ ] **Step 6:** Commit: `Pruebas de compatibilidad, preset de Android e instrucciones`.
