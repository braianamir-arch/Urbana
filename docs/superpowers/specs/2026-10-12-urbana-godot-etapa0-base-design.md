# URBANA Godot — Etapa 0: base del proyecto

Fecha: 2026-10-12 · Estado: diseño aprobado en el chat, pendiente de revisión escrita

## Contexto

URBANA Godot es hoy un único script (`extends Node3D`, ~3.700 líneas) que el autor pega en
Godot 4.7 y exporta como APK para Android. No está en ningún repositorio. El objetivo general
es llevarlo a un aspecto parecido a Cities: Skylines en celular, en 6 etapas:

| Etapa | Contenido |
|---|---|
| **0** | **Base: proyecto en el repo, código separado en módulos, pruebas con capturas** |
| 1 | Luz, cielo, terreno y agua realistas |
| 2 | Edificios y objetos con texturas PBR (fachadas modulares + bibliotecas CC0), LOD |
| 3 | Calles con curvas (splines), intersecciones y rotondas reales |
| 4 | Tránsito por carriles, aceleración, semáforos, peatones animados |
| 5 | Choques con física, derrumbes, viento, humo y fuego |

Decisiones ya tomadas para todo el proyecto:
- Plataforma: **Android**, renderer **Mobile** de Godot 4.7.
- Modelos y texturas: **bibliotecas gratuitas CC0** (Poly Haven, ambientCG, Kenney, Quaternius).
- Camino elegido: **"piel nueva sobre la misma simulación"**: la simulación no cambia; se reemplaza
  cómo se dibuja y cómo se mueve.

Este documento cubre solo la **etapa 0**.

## Objetivo

Dejar el proyecto en `godot/` dentro de este repo, separado en módulos con responsabilidades
claras, **sin cambiar en nada cómo se ve ni cómo se juega**, y con pruebas automáticas que lo
demuestren. Es la base para que las etapas 1–5 reemplacen piezas (sobre todo el render) sin
tocar la simulación.

## Fuera de alcance

- Cualquier cambio visual, de jugabilidad o de balance.
- Cambiar el formato de las partidas guardadas.
- Arreglar bugs existentes (si aparecen, se anotan para después; no se arreglan en esta etapa).
- Firmar el APK o subir claves de firma al repo.

## Estructura

> **Cambio durante la implementación (2026-10-12):** la separación con autoload `G` y módulos
> como nodos hacía la simulación un **70 % más lenta** (cada acceso a `G.x` es una búsqueda por
> nombre), y una variante con herencia en capas costaba entre 6 % y 22 %. Se reemplazó por:
> **el código se edita en `godot/src/*.gd` (un archivo por tema) y `tools/godot_modules.py build`
> los junta en `godot/scripts/main.gd`**, el único script que usa Godot. En ejecución es el mismo
> script de siempre (mismo rendimiento, medido); para trabajar, cada tema está en su archivo.
> No hay `G` ni `Data`: los nombres no cambian. Lo compartido entre temas vive en `src/state.gd`.
> `run_tests.sh` falla si `main.gd` no coincide con `src/` (por ejemplo, si se editó a mano).

```
godot/
  project.godot        Godot 4.7, renderer Mobile, nombre URBANA, ícono, orientación sensor
  export_presets.cfg   preset Android sin datos de firma
  main.tscn            nodo raíz Node3D con main.gd
  icon.png             ícono de la versión web (icon-512.png)
  scripts/
    state.gd           autoload "G": todo el estado compartido (arrays del mapa, plata, día, opts…)
    data.gd            constantes: DEF, STAGES, DECREES, DECISIONS, OBJECTIVES, MOVIES, colores…
    world.gd           idx/cx/cz/cell_pos, gen_map, compute_wdist, árboles, utilidades de celdas
    sim.gd             sim_process, run_sim_stage, compute_*, grow_zones, new_day y daily_*
    build.gd           herramientas: apply_cells, place_def, demoler, rotondas, paradas, líneas, deshacer
    render.gd          setup_render, terreno, chunks, em(), emit_*, overlay, preview, luz, clima visual
    agents.gd          autos, peatones, servicios, colectivos/trenes, barcos, aviones, cine, partículas, choques
    camera.gd          cámara, intro, paseo en auto, seguir vecino, entrada táctil/mouse/teclado
    ui.gd              HUD, abanico, bandejas, hojas, tarjetas, tutorial, pantalla de inicio, íconos SVG
    audio.gd           sonidos y música generados
    save.gd            snapshot, guardar/cargar, código URB1, migración de partidas viejas, opciones
    tests.gd           modos --test existentes + modo nuevo de números
  shaders/
    city.gdshader  water.gdshader  terrain.gdshader  cloud.gdshader  glow.gdshader  overlay.gdshader
  assets/              vacío (lo usan las etapas 1 y 2)
```

### Cómo se comunican los módulos

- **`G` (autoload, `state.gd`)** guarda el estado del juego: los `PackedArray` del mapa, `money`,
  `day`, `pop`, `opts`, `lines`, etc. Todos los módulos leen y escriben ahí.
- `main.gd` crea los módulos como nodos hijos, guarda referencias en `G` (`G.sim`, `G.render`,
  `G.ui`, …) y en `_process` llama a cada uno en el mismo orden que hoy.
- Las llamadas entre módulos van por esas referencias: por ejemplo `G.ui.toast(...)`,
  `G.render.mark_dirty(i)`, `G.audio.sfx("build")`.
- Las constantes viven en `data.gd` como `class_name Data` y se usan como `Data.DEF`.
- Regla: **solo se mueve código**. La lógica de cada función queda igual; únicamente cambian los
  nombres para alcanzar el estado o el módulo correcto (`money` → `G.money`, `toast()` →
  `G.ui.toast()`).

### Pensado para las etapas siguientes

- `render.gd` es el único que sabe cómo se dibuja una celda. En la etapa 2 se reemplaza por
  completo sin tocar `sim.gd`.
- `agents.gd` es el único que mueve vehículos y gente. La etapa 4 lo reemplaza.
- `world.gd` es el único que sabe de la grilla. La etapa 3 (splines) lo extiende.

## Compatibilidad

- Partidas guardadas: mismo formato (`SAVE_VERSION = 1`) y mismos archivos en `user://`
  (`urbana_N.json`, `.bak`, `opciones.json`, `ultimo_paso.txt`). Una partida hecha con el APK
  actual se tiene que poder cargar con el nuevo.
- Los códigos `URB1:` exportados siguen funcionando en los dos sentidos.

## Verificación

1. **Línea de base.** Primer commit: el script tal como lo pegó el autor, guardado entero en
   `godot/scripts/main.gd` con un `project.godot` mínimo. Se corre con Godot 4.7 en esta máquina
   (Xvfb + OpenGL por software, renderer Compatibility) y se guardan:
   - las capturas de los modos de prueba existentes (`ui=`, `city=`, `fx=`, `roads=`),
   - los números de un modo nuevo `--test=sim`: semilla fija, ciudad de prueba armada con
     `test_build()`, 30 días simulados, e imprime población, plata, empleos, felicidad,
     luz/agua y cantidad de líneas.
2. **Después de separar.** Se corren las mismas pruebas.
   - Los números de `--test=sim` tienen que ser **idénticos**.
   - Las capturas se comparan píxel a píxel. Se aceptan diferencias solo en lo que es aleatorio
     por cuadro (posición de autos y peatones, partículas); el resto (terreno, edificios, calles,
     interfaz) tiene que coincidir.
3. **Carga de partidas.** Una partida guardada por la línea de base se carga con la versión
   separada y da los mismos números.
4. **En el celular.** El autor exporta el APK con el renderer Mobile y confirma que arranca,
   que una partida suya se carga y que se juega igual que antes.

Las pruebas que necesitan semilla fija la ponen en `tests.gd`. El juego normal no cambia.

## Riesgos

- **Orden de inicialización.** Hoy todo se inicializa en `_ready` de un solo nodo. Con módulos,
  `main.gd` tiene que crearlos y configurarlos en el mismo orden (render → cámara → agentes →
  calidad → audio → interfaz). Si algún módulo se usa antes de existir, falla la prueba.
- **Clases y lambdas internas.** `Chart` (clase interna) va a `ui.gd`; las lambdas que capturan
  variables siguen funcionando mientras sigan dentro del mismo módulo que esas variables.
- **Renderer distinto en las pruebas.** Las capturas de esta máquina usan Compatibility y no
  Mobile: sirven para comparar antes y después, no para juzgar cómo se ve en el celular.
- **El script pegado podría no ser exactamente el que corre en el celular.** El autor confirma
  que la línea de base se comporta igual que su APK actual.

## Entrega

- Todo en la rama de trabajo, en commits chicos: línea de base, separación por módulos y pruebas.
- Al final: instrucciones cortas para bajar `godot/`, importarlo en Godot 4.7 y exportar el APK.
