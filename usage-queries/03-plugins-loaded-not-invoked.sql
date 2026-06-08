-- Plugins that lazy.nvim loaded but you never invoked via a mapping or :command.
-- Heuristic: fuzzy-match plugin name against any mapping desc or cmdline verb.
-- False positives possible (e.g. silently-active plugins like treesitter), but
-- a useful starting point for "what could I drop?"
WITH loaded AS (
  SELECT DISTINCT plugin FROM 'usage/*.jsonl' WHERE event = 'PluginLoaded'
),
used AS (
  SELECT DISTINCT lower(verb) AS p FROM 'usage/*.jsonl' WHERE verb IS NOT NULL
  UNION
  SELECT DISTINCT lower("desc") AS p FROM 'usage/*.jsonl' WHERE "desc" IS NOT NULL
)
SELECT plugin
FROM loaded
WHERE NOT EXISTS (
  SELECT 1 FROM used
  WHERE used.p LIKE '%' || lower(replace(plugin, '.nvim', '')) || '%'
)
ORDER BY plugin;
