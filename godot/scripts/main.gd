extends Node3D
# ARCHIVO GENERADO: no editar a mano.
# Se arma juntando godot/src/*.gd con: python3 tools/godot_modules.py build
# ================================================================ src/state.gd
# Estado compartido y constantes (lo usan varios módulos).
const N := 128
const CELL := 4.0
const NCH := N / CH
const REG := 32
const NREG := N / REG
const WATER_Y := -0.45
const DAY_SECONDS := 90.0
const SEASONS := ["Verano", "Otoño", "Invierno", "Primavera"]
const T_LAND := 0
const T_WATER := 1
const T_SAND := 2
const T_ROCK := 3
const ROAD_COST := [0, 5, 12, 30, 70]
const Z_R := 1
const Z_C := 2
const Z_I := 3
const Z_M := 4
const ZONE_COST := 4
const CAP_C := [0, 5, 12, 26, 56]
const CAP_I := [0, 8, 18, 34, 60]
const W_POWER := 1
const W_PIPE := 2
const W_BIKE := 4
const W_TRAM := 8
const W_ROUND := 16
const W_LEVEE := 32
const CV_POL := 0
const CV_FIRE := 1
const CV_HEALTH := 2
const CV_EDU1 := 3
const CV_EDU2 := 4
const CV_EDU3 := 5
const CV_PARK := 6
const CV_TRANSIT := 7
const CV_GARB := 8
const NCV := 9
const STAGES := [
	["Pueblo", 0], ["Villa", 150], ["Ciudad chica", 400], ["Ciudad", 1000],
	["Ciudad grande", 2500], ["Metrópolis chica", 6000], ["Metrópolis", 12000],
	["Gran metrópolis", 25000], ["Megaciudad", 50000], ["Capital", 100000],
]
const DEF := {
	20: {"n": "Comisaría", "c": "serv", "cost": 1500, "upk": 30, "sz": 1, "st": 0, "dep": 0, "cov": {0: 12}, "cap": 3500, "job": 20, "col": Color(0.25, 0.35, 0.75), "sh": "civic"},
	21: {"n": "Bomberos", "c": "serv", "cost": 1800, "upk": 30, "sz": 1, "st": 0, "dep": 1, "cov": {1: 13}, "cap": 5000, "job": 20, "col": Color(0.85, 0.2, 0.15), "sh": "civic"},
	22: {"n": "Salita", "c": "serv", "cost": 1000, "upk": 15, "sz": 1, "st": 0, "dep": 2, "cov": {2: 8}, "cap": 1200, "job": 10, "col": Color(0.95, 0.95, 0.95), "sh": "civic"},
	23: {"n": "Hospital", "c": "serv", "cost": 3000, "upk": 80, "sz": 2, "st": 2, "dep": 2, "cov": {2: 16}, "cap": 3000, "job": 80, "col": Color(0.92, 0.92, 0.95), "sh": "tower"},
	24: {"n": "Escuela", "c": "serv", "cost": 2500, "upk": 25, "sz": 1, "st": 0, "dep": 3, "cov": {3: 10}, "cap": 2200, "job": 25, "col": Color(0.95, 0.8, 0.35), "sh": "civic"},
	25: {"n": "Secundaria", "c": "serv", "cost": 4000, "upk": 60, "sz": 2, "st": 2, "dep": 3, "cov": {4: 14}, "cap": 3000, "job": 50, "col": Color(0.9, 0.7, 0.3), "sh": "civic"},
	26: {"n": "Universidad", "c": "serv", "cost": 14000, "upk": 200, "sz": 3, "st": 4, "dep": 3, "cov": {5: 24}, "cap": 8000, "job": 150, "col": Color(0.75, 0.45, 0.3), "sh": "campus", "tour": 2},
	27: {"n": "Biblioteca", "c": "serv", "cost": 1600, "upk": 15, "sz": 1, "st": 1, "dep": 3, "cov": {3: 8, 4: 6}, "cap": 1200, "job": 8, "hp": 0.02, "col": Color(0.6, 0.45, 0.35), "sh": "civic"},
	28: {"n": "Municipalidad", "c": "serv", "cost": 10000, "upk": 50, "sz": 2, "st": 3, "unique": true, "job": 60, "appr": 0.04, "col": Color(0.95, 0.9, 0.8), "sh": "cabildo", "tour": 3},
	29: {"n": "Casa de gobierno", "c": "serv", "cost": 24000, "upk": 90, "sz": 2, "st": 6, "unique": true, "job": 80, "appr": 0.06, "col": Color(0.9, 0.6, 0.65), "sh": "cabildo", "tour": 6},
	30: {"n": "Plaza", "c": "park", "cost": 400, "upk": 2, "sz": 1, "st": 0, "dep": 4, "cov": {6: 5}, "hp": 0.02, "col": Color(0.35, 0.65, 0.3), "sh": "park"},
	31: {"n": "Parque", "c": "park", "cost": 200, "upk": 6, "sz": 2, "st": 1, "dep": 4, "cov": {6: 9}, "hp": 0.04, "col": Color(0.3, 0.62, 0.28), "sh": "park"},
	32: {"n": "Cancha", "c": "park", "cost": 1000, "upk": 4, "sz": 2, "st": 0, "dep": 4, "cov": {6: 6}, "hp": 0.03, "sunday": 60, "col": Color(0.25, 0.6, 0.3), "sh": "pitch"},
	33: {"n": "Parrilla", "c": "park", "cost": 400, "upk": 1, "sz": 1, "st": 0, "dep": 4, "cov": {6: 3}, "hp": 0.02, "sunday": 25, "col": Color(0.45, 0.25, 0.15), "sh": "parrilla"},
	34: {"n": "Calesita", "c": "park", "cost": 600, "upk": 2, "sz": 1, "st": 0, "dep": 4, "cov": {6: 4}, "hp": 0.03, "col": Color(0.9, 0.4, 0.7), "sh": "calesita"},
	35: {"n": "Estadio", "c": "park", "cost": 16000, "upk": 120, "sz": 3, "st": 4, "dep": 4, "cov": {6: 12}, "hp": 0.06, "tour": 12, "job": 60, "col": Color(0.8, 0.8, 0.85), "sh": "stadium"},
	36: {"n": "Vuelta al mundo", "c": "park", "cost": 18000, "upk": 30, "sz": 2, "st": 3, "dep": 4, "cov": {6: 8}, "hp": 0.04, "tour": 8, "col": Color(0.9, 0.3, 0.3), "sh": "wheel"},
	37: {"n": "Catedral", "c": "park", "cost": 22000, "upk": 20, "sz": 2, "st": 3, "dep": 4, "cov": {6: 6}, "hp": 0.03, "tour": 7, "col": Color(0.85, 0.8, 0.7), "sh": "cathedral"},
	38: {"n": "Faro", "c": "park", "cost": 3500, "upk": 8, "sz": 1, "st": 2, "dep": 4, "tour": 3, "need": "shore", "col": Color(0.95, 0.95, 0.95), "sh": "lighthouse"},
	39: {"n": "Reloj", "c": "park", "cost": 1600, "upk": 4, "sz": 1, "st": 1, "dep": 4, "cov": {6: 4}, "hp": 0.02, "tour": 1, "col": Color(0.7, 0.6, 0.45), "sh": "clock"},
	40: {"n": "Playa", "c": "park", "cost": 600, "upk": 3, "sz": 1, "st": 1, "dep": 4, "cov": {6: 5}, "hp": 0.02, "tour": 4, "need": "sand", "col": Color(0.95, 0.85, 0.55), "sh": "beach"},
	41: {"n": "Club de barrio", "c": "park", "cost": 1000, "upk": 5, "sz": 1, "st": 0, "dep": 4, "cov": {6: 5}, "hp": 0.03, "col": Color(0.3, 0.45, 0.8), "sh": "civic"},
	42: {"n": "Usina a carbón", "c": "util", "cost": 6000, "upk": 60, "sz": 2, "st": 0, "pw": 900, "pol": 1.0, "job": 40, "col": Color(0.4, 0.38, 0.36), "sh": "plant"},
	43: {"n": "Central de gas", "c": "util", "cost": 9000, "upk": 70, "sz": 2, "st": 2, "pw": 1100, "pol": 0.5, "job": 40, "col": Color(0.6, 0.6, 0.65), "sh": "plant"},
	44: {"n": "Parque solar", "c": "util", "cost": 12000, "upk": 20, "sz": 2, "st": 3, "pw": 400, "col": Color(0.15, 0.2, 0.4), "sh": "solar"},
	45: {"n": "Molino eólico", "c": "util", "cost": 2400, "upk": 8, "sz": 1, "st": 2, "pw": 160, "col": Color(0.95, 0.95, 0.95), "sh": "windmill"},
	46: {"n": "Represa", "c": "util", "cost": 18000, "upk": 60, "sz": 2, "st": 4, "pw": 2600, "need": "shore", "job": 30, "col": Color(0.7, 0.7, 0.72), "sh": "dam"},
	47: {"n": "Bomba de agua", "c": "util", "cost": 900, "upk": 15, "sz": 1, "st": 0, "wt": 500, "need": "shore", "col": Color(0.3, 0.55, 0.85), "sh": "pump"},
	48: {"n": "Torre de agua", "c": "util", "cost": 1200, "upk": 12, "sz": 1, "st": 0, "wt": 260, "col": Color(0.55, 0.65, 0.8), "sh": "watertower"},
	49: {"n": "Potabilizadora", "c": "util", "cost": 8000, "upk": 50, "sz": 2, "st": 3, "wt": 2500, "job": 30, "col": Color(0.4, 0.6, 0.8), "sh": "plant"},
	50: {"n": "Relleno sanitario", "c": "util", "cost": 1200, "upk": 25, "sz": 2, "st": 1, "dep": 6, "gb": 1800, "pol": 0.6, "cov": {8: 30}, "col": Color(0.45, 0.4, 0.3), "sh": "landfill"},
	51: {"n": "Planta de reciclaje", "c": "util", "cost": 5000, "upk": 40, "sz": 2, "st": 3, "dep": 6, "gb": 1400, "pol": 0.15, "cov": {8: 30}, "job": 40, "col": Color(0.3, 0.6, 0.4), "sh": "plant"},
	52: {"n": "Incinerador", "c": "util", "cost": 10000, "upk": 60, "sz": 2, "st": 4, "dep": 6, "gb": 2600, "pw": 200, "pol": 0.7, "cov": {8: 30}, "job": 30, "col": Color(0.5, 0.35, 0.3), "sh": "plant"},
	66: {"n": "Cine", "c": "park", "cost": 3500, "upk": 15, "sz": 1, "st": 1, "dep": 4, "cov": {6: 6}, "hp": 0.03, "tour": 3, "job": 20, "col": Color(0.6, 0.1, 0.12), "sh": "cinema"},
	65: {"n": "Basurero", "c": "util", "cost": 500, "upk": 6, "sz": 1, "st": 0, "dep": 6, "gb": 300, "pol": 0.2, "cov": {8: 14}, "col": Color(0.3, 0.3, 0.2), "sh": "civic"},
	53: {"n": "Estación de subte", "c": "trans", "cost": 8000, "upk": 20, "sz": 1, "st": 3, "dep": 5, "cov": {7: 7}, "stop": "metro", "col": Color(0.2, 0.4, 0.8), "sh": "metro"},
	54: {"n": "Estación de tren", "c": "trans", "cost": 9000, "upk": 30, "sz": 2, "st": 2, "dep": 5, "cov": {7: 9}, "stop": "train", "trade": true, "col": Color(0.6, 0.35, 0.25), "sh": "station"},
	55: {"n": "Puerto", "c": "trans", "cost": 32000, "upk": 60, "sz": 2, "st": 3, "need": "shore", "trade": true, "job": 80, "pol": 0.3, "col": Color(0.5, 0.45, 0.4), "sh": "port"},
	56: {"n": "Aeropuerto", "c": "trans", "cost": 30000, "upk": 150, "sz": 3, "st": 5, "trade": true, "tour": 15, "job": 150, "pol": 0.5, "col": Color(0.75, 0.75, 0.78), "sh": "airport"},
	57: {"n": "Muelle de ferry", "c": "trans", "cost": 3000, "upk": 10, "sz": 1, "st": 2, "dep": 5, "need": "shore", "cov": {7: 6}, "stop": "ferry", "col": Color(0.55, 0.4, 0.3), "sh": "pier"},
	58: {"n": "Estacionamiento", "c": "trans", "cost": 600, "upk": 3, "sz": 1, "st": 1, "park": true, "col": Color(0.35, 0.35, 0.37), "sh": "parking"},
	59: {"n": "Hotel", "c": "tour", "cost": 4500, "upk": 10, "sz": 1, "st": 2, "bed": 200, "job": 30, "col": Color(0.8, 0.7, 0.55), "sh": "tower"},
	60: {"n": "Gran hotel", "c": "tour", "cost": 10000, "upk": 30, "sz": 2, "st": 4, "bed": 800, "job": 90, "tour": 3, "col": Color(0.85, 0.75, 0.6), "sh": "tower"},
	61: {"n": "Shopping", "c": "tour", "cost": 7000, "upk": 25, "sz": 2, "st": 3, "job": 160, "tour": 3, "col": Color(0.75, 0.75, 0.85), "sh": "mall"},
	62: {"n": "Barrio cerrado", "c": "tour", "cost": 6000, "upk": 5, "sz": 2, "st": 3, "res": 60, "col": Color(0.9, 0.85, 0.75), "sh": "gated"},
	63: {"n": "Chacra", "c": "tour", "cost": 1400, "upk": 5, "sz": 2, "st": 0, "food": 80, "job": 15, "col": Color(0.75, 0.65, 0.3), "sh": "farm"},
	64: {"n": "Frigorífico", "c": "tour", "cost": 5000, "upk": 20, "sz": 2, "st": 2, "prod": 60, "job": 70, "pol": 0.4, "col": Color(0.7, 0.7, 0.7), "sh": "plant"},
	70: {"n": "Torre Mirador", "c": "wonder", "cost": 12000, "upk": 30, "sz": 2, "st": 5, "tour": 20, "hp": 0.05, "cov": {6: 14}, "col": Color(0.8, 0.85, 0.95), "sh": "w_tower"},
	71: {"n": "Gran Parque", "c": "wonder", "cost": 10000, "upk": 30, "sz": 3, "st": 5, "tour": 16, "hp": 0.08, "cov": {6: 20}, "col": Color(0.25, 0.6, 0.25), "sh": "w_park"},
	72: {"n": "Estadio Monumental", "c": "wonder", "cost": 25000, "upk": 60, "sz": 3, "st": 6, "tour": 25, "hp": 0.06, "cov": {6: 16}, "col": Color(0.95, 0.95, 0.95), "sh": "w_stadium"},
	73: {"n": "Palacio", "c": "wonder", "cost": 16000, "upk": 40, "sz": 3, "st": 6, "tour": 22, "hp": 0.05, "appr": 0.05, "cov": {6: 12}, "col": Color(0.95, 0.85, 0.7), "sh": "w_palace"},
}
const WONDER_FUND := 2500
const WONDER_STEPS := 6
const CATS := [
	["roads", "Calles"], ["zones", "Zonas"], ["serv", "Servicios"],
	["infra", "Infra"], ["work", "Trabajo"], ["fun", "Ocio"], ["quit", "Quitar"],
]
const DISTRICT_NAMES := [
	"Barrio Norte", "Villa del Parque", "La Loma", "El Bajo",
	"San Telmo Chico", "Los Aromos", "Villa Sol", "Las Acacias",
	"Barrio Jardín", "La Ribera", "Centro", "Villa Rosa",
	"Los Álamos", "Puerto Viejo", "La Cañada", "Altos del Sur",
]
const DECREES := [
	{"id": "fumar", "n": "Prohibido fumar en lugares cerrados", "cost": 20, "d": "Más salud, un poco menos de comercio"},
	{"id": "boleto", "n": "Boleto gratis", "cost": 80, "d": "Más gente usa el transporte, menos autos"},
	{"id": "recicla", "n": "Reciclaje obligatorio", "cost": 30, "d": "Menos basura, más gasto"},
	{"id": "bici", "n": "Día del ciclista", "cost": 10, "d": "Más bicis los domingos"},
	{"id": "patrulla", "n": "Patrulla barrial", "cost": 40, "d": "Menos crimen"},
	{"id": "luz", "n": "Subsidio a la luz", "cost": 60, "d": "Vecinos más contentos"},
	{"id": "turismo", "n": "Promoción turística", "cost": 50, "d": "Más turistas"},
	{"id": "adultos", "n": "Educación para adultos", "cost": 40, "d": "Sube la educación"},
	{"id": "feria", "n": "Feria franca los domingos", "cost": 15, "d": "Más comercio los domingos"},
	{"id": "verde", "n": "Industria verde", "cost": 50, "d": "Menos contaminación, menos producción"},
	{"id": "alquiler", "n": "Ley de alquileres", "cost": 20, "d": "Barrios más contentos, menos impuestos"},
	{"id": "toque", "n": "Toque de queda", "cost": 10, "d": "Menos crimen, menos felicidad"},
]
const DECISIONS := [
	["Los colectiveros piden aumento.", ["Dar aumento", {"money": -800, "appr": 0.03}], ["Negar", {"appr": -0.03}]],
	["Una empresa quiere poner una fábrica grande.", ["Aceptar", {"money": 2500, "pol": 0.05}], ["Rechazar", {"appr": 0.01}]],
	["Los vecinos piden más luces en la calle.", ["Poner luces", {"money": -600, "crime": -0.05}], ["Más adelante", {"appr": -0.02}]],
	["Un club de barrio pide plata para el techo.", ["Ayudar", {"money": -500, "hp": 0.02}], ["No", {"appr": -0.02}]],
	["Proponen un festival de rock en la plaza.", ["Hacerlo", {"money": -900, "hp": 0.04, "tour": 4}], ["No", {}]],
	["Hay que arreglar los baches.", ["Arreglar todo", {"money": -1200, "appr": 0.04}], ["Solo el centro", {"money": -400}]],
	["Un canal de TV quiere filmar una novela acá.", ["Sí", {"money": 1500, "tour": 3}], ["No", {"appr": 0.01}]],
	["Los docentes piden capacitación.", ["Pagar cursos", {"money": -700, "edu": 0.05}], ["No", {"appr": -0.02}]],
	["Se propone peatonalizar una calle del centro.", ["Peatonalizar", {"hp": 0.03, "money": -300}], ["Dejar autos", {}]],
	["Una cadena de hamburguesas quiere abrir 10 locales.", ["Aceptar", {"money": 1200, "hp": -0.01}], ["Rechazar", {}]],
]
const PROMISES := [
	["Bajar el crimen", "crime"], ["Más espacios verdes", "park"], ["Que no se corte la luz", "power"],
	["Menos tránsito", "traffic"], ["Más trabajo", "jobs"],
]
const SCENARIOS := [
	{"n": "Libre", "d": "Construí la ciudad que quieras."},
	{"n": "Crisis energética", "d": "Sin usinas a carbón. Llegá a 2500 habitantes con toda la ciudad con luz antes del día 60."},
	{"n": "La gran obra", "d": "Inaugurá una maravilla antes del día 80."},
	{"n": "Ciudad bicicletera", "d": "Hacé que 25% de los viajes sean en bici o transporte antes del día 60."},
	{"n": "Pueblo costero", "d": "Mapa de costa. Llegá a 300 turistas por día antes del día 60."},
	{"n": "Ciudad ordenada", "d": "Llegá a 5000 habitantes sin bajar de 60% de aprobación."},
]
const OBJECTIVES := [
	{"k": "roads", "v": 12, "t": "Hacé 12 calles", "m": "¡Hola! Soy Marta, tu secretaria. Empecemos por las calles: sin calles no viene nadie.", "r": 500},
	{"k": "zoneR", "v": 20, "t": "Marcá 20 lotes residenciales", "m": "Ahora marcá lotes para casas al lado de las calles.", "r": 500},
	{"k": "power", "v": 1, "t": "Poné una usina", "m": "Las casas grandes necesitan luz. Poné una usina y conectala con calles o cables.", "r": 800},
	{"k": "water", "v": 1, "t": "Poné agua (bomba o torre)", "m": "Sin agua no crecen. Una torre de agua anda en cualquier lado.", "r": 800},
	{"k": "pop", "v": 50, "t": "Llegá a 50 vecinos", "m": "¡Ya hay vecinos! Esperá un poco que van llegando.", "r": 600},
	{"k": "zoneC", "v": 10, "t": "Marcá 10 lotes comerciales", "m": "La gente quiere trabajar y comprar cerca. Poné comercio.", "r": 600},
	{"k": "serv", "v": 2, "t": "Poné 2 servicios", "m": "Escuela, comisaría, bomberos o salita. Los barrios suben de nivel con servicios.", "r": 800},
	{"k": "pop", "v": 150, "t": "Llegá a 150 vecinos", "m": "¡Ya somos una villa!", "r": 1000},
	{"k": "line", "v": 1, "t": "Armá una línea de colectivo", "m": "Con colectivos hay menos autos y la gente llega antes.", "r": 1000},
	{"k": "garb", "v": 1, "t": "Poné un basurero o relleno", "m": "La basura se junta. Un basurero la levanta.", "r": 800},
	{"k": "pop", "v": 400, "t": "Llegá a 400 vecinos", "m": "Ya somos una ciudad chica. Llegan las primeras elecciones.", "r": 1500},
	{"k": "park", "v": 3, "t": "Poné 3 plazas o parques", "m": "Los barrios con verde valen más y la gente es más feliz.", "r": 1200},
	{"k": "pop", "v": 1000, "t": "Llegá a 1000 vecinos", "m": "¡Mil vecinos! Pensá en el tránsito: avenidas y rotondas ayudan.", "r": 2500},
	{"k": "pop", "v": 2500, "t": "Llegá a 2500 vecinos", "m": "Ciudad grande. Se desbloquea la universidad y el estadio.", "r": 4000},
	{"k": "wonder", "v": 1, "t": "Inaugurá una maravilla", "m": "Es hora de algo grande. Una maravilla atrae turistas de todo el país.", "r": 8000},
	{"k": "pop", "v": 10000, "t": "Llegá a 10.000 vecinos", "m": "¡Qué ciudad! Ya sos un intendente de verdad.", "r": 10000},
]
const ACHIEVEMENTS := [
	["first_road", "Primera calle"], ["pop100", "100 vecinos"], ["pop1000", "1.000 vecinos"],
	["pop10k", "10.000 vecinos"], ["pop50k", "50.000 vecinos"], ["pop100k", "Capital: 100.000"],
	["wonder", "Primera maravilla"], ["metro", "Subte propio"], ["airport", "Aeropuerto"],
	["port", "Puerto"], ["stadium", "Estadio"], ["election", "Ganaste una elección"],
	["festival", "Primer festival"], ["mundial", "¡Campeones del mundo!"], ["carnaval", "Carnaval"],
	["nodebt", "Sin deudas"], ["rich", "$100.000 en caja"], ["trees", "50 árboles"],
	["regions", "Todo el mapa"], ["bike", "Ciudad bicicletera"], ["lines3", "3 líneas"],
	["happy", "Ciudad feliz"], ["green", "100% energía limpia"], ["noFire", "30 días sin incendios"],
	["tourist", "100 turistas por día"],
]
const DAILY_CHALLENGES := [
	["Poné 15 calles hoy", "roads", 15], ["Marcá 20 lotes hoy", "zones", 20],
	["Plantá 10 árboles hoy", "trees", 10], ["Poné 2 edificios hoy", "builds", 2],
	["Ganá $500 hoy", "net", 500], ["Sumá 30 vecinos hoy", "popgain", 30],
]
var terr := PackedByteArray()
var hgt := PackedFloat32Array()
var road := PackedByteArray()
var zone := PackedByteArray()
var bld := PackedInt32Array()
var lvl := PackedByteArray()
var part := PackedInt32Array()
var occ := PackedFloat32Array()
var vari := PackedByteArray()
var tree := PackedByteArray()
var wire := PackedByteArray()
var burn := PackedFloat32Array()
var garbp := PackedFloat32Array()
var flood := PackedFloat32Array()
var owned := PackedByteArray()
var district := PackedInt32Array()
var wdist := PackedFloat32Array()
var cov: Array = []
var powered := PackedByteArray()
var watered := PackedByteArray()
var pollution := PackedFloat32Array()
var landv := PackedFloat32Array()
var crime := PackedFloat32Array()
var happy := PackedFloat32Array()
var tload := PackedFloat32Array()
var edu := PackedByteArray()
var why := PackedByteArray()
var map_kind: int = 0
var map_seed: int = 1
var scenario: int = 0
var creative: bool = false
var story: bool = true
var city_name: String = "Mi ciudad"
var money: float = 30000.0
var debt: float = 0.0
var day: int = 1
var day_timer: float = 0.0
var speed: int = 1
var pop: int = 0
var jobs: int = 0
var workers: int = 0
var tourists: int = 0
var stage: int = 0
var max_stage: int = 0
var approval: float = 0.7
var tax := [9, 9, 9]
var budget := [100, 100, 100, 100, 100, 100, 100]
var decrees := {}
var demand := [0.5, 0.3, 0.3]
var power_sup: float = 0.0
var power_use: float = 0.0
var water_sup: float = 0.0
var water_use: float = 0.0
var garb_made: float = 0.0
var garb_cap: float = 0.0
var food_stock: float = 0.0
var prod_stock: float = 0.0
var market := [6.0, 9.0]
var neighbors: Array = []
var contracts: Array = []
var offer = null
var lines: Array = []
var history := {"pop": [], "money": [], "happy": [], "appr": []}
var news: Array = []
var achieved := {}
var obj_index: int = 0
var counters := {}
var daily_ch: int = 0
var daily_done: bool = false
var promise: int = -1
var promise_base: float = 0.0
var next_election: int = 15
var decision = null
var request = null
var festival_days: int = 0
var weather: String = "Soleado"
var test_city: bool = false
var wind := Vector2(1, 0)
var mods := {"hp": 0.0, "crime": 0.0, "pol": 0.0, "edu": 0.0, "tour": 0.0, "days": 0}
var no_fire_days: int = 0
var avg_happy: float = 0.6
var avg_commute: float = 0.0
var last_net: float = 0.0
var wonder_progress := {}
var game_over_shown: bool = false
var slot: int = 1
var started: bool = false
var opts := {
	"quality": 1, "fps": false, "music": 0.6, "sfx": 0.8, "text": 20, "ui_size": 1,
	"colorblind": false, "calm": false, "lefty": false, "vibrate": true, "intro": true, "g_shadow": true, "g_water": true, "g_fog": true, "g_dyn": true, "g_wind": true, "g_rain": true, "g_ao": true, "g_detail": true, "g_clouds": true, "g_grass": true, "g_grade": true, "g_audio": true, "g_music": true, "autoround": true,
	"idle30": true, "tutorial_done": false,
}
const M_BOX := 0
const M_ROOF := 1
const M_CYL := 2
const M_SPH := 3
const M_CONE := 4
const NMESH := 9
var meshes: Array = []
var chunk_dirty := PackedByteArray()
var _bufs: Array = []
var _counts := PackedInt32Array()
var preview_node: MultiMeshInstance3D
var sun: DirectionalLight3D
var night: float = 0.0
var hour: float = 8.0
var view_mode: String = ""
var terrain_dirty: bool = true
var built_season: int = -1
var anim_cells := {}
var lamps := {}
var cam: Camera3D
var cam_target := Vector3.ZERO
var cam_goal := Vector3.ZERO
var cam_yaw: float = 0.6
var cam_pitch: float = 0.85
var cam_dist: float = 150.0
var cam_dist_goal: float = 150.0
var cam_follow = null
var cam_moving_t: float = 0.0
var intro_t: float = -1.0
var tool := {"k": "look"}
var touches := {}
var drag_a: int = -1
var drag_b: int = -1
var stops := {}
var line_edit := {}
var sim_dirty: bool = true
const LINE_COST := {"bus": 200, "tram": 600, "metro": 2000, "train": 1500, "ferry": 800}
const LINE_NAMES := {"bus": "Colectivo", "tram": "Tranvía", "metro": "Subte", "train": "Tren", "ferry": "Ferry"}
var finger_pos: Vector2 = Vector2.ZERO
var drag_acc: float = 0.0
var sim_stage: int = -1
var zone_list := PackedInt32Array()
var anchors: Array = []
var comp := PackedInt32Array()
var unemployment: float = 0.0
var trade_ok: bool = false
var commute := PackedFloat32Array()
var car_paths: Array = []
var power_frac: float = 1.0
var water_frac: float = 1.0
var last_budget := {}
var classes := [0, 0, 0]
var green_power: float = 0.0
var hp_bonus: float = 0.0
const WHY_TEXT := ["", "contaminación", "inseguridad", "cortes de luz", "falta de agua", "basura en la calle", "mucho tránsito", "falta de salud", "falta de escuelas", "impuestos altos", "falta de trabajo", "falta de verde", "inundación o incendio"]
var dyn_nodes: Array = []
var cars: Array = []
var peds: Array = []
var svc: Array = []
var boats: Array = []
var planes: Array = []
var parts: Array = []
var line_labels: Array = []
var drive = null
var drive_turn: int = 0
var follow_ped = null
var follow_info := {}
var stars: Array = []
var downs: Array = []
var movie_on: int = -1
var cine_next_day: int = 0
var ui_scale: float = 1.0
var notif_panel: PanelContainer
var notif_busy: bool = false
var tray_sc: ScrollContainer
var build_btn: Button
var fan_btns: Array = []
var fan_open: bool = false
var fan_hold: bool = false
var fan_hover: String = ""
var top_money: Label
var tray: HBoxContainer
var cat_bar: HBoxContainer
var cur_cat: String = ""
var sheet: PanelContainer
var sheet_body: VBoxContainer
var sheet_name: String = ""
var info_panel: PanelContainer
var card_panel: PanelContainer
var card_title: Label
var card_text: Label
var card_btns: HBoxContainer
var card_queue: Array = []
var mode_bar: PanelContainer
var photo_mode: bool = false
const COL_BTN_HI := Color(0.45, 0.33, 0.23, 1.0)
var prev_crumb: String = ""
var new_opts := {"name": "Mi ciudad", "map": 0, "scen": 0, "creative": false, "story": true, "tut": false}
var sounds := {}
var test_mode: String = ""
# ================================================================ src/world.gd
# El mapa: celdas, terreno, generación y utilidades.
const DAYS_PER_SEASON := 10
const YEAR_DAYS := 40
const RCAP := [0, 60, 170, 400, 850]
const ROUND_CAP := 520
const CAP_R := [0, 6, 14, 30, 64]
const CAP_MR := [0, 4, 10, 22, 48]
const FIRST_NAMES := ["Marta", "Juan", "Lucía", "Diego", "Sofía", "Carlos", "Valentina", "Martín", "Camila", "Jorge", "Florencia", "Pablo", "Rocío", "Nicolás", "Julieta", "Lionel", "Ana", "Gustavo", "Belén", "Facundo"]
const LAST_NAMES := ["González", "Rodríguez", "Gómez", "Fernández", "López", "Díaz", "Martínez", "Pérez", "Romero", "Sosa", "Álvarez", "Torres", "Ruiz", "Ramírez", "Flores", "Benítez", "Acosta", "Medina"]
const STREET_NAMES := ["San Martín", "Belgrano", "Rivadavia", "Sarmiento", "Mitre", "Moreno", "Alvear", "Güemes", "Lavalle", "Pueyrredón", "Corrientes", "Mendoza", "Tucumán", "Córdoba", "Entre Ríos", "Santa Fe", "Las Heras", "Urquiza", "Alberdi", "Brown", "Dorrego", "Castelli", "Paso", "French"]
const NEIGHBOR_CITIES := ["San Ramón", "Villa Esperanza", "Puerto Grande"]
func idx(x: int, z: int) -> int:
	return z * N + x
func inb(x: int, z: int) -> bool:
	return x >= 0 and z >= 0 and x < N and z < N
func cx(i: int) -> int:
	return i % N
func cz(i: int) -> int:
	return i / N
func cell_pos(i: int) -> Vector3:
	return Vector3((cx(i) + 0.5) * CELL - N * CELL * 0.5, hgt[i], (cz(i) + 0.5) * CELL - N * CELL * 0.5)
func world_to_cell(p: Vector3) -> Vector2i:
	return Vector2i(floori((p.x + N * CELL * 0.5) / CELL), floori((p.z + N * CELL * 0.5) / CELL))
func region_of(i: int) -> int:
	return (cz(i) / REG) * NREG + (cx(i) / REG)
func is_owned(i: int) -> bool:
	return creative or owned[region_of(i)] == 1
func season() -> int:
	return ((day - 1) / DAYS_PER_SEASON) % 4
func doy() -> int:
	return (day - 1) % YEAR_DAYS
func year() -> int:
	return (day - 1) / YEAR_DAYS + 1
func is_sunday() -> bool:
	return day % 7 == 0
func has_decree(id: String) -> bool:
	return decrees.get(id, false)
func buildable(i: int) -> bool:
	return terr[i] != T_WATER and flood[i] <= 0.0
func empty_cell(i: int) -> bool:
	return road[i] == 0 and zone[i] == 0 and bld[i] == 0
func anchor_of(i: int) -> int:
	return part[i] if part[i] >= 0 else i
func def_of(i: int) -> Dictionary:
	if bld[i] == 0:
		return {}
	return DEF[bld[i]]
func road_near(i: int, r: int) -> bool:
	var x := cx(i)
	var z := cz(i)
	for dz in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if abs(dx) + abs(dz) > r:
				continue
			var xx := x + dx
			var zz := z + dz
			if inb(xx, zz) and road[idx(xx, zz)] > 0:
				return true
	return false
func near_water(i: int, r: int) -> bool:
	var x := cx(i)
	var z := cz(i)
	for dz in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var xx := x + dx
			var zz := z + dz
			if inb(xx, zz) and terr[idx(xx, zz)] == T_WATER:
				return true
	return false
func fmt_money(v: float) -> String:
	var neg := v < 0
	var s := str(int(absf(v)))
	var out := ""
	var c := 0
	for k in range(s.length() - 1, -1, -1):
		out = s[k] + out
		c += 1
		if c % 3 == 0 and k > 0:
			out = "." + out
	return ("-$" if neg else "$") + out
func fmt_int(v: int) -> String:
	return fmt_money(float(v)).substr(1)
func rand_name() -> String:
	return FIRST_NAMES[randi() % FIRST_NAMES.size()] + " " + LAST_NAMES[randi() % LAST_NAMES.size()]
func street_name(i: int) -> String:
	if i < 0:
		return ""
	var x := cx(i)
	var z := cz(i)
	var horiz := (x > 0 and road[i - 1] > 0) or (x < N - 1 and road[i + 1] > 0)
	var prefix := "Av. " if road[i] >= 3 else "Calle "
	if road[i] == 4:
		prefix = "Autopista "
	if horiz:
		return prefix + STREET_NAMES[z % STREET_NAMES.size()]
	return prefix + STREET_NAMES[(x * 7 + 3) % STREET_NAMES.size()]
func count_add(k: String, v: float = 1.0) -> void:
	counters[k] = counters.get(k, 0.0) + v
	counters["day_" + k] = counters.get("day_" + k, 0.0) + v
func alloc_arrays() -> void:
	var nn := N * N
	terr.resize(nn); terr.fill(0)
	hgt.resize(nn); hgt.fill(0.0)
	road.resize(nn); road.fill(0)
	zone.resize(nn); zone.fill(0)
	bld.resize(nn); bld.fill(0)
	lvl.resize(nn); lvl.fill(0)
	part.resize(nn); part.fill(-1)
	occ.resize(nn); occ.fill(0.0)
	vari.resize(nn); vari.fill(0)
	tree.resize(nn); tree.fill(0)
	wire.resize(nn); wire.fill(0)
	burn.resize(nn); burn.fill(0.0)
	garbp.resize(nn); garbp.fill(0.0)
	flood.resize(nn); flood.fill(0.0)
	wdist.resize(nn); wdist.fill(99.0)
	powered.resize(nn); powered.fill(0)
	watered.resize(nn); watered.fill(0)
	pollution.resize(nn); pollution.fill(0.0)
	landv.resize(nn); landv.fill(0.3)
	crime.resize(nn); crime.fill(0.0)
	happy.resize(nn); happy.fill(0.6)
	tload.resize(nn); tload.fill(0.0)
	edu.resize(nn); edu.fill(0)
	why.resize(nn); why.fill(0)
	owned.resize(NREG * NREG); owned.fill(0)
	district.resize(NREG * NREG); district.fill(0)
	cov.clear()
	for k in NCV:
		var a := PackedFloat32Array()
		a.resize(nn)
		a.fill(0.0)
		cov.append(a)
func gen_map(kind: int, seed_v: int) -> void:
	map_kind = kind
	map_seed = seed_v
	alloc_arrays()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var nz := FastNoiseLite.new()
	nz.seed = seed_v
	nz.frequency = 0.035
	var nz2 := FastNoiseLite.new()
	nz2.seed = seed_v + 77
	nz2.frequency = 0.08
	var c := N * 0.5
	for z in N:
		for x in N:
			var i := idx(x, z)
			var n1 := nz.get_noise_2d(x, z)
			var n2 := nz2.get_noise_2d(x, z)
			var water := false
			match kind:
				0:
					var rx := c + sin(z * 0.06 + seed_v) * 14.0 + n1 * 8.0
					water = absf(x - rx) < 3.2 + n2 * 1.2
				1:
					var lx := c + 26.0
					var lz := c - 22.0
					water = Vector2(x - lx, z - lz).length() < 17.0 + n1 * 7.0
				2:
					water = x > N * 0.74 + n1 * 9.0
				3:
					var d := Vector2(x - c, z - c).length()
					water = d > 50.0 + n1 * 12.0 or (n2 > 0.55 and d > 20.0)
				4:
					water = Vector2(x - (c - 30), z - (c + 28)).length() < 6.0 + n1 * 3.0
			if water:
				terr[i] = T_WATER
				hgt[i] = -1.6
			else:
				var edge := clampf((Vector2(x - c, z - c).length() - 30.0) / 30.0, 0.0, 1.0)
				var h := maxf(0.0, (n1 + 0.15) * 9.0) * edge
				if kind == 4:
					h *= 0.4
				h = snappedf(h, 0.5)
				hgt[i] = h
				if h >= 3.0:
					terr[i] = T_ROCK
	for i in N * N:
		if terr[i] == T_WATER:
			continue
		if near_water(i, 1) and hgt[i] < 1.5:
			terr[i] = T_SAND
			hgt[i] = 0.0
	compute_wdist()
	for z in N:
		for x in N:
			var i := idx(x, z)
			if terr[i] == T_WATER or terr[i] == T_ROCK:
				continue
			var f := nz2.get_noise_2d(x * 1.7 + 50, z * 1.7)
			var dc := Vector2(x - c, z - c).length()
			if (f > 0.35 and dc > 12.0) or rng.randf() < 0.012:
				tree[i] = pick_tree_kind(i, rng)
	for r in [5, 6, 9, 10]:
		owned[r] = 1
	var hz := N / 2
	for x in range(0, N / 2 - 6):
		var i := idx(x, hz)
		road[i] = 4
		tree[i] = 0
		if terr[i] == T_ROCK:
			terr[i] = T_LAND
			hgt[i] = 0.0
	for z in range(int(c) - 20, int(c) + 20):
		for x in range(int(c) - 20, int(c) + 20):
			var i := idx(x, z)
			if terr[i] != T_WATER and terr[i] != T_SAND:
				hgt[i] = minf(hgt[i], 0.0)
				if terr[i] == T_ROCK:
					terr[i] = T_LAND
	init_neighbors()
func pick_tree_kind(i: int, rng: RandomNumberGenerator) -> int:
	if terr[i] == T_SAND:
		return 6
	if wdist[i] <= 2.0:
		return 7
	var r := rng.randi() % 10
	if r < 3:
		return 1
	if r < 5:
		return 2
	if r < 6:
		return 3
	if r < 8:
		return 4
	return 5
func compute_wdist() -> void:
	var q: Array = []
	for i in N * N:
		if terr[i] == T_WATER:
			wdist[i] = 0.0
			q.append(i)
		else:
			wdist[i] = 99.0
	var head := 0
	while head < q.size():
		var i: int = q[head]
		head += 1
		var d: float = wdist[i]
		if d >= 20.0:
			continue
		var x := cx(i)
		var z := cz(i)
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var xx: int = x + o.x
			var zz: int = z + o.y
			if not inb(xx, zz):
				continue
			var j := idx(xx, zz)
			if wdist[j] > d + 1.0:
				wdist[j] = d + 1.0
				q.append(j)
func init_neighbors() -> void:
	neighbors.clear()
	for n in NEIGHBOR_CITIES:
		neighbors.append({"n": n, "rel": 50.0})
func hsh(i: int, k: int) -> float:
	var v := (i * 73856093) ^ (k * 19349663)
	v = (v ^ (v >> 13)) * 1274126177
	return float(v & 0xffff) / 65535.0
func road_n(i: int) -> Array:
	var x := cx(i)
	var z := cz(i)
	return [x < N - 1 and road[i + 1] > 0, x > 0 and road[i - 1] > 0, z < N - 1 and road[i + N] > 0, z > 0 and road[i - N] > 0]
func vert_h(x: int, z: int) -> float:
	var hs := 0.0
	var cnt := 0
	for o in [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]:
		var xx: int = x + o.x
		var zz: int = z + o.y
		if inb(xx, zz):
			hs += hgt[idx(xx, zz)]
			cnt += 1
	return hs / maxf(cnt, 1)
func ground_y(wx: float, wz: float) -> float:
	var half := N * CELL * 0.5
	var fx := (wx + half) / CELL
	var fz := (wz + half) / CELL
	var x0 := clampi(int(floor(fx)), 0, N - 1)
	var z0 := clampi(int(floor(fz)), 0, N - 1)
	var u := clampf(fx - x0, 0.0, 1.0)
	var v := clampf(fz - z0, 0.0, 1.0)
	var ha := vert_h(x0, z0)
	var hb := vert_h(x0 + 1, z0)
	var hc := vert_h(x0, z0 + 1)
	var hd := vert_h(x0 + 1, z0 + 1)
	if u >= v:
		return ha + (hb - ha) * u + (hd - hb) * v
	return ha + (hc - ha) * v + (hd - hc) * u
func face_rot(i: int) -> float:
	var nb := road_n(i)
	if nb[2]:
		return 0.0
	if nb[3]:
		return PI
	if nb[0]:
		return PI * 0.5
	if nb[1]:
		return -PI * 0.5
	return 0.0
func road_cap(i: int) -> float:
	if wire[i] & W_ROUND:
		return float(ROUND_CAP)
	var c: float = RCAP[road[i]]
	if weather == "Nieve":
		c *= 0.7
	return maxf(c, 1.0)
func def_cells(a: int, sz: int) -> Array:
	var out: Array = []
	if a < 0:
		return out
	var x0 := cx(a) - (sz - 1) / 2
	var z0 := cz(a) - (sz - 1) / 2
	for dz in sz:
		for dx in sz:
			if inb(x0 + dx, z0 + dz):
				out.append(idx(x0 + dx, z0 + dz))
	return out
func near_road_cell(a: int, r: int) -> int:
	var x := cx(a)
	var z := cz(a)
	for dz in range(-r, r + 2):
		for dx in range(-r, r + 2):
			if inb(x + dx, z + dz) and road[idx(x + dx, z + dz)] > 0:
				return idx(x + dx, z + dz)
	return -1
func bike_near(i: int) -> bool:
	for dz in range(-3, 4):
		for dx in range(-3, 4):
			var x := cx(i) + dx
			var z := cz(i) + dz
			if inb(x, z) and wire[idx(x, z)] & W_BIKE:
				return true
	return false
func zone_cap(z: int, l: int) -> int:
	match z:
		Z_R:
			return CAP_R[l]
		Z_C:
			return CAP_C[l]
		Z_I:
			return CAP_I[l]
		Z_M:
			return CAP_MR[l]
	return 0
func zone_count(z: int) -> int:
	var n := 0
	for i in zone_list:
		if zone[i] == z:
			n += 1
	return n
func def_center(a: int) -> Vector3:
	var p := cell_pos(a)
	if bld[a] > 0:
		var sz: int = DEF[bld[a]]["sz"]
		p.x += (sz - 1) * CELL * 0.5
		p.z += (sz - 1) * CELL * 0.5
	return p
func place_plaza() -> void:
	var c := N / 2
	for z in range(c - 2, c + 2):
		for x in range(c - 2, c + 2):
			var i := idx(x, z)
			if terr[i] == T_WATER:
				return
	for z in range(c - 2, c + 2):
		for x in range(c - 2, c + 2):
			var i := idx(x, z)
			if x == c - 2 or x == c + 1 or z == c - 2 or z == c + 1:
				road[i] = 2
			tree[i] = 0
			terr[i] = T_LAND if terr[i] == T_ROCK else terr[i]
			hgt[i] = 0.0
	var a := idx(c - 1, c - 1)
	for dz in 2:
		for dx in 2:
			var j := a + dz * N + dx
			bld[j] = 31
			part[j] = a
	for x in range(N / 2 - 6, c - 2):
		var i := idx(x, c - 1)
		if terr[i] != T_WATER:
			road[i] = maxi(road[i], 3)
			tree[i] = 0
# ================================================================ src/sim.gd
# Simulación: redes, servicios, felicidad, crecimiento, economía y días.
const ROAD_UPK := [0.0, 0.03, 0.08, 0.2, 0.5]
const CAP_MJ := [0, 3, 6, 12, 24]
const REQUESTS := [
	["una plaza cerca", CV_PARK], ["más policía", CV_POL], ["una salita", CV_HEALTH],
	["una escuela", CV_EDU1], ["un colectivo", CV_TRANSIT], ["bomberos cerca", CV_FIRE],
]
var trips_total: int = 0
var trips_green: int = 0
var sim_acc: float = 0.0
var sim_cycle: int = 0
var jobs_c: int = 0
var jobs_i: int = 0
var jobs_cap: int = 0
var class_mult: float = 1.0
var epidemic_days: int = 0
func speed_mult() -> float:
	return [0.0, 1.0, 2.0, 4.0][speed]
func sim_process(delta: float) -> void:
	var m := speed_mult()
	if m <= 0.0 or not started:
		return
	day_timer += delta * m
	sim_acc += delta * m
	if sim_stage < 0 and sim_acc >= 1.0:
		sim_acc = 0.0
		sim_stage = 0
	if sim_stage >= 0:
		run_sim_stage(sim_stage)
		sim_stage += 1
		if sim_stage > 7:
			sim_stage = -1
			sim_cycle += 1
	if day_timer >= DAY_SECONDS:
		day_timer -= DAY_SECONDS
		new_day()
func run_sim_stage(s: int) -> void:
	match s:
		0:
			collect_lists()
			if sim_dirty or sim_cycle % 5 == 0:
				compute_networks()
		1:
			compute_coverage()
		2:
			compute_env()
		3:
			if sim_dirty or sim_cycle % 3 == 0:
				compute_traffic()
		4:
			compute_happiness()
		5:
			grow_zones()
		6:
			compute_stats()
			fire_tick()
		7:
			sim_dirty = false
			check_progress()
func collect_lists() -> void:
	zone_list.clear()
	anchors.clear()
	for i in N * N:
		if zone[i] > 0:
			zone_list.append(i)
		elif bld[i] > 0 and (part[i] < 0 or part[i] == i):
			anchors.append(i)
func def_active(a: int) -> bool:
	var d: Dictionary = DEF[bld[a]]
	if d["c"] == "wonder" and wonder_progress.get(a, 0) < WONDER_STEPS:
		return false
	if burn[a] > 0.0:
		return false
	return road_near(a, d["sz"])
func conducts(i: int, water: bool) -> bool:
	if road[i] > 0 or zone[i] > 0 or bld[i] > 0:
		return true
	return (wire[i] & (W_PIPE if water else W_POWER)) != 0
func compute_networks() -> void:
	for pass_i in 2:
		var water := pass_i == 1
		comp.resize(N * N)
		comp.fill(-1)
		var sup: Array = []
		var use: Array = []
		var ncomp := 0
		var q := PackedInt32Array()
		for i in N * N:
			if comp[i] >= 0 or not conducts(i, water):
				continue
			var cid := ncomp
			ncomp += 1
			sup.append(0.0)
			use.append(0.0)
			q.clear()
			q.append(i)
			comp[i] = cid
			var head := 0
			while head < q.size():
				var j := q[head]
				head += 1
				var x := cx(j)
				var z := cz(j)
				if x > 0 and comp[j - 1] < 0 and conducts(j - 1, water):
					comp[j - 1] = cid
					q.append(j - 1)
				if x < N - 1 and comp[j + 1] < 0 and conducts(j + 1, water):
					comp[j + 1] = cid
					q.append(j + 1)
				if z > 0 and comp[j - N] < 0 and conducts(j - N, water):
					comp[j - N] = cid
					q.append(j - N)
				if z < N - 1 and comp[j + N] < 0 and conducts(j + N, water):
					comp[j + N] = cid
					q.append(j + N)
		var bcid := {}
		for i in N * N:
			if bld[i] > 0 and (part[i] < 0 or part[i] == i):
				var rc := near_road_cell(i, DEF[bld[i]]["sz"])
				if rc >= 0 and comp[rc] >= 0:
					bcid[i] = comp[rc]
		for i in N * N:
			var cid := comp[i]
			if bld[i] > 0:
				cid = bcid.get(anchor_of(i), cid)
			if cid < 0:
				continue
			if zone[i] > 0:
				var l := float(lvl[i])
				var u := 0.0
				match zone[i]:
					Z_R:
						u = l * (1.0 if not water else 1.2)
					Z_C:
						u = l * (1.5 if not water else 1.0)
					Z_I:
						u = l * (2.5 if not water else 1.8)
					Z_M:
						u = l * 1.2
				use[cid] += u
			elif bld[i] > 0 and (part[i] < 0 or part[i] == i):
				var d: Dictionary = DEF[bld[i]]
				var key := "wt" if water else "pw"
				if d.has(key) and def_active(i):
					var eff := 1.0
					if not water and bld[i] == 44 and night > 0.5:
						eff = 0.3
					sup[cid] += float(d[key]) * eff
				else:
					use[cid] += 3.0 + float(d["upk"]) * 0.05
		var tot_sup := 0.0
		var tot_use := 0.0
		var frac: Array = []
		for k in ncomp:
			tot_sup += sup[k]
			tot_use += use[k]
			var f: float = 1.0 if use[k] <= sup[k] else (sup[k] / maxf(use[k], 0.01))
			if f < 1.0 and trade_ok and sup[k] > 0.0:
				f = minf(1.0, f + 0.25)
			frac.append(f)
		var arr := watered if water else powered
		var got := 0
		var need := 0
		for i in N * N:
			var cid := comp[i]
			if bld[i] > 0:
				cid = bcid.get(anchor_of(i), cid)
			var v := 0
			if cid >= 0 and sup[cid] > 0.0:
				var f: float = frac[cid]
				v = 1 if f >= 1.0 or hsh(i, day + pass_i) < f else 0
			arr[i] = v
			if zone[i] > 0 and lvl[i] > 0:
				need += 1
				got += v
		if water:
			watered = arr
			water_sup = tot_sup
			water_use = tot_use
			water_frac = float(got) / maxf(need, 1)
		else:
			powered = arr
			power_sup = tot_sup
			power_use = tot_use
			power_frac = float(got) / maxf(need, 1)
	var clean := 0.0
	var all := 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if d.has("pw"):
			all += d["pw"]
			if bld[a] in [44, 45, 46]:
				clean += d["pw"]
	green_power = clean / maxf(all, 1.0)
	trade_ok = false
	for k in N:
		for j in [idx(k, 0), idx(k, N - 1), idx(0, k), idx(N - 1, k)]:
			if road[j] == 4:
				trade_ok = true
	for a in anchors:
		if bld[a] == 0:
			continue
		if DEF[bld[a]].get("trade", false) and def_active(a):
			trade_ok = true
func stamp(layer: PackedFloat32Array, cxi: int, czi: int, r: float, amount: float) -> PackedFloat32Array:
	var ri := int(ceil(r))
	for dz in range(-ri, ri + 1):
		var zz := czi + dz
		if zz < 0 or zz >= N:
			continue
		for dx in range(-ri, ri + 1):
			var xx := cxi + dx
			if xx < 0 or xx >= N:
				continue
			var d := sqrt(float(dx * dx + dz * dz))
			if d > r:
				continue
			var j := zz * N + xx
			layer[j] += amount * (1.0 - d / (r + 1.0))
	return layer
func residents_near(cxi: int, czi: int, r: int) -> float:
	var s := 0.0
	for dz in range(-r, r + 1, 2):
		var zz := czi + dz
		if zz < 0 or zz >= N:
			continue
		for dx in range(-r, r + 1, 2):
			var xx := cxi + dx
			if xx < 0 or xx >= N:
				continue
			var j := zz * N + xx
			if zone[j] == Z_R or zone[j] == Z_M:
				s += occ[j]
	return s * 4.0
func compute_coverage() -> void:
	for t in NCV:
		var a: PackedFloat32Array = cov[t]
		a.fill(0.0)
		cov[t] = a
	hp_bonus = 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if not def_active(a):
			continue
		hp_bonus += d.get("hp", 0.0)
		if not d.has("cov"):
			continue
		var sz: int = d["sz"]
		var mx := cx(a) + (sz - 1) / 2
		var mz := cz(a) + (sz - 1) / 2
		var eff := 1.0
		if d.has("dep"):
			eff *= budget[d["dep"]] / 100.0
		if not powered[a]:
			eff *= 0.6
		if d.has("cap"):
			var r0: int = d["cov"].values()[0]
			var served := residents_near(mx, mz, r0)
			eff *= clampf(float(d["cap"]) / maxf(served, 1.0), 0.45, 1.0)
		if d.has("stop"):
			var used := false
			for ln in lines:
				if a in ln["stops"] and ln["pts"].size() > 1:
					used = true
			if not used:
				continue
		for t in d["cov"]:
			var r: float = d["cov"][t]
			cov[t] = stamp(cov[t], mx, mz, r, eff * 1.4)
	for s in stops:
		var used := false
		for ln in lines:
			if s in ln["stops"] and ln["pts"].size() > 1:
				used = true
		if used:
			cov[CV_TRANSIT] = stamp(cov[CV_TRANSIT], cx(s), cz(s), 5.0, 1.2 * budget[5] / 100.0)
	hp_bonus = minf(0.1, hp_bonus / (1.0 + pop / 3000.0))
var env_half: int = 0
func compute_env() -> void:
	pollution.fill(0.0)
	var green := 0.6 if has_decree("verde") else 1.0
	for i in zone_list:
		if zone[i] == Z_I and lvl[i] > 0:
			pollution = stamp(pollution, cx(i), cz(i), 5.0, lvl[i] * 0.07 * green)
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if d.has("pol") and def_active(a):
			pollution = stamp(pollution, cx(a), cz(a), 7.0, float(d["pol"]) * 0.45)
	for i in N * N:
		if road[i] == 4 and tload[i] > 100.0:
			pollution[i] += 0.15
		if tree[i] > 0:
			pollution[i] -= 0.06
	var pc: PackedFloat32Array = cov[CV_POL]
	var pk: PackedFloat32Array = cov[CV_PARK]
	var hc: PackedFloat32Array = cov[CV_HEALTH]
	var e1: PackedFloat32Array = cov[CV_EDU1]
	var tc: PackedFloat32Array = cov[CV_TRANSIT]
	var crime_mod: float = mods["crime"] - (0.1 if has_decree("patrulla") else 0.0) - (0.08 if has_decree("toque") else 0.0)
	env_half = 1 - env_half
	var half := N * N / 2
	for i in range(env_half * half, env_half * half + half + (N * N - 2 * half) * env_half):
		var p := clampf(pollution[i], 0.0, 1.5)
		pollution[i] = p
		if terr[i] == T_WATER:
			continue
		var lv := 0.32 + 0.25 * minf(pk[i], 1.2) + 0.08 * minf(hc[i], 1.0) + 0.06 * minf(e1[i], 1.0) + 0.06 * minf(tc[i], 1.0) - 0.5 * p - 0.2 * crime[i]
		if wdist[i] < 5.0:
			lv += 0.16 * (1.0 - wdist[i] / 5.0)
		if hgt[i] > 0.5:
			lv += 0.05
		var r := region_of(i)
		if district[r] == 2:
			lv += 0.05
		landv[i] = clampf(lv, 0.0, 1.0)
		if zone[i] > 0 and lvl[i] > 0:
			var c := 0.12 + unemployment * 0.45 + lvl[i] * 0.04 - minf(pc[i], 1.2) * 0.55 + crime_mod
			if district[r] == 3:
				c -= 0.1
			if district[r] == 4:
				c += 0.05
			crime[i] = clampf(c, 0.0, 1.0)
		else:
			crime[i] = 0.0
func compute_traffic() -> void:
	var nn := N * N
	var dist := PackedInt32Array()
	dist.resize(nn)
	dist.fill(-1)
	var nxt := PackedInt32Array()
	nxt.resize(nn)
	nxt.fill(-1)
	var q := PackedInt32Array()
	for i in zone_list:
		if (zone[i] == Z_C or zone[i] == Z_I or zone[i] == Z_M) and lvl[i] > 0:
			for o in [1, -1, N, -N]:
				var j: int = i + o
				if j >= 0 and j < nn and road[j] > 0 and dist[j] < 0:
					dist[j] = 0
					q.append(j)
	for a in anchors:
		if bld[a] == 0:
			continue
		if DEF[bld[a]].get("job", 0) > 0:
			for o in [1, -1, N, -N]:
				var j: int = a + o
				if j >= 0 and j < nn and road[j] > 0 and dist[j] < 0:
					dist[j] = 0
					q.append(j)
	var head := 0
	while head < q.size():
		var j := q[head]
		head += 1
		var x := cx(j)
		var dj := dist[j] + 1
		for o in [1, -1, N, -N]:
			var k: int = j + o
			if k < 0 or k >= nn or road[k] == 0 or dist[k] >= 0:
				continue
			if (o == 1 and x == N - 1) or (o == -1 and x == 0):
				continue
			dist[k] = dj
			nxt[k] = j
			q.append(k)
	var newload := PackedFloat32Array()
	newload.resize(nn)
	newload.fill(0.0)
	commute.resize(nn)
	var homes: Array = []
	for i in zone_list:
		if (zone[i] == Z_R or zone[i] == Z_M) and lvl[i] > 0:
			homes.append(i)
	var sample := mini(homes.size(), 260)
	var w := float(pop) / maxf(sample, 1) * 0.35
	var tot_len := 0.0
	var trips := 0
	var green := 0.0
	car_paths.clear()
	var tcov: PackedFloat32Array = cov[CV_TRANSIT]
	var lots: Array = []
	for a in anchors:
		if bld[a] > 0 and DEF[bld[a]].get("park", false):
			lots.append(a)
	for s in sample:
		var h: int = homes[randi() % homes.size()]
		var r0 := -1
		for o in [1, -1, N, -N]:
			var j: int = h + o
			if j >= 0 and j < nn and road[j] > 0 and dist[j] >= 0:
				r0 = j
				break
		if r0 < 0:
			commute[h] = 0.6
			continue
		var tshare := clampf(tcov[h] * 0.55 + (0.15 if has_decree("boleto") else 0.0), 0.0, 0.7)
		var bshare := 0.0
		if bike_near(h):
			bshare = 0.12 + (0.06 if has_decree("bici") and is_sunday() else 0.0)
		var car := maxf(0.0, 1.0 - tshare - bshare)
		var path: Array = []
		var j := r0
		var steps := 0
		var cong := 0.0
		while j >= 0 and steps < 400:
			newload[j] += w * car
			path.append(j)
			cong += tload[j] / road_cap(j)
			j = nxt[j]
			steps += 1
		tot_len += steps
		trips += 1
		green += tshare + bshare
		var c := clampf(cong / maxf(steps, 1) - 0.6, 0.0, 1.0)
		for lt in lots:
			if absi(cx(lt) - cx(h)) <= 8 and absi(cz(lt) - cz(h)) <= 8:
				c *= 0.75
				break
		commute[h] = c
		if car_paths.size() < 70 and path.size() > 3:
			car_paths.append(path)
	for i in nn:
		tload[i] = tload[i] * 0.4 + newload[i] * 0.6
	avg_commute = tot_len / maxf(trips, 1)
	if trips > 0:
		trips_total += trips
		trips_green += int(green)
	counters["green_share"] = green / maxf(trips, 1)
func compute_happiness() -> void:
	var hc: PackedFloat32Array = cov[CV_HEALTH]
	var e1: PackedFloat32Array = cov[CV_EDU1]
	var e2: PackedFloat32Array = cov[CV_EDU2]
	var e3: PackedFloat32Array = cov[CV_EDU3]
	var pk: PackedFloat32Array = cov[CV_PARK]
	var pc: PackedFloat32Array = cov[CV_POL]
	var fc: PackedFloat32Array = cov[CV_FIRE]
	var base := 0.5 + float(mods["hp"]) + hp_bonus
	if pop < 300:
		base += 0.1
	elif pop < 700:
		base += 0.05
	if festival_days > 0:
		base += 0.06
	if has_decree("luz"):
		base += 0.04
	if has_decree("alquiler"):
		base += 0.03
	if has_decree("toque"):
		base -= 0.04
	if epidemic_days > 0:
		base -= 0.08
	var tax_pen := maxf(0.0, (tax[0] - 9) * 0.015) - maxf(0.0, (9 - tax[0]) * 0.006)
	var sum_h := 0.0
	var cnt := 0
	classes = [0, 0, 0]
	var cls_tax := 0.0
	var edu_bonus: float = mods["edu"] + (0.3 if has_decree("adultos") else 0.0)
	for i in zone_list:
		if not (zone[i] == Z_R or zone[i] == Z_M) or lvl[i] == 0:
			continue
		var el := 0
		if e1[i] + edu_bonus > 0.25:
			el = 1
		if e2[i] + edu_bonus > 0.25 and el >= 1:
			el = 2
		if e3[i] + edu_bonus * 0.5 > 0.25 and el >= 2:
			el = 3
		edu[i] = el
		var neg := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		var h := base
		if has_decree("fumar"):
			h += 0.02
		h += 0.12 * minf(hc[i], 1.0)
		if hc[i] < 0.1:
			neg[7] = 0.06
		h += 0.06 * minf(e1[i], 1.0)
		if e1[i] < 0.1:
			neg[8] = 0.04
		h += 0.15 * minf(pk[i], 1.0)
		if pk[i] < 0.05:
			neg[11] = 0.03
		h += 0.04 * minf(pc[i], 1.0) + 0.03 * minf(fc[i], 1.0)
		neg[1] = 0.35 * pollution[i]
		neg[2] = 0.25 * crime[i]
		neg[3] = 0.0 if powered[i] else 0.2
		neg[4] = 0.0 if watered[i] else 0.2
		neg[5] = minf(0.18, garbp[i] * 0.06)
		neg[6] = 0.15 * (commute[i] if i < commute.size() else 0.0)
		neg[9] = tax_pen
		neg[10] = unemployment * 0.3
		neg[12] = 0.2 if (flood[i] > 0.0 or burn[i] > 0.0) else 0.0
		var r := region_of(i)
		match district[r]:
			1:
				h -= 0.05
			2:
				h += 0.06
			4:
				h -= 0.03
		var cl := 1
		if el >= 2 and landv[i] > 0.55 and lvl[i] >= 3:
			cl = 2
		elif el == 0 and landv[i] < 0.35:
			cl = 0
		classes[cl] += 1
		if cl == 2:
			h += 0.06 if (pk[i] > 0.3 and crime[i] < 0.2) else -0.06
		elif cl == 0:
			h += 0.03 if hc[i] > 0.3 else -0.03
		cls_tax += [0.7, 1.0, 1.4][cl]
		var worst := 0
		var wv := 0.02
		for k in neg.size():
			h -= neg[k]
			if neg[k] > wv:
				wv = neg[k]
				worst = k
		h = clampf(h, 0.0, 1.0)
		happy[i] = h
		why[i] = worst
		sum_h += h
		cnt += 1
	avg_happy = sum_h / cnt if cnt > 0 else 0.65
	class_mult = cls_tax / cnt if cnt > 0 else 1.0
func grow_zones() -> void:
	if zone_list.is_empty():
		return
	var n := mini(zone_list.size(), 500)
	var pk: PackedFloat32Array = cov[CV_TRANSIT]
	for s in n:
		var i: int = zone_list[randi() % zone_list.size()]
		if part[i] >= 0 and part[i] != i:
			continue
		if burn[i] > 0.0 or flood[i] > 0.0 or anim_cells.has(i):
			continue
		var z: int = zone[i]
		var l: int = lvl[i]
		var access := road_near(i, 2)
		var r := region_of(i)
		var maxl := 4
		if z == Z_I and district[r] == 2:
			maxl = 2
		if stage < 1:
			maxl = mini(maxl, 2)
		elif stage < 3:
			maxl = mini(maxl, 3)
		if district[r] == 1:
			maxl = mini(4, maxl + 1)
		var dmd: float = 0.0
		var des := 0.0
		match z:
			Z_R:
				dmd = demand[0]
				des = 0.45 * happy[i] + 0.4 * landv[i] + 0.3 * dmd - (tax[0] - 9) * 0.02
			Z_C:
				dmd = demand[1]
				des = 0.45 * landv[i] + 0.4 * dmd + 0.1 * minf(pk[i], 1.0) + 0.1 - (tax[1] - 9) * 0.02
				if district[r] == 4:
					des += 0.05
				if district[r] == 3:
					des -= 0.05
				if has_decree("fumar"):
					des -= 0.03
			Z_I:
				dmd = demand[2]
				des = 0.5 * dmd + 0.3 + (0.1 if trade_ok else 0.0) - (tax[2] - 9) * 0.02
			Z_M:
				dmd = (demand[0] + demand[1]) * 0.5
				des = 0.4 * happy[i] + 0.4 * landv[i] + 0.3 * dmd
		var nl := l + 1
		var ok := access and nl <= maxl
		if ok and nl >= 2 and not powered[i]:
			ok = false
		if ok and nl >= 3 and not watered[i]:
			ok = false
		if ok and nl >= 3 and z != Z_I and landv[i] < 0.42:
			ok = false
		if ok and nl >= 4 and (landv[i] < 0.58 or (z != Z_I and edu[i] < 1 and z != Z_C)):
			ok = false
		if ok and z == Z_C and nl >= 4 and pop < 2500:
			ok = false
		if ok and des > 0.42 + l * 0.06 and randf() < 0.3 and dmd > -0.2:
			level_up(i, nl)
		elif l > 0 and (not access or des < 0.16) and randf() < 0.06:
			lvl[i] = l - 1
			if part[i] == i:
				unmerge(i)
			mark_dirty(i)
		var cap := zone_cap(z, lvl[i])
		var fill := clampf(0.55 + dmd * 0.4, 0.2, 1.0)
		if z == Z_R and epidemic_days > 0:
			fill *= 0.95
		occ[i] = lerpf(occ[i], cap * fill, 0.3)
func level_up(i: int, nl: int) -> void:
	if cam != null and cell_pos(i).distance_to(cam_target) < cam_dist * 0.9 + 20.0:
		sfx("hammer")
	lvl[i] = nl
	tree[i] = 0
	vari[i] = randi() % 64
	anim_cells[i] = 1.5
	mark_dirty(i)
	if nl == 4 and (zone[i] == Z_R or zone[i] == Z_C) and cx(i) < N - 1 and cz(i) < N - 1:
		var group := [i, i + 1, i + N, i + N + 1]
		var okm := true
		for j in group:
			if zone[j] != zone[i] or lvl[j] < 3 or part[j] >= 0 or road[j] > 0 or anim_cells.has(j) and j != i:
				okm = false
		if okm and randf() < 0.5:
			for j in group:
				part[j] = i
				lvl[j] = 4
				mark_dirty(j)
func compute_stats() -> void:
	var p := 0.0
	var jc := 0.0
	var ji := 0.0
	var jm := 0.0
	var jd := 0.0
	for i in zone_list:
		match zone[i]:
			Z_R:
				p += occ[i]
			Z_M:
				p += occ[i]
				jm += CAP_MJ[lvl[i]]
			Z_C:
				jc += CAP_C[lvl[i]]
			Z_I:
				ji += CAP_I[lvl[i]]
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if def_active(a):
			p += d.get("res", 0)
			jd += d.get("job", 0)
	pop = int(p)
	jobs_cap = int(jc + ji + jm + jd)
	workers = int(pop * 0.5)
	var employed := mini(workers, jobs_cap)
	unemployment = 1.0 - float(employed) / maxf(workers, 1) if workers > 20 else 0.0
	var fillr := float(employed) / maxf(jobs_cap, 1)
	jobs_c = int(jc * fillr)
	jobs_i = int(ji * fillr)
	jobs = employed
	var dr := (float(jobs_cap) - workers) / maxf(workers, 60.0) * 0.8 + 0.25
	if pop < 200:
		dr = maxf(dr, 0.5)
	dr += 0.1 if avg_happy > 0.65 else (-0.15 if avg_happy < 0.4 else 0.0)
	var dc := (pop * 0.22 + tourists * 0.6 - jc) / maxf(pop * 0.22, 25.0)
	var di := (pop * 0.25 - ji) / maxf(pop * 0.25, 25.0) + (0.25 if trade_ok else 0.0)
	if pop < 60:
		dc = minf(dc, 0.15)
		di = minf(di, 0.2)
	demand = [clampf(dr, -1.0, 1.0), clampf(dc, -1.0, 1.0), clampf(di, -1.0, 1.0)]
	var ns := 0
	for k in STAGES.size():
		if pop >= STAGES[k][1]:
			ns = k
	if ns > max_stage:
		max_stage = ns
		stage_up(ns)
	stage = ns
	for k in [["pop100", 100], ["pop1000", 1000], ["pop10k", 10000], ["pop50k", 50000], ["pop100k", 100000]]:
		if pop >= k[1]:
			unlock_ach(k[0])
func stage_up(ns: int) -> void:
	var unl: Array = []
	for id in DEF:
		if DEF[id]["st"] == ns:
			unl.append(DEF[id]["n"])
	var txt: String = "¡La ciudad ahora es " + STAGES[ns][0] + "!"
	if not unl.is_empty():
		txt += "\nNuevo: " + ", ".join(unl)
	big_card(STAGES[ns][0], txt)
	bocinazo()
	add_news("¡Bocinazos! La ciudad llegó a " + STAGES[ns][0])
func fire_tick() -> void:
	var fc: PackedFloat32Array = cov[CV_FIRE]
	var wet := 0.3 if weather in ["Lluvia", "Tormenta", "Nieve"] else 1.0
	for i in N * N:
		if burn[i] <= 0.0:
			continue
		var c: float = fc[i]
		if c > 0.25 and randf() < 0.25 + c * 0.4:
			burn[i] = 0.0
			mark_dirty(i)
			continue
		burn[i] += 0.06 * (1.0 - minf(c, 0.9)) * wet
		if burn[i] >= 1.0:
			burn[i] = 0.0
			if zone[i] > 0:
				if part[i] >= 0:
					unmerge(anchor_of(i))
				lvl[i] = 0
				occ[i] = 0.0
			mark_dirty(i)
			add_news("Se quemó un edificio en " + DISTRICT_NAMES[region_of(i)])
			continue
		for dz in range(-1, 2):
			for dx in range(-1, 2):
				var x := cx(i) + dx
				var z := cz(i) + dz
				if not inb(x, z) or (dx == 0 and dz == 0):
					continue
				var j := idx(x, z)
				if burn[j] > 0.0 or (zone[j] == 0 and bld[j] == 0) or (zone[j] > 0 and lvl[j] == 0):
					continue
				var wf := 1.0 + Vector2(dx, dz).normalized().dot(wind) * 0.8
				if randf() < 0.012 * wf * (1.0 - 0.9 * minf(fc[j], 1.0)) * wet:
					burn[j] = 0.01
					mark_dirty(j)
func ignite(i: int) -> void:
	if burn[i] > 0.0:
		return
	burn[i] = 0.01
	mark_dirty(i)
	add_news("¡Incendio en " + DISTRICT_NAMES[region_of(i)] + "!")
	toast("¡Incendio! Los bomberos cerca lo apagan más rápido.")
	dispatch_from("fire", 21, i)
	no_fire_days = 0
func new_day() -> void:
	day += 1
	var s0 := season()
	daily_economy()
	daily_production()
	daily_garbage()
	daily_tourism()
	daily_events()
	cine_daily()
	daily_politics()
	if season() != built_season:
		built_season = season()
		terrain_dirty = true
		mark_all_dirty()
	for k in history:
		var arr: Array = history[k]
		var v := 0.0
		match k:
			"pop":
				v = pop
			"money":
				v = money
			"happy":
				v = avg_happy
			"appr":
				v = approval
		arr.append(v)
		if arr.size() > 120:
			arr.pop_front()
	check_achievements()
	pick_daily_challenge()
	for k in counters.keys():
		if String(k).begins_with("day_"):
			counters[k] = 0.0
	counters["pop_start"] = pop
	counters["money_start"] = money
	if day % 2 == 0:
		save_game(slot)
	if s0 != season():
		add_news("Empieza el " + SEASONS[season()].to_lower())
func daily_economy() -> void:
	var b := {}
	var r_tax: float = pop * tax[0] / 100.0 * 0.55 * class_mult
	if has_decree("alquiler"):
		r_tax *= 0.9
	var c_tax: float = jobs_c * tax[1] / 100.0 * 0.7
	var i_tax: float = jobs_i * tax[2] / 100.0 * 0.7
	var tour_inc: float = tourists * 4.0
	var sunday := 0.0
	var upkeep := 0.0
	var scale := 1.0 + pop / 40000.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		var u: float = d["upk"]
		if d.has("dep"):
			u *= budget[d["dep"]] / 100.0
		upkeep += u * scale
		if is_sunday() and d.has("sunday") and def_active(a):
			sunday += d["sunday"]
	if is_sunday() and has_decree("feria"):
		sunday += pop * 0.05
	var roads := 0.0
	for i in N * N:
		if road[i] > 0:
			roads += ROAD_UPK[road[i]]
	var line_cost := 0.0
	var fares := 0.0
	for ln in lines:
		line_cost += {"bus": 20.0, "tram": 40.0, "metro": 120.0, "train": 80.0, "ferry": 40.0}[ln["kind"]] * budget[5] / 100.0
	var riders: float = counters.get("green_share", 0.0) * pop * 0.3
	if not has_decree("boleto"):
		fares = riders * 0.4
	var dec := 0.0
	for d in DECREES:
		if has_decree(d["id"]):
			dec += d["cost"] * (1.0 + pop / 20000.0)
	var loan := 0.0
	if debt > 0.0:
		var interest := debt * 0.004
		var pay := minf(debt + interest, maxf(50.0, debt * 0.03))
		debt = debt + interest - pay
		loan = pay
		if debt < 1.0:
			debt = 0.0
			unlock_ach("nodebt")
			add_news("¡Terminaste de pagar la deuda!")
	var inc := r_tax + c_tax + i_tax + tour_inc + sunday + fares
	var out := upkeep + roads + line_cost + dec + loan
	b = {"Impuesto residencial": r_tax, "Impuesto comercial": c_tax, "Impuesto industrial": i_tax, "Turismo": tour_inc, "Domingo (cancha y asado)": sunday, "Boletos": fares,
		"Servicios": -upkeep, "Calles": -roads, "Transporte": -line_cost, "Decretos": -dec, "Préstamo": -loan}
	last_budget = b
	last_net = inc - out
	if not creative:
		money += last_net
	else:
		money = maxf(money, 999999.0)
	if money < -5000.0 and not game_over_shown:
		game_over_shown = true
		big_card("Números en rojo", "La ciudad debe mucha plata. Pedí un préstamo, subí impuestos o bajá gastos en Presupuesto.")
	if money > 0:
		game_over_shown = false
	if money >= 100000:
		unlock_ach("rich")
func daily_production() -> void:
	var food := 0.0
	var prod := 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if not def_active(a):
			continue
		food += d.get("food", 0)
		if d.has("prod"):
			var use := minf(food_stock + food, 40.0)
			food -= use
			prod += d["prod"]
	for i in zone_list:
		if zone[i] == Z_I and lvl[i] > 0:
			prod += lvl[i] * 1.2 * (0.8 if has_decree("verde") else 1.0)
	food_stock += food - pop * 0.02
	prod_stock += prod - pop * 0.015
	var keep: Array = []
	for c in contracts:
		var key := "food" if c["kind"] == "food" else "prod"
		var stock := food_stock if key == "food" else prod_stock
		if stock >= c["qty"]:
			if key == "food":
				food_stock -= c["qty"]
			else:
				prod_stock -= c["qty"]
			money += c["qty"] * c["price"]
			c["days"] -= 1
			if c["days"] > 0:
				keep.append(c)
			else:
				neighbors[c["nb"]]["rel"] = minf(100.0, neighbors[c["nb"]]["rel"] + 8.0)
				add_news("Se cumplió el contrato con " + neighbors[c["nb"]]["n"])
		else:
			neighbors[c["nb"]]["rel"] = maxf(0.0, neighbors[c["nb"]]["rel"] - 10.0)
			add_news("No pudimos cumplir con " + neighbors[c["nb"]]["n"])
	contracts = keep
	if trade_ok:
		if food_stock > 200.0:
			money += (food_stock - 200.0) * market[0] * 0.5
			food_stock = 200.0
		if prod_stock > 200.0:
			money += (prod_stock - 200.0) * market[1] * 0.5
			prod_stock = 200.0
	if food_stock < 0.0:
		money += food_stock * market[0] * (1.0 if trade_ok else 1.6)
		food_stock = 0.0
	if prod_stock < 0.0:
		money += prod_stock * market[1] * (1.0 if trade_ok else 1.6)
		prod_stock = 0.0
	market[0] = clampf(market[0] * randf_range(0.93, 1.07), 3.0, 12.0)
	market[1] = clampf(market[1] * randf_range(0.93, 1.07), 5.0, 18.0)
func daily_garbage() -> void:
	garb_made = (pop * 0.9 + jobs * 0.4) * (0.7 if has_decree("recicla") else 1.0)
	garb_cap = 0.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if d.has("gb") and def_active(a):
			garb_cap += float(d["gb"]) * budget[6] / 100.0
	var gc: PackedFloat32Array = cov[CV_GARB]
	var over := maxf(0.0, garb_made - garb_cap)
	for i in zone_list:
		if lvl[i] == 0:
			continue
		if gc[i] > 0.05 and over <= 0.0:
			garbp[i] = maxf(0.0, garbp[i] - 1.5)
		elif gc[i] <= 0.05 or randf() < over / maxf(garb_made, 1.0):
			if pop > 80:
				garbp[i] = minf(4.0, garbp[i] + 0.25)
		if garbp[i] > 0.5 and randf() < 0.05:
			mark_dirty(i)
	if over > 0 and pop > 150 and day % 3 == 0:
		add_news("Se junta la basura: hace falta un relleno o un basurero")
func daily_tourism() -> void:
	var attract: float = mods["tour"]
	var beds := 60.0
	for a in anchors:
		if bld[a] == 0:
			continue
		var d: Dictionary = DEF[bld[a]]
		if not def_active(a):
			continue
		var t: float = d.get("tour", 0)
		if bld[a] == 40:
			t *= [2.5, 0.8, 0.2, 1.2][season()]
		attract += t
		beds += d.get("bed", 0)
	if has_decree("turismo"):
		attract *= 1.3
	if festival_days > 0:
		attract += 10.0
	var t2 := minf(beds, attract * 12.0)
	if not trade_ok:
		t2 *= 0.6
	tourists = int(t2)
	if tourists >= 100:
		unlock_ach("tourist")
func daily_events() -> void:
	if test_city:
		return
	var s := season()
	var r := randf()
	var opt: Array = [["Soleado", 0.45], ["Nublado", 0.25], ["Lluvia", 0.2], ["Tormenta", 0.1]]
	if s == 2:
		opt = [["Soleado", 0.35], ["Nublado", 0.3], ["Lluvia", 0.15], ["Nieve", 0.15], ["Tormenta", 0.05]]
	elif s == 0:
		opt = [["Soleado", 0.5], ["Calor", 0.2], ["Nublado", 0.1], ["Lluvia", 0.1], ["Tormenta", 0.1]]
	var acc := 0.0
	var neww := "Soleado"
	for o in opt:
		acc += o[1]
		if r < acc:
			neww = o[0]
			break
	if (neww == "Nieve") != (weather == "Nieve"):
		terrain_dirty = true
		mark_all_dirty()
	weather = neww
	wind = Vector2.from_angle(randf() * TAU)
	for i in N * N:
		if flood[i] > 0.0:
			flood[i] -= 1.0
			if flood[i] <= 0.0:
				flood[i] = 0.0
				mark_dirty(i)
	if not opts["calm"]:
		if weather == "Tormenta":
			add_news("Tormenta fuerte sobre la ciudad")
			if randf() < 0.5:
				do_flood()
			if not zone_list.is_empty() and randf() < 0.5:
				var i: int = zone_list[randi() % zone_list.size()]
				if lvl[i] > 0:
					ignite(i)
		var fc: PackedFloat32Array = cov[CV_FIRE]
		var dry := 1.6 if (s == 0 and weather in ["Soleado", "Calor"]) else 1.0
		for k in mini(zone_list.size(), 400):
			var i: int = zone_list[randi() % zone_list.size()]
			if lvl[i] == 0:
				continue
			var p := 0.0012 * (1.0 - minf(fc[i], 1.0)) * dry * (2.0 if zone[i] == Z_I else 1.0)
			if randf() < p:
				ignite(i)
		if pop > 300 and not zone_list.is_empty():
			var i: int = zone_list[randi() % zone_list.size()]
			if crime[i] > 0.45 and randf() < 0.5:
				add_news("Robo en " + DISTRICT_NAMES[region_of(i)])
				dispatch_from("police", 20, i)
		if epidemic_days > 0:
			epidemic_days -= 1
			if not zone_list.is_empty():
				dispatch_from("ambulance", 22, zone_list[randi() % zone_list.size()])
		elif pop > 1500 and randf() < 0.04:
			var hc: PackedFloat32Array = cov[CV_HEALTH]
			var avg := 0.0
			for i in zone_list:
				avg += minf(hc[i], 1.0)
			avg /= maxf(zone_list.size(), 1)
			if avg < 0.3:
				epidemic_days = 3
				add_news("Brote de gripe: faltan hospitales y salitas")
				toast("Hay una epidemia. Más salud la frena.")
	no_fire_days += 1
	if no_fire_days >= 30:
		unlock_ach("noFire")
	var d := doy()
	if d == 0 and day > 1:
		add_news("¡Feliz año nuevo!")
		fireworks(cam_target, 40)
		sfx("cheer")
	if d == 4:
		add_news("¡Carnaval! Murgas en todos los barrios")
		mods["hp"] = 0.05
		mods["days"] = 1
		confetti([Color(0.95, 0.2, 0.5), Color(0.2, 0.8, 0.9), Color(0.95, 0.85, 0.2)])
		unlock_ach("carnaval")
	if d == 30:
		add_news("Día de la primavera: los chicos van a las plazas")
		mods["hp"] = 0.03
		mods["days"] = 1
	if d == 26:
		if randf() < 0.62:
			add_news("¡¡ARGENTINA CAMPEÓN DEL MUNDO!! Festejos en toda la ciudad")
			big_card("¡Campeones!", "¡Ganamos la final del Mundial! Banderas, bocinazos y todos a la plaza.")
			confetti([Color(0.45, 0.75, 0.95), Color(1, 1, 1), Color(0.95, 0.85, 0.2)])
			bocinazo()
			mods["hp"] = 0.08
			mods["days"] = 3
			unlock_ach("mundial")
		else:
			add_news("Perdimos la final del Mundial. La ciudad está triste.")
			mods["hp"] = -0.04
			mods["days"] = 2
	if is_sunday():
		add_news("Domingo: asado, fútbol y feria")
	if mods["days"] > 0:
		mods["days"] -= 1
		if mods["days"] <= 0:
			mods["hp"] = 0.0
			mods["crime"] = 0.0
			mods["tour"] = 0.0
	if festival_days > 0:
		festival_days -= 1
	if day % 3 == 0 and offer == null and pop > 100:
		var nb := randi() % neighbors.size()
		var kind := "food" if randf() < 0.5 else "prod"
		offer = {"nb": nb, "kind": kind, "qty": 20 + randi() % 40, "price": snappedf((market[0] if kind == "food" else market[1]) * randf_range(1.0, 1.4), 0.1), "days": 3 + randi() % 4}
		add_news(neighbors[nb]["n"] + " quiere comprarnos " + ("comida" if kind == "food" else "productos"))
func do_flood() -> void:
	if map_kind == 4 and randf() < 0.7:
		return
	var n := 0
	for i in N * N:
		if terr[i] == T_WATER or wdist[i] > 2.0 or hgt[i] > 0.5:
			continue
		var safe := false
		for dz in range(-2, 3):
			for dx in range(-2, 3):
				var x := cx(i) + dx
				var z := cz(i) + dz
				if inb(x, z) and wire[idx(x, z)] & W_LEVEE:
					safe = true
		if safe or randf() > 0.6:
			continue
		flood[i] = 2.0
		n += 1
		if zone[i] > 0 and lvl[i] > 0 and randf() < 0.3:
			lvl[i] -= 1
		mark_dirty(i)
	if n > 0:
		add_news("Inundación en la costa: %d lotes bajo el agua. Los diques protegen." % n)
func daily_politics() -> void:
	var target := 0.3 + avg_happy * 0.6 - unemployment * 0.2
	if money < 0:
		target -= 0.1
	for a in anchors:
		if bld[a] == 0:
			continue
		target += DEF[bld[a]].get("appr", 0.0)
	approval = clampf(lerpf(approval, target, 0.15), 0.0, 1.0)
	if stage >= 2 or day > 60:
		if day == next_election - 3 and promise < 0:
			ask_promise()
		if day >= next_election:
			run_election()
	if day > 5 and day % 3 == 0 and decision == null and max_stage >= 1:
		decision = DECISIONS[randi() % DECISIONS.size()]
		show_decision()
	if request != null:
		var c: int = request["cell"]
		var cvv: PackedFloat32Array = cov[request["cv"]]
		if cvv[c] > 0.25:
			approval = minf(1.0, approval + 0.05)
			money += 500
			add_news("Los vecinos de %s agradecen: ya tienen %s" % [DISTRICT_NAMES[region_of(c)], request["what"]])
			toast("¡Cumpliste el pedido de los vecinos! +$500")
			request = null
		elif day > request["until"]:
			approval = maxf(0.0, approval - 0.03)
			add_news("Los vecinos de %s se quejan: no llegó %s" % [DISTRICT_NAMES[region_of(c)], request["what"]])
			request = null
	elif day > 4 and day % 4 == 0 and pop > 60:
		make_request()
func make_request() -> void:
	var homes: Array = []
	for i in zone_list:
		if zone[i] == Z_R and lvl[i] > 0:
			homes.append(i)
	if homes.is_empty():
		return
	for tries in 10:
		var h: int = homes[randi() % homes.size()]
		var rq: Array = REQUESTS[randi() % REQUESTS.size()]
		var cvv: PackedFloat32Array = cov[rq[1]]
		if cvv[h] < 0.15:
			request = {"cell": h, "cv": rq[1], "what": rq[0], "until": day + 6}
			add_news("Los vecinos de %s piden %s (6 días)" % [DISTRICT_NAMES[region_of(h)], rq[0]])
			toast("Pedido de los vecinos: %s en %s" % [rq[0], DISTRICT_NAMES[region_of(h)]])
			return
func promise_metric(k: String) -> float:
	match k:
		"crime":
			var s := 0.0
			for i in zone_list:
				s += crime[i]
			return -s / maxf(zone_list.size(), 1)
		"park":
			var pk: PackedFloat32Array = cov[CV_PARK]
			var s2 := 0.0
			for i in zone_list:
				s2 += minf(pk[i], 1.0)
			return s2 / maxf(zone_list.size(), 1)
		"power":
			return power_frac
		"traffic":
			return -avg_commute
		"jobs":
			return -unemployment
	return 0.0
func set_promise(k: int) -> void:
	promise = k
	promise_base = promise_metric(PROMISES[k][1])
	add_news("Promesa de campaña: " + PROMISES[k][0])
func run_election() -> void:
	var bonus := 0.0
	if promise >= 0:
		var now := promise_metric(PROMISES[promise][1])
		if now > promise_base + 0.01 or (PROMISES[promise][1] == "power" and now >= 0.99):
			bonus = 0.06
			add_news("Cumpliste tu promesa: " + PROMISES[promise][0])
		else:
			bonus = -0.05
			add_news("No cumpliste tu promesa: " + PROMISES[promise][0])
	var result := clampf(approval + bonus + randf_range(-0.05, 0.05), 0.0, 1.0)
	next_election = day + 15
	promise = -1
	if result >= 0.5:
		unlock_ach("election")
		money += 1000
		big_card("¡Ganaste las elecciones!", "Te votó el %d%% de la gente. Seguís siendo intendente." % int(result * 100))
		bocinazo()
	else:
		big_card("Perdiste las elecciones", "Sacaste %d%%. Te dejan seguir, pero el concejo te recorta la plata y la aprobación arranca de cero." % int(result * 100))
		if money > 0:
			money *= 0.8
		approval = 0.45
func apply_effects(e: Dictionary) -> void:
	if e.has("money"):
		money += e["money"]
	if e.has("appr"):
		approval = clampf(approval + e["appr"], 0.0, 1.0)
	if e.has("hp"):
		mods["hp"] = mods["hp"] + e["hp"]
		mods["days"] = 5
	if e.has("crime"):
		mods["crime"] = mods["crime"] + e["crime"]
		mods["days"] = 5
	if e.has("tour"):
		mods["tour"] = mods["tour"] + e["tour"]
		mods["days"] = 5
	if e.has("edu"):
		mods["edu"] = mods["edu"] + e["edu"]
	if e.has("pol"):
		mods["hp"] = mods["hp"] - e["pol"]
		mods["days"] = 5
func hold_festival() -> void:
	var cost := 800.0 + pop * 0.2
	if not creative and money < cost:
		toast("Un festival cuesta " + fmt_money(cost))
		return
	if not creative:
		money -= cost
	festival_days = 3
	approval = minf(1.0, approval + 0.03)
	add_news("¡Festival en la plaza! Música y comida para todos")
	confetti([Color(0.95, 0.4, 0.2), Color(0.3, 0.8, 0.4), Color(0.95, 0.9, 0.3)])
	fireworks(cam_target, 25)
	sfx("cheer")
	unlock_ach("festival")
func take_loan(amount: float) -> void:
	if debt > 120000:
		toast("El banco no te presta más")
		return
	money += amount
	debt += amount * 1.05
	add_news("Préstamo de " + fmt_money(amount))
	sfx("cash")
func fund_wonder(a: int) -> void:
	if not wonder_progress.has(a):
		return
	if not creative and money < WONDER_FUND:
		toast("Cada aporte cuesta " + fmt_money(WONDER_FUND))
		return
	if not creative:
		money -= WONDER_FUND
	wonder_progress[a] = wonder_progress[a] + 1
	mark_dirty(a)
	sim_dirty = true
	if wonder_progress[a] >= WONDER_STEPS:
		big_card("¡Se inauguró " + DEF[bld[a]]["n"] + "!", "Llegan turistas de todo el país.")
		fireworks(cell_pos(a), 60)
		bocinazo()
		add_news("Gran inauguración: " + DEF[bld[a]]["n"])
		unlock_ach("wonder")
		count_add("wonder")
	else:
		toast("Obra al %d%%" % int(100.0 * wonder_progress[a] / WONDER_STEPS))
func obj_value(k: String) -> float:
	match k:
		"pop":
			return pop
		"roads":
			var n := 0
			for i in N * N:
				if road[i] > 0:
					n += 1
			return n
		"zoneR":
			var n2 := 0
			for i in zone_list:
				if zone[i] == Z_R:
					n2 += 1
			return n2
		"zoneC":
			var n3 := 0
			for i in zone_list:
				if zone[i] == Z_C:
					n3 += 1
			return n3
		"power":
			return 1.0 if power_sup > 0 else 0.0
		"water":
			return 1.0 if water_sup > 0 else 0.0
		"serv":
			var n4 := 0
			for a in anchors:
				if bld[a] == 0:
					continue
				if DEF[bld[a]]["c"] == "serv":
					n4 += 1
			return n4
		"line":
			return lines.size()
		"garb":
			return 1.0 if garb_cap > 0 else 0.0
		"park":
			var n5 := 0
			for a in anchors:
				if bld[a] == 0:
					continue
				if DEF[bld[a]]["c"] == "park":
					n5 += 1
			return n5
		"wonder":
			for a in wonder_progress:
				if wonder_progress[a] >= WONDER_STEPS:
					return 1.0
			return 0.0
	return 0.0
func check_progress() -> void:
	if story and obj_index < OBJECTIVES.size():
		var o: Dictionary = OBJECTIVES[obj_index]
		if obj_value(o["k"]) >= o["v"]:
			money += o["r"]
			obj_index += 1
			sfx("cheer")
			if obj_index < OBJECTIVES.size():
				var nx: Dictionary = OBJECTIVES[obj_index]
				marta("¡Muy bien! Te ganaste %s.\n\n%s" % [fmt_money(o["r"]), nx["m"]])
			else:
				marta("¡Terminaste todos los objetivos! La ciudad es tuya. Seguí creciendo como quieras.")
	if not daily_done and daily_ch >= 0:
		var ch: Array = DAILY_CHALLENGES[daily_ch]
		var v := 0.0
		match ch[1]:
			"net":
				v = money - counters.get("money_start", money)
			"popgain":
				v = pop - counters.get("pop_start", pop)
			_:
				v = counters.get("day_" + ch[1], 0.0)
		if v >= ch[2]:
			daily_done = true
			money += 300
			toast("¡Reto del día cumplido! +$300")
			sfx("cheer")
	check_scenario()
func pick_daily_challenge() -> void:
	daily_ch = randi() % DAILY_CHALLENGES.size()
	daily_done = false
func check_scenario() -> void:
	if scenario == 0 or counters.get("scenario_done", 0.0) > 0.0:
		return
	var win := false
	var lose := false
	match scenario:
		1:
			win = pop >= 2500 and power_frac >= 0.99
			lose = day > 60
		2:
			win = obj_value("wonder") >= 1.0
			lose = day > 80
		3:
			win = counters.get("green_share", 0.0) >= 0.25 and pop > 300
			if win:
				unlock_ach("bike")
			lose = day > 60
		4:
			win = tourists >= 300
			lose = day > 60
		5:
			win = pop >= 5000
			lose = day > 10 and approval < 0.6
	if win:
		counters["scenario_done"] = 1.0
		big_card("¡Ganaste el escenario!", SCENARIOS[scenario]["n"] + ": objetivo cumplido. Podés seguir jugando.")
		fireworks(cam_target, 50)
	elif lose:
		counters["scenario_done"] = 2.0
		big_card("Escenario perdido", SCENARIOS[scenario]["n"] + ": no llegaste a tiempo. Podés seguir jugando libre.")
func check_achievements() -> void:
	var nt := 0
	for i in N * N:
		if tree[i] > 0:
			nt += 1
	if nt >= 50 and counters.get("trees", 0.0) >= 20:
		unlock_ach("trees")
	if avg_happy > 0.8 and pop > 500:
		unlock_ach("happy")
	if green_power >= 0.99 and power_sup > 0:
		unlock_ach("green")
	if counters.get("green_share", 0.0) >= 0.3 and pop > 500:
		unlock_ach("bike")
func unlock_ach(id: String) -> void:
	if achieved.has(id):
		return
	achieved[id] = day
	var nm := id
	for a in ACHIEVEMENTS:
		if a[0] == id:
			nm = a[1]
	notify("LOGRO DESBLOQUEADO", nm, "trophy")
	sfx("cheer")
func advice() -> String:
	if power_sup <= 0 and pop > 0:
		return "Poné una usina y conectala: sin luz los barrios no crecen."
	if water_sup <= 0 and pop > 30:
		return "Falta agua: una torre de agua anda en cualquier lado."
	if power_frac < 0.9:
		return "Hay cortes de luz: hace falta otra usina."
	if water_frac < 0.9:
		return "Falta agua en algunos barrios: más bombas o torres."
	if garb_made > garb_cap and pop > 150:
		return "La basura se junta: poné un relleno sanitario o basureros."
	if demand[0] > 0.5 and zone_count(Z_R) < 30:
		return "La gente quiere vivir acá: marcá más lotes residenciales."
	if demand[1] > 0.5:
		return "Falta comercio: marcá lotes comerciales."
	if demand[2] > 0.5:
		return "Falta industria: marcá lotes industriales lejos de las casas."
	if unemployment > 0.2:
		return "Hay desocupados: más comercio e industria."
	if money < 1000:
		return "Poca plata: subí un poco los impuestos o bajá gastos en Presupuesto."
	var counts := {}
	for i in zone_list:
		if why[i] > 0 and (zone[i] == Z_R or zone[i] == Z_M):
			counts[why[i]] = counts.get(why[i], 0) + 1
	var best := 0
	var bc := 0
	for k in counts:
		if counts[k] > bc:
			bc = counts[k]
			best = k
	if best > 0:
		return "Lo que más molesta a la gente: " + WHY_TEXT[best] + "."
	return "La ciudad anda bien. ¡Seguí creciendo!"
# ================================================================ src/build.gd
# Herramientas de construir, demoler, rotondas, paradas y líneas.
const LINE_TOOLS := ["road", "cable", "pipe", "bike", "tram", "levee"]
func line_cells(a: int, b: int) -> Array:
	var out: Array = []
	if a < 0 or b < 0:
		return out
	var x0 := cx(a)
	var z0 := cz(a)
	var x1 := cx(b)
	var z1 := cz(b)
	var dx := x1 - x0
	var dz := z1 - z0
	var adx := absi(dx)
	var adz := absi(dz)
	var diag := adx >= 2 and adz >= 2 and maxf(adx, adz) / maxf(minf(adx, adz), 1.0) <= 2.2
	if not diag:
		if adx >= adz:
			z1 = z0
		else:
			x1 = x0
		var sx := signi(x1 - x0)
		var sz := signi(z1 - z0)
		var x := x0
		var z := z0
		out.append(idx(x, z))
		while x != x1 or z != z1:
			x += sx
			z += sz
			out.append(idx(x, z))
		return out
	var sx2 := signi(dx)
	var sz2 := signi(dz)
	var x := x0
	var z := z0
	out.append(idx(x, z))
	var steps := adx + adz
	for k in steps:
		var fx := float(absi(x - x0) + 1) / float(adx) if adx > 0 else 99.0
		var fz := float(absi(z - z0) + 1) / float(adz) if adz > 0 else 99.0
		if x != x1 and (fx <= fz or z == z1):
			x += sx2
		elif z != z1:
			z += sz2
		out.append(idx(x, z))
	return out
func rect_cells(a: int, b: int) -> Array:
	var out: Array = []
	if a < 0 or b < 0:
		return out
	for z in range(mini(cz(a), cz(b)), maxi(cz(a), cz(b)) + 1):
		for x in range(mini(cx(a), cx(b)), maxi(cx(a), cx(b)) + 1):
			out.append(idx(x, z))
	return out
func drag_cells() -> Array:
	if tool["k"] in LINE_TOOLS:
		return line_cells(drag_a, drag_b)
	return rect_cells(drag_a, drag_b)
func cell_cost(i: int) -> float:
	if i < 0:
		return -1.0
	if not is_owned(i):
		return -1.0
	var k: String = tool["k"]
	match k:
		"road":
			var t: int = tool["t"]
			if bld[i] > 0 or (zone[i] > 0 and lvl[i] > 0):
				return -1.0
			if road[i] >= t:
				return 0.0
			if terr[i] == T_WATER:
				if t == 1:
					return -1.0
				return ROAD_COST[t] * 3.0
			var c: float = ROAD_COST[t] - ROAD_COST[road[i]]
			if terr[i] == T_ROCK:
				c *= 2.0
			return c
		"zone":
			if road[i] > 0 or bld[i] > 0 or terr[i] == T_WATER or terr[i] == T_ROCK:
				return -1.0
			if zone[i] == tool["z"]:
				return 0.0
			return float(ZONE_COST)
		"dezone":
			return 0.0 if zone[i] > 0 else -1.0
		"demolish":
			if terr[i] == T_ROCK:
				return 25.0
			if road[i] > 0 or bld[i] > 0 or zone[i] > 0 or tree[i] > 0 or wire[i] > 0:
				return 2.0
			return -1.0
		"cable":
			if terr[i] == T_WATER:
				return -1.0
			return 0.0 if wire[i] & W_POWER else 3.0
		"pipe":
			if terr[i] == T_WATER:
				return -1.0
			return 0.0 if wire[i] & W_PIPE else 3.0
		"bike":
			if road[i] < 2 or road[i] == 4:
				return -1.0
			return 0.0 if wire[i] & W_BIKE else 6.0
		"tram":
			if road[i] < 3 or road[i] == 4:
				return -1.0
			return 0.0 if wire[i] & W_TRAM else 25.0
		"levee":
			if terr[i] == T_WATER or road[i] > 0 or bld[i] > 0 or zone[i] > 0:
				return -1.0
			return 0.0 if wire[i] & W_LEVEE else 40.0
		"trees":
			if road[i] > 0 or bld[i] > 0 or zone[i] > 0 or terr[i] == T_WATER or tree[i] > 0:
				return -1.0
			return 6.0
	return -1.0
func commit_drag() -> void:
	clear_preview()
	var cells := drag_cells()
	apply_cells(cells)
var undo_rec: Dictionary = {}
func do_undo() -> void:
	if undo_rec.is_empty():
		toast("No hay nada para deshacer")
		return
	if undo_rec.has("def"):
		var a: int = undo_rec["def"]
		if bld[a] > 0:
			remove_def(a)
	else:
		for r in undo_rec["cells"]:
			var c: int = r[0]
			road[c] = r[1]
			zone[c] = r[2]
			lvl[c] = r[3]
			wire[c] = r[4]
			tree[c] = r[5]
			part[c] = r[6]
			occ[c] = r[7]
			vari[c] = r[8]
			mark_dirty(c)
	if not creative:
		money += float(undo_rec["money"])
	undo_rec = {}
	sim_dirty = true
	sfx("demolish")
	toast("Deshecho")
func apply_cells(cells: Array) -> void:
	var total := 0.0
	for c in cells:
		var cc := cell_cost(c)
		if cc > 0.0:
			total += cc
	if not creative and total > money:
		toast("No alcanza la plata: necesitás " + fmt_money(total))
		sfx("error")
		return
	var k: String = tool["k"]
	var changed := 0
	var rec: Array = []
	for c in cells:
		if cell_cost(c) >= 0.0:
			rec.append([c, road[c], zone[c], lvl[c], wire[c], tree[c], part[c], occ[c], vari[c]])
	for c in cells:
		var cc := cell_cost(c)
		if cc < 0.0:
			continue
		match k:
			"road":
				if road[c] < tool["t"]:
					road[c] = tool["t"]
					tree[c] = 0
					if zone[c] > 0:
						zone[c] = 0
						lvl[c] = 0
					count_add("roads")
					changed += 1
			"zone":
				if zone[c] != tool["z"]:
					zone[c] = tool["z"]
					lvl[c] = 0
					occ[c] = 0.0
					part[c] = -1
					vari[c] = randi() % 64
					count_add("zones")
					if tool["z"] == Z_R:
						count_add("zoneR")
					if tool["z"] == Z_C:
						count_add("zoneC")
					changed += 1
			"dezone":
				clear_zone(c)
				changed += 1
			"demolish":
				demolish_cell(c)
				flatten_cell(c)
				changed += 1
			"cable":
				wire[c] |= W_POWER
				changed += 1
			"pipe":
				wire[c] |= W_PIPE
				changed += 1
			"bike":
				wire[c] |= W_BIKE
				changed += 1
			"tram":
				wire[c] |= W_TRAM
				changed += 1
			"levee":
				wire[c] |= W_LEVEE
				tree[c] = 0
				changed += 1
			"trees":
				tree[c] = pick_tree_kind(c, RandomNumberGenerator.new())
				count_add("trees")
				changed += 1
		mark_dirty(c)
	if changed > 0:
		if not creative:
			money -= total
		sim_dirty = true
		undo_rec = {} if k == "demolish" else {"cells": rec, "money": total}
		sfx("build" if k != "demolish" else "demolish")
		vibrate()
		if k == "road":
			unlock_ach("first_road")
			if opts["autoround"]:
				auto_rounds(cells)
func clear_zone(c: int) -> void:
	var a := anchor_of(c)
	if zone[c] > 0 and part[c] >= 0:
		unmerge(a)
	zone[c] = 0
	lvl[c] = 0
	occ[c] = 0.0
	part[c] = -1
	anim_cells.erase(c)
func unmerge(a: int) -> void:
	for dz in 2:
		for dx in 2:
			var j := a + dz * N + dx
			if j < N * N and part[j] == a:
				part[j] = -1
				lvl[j] = mini(lvl[j], 3)
				mark_dirty(j)
func flatten_cell(c: int) -> void:
	if terr[c] == T_ROCK:
		terr[c] = T_LAND
		hgt[c] = 0.0
		terrain_dirty = true
		mark_dirty(c)
func demolish_cell(c: int) -> void:
	if bld[c] > 0:
		remove_def(anchor_of(c))
	clear_zone(c)
	if road[c] > 0:
		road[c] = 0
		stops.erase(c)
		wire[c] &= ~(W_BIKE | W_TRAM | W_ROUND)
	tree[c] = 0
	wire[c] = 0
	burn[c] = 0.0
	garbp[c] = 0.0
func remove_def(a: int) -> void:
	var d: Dictionary = DEF[bld[a]]
	var sz: int = d["sz"]
	for dz in sz:
		for dx in sz:
			var j := a + dz * N + dx
			if j < N * N and anchor_of(j) == a:
				bld[j] = 0
				part[j] = -1
				burn[j] = 0.0
				mark_dirty(j)
	wonder_progress.erase(a)
	for ln in lines:
		ln["stops"] = ln["stops"].filter(func(s): return s != a)
	sim_dirty = true
func can_place_def(a: int, id: int) -> String:
	if a < 0:
		return "Fuera del mapa"
	var d: Dictionary = DEF[id]
	var sz: int = d["sz"]
	var cells := def_cells(a, sz)
	if cells.size() < sz * sz:
		return "No entra"
	if not creative and d["st"] > max_stage:
		return "Se desbloquea en etapa " + STAGES[d["st"]][0]
	if d.get("unique", false):
		for i in N * N:
			if bld[i] == id:
				return "Ya tenés uno"
	if scenario == 1 and id == 42:
		return "En este escenario no hay carbón"
	var need: String = d.get("need", "")
	var has_shore := false
	var has_sand := false
	for c in cells:
		if not is_owned(c):
			return "Esa zona no es tuya. Comprala en Herramientas."
		if road[c] > 0 or bld[c] > 0 or (zone[c] > 0 and lvl[c] > 0):
			return "Está ocupado"
		if terr[c] == T_WATER and need != "shore":
			return "Es agua"
		if terr[c] == T_ROCK:
			return "Es un cerro"
		if flood[c] > 0.0:
			return "Está inundado, esperá que baje el agua"
		if near_water(c, 1):
			has_shore = true
		if terr[c] == T_SAND:
			has_sand = true
	if need == "shore" and not has_shore:
		return "Tiene que ir en la costa"
	if need == "sand" and not has_sand:
		return "Tiene que ir en la arena"
	if not creative and money < d["cost"]:
		return "No alcanza la plata"
	return ""
func place_def(a: int, id: int) -> bool:
	var err := can_place_def(a, id)
	if err != "":
		toast(err)
		sfx("error")
		return false
	var d: Dictionary = DEF[id]
	var sz: int = d["sz"]
	var cells := def_cells(a, sz)
	var anchor: int = cells[0]
	for c in cells:
		clear_zone(c)
		bld[c] = id
		part[c] = anchor if sz > 1 else -1
		tree[c] = 0
		mark_dirty(c)
	vari[anchor] = randi() % 64
	if id == 66 and not cine_told:
		cine_told = true
		queue_card({"title": "🎬 ¡Abrió el cine!", "text": "Cada pocos días se estrena una película (Scream, Chucky, It, Avengers, Star Wars y muchas más). Durante 24 horas sus protagonistas salen a las calles haciendo lo que hacen en la película.", "btns": [["¡Genial!", Callable()]]})
	if d["c"] == "wonder":
		wonder_progress[anchor] = 0
	if not creative:
		money -= d["cost"]
	count_add("builds")
	undo_rec = {"def": anchor, "money": 0.0 if creative else float(d["cost"])}
	match d["c"]:
		"serv":
			count_add("serv")
		"park":
			count_add("park")
	if d.has("pw"):
		count_add("power")
	if d.has("wt"):
		count_add("water")
	if d.has("gb"):
		count_add("garb")
	if id == 53:
		unlock_ach("metro")
	if id == 56:
		unlock_ach("airport")
	if id == 55:
		unlock_ach("port")
	if id == 35:
		unlock_ach("stadium")
	if not road_near(anchor, sz):
		toast(d["n"] + " necesita una calle cerca para funcionar")
	sim_dirty = true
	sfx("build")
	vibrate()
	anim_cells[anchor] = 1.2
	return true
func block_fill(c: int) -> Array:
	if c < 0:
		return []
	var ok := func(j: int) -> bool:
		return road[j] == 0 and bld[j] == 0 and terr[j] != T_WATER and terr[j] != T_ROCK and is_owned(j)
	if not ok.call(c):
		return [c]
	var seen := {c: true}
	var q: Array = [c]
	var head := 0
	while head < q.size():
		var j: int = q[head]
		head += 1
		if q.size() > 90:
			break
		for o in [1, -1, N, -N]:
			var k: int = j + o
			if k < 0 or k >= N * N:
				continue
			if (o == 1 or o == -1) and cz(k) != cz(j):
				continue
			if seen.has(k) or not ok.call(k):
				continue
			seen[k] = true
			q.append(k)
	if q.size() > 90:
		var out: Array = []
		for dz in range(-1, 2):
			for dx in range(-1, 2):
				if inb(cx(c) + dx, cz(c) + dz):
					out.append(idx(cx(c) + dx, cz(c) + dz))
		return out
	return q
func auto_rounds(cells: Array) -> void:
	for c in cells:
		if road[c] != 3 or (wire[c] & W_ROUND):
			continue
		var nb := road_n(c)
		if not (nb[0] and nb[1] and nb[2] and nb[3]):
			continue
		var near := false
		for dz in range(-2, 3):
			for dx in range(-2, 3):
				var x := cx(c) + dx
				var z := cz(c) + dz
				if inb(x, z) and (wire[idx(x, z)] & W_ROUND):
					near = true
		if not near:
			wire[c] |= W_ROUND
			mark_dirty(c)
func toggle_round(c: int) -> void:
	if c < 0 or road[c] < 2:
		toast("La rotonda va en un cruce de calles")
		return
	var nb := road_n(c)
	var cnt := int(nb[0]) + int(nb[1]) + int(nb[2]) + int(nb[3])
	if cnt < 3:
		toast("La rotonda va en un cruce de 3 o 4 calles")
		return
	if not creative and money < 150:
		toast("No alcanza la plata")
		return
	wire[c] ^= W_ROUND
	if not creative:
		money -= 150
	mark_dirty(c)
	sim_dirty = true
	sfx("build")
func place_stop(c: int, kind: String) -> void:
	if c < 0 or road[c] == 0:
		toast("La parada va sobre una calle")
		return
	if kind == "tram" and not (wire[c] & W_TRAM):
		toast("La parada de tranvía va sobre vías de tranvía")
		return
	if stops.has(c):
		toast("Ya hay una parada")
		return
	if not creative and money < 60:
		toast("No alcanza la plata")
		return
	stops[c] = kind
	if not creative:
		money -= 60
	sim_dirty = true
	sfx("build")
	toast("Parada puesta. Para armar la línea tocá Transporte > Nueva línea.")
func stop_kind_at(c: int) -> String:
	if stops.has(c):
		return stops[c]
	if bld[c] > 0:
		var d: Dictionary = DEF[bld[c]]
		return d.get("stop", "")
	return ""
func pick_line_stop(c: int) -> void:
	if c < 0:
		return
	var kind: String = line_edit.get("kind", "bus")
	var found := -1
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			var x := cx(c) + dx
			var z := cz(c) + dz
			if not inb(x, z):
				continue
			var j := idx(x, z)
			if stop_kind_at(j) == kind:
				found = anchor_of(j)
				break
		if found >= 0:
			break
	if found < 0:
		toast("Tocá una parada de " + LINE_NAMES[kind])
		return
	line_edit["stops"].append(found)
	toast("Paradas en la línea: %d" % line_edit["stops"].size())
	sfx("click")
func ask_buy_region(c: int) -> void:
	if c < 0:
		return
	var r := region_of(c)
	if owned[r] == 1:
		toast("Esta zona ya es tuya")
		return
	var rx := r % NREG
	var rz := r / NREG
	var adj := false
	for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var xx: int = rx + o.x
		var zz: int = rz + o.y
		if xx >= 0 and zz >= 0 and xx < NREG and zz < NREG and owned[zz * NREG + xx] == 1:
			adj = true
	if not adj:
		toast("Solo podés comprar zonas pegadas a las tuyas")
		return
	var cost := region_price()
	confirm("¿Comprar %s por %s?" % [DISTRICT_NAMES[r], fmt_money(cost)], func():
		if money < cost and not creative:
			toast("No alcanza la plata")
			return
		if not creative:
			money -= cost
		owned[r] = 1
		terrain_dirty = true
		mark_all_dirty()
		sfx("cheer")
		toast("¡Compraste " + DISTRICT_NAMES[r] + "!")
		var all := true
		for k in NREG * NREG:
			if owned[k] == 0:
				all = false
		if all:
			unlock_ach("regions"))
func region_price() -> float:
	var n := 0
	for k in NREG * NREG:
		n += owned[k]
	return 4000.0 * pow(float(n - 3), 1.25)
func finish_line() -> void:
	var kind: String = line_edit.get("kind", "bus")
	var st: Array = line_edit.get("stops", [])
	if st.size() < 2:
		toast("La línea necesita al menos 2 paradas")
		return
	var cost: int = LINE_COST[kind]
	if not creative and money < cost:
		toast("No alcanza la plata")
		return
	if not creative:
		money -= cost
	var num := 1
	for ln in lines:
		num = maxi(num, ln["num"] + 1)
	var ln := {"kind": kind, "stops": st.duplicate(), "pts": [], "t": 0.0, "num": num, "col": Color.from_hsv(fmod(num * 0.17, 1.0), 0.75, 0.9)}
	lines.append(ln)
	route_line(ln)
	line_edit = {}
	set_tool({"k": "look"})
	count_add("line")
	sim_dirty = true
	sfx("cheer")
	toast("¡Línea %d de %s en marcha!" % [num, LINE_NAMES[kind]])
	add_news("Se inauguró la línea %d de %s" % [num, LINE_NAMES[kind]])
	if lines.size() >= 3:
		unlock_ach("lines3")
func set_speed(s: int) -> void:
	speed = s
	refresh_speed_buttons()
func vibrate() -> void:
	if opts["vibrate"]:
		Input.vibrate_handheld(18)
func road_next_to(i: int, tram: bool) -> int:
	if road[i] > 0 and (not tram or wire[i] & W_TRAM):
		return i
	for r in range(1, 3):
		for dz in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var x := cx(i) + dx
				var z := cz(i) + dz
				if inb(x, z):
					var j := idx(x, z)
					if road[j] > 0 and (not tram or wire[j] & W_TRAM):
						return j
	return -1
func road_path(from: int, to: int, tram: bool) -> Array:
	var a := road_next_to(from, tram)
	var b := road_next_to(to, tram)
	if a < 0 or b < 0:
		return []
	if a == b:
		return [a]
	var prev := {a: a}
	var q: Array = [a]
	var head := 0
	while head < q.size() and head < 20000:
		var c: int = q[head]
		head += 1
		if c == b:
			break
		for o in [1, -1, N, -N]:
			var j: int = c + o
			if j < 0 or j >= N * N or prev.has(j) or road[j] == 0:
				continue
			if (o == 1 or o == -1) and cz(j) != cz(c):
				continue
			if tram and not (wire[j] & W_TRAM):
				continue
			prev[j] = c
			q.append(j)
	if not prev.has(b):
		return []
	var path: Array = [b]
	var c2: int = b
	while c2 != a:
		c2 = prev[c2]
		path.push_front(c2)
	return path
func route_line(ln: Dictionary) -> void:
	var pts: Array = []
	var stop_k: Array = []
	var st: Array = ln["stops"]
	var kind: String = ln["kind"]
	var n := st.size()
	if n < 2:
		ln["pts"] = []
		return
	for s in n:
		var a: int = st[s]
		var b: int = st[(s + 1) % n]
		stop_k.append(pts.size())
		if kind == "bus" or kind == "tram":
			var path := road_path(a, b, kind == "tram")
			if path.is_empty():
				ln["pts"] = []
				ln["broken"] = true
				return
			for c in path:
				var pp := cell_pos(c)
				if terr[c] == T_WATER:
					pp.y = 0.6
				pts.append(pp)
		else:
			var pa := def_center(a)
			var pb := def_center(b)
			var y := -4.0
			if kind == "train":
				y = 7.0
			elif kind == "ferry":
				y = WATER_Y
			pa.y = y
			pb.y = y
			var steps := maxi(2, int(pa.distance_to(pb) / CELL))
			for k in steps:
				pts.append(pa.lerp(pb, float(k) / steps))
	ln["pts"] = pts
	ln["stopk"] = stop_k
	ln["broken"] = false
	ln["dwell"] = 0.0
	rebuild_rails()
func reroute_all() -> void:
	for ln in lines:
		route_line(ln)
var cine_told: bool = false
# ================================================================ src/render.gd
# Cómo se dibuja la ciudad: mallas, chunks, terreno, agua, luz y clima.
const CH := 32
const M_CORNER := 5
const M_GRASS := 6
const M_GABLE := 7
const M_HIP := 8
const MESH_CENTERED := [true, true, true, true, true, false, true, false, false]
var city_mat: ShaderMaterial
var water_mat: ShaderMaterial
var overlay_mat: ShaderMaterial
var terrain_mat: ShaderMaterial
var terrain_simple_mat: ShaderMaterial
var terrain_tex_loaded: bool = false
var terrain_hsub := PackedFloat32Array()
var dtex: ImageTexture
var ctex: ImageTexture
var terrain_node: MeshInstance3D
var water_node: MeshInstance3D
var chunk_nodes: Array = []
var overlay_node: MultiMeshInstance3D
var moon: DirectionalLight3D
var env: Environment
var sky_mat: ShaderMaterial
var cloud_drift := Vector2.ZERO
const SHADER_CITY := preload("res://shaders/city.gdshader")
const SHADER_WATER := preload("res://shaders/water.gdshader")
const SHADER_TERRAIN := preload("res://shaders/terrain_simple.gdshader")
const SHADER_TERRAIN_TEX := preload("res://shaders/terrain.gdshader")
const SHADER_SKY := preload("res://shaders/sky.gdshader")
const SHADER_GLOW := preload("res://shaders/glow.gdshader")
const SHADER_OVERLAY := preload("res://shaders/overlay.gdshader")
func setup_render() -> void:
	meshes.clear()
	var box := BoxMesh.new()
	meshes.append(box)
	var roof := PrismMesh.new()
	meshes.append(roof)
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.5
	cyl.bottom_radius = 0.5
	cyl.height = 1.0
	cyl.radial_segments = 12
	cyl.rings = 1
	meshes.append(cyl)
	var sph := SphereMesh.new()
	sph.radius = 0.5
	sph.height = 1.0
	sph.radial_segments = 10
	sph.rings = 6
	meshes.append(sph)
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.5
	cone.height = 1.0
	cone.radial_segments = 8
	cone.rings = 1
	meshes.append(cone)
	meshes.append(make_corner_mesh())
	var gcone := CylinderMesh.new()
	gcone.top_radius = 0.0
	gcone.bottom_radius = 0.5
	gcone.height = 1.0
	gcone.radial_segments = 5
	gcone.rings = 1
	meshes.append(gcone)
	meshes.append(make_gable_mesh())
	meshes.append(make_hip_mesh())
	city_mat = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = SHADER_CITY.code
	city_mat.shader = sh
	for m in meshes:
		m.surface_set_material(0, city_mat)
	water_mat = ShaderMaterial.new()
	var sw := Shader.new()
	sw.code = SHADER_WATER.code
	water_mat.shader = sw
	water_mat.set_shader_parameter("nrm_tex", load("res://assets/water/water_nrm.webp"))
	water_mat.set_shader_parameter("foam_tex", load("res://assets/water/foam.webp"))
	overlay_mat = ShaderMaterial.new()
	var so := Shader.new()
	so.code = SHADER_OVERLAY.code
	overlay_mat.shader = so
	dtex = make_noise_tex(0.045, 11, 4)
	ctex = make_noise_tex(0.02, 29, 5)
	terrain_simple_mat = ShaderMaterial.new()
	var st2 := Shader.new()
	st2.code = SHADER_TERRAIN.code
	terrain_simple_mat.shader = st2
	terrain_mat = ShaderMaterial.new()
	terrain_mat.shader = SHADER_TERRAIN_TEX
	for m in [city_mat, terrain_mat, terrain_simple_mat]:
		m.set_shader_parameter("dtex", dtex)
		m.set_shader_parameter("ctex", ctex)
	env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky_mat = ShaderMaterial.new()
	sky_mat.shader = SHADER_SKY
	sky_mat.set_shader_parameter("cloud_tex", ctex)
	sky.sky_material = sky_mat
	sky.process_mode = Sky.PROCESS_MODE_INCREMENTAL
	sky.radiance_size = Sky.RADIANCE_SIZE_128
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.0
	env.ambient_light_sky_contribution = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = 1.0
	env.glow_hdr_threshold = 1.3
	env.fog_enabled = true
	env.fog_light_color = Color(0.7, 0.78, 0.9)
	env.fog_density = 0.0007
	env.fog_sky_affect = 0.3
	env.fog_aerial_perspective = 0.45
	env.fog_height = 8.0
	env.fog_height_density = 0.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.shadow_enabled = true
	sun.shadow_blur = 1.6
	sun.light_specular = 0.35
	sun.directional_shadow_max_distance = 170.0
	add_child(sun)
	moon = DirectionalLight3D.new()
	moon.light_color = Color(0.55, 0.65, 1.0)
	moon.light_energy = 0.0
	moon.rotation_degrees = Vector3(-60, 140, 0)
	add_child(moon)
	terrain_node = MeshInstance3D.new()
	terrain_node.material_override = terrain_mat
	add_child(terrain_node)
	water_node = MeshInstance3D.new()
	var wp := PlaneMesh.new()
	wp.size = Vector2(N * CELL * 10.0, N * CELL * 10.0)
	wp.subdivide_width = 90
	wp.subdivide_depth = 90
	water_node.mesh = wp
	water_node.material_override = water_mat
	water_node.position = Vector3(0, WATER_Y, 0)
	add_child(water_node)
	overlay_node = new_mm_node(meshes[M_BOX], overlay_mat)
	preview_node = new_mm_node(meshes[M_BOX], overlay_mat)
	chunk_nodes.clear()
	chunk_dirty.resize(NCH * NCH)
	chunk_dirty.fill(1)
	for c in NCH * NCH:
		var arr: Array = []
		for m in NMESH:
			var node := new_mm_node(meshes[m], null)
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if m != M_GRASS else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			arr.append(node)
		chunk_nodes.append(arr)
	apply_quality()
func new_mm_node(mesh: Mesh, mat: Material) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = 0
	var node := MultiMeshInstance3D.new()
	node.multimesh = mm
	if mat != null:
		node.material_override = mat
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return node
func make_corner_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 8
	for k in seg:
		var a0 := k * PI * 0.5 / seg
		var a1 := (k + 1) * PI * 0.5 / seg
		var p0 := Vector3(cos(a0), 1, sin(a0))
		var p1 := Vector3(cos(a1), 1, sin(a1))
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(0, 1, 0))
		st.add_vertex(p0)
		st.add_vertex(p1)
		var n := Vector3(cos((a0 + a1) * 0.5), 0, sin((a0 + a1) * 0.5))
		st.set_normal(n)
		st.add_vertex(Vector3(p0.x, 0, p0.z))
		st.add_vertex(p1)
		st.add_vertex(p0)
		st.add_vertex(Vector3(p0.x, 0, p0.z))
		st.add_vertex(Vector3(p1.x, 0, p1.z))
		st.add_vertex(p1)
	return st.commit()
func make_noise_tex(freq: float, sd: int, oct: int) -> ImageTexture:
	var fn := FastNoiseLite.new()
	fn.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	fn.fractal_type = FastNoiseLite.FRACTAL_FBM
	fn.fractal_octaves = oct
	fn.frequency = freq
	fn.seed = sd
	var im := fn.get_seamless_image(256, 256)
	im.generate_mipmaps()
	return ImageTexture.create_from_image(im)
var water_simple_mat: StandardMaterial3D
func apply_quality() -> void:
	var q: int = opts["quality"]
	RenderingServer.directional_shadow_atlas_set_size(2048 if q < 2 else 4096, true)
	if sun:
		sun.shadow_enabled = q >= 1 and opts["g_shadow"]
	if env:
		env.fog_enabled = opts["g_fog"]
	if water_node:
		# calidad Baja: agua simple; Media: una capa de olas y sin anillos de lluvia; Alta: todo
		if opts["g_water"] and q >= 1:
			water_mat.set_shader_parameter("layers", 2.0 if q >= 2 else 1.0)
			water_node.material_override = water_mat
		else:
			if water_simple_mat == null:
				water_simple_mat = StandardMaterial3D.new()
				water_simple_mat.albedo_color = Color(0.12, 0.38, 0.52)
				water_simple_mat.roughness = 0.2
			water_node.material_override = water_simple_mat
	for nd in dyn_nodes:
		nd.visible = opts["g_dyn"]
	if sun:
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL if q < 2 else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	if env:
		env.glow_enabled = q >= 2
		env.glow_intensity = 0.6
		env.glow_bloom = 0.05
	var vp := get_viewport()
	if vp:
		vp.scaling_3d_scale = [0.8, 1.0, 1.0][q]
		vp.msaa_3d = Viewport.MSAA_2X if q >= 2 else Viewport.MSAA_DISABLED
	apply_fx()
var wfx: GPUParticles3D
var wfx_kind: String = ""
var wfx_r: float = 0.0
var vig_layer: CanvasLayer
var cloud_cover: float = -1.0
func apply_fx() -> void:
	if city_mat == null:
		return
	city_mat.set_shader_parameter("wind", 1.0 if opts["g_wind"] else 0.0)
	city_mat.set_shader_parameter("ao_on", 1.0 if opts["g_ao"] else 0.0)
	var dt: float = 1.0 if opts["g_detail"] else 0.0
	city_mat.set_shader_parameter("det", dt)
	terrain_simple_mat.set_shader_parameter("det", dt)
	terrain_dirty = true
	# calidad Baja: cielo nuevo pero sin nubes
	sky_mat.set_shader_parameter("clouds_on", 1.0 if (opts["g_clouds"] and int(opts["quality"]) >= 1) else 0.0)
	cloud_cover = -1.0
	env.adjustment_enabled = opts["g_grade"]
	env.adjustment_saturation = 1.12
	env.adjustment_contrast = 1.12
	if vig_layer == null:
		vig_layer = CanvasLayer.new()
		vig_layer.layer = 2
		var gt := GradientTexture2D.new()
		var gr := Gradient.new()
		gr.offsets = PackedFloat32Array([0.5, 0.7, 0.85, 1.0])
		gr.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0.03, 0.02, 0.05, 0.02), Color(0.03, 0.02, 0.05, 0.08), Color(0.03, 0.02, 0.05, 0.2)])
		gt.gradient = gr
		gt.fill = GradientTexture2D.FILL_RADIAL
		gt.fill_from = Vector2(0.5, 0.5)
		gt.fill_to = Vector2(1.0, 0.5)
		gt.width = 128
		gt.height = 128
		var tr := TextureRect.new()
		tr.texture = gt
		tr.set_anchors_preset(Control.PRESET_FULL_RECT)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vig_layer.add_child(tr)
		add_child(vig_layer)
	vig_layer.visible = opts["g_grade"]
func make_wfx() -> void:
	wfx = GPUParticles3D.new()
	wfx.visibility_aabb = AABB(Vector3(-140, -50, -140), Vector3(280, 80, 280))
	wfx.local_coords = false
	wfx.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(wfx)
func config_wfx(kind: String) -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(60, 1, 60)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if kind == "rain":
		pm.direction = Vector3(0.12, -1.0, 0.05)
		pm.spread = 1.5
		pm.initial_velocity_min = 34.0
		pm.initial_velocity_max = 40.0
		pm.gravity = Vector3.ZERO
		var bm := BoxMesh.new()
		bm.size = Vector3(0.025, 1.2, 0.025)
		mat.albedo_color = Color(0.82, 0.88, 1.0, 0.4)
		bm.material = mat
		wfx.draw_pass_1 = bm
		wfx.amount = 1800
		wfx.lifetime = 1.0
	else:
		pm.direction = Vector3(0.1, -1.0, 0.0)
		pm.spread = 28.0
		pm.initial_velocity_min = 2.5
		pm.initial_velocity_max = 4.5
		pm.gravity = Vector3.ZERO
		pm.scale_min = 0.6
		pm.scale_max = 1.4
		var sm := SphereMesh.new()
		sm.radius = 0.09
		sm.height = 0.18
		sm.radial_segments = 6
		sm.rings = 3
		mat.albedo_color = Color(1, 1, 1, 0.9)
		sm.material = mat
		wfx.draw_pass_1 = sm
		wfx.amount = 1500
		wfx.lifetime = 9.0
	wfx.process_material = pm
	wfx.preprocess = wfx.lifetime
	wfx_r = 0.0
func update_fx() -> void:
	if opts["g_clouds"] and int(opts["quality"]) >= 1:
		cloud_drift += wind * get_process_delta_time() * 0.0035
		sky_mat.set_shader_parameter("cloud_off", cloud_drift)
		var cv := 0.45
		if weather == "Nublado":
			cv = 0.85
		elif weather == "Lluvia" or weather == "Tormenta" or weather == "Nieve":
			cv = 0.95
		if cv != cloud_cover:
			cloud_cover = cv
			sky_mat.set_shader_parameter("cover", cv)
			sky_mat.set_shader_parameter("storm", 1.0 if weather in ["Lluvia", "Tormenta", "Nieve"] else 0.0)
			city_mat.set_shader_parameter("cshadow", cv)
			terrain_mat.set_shader_parameter("cshadow", cv)
			terrain_simple_mat.set_shader_parameter("cshadow", cv)
	elif cloud_cover != 0.0:
		cloud_cover = 0.0
		city_mat.set_shader_parameter("cshadow", 0.0)
		terrain_mat.set_shader_parameter("cshadow", 0.0)
		terrain_simple_mat.set_shader_parameter("cshadow", 0.0)
	var want := ""
	if opts["g_rain"] and opts["quality"] >= 1 and started:
		if weather == "Lluvia" or weather == "Tormenta":
			want = "rain"
		elif weather == "Nieve":
			want = "snow"
	if want != wfx_kind:
		wfx_kind = want
		if want != "":
			if wfx == null:
				make_wfx()
			config_wfx(want)
		if wfx:
			wfx.emitting = want != ""
	if wfx and wfx.emitting:
		wfx.global_position = Vector3(cam_target.x, 32.0, cam_target.z)
		var r := clampf(cam_dist * 0.9, 30.0, 110.0)
		if absf(r - wfx_r) > 5.0:
			wfx_r = r
			(wfx.process_material as ParticleProcessMaterial).emission_box_extents = Vector3(r, 1, r)
func use_tex_terrain() -> bool:
	return int(opts["quality"]) >= 1 and bool(opts["g_detail"])
func build_terrain() -> void:
	terrain_dirty = false
	if use_tex_terrain():
		build_terrain_tex()
		return
	terrain_node.material_override = terrain_simple_mat
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var s := season()
	var grass: Color = [Color(0.42, 0.62, 0.28), Color(0.58, 0.55, 0.28), Color(0.62, 0.66, 0.6), Color(0.45, 0.68, 0.32)][s]
	if weather == "Nieve":
		grass = Color(0.9, 0.92, 0.95)
	var half := N * CELL * 0.5
	var vh := PackedFloat32Array()
	vh.resize((N + 1) * (N + 1))
	var vc := PackedColorArray()
	vc.resize((N + 1) * (N + 1))
	for z in N + 1:
		for x in N + 1:
			var hs := 0.0
			var cnt := 0
			var col := Color(0, 0, 0)
			for o in [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]:
				var xx: int = x + o.x
				var zz: int = z + o.y
				if inb(xx, zz):
					var i := idx(xx, zz)
					hs += hgt[i]
					cnt += 1
					col += terrain_color(i, grass)
			vh[z * (N + 1) + x] = hs / maxf(cnt, 1)
			vc[z * (N + 1) + x] = col / maxf(cnt, 1)
	for z in N:
		for x in N:
			var a := z * (N + 1) + x
			var b := a + 1
			var c := a + N + 1
			var d := c + 1
			var pa := Vector3(x * CELL - half, vh[a], z * CELL - half)
			var pb := Vector3((x + 1) * CELL - half, vh[b], z * CELL - half)
			var pc := Vector3(x * CELL - half, vh[c], (z + 1) * CELL - half)
			var pd := Vector3((x + 1) * CELL - half, vh[d], (z + 1) * CELL - half)
			st.set_color(vc[a]); st.add_vertex(pa)
			st.set_color(vc[b]); st.add_vertex(pb)
			st.set_color(vc[d]); st.add_vertex(pd)
			st.set_color(vc[a]); st.add_vertex(pa)
			st.set_color(vc[d]); st.add_vertex(pd)
			st.set_color(vc[c]); st.add_vertex(pc)
	var himg := Image.create(N + 1, N + 1, false, Image.FORMAT_RH)
	for z in N + 1:
		for x in N + 1:
			himg.set_pixel(x, z, Color(vh[z * (N + 1) + x], 0.0, 0.0))
	set_hmap(himg)
	st.generate_normals()
	terrain_node.mesh = st.commit()
	build_outer(grass)
func set_hmap(himg: Image) -> void:
	var half := N * CELL * 0.5
	var htex := ImageTexture.create_from_image(himg)
	var hi := Vector4(N * CELL, half, float(N) / float(N + 1), 0.5 / float(N + 1))
	for m in [city_mat, water_mat, terrain_mat]:
		m.set_shader_parameter("hmap", htex)
		m.set_shader_parameter("hinfo", hi)
func load_terrain_tex() -> void:
	if terrain_tex_loaded:
		return
	terrain_tex_loaded = true
	for mat in ["grass", "dry", "dirt", "rock", "sand", "snow"]:
		terrain_mat.set_shader_parameter("alb_" + mat, load("res://assets/terrain/%s_alb.webp" % mat))
	for mat in ["grass", "dirt", "rock", "sand"]:
		terrain_mat.set_shader_parameter("nrm_" + mat, load("res://assets/terrain/%s_nrm.webp" % mat))
# celda "ocupada": su suelo no se suaviza (calles, zonas, edificios, diques y árboles se quedan como hoy)
func terrain_busy(x: int, z: int) -> bool:
	if not inb(x, z):
		return false
	var i := idx(x, z)
	return road[i] > 0 or zone[i] > 0 or bld[i] > 0 or tree[i] > 0 or (wire[i] & W_LEVEE) != 0
# Catmull-Rom en el punto medio
func cr_mid(p0: float, p1: float, p2: float, p3: float) -> float:
	return (-p0 + 9.0 * p1 + 9.0 * p2 - p3) / 16.0
# pesos del splat de una celda: pasto, arena, roca, tierra
func cell_splat(i: int) -> Color:
	match terr[i]:
		T_SAND:
			return Color(0, 1, 0, 0)
		T_ROCK:
			return Color(0, 0, 1, 0)
		T_WATER:
			return Color(0, 0.35, 0, 0.65)
	var x := cx(i)
	var z := cz(i)
	var sl := 0.0
	for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if inb(x + o.x, z + o.y):
			sl = maxf(sl, absf(hgt[idx(x + o.x, z + o.y)] - hgt[i]))
	var rock := clampf((sl - 0.6) / 0.8, 0.0, 1.0)
	var dirt := 0.6 if (wdist[i] <= 1.0 and hgt[i] < 0.5) else 0.0
	var g := maxf(0.0, 1.0 - rock - dirt)
	return Color(g, 0, rock, dirt)
# Terreno con texturas (Media y Alta): malla de 2×2 por celda. Las esquinas de celda quedan a la
# altura de hoy; los puntos nuevos se suavizan, salvo junto a celdas ocupadas, donde caen sobre los
# mismos triángulos de antes (diagonal a-d), así nada queda flotando ni enterrado.
func build_terrain_tex() -> void:
	load_terrain_tex()
	terrain_node.material_override = terrain_mat
	var s := season()
	var half := N * CELL * 0.5
	var N1 := N + 1
	# datos por celda, una sola vez
	var csp := PackedColorArray()
	csp.resize(N * N)
	var cown := PackedFloat32Array()
	cown.resize(N * N)
	var busy := PackedByteArray()
	busy.resize(N * N)
	for i in N * N:
		csp[i] = cell_splat(i)
		cown[i] = 1.0 if is_owned(i) else 0.0
		busy[i] = 1 if (road[i] > 0 or zone[i] > 0 or bld[i] > 0 or tree[i] > 0 or (wire[i] & W_LEVEE) != 0) else 0
	var vh := PackedFloat32Array()
	vh.resize(N1 * N1)
	var own := PackedFloat32Array()
	own.resize(N1 * N1)
	var sp := PackedByteArray()
	sp.resize(N1 * N1 * 4)
	for z in N1:
		for x in N1:
			var hs := 0.0
			var cnt := 0
			var ow := 0.0
			var c := Color(0, 0, 0, 0)
			for zz in range(z - 1, z + 1):
				if zz < 0 or zz >= N:
					continue
				for xx in range(x - 1, x + 1):
					if xx < 0 or xx >= N:
						continue
					var i := zz * N + xx
					hs += hgt[i]
					cnt += 1
					ow += cown[i]
					c += csp[i]
			var k := z * N1 + x
			var fc := 1.0 / maxf(cnt, 1)
			vh[k] = hs * fc
			own[k] = ow * fc
			sp[k * 4] = int(c.r * fc * 255.0)
			sp[k * 4 + 1] = int(c.g * fc * 255.0)
			sp[k * 4 + 2] = int(c.b * fc * 255.0)
			sp[k * 4 + 3] = int(c.a * fc * 255.0)
	set_hmap(Image.create_from_data(N1, N1, false, Image.FORMAT_RF, vh.to_byte_array()))
	terrain_mat.set_shader_parameter("splat", ImageTexture.create_from_image(Image.create_from_data(N1, N1, false, Image.FORMAT_RGBA8, sp)))
	terrain_mat.set_shader_parameter("season_dry", [0.08, 0.85, 0.55, 0.0][s] + (0.2 if weather == "Calor" else 0.0))
	# malla fina: (2N+1)² vértices
	var M := 2 * N + 1
	var hsub := PackedFloat32Array()
	hsub.resize(M * M)
	for v in M:
		for u in M:
			var h := 0.0
			var x0 := u >> 1
			var z0 := v >> 1
			if (u & 1) == 0 and (v & 1) == 0:
				h = vh[z0 * N1 + x0]
			elif (u & 1) == 1 and (v & 1) == 0:
				# borde horizontal entre esquinas x0 y x0+1; lo tocan las celdas (x0, z0-1) y (x0, z0)
				if (z0 > 0 and x0 < N and busy[(z0 - 1) * N + x0] == 1) or (z0 < N and x0 < N and busy[z0 * N + x0] == 1):
					h = (vh[z0 * N1 + x0] + vh[z0 * N1 + x0 + 1]) * 0.5
				else:
					h = cr_mid(vh[z0 * N1 + maxi(x0 - 1, 0)], vh[z0 * N1 + x0], vh[z0 * N1 + x0 + 1], vh[z0 * N1 + mini(x0 + 2, N)])
			elif (u & 1) == 0 and (v & 1) == 1:
				if (x0 > 0 and z0 < N and busy[z0 * N + x0 - 1] == 1) or (x0 < N and z0 < N and busy[z0 * N + x0] == 1):
					h = (vh[z0 * N1 + x0] + vh[(z0 + 1) * N1 + x0]) * 0.5
				else:
					h = cr_mid(vh[maxi(z0 - 1, 0) * N1 + x0], vh[z0 * N1 + x0], vh[(z0 + 1) * N1 + x0], vh[mini(z0 + 2, N) * N1 + x0])
			else:
				# centro de la celda (x0, z0)
				if busy[z0 * N + x0] == 1:
					h = (vh[z0 * N1 + x0] + vh[(z0 + 1) * N1 + x0 + 1]) * 0.5
				else:
					var xa := maxi(x0 - 1, 0)
					var xd := mini(x0 + 2, N)
					var r0 := maxi(z0 - 1, 0) * N1
					var r1 := z0 * N1
					var r2 := (z0 + 1) * N1
					var r3 := mini(z0 + 2, N) * N1
					h = cr_mid(cr_mid(vh[r0 + xa], vh[r0 + x0], vh[r0 + x0 + 1], vh[r0 + xd]),
						cr_mid(vh[r1 + xa], vh[r1 + x0], vh[r1 + x0 + 1], vh[r1 + xd]),
						cr_mid(vh[r2 + xa], vh[r2 + x0], vh[r2 + x0 + 1], vh[r2 + xd]),
						cr_mid(vh[r3 + xa], vh[r3 + x0], vh[r3 + x0 + 1], vh[r3 + xd]))
			hsub[v * M + u] = h
	terrain_hsub = hsub
	var verts := PackedVector3Array()
	verts.resize(M * M)
	var nrms := PackedVector3Array()
	nrms.resize(M * M)
	var cols := PackedColorArray()
	cols.resize(M * M)
	var step := CELL * 0.5
	for v in M:
		for u in M:
			var k := v * M + u
			verts[k] = Vector3(u * step - half, hsub[k], v * step - half)
			var hl := hsub[v * M + maxi(u - 1, 0)]
			var hr := hsub[v * M + mini(u + 1, M - 1)]
			var hd := hsub[maxi(v - 1, 0) * M + u]
			var hu := hsub[mini(v + 1, M - 1) * M + u]
			nrms[k] = Vector3(hl - hr, 2.0 * step, hd - hu).normalized()
			var ow := own[(v >> 1) * N1 + (u >> 1)]
			if (u & 1) == 1 or (v & 1) == 1:
				ow = (ow + own[mini((v + 1) >> 1, N) * N1 + mini((u + 1) >> 1, N)]) * 0.5
			cols[k] = Color(1, 1, 1, ow)
	var ids := PackedInt32Array()
	ids.resize((M - 1) * (M - 1) * 6)
	var n := 0
	for v in M - 1:
		for u in M - 1:
			var a := v * M + u
			# misma diagonal que el terreno de hoy (a-d)
			ids[n] = a
			ids[n + 1] = a + 1
			ids[n + 2] = a + M + 1
			ids[n + 3] = a
			ids[n + 4] = a + M + 1
			ids[n + 5] = a + M
			n += 6
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = nrms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_INDEX] = ids
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	terrain_node.mesh = am
	var grass: Color = [Color(0.42, 0.62, 0.28), Color(0.58, 0.55, 0.28), Color(0.62, 0.66, 0.6), Color(0.45, 0.68, 0.32)][s]
	build_outer(grass)
func terrain_color(i: int, grass: Color) -> Color:
	var c: Color
	match terr[i]:
		T_WATER:
			c = Color(0.55, 0.5, 0.38)
		T_SAND:
			c = Color(0.86, 0.78, 0.55)
		T_ROCK:
			c = Color(0.5, 0.48, 0.44)
		_:
			var v := float((cx(i) * 13 + cz(i) * 7) % 5) * 0.012
			c = grass + Color(v, v, -v)
	if not is_owned(i):
		c = c.darkened(0.28)
	return c
var outer_nodes: Array = []
var far_mat: ShaderMaterial
# Horizonte: un anillo de terreno alrededor del mapa (hasta 5 veces su tamaño) con lomas suaves que se
# pierden en la bruma. Junto al borde copia la altura del mapa (sin escalón); donde el borde es agua,
# baja bajo el nivel del agua para que el agua siga hasta el horizonte.
func build_outer(grass: Color) -> void:
	for n in outer_nodes:
		n.queue_free()
	outer_nodes.clear()
	var size := N * CELL
	var half := size * 0.5
	var stp := size / 16.0
	var R := 80
	var G := 2 * R + 1
	var nz := FastNoiseLite.new()
	nz.seed = map_seed + 991
	nz.frequency = 0.0016
	nz.fractal_octaves = 4
	# alturas reales del borde del terreno ya armado (para empalmar sin rendijas)
	var edge := {}
	if terrain_node.mesh != null:
		var tv: PackedVector3Array = terrain_node.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		for v in tv:
			if absf(absf(v.x) - half) < 0.01 or absf(absf(v.z) - half) < 0.01:
				edge[Vector2i(roundi(v.x * 10.0), roundi(v.z * 10.0))] = v.y
	var hv := PackedFloat32Array()
	hv.resize(G * G)
	for j in G:
		for i in G:
			var wx := (i - R) * stp
			var wz := (j - R) * stp
			# distancia al cuadrado del mapa (0 adentro y en el borde)
			var dxo := maxf(absf(wx) - half, 0.0)
			var dzo := maxf(absf(wz) - half, 0.0)
			var dist := sqrt(dxo * dxo + dzo * dzo)
			var bx := clampi(int((clampf(wx, -half, half - 0.01) + half) / CELL), 0, N - 1)
			var bz := clampi(int((clampf(wz, -half, half - 0.01) + half) / CELL), 0, N - 1)
			var bi := idx(bx, bz)
			var base: float = WATER_Y - 2.5 if terr[bi] == T_WATER else hgt[bi]
			var t := smoothstep(0.0, size * 1.2, dist)
			var hills := (nz.get_noise_2d(wx, wz) * 0.5 + 0.5) * 70.0 * smoothstep(0.0, size * 0.6, dist)
			if terr[bi] == T_WATER:
				hills *= 0.15
			hv[j * G + i] = lerpf(base, base + hills, t) if terr[bi] != T_WATER else base - 1.0 * t
			var ek := Vector2i(roundi(wx * 10.0), roundi(wz * 10.0))
			if edge.has(ek):
				hv[j * G + i] = edge[ek]
	var verts := PackedVector3Array()
	var nrms := PackedVector3Array()
	var cols := PackedColorArray()
	verts.resize(G * G)
	nrms.resize(G * G)
	cols.resize(G * G)
	for j in G:
		for i in G:
			var k := j * G + i
			verts[k] = Vector3((i - R) * stp, hv[k], (j - R) * stp)
			var hl := hv[j * G + maxi(i - 1, 0)]
			var hr := hv[j * G + mini(i + 1, G - 1)]
			var hd := hv[maxi(j - 1, 0) * G + i]
			var hu := hv[mini(j + 1, G - 1) * G + i]
			nrms[k] = Vector3(hl - hr, 2.0 * stp, hd - hu).normalized()
			cols[k] = Color(1, 1, 1, 0)  # el campo lejano se ve como zona no comprada
	var ids := PackedInt32Array()
	for j in G - 1:
		for i in G - 1:
			# se saltean los cuadros que están adentro del mapa
			var cxw := (i - R + 0.5) * stp
			var czw := (j - R + 0.5) * stp
			if absf(cxw) < half and absf(czw) < half:
				continue
			if (absf(cxw) < half and absf(czw) < half + stp) or (absf(czw) < half and absf(cxw) < half + stp):
				continue
			var a := j * G + i
			ids.append_array(PackedInt32Array([a, a + 1, a + G + 1, a, a + G + 1, a + G]))
	# altura del anillo sobre la línea a un paso del mapa (lineal entre sus vértices, igual que sus triángulos)
	var ring_h := func(x: float, z: float) -> float:
		var fi := x / stp + R
		var fj := z / stp + R
		var i0 := clampi(int(floor(fi)), 0, G - 2)
		var j0 := clampi(int(floor(fj)), 0, G - 2)
		var u := clampf(fi - i0, 0.0, 1.0)
		var w := clampf(fj - j0, 0.0, 1.0)
		if absf(u) < 0.0001 or absf(u - 1.0) < 0.0001:
			var ii := i0 + roundi(u)
			return lerpf(hv[j0 * G + ii], hv[(j0 + 1) * G + ii], w)
		var jj := j0 + roundi(w)
		return lerpf(hv[jj * G + i0], hv[jj * G + i0 + 1], u)
	for side in 4:
		# puntos del borde de este lado, ordenados
		var pts := []
		for k in edge:
			var x: float = k.x / 10.0
			var z: float = k.y / 10.0
			var on := false
			match side:
				0:
					on = absf(x - half) < 0.01
				1:
					on = absf(x + half) < 0.01
				2:
					on = absf(z - half) < 0.01
				3:
					on = absf(z + half) < 0.01
			if on:
				pts.append(z if side < 2 else x)
		pts.sort()
		for q in range(pts.size() - 1):
			var a0: float = pts[q]
			var a1: float = pts[q + 1]
			# cuatro esquinas con x y z crecientes (mismo orden de triángulos que el anillo)
			var p := []
			for c in [[0, 0], [1, 0], [0, 1], [1, 1]]:
				var along: float = a0 if c[1] == 0 else a1
				var outside: bool = c[0] == 1
				var px: float
				var pz: float
				match side:
					0:
						px = half + (stp if outside else 0.0)
						pz = along
					1:
						px = -half - (stp if not outside else 0.0)
						pz = along
					2:
						px = along
						pz = half + (stp if outside else 0.0)
					3:
						px = along
						pz = -half - (stp if not outside else 0.0)
				var inner: bool = (absf(absf(px) - half) < 0.01 and side < 2) or (absf(absf(pz) - half) < 0.01 and side >= 2)
				var py: float = edge[Vector2i(roundi(px * 10.0), roundi(pz * 10.0))] if inner else ring_h.call(px, pz)
				p.append(Vector3(px, py, pz))
			# ordenar como grilla: [x0z0, x1z0, x0z1, x1z1]
			p.sort_custom(func(A, B): return A.z < B.z - 0.001 or (absf(A.z - B.z) <= 0.001 and A.x < B.x))
			var base := verts.size()
			for v in p:
				verts.append(v)
				nrms.append(Vector3.UP)
				cols.append(Color(1, 1, 1, 0))
			ids.append_array(PackedInt32Array([base, base + 1, base + 3, base, base + 3, base + 2]))
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = nrms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_INDEX] = ids
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var m := MeshInstance3D.new()
	m.mesh = am
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if use_tex_terrain():
		if far_mat == null:
			far_mat = terrain_mat.duplicate()
		far_mat.set_shader_parameter("far", 1.0)
		far_mat.set_shader_parameter("season_dry", terrain_mat.get_shader_parameter("season_dry"))
		far_mat.set_shader_parameter("snow", terrain_mat.get_shader_parameter("snow"))
		m.material_override = far_mat
	else:
		var sm := StandardMaterial3D.new()
		sm.albedo_color = grass.darkened(0.12)
		sm.roughness = 1.0
		m.material_override = sm
	add_child(m)
	outer_nodes.append(m)
func mark_dirty(i: int) -> void:
	var x := cx(i)
	var z := cz(i)
	for o in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var xx: int = clampi(x + o.x * 2, 0, N - 1)
		var zz: int = clampi(z + o.y * 2, 0, N - 1)
		chunk_dirty[(zz / CH) * NCH + xx / CH] = 1
func mark_all_dirty() -> void:
	chunk_dirty.fill(1)
func update_chunks(max_n: int) -> void:
	var done := 0
	for c in NCH * NCH:
		if chunk_dirty[c] == 1:
			chunk_dirty[c] = 0
			build_chunk(c)
			done += 1
			if done >= max_n:
				return
func build_chunk(c: int) -> void:
	begin_buf()
	var x0 := (c % NCH) * CH
	var z0 := (c / NCH) * CH
	for z in range(z0, z0 + CH):
		for x in range(x0, x0 + CH):
			emit_cell(idx(x, z))
	var nodes: Array = chunk_nodes[c]
	for m in NMESH:
		var node: MultiMeshInstance3D = nodes[m]
		var mm := node.multimesh
		mm.instance_count = _counts[m]
		if _counts[m] > 0:
			mm.buffer = _bufs[m].slice(0, _counts[m] * 20)
func begin_buf() -> void:
	_counts.resize(NMESH)
	_counts.fill(0)
	while _bufs.size() < NMESH:
		var pb := PackedFloat32Array()
		pb.resize(2000)
		_bufs.append(pb)
func em(m: int, x: float, y: float, z: float, sx: float, sy: float, sz: float, rot: float, col: Color, c0: float = 0.0, c1: float = 0.0, c2: float = 0.0, c3: float = 0.0) -> void:
	var c := cos(rot)
	var s := sin(rot)
	var oy := y + (sy * 0.5 if MESH_CENTERED[m] else 0.0)
	var o: int = _counts[m] * 20
	var b: PackedFloat32Array = _bufs[m]
	if o + 20 > b.size():
		b.resize(maxi(b.size() * 2, 2000))
		_bufs[m] = b
	b[o] = c * sx
	b[o + 2] = s * sz
	b[o + 3] = x
	b[o + 5] = sy
	b[o + 7] = oy
	b[o + 8] = -s * sx
	b[o + 10] = c * sz
	b[o + 11] = z
	b[o + 12] = col.r
	b[o + 13] = col.g
	b[o + 14] = col.b
	b[o + 15] = col.a
	b[o + 16] = c0
	b[o + 17] = c1
	b[o + 18] = c2
	b[o + 19] = c3
	b[o + 1] = 0.0
	b[o + 4] = 0.0
	b[o + 6] = 0.0
	b[o + 9] = 0.0
	_counts[m] += 1
func emit_cell(i: int) -> void:
	var p := cell_pos(i)
	lamps.erase(i)
	if road[i] > 0:
		emit_road(i, p)
	elif bld[i] > 0:
		if part[i] < 0 or part[i] == i:
			emit_def(i, p)
	elif zone[i] > 0:
		if part[i] >= 0 and part[i] != i:
			pass
		elif anim_cells.has(i):
			emit_lot(i, p)
		else:
			emit_zone(i, p)
	elif tree[i] > 0:
		emit_trees(i, p)
	elif terr[i] == T_LAND and opts["g_grass"] and weather != "Nieve":
		emit_grass(i, p)
	if wire[i] & W_POWER and road[i] == 0 and bld[i] == 0 and zone[i] == 0:
		emit_cable(i, p)
	if wire[i] & W_LEVEE:
		em(M_BOX, p.x, p.y, p.z, CELL, 1.4, CELL, 0.0, Color(0.55, 0.55, 0.52))
	if flood[i] > 0.0:
		em(M_BOX, p.x, p.y, p.z, CELL, 0.25, CELL, 0.0, Color(0.2, 0.4, 0.55), 0, 0, 0.1, 1)
	if garbp[i] > 0.5 and road[i] == 0:
		for k in mini(3, int(garbp[i])):
			em(M_SPH, p.x + (hsh(i, k) - 0.5) * 2.2, p.y, p.z + (hsh(i, k + 5) - 0.5) * 2.2, 0.9, 0.6, 0.9, 0.0, Color(0.35, 0.3, 0.2))
	if burn[i] > 0.99:
		em(M_BOX, p.x, p.y, p.z, CELL * 0.8, 0.4, CELL * 0.8, 0.0, Color(0.12, 0.1, 0.1))
func emit_road(i: int, p: Vector3) -> void:
	var t: int = road[i]
	var col: Color = [Color(), Color(0.55, 0.45, 0.32), Color(0.25, 0.25, 0.27), Color(0.21, 0.21, 0.23), Color(0.19, 0.19, 0.21)][t]
	var nb := road_n(i)
	var e: bool = nb[0]
	var w: bool = nb[1]
	var s: bool = nb[2]
	var n: bool = nb[3]
	var cnt := int(e) + int(w) + int(s) + int(n)
	var y := p.y
	var bridge := terr[i] == T_WATER
	if bridge:
		y = 0.6
		em(M_BOX, p.x, WATER_Y - 1.0, p.z, 0.8, 1.6 + y, 0.8, 0.0, Color(0.5, 0.5, 0.5))
	var sidewalk := Color(0.62, 0.6, 0.56)
	var corner := cnt == 2 and ((e and s) or (e and n) or (w and s) or (w and n)) and not bridge
	if corner:
		var cxo := 1.0 if e else -1.0
		var czo := 1.0 if s else -1.0
		var rot := 0.0
		if cxo > 0 and czo > 0:
			rot = PI
		elif cxo < 0 and czo > 0:
			rot = -PI * 0.5
		elif cxo > 0 and czo < 0:
			rot = PI * 0.5
		em(M_CORNER, p.x + cxo * CELL * 0.5, y, p.z + czo * CELL * 0.5, CELL * 1.02, 0.17, CELL * 1.02, rot, sidewalk)
		em(M_CORNER, p.x + cxo * CELL * 0.5, y, p.z + czo * CELL * 0.5, CELL * 0.86, 0.2, CELL * 0.86, rot, col)
		return
	em(M_BOX, p.x, y, p.z, CELL, 0.2, CELL, 0.0, col)
	var horiz := (e or w) and not (s or n)
	var vert := (s or n) and not (e or w)
	if t >= 2 and not bridge:
		if not n and (horiz or cnt <= 1):
			em(M_BOX, p.x, y, p.z - CELL * 0.44, CELL, 0.26, CELL * 0.12, 0.0, sidewalk)
		if not s and (horiz or cnt <= 1):
			em(M_BOX, p.x, y, p.z + CELL * 0.44, CELL, 0.26, CELL * 0.12, 0.0, sidewalk)
		if not e and (vert or cnt <= 1):
			em(M_BOX, p.x + CELL * 0.44, y, p.z, CELL * 0.12, 0.26, CELL, 0.0, sidewalk)
		if not w and (vert or cnt <= 1):
			em(M_BOX, p.x - CELL * 0.44, y, p.z, CELL * 0.12, 0.26, CELL, 0.0, sidewalk)
	if wire[i] & W_ROUND:
		em(M_CYL, p.x, y, p.z, CELL * 0.45, 0.35, CELL * 0.45, 0.0, Color(0.3, 0.6, 0.3))
		em(M_SPH, p.x, y + 0.3, p.z, 1.0, 1.4, 1.0, 0.0, Color(0.25, 0.5, 0.25))
		return
	var rot := 0.0 if horiz else PI * 0.5
	if horiz or vert:
		match t:
			2:
				if (cx(i) + cz(i)) % 2 == 0:
					em(M_BOX, p.x, y, p.z, CELL * 0.45, 0.22, 0.12, rot, Color(0.9, 0.85, 0.6))
			3:
				em(M_BOX, p.x, y, p.z, CELL, 0.32, 0.5, rot, Color(0.35, 0.55, 0.3))
				if hsh(i, 3) < 0.4:
					em(M_SPH, p.x, y + 0.3, p.z, 0.9, 1.4, 0.9, 0.0, Color(0.28, 0.5, 0.25))
			4:
				em(M_BOX, p.x, y, p.z, CELL, 0.25, 0.25, rot, Color(0.85, 0.75, 0.2))
				em(M_BOX, p.x, y, p.z, CELL, 0.45, 0.15, rot, Color(0.7, 0.7, 0.7))
		if wire[i] & W_BIKE:
			var off := Vector2(0, CELL * 0.33) if horiz else Vector2(CELL * 0.33, 0)
			em(M_BOX, p.x + off.x, y, p.z + off.y, CELL if horiz else 0.6, 0.23, 0.6 if horiz else CELL, 0.0, Color(0.25, 0.6, 0.35))
		if wire[i] & W_TRAM:
			for sgn in [-0.12, 0.12]:
				var o2 := Vector2(0, CELL * sgn) if horiz else Vector2(CELL * sgn, 0)
				em(M_BOX, p.x + o2.x, y, p.z + o2.y, CELL if horiz else 0.1, 0.25, 0.1 if horiz else CELL, 0.0, Color(0.6, 0.6, 0.62))
		if t >= 2 and (cx(i) + cz(i) * 3) % 3 == 0 and not bridge:
			var lo := Vector2(0, -CELL * 0.45) if horiz else Vector2(-CELL * 0.45, 0)
			var ao := Vector2(0, 0.8) if horiz else Vector2(0.8, 0)
			em(M_BOX, p.x + lo.x, y, p.z + lo.y, 0.12, 2.9, 0.12, 0.0, Color(0.3, 0.3, 0.32))
			em(M_BOX, p.x + lo.x + ao.x * 0.5, y + 2.85, p.z + lo.y + ao.y * 0.5, 0.09 if horiz else 0.8, 0.09, 0.8 if horiz else 0.09, 0.0, Color(0.3, 0.3, 0.32))
			em(M_BOX, p.x + lo.x + ao.x, y + 2.78, p.z + lo.y + ao.y, 0.34, 0.1, 0.34, 0.0, Color(1.0, 0.85, 0.55), 0, 1.0)
			lamps[i] = Vector3(p.x + lo.x + ao.x, y, p.z + lo.y + ao.y)
		if t == 2 and opts["quality"] >= 1:
			for side in [-1, 1]:
				var j: int = i + (N * side if horiz else side)
				if j >= 0 and j < N * N and zone[j] > 0 and lvl[j] >= 1 and hsh(i, side + 7) < 0.45:
					var po := Vector2(0, side * CELL * 0.3) if horiz else Vector2(side * CELL * 0.3, 0)
					em(M_BOX, p.x + po.x, y + 0.15, p.z + po.y, 1.6, 0.6, 0.8, rot, car_color(i * 3 + side))
func car_color(k: int) -> Color:
	var pal := [Color(0.85, 0.85, 0.87), Color(0.15, 0.15, 0.17), Color(0.7, 0.12, 0.1), Color(0.2, 0.3, 0.6), Color(0.55, 0.57, 0.6), Color(0.9, 0.75, 0.2), Color(0.25, 0.45, 0.3)]
	return pal[absi(k) % pal.size()]
func emit_cable(i: int, p: Vector3) -> void:
	em(M_BOX, p.x, p.y, p.z, 0.2, 4.0, 0.2, 0.0, Color(0.45, 0.35, 0.25))
	em(M_BOX, p.x, p.y + 3.6, p.z, 1.6, 0.12, 0.12, 0.0, Color(0.45, 0.35, 0.25))
	var x := cx(i)
	var z := cz(i)
	if x < N - 1 and wire[i + 1] & W_POWER:
		em(M_BOX, p.x + CELL * 0.5, p.y + 3.6, p.z, CELL, 0.05, 0.05, 0.0, Color(0.1, 0.1, 0.1))
	if z < N - 1 and wire[i + N] & W_POWER:
		em(M_BOX, p.x, p.y + 3.6, p.z + CELL * 0.5, 0.05, 0.05, CELL, 0.0, Color(0.1, 0.1, 0.1))
func tree_colors(kind: int) -> Array:
	var s := season()
	var snowy := weather == "Nieve"
	match kind:
		1, 2:
			if s == 1:
				return [Color(0.8, 0.5, 0.15) if kind == 2 else Color(0.75, 0.45, 0.2), 1.0]
			if s == 2:
				return [Color(0.45, 0.35, 0.25), 0.45]
			return [Color(0.3, 0.55, 0.22) if kind == 1 else Color(0.38, 0.58, 0.25), 1.0]
		3:
			if s == 3:
				return [Color(0.58, 0.42, 0.85), 1.0]
			if s == 2:
				return [Color(0.42, 0.38, 0.3), 0.5]
			return [Color(0.32, 0.55, 0.3), 1.0]
		4:
			return [Color(0.9, 0.92, 0.95) if snowy else Color(0.15, 0.38, 0.2), 1.0]
		5:
			if s == 0 or s == 3:
				return [Color(0.92, 0.5, 0.7), 1.0]
			return [Color(0.35, 0.55, 0.28), 0.9]
		6:
			return [Color(0.3, 0.6, 0.25), 1.0]
		7:
			return [Color(0.55, 0.7, 0.3) if s != 2 else Color(0.5, 0.5, 0.35), 1.0]
	return [Color(0.3, 0.55, 0.25), 1.0]
func emit_trees(i: int, p: Vector3) -> void:
	var kind: int = tree[i]
	var tc := tree_colors(kind)
	var crown: Color = tc[0]
	var full: float = tc[1]
	var nt := 1 + int(hsh(i, 1) * 2.4)
	for k in nt:
		var ox := (hsh(i, k * 3 + 2) - 0.5) * CELL * 0.6
		var oz := (hsh(i, k * 3 + 3) - 0.5) * CELL * 0.6
		var sc := 0.8 + hsh(i, k * 3 + 4) * 0.6
		var x := p.x + ox
		var z := p.z + oz
		var gy := ground_y(x, z) - 0.12
		match kind:
			4:
				em(M_BOX, x, gy, z, 0.25 * sc, 0.8 * sc, 0.25 * sc, 0.0, Color(0.35, 0.25, 0.15))
				em(M_CONE, x, gy + 0.6 * sc, z, 1.7 * sc, 3.2 * sc, 1.7 * sc, 0.0, crown, 0.0, 0.0, 0.0, 2.08)
			5:
				em(M_CYL, x, gy, z, 0.6 * sc, 1.6 * sc, 0.6 * sc, 0.0, Color(0.45, 0.5, 0.35))
				em(M_SPH, x, gy + 1.4 * sc, z, 2.2 * sc * full, 1.6 * sc * full, 2.2 * sc * full, 0.0, crown, 0.0, 0.0, 0.0, 2.15)
			6:
				em(M_BOX, x, gy, z, 0.22 * sc, 3.2 * sc, 0.22 * sc, 0.3, Color(0.5, 0.4, 0.25))
				em(M_SPH, x, gy + 3.0 * sc, z, 2.2 * sc, 0.6 * sc, 2.2 * sc, 0.0, crown, 0.0, 0.0, 0.0, 2.3)
			7:
				em(M_BOX, x, gy, z, 0.3 * sc, 1.2 * sc, 0.3 * sc, 0.0, Color(0.35, 0.28, 0.2))
				em(M_SPH, x, gy + 0.6 * sc, z, 2.6 * sc, 2.2 * sc, 2.6 * sc, 0.0, crown, 0.0, 0.0, 0.0, 2.18)
			_:
				em(M_BOX, x, gy, z, 0.25 * sc, 1.1 * sc, 0.25 * sc, 0.0, Color(0.35, 0.25, 0.15))
				em(M_SPH, x, gy + 0.9 * sc, z, 1.9 * sc * full, 1.8 * sc * full, 1.9 * sc * full, 0.0, crown, 0.0, 0.0, 0.0, 2.16)
func emit_grass(i: int, p: Vector3) -> void:
	var h := hsh(i, 40)
	if h > 0.17:
		return
	var gc: Color = [Color(0.3, 0.52, 0.2), Color(0.5, 0.46, 0.2), Color(0.5, 0.56, 0.5), Color(0.33, 0.56, 0.22)][season()]
	for k in 2:
		var x := p.x + (hsh(i, 41 + k) - 0.5) * CELL * 0.8
		var z := p.z + (hsh(i, 44 + k) - 0.5) * CELL * 0.8
		var hh := 0.35 + hsh(i, 47 + k) * 0.4
		var v := 0.85 + hsh(i, 50 + k) * 0.35
		em(M_GRASS, x, ground_y(x, z) - 0.04, z, 0.18, hh, 0.18, hsh(i, 53 + k) * 3.0, gc * v * 1.3, 0.0, 0.0, 0.0, 2.1)
	if h < 0.03:
		var fc: Color = [Color(0.95, 0.85, 0.25), Color(0.95, 0.95, 0.92), Color(0.9, 0.45, 0.6), Color(0.7, 0.5, 0.9)][int(hsh(i, 60) * 4.0) % 4]
		var fx := p.x + (hsh(i, 61) - 0.5) * CELL * 0.6
		var fz := p.z + (hsh(i, 62) - 0.5) * CELL * 0.6
		em(M_GRASS, fx, ground_y(fx, fz) + 0.26, fz, 0.2, 0.16, 0.2, 0.0, fc, 0.0, 0.0, 0.0, 2.1)
func zone_color(z: int) -> Color:
	if opts["colorblind"]:
		return [Color(), Color(0.95, 0.75, 0.2), Color(0.2, 0.5, 0.95), Color(0.6, 0.6, 0.6), Color(0.9, 0.5, 0.9)][z]
	return [Color(), Color(0.45, 0.8, 0.4), Color(0.35, 0.55, 0.95), Color(0.95, 0.8, 0.3), Color(0.75, 0.55, 0.9)][z]
func emit_lot(i: int, p: Vector3) -> void:
	em(M_BOX, p.x, p.y, p.z, CELL * 0.92, 0.08, CELL * 0.92, 0.0, zone_color(zone[i]).darkened(0.35))
func emit_zone(i: int, p: Vector3) -> void:
	var z: int = zone[i]
	var l: int = lvl[i]
	if l == 0:
		emit_lot(i, p)
		return
	var v: int = vari[i]
	var rot := face_rot(i)
	var dark := burn[i] > 0.0
	var big := part[i] == i
	var w := CELL * (1.85 if big else 0.82)
	var bx := p.x
	var bz := p.z
	if big:
		bx += CELL * 0.5
		bz += CELL * 0.5
	em(M_BOX, bx, p.y, bz, w + CELL * 0.1, 0.12, w + CELL * 0.1, 0.0, (Color(0.36, 0.5, 0.28) if l == 1 else Color(0.5, 0.52, 0.45)) if z == Z_R else Color(0.55, 0.55, 0.55))
	var y := p.y + 0.1
	var wall := tint(res_wall(v), i)
	if dark:
		wall = wall.darkened(0.6)
	match z:
		Z_R:
			emit_res(i, bx, y, bz, w, l, v, rot, wall, big)
		Z_C:
			emit_com(i, bx, y, bz, w, l, v, rot, dark, big)
		Z_I:
			emit_ind(i, bx, y, bz, w, l, v, rot, dark)
		Z_M:
			emit_com(i, bx, y, bz, w, mini(l, 2), v, rot, dark, false)
			if l >= 2:
				var h := 2.0 + l * 2.5
				em(M_BOX, bx, y + 3.0, bz, w * 0.8, h, w * 0.8, rot, wall, 1.0)
func tint(c: Color, i: int) -> Color:
	var hh := fposmod(c.h + (hsh(i, 77) - 0.5) * 0.07, 1.0)
	return Color.from_hsv(hh, clampf(c.s * (0.75 + hsh(i, 78) * 0.6), 0.0, 1.0), clampf(c.v * (0.86 + hsh(i, 79) * 0.2), 0.0, 1.0))
func tower_col(v: int, i: int) -> Color:
	var gp := [Color(0.45, 0.62, 0.78), Color(0.35, 0.58, 0.55), Color(0.66, 0.6, 0.5), Color(0.3, 0.34, 0.42), Color(0.78, 0.74, 0.68), Color(0.5, 0.52, 0.72), Color(0.72, 0.5, 0.42)]
	return tint(gp[(v / 3 + i) % gp.size()], i)
func res_wall(v: int) -> Color:
	var pal := [Color(0.92, 0.88, 0.8), Color(0.85, 0.72, 0.6), Color(0.95, 0.93, 0.88), Color(0.78, 0.55, 0.45), Color(0.88, 0.82, 0.65), Color(0.7, 0.75, 0.78), Color(0.95, 0.85, 0.75), Color(0.65, 0.6, 0.55)]
	return pal[v % pal.size()]
func emit_ind(i: int, x: float, y: float, z: float, w: float, l: int, v: int, rot: float, dark: bool) -> void:
	var c := tint(COL_BRICK if v % 2 == 0 else Color(0.55, 0.6, 0.62), i)
	var im := -1.0 if v % 2 == 0 else -5.0
	if dark:
		c = c.darkened(0.6)
	match l:
		1:
			em(M_BOX, x, y, z, w * 0.9, 2.6, w * 0.8, rot, c, 0, 0, 0, im)
			em(M_ROOF, x, y + 2.6, z, w * 0.9, 0.8, w * 0.8, rot, Color(0.45, 0.47, 0.5), 0, 0, 0, -5)
		2:
			em(M_BOX, x, y, z, w * 0.9, 3.4, w * 0.9, rot, c, 0.4, 0, 0, im)
			em(M_CYL, x + w * 0.3, y, z + w * 0.3, 0.8, 5.0, 0.8, 0.0, Color(0.42, 0.38, 0.36))
		3:
			em(M_BOX, x - w * 0.15, y, z, w * 0.6, 4.0, w * 0.9, rot, c, 0.4, 0, 0, im)
			em(M_CYL, x + w * 0.3, y, z - w * 0.2, 1.4, 3.5, 1.4, 0.0, Color(0.8, 0.8, 0.82))
			em(M_CYL, x + w * 0.3, y, z + w * 0.25, 1.4, 3.5, 1.4, 0.0, Color(0.8, 0.8, 0.82))
			em(M_CYL, x - w * 0.3, y, z - w * 0.3, 0.8, 6.5, 0.8, 0.0, Color(0.42, 0.38, 0.36))
		4:
			em(M_BOX, x, y, z, w * 0.95, 6.0, w * 0.95, rot, c, 0.5, 0, 0, im)
			em(M_CYL, x - w * 0.3, y, z - w * 0.3, 1.0, 8.5, 1.0, 0.0, Color(0.42, 0.38, 0.36))
			em(M_CYL, x + w * 0.3, y, z - w * 0.3, 1.0, 7.5, 1.0, 0.0, Color(0.42, 0.38, 0.36))
			em(M_BOX, x, y + 6.0, z, w * 0.5, 1.5, w * 0.4, rot, c.darkened(0.2))
func emit_def(i: int, p: Vector3) -> void:
	var d: Dictionary = DEF[bld[i]]
	var sz: int = d["sz"]
	var w := sz * CELL
	var x := p.x + (sz - 1) * CELL * 0.5
	var z := p.z + (sz - 1) * CELL * 0.5
	var y := p.y
	var col: Color = d["col"]
	if burn[i] > 0.0:
		col = col.darkened(0.6)
	var sh: String = d["sh"]
	var rot := face_rot(i)
	if d["c"] == "wonder":
		var prog: int = wonder_progress.get(i, 0)
		if prog < WONDER_STEPS:
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.6, 0.55, 0.45))
			var h := 2.0 + prog * 3.0
			em(M_BOX, x, y, z, w * 0.6, h, w * 0.6, 0.0, col.darkened(0.3))
			for k in 4:
				var a := k * PI * 0.5 + 0.785
				em(M_BOX, x + cos(a) * w * 0.38, y, z + sin(a) * w * 0.38, 0.2, h + 1.0, 0.2, 0.0, Color(0.85, 0.6, 0.2))
			em(M_BOX, x + w * 0.3, y, z - w * 0.3, 0.3, h + 8.0, 0.3, 0.0, Color(0.95, 0.75, 0.1))
			em(M_BOX, x + w * 0.1, y + h + 7.6, z - w * 0.3, w * 0.5, 0.3, 0.3, 0.0, Color(0.95, 0.75, 0.1))
			return
	var ground := Color(0.55, 0.55, 0.52)
	match sh:
		"cinema":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			bx(x, y, z, rot, 0, -0.05 * w, 0, w * 0.86, 5.2, w * 0.78, col)
			bx(x, y, z, rot, 0, -0.05 * w, 5.2, w * 0.9, 0.3, w * 0.82, Color(0.12, 0.12, 0.13))
			bx(x, y, z, rot, 0, 0.42 * w, 2.6, w * 0.92, 0.7, 0.55, Color(0.95, 0.85, 0.45), 0, 0.9)
			bx(x, y, z, rot, 0, 0.43 * w, 2.45, w * 0.88, 0.12, 0.5, Color(1.0, 0.92, 0.65), 0, 0, 2.2)
			bx(x, y, z, rot, 0.36 * w, 0.39 * w, 3.3, 0.25, 2.8, 0.55, Color(1.0, 0.25, 0.2), 0, 0, 1.6)
			bx(x, y, z, rot, -0.27 * w, 0.351 * w, 0.5, 0.65, 1.3, 0.04, Color(0.2, 0.25, 0.55), 0, 0.5)
			bx(x, y, z, rot, 0.27 * w, 0.351 * w, 0.5, 0.65, 1.3, 0.04, Color(0.65, 0.15, 0.1), 0, 0.5)
			bx(x, y, z, rot, 0, 0.351 * w, 0.05, 1.0, 2.0, 0.03, COL_GLASS, 0, 0, 0, -8)
		"civic":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x, y, z, w * 0.8, 3.2, w * 0.7, rot, col, 0.8)
			em(M_BOX, x, y + 3.2, z, w * 0.84, 0.3, w * 0.74, rot, col.darkened(0.25))
			em(M_BOX, x + w * 0.38, y, z + w * 0.38, 0.1, 4.5, 0.1, 0.0, Color(0.8, 0.8, 0.8))
			em(M_BOX, x + w * 0.38 + 0.45, y + 3.9, z + w * 0.38, 0.9, 0.5, 0.05, 0.0, Color(0.45, 0.7, 0.95))
		"tower":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x, y, z, w * 0.75, 4.0 + sz * 5.0, w * 0.55, rot, col, 1.0)
			em(M_BOX, x, y, z, w * 0.4, 7.0 + sz * 6.0, w * 0.4, rot, col.darkened(0.08), 1.0)
		"campus":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.4, 0.62, 0.32))
			em(M_BOX, x, y, z - w * 0.25, w * 0.7, 6.0, w * 0.25, 0.0, col, 1.0)
			em(M_BOX, x - w * 0.3, y, z + w * 0.15, w * 0.2, 4.5, w * 0.45, 0.0, col, 1.0)
			em(M_BOX, x + w * 0.3, y, z + w * 0.15, w * 0.2, 4.5, w * 0.45, 0.0, col, 1.0)
			em(M_BOX, x, y + 6.0, z - w * 0.25, 2.0, 4.0, 2.0, 0.0, col.lightened(0.1))
		"cabildo":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.66, 0.6))
			em(M_BOX, x, y, z, w * 0.8, 5.0, w * 0.45, rot, col, 0.9)
			em(M_ROOF, x, y + 5.0, z, w * 0.8, 1.2, w * 0.45, rot, Color(0.6, 0.3, 0.2))
			em(M_BOX, x, y, z, 2.2, 10.0, 2.2, rot, col)
			em(M_CONE, x, y + 10.0, z, 2.4, 2.5, 2.4, 0.0, Color(0.55, 0.3, 0.2))
		"park":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, col)
			em(M_BOX, x, y, z, w * 0.9, 0.17, 0.8, 0.0, Color(0.8, 0.75, 0.6))
			em(M_BOX, x, y, z, 0.8, 0.17, w * 0.9, 0.0, Color(0.8, 0.75, 0.6))
			for k in sz * 3:
				var ax := x + (hsh(i, k) - 0.5) * w * 0.8
				var az := z + (hsh(i, k + 9) - 0.5) * w * 0.8
				em(M_BOX, ax, y, az, 0.25, 1.0, 0.25, 0.0, Color(0.35, 0.25, 0.15))
				em(M_SPH, ax, y + 0.8, az, 2.0, 2.0, 2.0, 0.0, tree_colors(1 + k % 3)[0])
			if sz >= 2:
				em(M_CYL, x, y, z, 2.0, 0.6, 2.0, 0.0, Color(0.7, 0.7, 0.72))
				em(M_CYL, x, y + 0.6, z, 0.5, 1.4, 0.5, 0.0, Color(0.6, 0.75, 0.95), 0, 0, 0.2)
		"pitch":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, Color(0.25, 0.58, 0.28))
			em(M_BOX, x, y, z, w * 0.75, 0.16, w * 0.55, rot, Color(0.3, 0.7, 0.32))
			em(M_BOX, x, y, z, 0.12, 0.17, w * 0.55, rot, Color(0.95, 0.95, 0.95))
			for sgn in [-1, 1]:
				em(M_BOX, x + sgn * w * 0.36 * cos(rot), y, z - sgn * w * 0.36 * sin(rot), 0.2, 1.0, 1.8, rot, Color(0.95, 0.95, 0.95))
		"parrilla":
			em(M_BOX, x, y, z, w * 0.9, 0.15, w * 0.9, 0.0, Color(0.7, 0.65, 0.55))
			em(M_BOX, x, y, z, 2.2, 1.3, 1.2, rot, Color(0.65, 0.32, 0.2))
			em(M_BOX, x, y + 1.3, z, 0.6, 1.6, 0.6, rot, Color(0.55, 0.28, 0.18))
			em(M_BOX, x + 1.0, y, z + 1.2, 1.6, 0.8, 0.8, 0.0, Color(0.5, 0.35, 0.2))
		"calesita":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.66, 0.58))
			em(M_CYL, x, y, z, 3.2, 0.4, 3.2, 0.0, Color(0.95, 0.9, 0.7))
			em(M_CYL, x, y + 0.4, z, 0.3, 2.2, 0.3, 0.0, Color(0.9, 0.85, 0.3))
			em(M_CONE, x, y + 2.6, z, 3.6, 1.6, 3.6, 0.0, col, 0, 0.5)
		"stadium":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, ground)
			em(M_CYL, x, y, z, w * 0.92, 5.5, w * 0.8, 0.0, col, 0.3)
			em(M_CYL, x, y + 5.5, z, w * 0.7, 0.2, w * 0.58, 0.0, Color(0.3, 0.65, 0.3))
			for k in 4:
				var a := k * PI * 0.5 + 0.785
				em(M_BOX, x + cos(a) * w * 0.45, y, z + sin(a) * w * 0.4, 0.4, 12.0, 0.4, 0.0, Color(0.7, 0.7, 0.72))
				em(M_BOX, x + cos(a) * w * 0.45, y + 12.0, z + sin(a) * w * 0.4, 2.0, 1.0, 0.4, a, Color(1, 1, 0.9), 0, 1.5)
		"wheel":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x - 1.5, y, z, 0.4, 8.0, 0.4, 0.3, Color(0.8, 0.8, 0.82))
			em(M_BOX, x + 1.5, y, z, 0.4, 8.0, 0.4, -0.3, Color(0.8, 0.8, 0.82))
			for k in 12:
				var a := k * TAU / 12.0
				em(M_BOX, x + cos(a) * 6.0, y + 8.0 + sin(a) * 6.0, z, 0.9, 0.9, 0.9, 0.0, [col, Color(0.95, 0.85, 0.2), Color(0.3, 0.6, 0.95)][k % 3], 0, 0.6)
		"cathedral":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.68, 0.62))
			em(M_BOX, x, y, z, w * 0.4, 7.0, w * 0.75, rot, col, 0.5)
			em(M_ROOF, x, y + 7.0, z, w * 0.4, 2.5, w * 0.75, rot, Color(0.4, 0.4, 0.45))
			for sgn in [-1, 1]:
				var tx: float = x + sgn * w * 0.18
				em(M_BOX, tx, y, z + w * 0.35, 2.0, 11.0, 2.0, 0.0, col)
				em(M_CONE, tx, y + 11.0, z + w * 0.35, 2.2, 4.0, 2.2, 0.0, Color(0.35, 0.4, 0.45))
		"lighthouse":
			em(M_CYL, x, y, z, 2.4, 0.5, 2.4, 0.0, Color(0.5, 0.5, 0.5))
			for k in 5:
				em(M_CYL, x, y + 0.5 + k * 2.2, z, 1.6 - k * 0.1, 2.2, 1.6 - k * 0.1, 0.0, Color(0.95, 0.95, 0.95) if k % 2 == 0 else Color(0.8, 0.15, 0.15))
			em(M_CYL, x, y + 11.5, z, 1.2, 1.2, 1.2, 0.0, Color(1, 0.95, 0.7), 0, 2.0)
		"clock":
			em(M_BOX, x, y, z, w * 0.9, 0.15, w * 0.9, 0.0, Color(0.7, 0.68, 0.6))
			em(M_BOX, x, y, z, 1.6, 9.0, 1.6, rot, col)
			em(M_BOX, x, y + 7.2, z, 1.75, 1.2, 1.75, rot, Color(0.95, 0.95, 0.9), 0, 0.8)
			em(M_CONE, x, y + 9.0, z, 2.0, 1.8, 2.0, 0.0, Color(0.3, 0.35, 0.3))
		"beach":
			em(M_BOX, x, y, z, w, 0.12, w, 0.0, Color(0.92, 0.85, 0.6))
			for k in 3:
				var ax := x + (hsh(i, k) - 0.5) * w * 0.7
				var az := z + (hsh(i, k + 4) - 0.5) * w * 0.7
				em(M_BOX, ax, y, az, 0.08, 1.6, 0.08, 0.0, Color(0.9, 0.9, 0.9))
				em(M_CONE, ax, y + 1.4, az, 1.8, 0.5, 1.8, 0.0, [Color(0.9, 0.3, 0.3), Color(0.2, 0.5, 0.9), Color(0.95, 0.8, 0.2)][k])
		"plant":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x - w * 0.12, y, z, w * 0.55, 5.0, w * 0.7, rot, col, 0.3)
			em(M_CYL, x + w * 0.28, y, z - w * 0.25, 1.3, 12.0, 1.3, 0.0, col.darkened(0.2))
			em(M_CYL, x + w * 0.28, y, z + w * 0.15, 1.3, 10.0, 1.3, 0.0, col.darkened(0.2))
		"solar":
			em(M_BOX, x, y, z, w * 0.98, 0.12, w * 0.98, 0.0, Color(0.45, 0.55, 0.35))
			for k in 4:
				em(M_BOX, x, y + 0.6, z - w * 0.36 + k * w * 0.24, w * 0.85, 0.12, w * 0.16, 0.0, col, 0, 0, 0.05)
		"windmill":
			em(M_CYL, x, y, z, 0.6, 11.0, 0.6, 0.0, col)
			em(M_BOX, x, y + 11.0, z + 0.4, 0.4, 7.0, 0.15, 0.0, col)
			em(M_BOX, x, y + 13.5, z + 0.4, 6.0, 0.4, 0.15, 0.7, col)
		"dam":
			em(M_BOX, x, y - 2.0, z, w, 6.0, w * 0.35, rot, col)
			em(M_BOX, x, y, z + w * 0.3, w * 0.5, 3.0, w * 0.3, rot, col.darkened(0.15), 0.4)
		"pump":
			em(M_BOX, x, y, z, w * 0.7, 2.2, w * 0.7, 0.0, col, 0.3)
			em(M_CYL, x + 1.0, y, z + 1.0, 0.7, 3.0, 0.7, 0.0, Color(0.6, 0.6, 0.65))
		"watertower":
			for k in 4:
				var a := k * PI * 0.5 + 0.785
				em(M_BOX, x + cos(a) * 1.0, y, z + sin(a) * 1.0, 0.2, 6.0, 0.2, 0.0, Color(0.5, 0.5, 0.52))
			em(M_SPH, x, y + 5.5, z, 3.2, 3.0, 3.2, 0.0, col)
		"landfill":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, Color(0.45, 0.4, 0.3))
			for k in 4:
				em(M_SPH, x + (hsh(i, k) - 0.5) * w * 0.6, y, z + (hsh(i, k + 3) - 0.5) * w * 0.6, 4.0, 1.8, 3.5, 0.0, Color(0.42, 0.36, 0.28))
		"metro":
			em(M_BOX, x, y, z, w * 0.9, 0.15, w * 0.9, 0.0, ground)
			em(M_BOX, x, y, z, 2.4, 1.6, 2.4, rot, Color(0.85, 0.85, 0.85), 0.5)
			em(M_BOX, x, y + 1.6, z, 1.0, 1.0, 0.2, rot, col, 0, 0, 0.6)
		"station":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, ground)
			em(M_BOX, x, y, z, w * 0.8, 4.0, w * 0.4, rot, col, 0.6)
			em(M_ROOF, x, y + 4.0, z, w * 0.85, 1.6, w * 0.45, rot, Color(0.4, 0.4, 0.42))
			em(M_BOX, x, y + 5.2, z, 1.0, 1.0, 0.3, rot, Color(0.95, 0.95, 0.9), 0, 0.6)
		"port":
			em(M_BOX, x, y, z, w, 0.4, w, 0.0, Color(0.5, 0.48, 0.45))
			em(M_BOX, x - w * 0.25, y, z, w * 0.35, 3.0, w * 0.6, 0.0, col)
			for k in 3:
				em(M_BOX, x + w * 0.2, y + 0.4 + k * 1.0, z - w * 0.2 + k * 0.2, 2.5, 1.0, 1.0, 0.0, [Color(0.8, 0.3, 0.2), Color(0.2, 0.4, 0.8), Color(0.2, 0.6, 0.3)][k])
			em(M_BOX, x + w * 0.35, y, z + w * 0.3, 0.5, 10.0, 0.5, 0.0, Color(0.95, 0.7, 0.1))
			em(M_BOX, x + w * 0.35 - 2.0, y + 10.0, z + w * 0.3, 5.0, 0.4, 0.4, 0.0, Color(0.95, 0.7, 0.1))
		"airport":
			em(M_BOX, x, y, z, w, 0.12, w, 0.0, Color(0.45, 0.5, 0.4))
			em(M_BOX, x, y, z + w * 0.15, w * 0.95, 0.16, w * 0.22, 0.0, Color(0.25, 0.25, 0.27))
			em(M_BOX, x, y, z + w * 0.15, w * 0.9, 0.17, 0.25, 0.0, Color(0.95, 0.95, 0.95))
			em(M_BOX, x - w * 0.15, y, z - w * 0.28, w * 0.5, 3.5, w * 0.25, 0.0, col, 1.0)
			em(M_CYL, x + w * 0.3, y, z - w * 0.3, 1.2, 9.0, 1.2, 0.0, Color(0.8, 0.8, 0.82))
			em(M_CYL, x + w * 0.3, y + 9.0, z - w * 0.3, 2.2, 1.6, 2.2, 0.0, Color(0.4, 0.55, 0.65), 0, 0.6)
		"pier":
			em(M_BOX, x, 0.2, z, w * 0.4, 0.3, w * 1.2, rot, col)
			em(M_BOX, x, 0.5, z, 1.4, 2.0, 1.4, rot, Color(0.8, 0.75, 0.6))
		"parking":
			em(M_BOX, x, y, z, w * 0.95, 0.16, w * 0.95, 0.0, col)
			for k in 4:
				em(M_BOX, x - 1.0 + (k % 2) * 2.0, y + 0.16, z - 0.8 + (k / 2) * 1.6, 1.5, 0.6, 0.75, 0.0, car_color(i + k))
		"mall":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, Color(0.3, 0.3, 0.32))
			em(M_BOX, x, y, z, w * 0.8, 6.0, w * 0.7, rot, col, 0.6)
			em(M_BOX, x, y + 6.0, z, w * 0.5, 0.8, 0.3, rot, Color(0.95, 0.3, 0.4), 0, 1.2)
		"gated":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, Color(0.4, 0.62, 0.32))
			for sgn in [-1, 1]:
				em(M_BOX, x + sgn * w * 0.48, y, z, 0.25, 1.4, w * 0.96, 0.0, Color(0.85, 0.82, 0.75))
				em(M_BOX, x, y, z + sgn * w * 0.48, w * 0.96, 1.4, 0.25, 0.0, Color(0.85, 0.82, 0.75))
			for k in 4:
				var hx := x + (k % 2 - 0.5) * w * 0.45
				var hz := z + (k / 2 - 0.5) * w * 0.45
				em(M_BOX, hx, y, hz, 2.6, 2.0, 2.2, 0.0, col, 0.6)
				em(M_ROOF, hx, y + 2.0, hz, 2.8, 1.0, 2.3, 0.0, Color(0.6, 0.3, 0.2))
			em(M_BOX, x + 1.5, y, z + 1.0, 2.0, 0.12, 1.2, 0.0, Color(0.3, 0.65, 0.9), 0, 0, 0.15)
		"farm":
			for k in 4:
				em(M_BOX, x, y, z - w * 0.36 + k * w * 0.24, w * 0.95, 0.2, w * 0.22, 0.0, [Color(0.75, 0.65, 0.3), Color(0.45, 0.6, 0.25)][k % 2])
			em(M_BOX, x + w * 0.3, y, z + w * 0.3, 2.4, 2.4, 2.0, 0.0, Color(0.7, 0.2, 0.15))
			em(M_ROOF, x + w * 0.3, y + 2.4, z + w * 0.3, 2.6, 1.2, 2.1, 0.0, Color(0.4, 0.35, 0.3))
		"w_tower":
			em(M_BOX, x, y, z, w * 0.95, 0.15, w * 0.95, 0.0, Color(0.7, 0.7, 0.72))
			em(M_CYL, x, y, z, 3.0, 30.0, 3.0, 0.0, col, 0.8)
			em(M_CYL, x, y + 30.0, z, 5.0, 3.0, 5.0, 0.0, Color(0.5, 0.6, 0.75), 1.2)
			em(M_CONE, x, y + 33.0, z, 1.2, 10.0, 1.2, 0.0, Color(0.85, 0.85, 0.9), 0, 0.8)
		"w_park":
			em(M_BOX, x, y, z, w * 0.98, 0.14, w * 0.98, 0.0, Color(0.3, 0.6, 0.28))
			em(M_CYL, x, y, z, w * 0.4, 0.2, w * 0.4, 0.0, Color(0.2, 0.45, 0.65), 0, 0, 0.1)
			for k in 14:
				var a := k * TAU / 14.0
				var ax := x + cos(a) * w * 0.38
				var az := z + sin(a) * w * 0.38
				em(M_BOX, ax, y, az, 0.3, 1.2, 0.3, 0.0, Color(0.35, 0.25, 0.15))
				em(M_SPH, ax, y + 1.0, az, 2.4, 2.4, 2.4, 0.0, tree_colors(3 if k % 3 == 0 else 1)[0])
			em(M_BOX, x, y, z, 1.0, 6.0, 1.0, 0.0, Color(0.95, 0.95, 0.95))
		"w_stadium":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, ground)
			em(M_CYL, x, y, z, w * 0.95, 9.0, w * 0.85, 0.0, col, 0.4)
			em(M_CYL, x, y + 9.0, z, w * 0.72, 0.2, w * 0.62, 0.0, Color(0.3, 0.65, 0.3))
			em(M_CYL, x, y + 9.0, z, w * 0.98, 0.6, w * 0.88, 0.0, Color(0.45, 0.65, 0.95))
		"w_palace":
			em(M_BOX, x, y, z, w * 0.98, 0.15, w * 0.98, 0.0, Color(0.75, 0.72, 0.65))
			em(M_BOX, x, y, z, w * 0.85, 8.0, w * 0.5, rot, col, 0.9)
			em(M_SPH, x, y + 8.0, z, 7.0, 8.0, 7.0, 0.0, Color(0.55, 0.7, 0.65))
			em(M_CONE, x, y + 15.0, z, 1.0, 4.0, 1.0, 0.0, Color(0.9, 0.8, 0.3))
			for sgn in [-1, 1]:
				em(M_BOX, x + sgn * w * 0.38, y, z, 3.0, 11.0, 3.0, 0.0, col)
		_:
			em(M_BOX, x, y, z, w * 0.8, 3.0, w * 0.8, 0.0, col)
func build_overlay() -> void:
	var mm := overlay_node.multimesh
	if view_mode == "":
		mm.instance_count = 0
		return
	begin_buf()
	for i in N * N:
		var c := overlay_color(i)
		if c.a <= 0.0:
			continue
		var p := cell_pos(i)
		em(M_BOX, p.x, maxf(p.y, 0.0) + 0.5, p.z, CELL * 0.96, 0.1, CELL * 0.96, 0.0, c)
	mm.instance_count = _counts[M_BOX]
	if _counts[M_BOX] > 0:
		mm.buffer = _bufs[M_BOX].slice(0, _counts[M_BOX] * 20)
func heat(v: float, a: float = 0.55) -> Color:
	v = clampf(v, 0.0, 1.0)
	if opts["colorblind"]:
		return Color(0.15 + v * 0.8, 0.45 + v * 0.1, 0.95 - v * 0.85, a)
	return Color(minf(1.0, v * 2.0), minf(1.0, (1.0 - v) * 2.0), 0.15, a)
func overlay_color(i: int) -> Color:
	var built := zone[i] > 0 or bld[i] > 0
	match view_mode:
		"power":
			if built:
				return Color(1, 0.9, 0.2, 0.55) if powered[i] else Color(0.9, 0.15, 0.1, 0.6)
			if wire[i] & W_POWER:
				return Color(1, 0.8, 0.2, 0.4)
		"water":
			if built:
				return Color(0.2, 0.6, 1.0, 0.55) if watered[i] else Color(0.9, 0.15, 0.1, 0.6)
			if wire[i] & W_PIPE:
				return Color(0.3, 0.7, 1.0, 0.5)
		"pollution":
			if pollution[i] > 0.05:
				return Color(0.45, 0.3, 0.1, clampf(pollution[i], 0.0, 0.8))
		"crime":
			if built and zone[i] > 0:
				return heat(crime[i])
		"land":
			if terr[i] != T_WATER:
				var v := landv[i]
				return Color(0.2, 0.4 + v * 0.6, 0.2, 0.45)
		"traffic":
			if road[i] > 0:
				return heat(tload[i] / road_cap(i), 0.75)
		"happy":
			if zone[i] == Z_R or zone[i] == Z_M:
				return heat(1.0 - happy[i])
		"fire":
			return Color(0.95, 0.3, 0.1, clampf(cov[CV_FIRE][i], 0.0, 1.0) * 0.6) if cov[CV_FIRE][i] > 0.02 else Color(0, 0, 0, 0)
		"police":
			return Color(0.2, 0.3, 0.95, clampf(cov[CV_POL][i], 0.0, 1.0) * 0.6) if cov[CV_POL][i] > 0.02 else Color(0, 0, 0, 0)
		"health":
			return Color(0.95, 0.95, 0.95, clampf(cov[CV_HEALTH][i], 0.0, 1.0) * 0.6) if cov[CV_HEALTH][i] > 0.02 else Color(0, 0, 0, 0)
		"edu":
			var e := maxf(cov[CV_EDU1][i], maxf(cov[CV_EDU2][i], cov[CV_EDU3][i]))
			return Color(0.95, 0.8, 0.2, clampf(e, 0.0, 1.0) * 0.6) if e > 0.02 else Color(0, 0, 0, 0)
		"transit":
			return Color(0.3, 0.8, 0.9, clampf(cov[CV_TRANSIT][i], 0.0, 1.0) * 0.6) if cov[CV_TRANSIT][i] > 0.02 else Color(0, 0, 0, 0)
		"garbage":
			if garbp[i] > 0.1:
				return Color(0.5, 0.35, 0.1, 0.7)
			if built and cov[CV_GARB][i] > 0.02:
				return Color(0.3, 0.7, 0.3, 0.35)
		"districts":
			var r := region_of(i)
			if not is_owned(i):
				return Color(0, 0, 0, 0.35)
			var dc: Color = [Color(0, 0, 0, 0), Color(0.9, 0.5, 0.2, 0.35), Color(0.2, 0.8, 0.3, 0.35), Color(0.3, 0.5, 0.95, 0.35), Color(0.9, 0.2, 0.7, 0.35)][district[r]]
			if (cx(i) % REG == 0 or cz(i) % REG == 0):
				return Color(1, 1, 1, 0.6)
			return dc
	return Color(0, 0, 0, 0)
var sun_rot := Vector3(999, 0, 0)
func update_light() -> void:
	hour = fmod(6.0 + day_timer / DAY_SECONDS * 24.0, 24.0)
	var sunrise := 6.25
	var sunset := 20.0
	var up := 0.0
	if hour > sunrise and hour < sunset:
		up = sin((hour - sunrise) / (sunset - sunrise) * PI)
	var nf := 1.0 - clampf(up * 4.0, 0.0, 1.0)
	night = nf
	var az := lerpf(-70.0, 250.0, clampf((hour - sunrise) / (sunset - sunrise), 0.0, 1.0))
	var srot := Vector3(-maxf(up * 62.0, 4.0), az, 0.0)
	if srot.distance_to(sun_rot) > 0.8:
		sun_rot = srot
		sun.rotation_degrees = srot
	# dirección real del sol para el cielo (de noche baja del horizonte)
	var elev := up * 62.0
	if hour <= sunrise or hour >= sunset:
		var nh := fmod(hour - sunset + 24.0, 24.0) / (24.0 - (sunset - sunrise))
		elev = -sin(nh * PI) * 25.0
	var sky_az := az if (hour > sunrise and hour < sunset) else lerpf(250.0, 290.0, fmod(hour - sunset + 24.0, 24.0) / (24.0 - (sunset - sunrise)))
	var sdir := Basis.from_euler(Vector3(deg_to_rad(-elev), deg_to_rad(sky_az), 0.0)).z
	sky_mat.set_shader_parameter("sun_dir", sdir)
	sky_mat.set_shader_parameter("moon_dir", moon.global_transform.basis.z)
	var se := sdir.y
	sun.light_color = sun_color_at(se)
	var cloudy := 0.0
	if weather == "Lluvia" or weather == "Tormenta" or weather == "Nieve":
		cloudy = 0.55
	elif weather == "Nublado":
		cloudy = 0.3
	var day_k := smoothstep(-0.02, 0.12, se)
	sun.light_energy = 1.6 * day_k * (1.0 - cloudy * 0.6)
	env.tonemap_exposure = lerpf(1.0, 1.35, nf)
	sun.visible = se > -0.02
	moon.light_energy = 0.28 * nf
	var hor := sky_horizon(se, cloudy)
	# la luz ambiente sigue al cielo real (no al factor de noche de las ventanas): cálida con el sol bajo
	var sky_day := smoothstep(-0.16, 0.10, se)
	var low_sun := 1.0 - smoothstep(0.0, 0.35, se)
	env.ambient_light_color = Color(0.62, 0.6, 0.56).lerp(hor, 0.35 + 0.35 * low_sun).lerp(Color(0.06, 0.07, 0.12), 1.0 - sky_day)
	env.ambient_light_energy = lerpf(0.45, 0.5, sky_day)
	env.ambient_light_sky_contribution = lerpf(0.55, 0.2, low_sun * sky_day)
	env.fog_light_color = hor
	env.fog_density = 0.0005 + cloudy * 0.0012 + (0.0005 if hour > 5.5 and hour < 8.0 else 0.0)
	city_mat.set_shader_parameter("night", nf)
	city_mat.set_shader_parameter("snow", 0.8 if weather == "Nieve" else 0.0)
	terrain_mat.set_shader_parameter("snow", 1.0 if weather == "Nieve" else 0.0)
	if far_mat != null:
		far_mat.set_shader_parameter("snow", 1.0 if weather == "Nieve" else 0.0)
	water_mat.set_shader_parameter("night", nf)
	water_mat.set_shader_parameter("wind_dir", wind)
	water_mat.set_shader_parameter("rain", 1.0 if (weather == "Lluvia" or weather == "Tormenta") and int(opts["quality"]) >= 2 else 0.0)
	city_mat.set_shader_parameter("wet", 1.0 if (weather == "Lluvia" or weather == "Tormenta") else 0.0)
	env.glow_intensity = lerpf(0.22, 0.9, nf)
# color del sol según la altura (seno de la elevación): blanco cálido arriba, dorado cerca del horizonte
func sun_color_at(se: float) -> Color:
	var t := clampf(se / 0.35, 0.0, 1.0)
	return Color(1.0, 0.5, 0.22).lerp(Color(1.0, 0.96, 0.9), t)
# color del horizonte (para la bruma), igual que en sky.gdshader
func sky_horizon(se: float, cloudy: float) -> Color:
	var day := smoothstep(-0.16, 0.10, se)
	var low := 1.0 - smoothstep(-0.05, 0.38, se)
	var c := Color(0.62, 0.75, 0.93).lerp(Color(0.95, 0.55, 0.35), low * 0.8)
	c = c.lerp(Color(0.6, 0.62, 0.65), cloudy)
	return Color(0.03, 0.045, 0.095).lerp(c, day)
const COL_WHITE := Color(0.93, 0.92, 0.88)
const COL_CREAM := Color(0.9, 0.83, 0.68)
const COL_BRICK := Color(0.68, 0.35, 0.26)
const COL_WOOD := Color(0.66, 0.43, 0.25)
const COL_CONC := Color(0.64, 0.64, 0.62)
const COL_BLACK := Color(0.13, 0.13, 0.14)
const COL_GLASS := Color(0.2, 0.25, 0.3)
const COL_STONE := Color(0.82, 0.76, 0.64)
func make_faces_mesh(faces: Array) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for f in faces:
		var hint: Vector3 = f[0]
		var pts: Array = f[1]
		var p0: Vector3 = pts[0]
		var p1: Vector3 = pts[1]
		var p2: Vector3 = pts[2]
		var n := (p1 - p0).cross(p2 - p0).normalized()
		if n.dot(hint) < 0.0:
			n = -n
		for k in range(1, pts.size() - 1):
			var b: Vector3 = pts[k]
			var c: Vector3 = pts[k + 1]
			if (b - p0).cross(c - p0).dot(n) > 0.0:
				var tmp := b
				b = c
				c = tmp
			st.set_normal(n)
			st.add_vertex(p0)
			st.set_normal(n)
			st.add_vertex(b)
			st.set_normal(n)
			st.add_vertex(c)
	return st.commit()
func make_gable_mesh() -> ArrayMesh:
	var t := 0.08
	var f: Array = []
	for sg in [-1.0, 1.0]:
		var s: float = sg
		f.append([Vector3(s, 0.5, 0), [Vector3(s * 0.5, 0, -0.5), Vector3(0, 1, -0.5), Vector3(0, 1, 0.5), Vector3(s * 0.5, 0, 0.5)]])
		f.append([Vector3(-s, -0.5, 0), [Vector3(s * 0.5, -t, -0.5), Vector3(0, 1 - t, -0.5), Vector3(0, 1 - t, 0.5), Vector3(s * 0.5, -t, 0.5)]])
		f.append([Vector3(s, 0, 0), [Vector3(s * 0.5, 0, -0.5), Vector3(s * 0.5, 0, 0.5), Vector3(s * 0.5, -t, 0.5), Vector3(s * 0.5, -t, -0.5)]])
		for zg in [-0.5, 0.5]:
			var zz: float = zg
			f.append([Vector3(0, 0, zz), [Vector3(s * 0.5, 0, zz), Vector3(0, 1, zz), Vector3(0, 1 - t, zz), Vector3(s * 0.5, -t, zz)]])
	return make_faces_mesh(f)
func make_hip_mesh() -> ArrayMesh:
	var r := 0.22
	var f: Array = []
	for sg in [-1.0, 1.0]:
		var s: float = sg
		f.append([Vector3(s, 0.6, 0), [Vector3(s * 0.5, 0, -0.5), Vector3(s * 0.5, 0, 0.5), Vector3(0, 1, r), Vector3(0, 1, -r)]])
		f.append([Vector3(0, 0.6, s), [Vector3(-0.5, 0, s * 0.5), Vector3(0.5, 0, s * 0.5), Vector3(0, 1, s * r)]])
	f.append([Vector3(0, -1, 0), [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(0.5, 0, 0.5), Vector3(-0.5, 0, 0.5)]])
	return make_faces_mesh(f)
func lp(x: float, z: float, rot: float, a: float, b: float) -> Vector2:
	var c := cos(rot)
	var s := sin(rot)
	return Vector2(x + a * c + b * s, z - a * s + b * c)
func bx(x: float, y: float, z: float, rot: float, a: float, b: float, yb: float, sx: float, sy: float, sz: float, col: Color, c0: float = 0.0, c1: float = 0.0, c2: float = 0.0, c3: float = 0.0) -> void:
	var q := lp(x, z, rot, a, b)
	em(M_BOX, q.x, y + yb, q.y, sx, sy, sz, rot, col, c0, c1, c2, c3)
func gable(x: float, y: float, z: float, rot: float, a: float, b: float, lx: float, lz: float, h: float, wallc: Color, roofc: Color, along_x: bool, rm: float = -4.0, wm: float = 0.0) -> void:
	var q := lp(x, z, rot, a, b)
	var r := rot + (PI * 0.5 if along_x else 0.0)
	var wx := lz if along_x else lx
	var wz := lx if along_x else lz
	em(M_ROOF, q.x, y, q.y, wx * 0.98, h, wz * 0.98, r, wallc, 0, 0, 0, wm)
	em(M_GABLE, q.x, y + 0.02, q.y, wx * 1.16, h * 1.12, wz * 1.08, r, roofc, 0, 0, 0, rm)
func hip(x: float, y: float, z: float, rot: float, a: float, b: float, lx: float, lz: float, h: float, roofc: Color) -> void:
	var q := lp(x, z, rot, a, b)
	if lx > lz:
		em(M_HIP, q.x, y, q.y, lz, h, lx, rot + PI * 0.5, roofc, 0, 0, 0, -4.0)
	else:
		em(M_HIP, q.x, y, q.y, lx, h, lz, rot, roofc, 0, 0, 0, -4.0)
func bush(x: float, y: float, z: float, r: float, i: int, k: int) -> void:
	var g := Color(0.2, 0.42, 0.18).lerp(Color(0.32, 0.5, 0.2), hsh(i, k))
	em(M_SPH, x, y, z, r, r * 0.8, r, 0.0, g, 0, 0, 0, 2.04)
func pine(x: float, y: float, z: float, h: float, i: int) -> void:
	em(M_BOX, x, y, z, 0.12, h * 0.25, 0.12, 0.0, Color(0.35, 0.24, 0.16))
	em(M_CONE, x, y + h * 0.2, z, h * 0.38, h * 0.8, h * 0.38, 0.0, Color(0.16, 0.34, 0.2).lerp(Color(0.25, 0.42, 0.2), hsh(i, 9)), 0, 0, 0, 2.03)
func parked_car(x: float, y: float, z: float, rot: float, a: float, b: float, i: int) -> void:
	var q := lp(x, z, rot, a, b)
	var cc: Color = [Color(0.92, 0.92, 0.93), Color(0.1, 0.1, 0.12), Color(0.55, 0.57, 0.6), Color(0.6, 0.1, 0.1)][int(hsh(i, 31) * 4.0) % 4]
	em(M_BOX, q.x, y + 0.15, q.y, 0.9, 0.42, 1.95, rot, cc, 0, 0, 0, 1.5)
	em(M_SPH, q.x, y + 0.5, q.y, 0.8, 0.42, 1.05, rot, Color(0.07, 0.09, 0.12), 0, 0, 0, 1.5)
func garden(i: int, x: float, y: float, z: float, rot: float, s: float) -> void:
	var q := lp(x, z, rot, -0.42 * s, 0.38 * s)
	bush(q.x, y, q.y, 0.6 + hsh(i, 3) * 0.3, i, 3)
	q = lp(x, z, rot, 0.42 * s, -0.4 * s)
	if hsh(i, 4) < 0.5:
		pine(q.x, y, q.y, 2.2 + hsh(i, 5) * 1.2, i)
	else:
		bush(q.x, y, q.y, 0.7, i, 6)
func emit_house(i: int, x: float, y: float, z: float, s: float, v: int, rot: float, wall: Color) -> void:
	var hd: bool = opts["quality"] >= 1
	var tile: Color = [Color(0.62, 0.27, 0.18), Color(0.45, 0.25, 0.18), Color(0.28, 0.22, 0.2), Color(0.72, 0.36, 0.2)][int(hsh(i, 11) * 4.0) % 4]
	var white := tint(COL_WHITE if hsh(i, 12) < 0.6 else COL_CREAM, i)
	var k := (v + int(hsh(i, 13) * 8.0)) % 8
	match k:
		0:
			bx(x, y, z, rot, -0.12 * s, -0.08 * s, 0, 0.62 * s, 3.4, 0.5 * s, white, 0.6)
			gable(x, y + 3.4, z, rot, -0.12 * s, -0.08 * s, 0.62 * s, 0.5 * s, 1.5, white, tile, true)
			bx(x, y, z, rot, 0.2 * s, 0.1 * s, 0, 0.34 * s, 3.4, 0.5 * s, white, 0.6)
			gable(x, y + 3.4, z, rot, 0.2 * s, 0.1 * s, 0.34 * s, 0.5 * s, 1.7, white, tile, false)
			bx(x, y, z, rot, 0.2 * s, 0.35 * s, 0, 0.32, 0.95, 0.05, Color(0.3, 0.2, 0.14), 0, 0, 0, -2)
			bx(x, y, z, rot, -0.14 * s, 0.24 * s, 1.75, 0.46 * s, 0.1, 0.2 * s, tile, 0, 0, 0, -4)
			if hd:
				for pa in [-0.34, -0.14, 0.06]:
					var pf: float = pa
					bx(x, y, z, rot, pf * s, 0.32 * s, 0, 0.1, 1.75, 0.1, Color(0.4, 0.26, 0.18))
				bx(x, y, z, rot, -0.14 * s, 0.33 * s, 0, 0.42 * s, 0.45, 0.05, COL_WHITE)
				bx(x, y, z, rot, 0.2 * s, 0.42 * s, 0, 0.6, 0.14, 0.25, COL_CONC)
			bx(x, y, z, rot, -0.34 * s, -0.12 * s, 3.4, 0.32, 2.3, 0.32, COL_BRICK, 0, 0, 0, -1)
		1:
			bx(x, y, z, rot, 0, -0.06 * s, 0, 0.7 * s, 2.2, 0.48 * s, white, 0.55)
			gable(x, y + 2.2, z, rot, 0, -0.06 * s, 0.7 * s, 0.48 * s, 1.6, white, tile, true)
			bx(x, y, z, rot, 0.17 * s, 0.22 * s, 0, 0.22 * s, 1.9, 0.1 * s, white)
			gable(x, y + 1.9, z, rot, 0.17 * s, 0.22 * s, 0.22 * s, 0.12 * s, 0.6, white, tile, false)
			bx(x, y, z, rot, 0.17 * s, 0.275 * s, 0, 0.3, 0.9, 0.04, Color(0.55, 0.3, 0.16), 0, 0, 0, -2)
			bx(x, y, z, rot, -0.2 * s, 0.24 * s, 1.6, 0.3 * s, 0.08, 0.16 * s, tile, 0, 0, 0, -4)
			if hd:
				bx(x, y, z, rot, -0.33 * s, 0.31 * s, 0, 0.08, 1.6, 0.08, COL_WHITE)
				bx(x, y, z, rot, -0.07 * s, 0.31 * s, 0, 0.08, 1.6, 0.08, COL_WHITE)
				bx(x, y, z, rot, -0.2 * s, 0.32 * s, 0, 0.3 * s, 0.42, 0.04, COL_WHITE)
				bx(x, y, z, rot, 0.27 * s, 0.28 * s, 1.25, 0.1, 0.16, 0.08, Color(1.0, 0.82, 0.5), 0, 1.0)
			bx(x, y, z, rot, 0.22 * s, -0.12 * s, 2.2, 0.3, 2.0, 0.3, COL_BRICK, 0, 0, 0, -1)
		2:
			bx(x, y, z, rot, 0, 0, 0, 0.78 * s, 2.2, 0.6 * s, white, 0.55)
			hip(x, y + 2.2, z, rot, 0, 0, 0.9 * s, 0.72 * s, 0.85, tile)
			bx(x, y, z, rot, 0.1 * s, -0.08 * s, 2.2, 0.48 * s, 2.1, 0.4 * s, white, 0.55)
			hip(x, y + 4.3, z, rot, 0.1 * s, -0.08 * s, 0.6 * s, 0.52 * s, 1.2, tile)
			bx(x, y, z, rot, -0.15 * s, 0.301 * s, 0, 0.3, 0.95, 0.04, Color(0.5, 0.3, 0.17), 0, 0, 0, -2)
			if hd:
				bx(x, y, z, rot, -0.15 * s, 0.4 * s, 0, 0.9, 0.06, 0.6, COL_CONC)
		3:
			bx(x, y, z, rot, -0.12 * s, -0.08 * s, 0, 0.52 * s, 2.4, 0.5 * s, COL_CONC, 0, 0, 0, -3)
			bx(x, y, z, rot, -0.12 * s, 0.171 * s, 0.15, 0.46 * s, 2.0, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.24 * s, -0.08 * s, 0, 0.3 * s, 2.4, 0.5 * s, white)
			bx(x, y, z, rot, 0.24 * s, 0.171 * s, 0, 0.26 * s, 1.9, 0.03, COL_WOOD, 0, 0, 0, -2)
			bx(x, y, z, rot, 0.04 * s, 0.02 * s, 2.4, 0.84 * s, 2.2, 0.62 * s, white)
			bx(x, y, z, rot, -0.12 * s, 0.331 * s, 2.6, 0.44 * s, 1.75, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.27 * s, 0.332 * s, 2.5, 0.26 * s, 2.0, 0.04, COL_WOOD, 0, 0, 0, -2)
			bx(x, y, z, rot, 0.04 * s, 0.02 * s, 4.6, 0.86 * s, 0.14, 0.64 * s, white.darkened(0.06))
			if hd:
				bx(x, y, z, rot, 0.24 * s, 0.4 * s, 0, 0.28 * s, 0.04, 0.16 * s, Color(0.78, 0.77, 0.74))
				parked_car(x, y, z, rot, 0.24 * s, 0.44 * s, i)
		4:
			bx(x, y, z, rot, 0.08 * s, -0.02 * s, 0, 0.62 * s, 2.3, 0.56 * s, tint(COL_BRICK, i), 0.4, 0, 0, -1)
			bx(x, y, z, rot, 0.08 * s, -0.06 * s, 2.3, 0.56 * s, 2.0, 0.44 * s, COL_BLACK, 0, 0, 0, -5)
			bx(x, y, z, rot, 0.08 * s, 0.161 * s, 2.45, 0.5 * s, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.08 * s, -0.04 * s, 4.3, 0.74 * s, 0.16, 0.6 * s, Color(0.1, 0.1, 0.11))
			bx(x, y, z, rot, -0.38 * s, 0.14 * s, 2.0, 0.26 * s, 0.08, 0.5 * s, Color(0.1, 0.1, 0.11))
			if hd:
				bx(x, y, z, rot, -0.48 * s, 0.37 * s, 0, 0.08, 2.0, 0.08, Color(0.1, 0.1, 0.11))
				bx(x, y, z, rot, -0.48 * s, -0.08 * s, 0, 0.08, 2.0, 0.08, Color(0.1, 0.1, 0.11))
				parked_car(x, y, z, rot, -0.37 * s, 0.14 * s, i)
				for la in [-0.1, 0.12, 0.32]:
					var lf: float = la
					bx(x, y, z, rot, lf * s, 0.272 * s, 0, 0.12, 0.08, 0.06, Color(1.0, 0.8, 0.5), 0, 1.0)
		5:
			bx(x, y, z, rot, 0.05 * s, 0, 0, 0.7 * s, 2.3, 0.56 * s, white)
			bx(x, y, z, rot, 0.05 * s, 0.281 * s, 0.1, 0.4 * s, 1.9, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, -0.34 * s, -0.04 * s, 0, 0.22 * s, 5.4, 0.36 * s, Color(0.27, 0.24, 0.23), 0, 0, 0, -1)
			bx(x, y, z, rot, 0.12 * s, -0.02 * s, 2.3, 0.44 * s, 1.5, 0.52 * s, COL_BLACK, 0, 0, 0, -5)
			gable(x, y + 3.8, z, rot, 0.12 * s, -0.02 * s, 0.44 * s, 0.52 * s, 1.8, COL_BLACK, COL_BLACK, false, -5.0, -5.0)
			var q := lp(x, z, rot, 0.12 * s, 0.245 * s)
			em(M_BOX, q.x, y + 2.45, q.y, 0.36 * s, 1.3, 0.04, rot, COL_GLASS, 0, 0, 0, -8)
			em(M_ROOF, q.x, y + 3.8, q.y, 0.36 * s, 1.55, 0.04, rot, COL_GLASS, 0, 0, 0, -8)
			if hd:
				bx(x, y, z, rot, -0.05 * s, 0.4 * s, 0, 0.6 * s, 0.1, 0.2 * s, Color(0.55, 0.38, 0.24), 0, 0, 0, -2)
		6:
			bx(x, y, z, rot, -0.08 * s, -0.12 * s, 0, 0.66 * s, 2.4, 0.44 * s, COL_STONE, 0, 0, 0, -7)
			bx(x, y, z, rot, -0.08 * s, 0.101 * s, 0.1, 0.5 * s, 2.0, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.02 * s, -0.06 * s, 2.4, 0.7 * s, 2.0, 0.5 * s, white)
			bx(x, y, z, rot, -0.24 * s, -0.06 * s, 2.4, 0.22 * s, 2.0, 0.52 * s, COL_WOOD, 0, 0, 0, -2)
			bx(x, y, z, rot, 0.1 * s, 0.191 * s, 2.55, 0.42 * s, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.02 * s, 0.0, 4.4, 0.78 * s, 0.25, 0.62 * s, white)
			bx(x, y, z, rot, 0.24 * s, 0.33 * s, 0, 0.42 * s, 0.1, 0.24 * s, Color(0.72, 0.58, 0.42), 0, 0, 0, -2)
			bx(x, y, z, rot, 0.24 * s, 0.33 * s, 0, 0.34 * s, 0.14, 0.17 * s, Color(0.22, 0.72, 0.8), 0, 0, 0.25)
		_:
			bx(x, y, z, rot, 0, -0.06 * s, 0, 0.86 * s, 2.2, 0.46 * s, white, 0.5)
			hip(x, y + 2.2, z, rot, 0, -0.06 * s, 0.98 * s, 0.6 * s, 1.1, tile)
			bx(x, y, z, rot, -0.2 * s, 0.181 * s, 0.05, 0.22 * s, 1.8, 0.03, COL_GLASS, 0, 0, 0, -8)
			bx(x, y, z, rot, 0.22 * s, 0.24 * s, 1.75, 0.24 * s, 0.06, 0.14 * s, COL_WHITE)
			if hd:
				for la in [-0.36, -0.02, 0.36]:
					var lf: float = la
					bx(x, y, z, rot, lf * s, 0.18 * s, 1.5, 0.1, 0.16, 0.08, Color(1.0, 0.8, 0.5), 0, 1.0)
	if hd:
		garden(i, x, y, z, rot, s)
func emit_res(i: int, x: float, y: float, z: float, w: float, l: int, v: int, rot: float, wall: Color, big: bool) -> void:
	var gc := tower_col(v, i)
	var hd: bool = opts["quality"] >= 1
	var vk := (v + int(hsh(i, 21) * 4.0)) % 4
	match l:
		1:
			emit_house(i, x, y, z, w, v, rot, wall)
		2, 3:
			var h := (4.5 + (v % 3)) if l == 2 else (8.0 + (v % 4) * 1.3)
			if vk == 0:
				var bc := tint(COL_BRICK, i)
				bx(x, y, z, rot, 0, 0, 0, w * 0.84, h, w * 0.84, bc, 1.0, 0, 0, -1)
				bx(x, y, z, rot, 0, 0, 0, w * 0.86, 1.1, w * 0.86, Color(0.15, 0.19, 0.23), 0, 0.55)
				var k := 2.5
				while k < h - 0.3:
					bx(x, y, z, rot, 0, 0, k, w * 0.86, 0.16, w * 0.86, COL_WHITE)
					k += 2.5
				bx(x, y, z, rot, 0, 0, h, w * 0.9, 0.3, w * 0.9, COL_WHITE)
				if l == 3 or v % 2 == 0:
					var q := lp(x, z, rot, w * 0.2, -w * 0.15)
					if hd:
						for lg in 4:
							em(M_BOX, q.x + (0.5 if lg % 2 == 0 else -0.5), y + h, q.y + (0.5 if lg < 2 else -0.5), 0.1, 1.2, 0.1, 0.0, Color(0.25, 0.22, 0.2))
					em(M_CYL, q.x, y + h + 1.2, q.y, 1.5, 1.4, 1.5, 0.0, Color(0.48, 0.36, 0.26), 0, 0, 0, -2)
					em(M_CONE, q.x, y + h + 2.6, q.y, 1.6, 0.6, 1.6, 0.0, Color(0.25, 0.22, 0.2))
			elif vk == 1:
				bx(x, y, z, rot, 0, 0, 0, w * 0.76, h, w * 0.76, COL_BLACK, 1.0, 0, 0, -5)
				var k := 0.0
				while k < h + 0.1:
					bx(x, y, z, rot, 0, 0.02 * w, k, w * 0.94, 0.26, w * 0.9, COL_WHITE.darkened(0.04), 0, 0, 0, -3)
					if hd and k > 0.1:
						bx(x, y, z, rot, 0, 0.44 * w, k + 0.26, w * 0.9, 0.22, 0.25, Color(0.3, 0.48, 0.22), 0, 0, 0, 2.02)
					k += 2.5
				if hd:
					for pk in 5:
						bx(x, y, z, rot, (pk - 2) * w * 0.15, -w * 0.1, h + 1.6, 0.1, 0.1, w * 0.5, COL_BLACK)
					bx(x, y, z, rot, -w * 0.3, -w * 0.1, h, 0.12, 1.6, 0.12, COL_BLACK)
					bx(x, y, z, rot, w * 0.3, -w * 0.1, h, 0.12, 1.6, 0.12, COL_BLACK)
			elif vk == 2:
				bx(x, y, z, rot, 0, 0, 0, w * 0.86, 1.8, w * 0.86, COL_STONE, 0, 0, 0, -7)
				bx(x, y, z, rot, 0.12 * w, 0.431 * w, 0.05, w * 0.5, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
				bx(x, y, z, rot, 0, 0, 1.8, w * 0.84, h - 1.8, w * 0.84, tint(Color(0.74, 0.4, 0.24), i), 0, 0, 0, -6)
				bx(x, y, z, rot, 0, 0, h, w * 0.87, 0.25, w * 0.87, COL_STONE)
			else:
				bx(x, y, z, rot, 0, 0, 0, w * 0.82, h, w * 0.82, wall, 1.0)
				bx(x, y, z, rot, 0, 0, 0, w * 0.84, 1.1, w * 0.84, Color(0.15, 0.19, 0.23), 0, 0.55)
				var k := 2.6
				while k < h - 0.5:
					bx(x, y, z, rot, 0, 0, k, w * 0.86, 0.12, w * 0.86, wall.darkened(0.15))
					bx(x, y, z, rot, 0, w * 0.45, k + 0.12, w * 0.5, 0.28, 0.5, wall.lightened(0.1))
					k += 2.5
				bx(x, y, z, rot, 0, 0, h, w * 0.88, 0.25, w * 0.88, wall.darkened(0.2))
				if hd:
					bx(x, y, z, rot, -w * 0.2, w * 0.18, h + 0.25, 0.9, 0.35, 0.5, Color(0.3, 0.55, 0.28), 0, 0, 0, 2.02)
					bx(x, y, z, rot, w * 0.15, -w * 0.1, h + 0.25, 0.8, 0.5, 0.8, Color(0.55, 0.57, 0.6))
		4:
			var kind := v % 4
			if kind == 0:
				var h := 16.0 + (v % 5) * 2.0
				em(M_BOX, x, y, z, w * 0.75, h, w * 0.75, rot, wall, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h, z, w * 0.5, 2.0, w * 0.5, rot, wall.darkened(0.1), 0.8, 0, 0, -7)
				em(M_BOX, x, y, z, w * 0.78, 1.4, w * 0.78, rot, Color(0.14, 0.18, 0.22), 0, 0.55)
				em(M_BOX, x, y + h - 0.3, z, w * 0.8, 0.4, w * 0.8, rot, wall.lightened(0.12))
				em(M_CYL, x, y + h + 2.0, z, 1.2, 1.5, 1.2, 0.0, Color(0.4, 0.4, 0.42))
			elif kind == 1:
				var h := 22.0 + (v % 3) * 3.0
				var sc := tint(Color(0.8, 0.7, 0.54), i)
				em(M_BOX, x, y, z, w * 0.8, h * 0.5, w * 0.8, rot, sc, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h * 0.5, z, w * 0.84, 0.35, w * 0.84, rot, sc.lightened(0.15))
				em(M_BOX, x, y + h * 0.5, z, w * 0.62, h * 0.3, w * 0.62, rot, sc, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h * 0.8, z, w * 0.66, 0.3, w * 0.66, rot, sc.lightened(0.15))
				em(M_BOX, x, y + h * 0.8, z, w * 0.44, h * 0.2, w * 0.44, rot, sc, 1.0, 0, 0, -7)
				em(M_BOX, x, y + h, z, w * 0.3, 1.4, w * 0.3, rot, Color(1.0, 0.85, 0.6), 0, 0.7)
				em(M_CONE, x, y + h + 1.4, z, w * 0.2, h * 0.22, w * 0.2, rot, Color(0.75, 0.75, 0.78), 0, 0, 0, 1.5)
			elif kind == 2:
				var h := 22.0 + (v % 3) * 2.5
				em(M_CYL, x, y, z, w * 0.7, h, w * 0.7, 0.0, gc, 1.3)
				em(M_CYL, x, y + h, z, w * 0.74, 0.4, w * 0.74, 0.0, Color(0.8, 0.82, 0.85))
			else:
				var h := 18.0
				bx(x, y, z, rot, -w * 0.22, 0, 0, w * 0.36, h, w * 0.5, gc, 1.3)
				bx(x, y, z, rot, w * 0.22, 0, 0, w * 0.36, h + 3.0, w * 0.5, gc, 1.3)
				em(M_BOX, x, y + h * 0.6, z, w * 0.2, 1.2, w * 0.3, rot, Color(0.5, 0.6, 0.7), 1.3)
func emit_com(i: int, x: float, y: float, z: float, w: float, l: int, v: int, rot: float, dark: bool, big: bool) -> void:
	var wallc: Color = tint([Color(0.85, 0.85, 0.9), Color(0.9, 0.8, 0.7), Color(0.7, 0.75, 0.85), Color(0.95, 0.9, 0.85)][v % 4], i)
	var gcm := tower_col(v + 2, i)
	if dark:
		wallc = wallc.darkened(0.6)
	var awn: Color = [Color(0.8, 0.2, 0.2), Color(0.2, 0.5, 0.8), Color(0.2, 0.6, 0.3), Color(0.9, 0.6, 0.1)][v % 4]
	var fx := sin(rot) * w * 0.45
	var fz := cos(rot) * w * 0.45
	match l:
		1:
			em(M_BOX, x, y, z, w * 0.85, 2.4, w * 0.85, rot, wallc, 0.7, 0, 0, -1.0 if v % 3 == 0 else 0.0)
			bx(x, y, z, rot, 0, w * 0.426, 0.1, w * 0.7, 1.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			em(M_BOX, x + fx, y + 1.9, z + fz, w * 0.85, 0.12, 0.9, rot, awn)
			if v % 2 == 0:
				for k in 2:
					em(M_CYL, x + fx * 1.25 + (k - 0.5) * 1.2 * cos(rot), y, z + fz * 1.25 - (k - 0.5) * 1.2 * sin(rot), 0.5, 0.6, 0.5, 0.0, Color(0.9, 0.9, 0.9))
		2:
			var bm := -1.0 if v % 2 == 0 else -7.0
			em(M_BOX, x, y, z, w * 0.88, 5.0, w * 0.88, rot, tint(COL_BRICK, i) if v % 2 == 0 else wallc, 1.0, 0, 0, bm)
			bx(x, y, z, rot, 0, w * 0.441, 0.05, w * 0.8, 1.8, 0.03, COL_GLASS, 0, 0, 0, -8)
			em(M_BOX, x + fx, y + 2.0, z + fz, w * 0.88, 0.12, 1.0, rot, awn)
			em(M_BOX, x, y + 5.0, z, w * 0.92, 0.3, w * 0.92, rot, COL_WHITE)
			em(M_BOX, x, y + 5.3, z, w * 0.6, 0.8, w * 0.2, rot, awn, 0, 0.6)
		3:
			var h := 12.0 + (v % 3) * 2.0
			em(M_BOX, x, y, z, w * 0.88, 3.0, w * 0.88, rot, COL_STONE, 0, 0, 0, -7)
			bx(x, y, z, rot, 0, w * 0.441, 0.1, w * 0.78, 2.6, 0.03, COL_GLASS, 0, 0, 0, -8)
			em(M_BOX, x, y + 3.0, z, w * 0.82, h - 3.0, w * 0.82, rot, gcm, 1.4)
			em(M_BOX, x, y + h, z, w * 0.6, 1.0, w * 0.6, rot, Color(0.4, 0.4, 0.45))
		4:
			var h := 28.0 + (v % 4) * 4.0
			if big:
				h += 10.0
			em(M_BOX, x, y, z, w * 0.88, 4.0, w * 0.88, rot, COL_STONE, 0.8, 0, 0, -7)
			em(M_BOX, x, y + 4.0, z, w * 0.75, h * 0.72 - 4.0, w * 0.75, rot, gcm.darkened(0.15), 1.5)
			em(M_BOX, x, y + h * 0.72, z, w * 0.79, 0.4, w * 0.79, rot, Color(0.75, 0.77, 0.8))
			em(M_BOX, x, y + h * 0.72, z, w * 0.58, h * 0.28, w * 0.58, rot, gcm.darkened(0.1), 1.5)
			if v % 2 == 0:
				em(M_BOX, x, y + h, z, w * 0.4, 2.5, w * 0.4, rot, Color(0.8, 0.82, 0.85), 0, 0.5)
				em(M_CONE, x, y + h + 2.5, z, w * 0.3, 6.0, w * 0.3, rot, Color(0.78, 0.8, 0.84), 0, 0, 0, 1.5)
				em(M_BOX, x, y + h + 8.0, z, 0.2, 4.0, 0.2, 0.0, Color(0.9, 0.2, 0.2), 0, 0, 1.0)
			else:
				em(M_BOX, x, y + h, z, w * 0.5, 3.0, w * 0.5, rot, Color(0.35, 0.45, 0.55), 1.2)
				em(M_BOX, x, y + h + 3.0, z, 0.25, 5.0, 0.25, 0.0, Color(0.9, 0.2, 0.2), 0, 0, 1.0)
func clear_preview() -> void:
	preview_node.multimesh.instance_count = 0
	set_cost_hint("")
func show_preview() -> void:
	begin_buf()
	var cost := 0.0
	var cells: Array = []
	if tool["k"] == "def":
		var d: Dictionary = DEF[tool["id"]]
		cells = def_cells(drag_a, d["sz"])
		var ok := can_place_def(drag_a, tool["id"]) == ""
		for c in cells:
			var p := cell_pos(c)
			em(M_BOX, p.x, maxf(p.y, 0.0) + 0.2, p.z, CELL * 0.95, 0.6, CELL * 0.95, 0.0, Color(0.2, 0.9, 0.3, 0.45) if ok else Color(0.95, 0.2, 0.15, 0.45))
		cost = d["cost"]
	else:
		cells = drag_cells()
		for c in cells:
			var cc := cell_cost(c)
			var p := cell_pos(c)
			em(M_BOX, p.x, maxf(p.y, 0.0) + 0.3, p.z, CELL * 0.95, 0.4, CELL * 0.95, 0.0, Color(0.2, 0.9, 0.3, 0.45) if cc >= 0.0 else Color(0.95, 0.2, 0.15, 0.4))
			if cc > 0.0:
				cost += cc
	var mm := preview_node.multimesh
	mm.instance_count = _counts[M_BOX]
	if _counts[M_BOX] > 0:
		mm.buffer = _bufs[M_BOX].slice(0, _counts[M_BOX] * 20)
	set_cost_hint(("Costo: " + fmt_money(cost)) if cost > 0 else "")
func flush_mm(mm: MultiMesh, count: int, buf: PackedFloat32Array) -> void:
	if count > mm.instance_count:
		var cap := 256
		while cap < count * 3 / 2:
			cap *= 2
		mm.instance_count = cap
	if count > 0:
		var pb := buf.slice(0, count * 20)
		pb.resize(mm.instance_count * 20)
		mm.buffer = pb
	mm.visible_instance_count = count
# ================================================================ src/camera.gd
# Cámara, intro y gestos táctiles, mouse y teclado.
var intro_full: bool = false
var gesture: String = ""
var press_pos := Vector2.ZERO
var press_time: float = 0.0
var hover_cell: int = -1
var multi_d0: float = 0.0
var multi_a0: float = 0.0
var multi_mid0 := Vector2.ZERO
var mouse_btn: int = 0
var last_mouse := Vector2.ZERO
const DRAG_TOOLS := ["road", "zone", "dezone", "demolish", "cable", "pipe", "bike", "tram", "levee", "trees"]
func setup_camera() -> void:
	cam = Camera3D.new()
	cam.far = 3000.0
	cam.fov = 55.0
	add_child(cam)
	cam.current = true
func update_camera(delta: float) -> void:
	if intro_t >= 0.0:
		update_intro(delta)
		return
	if cam_follow != null:
		var fp = cam_follow.call()
		if fp == null:
			cam_follow = null
		else:
			cam_goal = fp
	var half := N * CELL * 0.55
	cam_goal.x = clampf(cam_goal.x, -half, half)
	cam_goal.z = clampf(cam_goal.z, -half, half)
	cam_dist_goal = clampf(cam_dist_goal, 8.0 if drive != null else 14.0, 480.0)
	cam_pitch = clampf(cam_pitch, 0.22, 1.32)
	var k := 1.0 - exp(-delta * 12.0)
	cam_target = cam_target.lerp(cam_goal, k)
	cam_dist = lerpf(cam_dist, cam_dist_goal, k)
	place_camera()
func place_camera() -> void:
	var off := Vector3(sin(cam_yaw) * cos(cam_pitch), sin(cam_pitch), cos(cam_yaw) * cos(cam_pitch)) * cam_dist
	cam.position = cam_target + off
	cam.look_at(cam_target, Vector3.UP)
	if sun and not OS.has_feature("android"):
		sun.directional_shadow_max_distance = clampf(cam_dist * 2.2, 80.0, 420.0)
func start_intro(full: bool) -> void:
	intro_full = full
	intro_t = 0.0
func update_intro(delta: float) -> void:
	intro_t += delta
	var dur := 9.0 if intro_full else 3.5
	var t := clampf(intro_t / dur, 0.0, 1.0)
	var e := t * t * (3.0 - 2.0 * t)
	var a := cam_yaw + (1.0 - e) * (2.4 if intro_full else 0.8)
	var d := lerpf(420.0 if intro_full else 300.0, cam_dist_goal, e)
	var pt := lerpf(1.1, cam_pitch, e)
	var off := Vector3(sin(a) * cos(pt), sin(pt), cos(a) * cos(pt)) * d
	cam.position = cam_goal + off
	cam.look_at(cam_goal, Vector3.UP)
	cam_target = cam_goal
	cam_dist = cam_dist_goal
	if t >= 1.0:
		intro_t = -1.0
		if not card_queue.is_empty() and not card_panel.visible:
			next_card()
func skip_intro() -> void:
	if intro_t >= 0.0:
		intro_t = 999.0
func screen_ground(pos: Vector2) -> Vector3:
	var o := cam.project_ray_origin(pos)
	var d := cam.project_ray_normal(pos)
	if absf(d.y) < 0.0001:
		return Vector3(INF, 0, INF)
	var y := 0.0
	var p := Vector3.ZERO
	for it in 2:
		var t := (y - o.y) / d.y
		if t < 0:
			return Vector3(INF, 0, INF)
		p = o + d * t
		var c := world_to_cell(p)
		if inb(c.x, c.y):
			y = maxf(hgt[idx(c.x, c.y)], 0.0)
	return p
func screen_cell(pos: Vector2) -> int:
	var p := screen_ground(pos)
	if p.x == INF:
		return -1
	var c := world_to_cell(p)
	if not inb(c.x, c.y):
		return -1
	return idx(c.x, c.y)
var ui_touch := {}
func on_touch(index: int, pos: Vector2, pressed: bool) -> void:
	if pressed:
		if over_ui(pos):
			ui_touch[index] = true
			return
		ui_touch.erase(index)
	elif ui_touch.has(index):
		ui_touch.erase(index)
		return
	elif not touches.has(index):
		return
	if pressed:
		touches[index] = pos
		if touches.size() == 1:
			gesture = ""
			press_pos = pos
			press_time = Time.get_ticks_msec() / 1000.0
			drag_a = screen_cell(pos)
			drag_b = drag_a
		elif touches.size() == 2:
			if gesture == "draw":
				clear_preview()
			gesture = "multi"
			var ps: Array = touches.values()
			multi_d0 = (ps[0] - ps[1]).length()
			multi_a0 = (ps[1] - ps[0]).angle()
			multi_mid0 = (ps[0] + ps[1]) * 0.5
	else:
		touches.erase(index)
		if touches.is_empty():
			if gesture == "":
				tap_at(pos)
			elif gesture == "draw":
				commit_drag()
			gesture = ""
		elif gesture == "multi":
			gesture = "done"
func on_drag(index: int, pos: Vector2) -> void:
	if ui_touch.has(index) or not touches.has(index):
		return
	var prev: Vector2 = touches[index]
	touches[index] = pos
	cam_moving_t = 0.4
	if touches.size() == 1:
		if gesture == "":
			if (pos - press_pos).length() > 14.0:
				if tool["k"] in DRAG_TOOLS:
					gesture = "draw"
				else:
					gesture = "pan"
		if gesture == "draw":
			var c := screen_cell(pos)
			if c >= 0 and c != drag_b:
				drag_b = c
				show_preview()
		elif gesture == "pan":
			pan_screen(prev, pos)
	elif touches.size() == 2 and gesture == "multi":
		var ps: Array = touches.values()
		var d: float = (ps[0] - ps[1]).length()
		var a: float = (ps[1] - ps[0]).angle()
		var mid: Vector2 = (ps[0] + ps[1]) * 0.5
		if multi_d0 > 10.0:
			cam_dist_goal *= multi_d0 / maxf(d, 1.0)
			cam_dist = cam_dist_goal
		crumb("dos dedos (zoom %d)" % int(cam_dist_goal))
		var da := wrapf(a - multi_a0, -PI, PI)
		cam_yaw += da
		var dm := mid - multi_mid0
		if absf(dm.y) > absf(dm.x) * 1.5 and absf(d - multi_d0) < 12.0:
			cam_pitch += dm.y * 0.004
		else:
			pan_screen(multi_mid0, mid)
		multi_d0 = d
		multi_a0 = a
		multi_mid0 = mid
func pan_screen(from: Vector2, to: Vector2) -> void:
	var a := screen_ground(from)
	var b := screen_ground(to)
	if a.x == INF or b.x == INF:
		return
	var d := a - b
	d.y = 0
	cam_goal += d
	cam_target += d
	cam_follow = null
func on_mouse_button(ev: InputEventMouseButton) -> void:
	if ev.button_index == MOUSE_BUTTON_WHEEL_UP and ev.pressed:
		if ev.shift_pressed:
			cam_pitch += 0.06
		else:
			cam_dist_goal *= 0.88
		return
	if ev.button_index == MOUSE_BUTTON_WHEEL_DOWN and ev.pressed:
		if ev.shift_pressed:
			cam_pitch -= 0.06
		else:
			cam_dist_goal *= 1.13
		return
	if ev.pressed:
		mouse_btn = ev.button_index
		last_mouse = ev.position
		if ev.button_index == MOUSE_BUTTON_LEFT:
			on_touch(0, ev.position, true)
	else:
		if ev.button_index == MOUSE_BUTTON_LEFT and touches.has(0):
			on_touch(0, ev.position, false)
		mouse_btn = 0
func on_mouse_motion(ev: InputEventMouseMotion) -> void:
	if mouse_btn == MOUSE_BUTTON_LEFT:
		on_drag(0, ev.position)
	elif mouse_btn == MOUSE_BUTTON_RIGHT:
		pan_screen(last_mouse, ev.position)
	elif mouse_btn == MOUSE_BUTTON_MIDDLE:
		cam_yaw -= (ev.position.x - last_mouse.x) * 0.006
		cam_pitch += (ev.position.y - last_mouse.y) * 0.005
	else:
		var c := screen_cell(ev.position)
		if c != hover_cell:
			hover_cell = c
			if tool["k"] == "def":
				drag_a = c
				drag_b = c
				show_preview()
	last_mouse = ev.position
func on_key(ev: InputEventKey) -> void:
	var step := cam_dist * 0.08
	var fw := Vector3(-sin(cam_yaw), 0, -cos(cam_yaw))
	var rt := Vector3(cos(cam_yaw), 0, -sin(cam_yaw))
	match ev.keycode:
		KEY_W, KEY_UP:
			cam_goal += fw * step
		KEY_S, KEY_DOWN:
			cam_goal -= fw * step
		KEY_A, KEY_LEFT:
			cam_goal -= rt * step
		KEY_D, KEY_RIGHT:
			cam_goal += rt * step
		KEY_Q:
			cam_yaw += 0.15
		KEY_E:
			cam_yaw -= 0.15
		KEY_R:
			cam_pitch += 0.08
		KEY_F:
			cam_pitch -= 0.08
		KEY_EQUAL, KEY_KP_ADD:
			cam_dist_goal *= 0.85
		KEY_MINUS, KEY_KP_SUBTRACT:
			cam_dist_goal *= 1.15
		KEY_SPACE:
			set_speed(0 if speed > 0 else 1)
		KEY_1:
			set_speed(1)
		KEY_2:
			set_speed(2)
		KEY_3:
			set_speed(3)
		KEY_ESCAPE:
			set_tool({"k": "look"})
func tap_at(pos: Vector2) -> void:
	var c := screen_cell(pos)
	var k: String = tool["k"]
	if k in DRAG_TOOLS:
		if c >= 0:
			apply_cells([c])
		return
	match k:
		"look":
			var pk := pick_ped(pos)
			if not pk.is_empty():
				follow_citizen(pk)
			elif c >= 0:
				show_info(c)
		"def":
			if hover_cell != c or not preview_node.multimesh.instance_count:
				pass
			place_def(c, tool["id"])
			clear_preview()
		"round":
			toggle_round(c)
		"stop":
			place_stop(c, tool["kind"])
		"line":
			pick_line_stop(c)
		"buy":
			ask_buy_region(c)
		"district":
			if c >= 0:
				open_district(region_of(c))
		"follow":
			pass
# ================================================================ src/agents.gd
# Autos, gente, transporte, barcos, aviones, cine, partículas y choques.
var glow_node: MultiMeshInstance3D
var glow_buf := PackedFloat32Array()
var glow_n: int = 0
var dyn_close: bool = false
var rails_node: MultiMeshInstance3D
var tl_cells: Array = []
var road_list := PackedInt32Array()
var anim_time: float = 0.0
var plane_t: float = 0.0
var ship_t: float = 0.0
var garbage_t: float = 0.0
var flag_days: int = 0
var dyn_skip: int = 0
func setup_agents() -> void:
	dyn_nodes.clear()
	for m in NMESH:
		var node := new_mm_node(meshes[m], null)
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		dyn_nodes.append(node)
	rails_node = new_mm_node(meshes[M_BOX], null)
	var gm := ShaderMaterial.new()
	var gsh := Shader.new()
	gsh.code = SHADER_GLOW.code
	gm.shader = gsh
	var gq := PlaneMesh.new()
	gq.size = Vector2(1, 1)
	glow_node = new_mm_node(gq, gm)
	glow_buf.resize(4000)
	dyn_nodes.append(glow_node)
func gl(kind: float, x: float, y: float, z: float, sx: float, sz: float, rot: float, col: Color, sz2: float = 0.0) -> void:
	var c := cos(rot)
	var s := sin(rot)
	var o := glow_n * 20
	if o + 20 > glow_buf.size():
		glow_buf.resize(glow_buf.size() * 2)
	glow_buf[o] = c * sx
	glow_buf[o + 1] = 0.0
	glow_buf[o + 2] = s * sz
	glow_buf[o + 3] = x
	glow_buf[o + 4] = 0.0
	glow_buf[o + 5] = 1.0
	glow_buf[o + 6] = 0.0
	glow_buf[o + 7] = y
	glow_buf[o + 8] = -s * sx
	glow_buf[o + 9] = 0.0
	glow_buf[o + 10] = c * sz
	glow_buf[o + 11] = z
	glow_buf[o + 12] = col.r
	glow_buf[o + 13] = col.g
	glow_buf[o + 14] = col.b
	glow_buf[o + 15] = col.a
	glow_buf[o + 16] = kind
	glow_buf[o + 17] = sz2
	glow_buf[o + 18] = 0.0
	glow_buf[o + 19] = 0.0
	glow_n += 1
func veh_lights(p: Vector3, r: float, ln: float, hw: float, hy: float, nf: float, lit: bool, wheels: bool, beam: float) -> void:
	var sr := sin(r)
	var cr := cos(r)
	if wheels:
		for sg in [-1.0, 1.0]:
			for fz in [-0.32, 0.32]:
				em(M_SPH, p.x + cr * sg * hw + sr * fz * ln, p.y, p.z - sr * sg * hw + cr * fz * ln, 0.2, 0.42, 0.42, r, Color(0.06, 0.06, 0.07))
	if wheels or lit:
		var hl := 0.5 + nf * 3.0
		var tl := 0.5 + nf * 1.8
		for sg in [-0.7, 0.7]:
			var rx: float = cr * sg * hw
			var rz: float = -sr * sg * hw
			em(M_BOX, p.x + rx + sr * ln * 0.5, p.y + hy, p.z + rz + cr * ln * 0.5, 0.2, 0.12, 0.06, r, Color(1.0, 0.95, 0.75), 0, 0, hl)
			em(M_BOX, p.x + rx - sr * ln * 0.5, p.y + hy, p.z + rz - cr * ln * 0.5, 0.2, 0.12, 0.06, r, Color(0.9, 0.08, 0.06), 0, 0, tl)
	if lit:
		var halo_k := 1.5 if weather == "Lluvia" or weather == "Tormenta" else 1.0
		var k := ln * 0.5 + beam * 0.5
		gl(0.0, p.x + sr * k, p.y + 0.32, p.z + cr * k, 2.6 + hw, beam, r, Color(1.0, 0.92, 0.7, 0.55))
		gl(1.0, p.x - sr * ln * 0.55, p.y + 0.32, p.z - cr * ln * 0.55, 1.5, 1.5, 0.0, Color(1.0, 0.1, 0.05, 0.3))
		if weather == "Lluvia" or weather == "Tormenta":
			gl(0.0, p.x - sr * (ln * 0.5 + 2.0), p.y + 0.33, p.z - cr * (ln * 0.5 + 2.0), 1.4, 4.0, r + PI, Color(1.0, 0.1, 0.05, 0.55))
			gl(0.0, p.x + sr * (ln * 0.5 + 5.5), p.y + 0.33, p.z + cr * (ln * 0.5 + 5.5), 1.0, 7.0, r, Color(0.9, 0.95, 1.0, 0.35))
		for sg in [-0.7, 0.7]:
			var hx: float = p.x + cr * sg * hw + sr * ln * 0.52
			var hz: float = p.z - sr * sg * hw + cr * ln * 0.52
			gl(2.0, hx, p.y + hy, hz, 1.0, 1.0, 0.0, Color(1.0, 0.93, 0.75, 0.9), 0.95 * halo_k)
			var tx: float = p.x + cr * sg * hw - sr * ln * 0.52
			var tz: float = p.z - sr * sg * hw - cr * ln * 0.52
			gl(2.0, tx, p.y + hy, tz, 1.0, 1.0, 0.0, Color(1.0, 0.1, 0.05, 0.8), 0.5 * halo_k)
func max_cars() -> int:
	return [35, 75, 120][opts["quality"]]
func max_peds() -> int:
	return [40, 90, 150][opts["quality"]]
func agents_process(delta: float) -> void:
	anim_time += delta
	var m := minf(speed_mult(), 2.0)
	if speed == 0:
		m = 0.0
	var dt := delta * m
	if sim_dirty or road_list.is_empty():
		rebuild_road_list()
	for c in anim_cells.keys():
		anim_cells[c] = anim_cells[c] - dt
		if anim_cells[c] <= 0.0:
			anim_cells.erase(c)
			mark_dirty(c)
	spawn_agents(dt)
	move_cars(dt)
	move_peds(dt)
	move_svc(dt)
	move_lines(dt)
	move_boats(dt)
	move_stars(dt)
	move_parts(delta)
	if drive != null:
		move_drive(delta)
	dyn_skip += 1
	if opts["quality"] == 0 and dyn_skip % 2 == 1:
		return
	draw_dynamic()
func rebuild_road_list() -> void:
	road_list.clear()
	tl_cells.clear()
	for i in N * N:
		if road[i] > 0:
			road_list.append(i)
			if road[i] >= 2 and not (wire[i] & W_ROUND):
				var nb := road_n(i)
				if int(nb[0]) + int(nb[1]) + int(nb[2]) + int(nb[3]) >= 3:
					tl_cells.append(i)
func spawn_agents(dt: float) -> void:
	if dt <= 0.0:
		return
	var want_c := mini(max_cars(), pop / 10)
	if cars.size() < want_c and not car_paths.is_empty() and randf() < 0.5:
		var p: Array = car_paths[randi() % car_paths.size()]
		if randf() < 0.5:
			p = p.duplicate()
			p.reverse()
		var ckind := randi() % 3
		var car_col := car_color(randi())
		var rr := randf()
		if rr < 0.12:
			ckind = 3
			car_col = Color(0.95, 0.75, 0.08)
		elif rr < 0.22:
			ckind = 4
		elif rr < 0.34:
			ckind = 5
		var car_roof := car_col
		if ckind != 3 and randf() < 0.3:
			car_roof = Color(0.93, 0.93, 0.95) if randf() < 0.5 else Color(0.08, 0.08, 0.1)
		var cd := {"p": p, "k": 0.0, "spd": randf_range(0.9, 1.5), "col": car_col, "kind": ckind, "roof": car_roof}
		if ckind == 5:
			cd["spd"] = randf_range(1.2, 1.7)
			cd["deli"] = randf() < 0.55
			cd["box"] = [Color(0.95, 0.35, 0.1), Color(0.95, 0.8, 0.1), Color(0.85, 0.1, 0.15), Color(0.1, 0.65, 0.4)][randi() % 4]
			cd["look"] = rand_look()
			cd["col"] = Color(0.1, 0.1, 0.12) if randf() < 0.5 else car_col
		cars.append(cd)
	var want_p := mini(max_peds(), pop / 5 + 6 if pop > 0 else 0)
	if peds.size() < want_p and road_list.size() > 4:
		var c: int = road_list[randi() % road_list.size()]
		if road[c] >= 2:
			var kind := 0
			var r := randf()
			if r < 0.15:
				kind = 1
			elif r < 0.25:
				kind = 2
			elif r < 0.45 and wire[c] & W_BIKE or r < 0.33:
				kind = 3
			peds.append(new_ped(c, kind))
	garbage_t += dt
	if garbage_t > 6.0:
		garbage_t = 0.0
		if garb_cap > 0 and not zone_list.is_empty() and svc.size() < 8:
			dispatch_from("garbage", -1, zone_list[randi() % zone_list.size()])
	plane_t += dt
	if plane_t > 14.0:
		plane_t = 0.0
		for a in anchors:
			if bld[a] == 0:
				continue
			if bld[a] == 56 and def_active(a):
				var p0 := cell_pos(a) + Vector3(CELL * 1.5, 0.5, CELL * 1.6)
				planes.append({"p": p0, "v": Vector3(cos(cam_yaw * 0.0 + randf()), 0, sin(randf())).normalized() * 18.0, "t": 0.0})
				break
	ship_t += dt
	if ship_t > 10.0:
		ship_t = 0.0
		for a in anchors:
			if bld[a] == 0:
				continue
			if bld[a] == 55 and def_active(a) and boats.size() < 6:
				var p1 := cell_pos(a)
				var dir := water_dir(a)
				if dir != Vector3.ZERO:
					boats.append({"p": Vector3(p1.x, WATER_Y, p1.z) + dir * CELL * 2.0, "v": dir * 3.5, "kind": 0, "t": 0.0})
				break
		if boats.size() < 4 and (map_kind <= 3) and randf() < 0.6:
			for tries in 20:
				var i := randi() % (N * N)
				if terr[i] == T_WATER and wdist[i] == 0.0:
					var pp := cell_pos(i)
					boats.append({"p": Vector3(pp.x, WATER_Y, pp.z), "v": Vector3(cos(randf() * TAU), 0, sin(randf() * TAU)) * 1.5, "kind": 1, "t": 0.0})
					break
func water_dir(a: int) -> Vector3:
	var best := Vector3.ZERO
	for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var x: int = cx(a) + o.x * 3
		var z: int = cz(a) + o.y * 3
		if inb(x, z) and terr[idx(x, z)] == T_WATER:
			best = Vector3(o.x, 0, o.y)
	return best
func path_pos(p: Array, k: float, lane: float) -> Array:
	var n := p.size()
	var i0 := clampi(int(k), 0, n - 1)
	var i1 := mini(i0 + 1, n - 1)
	var a := cell_pos(p[i0])
	var b := cell_pos(p[i1])
	if terr[p[i0]] == T_WATER:
		a.y = 0.6
	if terr[p[i1]] == T_WATER:
		b.y = 0.6
	var f := k - i0
	var pos := a.lerp(b, f)
	var d := b - a
	if d.length() < 0.01:
		d = Vector3(1, 0, 0)
	d = d.normalized()
	var side := Vector3(-d.z, 0, d.x)
	pos += side * lane
	return [pos, atan2(d.x, d.z)]
func curve_at(pm: Vector3, p0: Vector3, pn: Vector3, f: float) -> Array:
	var m0 := (pm + p0) * 0.5
	var m1 := (p0 + pn) * 0.5
	var u := 1.0 - f
	var pos := m0 * (u * u) + p0 * (2.0 * u * f) + m1 * (f * f)
	var tg := (p0 - m0) * (2.0 * u) + (m1 - p0) * (2.0 * f)
	return [pos, tg]
func cell_y(i: int) -> Vector3:
	var v := cell_pos(i)
	if terr[i] == T_WATER:
		v.y = 0.6
	return v
func path_pos_s(p: Array, k: float, lane: float) -> Array:
	var n := p.size()
	var t := k + 0.5
	var si := clampi(int(t), 0, n - 1)
	var f := clampf(t - si, 0.0, 1.0)
	var c := curve_at(cell_y(p[maxi(si - 1, 0)]), cell_y(p[si]), cell_y(p[mini(si + 1, n - 1)]), f)
	var tg: Vector3 = c[1]
	tg.y = 0.0
	if tg.length() < 0.001:
		tg = Vector3(1, 0, 0)
	tg = tg.normalized()
	var pos: Vector3 = c[0] + Vector3(-tg.z, 0, tg.x) * lane
	return [pos, atan2(tg.x, tg.z)]
func move_cars(dt: float) -> void:
	var lanes := {}
	for c in cars:
		var p: Array = c["p"]
		var i: int = clampi(int(c["k"]), 0, p.size() - 1)
		var j: int = mini(i + 1, p.size() - 1)
		var key: int = int(p[i]) * 65536 + int(p[j])
		c["_f"] = c["k"] - i
		if lanes.has(key):
			lanes[key].append(c)
		else:
			lanes[key] = [c]
	var keep: Array = []
	for c in cars:
		var p: Array = c["p"]
		var i: int = clampi(int(c["k"]), 0, p.size() - 1)
		var cr: float = c.get("crash", 0.0)
		if cr > 0.0:
			c["crash"] = cr - dt
			keep.append(c)
			continue
		var j: int = mini(i + 1, p.size() - 1)
		var cong := tload[p[i]] / road_cap(p[i])
		var want: float = dt * c["spd"] / (1.0 + cong * 1.5)
		var f: float = c["_f"]
		var gap := 9.0
		for o in lanes[int(p[i]) * 65536 + int(p[j])]:
			if o != c:
				var d: float = o["_f"] - f
				if d > 0.0 and d < gap:
					gap = d
		if gap > 1.0 and i + 2 < p.size():
			var key2: int = int(p[i + 1]) * 65536 + int(p[i + 2])
			if lanes.has(key2):
				for o in lanes[key2]:
					var d2: float = 1.0 - f + o["_f"]
					if d2 < gap:
						gap = d2
		var mg := 0.42 if c["kind"] == 5 else 0.62
		c["k"] = c["k"] + minf(want, maxf(gap - mg, 0.0))
		if c["k"] < p.size() - 1:
			keep.append(c)
	cars = keep
	check_crash(dt)
func move_peds(dt: float) -> void:
	var keep: Array = []
	for pd in peds:
		var spd := 0.45 if pd["kind"] != 3 else 1.6
		if pd.get("panic", 0.0) > 0.0:
			spd = 1.5
		pd["t"] = pd["t"] + dt * spd
		if pd["t"] >= 1.0:
			pd["t"] = 0.0
			pd["c"] = pd["n"]
			var c: int = pd["c"]
			if road[c] == 0:
				continue
			var opts2: Array = []
			for o in [1, -1, N, -N]:
				var j: int = c + o
				if j >= 0 and j < N * N and road[j] >= 2 and terr[j] != T_WATER:
					if (o == 1 or o == -1) and cz(j) != cz(c):
						continue
					opts2.append(j)
			if opts2.is_empty():
				continue
			pd["n"] = opts2[randi() % opts2.size()]
			if randf() < 0.01 and pd != follow_ped:
				continue
		keep.append(pd)
	peds = keep
func dispatch_from(kind: String, def_id: int, target: int) -> void:
	var best := -1
	var bd := 1e9
	for a in anchors:
		if bld[a] == 0:
			continue
		var ok := false
		if def_id >= 0:
			ok = bld[a] == def_id or (kind == "ambulance" and bld[a] == 23)
		else:
			ok = DEF[bld[a]].has("gb")
		if ok and def_active(a):
			var d := Vector2(cx(a) - cx(target), cz(a) - cz(target)).length()
			if d < bd:
				bd = d
				best = a
	if best < 0:
		return
	var path := road_path(best, target, false)
	if path.size() < 2:
		return
	svc.append({"p": path, "k": 0.0, "kind": kind, "back": false})
	if kind != "garbage" and cam_dist < 160.0 and Vector2(cam_target.x - cell_pos(target).x, cam_target.z - cell_pos(target).z).length() < 120.0:
		sfx("siren")
func move_svc(dt: float) -> void:
	var keep: Array = []
	for v in svc:
		v["k"] = v["k"] + dt * 3.4
		var p: Array = v["p"]
		if v["k"] >= p.size() - 1:
			if v["back"]:
				continue
			v["back"] = true
			p.reverse()
			v["k"] = 0.0
			if v["kind"] == "fire":
				var t: int = p[0]
				for dz in range(-2, 3):
					for dx in range(-2, 3):
						var x := cx(t) + dx
						var z := cz(t) + dz
						if inb(x, z) and burn[idx(x, z)] > 0.0 and randf() < 0.6:
							burn[idx(x, z)] = 0.0
							mark_dirty(idx(x, z))
			if v["kind"] == "garbage":
				var t2: int = p[0]
				for dz in range(-3, 4):
					for dx in range(-3, 4):
						var x2 := cx(t2) + dx
						var z2 := cz(t2) + dz
						if inb(x2, z2) and garbp[idx(x2, z2)] > 0.0:
							garbp[idx(x2, z2)] = maxf(0.0, garbp[idx(x2, z2)] - 1.0)
							mark_dirty(idx(x2, z2))
		keep.append(v)
	svc = keep
func rebuild_rails() -> void:
	begin_buf()
	for ln in lines:
		if ln["kind"] != "train":
			continue
		var pts: Array = ln["pts"]
		for k in pts.size():
			var a: Vector3 = pts[k]
			var b: Vector3 = pts[(k + 1) % pts.size()]
			var mid := (a + b) * 0.5
			var d := b - a
			var rot := atan2(d.x, d.z)
			em(M_BOX, mid.x, mid.y - 0.3, mid.z, 2.2, 0.4, d.length() + 0.1, rot, Color(0.45, 0.45, 0.47))
			if k % 3 == 0:
				var gy := 0.0
				var c := world_to_cell(a)
				if inb(c.x, c.y):
					gy = maxf(hgt[idx(c.x, c.y)], WATER_Y)
				em(M_BOX, a.x, gy, a.z, 0.7, a.y - gy - 0.3, 0.7, 0.0, Color(0.6, 0.6, 0.62))
	var mm := rails_node.multimesh
	mm.instance_count = _counts[M_BOX]
	if _counts[M_BOX] > 0:
		mm.buffer = _bufs[M_BOX].slice(0, _counts[M_BOX] * 20)
func move_lines(dt: float) -> void:
	for ln in lines:
		var pts: Array = ln["pts"]
		if pts.size() < 2:
			continue
		if ln.get("dwell", 0.0) > 0.0:
			ln["dwell"] = ln["dwell"] - dt
			continue
		var spd: float = {"bus": 1.4, "tram": 1.3, "metro": 3.0, "train": 2.8, "ferry": 1.0}[ln["kind"]] * budget[5] / 100.0
		var old: float = ln["t"]
		var nt: float = fmod(old + dt * spd, float(pts.size()))
		for sk in ln.get("stopk", []):
			if old < sk and nt >= sk:
				ln["dwell"] = 1.2
		ln["t"] = nt
func move_boats(dt: float) -> void:
	var keep: Array = []
	for b in boats:
		b["p"] = b["p"] + b["v"] * dt
		b["t"] = b["t"] + dt
		var c := world_to_cell(b["p"])
		var half := N * CELL * 0.5
		if absf(b["p"].x) > half * 2.0 or absf(b["p"].z) > half * 2.0 or b["t"] > 120.0:
			continue
		if inb(c.x, c.y) and terr[idx(c.x, c.y)] != T_WATER:
			if b["kind"] == 1:
				b["v"] = -b["v"].rotated(Vector3.UP, randf_range(-0.8, 0.8))
				b["p"] = b["p"] + b["v"] * dt * 2.0
			else:
				continue
		keep.append(b)
	boats = keep
	var kp: Array = []
	for pl in planes:
		pl["t"] = pl["t"] + dt
		pl["p"] = pl["p"] + pl["v"] * dt + Vector3(0, minf(pl["t"] * 2.0, 8.0) * dt, 0)
		if pl["t"] < 40.0:
			kp.append(pl)
	planes = kp
func emit_flames(pf: Vector3, i: int) -> void:
	for k in 4:
		var ph := hsh(i, k) * TAU
		var ox := (hsh(i, k + 10) - 0.5) * 2.6
		var oz := (hsh(i, k + 20) - 0.5) * 2.6
		var h := 2.4 + 1.8 * hsh(i, k + 30)
		var fl := 0.78 + 0.22 * sin(anim_time * 7.0 + ph) * sin(anim_time * 3.1 + ph * 1.7) + 0.12 * sin(anim_time * 13.0 + ph)
		for j in 3:
			var f := float(j) / 3.0
			var swx := sin(anim_time * 2.3 + ph + f * 2.0) * 0.45 * f + wind.x * f * 0.7
			var swz := cos(anim_time * 1.9 + ph + f * 2.0) * 0.45 * f + wind.y * f * 0.7
			var sc := (1.0 - f * 0.5) * 1.25
			em(M_SPH, pf.x + ox + swx, pf.y + 0.8 + f * h * fl, pf.z + oz + swz, sc, sc * 1.7 * fl, sc, 0.0, Color(1.0, 0.22 + f * 0.55, 0.04 + f * 0.12), 0, 0, 1.8 + f)
func move_parts(dt: float) -> void:
	var keep: Array = []
	for p in parts:
		p["t"] = p["t"] - dt
		if p["t"] <= 0.0:
			continue
		p["v"] = p["v"] + Vector3(0, p.get("g", -6.0), 0) * dt
		if p.has("fade"):
			p["s"] = maxf(p["s"] * (1.0 - dt * 1.2), 0.02)
		p["p"] = p["p"] + p["v"] * dt
		keep.append(p)
	parts = keep
	if randf() < 0.6:
		for k in 3:
			var i := randi() % (N * N)
			if burn[i] > 0.0:
				parts.append({"p": cell_pos(i) + Vector3(randf_range(-1, 1), 3, randf_range(-1, 1)), "v": Vector3(wind.x, 2.5, wind.y), "t": 3.0, "g": 0.3, "col": Color(0.3, 0.3, 0.3), "s": 1.5})
				parts.append({"p": cell_pos(i) + Vector3(randf_range(-1, 1), 2, randf_range(-1, 1)), "v": Vector3(wind.x + randf_range(-0.8, 0.8), 3.5, wind.y + randf_range(-0.8, 0.8)), "t": 1.3, "g": 0.4, "col": Color(1.0, 0.6, 0.15), "s": 0.22, "glow": 3.0, "fade": true})
	if is_sunday() and hour > 11.0 and hour < 15.0 and randf() < 0.4:
		for a in anchors:
			if bld[a] == 0:
				continue
			if bld[a] == 33 and randf() < 0.3:
				parts.append({"p": cell_pos(a) + Vector3(0, 3, 0), "v": Vector3(wind.x * 0.5, 1.5, wind.y * 0.5), "t": 3.0, "g": 0.1, "col": Color(0.75, 0.75, 0.75), "s": 1.0})
func confetti(cols: Array) -> void:
	for k in 140:
		var p := cam_target + Vector3(randf_range(-60, 60), randf_range(20, 45), randf_range(-60, 60))
		parts.append({"p": p, "v": Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)), "t": 6.0, "g": -1.5, "col": cols[k % cols.size()], "s": 0.5, "glow": 0.3})
	flag_days = 3
func fireworks(at: Vector3, n: int) -> void:
	for b in maxi(1, n / 12):
		var c := at + Vector3(randf_range(-50, 50), randf_range(30, 55), randf_range(-50, 50))
		var col := Color.from_hsv(randf(), 0.8, 1.0)
		for k in 14:
			var v := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(6, 10)
			parts.append({"p": c, "v": v, "t": 2.2, "g": -3.0, "col": col, "s": 0.6, "glow": 2.0})
	sfx("pop")
func bocinazo() -> void:
	sfx("horns")
	var tw := create_tween()
	if top_money:
		tw.tween_property(top_money, "modulate", Color(1.0, 0.85, 0.3), 0.2)
		tw.tween_property(top_money, "modulate", Color.WHITE, 0.8)
func start_drive() -> void:
	if road_list.is_empty():
		toast("Primero hacé calles")
		return
	var c: int = road_list[randi() % road_list.size()]
	drive = {"c": c, "n": c, "t": 0.0, "dir": Vector2i(1, 0), "spd": 3.0}
	pick_drive_next()
	cam_pitch = 0.3
	cam_dist_goal = 10.0
	cam_follow = func():
		if drive == null:
			return null
		var pp := path_pos([drive["c"], drive["n"]], drive["t"], CELL * 0.18)
		cam_yaw = lerp_angle(cam_yaw, pp[1] + PI, 0.08)
		cam_dist_goal = 10.0
		return pp[0] + Vector3(0, 1.5, 0)
	show_drive_ui(true)
func stop_drive() -> void:
	drive = null
	cam_follow = null
	cam_pitch = 0.85
	cam_dist_goal = 120.0
	show_drive_ui(false)
func pick_drive_next() -> void:
	var c: int = drive["c"]
	var d: Vector2i = drive["dir"]
	var cands: Array = []
	var dirs := [d, Vector2i(-d.y, d.x), Vector2i(d.y, -d.x)]
	var order: Array = []
	if drive_turn == -1:
		order = [dirs[2], dirs[0], dirs[1]]
	elif drive_turn == 1:
		order = [dirs[1], dirs[0], dirs[2]]
	else:
		order = [dirs[0], dirs[1], dirs[2]]
	for o in order:
		var x: int = cx(c) + o.x
		var z: int = cz(c) + o.y
		if inb(x, z) and road[idx(x, z)] > 0:
			cands.append(o)
	if cands.is_empty():
		cands = [-d]
	var nd: Vector2i = cands[0]
	drive["dir"] = nd
	drive["n"] = idx(cx(c) + nd.x, cz(c) + nd.y) if inb(cx(c) + nd.x, cz(c) + nd.y) else c
	drive_turn = 0
func move_drive(dt: float) -> void:
	drive["t"] = drive["t"] + dt * drive["spd"]
	if drive["t"] >= 1.0:
		drive["t"] = 0.0
		drive["c"] = drive["n"]
		pick_drive_next()
		set_drive_street(street_name(drive["c"]))
func pick_ped(pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var bd := get_viewport().get_visible_rect().size.y * 0.045
	for pd in peds:
		if pd["kind"] == 2:
			continue
		var pp := path_pos([pd["c"], pd["n"]], pd["t"], CELL * 0.42 * pd["side"])
		var wp: Vector3 = pp[0]
		if cam.is_position_behind(wp):
			continue
		var d := cam.unproject_position(wp + Vector3(0, 1.0, 0)).distance_to(pos)
		if d < bd:
			bd = d
			best = pd
	return best
func follow_citizen(chosen: Dictionary = {}) -> void:
	if peds.is_empty():
		toast("Todavía no hay gente en la calle")
		return
	var pd: Dictionary = chosen
	if pd.is_empty():
		pd = peds[randi() % peds.size()]
		if pd["kind"] == 2:
			pd = peds[0]
	follow_ped = pd
	var homes: Array = []
	var work: Array = []
	for i in zone_list:
		if lvl[i] > 0:
			if zone[i] == Z_R:
				homes.append(i)
			elif zone[i] == Z_C or zone[i] == Z_I:
				work.append(i)
	pd["home"] = homes[randi() % homes.size()] if not homes.is_empty() else -1
	pd["job"] = work[randi() % work.size()] if not work.is_empty() else -1
	cam_dist_goal = 30.0
	cam_follow = func():
		if follow_ped == null or not (follow_ped in peds):
			follow_ped = null
			hide_follow_card()
			return null
		var pp := path_pos([follow_ped["c"], follow_ped["n"]], follow_ped["t"], CELL * 0.42 * follow_ped["side"])
		return pp[0]
	show_follow_card(pd)
func draw_dynamic() -> void:
	if not opts["g_dyn"]:
		return
	crumb("móviles: armando (zoom %d)" % int(cam_dist))
	begin_buf()
	var nf := night
	var near := cam_dist < 220.0
	if (cam_dist < 260.0) != dyn_close:
		dyn_close = cam_dist < 260.0
		crumb("zoom %s a %d" % ["cerca" if dyn_close else "lejos", int(cam_dist)])
	var near2 := cam_dist < 90.0
	var wet_now := weather == "Lluvia" or weather == "Tormenta"
	var lit: bool = nf > 0.25 and near and opts["quality"] >= 1
	glow_n = 0
	for c in cars:
		var pr := path_pos_s(c["p"], c["k"], CELL * 0.18)
		var p: Vector3 = pr[0]
		var r: float = pr[1]
		var col: Color = c["col"]
		var fade := clampf(minf(c["k"], c["p"].size() - 1.0 - c["k"]) * 1.2, 0.0, 1.0)
		if fade < 0.05:
			continue
		var kd: int = c["kind"]
		if kd == 5:
			draw_moto(p, r, c, nf, lit and fade > 0.9, near2)
			continue
		if c.get("crash", 0.0) > 0.0:
			draw_crash(c, p, r, near2)
		var ln: float = [2.0, 1.9, 2.5, 2.0, 2.4][kd]
		var bh: float = [0.45, 0.56, 0.7, 0.45, 0.55][kd]
		var roofc: Color = c["roof"]
		var sr := sin(r)
		var cr := cos(r)
		var fw := fade
		em(M_BOX, p.x - sr * ln * 0.16, p.y + 0.2, p.z - cr * ln * 0.16, 0.95 * fw, bh * fw, ln * 0.68, r, col, 0, 0, 0, 1.5)
		em(M_BOX, p.x + sr * ln * 0.33, p.y + 0.2, p.z + cr * ln * 0.33, 0.9 * fw, bh * 0.72 * fw, ln * 0.34, r, col, 0, 0, 0, 1.5)
		var cl := ln * (0.85 if kd == 2 else 0.5)
		var ch := 0.4 + (0.25 if kd == 2 else 0.0)
		var cby := p.y + 0.2 + bh * 0.88
		em(M_SPH, p.x - sr * ln * 0.1, cby, p.z - cr * ln * 0.1, 0.84 * fw, ch * fw, cl, r, Color(0.07, 0.09, 0.12), 0, 0, 0, 1.5)
		em(M_BOX, p.x - sr * ln * 0.1, cby + ch * 0.82, p.z - cr * ln * 0.1, 0.66 * fw, 0.05 * fw, cl * 0.7, r, roofc, 0, 0, 0, 1.5)
		if near2:
			for sg in [-1.0, 1.0]:
				em(M_BOX, p.x + cr * sg * 0.52 + sr * ln * 0.12, p.y + 0.2 + bh * 0.95, p.z - sr * sg * 0.52 + cr * ln * 0.12, 0.1, 0.07, 0.12, r, roofc if kd != 3 else col, 0, 0, 0, 1.5)
			if kd == 3:
				em(M_BOX, p.x - sr * ln * 0.1, cby + ch * 0.9, p.z - cr * ln * 0.1, 0.32, 0.1, 0.18, r, Color(1.0, 0.95, 0.7), 0, 0, 0.5 + nf * 2.2)
		veh_lights(p, r, ln, 0.4, bh * 0.85 + 0.2, nf, lit and fade > 0.9, near2, 5.0)
	if drive != null:
		var pr2 := path_pos([drive["c"], drive["n"]], drive["t"], CELL * 0.18)
		var p2: Vector3 = pr2[0]
		em(M_BOX, p2.x, p2.y + 0.2, p2.z, 1.0, 0.6, 2.2, pr2[1], Color(0.95, 0.85, 0.1))
		em(M_BOX, p2.x, p2.y + 0.8, p2.z, 0.9, 0.45, 1.2, pr2[1], Color(0.2, 0.2, 0.25), 0.6)
	for v in svc:
		var pr3 := path_pos_s(v["p"], v["k"], CELL * 0.18)
		var p3: Vector3 = pr3[0]
		var r3: float = pr3[1]
		var body: Color = {"police": Color(0.95, 0.95, 0.97), "ambulance": Color(0.97, 0.97, 0.97), "fire": Color(0.85, 0.12, 0.1), "garbage": Color(0.3, 0.55, 0.3)}[v["kind"]]
		var ln3 := 3.0 if v["kind"] == "fire" or v["kind"] == "garbage" else 2.2
		em(M_BOX, p3.x, p3.y + 0.2, p3.z, 1.05, 1.0 if ln3 > 2.5 else 0.7, ln3, r3, body)
		if v["kind"] != "garbage":
			var on := int(anim_time * 6.0) % 2 == 0
			var lc := Color(0.2, 0.3, 1.0) if on else Color(1.0, 0.15, 0.1)
			if v["kind"] == "fire" or v["kind"] == "ambulance":
				lc = Color(1.0, 0.15, 0.1) if on else Color(1, 1, 1)
			em(M_BOX, p3.x, p3.y + 1.2, p3.z, 0.8, 0.2, 0.3, r3, lc, 0, 0, 3.0)
	if cam_dist < 260.0:
		var pclose := cam_dist < 70.0
		for pd in peds:
			var pr4 := path_pos([pd["c"], pd["n"]], pd["t"], CELL * 0.42 * pd["side"])
			var p4: Vector3 = pr4[0]
			var rp: float = pr4[1]
			var ph: float = anim_time * (8.0 if pd.get("panic", 0.0) <= 0.0 else 16.0) + pd["side"] * 3.0
			match pd["kind"]:
				2:
					em(M_BOX, p4.x, p4.y + 0.3, p4.z, 0.25, 0.3, 0.6, rp, Color(0.55, 0.35, 0.2))
					em(M_SPH, p4.x + sin(rp) * 0.35, p4.y + 0.55, p4.z + cos(rp) * 0.35, 0.22, 0.22, 0.28, rp, Color(0.55, 0.35, 0.2))
				3:
					draw_bike(p4, rp, pd, pclose)
				_:
					var s := 0.72 if pd["kind"] == 1 else 1.0
					var ex := 1 if pd["bag"] else 0
					if wet_now and hsh(int(pd["age"]) + int(pd["c"]), 5) < 0.7:
						ex |= 2
					if pd.get("panic", 0.0) > 0.0:
						ex |= 4
					draw_person(p4.x, p4.y, p4.z, rp, s, pd["col"], pd["pant"], pd["skin"], pd["hair"], ph, pclose, ex, pd["umb"])
					var rx4 := cos(rp)
					var rz4 := -sin(rp)
					for f in pd["comp"]:
						var off: float = f["off"]
						var fs: float = f["s"]
						var ex2 := 1 if f["bag"] else 0
						if ex & 2 and not f.has("hand"):
							ex2 |= 2
						if ex & 4:
							ex2 |= 4
						draw_person(p4.x + rx4 * off * pd["side"], p4.y, p4.z + rz4 * off * pd["side"], rp, fs, f["col"], f["pant"], f["skin"], f["hair"], ph + 1.3, pclose, ex2, f["umb"])
		for ln in lines:
			if ln["pts"].size() < 2 or not (ln["kind"] in ["bus", "tram"]):
				continue
			for s in ln["stops"]:
				var sp := cell_pos(s)
				for k in 2:
					draw_person(sp.x + CELL * 0.42, sp.y, sp.z + (k - 0.5) * 0.7, -PI * 0.5, 1.0, SHIRTS[int(hsh(s, k) * 12.0) % 12], PANTS[k % 5], SKINS[int(hsh(s, k + 3) * 5.0) % 5], HAIRS[k * 2 % 6], 0.0, cam_dist < 70.0, 0)
	for s in stops:
		var sp2 := cell_pos(s)
		em(M_BOX, sp2.x + CELL * 0.45, sp2.y, sp2.z, 0.12, 2.4, 0.12, 0.0, Color(0.95, 0.85, 0.2))
		em(M_BOX, sp2.x + CELL * 0.45, sp2.y + 2.2, sp2.z, 0.1, 0.5, 0.6, 0.0, Color(0.95, 0.85, 0.2) if stops[s] == "bus" else Color(0.9, 0.4, 0.2), 0, 0.6)
	var li := 0
	for ln in lines:
		var pts: Array = ln["pts"]
		if pts.size() < 2:
			li += 1
			continue
		var t: float = ln["t"] + 0.5
		var np := pts.size()
		var si := int(t) % np
		var bc := curve_at(pts[(si - 1 + np) % np], pts[si], pts[(si + 1) % np], t - floor(t))
		var tg5: Vector3 = bc[1]
		tg5.y = 0.0
		if tg5.length() < 0.001:
			tg5 = Vector3(1, 0, 0)
		tg5 = tg5.normalized()
		var p5: Vector3 = bc[0] + Vector3(-tg5.z, 0, tg5.x) * CELL * 0.18
		var r5 := atan2(tg5.x, tg5.z)
		var col5: Color = ln["col"]
		match ln["kind"]:
			"bus":
				var sb := sin(r5)
				var cb := cos(r5)
				em(M_BOX, p5.x, p5.y + 0.25, p5.z, 1.2, 0.75, 4.3, r5, col5, 0, 0, 0, 1.5)
				em(M_BOX, p5.x, p5.y + 1.0, p5.z, 1.18, 0.7, 4.2, r5, Color(0.93, 0.93, 0.95), 0, 0, 0, 1.5)
				em(M_BOX, p5.x, p5.y + 1.7, p5.z, 1.1, 0.12, 4.0, r5, Color(0.9, 0.9, 0.92))
				var wcol := Color(0.1, 0.14, 0.2).lerp(Color(1.0, 0.85, 0.55), nf)
				for sg in [-1.0, 1.0]:
					em(M_BOX, p5.x + cb * sg * 0.595, p5.y + 1.06, p5.z - sb * sg * 0.595, 0.04, 0.52, 3.9, r5, wcol, 0, 0, nf * 0.9)
					if near2:
						for pz in [-1.5, -0.5, 0.5, 1.5]:
							em(M_BOX, p5.x + cb * sg * 0.6 + sb * pz, p5.y + 1.0, p5.z - sb * sg * 0.6 + cb * pz, 0.05, 0.7, 0.07, r5, Color(0.93, 0.93, 0.95))
				em(M_BOX, p5.x + sb * 2.16, p5.y + 1.0, p5.z + cb * 2.16, 1.05, 0.6, 0.04, r5, Color(0.08, 0.11, 0.15).lerp(Color(1.0, 0.9, 0.65), nf * 0.7), 0, 0, nf * 0.6)
				em(M_BOX, p5.x + sb * 2.17, p5.y + 1.55, p5.z + cb * 2.17, 0.95, 0.2, 0.05, r5, Color(0.03, 0.03, 0.03), 0, 0, 0.0)
				em(M_BOX, p5.x + sb * 2.18, p5.y + 1.55, p5.z + cb * 2.18, 0.8, 0.12, 0.04, r5, Color(1.0, 0.55, 0.05), 0, 0, 1.8)
				if near2:
					em(M_BOX, p5.x - sb * 0.8, p5.y + 1.82, p5.z - cb * 0.8, 0.7, 0.15, 1.0, r5, Color(0.75, 0.75, 0.78))
				veh_lights(p5, r5, 4.2, 0.45, 0.5, nf, lit, near2, 8.0)
			"tram":
				em(M_BOX, p5.x, p5.y + 0.25, p5.z, 1.3, 1.7, 5.0, r5, col5, 0.6)
				em(M_BOX, p5.x, p5.y + 1.95, p5.z, 0.1, 0.8, 0.1, 0.0, Color(0.2, 0.2, 0.2))
			"train":
				for k in 3:
					var o := -Vector3(sin(r5), 0, cos(r5)) * k * 4.4
					em(M_BOX, p5.x + o.x, p5.y, p5.z + o.z, 1.6, 1.8, 4.2, r5, col5 if k == 0 else Color(0.85, 0.85, 0.88), 0.6)
			"ferry":
				em(M_BOX, p5.x, WATER_Y - 0.3, p5.z, 2.6, 1.0, 6.0, r5, Color(0.95, 0.95, 0.95))
				em(M_BOX, p5.x, WATER_Y + 0.7, p5.z, 2.0, 1.2, 3.0, r5, col5, 0.5)
			"metro":
				pass
		if li < line_labels.size():
			var lab: Label3D = line_labels[li]
			lab.visible = ln["kind"] == "bus" and cam_dist < 110.0
			lab.position = p5 + Vector3(sin(r5) * 2.21, 1.55, cos(r5) * 2.21)
			lab.rotation = Vector3(0, r5, 0)
			lab.text = str(ln["num"])
		li += 1
	while line_labels.size() < lines.size():
		var lab2 := Label3D.new()
		lab2.font_size = 64
		lab2.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		lab2.pixel_size = 0.0075
		lab2.outline_size = 0
		lab2.shaded = false
		lab2.double_sided = false
		lab2.modulate = Color(1.0, 0.22, 0.15)
		add_child(lab2)
		line_labels.append(lab2)
	for k in range(lines.size(), line_labels.size()):
		line_labels[k].visible = false
	for bt in boats:
		var p6: Vector3 = bt["p"]
		var r6 := atan2(bt["v"].x, bt["v"].z)
		if bt["kind"] == 0:
			em(M_BOX, p6.x, p6.y - 0.6, p6.z, 4.0, 2.0, 14.0, r6, Color(0.6, 0.15, 0.12))
			for k in 3:
				em(M_BOX, p6.x - sin(r6) * (k - 1) * 3.5, p6.y + 1.4, p6.z - cos(r6) * (k - 1) * 3.5, 3.2, 1.6, 3.0, r6, [Color(0.2, 0.4, 0.8), Color(0.85, 0.5, 0.15), Color(0.3, 0.6, 0.3)][k])
		else:
			em(M_BOX, p6.x, p6.y - 0.2, p6.z, 1.0, 0.6, 3.0, r6, Color(0.95, 0.95, 0.95))
			em(M_ROOF, p6.x, p6.y + 0.4, p6.z, 0.1, 3.0, 1.8, r6, Color(0.98, 0.98, 0.98))
	for pl in planes:
		var p7: Vector3 = pl["p"]
		var r7 := atan2(pl["v"].x, pl["v"].z)
		em(M_BOX, p7.x, p7.y, p7.z, 1.2, 1.2, 8.0, r7, Color(0.95, 0.95, 0.97))
		em(M_BOX, p7.x, p7.y + 0.3, p7.z, 9.0, 0.2, 1.8, r7, Color(0.85, 0.85, 0.9))
		em(M_BOX, p7.x - sin(r7) * 3.5, p7.y + 0.6, p7.z - cos(r7) * 3.5, 0.2, 1.8, 1.2, r7, Color(0.2, 0.4, 0.8))
	if cam_dist < 200.0:
		var ph := fmod(anim_time, 9.0)
		for c6 in tl_cells:
			var p8 := cell_pos(c6)
			var ns := ph < 4.0
			var yel := (ph > 4.0 and ph < 4.5) or ph > 8.5
			var lc2 := Color(1.0, 0.8, 0.1) if yel else (Color(0.2, 1.0, 0.3) if ns else Color(1.0, 0.15, 0.1))
			em(M_BOX, p8.x + CELL * 0.45, p8.y, p8.z + CELL * 0.45, 0.12, 2.8, 0.12, 0.0, Color(0.2, 0.2, 0.2))
			em(M_BOX, p8.x + CELL * 0.45, p8.y + 2.6, p8.z + CELL * 0.45, 0.3, 0.3, 0.3, 0.0, lc2, 0, 0, 2.0)
	for a in anchors:
		if bld[a] == 0:
			continue
		if bld[a] == 34:
			var pc := cell_pos(a)
			for k in 6:
				var ang := anim_time * 0.8 + k * TAU / 6.0
				em(M_BOX, pc.x + cos(ang) * 1.2, pc.y + 0.6 + sin(anim_time * 3.0 + k) * 0.15, pc.z + sin(ang) * 1.2, 0.3, 0.6, 0.7, -ang, Color.from_hsv(k / 6.0, 0.6, 0.95))
		elif bld[a] == 45:
			var pw := cell_pos(a)
			for k in 3:
				var ang2 := anim_time * 1.5 + k * TAU / 3.0
				em(M_BOX, pw.x + cos(ang2) * 2.2, pw.y + 11.0 + sin(ang2) * 2.2, pw.z + 0.7, 4.4, 0.35, 0.1, 0.0, Color(0.95, 0.95, 0.95))
	for c7 in anim_cells:
		var p9 := cell_pos(c7)
		var big: bool = part[c7] == c7
		var w := CELL * (1.8 if big else 0.8)
		var t2: float = anim_cells[c7]
		var target := 2.0 + lvl[c7] * 3.0 if zone[c7] > 0 else 4.0
		var h := target * clampf(1.0 - t2 / 1.5, 0.1, 1.0)
		var bx := p9.x + (CELL * 0.5 if big else 0.0)
		var bz := p9.z + (CELL * 0.5 if big else 0.0)
		em(M_BOX, bx, p9.y, bz, w * 0.8, h, w * 0.8, 0.0, Color(0.75, 0.72, 0.68))
		for k in 4:
			var ang3 := k * PI * 0.5 + 0.785
			em(M_BOX, bx + cos(ang3) * w * 0.48, p9.y, bz + sin(ang3) * w * 0.48, 0.1, h + 0.8, 0.1, 0.0, Color(0.9, 0.6, 0.2))
		if target > 6.0:
			em(M_BOX, bx + w * 0.6, p9.y, bz, 0.25, target + 4.0, 0.25, 0.0, Color(0.95, 0.75, 0.1))
			em(M_BOX, bx + w * 0.6 - 2.0, p9.y + target + 3.8, bz, 6.0, 0.25, 0.25, 0.0, Color(0.95, 0.75, 0.1))
		if randf() < 0.05:
			parts.append({"p": Vector3(bx, p9.y + 0.5, bz), "v": Vector3(randf_range(-1, 1), 1.0, randf_range(-1, 1)), "t": 1.2, "g": 0.0, "col": Color(0.8, 0.75, 0.65), "s": 0.9})
	for i in N * N:
		if burn[i] > 0.0:
			emit_flames(cell_pos(i), i)
	if flag_days > 0 and cam_dist < 250.0:
		var nflag := 0
		for i in zone_list:
			if lvl[i] >= 2 and hsh(i, 99) < 0.12:
				var fr := face_rot(i)
				var pfl := cell_pos(i) + Vector3(sin(fr) * CELL * 0.44 + cos(fr) * CELL * 0.4, 0.1, cos(fr) * CELL * 0.44 - sin(fr) * CELL * 0.4)
				var hh := 0.0
				var wv := sin(anim_time * 4.0 + i) * 0.2
				em(M_BOX, pfl.x, pfl.y, pfl.z, 0.08, 4.6, 0.08, 0.0, Color(0.8, 0.8, 0.8))
				em(M_BOX, pfl.x + 0.6, pfl.y + hh + 4.2, pfl.z, 1.2, 0.25, 0.05, wv, Color(0.45, 0.75, 0.95))
				em(M_BOX, pfl.x + 0.6, pfl.y + hh + 3.95, pfl.z, 1.2, 0.25, 0.05, wv, Color(1, 1, 1))
				em(M_BOX, pfl.x + 0.6, pfl.y + hh + 3.7, pfl.z, 1.2, 0.25, 0.05, wv, Color(0.45, 0.75, 0.95))
				nflag += 1
				if nflag > 60:
					break
	draw_stars(nf)
	for p in parts:
		var pp: Vector3 = p["p"]
		var s2: float = p["s"]
		em(M_BOX if p.has("glow") else M_SPH, pp.x, pp.y, pp.z, s2, s2, s2, p["t"] * 3.0, p["col"], 0, 0, p.get("glow", 0.0))
	if weather in ["Lluvia", "Tormenta", "Nieve"] and opts["quality"] >= 1 and not opts["g_rain"]:
		var snow := weather == "Nieve"
		for k in 160:
			var rx := cam_target.x + (hsh(k, 1) - 0.5) * cam_dist * 1.4
			var rz := cam_target.z + (hsh(k, 2) - 0.5) * cam_dist * 1.4
			var fall := 30.0 if not snow else 5.0
			var ry := 40.0 - fmod(anim_time * fall + hsh(k, 3) * 40.0, 40.0)
			if snow:
				em(M_SPH, rx + sin(anim_time + k) * 0.5, ry, rz, 0.35, 0.35, 0.35, 0.0, Color(1, 1, 1))
			else:
				em(M_BOX, rx, ry, rz, 0.05, 1.6, 0.05, 0.0, Color(0.7, 0.75, 0.85))
	crumb("móviles: subiendo a la placa (%d autos, %d vecinos)" % [cars.size(), peds.size()])
	if nf > 0.3 and cam_dist < 240.0 and opts["quality"] >= 1:
		var rr := cam_dist * 1.2 + 30.0
		var inten := clampf((nf - 0.3) * 1.6, 0.0, 1.0)
		var shown := 0
		for k in lamps:
			var lp: Vector3 = lamps[k]
			if absf(lp.x - cam_target.x) > rr or absf(lp.z - cam_target.z) > rr:
				continue
			gl(1.0, lp.x, lp.y + 0.34, lp.z, 7.5 + (3.0 if wet_now else 0.0), 7.5 + (3.0 if wet_now else 0.0), 0.0, Color(1.0, 0.8, 0.45, (0.5 + (0.25 if wet_now else 0.0)) * inten))
			shown += 1
			if shown > 260:
				break
	flush_mm(glow_node.multimesh, glow_n, glow_buf)
	for m in NMESH:
		var node: MultiMeshInstance3D = dyn_nodes[m]
		flush_mm(node.multimesh, _counts[m], _bufs[m])
const SHIRTS := [Color(0.12, 0.16, 0.3), Color(0.08, 0.08, 0.09), Color(0.9, 0.9, 0.88), Color(0.5, 0.5, 0.52), Color(0.76, 0.68, 0.55), Color(0.65, 0.12, 0.12), Color(0.36, 0.38, 0.22), Color(0.78, 0.6, 0.18), Color(0.3, 0.42, 0.6), Color(0.85, 0.55, 0.6), Color(0.2, 0.45, 0.3), Color(0.42, 0.28, 0.18)]
const PANTS := [Color(0.18, 0.25, 0.42), Color(0.07, 0.07, 0.08), Color(0.6, 0.55, 0.42), Color(0.35, 0.35, 0.37), Color(0.4, 0.5, 0.65)]
const SKINS := [Color(0.95, 0.78, 0.65), Color(0.87, 0.66, 0.5), Color(0.72, 0.52, 0.38), Color(0.55, 0.38, 0.26), Color(0.38, 0.26, 0.18)]
const HAIRS := [Color(0.06, 0.05, 0.05), Color(0.2, 0.13, 0.08), Color(0.38, 0.25, 0.15), Color(0.82, 0.68, 0.42), Color(0.7, 0.7, 0.7), Color(0.55, 0.22, 0.1)]
const UMBS := [Color(0.1, 0.1, 0.12), Color(0.75, 0.1, 0.12), Color(0.15, 0.3, 0.7), Color(0.95, 0.75, 0.1), Color(0.2, 0.55, 0.35), Color(0.85, 0.4, 0.6)]
func rand_look() -> Dictionary:
	return {"col": SHIRTS[randi() % SHIRTS.size()], "pant": PANTS[randi() % PANTS.size()], "skin": SKINS[randi() % SKINS.size()], "hair": HAIRS[randi() % HAIRS.size()], "bag": randf() < 0.3, "umb": UMBS[randi() % UMBS.size()]}
func new_ped(c: int, kind: int) -> Dictionary:
	var pd := rand_look()
	pd.merge({"c": c, "n": c, "t": 0.0, "kind": kind, "side": 1.0 if randf() < 0.5 else -1.0, "name": rand_name(), "age": 8 + randi() % 70, "home": -1, "job": -1, "panic": 0.0})
	var comp: Array = []
	if kind == 0:
		var r := randf()
		if r < 0.22:
			var f := rand_look()
			f["off"] = 0.55
			f["s"] = 0.92 + randf() * 0.12
			comp.append(f)
			if randf() < 0.3:
				var f2 := rand_look()
				f2["off"] = -0.55
				f2["s"] = 0.95
				comp.append(f2)
		elif r < 0.32:
			var k := rand_look()
			k["off"] = 0.42
			k["s"] = 0.62
			k["bag"] = false
			k["hand"] = true
			comp.append(k)
	pd["comp"] = comp
	return pd
func draw_person(x: float, y: float, z: float, rp: float, s: float, shirt: Color, pant: Color, skin: Color, hair: Color, ph: float, close: bool, extra: int, umb: Color = Color.BLACK) -> void:
	var fx := sin(rp)
	var fz := cos(rp)
	var rx := cos(rp)
	var rz := -sin(rp)
	if close:
		var sw := sin(ph) * 0.13 * s
		for sg in [-1.0, 1.0]:
			var g: float = sg
			em(M_CYL, x + rx * g * 0.075 * s + fx * sw * g, y, z + rz * g * 0.075 * s + fz * sw * g, 0.12 * s, 0.5 * s, 0.12 * s, 0.0, pant)
			em(M_SPH, x + rx * g * 0.075 * s + fx * (sw * g + 0.03 * s), y, z + rz * g * 0.075 * s + fz * (sw * g + 0.03 * s), 0.12 * s, 0.07 * s, 0.18 * s, rp, Color(0.12, 0.1, 0.09))
			var ay := 0.5 * s if extra & 4 == 0 else 0.78 * s
			var asw := -sw * g if extra & 4 == 0 else sin(ph * 2.0 + g) * 0.05 * s
			em(M_CYL, x + rx * g * 0.2 * s + fx * asw, y + ay, z + rz * g * 0.2 * s + fz * asw, 0.08 * s, 0.4 * s, 0.08 * s, 0.0, shirt.darkened(0.1))
		em(M_SPH, x, y + 0.44 * s, z, 0.34 * s, 0.56 * s, 0.22 * s, rp, shirt)
		em(M_SPH, x, y + 0.86 * s, z, 0.22 * s, 0.26 * s, 0.22 * s, rp, skin)
		em(M_SPH, x - fx * 0.02 * s, y + 0.99 * s, z - fz * 0.02 * s, 0.23 * s, 0.15 * s, 0.23 * s, rp, hair)
		if extra & 1:
			em(M_BOX, x - fx * 0.15 * s, y + 0.55 * s, z - fz * 0.15 * s, 0.26 * s, 0.32 * s, 0.12 * s, rp, Color(0.15, 0.17, 0.2))
	else:
		em(M_CYL, x, y, z, 0.24 * s, 0.5 * s, 0.24 * s, 0.0, pant)
		em(M_SPH, x, y + 0.44 * s, z, 0.34 * s, 0.56 * s, 0.24 * s, rp, shirt)
		em(M_SPH, x, y + 0.88 * s, z, 0.24 * s, 0.28 * s, 0.24 * s, 0.0, skin.lerp(hair, 0.4))
	if extra & 2:
		em(M_BOX, x + rx * 0.18 * s, y + 0.75 * s, z + rz * 0.18 * s, 0.03, 0.8 * s, 0.03, 0.0, Color(0.2, 0.2, 0.2))
		em(M_SPH, x + rx * 0.1 * s, y + 1.45 * s, z + rz * 0.1 * s, 1.0 * s, 0.28 * s, 1.0 * s, 0.0, umb)
func draw_bike(p: Vector3, rp: float, pd: Dictionary, close: bool) -> void:
	var fx := sin(rp)
	var fz := cos(rp)
	var fc := Color(0.75, 0.12, 0.1) if hsh(int(pd["age"]), 3) < 0.5 else Color(0.15, 0.4, 0.7)
	for sg in [-0.42, 0.42]:
		var g: float = sg
		em(M_SPH, p.x + fx * g, p.y, p.z + fz * g, 0.06, 0.62, 0.62, rp, Color(0.08, 0.08, 0.08))
	em(M_BOX, p.x, p.y + 0.3, p.z, 0.06, 0.06, 0.84, rp, fc)
	em(M_BOX, p.x - fx * 0.12, p.y + 0.3, p.z - fz * 0.12, 0.06, 0.4, 0.06, rp, fc)
	draw_person(p.x - fx * 0.1, p.y + 0.35, p.z - fz * 0.1, rp, 0.9, pd["col"], pd["pant"], pd["skin"], pd["hair"], anim_time * 9.0, close, 1 if pd["bag"] else 0)
func draw_moto(p: Vector3, r: float, c: Dictionary, nf: float, lit: bool, close: bool) -> void:
	var fx := sin(r)
	var fz := cos(r)
	for sg in [-0.62, 0.6]:
		var g: float = sg
		em(M_SPH, p.x + fx * g, p.y + 0.02, p.z + fz * g, 0.14, 0.6, 0.6, r, Color(0.06, 0.06, 0.06))
	em(M_BOX, p.x, p.y + 0.35, p.z, 0.32, 0.35, 1.2, r, c["col"], 0, 0, 0, 1.5)
	em(M_BOX, p.x + fx * 0.5, p.y + 0.6, p.z + fz * 0.5, 0.5, 0.06, 0.06, r, Color(0.1, 0.1, 0.1))
	var look: Dictionary = c["look"]
	draw_person(p.x - fx * 0.05, p.y + 0.45, p.z - fz * 0.05, r, 0.9, look["col"], look["pant"], look["skin"], Color(0.1, 0.1, 0.12) if c["deli"] else Color(0.85, 0.85, 0.88), 0.0, close, 0)
	if c["deli"]:
		em(M_BOX, p.x - fx * 0.55, p.y + 0.7, p.z - fz * 0.55, 0.5, 0.5, 0.5, r, c["box"])
	if lit:
		em(M_BOX, p.x + fx * 0.62, p.y + 0.55, p.z + fz * 0.62, 0.12, 0.12, 0.05, r, Color(1.0, 0.95, 0.8), 0, 0, 3.0)
		gl(2.0, p.x + fx * 0.66, p.y + 0.55, p.z + fz * 0.66, 1.0, 1.0, 0.0, Color(1.0, 0.93, 0.75, 0.8), 0.6)
		gl(0.0, p.x + fx * 3.2, p.y + 0.33, p.z + fz * 3.2, 1.2, 5.0, r, Color(1.0, 0.9, 0.7, 0.35))
var crash_cool: float = 20.0
func check_crash(dt: float) -> void:
	crash_cool -= dt
	if crash_cool > 0.0 or cars.size() < 6:
		return
	crash_cool = 4.0
	if randf() > 0.25:
		return
	var by_cell := {}
	for c in cars:
		if c.get("crash", 0.0) > 0.0:
			return
		var p: Array = c["p"]
		var i: int = clampi(int(c["k"]), 0, p.size() - 1)
		var j: int = mini(i + 1, p.size() - 1)
		var cell: int = p[i]
		if by_cell.has(cell):
			var o: Dictionary = by_cell[cell]
			var op: Array = o["p"]
			var oi: int = clampi(int(o["k"]), 0, op.size() - 1)
			var oj: int = mini(oi + 1, op.size() - 1)
			if op[oj] != p[j] and road[cell] >= 2:
				c["crash"] = 26.0
				o["crash"] = 26.0
				c["argue"] = rand_look()
				o["argue"] = rand_look()
				crash_cool = 90.0
				var cp := cell_pos(cell)
				for k in 6:
					parts.append({"p": cp + Vector3(randf_range(-0.6, 0.6), 0.8, randf_range(-0.6, 0.6)), "v": Vector3(randf_range(-1, 1), 2.0, randf_range(-1, 1)), "t": 1.5, "g": 0.2, "col": Color(0.75, 0.75, 0.75), "s": 0.7})
				if Vector2(cam_target.x - cp.x, cam_target.z - cp.z).length() < 150.0:
					toast("💥 Choque en " + street_name(cell) + ": los conductores se bajaron a discutir")
					sfx("horn")
				return
		else:
			by_cell[cell] = c
func draw_crash(c: Dictionary, p: Vector3, r: float, close: bool) -> void:
	var on := int(anim_time * 3.0) % 2 == 0
	if on:
		for sg in [-1.0, 1.0]:
			var g: float = sg
			for fb in [-1.0, 1.0]:
				var b: float = fb
				gl(2.0, p.x + cos(r) * g * 0.45 + sin(r) * b * 1.0, p.y + 0.55, p.z - sin(r) * g * 0.45 + cos(r) * b * 1.0, 1.0, 1.0, 0.0, Color(1.0, 0.6, 0.1, 0.9), 0.5)
	if close:
		var lk: Dictionary = c["argue"]
		var ax := p.x + cos(r) * 1.4
		var az := p.z - sin(r) * 1.4
		draw_person(ax, p.y, az, r + PI * 0.5 + sin(anim_time * 2.0) * 0.4, 1.0, lk["col"], lk["pant"], lk["skin"], lk["hair"], anim_time * 6.0, true, 4)
const MOVIES := [
	{"t": "Scream", "cast": ["ghostface"], "h": true, "d": "Ghostface va a andar suelto persiguiendo vecinos"},
	{"t": "Chucky: el muñeco diabólico", "cast": ["chucky"], "h": true, "d": "Chucky se escapó de la caja y anda por las veredas"},
	{"t": "It", "cast": ["pennywise"], "h": true, "d": "Pennywise reparte globos rojos... y sustos"},
	{"t": "Viernes 13", "cast": ["jason"], "h": true, "d": "Jason Voorhees salió del lago con su machete"},
	{"t": "Halloween", "cast": ["michael"], "h": true, "d": "Michael Myers camina despacio detrás de la gente"},
	{"t": "Terminator", "cast": ["t800"], "h": true, "d": "Un T-800 busca a alguien llamado Sarah Connor"},
	{"t": "Avengers", "cast": ["hulk", "ironman", "cap", "thor"], "h": false, "d": "Los Vengadores recorren la ciudad saludando a todos"},
	{"t": "Cazafantasmas", "cast": ["buster", "buster", "buster", "ghost", "ghost"], "h": false, "d": "Los Cazafantasmas persiguen fantasmas por las calles"},
	{"t": "Star Wars", "cast": ["vader", "trooper", "trooper", "trooper", "trooper"], "h": false, "d": "Darth Vader desfila con sus soldados imperiales"},
	{"t": "Jurassic Park", "cast": ["trex"], "h": false, "d": "Un T-Rex se escapó: la gente corre a esconderse"},
	{"t": "Spider-Man", "cast": ["spidey"], "h": false, "d": "Spider-Man salta de techo en techo"},
	{"t": "Mi villano favorito", "cast": ["minion", "minion", "minion", "minion", "minion", "minion"], "h": false, "d": "Los Minions invaden las veredas"},
	{"t": "Shrek", "cast": ["shrek", "burro"], "h": false, "d": "Shrek y Burro pasean por el barrio"},
	{"t": "Godzilla", "cast": ["godzilla"], "h": false, "d": "Godzilla cruza la ciudad: todos corren"},
]
const SCARY := ["ghostface", "chucky", "pennywise", "jason", "michael", "t800", "trex", "godzilla"]
const KILLERS := ["ghostface", "chucky", "pennywise", "jason", "michael", "t800"]
var movie_end_day: int = 0
var cine_last: int = -1
var movie_scared: int = 0
func cinema_cell() -> int:
	for a in anchors:
		if bld[a] == 66 and def_active(a):
			return a
	return -1
func cine_daily() -> void:
	if movie_on >= 0 and day >= movie_end_day:
		var m: Dictionary = MOVIES[movie_on]
		if m["h"] and movie_scared > 0:
			toast("🎬 Terminó \"%s\": %d vecinos se desmayaron del susto" % [m["t"], movie_scared])
		stars.clear()
		movie_on = -1
	var cc := cinema_cell()
	if cc < 0 or movie_on >= 0:
		return
	if cine_next_day == 0:
		cine_next_day = day + 1
	if day >= cine_next_day:
		var k := randi() % MOVIES.size()
		if k == cine_last:
			k = (k + 1) % MOVIES.size()
		start_movie(k, cc)
		cine_next_day = day + 3 + randi() % 3
func start_movie(k: int, origin: int) -> void:
	movie_on = k
	cine_last = k
	movie_end_day = day + 1
	movie_scared = 0
	stars.clear()
	var m: Dictionary = MOVIES[k]
	var roads_near: Array = []
	for i in road_list:
		if road[i] >= 2 and terr[i] != T_WATER and absi(cx(i) - cx(origin)) < 8 and absi(cz(i) - cz(origin)) < 8:
			roads_near.append(i)
	if roads_near.is_empty():
		roads_near = road_list.duplicate()
	if roads_near.is_empty():
		return
	for who in m["cast"]:
		var c: int = roads_near[randi() % roads_near.size()]
		stars.append({"who": who, "c": c, "n": c, "t": 0.0, "side": 1.0 if randf() < 0.5 else -1.0, "cool": 3.0, "jump": 0.0, "pos": cell_pos(c), "r": 0.0, "fly": Vector3.ZERO})
	queue_card({"title": "🎬 Estreno en el cine", "text": "Hoy se estrena \"%s\". Durante 24 horas: %s." % [m["t"], m["d"]], "btns": [["¡A verlo!", func(): look_star()], ["Dale", Callable()]]})
func look_star() -> void:
	if stars.is_empty():
		return
	var p: Vector3 = stars[0]["pos"]
	cam_goal = p
	cam_dist_goal = 22.0
func star_step(st: Dictionary, to: int) -> void:
	var c: int = st["c"]
	var opts2: Array = []
	for o in [1, -1, N, -N]:
		var j: int = c + o
		if j >= 0 and j < N * N and road[j] >= 2 and terr[j] != T_WATER:
			if (o == 1 or o == -1) and cz(j) != cz(c):
				continue
			opts2.append(j)
	if opts2.is_empty():
		st["n"] = c
		return
	if to >= 0 and randf() < 0.85:
		var best: int = opts2[0]
		var bd := 1e9
		for j in opts2:
			var d := Vector2(cx(j) - cx(to), cz(j) - cz(to)).length()
			if d < bd:
				bd = d
				best = j
		st["n"] = best
	else:
		st["n"] = opts2[randi() % opts2.size()]
func ped_pos(pd: Dictionary) -> Vector3:
	var pr := path_pos([pd["c"], pd["n"]], pd["t"], CELL * 0.42 * pd["side"])
	return pr[0]
func move_stars(dt: float) -> void:
	if stars.is_empty():
		var keep0: Array = []
		for dn in downs:
			dn["t"] = dn["t"] - dt
			if dn["t"] > 0.0:
				keep0.append(dn)
		downs = keep0
		return
	for st in stars:
		var who: String = st["who"]
		var spd := 0.7
		if who == "godzilla":
			spd = 0.25
		elif who == "trex":
			spd = 0.6
		elif who == "michael":
			spd = 0.35
		elif who == "minion":
			spd = 0.55
		st["cool"] = st["cool"] - dt
		st["jump"] = maxf(st["jump"] - dt, 0.0)
		var target := -1
		var killer: bool = who in KILLERS
		var tp := Vector3.ZERO
		var victim = null
		if killer and not peds.is_empty():
			var bd := 400.0
			var sp: Vector3 = st["pos"]
			for pd in peds:
				if pd == follow_ped or pd["kind"] == 2:
					continue
				var pp := ped_pos(pd)
				var d := pp.distance_squared_to(sp)
				if d < bd:
					bd = d
					victim = pd
					tp = pp
			if victim != null:
				target = victim["c"]
				if bd < 1.4 and st["cool"] <= 0.0:
					peds.erase(victim)
					downs.append({"p": tp, "r": randf() * TAU, "col": victim["col"], "skin": victim["skin"], "t": 14.0})
					movie_scared += 1
					st["cool"] = 7.0
					if movie_scared % 3 == 1:
						dispatch_from("ambulance", 22, int(victim["c"]))
		if who == "ironman":
			var fl: Vector3 = st["fly"]
			var sp2: Vector3 = st["pos"]
			if fl == Vector3.ZERO or sp2.distance_to(fl) < 3.0:
				var rc: int = road_list[randi() % road_list.size()] if not road_list.is_empty() else 0
				st["fly"] = cell_pos(rc) + Vector3(0, 9.0, 0)
				fl = st["fly"]
			var dv := (fl - sp2)
			if dv.length() > 0.01:
				st["r"] = atan2(dv.x, dv.z)
				st["pos"] = sp2 + dv.normalized() * minf(dt * 9.0, dv.length())
			continue
		st["t"] = st["t"] + dt * spd * (1.6 if killer and victim != null else 1.0)
		if st["t"] >= 1.0:
			st["t"] = 0.0
			st["c"] = st["n"]
			star_step(st, target)
			if (who == "spidey" or who == "hulk") and randf() < 0.35:
				st["jump"] = 1.4
		var pr := path_pos([st["c"], st["n"]], st["t"], CELL * 0.3 * st["side"])
		st["pos"] = pr[0]
		st["r"] = pr[1]
	if movie_on >= 0 and MOVIES[movie_on]["cast"][0] in SCARY:
		for pd in peds:
			if pd["panic"] > 0.0:
				pd["panic"] = pd["panic"] - dt
		for st in stars:
			if not (st["who"] in SCARY):
				continue
			var sp3: Vector3 = st["pos"]
			var rr := 64.0 if st["who"] != "godzilla" else 400.0
			for pd in peds:
				if ped_pos(pd).distance_squared_to(sp3) < rr:
					pd["panic"] = 3.0
	var keep: Array = []
	for dn in downs:
		dn["t"] = dn["t"] - dt
		if dn["t"] > 0.0:
			keep.append(dn)
	downs = keep
func hum(p: Vector3, r: float, s: float, body: Color, legs: Color, head: Color, arms: Color, ph: float) -> void:
	var fx := sin(r)
	var fz := cos(r)
	var rx := cos(r)
	var rz := -sin(r)
	var sw := sin(ph) * 0.13 * s
	for sg in [-1.0, 1.0]:
		var g: float = sg
		em(M_CYL, p.x + rx * g * 0.09 * s + fx * sw * g, p.y, p.z + rz * g * 0.09 * s + fz * sw * g, 0.15 * s, 0.52 * s, 0.15 * s, 0.0, legs)
		em(M_CYL, p.x + rx * g * 0.24 * s - fx * sw * g, p.y + 0.5 * s, p.z + rz * g * 0.24 * s - fz * sw * g, 0.11 * s, 0.44 * s, 0.11 * s, 0.0, arms)
	em(M_SPH, p.x, p.y + 0.45 * s, p.z, 0.42 * s, 0.58 * s, 0.28 * s, r, body)
	em(M_SPH, p.x, p.y + 0.9 * s, p.z, 0.26 * s, 0.3 * s, 0.26 * s, r, head)
func draw_stars(nf: float) -> void:
	var close := cam_dist < 110.0
	for dn in downs:
		var dp: Vector3 = dn["p"]
		var dr: float = dn["r"]
		em(M_SPH, dp.x, dp.y + 0.02, dp.z, 0.34, 0.24, 0.9, dr, dn["col"])
		em(M_SPH, dp.x + sin(dr) * 0.55, dp.y + 0.02, dp.z + cos(dr) * 0.55, 0.24, 0.22, 0.24, 0.0, dn["skin"])
	for st in stars:
		var p: Vector3 = st["pos"]
		var r: float = st["r"]
		var who: String = st["who"]
		var ph := anim_time * 8.0 + float(st["side"])
		var fx := sin(r)
		var fz := cos(r)
		var rx := cos(r)
		var rz := -sin(r)
		var jy: float = st["jump"]
		if jy > 0.0:
			p.y += sin(jy / 1.4 * PI) * (9.0 if who == "spidey" else 4.0)
		match who:
			"ghostface":
				em(M_CONE, p.x, p.y, p.z, 0.7, 1.1, 0.7, 0.0, Color(0.04, 0.04, 0.05))
				em(M_SPH, p.x, p.y + 0.62, p.z, 0.45, 0.6, 0.3, r, Color(0.04, 0.04, 0.05))
				em(M_SPH, p.x + fx * 0.04, p.y + 1.0, p.z + fz * 0.04, 0.24, 0.36, 0.24, r, Color(0.95, 0.95, 0.93))
				em(M_SPH, p.x + fx * 0.14 + rx * 0.07, p.y + 1.18, p.z + fz * 0.14 + rz * 0.07, 0.06, 0.1, 0.04, r, Color(0.02, 0.02, 0.02))
				em(M_SPH, p.x + fx * 0.14 - rx * 0.07, p.y + 1.18, p.z + fz * 0.14 - rz * 0.07, 0.06, 0.1, 0.04, r, Color(0.02, 0.02, 0.02))
				em(M_BOX, p.x + rx * 0.3 + fx * 0.15, p.y + 0.85 + sin(ph * 0.5) * 0.15, p.z + rz * 0.3 + fz * 0.15, 0.04, 0.38, 0.08, r, Color(0.8, 0.82, 0.85), 0, 0, 0, 1.5)
				em(M_SPH, p.x + rx * 0.3, p.y + 0.72, p.z + rz * 0.3, 0.12, 0.12, 0.12, 0.0, Color(0.04, 0.04, 0.05))
			"chucky":
				hum(p, r, 0.55, Color(0.25, 0.4, 0.75), Color(0.25, 0.4, 0.75), Color(0.95, 0.78, 0.65), Color(0.85, 0.15, 0.15), ph * 1.5)
				em(M_SPH, p.x - fx * 0.03, p.y + 0.62, p.z - fz * 0.03, 0.17, 0.12, 0.17, r, Color(0.9, 0.4, 0.1))
				em(M_BOX, p.x + rx * 0.16, p.y + 0.42, p.z + rz * 0.16, 0.03, 0.25, 0.05, r, Color(0.8, 0.82, 0.85), 0, 0, 0, 1.5)
			"pennywise":
				hum(p, r, 1.05, Color(0.92, 0.92, 0.88), Color(0.92, 0.92, 0.88), Color(0.97, 0.97, 0.96), Color(0.92, 0.92, 0.88), ph)
				for k in 3:
					em(M_SPH, p.x + fx * 0.15, p.y + 0.4 + k * 0.17, p.z + fz * 0.15, 0.08, 0.08, 0.08, 0.0, Color(0.95, 0.45, 0.1))
				em(M_SPH, p.x + rx * 0.15, p.y + 1.05, p.z + rz * 0.15, 0.14, 0.14, 0.14, 0.0, Color(0.85, 0.25, 0.1))
				em(M_SPH, p.x - rx * 0.15, p.y + 1.05, p.z - rz * 0.15, 0.14, 0.14, 0.14, 0.0, Color(0.85, 0.25, 0.1))
				em(M_BOX, p.x + rx * 0.3, p.y + 0.9, p.z + rz * 0.3, 0.02, 1.3, 0.02, 0.0, Color(0.9, 0.9, 0.9))
				em(M_SPH, p.x + rx * 0.3, p.y + 2.2 + sin(anim_time * 2.0) * 0.08, p.z + rz * 0.3, 0.42, 0.5, 0.42, 0.0, Color(0.85, 0.05, 0.05), 0, 0, 0.0, 1.5)
			"jason":
				hum(p, r, 1.15, Color(0.22, 0.26, 0.2), Color(0.18, 0.18, 0.2), Color(0.88, 0.86, 0.8), Color(0.22, 0.26, 0.2), ph * 0.8)
				em(M_BOX, p.x + rx * 0.32 + fx * 0.25, p.y + 0.65, p.z + rz * 0.32 + fz * 0.25, 0.05, 0.08, 0.6, r, Color(0.75, 0.77, 0.8), 0, 0, 0, 1.5)
				em(M_SPH, p.x + fx * 0.12 + rx * 0.06, p.y + 1.18, p.z + fz * 0.12 + rz * 0.06, 0.03, 0.03, 0.03, 0.0, Color(0.7, 0.1, 0.1))
				em(M_SPH, p.x + fx * 0.12 - rx * 0.06, p.y + 1.18, p.z + fz * 0.12 - rz * 0.06, 0.03, 0.03, 0.03, 0.0, Color(0.7, 0.1, 0.1))
			"michael":
				hum(p, r, 1.15, Color(0.15, 0.2, 0.3), Color(0.15, 0.2, 0.3), Color(0.93, 0.93, 0.9), Color(0.15, 0.2, 0.3), ph * 0.5)
				em(M_SPH, p.x - fx * 0.03, p.y + 1.2, p.z - fz * 0.03, 0.28, 0.14, 0.28, r, Color(0.2, 0.15, 0.1))
				em(M_BOX, p.x + rx * 0.3, p.y + 0.55, p.z + rz * 0.3, 0.03, 0.36, 0.06, r, Color(0.8, 0.82, 0.85), 0, 0, 0, 1.5)
			"t800":
				hum(p, r, 1.15, Color(0.05, 0.05, 0.06), Color(0.08, 0.08, 0.1), Color(0.8, 0.62, 0.5), Color(0.05, 0.05, 0.06), ph * 0.8)
				em(M_BOX, p.x + fx * 0.14, p.y + 1.1, p.z + fz * 0.14, 0.26, 0.06, 0.04, r, Color(0.02, 0.02, 0.02))
				em(M_SPH, p.x + fx * 0.16 + rx * 0.06, p.y + 1.11, p.z + fz * 0.16 + rz * 0.06, 0.04, 0.04, 0.03, 0.0, Color(1.0, 0.1, 0.05), 0, 0, 3.0)
			"hulk":
				hum(p, r, 1.9, Color(0.3, 0.6, 0.22), Color(0.4, 0.2, 0.5), Color(0.3, 0.6, 0.22), Color(0.3, 0.6, 0.22), ph * 0.7)
				em(M_SPH, p.x - fx * 0.03, p.y + 1.9, p.z - fz * 0.03, 0.5, 0.2, 0.5, r, Color(0.06, 0.06, 0.06))
			"ironman":
				hum(p, r, 1.1, Color(0.75, 0.1, 0.08), Color(0.75, 0.1, 0.08), Color(0.85, 0.7, 0.2), Color(0.85, 0.7, 0.2), 0.0)
				em(M_SPH, p.x + fx * 0.15, p.y + 0.6, p.z + fz * 0.15, 0.12, 0.12, 0.05, 0.0, Color(0.6, 0.9, 1.0), 0, 0, 3.0)
				gl(2.0, p.x, p.y - 0.1, p.z, 1.0, 1.0, 0.0, Color(0.7, 0.9, 1.0, 0.9), 0.9)
			"cap":
				hum(p, r, 1.15, Color(0.15, 0.25, 0.6), Color(0.15, 0.25, 0.6), Color(0.15, 0.25, 0.6), Color(0.15, 0.25, 0.6), ph)
				em(M_CYL, p.x + rx * 0.38, p.y + 0.5, p.z + rz * 0.38, 0.62, 0.06, 0.62, 0.0, Color(0.8, 0.1, 0.1))
				em(M_CYL, p.x + rx * 0.38, p.y + 0.52, p.z + rz * 0.38, 0.42, 0.06, 0.42, 0.0, Color(0.95, 0.95, 0.95))
				em(M_CYL, p.x + rx * 0.38, p.y + 0.54, p.z + rz * 0.38, 0.24, 0.06, 0.24, 0.0, Color(0.15, 0.25, 0.7))
				em(M_SPH, p.x + fx * 0.05, p.y + 0.78, p.z + fz * 0.05, 0.12, 0.12, 0.05, r, Color(0.95, 0.95, 0.95))
			"thor":
				hum(p, r, 1.2, Color(0.35, 0.37, 0.42), Color(0.15, 0.15, 0.18), Color(0.95, 0.78, 0.65), Color(0.35, 0.37, 0.42), ph)
				em(M_BOX, p.x - fx * 0.2, p.y + 0.2, p.z - fz * 0.2, 0.55, 0.85, 0.05, r, Color(0.7, 0.08, 0.08))
				em(M_SPH, p.x - fx * 0.05, p.y + 1.15, p.z - fz * 0.05, 0.36, 0.3, 0.36, r, Color(0.85, 0.7, 0.35))
				em(M_BOX, p.x + rx * 0.35, p.y + 0.6, p.z + rz * 0.35, 0.2, 0.15, 0.32, r, Color(0.55, 0.57, 0.6), 0, 0, 0, 1.5)
				if fmod(anim_time + float(st["side"]), 6.0) < 0.25:
					gl(2.0, p.x + rx * 0.35, p.y + 3.0, p.z + rz * 0.35, 1.0, 1.0, 0.0, Color(0.7, 0.85, 1.0, 1.0), 6.0)
					em(M_BOX, p.x + rx * 0.35, p.y + 0.7, p.z + rz * 0.35, 0.08, 9.0, 0.08, 0.3, Color(0.8, 0.9, 1.0), 0, 0, 4.0)
			"buster":
				hum(p, r, 1.05, Color(0.6, 0.55, 0.42), Color(0.6, 0.55, 0.42), Color(0.87, 0.66, 0.5), Color(0.6, 0.55, 0.42), ph)
				em(M_BOX, p.x - fx * 0.2, p.y + 0.5, p.z - fz * 0.2, 0.36, 0.55, 0.22, r, Color(0.12, 0.12, 0.13))
				if fmod(anim_time + float(st["side"]) * 2.0, 4.0) < 1.2:
					em(M_BOX, p.x + fx * 1.6 + rx * 0.2, p.y + 0.9, p.z + fz * 1.6 + rz * 0.2, 0.05, 0.05, 3.0, r, Color(1.0, 0.55, 0.2), 0, 0, 3.0)
			"ghost":
				var gy := p.y + 2.2 + sin(anim_time * 2.0 + float(st["side"])) * 0.5
				em(M_SPH, p.x, gy, p.z, 1.1, 1.2, 1.0, r, Color(0.45, 0.9, 0.3), 0, 0, 0.8)
				em(M_SPH, p.x + fx * 0.45, gy + 0.5, p.z + fz * 0.45, 0.35, 0.3, 0.1, r, Color(0.15, 0.3, 0.1))
			"vader":
				hum(p, r, 1.25, Color(0.03, 0.03, 0.04), Color(0.03, 0.03, 0.04), Color(0.05, 0.05, 0.06), Color(0.03, 0.03, 0.04), ph * 0.6)
				em(M_CONE, p.x - fx * 0.1, p.y, p.z - fz * 0.1, 0.9, 1.3, 0.9, 0.0, Color(0.02, 0.02, 0.03))
				em(M_SPH, p.x, p.y + 1.15, p.z, 0.4, 0.32, 0.4, r, Color(0.03, 0.03, 0.04), 0, 0, 0, 1.5)
				em(M_BOX, p.x + rx * 0.35 + fx * 0.3, p.y + 0.75, p.z + rz * 0.35 + fz * 0.3, 0.06, 0.06, 1.0, r, Color(1.0, 0.1, 0.08), 0, 0, 4.0)
			"trooper":
				hum(p, r, 1.1, Color(0.93, 0.93, 0.93), Color(0.93, 0.93, 0.93), Color(0.95, 0.95, 0.95), Color(0.93, 0.93, 0.93), ph)
				em(M_BOX, p.x + fx * 0.13, p.y + 1.0, p.z + fz * 0.13, 0.2, 0.05, 0.04, r, Color(0.05, 0.05, 0.05))
			"spidey":
				hum(p, r, 1.05, Color(0.8, 0.1, 0.1), Color(0.12, 0.2, 0.6), Color(0.8, 0.1, 0.1), Color(0.8, 0.1, 0.1), ph * 1.3)
				em(M_SPH, p.x + fx * 0.1 + rx * 0.07, p.y + 1.0, p.z + fz * 0.1 + rz * 0.07, 0.08, 0.06, 0.04, r, Color(0.95, 0.95, 0.95))
				em(M_SPH, p.x + fx * 0.1 - rx * 0.07, p.y + 1.0, p.z + fz * 0.1 - rz * 0.07, 0.08, 0.06, 0.04, r, Color(0.95, 0.95, 0.95))
				if jy > 0.0:
					em(M_BOX, p.x, p.y + 1.0, p.z, 0.02, 8.0, 0.02, 0.0, Color(0.95, 0.95, 0.95))
			"minion":
				em(M_CYL, p.x, p.y + 0.1, p.z, 0.4, 0.55, 0.4, 0.0, Color(0.98, 0.85, 0.15))
				em(M_SPH, p.x, p.y + 0.55, p.z, 0.4, 0.3, 0.4, 0.0, Color(0.98, 0.85, 0.15))
				em(M_CYL, p.x, p.y, p.z, 0.42, 0.28, 0.42, 0.0, Color(0.15, 0.3, 0.65))
				em(M_SPH, p.x + fx * 0.18, p.y + 0.55, p.z + fz * 0.18, 0.18, 0.18, 0.08, r, Color(0.7, 0.72, 0.75), 0, 0, 0, 1.5)
				em(M_BOX, p.x, p.y + 0.12 + absf(sin(ph)) * 0.08, p.z, 0.08, 0.12, 0.08, 0.0, Color(0.08, 0.08, 0.08))
			"shrek":
				hum(p, r, 1.6, Color(0.92, 0.88, 0.75), Color(0.45, 0.3, 0.18), Color(0.5, 0.65, 0.2), Color(0.5, 0.65, 0.2), ph * 0.7)
				em(M_BOX, p.x - fx * 0.05, p.y + 0.8, p.z - fz * 0.05, 0.6, 0.6, 0.42, r, Color(0.35, 0.22, 0.12))
				em(M_CYL, p.x + rx * 0.2, p.y + 1.85, p.z + rz * 0.2, 0.08, 0.15, 0.08, 0.0, Color(0.5, 0.65, 0.2))
				em(M_CYL, p.x - rx * 0.2, p.y + 1.85, p.z - rz * 0.2, 0.08, 0.15, 0.08, 0.0, Color(0.5, 0.65, 0.2))
			"burro":
				em(M_BOX, p.x, p.y + 0.4, p.z, 0.4, 0.5, 1.0, r, Color(0.5, 0.5, 0.52))
				em(M_BOX, p.x + fx * 0.6, p.y + 0.8, p.z + fz * 0.6, 0.3, 0.35, 0.5, r, Color(0.5, 0.5, 0.52))
				em(M_BOX, p.x + fx * 0.5, p.y + 1.15, p.z + fz * 0.5, 0.06, 0.4, 0.06, r, Color(0.4, 0.4, 0.42))
				for k in 4:
					em(M_BOX, p.x + rx * (0.14 if k % 2 == 0 else -0.14) + fx * (0.35 if k < 2 else -0.35), p.y, p.z + rz * (0.14 if k % 2 == 0 else -0.14) + fz * (0.35 if k < 2 else -0.35), 0.1, 0.45, 0.1, r, Color(0.4, 0.4, 0.42))
			"trex", "godzilla":
				var s := 3.2 if who == "trex" else 9.0
				var bc := Color(0.4, 0.42, 0.25) if who == "trex" else Color(0.18, 0.22, 0.2)
				var stp := sin(ph * 0.35) * 0.25 * s
				for sg in [-1.0, 1.0]:
					var g: float = sg
					em(M_BOX, p.x + rx * g * 0.3 * s + fx * stp * g, p.y, p.z + rz * g * 0.3 * s + fz * stp * g, 0.3 * s, 0.8 * s, 0.4 * s, r, bc.darkened(0.15))
				if who == "trex":
					em(M_SPH, p.x, p.y + 0.7 * s, p.z, 0.8 * s, 0.8 * s, 1.6 * s, r, bc)
					em(M_BOX, p.x + fx * 1.0 * s, p.y + 1.15 * s, p.z + fz * 1.0 * s, 0.5 * s, 0.45 * s, 0.8 * s, r, bc)
					em(M_BOX, p.x + fx * 1.05 * s, p.y + 1.0 * s, p.z + fz * 1.05 * s, 0.42 * s, 0.12 * s, 0.75 * s, r, Color(0.85, 0.2, 0.15))
					em(M_BOX, p.x - fx * 1.4 * s, p.y + 0.8 * s, p.z - fz * 1.4 * s, 0.3 * s, 0.3 * s, 1.4 * s, r + sin(ph * 0.3) * 0.2, bc)
				else:
					em(M_SPH, p.x, p.y + 0.6 * s, p.z, 1.0 * s, 1.5 * s, 0.9 * s, r, bc)
					em(M_SPH, p.x + fx * 0.2 * s, p.y + 1.9 * s, p.z + fz * 0.2 * s, 0.45 * s, 0.4 * s, 0.55 * s, r, bc)
					em(M_BOX, p.x - fx * 1.2 * s, p.y + 0.3 * s, p.z - fz * 1.2 * s, 0.4 * s, 0.35 * s, 1.6 * s, r, bc)
					for k in 4:
						em(M_CONE, p.x - fx * (0.45 + k * 0.12) * s, p.y + (1.75 - k * 0.3) * s, p.z - fz * (0.45 + k * 0.12) * s, 0.22 * s, 0.4 * s, 0.22 * s, 0.0, Color(0.6, 0.75, 0.8).lerp(bc, 0.5), 0, 0, nf * 1.5)
					if fmod(anim_time, 9.0) < 1.5:
						em(M_BOX, p.x + fx * 4.5 * s, p.y + 1.9 * s, p.z + fz * 4.5 * s, 0.3 * s, 0.3 * s, 8.0 * s, r, Color(0.4, 0.75, 1.0), 0, 0, 4.0)
		if close and who in KILLERS and nf > 0.4:
			gl(2.0, p.x, p.y + 1.2, p.z, 1.0, 1.0, 0.0, Color(1.0, 0.1, 0.05, 0.5), 1.2)
# ================================================================ src/ui.gd
# Interfaz: HUD, abanico, bandejas, hojas, tarjetas, tutorial e íconos.
const ROAD_NAMES := ["", "Tierra", "Calle", "Avenida", "Autopista"]
const ZONE_NAMES := ["", "Residencial", "Comercial", "Industrial", "Mixta"]
const DEPTS := ["Policía", "Bomberos", "Salud", "Educación", "Parques", "Transporte", "Basura"]
const DISTRICT_RULES := ["Sin regla", "Densa", "Verde", "Tranquila", "24 horas"]
const MAP_KINDS := ["Río", "Lago", "Costa", "Islas", "Llanura"]
var scrolls: Array = []
var scroll_act: ScrollContainer = null
var scroll_coast: ScrollContainer = null
var scroll_vel: float = 0.0
func scroll_at(p: Vector2) -> ScrollContainer:
	for s in scrolls:
		var sc: ScrollContainer = s
		if sc.is_visible_in_tree():
			var r := sc.get_global_rect()
			if Rect2(r.position * ui_scale, r.size * ui_scale).has_point(p):
				return sc
	return null
func slider_under(n: Node, p: Vector2) -> bool:
	for c in n.get_children():
		if c is Slider:
			var r: Rect2 = c.get_global_rect()
			if Rect2(r.position * ui_scale, r.size * ui_scale).has_point(p):
				return true
		if slider_under(c, p):
			return true
	return false
func scroll_input(ev: InputEvent) -> void:
	if ev is InputEventScreenTouch:
		if ev.pressed:
			scroll_act = scroll_at(ev.position)
			scroll_coast = null
			if scroll_act != null and slider_under(scroll_act, ev.position):
				scroll_act = null
		else:
			scroll_coast = scroll_act
			scroll_act = null
	elif ev is InputEventScreenDrag and scroll_act != null and drag_acc > 14.0 * ui_scale:
		var d: Vector2 = ev.relative / ui_scale
		var horiz: bool = scroll_act.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
		var amt: float = d.x if horiz else d.y
		scroll_move(scroll_act, horiz, -amt)
		scroll_vel = lerpf(scroll_vel, -amt / maxf(get_process_delta_time(), 0.004), 0.5)
func scroll_move(sc: ScrollContainer, horiz: bool, amt: float) -> void:
	if horiz:
		sc.scroll_horizontal += roundi(amt)
	else:
		sc.scroll_vertical += roundi(amt)
func scroll_coast_step(delta: float) -> void:
	if scroll_coast == null:
		return
	if absf(scroll_vel) < 30.0 or not scroll_coast.is_visible_in_tree():
		scroll_coast = null
		scroll_vel = 0.0
		return
	scroll_move(scroll_coast, scroll_coast.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED, scroll_vel * delta)
	scroll_vel *= pow(0.04, delta)
func over_ui(pos: Vector2) -> bool:
	for fb in fan_btns:
		if fb.visible and fb.modulate.a > 0.05:
			var fr: Rect2 = fb.get_global_rect()
			if Rect2(fr.position * ui_scale, fr.size * ui_scale).has_point(pos):
				return true
	for c in [hud_col, hud_right, build_btn, bottom_box, side_box, sheet, info_panel, mode_bar, drive_bar, follow_panel, tut_panel, card_panel, start_panel]:
		var cc: Control = c
		if cc.visible:
			var r := cc.get_global_rect()
			var rr := Rect2(r.position * ui_scale, r.size * ui_scale)
			if rr.has_point(pos):
				return true
	return false
var ui_layer: CanvasLayer
var ui_root: Control
var ui_theme: Theme
var top_bar: PanelContainer
var hud_col: VBoxContainer
var hud_detail: VBoxContainer
var hud_right: HBoxContainer
var hud_chev: Button
var hud_open: bool = false
var hud_state: int = 0
var ui_built: bool = false
var notif_title: Label
var notif_text: Label
var notif_icon: TextureRect
var notif_q: Array = []
var menu_card: PanelContainer
var menu_scroll: ScrollContainer
var city_card: PanelContainer
var obj_card: PanelContainer
var obj_head: Label
var obj_text: Label
var obj_bar: ProgressBar
var obj_rew: Label
var top_rate: Label
var top_clock: Label
var top_stage: Label
var top_stage_bar: ProgressBar
var fan_final: Array = []
var fan_was_open: bool = false
var fan_hold_t: float = 0.0
var fan_dwell: float = 0.0
var fan_c: Vector2 = Vector2.ZERO
var top_pop: Label
var top_date: Label
var top_weather: Label
var top_appr: Label
var rci_bars: Array = []
var speed_btns: Array = []
var news_label: Label
var hint_label: Label
var toast_label: Label
var toast_t: float = 0.0
var cost_label: Label
var bottom_box: VBoxContainer
var cat_btns := {}
var side_box: GridContainer
var sheet_title: Label
var info_body: VBoxContainer
var info_cell: int = -1
var mode_label: Label
var mode_btns: HBoxContainer
var drive_bar: PanelContainer
var drive_label: Label
var follow_panel: PanelContainer
var follow_label: Label
var start_panel: PanelContainer
var start_body: VBoxContainer
var fps_label: Label
var photo_btn: Button
var photo_extra: Array = []
var ui_timer: float = 0.0
var overlay_timer: float = 0.0
var tut_on: bool = false
var tut_step: int = 0
var tut_panel: PanelContainer
var tut_label: Label
const TUT_STEPS := [
	["Tocá Construir, elegí Calles y después Calle.", "cat_roads"],
	["Arrastrá el dedo sobre el pasto para hacer una calle larga.", "roads5"],
	["Ahora tocá Construir, Zonas y elegí Residencial.", "tool_zone"],
	["Tocá un lote al lado de la calle, o arrastrá para marcar varios.", "zoneR"],
	["Tocá Construir, Infra y poné una usina a carbón cerca de la calle.", "power"],
	["Poné una torre de agua. La luz y el agua viajan por las calles.", "water"],
	["Marcá unos lotes comerciales para que la gente trabaje.", "zoneC"],
	["Apretá ▶▶ arriba para que el tiempo pase más rápido. ¡Listo!", "speed"],
]
class Chart extends Control:
	var data: Array = []
	var col := Color(0.4, 0.8, 1.0)
	var title := ""
	var money := false
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.25))
		var font := get_theme_default_font()
		var fs := get_theme_default_font_size()
		draw_string(font, Vector2(10, fs + 4), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 1, 1, 0.85))
		if data.size() < 2:
			draw_string(font, Vector2(10, size.y - 12), "Faltan datos: esperá unos días", HORIZONTAL_ALIGNMENT_LEFT, -1, fs - 4, Color(1, 1, 1, 0.5))
			return
		var lo: float = data[0]
		var hi: float = data[0]
		for v in data:
			lo = minf(lo, v)
			hi = maxf(hi, v)
		if hi - lo < 0.0001:
			hi = lo + 1.0
		var pts := PackedVector2Array()
		var top := fs + 14.0
		var h := size.y - top - 8.0
		for k in data.size():
			var x := 8.0 + (size.x - 16.0) * k / float(data.size() - 1)
			var y := top + h * (1.0 - (float(data[k]) - lo) / (hi - lo))
			pts.append(Vector2(x, y))
		draw_polyline(pts, col, 3.0, true)
		var last: float = data[data.size() - 1]
		var txt := str(snappedf(last, 0.01))
		if money:
			txt = str(int(last))
		draw_string(font, Vector2(size.x - 160, fs + 4), txt, HORIZONTAL_ALIGNMENT_RIGHT, 150, fs, col)
const COL_BG := Color(0.17, 0.12, 0.09, 0.92)
const COL_BTN := Color(0.37, 0.27, 0.19, 0.96)
const COL_ACC := Color(1.0, 0.78, 0.32)
const COL_ACC_DK := Color(0.2, 0.12, 0.05)
func sbox(col: Color, radius: int = 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = col
	s.set_corner_radius_all(radius)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s
func sbtn(col: Color, border: Color = Color(1, 1, 1, 0.16)) -> StyleBoxFlat:
	var s := sbox(col, 18)
	s.set_border_width_all(2)
	s.border_color = border
	s.shadow_color = Color(0, 0, 0, 0.4)
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 3)
	return s
func ssel(col: Color = COL_ACC, radius: int = 18) -> StyleBoxFlat:
	var s := sbtn(col, Color(1, 1, 1, 0.55))
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(1.0, 0.78, 0.32, 0.45)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 0)
	return s
func make_knob(r: int, col: Color) -> ImageTexture:
	var img := Image.create(r * 2, r * 2, false, Image.FORMAT_RGBA8)
	for y in r * 2:
		for x in r * 2:
			var d := Vector2(x + 0.5 - r, y + 0.5 - r).length()
			var a := clampf(r - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(col.r, col.g, col.b, a))
	return ImageTexture.create_from_image(img)
func make_theme() -> void:
	var t := ui_theme
	t.set_stylebox("normal", "Button", sbtn(COL_BTN))
	t.set_stylebox("hover", "Button", sbtn(COL_BTN))
	t.set_stylebox("pressed", "Button", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	t.set_stylebox("hover_pressed", "Button", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	t.set_stylebox("disabled", "Button", sbtn(Color(0.25, 0.19, 0.14, 0.6)))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", Color(1.0, 0.97, 0.9))
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", COL_ACC_DK)
	t.set_color("font_hover_pressed_color", "Button", COL_ACC_DK)
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.4))
	t.set_stylebox("panel", "PanelContainer", sbox(COL_BG, 18))
	t.set_stylebox("normal", "TextEdit", sbox(Color(0.1, 0.07, 0.05, 0.9), 10))
	t.set_stylebox("focus", "TextEdit", sbox(Color(0.1, 0.07, 0.05, 0.9), 10))
	t.set_stylebox("slider", "HSlider", sbox(Color(1, 1, 1, 0.16), 6))
	var fill := sbox(COL_ACC, 6)
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	for st in ["slider", "grabber_area", "grabber_area_highlight"]:
		var sb: StyleBoxFlat = t.get_stylebox(st, "HSlider")
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
	var kn := make_knob(22, Color(1, 0.95, 0.85))
	t.set_icon("grabber", "HSlider", kn)
	t.set_icon("grabber_highlight", "HSlider", kn)
	t.set_icon("grabber_disabled", "HSlider", kn)
	t.set_constant("separation", "HSeparator", 14)
	t.set_stylebox("separator", "HSeparator", sbox(Color(1, 1, 1, 0.12), 2))
	for sbn in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", sbn, sbox(Color(1, 1, 1, 0.05), 6))
		t.set_stylebox("grabber", sbn, sbox(Color(1, 1, 1, 0.25), 6))
		t.set_stylebox("grabber_highlight", sbn, sbox(Color(1, 1, 1, 0.4), 6))
		t.set_stylebox("grabber_pressed", sbn, sbox(Color(1, 1, 1, 0.5), 6))
func top_style() -> StyleBoxFlat:
	var s := sbox(Color(COL_BG.r, COL_BG.g, COL_BG.b, 0.84), 22)
	s.set_border_width_all(1)
	s.border_color = Color(1, 1, 1, 0.14)
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 3)
	s.corner_radius_top_left = 0
	s.corner_radius_top_right = 0
	return s
func mk_panel(alpha: float = 0.82) -> PanelContainer:
	var p := PanelContainer.new()
	var s := sbox(Color(COL_BG.r, COL_BG.g, COL_BG.b, alpha), 18)
	s.set_border_width_all(1)
	s.border_color = Color(1, 1, 1, 0.12)
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	return p
func chip(l: Label) -> PanelContainer:
	var p := PanelContainer.new()
	var s := sbox(Color(1, 1, 1, 0.08), 14)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return p
func mk_label(t: String, fs: int = 0, col: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = t
	if fs > 0:
		l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
func mk_text(t: String) -> Label:
	var l := mk_label(t)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(300, 0)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l
func mk_btn(t: String, cb: Callable, minw: int = 0) -> Button:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = Vector2(minw, 56)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func():
		if drag_acc > 14.0 * ui_scale:
			return
		crumb("botón " + t.replace("\n", " "))
		sfx("click")
		cb.call())
	press_fx(b)
	return b
func reg_scroll(sc: ScrollContainer) -> void:
	scrolls.append(sc)
	sc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for sb in [sc.get_v_scroll_bar(), sc.get_h_scroll_bar()]:
		var bar: ScrollBar = sb
		bar.modulate.a = 0.0
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.custom_minimum_size.x = 8
		bar.value_changed.connect(func(_v: float):
			bar.modulate.a = 1.0
			if bar.has_meta("tw"):
				bar.get_meta("tw").kill()
			var tw := bar.create_tween()
			tw.tween_interval(0.7)
			tw.tween_property(bar, "modulate:a", 0.0, 0.4)
			bar.set_meta("tw", tw))
func press_fx(b: Button) -> void:
	b.resized.connect(func(): b.pivot_offset = b.size * 0.5)
	b.button_down.connect(func():
		var tw := b.create_tween()
		tw.tween_property(b, "scale", Vector2(0.93, 0.93), 0.07))
	b.button_up.connect(func():
		var tw := b.create_tween()
		tw.set_trans(Tween.TRANS_BACK)
		tw.set_ease(Tween.EASE_OUT)
		tw.tween_property(b, "scale", Vector2.ONE, 0.22))
func pop_in(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	c.modulate.a = 0.0
	c.scale = Vector2(0.95, 0.95)
	var tw := c.create_tween()
	tw.set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, 0.16)
	tw.tween_property(c, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
func mk_round(t: String, cb: Callable) -> Button:
	var b := mk_btn("" if t.begins_with("@") else t, cb, 84)
	if t.begins_with("@"):
		add_btn_icon(b, t.substr(1), 62)
	b.custom_minimum_size = Vector2(84, 84)
	b.set_meta("round", true)
	b.add_theme_font_size_override("font_size", 34)
	for st in ["normal", "hover"]:
		var n := sbtn(COL_BTN)
		n.set_corner_radius_all(42)
		b.add_theme_stylebox_override(st, n)
	for st in ["pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(st, ssel(COL_ACC, 42))
	return b
func mk_ibtn(icon: String, lab: String, cb: Callable, w: int, h: int, isz: int = 34) -> Button:
	var b := mk_btn("", func():
		crumb("botón " + lab)
		cb.call(), w)
	b.custom_minimum_size = Vector2(w, h)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", -2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var li: Control = mk_ico(icon.substr(1), int(isz * 1.6)) if icon.begins_with("@") else mk_label(icon, isz)
	if li is Label:
		li.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var lt := mk_label(lab, maxi(int(opts["text"]) - 5, 13))
	lt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(li)
	v.add_child(lt)
	b.add_child(v)
	b.set_meta("lbls", [li, lt])
	return b
func mk_main(t: String, cb: Callable) -> Button:
	var b := mk_btn(t, cb, 0)
	b.custom_minimum_size = Vector2(0, 76)
	b.add_theme_font_size_override("font_size", int(opts["text"]) + 6)
	b.add_theme_stylebox_override("normal", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	b.add_theme_stylebox_override("hover", sbtn(COL_ACC, Color(1, 1, 1, 0.5)))
	b.add_theme_stylebox_override("pressed", sbtn(Color(0.85, 0.62, 0.2), Color(1, 1, 1, 0.5)))
	b.add_theme_color_override("font_color", COL_ACC_DK)
	b.add_theme_color_override("font_hover_color", COL_ACC_DK)
	b.add_theme_color_override("font_pressed_color", COL_ACC_DK)
	return b
func mark_sel(b: Button, on: bool) -> void:
	if b.has_meta("lbls"):
		for l in b.get_meta("lbls"):
			l.add_theme_color_override("font_color", COL_ACC_DK if on else Color.WHITE)
	var rr := 42 if b.has_meta("round") else 18
	if on:
		b.add_theme_stylebox_override("normal", ssel(COL_ACC, rr))
		b.add_theme_stylebox_override("hover", ssel(COL_ACC, rr))
		b.add_theme_color_override("font_color", COL_ACC_DK)
		b.add_theme_color_override("font_hover_color", COL_ACC_DK)
	else:
		b.remove_theme_stylebox_override("normal")
		b.remove_theme_stylebox_override("hover")
		b.remove_theme_color_override("font_color")
		b.remove_theme_color_override("font_hover_color")
func mk_row() -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 8)
	return r
func mk_slider(lo: float, hi: float, stp: float, val: float, cb: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = stp
	s.value = val
	s.custom_minimum_size = Vector2(260, 52)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.value_changed.connect(cb)
	return s
func mk_check(t: String, on: bool, cb: Callable) -> Button:
	var c := Button.new()
	c.toggle_mode = true
	c.alignment = HORIZONTAL_ALIGNMENT_LEFT
	c.focus_mode = Control.FOCUS_NONE
	c.custom_minimum_size = Vector2(0, 58)
	c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	c.set_pressed_no_signal(on)
	c.text = ("✔  " if on else "▢  ") + t
	c.toggled.connect(func(v: bool):
		c.text = ("✔  " if v else "▢  ") + t
		sfx("click")
		cb.call(v))
	return c
func mk_choice(items: Array, sel: int, cb: Callable) -> HBoxContainer:
	var r := mk_row()
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cur := [clampi(sel, 0, items.size() - 1)]
	var lab := mk_label(str(items[cur[0]]), 0, COL_ACC)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var step := func(d: int):
		cur[0] = (cur[0] + d + items.size()) % items.size()
		lab.text = str(items[cur[0]])
		cb.call(cur[0])
	r.add_child(mk_btn("◀", func(): step.call(-1), 64))
	r.add_child(lab)
	r.add_child(mk_btn("▶", func(): step.call(1), 64))
	return r
func clear_box(b: Node) -> void:
	for ch in b.get_children():
		b.remove_child(ch)
		ch.queue_free()
var crumb_last: String = ""
var crumb_f: FileAccess = null
func crumb(t: String) -> void:
	if t == crumb_last:
		return
	crumb_last = t
	if crumb_f == null:
		crumb_f = FileAccess.open("user://ultimo_paso.txt", FileAccess.WRITE)
		if crumb_f == null:
			return
	crumb_f.seek(0)
	var mem := "%dMB mem, %dMB video, %ds, cuadro %d" % [OS.get_static_memory_usage() / 1048576, int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / 1048576, Time.get_ticks_msec() / 1000, Engine.get_process_frames()]
	crumb_f.store_string(("día %d: %s [%s]" % [day, t, mem]).rpad(200))
	crumb_f.flush()
func build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 5
	add_child(ui_layer)
	ui_root = Control.new()
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(ui_root)
	ui_theme = Theme.new()
	ui_root.theme = ui_theme
	make_theme()
	apply_text_size()
	hud_col = VBoxContainer.new()
	hud_col.add_theme_constant_override("separation", 10)
	hud_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(hud_col)
	top_bar = mk_panel(0.86)
	hud_col.add_child(top_bar)
	var mcol := VBoxContainer.new()
	mcol.add_theme_constant_override("separation", 8)
	top_bar.add_child(mcol)
	var mr := mk_row()
	top_money = mk_label("$0", int(opts["text"]) + 12)
	top_rate = mk_label("", int(opts["text"]) - 3, Color(0.55, 0.9, 0.55))
	top_rate.size_flags_vertical = Control.SIZE_SHRINK_END
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_chev = mk_btn("", func(): toggle_hud(), 64)
	hud_chev.custom_minimum_size = Vector2(64, 56)
	add_btn_icon(hud_chev, "chev_dn", 44)
	mr.add_child(top_money)
	mr.add_child(top_rate)
	mr.add_child(sp)
	mr.add_child(hud_chev)
	mcol.add_child(mr)
	hud_detail = VBoxContainer.new()
	hud_detail.add_theme_constant_override("separation", 8)
	mcol.add_child(hud_detail)
	top_pop = mk_label("0")
	top_appr = mk_label("0%")
	top_clock = mk_label("00:00")
	var dr := HFlowContainer.new()
	dr.add_theme_constant_override("h_separation", 14)
	dr.add_theme_constant_override("v_separation", 4)
	var dic := ["people", "happy", "clock"]
	var dl := [top_pop, top_appr, top_clock]
	for k in 3:
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 6)
		hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hb.add_child(mk_ico(dic[k], 34))
		hb.add_child(dl[k])
		dr.add_child(hb)
	hud_detail.add_child(dr)
	var rci := HBoxContainer.new()
	rci.add_theme_constant_override("separation", 6)
	rci.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rcol := [Color(0.35, 0.8, 0.35), Color(0.35, 0.6, 0.95), Color(0.95, 0.75, 0.25)]
	for k in 3:
		var pb := ProgressBar.new()
		pb.min_value = -100
		pb.max_value = 100
		pb.custom_minimum_size = Vector2(96, 30)
		pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pb.show_percentage = false
		pb.add_theme_stylebox_override("fill", sbox(rcol[k], 8))
		pb.add_theme_stylebox_override("background", sbox(Color(1, 1, 1, 0.12), 8))
		pb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pl := mk_label("", 15)
		pl.set_anchors_preset(Control.PRESET_FULL_RECT)
		pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pl.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		pl.add_theme_constant_override("outline_size", 5)
		pb.add_child(pl)
		rci.add_child(pb)
		rci_bars.append([pb, pl])
	hud_detail.add_child(rci)
	city_card = mk_panel(0.86)
	hud_col.add_child(city_card)
	var cv2 := VBoxContainer.new()
	cv2.add_theme_constant_override("separation", 6)
	city_card.add_child(cv2)
	top_stage = mk_label("")
	var shb := HBoxContainer.new()
	shb.add_theme_constant_override("separation", 8)
	shb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shb.add_child(mk_ico("city", 36))
	shb.add_child(top_stage)
	cv2.add_child(shb)
	top_stage_bar = ProgressBar.new()
	top_stage_bar.show_percentage = false
	top_stage_bar.min_value = 0
	top_stage_bar.max_value = 1
	top_stage_bar.custom_minimum_size = Vector2(0, 12)
	top_stage_bar.add_theme_stylebox_override("fill", sbox(COL_ACC, 6))
	top_stage_bar.add_theme_stylebox_override("background", sbox(Color(1, 1, 1, 0.12), 6))
	top_stage_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv2.add_child(top_stage_bar)
	top_date = mk_label("Día 1", int(opts["text"]) - 1, Color(0.95, 0.89, 0.76))
	cv2.add_child(top_date)
	top_weather = mk_label("☀")
	cv2.add_child(top_weather)
	obj_card = mk_panel(0.88)
	hud_col.add_child(obj_card)
	var ov := VBoxContainer.new()
	ov.add_theme_constant_override("separation", 4)
	obj_card.add_child(ov)
	obj_head = mk_label("", int(opts["text"]) - 5, Color(0.86, 0.78, 0.64))
	obj_text = mk_label("", 0, Color.WHITE)
	obj_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	obj_text.custom_minimum_size = Vector2(300, 0)
	obj_bar = ProgressBar.new()
	obj_bar.show_percentage = false
	obj_bar.custom_minimum_size = Vector2(0, 10)
	obj_bar.add_theme_stylebox_override("fill", sbox(Color(0.45, 0.85, 0.5), 5))
	obj_bar.add_theme_stylebox_override("background", sbox(Color(1, 1, 1, 0.12), 5))
	obj_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	obj_rew = mk_label("", int(opts["text"]) - 3, Color(0.86, 0.78, 0.64))
	ov.add_child(obj_head)
	ov.add_child(obj_text)
	ov.add_child(obj_bar)
	ov.add_child(obj_rew)
	top_weather.add_theme_font_size_override("font_size", int(opts["text"]) - 1)
	menu_card = mk_panel(0.9)
	hud_col.add_child(menu_card)
	menu_scroll = ScrollContainer.new()
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(menu_scroll)
	menu_card.add_child(menu_scroll)
	var mg := GridContainer.new()
	mg.columns = 2
	mg.add_theme_constant_override("h_separation", 8)
	mg.add_theme_constant_override("v_separation", 8)
	mg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_scroll.add_child(mg)
	for it in menu_items():
		var cb: Callable = it[1]
		var txt: String = it[0]
		var bt := mk_btn(txt.substr(txt.find(" ") + 1), func():
			set_hud_state(0)
			cb.call(), 0)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bt.custom_minimum_size = Vector2(0, 72)
		bt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		mg.add_child(bt)
	set_hud_state(0)
	hud_right = HBoxContainer.new()
	hud_right.add_theme_constant_override("separation", 10)
	hud_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(hud_right)
	hud_right.add_child(mk_round("@undo", func(): do_undo()))
	var sbt := mk_round("@play", func(): set_speed((speed + 1) % 4))
	speed_btns.append(sbt)
	hud_right.add_child(sbt)
	news_label = mk_label("", 0, Color(1, 1, 1, 0.92))
	news_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	news_label.add_theme_constant_override("outline_size", 6)
	ui_root.add_child(news_label)
	hint_label = mk_label("", 0, Color(1, 0.95, 0.7))
	hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hint_label.add_theme_constant_override("outline_size", 6)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_root.add_child(hint_label)
	toast_label = mk_label("", 0, Color(1, 1, 1))
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_stylebox_override("normal", sbox(Color(0.05, 0.05, 0.08, 0.85), 18))
	toast_label.visible = false
	ui_root.add_child(toast_label)
	fps_label = mk_label("", 18, Color(0.7, 1, 0.7))
	ui_root.add_child(fps_label)
	notif_panel = mk_panel(0.95)
	notif_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_panel.visible = false
	var nh := HBoxContainer.new()
	nh.add_theme_constant_override("separation", 14)
	nh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_icon = mk_ico("trophy", 64) as TextureRect
	var nv := VBoxContainer.new()
	nv.add_theme_constant_override("separation", 0)
	nv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notif_title = mk_label("", int(opts["text"]) - 6, Color(0.95, 0.78, 0.35))
	notif_text = mk_label("", 0, Color.WHITE)
	notif_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notif_text.custom_minimum_size = Vector2(300, 0)
	nv.add_child(notif_title)
	nv.add_child(notif_text)
	nh.add_child(notif_icon)
	nh.add_child(nv)
	notif_panel.add_child(nh)
	ui_root.add_child(notif_panel)
	bottom_box = VBoxContainer.new()
	bottom_box.add_theme_constant_override("separation", 6)
	bottom_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(bottom_box)
	cost_label = mk_label("", 0, Color(1, 0.95, 0.6))
	cost_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	cost_label.add_theme_constant_override("outline_size", 6)
	bottom_box.add_child(cost_label)
	var tray_panel := mk_panel(0.82)
	var tsc := ScrollContainer.new()
	tsc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tsc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	tsc.custom_minimum_size = Vector2(0, 100)
	tray_sc = tsc
	reg_scroll(tsc)
	tray = mk_row()
	tsc.add_child(tray)
	tray_panel.add_child(tsc)
	tray_panel.visible = false
	bottom_box.add_child(tray_panel)
	var icons := {"roads": "@roads", "zones": "@zones", "serv": "@serv", "infra": "@infra", "work": "@work", "fun": "@fun", "quit": "@quit"}
	for c in CATS:
		var key: String = c[0]
		var fb := mk_ibtn(icons[key], c[1], func(): pick_cat(key), 90, 90, 32)
		fb.visible = false
		ui_root.add_child(fb)
		fan_btns.append(fb)
		cat_btns[key] = fb
	build_btn = Button.new()
	build_btn.focus_mode = Control.FOCUS_NONE
	build_btn.custom_minimum_size = Vector2(240, 96)
	var bs := sbtn(COL_ACC, Color(1, 1, 1, 0.6))
	bs.set_corner_radius_all(48)
	bs.shadow_color = Color(1.0, 0.78, 0.32, 0.4)
	bs.shadow_size = 12
	var bp := sbtn(Color(0.85, 0.62, 0.2), Color(1, 1, 1, 0.6))
	bp.set_corner_radius_all(48)
	for st in ["normal", "hover"]:
		build_btn.add_theme_stylebox_override(st, bs)
	for st in ["pressed", "hover_pressed"]:
		build_btn.add_theme_stylebox_override(st, bp)
	var bh := HBoxContainer.new()
	bh.set_anchors_preset(Control.PRESET_FULL_RECT)
	bh.alignment = BoxContainer.ALIGNMENT_CENTER
	bh.add_theme_constant_override("separation", 10)
	bh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bi := mk_ico("crane", 62)
	var bl := mk_label("CONSTRUIR", int(opts["text"]) + 2, COL_ACC_DK)
	bh.add_child(bi)
	bh.add_child(bl)
	build_btn.add_child(bh)
	press_fx(build_btn)
	build_btn.button_down.connect(func(): fan_down())
	build_btn.button_up.connect(func(): fan_up())
	ui_root.add_child(build_btn)
	side_box = GridContainer.new()
	side_box.columns = 1
	side_box.add_theme_constant_override("h_separation", 10)
	side_box.add_theme_constant_override("v_separation", 10)
	ui_root.add_child(side_box)
	side_box.add_child(mk_ibtn("@rotate", "Girar", func(): cam_yaw -= 0.45, 92, 92))
	side_box.add_child(mk_ibtn("@tilt", "Inclinar", func():
		cam_pitch = 0.5 if cam_pitch > 1.0 else (cam_pitch + 0.4 if cam_pitch < 0.9 else 1.25), 92, 92))
	side_box.add_child(mk_ibtn("@zoomin", "Acercar", func(): cam_dist_goal *= 0.75, 92, 92))
	side_box.add_child(mk_ibtn("@zoomout", "Alejar", func(): cam_dist_goal *= 1.33, 92, 92))
	side_box.add_child(mk_ibtn("@eye", "Vistas", func(): show_tray("views"), 92, 92))
	sheet = mk_panel(0.9)
	sheet.visible = false
	ui_root.add_child(sheet)
	var sv2 := VBoxContainer.new()
	sheet.add_child(sv2)
	var sh_head := mk_row()
	sheet_title = mk_label("", 0)
	sheet_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sheet_title.add_theme_font_size_override("font_size", int(opts["text"]) + 6)
	sh_head.add_child(sheet_title)
	sh_head.add_child(mk_btn("✕", func(): close_sheet(), 64))
	sv2.add_child(sh_head)
	var ssc := ScrollContainer.new()
	ssc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(ssc)
	ssc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sv2.add_child(ssc)
	sheet_body = VBoxContainer.new()
	sheet_body.add_theme_constant_override("separation", 10)
	sheet_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ssc.add_child(sheet_body)
	info_panel = mk_panel(0.9)
	info_panel.visible = false
	ui_root.add_child(info_panel)
	var isc := ScrollContainer.new()
	isc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(isc)
	info_panel.add_child(isc)
	info_body = VBoxContainer.new()
	info_body.add_theme_constant_override("separation", 6)
	info_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	isc.add_child(info_body)
	mode_bar = mk_panel(0.9)
	mode_bar.visible = false
	ui_root.add_child(mode_bar)
	var mv := mk_row()
	mode_bar.add_child(mv)
	mode_label = mk_label("")
	mv.add_child(mode_label)
	mode_btns = mk_row()
	mv.add_child(mode_btns)
	drive_bar = mk_panel(0.85)
	drive_bar.visible = false
	ui_root.add_child(drive_bar)
	var dv := mk_row()
	drive_bar.add_child(dv)
	drive_label = mk_label("")
	drive_label.custom_minimum_size = Vector2(260, 0)
	dv.add_child(drive_label)
	dv.add_child(mk_btn("◀ Doblar", func(): drive_turn = -1, 130))
	dv.add_child(mk_btn("Doblar ▶", func(): drive_turn = 1, 130))
	dv.add_child(mk_btn("Más rápido", func():
		if drive != null:
			drive["spd"] = minf(drive["spd"] + 1.0, 7.0), 140))
	dv.add_child(mk_btn("Más lento", func():
		if drive != null:
			drive["spd"] = maxf(drive["spd"] - 1.0, 1.0), 140))
	dv.add_child(mk_btn("Salir", func(): stop_drive(), 100))
	follow_panel = mk_panel(0.88)
	follow_panel.visible = false
	ui_root.add_child(follow_panel)
	var fv := VBoxContainer.new()
	follow_panel.add_child(fv)
	follow_label = mk_text("")
	fv.add_child(follow_label)
	var fr := mk_row()
	fr.add_child(mk_btn("🏠 Su casa", func():
		if follow_ped != null and follow_ped["home"] >= 0:
			cam_follow = null
			cam_goal = cell_pos(follow_ped["home"])
			cam_dist_goal = 40.0, 0))
	fr.add_child(mk_btn("🏢 Su trabajo", func():
		if follow_ped != null and follow_ped["job"] >= 0:
			cam_follow = null
			cam_goal = cell_pos(follow_ped["job"])
			cam_dist_goal = 40.0, 0))
	for fb in fr.get_children():
		fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fv.add_child(fr)
	fv.add_child(mk_btn("Dejar de seguir", func():
		follow_ped = null
		cam_follow = null
		hide_follow_card(), 0))
	tut_panel = mk_panel(0.92)
	tut_panel.add_theme_stylebox_override("panel", sbox(Color(0.15, 0.3, 0.55, 0.92)))
	tut_panel.visible = false
	ui_root.add_child(tut_panel)
	var tv := mk_row()
	tut_panel.add_child(tv)
	tut_label = mk_text("")
	tut_label.custom_minimum_size = Vector2(420, 0)
	tv.add_child(tut_label)
	tv.add_child(mk_btn("Saltar", func(): end_tutorial(), 100))
	card_panel = mk_panel(0.95)
	card_panel.visible = false
	ui_root.add_child(card_panel)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 14)
	card_panel.add_child(cv)
	card_title = mk_label("", 0, Color(1, 0.9, 0.5))
	card_title.add_theme_font_size_override("font_size", int(opts["text"]) + 10)
	card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cv.add_child(card_title)
	card_text = mk_text("")
	card_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_text.custom_minimum_size = Vector2(520, 0)
	cv.add_child(card_text)
	card_btns = mk_row()
	card_btns.alignment = BoxContainer.ALIGNMENT_CENTER
	cv.add_child(card_btns)
	photo_btn = Button.new()
	photo_btn.text = "Salir del modo foto"
	photo_btn.custom_minimum_size = Vector2(240, 56)
	photo_btn.modulate = Color(1, 1, 1, 0.6)
	photo_btn.visible = false
	photo_btn.pressed.connect(func(): set_photo_mode(false))
	photo_btn.modulate = Color(1, 1, 1, 0.75)
	var shoot := mk_btn("📸 Sacar foto", func(): take_photo(), 240)
	var hour_b := mk_btn("🌅 Cambiar la hora", func(): day_timer = fmod(day_timer + DAY_SECONDS / 6.0, DAY_SECONDS * 0.995), 240)
	photo_extra = [shoot, hour_b]
	var pl2 := CanvasLayer.new()
	pl2.layer = 6
	add_child(pl2)
	pl2.add_child(photo_btn)
	for pe in photo_extra:
		pe.visible = false
		pl2.add_child(pe)
	start_panel = mk_panel(0.88)
	start_panel.visible = false
	ui_root.add_child(start_panel)
	var stsc := ScrollContainer.new()
	stsc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reg_scroll(stsc)
	start_panel.add_child(stsc)
	start_body = VBoxContainer.new()
	start_body.add_theme_constant_override("separation", 12)
	start_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stsc.add_child(start_body)
	ui_root.move_child(build_btn, -1)
	for fb in fan_btns:
		ui_root.move_child(fb, -1)
	ui_root.move_child(card_panel, -1)
	ui_root.move_child(toast_label, -1)
	get_viewport().size_changed.connect(layout_ui)
	ui_built = true
	layout_ui()
	refresh_speed_buttons()
func toggle_hud() -> void:
	set_hud_state((hud_state + 1) % 3)
func set_hud_state(n: int) -> void:
	hud_state = n
	hud_open = n == 1
	set_btn_icon(hud_chev, ["chev_dn", "more", "chev_up"][n])
	hud_detail.visible = n == 1
	city_card.visible = n == 1
	obj_card.visible = n == 1 and story and obj_index < OBJECTIVES.size()
	menu_card.visible = n == 2
	if ui_built:
		hud_col.reset_size()
		layout_ui()
func show_hud(on: bool) -> void:
	hud_col.visible = on
	hud_right.visible = on
	bottom_box.visible = on
	side_box.visible = on
	build_btn.visible = on
	if not on:
		close_fan()
func fan_layout() -> void:
	var lefty: bool = opts["lefty"]
	fan_c = build_btn.position + build_btn.size * 0.5
	fan_final.clear()
	var n := fan_btns.size()
	var rad := 330.0
	for k in n:
		var ang := deg_to_rad(lerpf(186.0, 282.0, float(k) / float(n - 1)))
		if lefty:
			ang = PI - ang
		var bsz: Vector2 = fan_btns[k].size
		fan_final.append(fan_c + Vector2(cos(ang), sin(ang)) * rad - bsz * 0.5)
func open_fan() -> void:
	if fan_open:
		return
	fan_open = true
	fan_layout()
	create_tween().tween_property(side_box, "modulate:a", 0.0, 0.15)
	side_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crumb("abanico abierto")
	for k in fan_btns.size():
		var b: Button = fan_btns[k]
		b.visible = true
		b.pivot_offset = b.size * 0.5
		b.position = fan_c - b.size * 0.5
		b.scale = Vector2(0.3, 0.3)
		b.modulate.a = 0.0
		if b.has_meta("tw"):
			b.get_meta("tw").kill()
		var tw := b.create_tween()
		tw.set_parallel(true)
		tw.tween_property(b, "position", fan_final[k], 0.3).set_delay(k * 0.025).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(b, "scale", Vector2.ONE, 0.3).set_delay(k * 0.025).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(b, "modulate:a", 1.0, 0.15).set_delay(k * 0.025)
		b.set_meta("tw", tw)
func close_fan() -> void:
	if not fan_open:
		return
	fan_open = false
	fan_hover = ""
	create_tween().tween_property(side_box, "modulate:a", 1.0, 0.2)
	for k in fan_btns.size():
		var b: Button = fan_btns[k]
		if b.has_meta("tw"):
			b.get_meta("tw").kill()
		var tw := b.create_tween()
		tw.set_parallel(true)
		tw.tween_property(b, "position", fan_c - b.size * 0.5, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_property(b, "scale", Vector2(0.3, 0.3), 0.18)
		tw.tween_property(b, "modulate:a", 0.0, 0.16)
		tw.chain().tween_callback(func(): b.visible = fan_open)
		b.set_meta("tw", tw)
	for k in cat_btns:
		if k != cur_cat:
			mark_sel(cat_btns[k], false)
func fan_down() -> void:
	fan_hold = true
	fan_hold_t = 0.0
	fan_was_open = fan_open
	fan_dwell = 0.0
func fan_up() -> void:
	if not fan_hold:
		return
	fan_hold = false
	if fan_hover != "":
		var k := fan_hover
		fan_hover = ""
		pick_cat(k)
		return
	if fan_hold_t < 0.25:
		if fan_was_open:
			close_fan()
		else:
			open_fan()
	elif fan_open and not fan_was_open:
		close_fan()
func fan_process(delta: float) -> void:
	if not fan_hold:
		return
	fan_hold_t += delta
	if not fan_open and fan_hold_t > 0.25:
		open_fan()
	if not fan_open:
		return
	var mp := finger_pos / ui_scale
	var hov := ""
	for k in fan_btns.size():
		if fan_btns[k].get_global_rect().grow(10.0).has_point(mp):
			hov = CATS[k][0]
	if hov != fan_hover:
		fan_hover = hov
		fan_dwell = 0.0
		for k in cat_btns:
			mark_sel(cat_btns[k], k == hov or (hov == "" and k == cur_cat))
		if hov != "":
			sfx("click")
	elif hov != "":
		fan_dwell += delta
		if fan_dwell > 0.5:
			fan_hold = false
			fan_hover = ""
			pick_cat(hov)
func pick_cat(key: String) -> void:
	fan_hover = ""
	close_fan()
	toggle_cat(key)
func apply_text_size() -> void:
	ui_theme.default_font_size = int(opts["text"])
var sheet_avail: float = 600.0
func fit_sheet() -> void:
	if not sheet.visible:
		return
	var hh := minf(sheet_avail, sheet_body.get_combined_minimum_size().y + 110.0)
	if absf(sheet.size.y - hh) > 2.0:
		sheet.size = Vector2(sheet.size.x, hh)
func layout_ui() -> void:
	var vs := get_viewport().get_visible_rect().size
	ui_scale = clampf(minf(vs.x, vs.y) / 1000.0 * [1.0, 1.25, 1.5][clampi(int(opts["ui_size"]), 0, 2)], 0.5, 2.8)
	ui_layer.scale = Vector2(ui_scale, ui_scale)
	var w := vs.x / ui_scale
	var h := vs.y / ui_scale
	ui_root.position = Vector2.ZERO
	ui_root.size = Vector2(w, h)
	var lefty: bool = opts["lefty"]
	var hw := minf(450.0, w * 0.56)
	hud_col.custom_minimum_size = Vector2(hw, 0)
	hud_col.size = Vector2(hw, 0)
	menu_scroll.custom_minimum_size = Vector2(0, clampf(h - 300.0, 220.0, 620.0))
	hud_col.reset_size()
	var hm := hud_col.get_combined_minimum_size()
	hud_col.size = Vector2(hw, hm.y)
	hud_col.position = Vector2(w - hw - 14 if lefty else 14, 14)
	hud_right.reset_size()
	var rm := hud_right.get_combined_minimum_size()
	hud_right.position = Vector2(14 if lefty else w - rm.x - 14, 14)
	var tb_h := 14.0 + 84.0 + 10.0
	news_label.position = Vector2(14 if not lefty else 14 + 0.0, 14 + hm.y + 6)
	news_label.size = Vector2(minf(hw + 80, w - 120), 30)
	hint_label.position = Vector2(14, 14 + hm.y + 40)
	hint_label.size = Vector2(minf(hw + 80, w - 120), 30)
	fps_label.position = Vector2(w * 0.5 - 40, 6)
	var bw := 240.0
	build_btn.position = Vector2(14 if lefty else w - bw - 14, h - 96 - 14)
	build_btn.size = Vector2(bw, 96)
	var bm := bottom_box.get_combined_minimum_size()
	bottom_box.position = Vector2(bw + 28 if lefty else 0, h - bm.y)
	bottom_box.size = Vector2(w - bw - 28, bm.y)
	layout_side()
	var sbm := side_box.get_combined_minimum_size()
	var sw := minf(640.0, w - 20.0)
	var avail := h - 14.0 - bm.y - 20
	sheet.position = Vector2(w - sw - 10 if lefty else 10, 14)
	sheet_avail = avail
	sheet.size = Vector2(sw, avail)
	if not started:
		sheet.position = Vector2((w - sw) * 0.5, 14)
		sheet.size = Vector2(sw, h - 28.0)
	sheet_body.custom_minimum_size = Vector2(sw - 50, 0)
	var iw := minf(400.0, w - 110.0)
	info_panel.position = Vector2(sbm.x + 24 if lefty else w - iw - sbm.x - 24, tb_h + 10)
	info_body.custom_minimum_size = Vector2(iw - 50, 0)
	var ih := info_body.get_combined_minimum_size().y + 40.0
	info_panel.size = Vector2(iw, clampf(ih, 120.0, minf(avail - 100.0, 640.0)))
	info_body.custom_minimum_size = Vector2(iw - 50, 0)
	var cw := minf(620.0, w - 30.0)
	card_text.custom_minimum_size = Vector2(cw - 40, 0)
	card_panel.size = Vector2(cw, 0)
	card_panel.reset_size()
	var cs := card_panel.get_combined_minimum_size()
	card_panel.size = Vector2(cw, cs.y)
	card_panel.position = Vector2((w - cw) * 0.5, maxf(tb_h + 20, (h - cs.y) * 0.42))
	var mm2 := mode_bar.get_combined_minimum_size()
	mode_bar.position = Vector2((w - mm2.x) * 0.5, tb_h + 74)
	var dm := drive_bar.get_combined_minimum_size()
	drive_bar.position = Vector2((w - dm.x) * 0.5, h - dm.y - 20)
	var fw := minf(460.0, w - 110.0)
	follow_panel.size = Vector2(fw, 0)
	follow_panel.position = Vector2(sbm.x + 24 if lefty else w - fw - sbm.x - 24, tb_h + 10)
	var tm := tut_panel.get_combined_minimum_size()
	tut_panel.position = Vector2((w - tm.x) * 0.5, tb_h + 74)
	var stw := minf(720.0, w - 20.0)
	start_body.custom_minimum_size = Vector2(stw - 50, 0)
	var sh := minf(h - 40.0, start_body.get_combined_minimum_size().y + 36.0)
	start_panel.position = Vector2((w - stw) * 0.5, maxf(20.0, (h - sh) * 0.4))
	start_panel.size = Vector2(stw, sh)
	photo_btn.position = Vector2(vs.x - 260 * ui_scale, 20 * ui_scale)
	photo_btn.scale = Vector2(ui_scale, ui_scale)
	for k in photo_extra.size():
		var pe: Button = photo_extra[k]
		pe.position = Vector2(vs.x - 260 * ui_scale, (90 + 70 * k) * ui_scale)
		pe.scale = Vector2(ui_scale, ui_scale)
func notify(title: String, text: String, icon: String = "trophy") -> void:
	notif_q.append([title, text, icon])
	if not notif_busy:
		notify_next()
func notify_next() -> void:
	if notif_q.is_empty():
		notif_busy = false
		return
	notif_busy = true
	var it: Array = notif_q.pop_front()
	notif_title.text = it[0]
	notif_text.text = it[1]
	if notif_icon != null and ico(it[2]) != null:
		notif_icon.texture = ico(it[2])
	var w := ui_root.size.x
	var nw := minf(560.0, w - 40.0)
	notif_text.custom_minimum_size = Vector2(nw - 140.0, 0)
	notif_panel.size = Vector2(nw, 0)
	notif_panel.reset_size()
	notif_panel.size.x = nw
	notif_panel.pivot_offset = notif_panel.size * 0.5
	var x := (w - nw) * 0.5
	notif_panel.position = Vector2(x, -notif_panel.size.y - 20.0)
	notif_panel.modulate.a = 1.0
	notif_panel.visible = true
	ui_root.move_child(notif_panel, -1)
	var tw := notif_panel.create_tween()
	tw.tween_property(notif_panel, "position:y", 16.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(3.2)
	tw.tween_property(notif_panel, "position:y", -notif_panel.size.y - 20.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		notif_panel.visible = false
		notify_next())
func toast(t: String) -> void:
	toast_label.text = t
	toast_label.visible = true
	toast_label.modulate = Color(1, 1, 1, 1)
	toast_t = 3.2
	var w := ui_root.size.x
	var fw := minf(700.0, w - 40.0)
	toast_label.size = Vector2(fw, 0)
	toast_label.reset_size()
	toast_label.size.x = fw
	toast_label.position = Vector2((w - fw) * 0.5, ui_root.size.y * 0.6)
func set_cost_hint(t: String) -> void:
	cost_label.text = t
	layout_bottom()
func layout_bottom() -> void:
	var w := ui_root.size.x
	var bw := 240.0
	var lefty: bool = opts["lefty"]
	var bm := bottom_box.get_combined_minimum_size()
	bottom_box.position = Vector2(bw + 28 if lefty else 0, ui_root.size.y - bm.y)
	bottom_box.size = Vector2(w - bw - 28, bm.y)
	layout_side()
	sheet_avail = ui_root.size.y - 14.0 - bm.y - 20.0
	if sheet.visible:
		sheet.size = Vector2(sheet.size.x, minf(sheet.size.y, sheet_avail))
func layout_side() -> void:
	var w := ui_root.size.x
	var h := ui_root.size.y
	var top_y := 14.0 + 84.0 + 18.0
	var avail := h - maxf(bottom_box.get_combined_minimum_size().y, 124.0) - top_y - 10.0
	var n := side_box.get_child_count()
	var rows := maxi(1, int(avail / 102.0))
	side_box.columns = clampi(ceili(float(n) / rows), 1, 3)
	side_box.reset_size()
	var sbm := side_box.get_combined_minimum_size()
	var lefty: bool = opts["lefty"]
	side_box.position = Vector2(12 if lefty else w - sbm.x - 12, top_y)
func add_news(t: String) -> void:
	news.push_front("Día %d: %s" % [day, t])
	if news.size() > 60:
		news.pop_back()
	news_label.text = "📰 " + t
func big_card(title: String, text: String) -> void:
	queue_card({"title": title, "text": text, "btns": [["Bárbaro", Callable()]]})
func marta(text: String) -> void:
	queue_card({"title": "👩‍💼 Marta, tu secretaria", "text": text, "btns": [["Dale", Callable()]]})
func confirm(text: String, yes: Callable) -> void:
	queue_card({"title": "¿Seguro?", "text": text, "btns": [["Sí", yes], ["No", Callable()]]})
func queue_card(c: Dictionary) -> void:
	card_queue.append(c)
	if intro_t >= 0.0:
		return
	if not card_panel.visible:
		next_card()
var card_cur: Dictionary = {}
var card_busy: bool = false
func next_card() -> void:
	card_busy = false
	if card_queue.is_empty():
		card_cur = {}
		card_panel.visible = false
		return
	card_cur = card_queue.pop_front()
	card_title.text = card_cur["title"]
	card_text.text = card_cur["text"]
	clear_box(card_btns)
	var n: int = card_cur["btns"].size()
	for k in n:
		var kk := k
		var cbtn := mk_btn(card_cur["btns"][k][0], func():
			if card_busy:
				return
			card_busy = true
			call_deferred("card_pick", kk), 150)
		cbtn.custom_minimum_size = Vector2(150, 64)
		cbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if k == 0:
			mark_sel(cbtn, true)
		card_btns.add_child(cbtn)
	var was_card := card_panel.visible
	card_panel.visible = true
	layout_ui()
	if not was_card:
		pop_in(card_panel)
func card_pick(k: int) -> void:
	var cb: Callable = Callable()
	if not card_cur.is_empty() and k < card_cur["btns"].size():
		cb = card_cur["btns"][k][1]
	if cb.is_valid():
		cb.call()
	next_card()
func show_decision() -> void:
	if decision == null:
		return
	var d: Array = decision
	var a: Array = d[1]
	var b: Array = d[2]
	queue_card({"title": "🏛 Decisión del intendente", "text": d[0] + "\n\n" + a[0] + ": " + effects_text(a[1]) + "\n" + b[0] + ": " + effects_text(b[1]),
		"btns": [[a[0], func():
			apply_effects(a[1])
			add_news("El intendente decidió: " + a[0])
			decision = null], [b[0], func():
			apply_effects(b[1])
			add_news("El intendente decidió: " + b[0])
			decision = null]]})
func effects_text(e: Dictionary) -> String:
	var parts2: Array = []
	if e.has("money"):
		parts2.append(("+" if e["money"] > 0 else "") + fmt_money(e["money"]))
	if e.has("appr"):
		parts2.append(("más" if e["appr"] > 0 else "menos") + " aprobación")
	if e.has("hp"):
		parts2.append("gente más contenta")
	if e.has("crime"):
		parts2.append("menos crimen")
	if e.has("tour"):
		parts2.append("más turistas")
	if e.has("edu"):
		parts2.append("más educación")
	if e.has("pol"):
		parts2.append("más contaminación")
	if parts2.is_empty():
		return "nada cambia"
	return ", ".join(parts2)
func ask_promise() -> void:
	var btns: Array = []
	for k in PROMISES.size():
		var kk := k
		btns.append([PROMISES[k][0], func(): set_promise(kk)])
	queue_card({"title": "🗳 Se vienen las elecciones", "text": "En 3 días se vota. Elegí una promesa de campaña: si la cumplís, ganás votos. Si no, perdés.", "btns": btns})
func toggle_cat(key: String) -> void:
	if key == "quit":
		show_tray("")
		set_tool({"k": "demolish"})
		return
	if cur_cat == key:
		show_tray("")
	else:
		show_tray(key)
	if tut_on and key == "roads" and tut_step == 0:
		tut_next()
func show_tray(key: String) -> void:
	if key == "quit":
		key = ""
	cur_cat = key
	for k in cat_btns:
		mark_sel(cat_btns[k], k == key)
	clear_box(tray)
	var tp: Control = tray.get_parent().get_parent()
	var was_open := tp.visible
	tp.visible = key != ""
	if key == "":
		layout_bottom()
		return
	var look_b := mk_btn("👆\nMirar", func():
		set_tool({"k": "look"})
		show_tray(""), 96)
	look_b.custom_minimum_size = Vector2(100, 84)
	tray.add_child(look_b)
	var groups: Array = []
	match key:
		"roads":
			for t in range(1, 5):
				var tt := t
				tray.add_child(tool_btn(ROAD_NAMES[t] + "\n" + fmt_money(ROAD_COST[t]), {"k": "road", "t": tt}))
			tray.add_child(tool_btn("Rotonda\n$150", {"k": "round"}))
		"zones":
			for z in range(1, 5):
				var zz := z
				if z == Z_M and not creative and max_stage < 2:
					tray.add_child(lock_btn("Mixta", 2))
					continue
				tray.add_child(tool_btn(ZONE_NAMES[z] + "\n$%d" % ZONE_COST, {"k": "zone", "z": zz}))
			tray.add_child(tool_btn("Quitar zona", {"k": "dezone"}))
		"serv":
			groups = ["serv"]
		"infra":
			tray.add_child(tool_btn("Cables\n$3", {"k": "cable"}))
			tray.add_child(tool_btn("Caños\n$3", {"k": "pipe"}))
			groups = ["util"]
		"work":
			groups = ["tour"]
		"fun":
			tray.add_child(tool_btn("Árboles\n$6", {"k": "trees"}))
			groups = ["park", "wonder"]
		"views":
			var vv := [["", "Normal"], ["power", "Luz"], ["water", "Agua"], ["traffic", "Tránsito"], ["happy", "Felicidad"], ["pollution", "Contaminación"], ["crime", "Crimen"], ["land", "Valor del suelo"], ["fire", "Bomberos"], ["police", "Policía"], ["health", "Salud"], ["edu", "Educación"], ["transit", "Transporte"], ["garbage", "Basura"], ["districts", "Distritos"]]
			for v in vv:
				var vk: String = v[0]
				var b := mk_btn(v[1], func(): set_view(vk), 120)
				b.custom_minimum_size = Vector2(120, 84)
				mark_sel(b, view_mode == vk)
				tray.add_child(b)
	var ids: Array = DEF.keys()
	ids.sort()
	for gname in groups:
		for id in ids:
			var d: Dictionary = DEF[id]
			if d["c"] != gname:
				continue
			if not creative and d["st"] > max_stage:
				tray.add_child(lock_btn(d["n"], d["st"]))
			else:
				tray.add_child(tool_btn(d["n"] + "\n" + fmt_money(d["cost"]), {"k": "def", "id": id}))
	if key == "infra":
		tray.add_child(tool_btn("Bicisenda\n$6", {"k": "bike"}))
		tray.add_child(tool_btn("Vías de tranvía\n$25", {"k": "tram"}))
		tray.add_child(tool_btn("Parada de colectivo\n$60", {"k": "stop", "kind": "bus"}))
		tray.add_child(tool_btn("Parada de tranvía\n$60", {"k": "stop", "kind": "tram"}))
		var lb := mk_btn("🚌\nLíneas", func(): open_transport(), 110)
		lb.custom_minimum_size = Vector2(110, 84)
		tray.add_child(lb)
		for id in ids:
			var d2: Dictionary = DEF[id]
			if d2["c"] != "trans":
				continue
			if not creative and d2["st"] > max_stage:
				tray.add_child(lock_btn(d2["n"], d2["st"]))
			else:
				tray.add_child(tool_btn(d2["n"] + "\n" + fmt_money(d2["cost"]), {"k": "def", "id": id}))
		tray.add_child(tool_btn("Dique\n$40", {"k": "levee"}))
		tray.add_child(tool_btn("Comprar zona\n" + fmt_money(region_price()), {"k": "buy"}))
		tray.add_child(tool_btn("Distritos", {"k": "district"}))
	layout_bottom()
	if not was_open:
		pop_in(tp)
func tool_btn(t: String, tl: Dictionary) -> Button:
	var b := mk_btn(t, func(): set_tool(tl), 120)
	b.custom_minimum_size = Vector2(130, 84)
	mark_sel(b, tool.get("k", "") == tl["k"] and tool.get("id", -1) == tl.get("id", -1) and tool.get("t", -1) == tl.get("t", -1) and tool.get("z", -1) == tl.get("z", -1))
	return b
func lock_btn(n: String, st: int) -> Button:
	var b := mk_btn("🔒 " + n + "\n" + STAGES[st][0], func(): toast(n + " se desbloquea cuando la ciudad sea " + STAGES[st][0] + " (%s vecinos)" % fmt_int(STAGES[st][1])), 120)
	b.custom_minimum_size = Vector2(130, 84)
	b.modulate = Color(1, 1, 1, 0.55)
	return b
func set_tool(t: Dictionary) -> void:
	tool = t
	clear_preview()
	var k: String = t["k"]
	if k != "line" and not line_edit.is_empty():
		line_edit = {}
		mode_bar.visible = false
	var hint := ""
	match k:
		"road":
			hint = "Arrastrá para hacer " + ROAD_NAMES[t["t"]].to_lower() + ". En diagonal también se puede."
		"zone":
			hint = "Tocá una manzana para marcarla entera, o arrastrá un rectángulo."
		"dezone":
			hint = "Arrastrá para quitar zonas."
		"demolish":
			hint = "Arrastrá sobre lo que quieras demoler. Sobre un cerro lo aplana."
		"cable", "pipe", "bike", "tram", "levee":
			hint = "Arrastrá en línea."
		"trees":
			hint = "Arrastrá para plantar árboles."
		"def":
			var d: Dictionary = DEF[t["id"]]
			hint = d["n"] + ": tocá donde lo quieras poner."
			if d.has("need"):
				hint += " Va en la " + ("costa" if d["need"] == "shore" else "arena") + "."
		"round":
			hint = "Tocá un cruce de calles para poner o sacar una rotonda."
		"stop":
			hint = "Tocá una calle para poner la parada."
		"buy":
			hint = "Tocá una zona oscura pegada a la tuya para comprarla."
			view_mode = "districts"
			build_overlay()
		"district":
			hint = "Tocá un barrio para elegir su regla."
			view_mode = "districts"
			build_overlay()
		"look":
			hint = ""
	if k != "buy" and k != "district" and view_mode == "districts" and cur_cat != "views":
		view_mode = ""
		build_overlay()
	hint_label.text = hint
	if cur_cat != "" and cur_cat != "views":
		show_tray(cur_cat)
	if tut_on:
		if tut_step == 2 and k == "zone" and t.get("z", 0) == Z_R:
			tut_next()
func set_view(v: String) -> void:
	view_mode = v
	build_overlay()
	show_tray("views")
func refresh_speed_buttons() -> void:
	var names := ["pause", "play", "play2", "play3"]
	for b in speed_btns:
		set_btn_icon(b, names[clampi(speed, 0, 3)])
		mark_sel(b, speed == 0)
	if tut_on and tut_step == 7 and speed >= 2:
		tut_next()
func take_photo() -> void:
	photo_btn.visible = false
	for pe in photo_extra:
		pe.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	photo_btn.visible = photo_mode
	for pe in photo_extra:
		pe.visible = photo_mode
	var dir := OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	var path := "user://foto_%d.png" % Time.get_unix_time_from_system()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir + "/URBANA")
		path = dir + "/URBANA/foto_%d.png" % Time.get_unix_time_from_system()
	var err := img.save_png(path)
	if err != OK and path.begins_with("user://") == false:
		path = "user://foto_%d.png" % Time.get_unix_time_from_system()
		err = img.save_png(path)
	if err == OK:
		sfx("cash")
		toast("Foto guardada: " + path.get_file())
		photo_extra[0].text = "✔ Guardada"
	else:
		toast("No se pudo guardar la foto")
		photo_extra[0].text = "No se pudo"
	await get_tree().create_timer(1.6).timeout
	photo_extra[0].text = "📸 Sacar foto"
func set_photo_mode(on: bool) -> void:
	photo_mode = on
	ui_layer.visible = not on
	photo_btn.visible = on
	for pe in photo_extra:
		pe.visible = on
	for ll in line_labels:
		ll.visible = false
	if on:
		toast("Modo foto: mové la cámara y sacá una captura")
func open_sheet(title: String, key: String) -> VBoxContainer:
	if not started:
		start_panel.visible = false
	info_panel.visible = false
	sheet_name = key
	sheet_title.text = title
	clear_box(sheet_body)
	var was_vis := sheet.visible
	sheet.visible = true
	layout_ui()
	if not was_vis:
		pop_in(sheet)
	return sheet_body
func close_sheet() -> void:
	sheet.visible = false
	sheet_name = ""
	if not started and not start_panel.visible:
		show_start()
func open_menu() -> void:
	var b := open_sheet(city_name, "menu")
	var items := menu_items()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for it in items:
		var bt := mk_btn(it[0], it[1], 0)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(bt)
	b.add_child(grid)
func open_stats() -> void:
	var b := open_sheet("Estadísticas", "stats")
	b.add_child(mk_text("Etapa: %s · Vecinos: %s · Trabajos: %s · Desocupación: %d%%" % [STAGES[stage][0], fmt_int(pop), fmt_int(jobs), int(unemployment * 100)]))
	b.add_child(mk_text("Felicidad: %d%% · Aprobación: %d%% · Turistas por día: %d" % [int(avg_happy * 100), int(approval * 100), tourists]))
	b.add_child(mk_text("Luz: %s de %s (%d%% limpia) · Agua: %s de %s" % [fmt_int(int(power_use)), fmt_int(int(power_sup)), int(green_power * 100), fmt_int(int(water_use)), fmt_int(int(water_sup))]))
	b.add_child(mk_text("Basura: %s por día, se levantan %s" % [fmt_int(int(garb_made)), fmt_int(int(garb_cap))]))
	b.add_child(mk_text("Viaje promedio al trabajo: %.1f cuadras · En bici o transporte: %d%%" % [avg_commute, int(counters.get("green_share", 0.0) * 100)]))
	b.add_child(mk_text("Clases: %d bajas, %d medias, %d altas" % [classes[0], classes[1], classes[2]]))
	var specs := [["pop", "Vecinos", Color(0.4, 0.85, 0.5), true], ["money", "Plata", Color(1.0, 0.85, 0.3), true], ["happy", "Felicidad", Color(0.95, 0.5, 0.7), false], ["appr", "Aprobación", Color(0.45, 0.7, 1.0), false]]
	for s in specs:
		var ch := Chart.new()
		ch.data = history[s[0]]
		ch.title = s[1]
		ch.col = s[2]
		ch.money = s[3]
		ch.custom_minimum_size = Vector2(0, 170)
		b.add_child(ch)
func open_budget() -> void:
	var b := open_sheet("Presupuesto", "budget")
	b.add_child(mk_text("Plata: %s · Deuda: %s · Balance de ayer: %s" % [fmt_money(money), fmt_money(debt), fmt_money(last_net)]))
	var names := ["Residencial", "Comercial", "Industrial"]
	for k in 3:
		var kk := k
		var lab := mk_label("Impuesto %s: %d%%" % [names[k], tax[k]])
		b.add_child(lab)
		b.add_child(mk_slider(0, 25, 1, tax[k], func(v: float):
			tax[kk] = int(v)
			lab.text = "Impuesto %s: %d%%" % [names[kk], int(v)]))
	b.add_child(mk_text("Los impuestos altos ponen triste a la gente. Entre 7% y 11% anda bien."))
	b.add_child(HSeparator.new())
	for k in DEPTS.size():
		var kk := k
		var lab2 := mk_label("%s: %d%%" % [DEPTS[k], budget[k]])
		b.add_child(lab2)
		b.add_child(mk_slider(50, 150, 5, budget[k], func(v: float):
			budget[kk] = int(v)
			lab2.text = "%s: %d%%" % [DEPTS[kk], int(v)]
			sim_dirty = true))
	b.add_child(HSeparator.new())
	b.add_child(mk_label("Cuentas de ayer"))
	for k in last_budget:
		var v: float = last_budget[k]
		if absf(v) < 0.5:
			continue
		b.add_child(mk_label("%s: %s" % [k, fmt_money(v)], 0, Color(0.6, 1, 0.6) if v > 0 else Color(1, 0.6, 0.55)))
	b.add_child(HSeparator.new())
	var r := mk_row()
	r.add_child(mk_btn("Préstamo $5.000", func():
		take_loan(5000)
		open_budget(), 0))
	r.add_child(mk_btn("Préstamo $20.000", func():
		take_loan(20000)
		open_budget(), 0))
	b.add_child(r)
	if debt > 0:
		b.add_child(mk_btn("Pagar $5.000 de deuda", func():
			if money >= 5000:
				money -= 5000
				debt = maxf(0.0, debt - 5000)
				if debt <= 0.0:
					unlock_ach("nodebt")
				open_budget()
			else:
				toast("No alcanza la plata"), 0))
func open_decrees() -> void:
	var b := open_sheet("Decretos", "decrees")
	b.add_child(mk_text("Cada decreto cuesta plata por día y cambia cómo vive la gente."))
	for d in DECREES:
		var id: String = d["id"]
		b.add_child(mk_check("%s (%s/día)" % [d["n"], fmt_money(d["cost"])], has_decree(id), func(on: bool):
			decrees[id] = on
			sim_dirty = true
			if on:
				add_news("Nuevo decreto: " + d["n"])))
		b.add_child(mk_label("   " + d["d"], int(opts["text"]) - 4, Color(1, 1, 1, 0.7)))
func open_mayor() -> void:
	var b := open_sheet("Intendente", "mayor")
	b.add_child(mk_text("Aprobación: %d%%" % int(approval * 100)))
	var pb := ProgressBar.new()
	pb.value = approval * 100
	pb.custom_minimum_size = Vector2(0, 30)
	b.add_child(pb)
	b.add_child(mk_text("Próximas elecciones: día %d" % next_election if (stage >= 2 or day > 60) else "Las elecciones empiezan cuando la ciudad sea Ciudad chica."))
	if promise >= 0:
		b.add_child(mk_text("Tu promesa: " + PROMISES[promise][0]))
	if request != null:
		b.add_child(mk_text("Pedido de los vecinos: %s en %s (hasta el día %d)" % [request["what"], DISTRICT_NAMES[region_of(request["cell"])], request["until"]]))
		b.add_child(mk_btn("Ir a ver", func():
			cam_goal = cell_pos(request["cell"])
			cam_dist_goal = 70.0
			close_sheet(), 0))
	if decision != null:
		b.add_child(mk_btn("Hay una decisión pendiente", func(): show_decision(), 0))
	b.add_child(HSeparator.new())
	b.add_child(mk_text("La aprobación sube con gente feliz, trabajo y plata en caja. La municipalidad y la casa de gobierno también ayudan."))
	b.add_child(mk_btn("🎉 Hacer un festival (" + fmt_money(800.0 + pop * 0.2) + ")", func(): hold_festival(), 0))
func open_trade() -> void:
	var b := open_sheet("Comercio", "trade")
	b.add_child(mk_text("Comida guardada: %d · Productos: %d" % [int(food_stock), int(prod_stock)]))
	b.add_child(mk_text("Precio de la comida: %s · Productos: %s" % [fmt_money(market[0]), fmt_money(market[1])]))
	b.add_child(mk_text("Comercio con el país: " + ("sí (tenés tren, puerto, aeropuerto o autopista)" if trade_ok else "no. Con estación de tren, puerto o aeropuerto vendés lo que sobra.")))
	b.add_child(HSeparator.new())
	for k in neighbors.size():
		var nb: Dictionary = neighbors[k]
		b.add_child(mk_label("%s · relación %d%%" % [nb["n"], int(nb["rel"])]))
	if offer != null:
		var o: Dictionary = offer
		b.add_child(HSeparator.new())
		b.add_child(mk_text("Oferta: %s quiere %d de %s por día durante %d días, a %s cada uno." % [neighbors[o["nb"]]["n"], o["qty"], "comida" if o["kind"] == "food" else "productos", o["days"], fmt_money(o["price"])]))
		var r := mk_row()
		r.add_child(mk_btn("Aceptar", func():
			contracts.append(offer)
			add_news("Firmamos un contrato con " + neighbors[offer["nb"]]["n"])
			offer = null
			sfx("cash")
			open_trade(), 0))
		r.add_child(mk_btn("Rechazar", func():
			offer = null
			open_trade(), 0))
		b.add_child(r)
	if not contracts.is_empty():
		b.add_child(HSeparator.new())
		b.add_child(mk_label("Contratos"))
		for c in contracts:
			var cc: Dictionary = c
			b.add_child(mk_text("%s: %d de %s, quedan %d días" % [neighbors[c["nb"]]["n"], c["qty"], "comida" if c["kind"] == "food" else "productos", c["days"]]))
			b.add_child(mk_btn("Cancelar este contrato", func():
				confirm("Si lo cancelás, %s se enoja un poco. ¿Seguro?" % neighbors[cc["nb"]]["n"], func():
					contracts.erase(cc)
					neighbors[cc["nb"]]["rel"] = maxf(0.0, neighbors[cc["nb"]]["rel"] - 8.0)
					open_trade()), 0))
	b.add_child(mk_text("Las chacras hacen comida y el frigorífico la convierte en productos. La industria también produce."))
func open_transport() -> void:
	var b := open_sheet("Transporte", "transport")
	b.add_child(mk_text("Para una línea: poné paradas (o estaciones), tocá Nueva línea y después tocá las paradas en orden."))
	var r := HFlowContainer.new()
	for k in ["bus", "tram", "metro", "train", "ferry"]:
		var kk: String = k
		r.add_child(mk_btn("Nueva línea de " + LINE_NAMES[k] + " (" + fmt_money(LINE_COST[k]) + ")", func(): start_line(kk), 0))
	b.add_child(r)
	b.add_child(HSeparator.new())
	if lines.is_empty():
		b.add_child(mk_label("Todavía no hay líneas"))
	for ln in lines:
		var row := mk_row()
		var l := mk_label("Línea %d · %s · %d paradas%s" % [ln["num"], LINE_NAMES[ln["kind"]], ln["stops"].size(), " · ¡cortada!" if ln.get("broken", false) else ""], 0, ln["col"].lightened(0.3))
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		var lref: Dictionary = ln
		row.add_child(mk_btn("Ver", func():
			if lref["pts"].size() > 0:
				cam_goal = lref["pts"][0]
			close_sheet(), 80))
		row.add_child(mk_btn("Quitar", func():
			lines.erase(lref)
			rebuild_rails()
			sim_dirty = true
			open_transport(), 100))
		b.add_child(row)
func start_line(kind: String) -> void:
	close_sheet()
	line_edit = {"kind": kind, "stops": []}
	tool = {"k": "line"}
	mode_label.text = "Línea de " + LINE_NAMES[kind] + ": tocá las paradas en orden"
	clear_box(mode_btns)
	mode_btns.add_child(mk_btn("Terminar", func():
		finish_line()
		if line_edit.is_empty():
			mode_bar.visible = false, 120))
	mode_btns.add_child(mk_btn("Cancelar", func():
		line_edit = {}
		mode_bar.visible = false
		set_tool({"k": "look"}), 120))
	mode_bar.visible = true
	layout_ui()
func open_districts() -> void:
	var b := open_sheet("Distritos", "districts")
	b.add_child(mk_text("Cada zona del mapa es un barrio. Elegí una regla: Densa (edificios un piso más alto, vecinos algo menos contentos), Verde (industria chica, vecinos más contentos, suelo más caro), Tranquila (menos crimen, menos comercio), 24 horas (más comercio, más crimen, vecinos algo menos contentos)."))
	for r in NREG * NREG:
		if owned[r] == 0 and not creative:
			continue
		var rr := r
		b.add_child(mk_label(DISTRICT_NAMES[r], 0, COL_ACC))
		b.add_child(mk_choice(DISTRICT_RULES, district[r], func(v: int):
			district[rr] = v
			sim_dirty = true
			if view_mode == "districts":
				build_overlay()))
func open_district(r: int) -> void:
	if owned[r] == 0 and not creative:
		toast("Ese barrio todavía no es tuyo")
		return
	var b := open_sheet(DISTRICT_NAMES[r], "district")
	b.add_child(mk_text("Regla del barrio:"))
	for k in DISTRICT_RULES.size():
		var kk := k
		var bt := mk_btn(DISTRICT_RULES[k], func():
			district[r] = kk
			sim_dirty = true
			build_overlay()
			open_district(r), 0)
		if district[r] == k:
			mark_sel(bt, true)
		b.add_child(bt)
func open_goals() -> void:
	var b := open_sheet("Logros y retos", "goals")
	if story and obj_index < OBJECTIVES.size():
		var o: Dictionary = OBJECTIVES[obj_index]
		b.add_child(mk_label("Objetivo de Marta (%d de %d)" % [obj_index + 1, OBJECTIVES.size()], 0, Color(1, 0.9, 0.5)))
		b.add_child(mk_text("%s: %d de %d · premio %s" % [o["t"], int(obj_value(o["k"])), o["v"], fmt_money(o["r"])]))
	if scenario > 0:
		b.add_child(mk_label("Escenario: " + SCENARIOS[scenario]["n"], 0, Color(1, 0.9, 0.5)))
		b.add_child(mk_text(SCENARIOS[scenario]["d"]))
	if daily_ch >= 0:
		var ch: Array = DAILY_CHALLENGES[daily_ch]
		b.add_child(mk_label("Reto del día" + (" ✔" if daily_done else ""), 0, Color(1, 0.9, 0.5)))
		b.add_child(mk_text(ch[0] + " · premio $300"))
	b.add_child(HSeparator.new())
	b.add_child(mk_label("Logros: %d de %d" % [achieved.size(), ACHIEVEMENTS.size()]))
	var grid := GridContainer.new()
	grid.columns = 2
	for a in ACHIEVEMENTS:
		var got := achieved.has(a[0])
		grid.add_child(mk_label(("🏆 " if got else "🔒 ") + a[1], int(opts["text"]) - 2, Color.WHITE if got else Color(1, 1, 1, 0.45)))
	b.add_child(grid)
func open_news() -> void:
	var b := open_sheet("📰 El Diario de " + DISTRICT_NAMES[10], "news")
	if news.is_empty():
		b.add_child(mk_label("Todavía no pasó nada"))
	for n in news:
		b.add_child(mk_text(n))
func open_advisors() -> void:
	var b := open_sheet("Asesores", "advisors")
	b.add_child(mk_text("🧑‍💼 Jefe de gabinete: " + advice()))
	var tips: Array = []
	tips.append("⚡ Energía: " + ("todo bien" if power_frac >= 0.99 else "faltan %d%% de luz" % int((1.0 - power_frac) * 100)))
	tips.append("💧 Agua: " + ("todo bien" if water_frac >= 0.99 else "faltan %d%% de agua" % int((1.0 - water_frac) * 100)))
	tips.append("🚗 Tránsito: " + ("fluido" if avg_commute < 12 else "hay embotellamientos: avenidas, rotondas y transporte ayudan"))
	tips.append("🗑 Basura: " + ("al día" if garb_made <= garb_cap else "se acumula, poné más basureros o un relleno"))
	tips.append("💰 Plata: balance de ayer " + fmt_money(last_net))
	tips.append("🏭 Demanda: casas %d%%, comercio %d%%, industria %d%%" % [int(demand[0] * 100), int(demand[1] * 100), int(demand[2] * 100)])
	for t in tips:
		b.add_child(mk_text(t))
func open_saves() -> void:
	var b := open_sheet("Guardar y cargar", "saves")
	for s in range(1, 4):
		var ss := s
		var inf := save_info(s)
		var row := mk_row()
		var l := mk_label("Partida %d: %s" % [s, inf], 0)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(l)
		row.add_child(mk_btn("Guardar", func():
			slot = ss
			save_game(ss)
			toast("Guardado en la partida %d" % ss)
			open_saves(), 110))
		if inf != "vacía":
			row.add_child(mk_btn("Cargar", func():
				confirm("¿Cargar la partida %d? Lo que no guardaste se pierde." % ss, func():
					if load_game(ss):
						close_sheet()
						toast("Partida %d cargada" % ss)), 100))
		b.add_child(row)
		if FileAccess.file_exists(slot_path(s, true)):
			b.add_child(mk_btn("   Recuperar la copia de respaldo de la partida %d" % s, func():
				confirm("¿Volver a la copia anterior de la partida %d?" % ss, func():
					if load_game(ss, true):
						close_sheet()
						toast("Copia de respaldo cargada")), 0))
	b.add_child(HSeparator.new())
	b.add_child(mk_text("Código de la ciudad: copialo para pasárselo a alguien o guardarlo."))
	var box := TextEdit.new()
	box.custom_minimum_size = Vector2(0, 120)
	box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	b.add_child(box)
	var r := mk_row()
	r.add_child(mk_btn("Exportar y copiar", func():
		box.text = export_code()
		DisplayServer.clipboard_set(box.text)
		toast("Código copiado"), 0))
	r.add_child(mk_btn("Importar", func():
		var t := box.text.strip_edges()
		if t == "":
			t = DisplayServer.clipboard_get().strip_edges()
		if import_code(t):
			close_sheet()
			toast("Ciudad cargada")
		else:
			toast("Ese código no sirve"), 0))
	b.add_child(r)
func open_options() -> void:
	var b := open_sheet("Opciones", "options")
	b.add_child(mk_label("Gráficos"))
	b.add_child(mk_choice(["Baja (más rápido)", "Media", "Alta"], opts["quality"], func(v: int):
		opts["quality"] = v
		apply_quality()
		save_opts()))
	b.add_child(mk_label("Tamaño de los botones"))
	b.add_child(mk_choice(["Normal", "Grande", "Enorme"], opts["ui_size"], func(v: int):
		opts["ui_size"] = v
		layout_ui()
		save_opts()))
	b.add_child(mk_label("Si el juego se cierra solo, probá apagar estas cosas:"))
	b.add_child(mk_check("Sombras", opts["g_shadow"], func(on: bool):
		opts["g_shadow"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_check("Agua con ondas y brillo", opts["g_water"], func(on: bool):
		opts["g_water"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_check("Niebla", opts["g_fog"], func(on: bool):
		opts["g_fog"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_check("Autos y gente", opts["g_dyn"], func(on: bool):
		opts["g_dyn"] = on
		apply_quality()
		save_opts()))
	b.add_child(mk_label("Realismo extra (probá cuál anda bien en tu celu):"))
	b.add_child(mk_check("Viento en los árboles", opts["g_wind"], func(on: bool):
		opts["g_wind"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Lluvia y nieve con muchas gotas", opts["g_rain"], func(on: bool):
		opts["g_rain"] = on
		save_opts()))
	b.add_child(mk_check("Sombras de contacto en paredes", opts["g_ao"], func(on: bool):
		opts["g_ao"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Texturas en suelo y paredes", opts["g_detail"], func(on: bool):
		opts["g_detail"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Nubes y sombras de nubes", opts["g_clouds"], func(on: bool):
		opts["g_clouds"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Pasto y flores", opts["g_grass"], func(on: bool):
		opts["g_grass"] = on
		mark_all_dirty()
		save_opts()))
	b.add_child(mk_check("Color de cine y bordes oscuros", opts["g_grade"], func(on: bool):
		opts["g_grade"] = on
		apply_fx()
		save_opts()))
	b.add_child(mk_check("Sonido (se aplica al reiniciar)", opts["g_audio"], func(on: bool):
		opts["g_audio"] = on
		save_opts()))
	b.add_child(mk_check("Música (puede cerrar el juego en algunos celulares)", opts["g_music"], func(on: bool):
		opts["g_music"] = on
		if on:
			start_music()
		save_opts()))
	b.add_child(mk_btn("🛟 Modo seguro (apaga todo eso y pone gráficos bajos)", func():
		opts["g_shadow"] = false
		opts["g_water"] = false
		opts["g_fog"] = false
		opts["g_dyn"] = false
		opts["g_rain"] = false
		opts["g_grade"] = false
		opts["g_detail"] = false
		opts["g_clouds"] = false
		opts["g_grass"] = false
		mark_all_dirty()
		opts["g_audio"] = false
		opts["quality"] = 0
		apply_quality()
		save_opts()
		open_options(), 0))
	b.add_child(mk_check("Mostrar FPS", opts["fps"], func(on: bool):
		opts["fps"] = on
		fps_label.visible = on
		save_opts()))
	b.add_child(mk_check("Ahorrar batería (30 FPS cuando no tocás nada)", opts["idle30"], func(on: bool):
		opts["idle30"] = on
		save_opts()))
	b.add_child(mk_label("Música"))
	b.add_child(mk_slider(0, 1, 0.05, opts["music"], func(v: float):
		opts["music"] = v
		apply_volumes()
		save_opts()))
	b.add_child(mk_label("Sonidos"))
	b.add_child(mk_slider(0, 1, 0.05, opts["sfx"], func(v: float):
		opts["sfx"] = v
		apply_volumes()
		save_opts()))
	b.add_child(mk_label("Accesibilidad"))
	var tl := mk_label("Tamaño del texto: %d" % opts["text"])
	b.add_child(tl)
	b.add_child(mk_slider(14, 30, 1, opts["text"], func(v: float):
		opts["text"] = int(v)
		tl.text = "Tamaño del texto: %d" % int(v)
		apply_text_size()
		layout_ui()
		save_opts()))
	b.add_child(mk_check("Colores para daltonismo", opts["colorblind"], func(on: bool):
		opts["colorblind"] = on
		build_overlay()
		save_opts()))
	b.add_child(mk_check("Modo zurdo (botones a la izquierda)", opts["lefty"], func(on: bool):
		opts["lefty"] = on
		layout_ui()
		save_opts()))
	b.add_child(mk_check("Vuelo de cámara al empezar", opts["intro"], func(on: bool):
		opts["intro"] = on
		save_opts()))
	b.add_child(mk_check("Rotondas automáticas en cruces de avenidas", opts["autoround"], func(on: bool):
		opts["autoround"] = on
		save_opts()))
	b.add_child(mk_check("Vibrar al construir", opts["vibrate"], func(on: bool):
		opts["vibrate"] = on
		save_opts()))
	b.add_child(mk_check("Modo tranquilo (sin incendios ni tormentas)", opts["calm"], func(on: bool):
		opts["calm"] = on
		save_opts()))
	b.add_child(mk_btn("Hacer el tutorial paso a paso", func():
		close_sheet()
		start_tutorial(), 0))
	b.add_child(mk_text("Controles: un dedo mueve o dibuja, dos dedos acercan y giran, dos dedos para arriba o abajo inclinan. En la PC: rueda acerca, botón derecho mueve, botón del medio gira, WASD y QE."))
var info_more: bool = false
func show_info(c: int) -> void:
	if c != info_cell:
		info_more = false
	info_cell = c
	close_sheet()
	clear_box(info_body)
	var head := mk_row()
	var title := ""
	var lines_txt: Array = []
	var a := anchor_of(c)
	if bld[c] > 0:
		var d: Dictionary = DEF[bld[c]]
		title = d["n"]
		var act := def_active(a)
		lines_txt.append("Funciona" if act else "No funciona: " + def_problem(a))
		lines_txt.append("Mantenimiento: %s por día" % fmt_money(d["upk"]))
		if d.has("cap"):
			lines_txt.append("Atiende hasta %s personas" % fmt_int(d["cap"]))
		if d.has("pw"):
			lines_txt.append("Energía: %s" % fmt_int(d["pw"]))
		if d.has("wt"):
			lines_txt.append("Agua: %s" % fmt_int(d["wt"]))
		if d.has("gb"):
			lines_txt.append("Levanta %s de basura" % fmt_int(d["gb"]))
		if d.has("job"):
			lines_txt.append("Empleos: %d" % d["job"])
		if d.has("tour"):
			lines_txt.append("Atrae turistas")
		if d.has("dep"):
			lines_txt.append("Presupuesto de %s: %d%%" % [DEPTS[d["dep"]], budget[d["dep"]]])
	elif zone[c] > 0:
		title = ZONE_NAMES[zone[c]] + (" nivel %d" % lvl[c] if lvl[c] > 0 else " (lote vacío)")
		if zone[c] == Z_R or zone[c] == Z_M:
			lines_txt.append("Viven %d personas" % int(occ[anchor_of(c)] if part[c] >= 0 else occ[c]))
			lines_txt.append("Felicidad: %d%%" % int(happy[c] * 100))
			if why[c] > 0:
				lines_txt.append("Lo que más les molesta: " + WHY_TEXT[why[c]])
			lines_txt.append("Educación: " + ["sin estudios", "primaria", "secundaria", "universidad"][clampi(edu[c], 0, 3)])
		else:
			lines_txt.append("Trabajan hasta %d personas" % zone_cap(zone[c], lvl[c]))
		lines_txt.append("Luz: " + ("sí" if powered[c] else "no") + " · Agua: " + ("sí" if watered[c] else "no"))
		lines_txt.append("Valor del suelo: %d%% · Crimen: %d%% · Contaminación: %d%%" % [int(landv[c] * 100), int(crime[c] * 100), int(pollution[c] * 100)])
		if not road_near(c, 2):
			lines_txt.append("⚠ Necesita una calle cerca para crecer")
		if garbp[c] > 0.5:
			lines_txt.append("⚠ Hay basura acumulada")
	elif road[c] > 0:
		title = street_name(c)
		lines_txt.append(ROAD_NAMES[road[c]] + ((" con rotonda") if wire[c] & W_ROUND else ""))
		lines_txt.append("Tránsito: %d%% de lo que aguanta" % int(tload[c] / road_cap(c) * 100))
		if wire[c] & W_BIKE:
			lines_txt.append("Tiene bicisenda")
		if wire[c] & W_TRAM:
			lines_txt.append("Tiene vías de tranvía")
		if stops.has(c):
			lines_txt.append("Parada de " + LINE_NAMES[stops[c]])
	else:
		title = ["Pasto", "Agua", "Arena", "Cerro"][terr[c]]
		if tree[c] > 0:
			lines_txt.append("Árbol: " + ["", "redondo", "plátano", "jacarandá", "pino", "palo borracho", "palmera", "sauce"][tree[c]])
		lines_txt.append("Valor del suelo: %d%%" % int(landv[c] * 100))
		if terr[c] == T_ROCK:
			lines_txt.append("Es un cerro: no se construye encima hasta aplanarlo.")
	lines_txt.append("Barrio: " + DISTRICT_NAMES[region_of(c)] + ("" if is_owned(c) else " (no es tuyo)"))
	if burn[c] > 0.0:
		lines_txt.append("🔥 ¡Se está quemando!")
	var tl := mk_label(title, int(opts["text"]) + 4, Color(1, 0.9, 0.5))
	tl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.add_child(tl)
	head.add_child(mk_btn("✕", func(): info_panel.visible = false, 64))
	info_body.add_child(head)
	var nshow := lines_txt.size() if info_more else mini(lines_txt.size(), 3)
	for k in nshow:
		var tx := mk_label(lines_txt[k], int(opts["text"]) - 2)
		tx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_body.add_child(tx)
	if nshow < lines_txt.size():
		info_body.add_child(mk_btn("Ver más ▾", func():
			info_more = true
			show_info(c), 0))
	if bld[c] > 0 and wonder_progress.has(a):
		var pr: int = wonder_progress[a]
		if pr < WONDER_STEPS:
			info_body.add_child(mk_text("Obra: %d de %d aportes" % [pr, WONDER_STEPS]))
			info_body.add_child(mk_btn("Aportar " + fmt_money(WONDER_FUND), func():
				fund_wonder(a)
				show_info(c), 0))
		else:
			info_body.add_child(mk_text("¡Inaugurada!"))
	var r := mk_row()
	if stops.has(c):
		r.add_child(mk_btn("Quitar parada", func():
			stops.erase(c)
			for ln in lines:
				ln["stops"] = ln["stops"].filter(func(s): return s != c)
				route_line(ln)
			sim_dirty = true
			info_panel.visible = false, 0))
	if terr[c] == T_ROCK and is_owned(c):
		r.add_child(mk_btn("Aplanar ($25)", func():
			if money < 25.0 and not creative:
				toast("No alcanza la plata")
				return
			if not creative:
				money -= 25.0
			flatten_cell(c)
			sim_dirty = true
			sfx("demolish")
			info_panel.visible = false, 0))
	if bld[c] > 0 or zone[c] > 0 or road[c] > 0:
		r.add_child(mk_btn("Demoler", func():
			confirm("¿Demoler esto?", func():
				demolish_cell(c)
				mark_dirty(c)
				sim_dirty = true
				sfx("demolish")
				info_panel.visible = false), 0))
	info_body.add_child(r)
	info_panel.visible = true
	layout_ui()
	call_deferred("layout_ui")
func def_problem(a: int) -> String:
	var d: Dictionary = DEF[bld[a]]
	if not road_near(a, d["sz"]):
		return "le falta una calle cerca"
	if wonder_progress.has(a) and wonder_progress[a] < WONDER_STEPS:
		return "la obra no terminó"
	if not powered[a] and not d.has("pw"):
		return "no tiene luz"
	return "revisá luz, agua y calle"
func show_drive_ui(on: bool) -> void:
	drive_bar.visible = on
	show_hud(not on)
	close_sheet()
	info_panel.visible = false
	layout_ui()
func set_drive_street(s: String) -> void:
	drive_label.text = "🚗 " + s
func show_follow_card(pd: Dictionary) -> void:
	var t: String = pd["name"] + ", %d años" % pd["age"]
	if pd["kind"] == 1:
		t = pd["name"] + ", %d años" % (6 + int(pd["age"]) % 10)
	if pd["home"] >= 0:
		t += "\nVive en " + DISTRICT_NAMES[region_of(pd["home"])]
		t += "\nFelicidad: %d%%" % int(happy[pd["home"]] * 100)
		if why[pd["home"]] > 0:
			t += "\nLe molesta: " + WHY_TEXT[why[pd["home"]]]
	if pd["job"] >= 0:
		t += "\nTrabaja en " + ZONE_NAMES[zone[pd["job"]]].to_lower() + " de " + DISTRICT_NAMES[region_of(pd["job"])]
	elif pd["kind"] == 1:
		t += "\nVa a la escuela"
	follow_label.text = "🚶 " + t
	follow_panel.visible = true
	layout_ui()
func hide_follow_card() -> void:
	follow_panel.visible = false
func start_tutorial() -> void:
	tut_on = true
	tut_step = 0
	show_tut()
func show_tut() -> void:
	if tut_step >= TUT_STEPS.size():
		end_tutorial()
		marta("¡Terminaste el tutorial! Ahora la ciudad es tuya.")
		return
	tut_label.text = "Paso %d de %d: %s" % [tut_step + 1, TUT_STEPS.size(), TUT_STEPS[tut_step][0]]
	tut_panel.visible = true
	layout_ui()
func tut_next() -> void:
	tut_step += 1
	sfx("cash")
	show_tut()
func end_tutorial() -> void:
	tut_on = false
	tut_panel.visible = false
	opts["tutorial_done"] = true
	save_opts()
func tut_check() -> void:
	if not tut_on or tut_step >= TUT_STEPS.size():
		return
	var k: String = TUT_STEPS[tut_step][1]
	var ok := false
	match k:
		"roads5":
			ok = obj_value("roads") >= 5
		"zoneR":
			ok = zone_count(Z_R) >= 4
		"power":
			ok = counters.get("power", 0.0) >= 1.0
		"water":
			ok = counters.get("water", 0.0) >= 1.0
		"zoneC":
			ok = zone_count(Z_C) >= 3
	if ok:
		tut_next()
func start_reset(back: bool) -> void:
	started = false
	speed = 1
	clear_box(start_body)
	show_hud(false)
	info_panel.visible = false
	sheet.visible = false
	tut_panel.visible = false
	start_panel.visible = true
	if back:
		var bk := mk_btn("←  Volver", func(): show_start(), 0)
		bk.alignment = HORIZONTAL_ALIGNMENT_LEFT
		start_body.add_child(bk)
func show_start() -> void:
	start_reset(false)
	var t := mk_label("URBANA", 72, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	var st := mk_label("Construí tu ciudad", 0, Color(1, 1, 1, 0.8))
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(st)
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 16)
	start_body.add_child(sp)
	var ls := latest_slot()
	if ls > 0:
		start_body.add_child(mk_main("▶  Continuar\n" + save_info(ls), func():
			if load_game(ls):
				enter_game(false)))
	start_body.add_child(mk_main("✚  Nueva ciudad", func(): show_new_game()))
	start_body.add_child(mk_btn("🧪 Ciudad de prueba (para ver autos, gente y luces)", func():
		new_test_city()
		enter_game(false), 0))
	var r := mk_row()
	var b1 := mk_btn("📂 Mis partidas", func(): show_slots(), 0)
	b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b2 := mk_btn("🔑 Código", func(): show_code(), 0)
	b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b3 := mk_btn("⚙ Opciones", func(): open_options(), 0)
	b3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_child(b1)
	r.add_child(b2)
	r.add_child(b3)
	start_body.add_child(r)
	if prev_crumb != "" and not prev_crumb.contains("cierre limpio"):
		var cl := mk_text("La vez anterior el juego se cerró solo. Último paso anotado:\n" + prev_crumb)
		cl.modulate = Color(1, 0.8, 0.5)
		start_body.add_child(cl)
	layout_ui()
func show_new_game() -> void:
	start_reset(true)
	var t := mk_label("Nueva ciudad", 44, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	start_body.add_child(mk_label("Nombre de tu ciudad"))
	var nm := LineEdit.new()
	nm.text = new_opts["name"]
	nm.max_length = 24
	nm.custom_minimum_size = Vector2(0, 60)
	nm.text_changed.connect(func(t: String): new_opts["name"] = t)
	start_body.add_child(nm)
	start_body.add_child(mk_label("Mapa"))
	start_body.add_child(mk_choice(MAP_KINDS, new_opts["map"], func(v: int): new_opts["map"] = v))
	var names: Array = []
	for s2 in SCENARIOS:
		names.append(s2["n"])
	start_body.add_child(mk_label("Cómo arrancás"))
	var dl := mk_text(SCENARIOS[new_opts["scen"]]["d"])
	dl.modulate = Color(1, 1, 1, 0.75)
	start_body.add_child(mk_choice(names, new_opts["scen"], func(v: int):
		new_opts["scen"] = v
		dl.text = SCENARIOS[v]["d"]))
	start_body.add_child(dl)
	start_body.add_child(mk_check("Modo creativo (plata infinita y todo desbloqueado)", new_opts["creative"], func(on: bool): new_opts["creative"] = on))
	start_body.add_child(mk_check("Marta te va guiando (modo historia)", new_opts["story"], func(on: bool): new_opts["story"] = on))
	start_body.add_child(mk_check("Tutorial paso a paso", new_opts["tut"], func(on: bool): new_opts["tut"] = on))
	start_body.add_child(mk_main("🏙  ¡Empezar!", func():
		var ss := free_slot()
		var go := func():
			new_game(new_opts["map"], new_opts["scen"], new_opts["creative"], new_opts["story"], ss)
			enter_game(true)
			if new_opts["tut"]:
				start_tutorial()
		if FileAccess.file_exists(slot_path(ss)):
			confirm("Tenés las 3 partidas ocupadas. Se reemplaza la más vieja (%s). ¿Seguimos?" % save_info(ss), go)
		else:
			go.call()))
	layout_ui()
func show_slots() -> void:
	start_reset(true)
	var t := mk_label("Mis partidas", 44, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	var any := false
	for s in range(1, 4):
		var ss := s
		var inf := save_info(s)
		if inf == "vacía":
			continue
		any = true
		var row := mk_row()
		var bt := mk_btn("Partida %d\n%s" % [s, inf], func():
			if load_game(ss):
				enter_game(false), 0)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bt.custom_minimum_size = Vector2(0, 76)
		row.add_child(bt)
		row.add_child(mk_btn("🗑", func():
			confirm("¿Borrar la partida %d para siempre?" % ss, func():
				DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(ss)))
				DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(ss, true)))
				show_slots()), 76))
		start_body.add_child(row)
	if not any:
		start_body.add_child(mk_text("Todavía no guardaste ninguna ciudad."))
	layout_ui()
func show_code() -> void:
	start_reset(true)
	var t := mk_label("Cargar con un código", 40, COL_ACC)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_body.add_child(t)
	start_body.add_child(mk_text("Pegá acá el código de una ciudad que te pasaron."))
	var box := TextEdit.new()
	box.custom_minimum_size = Vector2(0, 160)
	box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	start_body.add_child(box)
	start_body.add_child(mk_btn("📋 Pegar lo copiado", func(): box.text = DisplayServer.clipboard_get().strip_edges(), 0))
	start_body.add_child(mk_main("Cargar la ciudad", func():
		var tx := box.text.strip_edges()
		if tx == "":
			tx = DisplayServer.clipboard_get().strip_edges()
		if import_code(tx):
			enter_game(false)
		else:
			toast("Ese código no sirve")))
	layout_ui()
func enter_game(fresh: bool) -> void:
	start_panel.visible = false
	show_hud(true)
	started = true
	show_tray("")
	set_tool({"k": "look"})
	fps_label.visible = opts["fps"]
	layout_ui()
	if opts["intro"]:
		start_intro(fresh)
	start_music()
	if fresh and story:
		marta(OBJECTIVES[0]["m"])
	refresh_speed_buttons()
var last_tb: float = 0.0
func ui_process(delta: float) -> void:
	fit_sheet()
	fan_process(delta)
	var tbh := hud_col.get_combined_minimum_size().y
	if absf(tbh - last_tb) > 1.0:
		last_tb = tbh
		layout_ui()
	hud_col.visible = started and not photo_mode and not sheet.visible
	if toast_t > 0.0:
		toast_t -= delta
		if toast_t < 0.6:
			toast_label.modulate = Color(1, 1, 1, maxf(toast_t / 0.6, 0.0))
		if toast_t <= 0.0:
			toast_label.visible = false
	if opts["fps"]:
		fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	ui_timer -= delta
	if ui_timer > 0.0 or not started:
		return
	ui_timer = 0.25
	top_money.text = fmt_money(money) + (" (debe " + fmt_money(debt) + ")" if debt > 0 else "")
	top_money.add_theme_color_override("font_color", Color(1, 0.55, 0.5) if money < 0 else Color.WHITE)
	top_rate.text = ("+" if last_net >= 0.0 else "-") + fmt_money(absf(last_net)) + "/min"
	top_rate.add_theme_color_override("font_color", Color(0.55, 0.9, 0.55) if last_net >= 0.0 else Color(1, 0.55, 0.5))
	top_pop.text = fmt_int(pop)
	var hh := int(hour)
	var mi := int((hour - hh) * 60.0) / 10 * 10
	top_clock.text = "%02d:%02d" % [hh, mi]
	top_date.text = "Día %d · %s año %d%s" % [day, SEASONS[season()], year(), " · domingo" if is_sunday() else ""]
	var nxt: int = STAGES[mini(stage + 1, STAGES.size() - 1)][1]
	top_stage.text = "%s · %s / %s hab." % [STAGES[stage][0], fmt_int(pop), fmt_int(nxt)]
	top_stage_bar.value = clampf(float(pop) / maxf(float(nxt), 1.0), 0.0, 1.0)
	top_weather.text = weather + " · Aprobación %d%%" % int(approval * 100)
	top_appr.text = "%d%%" % int(avg_happy * 100)
	var showobj := hud_open and story and obj_index < OBJECTIVES.size()
	obj_card.visible = showobj
	if showobj:
		var oo: Dictionary = OBJECTIVES[obj_index]
		var ov := minf(obj_value(oo["k"]), float(oo["v"]))
		obj_head.text = "OBJETIVO %d/%d" % [obj_index + 1, OBJECTIVES.size()]
		obj_text.text = oo["t"]
		obj_bar.max_value = oo["v"]
		obj_bar.value = ov
		obj_rew.text = "%d / %d    (+%s)" % [int(ov), int(oo["v"]), fmt_money(oo["r"])]
	var letters := ["R", "C", "I"]
	for k in 3:
		var pb: ProgressBar = rci_bars[k][0]
		var pl: Label = rci_bars[k][1]
		pb.value = demand[k] * 100.0
		pl.text = "%s %d%%" % [letters[k], int(demand[k] * 100)]
	if hint_label.text == "" or hint_label.text.begins_with("Tip:"):
		hint_label.text = "Tip: poné calles y después casas pegadas a ellas." if day <= 2 and tool["k"] == "look" else ""
	if tut_on:
		tut_check()
	if not line_edit.is_empty():
		mode_label.text = "Línea de %s: %d paradas" % [LINE_NAMES[line_edit["kind"]], line_edit["stops"].size()]
	overlay_timer -= 0.25
	if view_mode != "" and overlay_timer <= 0.0:
		overlay_timer = 2.0
		build_overlay()
var _ico_cache: Dictionary = {}
var _ico_src: Dictionary = {}
func lf(x: float, y: float, r: float, s: float = 1.0) -> String:
	return '<g transform="translate(%s %s) rotate(%s) scale(%s)"><path d="M0 0C3-8 13-8 15 0C13 8 3 8 0 0Z" fill="#86a95a" stroke="#4d6b34" stroke-width="1.8"/><path d="M2 0H12" stroke="#4d6b34" stroke-width="1.2" fill="none"/></g>' % [x, y, r, s]
func build_ico_src() -> void:
	var G := '<g stroke="#5a3d28" stroke-width="2.6" stroke-linejoin="round" stroke-linecap="round">'
	_ico_src = {
		"roads": '<path d="M19 52L27 12H37L45 52Z" fill="#8f8b86"/><path d="M32 17V23M32 29V35M32 41V47" stroke="#f0c04a" stroke-width="3.2" fill="none"/>' + lf(46, 46, -35) + lf(18, 40, 215, 0.8),
		"zones": '<path d="M10 32L32 13L54 32Z" fill="#c9573f"/><rect x="15" y="32" width="34" height="21" fill="#f0c9a0"/><rect x="28" y="40" width="9" height="13" fill="#9b6a45"/><rect x="19" y="36" width="7" height="7" fill="#9fcbe0"/>' + lf(50, 30, -50, 0.9),
		"serv": '<rect x="7" y="26" width="35" height="19" rx="3" fill="#c9573f"/><path d="M42 30H51L57 38V45H42Z" fill="#e0715a"/><path d="M11 22H36" fill="none"/><circle cx="19" cy="47" r="5.5" fill="#5a3d28"/><circle cx="47" cy="47" r="5.5" fill="#5a3d28"/>' + lf(10, 20, 200, 0.8),
		"infra": '<path d="M37 7L17 36H30L25 57L47 26H34Z" fill="#f0c04a"/>' + lf(46, 50, 35, 0.9),
		"work": '<rect x="9" y="22" width="46" height="30" rx="5" fill="#9b6a45"/><path d="M24 22V15H40V22" fill="none"/><path d="M9 35H55" fill="none"/><rect x="28" y="32" width="8" height="7" rx="2" fill="#f0c04a"/>' + lf(50, 20, -40, 0.8),
		"fun": '<rect x="29" y="36" width="6" height="19" fill="#9b6a45"/><circle cx="32" cy="25" r="17" fill="#86a95a"/><circle cx="25" cy="30" r="3" fill="#e9a1a1" stroke="none"/><circle cx="38" cy="22" r="3" fill="#e9a1a1" stroke="none"/><circle cx="33" cy="32" r="2.4" fill="#f0c04a" stroke="none"/>',
		"quit": '<path d="M17 23H47L44 55H20Z" fill="#a8a39a"/><rect x="13" y="16" width="38" height="7" rx="3" fill="#c9c4ba"/><path d="M27 11H37V16H27Z" fill="#a8a39a"/><path d="M26 29V49M32 29V49M38 29V49" fill="none"/>' + lf(48, 52, -30, 0.8),
		"rotate": '<path d="M46 22A18 18 0 1 0 50 36" fill="none" stroke-width="7"/><path d="M46 22A18 18 0 1 0 50 36" fill="none" stroke="#6fa3c9" stroke-width="3.4"/><path d="M38 12L54 22L40 32Z" fill="#6fa3c9"/>',
		"tilt": '<path d="M13 52V12L52 52Z" fill="#f0c04a"/><path d="M22 43V29L36 43Z" fill="#f2e3c4"/>' + lf(46, 50, -20, 0.8),
		"zoomin": '<circle cx="27" cy="27" r="16" fill="#cfe6f0"/><path d="M39 39L54 54" stroke-width="7" fill="none"/><path d="M19 27H35M27 19V35" stroke="#56763a" stroke-width="3.6" fill="none"/>',
		"zoomout": '<circle cx="27" cy="27" r="16" fill="#cfe6f0"/><path d="M39 39L54 54" stroke-width="7" fill="none"/><path d="M19 27H35" stroke="#c9573f" stroke-width="3.6" fill="none"/>',
		"eye": '<path d="M5 32C15 15 49 15 59 32C49 49 15 49 5 32Z" fill="#f7f1e2"/><circle cx="32" cy="32" r="10.5" fill="#6fa3c9"/><circle cx="32" cy="32" r="4.5" fill="#5a3d28"/>' + lf(52, 18, -50, 0.8),
		"undo": '<path d="M24 25H39A12 12 0 0 1 39 50H24" fill="none" stroke-width="7"/><path d="M24 25H39A12 12 0 0 1 39 50H24" fill="none" stroke="#e9a1a1" stroke-width="3.4"/><path d="M26 11L10 25L26 39Z" fill="#e9a1a1"/>',
		"pause": '<rect x="16" y="14" width="12" height="36" rx="3" fill="#e9a1a1"/><rect x="36" y="14" width="12" height="36" rx="3" fill="#e9a1a1"/>',
		"play": '<path d="M20 12L54 32L20 52Z" fill="#86a95a"/>',
		"play2": '<path d="M8 14L34 32L8 50Z" fill="#86a95a"/><path d="M30 14L56 32L30 50Z" fill="#86a95a"/>',
		"play3": '<path d="M4 16L23 32L4 48Z" fill="#86a95a"/><path d="M22 16L41 32L22 48Z" fill="#86a95a"/><path d="M40 16L59 32L40 48Z" fill="#86a95a"/>',
		"more": '<circle cx="14" cy="32" r="6" fill="#9b6a45"/><circle cx="32" cy="32" r="6" fill="#9b6a45"/><circle cx="50" cy="32" r="6" fill="#9b6a45"/>',
		"chev_dn": '<path d="M14 24L32 42L50 24" fill="none" stroke-width="8"/><path d="M14 24L32 42L50 24" fill="none" stroke="#86a95a" stroke-width="4"/>',
		"chev_up": '<path d="M14 42L32 24L50 42" fill="none" stroke-width="8"/><path d="M14 42L32 24L50 42" fill="none" stroke="#86a95a" stroke-width="4"/>',
		"people": '<circle cx="32" cy="22" r="10" fill="#e9b88f"/><path d="M12 56C12 36 52 36 52 56Z" fill="#6fa3c9"/>',
		"happy": '<circle cx="32" cy="32" r="22" fill="#f0c04a"/><circle cx="24" cy="26" r="2.6" fill="#5a3d28"/><circle cx="40" cy="26" r="2.6" fill="#5a3d28"/><path d="M21 37C26 47 38 47 43 37" fill="none"/>',
		"clock": '<circle cx="32" cy="32" r="22" fill="#f7f1e2"/><path d="M32 18V32L42 38" fill="none"/>' + lf(48, 12, -60, 0.7),
		"city": '<rect x="8" y="28" width="17" height="27" fill="#cfd8dc"/><rect x="27" y="12" width="17" height="43" fill="#e9b88f"/><rect x="46" y="32" width="11" height="23" fill="#cfd8dc"/><path d="M13 34H20M13 41H20M32 20H39M32 28H39M32 36H39" stroke-width="2.2" fill="none"/>',
		"trophy": '<path d="M20 10H44V26C44 36 38 40 32 40C26 40 20 36 20 26Z" fill="#f0c04a"/><path d="M20 14H10C10 26 14 30 21 30M44 14H54C54 26 50 30 43 30" fill="none"/><path d="M32 40V50M22 54H42" fill="none"/><rect x="24" y="48" width="16" height="6" rx="2" fill="#9b6a45"/>' + lf(46, 46, -30, 0.7),
		"star": '<path d="M32 8L39 25L57 26L43 38L48 56L32 46L16 56L21 38L7 26L25 25Z" fill="#f0c04a"/>',
		"crane": '<rect x="12" y="14" width="9" height="42" fill="#f0c04a"/><path d="M12 14H56V22H12Z" fill="#f0c04a"/><path d="M49 22V37" fill="none"/><rect x="44" y="37" width="10" height="9" fill="#c9573f"/>' + lf(24, 52, -20, 0.8),
	}
	for k in _ico_src:
		_ico_src[k] = G + _ico_src[k] + "</g>"
func ico(n: String) -> ImageTexture:
	if _ico_cache.has(n):
		return _ico_cache[n]
	if _ico_src.is_empty():
		build_ico_src()
	var tex: ImageTexture = null
	if _ico_src.has(n):
		var svg: String = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect x="1" y="1" width="62" height="62" rx="16" fill="#f2e3c4"/>' + _ico_src[n] + "</svg>"
		var img := Image.new()
		if img.load_svg_from_string(svg, 2.0) == OK:
			img.generate_mipmaps()
			tex = ImageTexture.create_from_image(img)
	_ico_cache[n] = tex
	return tex
func mk_ico(n: String, s: int) -> Control:
	var tex := ico(n)
	if tex == null:
		return mk_label("•", s)
	var r := TextureRect.new()
	r.texture = tex
	r.custom_minimum_size = Vector2(s, s)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
func set_btn_icon(b: Control, n: String) -> void:
	if b.has_meta("ico"):
		var r = b.get_meta("ico")
		if r is TextureRect:
			r.texture = ico(n)
func add_btn_icon(b: Button, n: String, s: int) -> void:
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var r := mk_ico(n, s)
	cc.add_child(r)
	b.add_child(cc)
	b.set_meta("ico", r)
func menu_items() -> Array:
	return [
		["📊 Estadísticas", func(): open_stats()], ["💰 Presupuesto e impuestos", func(): open_budget()],
		["🏛 Intendente", func(): open_mayor()], ["📜 Decretos", func(): open_decrees()],
		["🤝 Comercio con vecinos", func(): open_trade()], ["🚌 Transporte", func(): open_transport()],
		["🗺 Distritos", func(): open_districts()], ["🏆 Logros y retos", func(): open_goals()],
		["📰 Diario", func(): open_news()], ["💡 Asesores", func(): open_advisors()],
		["🎉 Hacer un festival", func(): hold_festival()], ["🚗 Manejar por la ciudad", func():
			close_sheet()
			start_drive()],
		["🚶 Seguir a un vecino", func():
			close_sheet()
			follow_citizen()], ["🎬 Vuelta de cine", func():
			close_sheet()
			start_intro(true)],
		["📷 Modo foto", func():
			close_sheet()
			set_photo_mode(true)], ["💾 Guardar y cargar", func(): open_saves()],
		["⚙ Opciones", func(): open_options()], ["🏠 Volver al inicio", func():
			save_game(slot)
			close_sheet()
			show_start()],
	]
# ================================================================ src/audio.gd
# Sonidos y música generados.
const SR := 22050
var sfx_players: Array = []
var sfx_next: int = 0
var sfx_last := {}
var music_players: Array = []
var music_ready: bool = false
func setup_audio() -> void:
	for k in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	if not opts["g_audio"]:
		return
	var lp := [0.0]
	var soft := func(k: float) -> float:
		lp[0] = lp[0] + (randf_range(-1.0, 1.0) - lp[0]) * k
		return lp[0]
	sounds["click"] = make_sound(0.09, func(t: float) -> float:
		return sin(TAU * 520.0 * t) * (1.0 - exp(-t * 900.0)) * exp(-t * 55.0) * 0.45)
	sounds["build"] = make_sound(0.3, func(t: float) -> float:
		return (sin(TAU * 170.0 * t) * 0.5 + soft.call(0.12) * 0.5) * (1.0 - exp(-t * 400.0)) * exp(-t * 14.0) * 0.55)
	sounds["demolish"] = make_sound(0.7, func(t: float) -> float:
		return (soft.call(0.05) * 0.8 + sin(TAU * 62.0 * t) * 0.3) * (1.0 - exp(-t * 60.0)) * exp(-t * 5.0) * 0.5)
	sounds["cash"] = make_sound(0.55, func(t: float) -> float:
		var f := 880.0 if t < 0.12 else 1320.0
		var lt := t if t < 0.12 else t - 0.12
		return sin(TAU * f * t) * (1.0 - exp(-lt * 500.0)) * exp(-lt * 9.0) * 0.3)
	sounds["error"] = make_sound(0.28, func(t: float) -> float:
		return sin(TAU * (210.0 - 60.0 * t) * t) * (1.0 - exp(-t * 300.0)) * exp(-t * 9.0) * 0.35)
	sounds["pop"] = make_sound(0.3, func(t: float) -> float:
		return sin(TAU * (300.0 + 700.0 * t) * t) * (1.0 - exp(-t * 400.0)) * exp(-t * 14.0) * 0.4)
	sounds["hammer"] = make_sound(0.14, func(t: float) -> float:
		return sin(TAU * 300.0 * t) * (1.0 - exp(-t * 800.0)) * exp(-t * 38.0) * 0.4)
	sounds["siren"] = make_sound(1.6, func(t: float) -> float:
		var f := 520.0 + 120.0 * sin(TAU * 0.9 * t)
		return sin(TAU * f * t) * 0.12 * minf(1.0, minf(t * 4.0, (1.6 - t) * 3.0)))
	sounds["horns"] = make_sound(1.4, func(t: float) -> float:
		var v := 0.0
		for k in 3:
			var st := k * 0.35
			if t > st and t < st + 0.28:
				var lt := t - st
				var e := minf(lt * 25.0, 1.0) * minf((0.28 - lt) * 25.0, 1.0)
				v += (sin(TAU * (330.0 + k * 50.0) * t) + sin(TAU * (415.0 + k * 50.0) * t)) * 0.07 * e
		return v)
	sounds["cheer"] = make_sound(1.5, func(t: float) -> float:
		var env2 := sin(PI * t / 1.5)
		return soft.call(0.22) * env2 * 0.5 * (0.75 + 0.25 * sin(TAU * 5.0 * t)))
	apply_volumes()
func make_sound(dur: float, f: Callable) -> Dictionary:
	return {"d": dur, "f": f}
func build_sound(dur: float, f: Callable) -> AudioStreamWAV:
	var n := int(dur * SR)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var v: float = f.call(float(i) / SR)
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 30000.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = SR
	s.stereo = false
	s.data = data
	return s
func sfx(nm: String) -> void:
	if not sounds.has(nm) or opts["sfx"] <= 0.01:
		return
	var now := Time.get_ticks_msec()
	if now - sfx_last.get(nm, -1000) < 120:
		return
	sfx_last[nm] = now
	var p: AudioStreamPlayer = sfx_players[sfx_next]
	sfx_next = (sfx_next + 1) % sfx_players.size()
	if sounds[nm] is Dictionary:
		sounds[nm] = build_sound(sounds[nm]["d"], sounds[nm]["f"])
	p.stream = sounds[nm]
	p.volume_db = linear_to_db(opts["sfx"]) - (8.0 if nm == "click" else 0.0)
	p.play()
const SRM := 11025
func start_music() -> void:
	if not opts["g_audio"] or not opts["g_music"]:
		return
	if not music_ready:
		music_ready = true
		build_music()
	apply_volumes()
func music_layer(dur: float, f: Callable) -> AudioStreamWAV:
	var n := int(dur * SRM)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var v: float = f.call(float(i) / SRM)
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 28000.0))
		if i % 6000 == 5999:
			await get_tree().process_frame
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = SRM
	s.stereo = false
	s.data = data
	s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	s.loop_begin = 0
	s.loop_end = n
	return s
func build_music() -> void:
	var chords := [[220.0, 277.18, 329.63], [196.0, 246.94, 293.66], [174.61, 220.0, 261.63], [196.0, 246.94, 329.63]]
	var bar := 2.0
	var dur := bar * 4.0
	var layers: Array = []
	layers.append(await music_layer(dur, func(t: float) -> float:
		var c: Array = chords[int(t / bar) % 4]
		var lt := fmod(t, bar)
		var e := minf(lt * 3.0, 1.0) * minf((bar - lt) * 3.0, 1.0)
		var v := 0.0
		for f in c:
			v += sin(TAU * f * t) * 0.14
		return v * e))
	layers.append(await music_layer(dur, func(t: float) -> float:
		var c: Array = chords[int(t / bar) % 4]
		var lt := fmod(t, 0.5)
		return sin(TAU * c[0] * 0.5 * t) * 0.35 * exp(-lt * 4.0)))
	layers.append(await music_layer(dur, func(t: float) -> float:
		var lt := fmod(t, 0.5)
		var lt2 := fmod(t + 0.25, 0.5)
		return sin(TAU * 60.0 * lt) * exp(-lt * 25.0) * 0.5 + sin(TAU * 3100.0 * t) * exp(-lt2 * 60.0) * 0.1))
	for s in layers:
		var p := AudioStreamPlayer.new()
		p.stream = s
		add_child(p)
		music_players.append(p)
	apply_volumes()
	for p in music_players:
		p.play()
func apply_volumes() -> void:
	var m: float = opts["music"]
	for k in music_players.size():
		var p: AudioStreamPlayer = music_players[k]
		var on := m > 0.01 and (k == 0 or (k == 1 and max_stage >= 2) or (k == 2 and max_stage >= 4))
		p.volume_db = linear_to_db(maxf(m * 0.55, 0.0001)) if on else -80.0
# ================================================================ src/save.gd
# Partidas: nueva, guardar, cargar, códigos y migración.
const SAVE_VERSION := 1
func latest_slot() -> int:
	var best := 0
	var bt := 0
	for s in range(1, 4):
		var p := slot_path(s)
		if FileAccess.file_exists(p):
			var t := int(FileAccess.get_modified_time(p))
			if best == 0 or t > bt:
				best = s
				bt = t
	return best
func free_slot() -> int:
	var oldest := 1
	var ot := 0
	for s in range(1, 4):
		var p := slot_path(s)
		if not FileAccess.file_exists(p):
			return s
		var t := int(FileAccess.get_modified_time(p))
		if ot == 0 or t < ot:
			oldest = s
			ot = t
	return oldest
func reset_state() -> void:
	test_city = false
	money = 30000.0
	debt = 0.0
	day = 1
	day_timer = 0.0
	speed = 1
	pop = 0
	jobs = 0
	workers = 0
	tourists = 0
	stage = 0
	max_stage = 0
	approval = 0.7
	tax = [9, 9, 9]
	budget = [100, 100, 100, 100, 100, 100, 100]
	decrees = {}
	demand = [0.5, 0.3, 0.3]
	food_stock = 0.0
	prod_stock = 0.0
	market = [6.0, 9.0]
	contracts = []
	offer = null
	lines = []
	history = {"pop": [], "money": [], "happy": [], "appr": []}
	news = []
	achieved = {}
	obj_index = 0
	counters = {}
	daily_ch = 0
	daily_done = false
	promise = -1
	next_election = 15
	decision = null
	request = null
	festival_days = 0
	weather = "Soleado"
	wind = Vector2(1, 0)
	mods = {"hp": 0.0, "crime": 0.0, "pol": 0.0, "edu": 0.0, "tour": 0.0, "days": 0}
	no_fire_days = 0
	avg_happy = 0.6
	last_net = 0.0
	wonder_progress = {}
	game_over_shown = false
	stops = {}
	line_edit = {}
	cars = []
	peds = []
	stars = []
	downs = []
	movie_on = -1
	cine_next_day = 0
	svc = []
	boats = []
	planes = []
	parts = []
	anim_cells = {}
	car_paths = []
	drive = null
	follow_ped = null
	cam_follow = null
	sim_stage = -1
	sim_dirty = true
	built_season = -1
	terrain_dirty = true
	view_mode = ""
func new_test_city() -> void:
	reset_state()
	scenario = 0
	creative = true
	story = false
	slot = 3
	city_name = "Ciudad de prueba"
	gen_map(4, 4242)
	place_plaza()
	money = 999999.0
	for r in NREG * NREG:
		owned[r] = 1
	after_load()
	test_build()
	for k in 5:
		for s2 in 8:
			run_sim_stage(s2)
		new_day()
	for i in zone_list:
		if zone[i] > 0 and part[i] < 0:
			lvl[i] = 1 + int(pow(hsh(i, 5), 2.4) * 4.0) % 4
			tree[i] = 0
			vari[i] = int(hsh(i, 6) * 64.0)
	for k in 2:
		for s3 in 8:
			run_sim_stage(s3)
	anim_cells.clear()
	mark_all_dirty()
	test_city = true
	day_timer = DAY_SECONDS * 0.55
	speed = 1
	add_news("Ciudad de prueba: mirá cada cosa de cerca")
func new_game(kind: int, scen: int, crea: bool, hist: bool, s: int) -> void:
	reset_state()
	if scen == 4:
		kind = 2
	scenario = scen
	creative = crea
	story = hist and not crea
	slot = s
	city_name = str(new_opts["name"]).strip_edges() if str(new_opts["name"]).strip_edges() != "" else "Mi ciudad"
	gen_map(kind, randi() % 100000 + 1)
	place_plaza()
	pick_daily_challenge()
	if creative:
		money = 999999.0
		for r in NREG * NREG:
			owned[r] = 1
	after_load()
	add_news("Se fundó la ciudad. ¡Bienvenidos!")
	save_game(slot)
func after_load() -> void:
	compute_wdist()
	terrain_dirty = true
	built_season = season()
	mark_all_dirty()
	sim_dirty = true
	collect_lists()
	compute_networks()
	compute_coverage()
	compute_env()
	compute_env()
	compute_traffic()
	compute_happiness()
	compute_stats()
	reroute_all()
	rebuild_road_list()
	cam_goal = Vector3.ZERO
	cam_target = Vector3.ZERO
	cam_dist_goal = 150.0
	cam_dist = 150.0
	apply_volumes()
func slot_path(s: int, backup: bool = false) -> String:
	return "user://urbana_%d%s.json" % [s, ".bak" if backup else ""]
func b64(a) -> String:
	if a is PackedByteArray:
		return Marshalls.raw_to_base64(a)
	return Marshalls.raw_to_base64(a.to_byte_array())
func snapshot() -> Dictionary:
	var ln_list: Array = []
	for ln in lines:
		ln_list.append({"kind": ln["kind"], "stops": ln["stops"], "num": ln["num"], "col": ln["col"].to_html(), "t": ln["t"]})
	var st: Array = []
	for c in stops:
		st.append([c, stops[c]])
	var wp: Array = []
	for a in wonder_progress:
		wp.append([a, wonder_progress[a]])
	var dec_idx := -1
	if decision != null:
		dec_idx = DECISIONS.find(decision)
	return {
		"v": SAVE_VERSION, "n": N, "map_kind": map_kind, "map_seed": map_seed, "scenario": scenario, "creative": creative, "story": story, "city": city_name,
		"money": money, "debt": debt, "day": day, "day_timer": day_timer, "pop": pop, "stage": stage, "max_stage": max_stage,
		"approval": approval, "tax": tax, "budget": budget, "decrees": decrees, "food": food_stock, "prod": prod_stock, "market": market,
		"neighbors": neighbors, "contracts": contracts, "offer": offer, "lines": ln_list, "stops": st, "history": history, "news": news,
		"achieved": achieved, "obj": obj_index, "counters": counters, "daily_ch": daily_ch, "daily_done": daily_done,
		"promise": promise, "promise_base": promise_base, "next_election": next_election, "decision": dec_idx, "request": request,
		"festival": festival_days, "weather": weather, "mods": mods, "no_fire": no_fire_days, "wonders": wp, "avg_happy": avg_happy,
		"cam": [cam_goal.x, cam_goal.z, cam_yaw, cam_pitch, cam_dist_goal],
		"terr": b64(terr), "hgt": b64(hgt), "road": b64(road), "zone": b64(zone), "bld": b64(bld), "lvl": b64(lvl), "part": b64(part),
		"occ": b64(occ), "vari": b64(vari), "tree": b64(tree), "wire": b64(wire), "garbp": b64(garbp), "owned": b64(owned), "district": b64(district),
	}
func save_game(s: int) -> void:
	if test_city:
		return
	var path := slot_path(s)
	if FileAccess.file_exists(path):
		var old := FileAccess.get_file_as_string(path)
		if old.length() > 100:
			var fb := FileAccess.open(slot_path(s, true), FileAccess.WRITE)
			if fb:
				fb.store_string(old)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(snapshot()))
func save_info(s: int) -> String:
	var path := slot_path(s)
	if not FileAccess.file_exists(path):
		return "vacía"
	var d = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(d) != TYPE_DICTIONARY:
		return "dañada"
	return "%s · día %d, %s vecinos" % [str(d.get("city", "Mi ciudad")), int(d.get("day", 1)), fmt_int(int(d.get("pop", 0)))]
func load_game(s: int, backup: bool = false) -> bool:
	var path := slot_path(s, backup)
	if not FileAccess.file_exists(path):
		return false
	var d = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(d) != TYPE_DICTIONARY:
		toast("La partida está dañada. Probá con la copia de respaldo.")
		return false
	if not apply_snapshot(d):
		return false
	slot = s
	return true
func unb(s: String) -> PackedByteArray:
	return Marshalls.base64_to_raw(s)
func apply_snapshot(d: Dictionary) -> bool:
	if int(d.get("n", 0)) != N:
		return false
	reset_state()
	alloc_arrays()
	map_kind = int(d.get("map_kind", 0))
	map_seed = int(d.get("map_seed", 1))
	scenario = int(d.get("scenario", 0))
	creative = bool(d.get("creative", false))
	story = bool(d.get("story", true))
	city_name = str(d.get("city", "Mi ciudad"))
	money = float(d.get("money", 30000))
	debt = float(d.get("debt", 0))
	day = int(d.get("day", 1))
	day_timer = float(d.get("day_timer", 0))
	pop = int(d.get("pop", 0))
	stage = int(d.get("stage", 0))
	max_stage = int(d.get("max_stage", 0))
	approval = float(d.get("approval", 0.7))
	tax = []
	for v in d.get("tax", [9, 9, 9]):
		tax.append(int(v))
	budget = []
	for v in d.get("budget", [100, 100, 100, 100, 100, 100, 100]):
		budget.append(int(v))
	decrees = d.get("decrees", {})
	food_stock = float(d.get("food", 0))
	prod_stock = float(d.get("prod", 0))
	market = d.get("market", [6.0, 9.0])
	neighbors = d.get("neighbors", [])
	if neighbors.is_empty():
		init_neighbors()
	contracts = []
	for c in d.get("contracts", []):
		contracts.append({"nb": int(c["nb"]), "kind": c["kind"], "qty": int(c["qty"]), "price": float(c["price"]), "days": int(c["days"])})
	var of = d.get("offer", null)
	if of != null:
		offer = {"nb": int(of["nb"]), "kind": of["kind"], "qty": int(of["qty"]), "price": float(of["price"]), "days": int(of["days"])}
	history = d.get("history", history)
	news = d.get("news", [])
	achieved = d.get("achieved", {})
	obj_index = int(d.get("obj", 0))
	counters = d.get("counters", {})
	daily_ch = int(d.get("daily_ch", 0))
	daily_done = bool(d.get("daily_done", false))
	promise = int(d.get("promise", -1))
	promise_base = float(d.get("promise_base", 0))
	next_election = int(d.get("next_election", 15))
	var di := int(d.get("decision", -1))
	decision = DECISIONS[di] if di >= 0 and di < DECISIONS.size() else null
	var rq = d.get("request", null)
	if rq != null:
		request = {"cell": int(rq["cell"]), "cv": int(rq["cv"]), "what": rq["what"], "until": int(rq["until"])}
	festival_days = int(d.get("festival", 0))
	weather = d.get("weather", "Soleado")
	var md: Dictionary = d.get("mods", {})
	for k in md:
		mods[k] = md[k]
	no_fire_days = int(d.get("no_fire", 0))
	avg_happy = float(d.get("avg_happy", 0.6))
	terr = unb(d["terr"])
	hgt = unb(d["hgt"]).to_float32_array()
	road = unb(d["road"])
	zone = unb(d["zone"])
	bld = unb(d["bld"]).to_int32_array()
	lvl = unb(d["lvl"])
	part = unb(d["part"]).to_int32_array()
	occ = unb(d["occ"]).to_float32_array()
	vari = unb(d["vari"])
	tree = unb(d["tree"])
	wire = unb(d["wire"])
	garbp = unb(d["garbp"]).to_float32_array()
	owned = unb(d["owned"])
	district = unb(d["district"]).to_int32_array()
	if terr.size() != N * N or bld.size() != N * N or hgt.size() != N * N:
		return false
	for s in d.get("stops", []):
		stops[int(s[0])] = s[1]
	for w in d.get("wonders", []):
		wonder_progress[int(w[0])] = int(w[1])
	for l in d.get("lines", []):
		var st: Array = []
		for s in l["stops"]:
			st.append(int(s))
		lines.append({"kind": l["kind"], "stops": st, "pts": [], "t": float(l.get("t", 0)), "num": int(l["num"]), "col": Color.html(l["col"])})
	after_load()
	var cm: Array = d.get("cam", [])
	if cm.size() == 5:
		cam_goal = Vector3(cm[0], 0, cm[1])
		cam_target = cam_goal
		cam_yaw = cm[2]
		cam_pitch = cm[3]
		cam_dist_goal = cm[4]
		cam_dist = cm[4]
	return true
func export_code() -> String:
	var raw := JSON.stringify(snapshot()).to_utf8_buffer()
	var comp := raw.compress(FileAccess.COMPRESSION_GZIP)
	return "URB1:" + str(raw.size()) + ":" + Marshalls.raw_to_base64(comp)
func import_code(t: String) -> bool:
	t = t.strip_edges().replace("\n", "").replace(" ", "")
	if t == "":
		return false
	if t.begins_with("URB1:"):
		var p := t.split(":", false, 2)
		if p.size() < 3:
			return false
		var comp := Marshalls.base64_to_raw(p[2])
		var raw := comp.decompress(int(p[1]), FileAccess.COMPRESSION_GZIP)
		var d = JSON.parse_string(raw.get_string_from_utf8())
		if typeof(d) != TYPE_DICTIONARY:
			return false
		if not apply_snapshot(d):
			return false
		save_game(slot)
		return true
	var txt := Marshalls.base64_to_utf8(t)
	var od = JSON.parse_string(txt)
	if typeof(od) != TYPE_DICTIONARY or not od.has("cells"):
		return false
	migrate_old(od)
	save_game(slot)
	return true
const OLD_OFF := 44
const OLD_DEFS := {5: 24, 6: 22, 7: 20, 8: 21, 10: 32, 11: 33, 12: 34, 13: 65}
func migrate_old(od: Dictionary) -> void:
	reset_state()
	scenario = 0
	creative = false
	story = true
	gen_map(4, 4242)
	for z in range(OLD_OFF - 2, OLD_OFF + 42):
		for x in range(OLD_OFF - 2, OLD_OFF + 42):
			var i := idx(x, z)
			terr[i] = T_LAND
			hgt[i] = 0.0
			tree[i] = 0
			road[i] = 0
	for r in [5, 6, 9, 10]:
		owned[r] = 1
	var defs: Array = []
	for c in od.get("cells", []):
		var x := int(c[0]) + OLD_OFF
		var z := int(c[1]) + OLD_OFF
		var k := int(c[2])
		if not inb(x, z):
			continue
		var i := idx(x, z)
		match k:
			1:
				road[i] = 2
			2, 3, 4:
				zone[i] = [0, 0, Z_R, Z_C, Z_I][k]
				lvl[i] = 1
				vari[i] = randi() % 64
			9:
				road[i] = 2
				stops[i] = "bus"
			_:
				if OLD_DEFS.has(k):
					defs.append([i, OLD_DEFS[k]])
	for s in od.get("stops", []):
		var x2 := int(s[0]) + OLD_OFF
		var z2 := int(s[1]) + OLD_OFF
		if inb(x2, z2):
			var i2 := idx(x2, z2)
			road[i2] = maxi(road[i2], 2)
			stops[i2] = "bus"
	for dd in defs:
		var i3: int = dd[0]
		var id: int = dd[1]
		var sz: int = DEF[id]["sz"]
		if sz == 1:
			bld[i3] = id
		elif can_place_old(i3, sz):
			for dz in sz:
				for dx in sz:
					var j := i3 + dz * N + dx
					zone[j] = 0
					bld[j] = id
					part[j] = i3
		else:
			bld[i3] = 30
	var num := 1
	for arr in od.get("lines", []):
		var st: Array = []
		for p in arr:
			var x3 := int(p[0]) + OLD_OFF
			var z3 := int(p[1]) + OLD_OFF
			if inb(x3, z3):
				st.append(idx(x3, z3))
		if st.size() >= 2:
			lines.append({"kind": "bus", "stops": st, "pts": [], "t": 0.0, "num": num, "col": Color.from_hsv(fmod(num * 0.17, 1.0), 0.75, 0.9)})
			num += 1
	day = int(od.get("day", 1))
	money = maxf(float(od.get("money", 0)), 30000.0)
	debt = 0.0
	pick_daily_challenge()
	after_load()
	cam_goal = cell_pos(idx(OLD_OFF + 20, OLD_OFF + 20))
	cam_target = cam_goal
	add_news("Tu ciudad de antes se mudó a este mapa nuevo")
func can_place_old(a: int, sz: int) -> bool:
	for dz in sz:
		for dx in sz:
			var x := cx(a) + dx
			var z := cz(a) + dz
			if not inb(x, z):
				return false
			var j := idx(x, z)
			if road[j] > 0 or bld[j] > 0:
				return false
	return true
func migrate_old_file() -> void:
	var old := "user://partida.json"
	if not FileAccess.file_exists(old) or FileAccess.file_exists(slot_path(1)):
		return
	var od = JSON.parse_string(FileAccess.get_file_as_string(old))
	if typeof(od) != TYPE_DICTIONARY or not od.has("cells"):
		return
	slot = 1
	migrate_old(od)
	save_game(1)
	DirAccess.rename_absolute(old, "user://partida_vieja.json")
func save_opts() -> void:
	var f := FileAccess.open("user://opciones.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(opts))
func load_opts() -> void:
	if not FileAccess.file_exists("user://opciones.json"):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string("user://opciones.json"))
	if typeof(d) != TYPE_DICTIONARY:
		return
	for k in d:
		if opts.has(k):
			opts[k] = d[k]
	for k in ["quality", "text", "ui_size"]:
		opts[k] = int(opts[k])
# ================================================================ src/tests.gd
# Modos de prueba (--test=...).
var test_frame: int = 0
func shot(nm: String) -> void:
	if test_mode == "run":
		return
	var img := get_viewport().get_texture().get_image()
	img.save_png(test_mode + "/" + nm + ".png")
	print("captura ", nm)
var tap_pending: Vector2 = Vector2.ZERO
var tap_phase: int = 0
func tap_ctrl(c: Control) -> void:
	tap_pending = c.get_global_rect().get_center() * ui_scale
	tap_phase = 1
func tap_step() -> void:
	if tap_phase == 1:
		var ev := InputEventScreenTouch.new()
		ev.index = 0
		ev.position = tap_pending
		ev.pressed = true
		Input.parse_input_event(ev)
		tap_phase = 2
	elif tap_phase == 2:
		var ev2 := InputEventScreenTouch.new()
		ev2.index = 0
		ev2.position = tap_pending
		ev2.pressed = false
		Input.parse_input_event(ev2)
		tap_phase = 0
func run_ui(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		save_game(2)
		show_start()
	elif f == 20:
		shot_to(dir, "u1_inicio")
		show_new_game()
	elif f == 30:
		shot_to(dir, "u2_nueva")
		show_slots()
	elif f == 40:
		shot_to(dir, "u3_partidas")
		show_code()
	elif f == 50:
		shot_to(dir, "u4_codigo")
		show_start()
		open_options()
	elif f == 60:
		shot_to(dir, "u5_opciones")
		close_sheet()
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 70:
		shot_to(dir, "u6_marta")
	elif f == 75:
		card_pick(0)
		test_build()
		show_tray("serv")
	elif f == 90:
		for k in 6:
			for s2 in 8:
				run_sim_stage(s2)
		card_queue.clear()
		card_panel.visible = false
		cam_dist_goal = 100.0
	elif f == 140:
		shot_to(dir, "u7_juego")
		open_fan()
	elif f == 146:
		shot_to(dir, "u7b_abanico")
		pick_cat("infra")
	elif f == 148:
		open_menu()
	elif f == 150:
		shot_to(dir, "u8_menu")
		open_districts()
	elif f == 160:
		shot_to(dir, "u9_distritos")
		close_sheet()
		show_tray("views")
	elif f == 170:
		shot_to(dir, "u10_vistas")
		close_fan()
		show_tray("none")
		set_hud_state(1)
	elif f == 176:
		shot_to(dir, "u11_panel1")
		set_hud_state(2)
	elif f == 182:
		shot_to(dir, "u12_panel2")
		print("UI OK")
		get_tree().quit()
func shot_to(dir: String, nm: String) -> void:
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir + "/" + nm + ".png")
func run_test() -> void:
	if test_mode.begins_with("album="):
		run_album(test_mode.substr(6))
		return
	if test_mode in ["compat_save", "compat_load", "fresh", "pause", "seam"]:
		run_extra()
		return
	if test_mode == "sim":
		run_sim()
		return
	if test_mode.begins_with("ui="):
		run_ui(test_mode.substr(3))
		return
	if test_mode == "dale":
		run_dale()
		return
	if test_mode.begins_with("city="):
		run_city(test_mode.substr(5))
		return
	if test_mode.begins_with("roads="):
		run_roads(test_mode.substr(6))
		return
	if test_mode.begins_with("fx="):
		run_fx(test_mode.substr(3))
		return
	if test_mode == "scroll":
		run_scroll()
		return
	if test_mode.begins_with("fan="):
		run_fan(test_mode.substr(4))
		return
	if test_mode.begins_with("menu="):
		run_menu(test_mode.substr(5))
		return
	test_frame += 1
	var f := test_frame
	if f == 20:
		shot("01_inicio")
	elif f == 25:
		seed(777)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 30:
		next_card()
		test_build()
	elif f == 60:
		for k in 8:
			for s in 8:
				run_sim_stage(s)
			new_day()
		print("pop=", pop, " money=", int(money), " jobs=", jobs, " power=", power_sup, "/", power_use, " water=", water_sup, " cars=", car_paths.size())
	elif f == 70:
		for k in 30:
			for s in 8:
				run_sim_stage(s)
			if k % 3 == 0:
				new_day()
		print("pop=", pop, " money=", int(money), " stage=", stage, " happy=", avg_happy, " lines=", lines.size())
		var hist := {}
		var sp := 0.0
		var scr := 0.0
		var scm := 0.0
		var nw := 0
		var n := 0
		for i in zone_list:
			if zone[i] == Z_R and lvl[i] > 0:
				hist[WHY_TEXT[why[i]]] = hist.get(WHY_TEXT[why[i]], 0) + 1
				sp += pollution[i]
				scr += crime[i]
				scm += commute[i]
				nw += 1 if watered[i] else 0
				n += 1
		print("motivos ", hist, " contam ", sp / maxf(n, 1), " crimen ", scr / maxf(n, 1), " viaje ", scm / maxf(n, 1), " con agua ", nw, "/", n, " desocup ", unemployment, " impuestos ", tax)
		card_queue.clear()
		card_panel.visible = false
		set_speed(2)
	elif f == 130:
		cam_goal = Vector3(0, 0, 0)
		cam_dist_goal = 110.0
		cam_pitch = 0.75
	elif f == 200:
		shot("02_ciudad")
		diag()
	elif f == 205:
		day_timer = DAY_SECONDS * 0.62
	elif f == 230:
		shot("03_noche")
		day_timer = DAY_SECONDS * 0.2
	elif f == 235:
		show_tray("roads")
		set_tool({"k": "road", "t": 3})
	elif f == 240:
		shot("04_bandeja")
	elif f == 245:
		test_panels()
	elif f == 250:
		open_stats()
	elif f == 255:
		shot("05_estadisticas")
		close_sheet()
		show_info(zone_list[0] if not zone_list.is_empty() else idx(N / 2, N / 2))
	elif f == 260:
		shot("06_info")
		info_panel.visible = false
		start_drive()
	elif f == 300:
		shot("07_manejar")
		stop_drive()
		set_view("traffic")
	elif f == 310:
		shot("08_vista")
		set_view("")
		test_save()
	elif f == 320:
		print("TEST OK")
		get_tree().quit()
func test_build() -> void:
	var c := N / 2
	money = 200000
	set_tool({"k": "road", "t": 2})
	for k in range(-3, 4):
		apply_cells(line_cells(idx(c - 14, c + k * 5 - 2), idx(c + 14, c + k * 5 - 2)))
		apply_cells(line_cells(idx(c + k * 5 - 2, c - 14), idx(c + k * 5 - 2, c + 14)))
	set_tool({"k": "road", "t": 3})
	apply_cells(line_cells(idx(c - 14, c + 3), idx(c + 14, c + 3)))
	for z in range(c - 14, c + 14):
		for x in range(c - 14, c + 14):
			var i := idx(x, z)
			if road[i] > 0 or bld[i] > 0:
				continue
			if x > c + 8:
				zone[i] = Z_I
			elif z < c - 6:
				zone[i] = Z_C
			else:
				zone[i] = Z_R
			vari[i] = randi() % 64
			mark_dirty(i)
	var spots := [[42, c + 15, c - 12], [48, c - 15, c - 12], [48, c - 15, c - 7], [65, c + 15, c + 3], [65, c - 12, c - 15], [24, c - 15, c - 2], [20, c - 15, c + 3], [21, c - 15, c + 8], [22, c + 15, c + 8], [22, c - 2, c + 15], [24, c + 8, c + 15], [33, c - 7, c - 15], [34, c + 3, c - 15], [30, c - 2, c - 15], [30, c - 12, c + 15], [41, c + 8, c - 15]]
	for s in spots:
		var a := idx(s[1], s[2])
		set_tool({"k": "def", "id": s[0]})
		var ok := place_def(a, s[0])
		if not ok:
			print("no se pudo poner ", DEF[s[0]]["n"], ": ", can_place_def(a, s[0]))
	set_tool({"k": "stop", "kind": "bus"})
	place_stop(idx(c - 12, c - 2), "bus")
	place_stop(idx(c + 12, c - 2), "bus")
	place_stop(idx(c + 3, c + 13), "bus")
	start_line("bus")
	pick_line_stop(idx(c - 12, c - 2))
	pick_line_stop(idx(c + 12, c - 2))
	pick_line_stop(idx(c + 3, c + 13))
	finish_line()
	mode_bar.visible = false
	sim_dirty = true
func test_panels() -> void:
	open_menu()
	for fn in [open_stats, open_budget, open_decrees, open_mayor, open_trade, open_transport, open_districts, open_goals, open_news, open_advisors, open_saves, open_options]:
		fn.call()
	open_district(5)
	for k in CATS:
		show_tray(k[0])
	for v in ["power", "water", "pollution", "crime", "land", "traffic", "happy", "fire", "police", "health", "edu", "transit", "garbage", "districts", ""]:
		set_view(v)
	for i in [idx(N / 2, N / 2), idx(N / 2 - 12, N / 2 - 2), idx(3, 3), zone_list[0] if not zone_list.is_empty() else 0]:
		show_info(i)
	decision = DECISIONS[0]
	show_decision()
	ask_promise()
	big_card("Prueba", "Texto de prueba")
	marta("Hola")
	while card_panel.visible:
		card_pick(0)
	follow_citizen()
	hide_follow_card()
	follow_ped = null
	cam_follow = null
	hold_festival()
	confetti([Color.RED])
	fireworks(Vector3.ZERO, 20)
	fund_wonder(-1)
	take_loan(5000)
	start_tutorial()
	tut_check()
	end_tutorial()
	set_photo_mode(true)
	set_photo_mode(false)
	for nm in sounds:
		sfx(nm)
	close_sheet()
	show_tray("")
	set_tool({"k": "look"})
	print("paneles ok")
func test_save() -> void:
	var p0 := pop
	var r0 := 0
	for i in N * N:
		if road[i] > 0:
			r0 += 1
	save_game(3)
	if not load_game(3):
		print("ERROR al cargar")
	var r1 := 0
	for i in N * N:
		if road[i] > 0:
			r1 += 1
	print("guardar/cargar calles ", r0, " -> ", r1, " pop ", p0, " -> ", pop, " lineas ", lines.size())
	var code := export_code()
	print("código de ", code.length(), " letras")
	if not import_code(code):
		print("ERROR al importar")
	var od := {"day": 12, "pop": 40, "money": 800, "debt": 100, "tax": 9, "cells": [[18, 18, 1], [19, 18, 1], [20, 18, 1], [21, 18, 1], [19, 19, 2], [20, 19, 3], [21, 19, 4], [18, 19, 5], [22, 18, 9], [17, 18, 9], [16, 19, 10], [15, 19, 13]], "stops": [[22, 18], [17, 18]], "lines": [[[22, 18], [17, 18]]]}
	var old_code := Marshalls.utf8_to_base64(JSON.stringify(od))
	if import_code(old_code):
		print("partida vieja pasada: calles ", obj_value("roads"), " zonas ", zone_list.size(), " líneas ", lines.size())
	else:
		print("ERROR partida vieja")
	load_game(3)
func diag() -> void:
	var keys := ["hc", "e1", "pk", "pol", "crime", "power", "water", "garb", "commute", "landv", "happy"]
	var sums := {}
	for k in keys:
		sums[k] = 0.0
	var n := 0
	for i in zone_list:
		if zone[i] != Z_R or lvl[i] == 0:
			continue
		n += 1
		sums["hc"] += minf(cov[CV_HEALTH][i], 1.0)
		sums["e1"] += minf(cov[CV_EDU1][i], 1.0)
		sums["pk"] += minf(cov[CV_PARK][i], 1.0)
		sums["pol"] += pollution[i]
		sums["crime"] += crime[i]
		sums["power"] += powered[i]
		sums["water"] += watered[i]
		sums["garb"] += garbp[i]
		sums["commute"] += commute[i]
		sums["landv"] += landv[i]
		sums["happy"] += happy[i]
	var out := ""
	for k in keys:
		out += "%s=%.2f " % [k, sums[k] / maxf(n, 1)]
	print("DIAG n=", n, " ", out, " mods=", mods, " hp_bonus=", hp_bonus, " unemp=", unemployment, " pop=", pop, " garb ", garb_made, "/", garb_cap)
func run_dale() -> void:
	tap_step()
	test_frame += 1
	var f := test_frame
	if f == 10:
		new_game(4, 0, false, true, 2)
		enter_game(true)
	elif f == 100:
		print("card visible ", card_panel.visible, " btns ", card_btns.get_child_count(), " title ", card_title.text, " rect ", card_btns.get_child(0).get_global_rect(), " scale ", ui_scale, " vp ", get_viewport().get_visible_rect().size)
		if card_btns.get_child_count() > 0:
			tap_ctrl(card_btns.get_child(0))
	elif f == 110:
		print("card visible after ", card_panel.visible, " intro_t ", intro_t, " title ", card_title.text, " queue ", card_queue.size(), " text ", card_text.text.substr(0, 40), " obj ", obj_index)
	elif f == 400:
		print("DALE OK day ", day)
		get_tree().quit()
func find_btn(n: Node, t: String) -> Button:
	if n is Button and n.text.contains(t):
		return n
	for ch in n.get_children():
		var r := find_btn(ch, t)
		if r != null:
			return r
	return null
func run_menu(dir: String) -> void:
	test_frame += 1
	tap_step()
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		set_tool({"k": "look"})
		open_menu()
	elif f == 50:
		var b := find_btn(sheet_body, "Opciones")
		print("opciones rect ", b.get_global_rect(), " sheet ", sheet.get_global_rect(), " scale ", ui_scale)
		tap_ctrl(b)
	elif f == 70:
		print("RESULT sheet=", sheet_name, " info=", info_panel.visible)
		shot_to(dir, "m1")
		get_tree().quit()
func touch_at(p: Vector2, pressed: bool) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.position = p
	ev.pressed = pressed
	Input.parse_input_event(ev)
func drag_to(p: Vector2) -> void:
	var ev := InputEventScreenDrag.new()
	ev.index = 0
	ev.position = p
	Input.parse_input_event(ev)
var fan_t0: int = 0
var scroll0: int = 0
func run_scroll() -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		show_tray("fun")
	elif f == 60:
		scroll0 = tray_sc.scroll_horizontal
		var r: Rect2 = tray.get_child(2).get_global_rect()
		touch_at(r.get_center() * ui_scale, true)
	elif f > 60 and f < 80:
		var r2: Rect2 = tray.get_child(2).get_global_rect()
		drag_to(r2.get_center() * ui_scale + Vector2(-(f - 60) * 24.0, 0))
		var ev := InputEventScreenDrag.new()
		ev.index = 0
		ev.position = r2.get_center() * ui_scale + Vector2(-(f - 60) * 24.0, 0)
		ev.relative = Vector2(-24, 0)
		Input.parse_input_event(ev)
	elif f == 80:
		touch_at(tray.get_child(2).get_global_rect().get_center() * ui_scale + Vector2(-480, 0), false)
	elif f == 90:
		print("SCROLL moved=", tray_sc.scroll_horizontal - scroll0, " tool=", tool["k"], " acc=", drag_acc)
		get_tree().quit()
func run_fx(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		cam_dist_goal = 45.0
		weather = "Soleado"
		notify("LOGRO DESBLOQUEADO", "Mil vecinos en la ciudad")
	elif f == 46:
		print("NOTIF vis=", notif_panel.visible, " pos=", notif_panel.position, " size=", notif_panel.size, " busy=", notif_busy, " mod=", notif_panel.modulate.a)
		shot_to(dir, "x0_notif")
	elif f == 60:
		show_hud(false)
		weather = "Lluvia"
	elif f == 120:
		shot_to(dir, "x1_lluvia")
		weather = "Nieve"
		terrain_dirty = true
	elif f == 220:
		shot_to(dir, "x2_nieve")
		weather = "Soleado"
		terrain_dirty = true
	elif f == 260:
		shot_to(dir, "x3_sol_ao")
		opts["g_ao"] = false
		opts["g_grade"] = false
		apply_fx()
	elif f == 300:
		shot_to(dir, "x4_sin_ao_tilt")
		print("FX OK")
		get_tree().quit()
func run_city(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f > 12:
		card_queue.clear()
		card_panel.visible = false
	if f == 10:
		new_test_city()
		enter_game(false)
		skip_intro()
		var hc := test_house_cell()
		var near: Array = []
		for i in zone_list:
			if zone[i] == Z_R and part[i] < 0:
				near.append([cell_pos(i).distance_to(cell_pos(hc)), i])
		near.sort()
		for k in mini(14, near.size()):
			var ci: int = near[k][1]
			lvl[ci] = 1
			vari[ci] = k
			anim_cells.erase(ci)
		mark_all_dirty()
		print("CITY pop=", pop, " zonas=", zone_list.size(), " lamps=", lamps.size(), " lineas=", lines.size())
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		show_hud(false)
		speed = 0
		weather = "Soleado"
		start_movie(6, test_house_cell())
		card_queue.clear()
		day_timer = DAY_SECONDS * 0.25
		cam_target = Vector3(0, 0, 0)
		cam_dist_goal = 70.0
		cam_pitch = 0.9
		cam_yaw = 0.5
	elif f == 200:
		print("CITY cars=", cars.size(), " peds=", peds.size())
		shot_to(dir, "c1_dia")
		cam_dist_goal = 30.0
		cam_pitch = 0.5
	elif f == 260:
		shot_to(dir, "c2_dia_cerca")
		var hc := test_house_cell()
		cam_target = cell_pos(hc)
		cam_goal = cam_target
		cam_dist_goal = 15.0
		cam_pitch = 0.6
	elif f == 280 and not stars.is_empty():
		cam_target = stars[0]["pos"]
		cam_goal = cam_target
	elif f == 300:
		shot_to(dir, "c5_avengers")
		day_timer = DAY_SECONDS * 0.7
		cam_target = Vector3(0, 0, 0)
		cam_goal = cam_target
		cam_dist_goal = 70.0
		cam_pitch = 0.9
	elif f == 370:
		shot_to(dir, "c3_noche")
		cam_dist_goal = 11.0
		cam_pitch = 1.0
	elif f > 370 and f < 460 and not cars.is_empty():
		var cp: Array = path_pos_s(cars[0]["p"], cars[0]["k"], CELL * 0.18)
		cam_goal = cp[0]
		cam_target = cp[0]
	elif f == 460:
		shot_to(dir, "c4_noche_cerca")
		start_movie(0, test_house_cell())
		card_queue.clear()
		cam_target = cell_pos(test_house_cell())
		cam_goal = cam_target
		cam_dist_goal = 15.0
		cam_pitch = 0.6
	elif f == 510:
		shot_to(dir, "c6_casas_noche")
		if not stars.is_empty():
			cam_target = stars[0]["pos"]
			cam_goal = cam_target
		cam_dist_goal = 12.0
		day_timer = DAY_SECONDS * 0.4
	elif f > 510 and f < 560 and not stars.is_empty():
		cam_goal = stars[0]["pos"]
		cam_target = cam_goal
	elif f == 560:
		shot_to(dir, "c7_scream")
		print("CITY OK stars=", stars.size(), " caidos=", downs.size())
		get_tree().quit()
func test_house_cell() -> int:
	var best := 0
	var bn := -1.0
	var c := 0
	for i in zone_list:
		if zone[i] == Z_R and lvl[i] == 1:
			c += 1
			var d := cell_pos(i).length()
			if d > bn:
				bn = d
				best = i
	print("CASAS ", c, " elegida ", cell_pos(best))
	return best
func run_roads(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		show_hud(false)
		money = 999999.0
		set_tool({"k": "road", "t": 2})
		var c0 := idx(N / 2, N / 2)
		var cells: Array = []
		for k in 7:
			cells.append(idx(N / 2 + k, N / 2))
		for k in 1:
			pass
		for k in range(1, 6):
			cells.append(idx(N / 2 + 6, N / 2 + k))
		for k in range(1, 4):
			cells.append(idx(N / 2 + 3, N / 2 - k))
		for k in range(1, 4):
			cells.append(idx(N / 2 - k, N / 2 + 3))
		apply_cells(cells)
		cam_target = Vector3(0, 0, 0)
		cam_dist_goal = 55.0
		cam_pitch = 1.2
		cam_yaw = 0.3
	elif f == 160:
		shot_to(dir, "r1_top")
		cam_pitch = 0.6
	elif f == 220:
		shot_to(dir, "r2_low")
		print("ROADS OK")
		get_tree().quit()
func run_fan(dir: String) -> void:
	test_frame += 1
	var f := test_frame
	var now := Time.get_ticks_msec()
	if f == 10:
		seed(5)
		new_game(4, 0, false, true, 3)
		enter_game(true)
		skip_intro()
	elif f == 40:
		card_queue.clear()
		card_panel.visible = false
		set_tool({"k": "look"})
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, true)
		fan_t0 = now
	elif f > 40 and f < 400 and fan_hold and fan_open and fan_t0 > 0 and now - fan_t0 > 900:
		var tgt: Vector2 = fan_btns[3].get_global_rect().get_center() * ui_scale
		drag_to(tgt)
		print("FAN open, hover=", fan_hover)
		fan_t0 = -1
		test_frame = 400
	elif f == 450:
		print("FAN dwell hover=", fan_hover, " cur_cat=", cur_cat, " open=", fan_open)
		shot_to(dir, "f1")
		touch_at(Vector2(10, 10), false)
	elif f == 470:
		print("RESULT cur_cat=", cur_cat, " fan_open=", fan_open, " tray=", tray.get_child_count())
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, true)
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, false)
	elif f == 500:
		print("TAP1 open=", fan_open)
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, true)
		touch_at(build_btn.get_global_rect().get_center() * ui_scale, false)
	elif f == 540:
		print("TAP2 open=", fan_open)
		get_tree().quit()
func run_sim() -> void:
	test_frame += 1
	if test_frame != 5:
		return
	seed(20261012)
	new_game(4, 0, false, true, 3)
	enter_game(true)
	skip_intro()
	card_queue.clear()
	test_build()
	var t0 := Time.get_ticks_usec()
	for k in 30:
		for s in 8:
			run_sim_stage(s)
		new_day()
		print("SIM día=%d pop=%d money=%d jobs=%d happy=%.4f power=%.1f/%.1f water=%.1f/%.1f lines=%d stage=%d" % [day, pop, int(money), jobs, avg_happy, power_sup, power_use, water_sup, water_use, lines.size(), stage])
	print("BENCH sim_ms=%d" % ((Time.get_ticks_usec() - t0) / 1000))
	t0 = Time.get_ticks_usec()
	for k in 5:
		mark_all_dirty()
		update_chunks(NCH * NCH)
	print("BENCH chunks_ms=%d" % ((Time.get_ticks_usec() - t0) / 1000))
	speed = 1
	for k in 600:
		agents_process(1.0 / 60.0)
	t0 = Time.get_ticks_usec()
	for k in 300:
		agents_process(1.0 / 60.0)
	print("BENCH agents_ms=%d cars=%d peds=%d" % [(Time.get_ticks_usec() - t0) / 1000, cars.size(), peds.size()])
	t0 = Time.get_ticks_usec()
	for k in 3:
		build_terrain()
	print("BENCH terrain_ms=%d" % ((Time.get_ticks_usec() - t0) / 1000))
	print("SIM OK")
	get_tree().quit()
# --- pruebas de compatibilidad y casos de borde (etapa 0)
func compat_line() -> String:
	var roads := 0
	for i in N * N:
		if road[i] > 0:
			roads += 1
	return "COMPAT money=%d day=%d roads=%d lines=%d pop=%d" % [int(money), day, roads, lines.size(), pop]
func run_extra() -> void:
	test_frame += 1
	var f := test_frame
	match test_mode:
		"compat_save":
			if f == 5:
				seed(20261012)
				new_game(4, 0, false, true, 1)
				enter_game(true)
				skip_intro()
				card_queue.clear()
				test_build()
				for k in 10:
					for s in 8:
						run_sim_stage(s)
					new_day()
				save_game(1)
				print(compat_line())
				var fc := FileAccess.open("user://compat_code.txt", FileAccess.WRITE)
				fc.store_string(export_code())
				fc.close()
				print("COMPAT_SAVE OK")
				get_tree().quit()
		"compat_load":
			if f == 5:
				if not load_game(1):
					print("COMPAT ERROR no se pudo cargar la partida 1")
				else:
					print(compat_line())
				var code := FileAccess.get_file_as_string("user://compat_code.txt")
				if not import_code(code):
					print("COMPAT ERROR no se pudo importar el código")
				else:
					print(compat_line())
				print("COMPAT_LOAD OK")
				get_tree().quit()
		"fresh":
			if f == 30:
				var clean := not FileAccess.file_exists("user://opciones.json") and latest_slot() == 0
				print("FRESH OK" if clean and start_panel.visible and not started else "FRESH FALLA")
				get_tree().quit()
		"seam":
			# mapas con bordes con lomas: el horizonte tiene que empalmar con el terreno en cada vértice del borde
			if f == 5:
				var res := []
				for kind in [1, 4, 0]:
					seed(20261012 + kind)
					new_game(kind, 0, true, false, 3)
					build_terrain()
					res.append(seam_check())
					opts["quality"] = 0
					build_terrain()
					res.append(seam_check())
					opts["quality"] = 1
				print("SEAM_CHECK ok" if res.min() == 0 else "SEAM_CHECK FALLA %s" % [res])
				get_tree().quit()
		"pause":
			if f == 5:
				new_game(4, 0, false, true, 2)
				enter_game(true)
				skip_intro()
				DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(2)))
			elif f == 20:
				notification(NOTIFICATION_APPLICATION_PAUSED)
				var saved := FileAccess.file_exists(slot_path(2))
				var clean := FileAccess.get_file_as_string("user://ultimo_paso.txt").contains("cierre limpio")
				print("PAUSE OK" if saved and clean else "PAUSE FALLA guardada=%s limpio=%s" % [saved, clean])
				get_tree().quit()
# --- álbum de capturas (etapa 1): se corre con el renderer Mobile (tools/album.sh)
var album_shots: Array = []
var album_k: int = -1
var album_wait: int = 0
var album_t: int = 0
var album_frames: Array = []
func album_hour(h: float) -> void:
	day_timer = (h - 6.0) / 24.0 * DAY_SECONDS
	speed = 0
func album_city(h: float, w: String, d: int) -> void:
	if album_k == 0 or test_city == false:
		new_test_city()
		enter_game(false)
		skip_intro()
	day = d
	weather = w
	album_hour(h)
	terrain_dirty = true
	mark_all_dirty()
	cam_goal = Vector3.ZERO
	cam_target = cam_goal
	cam_dist_goal = 110.0
	cam_dist = 110.0
	cam_pitch = 0.75
	cam_yaw = 0.5
# agua "abierta": casi todo alrededor es agua (para no apuntar a un charco)
func album_open_water(i: int) -> bool:
	var n := 0
	var w := 0
	for dz in range(-6, 7, 2):
		for dx in range(-6, 7, 2):
			if inb(cx(i) + dx, cz(i) + dz):
				n += 1
				if terr[idx(cx(i) + dx, cz(i) + dz)] == T_WATER:
					w += 1
	return w >= n * 0.8
func album_map(kind: int, want: int) -> void:
	new_game(kind, 0, true, false, 3)
	enter_game(false)
	skip_intro()
	weather = "Soleado"
	album_hour(13.0)
	var best := -1
	var bd := 1e9
	for i in N * N:
		if terr[i] == want and (want != T_WATER or album_open_water(i)):
			var dd := Vector2(cx(i) - N / 2, cz(i) - N / 2).length()
			if dd < bd:
				bd = dd
				best = i
	if best >= 0:
		cam_goal = cell_pos(best)
	cam_target = cam_goal
	cam_dist_goal = 120.0
	cam_dist = 120.0
	cam_pitch = 0.7
	cam_yaw = 0.5
# calidad Baja (la última toma: cambia las opciones)
func album_low() -> void:
	opts["quality"] = 0
	apply_quality()
	apply_fx()
	album_city(13.0, "Soleado", 3)
func album_horizon(h: float) -> void:
	album_city(h, "Soleado", 3)
	update_light()
	# mirar hacia el sol: la luz apunta a -Z, así que el sol está en +Z de su base
	var to_sun: Vector3 = sun.global_transform.basis.z
	cam_yaw = atan2(-to_sun.x, -to_sun.z)
	cam_pitch = 0.22
	cam_dist_goal = 170.0
	cam_dist = 170.0
var album_dir: String = ""
func run_album(dir: String) -> void:
	test_frame += 1
	if test_frame < 5:
		return
	if album_dir != "":
		dir = album_dir
	if album_k < 0:
		DirAccess.make_dir_recursive_absolute(dir.get_slice(":", 0))
		album_shots = [
			["amanecer", func(): album_city(6.8, "Soleado", 3)],
			["mediodia", func(): album_city(13.0, "Soleado", 3)],
			["atardecer", func(): album_city(19.5, "Soleado", 3)],
			["noche", func(): album_city(23.0, "Soleado", 3)],
			["lluvia", func(): album_city(13.0, "Lluvia", 3)],
			["nieve", func(): album_city(13.0, "Nieve", 23)],
			["otono", func(): album_city(13.0, "Soleado", 13)],
			["rio", func(): album_map(0, T_WATER)],
			["costa", func(): album_map(2, T_WATER)],
			["islas", func(): album_map(3, T_WATER)],
			["cerros", func(): album_map(1, T_ROCK)],
			["horizonte_dia", func(): album_horizon(13.0)],
			["horizonte_tarde", func(): album_horizon(19.5)],
			["baja", func(): album_low()],
		]
		# --test=album=<carpeta>:toma1,toma2 saca solo esas tomas
		if dir.contains(":"):
			var only := dir.get_slice(":", 1).split(",")
			dir = dir.get_slice(":", 0)
			album_shots = album_shots.filter(func(sh): return sh[0] in only)
		album_dir = dir
		album_k = 0
		album_wait = 0
	if album_k >= album_shots.size():
		print("ALBUM OK")
		get_tree().quit()
		return
	card_queue.clear()
	card_panel.visible = false
	ui_layer.visible = false
	if album_wait == 0:
		album_shots[album_k][1].call()
		card_queue.clear()
	album_wait += 1
	# en el mediodía se mide el tiempo por cuadro (cuadros 60 a 180)
	var bench_shot: bool = album_shots[album_k][0] in ["mediodia", "baja"]
	if bench_shot and album_wait == 1:
		album_frames.clear()
	if bench_shot and album_wait >= 60:
		var now := Time.get_ticks_usec()
		if album_wait > 60:
			album_frames.append(now - album_t)
		album_t = now
		if album_wait == 180:
			var tot := 0.0
			for v in album_frames:
				tot += v
			print("BENCH frame_ms%s=%.2f" % ["_baja" if album_shots[album_k][0] == "baja" else "", tot / maxf(album_frames.size(), 1) / 1000.0])
	var need := 180 if bench_shot else 90
	if album_wait == need and album_shots[album_k][0] in ["mediodia", "cerros"]:
		terrain_check()
	if album_wait >= need:
		get_viewport().get_texture().get_image().save_png(dir + "/" + album_shots[album_k][0] + ".png")
		print("captura ", album_shots[album_k][0])
		album_k += 1
		album_wait = 0
# el terreno suavizado no puede mover el suelo de las celdas ocupadas: en ellas los puntos nuevos de
# la malla fina tienen que caer sobre los triángulos de antes (bordes = promedio, centro = diagonal a-d)
func terrain_check() -> void:
	if not use_tex_terrain() or terrain_hsub.is_empty():
		print("TERRAIN_CHECK sin malla fina")
		return
	var M := 2 * N + 1
	var bad := 0
	var cells := 0
	for z in N:
		for x in N:
			if not terrain_busy(x, z):
				continue
			cells += 1
			var a := terrain_hsub[(2 * z) * M + 2 * x]
			var b := terrain_hsub[(2 * z) * M + 2 * x + 2]
			var c := terrain_hsub[(2 * z + 2) * M + 2 * x]
			var d := terrain_hsub[(2 * z + 2) * M + 2 * x + 2]
			var want := [[2 * x + 1, 2 * z, (a + b) * 0.5], [2 * x + 1, 2 * z + 2, (c + d) * 0.5], [2 * x, 2 * z + 1, (a + c) * 0.5], [2 * x + 2, 2 * z + 1, (b + d) * 0.5], [2 * x + 1, 2 * z + 1, (a + d) * 0.5]]
			for w in want:
				if absf(terrain_hsub[int(w[1]) * M + int(w[0])] - float(w[2])) > 0.001:
					bad += 1
	print("TERRAIN_CHECK ok (%d celdas ocupadas)" % cells if bad == 0 else "TERRAIN_CHECK FALLA %d puntos" % bad)
# Cuenta los vértices del borde del terreno que no tienen un vértice del horizonte en el mismo lugar y a la
# misma altura (cada uno es una posible rendija). 0 = empalme perfecto.
func seam_check() -> int:
	var half := N * CELL * 0.5
	var outer := {}
	for nd in outer_nodes:
		var m: Mesh = nd.mesh
		var arr := m.surface_get_arrays(0)
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		for v in vs:
			if absf(absf(v.x) - half) < 0.01 or absf(absf(v.z) - half) < 0.01:
				outer[Vector2i(roundi(v.x * 10.0), roundi(v.z * 10.0))] = v.y
	var tm: Mesh = terrain_node.mesh
	var tv: PackedVector3Array = tm.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var bad := 0
	for v in tv:
		if absf(absf(v.x) - half) < 0.01 or absf(absf(v.z) - half) < 0.01:
			var k := Vector2i(roundi(v.x * 10.0), roundi(v.z * 10.0))
			if not outer.has(k) or absf(float(outer[k]) - v.y) > 0.001:
				bad += 1
	return bad
# ================================================================ src/main.gd
# Arranque y bucle principal de Godot.
func _unhandled_input(event: InputEvent) -> void:
	if intro_t >= 0.0:
		if event is InputEventScreenTouch or (event is InputEventMouseButton and event.pressed):
			skip_intro()
		return
	if photo_mode and event is InputEventScreenTouch and event.pressed and touches.is_empty():
		pass
	if event is InputEventScreenTouch:
		on_touch(event.index, event.position, event.pressed)
	elif event is InputEventScreenDrag:
		on_drag(event.index, event.position)
	elif event is InputEventMouseButton:
		if event.device == -1:
			return
		on_mouse_button(event)
	elif event is InputEventMouseMotion:
		if event.device == -1:
			return
		on_mouse_motion(event)
	elif event is InputEventKey and event.pressed:
		on_key(event)
var idle_t: float = 0.0
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		crumb("cierre limpio")
		if started:
			save_game(slot)
var first_chunks: bool = true
func _ready() -> void:
	if FileAccess.file_exists("user://ultimo_paso.txt"):
		prev_crumb = FileAccess.get_file_as_string("user://ultimo_paso.txt").strip_edges()
	crumb("arranque")
	randomize()
	load_opts()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--test"):
			test_mode = a.substr(7) if a.length() > 7 else "run"
	if test_mode != "":
		seed(20261012)
	setup_render()
	setup_camera()
	setup_agents()
	apply_quality()
	setup_audio()
	build_ui()
	migrate_old_file()
	reset_state()
	gen_map(randi() % 5, randi() % 100000 + 1)
	place_plaza()
	after_load()
	cam_yaw = 0.6
	cam_dist_goal = 260.0
	show_start()
	if test_mode != "":
		print("TEST ", test_mode)
func _process(delta: float) -> void:
	scroll_coast_step(delta)
	crumb("terreno")
	if terrain_dirty:
		build_terrain()
	crumb("chunks")
	update_chunks(4 if first_chunks or not started else 1)
	if first_chunks and not chunk_dirty.has(1):
		first_chunks = false
	if started:
		crumb("simulación etapa %d" % sim_stage)
		sim_process(delta)
		crumb("agentes (intro %s, zoom %d)" % [str(intro_t >= 0.0), int(cam_dist)])
		agents_process(delta)
	else:
		cam_yaw += delta * 0.05
	crumb("luz")
	update_light()
	crumb("cámara (intro %s, zoom %d)" % [str(intro_t >= 0.0), int(cam_dist)])
	update_camera(delta)
	update_fx()
	crumb("interfaz")
	ui_process(delta)
	crumb("dibujando el cuadro")
	if opts["idle30"] and not OS.has_feature("android"):
		idle_t += delta
		if not touches.is_empty() or cam_moving_t > 0.0 or intro_t >= 0.0 or drive != null:
			idle_t = 0.0
		Engine.max_fps = 30 if idle_t > 4.0 else 0
	else:
		Engine.max_fps = 0
	cam_moving_t = maxf(0.0, cam_moving_t - delta)
	if test_mode != "":
		run_test()
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		finger_pos = event.position
		scroll_input(event)
		if event is InputEventScreenDrag:
			drag_acc += event.relative.length()
		elif event.pressed:
			drag_acc = 0.0
	if event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventKey:
		idle_t = 0.0
