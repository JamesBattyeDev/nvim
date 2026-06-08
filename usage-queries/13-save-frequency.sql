-- Manual :w invocations vs total BufWritePost events. format-on-save fires
-- the latter automatically; if manual saves are still high, you're :w-ing out
-- of habit and could rely on the autoformatter.
SELECT
  ts[1:10] AS day,
  count(*) FILTER (WHERE event = 'CmdlineLeave' AND verb = 'w') AS manual_saves,
  count(*) FILTER (WHERE event = 'BufWritePost') AS total_writes,
  round(100.0 * count(*) FILTER (WHERE event = 'CmdlineLeave' AND verb = 'w')
        / nullif(count(*) FILTER (WHERE event = 'BufWritePost'), 0), 1) AS manual_pct
FROM 'usage/*.jsonl'
GROUP BY day
ORDER BY day DESC
LIMIT 14;
