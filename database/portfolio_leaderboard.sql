-- Portfolio Challenge leaderboard (applied to rtbq). Server-authoritative (Phase 2).
-- The client sends holdings; the SERVER values them at real prices from `prices`
-- and writes the score. Clients cannot claim a value or write the table directly.

CREATE TABLE IF NOT EXISTS portfolio_leaderboard (
    player_name     VARCHAR(32) PRIMARY KEY,
    portfolio_value NUMERIC(14, 2) NOT NULL,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE portfolio_leaderboard ENABLE ROW LEVEL SECURITY;

-- Read is public (leaderboard). No direct anon insert/update/delete: writes go
-- ONLY through rpc_submit_score (SECURITY DEFINER), so scores are server-computed.
DROP POLICY IF EXISTS pl_select_all ON portfolio_leaderboard;
CREATE POLICY pl_select_all ON portfolio_leaderboard FOR SELECT TO anon USING (true);

CREATE OR REPLACE FUNCTION rpc_submit_score(p_name TEXT, p_cash NUMERIC, p_holdings JSONB)
RETURNS NUMERIC
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE v_value NUMERIC := 0; v_sym TEXT; v_shares NUMERIC; v_price NUMERIC;
BEGIN
  IF p_name IS NULL OR char_length(trim(p_name)) < 1 OR char_length(p_name) > 32 THEN
    RAISE EXCEPTION 'invalid name'; END IF;
  IF p_cash IS NULL OR p_cash < 0 OR p_cash > 100000000 THEN
    RAISE EXCEPTION 'invalid cash'; END IF;
  v_value := p_cash;
  IF p_holdings IS NOT NULL AND jsonb_typeof(p_holdings) = 'object' THEN
    FOR v_sym, v_shares IN SELECT key, (value)::NUMERIC FROM jsonb_each_text(p_holdings) LOOP
      IF v_shares IS NULL OR v_shares < 0 OR v_shares > 100000000 THEN
        RAISE EXCEPTION 'invalid shares'; END IF;
      SELECT price INTO v_price FROM prices WHERE symbol = v_sym;
      IF v_price IS NOT NULL THEN v_value := v_value + (v_shares * v_price); END IF;
    END LOOP;
  END IF;
  IF v_value < 0 THEN v_value := 0; END IF;
  IF v_value > 100000000 THEN v_value := 100000000; END IF;
  INSERT INTO portfolio_leaderboard (player_name, portfolio_value, updated_at)
  VALUES (p_name, round(v_value, 2), NOW())
  ON CONFLICT (player_name) DO UPDATE SET portfolio_value = EXCLUDED.portfolio_value, updated_at = NOW();
  RETURN round(v_value, 2);
END; $$;
GRANT EXECUTE ON FUNCTION rpc_submit_score(TEXT, NUMERIC, JSONB) TO anon;
