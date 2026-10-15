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
