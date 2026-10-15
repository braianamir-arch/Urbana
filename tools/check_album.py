#!/usr/bin/env python3
"""Verifica los colores del álbum de capturas (etapa 1: luz, cielo, terreno y agua).

Uso: check_album.py <carpeta del álbum>
Cada chequeo mira el promedio RGB (0-255) de una zona de la captura. Sale con 1 si alguno falla.
Las zonas se eligieron mirando el álbum "antes" (1280x720, cámara fija sobre la ciudad de prueba).
"""
import sys
from pathlib import Path
import numpy as np
from PIL import Image

# zona de pasto abierto (esquina inferior izquierda de la ciudad de prueba): x0, x1, y0, y1
SUELO = (40, 240, 560, 700)
# franja de cielo arriba y franja justo sobre el horizonte (tomas bajas)
CIELO = (0, 1280, 0, 60)
HORIZONTE = (120, 600, 150, 225)
# calle en las tomas de cerca sobre casas (abajo a la derecha)
CALLE = (1000, 1240, 460, 720)


def load(d, name):
    p = Path(d) / f"{name}.png"
    if not p.exists():
        return None
    return np.asarray(Image.open(p).convert("RGB"), dtype=np.float64)


def zone(img, z):
    x0, x1, y0, y1 = z
    return img[y0:y1, x0:x1].reshape(-1, 3).mean(axis=0)


def main():
    d = sys.argv[1]
    results = []

    def check(name, ok, detail):
        results.append(ok)
        print(f"{'ok    ' if ok else 'FALLA '} {name}: {detail}")

    m = load(d, "mediodia")
    if m is None:
        check("mediodia", False, "falta la captura")
    else:
        r, g, b = zone(m, SUELO)
        check("mediodia sin tinte azul (suelo G > B + 10)", g > b + 10, f"R={r:.0f} G={g:.0f} B={b:.0f}")
        lum = m.mean()
        check("mediodia brillo entre 70 y 190", 70 < lum < 190, f"{lum:.0f}")
        r, g, b = m.reshape(-1, 3).mean(axis=0)
        check("mediodia imagen no azulada (B <= R + 4)", b <= r + 4, f"R={r:.0f} G={g:.0f} B={b:.0f}")
    a = load(d, "atardecer")
    if a is None:
        check("atardecer", False, "falta la captura")
    else:
        r, g, b = a.reshape(-1, 3).mean(axis=0)
        check("atardecer cálido (R > B + 5)", r > b + 5, f"R={r:.0f} B={b:.0f}")
    n = load(d, "noche")
    if n is None:
        check("noche", False, "falta la captura")
    else:
        lum = n.mean()
        check("noche se ve (brillo entre 18 y 90)", 18 < lum < 90, f"{lum:.0f}")
    s = load(d, "nieve")
    if s is None:
        check("nieve", False, "falta la captura")
    else:
        lum = zone(s, SUELO).mean()
        check("nieve: suelo blanco (brillo > 170)", lum > 170, f"{lum:.0f}")
    hd = load(d, "horizonte_dia")
    if hd is None:
        check("horizonte_dia", False, "falta la captura")
    else:
        r, g, b = zone(hd, CIELO)
        check("horizonte_dia: cielo celeste (B > R + 20, brillo > 120)", b > r + 20 and (r + g + b) / 3 > 120,
              f"R={r:.0f} G={g:.0f} B={b:.0f}")
    ht = load(d, "horizonte_tarde")
    if ht is None:
        check("horizonte_tarde", False, "falta la captura")
    else:
        r, g, b = zone(ht, HORIZONTE)
        check("horizonte_tarde: cielo cálido junto al horizonte (R > B + 25)", r > b + 25, f"R={r:.0f} G={g:.0f} B={b:.0f}")
    for name in ("rio", "costa", "islas"):
        w = load(d, name)
        if w is None:
            check(name, False, "falta la captura")
            continue
        low = w[w.shape[0] // 2:]
        r, g, b = low[..., 0], low[..., 1], low[..., 2]
        frac = ((b > r + 20) & (g > r)).mean() * 100
        check(f"{name}: se ve agua (≥ 2 % de píxeles)", frac >= 2.0, f"{frac:.1f} %")
    # etapa 2: tomas de cerca
    cn = load(d, "cerca_noche")
    if cn is None:
        check("cerca_noche", False, "falta la captura")
    else:
        r, g, b = cn[..., 0], cn[..., 1], cn[..., 2]
        frac = ((r > 170) & (g > 100) & (r > b + 50)).mean() * 100
        check("cerca_noche: ventanas encendidas (≥ 0,5 % de píxeles cálidos)", frac >= 0.5, f"{frac:.2f} %")
    cc = load(d, "cerca_casas")
    cs = load(d, "cerca_nieve")
    cl = load(d, "cerca_lluvia")
    if cc is None or cs is None:
        check("cerca_nieve", False, "falta la captura")
    else:
        fc = (cc.mean(axis=2) > 200).mean()
        fs = (cs.mean(axis=2) > 200).mean()
        check("cerca_nieve: techos blancos (≥ 1,5× píxeles claros que con sol)", fs >= 1.5 * fc, f"{fs * 100:.1f} % vs {fc * 100:.1f} %")
    if cc is None or cl is None:
        check("cerca_lluvia", False, "falta la captura")
    else:
        a, b2 = zone(cl, CALLE).mean(), zone(cc, CALLE).mean()
        check("cerca_lluvia: calle más oscura (≤ 0,9 × con sol)", a <= 0.9 * b2, f"{a:.0f} vs {b2:.0f}")
    # etapa 2c: jacarandás violetas en primavera
    ap = load(d, "arboles_primavera")
    if ap is None:
        check("arboles_primavera", False, "falta la captura")
    else:
        r, g, b = ap[..., 0], ap[..., 1], ap[..., 2]
        frac = ((b > g + 30) & (r > g + 10)).mean() * 100
        check("arboles_primavera: jacarandá violeta (≥ 0,3 % de píxeles)", frac >= 0.3, f"{frac:.2f} %")
    sys.exit(0 if all(results) else 1)


if __name__ == "__main__":
    main()
