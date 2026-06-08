return {
  -- ========================================================================
  -- LSP: Language servers for JS/TS/HTML/CSS/GLSL + Lua
  -- ========================================================================
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'lazy.nvim', words = { 'LazyVim' } },
        { path = 'blink.cmp', words = { 'blink%.cmp' } },
      },
    },
  },
}
