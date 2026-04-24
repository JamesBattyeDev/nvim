--[[
  James's Neovim Config
  Based on kickstart.nvim, customized for:
  - Webflow custom code (JS/CSS/HTML)
  - Full-stack JS/TS projects
  - WebGL/shader development (GLSL)
  - General coding & scripting

  Leader key: Space
  Run :Tutor if you're still learning vim motions
  Run :Lazy to manage plugins
  Run :Mason to manage language servers
  Press <space> and wait to see available keybinds (which-key)
--]]

-- Set <space> as the leader key (must happen before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed in your terminal
vim.g.have_nerd_font = true

-- ============================================================================
-- OPTIONS
-- ============================================================================

vim.o.number = true
vim.o.relativenumber = true -- Helps with jumping (e.g., 5j to go down 5 lines)
vim.o.mouse = 'a'
vim.o.showmode = false -- Already shown in statusline
vim.o.breakindent = true
vim.o.undofile = true -- Persistent undo across sessions
vim.o.ignorecase = true
vim.o.smartcase = true -- Case-sensitive if you use capitals
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split' -- Live preview of substitutions
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.termguicolors = true

-- Folding (nvim-ufo handles the actual folding)
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Window separators
vim.opt.fillchars:append { vert = '▐', horiz = '▄', verthoriz = '▐', horizup = '▄', horizdown = '▄', vertleft = '▐', vertright = '▐' }

-- Indentation defaults (guess-indent will override per-file)
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Sync clipboard with OS
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic quickfix
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal insert mode with Ctrl+n
vim.keymap.set('t', '<C-n>', '<C-\\><C-n>', { desc = 'Exit terminal insert mode' })

-- Window navigation with Ctrl+hjkl
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus up' })

-- Window resizing (big jumps)
vim.keymap.set('n', '<C-Left>', '20<C-w><', { desc = 'Shrink window width' })
vim.keymap.set('n', '<C-Right>', '20<C-w>>', { desc = 'Grow window width' })
vim.keymap.set('n', '<C-Up>', '5<C-w>+', { desc = 'Grow window height' })
vim.keymap.set('n', '<C-Down>', '5<C-w>-', { desc = 'Shrink window height' })

-- Move lines up/down in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Keep cursor centered when searching
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Quick save
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = '[W]rite/Save file' })

-- Buffer navigation
vim.keymap.set('n', '<leader>x', '<cmd>bdelete<CR>', { desc = 'Close buffer' })

-- Terminal toggle (bottom panel, supports multiple terminals)
local terminals = {}

function ToggleTerminal(id)
  id = id or 1

  -- If this terminal's window is open, hide it
  if terminals[id] and terminals[id].win and vim.api.nvim_win_is_valid(terminals[id].win) then
    vim.api.nvim_win_hide(terminals[id].win)
    terminals[id].win = nil
    return
  end

  -- Hide any other open terminal windows first
  for _, term in pairs(terminals) do
    if term.win and vim.api.nvim_win_is_valid(term.win) then
      vim.api.nvim_win_hide(term.win)
      term.win = nil
    end
  end

  vim.cmd 'botright 15split'

  if terminals[id] and terminals[id].buf and vim.api.nvim_buf_is_valid(terminals[id].buf) then
    vim.api.nvim_set_current_buf(terminals[id].buf)
  else
    vim.cmd 'terminal'
    terminals[id] = { buf = vim.api.nvim_get_current_buf() }
  end
  terminals[id].win = vim.api.nvim_get_current_win()
  vim.cmd 'startinsert'
end

-- Quick terminal access: <space><space> opens terminal picker
-- a/s/d/f = terminal 1/2/3/4
vim.keymap.set('n', '<leader><leader>a', function() ToggleTerminal(1) end, { desc = 'Terminal 1' })
vim.keymap.set('n', '<leader><leader>s', function() ToggleTerminal(2) end, { desc = 'Terminal 2' })
vim.keymap.set('n', '<leader><leader>d', function() ToggleTerminal(3) end, { desc = 'Terminal 3' })
vim.keymap.set('n', '<leader><leader>f', function() ToggleTerminal(4) end, { desc = 'Terminal 4' })
vim.keymap.set('n', '<leader><leader>g', function() ToggleTerminal(5) end, { desc = 'Terminal 5' })

-- <space><space><space> closes any open terminal
vim.keymap.set('n', '<leader><leader><leader>', function()
  for _, term in pairs(terminals) do
    if term.win and vim.api.nvim_win_is_valid(term.win) then
      vim.api.nvim_win_hide(term.win)
      term.win = nil
    end
  end
end, { desc = 'Close all terminals' })

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Hide statusline on neo-tree
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'neo-tree',
  callback = function() vim.opt_local.statusline = ' ' end,
})

-- Git commit messages: set up for quick editing
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
  end,
})

-- ============================================================================
-- PLUGIN MANAGER (lazy.nvim)
-- ============================================================================

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- ============================================================================
-- PLUGINS
-- ============================================================================

require('lazy').setup({

  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- ========================================================================
  -- THEME: Catppuccin (clean, easy on the eyes, great for long sessions)
  -- ========================================================================
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha', -- latte, frappe, macchiato, mocha
        transparent_background = false,
        integrations = {
          gitsigns = true,
          telescope = { enabled = true },
          treesitter = true,
          mini = { enabled = true },
          which_key = true,
          indent_blankline = { enabled = true },
        },
      }
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- ========================================================================
  -- GIT: Gutter signs + inline blame
  -- ========================================================================
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
      },
      current_line_blame = true, -- Show git blame inline
      current_line_blame_opts = {
        delay = 500,
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation between hunks
        map('n', ']h', gitsigns.next_hunk, { desc = 'Next git [H]unk' })
        map('n', '[h', gitsigns.prev_hunk, { desc = 'Prev git [H]unk' })

        -- Actions
        map('n', '<leader>gs', gitsigns.stage_hunk, { desc = '[G]it [S]tage hunk' })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = '[G]it [R]eset hunk' })
        map('n', '<leader>gS', gitsigns.stage_buffer, { desc = '[G]it [S]tage buffer' })
        map('n', '<leader>gp', gitsigns.preview_hunk, { desc = '[G]it [P]review hunk' })
        map('n', '<leader>gb', gitsigns.blame_line, { desc = '[G]it [B]lame line' })
        map('n', '<leader>gd', gitsigns.diffthis, { desc = '[G]it [D]iff' })
      end,
    },
  },

  -- ========================================================================
  -- WHICH-KEY: Shows pending keybinds as you type
  -- ========================================================================
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- ========================================================================
  -- TELESCOPE: Fuzzy finder (your #1 priority - fast navigation)
  -- ========================================================================
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git/', 'dist/', '.next/' },
          layout_config = {
            horizontal = { preview_width = 0.55 },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'

      -- Search keymaps (all prefixed with <leader>s for [S]earch)
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })

      -- Search in current buffer
      vim.keymap.set(
        'n',
        '<leader>/',
        function()
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = '[/] Fuzzily search in current buffer' }
      )

      -- Search in open files
      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[S]earch [/] in Open Files' }
      )

      -- Search neovim config files
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })

      -- Project switcher: fuzzy find folders in your Code directory
      vim.keymap.set('n', '<leader>sp', function()
        builtin.find_files {
          cwd = '~/Code',
          find_command = { 'fd', '--type', 'd', '--max-depth', '3' },
          prompt_title = 'Switch Project',
          attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
              require('telescope.actions').close(prompt_bufnr)
              local project_path = vim.fn.expand('~/Code/' .. selection.value)
              vim.cmd('cd ' .. project_path)
              vim.cmd('Neotree dir=' .. project_path)
              builtin.find_files { cwd = project_path }
            end)
            return true
          end,
        }
      end, { desc = '[S]earch [P]roject' })
    end,
  },

  -- ========================================================================
  -- LSP: Language servers for JS/TS/HTML/CSS/GLSL + Lua
  -- ========================================================================
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Core LSP navigation
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- Highlight references on cursor hold
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Toggle inlay hints
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic display
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = false, -- Disable inline text (gets cut off in splits)
        virtual_lines = false,
      }

      -- Show diagnostics in a float on cursor hold instead
      vim.api.nvim_create_autocmd('CursorHold', {
        callback = function() vim.diagnostic.open_float(nil, { focusable = false, border = 'rounded', max_width = 80 }) end,
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Language servers
      local servers = {
        -- JavaScript/TypeScript
        ts_ls = {},

        -- HTML
        html = {},

        -- CSS/SCSS
        cssls = {},

        -- Tailwind (if you use it)
        tailwindcss = {},

        -- JSON (package.json, tsconfig, etc.)
        jsonls = {},

        -- ESLint
        eslint = {},

        -- Emmet for fast HTML/CSS expansion
        emmet_ls = {
          filetypes = {
            'html',
            'css',
            'scss',
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
            'jsx',
            'tsx',
          },
        },

        -- Lua (for editing this config)
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Lua formatter
        'prettierd', -- JS/TS/CSS/HTML formatter (fast daemon version)
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- ========================================================================
  -- FORMATTING: Auto-format on save with Prettier + Stylua
  -- ========================================================================
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then return nil end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },

  -- ========================================================================
  -- AUTOCOMPLETION: blink.cmp
  -- ========================================================================
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- Premade snippets for many languages (JS, TS, HTML, CSS, etc.)
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev', 'webflow' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
          webflow = { name = 'Webflow', module = 'webflow-syncer.blink' },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  -- ========================================================================
  -- TREESITTER: Syntax highlighting + code understanding
  -- ========================================================================
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'css',
        'diff',
        'glsl',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'scss',
        'typescript',
        'tsx',
        'vim',
        'vimdoc',
        'yaml',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Treesitter textobjects (function navigation with ]m / [m)
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        move = { set_jumps = true },
      }

      vim.keymap.set(
        { 'n', 'x', 'o' },
        ']m',
        function() require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects') end,
        { desc = 'Next function start' }
      )
      vim.keymap.set(
        { 'n', 'x', 'o' },
        ']M',
        function() require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects') end,
        { desc = 'Next function end' }
      )
      vim.keymap.set(
        { 'n', 'x', 'o' },
        '[m',
        function() require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects') end,
        { desc = 'Previous function start' }
      )
      vim.keymap.set(
        { 'n', 'x', 'o' },
        '[M',
        function() require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects') end,
        { desc = 'Previous function end' }
      )
    end,
  },

  -- Sticky context (shows current function/class at top of viewport)
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    opts = {
      max_lines = 3,
    },
  },

  -- ========================================================================
  -- UI: Clean aesthetic extras
  -- ========================================================================

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = { char = '│' },
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },

  -- Autopairs (auto close brackets, quotes, etc.)
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- Auto close/rename HTML/JSX tags
  {
    'tronikelis/ts-autotag.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  -- Todo comments highlighting
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- ========================================================================
  -- MINI: Collection of small, useful plugins
  -- ========================================================================
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = { enable_autocmd = false },
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better text objects (va), ci', etc.)
      require('mini.ai').setup { n_lines = 500 }

      -- Surround operations (sa, sd, sr)
      require('mini.surround').setup()

      -- Comment toggle (gcc for line, gc in visual mode)
      require('mini.comment').setup {
        options = {
          custom_commentstring = function() return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring end,
        },
      }

      -- Statusline (minimal: mode + filename + git branch)
      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode { trunc_width = 9999 }
            local filename = statusline.section_filename { trunc_width = 9999 }
            local git = statusline.section_git { trunc_width = 9999 }
            local lines = '%L lines'
            return statusline.combine_groups {
              { hl = mode_hl, strings = { ' ' .. mode .. ' ' } },
              { hl = 'MiniStatuslineFilename', strings = { ' ' .. filename .. ' ' } },
              '%=',
              { hl = 'MiniStatuslineDevinfo', strings = { ' ' .. lines .. '  ' .. git .. ' ' } },
            }
          end,
          inactive = function()
            local filename = statusline.section_filename { trunc_width = 9999 }
            return statusline.combine_groups {
              { hl = 'MiniStatuslineInactive', strings = { ' ' .. filename .. ' ' } },
            }
          end,
        },
      }

      -- Stronger contrast: dim inactive, bold active filename
      vim.api.nvim_set_hl(0, 'MiniStatuslineInactive', { fg = '#45475a', bg = '#11111b' })
      vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = '#cdd6f4', bg = '#313244', bold = true })
    end,
  },

  -- ========================================================================
  -- FILE EXPLORER: Neo-tree (sidebar file tree)
  -- ========================================================================
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'File [E]xplorer' },
      { '\\', '<cmd>Neotree toggle<CR>', desc = 'File Explorer' },
    },
    opts = {
      default_component_configs = {
        container = { enable_character_fade = false },
      },
      source_selector = { statusline = false },
      filesystem = {
        follow_current_file = { enabled = true }, -- Auto-reveal current file
        filtered_items = {
          visible = true, -- Show hidden files (dimmed)
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = { '.git', 'node_modules', '.DS_Store' },
        },
      },
      window = {
        width = 35,
        mappings = {
          ['<space>'] = 'none', -- Don't conflict with leader key
          ['l'] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              if not node:is_expanded() then require('neo-tree.sources.filesystem').toggle_directory(state, node) end
            end
          end,
          ['h'] = 'close_node', -- Collapse folder / go to parent
          ['Y'] = function(state)
            local node = state.tree:get_node()
            local filename = node.name
            vim.fn.setreg('+', filename)
            vim.notify('Copied: ' .. filename)
          end,
          ['y'] = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local relative = vim.fn.fnamemodify(filepath, ':.')
            vim.fn.setreg('+', relative)
            vim.notify('Copied: ' .. relative)
          end,
        },
      },
    },
  },

  -- ========================================================================
  -- LAZYGIT: Full git UI from within Neovim
  -- ========================================================================
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = { 'LazyGit' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<CR>', desc = 'Lazy[G]it' },
    },
  },

  -- ========================================================================
  -- WEBFLOW: Project syncer (local dev plugin)
  -- ========================================================================
  {
    dir = '~/Code/personal/webflow-project-syncer',
    cmd = 'WebflowSync',
    ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'html', 'css', 'vue', 'svelte', 'astro' },
    opts = {
      cmp = false, -- using blink.cmp source instead (webflow-syncer.blink)
    },
  },

  -- ========================================================================
  -- FOLDING: nvim-ufo (clean, treesitter-based folding)
  -- ========================================================================
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufReadPost',
    config = function()
      -- Custom fold text: shows first line + number of folded lines
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d lines '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth) end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'Comment' })
        return newVirtText
      end

      require('ufo').setup {
        provider_selector = function() return { 'treesitter', 'indent' } end,
        fold_virt_text_handler = handler,
        close_fold_kinds_for_ft = {
          default = { 'imports' },
        },
      }

      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds except kinds' })
      vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Close folds with level' })
      vim.keymap.set('n', 'zp', function() require('ufo').peekFoldedLinesUnderCursor() end, { desc = 'Peek folded lines' })
    end,
  },

  -- ========================================================================
  -- CSS-IN-JS: Styled-components syntax highlighting
  -- ========================================================================
  {
    'styled-components/vim-styled-components',
    branch = 'main',
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  },

  -- ========================================================================
  -- GLSL: Shader file support
  -- ========================================================================
  {
    'tikhomirov/vim-glsl',
    ft = { 'glsl', 'vert', 'frag', 'geom', 'comp' },
  },

  { import = 'custom.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
