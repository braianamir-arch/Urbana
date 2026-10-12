# URBANA Godot

Proyecto de Godot **4.7** de URBANA, pensado para celular Android.

## Abrirlo y exportar el APK

1. En GitHub, botón verde **Code → Download ZIP**. Descomprimí el ZIP y quedate con la carpeta `godot/`.
2. Abrí Godot 4.7. En la ventana de inicio tocá **Importar** y elegí el archivo `godot/project.godot`.
3. **Proyecto → Exportar…** → preset **Android** → **Exportar proyecto** (como hacías antes).

### Para que aparezcan tus partidas de antes

Android guarda las partidas por **nombre de paquete**. Si el APK nuevo tiene otro nombre, se instala
como una app aparte y no ve tus ciudades.

- Este proyecto usa el nombre que Godot pone por defecto: `com.example.$genname`.
- Si tu APK anterior usaba otro (lo ves en tu proyecto viejo: **Proyecto → Exportar → Android →
  Package → Unique Name**), poné ese mismo acá antes de exportar.

## Cómo está organizado el código

- `src/` tiene el código **separado por tema**: `world.gd` (mapa), `sim.gd` (simulación),
  `build.gd` (construir), `render.gd` (cómo se dibuja), `agents.gd` (autos, gente, cine),
  `camera.gd`, `ui.gd`, `audio.gd`, `save.gd`, `tests.gd`, `main.gd` y `state.gd` (lo compartido).
- `scripts/main.gd` es **el único script que usa Godot**. Se arma juntando los archivos de `src/` con
  `python3 tools/godot_modules.py build`. Por eso **no conviene editarlo a mano**: el próximo armado lo
  pisa. Si querés cambiar algo, avisá y se cambia en `src/`.
- `shaders/` tiene los shaders (antes estaban como texto dentro del script).
- `tests/` tiene las capturas de referencia de las pruebas automáticas (no van dentro del APK).

¿Por qué no usar varios scripts sueltos? Se probó: hacía la simulación hasta un 70 % más lenta en
cada acceso entre scripts. Juntos en uno, rinde igual que el original.

## Pruebas (en la compu de desarrollo)

```
tools/get_godot.sh                     # baja Godot 4.7 para las pruebas
python3 tools/godot_modules.py build   # arma scripts/main.gd desde src/
tools/run_tests.sh out/prueba          # corre todo y saca capturas
python3 tools/compare.py godot/tests/reference out/prueba   # compara con la referencia
tools/compat_test.sh                   # partidas guardadas con la versión vieja cargan igual
```
