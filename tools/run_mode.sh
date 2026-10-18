#!/usr/bin/env bash
# Corre un solo modo de prueba (renderer de compatibilidad) y deja el log en <salida>/<modo>.log.
# Uso: tools/run_mode.sh <modo> <salida>   (ej.: tools/run_mode.sh buildings out/b)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "$2" && cd "$2" && pwd)"
GODOT="$ROOT/tools/.godot/godot"
python3 "$ROOT/tools/godot_modules.py" check >/dev/null || { echo "main.gd no está al día: python3 tools/godot_modules.py build" >&2; exit 2; }
export XDG_DATA_HOME="$OUT/home"; rm -rf "$XDG_DATA_HOME"; mkdir -p "$XDG_DATA_HOME"
LOG="$OUT/${1%%=*}.log"
timeout 600 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path "$ROOT/godot" --rendering-method gl_compatibility \
	--rendering-driver opengl3 --fixed-fps 60 --resolution 1280x720 --audio-driver Dummy -- "--test=$1" > "$LOG" 2>&1 &
PID=$!
# un error de sintaxis deja a Godot abierto sin hacer nada: se corta enseguida
while kill -0 $PID 2>/dev/null; do
	if grep -q "Parse Error" "$LOG" 2>/dev/null; then sleep 1; kill -- -$PID 2>/dev/null; pkill -P $PID; break; fi
	sleep 1
done
wait $PID 2>/dev/null
grep -E "SCRIPT ERROR|SHADER ERROR|FALLA|BENCH|OK$" "$LOG" | head -40
# código de salida: 0 solo si terminó bien (línea "... OK") y sin errores ni fallas
if grep -qE "SCRIPT ERROR|SHADER ERROR|FALLA" "$LOG" || ! grep -qE "^[A-Z]+ OK$" "$LOG"; then exit 1; fi
