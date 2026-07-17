--[[
  James's Neovim Config
  Requires: Neovim 0.12+, tree-sitter-cli (brew install tree-sitter-cli)
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

  Navigation:
  ]m / [m  - Jump to next/prev function start (treesitter)
  ]M / [M  - Jump to next/prev function end (treesitter)
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

-- Quickfix navigation
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix item' })
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz', { desc = 'Previous quickfix item' })
vim.keymap.set('n', ']Q', '<cmd>clast<CR>zz', { desc = 'Last quickfix item' })
vim.keymap.set('n', '[Q', '<cmd>cfirst<CR>zz', { desc = 'First quickfix item' })

-- Project-wide diagnostics via external tools → vim.diagnostic → Telescope diagnostics picker.
-- Publishing into vim.diagnostic (rather than the quickfix list) gives the same nice columnar
-- UI as <leader>sd: severity icon, line:col, message, truncated path. Also keeps the qflist
-- populated as a bonus so ]q / [q still works for serial navigation.
local ns_tsc = vim.api.nvim_create_namespace('tsc')
local ns_eslint = vim.api.nvim_create_namespace('eslint')

local function publish_diagnostics(ns, items, label)
  vim.diagnostic.reset(ns)
  local by_buf = {}
  for _, item in ipairs(items) do
    local bufnr = vim.fn.bufadd(item.filename)
    local lnum = math.max(0, (item.lnum or 1) - 1)
    local col = math.max(0, (item.col or 1) - 1)
    by_buf[bufnr] = by_buf[bufnr] or {}
    table.insert(by_buf[bufnr], {
      lnum = lnum,
      col = col,
      end_lnum = lnum,
      end_col = col + 1,
      severity = item.type == 'W' and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR,
      message = item.text,
      source = label,
    })
  end
  for bufnr, diags in pairs(by_buf) do
    vim.diagnostic.set(ns, bufnr, diags)
  end
end

-- Custom previewer that renders the full diagnostic message as virtual lines
-- anchored above the error line. Auto-sizes to the message height (1 line for
-- short errors, N lines for multi-line errors) and stays in view as you scroll.
local ns_diag_msg = vim.api.nvim_create_namespace('diag_msg_preview')

local function make_diag_previewer()
  local previewers = require('telescope.previewers')
  return previewers.new_buffer_previewer({
    title = 'Diagnostic + Source',
    get_buffer_by_name = function(_, entry) return entry.filename end,
    define_preview = function(self, entry)
      local bufnr = self.state.bufnr
      local filename = entry.filename
      if not filename or filename == '' then return end

      -- Populate buffer only on first load (cached by get_buffer_by_name)
      local existing = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      if #existing <= 1 and (existing[1] or '') == '' then
        local ok, lines = pcall(vim.fn.readfile, filename)
        if not ok then return end
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        local ft = vim.filetype.match({ filename = filename })
        if ft then vim.bo[bufnr].filetype = ft end
      end

      -- Refresh the floating message: clear previous extmark, draw new one
      vim.api.nvim_buf_clear_namespace(bufnr, ns_diag_msg, 0, -1)
      local diag = entry.value or {}
      local msg = diag.message or entry.text or ''
      local severity = diag.severity or vim.diagnostic.severity.ERROR
      local hl = severity == vim.diagnostic.severity.WARN and 'DiagnosticWarn'
        or severity == vim.diagnostic.severity.INFO and 'DiagnosticInfo'
        or severity == vim.diagnostic.severity.HINT and 'DiagnosticHint'
        or 'DiagnosticError'

      local virt_lines = {}
      for _, line in ipairs(vim.split(msg, '\n', { plain = true })) do
        table.insert(virt_lines, { { line, hl } })
      end
      table.insert(virt_lines, { { string.rep('─', 200), 'Comment' } })

      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local target = math.min(math.max(0, (entry.lnum or 1) - 1), math.max(0, line_count - 1))
      vim.api.nvim_buf_set_extmark(bufnr, ns_diag_msg, target, 0, {
        virt_lines = virt_lines,
        virt_lines_above = true,
      })

      -- Center the error line so the message sits just above it, in view.
      pcall(vim.api.nvim_win_set_cursor, self.state.winid, { target + 1, math.max(0, (entry.col or 1) - 1) })
      pcall(vim.api.nvim_win_call, self.state.winid, function() vim.cmd('normal! zz') end)
    end,
  })
end

local function run_to_qf(cmd, label, parse, ns)
  vim.notify('Running ' .. label .. '...', vim.log.levels.INFO)
  vim.system(vim.fn.split(cmd, ' '), { text = true, cwd = vim.fn.getcwd() }, function(obj)
    vim.schedule(function()
      local items = {}
      local cwd = vim.fn.getcwd()
      for _, line in ipairs(vim.fn.split((obj.stdout or '') .. (obj.stderr or ''), '\n')) do
        local item = parse(line, cwd)
        if item then table.insert(items, item) end
      end
      vim.fn.setqflist({}, ' ', { title = label, items = items })
      publish_diagnostics(ns, items, label)
      vim.notify(label .. ': ' .. #items .. ' items', vim.log.levels.INFO)
      if #items > 0 then
        require('telescope.builtin').diagnostics({
          prompt_title = label,
          previewer = make_diag_previewer(),
        })
      end
    end)
  end)
end

-- tsc: "src/foo.ts(12,5): error TS2322: message" or location-less "error TSxxxx: message"
local function parse_tsc(line, cwd)
  local file, lnum, col, text = line:match('^(.-)%((%d+),(%d+)%)%s*:%s*(.+)$')
  if file then
    return { filename = cwd .. '/' .. file, lnum = tonumber(lnum), col = tonumber(col), text = text, type = 'E' }
  end
  -- Config-level errors with no file location (e.g. missing types package)
  local config_err = line:match('^(error TS%d+:.+)$')
  if config_err then
    return { filename = cwd .. '/tsconfig.json', lnum = 1, col = 1, text = config_err, type = 'E' }
  end
  return nil
end

-- eslint compact: "/path/foo.ts: line 12, col 5, Error - message (rule)"
local function parse_eslint(line, _)
  local file, lnum, col, text = line:match('^(.-):%s*line%s+(%d+),%s*col%s+(%d+),%s*(.+)$')
  if not file then return nil end
  return { filename = file, lnum = tonumber(lnum), col = tonumber(col), text = text, type = 'E' }
end

-- Resolve `tsc` per-project: local node_modules/.bin first, then bunx (works in bun
-- repos where typescript isn't installed but bun can fetch it), then npx as fallback.
-- npx prints a "this is not the tsc command" stub when typescript isn't in
-- node_modules, which the parser sees as 0 errors — auto-detection avoids that trap.
local function resolve_tsc()
  local cwd = vim.fn.getcwd()
  local local_tsc = cwd .. '/node_modules/.bin/tsc'
  if vim.fn.executable(local_tsc) == 1 then return local_tsc end
  if vim.fn.executable('bunx') == 1 and vim.fn.filereadable(cwd .. '/bun.lock') == 1 then return 'bunx tsc' end
  if vim.fn.executable('bunx') == 1 and vim.fn.filereadable(cwd .. '/bun.lockb') == 1 then return 'bunx tsc' end
  return 'npx tsc'
end

vim.keymap.set('n', '<leader>tc', function()
  run_to_qf(resolve_tsc() .. ' --noEmit --pretty false', 'tsc', parse_tsc, ns_tsc)
end, { desc = '[T]ypescript [C]heck (project-wide)' })
vim.keymap.set('n', '<leader>te', function() run_to_qf('npx eslint . -f compact', 'eslint', parse_eslint, ns_eslint) end, { desc = '[T]ypescript [E]slint (project-wide)' })

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

-- Send x deletes to the black hole register so they don't clobber yanks
vim.keymap.set({ 'n', 'v' }, 'x', '"_x')
vim.keymap.set({ 'n', 'v' }, 'X', '"_X')

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
vim.keymap.set('n', '<leader><BS>', '<C-^>', { desc = 'Toggle alternate buffer' })

-- Restart LSP clients attached to the current buffer (wraps native :lsp restart)
vim.keymap.set('n', '<leader>lr', '<cmd>lsp restart<CR>', { desc = '[L]sp [R]estart' })

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

  vim.cmd 'botright 50vsplit'

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

-- Keep terminal buffers scrolled to the bottom when re-entering
vim.api.nvim_create_autocmd('WinEnter', {
  callback = function()
    if vim.bo.buftype == 'terminal' and vim.fn.mode() == 'n' then vim.cmd 'normal! G' end
  end,
})

-- Whitespace-aware paragraph motions for terminal buffers
-- Terminal TUIs (like Claude Code) pad "blank" lines with spaces,
-- so Vim's default {/} (which only match truly empty lines) skip over them.
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    local function jump_paragraph(direction)
      local line = vim.fn.line '.'
      local last = vim.fn.line '$'
      local step = direction == 'down' and 1 or -1
      -- Skip current blank/whitespace lines
      while line >= 1 and line <= last and vim.fn.getline(line):match '^%s*$' do
        line = line + step
      end
      -- Find next blank/whitespace line
      while line >= 1 and line <= last and not vim.fn.getline(line):match '^%s*$' do
        line = line + step
      end
      if line >= 1 and line <= last then vim.api.nvim_win_set_cursor(0, { line, 0 }) end
    end

    vim.keymap.set('n', '}', function() jump_paragraph 'down' end, { buffer = true, desc = 'Next paragraph (whitespace-aware)' })
    vim.keymap.set('n', '{', function() jump_paragraph 'up' end, { buffer = true, desc = 'Prev paragraph (whitespace-aware)' })
  end,
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
  require 'kickstart.plugins.debug',
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

require('custom.usage-logger').setup()

-- vim: ts=2 sts=2 sw=2 et
