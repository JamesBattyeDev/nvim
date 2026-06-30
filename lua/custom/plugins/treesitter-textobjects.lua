return {
  -- Treesitter textobjects (function navigation with ]m / [m)
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        move = { set_jumps = true },
      }

      -- Select text objects: af/if (function), ac/ic (class)
      local select = require 'nvim-treesitter-textobjects.select'
      vim.keymap.set({ 'x', 'o' }, 'af', function() select.select_textobject('@function.outer', 'textobjects') end, { desc = 'a function' })
      vim.keymap.set({ 'x', 'o' }, 'if', function() select.select_textobject('@function.inner', 'textobjects') end, { desc = 'inner function' })
      vim.keymap.set({ 'x', 'o' }, 'ac', function() select.select_textobject('@class.outer', 'textobjects') end, { desc = 'a class' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function() select.select_textobject('@class.inner', 'textobjects') end, { desc = 'inner class' })

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
}
