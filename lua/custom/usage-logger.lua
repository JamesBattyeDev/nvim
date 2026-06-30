-- Usage Logger — logs Neovim usage patterns for LLM analysis
-- Toggle: <leader>tu | Logs: usage/*.jsonl (gitignored)

local M = {}

local enabled = false
local augroup = nil
local on_key_ns = nil
local log_buffer = {}
local flush_timer = nil
local FLUSH_INTERVAL_MS = 10000
local FLUSH_THRESHOLD = 100
local SEQ_TIMEOUT_MS = 1500
local CONFIG_DIR = vim.fn.stdpath 'config'
local USAGE_DIR = CONFIG_DIR .. '/usage'

-- Rolling buffer for resolving keymap sequences to their `desc` text
local key_seq = ''
local seq_timer = nil

-- Modes where keystrokes are logged (normal, visual, visual-line, visual-block, operator-pending)
local LOG_MODES = { n = true, v = true, V = true, ['\22'] = true, no = true }

local function get_timestamp()
  local sec, usec = vim.uv.gettimeofday()
  local ms = math.floor(usec / 1000)
  return os.date('!%Y-%m-%dT%H:%M:%S', sec) .. string.format('.%03d', ms)
end

local function get_log_path()
  return USAGE_DIR .. '/' .. os.date '%Y-%m-%d' .. '.jsonl'
end

local function buf_context()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  return {
    buf = vim.fn.fnamemodify(name, ':t'),
    ft = vim.bo[buf].filetype,
  }
end

local function log_entry(event_name, data)
  if not enabled then
    return
  end
  data = data or {}
  data.ts = get_timestamp()
  data.event = event_name
  if not data.buf then
    local ctx = buf_context()
    data.buf = ctx.buf
    data.ft = ctx.ft
  end
  table.insert(log_buffer, vim.json.encode(data))
  if #log_buffer >= FLUSH_THRESHOLD then
    M._flush()
  end
end

function M._flush()
  if #log_buffer == 0 then
    return
  end
  local path = get_log_path()
  local lines = table.concat(log_buffer, '\n') .. '\n'
  log_buffer = {}

  vim.uv.fs_open(path, 'a', 438, function(err_open, fd)
    if err_open or not fd then
      return
    end
    vim.uv.fs_write(fd, lines, -1, function()
      vim.uv.fs_close(fd, function() end)
    end)
  end)
end

local function flush_sync()
  if #log_buffer == 0 then
    return
  end
  local path = get_log_path()
  local lines = table.concat(log_buffer, '\n') .. '\n'
  log_buffer = {}
  local fd = vim.uv.fs_open(path, 'a', 438)
  if fd then
    vim.uv.fs_write(fd, lines)
    vim.uv.fs_close(fd)
  end
end

local function reset_seq()
  key_seq = ''
  if seq_timer then
    pcall(function()
      seq_timer:stop()
      seq_timer:close()
    end)
    seq_timer = nil
  end
end

-- After each captured keystroke, try to resolve the accumulated buffer to a
-- defined mapping. Logs `{ event = 'mapping', lhs, desc, mode }` on match.
-- Resets the buffer when no defined mapping starts with the current prefix.
--
-- `orig_buf` is the buffer that was current when the keystroke fired. We have
-- to query maparg/mapcheck in that buffer's context (via nvim_buf_call),
-- because the scheduled lookup runs AFTER the mapped action has executed —
-- which for LSP gotos, Telescope pickers, and rename floats means we've
-- already switched to a different buffer with different (or no) buffer-local
-- mappings. Querying the current buffer at lookup time loses those events
-- silently. We also log the source buf/ft, not the destination's.
local function resolve_mapping(mode, orig_buf)
  if key_seq == '' then
    return
  end
  if not vim.api.nvim_buf_is_valid(orig_buf) then
    reset_seq()
    return
  end
  local ok, m = pcall(vim.api.nvim_buf_call, orig_buf, function()
    return vim.fn.maparg(key_seq, mode, false, true)
  end)
  if ok and type(m) == 'table' and m.desc and m.desc ~= '' then
    log_entry('mapping', {
      lhs = key_seq,
      desc = m.desc,
      mode = mode,
      buf = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(orig_buf), ':t'),
      ft = vim.bo[orig_buf].filetype,
    })
    -- which-key registers its popup trigger as a real mapping on <leader>.
    -- If we reset on that match, slow-typed leader sequences (where the user
    -- pauses for the popup) lose the prefix and the real mapping — e.g.
    -- <leader>sf — never resolves. Keep accumulating instead; the inactivity
    -- timer will still reset if the user truly walks away.
    if not m.desc:match('^which%-key%-trigger') then
      reset_seq()
    end
    return
  end
  local prefix_ok, mc = pcall(vim.api.nvim_buf_call, orig_buf, function()
    return vim.fn.mapcheck(key_seq, mode)
  end)
  if prefix_ok and mc == '' then
    reset_seq()
  end
end

local function register_on_key()
  on_key_ns = vim.on_key(function(raw, typed)
    if not enabled then
      return
    end
    if not typed or typed == '' then
      return
    end
    local mode = vim.fn.mode()
    if not LOG_MODES[mode] then
      return
    end
    local key = vim.fn.keytrans(typed)
    if key == '' then
      return
    end
    local orig_buf = vim.api.nvim_get_current_buf()
    log_entry('key', { key = key, mode = mode })

    -- Accumulate for mapping resolution; restart the inactivity timer.
    key_seq = key_seq .. key
    if not seq_timer then
      seq_timer = vim.uv.new_timer()
    end
    seq_timer:stop()
    seq_timer:start(SEQ_TIMEOUT_MS, 0, vim.schedule_wrap(reset_seq))
    vim.schedule(function()
      resolve_mapping(mode, orig_buf)
    end)
  end)
end

local function deregister_on_key()
  if on_key_ns then
    vim.on_key(nil, on_key_ns)
    on_key_ns = nil
  end
end

local function register_autocmds()
  augroup = vim.api.nvim_create_augroup('usage-logger', { clear = true })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = augroup,
    callback = function(ev)
      local old, new = ev.match:match '(.+):(.+)'
      log_entry('ModeChanged', { old_mode = old, new_mode = new })
      reset_seq()
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = augroup,
    pattern = 'LazyLoad',
    callback = function(ev)
      log_entry('PluginLoaded', { plugin = ev.data })
    end,
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      log_entry('BufEnter', { lines = vim.api.nvim_buf_line_count(buf) })
    end,
  })

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = augroup,
    callback = function()
      log_entry 'BufWritePost'
    end,
  })

  vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = augroup,
    callback = function()
      log_entry('CmdlineEnter', { cmdtype = vim.fn.getcmdtype() })
    end,
  })

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = augroup,
    callback = function()
      local cmdtype = vim.fn.getcmdtype()
      local cmdline = vim.fn.getcmdline()
      local verb = (cmdtype == ':') and cmdline:match '^(%S+)' or nil
      log_entry('CmdlineLeave', { cmdtype = cmdtype, verb = verb })
    end,
  })

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    callback = function()
      local yank = vim.v.event
      log_entry('TextYankPost', {
        operator = yank.operator,
        regtype = yank.regtype,
        visual = yank.visual,
      })
    end,
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = augroup,
    callback = flush_sync,
  })
end

local function start_timer()
  flush_timer = vim.uv.new_timer()
  flush_timer:start(FLUSH_INTERVAL_MS, FLUSH_INTERVAL_MS, vim.schedule_wrap(M._flush))
end

local function stop_timer()
  if flush_timer then
    flush_timer:stop()
    flush_timer:close()
    flush_timer = nil
  end
end

function M.enable()
  if enabled then
    return
  end
  vim.fn.mkdir(USAGE_DIR, 'p')
  enabled = true
  register_autocmds()
  register_on_key()
  start_timer()
  log_entry 'LoggerEnabled'
  vim.notify('Usage logger ON', vim.log.levels.INFO)
end

function M.disable()
  if not enabled then
    return
  end
  log_entry 'LoggerDisabled'
  M._flush()
  enabled = false
  deregister_on_key()
  stop_timer()
  reset_seq()
  if augroup then
    vim.api.nvim_del_augroup_by_id(augroup)
    augroup = nil
  end
  vim.notify('Usage logger OFF', vim.log.levels.INFO)
end

function M.toggle()
  if enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.is_enabled()
  return enabled
end

function M.setup(opts)
  opts = opts or {}
  if opts.auto_start ~= false then
    M.enable()
  end
  vim.keymap.set('n', '<leader>tu', M.toggle, { desc = '[T]oggle [U]sage logger' })
end

return M
