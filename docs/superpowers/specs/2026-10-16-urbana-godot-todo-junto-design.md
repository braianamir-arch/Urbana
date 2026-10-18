# URBANA Godot — "todo junto": sala de computación y etapas 3, 4 y 5

El autor pidió hacer las etapas que faltan todas juntas, sin más preguntas ("mete todas juntas, ya fue").
Las decisiones de diseño las tomé yo y quedan anotadas acá. La regla que vale para todo es la misma de la
etapa 2: **misma fluidez**, sin pérdida de cuadros por segundo comparado con lo que hay hoy.

## A. Sala de computación

- Un medidor siempre prendido y barato: unas pocas lecturas del reloj por cuadro. Mide por partes:
  simulación, autos y gente, bloques de la ciudad, cámara y luz, interfaz, y el resto del cuadro (dibujo).
  Guarda los últimos 600 cuadros y anota cada trabón (un cuadro de más de 25 ms y 1,5 veces el normal), con la
  parte que más tardó y si la cámara se estaba moviendo o haciendo zoom.
- También anota draw calls, objetos, triángulos, memoria de video, calidad, resolución y modelo del
  celular, y si la vez anterior el juego se cerró sin cierre limpio (archivo `ultimo_paso.txt`).
- Se abre en Menú → "🖥 Sala de computación". Arriba se ve una sala dibujada con tres personitas en
  computadoras, cada una con su tarea. Abajo, la lista de mejoras: cada una con título, explicación corta y
  un botón "📋 Copiar" que copia un pedido completo para Claude Code (contexto del proyecto, números
  medidos y qué hay que hacer). Además "📋 Copiar todo" y "🔄 Medir de nuevo".
- Las reglas que arman los pedidos: cuadro lento y qué parte pesa más; muchos trabones y en qué parte; muchas
  draw calls; memoria alta; cierre inesperado. Siempre hay un "Informe completo".
- Sin internet. Prueba: modo `--test=vida` (LAB_CHECK).

## B. Etapa 3: calles realistas

Las calles siguen en la cuadrícula de la simulación (cambiar a calles libres con curvas obligaría a rehacer
la simulación, los caminos de los autos y las partidas guardadas). Lo que cambia es cómo se ven, sin
instancias nuevas: todo se pinta en el shader del asfalto con datos que viajan en la misma instancia.

- Línea central discontinua en las calles comunes, doble línea amarilla en avenidas, líneas de borde.
- Sendas peatonales (cebra) y línea de pare en cada llegada a un cruce.
- Desgaste del asfalto: parches, manchas de aceite en el centro del carril y tapas de alcantarilla.
- Las esquinas ya tenían el giro curvo; las calles de tierra no llevan marcas.
- Prueba: ROAD_CHECK (cada calle recta lleva sus datos; cada cruce lleva cebras hacia sus llegadas).

## C. Etapa 4: gente con rutina y vida detrás de las ventanas

- Horario de la ciudad (de lunes a viernes y fin de semana): qué parte de la gente está en casa, en el
  trabajo, en la escuela o en la calle a cada hora. Sale de una sola tabla, así nadie está en dos lugares a
  la vez: si el 70 % está trabajando, las casas están más vacías; a las 3 de la mañana casi todos duermen y
  nadie está en la escuela.
- Cada edificio lleva su uso en el dato del modelo (casa, comercio, oficina, industria, escuela,
  hospital...). El shader de cerca dibuja, en las ventanas ocupadas, lo que hace la gente: tele (luz azul que
  titila), cocina (luz cálida y una persona de pie), alguien en el sillón; en oficinas, personas frente a
  monitores; en la escuela, filas de chicos y el pizarrón con el maestro; en negocios, vendedor y clientes.
  De lejos solo cambia cuántas ventanas se prenden según la ocupación.
- La calle sigue el mismo horario: más autos y gente en las horas pico, chicos con mochila a la hora de
  entrar y salir de la escuela, casi nadie de madrugada.
- Prueba: LIFE_CHECK (la tabla suma 1 a cada hora, nadie estudia de madrugada, el uso de cada edificio).

## D. Etapa 5: efectos

- Humo que sale de chimeneas de industrias y de la usina, empujado por el viento.
- Partes que giran en los especiales que tienen: aspas de molino o eólicos, vuelta al mundo, calesita.
- Rayos y relámpagos con tormenta.
- Agua de fuentes saltando.
- El humo, el agua y el rayo usan el sistema de cosas dinámicas que ya existe y solo cerca de la cámara.
  Las partes que giran no cuestan nada en el procesador: el modelo las marca y el shader las hace girar.
- Prueba: FX2_CHECK.

## E. Arreglos chicos pendientes

Los anotados en las etapas anteriores que se pueden cerrar sin riesgo, más la medición antes/después, el
álbum y la revisión final.
