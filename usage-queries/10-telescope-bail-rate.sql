-- Per-day count of cmdlines started vs Telescope commands actually completed.
-- High ratio of start-but-no-Telescope-completion = decision paralysis or
-- typo-and-abort behaviour. Not a perfect signal but trends are real.
SELECT
  ts[1:10] AS day,
  count(*) FILTER (WHERE event = 'CmdlineEnter' AND cmdtype = ':') AS cmdlines_started,
  count(*) FILTER (WHERE event = 'CmdlineLeave' AND verb = 'Telescope') AS telescope_completed,
  count(*) FILTER (WHERE event = 'CmdlineLeave' AND verb IS NOT NULL) AS any_verb_completed
FROM 'usage/*.jsonl'
GROUP BY day
ORDER BY day;
