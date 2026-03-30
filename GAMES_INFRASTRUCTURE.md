# Games Infrastructure Documentation

**Last Updated:** March 30, 2026

## Quick Deploy (DO NOT USE FTP)

**Step 1:** Commit to correct repo/folder
```bash
# Commit to ryoutooai-debugin/Rudedudeedu under games/
git add games/ceo-battle.html
git commit -m "Add SamOwl CEO Battle game"
git push public main  # or use GitHub API
```

**Step 2:** Auto-publishes to samowl.net (5-10 min)

---

## Repository

**GitHub Repo:** `ryoutooai-debugin/Rudedudeedu`
- **URL:** https://github.com/ryoutooai-debugin/Rudedudeedu
- **Branch:** main
- **Games Folder:** `games/`

### How Publishing Works

| Commit to... | Auto-publishes to... |
|--------------|---------------------|
| `games/ceo-battle.html` | https://samowl.net/games/ceo-battle.html |
| `games/samowl-financier.html` | https://samowl.net/games/samowl-financier.html |
| `games/samowl-portfolio-challenge.html` | https://samowl.net/games/samowl-portfolio-challenge.html |

**Delay:** ~5-10 minutes (GitHub Pages CDN caching)

---

## Live Game URLs

| Game | GitHub | Live on samowl.net |
|------|--------|-------------------|
| CEO Battle | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/ceo-battle.html | https://samowl.net/games/ceo-battle.html |
| Financier | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/samowl-financier.html | https://samowl.net/games/samowl-financier.html |
| Portfolio Challenge | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/samowl-portfolio-challenge.html | https://samowl.net/games/samowl-portfolio-challenge.html |
| Bulls vs Bears TD | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/bull-vs-bear.html | https://samowl.net/games/bull-vs-bear.html |
| Trading Quest | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/samowl-trading-quest.html | https://samowl.net/games/samowl-trading-quest.html |
| Market Match | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/samowl-market-match.html | https://samowl.net/games/samowl-market-match.html |
| Color Match | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/samowl-color-match.html | https://samowl.net/games/samowl-color-match.html |
| Pattern Master | https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/samowl-pattern-master.html | https://samowl.net/games/samowl-pattern-master.html |

---

## Credentials Storage

**Location:** `/root/.openclaw/workspace/game_vault.env`

```bash
# GitHub (for pushing to Rudedudeedu)
GITHUB_TOKEN=ghp_YOUR_TOKEN_HERE

# Supabase (for leaderboards)
GAME_SUPABASE_URL=https://kyxoizlonqbahkothtaq.supabase.co
GAME_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Deployment via GitHub API (Recommended)

Use this method to bypass branch conflicts:

```bash
# Get current file SHA
SHA=$(curl -s "https://api.github.com/repos/ryoutooai-debugin/Rudedudeedu/contents/games/YOUR_GAME.html" \
  -H "Authorization: token $GITHUB_TOKEN" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")

# Upload new version
curl -s -X PUT "https://api.github.com/repos/ryoutooai-debugin/Rudedudeedu/contents/games/YOUR_GAME.html" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"Update YOUR_GAME.html\",\"content\":\"$(base64 -w0 YOUR_GAME.html)\",\"sha\":\"$SHA\"}"
```

---

## Games Hub

**Main hub:** https://samowl.net/games/

**Index file:** https://github.com/ryoutooai-debugin/Rudedudeedu/blob/main/games/index.html

---

## Old Documentation (Deprecated)

### FTP Deploy (DO NOT USE)
- Previous method: Manual upload via cPanel FTP
- **Now deprecated** - commits to `games/` folder auto-publish

### Netlify (Deprecated)
- Previously used Netlify for hosting
- Removed due to credits expiring

---

*Last updated: March 30, 2026*