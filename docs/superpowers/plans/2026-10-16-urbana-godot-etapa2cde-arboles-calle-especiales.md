# URBANA Godot — Etapa 2c+2d+2e: árboles, calle y edificios especiales · Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Árboles por especie con copas texturizadas, objetos de calle (faroles, semáforos, autos, mobiliario, postes y carteles) y un modelo único para cada uno de los 51 edificios especiales, todo en el catálogo de la 2b y sin perder fluidez.

**Architecture:** Se amplía `godot/src/buildings.gd`: una función genérica `emit_model` agrega instancias a `_binst` (la usan edificios, árboles, objetos y especiales), los modelos pueden declararse "solo cerca", y se suman tablas `tree_models` y `special_model`. Tres capas de textura nuevas (corteza, follaje, pasto) y renumeración de los materiales que dibuja solo el shader. Las recetas nuevas viven en archivos nuevos `src/trees.gd`, `src/props.gd`, `src/specials.gd`.

**Tech Stack:** Godot 4.7 (GDScript, `ArrayMesh`, `MultiMesh`, `Texture2DArray`, shaders `spatial`), Mesa lavapipe + Xvfb, Python 3 + Pillow/numpy, ambientCG (CC0).

**Spec:** `docs/superpowers/specs/2026-10-16-urbana-godot-etapa2cde-arboles-calle-especiales-design.md`

## Global Constraints

- Código en `godot/src/*.gd` (módulos nuevos `trees`, `props`, `specials` en `tools/godot_modules.py`, después de `buildings`); siempre `python3 tools/godot_modules.py build`.
- `--test=sim`: líneas `SIM ` **idénticas** a la referencia; el dibujo **nunca** usa `randi`/`randf`.
- `tools/compat_test.sh` pasa.
- Presupuestos contra la medición "antes" de la Task 1 (HEAD de hoy, misma máquina): cuadro **≤ +5 %** en Alta; **Baja ≤ +0 %** (medido alternando con la versión anterior, dos pares); `BENCH chunks_ms` **≤ 1,3×**; `BENCH catalog_ms` **≤ 4000**; `.pck` **≤ +15 MB**.
- Objetos chicos (bancos, tachos, bolardos, carteles, cables, canteros, señales) **solo versión cerca**. Árboles y autos: cerca, media y lejos.
- Materiales: capas de textura 0–12 (`BM_BARK = 10`, `BM_LEAF = 11`, `BM_TURF = 12`); solo shader: `BM_GLASS = 20`, `BM_MIRROR = 21`, `BM_DARK = 22`, `BM_EMIT = 23` (brilla de noche), `BM_SIGNAL = 24` (luz de semáforo), fachada lejana `BM_FARWIN = 30 + material` (30–42).
- Texturas ambientCG CC0 anotadas en `FUENTES.md`; textos en español rioplatense.

## Review Focus

1. **Especiales de 2×2 y 3×3**: una sola instancia en el ancla, centrada en el lote como hoy (`emit_def`), y nada en las otras celdas (Task 5/6, `SPECIAL_CHECK`).
2. **Maravillas en construcción y especiales animados** (aspas, vuelta al mundo, calesita): siguen igual que hoy (Task 6, toma `catalogo_especiales` + mirar `agents.gd`).
3. **Calidad Baja**: sin mobiliario ni cables, árboles y autos en versión lejana, sin capas de textura nuevas cargadas (Task 7, `BENCH frame_ms_baja`).
4. **Invierno y nieve**: árboles de hoja caduca ralos, pinos verdes, nieve arriba de las copas (Task 2, toma `arboles_invierno`).
5. **Mapas con agua y cerros**: árboles y objetos apoyados en el suelo (`ground_y`), nunca sobre agua (Task 3–4, `PROP_CHECK`).

---

## Archivos

| Archivo | Qué hace |
|---|---|
| `godot/src/buildings.gd` | materiales renumerados, `emit_model`, modelos "solo cerca", tablas nuevas, `flush_buildings` |
| `godot/src/trees.gd` (nuevo) | recetas de las 7 especies (3 formas, llena y rala) y `emit_trees` nuevo |
| `godot/src/props.gd` (nuevo) | faroles, semáforos, autos, mobiliario, postes, cables, carteles y su ubicación |
| `godot/src/specials.gd` (nuevo) | 51 recetas de especiales y `emit_special` |
| `godot/src/render.gd` | `emit_cell`, `emit_road`, `emit_cable`, `emit_def` (queda solo la maravilla en obra) |
| `godot/shaders/building.gdshaderinc` | capas nuevas, viento en el follaje, `BM_EMIT`, `BM_SIGNAL` |
| `tools/get_textures.py`, `godot/assets/city/*` | 13 capas |
| `godot/src/tests.gd`, `tools/check_album.py` | chequeos y tomas nuevas |

---

### Task 1: Base común

**Files:** Modify `godot/src/buildings.gd`, `godot/src/render.gd`, `godot/shaders/building.gdshaderinc`, `tools/get_textures.py`, `godot/assets/city/*.import`, `godot/assets/FUENTES.md`, `tools/godot_modules.py`, `godot/src/tests.gd`; Create `godot/src/trees.gd`, `godot/src/props.gd`, `godot/src/specials.gd` (vacíos con su encabezado), `godot/tests/etapa2cde_antes.txt`.

**Interfaces:**
- Produces:
  - Constantes de material de Global Constraints (las recetas de la 2b usan los nombres, no números).
  - `cat_add(id, zones, levels, big, floors, recipe, near_only := false, fam := "edificio")`; `cat_models[m]["near_only"]`, `["fam"]`.
  - `emit_model(m: int, f: int, x: float, y: float, z: float, rot: float, sc: float, col: Color, cust: Vector4) -> void` (agrega a `_binst[m * 64 + f]`; `emit_building` pasa a usarla).
  - `flush_buildings`: para modelos `near_only`, solo la versión cerca y solo si `near_ok`; si no, ningún nodo.
  - `bcheck_log` sigue para edificios; nuevo `mcheck_log: Array` de `[celda, modelo]` para todas las instancias cuando `bcheck_on`.
  - Uniform `wind` en los shaders de edificios (`bmat_param("wind", ...)` en `apply_fx`).
  - Arreglos de texturas con 13 capas: 10 corteza (`Bark` de ambientCG), 11 follaje (hojas en primer plano; si no hay CC0 adecuado, generado), 12 pasto corto (`Grass` corto de ambientCG).
- [ ] **Step 1:** Medición "antes" en un worktree limpio del HEAD actual: álbum `mediodia,baja` dos veces alternado y `run_tests` (`chunks_ms`), `.pck`. Anotar en `godot/tests/etapa2cde_antes.txt`.
- [ ] **Step 2:** Prueba: en `--test=buildings`, `TEXTURE_CHECK`: los arreglos cargados tienen 13 capas (`get_layers()`), y `CATALOG_CHECK` de un modelo de prueba `near_only` da malla vacía en media y lejos. Correr: FALLA.
- [ ] **Step 3:** Implementar. `--test=buildings` → `BUILDINGS OK`; `run_tests.sh` sin errores; `SIM` idénticos; álbum `mediodia` igual a la vista (los materiales renumerados no cambian nada visible).
- [ ] **Step 4:** Commit: `Etapa 2c-e: base común (materiales, capas de textura, modelos solo cerca)`.

### Task 2: Árboles (2c)

**Files:** `godot/src/trees.gd`, `godot/src/render.gd` (`emit_trees`), shader, `godot/src/tests.gd`, `tools/check_album.py`.

**Interfaces:**
- Produces: `tree_models: Dictionary` tipo (1–7) → `Array[int]` de modelos (3 formas); `floors` del modelo = 0 llena, 1 rala; `emit_trees(i, p)` emite 1–3 árboles por celda (misma cantidad y desplazamientos con `hsh` que hoy), color `tree_colors(kind)[0]`, rala si `tree_colors(kind)[1] < 0.6`, escala `0.8 + hsh * 0.6`, apoyados en `ground_y`. Especies y formas: tabla del spec. Copas: bultos (icosfera de 1 subdivisión deformada con `hsh`) con `BM_LEAF` (tinte 1); tronco y ramas `BM_BARK`; palo borracho con tronco panzón tintado verde; palmera con hojas como cintas dobles `BM_LEAF`.
  - Alturas: 3–9 m; huella dentro de la celda + 1,5 m (las copas pueden pasar la celda).
  - `TREE_CHECK` en `--test=buildings`: cada celda con `tree[i] > 0` (y sin calle, zona ni edificio) tiene ≥ 1 instancia de un modelo de su especie; ninguna instancia de árbol en otras celdas (salvo árboles de vereda y especiales, que se registran aparte).
  - Tomas: `arboles_primavera` (día 3), `arboles_otono` (día 13), `arboles_invierno` (día 23, Nieve) con `album_close` sobre la celda con árbol más cercana al centro; `catalogo_arboles` (hoja). Chequeo: en `arboles_primavera` hay ≥ 0,3 % de píxeles violetas (`B > G + 30`, `R > G + 10`).
- [ ] **Step 1:** `TREE_CHECK` y el chequeo violeta. Correr: FALLA.
- [ ] **Step 2:** Recetas, `emit_trees` y viento en el shader (follaje: desplazamiento ∝ altura local, `wind`, fase por instancia).
- [ ] **Step 3:** `--test=buildings` ok; tomas; mirar y corregir; `BENCH frame_ms` ≤ +5 %.
- [ ] **Step 4:** Commit: `Árboles por especie con copas texturizadas, estaciones y viento`. Mandar las tomas al autor.

### Task 3: Calle, parte 1: faroles, semáforos y autos (2d)

**Files:** `godot/src/props.gd`, `godot/src/render.gd` (`emit_road`), shader, tests.

**Interfaces:**
- Produces: modelos `farol` (columna, brazo, farola `BM_EMIT`), `semaforo` (poste, caja `BM_PAINTED`, tres luces `BM_SIGNAL` con UV.x = 0 rojo / 1 amarillo / 2 verde), autos `sedan`, `hatch`, `camioneta`, `utilitario`, `taxi` (carrocería tinte 1, vidrios `BM_GLASS`, ruedas `BM_DARK`; taxi con techo amarillo fijo). Ubicación: faroles donde hoy hay `lamps` (misma posición; `lamps[i]` se sigue llenando igual); semáforos en cada esquina de un cruce (`cnt >= 3`) donde alguna calle es tipo ≥ 3; autos con la regla de hoy (calle tipo 2, calidad ≥ 1, lote vecino con zona y nivel ≥ 1, `hsh < 0.45`) + en zonas comerciales `hsh < 0.7`. Semáforo en el shader: ciclo de 12 s, fase `floor(hash(semilla) * 12)`, eje por `cust.w` (0/1): verde 5 s, amarillo 1 s, rojo 6 s, opuesto desfasado.
  - `PROP_CHECK` en `--test=buildings`: cantidad de faroles = cantidad de `lamps`; semáforos solo en cruces con avenida; autos solo en celdas con `road > 0` y `terr != T_WATER`.
- [ ] **Step 1:** `PROP_CHECK` (parte 1). FALLA.
- [ ] **Step 2:** Implementar.
- [ ] **Step 3:** ok; toma `calle_dia` y `calle_noche` (`album_close` sobre un cruce con avenida, 13 h y 23 h); chequeo: en `calle_noche` hay ≥ 0,2 % de píxeles cálidos y brillantes.
- [ ] **Step 4:** Commit: `Faroles, semáforos y autos estacionados de verdad`.

### Task 4: Calle, parte 2: mobiliario, postes, cables y carteles (2d)

**Files:** `godot/src/props.gd`, `godot/src/render.gd` (`emit_cable`, `emit_road`, `emit_cell`), tests.

**Interfaces:**
- Produces (todos `near_only`): `banco`, `tacho`, `bolardo`, `cantero`, `parada` (techito con banco, donde `stops.has(i)`; se marca el bloque al cambiar `stops`), `cartel_calle` (en esquinas, `cnt >= 3`, uno por cruce), `pare` (en cruces sin semáforo, `hsh < 0.3`), `poste` y `cable` (tramos con comba: 4 segmentos, caída 0,35 m) para `W_POWER` (reemplaza `emit_cable`); `arbol_vereda`: modelo de árbol chico (de `trees.gd`) en la vereda de calles tipo 2 frente a lotes residenciales, `hsh < 0.35`, cerca y media. Bancos y tachos frente a lotes comerciales (`hsh < 0.25`) y en plazas.
  - `PROP_CHECK` (parte 2): mobiliario solo en celdas de calle o vereda (nunca sobre un lote con edificio ni agua); sin nodos de mobiliario con la cámara lejos.
- [ ] **Step 1:** `PROP_CHECK` parte 2. FALLA.
- [ ] **Step 2:** Implementar.
- [ ] **Step 3:** ok; tomas `calle_dia`, `calle_noche`, `catalogo_calle`; `BENCH frame_ms` ≤ +5 %.
- [ ] **Step 4:** Commit: `Mobiliario de vereda, postes con cables y carteles`. Mandar las tomas al autor.

### Task 5: Especiales A (servicios, educación, gobierno, ocio y verde: ids 20–41, 66)

**Files:** `godot/src/specials.gd`, `godot/src/render.gd` (`emit_cell` → `emit_special`), tests.

**Interfaces:**
- Produces: `special_model: Dictionary` id → modelo; receta `rc_sp_<id>(lod, f, w)` con `w = sz * CELL`; `emit_special(i, p)`: si `special_model.has(bld[i])` y no es maravilla en obra → una instancia centrada como hoy (`x = p.x + (sz - 1) * CELL * 0.5`, idem z), `rot = face_rot(i)`, color `DEF[id]["col"]` (tinte 1), quemado en `cust.x`; si no, `emit_def` de hoy. Plazas, parques y club usan árboles (`emit_model` con modelos de `tree_models`) y bancos.
  - `SPECIAL_CHECK` en `--test=buildings`: ciudad de prueba + un especial de cada id de esta tanda colocado con `place_def` en un mapa vacío; cada ancla tiene exactamente una instancia de su modelo; ninguna en celdas secundarias.
  - `CATALOG_CHECK` para especiales: huella ≤ `sz * CELL / 2 + 0.2`, altura 1,5–45 m.
- [ ] **Step 1:** `SPECIAL_CHECK` (ids de la tanda). FALLA.
- [ ] **Step 2:** Recetas (firmas del spec).
- [ ] **Step 3:** ok; `catalogo_especiales_a`; mirar y corregir.
- [ ] **Step 4:** Commit: `Edificios especiales únicos: servicios, educación, gobierno y ocio`.

### Task 6: Especiales B (monumentos, energía, transporte y otros: ids 42–65, 70–73)

**Files:** igual que Task 5.

**Interfaces:**
- Produces: las recetas restantes; las maravillas terminadas (70–73) usan su receta y en obra siguen con `emit_def`. Las partes animadas que hoy dibuja `agents.gd` (aspas, rueda, calesita, humo) se conservan; la receta no las duplica.
  - `SPECIAL_CHECK` con los 51 ids; `CATALOG_CHECK` de todos.
  - `emit_def` queda solo con la maravilla en obra; se borra el resto y los ayudantes sin uso (verificar con `grep`).
- [ ] **Step 1:** `SPECIAL_CHECK` con todos los ids. FALLA.
- [ ] **Step 2:** Recetas.
- [ ] **Step 3:** ok; `catalogo_especiales_b`; `run_tests.sh`; `SIM` idénticos.
- [ ] **Step 4:** Commit: `Edificios especiales únicos: monumentos, energía, transporte y otros`. Mandar las tomas al autor.

### Task 7: Álbum, mediciones y entrega

**Files:** `godot/tests/etapa2cde_despues.txt`, `godot/tests/album_etapa2cde/`, `docs/etapa2cde_antes_despues.jpg`, `godot/LEEME.md`, `docs/superpowers/hoja-de-ruta.md`.
- [ ] **Step 1:** Álbum completo + `check_album.py` (todo ok), `run_tests.sh`, `compat_test.sh`, `.pck`.
- [ ] **Step 2:** Mediciones (todas las de Global Constraints); si alguna no cumple, recortar (más cosas "solo cerca", menos instancias) hasta cumplir.
- [ ] **Step 3:** Copiar álbum, armar comparación, LEEME (tabla de Gráficos) y hoja de ruta.
- [ ] **Step 4:** Commit: `Etapa 2c-e: álbum, mediciones y entrega`.
