# URBANA Godot — Etapa 2a+2b: materiales reales y edificios con volumen

Fecha: 2026-10-15 · Estado: diseño aprobado en el chat, pendiente de revisión escrita
Etapas anteriores: 0 (proyecto en `godot/`, código en `godot/src/*.gd` unido por
`tools/godot_modules.py` en `godot/scripts/main.gd`) y 1 (cielo, luz AgX, terreno y agua; álbum con el
renderer Mobile y verificador de colores).

## Objetivo

Que las casas y los edificios que crecen solos (zonas residencial, comercial, industrial y mixta) y las
calles dejen de verse como cajas de colores: modelos con volumen real (ventanas hundidas, balcones,
cornisas, rejas, toldos) y materiales fotográficos (ladrillo, revoque, hormigón, vidrio, tejas, chapa,
madera, metal, asfalto, vereda), con estilo **mezcla**: barrios bajos porteños y centro moderno.

## Lo que pidió el autor

- Hacer juntas la 2a (materiales) y la 2b (edificios con volumen).
- Estilo: mezcla (nivel 1 porteño, niveles 2–3 departamentos con balcones, nivel 4 torres modernas).
- Camino elegido: **catálogo de modelos generados por código** (descartados: seguir armando con cajas
  sueltas, por su techo de detalle y su costo en celular; y modelos de bibliotecas, porque casi no hay
  edificios realistas CC0 ni de estilo porteño).

## Fuera de alcance

- Edificios especiales (escuela, estadio, usinas, maravillas…): etapa 2e.
- Árboles y vegetación: 2c. Faroles, semáforos, autos estacionados, cables: 2d.
- Forma de las calles (curvas, intersecciones): etapa 3. Gente y vehículos en movimiento: etapa 4.
- Animación de obra (andamio y grúa) y lotes vacíos: quedan como hoy.
- Simulación, balance y formato de partidas: sin cambios.

## Lo que hay hoy

- `build_chunk(c)` recorre las celdas del bloque (32×32) y `emit_cell` → `emit_zone` arma cada
  edificio con `em()` sobre 9 mallas primitivas (MultiMesh por bloque y por primitiva).
  `emit_res` / `emit_house` / `emit_com` / `emit_ind` eligen la forma por zona, nivel (`lvl`) y variante
  (`vari`); `face_rot(i)` orienta hacia la calle; `part[i] == i` marca las torres de 2×2; `burn[i]`
  oscurece; `tint()` varía el color.
- `city.gdshader` pinta ventanas, ladrillo, tejas, chapa, vidrio, etc. con fórmulas según
  `INSTANCE_CUSTOM` (x = ventanas, y/z = emisión, w = material), y maneja noche, nieve, lluvia y sombras
  de nubes.

## Diseño

### 1. Catálogo de modelos (`src/buildings.gd` nuevo, agregado a `godot_modules.py`)

Recetas en código que arman `ArrayMesh` con piezas (paredes con huecos de ventana, marcos, vidrios,
balcones con baranda, cornisas, techos a dos aguas y de tejas, terrazas con tanque y antenas, rejas,
persianas, toldos, vidrieras, chimeneas, silos). Cada vértice lleva: posición, normal, UV en metros
(mapeo por cara), **índice de material** y **máscara de tinte** (cuánto toma el color del edificio).

| Familia | Nivel | Modelos |
|---|---|---|
| Residencial | 1 (casas) | 10: chorizo con patio lateral, chalet con tejas a dos aguas, casa de frente con rejas y persianas, ladrillo visto con terraza, PH de dos plantas, moderna de hormigón y madera, casa con galería, casa de esquina con ochava, y 2 variantes de las anteriores |
| Residencial | 2–3 (departamentos) | 8: 3 a 8 pisos, balcones de hierro o de vidrio, revoque o ladrillo, planta baja con local o entrada, tanque y antenas |
| Residencial | 4 (torres) | 6: muro cortina, hormigón con franjas, escalonada, cilíndrica, y 2 de 2×2 celdas |
| Comercial | 1–4 | 8: almacén/kiosco con toldo y cartel; locales con vidriera y departamentos arriba; oficinas medianas; torre de oficinas con remate (incluye 2×2) |
| Industrial | 1–4 | 6: galpón de chapa; fábrica de ladrillo con diente de sierra; planta con silos y chimenea; complejo grande |
| Mixta | 1–4 | reusa comercial abajo + residencial arriba (como hoy) |

- **Elección:** misma regla que hoy: modelo = f(zona, nivel, `vari[i]`, `hsh(i, k)`); una tabla
  `BUILDING_SET[zona][nivel] → [ids de modelo]`.
- **Variedad por instancia:** color de tinte (paleta por familia con `tint()`), color de persianas y
  toldos (2º color), y para departamentos y torres, altura en pisos dentro de un rango (escala vertical
  por pisos enteros, sin deformar ventanas: la receta repite el piso tipo).
- **Medidas:** cada modelo entra en su lote (celda de 4 m con margen de vereda: hoy `CELL * 0.82`;
  2×2: `CELL * 1.85`) y se apoya en `y = p.y + 0.1` como hoy.
- **Tres versiones (LOD):** cerca (todo), media (sin balcones, rejas ni marcos; ventanas pintadas en el
  shader), lejos (volumen y techo). Las recetas generan las tres.

### 2. Materiales (`godot/assets/city/`, `shaders/building.gdshader` nuevo, `city.gdshader`)

- **Texturas CC0 de ambientCG**, 1K, color + rugosidad (alfa) y normales, en dos `Texture2DArray`
  (color y normales). Materiales: ladrillo visto, revoque pintado, hormigón, tejas coloniales, chapa
  acanalada, madera, metal pintado, asfalto, baldosas de vereda, más un "liso" para piezas chicas.
  Se bajan y preparan con un script reproducible (como `tools/get_textures.py`) y se anotan en
  `godot/assets/FUENTES.md`.
- **Vidrio** sin textura: reflejo del cielo (Fresnel), más espejado en torres; de día se insinúa el
  interior (cortinas); **de noche** se encienden ventanas al azar (hash por ventana: luz cálida o fría,
  ~55 % encendidas, menos de madrugada), como hoy.
- **`building.gdshader`** (para los modelos): muestrea el arreglo por índice de material, aplica tinte
  por instancia (máscara del vértice), nieve en caras hacia arriba, mojado con lluvia, oscurecido si está
  quemado (dato por instancia), sombras de nubes y oclusión de contacto en la base (la de hoy con `hmap`).
- **Calles:** `emit_road` pasa a marcar asfalto y vereda con su índice de material y `city.gdshader`
  las pinta con las texturas del arreglo (mojado y nieve como hoy). La forma de las calles no cambia.
- **Calidad Baja:** sin texturas de fachada ni de calle (colores lisos como hoy), modelos en versión
  "lejos".

### 3. Dibujo y rendimiento (`src/render.gd`)

- `build_chunk` deja de llamar a `emit_res/emit_com/emit_ind/emit_house` para lotes con nivel ≥ 1:
  agrega una instancia (transformación + tinte + datos) a la lista del modelo correspondiente en ese
  bloque. El resto de `emit_cell` (base del lote, calles, árboles, cables, basura, inundación, quemado,
  obra) sigue igual.
- Por bloque y por modelo, tres `MultiMeshInstance3D` (cerca, media, lejos) con
  `visibility_range_begin/end` y fundido (`VISIBILITY_RANGE_FADE_SELF`): cerca 0–140 m, media
  120–380 m, lejos 340 m en adelante (medido desde el centro del bloque). Los nodos se crean recién
  cuando el bloque usa ese modelo.
- Sombras: cerca y media proyectan; lejos proyecta solo en Alta.
- **Presupuestos** (contra la etapa 1, renderer Mobile en esta máquina):
  - cuadro **≤ +25 %** en Alta; **Baja ≤ +0 %**;
  - `build_chunk` (rehacer un bloque) **≤ 1,5×**;
  - generar el catálogo al arrancar **≤ 2 s** (headless, esta máquina);
  - `.pck` **≤ +40 MB**.

## Pruebas

- **Simulación intacta:** líneas `SIM ` idénticas a `godot/tests/reference/sim.log`; `compat_test.sh`
  (partidas, primer arranque, pausa, empalme del horizonte) pasa.
- **`BUILDING_CHECK`** (modo de prueba): en la ciudad de prueba, cada lote con nivel ≥ 1 y que no es parte
  secundaria de una torre 2×2 tiene exactamente una instancia de modelo, de su familia y nivel; ninguna
  instancia en celdas sin edificio.
- **`CATALOG_CHECK`**: cada modelo genera sus 3 versiones sin error, con vértices dentro de su caja de lote
  (huella ≤ lote) y altura dentro del rango de su nivel; imprime el tiempo total (`BENCH catalog_ms`).
- **`BENCH chunk_ms`**: tiempo de rehacer todos los bloques, comparado con hoy.
- **Álbum** (renderer Mobile): las tomas de la etapa 1 más tomas de cerca de casas, departamentos, torres,
  comercio e industria, de día y de noche, con lluvia y con nieve, y una **hoja del catálogo** (todos los
  modelos en fila, versión "cerca").
- **Verificador de colores** (`check_album.py`), chequeos nuevos: de noche hay ventanas encendidas
  (≥ 0,5 % de píxeles cálidos y brillantes en la toma de cerca de noche); con nieve, la zona de techos es
  clara; con lluvia, la zona de calle es más oscura que con sol.
- **Aprobación visual del autor** con el álbum y la hoja del catálogo; los modelos que no le gusten se
  cambian uno por uno.

## Riesgos

- **Cantidad de nodos:** hasta 16 bloques × ~40 modelos × 3 versiones; se crean solo los usados. Si
  igual pesa, se pasa a una MultiMesh por modelo para toda la ciudad con actualización parcial.
- **Tiempo de arranque** por generar el catálogo: si supera 2 s, se genera en segundo plano por partes o
  se guarda en `user://` la primera vez.
- **Texturas en arreglo** requieren el mismo tamaño y formato: el script las normaliza a 1K.
- **El tinte azul de los vidrios** de la etapa 1 puede volver con fachadas espejadas: el álbum lo vigila
  (chequeo "imagen no azulada" del mediodía).
