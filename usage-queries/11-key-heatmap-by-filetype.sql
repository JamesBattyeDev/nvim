-- Top 10 normal-mode keys per filetype. Lets you see e.g. whether you live in
-- 'w' for typescript vs 'j' for markdown.
SELECT ft, key, count(*) AS n
FROM 'usage/*.jsonl'
WHERE event = 'key'
  AND mode = 'n'
  AND ft IS NOT NULL AND ft != ''
GROUP BY ft, key
QUALIFY row_number() OVER (PARTITION BY ft ORDER BY count(*) DESC) <= 10
ORDER BY ft, n DESC;
