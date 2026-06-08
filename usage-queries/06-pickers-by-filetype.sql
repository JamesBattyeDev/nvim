-- Telescope/search mappings broken down by the filetype you were editing.
-- Surfaces which pickers you actually reach for in which contexts.
SELECT ft, "desc", count(*) AS n
FROM 'usage/*.jsonl'
WHERE event = 'mapping'
  AND "desc" LIKE '[S]earch%'
  AND ft IS NOT NULL AND ft != ''
GROUP BY ft, "desc"
ORDER BY n DESC
LIMIT 30;
