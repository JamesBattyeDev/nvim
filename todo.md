# todo

Running list of things to revisit in this nvim config.

## Remap `<leader>sp`

The current binding is "project switcher" (fuzzy-find a folder under `~/Code`,
`cd` + open Neotree). I never use it — I open a new iTerm tab and `cd` instead.

Source: `lua/custom/plugins/telescope.lua` (around line 87).

Candidate replacements:

- **Harpoon-style buffer marks** — pin 2–4 files, jump with `<leader>1`–`4`. Strong fit for bouncing between a page + a util in Next.js work.
- **`:Telescope resume`** — reopen the last picker with state preserved. Boring-sounding, gets used constantly once bound.
- **`:Telescope git_status`** — fuzzy over uncommitted files. Useful mid-feature.
- **Search persisted prompts** — if/when I keep a `prompts/` dir for 99 / Claude system prompts.
