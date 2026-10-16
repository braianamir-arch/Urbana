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

> ⚠️ **Antes de instalar el APK nuevo, hacé una copia de tus ciudades.** En el juego: menú →
> **Guardar y cargar** → **Exportar y copiar**, y pegá cada código en un lugar seguro (una nota,
> un mail a vos mismo). Si Android dice que no puede instalar el APK nuevo ("conflicto con un paquete
> existente"), es porque se exportó con otra clave de firma: **no desinstales la app vieja**, porque
> desinstalar borra todas las partidas. Avisá y lo resolvemos; con los códigos copiados no se pierde nada.

## Gráficos (Opciones → Gráficos)

| Calidad | Cielo | Suelo | Agua | Edificios y calles |
|---|---|---|---|---|
| **Alta** | atmósfera con nubes que se mueven | texturas fotográficas mezcladas (pasto, tierra, roca, arena, nieve) y lomas suaves | olas en dos capas, espuma en la orilla y anillos de gotas cuando llueve | ~40 modelos (casas porteñas, departamentos, torres, comercios, fábricas) con ladrillo, revoque, tejas, chapa y vidrio de verdad; de cerca, ventanas hundidas, balcones, rejas y persianas |
| **Media** | igual que Alta | igual que Alta | una capa de olas, sin anillos de lluvia | igual que Alta |
| **Baja** | atmósfera sin nubes | el suelo simple de antes | agua simple | los mismos modelos en su versión simple, con colores lisos |

Árboles (fresno, plátano, jacarandá, pino, palo borracho, palmera, ombú) con copas que cambian con las
estaciones y se mueven con el viento; en la calle, faroles, semáforos, autos estacionados, árboles de
vereda, postes con cables, y —con la cámara acercada— bancos, tachos, canteros, paradas, carteles y
bolardos. Los 51 edificios especiales tienen su propio modelo.

Las calles tienen las marcas pintadas: línea del medio, bordes en avenidas, sendas peatonales y línea
de pare al llegar a cada cruce, parches y tapas de alcantarilla.

La ciudad tiene horario: de madrugada casi todos duermen y hay poca gente y pocos autos; a la mañana
salen a trabajar y los chicos van a la escuela con mochila. Acercando la cámara se ve qué hace la gente
detrás de las ventanas: mirando tele, cocinando, en la oficina frente a la compu, chicos en clase con el
maestro, el que atiende el negocio. Hay humo en las chimeneas, el molino, la vuelta al mundo y la
calesita giran, las fuentes tiran agua y con tormenta caen rayos.

**Sala de computación** (Menú → 🖥 Sala de computación): mide en el celular cuánto tarda cada parte del
juego y dónde se traba, y arma pedidos de mejora listos para pegar en Claude Code (botón "Copiar").
Conviene usar la ciudad un minuto (moverse, hacer zoom, acelerar) antes de abrirla.

Los edificios tienen tres versiones según la distancia. La más detallada (balcones, rejas, marcos)
aparece cuando acercás la cámara; desde la vista normal se ven las fachadas con las ventanas pintadas,
que es mucho más liviano para el celular.

Si algo anda lento o se cierra, en la misma pantalla se pueden apagar por separado: texturas en suelo
y paredes, nubes, agua con ondas, niebla, sombras y "color de cine". El botón **Modo seguro** apaga
todo lo pesado de una vez.

## Cómo está organizado el código

- `src/` tiene el código **separado por tema**: `world.gd` (mapa), `sim.gd` (simulación),
  `build.gd` (construir), `render.gd` (cómo se dibuja), `agents.gd` (autos, gente, cine, humo, rayos),
  `life.gd` (horario de la ciudad y vida en las ventanas), `lab.gd` (sala de computación),
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
