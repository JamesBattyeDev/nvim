return {
  -- Sticky context (shows current function/class at top of viewport)
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    opts = {
      max_lines = 3,
    },
  },
}
