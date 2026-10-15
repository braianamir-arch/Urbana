#!/usr/bin/env bash
# Saca el álbum de capturas con el renderer Mobile (Vulkan por software). Uso: tools/album.sh <carpeta>
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "$1" && cd "$1" && pwd)"
GODOT="$ROOT/tools/.godot/godot"
python3 "$ROOT/tools/godot_modules.py" check >/dev/null || { echo "main.gd no está al día: python3 tools/godot_modules.py build" >&2; exit 2; }
"$GODOT" --headless --path "$ROOT/godot" --import > "$OUT/import.log" 2>&1
export XDG_DATA_HOME="$OUT/home"; rm -rf "$XDG_DATA_HOME"; mkdir -p "$XDG_DATA_HOME"
timeout 1200 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path "$ROOT/godot" --rendering-method mobile \
	--rendering-driver vulkan --fixed-fps 60 --resolution 1280x720 --audio-driver Dummy -- "--test=album=$OUT" > "$OUT/album.log" 2>&1
if grep -qE "SCRIPT ERROR|SHADER ERROR" "$OUT/album.log" || ! grep -q "ALBUM OK" "$OUT/album.log"; then
	echo "FALLA álbum (ver $OUT/album.log)"; exit 1
fi
grep "^BENCH" "$OUT/album.log"
echo "ok    álbum en $OUT"
