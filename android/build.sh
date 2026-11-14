#!/usr/bin/env bash
# Arma urbana.apk con las herramientas del SDK de Android (sin Gradle).
# Uso: ANDROID_HOME=/ruta/al/Sdk ./build.sh   → deja el APK en android/out/urbana.apk
set -euo pipefail
cd "$(dirname "$0")"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
BT="$(ls -d "$SDK"/build-tools/* | sort -V | tail -1)"
PLAT="$(ls -d "$SDK"/platforms/android-* | sort -V | tail -1)/android.jar"
VER="$(grep -o "VERSION='[0-9.]*'" ../index.html | head -1 | tr -dc '0-9.')"
CODE="$(echo "$VER" | awk -F. '{printf "%d", $1*10000+$2*100+$3}')"
echo "SDK: $SDK · build-tools: $BT · versión $VER ($CODE)"
rm -rf out && mkdir -p out/gen out/cls out/dex out/assets/www out/res/mipmap-xxxhdpi out/res/values out/src
# el juego adentro de la app
cp ../index.html ../manifest.webmanifest ../icon-192.png ../icon-512.png ../icon-maskable.png out/assets/www/
cp ../icon-192.png out/res/mipmap-xxxhdpi/ic_launcher.png
cp res/values/styles.xml out/res/values/
sed "s/VERSION_CODE/$CODE/; s/VERSION_NAME/$VER/" AndroidManifest.xml > out/AndroidManifest.xml
mkdir -p out/src/app/urbana/juego
sed "s/VERSION_NAME/$VER/" src/app/urbana/juego/MainActivity.java > out/src/app/urbana/juego/MainActivity.java
"$BT/aapt2" compile --dir out/res -o out/res.zip
"$BT/aapt2" link -o out/base.apk -I "$PLAT" --manifest out/AndroidManifest.xml -A out/assets --java out/gen out/res.zip
javac -source 8 -target 8 -nowarn -Xlint:-options -classpath "$PLAT" -d out/cls out/src/app/urbana/juego/MainActivity.java $(find out/gen -name '*.java')
"$BT/d8" --release --min-api 24 --lib "$PLAT" --output out/dex $(find out/cls -name '*.class')
(cd out/dex && zip -q -j ../base.apk classes.dex)
"$BT/zipalign" -f 4 out/base.apk out/aligned.apk
"$BT/apksigner" sign --ks urbana.keystore --ks-pass pass:urbana-juego --ks-key-alias urbana --out out/urbana.apk out/aligned.apk
"$BT/apksigner" verify --verbose out/urbana.apk | head -5
"$BT/aapt2" dump badging out/urbana.apk | head -4
ls -la out/urbana.apk
