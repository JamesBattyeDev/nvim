return {
  {
    'ThePrimeagen/99',
    dependencies = { { 'saghen/blink.compat', version = '2.*' } },
    config = function()
      local _99 = require '99'

      _99.setup {
        provider = _99.Providers.ClaudeCodeProvider,
        model = 'claude-opus-4-7',
        tmp_dir = './tmp',
        md_files = { 'AGENT.md' },
        completion = { source = 'blink' },
        logger = {
          level = _99.DEBUG,
          path = '/tmp/' .. vim.fs.basename(vim.uv.cwd()) .. '.99.debug',
          print_on_error = true,
        },
      }

      vim.keymap.set('v', '<leader>a', function() _99.visual() end, { desc = '[A]I rewrite selection (99)' })
      vim.keymap.set('n', '<leader>9s', function() _99.search() end, { desc = '[9]9 [S]earch: agentic project search → qf' })
      vim.keymap.set('n', '<leader>9o', function() _99.open() end, { desc = '[9]9 [O]pen: last interaction result' })
      vim.keymap.set('n', '<leader>9l', function() _99.view_logs() end, { desc = '[9]9 view [L]ogs' })
      vim.keymap.set('n', '<leader>9x', function() _99.stop_all_requests() end, { desc = '[9]9 cancel ([X]) all requests' })
      vim.keymap.set('n', '<leader>9c', function() _99.clear_previous_requests() end, { desc = '[9]9 [C]lear previous requests' })
    end,
  },
}
