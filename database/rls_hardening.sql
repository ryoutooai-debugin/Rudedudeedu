-- =====================================================================
-- SamOwl RLS Hardening  --  APPLIED & VERIFIED on project rtbqaqkobwwjnbzwvjab
-- =====================================================================
-- This is the authoritative, live state. Safe to re-run (idempotent).
-- Model: public, no-auth, pseudonymous leaderboard. Browser uses the ANON
-- key directly. RLS locks down read/edit/delete abuse. Trade P&L is still
-- self-reported ("fun-tier") until scoring moves server-side (Replay-Sim
-- rebuild) -- see FLIP switch at the bottom.
-- =====================================================================

-- 1) RLS ON for every table
ALTER TABLE users             ENABLE ROW LEVEL SECURITY;
ALTER TABLE trades            ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_cache ENABLE ROW LEVEL SECURITY;

-- 2) Clean slate: drop old permissive policies + any prior version of ours
DROP POLICY IF EXISTS "Users are viewable by everyone"     ON users;
DROP POLICY IF EXISTS "Users can create their own profile" ON users;
DROP POLICY IF EXISTS users_select_all                     ON users;
DROP POLICY IF EXISTS users_insert_anon                    ON users;
DROP POLICY IF EXISTS "Trades are viewable by everyone"    ON trades;
DROP POLICY IF EXISTS trades_select_all                    ON trades;
DROP POLICY IF EXISTS trades_insert_anon                   ON trades;
DROP POLICY IF EXISTS lbcache_select_all                   ON leaderboard_cache;

-- 3) USERS: read all (leaderboard), create pseudonymous profile w/ name bounds,
--    no update/delete for anon (no policy => denied)
CREATE POLICY users_select_all ON users
    FOR SELECT TO anon USING (true);
CREATE POLICY users_insert_anon ON users
    FOR INSERT TO anon WITH CHECK (char_length(display_name) BETWEEN 3 AND 32);

-- 4) TRADES: read all (leaderboard), bounded inserts, no update/delete.
--    NOTE: pnl is self-reported here -> spoofable (fun-tier tradeoff).
CREATE POLICY trades_select_all ON trades
    FOR SELECT TO anon USING (true);
CREATE POLICY trades_insert_anon ON trades
    FOR INSERT TO anon WITH CHECK (
        quantity > 0 AND quantity <= 100000
        AND char_length(symbol) BETWEEN 1 AND 10
        AND status IN ('open', 'closed')
    );

-- 5) LEADERBOARD_CACHE: read all, no anon writes (server/service role only)
CREATE POLICY lbcache_select_all ON leaderboard_cache
    FOR SELECT TO anon USING (true);

-- 6) Harden functions (pin search_path)
ALTER FUNCTION public.get_user_stats(uuid, character varying)   SET search_path = public;
ALTER FUNCTION public.generate_leaderboard(character varying)   SET search_path = public;

-- =====================================================================
-- VERIFIED (anon key, live REST):
--   read users        -> allowed
--   valid user insert -> allowed
--   short name "ab"   -> BLOCKED (401)
--   junk trade insert -> BLOCKED (400)
--   delete row        -> BLOCKED (row survives)
--
-- OPTIONAL FLIP (trustworthy-tier): once scoring is server-side, drop the
-- anon insert on trades so only the service role records verified trades:
--   DROP POLICY IF EXISTS trades_insert_anon ON trades;
-- =====================================================================
