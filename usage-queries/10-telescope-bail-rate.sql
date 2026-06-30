-- Per-day Telescope picker outcomes. A "session ending" key is <CR> (accepted
-- a result) or <Esc>/q (bailed). High bail rate = decision paralysis or you
-- opened the wrong picker. Telescope launches from mappings (not :Telescope),
-- so cmdline-verb counts miss everything; counting terminator keys inside
-- TelescopePrompt is the cleanest signal. (BufEnter fires before filetype is
-- set, so it can't be used here.)
SELECT
  ts[1:10] AS day,
  count(*) FILTER (WHERE key = '<CR>') AS selected,
  count(*) FILTER (WHERE key IN ('<Esc>', 'q')) AS bailed,
  count(*) FILTER (WHERE key IN ('<CR>', '<Esc>', 'q')) AS total_sessions,
  round(100.0 * count(*) FILTER (WHERE key IN ('<Esc>', 'q'))
        / nullif(count(*) FILTER (WHERE key IN ('<CR>', '<Esc>', 'q')), 0), 1)
        AS bail_pct
FROM 'usage/*.jsonl'
WHERE event = 'key' AND ft = 'TelescopePrompt'
GROUP BY day
ORDER BY day;
