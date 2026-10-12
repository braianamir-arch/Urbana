# Estado compartido y constantes (lo usan varios módulos).
extends Node3D
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
