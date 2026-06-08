-- Most-pressed individual keys in normal mode. Surfaces your true muscle
-- memory: if you press 'j' 50x more than 'gj', you don't use wrap-aware moves.
SELECT key, count(*) AS n
FROM 'usage/*.jsonl'
WHERE event = 'key' AND mode = 'n'
GROUP BY key
ORDER BY n DESC
LIMIT 30;
