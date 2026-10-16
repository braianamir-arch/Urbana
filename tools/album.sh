#!/usr/bin/env bash
# Saca el álbum de capturas con el renderer Mobile (Vulkan por software).
# Uso: tools/album.sh <carpeta> [toma1,toma2]  (sin lista: todas)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "$1" && cd "$1" && pwd)"
GODOT="$ROOT/tools/.godot/godot"
python3 "$ROOT/tools/godot_modules.py" check >/dev/null || { echo "main.gd no está al día: python3 tools/godot_modules.py build" >&2; exit 2; }
"$GODOT" --headless --path "$ROOT/godot" --import > "$OUT/import.log" 2>&1
export XDG_DATA_HOME="$OUT/home"; rm -rf "$XDG_DATA_HOME"; mkdir -p "$XDG_DATA_HOME"
timeout 4800 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path "$ROOT/godot" --rendering-method mobile \
	--rendering-driver vulkan --fixed-fps 60 --resolution 1280x720 --audio-driver Dummy -- "--test=album=$OUT${2:+:$2}" > "$OUT/album.log" 2>&1 &
PID=$!
# un error de sintaxis deja a Godot abierto sin hacer nada: se corta enseguida
while kill -0 $PID 2>/dev/null; do
	if grep -q "Parse Error" "$OUT/album.log" 2>/dev/null; then sleep 1; pkill -P $PID; pkill -x godot; break; fi
	sleep 2
done
wait $PID 2>/dev/null
if grep -qE "SCRIPT ERROR|SHADER ERROR|TERRAIN_CHECK FALLA" "$OUT/album.log" || ! grep -q "ALBUM OK" "$OUT/album.log"; then
	echo "FALLA álbum (ver $OUT/album.log)"; exit 1
fi
grep "^BENCH" "$OUT/album.log"
echo "ok    álbum en $OUT"
