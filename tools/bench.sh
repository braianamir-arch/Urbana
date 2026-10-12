#!/usr/bin/env bash
# Mide cuánto tarda el modo --test=sim (simulación pura). Uso: tools/bench.sh [veces]
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export XDG_DATA_HOME="$(mktemp -d)"
for k in $(seq "${1:-3}"); do
	s=$(date +%s.%N)
	"$ROOT/tools/.godot/godot" --headless --path "$ROOT/godot" --fixed-fps 60 -- --test=sim > /dev/null 2>&1
	e=$(date +%s.%N)
	echo "sim: $(echo "$e - $s" | bc) s"
done
