"""
autocrop.py — trim transparent padding so an icon fills its slot.

Generated art tends to sit in a big empty frame; dropped into a fixed-size icon
container it then reads far smaller than the emoji it replaces. This crops to the
alpha bounding box, then re-pads to a square with a small even margin.

Usage: python autocrop.py icon-t.png [...]
Writes <name>-fit.png
"""

import sys
from pathlib import Path

from PIL import Image

MARGIN = 0.04  # fraction of the final square left as breathing room


def fit(path: Path) -> None:
    img = Image.open(path).convert("RGBA")
    bbox = img.getbbox()  # bounds of non-zero alpha
    if not bbox:
        print(f"{path.name}: fully transparent, skipped")
        return
    art = img.crop(bbox)
    w, h = art.size
    side = int(max(w, h) * (1 + MARGIN * 2))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(art, ((side - w) // 2, (side - h) // 2), art)

    stem = path.stem[:-2] if path.stem.endswith("-t") else path.stem
    out = path.with_name(stem + "-fit.png")
    canvas.save(out)
    gain = (max(w, h) / max(img.size)) * 100
    print(f"{path.name:26} -> {out.name:24} art filled {gain:4.0f}% of frame")


if __name__ == "__main__":
    for a in sys.argv[1:]:
        fit(Path(a))
