"""
make-transparent.py — knock the flat white background out of Higgsfield raster output.

Uses a flood fill from the image border, NOT a global colour key, so Sam's white
belly and eye whites survive. Anything white that is connected to the edge becomes
transparent; enclosed white stays.

Usage:  python make-transparent.py sam-wave-v2.png [more.png ...]
Writes: <name>-t.png alongside each input.
"""

import sys
from collections import deque
from pathlib import Path

from PIL import Image

THRESHOLD = 228  # a pixel counts as "background white" above this on every channel


def is_bg(px, i):
    r, g, b = px[i], px[i + 1], px[i + 2]
    return r >= THRESHOLD and g >= THRESHOLD and b >= THRESHOLD


def knock_out(path: Path) -> None:
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    px = bytearray(img.tobytes())
    seen = bytearray(w * h)
    q = deque()

    # seed from every border pixel that reads as background
    for x in range(w):
        for y in (0, h - 1):
            q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            q.append((x, y))

    cleared = 0
    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h:
            continue
        idx = y * w + x
        if seen[idx]:
            continue
        i = idx * 4
        if not is_bg(px, i):
            continue
        seen[idx] = 1
        px[i + 3] = 0  # alpha -> transparent
        cleared += 1
        q.append((x + 1, y))
        q.append((x - 1, y))
        q.append((x, y + 1))
        q.append((x, y - 1))

    out = path.with_name(path.stem + "-t.png")
    Image.frombytes("RGBA", (w, h), bytes(px)).save(out)
    pct = 100.0 * cleared / (w * h)
    print(f"{path.name:22} -> {out.name:24} {pct:5.1f}% cleared")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        raise SystemExit(1)
    for a in sys.argv[1:]:
        knock_out(Path(a))
