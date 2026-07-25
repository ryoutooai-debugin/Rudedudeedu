"""
make-web.py — downscale generated art to the size the page actually displays it.

Higgsfield returns 2048px PNGs. Shipping those for a 96px icon wastes megabytes on a
site aimed at kids on phones. This writes a 2x-of-display-size, quantised, optimised
PNG in place and keeps the original as a master.

Usage:  python make-web.py <target_px> <file.png> [...]
        masters are moved to _masters/ next to the file
"""

import shutil
import sys
from pathlib import Path

from PIL import Image


def shrink(path: Path, target: int) -> None:
    masters = path.parent / "_masters"
    masters.mkdir(exist_ok=True)
    master = masters / path.name
    if not master.exists():
        shutil.copy2(path, master)

    img = Image.open(master).convert("RGBA")
    before = master.stat().st_size

    img.thumbnail((target, target), Image.LANCZOS)

    # Flat vector art has very few distinct colours, so a 255-colour palette is
    # visually lossless and cuts size hard. FASTOCTREE is the only quantiser that
    # accepts RGBA and carries the alpha channel through.
    out = img.quantize(colors=255, method=Image.FASTOCTREE)
    out.save(path, optimize=True)

    after = path.stat().st_size
    print(
        f"{path.name:32} {before/1024:8.0f} KB -> {after/1024:6.1f} KB "
        f"({100 - after/before*100:4.1f}% smaller, {img.size[0]}px)"
    )


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        raise SystemExit(1)
    target = int(sys.argv[1])
    for a in sys.argv[2:]:
        shrink(Path(a), target)
