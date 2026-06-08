-- debug.lua
--
-- DAP (Debug Adapter Protocol) setup for JS/TS/Node debugging.
-- Adapter: Mason-installed js-debug-adapter (vscode-js-debug).
-- All keymaps under <leader>d for [D]ebug.

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    { '<leader>dc', function() require('dap').continue() end, desc = '[D]ebug: [C]ontinue / Start' },
    { '<leader>di', function() require('dap').step_into() end, desc = '[D]ebug: Step [I]nto' },
    { '<leader>do', function() require('dap').step_over() end, desc = '[D]ebug: Step [O]ver' },
    { '<leader>du', function() require('dap').step_out() end, desc = '[D]ebug: Step O[u]t' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug: Toggle [B]reakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = '[D]ebug: Conditional [B]reakpoint' },
    { '<leader>dl', function() require('dap').list_breakpoints() vim.cmd 'copen' end, desc = '[D]ebug: [L]ist Breakpoints' },
    { '<leader>dX', function() require('dap').clear_breakpoints() end, desc = '[D]ebug: Clear All Breakpoints' },
    { '<leader>dt', function() require('dapui').toggle() end, desc = '[D]ebug: [T]oggle UI' },
    { '<leader>dr', function() require('dap').restart() end, desc = '[D]ebug: [R]estart' },
    { '<leader>dq', function() require('dap').terminate() end, desc = '[D]ebug: [Q]uit / Terminate' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Ensure js-debug-adapter is installed via Mason
    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = { 'js' },
    }

    -- Register pwa-node and pwa-chrome adapters manually
    -- (mason-nvim-dap default handler doesn't reliably register these)
    local js_debug_path = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'

    for _, adapter in ipairs { 'pwa-node', 'pwa-chrome' } do
      dap.adapters[adapter] = {
        type = 'server',
        host = '127.0.0.1',
        port = '${port}',
        executable = {
          command = 'node',
          args = { js_debug_path, '${port}', '127.0.0.1' },
        },
      }
    end

    -- Debug configurations for JS/TS filetypes
    local js_filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }

    for _, ft in ipairs(js_filetypes) do
      dap.configurations[ft] = {
        -- 1. Launch current file with Node (most reliable)
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch Current File (Node)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          autoAttachChildProcesses = true,
          skipFiles = { '<node_internals>/**' },
        },
        -- 2. Attach to running --inspect process
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to Node Process',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          autoAttachChildProcesses = true,
          skipFiles = { '<node_internals>/**' },
        },
        -- 3. Chrome (for frontend/client-side debugging)
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch Chrome (localhost:3000)',
          url = 'http://localhost:3000',
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
    end

    -- DAP UI
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Auto open/close DAP UI with debug sessions
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
