// Deployed to Supabase project rtbqaqkobwwjnbzwvjab as edge function `refresh-prices`.
// Cron `refresh-prices-rotate` (*/6 13-20 UTC Mon-Fri) invokes it via pg_net.
//
// Auto-rotating price feed for Portfolio Challenge: fetches 8 tickers per call
// (Twelve Data free = 8 credits/min), advances a cursor, cycles the whole basket.
// Add as many tickers as you like -- daily cost stays flat (~640/day, under 800);
// each symbol just refreshes a bit less often.
//
// Secrets used (Supabase Edge Function secrets): Price_API_KEY (Twelve Data).
// SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY are auto-injected.

import { createClient } from "jsr:@supabase/supabase-js@2";

const TICKERS = [
  "AAPL","GOOGL","MSFT","NVDA","NFLX","AMZN","META","TSLA","AMD",
  "OXY","CVX","JPM","V","JNJ","UNH","HD","PG"
];
const CHUNK_SIZE = 8;          // Twelve Data free = 8 credits/min
const MIN_GAP_MS = 30_000;     // anti-spam: skip if a fetch happened <30s ago

function json(b: unknown, s = 200): Response {
  return new Response(JSON.stringify(b), { status: s, headers: { "Content-Type": "application/json" } });
}
function chunk<T>(arr: T[], n: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // anti-spam throttle (most-recent fetch across the table)
  const { data: last } = await supabase
    .from("prices").select("updated_at")
    .order("updated_at", { ascending: false }).limit(1).maybeSingle();
  if (last?.updated_at && Date.now() - new Date(last.updated_at).getTime() < MIN_GAP_MS) {
    return json({ skipped: "throttled", last: last.updated_at });
  }

  const apiKey = Deno.env.get("PRICE_API_KEY") ?? Deno.env.get("Price_API_KEY");
  if (!apiKey) return json({ error: "PRICE_API_KEY not set" }, 500);

  const chunks = chunk(TICKERS, CHUNK_SIZE);

  // read + advance rotation cursor
  const { data: cur } = await supabase
    .from("price_cursor").select("chunk_idx").eq("id", 1).maybeSingle();
  const idx = (((cur?.chunk_idx ?? 0) % chunks.length) + chunks.length) % chunks.length;
  const batch = chunks[idx];
  const nextIdx = (idx + 1) % chunks.length;
  await supabase.from("price_cursor").upsert({ id: 1, chunk_idx: nextIdx });

  // fetch just this chunk (<= 8 symbols = within the per-minute limit)
  const url = `https://api.twelvedata.com/quote?symbol=${batch.join(",")}&apikey=${apiKey}`;
  let data: Record<string, any>;
  try {
    const r = await fetch(url);
    data = await r.json();
  } catch (e) {
    return json({ error: "fetch failed", detail: String(e) }, 502);
  }

  const nowIso = new Date().toISOString();
  const rows: any[] = [];
  for (const sym of batch) {
    const q = data?.[sym] ?? (data?.symbol === sym ? data : null);
    if (!q || q.status === "error" || q.close == null) continue;
    rows.push({
      symbol: sym,
      price: Number(q.close),
      prev_close: q.previous_close != null ? Number(q.previous_close) : null,
      change_pct: q.percent_change != null ? Number(q.percent_change) : null,
      source: "twelvedata",
      updated_at: nowIso,
    });
  }
  if (rows.length === 0) return json({ error: "no quotes parsed", chunk: idx, provider_sample: data }, 502);

  const { error } = await supabase.from("prices").upsert(rows, { onConflict: "symbol" });
  if (error) return json({ error: error.message }, 500);

  return json({
    chunk: idx, next: nextIdx, chunks: chunks.length, total_tickers: TICKERS.length,
    updated: rows.length, symbols: rows.map((r) => r.symbol),
  });
});
