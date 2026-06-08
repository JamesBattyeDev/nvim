return {
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
}
