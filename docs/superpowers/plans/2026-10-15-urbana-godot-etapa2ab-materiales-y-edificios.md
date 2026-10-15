# URBANA Godot — Etapa 2a+2b: materiales reales y edificios con volumen · Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar las cajas de las zonas (residencial, comercial, industrial, mixta) por un catálogo de ~40 modelos generados por código con volumen real, tres versiones por distancia y materiales fotográficos, y texturizar calles y veredas, sin tocar la simulación.

**Architecture:** Módulo nuevo `godot/src/buildings.gd` (constructor de mallas + recetas + catálogo con caché). `build_chunk` junta, por bloque, una lista de instancias por (modelo, pisos) y las vuelca en `MultiMeshInstance3D` por versión (cerca/media/lejos) con `visibility_range`. Shader nuevo `building.gdshader` con dos `Texture2DArray` (color+rugosidad y normales) de ambientCG; `city.gdshader` usa las capas de asfalto y vereda.

**Tech Stack:** Godot 4.7 (GDScript, `ArrayMesh`, `MultiMesh`, `Texture2DArray`, shaders `spatial`), Mesa lavapipe + Xvfb, Python 3 + Pillow/numpy, ambientCG (CC0).

**Spec:** `docs/superpowers/specs/2026-10-15-urbana-godot-etapa2ab-materiales-y-edificios-design.md`

## Global Constraints

- El código se edita en `godot/src/*.gd`; siempre `python3 tools/godot_modules.py build` antes de probar.
- `--test=sim`: líneas `SIM ` **idénticas** a `godot/tests/reference/sim.log` después de cada tarea. El código de dibujo **nunca** llama a `randi`/`randf` (solo `hsh`).
- `tools/compat_test.sh` sigue pasando.
- Presupuestos contra la medición "antes" de la Task 1 (misma máquina, renderer Mobile): cuadro **≤ +25 % en Alta**, **Baja ≤ +0 %**; `BENCH chunks_ms` **≤ 1,5×**; `BENCH catalog_ms` (catálogo completo, headless) **≤ 2000**; `.pck` Android **≤ +40 MB**.
- Escala del juego (no cambia): celda `CELL = 4.0`; lote `w = CELL * 0.82` (2×2: `CELL * 1.85`); apoyo en `y = p.y + 0.1`; frente del modelo hacia **+Z** (con `rot = face_rot(i)`). Piso tipo `FLOOR_H = 1.3`; puerta 0,95 de alto.
- Alturas por nivel (incluye techo y tanque, sin antenas): Res 1 `[2.0, 7.0]`, Res 2 `[3.5, 9.0]`, Res 3 `[7.0, 13.0]`, Res 4 `[14.0, 40.0]`; Com 1 `[2.0, 7.0]`, Com 2 `[3.5, 9.0]`, Com 3 `[7.0, 20.0]`, Com 4 `[14.0, 45.0]`; Ind 1 `[2.0, 7.0]`, Ind 2 `[3.0, 9.0]`, Ind 3 `[3.0, 12.0]`, Ind 4 `[5.0, 14.0]`. Pisos: Res 2 `{3,4,5}`, Res 3 `{6,7,8}`, Res 4 y Com 4 `{12,16,20}`, Com 3 `{6,8,10}`.
- Huella: todo vértice con `|x|, |z| ≤ w/2 + 0.2` (balcones y toldos pueden salir hasta la vereda del lote).
- Texturas solo de ambientCG (CC0), 1K, anotadas en `godot/assets/FUENTES.md`. Textos visibles en español rioplatense.
- Distancias LOD: cerca 0–140 m, media 120–380 m, lejos ≥ 340 m (márgenes de fundido 20 m). Calidad Baja: solo "lejos", sin texturas (y no se cargan).

## Review Focus

1. **Torres 2×2 y celdas secundarias** (`part[i] != i`) → una sola instancia en el ancla, ninguna en las otras tres; `BUILDING_CHECK` (Task 2).
2. **Edificio quemado, demolido o subiendo de nivel** → el bloque se rehace y la instancia cambia (oscura / desaparece / otro modelo); `BUILDING_CHECK` después de cambiar `burn`, `lvl` y `zone` de celdas de prueba (Task 2).
3. **Calidad Baja / Modo seguro** → no carga los arreglos de texturas y no cuesta más que hoy; captura `baja` + `BENCH frame_ms_baja` (Task 6).
4. **Noche, lluvia y nieve de cerca** → ventanas encendidas, calles mojadas más oscuras, techos blancos; chequeos nuevos del verificador (Task 6).
5. **Cerros** → los modelos apoyados en el terreno subdividido sin flotar; captura `cerros` (Task 6).

---

## Archivos

| Archivo | Qué hace |
|---|---|
| `godot/src/buildings.gd` (nuevo) | constructor de mallas `mb_*`, recetas, `cat_register`, `cat_mesh`, `pick_model` |
| `tools/godot_modules.py` | agrega `buildings` a `ORDER` (después de `render`) y a `ABOUT` |
| `godot/src/render.gd` | `setup_render`, `build_chunk`, `emit_zone`, `emit_road`, `apply_quality`, `apply_fx`, `update_light`, `update_fx`; se borran `emit_res/emit_com/emit_ind/emit_house` y los ayudantes que queden sin uso |
| `godot/shaders/building.gdshader` (nuevo), `godot/shaders/city.gdshader` | materiales |
| `tools/get_textures.py`, `godot/assets/city/*`, `godot/assets/FUENTES.md` | texturas de la ciudad |
| `godot/src/tests.gd`, `tools/run_tests.sh`, `tools/check_album.py` | `--test=buildings`, tomas nuevas del álbum, chequeos |

---

### Task 1: Medición "antes", constructor de mallas y `CATALOG_CHECK`

**Files:**
- Create: `godot/src/buildings.gd`, `godot/tests/etapa2_antes.txt`
- Modify: `tools/godot_modules.py`, `godot/src/tests.gd`, `tools/run_tests.sh`

**Interfaces:**
- Produces:
  - Materiales (`const` en `buildings.gd`): `BM_PLAIN=0, BM_BRICK=1, BM_PLASTER=2, BM_CONCRETE=3, BM_TILES=4, BM_SHEET=5, BM_WOOD=6, BM_PAINTED=7, BM_ASPHALT=8, BM_SIDEWALK=9` (capas de textura 0–9), `BM_GLASS=10`, `BM_MIRROR=11`, `BM_DARK=12`, `BM_FARWIN=13`. Máscara de tinte: `0` sin tinte, `1` color del edificio, `2` segundo color.
  - Vértice: `VERTEX`, `NORMAL`, `UV` (metros por cara; en `BM_GLASS/BM_MIRROR` = `(columna + u, piso + v)` para que `floor(UV)` identifique la ventana; en `BM_FARWIN` = `(x / paso_ventana, y / FLOOR_H)`), `UV2 = (material, máscara)`. Sin color de vértice (el `COLOR` del shader = color de instancia).
  - `mb_begin() -> void`; `mb_quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3, mat: int, tm: int, uva := Vector2.ZERO, uvc := Vector2.ZERO) -> void` (a→b→c→d antihorario visto de frente; si `uva == uvc` el UV se calcula en metros); `mb_box(c: Vector3, s: Vector3, mat: int, tm: int, faces := 63) -> void` (`c` = centro de la base; bits `+X −X +Y −Y +Z −Z`); `mb_gable(c: Vector3, lx: float, lz: float, h: float, mat: int, tm: int, along_x: bool) -> void`; `mb_cyl(c: Vector3, r: float, h: float, seg: int, mat: int, tm: int) -> void`; `mb_end() -> ArrayMesh`.
  - Catálogo: `var cat_models: Array` de `{"id": String, "zones": Array[int], "levels": Array[int], "big": bool, "floors": Dictionary (nivel → Array[int], vacío si fijo), "recipe": Callable (lod: int, floors: int, w: float) -> void}`; `cat_register() -> void`; `cat_mesh(m: int, floors: int, lod: int) -> ArrayMesh` (con caché `cat_cache`); `LOD_NEAR=0, LOD_MID=1, LOD_FAR=2`.
  - `--test=buildings`: imprime `CATALOG_CHECK <id> f=<pisos> lod=<n> ok|FALLA <motivo>` por combinación, `BENCH catalog_ms=<n>` (todas las combinaciones, caché vacía) y `BUILDINGS OK` si nada falló.

- [ ] **Step 1:** Medición "antes" en el HEAD actual: `tools/album.sh out/e2_antes` (BENCH `frame_ms` y `frame_ms_baja`) y `tools/run_tests.sh out/e2_antes_t` (BENCH `chunks_ms`); `.pck` con `--export-pack` como en la etapa 1. Anotar en `godot/tests/etapa2_antes.txt`.
- [ ] **Step 2:** Escribir el modo `--test=buildings` con `CATALOG_CHECK` (3 versiones sin error, `get_surface_count() == 1`, vértices > 0, huella y alturas de Global Constraints; la versión lejos tiene menos vértices que la cerca) y agregarlo a `run_tests.sh` (`run buildings buildings "BUILDINGS OK"`). Correr. Esperado: falla (no existe `cat_register`).
- [ ] **Step 3:** Crear `buildings.gd` con el constructor, `cat_register` con un modelo de prueba (`"caja"`, Res 1) y registrarlo en `godot_modules.py`.
- [ ] **Step 4:** `build` + `--test=buildings`. Esperado: `CATALOG_CHECK caja … ok` ×3 y `BUILDINGS OK`. Números `SIM ` idénticos.
- [ ] **Step 5:** Commit: `Etapa 2: constructor de mallas y prueba del catálogo`.

### Task 2: Edificios por catálogo en los bloques y `BUILDING_CHECK`

**Files:**
- Modify: `godot/src/render.gd`, `godot/src/buildings.gd`, `godot/src/tests.gd`
- Create: `godot/shaders/building.gdshader` (versión mínima: color por material sin texturas, tinte, quemado)

**Interfaces:**
- Consumes: Task 1.
- Produces:
  - `pick_model(i: int) -> Vector2i` = (índice de modelo, pisos) o `(-1, 0)`; candidatos = modelos con `zone[i]` en `zones`, `lvl[i]` en `levels` y `big == (part[i] == i)`; elección `cands[(vari[i] + int(hsh(i, 41) * 7.0)) % cands.size()]`; pisos `fl[int(hsh(i, 43) * fl.size()) % fl.size()]`. Si no hay candidato grande, usa uno normal escalado ×(1.85/0.82) en XZ.
  - Instancia: transformación como `em()` (rotación Y `face_rot(i)`), `COLOR` = `tint(res_wall(v), i)` (Res/Mixta) o la paleta de hoy por familia; `INSTANCE_CUSTOM = (quemado 0/1, segundo color 0..7 / 8, hsh(i, 42), 0)`.
  - `building_mat: ShaderMaterial`; `bnodes: Array` (por bloque, `Dictionary` clave `(m * 64 + pisos) * 3 + lod` → `MultiMeshInstance3D`, creados al primer uso; los que quedan sin instancias → `instance_count = 0`). Rangos de visibilidad de Global Constraints con `VISIBILITY_RANGE_FADE_SELF`; sombra: cerca y media sí, lejos solo con `quality == 2`. Calidad 0: solo lejos y sin rango.
  - `emit_zone` con `lvl >= 1`: base del lote como hoy + una instancia; nada de `emit_res/com/ind/house`.
  - `bcheck_log: Dictionary` (celda → modelo) que llena `emit_zone` cuando `bcheck_on`.
  - `BUILDING_CHECK ok|FALLA <motivo>` en `--test=buildings` sobre `new_test_city()`: cada celda con `zone > 0`, `lvl >= 1`, `road == 0`, `bld == 0`, sin `anim_cells` y `part < 0 or part == i` tiene exactamente una entrada con modelo de su zona, nivel y tamaño; ninguna otra celda tiene entrada; la suma de `instance_count` de los nodos "cerca" = cantidad de entradas. Luego cambia una celda (quemada), sube otra de nivel y borra la zona de una tercera, `update_chunks(NCH * NCH)` y vuelve a verificar (quemada → `custom.x == 1`).
- [ ] **Step 1:** Escribir `BUILDING_CHECK`. Correr. Esperado: falla.
- [ ] **Step 2:** Implementar (con el modelo `caja` sirviendo a todas las familias de momento) y el shader mínimo; borrar las funciones de dibujo viejas que queden sin llamadas (verificar con `grep`).
- [ ] **Step 3:** `--test=buildings` → `BUILDING_CHECK ok` y `BUILDINGS OK`; `run_tests.sh` sin `SCRIPT ERROR`; números `SIM ` idénticos; `BENCH chunks_ms` anotado.
- [ ] **Step 4:** Commit: `Edificios por catálogo en los bloques, con versiones por distancia`.

### Task 3: Recetas residenciales (10 casas, 8 departamentos, 6 torres)

**Files:** Modify: `godot/src/buildings.gd`

**Interfaces:**
- Consumes: constructor (Task 1), `pick_model` (Task 2).
- Produces: piezas reutilizables `mb_wall_win(p0: Vector3, p1: Vector3, y0: float, floors: int, cols: int, lod: int, mat: int, tm: int, opts: Dictionary)` (cerca: hueco hundido 0,08 con marco y vidrio; media: vidrio a ras; lejos: `BM_FARWIN`), `mb_balcony`, `mb_cornice`, `mb_parapet`, `mb_tank`, `mb_rail`, `mb_shutters`, `mb_awning`, `mb_door`. Modelos con los nombres del spec: casas `chorizo`, `chalet`, `casa_rejas`, `ladrillo_terraza`, `ph`, `moderna`, `galeria`, `esquina_ochava`, `chorizo_b`, `chalet_b`; departamentos `depto_1`…`depto_8` (balcón de hierro o de vidrio, revoque o ladrillo, planta baja con local o entrada, tanque y antenas); torres `torre_cortina`, `torre_franjas`, `torre_escalonada`, `torre_cilindro`, `torre_grande_a` y `torre_grande_b` (2×2). Quitar `caja`.
- [ ] **Step 1:** `CATALOG_CHECK` ya cubre huella, alturas y versiones: correr con las recetas nuevas declaradas pero vacías. Esperado: FALLA "sin vértices".
- [ ] **Step 2:** Implementar las recetas.
- [ ] **Step 3:** `--test=buildings` → todo ok y `BENCH catalog_ms` ≤ 2000; `BUILDING_CHECK ok`; `tools/album.sh out/e2_t3 mediodia` y mirar la captura.
- [ ] **Step 4:** Commit: `Recetas residenciales: casas porteñas, departamentos y torres`.

### Task 4: Recetas comerciales, industriales y mixtas

**Files:** Modify: `godot/src/buildings.gd`

**Interfaces:**
- Produces: comercio `almacen`, `kiosco` (nivel 1, toldo con segundo color y cartel), `locales_a`, `locales_b` (nivel 2, vidriera abajo y departamentos arriba; también Mixta 1–3), `oficinas_a`, `oficinas_b` (nivel 3), `torre_oficinas` (nivel 4, con remate), `torre_oficinas_grande` (2×2, nivel 3–4; también Mixta grande); industria `galpon_chapa` (1), `fabrica_ladrillo` (2, diente de sierra), `planta_silos` (3, silos y chimenea), `fabrica_grande` (3–4), `complejo` (4) y `complejo_grande` (2×2). Mixta 4 usa `torre_oficinas`.
- [ ] **Step 1:** Declarar vacías → `CATALOG_CHECK` FALLA.
- [ ] **Step 2:** Implementar.
- [ ] **Step 3:** `--test=buildings` ok, `catalog_ms` ≤ 2000, `BUILDING_CHECK ok`; números `SIM ` idénticos.
- [ ] **Step 4:** Commit: `Recetas de comercio, industria y zonas mixtas`.

### Task 5: Texturas, `building.gdshader` completo y calles texturizadas

**Files:**
- Modify: `tools/get_textures.py` (función `city()`), `godot/assets/FUENTES.md`, `godot/shaders/building.gdshader`, `godot/shaders/city.gdshader`, `godot/src/render.gd`
- Create: `godot/assets/city/city_alb.webp` + `.import`, `godot/assets/city/city_nrm.webp` + `.import`

**Interfaces:**
- Produces:
  - `city()` en `get_textures.py`: baja de ambientCG un material por capa 0–9 (liso = gris neutro generado; ladrillo, revoque, hormigón, tejas, chapa acanalada, madera, metal pintado, asfalto, baldosas) a 1024², aplica `flatten`, y arma tiras verticales 1024 × 10240: `city_alb.webp` (RGB + rugosidad en A) y `city_nrm.webp` (normal OpenGL). Los `.import` con `importer="2d_array_texture"`, `slices/horizontal=1`, `slices/vertical=10`, mipmaps y compresión VRAM.
  - `building.gdshader`: uniforms `alb_arr`, `nrm_arr` (`sampler2DArray`), `tex_on`, `night`, `snow`, `wet`, `cshadow`, `ctex`, `ao_on`, `hmap`, `hinfo`. Color = textura (capa = material) × tinte según máscara; vidrio con Fresnel y reflejo del cielo (`mirror()` de `city.gdshader`), más espejado en `BM_MIRROR`; cortinas de día; de noche ventana encendida si `hash(floor(UV) + seed) < 0.55` (× 0,6 de 1 a 6 h), luz cálida o fría; `BM_FARWIN` dibuja la grilla de ventanas con la misma regla; nieve en caras con `normal.y > 0.7`, mojado (rugosidad baja y color −25 %), quemado (−60 %), sombra de nubes, oclusión de contacto con `hmap`. `tex_on = 0` → colores lisos por material.
  - `city.gdshader`: `cust.w == -20` asfalto (capa 8) y `-21` vereda (capa 9) con UV `wpos.xz / 3.0`, mojado y nieve como hoy; `emit_road` los marca.
  - `load_city_tex()` en `render.gd`: carga los arreglos solo si `quality >= 1` y `g_detail`; si no, `tex_on = 0` en ambos materiales. `update_light`/`update_fx`/`apply_fx` pasan los uniforms a `building_mat` igual que a `city_mat`.
- [ ] **Step 1:** `python3 tools/get_textures.py city` y `--import`. Esperado: sin errores; `import.log` sin `ERROR`.
- [ ] **Step 2:** Implementar shaders y carga. `tools/album.sh out/e2_t5 mediodia,noche,lluvia,nieve,baja` + `check_album.py`. Esperado: pasan los chequeos de la etapa 1.
- [ ] **Step 3:** `BENCH frame_ms` ≤ +25 % y `frame_ms_baja` ≤ +0 % contra Task 1; números `SIM ` idénticos.
- [ ] **Step 4:** Commit: `Materiales fotográficos en edificios y calles`.

### Task 6: Álbum de cerca, verificador, mediciones y entrega

**Files:** Modify: `godot/src/tests.gd`, `tools/check_album.py`, `godot/LEEME.md`, `godot/assets/FUENTES.md`; Create: `godot/tests/etapa2_despues.txt`, `godot/tests/album_etapa2/`, `docs/etapa2_antes_despues.jpg`

**Interfaces:**
- Produces: tomas `cerca_casas`, `cerca_deptos`, `cerca_torres`, `cerca_comercio`, `cerca_industria` (mediodía; cámara `cam_dist = 30`, `cam_pitch = 0.42` sobre la celda más cercana al centro de esa familia y nivel), `cerca_noche` (23 h sobre deptos), `cerca_lluvia`, `cerca_nieve` (sobre casas) y `catalogo` (todos los modelos, versión cerca, en filas sobre un mapa plano, mediodía). Chequeos nuevos en `check_album.py`: `cerca_noche` ≥ 0,5 % de píxeles con `R > 170`, `G > 100`, `R > B + 50`; `cerca_nieve` tiene ≥ 1,5× la fracción de píxeles con brillo > 200 que `cerca_casas`; la mitad de abajo de `cerca_lluvia` es ≤ 0,9 × el brillo de la de `cerca_casas`.
- [ ] **Step 1:** Escribir los chequeos y correrlos sobre `out/e2_antes`. Esperado: FALLA (no existen las tomas).
- [ ] **Step 2:** Agregar las tomas. `tools/album.sh out/album_e2` + `check_album.py`. Esperado: todo ok. Mirar todas las tomas, el catálogo, `cerros` y `baja`; corregir lo que se vea mal.
- [ ] **Step 3:** Mediciones en `godot/tests/etapa2_despues.txt` (todos los presupuestos de Global Constraints), `tools/compat_test.sh` ok, números `SIM ` idénticos.
- [ ] **Step 4:** Copiar el álbum (JPG) a `godot/tests/album_etapa2/`, armar `docs/etapa2_antes_despues.jpg` con `tools/mosaic.py`, actualizar LEEME (tabla de Gráficos: edificios) y FUENTES.
- [ ] **Step 5:** Commit: `Etapa 2a+2b: álbum de cerca, mediciones y entrega`.
