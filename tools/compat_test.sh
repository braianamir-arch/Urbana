#!/usr/bin/env bash
# Guarda una partida con el script ORIGINAL (commit e7dd918) y la carga con la versión actual.
# También prueba el primer arranque sin datos y el guardado al pasar a segundo plano.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$ROOT/tools/.godot/godot"
OUT="$ROOT/out/compat"
rm -rf "$OUT"; mkdir -p "$OUT/orig/scripts" "$OUT/home"
run() { xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path "$1" --rendering-method gl_compatibility \
	--rendering-driver opengl3 --fixed-fps 60 --resolution 1280x720 --audio-driver Dummy -- "--test=$2" 2>&1; }
# proyecto original + los modos de prueba nuevos copiados del main.gd actual
for f in project.godot main.tscn icon.png; do git -C "$ROOT" show "e7dd918:godot/$f" > "$OUT/orig/$f"; done
git -C "$ROOT" show e7dd918:godot/scripts/main.gd > "$OUT/orig/scripts/main.gd"
python3 - "$ROOT" "$OUT/orig/scripts/main.gd" <<'PY'
import sys
sys.path.insert(0, sys.argv[1] + "/tools")
import godot_modules as M
new = {n: t for k, n, t in M.items_of(open(sys.argv[1] + "/godot/scripts/main.gd").read())}
p = sys.argv[2]
s = open(p).read()
a = 'func run_test() -> void:\n'
s = s.replace(a, a + '\tif test_mode in ["compat_save", "compat_load", "fresh", "pause"]:\n\t\trun_extra()\n\t\treturn\n', 1)
s += new["compat_line"] + new["run_extra"]
open(p, "w").write(s)
PY
"$GODOT" --headless --path "$OUT/orig" --import > /dev/null 2>&1
export XDG_DATA_HOME="$OUT/home"
fail=0
run "$OUT/orig" compat_save > "$OUT/save.log"
run "$ROOT/godot" compat_load > "$OUT/load.log"
A=$(grep "^COMPAT money" "$OUT/save.log")
mapfile -t B < <(grep "^COMPAT money" "$OUT/load.log")
echo "original guardó: $A"
echo "nueva cargó:     ${B[0]:-(nada)}"
echo "nueva importó:   ${B[1]:-(nada)}"
if [ -z "$A" ] || [ "${B[0]:-}" != "$A" ] || [ "${B[1]:-}" != "$A" ] || grep -q "SCRIPT ERROR\|COMPAT ERROR" "$OUT/save.log" "$OUT/load.log"; then
	echo "FALLA compatibilidad"; fail=1
else
	echo "ok    compatibilidad de partidas y códigos"
fi
for mode in fresh pause seam; do
	export XDG_DATA_HOME="$OUT/home_$mode"; mkdir -p "$XDG_DATA_HOME"
	run "$ROOT/godot" "$mode" > "$OUT/$mode.log"
	ok=$(echo "$mode" | tr a-z A-Z); [ "$mode" = seam ] && ok="SEAM_CHECK"
	if grep -q "^$ok OK" "$OUT/$mode.log" && ! grep -q "SCRIPT ERROR" "$OUT/$mode.log"; then echo "ok    $mode"; else echo "FALLA $mode: $(grep -m1 "$ok\|SCRIPT ERROR" "$OUT/$mode.log")"; fail=1; fi
done
exit $fail
