# Games Infrastructure Documentation

**Last Updated:** March 28, 2026

## Current Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Development   │────▶│   GitHub Repo    │────▶│   samowl.net    │
│  (This Container)│     │ Rudedudeedu     │     │   /games/       │
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                        │                         │
        ▼                        ▼                         ▼
  game_vault.env         Supabase DB              Manual FTP or
                    (Leaderboard: kyxoizlon...)   deploy script
```

## Repository

**GitHub Repo:** `ryoutooai-debugin/Rudedudeedu`
- **URL:** https://github.com/ryoutooai-debugin/Rudedudeedu
- **Collaborators:** Rudedude + Samuel (AI assistant)
- **Branch:** main

### Files in Repo

| Path | Purpose |
|------|---------|
| `games/index.html` | Games hub page |
| `games/samowl-portfolio-challenge.html` | Portfolio trading game |
| `games/samowl-market-match.html` | Pattern matching game |
| `games/samowl-color-match.html` | Color matching game |
| `games/samowl-pattern-master.html` | Pattern mastery game |
| `games/bull-vs-bear.html` | Tower defense game |
| `games/samowl-trading-quest.html` | Trading quest game |
| `games/deploy_to_samowl.sh` | Auto-deploy script to samowl.net |
| `games/td-chunked/` | Chunked TD game |

## Hosting

**Live URL:** https://samowl.net/games/

**Deployment Method:** Manual upload via cPanel FTP or auto-deploy script

### Auto-Deploy Script

```bash
# Edit credentials in deploy_to_samowl.sh
bash games/deploy_to_samowl.sh
```

**Script Location:** `games/deploy_to_samowl.sh`

## Database (Leaderboard)

**Supabase Project:** `kyxoizlonqbahkothtaq`
- **URL:** https://kyxoizlonqbahkothtaq.supabase.co
- **Database:** PostgreSQL
- **Table:** `portfolio_leaderboard`

### Table Schema

```sql
CREATE TABLE portfolio_leaderboard (
    id SERIAL PRIMARY KEY,
    player_name TEXT UNIQUE NOT NULL,
    portfolio_value DECIMAL(12,2) NOT NULL DEFAULT 10000,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### RLS Policies
- Anyone can read
- Anyone can insert/update scores

## Credentials Storage

**Location:** `/root/.openclaw/workspace/game_vault.env`

```bash
# Supabase
GAME_SUPABASE_URL=https://kyxoizlonqbahkothtaq.supabase.co
GAME_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
GAME_SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# GitHub
GITHUB_TOKEN=YOUR_TOKEN_HERE
GITHUB_REPO=https://github.com/ryoutooai-debugin/Rudedudeedu.git

# samowl.net Hosting
SAMOWL_FTP_HOST=samowl.net
SAMOWL_FTP_USER=your_username
SAMOWL_FTP_PASS=your_password
SAMOWL_GAMES_DIR=/games
```

## Deployment Workflow

### Option 1: Manual Push

```bash
# Clone repo (once)
git clone https://github.com/ryoutooai-debugin/Rudedudeedu.git

# Make changes
cd Rudedudeedu
git add games/samowl-portfolio-challenge.html
git commit -m "Update portfolio game"
git push origin main
```

### Option 2: Auto-Deploy to samowl.net

```bash
# Edit deploy_to_samowl.sh with your FTP credentials
nano games/deploy_to_samowl.sh

# Run after pushing to GitHub
bash games/deploy_to_samowl.sh
```

## Games

### Portfolio Challenge
- **File:** `games/samowl-portfolio-challenge.html`
- **Live:** https://samowl.net/games/samowl-portfolio-challenge.html
- **Leaderboard:** Supabase (portfolio_leaderboard table)
- **Features:** Paper trading, real prices during market hours, leaderboard

### Market Match
- **File:** `games/samowl-market-match.html`
- **Live:** https://samowl.net/games/samowl-market-match.html
- **Objective:** Match candlestick patterns

### Color Match
- **File:** `games/samowl-color-match.html`
- **Live:** https://samowl.net/games/samowl-color-match.html

### Pattern Master
- **File:** `games/samowl-pattern-master.html`
- **Live:** https://samowl.net/games/samowl-pattern-master.html

### Bulls vs Bears TD
- **File:** `games/bull-vs-bear.html`
- **Live:** https://samowl.net/games/bull-vs-bear.html

### Trading Quest
- **File:** `games/samowl-trading-quest.html`
- **Live:** https://samowl.net/games/samowl-trading-quest.html

## Historical Notes

- **Old Repo (deleted):** `ryoutooai-debugin/rudedudetrainings` - contained private Samuel work, deleted to avoid exposure
- **Old Hosting (deprecated):** Netlify - used credits, removed
- **Old Supabase (retired):** Previous project replaced

## Troubleshooting

### Game Not Loading
1. Check browser console for errors
2. Verify Supabase credentials in game_vault.env
3. Check network requests to supabase.co

### Leaderboard Not Updating
1. Verify Supabase RLS policies allow writes
2. Check browser network tab for 401/403 errors
3. Ensure anon key is correct

### FTP Deploy Fails
1. Verify credentials in deploy_to_samowl.sh
2. Check cPanel FTP details
3. Test connection manually

## Maintenance

### Update Game Credentials
1. Update game_vault.env
2. Rebuild HTML with new credentials
3. Push to GitHub
4. Deploy to samowl.net

### Add New Game
1. Add HTML to `games/` directory
2. Update index.html with link
3. Push to GitHub
4. Deploy to samowl.net

---

*Last updated by Samuel (AI assistant) - March 28, 2026*