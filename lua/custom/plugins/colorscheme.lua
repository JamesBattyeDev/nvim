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

  -- Extra themes (installed but not applied until picked via <leader>u below)
  { 'rose-pine/neovim', name = 'rose-pine', priority = 1000 },
  { 'folke/tokyonight.nvim', priority = 1000 },

  -- ========================================================================
  -- Theme picker: <leader>u + home row (asdfg) jumps straight to a theme
  -- ========================================================================
  {
    'nvim-lua/plenary.nvim', -- always-loaded host so these keymaps register early
    lazy = false,
    config = function()
      -- key -> { colorscheme, human-readable label }
      local picks = {
        a = { 'catppuccin-mocha', 'Catppuccin Mocha (dark)' },
        s = { 'catppuccin-latte', 'Catppuccin Latte (light)' },
        d = { 'rose-pine-dawn', 'Rosé Pine Dawn (light)' },
        f = { 'tokyonight-day', 'Tokyonight Day (light)' },
        g = { 'tokyonight-moon', 'Tokyonight Moon (dark)' },
      }

      for key, pick in pairs(picks) do
        local scheme, label = pick[1], pick[2]
        vim.keymap.set('n', '<leader>u' .. key, function()
          vim.cmd.colorscheme(scheme)
          vim.notify('Theme: ' .. label, vim.log.levels.INFO)
        end, { desc = label })
      end
    end,
  },
}
