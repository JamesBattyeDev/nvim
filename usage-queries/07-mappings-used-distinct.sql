-- Distinct mapping descs you've ever fired. Compare against your config to
-- spot bound-but-untouched keymaps (dead keymaps you could repurpose).
SELECT "desc", count(*) AS times, min(ts) AS first_used, max(ts) AS last_used
FROM 'usage/*.jsonl'
WHERE event = 'mapping'
GROUP BY "desc"
ORDER BY last_used DESC;
