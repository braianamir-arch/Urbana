#!/usr/bin/env python3
"""Módulos de URBANA Godot.

El código se edita en godot/src/*.gd (un archivo por tema) y se junta en
godot/scripts/main.gd, que es el único script que usa Godot. Así cada tema
queda separado para trabajar, pero en ejecución es un solo script: el mismo
rendimiento que el original.

  godot_modules.py build [--to F]     junta godot/src en godot/scripts/main.gd (o en F)
  godot_modules.py check              sale con 1 si main.gd no coincide con godot/src
  godot_modules.py split <main.gd>    (una sola vez) reparte un script único en godot/src
"""
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "godot" / "src"
OUT = ROOT / "godot" / "scripts" / "main.gd"
SHADER_DIR = ROOT / "godot" / "shaders"

# orden en que se juntan; state va primero porque tiene el 'extends' y lo compartido
ORDER = ["state", "world", "sim", "build", "render", "buildings", "trees", "props", "specials", "camera", "agents", "ui", "audio", "save", "tests", "main"]
ABOUT = {
    "state": "Estado compartido y constantes (lo usan varios módulos)",
    "world": "El mapa: celdas, terreno, generación y utilidades",
    "sim": "Simulación: redes, servicios, felicidad, crecimiento, economía y días",
    "build": "Herramientas de construir, demoler, rotondas, paradas y líneas",
    "render": "Cómo se dibuja la ciudad: mallas, chunks, terreno, agua, luz y clima",
    "buildings": "Edificios de la etapa 2: constructor de mallas, recetas y catálogo",
    "trees": "Árboles de la etapa 2c: recetas por especie y ubicación",
    "props": "Objetos de calle de la etapa 2d: faroles, semáforos, autos, mobiliario, postes y carteles",
    "specials": "Edificios especiales de la etapa 2e: una receta por cada uno",
    "camera": "Cámara, intro y gestos táctiles, mouse y teclado",
    "agents": "Autos, gente, transporte, barcos, aviones, cine, partículas y choques",
    "ui": "Interfaz: HUD, abanico, bandejas, hojas, tarjetas, tutorial e íconos",
    "audio": "Sonidos y música generados",
    "save": "Partidas: nueva, guardar, cargar, códigos y migración",
    "tests": "Modos de prueba (--test=...)",
    "main": "Arranque y bucle principal de Godot",
}
HEADER = ("# ARCHIVO GENERADO: no editar a mano.\n"
          "# Se arma juntando godot/src/*.gd con: python3 tools/godot_modules.py build\n")

# ---------------------------------------------------------------- reparto (solo para split)
MOD = {}


def put(mod, names):
    for n in names.split():
        MOD[n] = mod


put("world", """idx inb cx cz cell_pos world_to_cell region_of is_owned season doy year is_sunday
    has_decree buildable empty_cell anchor_of def_of road_near near_water fmt_money fmt_int rand_name
    street_name count_add alloc_arrays gen_map pick_tree_kind compute_wdist init_neighbors hsh road_n
    vert_h ground_y face_rot zone_cap road_cap def_cells def_center near_road_cell bike_near zone_count
    place_plaza""")
put("sim", """speed_mult sim_process run_sim_stage collect_lists def_active conducts compute_networks stamp
    residents_near compute_coverage compute_env compute_traffic compute_happiness grow_zones level_up
    compute_stats stage_up fire_tick ignite new_day daily_economy daily_production daily_garbage
    daily_tourism daily_events do_flood daily_politics make_request promise_metric set_promise
    run_election apply_effects hold_festival take_loan fund_wonder obj_value check_progress
    pick_daily_challenge check_scenario check_achievements unlock_ach advice""")
put("build", """line_cells rect_cells drag_cells cell_cost commit_drag do_undo apply_cells clear_zone unmerge
    flatten_cell demolish_cell remove_def can_place_def place_def block_fill auto_rounds toggle_round
    place_stop stop_kind_at pick_line_stop ask_buy_region region_price finish_line set_speed vibrate
    route_line reroute_all road_next_to road_path""")
put("render", """setup_render new_mm_node make_corner_mesh make_noise_tex apply_quality apply_fx make_wfx
    config_wfx update_fx build_terrain terrain_color build_outer mark_dirty mark_all_dirty update_chunks
    build_chunk begin_buf em emit_cell emit_road car_color emit_cable tree_colors emit_trees emit_grass
    zone_color emit_lot emit_zone tint tower_col res_wall emit_ind emit_def build_overlay heat
    overlay_color update_light make_faces_mesh make_gable_mesh make_hip_mesh lp bx gable hip bush pine
    parked_car garden emit_house emit_res emit_com clear_preview show_preview flush_mm""")
put("camera", """setup_camera update_camera place_camera start_intro update_intro skip_intro screen_ground
    screen_cell on_touch on_drag pan_screen on_mouse_button on_mouse_motion on_key tap_at""")
put("agents", """setup_agents gl veh_lights max_cars max_peds agents_process rebuild_road_list spawn_agents
    water_dir path_pos curve_at cell_y path_pos_s move_cars move_peds dispatch_from move_svc
    rebuild_rails move_lines move_boats emit_flames move_parts confetti fireworks bocinazo start_drive
    stop_drive pick_drive_next move_drive pick_ped follow_citizen draw_dynamic rand_look new_ped
    draw_person draw_bike draw_moto check_crash draw_crash cinema_cell cine_daily start_movie look_star
    star_step ped_pos move_stars hum draw_stars""")
put("ui", """Chart scroll_at slider_under scroll_input scroll_move scroll_coast_step over_ui sbox sbtn ssel
    make_knob make_theme top_style mk_panel chip mk_label mk_text mk_btn reg_scroll press_fx pop_in
    mk_round mk_ibtn mk_main mark_sel mk_row mk_slider mk_check mk_choice clear_box crumb build_ui
    toggle_hud set_hud_state show_hud fan_layout open_fan close_fan fan_down fan_up fan_process pick_cat
    apply_text_size fit_sheet layout_ui notify notify_next toast set_cost_hint layout_bottom layout_side
    add_news big_card marta confirm queue_card next_card card_pick show_decision effects_text
    ask_promise toggle_cat show_tray tool_btn lock_btn set_tool set_view refresh_speed_buttons
    take_photo set_photo_mode open_sheet close_sheet open_menu open_stats open_budget open_decrees
    open_mayor open_trade open_transport start_line open_districts open_district open_goals open_news
    open_advisors open_saves open_options show_info def_problem show_drive_ui set_drive_street
    show_follow_card hide_follow_card start_tutorial show_tut tut_next end_tutorial tut_check
    start_reset show_start show_new_game show_slots show_code enter_game ui_process lf build_ico_src
    ico mk_ico set_btn_icon add_btn_icon menu_items""")
put("audio", "setup_audio make_sound build_sound sfx start_music music_layer build_music apply_volumes")
put("save", """reset_state new_test_city new_game after_load slot_path b64 unb snapshot save_game save_info
    load_game apply_snapshot export_code import_code migrate_old can_place_old migrate_old_file
    save_opts load_opts latest_slot free_slot""")
put("tests", """shot tap_ctrl tap_step run_ui shot_to run_test test_build test_panels test_save diag run_dale
    find_btn run_menu touch_at drag_to run_scroll run_fx run_city test_house_cell run_roads run_fan
    run_sim""")
put("main", "_notification _ready _process _input _unhandled_input")
SHADERS = {"SHADER_CITY": "city", "SHADER_WATER": "water", "SHADER_TERRAIN": "terrain",
           "SHADER_CLOUD": "cloud", "SHADER_GLOW": "glow", "SHADER_OVERLAY": "overlay"}

TOK = re.compile(r'''
    (?P<tq>"""(?:.|\n)*?""")
  | (?P<str>"(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*')
  | (?P<com>\#[^\n]*)
  | (?P<num>\d[\w.]*)
  | (?P<id>[A-Za-z_]\w*)
  | (?P<nl>\n)
  | (?P<ws>[ \t]+)
  | (?P<op>.)
''', re.X)


def tokenize(src):
    return [(m.lastgroup, m.group(), m.start()) for m in TOK.finditer(src)]


def items_of(src):
    """[(tipo, nombre, texto)] de los elementos de primer nivel, con sus comentarios previos."""
    toks = tokenize(src)
    depth = 0
    starts = []
    for kind, text, pos in toks:
        if kind not in ("ws", "nl") and depth == 0 and (pos == 0 or src[pos - 1] == "\n"):
            starts.append(pos)
        if kind == "op":
            if text in "([{":
                depth += 1
            elif text in ")]}":
                depth -= 1
    starts.append(len(src))
    items, pending = [], ""
    for a, b in zip(starts, starts[1:]):
        chunk = src[a:b]
        if chunk.startswith("#"):
            pending += chunk
            continue
        kind = chunk.split(None, 1)[0]
        if kind in ("func", "var", "const", "class"):
            name = re.match(rf"{kind}\s+(\w+)", chunk).group(1)
        elif kind == "extends":
            name = ""
        else:
            raise SystemExit(f"no entiendo esta línea de primer nivel: {chunk[:60]!r}")
        items.append((kind, name, pending + chunk))
        pending = ""
    if pending:
        items.append(("comment", "", pending))
    return items


def split(orig):
    src = Path(orig).read_text()
    items = items_of(src)
    funcs = {n for k, n, _ in items if k in ("func", "class")}
    missing = sorted(n for n in funcs if n not in MOD)
    if missing:
        raise SystemExit(f"funciones sin módulo asignado: {missing}")
    decls = {n: t for k, n, t in items if k in ("var", "const")}
    # quién usa cada var/const
    users = defaultdict(set)
    for k, n, txt in items:
        if k in ("func", "class") and n != "Chart":
            for kind, t, _ in tokenize(txt):
                if kind == "id" and t in decls:
                    users[t].add(MOD[n])
    files = defaultdict(list)
    SHADER_DIR.mkdir(exist_ok=True)
    for k, n, txt in items:
        if k == "extends":
            files["state"].append(txt)
        elif k in ("func", "class"):
            files[MOD[n]].append(txt)
        elif n in SHADERS:
            body = re.search(r'"""\n?((?:.|\n)*?)"""', txt).group(1)
            (SHADER_DIR / f"{SHADERS[n]}.gdshader").write_text(body)
            lead = txt[: txt.index("const ")]
            files["render"].append(f'{lead}const {n} := preload("res://shaders/{SHADERS[n]}.gdshader")\n')
        else:
            u = users[n]
            files[next(iter(u)) if len(u) == 1 else "state"].append(txt)
    SRC.mkdir(parents=True, exist_ok=True)
    (SRC / ".gdignore").write_text("")
    for m in ORDER:
        body = "".join(files.get(m, []))
        body = re.sub(r"\.code = (SHADER_\w+)\b", r".code = \1.code", body)
        (SRC / f"{m}.gd").write_text(f"# {ABOUT[m]}.\n" + body)
    print("módulos:", {m: len(files.get(m, [])) for m in ORDER})


def build_text():
    parts = []
    for m in ORDER:
        txt = (SRC / f"{m}.gd").read_text()
        if m == "state":
            # el 'extends' tiene que ser la primera línea del script
            ext = re.search(r"(?m)^extends [^\n]*\n", txt)
            if not ext:
                raise SystemExit("src/state.gd tiene que tener la línea 'extends'")
            parts.append(ext.group(0) + HEADER)
            txt = txt[: ext.start()] + txt[ext.end():]
        parts.append(f"# ================================================================ src/{m}.gd\n")
        parts.append(txt if txt.endswith("\n") else txt + "\n")
    return "".join(parts)


def check_init_order(text):
    """Las variables se inicializan en orden: ninguna puede usar otra que esté más abajo."""
    items = items_of(text)
    seen, bad = set(), []
    decl_names = {n for k, n, _ in items if k in ("var", "const")}
    for k, n, txt in items:
        if k == "var" and "=" in txt:
            init = txt.split("=", 1)[1]
            for kind, t, _ in tokenize(init):
                if kind == "id" and t in decl_names and t not in seen and t != n:
                    bad.append(f"{n} usa {t}, que se declara después")
        if k in ("var", "const"):
            seen.add(n)
    return bad


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "split":
        split(sys.argv[2])
    elif cmd in ("build", "check"):
        text = build_text()
        bad = check_init_order(text)
        if bad:
            raise SystemExit("orden de inicialización roto:\n  " + "\n  ".join(bad))
        if cmd == "build":
            dest = Path(sys.argv[sys.argv.index("--to") + 1]) if "--to" in sys.argv else OUT
            dest.write_text(text)
            print(f"main.gd armado ({text.count(chr(10))} líneas)")
        else:
            same = OUT.exists() and OUT.read_text() == text
            print("main.gd al día" if same else "main.gd NO coincide con godot/src (¿se editó a mano?)")
            sys.exit(0 if same else 1)
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main()
