-- Percentage of <leader> presses that didn't resolve to any mapping. Leader =
-- literal Space, so we look at lhs starting with ' '. A high abandon rate
-- means you're starting sequences and bailing — usually "couldn't remember."
WITH leader_keys AS (
  SELECT count(*) AS leaders FROM 'usage/*.jsonl'
  WHERE event = 'key' AND key = ' ' AND mode = 'n'
),
leader_mappings AS (
  SELECT count(*) AS resolved FROM 'usage/*.jsonl'
  WHERE event = 'mapping' AND lhs LIKE ' %'
)
SELECT
  leaders,
  resolved,
  leaders - resolved AS abandoned,
  round(100.0 * (leaders - resolved) / nullif(leaders, 0), 1) AS abandon_pct
FROM leader_keys, leader_mappings;
