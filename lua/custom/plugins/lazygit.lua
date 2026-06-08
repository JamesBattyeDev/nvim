return {
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
}
