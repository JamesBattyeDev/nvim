-- For each <leader>-led second key, the average delay between pressing leader
-- and pressing the next key. Long delays = you're forgetting that mapping;
-- candidates for a sticky note or a less buried binding. Leader is logged as
-- the literal token "<Space>" (keytrans output), not a space char.
WITH leader_presses AS (
  SELECT
    strptime(ts, '%Y-%m-%dT%H:%M:%S.%g') AS ts,
    lead(strptime(ts, '%Y-%m-%dT%H:%M:%S.%g')) OVER (ORDER BY ts) AS next_ts,
    lead(key) OVER (ORDER BY ts) AS next_key
  FROM 'usage/*.jsonl'
  WHERE event = 'key' AND key = '<Space>' AND mode = 'n'
)
SELECT
  next_key AS second_key,
  count(*) AS times,
  round(avg(epoch_ms(next_ts - ts)), 0) AS avg_delay_ms,
  round(max(epoch_ms(next_ts - ts)), 0) AS max_delay_ms
FROM leader_presses
WHERE next_ts IS NOT NULL AND epoch_ms(next_ts - ts) < 5000
GROUP BY second_key
HAVING times >= 3
ORDER BY avg_delay_ms DESC
LIMIT 30;
