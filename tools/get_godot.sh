#!/usr/bin/env bash
# Baja Godot 4.7 estable (Linux) a tools/.godot/godot para correr las pruebas.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)/.godot"
VER="4.7-stable"
if [ -x "$DIR/godot" ]; then echo "ya está: $DIR/godot"; exit 0; fi
mkdir -p "$DIR"
URL="https://github.com/godotengine/godot/releases/download/$VER/Godot_v${VER}_linux.x86_64.zip"
curl -fsSL -o "$DIR/godot.zip" "$URL"
(cd "$DIR" && unzip -q -o godot.zip && rm godot.zip && mv "Godot_v${VER}_linux.x86_64" godot && chmod +x godot)
echo "listo: $DIR/godot"
