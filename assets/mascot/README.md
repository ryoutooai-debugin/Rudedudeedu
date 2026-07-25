# Sam the Owl — mascot set

Regenerated 2026-07-25 in the Higgsfield **web UI on the unlimited tier**. **Total cost: 0 credits.**
Not yet wired into the site — no page references these files.

| File | Use |
|---|---|
| `sam-wave.png` | hero, landing, "start here" |
| `sam-coin.png` | reward, coins earned, portfolio |
| `sam-teach.png` | hint, tutorial, tooltip |
| `sam-cheer.png` | win state, level complete |
| `sam-wave.svg` | **vector source — favicon only** |

All PNGs are 2048×2048 **with transparency**, so they composite on white cards and on the site's
navy `#1a1a2e`. `_setcheck.png` shows the set on both grounds, in game cards, and at thumbnail sizes.

## How this set was made (repeat this, don't improvise)

One reference-image lineage, so the character is consistent — this fixed the mismatched-wing bug
that ruined the previous SVG set.

1. Higgsfield web UI → Image → **Seedream 5.0 Lite**, 2K, 1:1, **Unlimited on**.
   Verify the button reads `Unlimited ✦` and not a credit number.
2. Attach `sam-wave` from the asset library as a **reference image** (the `+` left of the prompt).
3. Prompt shape: *"Keep the owl character in the reference image exactly the same — identical
   indigo-to-purple wings on both sides, identical cream-white face and belly, identical coral red
   bow tie, identical eyes and beak, identical flat vector style. Use THICK BOLD dark outlines.
   Change ONLY the pose: [pose]. Full body, centered, plain flat white background, no text."*
4. Output is opaque raster. Knock out the white background:
   ```bash
   python make-transparent.py sam-wave-v2.png
   ```
   It flood-fills from the border only, so Sam's white belly and eye whites survive — a global
   colour key would eat them.

Full click-path, billing traps, and asset-download details: the **`higgsfield-free-images` skill**.

## Known imperfections

- **`sam-teach` has a cream belly** where the other three are white. Minor drift the reference
  didn't hold. Regenerate free if it bothers you.
- Raster, so it softens below ~40px. `sam-wave.svg` is kept for the favicon, which is the one
  place vector actually matters.
- The reference locks colour and character but **not stroke weight or proportion** — never mix
  reference-guided output with older originals in the same set, the line weights won't match.

## Character spec (keep locked)

Round chubby body, oversized head, very large round eyes with white sclera and big dark pupils,
small golden-orange triangular beak, two pointed ear tufts, cream-white heart-shaped facial disc,
large white oval belly, tiny golden-orange feet, coral-red bow tie. Both wings the same
indigo→purple gradient, symmetrical. Thick bold outlines, flat fills, minimal interior detail.

## Palette (from the site CSS)

| Hex | Role |
|---|---|
| `#667eea` | brand primary indigo — body |
| `#764ba2` | brand purple — gradient end |
| `#f5576c` | coral — bow tie, confetti |
| `#00d4ff` | cyan — confetti accent |
| `#1a1a2e` | site navy — must stay legible on this |

`strip-bg.ps1` is the equivalent tool for **Recraft SVG** output, which bakes an opaque white
full-canvas `<path>` as its first element. Only needed if you go back to paid vector generation.
