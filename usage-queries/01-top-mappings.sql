-- Most-used keymaps (mappings with a `desc` field). Best signal for
-- "which custom keymaps are actually earning their slot."
SELECT "desc", count(*) AS n
FROM 'usage/*.jsonl'
WHERE event = 'mapping'
GROUP BY "desc"
ORDER BY n DESC
LIMIT 30;
