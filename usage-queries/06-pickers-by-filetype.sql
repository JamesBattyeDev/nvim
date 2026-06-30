-- Telescope sessions broken down by the filetype you came FROM. For each key
-- event whose ft is TelescopePrompt, looks at the previous key event's ft
-- when that's NOT TelescopePrompt — i.e., the moment a picker opened.
-- Surfaces which contexts make you reach for a picker.
WITH ordered AS (
  SELECT
    strptime(ts, '%Y-%m-%dT%H:%M:%S.%g') AS ts,
    ft,
    lag(ft) OVER (ORDER BY ts) AS prev_ft
  FROM 'usage/*.jsonl'
  WHERE event = 'key'
)
SELECT
  prev_ft AS source_ft,
  count(*) AS picker_sessions
FROM ordered
WHERE ft = 'TelescopePrompt'
  AND prev_ft IS NOT NULL AND prev_ft != '' AND prev_ft != 'TelescopePrompt'
GROUP BY source_ft
ORDER BY picker_sessions DESC
LIMIT 30;
