#!/usr/bin/env bash
# Corre todos los modos de prueba de URBANA Godot y guarda logs y capturas en <salida>.
# Uso: tools/run_tests.sh <salida>
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "$1" && cd "$1" && pwd)"
GODOT="$ROOT/tools/.godot/godot"
if [ ! -f "$ROOT/godot/project.godot" ]; then echo "falta godot/project.godot" >&2; exit 2; fi
if [ ! -x "$GODOT" ]; then echo "falta Godot: correr tools/get_godot.sh" >&2; exit 2; fi
# user:// propio por corrida, así las pruebas no se pisan
export XDG_DATA_HOME="$OUT/home"
rm -rf "$XDG_DATA_HOME"; mkdir -p "$XDG_DATA_HOME"
if ! python3 "$ROOT/tools/godot_modules.py" check; then
	echo "Si cambiaste godot/src: python3 tools/godot_modules.py build" >&2
	echo "Si alguien editó godot/scripts/main.gd a mano, NO armes todavía (se pierden esos cambios):" >&2
	echo "  mirá las diferencias con: python3 tools/godot_modules.py build --to out/armado.gd && diff out/armado.gd godot/scripts/main.gd" >&2
	echo "  y pasá los cambios a godot/src primero." >&2
	exit 2
fi
# importar primero (registra class_name y genera .uid)
"$GODOT" --headless --path "$ROOT/godot" --import > "$OUT/import.log" 2>&1
fail=0
run() {
	local mode="$1" name="$2" ok="$3"
	timeout 600 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path "$ROOT/godot" \
		--rendering-method gl_compatibility --rendering-driver opengl3 \
		--fixed-fps 60 --resolution 1280x720 --audio-driver Dummy -- "--test=$mode" > "$OUT/$name.log" 2>&1
	if grep -q "SCRIPT ERROR" "$OUT/$name.log" || ! grep -q "$ok" "$OUT/$name.log"; then
		echo "FALLA $name (ver $OUT/$name.log)"; fail=1
	else
		echo "ok    $name"
	fi
}
run sim sim "SIM OK"
run run run "TEST OK"
run "ui=$OUT" ui "UI OK"
run "city=$OUT" city "CITY OK"
run "fx=$OUT" fx "FX OK"
run "roads=$OUT" roads "ROADS OK"
exit $fail
