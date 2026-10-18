# URBANA Godot — Etapa 2c+2d+2e: árboles, objetos de calle y edificios especiales

Fecha: 2026-10-16 · Estado: diseño acordado en el chat ("vamos con el 1, vos mandale")
Etapas anteriores: 2a+2b (catálogo de modelos generados por código en `godot/src/buildings.gd`, tres
versiones por distancia, `MultiMesh` por bloque y por modelo, texturas ambientCG en `Texture2DArray`,
shader `building.gdshaderinc` con variante liviana).

## Objetivo

Que los árboles, la calle y los 51 edificios especiales dejen de ser cajas y esferas, con el mismo
estilo y la misma técnica que los edificios de la 2b, **sin bajar la fluidez de hoy** en el celular.

## Lo que pidió el autor

- Hacer juntas la 2c (árboles y vegetación), la 2d (objetos de calle) y la 2e (edificios especiales).
- **Misma fluidez que hoy:** los detalles finos solo de cerca; de lejos, versiones simples.
- Árboles con **copas con forma y textura** (tronco con ramas, copa de varios bultos irregulares con
  textura de follaje, forma propia de cada especie, movimiento con el viento).
- Calle: **todo**: faroles y semáforos, autos estacionados, mobiliario de vereda (bancos, tachos,
  paradas de colectivo, bolardos, canteros, árboles de vereda), postes con cables y carteles.
- Edificios especiales: **cada uno único** y reconocible de un vistazo.
- Camino: **todo generado por código** dentro del catálogo (descartados: modelos CC0 de internet, por
  estilo caricatura, peso y falta de modelos porteños; y la mezcla).

## Fuera de alcance

- Forma de las calles (curvas): etapa 3. Autos y gente en movimiento: etapa 4.
- Luces reales (`OmniLight`) por farol: caras en celular; se usa el brillo falso de hoy.
- Simulación, balance y partidas: sin cambios.

## Diseño

### 0. Base común (catálogo ampliado)

- El catálogo de `buildings.gd` pasa a tener cuatro familias: **edificios** (2b), **árboles**,
  **objetos de calle** y **especiales**. Todas usan las mismas recetas en código, las tres versiones
  (cerca / media / lejos), la caché de mallas, la preparación de a poco (`cat_warm_step`) y el volcado
  por bloque en `MultiMesh`.
- Materiales nuevos en el arreglo de texturas: **corteza** y **follaje** (ambientCG, CC0) y **pasto
  corto** para canchas y parques. Los materiales que dibuja solo el shader (vidrio, espejado, oscuro,
  fachada lejana) se renumeran por encima de las capas de textura.
- Shader: el follaje se mueve con el viento (más arriba, más movimiento; usa el interruptor `g_wind`),
  toma el color de la estación por instancia y junta nieve arriba. El vidrio de los semáforos y la cabeza
  de los faroles brillan de noche.
- **Regla de fluidez:** los objetos chicos (bancos, tachos, bolardos, carteles, cables) existen solo en
  la versión cerca (cámara acercada, bloques cercanos), como balcones y rejas en la 2b. Los árboles y los
  autos tienen versión media liviana. Lejos: árboles como un bulto, autos como una caja, nada de mobiliario.

### 1. Árboles (2c)

| Tipo (`tree[i]`) | Especie | Forma |
|---|---|---|
| 1 | Fresno | copa redonda media, tronco recto |
| 2 | Plátano | copa ancha y alta, corteza manchada |
| 3 | Jacarandá | copa ancha y achatada, violeta en primavera |
| 4 | Pino | cono en capas, verde oscuro todo el año |
| 5 | Palo borracho | tronco panzón verde, copa rala, rosado en verano/otoño |
| 6 | Palmera | tronco alto anillado, penacho de hojas largas |
| 7 | Ombú / sauce | copa baja muy ancha, tronco grueso |

- Cada especie tiene **3 variantes** de forma (semilla distinta). Cerca: tronco que se afina y 3–5 ramas,
  copa de 6–12 bultos deformados con textura de follaje. Media: tronco y 3–4 bultos. Lejos: tronco y un bulto.
- **Estaciones** como hoy (`tree_colors`): color de copa y "llenura" (en invierno los de hoja caduca
  quedan ralos y se ven las ramas).
- Dónde: celdas con árbol (como hoy), parques y plazas (los especiales los usan) y **árboles de vereda**
  (2d). El pasto suelto (`emit_grass`) queda como está.

### 2. Calle (2d)

- **Faroles:** columna con brazo y farola; el lugar y la regla de hoy (cada 3 celdas en calles ≥ 2),
  brillo de noche y los charcos de luz de hoy (`lamps`).
- **Semáforos:** en los cruces donde llega una avenida (tipo ≥ 3): un poste por esquina con caja de tres
  luces; el color cambia con el tiempo (en el shader, con desfase por cruce, verde/amarillo/rojo
  coordinados por eje). Solo visual.
- **Autos estacionados:** 5 modelos (sedán, hatchback, camioneta, utilitario, taxi negro y amarillo) en
  las cuadras de calles tipo 2, más en zonas comerciales; misma regla de lugar que hoy, color por instancia.
- **Mobiliario de vereda:** bancos y tachos cerca de comercios y plazas, paradas de colectivo con
  techito donde hay parada, bolardos en esquinas de avenidas, canteros, y **árboles de vereda** en las
  cuadras residenciales (en la vereda, entre lotes y calle).
- **Postes y cables:** poste de madera con cruceta y cables con comba (en tramos) para `W_POWER`;
  **carteles** con nombre de calle en esquinas y señal de PARE en algunos cruces.
- Todo con reglas deterministas (`hsh`), sin tocar la simulación.

### 3. Edificios especiales (2e)

- Un modelo propio por cada uno de los **51** de `DEF` (clave = id), del tamaño de su lote (`sz` × `sz`
  celdas), mirando a la calle (`face_rot`), con sus tres versiones. Cada uno con su "firma" reconocible:
  - Servicios: comisaría (azul, patrulleros), bomberos (portones rojos, torre de mangueras), salita y
    hospital (cruz, guardia con ambulancias, helipuerto en el hospital).
  - Educación: escuela (patio con mástil y bandera), secundaria, universidad (campus con edificios y
    pasto), biblioteca (columnas).
  - Gobierno: municipalidad y casa de gobierno (cabildo con torre y reloj).
  - Ocio y verde: plaza (senderos, bancos, fuente, árboles), parque, cancha (pasto con líneas y arcos),
    parrilla (quincho con humo), calesita, estadio (tribunas y luces), vuelta al mundo, cine (marquesina),
    club de barrio, playa (sombrillas), gran parque.
  - Monumentos: catedral (fachada con torres), faro, reloj, torre mirador, palacio, estadio monumental.
  - Energía y servicios públicos: usina a carbón (chimeneas, carbón), central de gas (tanques
    esféricos), parque solar (paneles), molino eólico (aspas), represa, bomba de agua, torre de agua,
    potabilizadora (piletas), relleno sanitario, planta de reciclaje, incinerador.
  - Transporte: estación de subte (boca con escalera), estación de tren (andenes y techo), puerto
    (grúas y contenedores), aeropuerto (terminal, torre de control, pista), muelle de ferry,
    estacionamiento (autos en filas).
  - Otros: hotel, gran hotel, shopping, barrio cerrado (casas con pileta y muro), chacra (granero y
    surcos), frigorífico, basurero.
- Lo que hoy se anima (aspas, vuelta al mundo, calesita, humo) sigue animado como hoy.
- Las **maravillas en construcción** (andamio y grúa según avance) quedan como hoy.
- Quemado: oscurecido como los demás edificios.

### 4. Rendimiento

- Mismos bloques y nodos `MultiMesh` que la 2b; las claves nuevas se crean solo si el bloque las usa.
- **Presupuestos** (contra la versión de hoy, renderer Mobile en esta máquina):
  - cuadro **≤ +5 %** en Alta; **Baja ≤ +0 %** (medido alternando con la versión anterior);
  - rehacer los bloques (`BENCH chunks_ms`) **≤ 1,3×**;
  - catálogo completo **≤ 4 s** (se prepara de a poco; al arrancar solo media y lejos de lo que se usa);
  - `.pck` **≤ +15 MB**.

## Pruebas

- **Simulación intacta:** líneas `SIM ` idénticas; `compat_test.sh` pasa.
- `CATALOG_CHECK` para las familias nuevas: 3 versiones sin error, huella dentro del lote (`sz` celdas
  para especiales; la celda para árboles y objetos), alturas en rango por familia, lejos más liviano que cerca.
- **`TREE_CHECK`:** cada celda con árbol tiene sus instancias de la especie que corresponde; ninguna en
  celdas sin árbol.
- **`SPECIAL_CHECK`:** cada edificio especial (ancla, `part < 0` o `part == i`) tiene exactamente una
  instancia de **su** modelo; los 51 ids tienen receta.
- **`PROP_CHECK`:** faroles donde hoy hay `lamps`; semáforos solo en cruces con avenida; autos y
  mobiliario solo en celdas de calle o vereda, nunca sobre lotes ni agua.
- **Álbum:** las tomas de antes más: árboles de cerca en primavera, otoño e invierno; calle de cerca de
  día y de noche (faroles y semáforos); hojas del catálogo de árboles, objetos y especiales (3 hojas);
  toma de cerca de una zona con especiales. Chequeos nuevos: de noche hay luces en la toma de calle; en
  primavera aparece violeta (jacarandá) en la toma de árboles.
- **Aprobación visual del autor** por partes (árboles, calle, especiales).

## Riesgos

- **Muchos objetos chicos** (mobiliario, carteles): por eso existen solo en la versión cerca.
- **51 recetas** es mucho trabajo: se hacen por grupos; si alguna queda floja se mejora después.
- **Animados de hoy** (aspas, calesita, rueda): hay que ubicar dónde se animan y conservarlos.
