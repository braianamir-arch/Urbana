# URBANA Godot — Etapa 1: luz, cielo, terreno y agua

Fecha: 2026-10-15 · Estado: diseño aprobado en el chat, pendiente de revisión escrita
Etapa anterior: `2026-10-12-urbana-godot-etapa0-base-design.md` (proyecto en `godot/`, código en
`godot/src/*.gd` que `tools/godot_modules.py build` junta en `godot/scripts/main.gd`).

## Objetivo

Que la ciudad deje de verse plana, azulada y "de juguete" en lo que rodea a los edificios: el cielo,
la luz, el suelo, el agua y el horizonte, con un aspecto natural en el celular del autor y que se vea
bien **en movimiento** (ciclo de día de 90 s, estaciones y clima).

## Lo que pidió el autor

- Mejorar las cuatro cosas: luz y colores, terreno y pasto, agua, cielo y horizonte.
- Celular Android de **gama alta** que hoy anda fluido: hay margen para efectos más pesados.
- El APK puede crecer **hasta 100 MB**.
- Camino elegido: **cielo con atmósfera física + texturas fotográficas CC0** en terreno y agua
  (descartados: cielos HDRI, porque el sol de la foto no coincide con el del juego y las nubes no se
  mueven; y solo ajustar lo que hay, porque no llega a realista).

## Fuera de alcance

- Edificios, calles, árboles, matas de pasto, autos y gente (etapas 2 a 4).
- Reflejo de edificios en el agua (dibujar la ciudad dos veces es demasiado caro en celular).
- Cambios en la simulación, el balance o el formato de las partidas.

## Lo que hay hoy (para entender el cambio)

- Cielo: `ProceduralSkyMaterial` con colores puestos a mano en `update_light()`. En el renderer
  Mobile la luz ambiente y los reflejos salen de ese cielo y **tiñen todo de azul** (verificado con
  capturas en Mobile).
- Tonemap ACES, sol y luna `DirectionalLight3D`, niebla de Godot.
- Terreno: una malla de (N+1)² vértices con un color por vértice (promedio de celdas) y un shader con
  ruido (`terrain.gdshader`). Alturas en escalones de 0,5.
- Agua: un plano grande con color según la profundidad (sale del mapa de alturas `hmap`), ondas
  calculadas y un poco de brillo de costado (`water.gdshader`).
- Nubes: un plano a 170 m con ruido (`cloud.gdshader`) y sombras de nubes en terreno y ciudad.
- Horizonte: planos de pasto y esferas estiradas como lomas (`build_outer`).

## Diseño

### 1. Cielo y luz (`src/render.gd`, `shaders/sky.gdshader` nuevo)

- **Cielo:** shader de cielo propio (`shader_type sky`) con dispersión atmosférica simplificada
  (Rayleigh + Mie): azul profundo en el cénit, claro y lechoso en el horizonte, naranjas y rosados
  alrededor del sol al amanecer y al atardecer. Lo controla la dirección real del sol
  (`LIGHT0_DIRECTION`), así que siempre coincide con la luz.
- **Noche:** azul muy oscuro (nunca negro), estrellas (más visibles lejos de la luna) y disco de luna.
- **Nubes en el cielo:** una capa de nubes con textura (ruido ya existente `ctex` u otra CC0) que se
  desplaza con `wind`. Cobertura según el clima, igual que hoy: Soleado ~0,45, Nublado ~0,85,
  Lluvia/Tormenta/Nieve ~0,95, grises con mal tiempo. Las sombras de nubes sobre terreno y ciudad
  (`cshadow`) se mantienen y usan la misma cobertura.
- **El plano de nubes actual (`cloud_node`) se quita:** las nubes pasan al cielo. Se mantiene el
  interruptor `g_clouds` (apaga nubes del cielo y sus sombras).
- **Sol:** el color y la intensidad salen de la misma fórmula del cielo: blanco cálido de día y dorado
  y más débil cerca del horizonte. Sombras más suaves de día (`shadow_blur`).
- **Ambiente y reflejos:** `ambient_light_source = SKY` desde el cielo nuevo, con `sky_contribution`
  y energía ajustadas para que no tiña de azul. Reflejos desde el mismo cielo (radiancia actualizada
  de a poco, `Sky.PROCESS_MODE_INCREMENTAL`, para que sea barato).
- **Tonemap AgX** (Godot 4.4+) en lugar de ACES y exposición revisada para día y noche: de noche se
  tiene que seguir viendo la ciudad, con las luces de ventanas y faroles.
- **Ciclo, clima y estaciones:** misma duración (`DAY_SECONDS = 90`), mismos horarios de amanecer y
  atardecer que `update_light()` hoy, misma lógica de clima.

### 2. Terreno (`src/render.gd`: `build_terrain`, `terrain_color`; `shaders/terrain.gdshader`)

- **6 materiales CC0 de ambientCG**, cada uno con color, normales y rugosidad, importados con
  compresión VRAM (ETC2/ASTC): pasto verde, pasto seco, tierra, roca, arena y nieve.
  2K para calidad Alta, 1K para Media (versiones reducidas en el import).
- **Mezcla por celda:** un mapa de mezcla de (N+1)² píxeles RGBA (pasto, arena, roca y tierra) que se
  calcula en `build_terrain` con la misma lógica de tipos que hoy:
  - `T_SAND` → arena; `T_ROCK` o pendiente fuerte → roca; cerca del agua y bajo → tierra húmeda;
  - `T_LAND` → pasto.
  El shader interpola el mapa (sin cuadriculado) y le suma ruido en los bordes para que las
  transiciones no sean rectas.
- **Estación:** un uniform `season_dry` (0 a 1) mezcla pasto verde con pasto seco: verano un poco,
  otoño mucho, invierno apagado, primavera verde. El color de tinte por estación que hoy usa
  `build_terrain` se conserva como multiplicador suave.
- **Nieve:** uniform `snow` (ya existe en el shader de la ciudad) que cubre primero las partes planas
  y deja la roca de las pendientes.
- **Anti-repetición:** muestreo con rotación y desplazamiento por zonas (técnica de "teselas
  aleatorias") + una variación grande de color y brillo que abarca varias cuadras.
- **Relieve suave:** la malla pasa de 1 a 2×2 subdivisiones por celda. Los vértices de las esquinas de
  celda conservan la altura de hoy; los nuevos interpolan con una curva suave. **Celdas con calle,
  zona, edificio, dique o árbol no se tocan** (mantienen el plano de hoy), para que nada quede
  flotando ni enterrado. `ground_y()` (lo usan árboles y matas) no cambia.
- **Zonas no compradas:** en vez de oscurecer 28 %, se desaturan y aclaran un poco ("campo lejano").
- Se mantienen: la textura de alturas `hmap` (la usan el agua y la oclusión de la ciudad) y el borde
  oscuro bajo el agua.

### 3. Agua (`shaders/water.gdshader`)

- **Olas:** dos capas de normales de una textura CC0 de agua, desplazándose en direcciones distintas
  (una sigue a `wind`), más la ondulación de vértices que ya existe.
- **Color por profundidad** (desde `hmap`, como hoy): turquesa claro y algo transparente en la orilla,
  azul verdoso oscuro en lo profundo. El agua pasa a ser semitransparente solo en los primeros ~1,5 m
  de profundidad (ALPHA), así se ve la arena del fondo.
- **Reflejo del cielo** con Fresnel (más reflejo de costado), y **brillo del sol** especular sobre
  las olas, naranja al atardecer.
- **Espuma** con textura en la orilla (profundidad < ~0,5 m) que va y viene, y alrededor de los pilares
  de los puentes (también son "poca profundidad" en `hmap`).
- **Lluvia:** anillos de gotas animados (procedurales) y agua más gris con Lluvia o Tormenta.
- **Noche:** oscura, con reflejo de luna.
- El interruptor `g_water` sigue eligiendo entre el agua nueva y el agua simple.

### 4. Horizonte (`src/render.gd`: `build_outer`)

- Se reemplazan los planos y las esferas por un **anillo de terreno lejano**: una malla en forma de
  anillo alrededor del mapa (desde el borde hasta ~5 veces el tamaño del mapa) con lomas de ruido
  suaves, que usa el mismo material del terreno (pasto, pasto seco y roca).
- En los lados donde el mapa tiene agua en el borde (hoy se detecta en `build_outer`), el anillo baja
  bajo el nivel del agua y el agua sigue hasta el horizonte (el plano de agua ya mide 5× el mapa).
- **Bruma de distancia:** niebla con perspectiva aérea (`fog_aerial_perspective`) que toma el color del
  cielo: azulada de día, dorada al atardecer, oscura de noche. Densidad mayor con mal tiempo y a la
  mañana temprano, como hoy. Interruptor `g_fog` sin cambios.

## Calidad y rendimiento

| Opción | Cielo | Terreno | Agua |
|---|---|---|---|
| Alta (2) | nuevo, nubes | texturas 2K, anti-repetición, malla 2×2 | nueva completa |
| Media (1) | nuevo, nubes | texturas 1K, anti-repetición, malla 2×2 | nueva sin anillos de lluvia ni segunda capa de olas |
| Baja (0) | nuevo, sin nubes | shader de hoy (color por vértice), malla 1×1 | agua simple (`water_simple_mat`) |

- Los interruptores existentes (`g_shadow`, `g_water`, `g_fog`, `g_detail`, `g_clouds`, `g_grade`)
  siguen funcionando y el "Modo seguro" sigue apagando todo lo pesado.
- **Presupuesto (medido acá con el renderer Mobile sobre Vulkan por software, comparando antes y
  después en la misma escena):** costo por cuadro **≤ +25 % en Alta** y **≤ +10 % en Baja**.
- **`build_terrain`** (corre al cambiar de estación, nevar o comprar zona): ≤ 2× el tiempo de hoy.
- **Tamaño:** el `.pck` exportado no puede crecer más de **100 MB**.

## Pruebas

- **Simulación intacta:** `--test=sim` tiene que dar exactamente los mismos números que la referencia
  actual (`godot/tests/reference/sim.log`).
- **Partidas:** `tools/compat_test.sh` sigue pasando (cargar partidas de antes, primer arranque, guardar
  al minimizar).
- **Modo de prueba nuevo `--test=album=<carpeta>`:** con semilla fija saca, con el renderer Mobile,
  capturas de: amanecer, mediodía, atardecer, noche, lluvia, nieve, otoño, y mapas de río, costa e
  islas con cerros. Se generan antes del cambio (álbum "antes") y después ("después").
- **Aprobación visual del autor:** se le pasan los dos álbumes. Cuando lo aprueba, las capturas nuevas
  (renderer Mobile) reemplazan a las de referencia y `run_tests.sh` pasa a usar el renderer Mobile.
- **Medición:** `run_sim` agrega una línea `BENCH frame_ms=…` (promedio de cuadros con el renderer
  Mobile en una escena fija) y `BENCH terrain_ms=…` (tiempo de `build_terrain`).

## Recursos

- Texturas de **ambientCG** (CC0, sin atribución obligatoria) en `godot/assets/terrain/` y
  `godot/assets/water/`. Se anota en `godot/assets/FUENTES.md` de dónde sale cada una (nombre y
  enlace), aunque no sea obligatorio.
- Las versiones 1K se generan con la opción de tamaño máximo de importación de Godot o con un script
  de `tools/`; no se suben dos copias si no hace falta.

## Riesgos

- **Vulkan por software no es una placa de celular:** el aspecto coincide, pero el rendimiento real
  lo confirma el autor en su celular.
- **El tinte azul puede venir también de los materiales de la ciudad** (reflejos del cielo en vidrios
  y asfalto mojado); se revisa con el álbum y se ajusta solo la parte de cielo y ambiente en esta
  etapa.
- **Subdividir el terreno** puede dejar costuras con calles y edificios si la regla de "celdas
  ocupadas no se tocan" tiene huecos; el álbum incluye cerros con calles para verlo.
- **AgX cambia el color de toda la ciudad** (también edificios): se acepta, es parte de arreglar "luz y
  colores", pero si algo queda mal se ajustan exposición y blancos, no los materiales de los edificios.
