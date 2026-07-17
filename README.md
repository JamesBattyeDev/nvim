# nvim

Personal Neovim configuration built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

## Features

- **Catppuccin Mocha** colour scheme
- **Full JS/TS/HTML/CSS LSP** — vtsls, tailwindcss, eslint, emmet, cssls, css-variables, jsonls
- **Telescope** fuzzy finder with fzf-native backend
- **Treesitter** syntax highlighting, sticky context, and function navigation (`]f` / `[f`)
- **blink.cmp** completion engine with LuaSnip snippets
- **Format on save** — prettierd (JS/TS/CSS/HTML/JSON) + stylua (Lua)
- **Neo-tree** file explorer
- **LazyGit** integration
- **Gitsigns** with inline blame
- **Statusline** — mode, filename, line count, git branch
- **Code folding** via nvim-ufo (treesitter-based)
- **Markdown rendering** in-buffer via render-markdown.nvim
- **Project-wide diagnostics** — `tsc` / `eslint` to quickfix in one keymap
- **AI** — [ThePrimeagen/99](https://github.com/ThePrimeagen/99) wired to Claude (Opus 4.7) via the local `claude` CLI
- **Usage logger** — opt-in JSONL keystroke/mapping/plugin-load tracking for self-analysis
- **GLSL shader** + **styled-components** syntax support

## Requirements

- [Neovim](https://neovim.io/) ≥ **0.12** (uses APIs like `vim.diagnostic.jump` and the new `gr*` LSP defaults)
- git
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- A [Nerd Font](https://www.nerdfonts.com/)
- Node.js & npm (for JS/TS tooling)
- The `claude` CLI (optional, only for the 99 plugin)

## Install

```sh
git clone https://github.com/jamesbattye/nvim.git ~/.config/nvim
nvim
```

Lazy will install all plugins on first launch. Run `:Lazy` to check status.

## Structure

```
~/.config/nvim/
├── init.lua                       # Bootstrap, options, keymaps, autocmds
├── lua/
│   ├── custom/
│   │   ├── plugins/               # One file per plugin (telescope.lua, lsp.lua, …)
│   │   └── usage-logger.lua       # Local keystroke/mapping/plugin-load logger
│   └── kickstart/plugins/         # Kickstart extras (debug.lua is the only one active)
├── usage/                         # (gitignored) usage logger output
├── lazy-lock.json
└── LICENSE.md
```

Each plugin lives in its own file under `lua/custom/plugins/`. Lazy auto-imports the
whole directory via `{ import = 'custom.plugins' }` at the bottom of `init.lua`, so
adding a new plugin is just "drop a new file in there."

## Key Bindings

Leader is **Space**.

### General

| Key                | Action                                                           |
| ------------------ | ---------------------------------------------------------------- |
| `<leader>w`        | Save file                                                        |
| `<leader>x`        | Close buffer                                                     |
| `<leader>f`        | Format buffer                                                    |
| `<leader>e`        | Toggle file explorer                                             |
| `<leader>q`        | Diagnostics quickfix list (open buffers)                         |
| `<C-h/j/k/l>`      | Navigate windows                                                 |
| `J` / `K` (visual) | Move selection up/down                                           |
| `<C-o>` / `<C-i>`  | Jump to previous / next _different_ file (skips same-file jumps) |

### Search (Telescope)

| Key          | Action                            |
| ------------ | --------------------------------- |
| `<leader>sf` | Find files                        |
| `<leader>sg` | Live grep                         |
| `<leader>sw` | Search current word               |
| `<leader>sd` | Search diagnostics (open buffers) |
| `<leader>sr` | Resume last search                |
| `<leader>s.` | Recent files                      |
| `<leader>/`  | Fuzzy search in buffer            |
| `<leader>sp` | Project switcher                  |

### Diagnostics (project-wide)

Runs an external tool, parses output into the quickfix list, then opens it as a
Telescope picker in vertical layout (full-width rows so messages aren't truncated).

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `<leader>tc` | Run `tsc --noEmit` across the project        |
| `<leader>te` | Run `eslint . -f compact` across the project |
| `]q` / `[q`  | Next / prev quickfix item                    |
| `]Q` / `[Q`  | Last / first quickfix item                   |

### Git

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>gg` | LazyGit          |
| `<leader>gs` | Stage hunk       |
| `<leader>gr` | Reset hunk       |
| `<leader>gp` | Preview hunk     |
| `<leader>gb` | Blame line       |
| `]h` / `[h`  | Next / prev hunk |

### LSP

Uses Neovim 0.11+'s native `gr*` mappings.

| Key          | Action                       |
| ------------ | ---------------------------- |
| `grd`        | Go to definition             |
| `grr`        | Go to references             |
| `gri`        | Go to implementation         |
| `grn`        | Rename symbol                |
| `gra`        | Code action                  |
| `K`          | Hover docs                   |
| `gO` / `gW`  | Document / workspace symbols |
| `<leader>th` | Toggle inlay hints           |

### Treesitter navigation

| Key         | Action                                 |
| ----------- | -------------------------------------- |
| `]f` / `[f` | Next / prev function start             |
| `]F` / `[F` | Next / prev function end               |
| `af` / `if` | Around / inside function (text object) |
| `ac` / `ic` | Around / inside class (text object)    |

### AI (99)

99 shells out to your local `claude` CLI; it inherits your Claude Max session
via OAuth, no `ANTHROPIC_API_KEY` needed.

| Key          | Mode       | Action                                       |
| ------------ | ---------- | -------------------------------------------- |
| `<leader>9s` | n          | Agentic project search → quickfix            |
| `<leader>a`  | v / V / ^V | Send selection + prompt, replace with output |
| `<leader>9o` | n          | Reopen last interaction result               |
| `<leader>9l` | n          | View 99 logs                                 |
| `<leader>9x` | n          | Cancel all in-flight requests                |
| `<leader>9c` | n          | Clear previous requests                      |

### Terminals

Five persistent terminal slots, each its own buffer. Re-toggling reopens the same
shell session (history preserved).

| Key                        | Action                                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| `<leader><leader>a`        | Toggle terminal 1                                                                               |
| `<leader><leader>s`        | Toggle terminal 2 _(currently the Claude / AI workspace — migrating to in-editor [99](#ai-99))_ |
| `<leader><leader>d`        | Toggle terminal 3                                                                               |
| `<leader><leader>f`        | Toggle terminal 4                                                                               |
| `<leader><leader>g`        | Toggle terminal 5                                                                               |
| `<leader><leader><leader>` | Close all open terminals                                                                        |
| `<C-n>`                    | Exit terminal insert mode                                                                       |

### Misc

| Key          | Action                                               |
| ------------ | ---------------------------------------------------- |
| `<leader>tu` | Toggle usage logger (writes to `usage/<date>.jsonl`) |
| `<Esc>`      | Clear search highlight                               |

## Usage logger

The local `usage-logger.lua` module captures keystrokes, mode changes, Ex command
verbs, mapping invocations (with their `desc`), and `LazyLoad` events into
`usage/<date>.jsonl` (gitignored). Useful for analysing your own habits with
`jq` — e.g.:

```sh
# Plugins loaded but never invoked
comm -23 \
  <(jq -r 'select(.event=="PluginLoaded") | .plugin' usage/*.jsonl | sort -u) \
  <(jq -r 'select(.event=="mapping" or .event=="CmdlineLeave") | .desc, .verb // empty' usage/*.jsonl | sort -u)

# Most-used keymaps in the last week
jq -r 'select(.event=="mapping") | .desc' usage/*.jsonl | sort | uniq -c | sort -rn | head -20
```

Toggle on/off with `<leader>tu`; runs by default on startup.

## License

[MIT](LICENSE.md)
