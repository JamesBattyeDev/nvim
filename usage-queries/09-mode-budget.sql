-- How much time you spend in each mode. >10min gaps treated as idle and
-- dropped (assume you walked away). Useful insert-vs-normal ratio check.
WITH mode_events AS (
  SELECT
    strptime(ts, '%Y-%m-%dT%H:%M:%S.%g') AS ts,
    new_mode AS mode,
    lead(strptime(ts, '%Y-%m-%dT%H:%M:%S.%g')) OVER (ORDER BY ts) AS next_ts
  FROM 'usage/*.jsonl'
  WHERE event = 'ModeChanged'
)
SELECT
  mode,
  round(sum(epoch_ms(next_ts - ts)) / 1000.0 / 60.0, 1) AS minutes,
  round(100.0 * sum(epoch_ms(next_ts - ts))
        / sum(sum(epoch_ms(next_ts - ts))) OVER (), 1) AS pct
FROM mode_events
WHERE next_ts IS NOT NULL AND epoch_ms(next_ts - ts) < 600000
GROUP BY mode
ORDER BY minutes DESC;
