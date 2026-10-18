#!/usr/bin/env python3
"""Arma una hoja de contactos con las capturas de un álbum. Uso: mosaic.py <carpeta> <salida.jpg>"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw
NAMES = ["amanecer", "mediodia", "atardecer", "noche", "lluvia", "nieve", "otono", "rio", "costa", "islas",
         "cerros", "horizonte_dia", "horizonte_tarde", "baja"]
d = Path(sys.argv[1])
ims = [(n, Image.open(p)) for n in NAMES for p in [d / f"{n}.png", d / f"{n}.jpg"] if p.exists()]
W = Image.new("RGB", (480 * 4, 290 * ((len(ims) + 3) // 4)))
dr = ImageDraw.Draw(W)
for k, (n, im) in enumerate(ims):
    x, y = (k % 4) * 480, (k // 4) * 290
    W.paste(im.convert("RGB").resize((480, 270)), (x, y + 20))
    dr.text((x + 6, y + 4), n, fill=(255, 255, 0))
W.save(sys.argv[2], quality=85)
