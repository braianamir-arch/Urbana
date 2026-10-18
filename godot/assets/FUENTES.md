# Fuentes de los recursos

Todas las texturas de terreno son de **ambientCG** (https://ambientcg.com), licencia **CC0 1.0**
(dominio público: se pueden usar, modificar y vender sin pagar ni dar crédito). Igual se anota de dónde
sale cada una. Se bajan y preparan con `python3 tools/get_textures.py` (2K, color con la rugosidad en el
canal alfa, normales en 1K, y se le saca la variación de luz de gran escala para que no se note la
repetición).

| Material del juego | Archivo | ambientCG |
|---|---|---|
| Pasto | `terrain/grass_*.webp` | Grass004 — https://ambientcg.com/view?id=Grass004 |
| Pasto con parches (seco) | `terrain/dry_*.webp` | Ground037 — https://ambientcg.com/view?id=Ground037 |
| Tierra húmeda | `terrain/dirt_*.webp` | Ground109 — https://ambientcg.com/view?id=Ground109 |
| Roca | `terrain/rock_*.webp` | Rock044 — https://ambientcg.com/view?id=Rock044 |
| Arena | `terrain/sand_*.webp` | Ground080 — https://ambientcg.com/view?id=Ground080 |
| Nieve | `terrain/snow_*.webp` | Snow010A — https://ambientcg.com/view?id=Snow010A |

El agua (`water/water_nrm.webp`, `water/foam.webp`) se genera con ruido en el mismo script; no viene de
ninguna biblioteca.

## Ciudad (etapa 2)

Fachadas, techos y calles salen de dos arreglos de texturas (`city/city_alb.webp`: color con la
rugosidad en el alfa; `city/city_nrm.webp`: normales), una capa de 1024² por material, armados con
`python3 tools/get_textures.py ciudad`. Revoque, chapa y metal se pasan a gris para que tomen el color de
cada edificio. Todos de **ambientCG**, licencia **CC0 1.0**.

| Capa | Material del juego | ambientCG |
|---|---|---|
| 0 | Liso | generado (ruido suave) |
| 1 | Ladrillo visto | Bricks085 — https://ambientcg.com/view?id=Bricks085 |
| 2 | Revoque | Plaster001 — https://ambientcg.com/view?id=Plaster001 |
| 3 | Hormigón | Concrete031 — https://ambientcg.com/view?id=Concrete031 |
| 4 | Tejas coloniales | RoofingTiles006 — https://ambientcg.com/view?id=RoofingTiles006 |
| 5 | Chapa acanalada | CorrugatedSteel005 — https://ambientcg.com/view?id=CorrugatedSteel005 |
| 6 | Madera | WoodSiding005 — https://ambientcg.com/view?id=WoodSiding005 |
| 7 | Metal pintado | Metal027 — https://ambientcg.com/view?id=Metal027 |
| 8 | Asfalto | Asphalt025C — https://ambientcg.com/view?id=Asphalt025C |
| 9 | Baldosas de vereda | PavingStones128 — https://ambientcg.com/view?id=PavingStones128 |
| 10 | Corteza | Bark014 — https://ambientcg.com/view?id=Bark014 |
| 11 | Follaje (copas de árboles; se pasa a gris para teñirla según la estación) | Grass001 — https://ambientcg.com/view?id=Grass001 |
| 12 | Césped corto (canchas, parques) | Grass005 — https://ambientcg.com/view?id=Grass005 |
