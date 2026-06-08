-- Daily keystroke volume. Rough proxy for "how much was I actually editing."
-- Big drops vs steady = signal of when you switched to TUI/external work.
SELECT
  ts[1:10] AS day,
  count(*) FILTER (WHERE event = 'key') AS keys,
  count(*) FILTER (WHERE event = 'BufWritePost') AS saves,
  count(DISTINCT buf) FILTER (WHERE event = 'BufEnter') AS buffers_touched
FROM 'usage/*.jsonl'
GROUP BY day
ORDER BY day;
