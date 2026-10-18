#!/usr/bin/env bash
# Cuenta lo que se dibuja (imagen y sombras) con el renderer Mobile. Uso: tools/dibujo.sh <carpeta> [ancho x alto]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "$1" && cd "$1" && pwd)"
RES="${2:-540x1170}"
W="${RES%x*}"; H="${RES#*x}"
GODOT="$ROOT/tools/.godot/godot"
python3 "$ROOT/tools/godot_modules.py" check >/dev/null || { echo "main.gd no está al día" >&2; exit 2; }
"$GODOT" --headless --path "$ROOT/godot" --import > "$OUT/import.log" 2>&1
export XDG_DATA_HOME="$OUT/home"; rm -rf "$XDG_DATA_HOME"; mkdir -p "$XDG_DATA_HOME"
timeout 1800 xvfb-run -a -s "-screen 0 ${H}x${W}x24" "$GODOT" --path "$ROOT/godot" --rendering-method mobile \
	--rendering-driver vulkan --fixed-fps 60 --resolution "${H}x${W}" --audio-driver Dummy -- "--test=dibujo=$OUT" > "$OUT/dibujo.log" 2>&1
grep -E "^BENCH|SCRIPT ERROR|SHADER ERROR|DIBUJO" "$OUT/dibujo.log"
