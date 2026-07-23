# Portfolio Challenge — Live-ish Price Feed Plan

Goal: 15-min-delayed quotes for a basket of stocks, refreshed server-side, so the
Portfolio Challenge (game B) values portfolios at "today's" prices and the
leaderboard is a fair, uncheatable, same-market competition.

## Architecture (no key ever touches the browser)
```
pg_cron (every 15 min, market hours)
  -> Supabase Edge Function `refresh-prices`
       -> ONE batch quote call to provider   [API key = Supabase secret]
       -> UPSERT into public.prices
Game reads public.prices (anon SELECT, already secured)
```
One fetch feeds all players. No client API key. No CORS. No rate-limit blowups.

## prices table (DONE, live in rtbq)
symbol PK, price, prev_close, change_pct, source, updated_at.
RLS: anon SELECT only; writes = service role (the Edge Function) only.

## Decisions needed from Rude
1. **Provider** (must offer DELAYED INTRADAY on free tier, not EOD-only):
   - Twelve Data — free 800/day, 8/min, batch `?symbol=AAPL,MSFT,...` (recommended)
   - Finnhub — free 60/min, per-symbol (no batch)
   - FMP — batch `/quote/AAPL,MSFT`, but verify free tier isn't EOD-only
   -> Rude signs up, gets API key. Key stored as Supabase secret (never in repo/browser).
2. **Ticker basket** — start with the existing 17 from price.json
   (AAPL GOOGL MSFT NVDA NFLX AMZN META TSLA AMD OXY CVX JPM V JNJ UNH HD PG).
3. **Cadence** — every 15 min, 9:30-16:00 ET Mon-Fri only (~26 calls/day = well under any free tier). Off-hours: last prices persist.

## Build steps
- [x] prices table + RLS  (+ price_cursor table for rotation, internal/locked)
- [x] Twelve Data key set as Supabase secret (named `Price_API_KEY`; function reads either casing)
- [x] Edge Function `refresh-prices` v5 -- AUTO-ROTATING: fetches 8 tickers/call, advances a
      cursor, cycles the whole basket. Add unlimited tickers; daily cost stays flat.
- [x] pg_cron `refresh-prices-rotate` (*/6 13-20 UTC Mon-Fri) -- ACTIVE. Rotation verified.
- [ ] Repoint game: read prices from Supabase `prices` instead of static price.json  <-- NEXT

## Notes / gotchas
- Twelve Data FREE = 8 credits/min AND 800 credits/day; 1 credit PER symbol (even batched).
  It's a RATE, not a hard cap -> we rotate 8/call to cover any-size basket for free.
- Current basket = 17 tickers -> 3 chunks -> each refreshes ~every 18 min. To add more, just edit
  TICKERS in the function; cost stays ~640/day (80 fires x 8). More tickers = each refreshes less often.
- Cadence math: */6 over 13-20 UTC = 80 fires/day x 8 = 640/day (under 800). Keep fires x 8 < 800.
- Secret name casing matters (env vars case-sensitive); it's `Price_API_KEY` in the dashboard.
- verify_jwt=false (cron/webhook style); 30s anti-spam throttle; only writes public delayed prices.
- yfinance/Yahoo = free + many-symbols-per-call + no key, BUT Python (won't run in Deno edge fn;
  you'd hit query1.finance.yahoo.com directly) and unofficial/ToS-gray/fragile. Back-pocket option.

## Phase 2 — trustworthy leaderboard (later)
Store player HOLDINGS (buys/sells), value portfolio server-side = holdings x prices.
Score is computed, not client-claimed -> uncheatable. Uses the same prices table.
