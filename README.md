# nvim

Personal Neovim configuration built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

<!-- ![screenshot](screenshot.png) -->

## Features

- **Catppuccin Mocha** colour scheme
- **Full JS/TS/HTML/CSS LSP** — ts_ls, tailwindcss, eslint, emmet, cssls, jsonls
- **Telescope** fuzzy finder with fzf-native backend
- **Treesitter** syntax highlighting + sticky context
- **blink.cmp** completion engine with LuaSnip snippets
- **Format on save** — prettierd (JS/TS/CSS/HTML/JSON) + stylua (Lua)
- **Neo-tree** file explorer
- **LazyGit** integration
- **Gitsigns** with inline blame
- **Multiple terminal buffers** (4 quick-toggle slots)
- **Code folding** via nvim-ufo (treesitter-based)
- **GLSL shader** syntax support

## Requirements

- [Neovim](https://neovim.io/) stable (≥ 0.10)
- git
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- A [Nerd Font](https://www.nerdfonts.com/)
- Node.js & npm (for JS/TS tooling)

## Install

```sh
git clone https://github.com/jamesbattye/nvim.git ~/.config/nvim
nvim
```

Lazy will install all plugins on first launch. Run `:Lazy` to check status.

## Structure

```
~/.config/nvim/
├── init.lua                 # Main configuration
├── lua/
│   ├── custom/plugins/      # Your own plugin specs
│   └── kickstart/plugins/   # Bundled extras (gitsigns, neo-tree, etc.)
├── lazy-lock.json
└── LICENSE.md
```

## Key Bindings

Leader is **Space**.

### General

| Key | Action |
| --- | --- |
| `<leader>w` | Save file |
| `<leader>x` | Close buffer |
| `<leader>f` | Format buffer |
| `<leader>e` | Toggle file explorer |
| `<leader>q` | Diagnostics quickfix list |
| `<C-h/j/k/l>` | Navigate windows |
| `J` / `K` (visual) | Move selection up/down |

### Search (Telescope)

| Key | Action |
| --- | --- |
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Search current word |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader>/` | Fuzzy search in buffer |
| `<leader>sp` | Project switcher |

### Git

| Key | Action |
| --- | --- |
| `<leader>gg` | LazyGit |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line |
| `]h` / `[h` | Next / prev hunk |

### LSP

| Key | Action |
| --- | --- |
| `grd` | Go to definition |
| `grr` | Go to references |
| `gri` | Go to implementation |
| `grn` | Rename symbol |
| `gra` | Code action |
| `K` | Hover docs |
| `<leader>th` | Toggle inlay hints |

### Terminals

| Key | Action |
| --- | --- |
| `<leader>t1` – `t4` | Toggle terminal 1–4 |
| `<leader>tt` | Toggle terminal 1 |
| `<C-n>` | Exit terminal mode |

## License

[MIT](LICENSE.md)
