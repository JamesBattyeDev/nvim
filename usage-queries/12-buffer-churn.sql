-- Per-hour buffer-switch activity. Spikes of many BufEnters with few unique
-- buffers = bouncing between the same 2-3 files repeatedly = harpoon candidate.
SELECT
  ts[1:13] AS hour,
  count(*) FILTER (WHERE event = 'BufEnter') AS buf_enters,
  count(DISTINCT buf) FILTER (WHERE event = 'BufEnter') AS unique_buffers,
  round(1.0 * count(*) FILTER (WHERE event = 'BufEnter')
        / nullif(count(DISTINCT buf) FILTER (WHERE event = 'BufEnter'), 0), 1)
        AS enters_per_unique
FROM 'usage/*.jsonl'
GROUP BY hour
HAVING buf_enters > 5
ORDER BY hour DESC
LIMIT 48;
