-- Daily undo (u) and redo (<C-R>) counts. Spikes = you tried something that
-- didn't work. Useful retrospective signal for "rough day vs clean day."
SELECT
  ts[1:10] AS day,
  count(*) FILTER (WHERE event = 'key' AND key = 'u' AND mode = 'n') AS undos,
  count(*) FILTER (WHERE event = 'key' AND key = '<C-R>' AND mode = 'n') AS redos
FROM 'usage/*.jsonl'
GROUP BY day
ORDER BY day DESC
LIMIT 14;
