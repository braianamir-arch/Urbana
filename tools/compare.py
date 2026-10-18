#!/usr/bin/env python3
"""Compara una corrida de pruebas contra la referencia.

Uso: compare.py <referencia> <corrida>
- Las líneas que empiezan con "SIM " de sim.log tienen que ser idénticas.
- Cada .png de la referencia tiene que existir en la corrida con a lo sumo
  TOL % de píxeles distintos (un píxel es distinto si algún canal difiere en más de 24).
Sale con 0 si todo coincide; si no, guarda diff_<nombre>.png en la corrida y sale con 1.
"""
import sys
from pathlib import Path
import numpy as np
from PIL import Image

TOL = 1.5
TOL_POR_CAPTURA = {}  # nombre.png -> % (solo si NOTAS.md lo justifica)
UMBRAL = 24


def sim_lines(p):
    f = p / "sim.log"
    return [l.rstrip() for l in f.read_text(errors="replace").splitlines() if l.startswith("SIM ")] if f.exists() else None


def main():
    ref, run = Path(sys.argv[1]), Path(sys.argv[2])
    ok = True
    a, b = sim_lines(ref), sim_lines(run)
    if a is None:
        print("referencia sin sim.log"); ok = False
    elif a != b:
        ok = False
        print("NÚMEROS distintos:")
        for x, y in zip(a, b or []):
            if x != y:
                print("  ref:", x); print("  run:", y); break
        if b is None or len(a) != len(b):
            print(f"  líneas: ref {len(a)} / run {0 if b is None else len(b)}")
    else:
        print(f"números iguales ({len(a)} líneas)")
    for rp in sorted(ref.glob("*.png")):
        if rp.name.startswith("diff_"):
            continue
        qp = run / rp.name
        if not qp.exists():
            print(f"FALTA  {rp.name}"); ok = False; continue
        x = np.asarray(Image.open(rp).convert("RGB"), dtype=np.int16)
        y = np.asarray(Image.open(qp).convert("RGB"), dtype=np.int16)
        if x.shape != y.shape:
            print(f"TAMAÑO {rp.name} {x.shape} vs {y.shape}"); ok = False; continue
        mask = (np.abs(x - y) > UMBRAL).any(axis=2)
        pct = 100.0 * mask.mean()
        tol = TOL_POR_CAPTURA.get(rp.name, TOL)
        good = pct <= tol
        print(f"{'ok    ' if good else 'DISTINTA'} {rp.name}: {pct:.2f}% (tolerancia {tol}%)")
        if not good:
            ok = False
            d = y.astype(np.uint8).copy()
            d[mask] = [255, 0, 255]
            Image.fromarray(d).save(run / f"diff_{rp.name}")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
