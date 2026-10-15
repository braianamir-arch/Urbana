# URBANA Godot — Etapa 1: luz, cielo, terreno y agua · Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cielo con atmósfera física, luz sin tinte azul, terreno con texturas fotográficas mezcladas, agua realista y horizonte con bruma, en el renderer Mobile, sin tocar la simulación.

**Architecture:** Todo el cambio vive en `godot/src/render.gd` y en `godot/shaders/`. Se agrega un álbum de capturas con el renderer Mobile (Vulkan por software) y un verificador de colores (`tools/check_album.py`) que hace de prueba automática de "cómo se ve"; el autor aprueba el álbum final a ojo.

**Tech Stack:** Godot 4.7 (GDScript, shaders `spatial` y `sky`), Mesa lavapipe + Xvfb, Python 3 + Pillow/numpy, texturas CC0 de ambientCG.

**Spec:** `docs/superpowers/specs/2026-10-15-urbana-godot-etapa1-luz-cielo-terreno-agua-design.md`

## Global Constraints

- El código se edita en `godot/src/*.gd`; siempre `python3 tools/godot_modules.py build` antes de probar (`run_tests.sh` lo verifica).
- `--test=sim` tiene que dar líneas `SIM ` **idénticas** a `godot/tests/reference/sim.log` después de cada tarea.
- `tools/compat_test.sh` sigue pasando.
- Presupuesto: costo por cuadro ≤ **+25 % en Alta** y ≤ **+10 % en Baja** contra el álbum "antes"; `build_terrain` ≤ **2×** el tiempo de hoy; el `.pck` exportado crece ≤ **100 MB**.
- Ciclo de día `DAY_SECONDS = 90` y horarios de `update_light()` sin cambios (amanecer 6,25 h, atardecer 20 h).
- Interruptores que siguen funcionando: `g_shadow`, `g_water`, `g_fog`, `g_detail`, `g_clouds`, `g_grade` y el "Modo seguro".
- Texturas solo de ambientCG (CC0); se anotan en `godot/assets/FUENTES.md`.
- Textos visibles en español rioplatense.
- Diferencia con el spec: Media usa las **mismas texturas** que Alta (una sola resolución en el `.pck`, para no duplicar el peso); Media se diferencia por el agua (una capa de olas, sin lluvia).

## Review Focus

1. **Cambio de estación con la ciudad grande** (`build_terrain` + `mark_all_dirty`) → no tiene que congelar el juego; medido en `BENCH terrain_ms` (Task 4).
2. **Calles y edificios sobre cerros** → con el terreno subdividido no pueden quedar flotando ni enterrados; captura `cerros` del álbum + chequeo de alturas en celdas ocupadas (Task 4).
3. **Calidad Baja / Modo seguro** → tiene que verse como hoy de liviano, sin texturas nuevas cargadas; captura `baja` del álbum (Task 7).
4. **Nieve en invierno y lluvia** → el cielo se nubla, el suelo se pone blanco (nieve) y el agua gris con anillos (lluvia); capturas `nieve` y `lluvia` (Tasks 3–5).
5. **Mapas con agua en el borde (río, costa, islas)** → el agua sigue hasta el horizonte sin un borde de pasto; capturas `costa` e `islas` (Task 6).

---

## Archivos

| Archivo | Qué hace |
|---|---|
| `godot/src/tests.gd` | modo `--test=album=<carpeta>` y `BENCH frame_ms` / `terrain_ms` en `run_sim` |
| `tools/album.sh` | corre el álbum con el renderer Mobile |
| `tools/check_album.py` | verifica colores por zona en las capturas del álbum (prueba automática) |
| `tools/get_textures.py` | baja y prepara las texturas de ambientCG |
| `godot/assets/terrain/*`, `godot/assets/water/*`, `godot/assets/FUENTES.md` | texturas y fuentes |
| `godot/shaders/sky.gdshader` | cielo nuevo |
| `godot/shaders/terrain.gdshader`, `water.gdshader` | reescritos |
| `godot/src/render.gd` | `setup_render`, `update_light`, `update_fx`, `apply_quality`, `apply_fx`, `build_terrain`, `build_outer` |

---

### Task 1: Álbum Mobile, verificador y mediciones

**Files:**
- Modify: `godot/src/tests.gd` (agregar `run_album(dir)` y el despacho `album=` en `run_test`; BENCH en `run_sim`)
- Create: `tools/album.sh`, `tools/check_album.py`

**Interfaces:**
- Produces:
  - `--test=album=<dir>`: con `seed(20261012)` y la HUD oculta (`show_hud(false)`, sin tarjetas ni notificaciones), guarda 1280×720 PNG: `amanecer` (hora 6,8), `mediodia` (13), `atardecer` (19,5), `noche` (23), `lluvia` (13, `weather="Lluvia"`), `nieve` (13, `weather="Nieve"`, invierno), `otono` (13, otoño) sobre la ciudad de prueba (`new_test_city()`), cámara `cam_target=(0,0,0)`, `cam_dist_goal=110`, `cam_pitch=0.75`, `cam_yaw=0.5`; y `rio`, `costa`, `islas`, `cerros` con `new_game(kind, 0, true, false, 3)` (kind 0, 2, 3, 1) y la cámara apuntando a la celda de agua más cercana al centro (para `cerros`, a la celda `T_ROCK` más cercana), mediodía. Espera ≥ 90 cuadros antes de cada captura (`update_chunks` y radiancia). Imprime `ALBUM OK`.
    La hora se fija con `day_timer = (h - 6.0) / 24.0 * DAY_SECONDS` y `speed = 0`.
  - `run_sim` imprime además `BENCH terrain_ms=%d` (tiempo de 3 × `build_terrain()`) y, solo con renderer Mobile, `BENCH frame_ms=%.2f` (promedio de 120 cuadros con la cámara fija sobre la ciudad de prueba a mediodía).
  - `tools/album.sh <dir>`: corre `--test=album=<dir>` con `--rendering-method mobile --rendering-driver vulkan` (Xvfb, `--fixed-fps 60`, `--audio-driver Dummy`, `XDG_DATA_HOME` propio); falla si no aparece `ALBUM OK` o hay `SCRIPT ERROR`/`SHADER ERROR`.
  - `tools/check_album.py <dir>`: carga cada PNG y verifica (zona = rectángulo en píxeles; promedios RGB 0–255):
    - `mediodia`: cielo (franja superior de 1280×60, si es visible) o, si no hay cielo, suelo verde: en la zona de pasto `(40..240, 560..700)` **G > B + 10** (sin tinte azul).
    - `mediodia`: brillo medio de toda la imagen entre 70 y 190.
    - `atardecer`: en la imagen completa **R > B + 15** (luz cálida).
    - `noche`: brillo medio **> 18** (se ve la ciudad) y **< 90**.
    - `nieve`: zona de suelo `(40..240, 560..700)` con brillo **> 170**.
    - `rio`/`costa`/`islas`: existe al menos un 2 % de píxeles "agua" (B > R + 20 y G > R) en la mitad inferior.
    Imprime una línea por chequeo (`ok`/`FALLA`) y sale con 1 si alguno falla.
    Las zonas exactas se ajustan mirando el álbum "antes" una vez; quedan escritas como constantes en el script.

- [ ] **Step 1:** Escribir `check_album.py` con los chequeos de arriba.
- [ ] **Step 2:** Escribir el modo `album`, el BENCH y `album.sh`; `python3 tools/godot_modules.py build`; `tools/album.sh out/album_antes`. Esperado: `ALBUM OK` y 11 PNG.
- [ ] **Step 3:** `python3 tools/check_album.py out/album_antes`. Esperado: **FALLA** al menos en `mediodia` (tinte azul: G no supera a B). Es la prueba en rojo de esta etapa. Mirar las capturas y ajustar zonas si una zona cae en un edificio.
- [ ] **Step 4:** Guardar los números "antes": `BENCH frame_ms` (renderer Mobile, 3 corridas, promedio), `terrain_ms` y el tamaño de `--export-pack Android` en `godot/tests/etapa1_antes.txt`. Copiar `out/album_antes/*.png` a `godot/tests/album_antes/`.
- [ ] **Step 5:** `tools/run_tests.sh out/t1 && python3 tools/compare.py godot/tests/reference out/t1` (las capturas viejas siguen iguales: todavía no cambió nada visual). Esperado: código 0.
- [ ] **Step 6:** Commit: `Álbum de capturas con el renderer Mobile y verificador de colores`.

### Task 2: Texturas

**Files:**
- Create: `tools/get_textures.py`, `godot/assets/terrain/`, `godot/assets/water/`, `godot/assets/FUENTES.md`

**Interfaces:**
- Produces (rutas que usan las Tasks 4 y 5):
  - `res://assets/terrain/<mat>_alb.png` (RGB = color, A = rugosidad), 2048² · `res://assets/terrain/<mat>_nrm.png` (normal OpenGL), 1024² — para `mat` ∈ `grass`, `dry`, `dirt`, `rock`, `sand`, `snow`.
  - `res://assets/water/water_nrm.png` (normal tileable 1024², generada) y `res://assets/water/foam.png` (gris 512², generada).
  - Candidatos ambientCG (elegir uno por material mirando las vistas previas, anotar la elección): pasto `Grass004`/`Grass005`/`Grass001`; pasto seco: un `Grass` o `Ground` amarillento (buscar "dry"); tierra `Ground037`/`Ground054`; roca `Rock064`/`Rock063`; arena `Ground080`/`Ground093C`; nieve `Snow015`/`Snow010A`.
  - `get_textures.py` baja `<id>_2K-JPG.zip` de `https://ambientcg.com/get?file=<id>_2K-JPG.zip`, toma `*_Color`, `*_NormalGL`, `*_Roughness`, arma `_alb` (color + rugosidad en alfa) y `_nrm` (reducida a 1024), y genera agua y espuma con ruido periódico (tileable) con semilla fija. Es reproducible.
  - Import: compresión VRAM, mipmaps, `repeat` activado (los `.import` se generan con `--import` y se ajustan `compress/mode=2`, `mipmaps/generate=true`; normales con `compress/normal_map=1`).

- [ ] **Step 1:** Escribir `get_textures.py`; correrlo; revisar visualmente un mosaico 3×3 de cada `_alb` (que se repita sin costuras).
- [ ] **Step 2:** `--import` y `--export-pack Android`. Esperado: el `.pck` crece ≤ 100 MB respecto del número "antes". Si se pasa, bajar `_alb` de roca, arena y nieve a 1024 y repetir (anotar en el ledger).
- [ ] **Step 3:** Escribir `FUENTES.md` (material → id de ambientCG, enlace, licencia CC0).
- [ ] **Step 4:** Commit: `Texturas CC0 de terreno y agua`.

### Task 3: Cielo, luz, nubes y bruma

**Files:**
- Create: `godot/shaders/sky.gdshader`
- Modify: `godot/src/render.gd` (`setup_render`, `update_light`, `update_fx`, `apply_quality`, `apply_fx`), `godot/shaders/city.gdshader` y `terrain.gdshader` solo si `cshadow` cambia de fuente

**Interfaces:**
- Consumes: álbum y verificador (Task 1).
- Produces:
  - `sky.gdshader` (`shader_type sky; render_mode use_half_res_pass;` si no rompe nada) con uniforms: `cover: float` (0..1), `night: float`, `wind_off: vec2`, `cloud_tex: sampler2D` (= `ctex`), `stars: float`. Dispersión Rayleigh + Mie con `LIGHT0_DIRECTION`; nubes con `cloud_tex` proyectada sobre una cúpula; estrellas por hash; disco de luna en la dirección opuesta al sol.
  - `sky_mat` pasa a ser `ShaderMaterial`; `cloud_node` se elimina (y su uso en `update_fx` y `apply_fx`). `cloud_cover` sigue alimentando `cshadow` de ciudad y terreno con los mismos valores que hoy (0,45 / 0,85 / 0,95).
  - `env.tonemap_mode = Environment.TONE_MAPPER_AGX`; `env.sky.process_mode = Sky.PROCESS_MODE_INCREMENTAL`; ambiente desde el cielo con `ambient_light_sky_contribution` y energía ajustadas para que el chequeo "sin tinte azul" pase; `env.fog_aerial_perspective` 0,5–0,8; la luz del sol (`sun.light_color`, energía) sale de la misma función de color que el shader de cielo (escribirla una vez en GDScript, `sun_color_at(elev: float) -> Color`).
  - Se borran las asignaciones a `sky_top_color` y similares de `update_light()`; la hora, el azimut y la elevación del sol se calculan igual que hoy.

- [ ] **Step 1:** Implementar cielo, luz, AgX, bruma y quitar `cloud_node`.
- [ ] **Step 2:** `build`, `tools/album.sh out/a3 && python3 tools/check_album.py out/a3`. Esperado: pasan los chequeos de `mediodia`, `atardecer` y `noche`. Mirar `amanecer`, `atardecer`, `noche`, `lluvia` y `nieve` (cielo coherente, nubes, estrellas, sin bandas raras).
- [ ] **Step 3:** `BENCH frame_ms` en Alta (Mobile). Esperado: ≤ +25 % del "antes".
- [ ] **Step 4:** `tools/run_tests.sh out/t3`; comparar solo números: `grep '^SIM ' out/t3/sim.log | diff - <(grep '^SIM ' godot/tests/reference/sim.log)`. Esperado: sin diferencias. (Las capturas viejas ya no coinciden: se esperan diferencias de imagen hasta que el autor apruebe el álbum.)
- [ ] **Step 5:** Commit: `Cielo con atmósfera física, nubes, luz AgX y bruma`.

### Task 4: Terreno con texturas y relieve suave

**Files:**
- Modify: `godot/src/render.gd` (`build_terrain`, `terrain_color`), `godot/shaders/terrain.gdshader`

**Interfaces:**
- Consumes: texturas (Task 2); `season()`, `weather`, `terr`, `hgt`, `road`, `zone`, `bld`, `tree`, `wire`, `is_owned`, `near_water`, `wdist`.
- Produces:
  - `splat: ImageTexture` (N+1)² RGBA8: R pasto, G arena, B roca, A tierra (suman 1), calculado en `build_terrain` desde las celdas que rodean cada vértice (misma vecindad de 4 celdas que hoy). Reglas: `T_SAND` → arena; `T_ROCK` → roca; pendiente (diferencia de altura con vecinos) > 1,0 → roca; `T_LAND` con `wdist <= 1` y altura < 0,5 → tierra 0,6; resto pasto. Celdas no compradas: se marca en un canal aparte (`owned` en el alfa del color de vértice) para desaturar.
  - Uniforms nuevos en `terrain.gdshader`: `splat`, `alb_grass … alb_snow`, `nrm_grass … nrm_snow`, `season_dry: float`, `snow: float`, `tile_rand: float` (1 en Alta y Media). Escala de textura: 1 repetición cada 6 m. Anti-repetición: celdas de 24 m con rotación y desplazamiento al azar + mezcla en los bordes; variación grande con `dtex` a escala 1/180 m.
  - `season_dry` por estación: Verano 0,25 · Otoño 0,85 · Invierno 0,6 · Primavera 0,0 (con `weather == "Calor"` +0,2).
  - Malla 2×2 por celda: vértices de esquina iguales a hoy; los nuevos interpolan (bicúbico de Catmull-Rom sobre las esquinas). Si alguna de las 4 celdas que tocan un vértice nuevo tiene `road`, `zone`, `bld`, `wire & W_LEVEE` o `tree`, ese vértice usa interpolación lineal (plano como hoy).
  - Calidad Baja (`opts["quality"] == 0`) o `g_detail` apagado: shader y malla de hoy (se conserva el código actual como `build_terrain_simple` y `terrain_simple.gdshader`).
  - `run_sim` sigue imprimiendo `BENCH terrain_ms`.

- [ ] **Step 1:** Prueba de alturas: agregar al modo `album` una verificación `TERRAIN_CHECK`: para toda celda con `road|zone|bld`, la altura de la malla en el centro de la celda (leída del arreglo de vértices de `build_terrain`) difiere de `hgt[i]` en < 0,01. Correrla antes de implementar la subdivisión. Esperado: imprime `TERRAIN_CHECK ok` (hoy la malla es plana por celda en esos casos) — sirve de guardia.
- [ ] **Step 2:** Implementar splat, shader y subdivisión.
- [ ] **Step 3:** `build`, `tools/album.sh out/a4` (incluye `TERRAIN_CHECK ok`) y `check_album.py`. Esperado: pasa todo, incluido `nieve`. Mirar `mediodia`, `otono`, `cerros`, `costa`.
- [ ] **Step 4:** `BENCH terrain_ms` ≤ 2× "antes"; `BENCH frame_ms` ≤ +25 %.
- [ ] **Step 5:** Números `SIM ` idénticos (como en Task 3, Step 4).
- [ ] **Step 6:** Commit: `Terreno con texturas mezcladas, estaciones, nieve y relieve suave`.

### Task 5: Agua

**Files:**
- Modify: `godot/shaders/water.gdshader`, `godot/src/render.gd` (uniforms del agua en `setup_render`, `update_light`, `update_fx`)

**Interfaces:**
- Consumes: `water_nrm.png`, `foam.png` (Task 2); `hmap`, `hinfo` (ya existen); `wind`, `weather`, `night`.
- Produces: uniforms `nrm_tex`, `foam_tex`, `wind_dir: vec2`, `rain: float` (1 con Lluvia/Tormenta), `layers: float` (2 en Alta, 1 en Media). Profundidad `depth = max(-0.45 - gh, 0)` como hoy; `ALPHA = mix(0.55, 1.0, smoothstep(0.0, 1.5, depth))` y `render_mode` con transparencia; color turquesa `vec3(0.16,0.42,0.40)` en la orilla y `vec3(0.03,0.16,0.20)` en lo profundo; Fresnel con potencia 5; `ROUGHNESS` 0,04–0,08; espuma donde `depth < 0.5`, animada con `TIME`; anillos de lluvia procedurales cuando `rain > 0`. `water_simple_mat` sin cambios para `g_water` apagado y calidad Baja.

- [ ] **Step 1:** Implementar.
- [ ] **Step 2:** `album.sh out/a5` + `check_album.py`. Esperado: pasan `rio`, `costa`, `islas`. Mirar `atardecer` (brillo del sol en el agua) y `lluvia`.
- [ ] **Step 3:** `BENCH frame_ms` ≤ +25 %; números `SIM ` idénticos.
- [ ] **Step 4:** Commit: `Agua con olas, transparencia en la orilla, reflejo, espuma y lluvia`.

### Task 6: Horizonte

**Files:**
- Modify: `godot/src/render.gd` (`build_outer`)

**Interfaces:**
- Consumes: material de terreno (Task 4).
- Produces: `build_outer(grass)` arma una sola malla anillo: radio interior = borde del mapa (cuadrado de lado `N*CELL`), exterior = `5 * N * CELL`, 96 segmentos × 12 anillos, altura `ruido(x,z) * 18 * t` con `t` creciendo de 0 en el borde a 1 a mitad del anillo; en los lados con agua en el borde (misma detección de hoy: más de N/3 celdas `T_WATER`) la altura es −3 (bajo el agua). Usa `terrain_mat` con un `splat` constante (pasto 0,8 / roca 0,2) vía uniform `far: float = 1`. Sin sombra (`cast_shadow` apagado).

- [ ] **Step 1:** Implementar.
- [ ] **Step 2:** `album.sh out/a6` + `check_album.py`. Esperado: todo pasa. Mirar `costa`, `islas`, `rio` y `mediodia`: sin bordes rectos ni pasto sobre el agua.
- [ ] **Step 3:** Números `SIM ` idénticos; `BENCH frame_ms` ≤ +25 %.
- [ ] **Step 4:** Commit: `Horizonte con lomas lejanas que se pierden en la bruma`.

### Task 7: Calidades, interruptores, cierre y entrega

**Files:**
- Modify: `godot/src/render.gd` (`apply_quality`, `apply_fx`), `godot/src/tests.gd` (captura `baja` en el álbum), `godot/LEEME.md`, `godot/tests/etapa1_despues.txt`

**Interfaces:**
- Consumes: todo lo anterior.
- Produces: tabla de calidades del spec aplicada: Baja = cielo nuevo sin nubes + terreno y agua simples; Media = texturas, sin segunda capa de olas ni lluvia en el agua; Alta = todo. Captura `baja` (mediodía, calidad 0) en el álbum. `BENCH frame_ms` también en calidad 0.

- [ ] **Step 1:** Implementar y agregar la captura `baja`.
- [ ] **Step 2:** `album.sh out/album_despues` + `check_album.py`. Esperado: todo pasa.
- [ ] **Step 3:** Mediciones finales en `godot/tests/etapa1_despues.txt`: `frame_ms` Alta (≤ +25 %), `frame_ms` Baja (≤ +10 %), `terrain_ms` (≤ 2×), tamaño del `.pck` (≤ +100 MB).
- [ ] **Step 4:** `tools/compat_test.sh` (código 0); números `SIM ` idénticos.
- [ ] **Step 5:** Copiar `out/album_despues` a `godot/tests/album_despues/`; LEEME: sección "Gráficos" (qué cambia en Alta/Media/Baja).
- [ ] **Step 6:** Commit: `Etapa 1: calidades, mediciones y álbum final`.
- [ ] **Step 7 (después de que el autor apruebe el álbum):** pasar `run_tests.sh` y `compat_test.sh` al renderer Mobile, regenerar `godot/tests/reference/` con las capturas nuevas (dos corridas iguales, como en la etapa 0) y commit: `Referencia de pruebas con el renderer Mobile`.
