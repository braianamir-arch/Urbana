# URBANA Godot — hoja de ruta

| Etapa | Qué | Estado |
|---|---|---|
| 0 | Proyecto base en `godot/`, pruebas automáticas | hecha |
| 1 | Luz, cielo, terreno y agua | hecha |
| 2a+2b | Materiales reales y edificios con volumen | hecha, falta la aprobación del autor |
| 2c+2d+2e | Árboles, objetos de calle y los 51 edificios especiales | hecha, falta la aprobación del autor |
| Próxima | Sala de computación (medir el rendimiento en el celular y armar pedidos para Claude Code) | pendiente |
| 3 | Calles con curvas (splines) e intersecciones | pendiente |
| 4 | Tránsito y gente animada | pendiente |
| 5 | Físicas y efectos | pendiente |

## Ideas anotadas para la etapa 4 (pedidas por el autor)

- **Gente con rutina y lugar propio:** cada habitante tiene casa, y trabajo o escuela, y un horario
  (duerme de noche, estudia de mañana, trabaja, vuelve). Nadie está en dos lugares a la vez y nadie
  estudia a las 3 de la mañana.
- **Vida detrás de las ventanas:** según quién esté adentro y la hora, en las ventanas se ve qué hace:
  mirando tele, cocinando, limpiando; en la escuela, chicos en clase con el maestro; en oficinas, gente
  trabajando. Base ya lista desde la etapa 2: cada ventana tiene su número propio y las luces dependen de
  la hora.

## Sala de computación (pedida por el autor)

Un edificio especial con personitas en computadoras. El juego mide **en el celular** cuánto tarda cada
parte (simulación, autos y gente, dibujo, sombras), dónde se traba y qué problemas tiene la ciudad, y arma
una **lista de mejoras escritas como pedidos para Claude Code**, con un botón "Copiar". Sin internet ni
costo. Más adelante, opcional: con una clave de la API de Anthropic, que además le pregunte a Claude.
