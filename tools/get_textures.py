#!/usr/bin/env python3
"""Baja y prepara las texturas CC0 de ambientCG para el terreno, y genera las del agua.

Uso: python3 tools/get_textures.py
Deja en godot/assets/terrain/<mat>_alb.webp (RGB = color, A = rugosidad, 2048²) y
<mat>_nrm.webp (normal OpenGL, 1024²); en godot/assets/water/ water_nrm.webp y foam.webp
(generadas con ruido periódico, semilla fija). Es reproducible.
"""
import io
import urllib.request
import zipfile
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
TERRAIN = ROOT / "godot" / "assets" / "terrain"
WATER = ROOT / "godot" / "assets" / "water"
CACHE = ROOT / "out" / "ambientcg"

# material del juego -> id de ambientCG (CC0)
MATERIALS = {
    "grass": "Grass004",
    "dry": "Ground037",
    "dirt": "Ground109",
    "rock": "Rock044",
    "sand": "Ground080",
    "snow": "Snow010A",
}
ALB_SIZE = 2048
NRM_SIZE = 1024


def fetch(asset):
    CACHE.mkdir(parents=True, exist_ok=True)
    z = CACHE / f"{asset}_2K-JPG.zip"
    if not z.exists():
        url = f"https://ambientcg.com/get?file={asset}_2K-JPG.zip"
        req = urllib.request.Request(url, headers={"User-Agent": "urbana-godot"})
        z.write_bytes(urllib.request.urlopen(req, timeout=120).read())
    return zipfile.ZipFile(z)


def member(zf, suffix):
    for n in zf.namelist():
        if n.endswith(suffix):
            return Image.open(io.BytesIO(zf.read(n)))
    raise SystemExit(f"falta {suffix} en {zf.filename}")


def flatten(img):
    """Saca la variación de luz de gran escala (degradados de la foto) para que al repetirse no
    aparezcan bandas. Divide por una versión muy borrosa (periódica) y vuelve al color promedio."""
    a = np.asarray(img, dtype=np.float64)
    big = np.zeros_like(a)
    k = a.shape[0] // 8
    # desenfoque de caja periódico, en las dos direcciones, dos pasadas
    for _ in range(2):
        b = a if not big.any() else big
        c = np.cumsum(np.concatenate([b[-k:], b, b[:k]], axis=0), axis=0)
        b = (c[2 * k:] - c[:-2 * k]) / (2 * k)
        c = np.cumsum(np.concatenate([b[:, -k:], b, b[:, :k]], axis=1), axis=1)
        big = (c[:, 2 * k:] - c[:, :-2 * k]) / (2 * k)
    mean = a.reshape(-1, a.shape[2]).mean(axis=0)
    out = a / np.maximum(big, 1.0) * mean
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), img.mode)


def terrain():
    TERRAIN.mkdir(parents=True, exist_ok=True)
    for mat, asset in MATERIALS.items():
        zf = fetch(asset)
        col = flatten(member(zf, "_Color.jpg").convert("RGB").resize((ALB_SIZE, ALB_SIZE), Image.LANCZOS))
        rough = member(zf, "_Roughness.jpg").convert("L").resize((ALB_SIZE, ALB_SIZE), Image.LANCZOS)
        alb = Image.merge("RGBA", (*col.split(), rough))
        alb.save(TERRAIN / f"{mat}_alb.webp", quality=92, method=6)
        nrm = member(zf, "_NormalGL.jpg").convert("RGB").resize((NRM_SIZE, NRM_SIZE), Image.LANCZOS)
        nrm.save(TERRAIN / f"{mat}_nrm.webp", quality=95, method=6)
        print(f"{mat}: {asset}")


def periodic_noise(size, octaves, seed):
    """Ruido suave y periódico (se repite sin costuras) sumando ondas con frecuencias enteras."""
    rng = np.random.default_rng(seed)
    y, x = np.mgrid[0:size, 0:size] / size * 2 * np.pi
    h = np.zeros((size, size))
    for o in range(octaves):
        f = 2 ** o
        for _ in range(6):
            kx, ky = rng.integers(-f * 2, f * 2 + 1, 2)
            if kx == 0 and ky == 0:
                continue
            h += np.sin(kx * x + ky * y + rng.uniform(0, 2 * np.pi)) / (f ** 1.1)
    h -= h.min()
    return h / h.max()


def water():
    WATER.mkdir(parents=True, exist_ok=True)
    h = periodic_noise(1024, 6, 20261015)
    # normales a partir de la altura (diferencias con vecinos, envolviendo los bordes)
    dx = np.roll(h, -1, 1) - np.roll(h, 1, 1)
    dy = np.roll(h, -1, 0) - np.roll(h, 1, 0)
    s = 18.0
    n = np.dstack((-dx * s, dy * s, np.ones_like(h)))
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    img = ((n * 0.5 + 0.5) * 255).astype(np.uint8)
    Image.fromarray(img, "RGB").save(WATER / "water_nrm.webp", quality=95, method=6)
    f = periodic_noise(512, 7, 7)
    foam = np.clip((f - 0.45) * 3.0, 0, 1) ** 1.5
    Image.fromarray((foam * 255).astype(np.uint8), "L").save(WATER / "foam.webp", quality=92, method=6)
    print("agua: generada")


if __name__ == "__main__":
    terrain()
    water()
