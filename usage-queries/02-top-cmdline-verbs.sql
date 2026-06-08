-- Most-used :Ex command verbs. Captures TUI-launched plugin commands
-- (Telescope, LazyGit, Neotree, Mason, Lazy, etc.) and built-in verbs (w, q).
SELECT verb, count(*) AS n
FROM 'usage/*.jsonl'
WHERE event = 'CmdlineLeave' AND verb IS NOT NULL
GROUP BY verb
ORDER BY n DESC
LIMIT 30;
