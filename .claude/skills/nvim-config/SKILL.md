---
name: nvim-config
description: Use whenever working with the user's Neovim config at ~/.config/nvim, editing any file under that directory, debugging LSP/keymap/completion behavior in their nvim, or answering questions that involve nvim commands, vim.lsp / vim.diagnostic / vim.treesitter APIs, lua plugin setup, or kickstart.nvim patterns. The user runs nvim 0.12 — many APIs and commands from older guides (notably :LspInfo, vim.lsp.get_active_clients, vim.diagnostic.goto_next, vim.lsp.buf_get_clients) are removed or deprecated, so always trigger this skill before suggesting any nvim command, keymap, or lua snippet so suggestions don't reference removed APIs. Also triggers on errors like "Not an editor command" for old LSP commands, or when the user is investigating why grr/grn/gra aren't working as expected.
metadata:
  type: reference
---

# Working with the user's Neovim config

The user runs **Neovim 0.12** with a config derived from **kickstart.nvim**, located at `~/.config/nvim`. This skill exists because a lot of nvim guidance on the web targets 0.9/0.10 and references APIs that are now removed or deprecated. Suggesting `:LspInfo` or `vim.lsp.get_active_clients()` here produces "Not an editor command" / deprecation warnings, which is exactly the friction this skill prevents.

The goal: when you suggest a command, keymap, or lua snippet, it should *just work* on their setup the first time.

## Config layout

```
~/.config/nvim/
├── init.lua                         # main config (lazy.nvim, LSP, keymaps, plugins)
├── lua/
│   ├── custom/plugins/init.lua      # user's own plugin additions
│   └── kickstart/plugins/           # optional kickstart modules (debug, gitsigns, lint, etc.)
```

Plugin manager: **lazy.nvim**. LSP installed via **mason** + **mason-lspconfig** + **nvim-lspconfig**. Completion: **blink.cmp** (not nvim-cmp). Formatting: **conform.nvim** (prettierd/stylua) on save. Treesitter for syntax + function navigation.

Active language servers (init.lua ~line 596): `ts_ls`, `html`, `cssls`, `tailwindcss`, `jsonls`, `eslint`, `emmet_ls`, `lua_ls`.

## LSP keymaps in this config

The user follows the **nvim 0.11+ `gr*` convention** (kickstart adopted these as defaults). When recommending an LSP action, refer to these — don't invent `<leader>rn` style mappings:

| Keymap | Action |
|--------|--------|
| `grn`  | rename symbol (`vim.lsp.buf.rename`) |
| `gra`  | code action (`vim.lsp.buf.code_action`) |
| `grr`  | references (telescope) |
| `gri`  | implementation (telescope) |
| `grd`  | definition |
| `grD`  | declaration |
| `grt`  | type definition |
| `gO`   | document symbols |
| `gW`   | workspace symbols |
| `K`    | hover docs |

## Removed or deprecated APIs — always use the right-hand column

The user is on 0.12; the left column will fail or warn. This is the single most important thing to get right.

### Commands

| Don't suggest                  | Use instead                          | Notes |
|--------------------------------|--------------------------------------|-------|
| `:LspInfo`                     | `:checkhealth vim.lsp`               | removed from nvim-lspconfig; native checkhealth replaces it |
| `:LspLog`                      | `:lua vim.cmd.edit(vim.lsp.get_log_path())` or `:e ~/.local/state/nvim/lsp.log` | also removed — use the lua form or open the file directly |
| `:LspStart` / `:LspStop` / `:LspRestart` | `:lua vim.lsp.start(...)` / `:lua vim.lsp.stop_client(...)` / stop + reopen | **the whole `:Lsp*` command family is gone in modern nvim-lspconfig.** Assume no `:Lsp...` user command exists |

Useful native one-liners (since you can't `:Lsp*`):

```vim
" Stop a specific server by name
:lua vim.lsp.stop_client(vim.lsp.get_clients({ name = 'ts_ls' }))

" Stop everything on the current buffer
:lua vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = 0 }))

" Restart-everything pattern (clients re-attach on next file event)
:lua for _, c in ipairs(vim.lsp.get_clients()) do vim.lsp.stop_client(c.id) end
```
| `:TSUpdate`/`:TSInstall`       | same — still valid                    | treesitter commands unchanged |
| `:Mason`                       | same — still valid                    | |

### `vim.lsp` API

| Deprecated / removed                    | Use instead                                      |
|-----------------------------------------|--------------------------------------------------|
| `vim.lsp.get_active_clients()`          | `vim.lsp.get_clients()`                          |
| `vim.lsp.buf_get_clients(bufnr)`        | `vim.lsp.get_clients({ bufnr = bufnr })`         |
| `client.resolved_capabilities`          | `client.server_capabilities`                     |
| `client.supports_method(method)`        | `client:supports_method(method, bufnr)` (method form) |
| `vim.lsp.diagnostic.*`                  | `vim.diagnostic.*` (moved out of `lsp.` years ago, but still seen in old guides) |

### `vim.diagnostic` API

| Deprecated                              | Use instead                                      |
|-----------------------------------------|--------------------------------------------------|
| `vim.diagnostic.goto_next()`            | `vim.diagnostic.jump({ count = 1 })`             |
| `vim.diagnostic.goto_prev()`            | `vim.diagnostic.jump({ count = -1 })`            |
| `vim.diagnostic.get_next()` (still ok)  | `vim.diagnostic.get_next({ ... })`               |

Default keymaps `[d` and `]d` already wrap `vim.diagnostic.jump` in 0.11+.

### Other moved/renamed surface area

- `vim.loop` → `vim.uv` (both still resolve, but `vim.uv` is canonical)
- `vim.lsp.start_client()` → `vim.lsp.start()` for ad-hoc clients
- For looping/filtering tables, prefer `vim.iter(...)` over manual `pairs` chains in new code

## Native LSP config (`vim.lsp.config` / `vim.lsp.enable`)

Nvim 0.11 introduced native, lspconfig-free configuration:

```lua
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'package.json' },
})
vim.lsp.enable('ts_ls')
```

The user's current config still uses `require('lspconfig')[server_name].setup(server)` through the mason-lspconfig handler (init.lua ~line 645). **Don't rip this out unprompted** — it works fine in 0.12 and the mason integration is doing useful work. Only suggest migrating to `vim.lsp.config` / `vim.lsp.enable` if the user explicitly asks to modernize, or if there's a specific bug that native config fixes. When you do suggest it, explain the tradeoff: you lose mason-lspconfig's auto-wiring but gain less indirection.

## Diagnosing LSP problems on this config

When the user reports LSP weirdness (rename only hits one file, no completions, "no references found"), the workflow is:

1. **`:checkhealth vim.lsp`** — shows every attached client, its `root_dir`, attached buffer count, and recent errors. This is the single most useful diagnostic.
2. One-liners for quick checks inside a buffer:
   ```vim
   :lua =vim.lsp.get_clients({ bufnr = 0 })[1].root_dir
   :lua =#vim.lsp.get_clients({ bufnr = 0 })[1].attached_buffers
   ```
3. `:lua vim.cmd.edit(vim.lsp.get_log_path())` for the raw log (default path: `~/.local/state/nvim/lsp.log`). `:LspLog` no longer exists.
4. `:Mason` to confirm the server binary is installed.

**Two common root causes for `ts_ls` weirdness on big projects:**

1. **Single-file mode** — the server attached without a proper workspace root. Symptom: `root_dir` is wrong / nil in `:checkhealth vim.lsp`. Fix: ensure `tsconfig.json` / `package.json` exists at the expected root.

2. **Incomplete reference results** — `ts_ls` returns references *only* in files already loaded into the TS server's program (typically files you've opened in nvim), even when other consumers exist on disk and are in `tsconfig.json`'s `include`. Symptom: `grr` returns 3-5 results in big projects where you know there should be 20+; `:lua vim.lsp.buf.references()` confirms (rules out telescope). Look in `:lua vim.cmd.edit(vim.lsp.get_log_path())` for repeated `LSP[ts_ls] "Cannot find request with id X whilst attempting to cancel"` — the TS server is dropping requests under load. **Fix: switch to `vtsls`** (see below). This is a known `ts_ls` limitation on large Next.js / monorepo codebases.

### `vtsls` is the recommended TypeScript LSP for big projects

`vtsls` is the modern wrapper around `tsserver` (same one VS Code uses internally). It's a drop-in replacement for `ts_ls` with proper project-wide references and rename, much better memory handling, and significantly faster on Next.js / monorepo projects. The user's config currently uses `ts_ls = {}` (init.lua ~line 598) — recommend migrating to `vtsls` if they hit incomplete `grr`/`grn` results.

To migrate: install via `:Mason` (search `vtsls`), then in init.lua replace `ts_ls = {},` with:
```lua
vtsls = {
  settings = {
    typescript = {
      tsserver = { maxTsServerMemory = 8192 },
    },
  },
},
```

## blink.cmp specifics

The user is on **blink.cmp**, not nvim-cmp. Don't suggest `require('cmp').setup{...}` or `cmp.mapping` — those are wrong here. blink.cmp uses its own config under `opts = { keymap = ..., sources = ..., completion = ... }`. Capabilities flow through `require('blink.cmp').get_lsp_capabilities()` (init.lua ~line 593) — preserve this when editing LSP setup.

## Editing the config

- Lua formatting: **stylua** runs on save via conform.nvim. Don't fight it on indentation/quote style.
- New plugins go in `lua/custom/plugins/init.lua` (or a new file in `lua/custom/plugins/` — lazy.nvim picks them up automatically).
- After editing init.lua, `:Lazy sync` if plugins changed; otherwise restart nvim.
- Health check anything you suspect: `:checkhealth <module>` — e.g. `:checkhealth lazy`, `:checkhealth mason`, `:checkhealth vim.treesitter`.

## When you're not sure if something is current

If you're about to recommend an API and you can't remember whether it was renamed in 0.10/0.11/0.12, check `:h <api>` in the docs before suggesting it, or grep the nvim runtime: `nvim --headless +'lua print(vim.fn.exepath("nvim"))' +q` gives the binary, and `:h news` lists breaking changes per release. Better to verify than to send the user down another `:LspInfo` rabbit hole.
