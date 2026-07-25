# SamOwl game icons

Generated 2026-07-25 in the Higgsfield web UI on the **unlimited tier — 0 credits**.
**Not yet wired into the site.** `games/index.html` still uses emoji.

These replace the `.game-icon` emoji in each card on `games/index.html`. One icon per game
that is actually **live on the site** — Financier, CEO Battle and Bull vs Bear exist as files
in `games/` but are not linked from the index, so they were deliberately skipped.

| File | Game | Replaces | Reads at 48px |
|---|---|---|---|
| `color-match-icon.png` | Color Match (4-6) | 🎨 | ok |
| `market-match-icon.png` | Market Match (7-9) | 📊 | ok — but see below |
| `trading-quest-icon.png` | Trading Quest (10-12) | ⚔️ | good |
| `portfolio-challenge-icon.png` | Portfolio Challenge (13+) | 🏆 | good |
| `pattern-master-icon.png` | Pattern Master (13+) | 📈 | good |
| `day-trader-icon.png` | Day Trader (13+) | 🦉 | ok |

All are transparent square PNGs that fill their frame, so they drop straight into the existing
96px icon slot. `_check.png` shows them inside a replica of the real `.game-card` component,
next to the current emoji, plus a 48/64px legibility strip.

`day-trader.png` / `.webp` is a separate **4:3 landscape** illustration — not an icon. Kept as a
possible page hero for the Day Trader game. Nothing references it.

## Known weakness

**`market-match-icon.png` is clean but abstract.** It ended as a coral/cyan split circle; the
bull and bear silhouettes did not survive the simplification. It's the boldest of the six but it
doesn't communicate the game. An earlier attempt had recognisable animal heads but turned to mush
below 64px. Pick your trade-off, or regenerate free — it's the one icon worth another pass.

## Wiring them in

In `games/index.html`, replace each card's emoji div:

```html
<div class="game-icon">🎨</div>
<!-- becomes -->
<div class="game-icon"><img src="../assets/game-cards/color-match-icon.png" alt=""></div>
```

and give the slot a fixed box so cards stay aligned:

```css
.game-icon { height: 96px; display: flex; align-items: center; justify-content: center; }
.game-icon img { max-height: 96px; max-width: 96px; }
```

⚠️ Check the relative path — the games live in `games/`, the assets in `assets/game-cards/`.

## Regenerating

Full click-path and billing traps: the **`higgsfield-free-images` skill**.
Seedream 5.0 Lite, 2K, 1:1, Unlimited on. Then two local steps, both free:

```bash
python ../mascot/make-transparent.py raw.png   # border flood-fill, keeps interior whites
python autocrop.py raw-t.png                   # crop to content so it fills the icon slot
```

**Prompt lesson:** do *not* ask for "generous margin" on an icon — the art lands small inside a big
empty frame and reads weaker than the emoji it replaces. Ask for "fills the frame, tight margin",
and keep the subject to **one simple silhouette**. Every icon here that stacked two or more
overlapping objects (magnifying glass over candles, animal heads over a chart) failed at 48px.
