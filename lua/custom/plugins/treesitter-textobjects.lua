return {
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
}
