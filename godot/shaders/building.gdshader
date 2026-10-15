// Edificios de URBANA (etapa 2). Cada vértice trae su material (UV2.x) y su máscara de tinte (UV2.y:
// 0 sin tinte, 1 color del edificio, 2 segundo color). Materiales 0-9: capas de las texturas de la ciudad
// (ambientCG) con UV en metros; 10 vidrio, 11 vidrio espejado, 12 oscuro; 13-22: fachada lejana con las
// ventanas dibujadas (13 + material de la pared, UV = (columna, piso)).
// Por instancia: COLOR = color del edificio; INSTANCE_CUSTOM = (quemado, segundo color, semilla, 0).
shader_type spatial;
#include "res://shaders/building.gdshaderinc"
