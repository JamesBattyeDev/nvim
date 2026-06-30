-- Percentage of <leader> presses that didn't resolve to any mapping. Leader
-- shows up in the log as the token "<Space>" — either alone (the user pressed
-- space and waited) or pre-joined with a follow-up key like "<Space>w" when
-- typed quickly. Both forms count as "started a leader sequence."
WITH leader_keys AS (
  SELECT count(*) AS leaders FROM 'usage/*.jsonl'
  WHERE event = 'key' AND mode = 'n'
    AND (key = '<Space>' OR key LIKE '<Space>%')
),
leader_mappings AS (
  SELECT count(*) AS resolved FROM 'usage/*.jsonl'
  WHERE event = 'mapping' AND lhs LIKE '<Space>%'
)
SELECT
  leaders,
  resolved,
  leaders - resolved AS abandoned,
  round(100.0 * (leaders - resolved) / nullif(leaders, 0), 1) AS abandon_pct
FROM leader_keys, leader_mappings;
