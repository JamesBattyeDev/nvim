return {
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
}
